/* نشانه‌های برنامه.

   این آزمون بعد از یک خرابیِ واقعی نوشته شد: نشانهٔ maskable دو سرِ
   لوگو را بریده نشان می‌داد و هیچ آزمونی نمی‌گرفتش، چون فایلِ ۵۱۲ در
   ۵۱۲ کاملاً سالم بود. چیزی که سالم نبود نسبت‌ها بود — اندروید از یک
   نشانهٔ تطبیقی فقط مرکزش را نشان می‌دهد.

   پس این‌جا سه دسته چیز سنجیده می‌شود:

   یک) هر نشانی‌ای که جایی اعلام شده واقعاً فایل دارد. نامِ نشانه‌ها
   شماره دارد و با هر تغییر عوض می‌شود؛ یک جا جا بیفتد، یک ۴۰۴ِ
   بی‌صدا می‌ماند که فقط وقتی معلوم می‌شود کسی برنامه را نصب کند.

   دو) جنسِ فایل. گرد باید شفافیتِ کامل داشته باشد وگرنه لبهٔ دایره
   دندانه‌دار می‌شود، و maskable و آیفون باید اصلاً شفافیت نداشته
   باشند وگرنه سیستم‌عامل چیزِ خودش را زیرش می‌گذارد.

   سه) همان نسبتی که خراب بود. از روی خودِ اسکریپتِ ساخت و اندازهٔ
   واقعیِ لوگو حساب می‌شود، نه از روی عددی که این‌جا نوشته باشم. */
import http from 'node:http';
import { readFileSync } from 'node:fs';

const BASE = new URL(process.env.VS_BASE || 'http://127.0.0.1:8911');
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* خام، نه متن: این‌ها PNG اند و با رشته‌شدن خراب می‌شوند. */
function get(path, host) {
  return new Promise((res, rej) => {
    http.get({ host: BASE.hostname, port: BASE.port, path, headers: host ? { Host: host } : {} },
      r => {
        const parts = [];
        r.on('data', c => parts.push(c));
        r.on('end', () => res({ code: r.statusCode, type: r.headers['content-type'] || '', body: Buffer.concat(parts) }));
      }).on('error', rej);
  });
}

/* سرآیندِ PNG به‌اندازهٔ کافی ساده است که همین‌جا خوانده شود و این
   آزمون به هیچ کتابخانه‌ای بند نباشد. */
function png(buf) {
  if (buf.length < 33 || buf.readUInt32BE(0) !== 0x89504e47) return null;
  const o = { w: buf.readUInt32BE(16), h: buf.readUInt32BE(20), depth: buf[24], color: buf[25], trns: false };
  let p = 8;
  while (p + 8 <= buf.length) {
    const len = buf.readUInt32BE(p), tag = buf.toString('ascii', p + 4, p + 8);
    if (tag === 'tRNS') o.trns = true;
    if (tag === 'IEND') break;
    p += 12 + len;
  }
  /* ۶ = رنگی با کانالِ شفافیت، ۴ = خاکستریِ شفافیت‌دار، وگرنه شفافیت
     فقط از راهِ tRNS ممکن است. */
  o.alpha = o.color === 6 || o.color === 4 || o.trns;
  return o;
}

const ROUND  = ['/icon-sl.4.png', '/app-icon-192.2.png', '/favicon-sl.4.png'];
const OPAQUE = ['/app-icon-mask.2.png', '/app-icon-apple.2.png'];
const SIZES  = {
  '/icon-sl.4.png': 512, '/app-icon-192.2.png': 192, '/favicon-sl.4.png': 64,
  '/app-icon-mask.2.png': 512, '/app-icon-apple.2.png': 180
};

console.log('— فایل‌ها —');
const meta = {};
for (const u of [...ROUND, ...OPAQUE]) {
  const r = await get(u);
  const i = r.code === 200 ? png(r.body) : null;
  meta[u] = i;
  t(r.code === 200 && /image\/png/.test(r.type) && i && i.w === SIZES[u] && i.h === SIZES[u],
    u.slice(1), i ? `${r.code} ${i.w}×${i.h} ${r.body.length}ب` : String(r.code));
}

console.log('— جنسِ هرکدام —');
for (const u of ROUND) {
  t(meta[u] && meta[u].color === 6,
    `${u.slice(1)} شفافیتِ کامل دارد — لبهٔ دایره صاف می‌ماند`,
    meta[u] ? 'نوعِ رنگ ' + meta[u].color : 'نیست');
}
for (const u of OPAQUE) {
  t(meta[u] && !meta[u].alpha,
    `${u.slice(1)} هیچ شفافیتی ندارد — تا لبه رنگ دارد`,
    meta[u] ? (meta[u].alpha ? 'شفافیت دارد' : 'مات') : 'نیست');
}

