/* زدنِ خبر باید آدم را ببرد همان‌جا — در کارتابل و در پنلِ ادمین.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const DB = process.env.DB_FILE || '';
const P1 = { slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak' };
const P2 = { slug: 'sina', page: '/sina/', api: 'sina', pass: 'sinasinasina' };
const ROOM = 'bellgo';

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
for (const x of [P1, P2])
  await adm(A + '/planners/' + x.slug + '/password',
    { method: 'POST', body: JSON.stringify({ password: x.pass }) });

const b = await launch();
const errs = [];

/* ======================= کارتابل ======================= */
console.log('===== خبرهای کارتابل، هر کدام یک مقصد =====');
const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
p.on('pageerror', e => errs.push('planner: ' + String(e).slice(0, 170)));
p.on('dialog', d => d.accept());

/* یک تلاشِ ناموفقِ ورود، تا خبرِ «رمزِ اشتباه» هم باشد */
await mk()('/api/' + P1.api + '/login', { method: 'POST', body: JSON.stringify({ password: 'ghalat-bellgo' }) });

await p.goto(BASE + P1.page, { waitUntil: 'networkidle' });
await p.evaluate(async a => {
  await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password: a.pass, remember: false }) });
}, { api: P1.api, pass: P1.pass });
await p.goto(BASE + P1.page, { waitUntil: 'networkidle' });
await p.waitForTimeout(2800);

/* یک کارِ عقب‌افتاده و یک یادآورِ روزانه */
await p.evaluate(() => {
  state.bellSeen = [];
  state.tasks = (state.tasks || []).filter(x => !/آزمونِ خبر/.test(x.category || ''));
  state.tasks.push({ category: 'آزمونِ خبر', task: 'کارِ عقب‌افتادهٔ آزمونِ خبر',
    owner: '', deadline: '۱۴۰۴/۰۱/۰۱', status: 'انجام نشده', priority: 'بالا', note: '' });
  state.days = (state.days || []).filter(x => !/یادآورِ آزمونِ خبر/.test((x && x.main) || ''));
  state.days.push({ main: 'یادآورِ آزمونِ خبر', meet: '', company: '', status: 'انجام نشده',
    reminder: { at: Date.now(), fired: false } });
  scheduleSave();
  if (window.BELL) window.BELL.refresh();
});
await p.waitForTimeout(700);

const openBell = async () => {
  await p.evaluate(() => {
    const pop = document.getElementById('bellPopK');
    if (pop && pop.hidden) document.getElementById('bellBtnK').click();
  });
  await p.waitForTimeout(350);
};
await openBell();
const items = await p.evaluate(() =>
  [...document.querySelectorAll('#bellListK .bell-i')].map(x => ({
    txt: x.textContent.replace(/\s+/g, ' ').trim(),
    go: x.classList.contains('go'), bi: x.getAttribute('data-bi'),
    arrow: !!x.querySelector('.ar')
  })));
t(items.length >= 3, 'چند خبر روی صفحه است', String(items.length));
t(items.every(x => x.bi !== null),
  'هر خبر زدنی است — دستِ‌کم برای «خواندم»',
  items.map(x => (x.bi === null ? '✘' : '✔')).join(''));
t(items.filter(x => x.arrow).length && items.some(x => !x.arrow),
  'و پیکان فقط روی آن‌هایی است که جایی برای رفتن دارند',
  items.map(x => (x.arrow ? '›' : '·')).join(''));

const clickItem = async (re) => {
  await openBell();
  const n = await p.evaluate(r => {
    const el = [...document.querySelectorAll('#bellListK .bell-i')]
      .find(x => new RegExp(r).test(x.textContent));
    if (!el) return -1;
    el.click();
    return 1;
  }, re.source);
  await p.waitForTimeout(700);
  return n;
};
const viewNow = () => p.evaluate(() => {
  const v = [...document.querySelectorAll('.view')].find(x => x.classList.contains('active'));
  return v ? v.id : '';
});

