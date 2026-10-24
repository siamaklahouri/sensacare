/* اقساط، سه‌گونه: وام، چک، و خریدِ اقساطیِ متفرقه — به‌علاوهٔ یادآورِ
   دو روز پیش از سررسید، که بیرونِ صندوق هم کار می‌کند.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const SLUG = 'sina', API = 'sina', PASS = 'sinasinasina';
const SEC = 'inst';
const VPW = 'vault1234';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

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

const b = await launch();
const errs = [];
const p = await b.newPage({ viewport: { width: 1280, height: 980 } });
p.on('pageerror', e => errs.push(String(e).slice(0, 170)));
p.on('dialog', d => d.accept());

const openPersonal = async () => {
  await p.goto(BASE + '/' + SLUG + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(2300);
  await p.evaluate(() => {
    const nb = [...document.querySelectorAll('.navbtn')].find(x => x.dataset.view === 'personal');
    if (nb) nb.click();
  });
  await p.waitForTimeout(400);
};
const unlock = async () => {
  const fresh = await p.evaluate(() => !!document.getElementById('personalPwInput2'));
  await p.fill('#personalPwInput', VPW);
  if (fresh) await p.fill('#personalPwInput2', VPW);
  await p.evaluate(() => document.getElementById('personalUnlockBtn').click());
  await p.waitForTimeout(1300);
  await p.evaluate(s => {
    const tb = document.querySelector('[data-ptab="' + s + '"]');
    if (tb) tb.click();
  }, SEC);
  await p.waitForTimeout(400);
};

await p.goto(BASE + '/' + SLUG + '/', { waitUntil: 'networkidle' });
await p.evaluate(async (a) => {
  await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password: a.pass, remember: false }) });
}, { api: API, pass: PASS });
await openPersonal();
await unlock();

/* صندوق از اجرای قبلی هم ممکن است پر باشد. از صفر شروع می‌کنیم،
   وگرنه آزمونِ بارِ دوم روی ردیف‌های دفعهٔ قبل می‌افتد. */
await p.evaluate(s => {
  const sec = vaultSections().find(x => x.id === s);
  vaultRows(sec).length = 0;
  state.bellSeen = [];
  encryptPersonalVault();
  renderPersonalInstallments();
}, SEC);
await p.waitForTimeout(600);

console.log('===== سه فرمِ افزودن =====');
const tabs = await p.evaluate(() =>
  [...document.querySelectorAll('[data-iadd]')].map(x => ({
    k: x.getAttribute('data-iadd'), txt: x.textContent.replace(/\s+/g, ' ').trim(),
    on: x.classList.contains('active')
  })));
t(tabs.map(x => x.k).join(',') === 'loan,cheque,misc',
  'سه سربرگ بالای فرمِ افزودن: وام، چک، متفرقه', tabs.map(x => x.k).join(','));
t(/دیجی/.test((tabs.find(x => x.k === 'misc') || {}).txt || ''),
  'و سربرگِ متفرقه همان مثالی را می‌زند که خواسته شد (دیجی‌کالا / اسنپ)',
  (tabs.find(x => x.k === 'misc') || {}).txt);
t((tabs.find(x => x.on) || {}).k === 'loan', 'پیش‌فرض همان فرمِ وام است، مثلِ قبل');
const loanFields = await p.evaluate(() => ['instTitle', 'instPrincipal', 'instCount', 'instPercent',
  'instDay', 'instMonth', 'instYear', 'addInstallmentBtn'].filter(i => !document.getElementById(i)));
t(loanFields.length === 0, 'فرمِ وام همان خانه‌های قبلی را دارد — چیزی از دست نرفته', loanFields.join(','));

