/* «دیتا تو جدول درست نمیشینه».

   ریشه‌اش نگهبانِ ضدِ تکمیلِ خودکار بود. آن نگهبان هر مقداری را که
   کاربر خودش تایپ نکرده بود از ردیفِ افزودن پاک می‌کرد — و تقویم
   مقدار را برنامه‌ای می‌گذارد، نه با تایپ. پس کاربر تاریخ را انتخاب
   می‌کرد و ۴۰۰ میلی‌ثانیه بعد خانه خالی می‌شد، در پنج ردیفِ افزودنِ
   کارتابل مالی.

   این آزمون همان راهِ کاربر را می‌رود: روی خانهٔ تاریخ کلیک، یک روز
   از تقویم انتخاب، و بعد دیدن اینکه تاریخ هم روی صفحه مانده هم در
   ردیفِ ساخته‌شده نشسته. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1440, height: 1000 } });
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 180)));
p.on('dialog', d => d.accept());
await p.goto('http://127.0.0.1:8893/', { waitUntil: 'networkidle' });
await p.waitForTimeout(1600);
await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
await p.waitForTimeout(400);

const views = await p.evaluate(() => [...document.querySelectorAll('.navbtn')]
  .filter(x => x.offsetParent !== null).map(x => ({ v: x.getAttribute('data-view'), label: x.textContent.trim() })));

let checked = 0;
for (const v of views) {
  await p.evaluate(x => document.querySelector(`[data-view="${x}"]`).click(), v.v);
  await p.waitForTimeout(450);
  await p.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
    .forEach(i => { if (!i.checked) i.click(); }); }, v.v);
  await p.waitForTimeout(350);

  const id = await p.evaluate(x => { const el = [...document.querySelectorAll('#view-' + x + ' tr.add-row input')]
      .find(i => i.closest('.dp-host')); return el ? el.id : null; }, v.v);
  if (!id) continue;
  checked++;

  /* تقویم را مثل کاربر باز می‌کنیم */
  await p.click('#' + id);
  await p.waitForTimeout(500);
  const open = await p.evaluate(() => { const q = document.querySelector('.dp-pop, .dp-wrap, [class*="dp-"]:not(.dp-host)');
    return !!(q && q.getBoundingClientRect().width > 60); });
  t(open, v.label + ': تقویم با کلیک روی خانه باز شد');

  /* یک روز را انتخاب می‌کنیم */
  const picked = await p.evaluate(() => {
    const days = [...document.querySelectorAll('.dp-d, .dp-day, .dp-grid button, .dp-grid td')]
      .filter(d => d.offsetParent !== null && /^[۰-۹0-9]+$/.test((d.textContent || '').trim()));
    if (!days.length) return null;
    const d = days[Math.min(14, days.length - 1)];
    const txt = (d.textContent || '').trim();
    d.click();
    return txt;
  });
  t(!!picked, v.label + ': یک روز از تقویم انتخاب شد', picked || 'روزی پیدا نشد');

  /* و حالا همان کاری که هر کاربری می‌کند: می‌رود سراغ خانهٔ بعدی.
     اینجا بود که تاریخ گم می‌شد — تا وقتی خانه زیرِ دستِ کاربر است
     نگهبان کاری ندارد، ولی به‌محضِ رفتنِ فوکوس، چون مقدار را «کاربر
     تایپ نکرده بود»، پاکش می‌کرد. */
  const other = await p.evaluate(({ x, skip }) => {
    const el = [...document.querySelectorAll('#view-' + x + ' tr.add-row input:not([type=hidden])')]
      .filter(i => i.offsetParent !== null && i.id !== skip)[0];
    if (!el) return null;
    el.focus();
    return el.id || '?';
  }, { x: v.v, skip: id });
  await p.waitForTimeout(1700);
  const val = await p.evaluate(i => (document.getElementById(i) || {}).value || '', id);
  t(val !== '', v.label + ': تاریخ بعد از رفتنِ فوکوس هم در خانه ماند',
    JSON.stringify(val) + (other ? ' (فوکوس رفت به ' + other + ')' : ''));

  /* و در ردیفِ ساخته‌شده هم بنشیند */
  if (val) {
    const AB = 'الفبپتثجچحخدذرزژسشصضطظعغ';
    const stamp = 'آزمون' + Array.from({ length: 5 }, () => AB[Math.floor(Math.random() * AB.length)]).join('');
    /* همهٔ خانه‌های لازم را پر می‌کنیم، نه فقط اولی: بعضی جدول‌ها دو
       خانهٔ اجباری دارند و با یکی، «افزودن» یک هشدار می‌دهد و ردیفی
       ساخته نمی‌شود — هشدار هم خودکار بسته می‌شود و بی‌صدا می‌ماند. */
    const fields = await p.evaluate(({ x, skip }) =>
      [...document.querySelectorAll('#view-' + x + ' tr.add-row input:not([type=hidden])')]
        .filter(i => i.offsetParent !== null && i.id !== skip)
        .map(i => ({ id: i.id, num: i.type === 'number' })), { x: v.v, skip: id });
    for (let k = 0; k < fields.length; k++) {
      const h = await p.$('#' + fields[k].id);
      if (!h) continue;
      await h.click();
      await h.fill(fields[k].num ? String(10 + k) : stamp + (k ? '-' + k : ''));
      await p.waitForTimeout(40);
    }
    await p.evaluate(x => [...document.querySelectorAll('#view-' + x + ' tr.add-row button')]
      .filter(z => !z.classList.contains('cp-more'))[0].click(), v.v);
    await p.waitForTimeout(800);
    /* مقدارِ خانه را مثلِ خودِ برنامه می‌خوانیم: بعضی خانه‌ها <input>
       دارند و متنشان در innerText نمی‌آید. */
    const inRow = await p.evaluate(({ x, d }) => {
      const rows = [...document.querySelectorAll('#view-' + x + ' tbody tr')].filter(z => !z.classList.contains('add-row'));
      return rows.some(r => [...r.children].some(td => {
        const f = td.querySelector('input, select, textarea');
        const v2 = f ? (f.value || '') : ((td.textContent || '').trim());
        return v2 === d;
      }));
    }, { x: v.v, d: val });
    t(inRow, v.label + ': و همان تاریخ در ردیفِ تازه نشست', val);
  }
}
/* ---- و حالا همان چیزی که نگهبانِ ضدِ تکمیلِ خودکار خرابش می‌کرد ----
   مقداری که برنامه می‌گذارد و خانه زیرِ دستِ کاربر نیست. نگهبانِ قبلی
   هر چیزی را که «کاربر تایپ نکرده» پاک می‌کرد؛ حالا فقط چیزی را
   برمی‌دارد که خودِ مرورگر ریخته باشد. */
