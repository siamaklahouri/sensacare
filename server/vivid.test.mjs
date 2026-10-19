/* پوستهٔ «رنگی» — فعلاً فقط روی کارتابلِ سیامک.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const S = { slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak' };

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const mk = () => { let ck = ''; return async (path, opt) => {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
  const r = await fetch(BASE + path, o);
  for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
    const kv = c.split(';')[0], k = kv.split('=')[0];
    ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
  }
  try { return await r.json(); } catch (e) { return {}; }
}; };
const A = '/api/admin.planer';
const adm = mk();
await adm(A + '/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
await adm(A + '/planners/' + S.slug + '/password',
  { method: 'POST', body: JSON.stringify({ password: S.pass }) });

console.log('===== کدام کارتابل پوسته دارد =====');
const pageOf = async (p) => await (await fetch(BASE + p, { headers: { Host: 'sltech.ir' } })).text();
const mine = await pageOf(S.page);
t(/<body data-skin="vivid">/.test(mine), 'کارتابلِ سیامک با پوستهٔ رنگی سرو می‌شود');
const others = (await adm(A + '/planners')).items || [];
const plain = others.filter(x => x.slug !== S.slug);
let allPlain = true, who = [];
for (const o of plain) {
  const h = await pageOf('/' + o.slug + '/');
  const on = /<body data-skin="vivid">/.test(h);
  if (on) { allPlain = false; who.push(o.slug); }
}
t(allPlain, 'و هیچ کارتابلِ دیگری نگرفتش — همان‌طور که خواسته شد',
  who.length ? who.join(',') : plain.map(x => x.slug).join(',') + ' همه کلاسیک');
t((others.find(x => x.slug === S.slug) || {}).skin === 'vivid',
  'پنلِ ادمین هم همین را می‌گوید');

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];
const p = await b.newPage({ viewport: { width: 1340, height: 900 } });
p.on('pageerror', e => errs.push(String(e).slice(0, 170)));
p.on('dialog', d => d.accept());
await p.goto(BASE + S.page, { waitUntil: 'networkidle' });
await p.evaluate(async a => {
  await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password: a.pass, remember: false }) });
}, { api: S.api, pass: S.pass });
await p.goto(BASE + S.page, { waitUntil: 'networkidle' });
await p.waitForTimeout(2900);

/* چند ردیفِ نمونه با وضعیت‌های مختلف */
await p.evaluate(() => {
  state.tasks = [
    { category: 'زیرساخت', task: 'تست ری‌استور', owner: 'سیامک', deadline: '۵', status: 'انجام شد', priority: 'بالا', note: '' },
    { category: 'شبکه', task: 'به‌روزرسانی سوییچ', owner: 'رضا', deadline: '۱۲', status: 'در حال انجام', priority: 'متوسط', note: '' },
    { category: 'امنیت', task: 'بازبینی دسترسی‌ها', owner: 'سیامک', deadline: '۲۰', status: 'انجام نشده', priority: 'پایین', note: '' }
  ];
  state.days = [
    { createdDate: '۱۴۰۵/۰۷/۲۲', main: 'جلسهٔ شبکه', meet: '', company: '', status: 'انجام شد', doneDate: '۱۴۰۵/۰۷/۲۲' },
    { createdDate: '۱۴۰۵/۰۷/۲۳', main: 'نصب سرور', meet: '', company: '', status: 'در حال انجام', doneDate: '' }
  ];
  scheduleSave(); renderAll(); renderCharts(); renderDaily();
});
await p.waitForTimeout(900);

/* ---------- اندازه‌ها نباید تکان بخورند ---------- */
console.log('\n===== پوسته فقط رنگ است، نه اندازه =====');
const geom = () => p.evaluate(() => {
  const g = (sel, keys) => {
    const el = document.querySelector(sel);
    if (!el) return null;
    const s = getComputedStyle(el), o = {};
    for (const k of keys) o[k] = s[k];
    const r = el.getBoundingClientRect();
    o.w = Math.round(r.width); o.h = Math.round(r.height);
    return o;
  };
  return {
    th: g('#view-checklist thead th', ['padding', 'fontSize']),
    td: g('#checklistBody td', ['padding', 'fontSize']),
    nav: g('.navbtn', ['padding', 'fontSize', 'borderRadius']),
    stat: g('.stat', ['padding', 'borderRadius']),
    panel: g('.panel', ['padding', 'borderRadius']),
    sel: g('#checklistBody select', ['padding', 'fontSize', 'fontWeight']),
    sidebar: g('.sidebar', ['width']),
    topbar: g('.topbar', ['height'])
  };
});
const withSkin = await geom();
await p.evaluate(() => document.body.setAttribute('data-skin', ''));
await p.waitForTimeout(350);
const noSkin = await geom();
const diff = Object.keys(withSkin).filter(k =>
  JSON.stringify(withSkin[k]) !== JSON.stringify(noSkin[k]));
