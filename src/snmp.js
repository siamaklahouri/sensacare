/* ==================== SNMP نسخهٔ ۲c ====================
   برای خواندنِ مصرفِ اینترنت از خودِ روتر. هر روتر و سوییچِ مدیریتی
   شمارندهٔ بایتِ هر پورت را دارد و SNMP زبانِ استانداردِ خواندنش است؛
   پس به‌جای بستن به یک برند، همین را می‌گوییم.

   کتابخانه‌ای اضافه نشد. SNMP روی UDP است و بسته‌اش BER است — صد خط
   کُد، در برابر یک وابستگیِ تازه که باید به‌روز نگه داشته شود و روی
   سرورِ خودمان بنشیند. آنچه لازم است همین سه تاست: GET، GETNEXT، و
   یک پیمایشِ ساده روی زیرشاخه.

   امنیت: جامعه (community) رمز نیست و روی سیم هم رمز نمی‌شود — این
   ذاتِ v2c است. پس فقط خواندن، و هیچ SET‌ای این‌جا نیست. */
import dgram from 'node:dgram';

/* ---------- BER ---------- */
const INT = 0x02, OCTET = 0x04, NULLT = 0x05, OID = 0x06, SEQ = 0x30;
export const TYPES = {
  2: 'int', 4: 'str', 5: 'null', 6: 'oid',
  0x40: 'ip', 0x41: 'counter', 0x42: 'gauge', 0x43: 'ticks',
  0x44: 'opaque', 0x46: 'counter64',
  0x80: 'نیست', 0x81: 'نمونه‌ای نیست', 0x82: 'پایانِ درخت'
};

function len(n) {
  if (n < 0x80) return Buffer.from([n]);
  const b = [];
  let x = n;
  while (x > 0) { b.unshift(x & 0xff); x = Math.floor(x / 256); }
  return Buffer.from([0x80 | b.length, ...b]);
}
function tlv(type, body) {
  return Buffer.concat([Buffer.from([type]), len(body.length), body]);
}
function int(n) {
  const b = [];
  let x = Math.trunc(n);
  if (x === 0) b.push(0);
  while (x > 0) { b.unshift(x & 0xff); x = Math.floor(x / 256); }
  if (b[0] & 0x80) b.unshift(0);           /* مثبت است، نه منفی */
  return tlv(INT, Buffer.from(b));
}
function varint(n) {
  const b = [n & 0x7f];
  let x = Math.floor(n / 128);
  while (x > 0) { b.unshift((x & 0x7f) | 0x80); x = Math.floor(x / 128); }
  return b;
}
export function encOid(oid) {
  const p = String(oid).replace(/^\./, '').split('.').map(Number);
  if (p.length < 2 || p.some(x => !Number.isFinite(x))) throw new Error('OID نادرست');
  const b = [40 * p[0] + p[1]];
  for (let i = 2; i < p.length; i++) b.push(...varint(p[i]));
  return tlv(OID, Buffer.from(b));
}

/* خواندنِ یک TLV: نوع، بدنه، و جایی که تمام شد. */
function read(buf, i) {
  const type = buf[i];
  let j = i + 1, n = buf[j++];
  if (n & 0x80) {
    const k = n & 0x7f;
    n = 0;
    for (let x = 0; x < k; x++) n = n * 256 + buf[j++];
  }
  return { type, start: j, end: j + n, body: buf.slice(j, j + n) };
}
function toInt(b) {
  let n = 0;
  for (const x of b) n = n * 256 + x;
  return n;
}
function decOid(b) {
  const out = [Math.floor(b[0] / 40), b[0] % 40];
  let acc = 0;
  for (let i = 1; i < b.length; i++) {
    acc = acc * 128 + (b[i] & 0x7f);
    if (!(b[i] & 0x80)) { out.push(acc); acc = 0; }
  }
  return out.join('.');
}
function decVal(t) {
  const k = TYPES[t.type];
  if (k === 'str') return t.body.toString('utf8').replace(/\u0000/g, '');
  if (k === 'oid') return decOid(t.body);
  if (k === 'null' || k === undefined) return null;
  if (t.type >= 0x80 && t.type <= 0x82) return null;
  return toInt(t.body);                    /* int، counter، gauge، ticks، counter64 */
}

/* ---------- یک درخواست ----------
   pdu: 0=GET، 1=GETNEXT. */
function packet(community, pdu, reqId, oids) {
  const binds = oids.map(o => tlv(SEQ, Buffer.concat([encOid(o), tlv(NULLT, Buffer.alloc(0))])));
  const body = Buffer.concat([
    int(reqId), int(0), int(0), tlv(SEQ, Buffer.concat(binds))
  ]);
  return tlv(SEQ, Buffer.concat([
    int(1),                                /* نسخهٔ ۲c */
    tlv(OCTET, Buffer.from(String(community), 'utf8')),
    tlv(0xa0 | pdu, body)
  ]));
}

