/* پشتیبان را برمی‌گرداند و می‌سنجد که همان چیزی برگردد که رفته بود.

   تا امروز این مسیر هیچ آزمونی نداشت: گرفتنِ پشتیبان آزموده می‌شد،
   برگرداندنش نه. یعنی تنها چیزی که در روزِ بد به کار می‌آید، تنها
   چیزی بود که هیچ‌وقت امتحان نشده بود — همان اشتباهی که یک بار
   خوردیم و پشتیبان‌های ۳ تا ۸ آبان بی‌استفاده ماندند.

   و همین آزمون، همان بار اول، چیزی پیدا کرد: فایلِ JSONِ داخلِ
   پشتیبان فقط «state» را داشت. نیمِ کارتابل — سرورها، تقویمِ بکاپ،
   شرکت‌ها، MVPN، و در کارتابلِ مالی تقریباً همه‌چیز — در «db» است و
   داخلِ فایل نبود. بازیابی هم «با موفقیت انجام شد» می‌گفت. */
import { inflateRawSync } from 'node:zlib';
import { IT_API, IT_PASS, FIN_API, FIN_PASS } from './where.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* ---- یک مشتریِ HTTP با کوکی ---- */
function client() {
  let ck = '';
  return async (path, opt) => {
    const o = Object.assign({ headers: {} }, opt || {});
    o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
    const r = await fetch(BASE + path, o);
    for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
      const kv = c.split(';')[0], k = kv.split('=')[0];
      ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
    }
    const ct = r.headers.get('content-type') || '';
    const body = ct.includes('json') ? await r.json().catch(() => ({}))
                                     : Buffer.from(await r.arrayBuffer());
    return { status: r.status, body };
  };
}

/* ---- خواندنِ زیپ: فهرستِ مرکزی، همان راهی که bkcheck می‌رود ---- */
function unzip(buf) {
  const out = new Map();
  let end = buf.length - 22;
  while (end >= 0 && buf.readUInt32LE(end) !== 0x06054b50) end--;
  if (end < 0) return out;
  let n = buf.readUInt16LE(end + 10), at = buf.readUInt32LE(end + 16);
  for (let i = 0; i < n; i++) {
    if (buf.readUInt32LE(at) !== 0x02014b50) break;
    const method = buf.readUInt16LE(at + 10);
    const csize = buf.readUInt32LE(at + 20), usize = buf.readUInt32LE(at + 24);
    const nlen = buf.readUInt16LE(at + 28), elen = buf.readUInt16LE(at + 30);
    const clen = buf.readUInt16LE(at + 32), lho = buf.readUInt32LE(at + 42);
    const name = buf.slice(at + 46, at + 46 + nlen).toString('utf8');
    const lnlen = buf.readUInt16LE(lho + 26), lelen = buf.readUInt16LE(lho + 28);
    const start = lho + 30 + lnlen + lelen;
    const raw = buf.slice(start, start + csize);
    out.set(name, method === 8 ? inflateRawSync(raw) : raw);
    at += 46 + nlen + elen + clen;
    void usize;
  }
  return out;
}

/* نشانی‌هایی که در هر دو نیمه می‌گذاریم و بعد دنبالشان می‌گردیم */
const MARK = 'نشانهٔ-آزمونِ-بازیابی-' + Date.now();

