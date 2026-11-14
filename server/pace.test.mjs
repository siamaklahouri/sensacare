/* نوارِ «کجای ماهی» — داشبوردِ کارتابل‌ها.

   کارتابلِ ماهانه دو عدد را روی صفحه داشت و هیچ‌وقت کنارِ هم
   نگذاشته بود: چند درصدِ کار انجام شده، و چند درصدِ ماه گذشته.
   فاصلهٔ این دو همان حرفی است که یک پلنرِ ماهانه باید بزند.

   آزمون روی خودِ تابع است، نه مرورگر: ریاضیِ تقویم جایی برای
   اشتباهِ سنجه ندارد، و بندهای قضاوت («کمی عقب»، «عقب از برنامه»)
   مرزِ عددی‌اند — اگر یکی‌شان جابه‌جا شود، هشداری که هر روز روشن
   است یا هیچ‌وقت روشن نمی‌شود، و هیچ‌کدام به چشم نمی‌آید.

   اسفندِ کبیسه هم این‌جا سنجیده می‌شود: طولِ ماه را از همان‌جایی
   می‌گیرد که تقویم می‌گیرد، نه از حدس. */
import { readFileSync } from 'node:fs';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const rd = p => readFileSync(new URL(p, import.meta.url), 'utf8');
const paceSrc = rd('../public/_t/p/pace.tpl');
const cssSrc  = rd('../public/_t/p/pacecss.tpl');
const itSrc   = rd('../public/_t/it.tpl');
const finSrc  = rd('../public/_t/fin.tpl');
const dpSrc   = rd('../public/_t/p/datepick.tpl');

/* ۱) جزوِ قالب نباید تگ داشته باشد — داخلِ <script> و <style>ِ موجود
      تزریق می‌شود و یک تگِ اضافه کلِ اسکریپت را می‌کشد. */
t(!/<\/?(script|style)\b/i.test(paceSrc), 'جزوِ pace تگِ script/style ندارد');
t(!/<\/?(script|style)\b/i.test(cssSrc), 'جزوِ pacecss تگِ script/style ندارد');
t(!/<!--/.test(paceSrc) && !/<!--/.test(cssSrc), 'توضیحِ HTML میانِ جزوها نیست');

/* ۲) ساختنِ تابع در یک جعبهٔ بسته، با DatePickِ بدلی. */
function build(monthLen) {
  const win = monthLen ? { DatePick: { monthLen } } : {};
  const f = new Function('window', paceSrc + '\n;return { paceHtml: paceHtml, faN: faN };');
  return f(win);
}
const realLen = (jy, jm) => {
  if (jm <= 6) return 31;
  if (jm <= 11) return 30;
  /* کبیسهٔ تقویمِ خودِ datepick */
  return [1, 5, 9, 13, 17, 22, 26, 30].includes(jy % 33) ? 30 : 29;
};
const P = build(realLen);