console.log('— منطقهٔ امنِ نشانهٔ maskable —');
{
  const sh = readFileSync(new URL('../art/make-icons.sh', import.meta.url), 'utf8');
  const m = sh.match(/place\s+"\$tmp\/bg\.png"\s+([0-9.]+)\s+"\$tmp\/mask\.png"/);
  const glyph = png(readFileSync(new URL('../art/sl-glyph.png', import.meta.url)));
  t(!!m && !!glyph, 'اسکریپتِ ساخت و منبعِ لوگو هر دو هستند');
  if (m && glyph) {
    const frac = parseFloat(m[1]);
    const diag = frac * Math.hypot(1, glyph.h / glyph.w);   // قطر، به نسبتِ عرضِ بوم
    t(diag <= 0.61,
      'قطرِ لوگو از دایرهٔ امنِ اندروید (۶۱٪) بیرون نمی‌زند',
      `${(frac * 100).toFixed(0)}٪ عرض → ${(diag * 100).toFixed(1)}٪ قطر`);
    t(frac > 0.40, 'و آن‌قدر کوچک هم نیست که گم شود', `${(frac * 100).toFixed(0)}٪`);
  }
}

console.log('— هرجا اعلام شده —');
{
  const seen = new Set();
  const pages = [['/', 'sltech.ir'], ['/login', null], ['/siamak/', null], ['/maghale/', null], ['/admin', null]];
  for (const [p, host] of pages) {
    const r = await get(p, host);
    const html = r.body.toString('utf8');
    for (const m of html.matchAll(/\/[A-Za-z0-9._-]*(?:icon|favicon)[A-Za-z0-9._-]*\.png/g)) seen.add(m[0]);
  }
  /* نشانهٔ خودِ کارتابل‌ها (icon-siamak و امثالش) هم همین‌جا می‌افتد و
     باید باشد — فرقی نمی‌کند، همه‌شان باید ۲۰۰ بدهند. */
  t(seen.size >= 4, 'صفحه‌ها نشانه اعلام می‌کنند', [...seen].length + ' نشانی');
  for (const u of [...seen].sort()) {
    const r = await get(u);
    t(r.code === 200, `اعلام‌شده در صفحه‌ها: ${u.slice(1)}`, String(r.code));
  }
}

console.log('— مانیفست‌ها —');
for (const [p, host] of [['/app.webmanifest', 'sltech.ir'], ['/siamak/app.webmanifest', null]]) {
  const r = await get(p, host);
  let man = null;
  try { man = JSON.parse(r.body.toString('utf8')); } catch { }
  t(!!man && Array.isArray(man.icons) && man.icons.length >= 3, `${p} نشانه دارد`,
    man && man.icons ? man.icons.length + 'تا' : String(r.code));
  if (!man || !man.icons) continue;
  const mask = man.icons.filter(i => (i.purpose || '').split(/\s+/).includes('maskable'));
  t(mask.length === 1, `${p} دقیقاً یک maskable دارد`, String(mask.length));
  for (const i of man.icons) {
    const r2 = await get(i.src);
    const info = r2.code === 200 ? png(r2.body) : null;
    const want = parseInt(String(i.sizes).split('x')[0], 10);
    t(!!info && info.w === want && info.h === want,
      `${i.src.slice(1)} همان اندازه‌ای است که اعلام شده (${i.sizes})`,
      info ? `${info.w}×${info.h}` : String(r2.code));
  }
}

console.log('— سرویس‌ورکر —');
{
  const r = await get('/sw.js');
  const js = r.body.toString('utf8');
  const shell = (js.match(/var SHELL = \[([\s\S]*?)\]/) || ['', ''])[1];
  const urls = [...shell.matchAll(/"([^"]+)"/g)].map(m => m[1]);
  t(urls.length > 0, 'فهرستِ پیش‌دریافت خوانده شد', urls.length + ' فایل');
  for (const u of urls) {
    const r2 = await get(u);
    t(r2.code === 200, `پیش‌دریافت: ${u.slice(1)}`, String(r2.code));
  }
  const ver = (js.match(/var V = "([^"]+)"/) || ['', ''])[1];
  t(/^sltech-app-\d+$/.test(ver), 'نسخهٔ حافظه شماره دارد', ver);
}

console.log('— نشانه‌های برداشته‌شده —');
for (const u of ['/icon-sl.3.png', '/app-icon-mask.1.png', '/app-icon-192.1.png',
                 '/app-icon-apple.1.png', '/favicon-sl.3.png']) {
  const r = await get(u);
  t(r.code === 404, `${u.slice(1)} دیگر نیست و جایی هم صدایش نمی‌کند`, String(r.code));
}

console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