function parse(buf) {
  const msg = read(buf, 0);
  let i = msg.start;
  const ver = read(buf, i); i = ver.end;
  const com = read(buf, i); i = com.end;
  const pdu = read(buf, i);
  let j = pdu.start;
  const id = read(buf, j); j = id.end;
  const err = read(buf, j); j = err.end;
  const idx = read(buf, j); j = idx.end;
  const vbs = read(buf, j);
  const out = [];
  let k = vbs.start;
  while (k < vbs.end) {
    const vb = read(buf, k);
    const name = read(buf, vb.start);
    const val = read(buf, name.end);
    out.push({ oid: decOid(name.body), type: TYPES[val.type] || val.type, value: decVal(val) });
    k = vb.end;
  }
  return { id: toInt(id.body), err: toInt(err.body), binds: out };
}

const ERR = {
  1: 'جوابِ دستگاه از بستهٔ ما بزرگ‌تر بود', 2: 'چنین چیزی روی دستگاه نیست',
  3: 'مقدارِ نادرست', 4: 'فقط‌خواندنی', 5: 'خطای خودِ دستگاه',
  6: 'اجازه نبود', 16: 'اجازهٔ خواندنِ این شاخه نبود'
};

/* یک رفت‌وبرگشت. چیزی برنگشت یعنی یا SNMP خاموش است، یا جامعه غلط
   است، یا فایروال وسط — از بیرون این سه فرقی ندارند و همین را هم
   می‌گوییم، نه بیشتر. */
function ask(host, port, community, pdu, oids, ms) {
  const wait = Math.min(Math.max(parseInt(ms, 10) || 1500, 300), 8000);
  return new Promise(resolve => {
    let done = false;
    const sock = dgram.createSocket('udp4');
    const reqId = Math.floor(Math.random() * 0x7ffffff) + 1;
    const end = (ok, data, error) => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      try { sock.close(); } catch (e) { }
      resolve(ok ? { ok: true, binds: data } : { ok: false, error: error || 'پاسخی نداد' });
    };
    const timer = setTimeout(() => end(false, null, 'پاسخی نداد'), wait);
    sock.on('message', msg => {
      let r;
      try { r = parse(msg); } catch (e) { return end(false, null, 'جوابش خوانده نشد'); }
      if (r.id !== reqId) return;
      if (r.err) return end(false, null, ERR[r.err] || ('خطای ' + r.err));
      end(true, r.binds);
    });
    sock.on('error', e => end(false, null, (e && e.code) || 'خطای شبکه'));
    let buf;
    try { buf = packet(community, pdu, reqId, oids); }
    catch (e) { return end(false, null, e.message); }
    sock.send(buf, port || 161, host, e => { if (e) end(false, null, (e && e.code) || 'نرفت'); });
  });
}

export const snmpGet = (host, community, oids, opt) =>
  ask(host, (opt || {}).port, community, 0, oids, (opt || {}).ms);

export const snmpNext = (host, community, oids, opt) =>
  ask(host, (opt || {}).port, community, 1, oids, (opt || {}).ms);

/* پیمایشِ یک زیرشاخه، با GETNEXT. سقفِ قدم دارد تا روی دستگاهی که
   درختش بزرگ است، یک درخواستِ صفحه بی‌پایان نشود. */
export async function snmpWalk(host, community, root, opt) {
  const o = opt || {};
  const max = Math.min(Math.max(parseInt(o.max, 10) || 60, 1), 400);
  const out = [];
  let cur = root;
  for (let i = 0; i < max; i++) {
    const r = await snmpNext(host, community, [cur], o);
    if (!r.ok) return i ? { ok: true, rows: out } : r;
    const b = r.binds[0];
    if (!b || !b.oid) break;
    /* سه دلیلِ ایستادن، و هر سه لازم‌اند:
       • از شاخه بیرون زد — پیمایش تمام است.
       • جلو نرفت و همان قبلی را داد — دستگاهی که پایانِ درخت را
         درست اعلام نمی‌کند، وگرنه ما تا سقفِ قدم همان یک شاخه را
         می‌پرسیدیم و فهرست پر از ردیفِ تکراریِ تهی می‌شد.
       • مقدار تهی بود — «چنین چیزی نیست» و «پایانِ درخت». */
    if (b.oid.indexOf(root + '.') !== 0) break;
    if (b.oid === cur) break;
    if (b.value == null) break;
    out.push(b);
    cur = b.oid;
  }
  return { ok: true, rows: out };
}
