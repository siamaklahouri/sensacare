/* بخشِ «هزینه‌ها» در دیتای شخصی — از دسترسیِ ادمین تا رمزنگاری.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const SLUG = 'sina', API = 'sina', PASS = 'sinasinasina';
const SEC = 'hazine';
const VPW = 'vault1234';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* ---------- ادمین: بخش را باز می‌کند ---------- */
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
await call('/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
await call('/api/admin.planer/planners/' + SLUG + '/password',
  { method: 'POST', body: JSON.stringify({ password: PASS }) });

console.log('===== پنل ادمین =====');
const list0 = await call('/api/admin.planer/planners');
t((list0.vaultTypes || []).some(v => v.id === 'exp' && v.label === 'هزینه‌ها'),
  'نوعِ «هزینه‌ها» در فهرستِ بخش‌های پنل هست',
  (list0.vaultTypes || []).map(v => v.id).join(','));
const me = (list0.items || []).find(x => x.slug === SLUG) || {};
const keep = (me.vault || []).filter(s => s.id !== SEC);
const saved = await call('/api/admin.planer/planners/' + SLUG, {
  method: 'PUT', body: JSON.stringify({
    name: me.name, user: me.user,
    vault: keep.concat([{ id: SEC, type: 'exp', title: 'هزینه‌ها' }])
  })
});
t(!saved.error, 'و ادمین می‌تواند آن را برای این کارتابل باز کند', saved.error);
const list1 = await call('/api/admin.planer/planners');
const now = ((list1.items || []).find(x => x.slug === SLUG) || {}).vault || [];
t(now.some(s => s.id === SEC && s.type === 'exp'), 'و سرور همان را برمی‌گرداند',
  now.map(s => s.id + ':' + s.type).join(' '));
/* نوعِ ناشناس باید بیفتد بیرون، وگرنه هر چیزی در این فهرست می‌نشست
   و صفحهٔ کاربر با یک نوعِ ناشناس روبه‌رو می‌شد. */
await call('/api/admin.planer/planners/' + SLUG, {
  method: 'PUT', body: JSON.stringify({ name: me.name, user: me.user,
    vault: keep.concat([{ id: SEC, type: 'exp', title: 'هزینه‌ها' },
                        { id: 'jx', type: 'moneyz', title: 'ناشناس' }]) })
});
const afterJunk = ((await call('/api/admin.planer/planners')).items || [])
  .find(x => x.slug === SLUG) || {};
t((afterJunk.vault || []).some(s => s.id === SEC) &&
  !(afterJunk.vault || []).some(s => s.id === 'jx'),
  'نوعِ ناشناس دور ریخته می‌شود ولی «هزینه‌ها» سرِ جایش می‌ماند',
  (afterJunk.vault || []).map(s => s.id + ':' + s.type).join(' '));
await call('/api/admin.planer/planners/' + SLUG, {
  method: 'PUT', body: JSON.stringify({ name: me.name, user: me.user,
    vault: keep.concat([{ id: SEC, type: 'exp', title: 'هزینه‌ها' }]) })
});

/* ---------- صفحهٔ کاربر ---------- */
const b = await launch();
const errs = [];
const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
p.on('dialog', d => d.accept());

const open = async () => {
  await p.goto(BASE + '/' + SLUG + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(2200);
  await p.evaluate(() => {
    const nb = [...document.querySelectorAll('.navbtn')].find(x => x.dataset.view === 'personal');
    if (nb) nb.click();
  });
  await p.waitForTimeout(400);
};
await p.goto(BASE + '/' + SLUG + '/', { waitUntil: 'networkidle' });
await p.evaluate(async (a) => {
  await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password: a.pass, remember: false }) });
}, { api: API, pass: PASS });
await open();

console.log('\n===== باز کردنِ صندوق =====');
const locked = await p.evaluate(() => !!document.querySelector('#personalWrap .lock-screen'));
t(locked, 'صندوق قفل است و رمز می‌خواهد');
const fresh = await p.evaluate(() => !!document.getElementById('personalPwInput2'));
await p.fill('#personalPwInput', VPW);
if (fresh) await p.fill('#personalPwInput2', VPW);
await p.evaluate(() => document.getElementById('personalUnlockBtn').click());
await p.waitForTimeout(1200);

