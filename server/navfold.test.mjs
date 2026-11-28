/* منوی کشویی: ستونِ بخش‌ها باید با یک دکمه جمع شود، آیکن‌ها بمانند،
   ناوبری همان‌جا کار کند، حالتش یادش بماند، و روی موبایل دست به
   کشویی‌شدنِ خودِ موبایل نزند.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch, calm } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const WHO = [
  { page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak', name: 'کارتابلِ فنی' },
  { page: '/sina/', api: 'sina', pass: 'sinasinasina', name: 'کارتابلِ مالی' }
];

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await launch();

for (const w of WHO) {
  console.log('===== ' + w.name + ' =====');
  const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
  const errs = [];
  p.on('pageerror', e => errs.push(e.message));

  await p.goto(BASE + w.page, { waitUntil: 'domcontentloaded' });
  await p.evaluate(async (a) => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'content-type': 'application/json' }, body: JSON.stringify({ password: a.pass }) });
  }, w);
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await calm(p);
  await p.waitForSelector('.sidebar .nav-fold', { timeout: 20000 });

  const open = await p.evaluate(() => ({
    w: Math.round(document.querySelector('.sidebar').getBoundingClientRect().width),
    shut: document.documentElement.classList.contains('nav-shut'),
    lbl: document.querySelector('.nav-label').offsetWidth > 0,
    foldShown: document.querySelector('.nav-fold').offsetWidth > 0
  }));
  t(open.foldShown, 'دکمهٔ باز و بسته‌کردن روی صفحهٔ بزرگ دیده می‌شود');
  t(!open.shut, 'اول باز است');
  t(open.w > 150, 'ستون پهنای کاملش را دارد', open.w + 'px');
  t(open.lbl, 'عنوانِ «بخش‌ها» دیده می‌شود');

  await p.click('.nav-fold');
  await p.waitForTimeout(450);
  const shut = await p.evaluate(() => {
    const btn = document.querySelector('.nav-list .navbtn[data-view="dashboard"]');
    const ic = btn.querySelector('.ic');
    return {
      w: Math.round(document.querySelector('.sidebar').getBoundingClientRect().width),
      shut: document.documentElement.classList.contains('nav-shut'),
      btnFont: getComputedStyle(btn).fontSize,
      icW: Math.round(ic.getBoundingClientRect().width),
      lbl: document.querySelector('.nav-label').offsetWidth > 0,
      lockW: Math.round(document.querySelector('#lockBtn').getBoundingClientRect().width),
      lockIc: (document.querySelector('#lockBtn .ic') || {}).textContent || '',
      ls: localStorage.getItem('kb-nav-shut')
    };
  });
  t(shut.shut, 'کلیک، ستون را می‌بندد');
  t(shut.w > 40 && shut.w < 90, 'ستونِ بسته یک نوارِ باریک است', shut.w + 'px');
  t(shut.btnFont === '0px', 'نوشتهٔ دکمه‌ها در حالتِ بسته جمع می‌شود');
  t(shut.icW > 10, 'ولی آیکن‌ها سرِ جایشان‌اند', shut.icW + 'px');
  t(!shut.lbl, 'عنوانِ «بخش‌ها» در حالتِ بسته نیست');
  t(shut.lockW > 10 && shut.lockIc.length > 0, 'دکمهٔ خروج هم با آیکنش می‌ماند', shut.lockIc);
  t(shut.ls === '1', 'حالتِ بسته ذخیره شد');

  await p.click('.nav-list .navbtn[data-view="checklist"]');
  await p.waitForTimeout(300);
  t(await p.evaluate(() => document.querySelector('#view-checklist').classList.contains('active')),
    'در حالتِ بسته هم می‌شود بخش عوض کرد');

  await p.reload({ waitUntil: 'networkidle' });
  await calm(p);
  await p.waitForSelector('.sidebar .nav-fold', { timeout: 20000 });
  await p.waitForTimeout(400);
  const again = await p.evaluate(() => ({
    shut: document.documentElement.classList.contains('nav-shut'),
    w: Math.round(document.querySelector('.sidebar').getBoundingClientRect().width)
  }));
  t(again.shut && again.w < 90, 'بعد از تازه‌کردنِ صفحه هم بسته مانده', again.w + 'px');

  await p.click('.nav-fold');
  await p.waitForTimeout(450);
  const back = await p.evaluate(() => ({
    shut: document.documentElement.classList.contains('nav-shut'),
    w: Math.round(document.querySelector('.sidebar').getBoundingClientRect().width),
    lbl: document.querySelector('.nav-label').offsetWidth > 0,
    ls: localStorage.getItem('kb-nav-shut')
  }));
  t(!back.shut && back.w > 150 && back.lbl, 'دوباره باز می‌شود', back.w + 'px');
  t(back.ls === '0', 'حالتِ باز هم ذخیره شد');

  await p.setViewportSize({ width: 390, height: 780 });
  await p.waitForTimeout(400);
  const phone = await p.evaluate(() => ({
    fold: document.querySelector('.nav-fold').offsetWidth,
    toggle: !!document.querySelector('.nav-toggle')
  }));
  t(phone.fold === 0, 'روی موبایل این دکمه دیده نمی‌شود');
  t(phone.toggle, 'و کشویی خودِ موبایل سرِ جایش است');

  t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' | ') || '—');
  await p.close();
}

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
