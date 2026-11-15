/* کاری که از مهلتش گذشته، باید دیده شود.

   یادآور فقط وقتی می‌آمد که یک یا دو روز به مهلت مانده باشد. از روزی
   که مهلت رد می‌شد هیچ‌چیز: نه رنگی در چک‌لیست، نه نشانه‌ای در
   «مهلت‌های نزدیک»، نه خبری در داشبورد. ردیفی که مهلتش پنجم بود و
   امروز بیست‌وچهارم است، عینِ ردیفی دیده می‌شد که مهلتش بیست‌وهشتم
   است — در یک پلنرِ ماهانه، بزرگ‌ترین حفره.

   دو مرزِ عمدی هم این‌جا سنجیده می‌شود، چون اگر نباشند نشانه بی‌ارزش
   می‌شود: کارِ «انجام شد» هرگز عقب‌افتاده نیست (گذشته را نمی‌شود
   درست کرد)، و در ماهِ بایگانی‌شده هیچ‌چیز عقب‌افتاده نیست (آن ماه
   تمام شده؛ وگرنه هر ماهِ قدیمی یک صفحهٔ قرمز می‌شد). */
import { launch } from './pw.mjs';
import { readFileSync } from 'node:fs';
import { ensureTasks, ensureCurrentMonth, todayJalali } from './seed.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const rd = p => readFileSync(new URL(p, import.meta.url), 'utf8');

console.log('===== سیم‌کشی =====');
{
  const eng = rd('../public/_t/p/overdue.tpl'), css = rd('../public/_t/p/overduecss.tpl');
  t(!/<\/?(script|style)\b/i.test(eng) && !/<!--/.test(eng), 'جزوِ موتور تگ و توضیحِ HTML ندارد');
  t(!/<\/?(script|style)\b/i.test(css), 'جزوِ شیوه‌نامه تگ ندارد');
  const tpls = rd('../src/templates.js');
  t(/\['overdue', *p_overdue\]/.test(tpls) && /\['overduecss', *p_overduecss\]/.test(tpls), 'هر دو جزو ثبت شده‌اند');
  for (const f of ['it.tpl', 'fin.tpl']) {
    const src = rd('../public/_t/' + f);
    t(/\{\{PART:overdue\}\}/.test(src) && /\{\{PART:overduecss\}\}/.test(src), f + ': جزوها را می‌آورد');
    t(/id="odBar"/.test(src), f + ': نوارِ داشبورد را دارد');
    t(/odDays\(t\) \? ' od' : ''/.test(src), f + ': چیپِ مهلت نشانه می‌گیرد');
    t(/renderOverdueBar\(\)/.test(src), f + ': نوار صدا زده می‌شود');
  }
  /* «انجام شد» نباید قرمز شود — مرز در خودِ موتور است، نه در قالب */
  t(/status === "انجام شد"/.test(eng), 'کارِ انجام‌شده از شمارش بیرون است');
  t(/currentMonthKey/.test(eng), 'و ماهِ بایگانی‌شده هم');
}