t(diff.length === 0, 'با پوسته و بی پوسته، همهٔ اندازه‌ها یکی‌اند',
  diff.length ? diff.map(k => k + ': ' + JSON.stringify(withSkin[k]) + ' ≠ ' + JSON.stringify(noSkin[k])).join(' | ')
    : Object.keys(withSkin).length + ' عنصر');

/* ---------- ولی رنگ عوض می‌شود ---------- */
console.log('\n===== و واقعاً رنگی‌تر است =====');
const paint = () => p.evaluate(() => {
  const bg = sel => { const el = document.querySelector(sel); return el ? getComputedStyle(el).backgroundImage : ''; };
  const navIc = document.querySelector('.navbtn .ic');
  return {
    body: (getComputedStyle(document.body).backgroundImage.match(/gradient/g) || []).length,
    navActive: bg('.navbtn.active'),
    th: bg('#view-checklist thead th'),
    stat: bg('.stat'),
    panel: bg('.panel'),
    topbarAfter: getComputedStyle(document.querySelector('.topbar'), '::after').backgroundImage,
    icBg: navIc ? getComputedStyle(navIc).backgroundColor : '',
    activeInk: getComputedStyle(document.querySelector('.navbtn.active')).color
  };
});
const off = await paint();
await p.evaluate(() => document.body.setAttribute('data-skin', 'vivid'));
await p.waitForTimeout(350);
const on = await paint();
t(on.body > off.body, 'کاغذِ صفحه چند لایه رنگ بیشتر دارد', off.body + ' → ' + on.body);
t(/gradient/.test(on.navActive) && on.navActive !== off.navActive,
  'بخشِ باز در نوارِ کنار، قرصِ رنگیِ خودش را دارد',
  off.navActive.slice(0, 28) + ' → ' + on.navActive.slice(0, 28));
t(on.activeInk === 'rgb(255, 255, 255)', 'و نوشته‌اش سفید است، پس روی رنگِ پُر خوانا می‌ماند', on.activeInk);
t(/gradient/.test(on.th) && on.th !== off.th, 'سربرگِ جدول ته‌رنگ گرفت',
  off.th.slice(0, 24) + ' → ' + on.th.slice(0, 24));
t(/gradient/.test(on.stat) && /gradient/.test(on.panel), 'کاشی‌ها و کارت‌ها هم');
t(/gradient/.test(on.topbarAfter), 'و زیرِ نوارِ بالا یک نوارِ رنگی هست');
t(on.icBg !== off.icBg, 'آیکن‌های نوارِ کنار هرکدام چیپِ رنگیِ خودشان را دارند',
  off.icBg + ' → ' + on.icBg);

/* ---------- رنگِ وضعیت ---------- */
console.log('\n===== رنگ، به‌معنای وضعیت =====');
const cols = await p.evaluate(() => {
  const rows = [...document.querySelectorAll('#checklistBody tr')];
  const pick = txt => {
    const tr = rows.find(r => {
      const s = r.querySelector('select[data-field="status"]');
      return s && s.value === txt;
    });
    if (!tr) return null;
    const s = tr.querySelector('select[data-field="status"]');
    return { sel: getComputedStyle(s).backgroundColor,
             row: getComputedStyle(tr.querySelector('td')).backgroundColor };
  };
  return { done: pick('انجام شد'), doing: pick('در حال انجام'), todo: pick('انجام نشده') };
});
const num = c => (String(c).match(/[\d.]+/g) || []).map(Number);
const greener = c => { const [r, g, bl] = num(c); return g > r && g > bl; };
const warmer = c => { const [r, g, bl] = num(c); return r > bl && g > bl; };
const bluer = c => { const [r, g, bl] = num(c); return bl > r; };
t(cols.done && greener(cols.done.sel), 'وضعیتِ «انجام شد» سبز است', cols.done && cols.done.sel);
t(cols.doing && bluer(cols.doing.sel), '«در حال انجام» آبی', cols.doing && cols.doing.sel);
t(cols.todo && warmer(cols.todo.sel), '«انجام نشده» کهربایی', cols.todo && cols.todo.sel);
t(cols.done && cols.todo && cols.done.row !== cols.todo.row,
  'و خودِ ردیف هم ته‌رنگِ وضعیتش را می‌گیرد',
  (cols.done && cols.done.row) + ' ≠ ' + (cols.todo && cols.todo.row));

