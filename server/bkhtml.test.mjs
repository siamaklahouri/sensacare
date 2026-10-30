/* فایلِ HTMLِ داخلِ پشتیبان، واقعاً از روی دیسک باز می‌شود؟

   این آزمون بعد از یک خرابیِ واقعی نوشته شد و لحنش را از همان دارد:
   کاربر پشتیبان را دانلود کرد و گفت «کارتابل‌ها کاملاً به هم ریخته».
   داده سالم بود — JSON و اکسل هر دو کامل. چیزی که شکسته بود فایلِ
   HTML بود: بی هیچ استایل و اسکریپتی باز می‌شد.

   علت: از ۳ آبان، CSS و جاوااسکریپت از خودِ صفحه بیرون کشیده شدند و
   به «/_a/k-it-….css» رفتند. الگویی که فایل‌های همراهِ پشتیبان را از
   صفحه پیدا می‌کرد این شکلِ دوبخشی را نمی‌شناخت، پس آن دو فایل نه
   داخلِ زیپ می‌آمدند و نه مسیرشان نسبی می‌شد. هیچ آزمونی هم نداشت،
   چون همه‌شان زیپ را می‌ساختند و فهرستش را می‌دیدند — نه اینکه
   فایل را باز کنند.

   پس این‌جا سه دسته سنجه است:

   یک) ساختاری: هر نشانی‌ای که صفحه به آن تکیه دارد، داخلِ زیپ فایل
   دارد. و هیچ نشانیِ مطلقی نمانده — نشانیِ مطلق روی دیسک یعنی ریشهٔ
   دیسک، نه ریشهٔ سایت.

   دو) یک لایه عمیق‌تر: خودِ فایل‌های بیرون‌کشیده هم ارجاع دارند
   (فونت، کتابخانهٔ نمودار). آن‌ها هم باید حل شوند. این لایه بود که
   بارِ دوم گولم زد.

   سه) و در نهایت، صفحه واقعاً با مرورگر از روی دیسک باز می‌شود و
   استایل و داده دارد. ساختارِ درست تضمین نمی‌کند که باز شود. */
/* ایمپورتِ پویا، عمدی: روی سرور playwright نصب نیست و یک ایمپورتِ
   ایستا پیش از اجرای هر خطی می‌افتد — آن‌وقت حتی سنجه‌های ساختاری
   که هیچ مرورگری نمی‌خواهند هم اجرا نمی‌شوند. یک بار همین شد و
   وارسی‌ای که روی سرور داده بودم اصلاً شروع نشد. */
let launch = null;
try { ({ launch } = await import('./pw.mjs')); } catch (e) { launch = null; }
import { inflateRawSync } from 'node:zlib';
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, rmSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import { join, dirname, posix } from 'node:path';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* ---------- ورود و گرفتنِ زیپ ---------- */
let ck = '';
const call = async (path, opt) => {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({}, o.headers, ck ? { cookie: ck } : {});
  const r = await fetch(BASE + path, o);
  for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
    const kv = c.split(';')[0];
    ck = (ck ? ck + '; ' : '') + kv;
  }
  return r;
};
await call('/api/admin.planer/signin', { method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ user: AUSER, password: APASS }) });
const res = await call('/api/admin.planer/backup/all');
const zipBytes = Buffer.from(await res.arrayBuffer());
t(res.status === 200 && zipBytes.length > 1000, 'پشتیبان ساخته شد',
  `${res.status} — ${zipBytes.length} بایت`);

/* ---------- خواندنِ زیپ، بی هیچ کتابخانه‌ای ----------
   از فهرستِ مرکزی خوانده می‌شود نه از هدرهای محلی: هدرِ محلی ممکن
   است اندازه را صفر بگذارد و به توصیفگرِ بعدش حواله بدهد. */
