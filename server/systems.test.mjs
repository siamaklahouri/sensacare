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

console.log('===== خواندن از اکسل =====');
t(await p.evaluate(() => !!document.getElementById('syXlsxBtn') && !!document.getElementById('sySampleBtn')),
  'دکمه‌های اکسل سرِ جایشان‌اند');

await p.evaluate(() => { state.systems = []; SYSTEMS.render(); });
await p.evaluate(async () => { await ensureXlsxLib(); });

const book = (aoa, sheet) => p.evaluate((a) => {
  const ws = XLSX.utils.aoa_to_sheet(a.rows);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, a.sheet);
  return Array.from(new Uint8Array(XLSX.write(wb, { type: 'array', bookType: 'xlsx' })));
}, { rows: aoa, sheet });

const feed = async (bytes, name) => {
  await p.setInputFiles('#syFile', { name, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', buffer: Buffer.from(bytes) });
  await p.waitForTimeout(1200);
};
const status = () => p.evaluate(() => document.getElementById('syXStatus').textContent);

const en = await book([
  ['Person', 'Username', 'Computer Name', 'Email', 'IP', 'CPU', 'RAM'],
  ['سیامک', 's.lahouri', 'PC-001', 's@c.ir', '192.168.1.10', 'Core i7-11700', 32],
  ['مریم', 'm.rezaei', 'PC-002', 'm@c.ir', '192.168.1.24', 'Core i5-10400', 16]
], 'Systems');
await feed(en, 'systems.xlsx');
t(await p.evaluate(() => state.systems.length) === 2, 'دو ردیف از فایل خوانده شد', await status());
t(await p.evaluate(() => state.systems[0].cpu) === 'Core i7-11700', 'ستون‌ها سرِ جای خودشان نشستند');
t(await p.evaluate(() => state.systems[0].ram) === '32', 'عددِ رم به متن تبدیل شد، نه گم');

await feed(en, 'systems.xlsx');
t(await p.evaluate(() => state.systems.length) === 2, 'خواندنِ دوبارهٔ همان فایل چیزی اضافه نمی‌کند');
t((await status()).indexOf('تکراری') >= 0, 'و می‌گوید چند ردیف تکراری بود', await status());

const faBook = await book([
  ['شخص', 'نام کاربری', 'نام کامپیوتر', 'ایمیل', 'آی‌پی', 'مدل پردازنده', 'رم'],
  ['رضا', 'r.ahmadi', 'PC-009', 'r@c.ir', '192.168.1.99', 'Ryzen 5 5600', 16]
], 'Sheet1');
await feed(faBook, 'fa.xlsx');
t(await p.evaluate(() => state.systems.length) === 3, 'سرستونِ فارسی هم خوانده می‌شود');
t(await p.evaluate(() => (state.systems[2] || {}).name) === 'PC-009',
  'و برگه‌ای با نامِ دیگر («Sheet1») هم پیدا می‌شود');

const junk = await book([['الف', 'ب'], ['۱', '۲']], 'Sheet1');
await feed(junk, 'junk.xlsx');
t(await p.evaluate(() => state.systems.length) === 3, 'فایلِ بی‌ربط چیزی را خراب نمی‌کند');
t((await status()).indexOf('⚠️') === 0, 'و هشدار می‌دهد', await status());

console.log('===== مرتب‌سازی و جابه‌جایی =====');
await p.evaluate(() => {
  state.systems = [
    { person: 'سیامک', user: 's.l', name: 'PC-003', email: 'a@c.ir', ip: '192.168.1.30', cpu: 'Core i7', ram: '32' },
    { person: 'مریم', user: 'm.r', name: 'PC-001', email: 'b@c.ir', ip: '192.168.1.10', cpu: 'Core i5', ram: '8' },
    { person: 'حسن', user: 'h.k', name: 'PC-002', email: 'c@c.ir', ip: '192.168.1.20', cpu: 'Core i3', ram: '16' }
  ];
  SYSTEMS.render();
});
await p.waitForTimeout(800);

const order = () => p.evaluate(() => [].slice.call(document.querySelectorAll('#syBody tr'))
  .filter(r => r.children.length > 1 && r.style.display !== 'none')
  .map(r => r.querySelector('input[data-sy="name"]').value).join(','));

t(await p.evaluate(() => document.querySelectorAll('#view-systems thead .ts-h').length) === 7,
  'هر هفت ستون سرستونِ مرتب‌شدنی دارند');

await p.click('#view-systems thead th[data-col="3"]');
await p.waitForTimeout(400);
t(await order() === 'PC-001,PC-002,PC-003', 'کلیک روی «اسمِ سیستم» صعودی مرتب می‌کند', await order());
await p.click('#view-systems thead th[data-col="3"]');
await p.waitForTimeout(400);
t(await order() === 'PC-003,PC-002,PC-001', 'کلیکِ دوم نزولی', await order());

await p.click('#view-systems thead th[data-col="7"]');
await p.waitForTimeout(400);
t(await p.evaluate(() => [].slice.call(document.querySelectorAll('#syBody tr'))
  .filter(r => r.children.length > 1).map(r => r.querySelector('input[data-sy="ram"]').value).join(',')) === '8,16,32',
  'ستونِ رم عددی مرتب می‌شود، نه حرفی');

await p.click('#view-systems thead th[data-col="7"]');
await p.waitForTimeout(300);
await p.click('#view-systems thead th[data-col="7"]');
await p.waitForTimeout(400);
t(await order() === 'PC-003,PC-001,PC-002', 'کلیکِ سوم مرتب‌سازی را برمی‌دارد', await order());

const fbox = await p.evaluate(() => document.querySelectorAll('#view-systems thead .ts-f').length);
t(fbox === 7, 'هر ستون کادرِ فیلترِ خودش را دارد', String(fbox));
await p.fill('#view-systems thead .ts-f[data-col="3"]', 'PC-002');
await p.waitForTimeout(400);
t(await order() === 'PC-002', 'فیلترِ ستونی کار می‌کند');
await p.fill('#view-systems thead .ts-f[data-col="3"]', '');
await p.waitForTimeout(400);

t(await p.evaluate(() => document.querySelectorAll('#syBody .rd-grip').length) === 3,
  'هر ردیف دستهٔ جابه‌جایی دارد');

const moved = await p.evaluate(() => {
  const rows = [].slice.call(document.querySelectorAll('#syBody tr')).filter(r => r.children.length > 1);
  const grip = rows[0].querySelector('.rd-grip');
  if (!grip) return 'NO GRIP';
  const dt = new DataTransfer();
  grip.dispatchEvent(new DragEvent('dragstart', { bubbles: true, dataTransfer: dt }));
  const r = rows[2].getBoundingClientRect();
  const at = { bubbles: true, dataTransfer: dt, clientY: r.top + r.height - 2 };
  rows[2].dispatchEvent(new DragEvent('dragover', at));
  rows[2].dispatchEvent(new DragEvent('drop', at));
  document.dispatchEvent(new DragEvent('dragend', { bubbles: true, dataTransfer: dt }));
  return 'ok';
});
await p.waitForTimeout(700);
t(moved === 'ok' && await p.evaluate(() => state.systems.map(r => r.name).join(',')) === 'PC-001,PC-002,PC-003',
  'کشیدنِ ردیف، ترتیبِ خودِ داده را عوض می‌کند',
  await p.evaluate(() => state.systems.map(r => r.name).join(',')));

t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' | ') || '—');

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