/* ---------- تاریخ‌های آزمون، از خودِ تقویمِ صفحه ---------- */
const D = await p.evaluate(() => {
  const t0 = todayJalali();
  const f = x => DatePick.fmt(x.y, x.m, x.d);
  const p5 = jalaliPlusDays(t0.y, t0.m, t0.d, 5);
  const p1 = jalaliPlusDays(t0.y, t0.m, t0.d, 1);
  return { today: f(t0), tomorrow: f(p1), far: f(p5),
           past: f({ y: t0.y - 1, m: t0.m, d: t0.d }),
           raw: { y: t0.y, m: t0.m, d: t0.d } };
});

console.log('\n===== چک =====');
await p.evaluate(() => document.querySelector('[data-iadd="cheque"]').click());
await p.waitForTimeout(300);
const chqForm = await p.evaluate(() => {
  const g = i => document.getElementById(i);
  return { has: ['chqTitle', 'chqAmount', 'chqDate', 'addChequeBtn'].filter(i => !g(i)),
           date: !!(g('chqDate') && g('chqDate').hasAttribute('data-date')),
           ph: g('chqTitle') ? g('chqTitle').placeholder : '' };
});
t(chqForm.has.length === 0, 'فرمِ چک سه خانه دارد: چک، مبلغ، تاریخ', chqForm.has.join(','));
t(chqForm.date, 'و تاریخِ چک با تقویم انتخاب می‌شود، نه با تایپ');
t(/چک/.test(chqForm.ph), 'خانهٔ اول همان «چک / بابتِ» است', chqForm.ph);

await p.fill('#chqTitle', 'چک ۱۲۳۴۵۶ بانک ملت');
await p.fill('#chqAmount', '8500000');
await p.fill('#chqDate', D.tomorrow);
await p.evaluate(() => document.getElementById('addChequeBtn').click());
await p.waitForTimeout(700);

const chq = await p.evaluate(() => {
  const row = document.querySelector('.chq-table tbody tr');
  return {
    card: !!document.querySelector('.chq-card'),
    cols: [...document.querySelectorAll('.chq-table thead th')].map(x => x.textContent.trim()),
    cells: row ? [...row.querySelectorAll('td')].map(x => x.textContent.replace(/\s+/g, ' ').trim()) : [],
    id: row ? row.id : '',
    stored: JSON.parse(JSON.stringify(vaultRows(vaultSections().find(s => s.id === 'inst'))))
  };
});
t(chq.card, 'چک در کادرِ «چک‌ها» نشست');
t(/چک/.test(chq.cols[0]) && /تاریخ/.test(chq.cols[1]) && /مبلغ/.test(chq.cols[2]),
  'ستون‌ها همان سه چیزی‌اند که خواسته شد', chq.cols.join(' | '));
t(/۱۲۳۴۵۶/.test(chq.cells[0] || ''), 'عنوانِ چک سرِ جایش است', chq.cells[0]);
t((chq.cells[2] || '').indexOf('۸٬۵۰۰٬۰۰۰') >= 0 || /۸.۵۰۰.۰۰۰/.test(chq.cells[2] || ''),
  'مبلغ با رقمِ فارسی و جداکنندهٔ هزارگان', chq.cells[2]);
t(chq.stored.length === 1 && chq.stored[0].kind === 'cheque' && chq.stored[0].count === 1 &&
  Number(chq.stored[0].per) === 8500000,
  'و داخلِ صندوق به شکلِ یک «قسطِ تک» ذخیره شد', JSON.stringify(chq.stored[0]));

const inBox = await p.evaluate(() =>
  [...document.querySelectorAll('.inst-box-grid .inst-next-chip')]
    .map(x => x.textContent.replace(/\s+/g, ' ').trim()));
t(inBox.some(x => /۱۲۳۴۵۶/.test(x) && /چک/.test(x)),
  'چک هم مثلِ قسط در «خلاصهٔ اقساط» می‌آید — همین خواسته شده بود',
  inBox.join(' || '));

console.log('\n===== متفرقه (دیجی‌کالا / اسنپ) =====');
await p.evaluate(() => document.querySelector('[data-iadd="misc"]').click());
await p.waitForTimeout(300);
const mscForm = await p.evaluate(() => ['mscTitle', 'mscPer', 'mscCount', 'mscDate', 'addMiscBtn']
  .filter(i => !document.getElementById(i)));