function unzip(buf) {
  const files = new Map();
  let eocd = buf.length - 22;
  while (eocd >= 0 && buf.readUInt32LE(eocd) !== 0x06054b50) eocd--;
  if (eocd < 0) return files;
  const n = buf.readUInt16LE(eocd + 10);
  let p = buf.readUInt32LE(eocd + 16);
  for (let i = 0; i < n; i++) {
    const method = buf.readUInt16LE(p + 10);
    const csize = buf.readUInt32LE(p + 20);
    const nlen = buf.readUInt16LE(p + 28);
    const elen = buf.readUInt16LE(p + 30);
    const clen = buf.readUInt16LE(p + 32);
    const lho = buf.readUInt32LE(p + 42);
    const name = buf.toString('utf8', p + 46, p + 46 + nlen);
    const lnlen = buf.readUInt16LE(lho + 26), lelen = buf.readUInt16LE(lho + 28);
    const start = lho + 30 + lnlen + lelen;
    const raw = buf.subarray(start, start + csize);
    files.set(name, method === 8 ? inflateRawSync(raw) : Buffer.from(raw));
    p += 46 + nlen + elen + clen;
  }
  return files;
}
const ALL = unzip(zipBytes);
const files = ALL;
t(ALL.size > 5, 'زیپ خوانده شد', files.size + ' فایل');

const htmlName = [...files.keys()].find(k => k.endsWith('.html') && k.startsWith('It/'));
t(!!htmlName, 'فایلِ HTMLِ کارتابل IT داخلش هست', htmlName);
t([...files.keys()].some(k => k.startsWith('It/') && k.endsWith('.json')), 'و دادهٔ JSON');
t([...files.keys()].some(k => k.startsWith('It/') && k.endsWith('.xlsx')), 'و فایلِ اکسل');

/* ---------- ۱ و ۲: هر ارجاع، فایلی دارد؟ ---------- */
/* چه چیزی «ارجاع» حساب می‌شود، و فرقِ ظریفی که یک بار گولم زد:

   پیوندِ <a href> ناوبری است نه منبع — «/sltech.apk» کنارِ صفحه لازم
   نیست و نبودنش چیزی را نمی‌شکند. و <link rel="manifest"> روی
   file:// اصلاً نقشی ندارد.

   مهم‌تر: نشانیِ داخلِ CSS نسبت به خودِ فایلِ CSS حل می‌شود، ولی
   نشانی‌ای که جاوااسکریپت در زمانِ اجرا می‌سازد نسبت به «سند». پس
   مبنای حلِ این دو یکی نیست و آزمون هم باید همان را مدل کند. */