/* متنِ وضعیت نباید بریده شود — یک بار با بولد کردن برید. روی نمای
   باز سنجیده می‌شود، وگرنه عرضِ عنصرِ پنهان صفر است. */
await p.evaluate(() => document.querySelector('.navbtn[data-view="daily"]').click());
await p.waitForTimeout(700);
const fit = await p.evaluate(() => {
  const pickSel = () => [...document.querySelectorAll('#dailyBody select[data-field="status"]')][0];
  const s = pickSel();
  if (!s) return null;
  const on = { w: Math.round(s.getBoundingClientRect().width),
               fw: getComputedStyle(s).fontWeight, fs: getComputedStyle(s).fontSize };
  document.body.setAttribute('data-skin', '');
  const s2 = pickSel();
  const off = { w: Math.round(s2.getBoundingClientRect().width),
                fw: getComputedStyle(s2).fontWeight, fs: getComputedStyle(s2).fontSize };
  document.body.setAttribute('data-skin', 'vivid');
  return { on, off };
});
t(fit && fit.on.w === fit.off.w && fit.on.fw === fit.off.fw && fit.on.fs === fit.off.fs,
  'کشویی‌های وضعیت با پوسته هم‌اندازه و هم‌وزنِ قبل‌اند — متنشان بریده نمی‌شود',
  fit ? JSON.stringify(fit.on) + ' = ' + JSON.stringify(fit.off) : '—');

/* ---------- تمِ شب ---------- */
console.log('\n===== تمِ شب =====');
await p.evaluate(() => { const b2 = document.getElementById('themeBtn'); if (b2) b2.click(); });
await p.waitForTimeout(700);
const night = await p.evaluate(() => ({
  theme: document.documentElement.getAttribute('data-theme'),
  body: (getComputedStyle(document.body).backgroundImage.match(/gradient/g) || []).length,
  activeInk: getComputedStyle(document.querySelector('.navbtn.active')).color,
  th: getComputedStyle(document.querySelector('#view-checklist thead th')).backgroundImage,
  ic: getComputedStyle(document.querySelector('.navbtn .ic')).backgroundColor
}));
t(night.theme === 'dark', 'شب شد', night.theme);
t(night.body > 1 && /gradient/.test(night.th), 'در شب هم رنگ‌ها سرِ جایشان‌اند');
t(night.activeInk === 'rgb(255, 255, 255)', 'و نوشتهٔ بخشِ باز هنوز سفید است', night.activeInk);
t(!/rgba\(0, 0, 0, 0\)/.test(night.ic), 'چیپِ آیکن در شب گم نمی‌شود', night.ic);
await p.evaluate(() => { const b2 = document.getElementById('themeBtn'); if (b2) b2.click(); });
await p.waitForTimeout(500);

/* ---------- خاموش و روشن کردنش از پنل ---------- */
console.log('\n===== سوییچِ پنلِ ادمین =====');
const row = (await adm(A + '/planners')).items.find(x => x.slug === 'ali');
if (row) {
  const onR = await adm(A + '/planners/ali', { method: 'PUT',
    body: JSON.stringify({ name: row.name, user: row.user, skin: 'vivid' }) });
  t(!onR.error, 'ادمین می‌تواند پوسته را برای کارتابلِ دیگری هم روشن کند', onR.error);
  const h = await pageOf('/ali/');
  t(/<body data-skin="vivid">/.test(h), 'و همان لحظه روی صفحه‌اش می‌نشیند');
  const junk = await adm(A + '/planners/ali', { method: 'PUT',
    body: JSON.stringify({ name: row.name, user: row.user, skin: 'rainbow' }) });
  t(!!junk.error, 'ولی ظاهرِ ناشناس پذیرفته نمی‌شود', junk.error);
  await adm(A + '/planners/ali', { method: 'PUT',
    body: JSON.stringify({ name: row.name, user: row.user, skin: '' }) });
  const h2 = await pageOf('/ali/');
  /* با تگ می‌سنجیم، نه با خودِ رشته: شیوه‌نامهٔ پوسته داخلِ همین صفحه
     است و هر قاعده‌اش با body[data-skin="vivid"] شروع می‌شود. */
  t(!/<body data-skin="vivid">/.test(h2) && /<body data-skin="">/.test(h2),
    'و با «کلاسیک» دوباره برمی‌گردد به حالتِ قبل',
    (h2.match(/<body[^>]*>/) || [])[0]);
}

await p.evaluate(() => { state.tasks = []; state.days = []; scheduleSave(); });
await p.waitForTimeout(1500);
t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نبود', errs.join(' | ') || '—');
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