t(mscForm.length === 0, 'فرمِ متفرقه: عنوان، مبلغ هر قسط، تعداد اقساط، تاریخ', mscForm.join(','));
await p.fill('#mscTitle', 'دیجی‌کالا — یخچال');
await p.fill('#mscPer', '2500000');
await p.fill('#mscCount', '4');
await p.fill('#mscDate', D.far);
await p.evaluate(() => document.getElementById('addMiscBtn').click());
await p.waitForTimeout(700);

const msc = await p.evaluate(() => {
  const cards = [...document.querySelectorAll('.inst-card')].filter(c => !c.classList.contains('chq-card'));
  const c = cards.find(x => /دیجی/.test(x.textContent));
  const rows = c ? [...c.querySelectorAll('tbody tr')] : [];
  const stored = JSON.parse(JSON.stringify(vaultRows(vaultSections().find(s => s.id === 'inst'))))
    .find(x => x.kind === 'misc');
  return { has: !!c, badge: c ? (c.querySelector('.inst-kind-badge') || {}).textContent : '',
           sum: c ? c.querySelector('.inst-summary').textContent.replace(/\s+/g, ' ').trim() : '',
           n: rows.length,
           dates: rows.map(r => r.children[1].textContent.trim()),
           amounts: rows.map(r => r.children[2].textContent.trim()),
           stored };
});
t(msc.has, 'خریدِ اقساطی کارتِ خودش را گرفت');
t(/متفرقه/.test(msc.badge || ''), 'و با برچسبِ «متفرقه» از وام جدا می‌شود', (msc.badge || '').trim());
t(msc.n === 4, 'چهار قسط، همان‌قدر که گفته شد', String(msc.n));
t(/۲٬۵۰۰٬۰۰۰|۲.۵۰۰.۰۰۰/.test(msc.amounts[0] || ''), 'مبلغِ هر قسط همان است که نوشته شد، نه محاسبه‌شده',
  msc.amounts[0]);
t(!/نرخ سود/.test(msc.sum), 'و حرفی از نرخِ سود در کارتش نیست — چون این‌جا سودی حساب نمی‌شود');
t(/کل/.test(msc.sum) && /۱۰٬۰۰۰٬۰۰۰|۱۰.۰۰۰.۰۰۰/.test(msc.sum), 'جمعِ کل = مبلغ × تعداد', msc.sum);
t(new Set(msc.dates).size === 4, 'سررسیدِ هر قسط یک ماه بعد از قسطِ قبلی', msc.dates.join(' · '));
t(msc.stored && Number(msc.stored.per) === 2500000 && msc.stored.count === 4 &&
  msc.stored.paid.length === 4, 'و درست ذخیره شد', JSON.stringify(msc.stored));

console.log('\n===== وام، مثلِ قبل =====');
await p.evaluate(() => document.querySelector('[data-iadd="loan"]').click());
await p.waitForTimeout(300);
await p.fill('#instTitle', 'وام آزمون');
await p.fill('#instPrincipal', '12000000');
await p.fill('#instCount', '12');
await p.fill('#instPercent', '18');
await p.evaluate(() => document.getElementById('addInstallmentBtn').click());
await p.waitForTimeout(700);
const loan = await p.evaluate(() => {
  const c = [...document.querySelectorAll('.inst-card')].find(x => /وام آزمون/.test(x.textContent));
  return { has: !!c, n: c ? c.querySelectorAll('tbody tr').length : 0,
           sum: c ? c.querySelector('.inst-summary').textContent.replace(/\s+/g, ' ').trim() : '' };
});
t(loan.has && loan.n === 12, 'وام هم مثلِ قبل محاسبه و افزوده می‌شود', String(loan.n));
t(/نرخ سود/.test(loan.sum) && /اصل وام/.test(loan.sum), 'و کارتش همان اعدادِ قبلی را می‌گوید');