function refs(text, kind) {
  const out = [];
  if (kind === 'js') {
    /* فقط رشته‌هایی که به پسوندِ یک فایلِ واقعی ختم می‌شوند. دنبالِ
       «url(» گشتن در جاوااسکریپت، رشته‌های به‌هم‌چسبیدهٔ کد را هم
       می‌گیرد؛ و «هر مسیرِ نسبی» در پشتیبانِ تکی چیزی پیدا نمی‌کرد،
       چون آن‌جا مسیرها «..» ندارند و کنارِ خودِ صفحه‌اند. */
    for (const m of text.matchAll(
      /["']((?:\.\.\/)*[A-Za-z0-9_.\/-]+\.(?:woff2|png|svg|ico|webp|js|css))["']/g))
      out.push(m[1]);
  } else {
    for (const m of text.matchAll(/<link\b[^>]*?\brel="([^"]*)"[^>]*?\bhref="([^"]+)"/g))
      if (!/manifest/.test(m[1])) out.push(m[2]);
    for (const m of text.matchAll(/<link\b[^>]*?\bhref="([^"]+)"[^>]*?\brel="([^"]*)"/g))
      if (!/manifest/.test(m[2])) out.push(m[1]);
    for (const m of text.matchAll(/\bsrc="([^"]+)"/g)) out.push(m[1]);
    for (const m of text.matchAll(/url\((["']?)([^)"']+)\1\)/g)) out.push(m[2]);
  }
  return out.filter(u => u && !/^(data:|https?:|mailto:|#|javascript:)/.test(u));
}
function check(fileName, label, baseDir, set) {
  const files = set || ALL;
  const body = files.get(fileName);
  if (!body) { t(false, `${label} داخلِ زیپ نیست`, fileName); return []; }
  const kind = fileName.endsWith('.js') ? 'js' : fileName.endsWith('.css') ? 'css' : 'html';
  const dir = baseDir === undefined ? posix.dirname(fileName) : baseDir;
  const abs = [], missing = [], found = [];
  for (const u of new Set(refs(body.toString('utf8'), kind))) {
    const clean = u.split('#')[0].split('?')[0];
    if (!clean) continue;
    if (clean.startsWith('/')) { abs.push(u); continue; }
    const target = posix.normalize(posix.join(dir, clean));
    (files.has(target) ? found : missing).push(u);
  }
  t(abs.length === 0, `${label}: هیچ نشانیِ مطلقی نمانده`, abs.join(', ') || 'پاک');
  t(missing.length === 0, `${label}: هر ارجاع فایلش داخلِ زیپ هست`,
    missing.join(', ') || `${found.length} ارجاع، همه حاضر`);
  return found.map(u => posix.normalize(posix.join(dir, u.split('#')[0].split('?')[0])));
}

console.log('— ارجاع‌های خودِ صفحه —');
const htmlDir = posix.dirname(htmlName);
const fromHtml = check(htmlName, 'HTML');

console.log('— صفحه خودکفاست —');
{
  const txt = files.get(htmlName).toString('utf8');
  const style = [...txt.matchAll(/<style>([\s\S]*?)<\/style>/g)].reduce((n, m) => n + m[1].length, 0);
  const script = [...txt.matchAll(/<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/g)]
    .reduce((n, m) => n + m[1].length, 0);
  t(style > 50000, 'CSS داخلِ خودِ صفحه است', `${Math.round(style / 1024)} کیلوبایت`);
  t(script > 100000, 'و جاوااسکریپت هم', `${Math.round(script / 1024)} کیلوبایت`);
  t(!/\/_a\//.test(txt), 'و هیچ ارجاعی به فایلِ بیرون‌کشیده نمانده');
  /* قلم و نمودار یک بار فایلِ کنار بودند و استدلالم این بود که
     «نبودنشان صفحه را ناخوانا نمی‌کند». در دقیقهٔ اول کسی پرسید
     «این چه قلمی است؟» — پس استدلال غلط بود. حالا همه‌چیز داخلِ
     صفحه است و این سنجه‌ها نگهش می‌دارند. */
  const fonts = (txt.match(/data:font\/woff2;base64,/g) || []).length;
  t(fonts >= 4, 'قلم‌ها داخلِ خودِ صفحه‌اند', fonts + ' وزن');
  t(/data:image\/(?:png|svg\+xml);base64,/.test(txt), 'و تصویرها هم');
  t(!/["'(]\/[A-Za-z0-9_./-]+\.(?:woff2|png|svg|ico|webp)["')]/.test(txt),
    'و هیچ نشانیِ فایلِ بیرونی نمانده');
}

/* ---------- پشتیبانِ تکیِ داخلِ خودِ کارتابل ----------
   مسیرِ جداگانه‌ای است: آن‌جا پوشهٔ مشترکی نیست و فایل‌ها کنارِ خودِ
   کارتابل می‌نشینند، پس پیشوندها فرق می‌کنند. همان اشتباه می‌توانست
   فقط این یکی را بشکند. */
console.log('— پشتیبانِ تکی —');
{
  let ck2 = '';
  const c2 = async (path, opt) => {
    const o = Object.assign({ headers: {} }, opt || {});
    o.headers = Object.assign({}, o.headers, ck2 ? { cookie: ck2 } : {});
    const r = await fetch(BASE + path, o);
    for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : []))
      ck2 = (ck2 ? ck2 + '; ' : '') + c.split(';')[0];
    return r;
  };
  const api = process.env.VS_IT_API || 'kartabl';
  const pass = process.env.VS_IT_PASS || 'siamaksiamak';
  await c2('/api/' + api + '/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ password: pass }) });
  const r2 = await c2('/api/' + api + '/backup/download');
  t(r2.status === 200, 'پشتیبانِ تکی ساخته شد', String(r2.status));
  if (r2.status === 200) {
    const one = unzip(Buffer.from(await r2.arrayBuffer()));
    const h = [...one.keys()].find(k => k.endsWith('.html'));
    t(!!h, 'و HTML دارد', h);
    if (h) {
      const dir1 = posix.dirname(h);
      const got = check(h, 'تکی/HTML', undefined, one);
      for (const f of got.filter(x => /\/_a\/.*\.(css|js)$/.test(x)))
        check(f, 'تکی/' + f.split('/').pop(), f.endsWith('.js') ? dir1 : undefined, one);
    }
  }
}

/* ---------- ۳: واقعاً باز می‌شود؟ ---------- */
console.log('— باز کردنش با مرورگر، از روی دیسک —');
const dir = mkdtempSync(join(tmpdir(), 'bkhtml-'));
for (const [name, body] of files) {
  const full = join(dir, name);
  mkdirSync(dirname(full), { recursive: true });
  writeFileSync(full, body);
}
let b = null;
try { if (launch) b = await launch(); } catch (e) { b = null; }
if (!b) console.log('   —  مرورگر در دسترس نیست، سنجه‌های دیداری رد شدند');
if (!b) {
  rmSync(dir, { recursive: true, force: true });
  console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
  process.exit(bad ? 1 : 0);
}
const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
const failed = [];
p.on('requestfailed', r => failed.push(r.url()));
p.on('response', r => { if (r.status() >= 400) failed.push(r.status() + ' ' + r.url()); });
const errs = [];
p.on('pageerror', e => errs.push(String(e).slice(0, 120)));
await p.goto('file://' + join(dir, htmlName).split('/').map(encodeURIComponent).join('/')
  .replace(/^file%3A/, ''), { waitUntil: 'load' }).catch(e => errs.push('goto: ' + e.message.slice(0, 80)));
await p.waitForTimeout(2600);
const seen = await p.evaluate(async () => {
  try { await document.fonts.ready; } catch (e) { }
  return {
    font: getComputedStyle(document.body).fontFamily,
    bg: getComputedStyle(document.body).backgroundColor,
    rows: document.querySelectorAll('tbody tr').length,
    offline: !!window.KARTABL_OFFLINE,
    vazir: (() => { try { return document.fonts.check('400 16px Vazirmatn'); } catch (e) { return false; } })(),
    chart: typeof Chart, xlsx: typeof XLSX,
    drawn: [...document.querySelectorAll('canvas')].filter(c => c.width > 0 && c.height > 0).length
  };
});
t(/Vazirmatn/.test(seen.font), 'صفحه استایل دارد — قلمش Vazirmatn است', seen.font.slice(0, 40));
t(seen.bg !== 'rgba(0, 0, 0, 0)' && seen.bg !== 'transparent',
  'و پس‌زمینه‌اش رنگ دارد، نه سفیدِ خام', seen.bg);
t(seen.vazir, 'و فایلِ قلم واقعاً بارگذاری شد');
t(seen.rows > 0, 'و دادهٔ کارتابل رسم شده — یعنی جاوااسکریپت هم اجرا شد',
  seen.rows + ' سطر');
t(seen.offline, 'و در حالتِ آفلاین است، پس سراغِ سرور نمی‌رود');
t(seen.chart === 'function' && seen.xlsx === 'object',
  'کتابخانهٔ نمودار و اکسل از قبل تعریف‌اند، پس سراغِ شبکه نمی‌روند',
  `Chart=${seen.chart}، XLSX=${seen.xlsx}`);
t(seen.drawn > 0, 'و نمودارها رسم شده‌اند', seen.drawn + ' نمودار');

/* preloadِ قلم با crossorigin روی file:// همیشه رد می‌شود و همان قلم
   از راهِ CSS می‌آید؛ بالا ثابت شد که بارگذاری می‌شود. بقیه مهم‌اند. */
const real = failed.filter(u => !/Vazirmatn-Regular\.2\.woff2$/.test(u));
t(real.length === 0, 'هیچ فایلِ دیگری نرسیده نماند', real.join(', ') || 'پاک');
t(errs.length === 0, 'و هیچ خطای صفحه‌ای نبود', errs.join(' | ') || 'پاک');


/* ---------- و تنها، بی هیچ فایلِ کناری ----------
   کسی که زیپ را باز می‌کند لازم نیست اول اکسترکتش کند: ویندوز
   اجازه می‌دهد فایلِ داخلِ زیپ دوبار کلیک شود و آن را تنها در یک
   پوشهٔ موقت باز می‌کند. صفحه باید همان‌جا هم خوانده شود. */
console.log('— تنها، بی فایلِ کناری —');
{
  const solo = mkdtempSync(join(tmpdir(), 'solo-'));
  const file = htmlName.split('/').pop();
  writeFileSync(join(solo, file), files.get(htmlName));
  const p3 = await b.newPage({ viewport: { width: 1200, height: 850 } });
  await p3.goto('file://' + join(solo, file).split('/').map(encodeURIComponent).join('/')
    .replace(/^file%3A/, ''), { waitUntil: 'load' }).catch(() => { });
  await p3.waitForTimeout(3200);
  const r3 = await p3.evaluate(() => ({
    font: getComputedStyle(document.body).fontFamily,
    bg: getComputedStyle(document.body).backgroundColor,
    rows: document.querySelectorAll('tbody tr').length,
    vazir: (() => { try { return document.fonts.check('400 16px Vazirmatn'); } catch (e) { return false; } })(),
    drawn: [...document.querySelectorAll('canvas')].filter(c => c.width > 0 && c.height > 0).length
  }));
  t(/Vazirmatn/.test(r3.font) && r3.bg !== 'rgba(0, 0, 0, 0)',
    'بی فایلِ کناری هم استایل دارد', r3.bg);
  t(r3.rows > 0, 'و داده‌اش رسم می‌شود', r3.rows + ' سطر');
  t(r3.vazir, 'و قلمش همان Vazirmatn است، نه قلمِ پیش‌فرضِ سیستم');
  t(r3.drawn > 0, 'و نمودارهایش هم رسم می‌شوند', r3.drawn + ' نمودار');
  await p3.close();
  rmSync(solo, { recursive: true, force: true });
}

/* ---------- ابزارِ درست کردنِ پشتیبان‌های آن بازه ----------
   bkfix دادهٔ فایلِ قدیمی را برمی‌دارد و داخلِ نمایشگرِ سالم می‌گذارد.
   چیزی که باید تضمین شود همین است: دادهٔ خروجی همان دادهٔ ورودی
   باشد — نه دادهٔ پشتیبانی که نمایشگرش از آن آمده. اگر این جابه‌جا
   شود، آدم فکر می‌کند پشتیبانِ مهرش را باز کرده و دادهٔ امروز را
   می‌بیند، که از خرابیِ اولیه بدتر است. */
console.log('— ابزارِ bkfix —');
{
  const zipPath = join(dir, 'snapshot.zip');
  writeFileSync(zipPath, zipBytes);
  const out = mkdtempSync(join(tmpdir(), 'bkfix-'));
  let ran = true, msg = '';
  try {
    execFileSync(process.execPath, [new URL('./bkfix.mjs', import.meta.url).pathname,
      zipPath, zipPath, out], { stdio: 'pipe' });
  } catch (e) { ran = false; msg = String(e.stderr || e.message).slice(0, 120); }
  t(ran, 'bkfix بی‌خطا اجرا شد', msg || 'ok');
  if (ran) {
    const seedOf = txt => (txt.match(/window\.KARTABL_SEED = ([\s\S]*?);<\/script>/) || [])[1];
    const before = seedOf(files.get(htmlName).toString('utf8'));
    const after = seedOf(readFileSync(join(out, htmlName), 'utf8'));
    t(!!after, 'خروجی بلوکِ داده دارد');
    t(before === after, 'و دادهٔ خروجی دقیقاً همان دادهٔ ورودی است — بایت به بایت',
      after && before ? `${before.length} بایت` : 'یکی‌شان نیست');
    const p2 = await b.newPage({ viewport: { width: 1100, height: 800 } });
    await p2.goto('file://' + join(out, htmlName).split('/').map(encodeURIComponent).join('/')
      .replace(/^file%3A/, ''), { waitUntil: 'load' }).catch(() => { });
    await p2.waitForTimeout(2400);
    const seen2 = await p2.evaluate(() => ({
      font: getComputedStyle(document.body).fontFamily,
      rows: document.querySelectorAll('tbody tr').length
    }));
    t(/Vazirmatn/.test(seen2.font) && seen2.rows > 0,
      'و فایلِ درست‌شده با استایل و داده باز می‌شود', `${seen2.rows} سطر`);
    await p2.close();
  }
  rmSync(out, { recursive: true, force: true });
}

await b.close();
rmSync(dir, { recursive: true, force: true });
console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