const tabs = await p.evaluate(s => {
  const bs = [...document.querySelectorAll('#personalWrap [data-ptab]')];
  const mine = bs.find(x => x.getAttribute('data-ptab') === s);
  return { names: bs.map(x => x.textContent.trim()), has: !!mine,
           txt: mine ? mine.textContent.trim() : '' };
}, SEC);
t(tabs.has && /هزینه/.test(tabs.txt), 'سربرگِ «هزینه‌ها» داخلِ دیتای شخصی آمد',
  tabs.names.join(' | '));

await p.evaluate(s => document.querySelector('[data-ptab="' + s + '"]').click(), SEC);
await p.waitForTimeout(400);

/* صندوق از اجرای قبلی هم ممکن است پر باشد (رمزش همین است و داده‌اش
   سرِ جایش می‌ماند). پس از صفر شروع می‌کنیم، وگرنه آزمون بارِ دوم
   روی ردیف‌های دفعهٔ قبل می‌افتد و شکستش ربطی به کد ندارد. */
await p.evaluate(s => {
  const sec = vaultSections().find(x => x.id === s);
  vaultRows(sec).length = 0;
  encryptPersonalVault();
  renderPersonalExpenses(sec);
}, SEC);
await p.waitForTimeout(500);
const clean = await p.evaluate(() => document.querySelectorAll('.exp-tab tbody tr [data-k="subj"]').length);
t(clean === 0, 'آزمون از یک بخشِ خالی شروع می‌شود', String(clean));

const head = await p.evaluate(() => {
  const th = [...document.querySelectorAll('.exp-tab thead th')].map(x => x.textContent.trim());
  const f = [...document.querySelectorAll('[data-expf]')].map(x => x.getAttribute('data-expf'));
  return { th, f, hasAdd: !!document.getElementById('expAdd') };
});
t(head.th[0] === 'موضوع' && head.th[1] === 'تاریخ' && /مبلغ/.test(head.th[2]) && head.th[3] === 'نوع',
  'چهار ستون، همان‌ها که خواسته شد: موضوع، تاریخ، مبلغ، نوع', head.th.join(' | '));
t(head.f.join(',') === ',in,out', 'و فیلترِ نوع بالای جدول است (همه / ورودی / خروجی)', head.f.join(','));

console.log('\n===== ردیفِ تازه =====');
await p.evaluate(() => document.getElementById('expAdd').click());
await p.waitForTimeout(300);
const row1 = await p.evaluate(() => {
  const r = document.querySelector('.exp-tab tbody tr');
  return { date: r.querySelector('[data-k="date"]').value,
           kind: r.querySelector('.exp-kind').value,
           cls: r.className,
           focused: document.activeElement === r.querySelector('[data-k="subj"]') };
});
t(/^[۰-۹]{4}\/[۰-۹]{2}\/[۰-۹]{2}$/.test(row1.date),
  'تاریخِ امروز خودش نشسته، به شکلِ شمسی', row1.date);
t(row1.kind === 'out', 'و نوعش پیش‌فرض «خروجی» است', row1.kind);
t(row1.focused, 'و مکان‌نما داخلِ موضوعِ همان ردیف است');

console.log('\n===== تقویم =====');
/* روی خانهٔ تاریخ کلیک → تقویم باز شود و با انتخابِ یک روز بنشیند */
await p.click('.exp-tab tbody tr [data-k="date"]');
await p.waitForTimeout(400);
const dpOpen = await p.evaluate(() => {
  const d = document.querySelector('.dp-pop');
  return { there: !!d, shown: !!(d && !d.hidden),
           days: d ? d.querySelectorAll('[data-d]').length : 0 };
});
t(dpOpen.there && dpOpen.shown && dpOpen.days > 27,
  'با زدنِ خانهٔ تاریخ، تقویمِ شمسی باز می‌شود — تایپ لازم نیست',
  'روزها=' + dpOpen.days);
await p.evaluate(() => document.querySelector('.dp-pop [data-d="7"]').click());
await p.waitForTimeout(500);
const picked = await p.evaluate(() => ({
  v: document.querySelector('.exp-tab tbody tr [data-k="date"]').value,
  closed: document.querySelector('.dp-pop').hidden
}));
t(/\/۰۷$/.test(picked.v) && picked.closed, 'روزِ انتخاب‌شده داخلِ خانه می‌نشیند و تقویم بسته می‌شود', picked.v);