console.log('\n===== تاریخ‌هایی که بیرونِ صندوق می‌نشینند =====');
const dig = await p.evaluate(() => ({
  due: (state.personalDue || []).slice(),
  blob: JSON.stringify(state.personalDue || [])
}));
t(Array.isArray(dig.due) && dig.due.length === 1 + 4 + 12,
  'برای هر سررسیدِ پرداخت‌نشده یک تاریخ', String(dig.due.length));
t(dig.due.every(x => /^\d{4}\/\d{2}\/\d{2}$/.test(x)),
  'و هیچ‌چیز جز تاریخ بیرون نیست — نه عنوان، نه مبلغ، نه اینکه قسط است یا چک',
  dig.due.slice(0, 3).join(' · '));
t(!/چک|دیجی|وام|۱۲۳۴۵۶|8500000|2500000/.test(dig.blob),
  'نامِ چک و وام و مبلغ‌ها هیچ‌جای بیرونِ صندوق نیستند');

console.log('\n===== یادآورِ دو روز قبل =====');
const near = await p.evaluate(() => {
  const d = window.vaultDueDigest();
  return d ? { n: d.n, soon: d.soon, late: d.late, days: d.days, nearest: d.nearest } : null;
});
t(near && near.days === 2, 'پنجرهٔ یادآور دو روز است', near ? String(near.days) : '—');
t(near && near.soon >= 1, 'چکِ فردا داخلِ یادآور است', near ? 'soon=' + near.soon : '—');
t(near && !near.late, 'و هنوز چیزی عقب‌افتاده نیست', near ? 'late=' + near.late : '—');

/* یک چک برای پنج روز بعد: نباید عددِ یادآور را تکان بدهد */
const far = await p.evaluate(() => {
  const was = window.vaultDueDigest().soon;
  const sec = vaultSections().find(s => s.id === 'inst');
  const t0 = todayJalali(), x = jalaliPlusDays(t0.y, t0.m, t0.d, 5);
  vaultRows(sec).push({ kind: 'cheque', title: 'چک دور', per: 1000, count: 1,
                        startY: x.y, startM: x.m, startD: x.d, paid: [false] });
  encryptPersonalVault();
  renderPersonalInstallments();
  const d = window.vaultDueDigest();
  return { was, now: d ? d.soon : 0 };
});
t(far.now === far.was, 'سررسیدِ پنج روز بعد هنوز خبر نمی‌دهد — یادآور دو روز قبل است، نه هر وقت',
  far.was + ' → ' + far.now);

/* و یک چکِ عقب‌افتاده */
await p.evaluate(() => {
  const sec = vaultSections().find(s => s.id === 'inst');
  const t0 = todayJalali();
  vaultRows(sec).push({ kind: 'cheque', title: 'چک عقب‌افتاده', per: 4000000, count: 1,
                        startY: t0.y - 1, startM: t0.m, startD: t0.d, paid: [false] });
  encryptPersonalVault();
  renderPersonalInstallments();
});
await p.waitForTimeout(600);
const lateD = await p.evaluate(() => window.vaultDueDigest());
t(lateD && lateD.late >= 1, 'چکی که سررسیدش گذشته و پاس نشده، عقب‌افتاده حساب می‌شود',
  lateD ? 'late=' + lateD.late : '—');

console.log('\n===== بنرِ داخلِ دیتای شخصی =====');
const banner = await p.evaluate(() => {
  const bn = document.querySelector('.due-banner');
  return bn ? {
    late: bn.classList.contains('has-late'),
    items: [...bn.querySelectorAll('.db-item')].map(x => x.textContent.replace(/\s+/g, ' ').trim()),
    secs: [...bn.querySelectorAll('.db-item')].map(x => x.getAttribute('data-due-sec'))
  } : null;
});
t(banner && banner.items.length >= 2, 'بنرِ «سررسیدهای نزدیک» بالای دیتای شخصی آمد',
  banner ? String(banner.items.length) : '—');
