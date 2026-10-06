/* ستونِ حجم در «سرورها و بکاپ» دو تا شد: vbk و vib.
   این آزمون هر سه جایی را می‌بیند که یک ستونِ تازه معمولاً از قلم
   می‌افتد: خودِ جدول، فرمِ ردیفِ تازه، و راهِ رفت‌وبرگشتِ اکسل. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const API  = process.env.VS_API  || 'kartabl';
const PASS = process.env.VS_PASS || 'siamaksiamak';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1600, height: 1000 } });
const errs = [];
p.on('pageerror', e => errs.push(String(e).slice(0, 200)));
p.on('dialog', d => d.accept());

await p.goto(BASE + '/siamak/');
await p.evaluate(async ({ a, w }) => {
  await fetch('/api/' + a + '/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ password: w }) });
}, { a: API, w: PASS });
await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
await p.waitForTimeout(3200);

await p.evaluate(() => {
  backupData = { vm: [
    { server: 'srv-a', location: '10.0.0.1', sizeUsed: 240, sizeVib: 35, schedule: 'روزانه یک بار', storage: 'Storage-01' },
    { server: 'srv-b', location: '10.0.0.2', sizeUsed: 1820, sizeVib: 410, schedule: 'روزانه دوبار', storage: 'Storage-02' }
  ] };
  document.querySelector('[data-view="servers"]').click();
  renderServers();
});
await p.waitForTimeout(800);

console.log('===== سرستون‌ها =====');
const TBL = '#serversBody';
const ths = await p.evaluate(s =>
  [...document.querySelector(s).closest('table').querySelectorAll('thead tr:first-child th')]
    .map(x => x.textContent.trim()), TBL);
t(ths.includes('حجم vbk (GB)') && ths.includes('حجم vib (GB)'), 'هر دو ستون در سرِ جدول هستند', ths.join(' | '));
t(ths.indexOf('حجم vib (GB)') === ths.indexOf('حجم vbk (GB)') + 1, 'و vib دقیقاً کنارِ vbk است');

console.log('\n===== ردیف‌ها =====');
const rows = await p.evaluate(() =>
  [...document.querySelectorAll('#serversBody tr')].filter(r => !r.classList.contains('add-row'))
    .map(r => [...r.children].map(c => c.textContent.trim())));
t(rows.length === 2, 'هر دو سرور آمدند', String(rows.length));
t(rows[0].includes('240') && rows[0].includes('35'), 'هر دو عدد در ردیفِ اول‌اند', rows[0].join(' | '));
const cols = await p.evaluate(() =>
  [...document.querySelectorAll('#serversBody tr:first-child td')].map(td => td.getAttribute('data-field') || '-'));
t(cols.indexOf('sizeVib') === cols.indexOf('sizeUsed') + 1,
  'و خانه‌هایشان هم کنارِ هم‌اند', cols.join(','));

/* شمارهٔ ستون‌ها باید با سرستون‌ها بخواند، وگرنه جدول یک خانه می‌لغزد */
const widths = await p.evaluate(s => {
  const tb = document.querySelector(s), tbl = tb.closest('table');
  return {
    head: tbl.querySelectorAll('thead tr:first-child th').length,
    filter: tbl.querySelectorAll('thead tr.filter-row th').length,
    row: tb.querySelector('tr').children.length,
    add: [...tb.querySelectorAll('tr.add-row td')]
           .reduce((n, td) => n + (parseInt(td.getAttribute('colspan'), 10) || 1), 0)
  };
}, TBL);
t(widths.head === widths.filter && widths.head === widths.row && widths.head === widths.add,
  'سرستون، فیلتر، ردیف و فرمِ افزودن همه هم‌عرض‌اند', JSON.stringify(widths));

console.log('\n===== کارتِ حجم کل =====');
const total = await p.evaluate(() =>
  [...document.querySelectorAll('#serverCards .stat')].map(c => c.querySelector('.lbl').textContent.trim() + '=' + c.querySelector('.val').textContent.trim()));
t(total.some(x => /حجم کل/.test(x) && /۲۵۰۵/.test(x)),
  'حجم کل هر دو را با هم می‌شمارد (۲۴۰+۳۵+۱۸۲۰+۴۱۰)', total.join(' | '));

console.log('\n===== نوشتن در خانه =====');
await p.evaluate(() => {
  const c = document.getElementById('editToggleServers');
  c.checked = true; c.dispatchEvent(new Event('change', { bubbles: true }));
});
await p.waitForTimeout(500);
await p.evaluate(() => {
  const td = [...document.querySelectorAll('#serversBody tr:first-child td')]
    .find(x => x.getAttribute('data-field') === 'sizeVib');
  td.focus(); td.textContent = '۷۷'; td.blur();
});
await p.waitForTimeout(700);
t(await p.evaluate(() => String(backupData.vm[0].sizeVib)) === '۷۷',
  'مقدارِ تایپ‌شده در دادهٔ سرور نشست',
  await p.evaluate(() => String(backupData.vm[0].sizeVib)));

console.log('\n===== رفت‌وبرگشتِ اکسل =====');
const trip = await p.evaluate(() => {
  const aoa = serversToAOA();
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet(aoa), 'Servers');
  const back = parseServersSheet(wb);
  return { header: aoa[0], first: back[0], n: back.length };
});
t(trip.header.includes('SizeVib'), 'ستونِ تازه در سرستونِ اکسل هست', trip.header.join(','));
t(trip.header.includes('SizeUsed'),
  'و نامِ ستونِ قبلی عوض نشده — فایل‌های قدیمی هنوز خوانده می‌شوند');
t(trip.n === 2 && String(trip.first.sizeVib) === '۷۷' && String(trip.first.sizeUsed) === '240',
  'و هر دو عدد از اکسل سالم برمی‌گردند', JSON.stringify(trip.first));

console.log('\n===== خطای صفحه =====');
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' // ') || '—');

await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