await p.evaluate(() => document.querySelector('.navbtn[data-view="dashboard"]').click());
await clickItem(/عقب‌افتاده/);
t(await viewNow() === 'view-checklist', 'زدنِ «کارهای عقب‌افتاده» می‌برد سرِ چک‌لیست',
  await viewNow());

await p.evaluate(() => document.querySelector('.navbtn[data-view="dashboard"]').click());
await clickItem(/یادآور.* برنامهٔ روزانه/);
t(await viewNow() === 'view-daily', 'و «یادآورهای برنامهٔ روزانه» سرِ برنامهٔ روزانه',
  await viewNow());

/* خبرِ محض: زدنش نباید آدم را هیچ‌جا ببرد — فقط خوانده شود. پیش از
   این می‌بردش سرِ تنظیمات، که نه کسی خواسته بود و نه کاری از آن‌جا
   پیش می‌رفت. */
await p.evaluate(() => document.querySelector('.navbtn[data-view="dashboard"]').click());
await openBell();
const stay = await p.evaluate(() => {
  const el = [...document.querySelectorAll('#bellListK .bell-i')]
    .find(x => /رمزِ اشتباه/.test(x.textContent));
  if (!el) return null;
  el.click();
  return { view: ([...document.querySelectorAll('.view')].find(v => v.classList.contains('active')) || {}).id,
           pop: !document.getElementById('bellPopK').hidden,
           seen: !!document.querySelector('#bellListK .bell-i.seen') };
});
t(stay && stay.view === 'view-dashboard',
  'زدنِ خبرِ «رمزِ اشتباه» هیچ‌جا نمی‌بردت — دیگر سرِ تنظیمات نمی‌پرد',
  stay ? stay.view : '—');
t(stay && stay.pop, 'و پنجره باز می‌ماند تا ببینی همان یکی کم‌رنگ شد');
t(stay && stay.seen, 'و خوانده می‌شود');

/* خبری که زده شد، همان یکی دیده‌شده می‌شود — نه همهٔ فهرست */
await openBell();
const seenState = await p.evaluate(() => ({
  seen: document.querySelectorAll('#bellListK .bell-i.seen').length,
  all: document.querySelectorAll('#bellListK .bell-i').length,
  keys: (state.bellSeen || []).length
}));
t(seenState.seen === 3 && seenState.keys === 3,
  'هر خبری که زده شد همان یکی دیده‌شده شد — نه اینکه زدنِ یکی همه را ببرد',
  seenState.seen + ' از ' + seenState.all + '، ' + seenState.keys + ' کلید');

/* ======================= پیامِ گفت‌وگو ======================= */
console.log('\n===== «پیام باز نمی‌شد» — حالا باز می‌شود =====');
await adm(A + '/chat-rooms/' + ROOM, { method: 'DELETE' });
const room = await adm(A + '/chat-rooms', { method: 'POST',
  body: JSON.stringify({ id: ROOM, title: 'گفت‌وگوی آزمونِ خبر', members: [P1.slug, P2.slug] }) });
t(!!room.ok, 'یک گفت‌وگو با هر دو عضو ساخته شد', JSON.stringify(room));

/* سینا پیام می‌دهد؛ سیامک جای دیگری است و باید نخوانده بگیرد */
const q = await b.newPage({ viewport: { width: 1100, height: 800 } });
q.on('pageerror', e => errs.push('sina: ' + String(e).slice(0, 170)));
await q.goto(BASE + P2.page, { waitUntil: 'networkidle' });
await q.evaluate(async a => {
  await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password: a.pass, remember: false }) });
}, { api: P2.api, pass: P2.pass });
await q.goto(BASE + P2.page, { waitUntil: 'networkidle' });
await q.waitForTimeout(2600);

await p.goto(BASE + P1.page, { waitUntil: 'networkidle' });
await p.waitForTimeout(2800);
await p.evaluate(() => {
  const nb = document.querySelector('.navbtn[data-view="chat-' + 'bellgo' + '"]');
  if (nb) nb.click();                   /* یک بار می‌بیندش تا شمارنده صفر شود */
});
await p.waitForTimeout(900);
await p.evaluate(() => document.querySelector('.navbtn[data-view="dashboard"]').click());
await p.waitForTimeout(400);