t(banner && banner.items.some(x => /۱۲۳۴۵۶/.test(x) && /فردا/.test(x)),
  'و این‌جا — که رمز خورده — عنوان و مبلغ و «فردا» را می‌گوید',
  banner ? (banner.items.find(x => /۱۲۳۴۵۶/.test(x)) || '') : '—');
t(banner && banner.items.some(x => /عقب‌افتاده/.test(x)), 'عقب‌افتاده‌ها هم با نشانِ خودشان');
t(banner && banner.late, 'و خودِ بنر هم وقتی عقب‌افتاده‌ای باشد رنگش عوض می‌شود');

/* از بنر، پریدن سرِ خودِ ردیف */
await p.evaluate(() => {
  const it = [...document.querySelectorAll('.db-item')].find(x => /۱۲۳۴۵۶/.test(x.textContent));
  if (it) it.click();
});
await p.waitForTimeout(500);
const jumped = await p.evaluate(() =>
  !!document.querySelector('.chq-table tr.inst-flash') ||
  !!document.querySelector('tr.inst-flash'));
t(jumped, 'با زدنِ هر ردیفِ بنر، همان سررسید در فهرست چشمک می‌زند');

console.log('\n===== زنگوله، وقتی صندوق قفل است =====');
await p.waitForTimeout(2200);          /* تا ذخیرهٔ state برسد */
await p.goto(BASE + '/' + SLUG + '/', { waitUntil: 'networkidle' });
await p.waitForTimeout(2800);
const bell = await p.evaluate(() => {
  const locked = !personalUnlocked;
  const btn = document.getElementById('bellBtnK');
  if (btn) btn.click();
  const its = [...document.querySelectorAll('#bellListK .bell-i')].map(x => ({
    txt: x.textContent.replace(/\s+/g, ' ').trim(),
    go: x.classList.contains('go'), bi: x.getAttribute('data-bi')
  }));
  return { locked, dot: btn ? !!btn.querySelector('.nd') : false, its };
});
const vd = bell.its.find(x => /سررسیدِ دیتای شخصی/.test(x.txt)) || null;
t(bell.locked, 'صندوق بسته است و رمزش را کسی نزده');
t(!!vd, 'ولی زنگوله خبرِ «دیتای شخصی» را دارد', vd ? vd.txt : bell.its.map(x => x.txt).join(' || '));
t(!!bell.dot, 'و شمارنده روشن است');
t(vd && !/۱۲۳۴۵۶|دیجی|وام آزمون/.test(vd.txt),
  'و هیچ‌چیز از محتوای صندوق لو نمی‌دهد — نه عنوان، نه مبلغ', vd ? vd.txt : '—');
t(vd && vd.txt.replace(/\s+/g, ' ').length < 70,
  'و کوتاه است، نه یک بندِ کامل', String(vd ? vd.txt.replace(/\s+/g, ' ').length : 0) + ' نویسه');
t(vd && vd.go, 'و خبر زدنی است — جایی برای رفتن دارد');

await p.evaluate(() => {
  const el = [...document.querySelectorAll('#bellListK .bell-i')].find(x => /سررسیدِ دیتای شخصی/.test(x.textContent));
  if (el) el.click();
});
await p.waitForTimeout(700);
const landed = await p.evaluate(() => ({
  view: !!(document.getElementById('view-personal') || {}).classList &&
        document.getElementById('view-personal').classList.contains('active'),
  lock: !!document.querySelector('#personalWrap .lock-screen'),
  banner: !!document.querySelector('.due-banner')
}));
t(landed.view, 'با زدنِ خبر، صفحهٔ دیتای شخصی باز می‌شود');
t(landed.lock && !landed.banner,
  'ولی اول رمز را می‌خواهد — جزئیات پیش از رمز نشان داده نمی‌شود');