const pct = html => {
  const w = html.match(/dh-rail-fill" style="width:(\d+)%/);
  const n = html.match(/dh-rail-now" style="inset-inline-start:(\d+)%/);
  return { work: w ? +w[1] : null, time: n ? +n[1] : null };
};
const cls = html => (html.match(/class="dh-pace ([a-z]+)"/) || [])[1];
const say = html => (html.match(/dh-pace-say">([^<]*)</) || [])[1];

/* ۳) بی‌کار، بی‌نوار. داشبوردِ خالی نباید «۰٪ عقب از برنامه» بگوید. */
t(P.paceHtml(0, 0, 1404, 8, 23) === '', 'کارِ صفر → نوار ساخته نمی‌شود');
t(P.paceHtml(5, null, 1404, 8, 23) === '', 'جمعِ نامعلوم → نوار ساخته نمی‌شود');

/* ۴) دو درصد درست حساب می‌شوند و روی ریل می‌نشینند. */
{
  const h = P.paceHtml(1, 16, 1404, 8, 23);         /* آبان = ۳۰ روز */
  const p = pct(h);
  t(p.work === 6, 'درصدِ کار: ۱ از ۱۶ → ۶٪', String(p.work));
  t(p.time === 77, 'درصدِ ماه: ۲۳ از ۳۰ → ۷۷٪', String(p.time));
  t(cls(h) === 'late' && say(h) === 'عقب از برنامه', 'فاصلهٔ ۷۱ → عقب از برنامه', cls(h) + '/' + say(h));
  t(/۱ از ۱۶ کار/.test(h), 'پانویس شمارشِ کار را می‌گوید');
  t(/۷ روز تا پایان ماه/.test(h), 'پانویس روزِ مانده را می‌گوید');
  t(/۷۷٪ از ماه/.test(h), 'پانویس درصدِ ماه را می‌گوید');
}

/* ۵) چهار بندِ قضاوت، روی مرزهایشان. روزِ پانزدهمِ ماهِ سی‌ویک‌روزه
      ۴۸٪ از ماه است؛ کارِ انجام‌شده را عوض می‌کنیم. */
const band = workPct => {
  const h = P.paceHtml(workPct, 100, 1404, 2, 15);   /* اردیبهشت = ۳۱ → ۴۸٪ */
  return { cls: cls(h), say: say(h) };
};
t(band(60).cls === 'ok' && band(60).say === 'جلوتر از تقویم', 'کارِ جلوتر از تقویم → سبز');
t(band(48).cls === 'ok' && band(48).say === 'جلوتر از تقویم', 'برابر با تقویم → سبز (فاصله صفر)');
t(band(40).cls === 'ok' && band(40).say === 'روی برنامه', 'فاصلهٔ ۸ → روی برنامه');
t(band(33).cls === 'ok' && band(33).say === 'روی برنامه', 'فاصلهٔ ۱۵ → هنوز روی برنامه (مرز)');
t(band(32).cls === 'warn' && band(32).say === 'کمی عقب', 'فاصلهٔ ۱۶ → کمی عقب');
t(band(13).cls === 'warn' && band(13).say === 'کمی عقب', 'فاصلهٔ ۳۵ → کمی عقب (مرز)');
t(band(12).cls === 'late' && band(12).say === 'عقب از برنامه', 'فاصلهٔ ۳۶ → عقب از برنامه');
t(band(100).cls === 'done' && band(100).say === 'ماه تمام شد', '۱۰۰٪ → تمام‌شده');
t(band(140).cls === 'done', 'بیش از ۱۰۰٪ هم تمام‌شده است');

/* ۶) طولِ ماه از datepick می‌آید، نه از حدس. اسفندِ ۱۴۰۳ کبیسه است
      (۱۴۰۳ % ۳۳ = ۲۲) و سی روز دارد، اسفندِ ۱۴۰۴ بیست‌ونه روز. */
t(realLen(1403, 12) === 30 && realLen(1404, 12) === 29, 'تقویمِ بدلی خودش درست است');
{
  const a = pct(P.paceHtml(1, 10, 1403, 12, 30)).time;   /* ۳۰ از ۳۰ */
  const b = pct(P.paceHtml(1, 10, 1404, 12, 29)).time;   /* ۲۹ از ۲۹ */
  t(a === 100 && b === 100, 'آخرین روزِ اسفند در هر دو سال ۱۰۰٪ است', a + '/' + b);
  t(/آخرین روزِ ماه/.test(P.paceHtml(1, 10, 1403, 12, 30)), 'روزِ آخر: «آخرین روزِ ماه»');
  t(pct(P.paceHtml(1, 10, 1403, 12, 29)).time === 97, 'بیست‌ونهمِ اسفندِ کبیسه ۹۷٪ است، نه ۱۰۰٪');
}
t(/monthLen/.test(paceSrc), 'نوار از DatePick.monthLen می‌خواند');
t(/monthLen/.test(dpSrc) && /window\.DatePick|DatePick *=/.test(dpSrc), 'datepick خودش monthLen را بیرون می‌دهد');

/* ۷) بی‌تقویم هم نباید بشکند — جزوِ datepick در هر صفحه‌ای نیست. */
{
  const Q = build(null);
  t(pct(Q.paceHtml(1, 10, 1404, 8, 15)).time === 50, 'بی DatePick: آبان ۳۰ روز فرض می‌شود');
  t(pct(Q.paceHtml(1, 10, 1404, 2, 15)).time === 48, 'بی DatePick: اردیبهشت ۳۱ روز');
  const R = build(() => { throw new Error('خراب'); });
  t(R.paceHtml(1, 10, 1404, 8, 15) !== '', 'تقویمِ خطادار نوار را نمی‌کشد');
}

/* ۸) روزِ بیرون از ماه مهار می‌شود — ساعتِ سیستمِ کاربر همیشه درست
      نیست و درصدی بیش از صد ریل را از قاب بیرون می‌برد. */
t(pct(P.paceHtml(1, 10, 1404, 8, 44)).time === 100, 'روزِ بزرگ‌تر از ماه → ۱۰۰٪');
t(pct(P.paceHtml(1, 10, 1404, 8, 0)).time === 3, 'روزِ صفر → روزِ یکم');

/* ۹) واژه‌های سفارشی: کارتابلِ مالی «کار» ندارد، «وصول» دارد. */
{
  const h = P.paceHtml(3, 10, 1404, 8, 23, { foot: 'سه از ده تومان', full: 'همه وصول شد' });
  t(/سه از ده تومان/.test(h) && !/کار</.test(h), 'پانویسِ سفارشی جای شمارشِ کار را می‌گیرد');
  t(/۷ روز تا پایان ماه/.test(h), 'روزِ مانده با پانویسِ سفارشی هم می‌آید');
  t(say(P.paceHtml(10, 10, 1404, 8, 23, { full: 'همه وصول شد' })) === 'همه وصول شد', 'واژهٔ تمام‌شدنِ سفارشی');
  t(say(P.paceHtml(10, 10, 1404, 8, 23)) === 'ماه تمام شد', 'بی سفارش، واژهٔ پیش‌فرض');
}

/* ۱۰) رقم‌ها فارسی‌اند — کلِ کارتابل فارسی است و یک «7» لاتین
       وسطِ قاب فوراً به چشم می‌آید. */
t(P.faN(2305) === '۲۳۰۵', 'رقمِ فارسی');
t(!/[0-9]/.test(P.paceHtml(1, 16, 1404, 8, 23).replace(/style="[^"]*"/g, '').replace(/class="[^"]*"/g, '')),
  'هیچ رقمِ لاتینی در متنِ نوار نیست');

/* ۱۱) هر دو کارتابل نوار را دارند — یکی عقب نماند. */
for (const [name, src] of [['IT', itSrc], ['مالی', finSrc]]) {
  t(/\{\{PART:pacecss\}\}/.test(src), name + ': جزوِ pacecss هست');
  t(/\{\{PART:pace\}\}/.test(src), name + ': جزوِ pace هست');
  const hero = src.match(/function renderDashHero\(\)\{[\s\S]*?\n\}/);
  t(!!hero && /paceHtml\(/.test(hero[0]), name + ': renderDashHero نوار را می‌سازد');
  t(!!hero && /\$\{pace\}/.test(hero[0]), name + ': نوار داخلِ قاب تزریق می‌شود');
}

/* ۱۲) نوار نباید از داده‌ی کارت‌ها جدا بیفتد: هر جا داده عوض می‌شود
       و کارت‌ها دوباره کشیده می‌شوند، قاب هم دوباره کشیده شود. */
t(/function renderCards\(\)\{[\s\S]*?renderDashHero\(\)/.test(finSrc.replace(/\r/g, '')),
  'مالی: renderCards قاب را هم تازه می‌کند');
t((itSrc.match(/renderDashHero\(\)/g) || []).length >= 3, 'IT: قاب در مسیرهای تازه‌سازی هم کشیده می‌شود',
  String((itSrc.match(/renderDashHero\(\)/g) || []).length));

/* ۱۳) CSS: علامتِ «امروز» و پرشدنِ ریل باید در هر دو جهت و در چاپ
       درست بمانند. */
t(/inset-inline-start/.test(paceSrc), 'جایِ علامت با منطقِ راست‌به‌چپ تنظیم می‌شود');
t(/\.dh-rail-fill/.test(cssSrc) && /\.dh-rail-now/.test(cssSrc), 'کلاس‌های ریل در CSS تعریف شده‌اند');
t(/print-color-adjust|color-adjust/.test(cssSrc), 'در چاپ رنگِ نوار حذف نمی‌شود');
t(/\.dh-pace\.late|\.late\b/.test(cssSrc), 'حالت‌های معنایی در CSS رنگ دارند');

console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
