/* دو تب، دو ماهِ جدا: هیچ‌کدام نباید کارِ دیگری را دور بیندازد.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';
import { IT, IT_API, IT_PASS, signIn } from './where.mjs';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await launch();

/* دو تبِ باز در یک مرورگر — نه دو دستگاه.
   هر کارتابل پیش‌فرض «تک‌نشست» است (solo): ورود روی گوشی، نشستِ
   لپ‌تاپ را می‌بندد. پس دو دستگاهِ هم‌زمان با ورودِ عادی ممکن نیست و
   تداخلِ واقعی از جای دیگری می‌آید: دو تب یا دو پنجره روی همان
   مرورگر، که یک نشست را شریک‌اند و هر دو می‌توانند بنویسند.
   (و کارتابل‌هایی که ادمین solo را برایشان خاموش کرده.) */
const ctx = await b.newContext({ viewport: { width: 1280, height: 900 } });
let signedOnce = false;
const open = async () => {
  const p = await ctx.newPage();
  p.on('dialog', d => d.accept());
  if (!signedOnce) { await signIn(p, IT, IT_API, IT_PASS); signedOnce = true; }
  else { await p.goto(IT, { waitUntil: 'networkidle' }); await p.waitForTimeout(2200); }
  return p;
};

/* ماهِ دلخواه را در state می‌نشاند و می‌فرستد — بی‌آنکه با رابط کاربری
   ور برویم: چیزی که سنجیده می‌شود همگام‌سازی است، نه دکمه‌ها. */
const setMonth = (p, key, mark) => p.evaluate(([k, m]) => {
  state.monthsData = state.monthsData || {};
  state.monthsData[k] = { tasks: [{ category: 'آزمون', task: m, owner: '', deadline: 1,
                                    status: 'انجام نشده', priority: 'متوسط', note: '' }],
                          days: [] };
  return true;
}, [key, mark]);

const pushNow = p => p.evaluate(() => Cloud.pushNow(false));
const monthsOf = p => p.evaluate(() => {
  const md = (state && state.monthsData) || {};
  const out = {};
  for (const k of Object.keys(md))
    out[k] = ((md[k].tasks || [])[0] || {}).task || '';
  return out;
});

console.log('— دو تب، دو ماهِ جدا —');
{
  const A = await open();
  const B = await open();
  await A.waitForTimeout(800); await B.waitForTimeout(800);

  /* هر دو از یک نسخه شروع کرده‌اند و هر دو یک بار ذخیره می‌کنند تا
     «امضای پایه» داشته باشند. */
  await setMonth(A, '1405|فروردین', 'پایه');
  await pushNow(A); await A.waitForTimeout(900);
  await B.evaluate(() => Cloud.pull()); await B.waitForTimeout(900);
  await pushNow(B); await B.waitForTimeout(900);

  /* حالا هرکدام یک ماهِ متفاوت را عوض می‌کند */
  await setMonth(A, '1405|اردیبهشت', 'کارِ تبِ الف');
  await pushNow(A); await A.waitForTimeout(1200);

  await setMonth(B, '1405|خرداد', 'کارِ تبِ ب');
  await pushNow(B); await B.waitForTimeout(2500);

  const bar = await B.$('#syncConflict');
  t(!bar, 'نوارِ «کدام نسخه بماند؟» بالا نیامد — برخوردی نبود');

  const m = await monthsOf(B);
  t(m['1405|اردیبهشت'] === 'کارِ تبِ الف', 'کارِ تبِ الف سرِ جایش است', m['1405|اردیبهشت'] || '—');
  t(m['1405|خرداد'] === 'کارِ تبِ ب', 'کارِ تبِ ب هم همین‌طور', m['1405|خرداد'] || '—');

  /* و روی سرور هم هر دو نشسته باشند، نه فقط در حافظهٔ همین صفحه */
  const srv = await B.evaluate(async () => {
    const r = await apiCall('/state');
    const md = (r.data && r.data.state && r.data.state.monthsData) || {};
    const out = {};
    for (const k of Object.keys(md)) out[k] = ((md[k].tasks || [])[0] || {}).task || '';
    return out;
  });
  t(srv['1405|اردیبهشت'] === 'کارِ تبِ الف' && srv['1405|خرداد'] === 'کارِ تبِ ب',
    'و روی سرور هر دو با هم ذخیره شده‌اند', JSON.stringify(srv));

  await A.close(); await B.close();
}

console.log('— دو تب، یک ماه: این‌جا باید بپرسد —');
{
  const A = await open();
  const B = await open();
  await A.waitForTimeout(800); await B.waitForTimeout(800);

  await setMonth(A, '1405|تیر', 'پایهٔ دوم');
  await pushNow(A); await A.waitForTimeout(900);
  await B.evaluate(() => Cloud.pull()); await B.waitForTimeout(900);
  await pushNow(B); await B.waitForTimeout(900);

  await setMonth(A, '1405|تیر', 'نسخهٔ الف');
  await pushNow(A); await A.waitForTimeout(1200);

  await setMonth(B, '1405|تیر', 'نسخهٔ ب');
  await pushNow(B); await B.waitForTimeout(2500);

  const bar = await B.$('#syncConflict');
  t(!!bar, 'نوارِ انتخاب بالا آمد — چون واقعاً یک ماه را هر دو دست زده‌اند');
  if (bar) {
    const txt = await B.evaluate(() => document.getElementById('syncConflict').textContent);
    t(/تیر/.test(txt), 'و اسمِ همان ماه را می‌گوید، نه یک هشدارِ کلی', txt.slice(0, 80));
  }
  await A.close(); await B.close();
}

console.log('— آفلاین —');
{
  const c = await b.newContext({ viewport: { width: 1280, height: 900 } });
  const p = await c.newPage();
  p.on('dialog', d => d.accept());
  await signIn(p, IT, IT_API, IT_PASS);
  await p.waitForTimeout(1200);
  const on = await p.evaluate(() => Object.keys((state || {}).monthsData || {}).length);
  await c.setOffline(true);
  await p.reload({ waitUntil: 'domcontentloaded' }).catch(() => {});
  await p.waitForTimeout(4000);
  const off = await p.evaluate(() => ({
    months: Object.keys((state || {}).monthsData || {}).length,
    rows: document.querySelectorAll('table tbody tr').length,
    status: (document.getElementById('cloudStatus') || {}).textContent || ''
  }));
  t(off.months === on && on > 0, 'بی‌اینترنت، دادهٔ کارتابل سرِ جایش است', off.months + ' از ' + on + ' ماه');
  t(off.rows > 0, 'و جدول‌ها رسم شده‌اند', off.rows + ' ردیف');
  t(/آفلاین/.test(off.status),
    'و وضعیت می‌گوید آفلاین است — نه «در حال بررسی…» که کاربر خیال کند ذخیره می‌شود',
    off.status.slice(0, 60));
  await c.close();
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