let wiped = [];
for (const v of views) {
  await p.evaluate(x => document.querySelector(`[data-view="${x}"]`).click(), v.v);
  await p.waitForTimeout(400);
  await p.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
    .forEach(i => { if (!i.checked) i.click(); }); }, v.v);
  await p.waitForTimeout(300);
  const put = await p.evaluate(x => {
    const el = [...document.querySelectorAll('#view-' + x + ' tr.add-row input:not([type=hidden])')]
      .filter(i => i.offsetParent !== null && i.type !== 'number')[0];
    if (!el) return null;
    el.value = 'مقدارِ برنامه‌ای';
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.blur();                       /* عمداً زیرِ دستِ کاربر نیست */
    return el.id || el.placeholder || '?';
  }, v.v);
  if (!put) continue;
  await p.waitForTimeout(1700);
  const still = await p.evaluate(x => {
    const el = [...document.querySelectorAll('#view-' + x + ' tr.add-row input:not([type=hidden])')]
      .filter(i => i.offsetParent !== null && i.type !== 'number')[0];
    return el ? el.value : '';
  }, v.v);
  if (still !== 'مقدارِ برنامه‌ای') wiped.push(v.label + ' (' + put + ')');
}
t(wiped.length === 0, 'مقداری که برنامه می‌گذارد پاک نمی‌شود، حتی بی‌فوکوس',
  wiped.length ? 'پاک شد در: ' + wiped.join('، ') : 'در هیچ جدولی پاک نشد');

t(checked >= 4, 'همهٔ جدول‌های تاریخ‌دار سنجیده شدند', checked + ' جدول');
t(errs.length === 0, 'هیچ خطای صفحه‌ای رخ نداد', errs[0] || '');
await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
