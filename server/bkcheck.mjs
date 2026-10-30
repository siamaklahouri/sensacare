/* ==================== این فایلِ پشتیبان سالم است؟ ====================
   یک زیپِ پشتیبان را می‌گیرد و می‌گوید داخلش چه خبر است. نه رمزی
   می‌خواهد، نه مرورگری، نه سروری — فقط node و خودِ فایل.

   چرا جدا از آزمون‌ها: آزمون سرور و مرورگر و رمزِ نمونه لازم دارد و
   روی سرورِ واقعی اجرا نمی‌شود. این‌جا سؤال ساده‌تر است و جوابش از
   خودِ فایل درمی‌آید: «این زیپ که دستم است، باز می‌شود یا نه؟»

     node server/bkcheck.mjs <پشتیبان.zip>

   خروجی برای هر کارتابل: داده هست؟ چند ماه؟ CSS و جاوااسکریپت داخلِ
   خودِ صفحه‌اند؟ و اگر ارجاعی به بیرون مانده، فایلش داخلِ زیپ هست؟ */
import { inflateRawSync } from 'node:zlib';
import { readFileSync } from 'node:fs';
import { posix } from 'node:path';

const zipPath = process.argv[2];
if (!zipPath) { console.error('اجرا:  node server/bkcheck.mjs <پشتیبان.zip>'); process.exit(2); }

function unzip(buf) {
  const out = new Map();
  let e = buf.length - 22;
  while (e >= 0 && buf.readUInt32LE(e) !== 0x06054b50) e--;
  if (e < 0) throw new Error('زیپِ سالمی نیست — انتهایش پیدا نشد.');
  const n = buf.readUInt16LE(e + 10);
  let p = buf.readUInt32LE(e + 16);
  for (let i = 0; i < n; i++) {
    const method = buf.readUInt16LE(p + 10), csize = buf.readUInt32LE(p + 20);
    const nlen = buf.readUInt16LE(p + 28), elen = buf.readUInt16LE(p + 30);
    const clen = buf.readUInt16LE(p + 32), lho = buf.readUInt32LE(p + 42);
    const name = buf.toString('utf8', p + 46, p + 46 + nlen);
    const st = lho + 30 + buf.readUInt16LE(lho + 26) + buf.readUInt16LE(lho + 28);
    const raw = buf.subarray(st, st + csize);
    out.set(name, method === 8 ? inflateRawSync(raw) : Buffer.from(raw));
    p += 46 + nlen + elen + clen;
  }
  return out;
}

let files;
try { files = unzip(readFileSync(zipPath)); }
catch (e) { console.error('خوانده نشد: ' + e.message); process.exit(1); }

const kb = n => Math.round(n / 1024) + ' کیلوبایت';
let bad = 0, n = 0;

