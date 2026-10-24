/* توضیحاتِ بخشِ سرورها و بکاپ: نوشتن، ماندن، پاک شدن، و پیدا شدن
   در جست‌وجو. سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await launch();
const errs = [];
const p = await b.newPage({ viewport: { width: 1400, height: 950 } });
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

const open = await p.evaluate(() => {
  state.notes = {};
  document.querySelector('.navbtn[data-view="servers"]').click();
  NOTES.init();
  const box = document.querySelector('[data-notes="servers"]');
  return { there: !!box, add: !!document.querySelector('[data-notes-add="servers"]'),
           empty: box ? box.textContent.trim() : '' };
});
t(open.there && open.add, 'بخشِ سرورها و بکاپ جای توضیحات دارد');
t(/هنوز توضیحی/.test(open.empty), 'و تا چیزی نوشته نشود همین را می‌گوید', open.empty);

/* ---------- نوشتن ---------- */
await p.evaluate(() => document.querySelector('[data-notes-add="servers"]').click());
await p.waitForTimeout(150);
await p.evaluate(() => {
  const ta = document.querySelector('[data-notes="servers"] .nt-txt');
  ta.value = 'بکاپِ سرورِ KLS عمداً هفتگی است — دیسکش کند است.';
  ta.dispatchEvent(new Event('input', { bubbles: true }));
});
await p.waitForTimeout(900);
const one = await p.evaluate(() => ({
  n: (state.notes.servers || []).length,
  txt: (state.notes.servers[0] || {}).text,
  at: (state.notes.servers[0] || {}).at,
  today: (function () { return getTodayJalaliStr(); })()
}));
t(one.n === 1 && /KLS/.test(one.txt), 'توضیح در خودِ دادهٔ کارتابل می‌نشیند', one.txt);
t(one.at === one.today, 'و تاریخِ همان روز را می‌گیرد', one.at);

/* ---------- دومی بالای اولی ---------- */
await p.evaluate(() => document.querySelector('[data-notes-add="servers"]').click());
await p.waitForTimeout(150);
await p.evaluate(() => {
  const ta = document.querySelector('[data-notes="servers"] .nt-txt');
  ta.value = 'پشتیبانِ استوریج: آقای رضایی';
  ta.dispatchEvent(new Event('input', { bubbles: true }));
});
await p.waitForTimeout(900);
const two = await p.evaluate(() => ({
  n: state.notes.servers.length,
  first: state.notes.servers[0].text,
  rows: document.querySelectorAll('[data-notes="servers"] .nt-row').length
}));
t(two.n === 2 && two.rows === 2, 'چند توضیح، هر کدام کادرِ خودش', 'n=' + two.n);
t(/رضایی/.test(two.first), 'و تازه‌ترین بالا می‌نشیند — نه ته فهرست', two.first);

/* ---------- ماندن ---------- */
const back = await p.evaluate(() => {
  document.querySelector('.navbtn[data-view="dashboard"]').click();
  document.querySelector('.navbtn[data-view="servers"]').click();
  NOTES.render('servers');
  const tas = [...document.querySelectorAll('[data-notes="servers"] .nt-txt')];
  return tas.map(x => x.value);
});
t(back.length === 2 && /رضایی/.test(back[0]) && /KLS/.test(back[1]),
  'با رفتن و برگشتن سرِ جایشان هستند، با همان ترتیب',
  back.map(x => x.slice(0, 18)).join(' | '));

/* ---------- جست‌وجو ---------- */
const found = await p.evaluate(() => FIND.search('استوریج').map(h => ({ w: h.where, v: h.view })));
t(found.length >= 1 && /توضیحات/.test(found[0].w) && found[0].v === 'servers',
  'جست‌وجوی سراسری توضیحات را هم می‌گردد', JSON.stringify(found[0] || {}));

/* ---------- پاک کردن ---------- */
const gone = await p.evaluate(() => {
  document.querySelector('[data-notes="servers"] .nt-del').click();
  return { n: state.notes.servers.length, first: (state.notes.servers[0] || {}).text };
});
t(gone.n === 1 && /KLS/.test(gone.first), 'و پاک کردن فقط همان یکی را می‌برد', gone.first);

const last = await p.evaluate(() => {
  document.querySelector('[data-notes="servers"] .nt-del').click();
  return { n: state.notes.servers.length,
           empty: document.querySelector('[data-notes="servers"]').textContent.trim() };
});
t(last.n === 0 && /هنوز توضیحی/.test(last.empty),
  'و با رفتنِ آخری، دوباره همان پیامِ خالی', last.empty);

console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
await p.close();
await b.close();
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