await unlock();
const afterPw = await p.evaluate(() => {
  const bn = document.querySelector('.due-banner');
  return { has: !!bn, txt: bn ? bn.textContent.replace(/\s+/g, ' ').trim() : '' };
});
t(afterPw.has && /۱۲۳۴۵۶/.test(afterPw.txt),
  'و بعد از رمز، همان‌جا می‌گوید چه سررسیدی نزدیک است', afterPw.txt.slice(0, 150));

console.log('\n===== پرداخت‌شده دیگر یادآور نمی‌شود =====');
const beforeN = await p.evaluate(() => (state.personalDue || []).length);
await p.evaluate(() => {
  const btn = document.querySelector('.chq-table tbody tr .inst-pay-toggle');
  if (btn) btn.click();
});
await p.waitForTimeout(800);
const afterPay = await p.evaluate(() => ({
  n: (state.personalDue || []).length,
  dig: window.vaultDueDigest(),
  rowPaid: !!document.querySelector('.chq-table tbody tr.paid')
}));
t(afterPay.rowPaid, 'چکِ پاس‌شده خط می‌خورد');
t(afterPay.n === beforeN - 1, 'و تاریخش از بیرونِ صندوق هم برداشته می‌شود',
  beforeN + ' → ' + afterPay.n);

/* تمیزکاری */
await p.evaluate(() => {
  const sec = vaultSections().find(s => s.id === 'inst');
  vaultRows(sec).length = 0;
  state.bellSeen = [];
  encryptPersonalVault();
});
await p.waitForTimeout(1600);

/* ======================= کارتابلِ IT =======================
   دو قالب داریم (it و fin) و هر کدام نسخهٔ خودش را از توابعِ تقویم
   دارد. بخشِ دیتای شخصی مشترک است، ولی همین «هر کدام نسخهٔ خودش» بود
   که یک بار سرِ اسفند در قالبِ مالی خطا داد — پس هر دو آزموده می‌شوند. */
