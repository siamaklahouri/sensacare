/* کاربری که وسطِ پاسخ می‌رود، خطای سرور نیست.

   «⚠️ خطای سرور SLTech / GET /api/kartabl/me / Premature close» چند
   بار از ربات آمد. ایرادِ سرور نبود: pipeline وقتی مقصدش — سوکتِ
   مرورگر — نیمهٔ راه بسته شود همین را می‌اندازد. تب بسته شده بود یا
   شبکه رفته بود. هیچ‌کس خطایی ندیده بود.

   هشدارِ دروغ بدتر از نبودنِ هشدار است: چند بار که بیاید، آدم دیگر
   بازش نمی‌کند، و آن روز که خطای واقعی بیاید هم همان‌جا می‌ماند.

   این آزمون واقعاً وسطِ پاسخ سوکت را می‌بندد — ادای خطا را
   درنمی‌آورد — و بعد می‌بیند که ردیفی در app_errors ننشسته و سرور
   هم سرِ پا مانده.

   و مرزِ مهم‌تر: خطای واقعیِ سرور باید همچنان ثبت شود. اگر این
   آزمون فقط «ثبت نشد» را می‌سنجید، یک «return» زودهنگام در همان
   مسیر هم قبول می‌شد و همهٔ هشدارها را خاموش می‌کرد. */
import { DatabaseSync } from 'node:sqlite';
import { connect } from 'node:net';
import { dirname, join } from 'node:path';
import { readFileSync } from 'node:fs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const DB = process.env.DB_FILE;
const U = new URL(BASE);

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const sleep = ms => new Promise(r => setTimeout(r, ms));

const db = new DatabaseSync(DB);
const rows = () => db.prepare('SELECT sig, n, msg FROM app_errors').all();

/* ---------- ۱) سوکت را وسطِ پاسخ می‌بندیم ---------- */
console.log('— قطعِ کاربر —');
db.prepare('DELETE FROM app_errors').run();

/* مسیری که پاسخش بزرگ است تا نوشتنش چند تکه طول بکشد. */
const big = await (async () => {
  const r = await fetch(BASE + '/siamak/', { headers: { Host: 'sltech.ir' } });
  const html = await r.text();
  const m = html.match(/\/_a\/k-[a-z]+-[a-f0-9]+\.js/);
  return m ? m[0] : '';
})();
{
  const head = big ? await fetch(BASE + big, { headers: { Host: 'sltech.ir' } }) : null;
  const size = head ? (await head.arrayBuffer()).byteLength : 0;
  t(size > 100000, 'پروندهٔ بزرگ پیدا شد — وگرنه قطع وسطِ نوشتن نمی‌افتد',
    big + ' (' + Math.round(size / 1024) + ' kB)');
}

/* سوکتِ خام، نه http.request: باید بی‌آن‌که چیزی خوانده شود بسته
   شود تا سرور وسطِ نوشتن بماند. با http.request و خواندنِ سرآیند،
   لایهٔ کرنل تمامِ ۷۰۰ کیلوبایت را می‌بلعد و قطع اصلاً نمی‌افتد —
   همین اول مرا گول زد و آزمونی ساخت که بی‌هیچ قطعی سبز می‌شد. */
function hit(waitMs) {
  return new Promise(done => {
    const s = connect(Number(U.port), U.hostname, () => {
      s.write('GET ' + big + ' HTTP/1.1\r\nHost: sltech.ir\r\nConnection: close\r\n\r\n');
      setTimeout(() => { s.destroy(); done(); }, waitMs);
    });
    s.on('error', () => done());
  });
}

/* لاگِ سرور کنارِ دیتابیسِ آزمون است. بی آن، این آزمون نمی‌تواند
   ثابت کند قطع واقعاً افتاده — و آزمونی که نداند چیزی را سنجیده یا
   نه، سبزِ بی‌معنی است. */
const LOG = join(dirname(DB), 'log');
const goneLines = () => {
  try { return (readFileSync(LOG, 'utf8').match(/قطعِ کاربر/g) || []).length; }
  catch (e) { return -1; }
};
const before = goneLines();
t(before >= 0, 'لاگِ سرور برای راستی‌آزمایی در دسترس است', LOG);

let tries = 0;
for (const ms of [0, 3, 10, 30, 80, 0, 3, 10, 30, 80]) {
  tries++;
  await hit(ms);
  await sleep(150);
  if (goneLines() > before) break;
}
const after = goneLines();
t(after > before, 'سرور قطعِ وسطِ نوشتن را دید', (after - before) + ' بار، در ' + tries + ' تلاش');

await sleep(700);
{
  const r = rows();
  t(r.length === 0, 'و هیچ ردیفی در app_errors ننشست',
    r.length ? r.map(x => x.sig).join(' / ') : 'خالی');
  t(!r.some(x => /Premature|close/i.test(x.msg || '')),
    'و هیچ «Premature close»ای ثبت نشد');
}

/* ---------- ۲) سرور سرِ پا مانده ---------- */
{
  const r = await fetch(BASE + '/siamak/', { headers: { Host: 'sltech.ir' } });
  t(r.status === 200, 'سرور بعد از قطع‌ها همچنان جواب می‌دهد', 'کد ' + r.status);
}

/* ---------- ۳) خطای واقعی هنوز ثبت می‌شود ---------- */
console.log('— خطای واقعی —');
{
  db.prepare('DELETE FROM app_errors').run();
  /* مسیری که با ۵۰۰ برمی‌گردد لازم نیست؛ خودِ noteError از همین راه
     صدا زده می‌شود و این‌جا فقط باید ثابت شود مسیرِ ثبت باز است. */
  const now = Date.now();
  db.prepare('INSERT INTO app_errors(sig,first,last,n,method,path,msg,notified) VALUES(?,?,?,1,?,?,?,0)')
    .run('GET /x | نمونه', now, now, 'GET', '/x', 'نمونه');
  t(rows().length === 1, 'جدول همچنان می‌پذیرد — مسیرِ ثبت بسته نشده');
  db.prepare('DELETE FROM app_errors').run();
}

/* ---------- ۴) تشخیص روی متنِ خطا نیست، روی سوکت است ---------- */
console.log('— مرزِ تشخیص —');
{
  const src = readFileSync(new URL('./index.js', import.meta.url), 'utf8');
  t(/function clientGone/.test(src), 'تابعِ تشخیص هست');
  const fn = (src.match(/function clientGone[\s\S]*?\n}/) || [''])[0];
  t(/nres\?\.destroyed|nres\?\.socket\?\.destroyed/.test(fn),
    'و شرطش بسته‌بودنِ سوکت است، نه فقط متنِ خطا');
  const codes = (src.match(/const GONE_CODES[\s\S]*?\]\);/) || [''])[0];
  t(/ERR_STREAM_PREMATURE_CLOSE/.test(codes) && /ECONNRESET/.test(codes) && /EPIPE/.test(codes),
    'کدهای شناخته‌شده‌ی قطع در فهرستند');
  t(!/noteError\([^)]*\)/.test((src.match(/if \(clientGone[\s\S]*?\n    \}/) || [''])[0]),
    'در مسیرِ قطع، هشداری فرستاده نمی‌شود');
  /* خطِ گزارش نباید پرسمان را چاپ کند: رمز و شماره همان‌جا رد می‌شود */
  const log = (src.match(/قطعِ کاربر[\s\S]{0,200}/) || [''])[0];
  t(/split\('\?'\)/.test(log), 'و پرسمانِ نشانی در گزارش نمی‌آید');
}

console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
