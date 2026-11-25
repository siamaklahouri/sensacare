/* بخش‌های اشتراکی، این بار در خودِ صفحه: باید زیرِ نامِ گروه و پایینِ
   بخش‌های خودِ کاربر بنشینند، جدولشان پر شود، و تغییرِ یک خانه در
   دادهٔ کارتابلِ صاحبش بنشیند.

   سرورِ واقعی روی 8911 با دیتابیسِ موقت بالاست؛ این فایل فقط صفحه را
   می‌آزماید. راه‌اندازی‌اش در server/vshare.setup.md نوشته شده. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const USER = process.env.VS_USER || 'sina';
const PASS = process.env.VS_PASS || 'sinasinasina';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await launch();
const p = await b.newPage({ viewport: { width: 1440, height: 1000 } });
const errs = [];
p.on('pageerror', e => errs.push(String(e).slice(0, 200)));

await p.goto(BASE + '/' + USER + '/', { waitUntil: 'networkidle' });
await p.waitForTimeout(800);

/* رمزِ این کارتابل را خودِ آزمون می‌گذارد، وگرنه به ترتیبِ اجرا بند
   می‌شود: آزمونِ پوسته رمزِ همهٔ کارتابل‌ها را عوض می‌کند و این یکی
   پشتِ در می‌ماند. هر آزمون باید بتواند تنها هم اجرا شود. */
{
  let ck = '';
  const call = async (path, opt) => {
    const o = Object.assign({ headers: {} }, opt || {});
    o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
    const r = await fetch(BASE + path, o);
    for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
      const kv = c.split(';')[0], k = kv.split('=')[0];
      ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
    }
    try { return await r.json(); } catch (e) { return {}; }
  };
  await call('/api/admin.planer/signin', { method: 'POST', body: JSON.stringify({
    user: process.env.VS_ADMIN || 'admin',
    password: process.env.VS_ADMIN_PASS || 'adminadminadmin' }) });
  await call('/api/admin.planer/planners/' + USER + '/password',
    { method: 'POST', body: JSON.stringify({ password: PASS }) });
}

/* ورود: همان مسیرِ /login که فرمِ صفحه هم صدا می‌زند. از خودِ فرم
   نرفتیم چون این فایل قفلِ ورود را نمی‌آزماید — آن جای دیگری آزموده
   می‌شود — و یک ناخنکِ مرورگر به کادرِ رمز، این آزمون را بی‌دلیل
   شکننده می‌کرد. */
const login = await p.evaluate(async ({ u, w }) => {
  const r = await fetch('/api/' + u + '/login', {
    method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password: w, remember: false })
  });
  return r.status;
}, { u: USER, w: PASS });
t(login === 200, 'وارد شد', String(login));
await p.goto(BASE + '/' + USER + '/', { waitUntil: 'networkidle' });
await p.waitForTimeout(3500);

console.log('===== نوار کنار =====');
const nav = await p.evaluate(() => {
  const out = [];
  document.querySelectorAll('.nav-list > *').forEach(el => {
    if (el.classList.contains('sh-org')) out.push({ kind: 'org', text: el.textContent.trim() });
    else if (el.classList.contains('navbtn'))
      out.push({ kind: 'btn', view: el.getAttribute('data-view'), text: el.textContent.trim() });
  });
  return out;
});
const vsBtns = nav.filter(x => x.kind === 'btn' && String(x.view).indexOf('vshare-') === 0);
t(vsBtns.length === 2, 'هر دو بخشِ اشتراکی در نوار آمدند',
  vsBtns.map(x => x.view).join(', ') || JSON.stringify(nav.slice(-6)));

const orgIx = nav.findIndex(x => x.kind === 'org');
const firstVs = nav.findIndex(x => x.kind === 'btn' && String(x.view).indexOf('vshare-') === 0);
t(orgIx >= 0 && orgIx < firstVs, 'سرفصلِ گروه بالای آن‌هاست',
  orgIx >= 0 ? nav[orgIx].text : 'سرفصلی نیامد');