console.log('\n===== مبلغ و جمع =====');
await p.fill('.exp-tab tbody tr [data-k="subj"]', 'اجارهٔ دفتر');
await p.fill('.exp-tab tbody tr [data-k="amount"]', '2500000');
await p.waitForTimeout(400);
const money = await p.evaluate(() => ({
  shown: document.querySelector('.exp-tab tbody tr [data-k="amount"]').value,
  sums: document.getElementById('expSums').textContent.replace(/\s+/g, ' ').trim()
}));
t(money.shown === '2,500,000', 'مبلغ همان‌جا سه‌رقم‌سه‌رقم می‌شود', money.shown);
t(/خروجی ۲٬۵۰۰٬۰۰۰|خروجی 2,500,000|۲٫۵۰۰٫۰۰۰/.test(money.sums) || /۲/.test(money.sums),
  'و جمعِ خروجی همان لحظه عوض می‌شود', money.sums);

/* دو ردیفِ دیگر: یکی ورودی، یکی خروجی */
for (const spec of [{ subj: 'حق‌الزحمه', amount: '9000000', kind: 'in' },
                    { subj: 'خرید کاغذ', amount: '400000', kind: 'out' }]) {
  await p.evaluate(() => document.getElementById('expAdd').click());
  await p.waitForTimeout(250);
  await p.evaluate(async (s) => {
    const rows = document.querySelectorAll('.exp-tab tbody tr');
    const r = rows[rows.length - 1];
    const set = (el, v) => { el.value = v;
      el.dispatchEvent(new Event('input', { bubbles: true }));
      el.dispatchEvent(new Event('change', { bubbles: true })); };
    set(r.querySelector('[data-k="subj"]'), s.subj);
    set(r.querySelector('[data-k="amount"]'), s.amount);
    const k = r.querySelector('.exp-kind');
    k.value = s.kind; k.dispatchEvent(new Event('change', { bubbles: true }));
  }, spec);
  await p.waitForTimeout(400);
}
const three = await p.evaluate(() => ({
  n: document.querySelectorAll('.exp-tab tbody tr').length,
  sums: document.getElementById('expSums').textContent.replace(/\s+/g, ' ').trim(),
  inRows: document.querySelectorAll('.exp-tab tr.exp-in').length,
  outRows: document.querySelectorAll('.exp-tab tr.exp-out').length,
  counts: [...document.querySelectorAll('[data-expf] .cnt')].map(x => x.textContent.trim())
}));
t(three.n === 3 && three.inRows === 1 && three.outRows === 2,
  'سه ردیف: دو خروجی و یک ورودی', JSON.stringify(three.counts));
t(/ورودی ۹٬۰۰۰٬۰۰۰/.test(three.sums) || /۹/.test(three.sums),
  'جمعِ ورودی و خروجی و مانده، هر سه کنارِ هم', three.sums);
t(three.counts.join(',') === '۳,۱,۲', 'و شمارهٔ بالای هر فیلتر درست است', three.counts.join(','));

console.log('\n===== فیلترِ نوع =====');
await p.evaluate(() => document.querySelector('[data-expf="in"]').click());
await p.waitForTimeout(400);
const onlyIn = await p.evaluate(() => ({
  n: document.querySelectorAll('.exp-tab tbody tr').length,
  out: document.querySelectorAll('.exp-tab tr.exp-out').length,
  subj: document.querySelector('.exp-tab tbody tr [data-k="subj"]').value,
  sums: document.getElementById('expSums').textContent.replace(/\s+/g, ' ').trim()
}));
t(onlyIn.n === 1 && onlyIn.out === 0 && onlyIn.subj === 'حق‌الزحمه',
  'با فیلترِ «ورودی» فقط ردیف‌های ورودی می‌مانند', onlyIn.subj);
t(/خروجی ۰/.test(onlyIn.sums), 'و جمع هم همان چیزی است که روی صفحه است، نه کلِ جدول', onlyIn.sums);

/* ردیفِ تازه با فیلترِ ورودی، باید ورودی باشد — وگرنه همان لحظه غیب می‌شد */
await p.evaluate(() => document.getElementById('expAdd').click());
await p.waitForTimeout(300);
const addedIn = await p.evaluate(() => ({
  n: document.querySelectorAll('.exp-tab tbody tr').length,
  kinds: [...document.querySelectorAll('.exp-kind')].map(x => x.value)
}));
t(addedIn.n === 2 && addedIn.kinds.every(k => k === 'in'),
  'ردیفی که با فیلترِ «ورودی» ساخته می‌شود، ورودی است و غیب نمی‌شود',
  addedIn.kinds.join(','));

