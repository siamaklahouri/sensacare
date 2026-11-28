/* سیستم‌ها: افزودن، ویرایشِ درجا، جست‌وجو، نشانهٔ تکراری و ماندگاری.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch, calm } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await launch();
const p = await b.newPage({ viewport: { width: 1500, height: 950 } });
const errs = [];
p.on('pageerror', e => errs.push(e.message));

await p.goto(BASE + '/siamak/', { waitUntil: 'domcontentloaded' });
await p.evaluate(async () => {
  await fetch('/api/kartabl/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'content-type': 'application/json' }, body: JSON.stringify({ password: 'siamaksiamak' }) });
});
await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
await calm(p);

console.log('===== راه‌اندازی =====');
t(await p.evaluate(() => !!document.querySelector('.nav-list .navbtn[data-view="systems"]')),
  'دکمهٔ «سیستم‌ها» در فهرستِ بخش‌ها هست');
await p.evaluate(() => { state.systems = []; document.querySelector('.nav-list .navbtn[data-view="systems"]').click(); });
await p.waitForTimeout(400);
t(await p.evaluate(() => document.querySelector('#syBody .tbl-empty') !== null),
  'فهرستِ خالی، پیامِ خودش را دارد');

const fill = async (v) => {
  const ids = ['person', 'user', 'name', 'email', 'ip', 'cpu', 'ram'];
  for (let i = 0; i < ids.length; i++) await p.fill('#syNew_' + ids[i], v[i]);
  await p.click('#syAddBtn');
  await p.waitForTimeout(250);
};

console.log('===== افزودن =====');
await fill(['سیامک', 's.lahouri', 'PC-001', 's@company.ir', '192.168.1.10', 'Core i7-11700', '32']);
await fill(['مریم', 'm.rezaei', 'PC-002', 'm@company.ir', '192.168.1.24', 'Core i5-10400', '16']);
await fill(['حسن', 'h.karimi', 'PC-003', 'h@company.ir', '192.168.1.24', 'Core i3-9100', '8']);

const st = await p.evaluate(() => state.systems.map(r => r.person + '|' + r.name + '|' + r.cpu + '|' + r.ram).join(' , '));
t(await p.evaluate(() => state.systems.length) === 3, 'سه سیستم ثبت شد');
t(st.indexOf('Core i7-11700') >= 0, 'مدلِ پردازنده با رقمِ لاتین می‌ماند، نه فارسی', st.split(' , ')[0]);
t(await p.evaluate(() => document.querySelectorAll('#syBody tr').length) === 3, 'هر سه ردیف در جدول‌اند');
t(await p.evaluate(() => document.querySelectorAll('#syNew_person')[0].value) === '',
  'فرمِ افزودن بعد از ثبت خالی می‌شود');

console.log('===== آی‌پیِ تکراری =====');
const dup = await p.evaluate(() => ({
  cells: document.querySelectorAll('#syBody .sy-in.is-dup').length,
  card: [].slice.call(document.querySelectorAll('#syCards .stat'))
    .filter(s => s.querySelector('.stat-lbl').textContent.indexOf('تکراری') >= 0)
    .map(s => s.querySelector('.stat-val').textContent)[0]
}));
t(dup.cells === 2, 'دو خانهٔ آی‌پی قرمز شد', String(dup.cells));
t(dup.card === '۱', 'کارت هم یک آی‌پیِ تکراری می‌شمارد', dup.card);

console.log('===== کارت‌ها =====');
const cards = await p.evaluate(() => [].slice.call(document.querySelectorAll('#syCards .stat'))
  .map(s => s.querySelector('.stat-lbl').textContent + '=' + s.querySelector('.stat-val').textContent).join(' | '));
t(cards.indexOf('سیستم‌ها=۳') >= 0, 'شمارشِ سیستم‌ها درست است', cards);
t(cards.indexOf('افراد=۳') >= 0, 'شمارشِ افراد درست است');
t(cards.indexOf('مجموعِ رم=۵۶') >= 0, 'مجموعِ رم جمع زده می‌شود');

console.log('===== جست‌وجو =====');
await p.fill('#syFind', 'PC-002');
await p.waitForTimeout(300);
t(await p.evaluate(() => document.querySelectorAll('#syBody tr').length) === 1, 'جست‌وجو فهرست را کم می‌کند');
t((await p.evaluate(() => document.getElementById('syCount').textContent)).indexOf('۱ از ۳') >= 0,
  'شمارنده می‌گوید چند تا از چند تا', await p.evaluate(() => document.getElementById('syCount').textContent));
await p.fill('#syFind', '۱۹۲.۱۶۸.۱.۲۴');
await p.waitForTimeout(300);
t(await p.evaluate(() => document.querySelectorAll('#syBody tr').length) === 2,
  'رقمِ فارسی هم همان نتیجه را می‌دهد');
await p.fill('#syFind', '');
await p.waitForTimeout(250);

console.log('===== ویرایش و ماندگاری =====');
await p.fill('#syBody tr:nth-child(1) input[data-sy="ram"]', '64');
await p.keyboard.press('Tab');
await p.waitForTimeout(400);
t(await p.evaluate(() => state.systems[0].ram) === '64', 'ویرایشِ درجا در داده می‌نشیند');

await p.evaluate(() => { try { scheduleSave(); } catch (e) { } });
await p.waitForTimeout(1600);
await p.reload({ waitUntil: 'networkidle' });
await calm(p);
await p.evaluate(() => document.querySelector('.nav-list .navbtn[data-view="systems"]').click());
await p.waitForTimeout(500);
t(await p.evaluate(() => state.systems.length) === 3, 'بعد از تازه‌کردنِ صفحه هم سرِ جایش است');
t(await p.evaluate(() => state.systems[0].ram) === '64', 'و ویرایش هم ذخیره شده بود');

t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' | ') || '—');

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