console.log('\n===== همین‌ها روی کارتابلِ IT =====');
await call('/api/admin.planer/planners/siamak/password',
  { method: 'POST', body: JSON.stringify({ password: 'siamaksiamak' }) });
{
  const q = await b.newPage({ viewport: { width: 1280, height: 980 } });
  const qerr = [];
  q.on('pageerror', e => qerr.push(String(e).slice(0, 170)));
  q.on('dialog', d => d.accept());
  await q.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
  await q.evaluate(async () => {
    await fetch('/api/kartabl/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: 'siamaksiamak', remember: false }) });
  });
  await q.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
  await q.waitForTimeout(2300);
  await q.evaluate(() => {
    const nb = [...document.querySelectorAll('.navbtn')].find(x => x.dataset.view === 'personal');
    if (nb) nb.click();
  });
  await q.waitForTimeout(400);
  const fresh2 = await q.evaluate(() => !!document.getElementById('personalPwInput2'));
  await q.fill('#personalPwInput', VPW);
  if (fresh2) await q.fill('#personalPwInput2', VPW);
  await q.evaluate(() => document.getElementById('personalUnlockBtn').click());
  await q.waitForTimeout(1300);
  await q.evaluate(() => {
    const tb = document.querySelector('[data-ptab="inst"]');
    if (tb) tb.click();
  });
  await q.waitForTimeout(400);
  await q.evaluate(() => {
    const sec = vaultSections().find(x => x.id === 'inst');
    vaultRows(sec).length = 0;
    state.bellSeen = [];
    encryptPersonalVault();
    renderPersonalInstallments();
  });
  await q.waitForTimeout(500);

  const tabs2 = await q.evaluate(() =>
    [...document.querySelectorAll('[data-iadd]')].map(x => x.getAttribute('data-iadd')).join(','));
  t(tabs2 === 'loan,cheque,misc', 'سه سربرگِ افزودن در کارتابلِ IT هم هست', tabs2);

  /* وامِ دوازده‌قسطی: همان حسابی که سرِ اسفند می‌افتاد */
  await q.evaluate(() => document.querySelector('[data-iadd="loan"]').click());
  await q.waitForTimeout(250);
  await q.fill('#instTitle', 'وام آزمون IT');
  await q.fill('#instPrincipal', '24000000');
  await q.fill('#instCount', '12');
  await q.fill('#instPercent', '20');
  await q.evaluate(() => document.getElementById('addInstallmentBtn').click());
  await q.waitForTimeout(700);
  const loan2 = await q.evaluate(() => {
    const c = [...document.querySelectorAll('.inst-card')].find(x => /وام آزمون IT/.test(x.textContent));
    return c ? c.querySelectorAll('tbody tr').length : 0;
  });
  t(loan2 === 12, 'وامِ دوازده‌قسطی — که سررسیدش به اسفند می‌رسد — بی‌خطا محاسبه می‌شود',
    String(loan2));

  await q.evaluate(() => document.querySelector('[data-iadd="cheque"]').click());
  await q.waitForTimeout(250);
  const tom = await q.evaluate(() => {
    const t0 = todayJalali(), x = jalaliPlusDays(t0.y, t0.m, t0.d, 1);
    return DatePick.fmt(x.y, x.m, x.d);
  });
  await q.fill('#chqTitle', 'چک آزمونِ IT');
  await q.fill('#chqAmount', '3000000');
  await q.fill('#chqDate', tom);
  await q.evaluate(() => document.getElementById('addChequeBtn').click());
  await q.waitForTimeout(700);
  const it2 = await q.evaluate(() => ({
    chq: !!document.querySelector('.chq-table tbody tr'),
    banner: !!document.querySelector('.due-banner'),
    bannerTxt: (document.querySelector('.due-banner') || {}).textContent || '',
    dig: window.vaultDueDigest(),
    due: (state.personalDue || []).every(x => /^\d{4}\/\d{2}\/\d{2}$/.test(x))
  }));
  t(it2.chq, 'چک در کارتابلِ IT هم ثبت می‌شود');
  t(it2.banner && /آزمونِ IT/.test(it2.bannerTxt), 'و بنرِ سررسید همان‌جا می‌آید',
    it2.bannerTxt.replace(/\s+/g, ' ').slice(0, 110));
  t(it2.dig && it2.dig.n >= 1 && it2.due,
    'و تاریخ‌های بیرونِ صندوق این‌جا هم فقط تاریخ‌اند',
    it2.dig ? 'n=' + it2.dig.n : '—');

  await q.waitForTimeout(2200);
  await q.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
  await q.waitForTimeout(2800);
  const bell2 = await q.evaluate(() => {
    const btn = document.getElementById('bellBtnK');
    if (btn) btn.click();
    return [...document.querySelectorAll('#bellListK .bell-i')]
      .map(x => x.textContent.replace(/\s+/g, ' ').trim());
  });
  const v2 = bell2.find(x => /دیتای شخصی/.test(x)) || '';
  t(!!v2 && !/آزمونِ IT/.test(v2),
    'زنگولهٔ کارتابلِ IT هم خبر می‌دهد و هیچ‌چیز لو نمی‌دهد', v2 || bell2.join(' || '));

  await q.evaluate(() => {
    const nb = [...document.querySelectorAll('.navbtn')].find(x => x.dataset.view === 'personal');
    if (nb) nb.click();
  });
  await q.waitForTimeout(400);
  await q.fill('#personalPwInput', VPW);
  await q.evaluate(() => document.getElementById('personalUnlockBtn').click());
  await q.waitForTimeout(1300);
  await q.evaluate(() => {
    const sec = vaultSections().find(x => x.id === 'inst');
    vaultRows(sec).length = 0;
    state.bellSeen = [];
    encryptPersonalVault();
  });
  await q.waitForTimeout(1600);
  t(qerr.length === 0, 'و در کارتابلِ IT هم خطای جاوااسکریپتی نبود', qerr.join(' | ') || '—');
  await q.close();
}

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نبود', errs.join(' | ') || '—');
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
