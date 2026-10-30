/* ==================== درست کردنِ پشتیبان‌های ۳ آبان تا ۸ آبان ====================
   در آن بازه، فایلِ HTMLِ داخلِ پشتیبان بی استایل و بی اسکریپت باز
   می‌شد. دلیلش در کامیتِ اصلاح نوشته شده؛ این‌جا فقط نتیجه‌اش مهم است:
   آن فایل‌ها قابلِ دیدن نیستند.

   ولی هیچ داده‌ای گم نشده. دادهٔ کاملِ هر کارتابل — ماه‌ها، چک‌لیست،
   سرورها، شرکت‌ها، و صندوقِ رمزدار — داخلِ خودِ همان HTML در بلوکی به
   نامِ KARTABL_SEED نشسته است. چیزی که نبود، CSS و جاوااسکریپتی بود
   که نشانش بدهد.

   پس این ابزار چیزی را بازسازی یا حدس نمی‌زند: همان دادهٔ دست‌نخورده
   را از فایلِ قدیمی برمی‌دارد و داخلِ نمایشگرِ سالمِ امروز می‌گذارد.

   چرا نمایشگرِ تازه و نه وصله کردنِ همان فایل: نامِ فایل‌های CSS و JS
   از روی محتوایشان ساخته می‌شود و با هر استقرار عوض می‌شود. فایلِ
   قدیمی نامِ آن روز را صدا می‌زند، که دیگر وجود ندارد.

   اجرا:
     # یک پشتیبانِ تازه از پنل بگیرید (یا از همان دکمهٔ «پشتیبان همه»)
     node server/bkfix.mjs <پشتیبانِ-قدیمی.zip> <پشتیبانِ-تازه.zip> <پوشهٔ-خروجی>

   خروجی یک پوشه است، نه زیپ: فایلِ HTML را همان‌جا دوبار کلیک کنید.
   هیچ‌چیز روی سرور و هیچ‌کدام از فایل‌های ورودی دست نمی‌خورد. */
import { inflateRawSync } from 'node:zlib';
import { readFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join, posix } from 'node:path';

const [oldZip, newZip, outDir] = process.argv.slice(2);
if (!oldZip || !newZip || !outDir) {
  console.error('اجرا:  node server/bkfix.mjs <قدیمی.zip> <تازه.zip> <پوشهٔ خروجی>');
  process.exit(2);
}

/* فهرستِ مرکزی خوانده می‌شود نه هدرهای محلی: هدرِ محلی ممکن است
   اندازه را صفر بگذارد و به توصیفگرِ بعدش حواله بدهد. */
function unzip(buf) {
  const out = new Map();
  let e = buf.length - 22;
  while (e >= 0 && buf.readUInt32LE(e) !== 0x06054b50) e--;
  if (e < 0) throw new Error('زیپِ سالمی نیست');
  const n = buf.readUInt16LE(e + 10);
  let p = buf.readUInt32LE(e + 16);
  for (let i = 0; i < n; i++) {
    const method = buf.readUInt16LE(p + 10), csize = buf.readUInt32LE(p + 20);
    const nlen = buf.readUInt16LE(p + 28), elen = buf.readUInt16LE(p + 30);
    const clen = buf.readUInt16LE(p + 32), lho = buf.readUInt32LE(p + 42);
    const name = buf.toString('utf8', p + 46, p + 46 + nlen);
    const start = lho + 30 + buf.readUInt16LE(lho + 26) + buf.readUInt16LE(lho + 28);
    const raw = buf.subarray(start, start + csize);
    out.set(name, method === 8 ? inflateRawSync(raw) : Buffer.from(raw));
    p += 46 + nlen + elen + clen;
  }
  return out;
}

const OLD = unzip(readFileSync(oldZip));
const NEW = unzip(readFileSync(newZip));

/* بلوکِ داده، از «window.KARTABL_SEED = » تا پایانِ همان اسکریپت.
   با regex و نه با JSON.parse دنبالِ مرزها گشتن: متن با < فرار
   داده شده و دقیقاً همان‌طور که هست جابه‌جا می‌شود. */
const SEED = /(window\.KARTABL_SEED = )([\s\S]*?)(;<\/script>)/;

const write = (rel, data) => {
  const full = join(outDir, rel);
  mkdirSync(dirname(full), { recursive: true });
  writeFileSync(full, data);
};

/* نمایشگرِ سالم، به تفکیکِ پوشهٔ همان کارتابل.
   چرا پوشه و نه «نوعِ کارتابل»: نمایشگرِ امروز خودکفاست و دیگر هیچ
   «/_a/k-it-…» ندارد که بشود نوعش را از آن خواند. و اگر نوع را
   اشتباه بگیریم، دادهٔ یک کارتابلِ فنی داخلِ نمایشگرِ مالی می‌نشیند
   و صفحه‌ای می‌دهد که بخش‌هایش با داده نمی‌خواند — بدتر از نساختن.
   پس اگر پوشه‌اش در پشتیبانِ تازه نبود، دست نمی‌خورد و گزارش می‌شود. */
const fresh = new Map();
for (const [name, body] of NEW) {
  if (!name.endsWith('.html')) continue;
  fresh.set(name.split('/')[0], body.toString('utf8'));
}
if (!fresh.size) { console.error('در پشتیبانِ تازه هیچ نمایشگری پیدا نشد.'); process.exit(1); }

let fixed = 0, copied = 0, skipped = [];
for (const [name, body] of OLD) {
  if (name.startsWith('_files/')) continue;           /* از تازه برداشته می‌شود */
  if (!name.endsWith('.html')) { write(name, body); copied++; continue; }

  const txt = body.toString('utf8');
  const seed = txt.match(SEED);
  if (!seed) { skipped.push(name + ' (دادهٔ داخلش پیدا نشد)'); write(name, body); continue; }
  const viewer = fresh.get(name.split('/')[0]);
  if (!viewer) {
    skipped.push(name + ' (این کارتابل در پشتیبانِ تازه نیست — دست نخورد)');
    write(name, body); continue;
  }
  if (!SEED.test(viewer)) { skipped.push(name + ' (نمایشگرِ تازه جای داده ندارد)'); write(name, body); continue; }

  write(name, Buffer.from(viewer.replace(SEED, (m, a, _old, c) => a + seed[2] + c), 'utf8'));
  fixed++;
}

/* فایل‌های مشترکِ نمایشگر از پشتیبانِ تازه می‌آیند */
for (const [name, body] of NEW) if (name.startsWith('_files/')) { write(name, body); copied++; }

console.log(`نمایشگرِ درست‌شده: ${fixed}`);
console.log(`فایل‌های دیگر (داده، اکسل، قلم، کتابخانه): ${copied}`);
if (skipped.length) { console.log('دست‌نخورده:'); skipped.forEach(s => console.log('   ' + s)); }
console.log(`\nخروجی: ${outDir}`);
console.log('فایلِ HTML هر پوشه را دوبار کلیک کنید.');