async function roundTrip(label, api, pass, folder, seedDb) {
  console.log('\n===== ' + label + ' =====');
  const admin = client();
  await admin('/api/admin.planer/signin',
    { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });

  const k = client();
  const li = await k('/api/' + api + '/login', { method: 'POST', body: JSON.stringify({ password: pass }) });
  if (li.status !== 200) { t(false, 'ورود به کارتابل', 'کد ' + li.status); return; }

  /* ۱) دادهٔ شناخته‌شده بگذار — در هر دو نیمه.
     «before» را نگه می‌داریم تا آخرِ کار دقیقاً همان را برگردانیم:
     دیتابیسِ آزمون میانِ همهٔ آزمون‌ها مشترک است و ردیفی که این‌جا
     جا بماند، آزمونِ بعدی را می‌شکند — یک بار همین شد و دو آزمونِ
     بی‌ربط قرمز شدند. */
  const before = await k('/api/' + api + '/state');
  const st = Object.assign({}, before.body.state || {});
  st.meta = Object.assign({}, st.meta, { restoreMark: MARK });
  /* ردیفِ نشانه را به آن‌چه هست «اضافه» می‌کنیم، نه جایش بنشانیم:
     سرور نوشتنی را که داده را کم کند رد می‌کند (۴۰۹ با «loss») — یک
     محافظت، نه یک ایراد. پایین‌تر خودِ همین را هم می‌سنجیم. */
  const db = seedDb(MARK, before.body.db || {});
  const put = await k('/api/' + api + '/state',
    { method: 'PUT', body: JSON.stringify({ state: st, db, baseRev: before.body.rev }) });
  t(put.status === 200, 'دادهٔ آزمون نشست',
    'کد ' + put.status + (put.status !== 200 ? ' ' + JSON.stringify(put.body).slice(0, 80) : ''));

  /* ۲) پشتیبان بگیر */
  const bk = await admin('/api/admin.planer/kartablBackupDownload?slug=' + folder);
  let zipBuf = null;
  if (bk.status === 200 && Buffer.isBuffer(bk.body)) zipBuf = bk.body;
  if (!zipBuf) {
    const alt = await k('/api/' + api + '/backup/download');
    if (alt.status === 200 && Buffer.isBuffer(alt.body)) zipBuf = alt.body;
  }
  t(!!zipBuf && zipBuf.length > 1000, 'زیپِ پشتیبان ساخته شد',
    zipBuf ? Math.round(zipBuf.length / 1024) + 'KB' : 'نشد');
  if (!zipBuf) return;

  const files = unzip(zipBuf);
  const jsonName = [...files.keys()].find(n => n.endsWith('.json'));
  t(!!jsonName, 'فایلِ JSON داخلِ زیپ هست', jsonName);
  if (!jsonName) return;

  let doc;
  try { doc = JSON.parse(files.get(jsonName).toString('utf8')); }
  catch (e) { t(false, 'JSON خوانده شد', e.message); return; }

  /* ۳) هسته: آیا هر دو نیمه داخلِ فایل‌اند؟ */
  t(doc && doc.state && typeof doc.state === 'object',
    'فایل نیمهٔ «state» را دارد');
  t(doc && doc.db && typeof doc.db === 'object',
    'و نیمهٔ «db» را هم دارد — سرورها و جدول‌ها');
  t(doc && doc.kartabl === 2, 'و نسخهٔ شکلِ فایل علامت خورده', doc && doc.kartabl);

  const inState = JSON.stringify(doc.state || {}).includes(MARK);
  const inDb = JSON.stringify(doc.db || {}).includes(MARK);
  t(inState, 'نشانهٔ نیمهٔ اول داخلِ فایل پیدا شد');
  t(inDb, 'نشانهٔ نیمهٔ دوم هم پیدا شد');

  /* ۴) کارتابل را خالی کن.
     rev باید همان لحظه خوانده شود: ساختنِ پشتیبان خودش یک عکسِ تازه
     می‌گیرد و شماره را جلو می‌برد، پس revِ مرحلهٔ یک دیگر کهنه است و
     سرور درست ۴۰۹ می‌دهد. */
  const nowRev = (await k('/api/' + api + '/state')).body.rev;
  /* اول بی force: سرور باید جلویش را بگیرد. این همان چیزی است که
     نمی‌گذارد یک اشتباهِ مرورگر کارتابل را پاک کند. */
  const guard = await k('/api/' + api + '/state',
    { method: 'PUT', body: JSON.stringify({ state: {}, db: {}, baseRev: nowRev }) });
  t(guard.status !== 200, 'سرور جلوی پاک‌شدنِ بی‌اجازه را می‌گیرد', 'کد ' + guard.status);
  t(guard.body && (guard.body.loss || guard.body.broken), 'و دلیلش را می‌گوید',
    JSON.stringify(guard.body || {}).slice(0, 60));
  /* حالا عمداً و با اجازه */
  const wipe = await k('/api/' + api + '/state',
    { method: 'PUT', body: JSON.stringify({ state: {}, db: {}, baseRev: nowRev, force: true }) });
  t(wipe.status === 200, 'ولی با اجازه خالی می‌شود', 'کد ' + wipe.status);
  const empty = await k('/api/' + api + '/state');
  t(!JSON.stringify(empty.body.state || {}).includes(MARK), 'و نشانه دیگر نیست');

  /* ۵) از روی خودِ فایل برگردان — همان کاری که صفحه می‌کند */
  const back = await k('/api/' + api + '/state',
    { method: 'PUT', body: JSON.stringify({ state: doc.state, db: doc.db,
                                            baseRev: empty.body.rev, force: true }) });
  t(back.status === 200, 'بازیابی از روی فایل', 'کد ' + back.status);

  /* ۶) مقایسهٔ دقیق */
  const after = await k('/api/' + api + '/state');
  t(JSON.stringify(after.body.state || {}).includes(MARK), 'نیمهٔ اول برگشت');
  t(JSON.stringify(after.body.db || {}).includes(MARK), 'نیمهٔ دوم هم برگشت');
  t(JSON.stringify(after.body.state) === JSON.stringify(doc.state),
    'و «state» مو‌به‌مو همان است که در فایل بود');
  t(JSON.stringify(after.body.db) === JSON.stringify(doc.db),
    'و «db» هم همان');

  /* ۷) جارو: کارتابل را به همان حالی که تحویل گرفتیم برگردان */
  const endRev = (await k('/api/' + api + '/state')).body.rev;
  const put2 = await k('/api/' + api + '/state',
    { method: 'PUT', body: JSON.stringify({ state: before.body.state, db: before.body.db,
                                            baseRev: endRev, force: true }) });
  t(put2.status === 200, 'و کارتابل به حالِ اولش برگشت', 'کد ' + put2.status);
  const final = await k('/api/' + api + '/state');
  t(!JSON.stringify(final.body).includes(MARK), 'هیچ نشانی از آزمون نماند');
}

