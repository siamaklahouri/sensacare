/* تقویم‌های کوچکِ صفحه: انتخابِ روزِ مهلت و انتخابگرِ تاریخ.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];
const p = await b.newPage({ viewport: { width: 1340, height: 920 } });
p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
p.on('dialog', d => d.accept());
await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
await p.evaluate(async () => {
  await fetch('/api/kartabl/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password: 'siamaksiamak', remember: false }) });
});
await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
await p.waitForTimeout(2800);

/* ---------- انتخابِ روزِ مهلت ---------- */
console.log('===== روزِ مهلت =====');
const dp = await p.evaluate(() => {
  state.meta = { month: 'مهر', year: '1405' };
  state.currentMonthKey = '1405|مهر';
  state.monthsData['1405|مهر'] = {
    tasks: [{ category: 'شبکه', task: 'نمونه', owner: '', deadline: 12,
              status: 'انجام نشده', priority: 'بالا', note: '' }], days: [] };
  state.tasks = state.monthsData['1405|مهر'].tasks;
  state.days = [];
  document.querySelector('.navbtn[data-view="checklist"]').click();
  renderChecklist();
  document.querySelector('#checklistBody .date-box').click();
  const pop = document.querySelector('.day-picker-popup');
  const btns = [...pop.querySelectorAll('button[data-day]')];
  /* روزِ هفتهٔ هر خانه باید با تقویمِ واقعی بخواند: شمارهٔ خانه در
     شبکه (با احتسابِ خانه‌های خالیِ اول) همان روزِ هفته است. */
  const pads = pop.querySelectorAll('.dp2-pad').length;
  let wrong = 0;
  btns.forEach((x, i) => {
    const d = +x.getAttribute('data-day');
    const g = DatePick.toG(1405, 7, d);
    const real = (new Date(g.gy, g.gm - 1, g.gd).getDay() + 1) % 7;
    if ((pads + i) % 7 !== real) wrong++;
  });
  return { open: pop.classList.contains('open'),
           ttl: pop.querySelector('.dp2-ttl').textContent.trim(),
           wd: [...pop.querySelectorAll('.dp2-wd span')].map(x => x.textContent).join(''),
           pads, n: btns.length, wrong,
           off: btns.filter(x => x.classList.contains('off')).map(x => +x.getAttribute('data-day')),
           sel: btns.filter(x => x.classList.contains('selected')).map(x => +x.getAttribute('data-day')) };
});
t(dp.open && dp.n === 30, 'پنجرهٔ روزِ مهلت باز می‌شود و ماهِ سی‌روزه سی خانه دارد', 'n=' + dp.n);
t(dp.wd === 'شیدسچپج', 'ستون‌ها روزهای هفته‌اند — پیش از این فقط یک شبکهٔ ۱ تا ۳۱ بود', dp.wd);
t(dp.ttl === 'مهر ۱۴۰۵', 'و بالایش می‌گوید کدام ماه است', dp.ttl);
t(dp.wrong === 0,
  'و هر روز زیرِ ستونِ روزِ هفتهٔ خودش نشسته', 'ناجور=' + dp.wrong);
t(dp.off.indexOf(22) >= 0,
  '۲۲ مهر (شهادت حضرت فاطمه) در همین پنجره هم تعطیل است — همان جدولِ بخشِ تقویم',
  dp.off.join(','));
t(dp.off.filter(d => d % 7 === dp.off[0] % 7).length >= 4, 'جمعه‌ها هم رنگ دارند');
t(dp.sel.length === 1 && dp.sel[0] === 12, 'و روزِ انتخاب‌شده علامت دارد', String(dp.sel));

/* ماه که عوض شود، شبکه هم باید عوض شود */
const dp2 = await p.evaluate(() => {
  state.meta = { month: 'اسفند', year: '1405' };
  state.currentMonthKey = '1405|اسفند';
  state.monthsData['1405|اسفند'] = { tasks: state.tasks, days: [] };
  document.querySelector('#checklistBody .date-box').click();
  const pop = document.querySelector('.day-picker-popup');
  return { ttl: pop.querySelector('.dp2-ttl').textContent.trim(),
           n: pop.querySelectorAll('button[data-day]').length,
           off: [...pop.querySelectorAll('button.off')].map(x => +x.getAttribute('data-day')) };
});
t(dp2.ttl === 'اسفند ۱۴۰۵' && dp2.n === 29,
  'ماهِ باز که عوض شود، شبکه از نو چیده می‌شود — اسفندِ ۱۴۰۵ بیست‌ونه روز است',
  dp2.ttl + ' / ' + dp2.n);
t(dp2.off.indexOf(19) >= 0 && dp2.off.indexOf(20) >= 0 && dp2.off.indexOf(29) >= 0,
  'و عید فطر و ۲۹ اسفندش تعطیل‌اند', dp2.off.join(','));

/* ---------- انتخابگرِ تاریخ ---------- */
console.log('===== انتخابگرِ تاریخ =====');
const dk = await p.evaluate(() => {
  const inp = document.createElement('input');
  inp.setAttribute('data-date', '1');
  inp.value = '۱۴۰۵/۰۷/۰۵';
  inp.style.cssText = 'position:fixed;top:120px;right:420px;z-index:5;';
  document.body.appendChild(inp);
  DatePick.open(inp, inp);
  const pop = document.querySelector('.dp-pop');
  const ds = [...pop.querySelectorAll('.dp-d')];
  return { ttl: pop.querySelector('.dp-ttl').textContent.trim(), n: ds.length,
           off: ds.filter(x => x.classList.contains('off')).map(x => x.textContent),
           wd: !!pop.querySelector('.dp-wd') };
});
t(dk.wd && dk.n === 30, 'انتخابگرِ تاریخ از قبل روزهای هفته را داشت', 'n=' + dk.n);
t(dk.off.length >= 5,
  'و حالا تعطیلی‌ها هم در آن رنگ دارند — سه تقویمِ صفحه یک حرف می‌زنند',
  dk.off.join(','));

console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
await p.close();
await b.close();
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
