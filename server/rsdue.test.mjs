/* تستِ ری‌استور: ترتیب از روی ستونِ «آخرین ری‌استور» است و با کلیکِ
   سرستون برمی‌گردد؛ ثبتِ تستِ امروز هم در همان جدولِ سرورها می‌نشیند.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch, calm } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await launch();
const p = await b.newPage({ viewport: { width: 1400, height: 950 } });
const errs = [];
p.on('pageerror', e => errs.push(e.message));

await p.goto(BASE + '/siamak/', { waitUntil: 'domcontentloaded' });
await p.evaluate(async () => {
  await fetch('/api/kartabl/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'content-type': 'application/json' }, body: JSON.stringify({ password: 'siamaksiamak' }) });
});
await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
await calm(p);

await p.evaluate(() => {
  backupData.vm = [
    { server: 'A', location: '10.0.0.1', lastRestore: '۱۴۰۵/۰۸/۲۷' },
    { server: 'B', location: '10.0.0.2', lastRestore: '۱۴۰۵/۰۵/۰۹' },
    { server: 'C', location: '10.0.0.3', lastRestore: '۱۴۰۵/۰۶/۱۳' },
    { server: 'D', location: '10.0.0.4', lastRestore: '' }
  ];
  document.querySelector('.nav-list .navbtn[data-view="restore"]').click();
});
await p.waitForTimeout(500);

const names = () => p.evaluate(() =>
  [].slice.call(document.querySelectorAll('#rsBody tr')).map(r => r.children[1].textContent).join(','));
const arrow = () => p.evaluate(() => {
  const th = document.getElementById('rsSortWhen');
  return th.querySelector('.rs-arrow').textContent + '/' + th.getAttribute('aria-sort');
});

console.log('===== ترتیبِ ستونِ آخرین ری‌استور =====');
t(await names() === 'D,B,C,A', 'پیش‌فرض: قدیمی‌ترین تست اول، تست‌نشده‌ها بالاتر', await names());
t((await arrow()) === '▾/descending', 'پیکانِ سرستون همان را می‌گوید', await arrow());

await p.click('#rsSortWhen');
await p.waitForTimeout(300);
t(await names() === 'A,C,B,D', 'کلیک، ترتیب را برمی‌گرداند: تازه‌ترین اول', await names());
t((await arrow()) === '▴/ascending', 'پیکان هم برمی‌گردد', await arrow());

await p.click('#rsSortWhen');
await p.waitForTimeout(300);
t(await names() === 'D,B,C,A', 'کلیکِ دوم به حالتِ اول برمی‌گردد', await names());

console.log('===== وضعیت و ثبتِ تست =====');
const st = await p.evaluate(() => {
  const r = [].slice.call(document.querySelectorAll('#rsBody tr'));
  return { never: r[0].querySelector('.rs-chip').textContent,
           late: r[1].querySelector('.rs-chip').textContent,
           cards: document.querySelectorAll('#rsCards .stat').length };
});
t(st.never.indexOf('هیچ‌وقت') >= 0, 'سرورِ تست‌نشده همان‌طور نشان داده می‌شود', st.never);
t(st.late.indexOf('موعد') >= 0, 'عقب‌افتاده، فاصله‌اش تا موعد را می‌گوید', st.late);
t(st.cards === 4, 'چهار کارتِ خلاصه بالای جدول هست', String(st.cards));

await p.click('#rsBody tr:first-child [data-rs-done]');
await p.waitForTimeout(400);
const after = await p.evaluate(() => ({
  row: (backupData.vm.find(v => v.server === 'D') || {}).lastRestore || '',
  names: [].slice.call(document.querySelectorAll('#rsBody tr')).map(r => r.children[1].textContent).join(',')
}));
t(/^[۰-۹]{4}\/[۰-۹]{2}\/[۰-۹]{2}$/.test(after.row), 'تستِ امروز در جدولِ سرورها ثبت شد', after.row);
t(after.names === 'B,C,A,D', 'و همان سرور می‌رود تهِ فهرست — تازه‌ترین تست', after.names);

const days = await p.evaluate(() => {
  const i = document.getElementById('rsDays');
  i.value = '30';
  i.dispatchEvent(new Event('change'));
  return { shown: i.value, kept: (window.state || {}).restoreDays };
});
t(days.shown === '۳۰', 'موعد عوض می‌شود و با رقمِ فارسی برمی‌گردد', days.shown);

t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' | ') || '—');

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