await roundTrip('کارتابلِ فنی', IT_API, IT_PASS, 'It',
  (m, cur) => Object.assign({}, cur, { vm: (cur.vm || []).concat(
    [{ server: m, location: '10.9.9.9', schedule: 'روزانه دوبار', storage: 'S-1' }]) }));

await roundTrip('کارتابلِ مالی', FIN_API, FIN_PASS, 'Fin',
  (m, cur) => Object.assign({}, cur, { parties: (cur.parties || []).concat(
    [{ name: m, kind: 'مشتری' }]) }));

/* ---------- فایلِ قدیمی هم باید باز شود ---------- */
console.log('\n===== سازگاری با فایلِ قدیمی =====');
{
  /* شکلِ قدیمی: خودِ state، بی هیچ پوششی. بازیابی باید از روی نبودنِ
     کلیدِ «state» بفهمد و همان را به‌عنوان state بردارد. */
  const oldFile = { meta: { x: 1 }, tasks: [], days: [] };
  const sniff = o => !!(o && typeof o === 'object' && o.state && typeof o.state === 'object');
  t(sniff(oldFile) === false, 'فایلِ قدیمی «پوشیده» تشخیص داده نمی‌شود');
  t(sniff({ kartabl: 2, state: { meta: {} }, db: {} }) === true, 'و فایلِ تازه بله');
  t(sniff(null) === false, 'و فایلِ خراب هم چیزی نمی‌شکند');

  /* و همین منطق باید در هر دو قالب باشد، نه فقط یکی */
  const { readFileSync } = await import('node:fs');
  for (const f of ['it.tpl', 'fin.tpl']) {
    const src = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
    t(/parsed\.state && typeof parsed\.state === "object"/.test(src),
      f + ': هر دو شکلِ فایل را می‌شناسد');
    t(/applyDbSnapshot\(parsed\.db\)/.test(src),
      f + ': و نیمهٔ db را هم برمی‌گرداند');
    t(/kartabl: 2, stamp: Date\.now\(\), state: state, db: dbSnapshot\(\)/.test(src),
      f + ': و خروجی‌اش هر دو نیمه را می‌نویسد');
  }
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