await q.evaluate(async (a) => {
  await fetch('/api/' + a.api + '/chat/' + a.room + '/send', {
    method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ body: 'سلام، این پیامِ آزمونِ خبر است.' })
  });
}, { api: P2.api, room: ROOM });
await p.waitForTimeout(8000);           /* تا نوبتِ بعدیِ خبرگیری */

const unread = await p.evaluate(() => Number(window.CHAT_UNREAD || 0));
t(unread >= 1, 'سیامک یک پیامِ نخوانده دارد', String(unread));
await openBell();
const chatItem = await p.evaluate(() => {
  const el = [...document.querySelectorAll('#bellListK .bell-i')]
    .find(x => /پیامِ خوانده‌نشده/.test(x.textContent));
  return el ? { txt: el.textContent.replace(/\s+/g, ' ').trim(), go: el.classList.contains('go') } : null;
});
t(chatItem && chatItem.go, 'زنگوله خبرش را دارد و پیکانِ رفتن دارد',
  chatItem ? chatItem.txt : '—');
await clickItem(/پیامِ خوانده‌نشده/);
const landed = await p.evaluate(r => {
  const sec = document.getElementById('view-chat-' + r);
  const log = sec ? sec.querySelector('.ch-log') : null;
  return { active: !!(sec && sec.classList.contains('active')),
           txt: log ? log.textContent.replace(/\s+/g, ' ').trim() : '',
           unread: Number(window.CHAT_UNREAD || 0) };
}, ROOM);
t(landed.active, 'با زدنش خودِ گفت‌وگو باز می‌شود — همین نمی‌شد');
t(/آزمونِ خبر/.test(landed.txt), 'و پیام جلوِ چشم است', landed.txt.slice(-70));
t(landed.unread === 0, 'و نخوانده صفر می‌شود', String(landed.unread));

/* تمیزکاری */
await p.evaluate(() => {
  state.tasks = (state.tasks || []).filter(x => !/آزمونِ خبر/.test(x.category || ''));
  state.days = (state.days || []).filter(x => !/یادآورِ آزمونِ خبر/.test((x && x.main) || ''));
  state.bellSeen = [];
  scheduleSave();
});
await p.waitForTimeout(1600);
await q.close();
await p.close();
await adm(A + '/chat-rooms/' + ROOM, { method: 'DELETE' });

