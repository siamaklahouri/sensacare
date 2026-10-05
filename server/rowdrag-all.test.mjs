/* جابه‌جایی ردیف‌ها، در جدول‌هایی که ساختارشان با بقیه فرق دارد:
   «چک‌لیست ریموت» (ردیف‌هایش شناسهٔ عددی نداشتند) و «شرکت‌ها» (هر
   شرکت جدولِ خودش را دارد، بی‌id، و وارونه نشان داده می‌شود).

   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const API  = process.env.VS_API  || 'kartabl';
const PASS = process.env.VS_PASS || 'siamaksiamak';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1500, height: 1100 } });
const errs = [];
p.on('pageerror', e => errs.push(String(e).slice(0, 200)));
p.on('dialog', d => d.accept());

/* یک کشیدنِ واقعی روی دستهٔ همان ردیف */
const drag = (sel, from, to, after) => p.evaluate(({ s, f, x, af }) => {
  const tb = document.querySelector(s);
  const rows = [...tb.querySelectorAll('tr')].filter(r => !r.classList.contains('add-row') && r.children.length > 1);
  const src = rows[f], dst = rows[x];
  const grip = src && src.querySelector('.rd-grip');
  if (!grip) return 'no-grip';
  const dt = new DataTransfer();
  grip.dispatchEvent(new DragEvent('dragstart', { bubbles: true, dataTransfer: dt }));
  const r = dst.getBoundingClientRect();
  const o = { bubbles: true, cancelable: true, dataTransfer: dt,
              clientX: r.left + 10, clientY: r.top + (af ? r.height * 0.8 : r.height * 0.2) };
  dst.dispatchEvent(new DragEvent('dragover', o));
  dst.dispatchEvent(new DragEvent('drop', o));
  src.dispatchEvent(new DragEvent('dragend', { bubbles: true, dataTransfer: dt }));
  return 'ok';
}, { s: sel, f: from, x: to, af: after });

await p.goto(BASE + '/siamak/');
await p.evaluate(async ({ a, w }) => {
  await fetch('/api/' + a + '/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ password: w }) });
}, { a: API, w: PASS });
await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
await p.waitForTimeout(3000);

/* دادهٔ نمونه، تا آزمون به محتوای دیتابیس بند نباشد */
await p.evaluate(() => {
  remoteBackupData = { roster: [{ server: 'srv-الف' }, { server: 'srv-ب' }, { server: 'srv-ج' }] };
  companiesData = { companies: { 'احیا': [
    { dateStr: '۱۴۰۴.۰۱.۰۱', time: '۱۰m', type: 'onsite' },
    { dateStr: '۱۴۰۴.۰۲.۰۲', time: '۲۰m', type: 'remote' },
    { dateStr: '۱۴۰۴.۰۳.۰۳', time: '۳۰m', type: 'onsite' }
  ] } };
  document.querySelector('[data-view="servers"]').click();
  renderRemoteChecklist();
  document.querySelector('[data-view="companies"]').click();
  renderCompanies();
});
await p.waitForTimeout(900);

console.log('===== چک‌لیست ریموت =====');
await p.evaluate(() => { document.querySelector('[data-view="servers"]').click(); });
await p.waitForTimeout(500);
let grips = await p.evaluate(() => document.querySelectorAll('#remoteBody .rd-grip').length);
t(grips === 0, 'با قفلِ بسته، دسته‌ای نیست', String(grips));

await p.evaluate(() => { const c = document.getElementById('editToggleRemote'); c.checked = true; c.dispatchEvent(new Event('change', { bubbles: true })); });
await p.waitForTimeout(700);
grips = await p.evaluate(() => document.querySelectorAll('#remoteBody .rd-grip').length);
t(grips === 3, 'با قفلِ باز، هر سه ردیف دسته گرفتند', String(grips));

let before = await p.evaluate(() => remoteBackupData.roster.map(x => x.server).join(','));
t(await drag('#remoteBody', 0, 2, true) === 'ok', 'ردیفِ اول تا ته کشیده شد');
await p.waitForTimeout(700);
let after = await p.evaluate(() => remoteBackupData.roster.map(x => x.server).join(','));
t(after === 'srv-ب,srv-ج,srv-الف', 'ترتیبِ دادهٔ ریموت عوض شد', before + '  →  ' + after);
let shown = await p.evaluate(() =>
  [...document.querySelectorAll('#remoteBody tr .server-name')].map(x => x.textContent.trim()).join(','));
t(shown === after, 'و همان ترتیب روی صفحه هم کشیده شد', shown);

console.log('\n===== شرکت‌ها (وارونه، بی‌id) =====');
await p.evaluate(() => { document.querySelector('[data-view="companies"]').click(); });
await p.waitForTimeout(600);
const sel = 'tbody[data-rd="companyVisits"]';
grips = await p.evaluate(s => document.querySelectorAll(s + ' .rd-grip').length, sel);
t(grips === 0, 'با قفلِ بسته، دسته‌ای نیست', String(grips));

await p.evaluate(() => {
  const c = document.querySelector('.edit-toggle-company');
  c.checked = true; c.dispatchEvent(new Event('change', { bubbles: true }));
});
await p.waitForTimeout(800);
grips = await p.evaluate(s => document.querySelectorAll(s + ' .rd-grip').length, sel);
t(grips === 3, 'با قفلِ باز، هر سه بازدید دسته گرفتند', String(grips));

/* نمایش وارونه است: ردیفِ اولِ صفحه، آخرین عضوِ آرایه */
let dates = await p.evaluate(s =>
  [...document.querySelectorAll(s + ' tr')].map(r => r.children[0].textContent.trim()).join(','), sel);
t(dates === '۱۴۰۴.۰۳.۰۳,۱۴۰۴.۰۲.۰۲,۱۴۰۴.۰۱.۰۱', 'تازه‌ترین بازدید بالاست', dates);

t(await drag(sel, 0, 1, true) === 'ok', 'بازدیدِ بالا یک پله پایین کشیده شد');
await p.waitForTimeout(800);
dates = await p.evaluate(s =>
  [...document.querySelectorAll(s + ' tr')].map(r => r.children[0].textContent.trim()).join(','), sel);
t(dates === '۱۴۰۴.۰۲.۰۲,۱۴۰۴.۰۳.۰۳,۱۴۰۴.۰۱.۰۱',
  'روی صفحه دقیقاً همان‌جایی نشست که رها شد — نه یک خانه آن‌طرف‌تر', dates);
const arr = await p.evaluate(() => companiesData.companies['احیا'].map(x => x.dateStr).join(','));
t(arr === '۱۴۰۴.۰۱.۰۱,۱۴۰۴.۰۳.۰۳,۱۴۰۴.۰۲.۰۲', 'و آرایه هم وارونهٔ همان است', arr);

console.log('\n===== جدول‌هایی که از قبل کار می‌کردند =====');
await p.evaluate(() => {
  backupData = { vm: [{ server: 'a' }, { server: 'b' }, { server: 'c' }] };
  document.querySelector('[data-view="servers"]').click();
  renderServers();
  const c = document.getElementById('editToggleServers');
  c.checked = true; c.dispatchEvent(new Event('change', { bubbles: true }));
});
await p.waitForTimeout(800);
t(await drag('#serversBody', 2, 0, false) === 'ok', 'سرورها هنوز کشیده می‌شوند');
await p.waitForTimeout(600);
const vm = await p.evaluate(() => backupData.vm.map(x => x.server).join(','));
t(vm === 'c,a,b', 'و درست جابه‌جا شدند', vm);

console.log('\n===== خطای صفحه =====');
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' // ') || '—');

await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