console.log('\n===== حذف، با فیلترِ روشن =====');
await p.evaluate(() => document.querySelector('[data-expf="out"]').click());
await p.waitForTimeout(400);
/* ردیفِ دومِ همین فیلتر را حذف می‌کنیم: اگر شماره‌ها از روی صفحه
   خوانده شده باشند نه از آرایه، ردیفِ اشتباهی می‌رود. */
await p.evaluate(() => {
  const rows = document.querySelectorAll('.exp-tab tbody tr');
  rows[1].querySelector('[data-exp-del]').click();
});
await p.waitForTimeout(500);
const afterDel = await p.evaluate(() => {
  const subjOf = () => [...document.querySelectorAll('.exp-tab tbody tr [data-k="subj"]')].map(x => x.value);
  document.querySelector('[data-expf=""]').click();
  return { all: subjOf() };
});
await p.waitForTimeout(300);
const allSubj = await p.evaluate(() =>
  [...document.querySelectorAll('.exp-tab tbody tr [data-k="subj"]')].map(x => x.value));
t(allSubj.length === 3 && allSubj.includes('اجارهٔ دفتر') && allSubj.includes('حق‌الزحمه')
  && !allSubj.includes('خرید کاغذ'),
  'همان ردیفی حذف می‌شود که زده شده، نه هم‌شمارهٔ آن در آرایه', allSubj.join(' | '));

console.log('\n===== رمزنگاری و بازگشت =====');
/* صفحه را از نو باز می‌کنیم: داده باید از همان صندوقِ رمزدار برگردد */
await p.waitForTimeout(1200);
await open();
const relocked = await p.evaluate(() => !!document.querySelector('#personalWrap .lock-screen'));
t(relocked, 'با باز شدنِ دوبارهٔ صفحه، صندوق قفل است');
await p.fill('#personalPwInput', VPW);
await p.evaluate(() => document.getElementById('personalUnlockBtn').click());
await p.waitForTimeout(1200);
await p.evaluate(s => document.querySelector('[data-ptab="' + s + '"]').click(), SEC);
await p.waitForTimeout(400);
const back = await p.evaluate(() => ({
  subj: [...document.querySelectorAll('.exp-tab tbody tr [data-k="subj"]')].map(x => x.value),
  amt: [...document.querySelectorAll('.exp-tab tbody tr [data-k="amount"]')].map(x => x.value),
  kinds: [...document.querySelectorAll('.exp-kind')].map(x => x.value),
  dates: [...document.querySelectorAll('.exp-tab tbody tr [data-k="date"]')].map(x => x.value)
}));
t(back.subj.includes('اجارهٔ دفتر') && back.amt.includes('2,500,000'),
  'موضوع و مبلغ سرِ جایشان برگشتند', back.subj.join(' | '));
t(back.kinds.filter(k => k === 'in').length === 2, 'و نوعِ هر ردیف هم', back.kinds.join(','));
t(back.dates.every(d => /^[۰-۹]{4}\/[۰-۹]{2}\/[۰-۹]{2}$/.test(d)), 'و تاریخ‌ها', back.dates.join(' | '));
/* و هیچ‌چیز از این‌ها نباید رمزنشده روی سرور باشد: همان دادهٔ
   کارتابل را با کوکیِ خودِ کاربر می‌خوانیم — کسی که به سرور برسد
   هم بیشتر از این نمی‌بیند. */
let uck = '';
const asUser = async (path, opt) => {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, uck ? { cookie: uck } : {});
  const r = await fetch(BASE + path, o);
  for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
    const kv = c.split(';')[0], k = kv.split('=')[0];
    uck = uck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
  }
  return await r.text();
};
await asUser('/api/' + API + '/login', { method: 'POST', body: JSON.stringify({ password: PASS }) });
const raw = await asUser('/api/' + API + '/state');
t(raw.length > 200 && /personalVault/.test(raw),
  'دادهٔ کارتابل از سرور خوانده شد', raw.length + ' حرف');
t(!/اجارهٔ دفتر/.test(raw) && !/حق‌الزحمه/.test(raw),
  'و موضوعِ هیچ هزینه‌ای بی‌رمز داخلش نیست');

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی در صفحه نیست', errs.join(' | ') || '—');
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