async function session(api, pass) {
  const r = await fetch(BASE + '/api/' + api + '/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ password: pass }) });
  return (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
}

const now = todayJalali();
/* روزِ یکِ ماه هیچ گذشته‌ای ندارد؛ آن روز این آزمون چیزی برای سنجیدن
   ندارد و باید بگوید، نه این‌که سبزِ بی‌معنی بدهد. */
const canTest = now.jd > 3;
console.log('— امروز ' + now.jd + ' ' + now.name + ' —');

const b = await launch();
for (const [label, w, api, pass, path] of [
  ['کارتابلِ فنی', 'it', 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak', '/siamak/'],
  ['کارتابلِ مالی', 'fin', 'sina', process.env.VS_FIN_PASS || 'sinasinasina', '/sina/']
]) {
  console.log('===== ' + label + ' =====');
  if (!canTest) { t(true, 'امروز روزِ سومِ ماه یا پیش از آن است — سنجشِ عقب‌افتادگی معنا ندارد'); continue; }

  await ensureCurrentMonth(BASE, HOST, api, pass);
  const future = String(Math.min(29, now.jd + 3));
  await ensureTasks(BASE, HOST, api, pass,
    ts => ts.some(x => x && x.task === 'کارِ گذشته ۱'), [
      { category: 'آزمون', task: 'کارِ گذشته ۱', owner: '-', deadline: '2', status: 'انجام نشده', priority: 'بالا' },
      { category: 'آزمون', task: 'کارِ گذشته ۲', owner: '-', deadline: '3', status: 'در حال انجام', priority: 'متوسط' },
      { category: 'آزمون', task: 'گذشته ولی انجام‌شده', owner: '-', deadline: '2', status: 'انجام شد', priority: 'پایین' },
      { category: 'آزمون', task: 'کارِ آینده', owner: '-', deadline: future, status: 'انجام نشده', priority: 'بالا' }
    ]);

  const ctx = await b.newContext({ viewport: { width: 1500, height: 1000 } });
  await ctx.addCookies(await session(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3800);

  /* ۱) ریاضیِ خودِ موتور */
  const m = await p.evaluate(() => {
    const by = n => (state.tasks || []).find(x => x && x.task === n);
    return { past: odDays(by('کارِ گذشته ۱')), done: odDays(by('گذشته ولی انجام‌شده')),
             soon: odDays(by('کارِ آینده')), count: odCount(), today: odTodayDay() };
  });
  t(m.today === now.jd, 'روزِ امروز را درست می‌خواند', m.today + '/' + now.jd);
  t(m.past === now.jd - 2, 'شمارِ روزهای گذشته درست است', m.past + '');
  t(m.done === 0, 'کارِ انجام‌شده عقب‌افتاده شمرده نمی‌شود');
  t(m.soon === 0, 'کارِ آینده هم نه');
  /* شمارِ کل به آن‌چه از قبل در کارتابل هست بستگی دارد (در مجموعهٔ
     کامل، چک‌لیستِ نمونه خودش ده‌ها کارِ گذشته دارد). پس عددِ ثابت
     نمی‌سنجیم؛ می‌سنجیم که شمارش با خودِ ردیف‌ها بخواند. */
  const real = await p.evaluate(() => (state.tasks || []).filter(x => odDays(x) > 0).length);
  t(m.count === real, 'شمارش با ردیف‌های واقعی می‌خواند', m.count + '/' + real);
  t(m.count >= 2, 'و دستِ‌کم دو کارِ آزمونِ ما را می‌شمارد', m.count + '');

  /* ۲) نوارِ داشبورد */
  const bar = await p.evaluate(() => {
    const e = document.getElementById('odBar');
    return e ? { hidden: e.hidden, text: (e.innerText || '').replace(/\n/g, ' '),
                 go: !!e.querySelector('.od-go') } : null;
  });
  t(bar && !bar.hidden, 'نوارِ داشبورد باز است');
  const faCount = String(m.count).replace(/[0-9]/g, d => '۰۱۲۳۴۵۶۷۸۹'[d]);
  t(bar && bar.text.indexOf(faCount + ' کار') >= 0, 'و همان شمار را با رقمِ فارسی می‌گوید',
    bar ? bar.text : '—');
  t(bar && bar.go, 'و دکمهٔ رفتن به چک‌لیست دارد');

  /* ۳) چیپِ مهلت در چک‌لیست */
  await p.evaluate(() => { const x = document.querySelector('.navbtn[data-view="checklist"]'); if (x) x.click(); });
  await p.waitForTimeout(900);
  const chips = await p.evaluate(() => {
    const all = [...document.querySelectorAll('#checklistBody tr')].map(r => ({
      task: (r.querySelector('input[data-field="task"]') || {}).value || '',
      od: !!r.querySelector('.date-box.od'),
      title: (r.querySelector('.date-box') || {}).title || ''
    }));
    const one = document.querySelector('#checklistBody .date-box.od');
    const cs = one ? getComputedStyle(one) : null;
    return { rows: all.filter(x => /کارِ گذشته|گذشته ولی|کارِ آینده/.test(x.task)),
             red: cs ? cs.borderTopColor : '', bg: cs ? cs.backgroundColor : '' };
  });
  const find = n => chips.rows.find(x => x.task === n) || {};
  t(find('کارِ گذشته ۱').od && find('کارِ گذشته ۲').od, 'چیپِ دو کارِ گذشته نشانه دارد');
  t(!find('گذشته ولی انجام‌شده').od, 'چیپِ کارِ انجام‌شده نشانه ندارد');
  t(!find('کارِ آینده').od, 'چیپِ کارِ آینده هم نه');
  t(/روز از مهلتش گذشته/.test(find('کارِ گذشته ۱').title), 'و با موشواره می‌گوید چند روز',
    find('کارِ گذشته ۱').title);
  t(chips.red !== chips.bg && chips.red !== 'rgba(0, 0, 0, 0)', 'و قابش رنگِ هشدار دارد', chips.red);

  /* ۴) ماهِ دیگر: هیچ‌چیز عقب‌افتاده نیست */
  const archived = await p.evaluate(() => {
    const keep = state.currentMonthKey;
    state.currentMonthKey = '1400|مهر';
    const n = odCount(), d = odTodayDay();
    state.currentMonthKey = keep;
    return { n, d };
  });
  t(archived.n === 0 && archived.d === 0, 'در ماهِ بایگانی‌شده چیزی عقب‌افتاده نیست',
    archived.n + '/' + archived.d);

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

/* ۵) جدولِ «مهلت‌های نزدیک» — فقط کارتابلِ فنی دارد */
if (canTest) {
  console.log('===== مهلت‌های نزدیک =====');
  const ctx = await b.newContext({ viewport: { width: 1500, height: 1000 } });
  await ctx.addCookies(await session('kartabl', process.env.VS_IT_PASS || 'siamaksiamak'));
  const p = await ctx.newPage();
  await p.goto('http://' + HOST + ':' + PORT + '/siamak/', { waitUntil: 'load' });
  await p.waitForTimeout(3600);
  const d = await p.evaluate(() => {
    const rows = [...document.querySelectorAll('#deadlinesBody tr')];
    return { first: rows.slice(0, 2).map(r => r.cells[0].textContent.trim()),
             cells: rows.filter(r => r.querySelector('.od-cell')).length,
             firstIsOverdue: !!(rows[0] && rows[0].querySelector('.od-cell')),
             note: (document.querySelector('#deadlinesBody .od-cell small') || {}).textContent || '' };
  });
  t(d.cells >= 2, 'خانهٔ مهلتِ عقب‌افتاده‌ها نشانه دارد', d.cells + ' تا');
  t(/روز از مهلتش گذشته/.test(d.note), 'و با حرف می‌گوید، نه فقط با رنگ', d.note);
  t(d.firstIsOverdue, 'و عقب‌افتاده‌ها اولِ جدول‌اند', (d.first[0] || '—'));
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