for (const name of [...files.keys()].filter(k => k.endsWith('.html')).sort()) {
  n++;
  const folder = name.split('/')[0];
  const txt = files.get(name).toString('utf8');
  console.log('\n📁 ' + folder);

  /* داده */
  const seed = txt.match(/window\.KARTABL_SEED = ([\s\S]*?);<\/script>/);
  let months = null, vault = null, stamp = null;
  if (seed) {
    try {
      const d = JSON.parse(seed[1].replace(/\\u003c/g, '<'));
      stamp = d.stamp;
      months = Object.keys((d.state || {}).monthsData || {}).length;
      vault = !!((d.state || {}).personalVault || {}).cipher;
    } catch (e) { /* ساختارش عوض شده */ }
  }
  console.log(seed ? `   ✅ داده دارد — ${kb(seed[1].length)}` + (stamp ? `، مهرِ ${stamp}` : '')
                   : '   ❌ دادهٔ داخلِ صفحه پیدا نشد');
  if (!seed) bad++;
  if (months !== null) console.log(`      ماه‌ها: ${months}${vault ? '، صندوقِ رمزدار دارد' : ''}`);

  /* خودکفا؟ */
  const css = [...txt.matchAll(/<style>([\s\S]*?)<\/style>/g)].reduce((a, m) => a + m[1].length, 0);
  const js = [...txt.matchAll(/<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/g)]
    .reduce((a, m) => a + m[1].length, 0);
  const fonts = (txt.match(/data:font\/woff2;base64,/g) || []).length;
  const imgs = (txt.match(/data:image\/[a-z+]+;base64,/g) || []).length;
  const selfContained = css > 50000 && js > 100000;
  console.log(selfContained
    ? `   ✅ خودکفاست — CSS ${kb(css)}، جاوااسکریپت ${kb(js)}`
    : `   ⚠️  خودکفا نیست — CSS ${kb(css)}، جاوااسکریپت ${kb(js)}`);
  if (!selfContained) bad++;
  const rich = fonts >= 4 && imgs >= 1;
  console.log(rich
    ? `   ✅ قلم و تصویر هم داخلش‌اند — ${fonts} وزنِ قلم، ${imgs} تصویر`
    : `   ⚠️  قلم یا تصویر داخلش نیست — ${fonts} وزنِ قلم، ${imgs} تصویر` +
      ' (صفحه باز می‌شود ولی با قلمِ پیش‌فرضِ سیستم)');
  if (!rich) bad++;

  /* ارجاع‌هایی که به بیرون مانده‌اند */
  const dir = posix.dirname(name);
  const abs = [], miss = [];
  const refs = new Set();
  for (const m of txt.matchAll(/<link\b[^>]*\bhref="([^"]+)"/g)) refs.add(m[1]);
  for (const m of txt.matchAll(/\bsrc="([^"]+)"/g)) refs.add(m[1]);
  for (const m of txt.matchAll(/url\((["']?)([^)"']+)\1\)/g)) refs.add(m[2]);
  for (let u of refs) {
    u = u.split('#')[0].split('?')[0];
    if (!u || /^(data:|https?:|mailto:|javascript:)/.test(u)) continue;
    if (/app\.webmanifest$/.test(u)) continue;        /* روی دیسک نقشی ندارد */
    if (u.startsWith('/')) { abs.push(u); continue; }
    if (!files.has(posix.normalize(posix.join(dir, u)))) miss.push(u);
  }
  if (abs.length) { console.log('   ⚠️  نشانیِ مطلق (روی دیسک پیدا نمی‌شود): ' + abs.join('، ')); }
  console.log(miss.length ? '   ⚠️  فایلِ کنارش داخلِ زیپ نیست: ' + miss.join('، ')
                          : '   ✅ هر فایلِ کناری که لازم دارد، داخلِ زیپ هست');
  if (miss.length) bad++;

  /* داده و اکسل */
  const json = [...files.keys()].find(k => k.startsWith(folder + '/') && k.endsWith('.json'));
  const xlsx = [...files.keys()].find(k => k.startsWith(folder + '/') && k.endsWith('.xlsx'));
  console.log(`   ${json ? '✅' : '❌'} فایلِ داده (JSON)${json ? ' — ' + kb(files.get(json).length) : ''}` +
              `     ${xlsx ? '✅' : '❌'} فایلِ اکسل${xlsx ? ' — ' + kb(files.get(xlsx).length) : ''}`);
  if (!json) bad++;
  if (!xlsx) bad++;
}

console.log('\n' + '─'.repeat(50));
if (!n) { console.log('هیچ کارتابلی داخلِ این زیپ نبود.'); process.exit(1); }
console.log(bad === 0
  ? `✅ ${n} کارتابل، همه سالم. فایلِ HTML هرکدام را از هر جا می‌شود باز کرد.`
  : `⚠️  ${n} کارتابل بررسی شد، ${bad} ایراد بالا نشان داده شد.`);
process.exit(bad ? 1 : 0);
