/* ==================== آدرسِ هر چیز در آزمون‌ها ====================
   آزمون‌های قدیمی هرکدام یک پورت را دستی نوشته بودند: ۸۸۹۴ کارتابلِ
   فنی، ۸۸۹۳ مالی، ۸۸۹۲ پنل، ۸۸۹۵ سایت — از دورانی که هر کدام سرورِ
   جدا داشتند. آن سرورها دیگر نیستند، پس آن آزمون‌ها هم دیگر اجرا
   نمی‌شدند؛ در فهرستِ run-tests.sh نبودند و کسی هم خبر نداشت که
   یک‌سومِ آزمون‌ها خاموش‌اند.

   حالا همه‌چیز روی یک سرور است و این فایل تنها جایی است که آدرس‌ها
   نوشته می‌شوند. اگر فردا پورت یا نشانی عوض شد، همین‌جا عوض می‌شود. */

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const PORT = new URL(BASE).port || '80';

/* کارتابل‌های نمونهٔ هارنس. slug ها از vshare.setup.md می‌آیند. */
export const IT    = BASE + '/' + (process.env.VS_IT_SLUG  || 'siamak') + '/';
export const FIN   = BASE + '/' + (process.env.VS_FIN_SLUG || 'sina') + '/';
export const ADMIN = BASE + '/login';

/* نام و رمزِ کارتابل‌های نمونه — از vshare.setup.md */
export const IT_API   = process.env.VS_IT_API   || 'kartabl';
export const IT_PASS  = process.env.VS_IT_PASS  || 'siamaksiamak';
export const FIN_API  = process.env.VS_FIN_API  || 'sina';
export const FIN_PASS = process.env.VS_FIN_PASS || 'sinasinasina';

/* صفحهٔ خانهٔ sltech فقط روی دامنهٔ پنل سرو می‌شود — سرور از روی
   میزبان تصمیم می‌گیرد. با 127.0.0.1 صفحهٔ فروشگاه می‌آید، نه این.
   پس آزمون باید خودِ نام را صدا بزند؛ کرومیومِ آزمون با
   host-resolver-rules آن را به همین‌جا برمی‌گرداند (پایینِ pw.mjs). */
export const HOME  = `http://sltech.ir:${PORT}/`;
export const SHOP  = `http://sensacare.ir:${PORT}/`;

/* کارتابل را باز می‌کند و پردهٔ ورود را کنار می‌زند. صفحه کامل از
   سرور آمده و پرده فقط رویش افتاده، پس برداشتنش یعنی همان چیزی که
   کاربرِ واردشده می‌بیند — بی‌آنکه آزمون هر بار رمز بزند. */
export async function openKartabl(page, url, wait = 1600) {
  await page.goto(url, { waitUntil: 'networkidle' });
  await page.waitForTimeout(wait);
  await page.evaluate(() => {
    const g = document.getElementById('gateScreen');
    if (g) { g.hidden = true; g.innerHTML = ''; }
  });
  await page.waitForTimeout(400);
}

/* متنِ خامِ یک صفحهٔ دامنهٔ پنل، از راهِ خودِ نود.
   چرا نه با route.fetch خودِ پلی‌رایت: شبکهٔ داخلیِ پلی‌رایت نقشهٔ
   دامنه‌ای را که به کرومیوم داده‌ایم نمی‌شناسد، پس «sltech.ir» را
   واقعاً از اینترنت می‌خواهد و معطل می‌ماند. این‌جا میزبان را خودمان
   در سربرگ می‌گذاریم و مستقیم از سرورِ محلی می‌گیریم. */
export function panelHtml(path = '/') {
  const u = new URL(process.env.VS_BASE || 'http://127.0.0.1:8911');
  return new Promise((res, rej) => {
    import('node:http').then(({ default: http }) => {
      http.get({ host: u.hostname, port: u.port, path, headers: { Host: 'sltech.ir' } }, r => {
        let b = ''; r.on('data', c => { b += c; }); r.on('end', () => res(b));
      }).on('error', rej);
    });
  });
}

/* واردِ کارتابل می‌شود و صفحه را با نشستِ باز بالا می‌آورد.
   openKartabl فقط پردهٔ ورود را کنار می‌زند — برای آزمونی که چیزی
   روی سرور می‌نویسد کافی نیست و هر درخواستش ۴۰۱ می‌گیرد. */
export async function signIn(page, url, api, pass) {
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', {
      method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api, pass });
  await page.goto(url, { waitUntil: 'networkidle' });
  await page.waitForTimeout(2200);
}
