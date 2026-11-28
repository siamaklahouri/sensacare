/* گزارشِ سلامتِ ماهانه: عددهایش از همان داده‌های کارتابل درمی‌آید،
   «آنچه اقدام می‌خواهد» سرِ صفحه است، و بخشِ بی‌داده اصلاً چاپ
   نمی‌شود. سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch, calm } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await launch();
const p = await b.newPage({ viewport: { width: 1500, height: 1000 } });
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
t(await p.evaluate(() => !!document.querySelector('.nav-list .navbtn[data-view="health"]')),
  'دکمهٔ «گزارش سلامت» در فهرستِ بخش‌هاست');

await p.evaluate(() => {
  state.systems = [
    { person: 'سیامک', user: 's.l', name: 'PC-01', email: 'a@c.ir', ip: '192.168.1.10', cpu: 'i7', ram: '32' },
    { person: 'مریم', user: 'm.r', name: 'PC-02', email: 'b@c.ir', ip: '192.168.1.24', cpu: 'i5', ram: '16' },
    { person: '', user: 'h.k', name: 'PC-03', email: 'c@c.ir', ip: '192.168.1.24', cpu: 'i3', ram: '8' }
  ];
  backupData = backupData || { vm: [] };
  backupData.vm = [
    { server: 'SRV-APP-01', location: 'DC1', sizeUsed: 220, sizeVib: 35, schedule: 'روزانه', lastRestore: '۱۴۰۵/۰۵/۰۹', storage: 'NAS' },
    { server: 'SRV-DB-01', location: 'DC2', sizeUsed: 640, sizeVib: 120, schedule: 'هفتگی', lastRestore: '', storage: 'Tape' },
    { server: 'SRV-FILE', location: 'DC1', sizeUsed: 90, sizeVib: 10, schedule: 'روزانه', lastRestore: DatePick.fmt(DatePick.today().jy, DatePick.today().jm, DatePick.today().jd), storage: 'NAS' }
  ];
  document.querySelector('.nav-list .navbtn[data-view="health"]').click();
});
await p.waitForTimeout(800);

console.log('===== سربرگ و کارت‌ها =====');
t((await p.evaluate(() => document.getElementById('hrWhen').textContent)).indexOf('تهیه‌شده در') >= 0,
  'تاریخِ تهیه روی گزارش هست', await p.evaluate(() => document.getElementById('hrWhen').textContent));

const cards = await p.evaluate(() => [].slice.call(document.querySelectorAll('#hrCards .stat'))
  .map(s => s.querySelector('.stat-lbl').textContent + '=' + s.querySelector('.stat-val').textContent).join(' | '));
t(await p.evaluate(() => document.querySelectorAll('#hrCards .stat').length) === 4,
  'چهار کارتِ خلاصه بالای گزارش است', cards);
t(cards.indexOf('ری‌استورِ عقب‌افتاده=۲') >= 0,
  'ری‌استورِ عقب‌افتاده درست شمرده می‌شود (یکی گذشته، یکی هیچ‌وقت)', cards);

console.log('===== آنچه اقدام می‌خواهد =====');
const todo = await p.evaluate(() => [].slice.call(document.querySelectorAll('#hrBody .hr-act tbody tr'))
  .map(r => r.children[1].textContent).join(' | '));
t(todo.indexOf('SRV-DB-01') >= 0 && todo.indexOf('هیچ‌وقت') >= 0,
  'سرورِ تست‌نشده در فهرستِ اقدام هست');
t(todo.indexOf('SRV-APP-01') >= 0, 'سرورِ از موعد گذشته هم هست');
t(todo.indexOf('192.168.1.24') >= 0, 'آی‌پیِ تکراری هم هشدار می‌شود');
t(todo.indexOf('ناقص') >= 0, 'سیستمِ ناقص هم گفته می‌شود');
t(await p.evaluate(() => document.querySelectorAll('#hrBody .hr-act tbody tr.hr-bad').length) > 0,
  'موردهای جدی قرمزند');

console.log('===== جعبه‌های خلاصه =====');
const boxes = await p.evaluate(() => [].slice.call(document.querySelectorAll('#hrBody .hr-box h4'))
  .map(h => h.textContent).join(' | '));
t(boxes.indexOf('بکاپ و سرورها') >= 0, 'جعبهٔ بکاپ هست', boxes);
t(boxes.indexOf('تستِ ری‌استور') >= 0, 'جعبهٔ ری‌استور هست');
t(boxes.indexOf('سیستم‌ها') >= 0, 'جعبهٔ سیستم‌ها هست');
t(boxes.indexOf('خطوطِ MVPN') < 0, 'بخشی که داده ندارد اصلاً نمی‌آید', boxes);

const sizeRow = await p.evaluate(() => {
  const r = [].slice.call(document.querySelectorAll('#hrBody .hr-t tr'))
    .filter(x => x.children[0].textContent.indexOf('حجمِ کل') >= 0)[0];
  return r ? r.children[1].textContent : '';
});
t(sizeRow.indexOf('۱۱۱۵') >= 0, 'حجمِ کل از جمعِ vbk و vib درمی‌آید', sizeRow);

console.log('===== چاپ =====');
t(await p.evaluate(() => !!document.querySelector('#view-health .section-title .kb-print-btn')),
  'دکمهٔ چاپِ همین بخش سرِ عنوان نشسته');
t(await p.evaluate(() => !!document.querySelector('#view-health .hr-sign')),
  'جای امضا و تاریخ پای گزارش هست');

console.log('===== نمرهٔ سلامت =====');
const sc = await p.evaluate(() => ({
  n: document.querySelector('.hr-sc-v').textContent,
  g: document.querySelector('.hr-sc-g').textContent,
  bars: [].slice.call(document.querySelectorAll('.hr-bar'))
    .map(x => x.querySelector('.hr-bl').textContent + '=' + x.querySelector('.hr-bv').textContent).join(' | '),
  raw: HEALTH.score('')
}));
t(/[۰-۹]/.test(sc.n), 'نمرهٔ سلامت عدد دارد', sc.n + ' — ' + sc.g);
t(sc.bars.indexOf('چک‌لیستِ ماهانه') >= 0 && sc.bars.indexOf('تستِ ری‌استور') >= 0,
  'اجزای نمره جداجدا نشان داده می‌شوند', sc.bars);
t(sc.bars.indexOf('چک‌لیستِ ریموت') < 0,
  'جزئی که داده ندارد در نمره نمی‌آید');
t(sc.raw.parts.reduce((a, x) => a + x.share, 0) >= 99,
  'وزنِ اجزای موجود روی هم ۱۰۰ می‌شود', String(sc.raw.parts.map(x => x.share)));

console.log('===== کارهای بازِ این ماه =====');
const open = await p.evaluate(() => {
  const h = [].slice.call(document.querySelectorAll('#hrBody .panel h3'))
    .filter(x => x.textContent.indexOf('کارهای باز') >= 0)[0];
  if (!h) return null;
  const tb = h.parentNode.querySelector('tbody');
  return { n: tb.children.length, first: tb.children[0].children[1].textContent,
           late: tb.querySelectorAll('tr.hr-bad').length };
});
t(open && open.n > 0, 'جدولِ کارهای باز هست', open ? String(open.n) + ' ردیف' : 'نیست');
t(open && open.late > 0, 'عقب‌افتاده‌ها بالای همین جدول و قرمزند');

console.log('===== ماهِ گزارش =====');
const mo = await p.evaluate(() => ({
  opts: [].slice.call(document.querySelectorAll('#hrMonth option')).map(o => o.textContent).join(' | '),
  val: document.getElementById('hrMonth').value
}));
t(mo.opts.length > 0, 'فهرستِ ماه‌ها پُر شده', mo.opts);
t(mo.val === await p.evaluate(() => String(state.currentMonthKey || '')),
  'و ماهِ جاری انتخاب است', mo.val);

console.log('===== نمودار و یادداشت =====');
t(await p.evaluate(() => !!document.getElementById('hrChart')), 'نمودارِ کارهای باز کشیده شده');
t(await p.evaluate(() => {
  const n = document.getElementById('hrNote');
  if (!n) return false;
  const box = n.closest('.hr-note-box');
  const chart = document.getElementById('hrChartWrap');
  const sign = document.querySelector('.hr-sign');
  if (!box || !chart || !sign) return false;
  return (chart.compareDocumentPosition(box) & Node.DOCUMENT_POSITION_FOLLOWING) > 0 &&
         (box.compareDocumentPosition(sign) & Node.DOCUMENT_POSITION_FOLLOWING) > 0;
}), 'ترتیبِ پایینِ صفحه درست است: نمودار، یادداشت، امضا');

await p.evaluate(() => {
  const n = document.getElementById('hrNote');
  n.value = 'قطعیِ برقِ دیتاسنتر ۲';
  n.dispatchEvent(new Event('change'));
});
await p.waitForTimeout(300);
t(await p.evaluate(() => String(state.healthNote || '')) === 'قطعیِ برقِ دیتاسنتر ۲',
  'یادداشتِ تهیه‌کننده در کارتابل ذخیره می‌شود');
t((await p.evaluate(() => document.querySelector('.hr-note-print').textContent)).indexOf('قطعی') >= 0,
  'و همان متن برای کاغذ هم آماده است');

console.log('===== وقتی همه‌چیز مرتب است =====');
await p.evaluate(() => {
  state.systems = [];
  backupData.vm = [];
  (state.tasks || []).forEach(x => { x.status = 'انجام شد'; });
  HEALTH.render();
});
await p.waitForTimeout(400);
t(await p.evaluate(() => !!document.querySelector('#hrBody .hr-none')),
  'گزارشِ بی‌ایراد، پیامِ خودش را دارد');

t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' | ') || '—');

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
