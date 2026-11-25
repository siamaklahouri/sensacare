/* یک عاملِ SNMP ساختگی، فقط برای آزمون.

   بدونِ این، آزمونِ «مصرف» به یک روترِ واقعی بند بود — یعنی عملاً
   آزمونی وجود نداشت. این عامل همان چند شاخه‌ای را می‌دهد که
   خواننده می‌خواهد: نامِ دستگاه، نامِ پورت‌ها، و شمارنده‌ها. */
import dgram from 'node:dgram';

const INT = 0x02, OCTET = 0x04, NULLT = 0x05, OID = 0x06, SEQ = 0x30, C64 = 0x46;
const len = n => { if (n < 0x80) return Buffer.from([n]); const b = []; let x = n;
  while (x > 0) { b.unshift(x & 0xff); x = Math.floor(x / 256); }
  return Buffer.from([0x80 | b.length, ...b]); };
const tlv = (t, b) => Buffer.concat([Buffer.from([t]), len(b.length), b]);
const int = (n, t = INT) => { const b = []; let x = Math.trunc(n);
  if (x === 0) b.push(0);
  while (x > 0) { b.unshift(x & 0xff); x = Math.floor(x / 256); }
  if (b[0] & 0x80) b.unshift(0); return tlv(t, Buffer.from(b)); };
const varint = n => { const b = [n & 0x7f]; let x = Math.floor(n / 128);
  while (x > 0) { b.unshift((x & 0x7f) | 0x80); x = Math.floor(x / 128); } return b; };
const encOid = o => { const p = o.split('.').map(Number); const b = [40 * p[0] + p[1]];
  for (let i = 2; i < p.length; i++) b.push(...varint(p[i])); return tlv(OID, Buffer.from(b)); };
function read(buf, i) { const type = buf[i]; let j = i + 1, n = buf[j++];
  if (n & 0x80) { const k = n & 0x7f; n = 0; for (let x = 0; x < k; x++) n = n * 256 + buf[j++]; }
  return { type, start: j, end: j + n, body: buf.slice(j, j + n) }; }
const toInt = b => { let n = 0; for (const x of b) n = n * 256 + x; return n; };
const decOid = b => { const out = [Math.floor(b[0] / 40), b[0] % 40]; let a = 0;
  for (let i = 1; i < b.length; i++) { a = a * 128 + (b[i] & 0x7f); if (!(b[i] & 0x80)) { out.push(a); a = 0; } }
  return out.join('.'); };
const cmp = (a, b) => { const x = a.split('.').map(Number), y = b.split('.').map(Number);
  for (let i = 0; i < Math.max(x.length, y.length); i++) {
    const u = x[i] == null ? -1 : x[i], v = y[i] == null ? -1 : y[i];
    if (u !== v) return u < v ? -1 : 1; } return 0; };

/* mib: {oid: {t:'str'|'int'|'c64', v}} — ترتیبش را خودمان مرتب می‌کنیم */
export function fakeAgent(mib, opt) {
  const o = opt || {};
  const community = o.community || 'public';
  const sock = dgram.createSocket('udp4');
  const val = x => x.t === 'str' ? tlv(OCTET, Buffer.from(String(x.v), 'utf8'))
    : x.t === 'end' ? tlv(0x82, Buffer.alloc(0))
    : x.t === 'c64' ? int(x.v, C64) : int(x.v);

  sock.on('message', (msg, rinfo) => {
    let m, com, pdu, reqId, oid;
    try {
      m = read(msg, 0);
      let i = m.start;
      const ver = read(msg, i); i = ver.end;
      com = read(msg, i); i = com.end;
      pdu = read(msg, i);
      let j = pdu.start;
      const id = read(msg, j); j = id.end;
      reqId = toInt(id.body);
      const e1 = read(msg, j); j = e1.end;
      const e2 = read(msg, j); j = e2.end;
      const vbs = read(msg, j);
      oid = [];
      let k = vbs.start;
      while (k < vbs.end) { const vb = read(msg, k); const nm = read(msg, vb.start);
        oid.push(decOid(nm.body)); k = vb.end; }
    } catch (e) { return; }
    if (com.body.toString('utf8') !== community) return;   /* جامعهٔ غلط: سکوت، مثلِ دستگاهِ واقعی */

    const keys = Object.keys(mib).sort(cmp);
    const binds = oid.map(q => {
      if ((pdu.type & 0x1f) === 1) {                        /* GETNEXT */
        const nx = keys.find(k => cmp(k, q) > 0);
        /* پایانِ درخت را دستگاهِ واقعی با نوعِ ۰x82 می‌گوید، نه با
           تکرارِ همان شاخه. */
        return nx ? { oid: nx, v: mib[nx] } : { oid: q, v: { t: 'end' } };
      }
      return { oid: q, v: mib[q] || null };
    });
    const body = Buffer.concat([
      int(reqId), int(0), int(0),
      tlv(SEQ, Buffer.concat(binds.map(b =>
        tlv(SEQ, Buffer.concat([encOid(b.oid),
          b.v ? val(b.v) : tlv(NULLT, Buffer.alloc(0))])))))
    ]);
    const out = tlv(SEQ, Buffer.concat([int(1), tlv(OCTET, Buffer.from(community)), tlv(0xa2, body)]));
    sock.send(out, rinfo.port, rinfo.address);
  });
  return new Promise(r => sock.bind(o.port || 0, o.host || '127.0.0.1',
    () => r({ port: sock.address().port, close: () => sock.close(), sock })));
}