/* ======================= پنلِ ادمین ======================= */
console.log('\n===== پیامِ پشتیبانی در پنلِ ادمین =====');
if (DB) {
  const { DatabaseSync } = await import('node:sqlite');
  const db = new DatabaseSync(DB);
  db.prepare("DELETE FROM support_msgs WHERE text LIKE ?").run('%آزمونِ خبر%');
  db.prepare('DELETE FROM settings WHERE k=?').run('msgSeen:admin');
  const ins = db.prepare(
    'INSERT INTO support_msgs(created,platform,chat_id,name,phone,dir,text) VALUES(?,?,?,?,?,?,?)');
  ins.run(Date.now() - 60000, 'sltg', '99001', 'مشتریِ آزمون', '09120000000', 'in', 'سلام، آزمونِ خبر ۱');
  ins.run(Date.now() - 30000, 'sltg', '99001', 'مشتریِ آزمون', '09120000000', 'in', 'جواب؟ آزمونِ خبر ۲');

  const pay = await adm(A + '/planners');
  t(pay.msgNews && Number(pay.msgNews.n) === 2,
    'سرور می‌گوید دو پیامِ خوانده‌نشده هست', JSON.stringify(pay.msgNews));

  const a = await b.newPage({ viewport: { width: 1360, height: 950 } });
  a.on('pageerror', e => errs.push('admin: ' + String(e).slice(0, 170)));
  a.on('dialog', d => d.accept());
  await a.goto(BASE + '/login', { waitUntil: 'domcontentloaded' });
  await a.evaluate(async x => {
    await fetch('/api/admin.planer/signin', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user: x.u, password: x.p }) });
    try { localStorage.removeItem('sl-admin-bell-seen'); } catch (e) { }
  }, { u: AUSER, p: APASS });
  await a.goto(BASE + '/login', { waitUntil: 'networkidle' });
  await a.waitForTimeout(2400);

  const badge = await a.evaluate(() => {
    const el = document.querySelector('.tabs button[data-tab="msgs"] .tab-n');
    return el ? el.textContent.trim() : '';
  });
  t(badge === '۲', 'سربرگِ «پیام‌ها» نشانِ نخوانده دارد', badge || '—');

  await a.evaluate(() => document.getElementById('bellBtn').click());
  await a.waitForTimeout(400);
  const aItems = await a.evaluate(() =>
    [...document.querySelectorAll('#bellList .bell-item')].map(x => ({
      txt: x.textContent.replace(/\s+/g, ' ').trim(),
      go: x.classList.contains('b-go'), bi: x.getAttribute('data-bi')
    })));
  const msgIt = aItems.find(x => /پیامِ تازهٔ پشتیبانی/.test(x.txt));
  t(!!msgIt, 'خبرِ «پیامِ تازهٔ پشتیبانی» در زنگولهٔ ادمین هست',
    msgIt ? msgIt.txt : aItems.map(x => x.txt.slice(0, 28)).join(' || '));
  t(msgIt && /۲/.test(msgIt.txt), 'با شمارِ درست');
  t(aItems.every(x => x.bi !== null) && aItems.filter(x => x.go).length >= 3,
    'و خبرهای ادمین هم همه زدنی‌اند، و چندتایشان جایی برای رفتن دارند',
    aItems.filter(x => x.go).length + ' از ' + aItems.length);

  await a.evaluate(() => {
    const el = [...document.querySelectorAll('#bellList .bell-item')]
      .find(x => /پیامِ تازهٔ پشتیبانی/.test(x.textContent));
    if (el) el.click();
  });
  await a.waitForTimeout(1500);
  const after = await a.evaluate(() => ({
    tab: !document.getElementById('tab-msgs').hidden,
    txt: (document.getElementById('msgBody') || {}).textContent || '',
    badge: !!document.querySelector('.tabs button[data-tab="msgs"] .tab-n'),
    pop: !!(document.getElementById('bellPop') || {}).hidden
  }));
  t(after.tab, 'با زدنش تبِ «پیام‌ها» باز می‌شود — همین خواسته شده بود');
  t(/آزمونِ خبر/.test(after.txt), 'و خودِ پیام روی صفحه است',
    after.txt.replace(/\s+/g, ' ').slice(0, 80));
  t(after.pop, 'و پنجرهٔ زنگوله بسته می‌شود');
  t(!after.badge, 'نشانِ نخوانده هم خاموش شد');

  const pay2 = await adm(A + '/planners');
  t(pay2.msgNews && Number(pay2.msgNews.n) === 0,
    'و سمتِ سرور هم «خوانده» ثبت شد', JSON.stringify(pay2.msgNews));

  /* یک خبرِ دیگر: کلیدِ اضطراری → تبِ کلیدها */
  await a.evaluate(() => document.getElementById('bellBtn').click());
  await a.waitForTimeout(350);
  const hasEscrow = await a.evaluate(() => {
    const el = [...document.querySelectorAll('#bellList .bell-item')]
      .find(x => /کلیدِ اضطراری/.test(x.textContent));
    if (!el) return false;
    el.click();
    return true;
  });
  if (hasEscrow) {
    await a.waitForTimeout(900);
    const keys = await a.evaluate(() => !document.getElementById('tab-keys').hidden);
    t(keys, 'و «کلیدِ اضطراری گذاشته نشده» می‌برد سرِ تبِ کلیدها');
  } else {
    t(true, 'کلیدِ اضطراری این‌جا گذاشته شده بود، پس خبری نداشت');
  }

  db.prepare("DELETE FROM support_msgs WHERE text LIKE ?").run('%آزمونِ خبر%');
  await a.close();
} else {
  console.log('   —   DB_FILE داده نشده، بخشِ پیام‌های ادمین رد شد');
}

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نبود', errs.join(' | ') || '—');
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