const ownIx = nav.map((x, i) => (x.kind === 'btn' && String(x.view).indexOf('vshare-') !== 0 ? i : -1))
                 .filter(i => i >= 0);
t(ownIx.length && Math.max(...ownIx.filter(i => i < firstVs)) < firstVs,
  'و بخش‌های خودِ کاربر بالاترند');
t(vsBtns.some(x => x.text.indexOf('سیامک') >= 0), 'نامِ صاحبِ بخش روی دکمه هست', vsBtns[0] && vsBtns[0].text);

console.log('\n===== جدول =====');
const id = vsBtns[0] ? String(vsBtns[0].view).replace('vshare-', '') : '';
await p.evaluate(v => document.querySelector('[data-view="' + v + '"]').click(), 'vshare-' + id);
await p.waitForTimeout(1500);

await p.evaluate(async ({ i, u }) => {
  const r = await fetch('/api/' + u + '/vshare/' + i, { credentials: 'same-origin' });
  const d = await r.json();
  window.__vsCols = (d.cols || []).length;
}, { i: id, u: USER });
const tbl = await p.evaluate(i => {
  const sec = document.getElementById('view-vshare-' + i);
  if (!sec) return { no: 'section' };
  const ths = [...sec.querySelectorAll('thead th')].map(x => x.textContent.trim());
  const rows = [...sec.querySelectorAll('tbody tr')].map(tr =>
    [...tr.children].map(td => (td.querySelector('select') ? td.querySelector('select').value : td.textContent.trim())));
  return { active: sec.classList.contains('active'), ths, rows,
           cols: (window.__vsCols || 0),
           sub: (sec.querySelector('.section-sub') || {}).textContent || '',
           hasToggle: !!sec.querySelector('[data-vsedit]'),
           hasAdd: !!sec.querySelector('[data-vsadd]') };
}, id);
t(tbl.active, 'نما باز شد');
/* تعداد ستون‌ها عمداً سفت نشده: فهرستِ ستون‌های هر بخش در
   src/viewshare.js است و ممکن است عوض شود. آن‌چه باید همیشه درست
   بماند این است: شماره اول، کلیدِ حذف/تغییر آخر، و ستون‌ها همان‌هایی
   که سرور اعلام کرده. */
t(tbl.ths && tbl.ths.length === tbl.cols + 2 &&
  tbl.ths[0] === '#' && /حذف\/تغییر/.test(tbl.ths[tbl.ths.length - 1]),
  'سرستون‌ها همان ستون‌های سرورند، با شماره در اول و کلیدِ حذف/تغییر در آخر',
  (tbl.ths || []).join(' | '));
t(tbl.rows && tbl.rows.length === 3, 'هر سه ردیفِ سرورها آمدند', tbl.rows && tbl.rows.length);
t(tbl.rows && tbl.rows[0].join(',').indexOf('srv-a') >= 0, 'و دادهٔ واقعی داخلشان است', tbl.rows && tbl.rows[0].join(' | '));
t(/سیامک/.test(tbl.sub), 'زیرنویس می‌گوید بخشِ کِی است', tbl.sub.slice(0, 70).replace(/\s+/g, ' '));
t(tbl.hasToggle && tbl.hasAdd, 'کلیدِ حذف/تغییر و دکمهٔ ردیف تازه هستند (دسترسیِ نوشتن دارد)');

console.log('\n===== خانه‌ها پیش از باز کردنِ کلید قفل‌اند =====');
let able = await p.evaluate(i => {
  const sec = document.getElementById('view-vshare-' + i);
  return [...sec.querySelectorAll('tbody td.vs-c')].filter(td => td.getAttribute('contenteditable') === 'true').length;
}, id);
t(able === 0, 'هیچ خانه‌ای نوشتنی نیست', String(able));

await p.evaluate(i => document.querySelector('[data-vsedit="' + i + '"]').click(), id);
await p.waitForTimeout(500);
able = await p.evaluate(i => {
  const sec = document.getElementById('view-vshare-' + i);
  return [...sec.querySelectorAll('tbody td.vs-c')].filter(td => td.getAttribute('contenteditable') === 'true').length;
}, id);
t(able > 0, 'بعد از باز کردنِ کلید، نوشتنی شدند', String(able));

