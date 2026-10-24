/* ==================== راهِ رسیدن به مرورگرِ آزمون ====================
   آزمون‌ها مسیرِ پلی‌رایت را دستی نوشته بودند — یک مسیرِ مطلق در
   کانتینرِ من. یعنی روی هیچ ماشینِ دیگری اجرا نمی‌شدند: نه روی
   گیت‌هاب، نه روی سرورِ خودمان، نه روی لپ‌تاپ. آزمونی که فقط یک جا
   اجرا شود، فقط همان‌جا جلوی خرابی را می‌گیرد.

   این یک لایهٔ نازک است: اگر پلی‌رایت مثل یک وابستگیِ معمولی نصب شده
   باشد همان را می‌گیرد، وگرنه سراغِ مسیری می‌رود که محیط گفته
   (PW_MODULE). مرورگر هم همین‌طور: اگر کرومیومی از قبل روی ماشین
   هست (PW_CHROMIUM یا /opt/pw-browsers/chromium) همان، وگرنه همان
   که خودِ پلی‌رایت نصب کرده. */
import { existsSync } from 'node:fs';

let mod = null;
try {
  mod = await import('playwright');
} catch (e) {
  const alt = process.env.PW_MODULE ||
    '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
  mod = await import(alt);
}

export const chromium = mod.chromium;

function exe() {
  const want = process.env.PW_CHROMIUM;
  if (want) return want;
  /* کرومیومِ آمادهٔ همین کانتینر. اگر نبود، چیزی نمی‌گوییم و
     می‌گذاریم پلی‌رایت خودش نسخهٔ خودش را پیدا کند. */
  return existsSync('/opt/pw-browsers/chromium') ? '/opt/pw-browsers/chromium' : undefined;
}

export function launch(opts) {
  const o = Object.assign({}, opts || {});
  const path = exe();
  if (path && !o.executablePath) o.executablePath = path;
  return chromium.launch(o);
}