console.log('\n===== نوشتنِ یک خانه =====');
const stamp = 'انبارِ' + Math.floor(Math.random() * 9000 + 1000);
await p.evaluate(({ i, v }) => {
  const sec = document.getElementById('view-vshare-' + i);
  const tr = sec.querySelector('tbody tr[data-ix="0"]');
  const td = [...tr.querySelectorAll('td.vs-c')].find(x => x.getAttribute('data-k') === 'storage');
  td.focus(); td.textContent = v; td.blur();
}, { i: id, v: stamp });
await p.waitForTimeout(1800);

const after = await p.evaluate(i => {
  const sec = document.getElementById('view-vshare-' + i);
  const tr = sec.querySelector('tbody tr[data-ix="0"]');
  const td = [...tr.querySelectorAll('td.vs-c')].find(x => x.getAttribute('data-k') === 'storage');
  return { shown: td ? td.textContent.trim() : '',
           note: (sec.querySelector('.vs-note') || {}).textContent || '' };
}, id);
t(after.shown === stamp, 'خانه همان مقدار را نشان می‌دهد', after.shown);
t(/ذخیره شد/.test(after.note), 'و پیامِ ذخیره آمد', after.note);

/* سرور چه می‌گوید — نه مرورگر */
const srv = await p.evaluate(async ({ i }) => {
  const r = await fetch('/api/sina/vshare/' + i, { credentials: 'same-origin' });
  const d = await r.json();
  return (d.rows && d.rows[0] && d.rows[0].storage) || '';
}, { i: id });
t(srv === stamp, 'و در دادهٔ کارتابلِ سیامک روی سرور نشست', srv);

console.log('\n===== بخشِ فقط‌خواندنی =====');
const roId = vsBtns[1] ? String(vsBtns[1].view).replace('vshare-', '') : '';
await p.evaluate(v => document.querySelector('[data-view="' + v + '"]').click(), 'vshare-' + roId);
await p.waitForTimeout(1200);
const ro = await p.evaluate(i => {
  const sec = document.getElementById('view-vshare-' + i);
  return { toggle: !!sec.querySelector('[data-vsedit]'), add: !!sec.querySelector('[data-vsadd]'),
           del: sec.querySelectorAll('[data-vsdel]').length,
           able: [...sec.querySelectorAll('td.vs-c')].filter(td => td.getAttribute('contenteditable') === 'true').length,
           rows: sec.querySelectorAll('tbody tr').length,
           sub: (sec.querySelector('.section-sub') || {}).textContent || '' };
}, roId);
t(!ro.toggle && !ro.add && ro.del === 0, 'نه کلیدِ تغییر، نه دکمهٔ افزودن، نه دکمهٔ حذف');
t(ro.able === 0, 'و هیچ خانه‌ای نوشتنی نیست');
t(ro.rows >= 1, 'ولی ردیف‌ها دیده می‌شوند', String(ro.rows));
t(/فقط می‌توانید ببینید/.test(ro.sub), 'و زیرنویس همین را می‌گوید', ro.sub.slice(0, 70));

console.log('\n===== نوارِ ابزارِ بخشِ اشتراکی =====');
{
  /* بخشی که از کارتابلِ دیگری می‌آید، ابزارهای خودِ کارتابل را ندارد:
     نه مرتب‌سازی، نه پالایه. و بعضی از این جدول‌ها ده ستون دارند.
     گزارش شد که «کاربر باید بتواند قشنگ آن بخش را ببیند و اگر چند
     قسمت دارد انتخاب کند کدام را ببیند» — این سه چیز کمینهٔ همان
     است: جستجو، انتخابِ ستون، و شمارِ ردیف. */
  await p.evaluate(v => document.querySelector('[data-view="' + v + '"]').click(), 'vshare-' + id);
  await p.waitForTimeout(1200);

  /* دو بخشِ اشتراکی در صفحه هست؛ همه‌چیز باید داخلِ همین یکی سنجیده
     شود، وگرنه ستون‌های آن یکی هم شمرده می‌شوند. */
  const SEC = '#view-vshare-' + id + ' ';
  const head = () => p.evaluate(sel =>
    [...document.querySelectorAll(sel + '[data-vshead] th')].map(x => x.innerText.trim()), SEC);
  const cols0 = await head();
  t(cols0.length > 3, 'سرِ جدول ساخته می‌شود', cols0.join(' | '));
  t(await p.evaluate(sel => !!document.querySelector(sel + '.vs-find'), SEC), 'کادرِ جستجو هست');
  const cnt0 = await p.evaluate(sel =>
    (document.querySelector(sel + '[data-vscount]') || {}).textContent || '', SEC);
  t(/ردیف/.test(cnt0), 'و شمارِ ردیف‌ها نوشته می‌شود', cnt0);

  /* انتخابِ ستون */
  await p.evaluate(sel => document.querySelector(sel + '[data-vscols]').click(), SEC);
  await p.waitForTimeout(300);
  const chips = await p.evaluate(sel => document.querySelectorAll(sel + '.vs-col').length, SEC);
  const extra = await p.evaluate(sel =>
    document.querySelector(sel + '[data-vshead] .edit-toggle-wrap') ? 2 : 1, SEC);
  t(chips === cols0.length - extra, 'برای هر ستون یک قرص هست',
    chips + ' قرص در برابرِ ' + cols0.length + ' سرستون');

  const dropped = await p.evaluate(sel => {
    const c = document.querySelectorAll(sel + '.vs-col')[2];
    const name = c.textContent;
    c.click();
    return name;
  }, SEC);
  await p.waitForTimeout(400);
  const cols1 = await head();
  t(cols1.length === cols0.length - 1 && cols1.indexOf(dropped) < 0,
    'ستونی که کنار گذاشته شود از جدول می‌رود', dropped);

  /* و یادش می‌ماند */
  await p.reload({ waitUntil: 'load' });
  await p.waitForTimeout(3500);
  await p.evaluate(v => document.querySelector('[data-view="' + v + '"]').click(), 'vshare-' + id);
  await p.waitForTimeout(1500);
  const cols2 = await head();
  t(cols2.indexOf(dropped) < 0, 'و بعد از بازخوانیِ صفحه هم یادش می‌ماند',
    cols2.join(' | '));

  /* برش گردانیم تا بقیهٔ آزمون‌ها جدولِ کامل ببینند */
  await p.evaluate(sel => document.querySelector(sel + '[data-vscols]').click(), SEC);
  await p.waitForTimeout(250);
  await p.evaluate(o => {
    const c = [...document.querySelectorAll(o.sel + '.vs-col')].find(x => x.textContent === o.d);
    if (c) c.click();
  }, { sel: SEC, d: dropped });
  await p.waitForTimeout(400);
  t((await head()).length === cols0.length, 'و برگرداندنش هم همین‌طور');

  /* جستجو */
  const first = await p.evaluate(sel => {
    const td = document.querySelector(sel + '[data-vsbody] tr td:nth-child(2)');
    return td ? td.innerText.trim() : '';
  }, SEC);
  if (first) {
    await p.fill(SEC + '.vs-find', first);
    await p.waitForTimeout(400);
    const seen = await p.evaluate(sel => ({
      rows: document.querySelectorAll(sel + '[data-vsbody] tr').length,
      say: (document.querySelector(sel + '[data-vscount]') || {}).textContent || ''
    }), SEC);
    t(seen.rows >= 1 && /از/.test(seen.say), 'جستجو ردیف‌ها را کم می‌کند',
      first + ' → ' + seen.say);
    await p.fill(SEC + '.vs-find', 'چنین‌چیزی‌نیست‌۱۲۳');
    await p.waitForTimeout(400);
    t(await p.evaluate(sel =>
      /پیدا نشد/.test(document.querySelector(sel + '[data-vsbody]').innerText), SEC),
      'و وقتی چیزی پیدا نشود، خودش می‌گوید');
    await p.fill(SEC + '.vs-find', '');
    await p.waitForTimeout(300);
  }
}

console.log('\n===== خطای صفحه =====');
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' // ') || '—');

await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
