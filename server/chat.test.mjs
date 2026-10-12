/* گفت‌وگوی درون‌برنامه‌ای، از ادمین تا دو مرورگر.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const ROOM = 'chattest';
const P1 = { slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak' };
const P2 = { slug: 'sina',   page: '/sina/',   api: 'sina', pass: 'sinasinasina' };

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

console.log('===== ساختِ اتاق از پنلِ ادمین =====');
const adm = mk();
await adm('/api/admin.planer/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
for (const p of [P1, P2])
  await adm('/api/admin.planer/planners/' + p.slug + '/password',
    { method: 'POST', body: JSON.stringify({ password: p.pass }) });
await adm('/api/admin.planer/chat-rooms/' + ROOM, { method: 'DELETE' });

const bad1 = await adm('/api/admin.planer/chat-rooms',
  { method: 'POST', body: JSON.stringify({ id: ROOM, title: 'گفت‌وگوی آزمون' }) });
t(!!bad1.error && /گروه|کارتابل/.test(bad1.error),
  'اتاقِ بی‌عضو ساخته نمی‌شود — گفت‌وگویی که کسی داخلش نیست، گفت‌وگو نیست', bad1.error);

const made = await adm('/api/admin.planer/chat-rooms', {
  method: 'POST',
  body: JSON.stringify({ id: ROOM, title: 'گفت‌وگوی آزمون', members: [P1.slug, P2.slug] })
});
t(made.ok && made.created, 'اتاق ساخته شد', JSON.stringify(made));
const list = await adm('/api/admin.planer/chat-rooms');
t((list.items || []).some(x => x.id === ROOM), 'و در فهرستِ پنل هست',
  (list.items || []).map(x => x.id).join(','));

console.log('\n===== دسترسی =====');
const out = mk();
await out('/api/' + P1.api + '/login', { method: 'POST', body: JSON.stringify({ password: P1.pass }) });
/* کسی که عضو نیست نباید حتی بتواند بخواند. عضویت از سرور خوانده
   می‌شود، نه از چیزی که مرورگر ادعا می‌کند. */
const stranger = await adm('/api/admin.planer/chat-rooms',
  { method: 'POST', body: JSON.stringify({ id: ROOM + 'x', title: 'اتاقِ دیگران', members: [P2.slug] }) });
t(stranger.ok, 'یک اتاقِ دوم، بی‌حضورِ سیامک');
const denied = await out('/api/' + P1.api + '/chat/' + ROOM + 'x');
t(!!denied.error, 'و سیامک حتی نمی‌تواند بخواندش', denied.error);
const sent = await out('/api/' + P1.api + '/chat/' + ROOM + 'x/send',
  { method: 'POST', body: JSON.stringify({ body: 'سلام' }) });
t(!!sent.error, 'و نمی‌تواند داخلش بنویسد', sent.error);
const empty = await out('/api/' + P1.api + '/chat/' + ROOM + '/send',
  { method: 'POST', body: JSON.stringify({ body: '   ' }) });
t(!!empty.error, 'پیامِ خالی هم فرستاده نمی‌شود', empty.error);

console.log('\n===== اتاقِ گروهِ سازمانی =====');
/* خواستهٔ اصلی همین بود: «برای سازمانی‌ها یک بخش بسازم». با گروه، هر
   کس را به گروه اضافه کنید خودش داخلِ گفت‌وگو می‌آید. */
const org = await adm('/api/admin.planer/orgs',
  { method: 'POST', body: JSON.stringify({ name: 'گروهِ آزمونِ گفت‌وگو', members: [P1.slug, P2.slug] }) });
t(org.ok && org.id, 'گروه ساخته شد', org.id || org.error);
const byOrg = await adm('/api/admin.planer/chat-rooms',
  { method: 'POST', body: JSON.stringify({ id: ROOM + 'org', title: 'گفت‌وگوی گروهی', org: org.id }) });
t(byOrg.ok, 'و اتاقی که به همان گروه وصل است', byOrg.error || '');
for (const p of [P1, P2]) {
  const u = mk();
  await u('/api/' + p.api + '/login', { method: 'POST', body: JSON.stringify({ password: p.pass }) });
  const mine = await u('/api/' + p.api + '/chat');
  const r = (mine.rooms || []).find(x => x.id === ROOM + 'org');
  t(!!r && r.members.length === 2,
    p.slug + ' اتاقِ گروهی را می‌بیند، با هر دو عضوش',
    r ? r.members.join(',') : 'نیامد');
}
/* و کسی که در گروه نیست، نمی‌بیند */
{
  const u = mk();
  await u('/api/reza/login', { method: 'POST', body: JSON.stringify({ password: 'rezarezareza' }) });
  await adm('/api/admin.planer/planners/reza/password',
    { method: 'POST', body: JSON.stringify({ password: 'rezarezareza' }) });
  const u2 = mk();
  await u2('/api/reza/login', { method: 'POST', body: JSON.stringify({ password: 'rezarezareza' }) });
  const mine = await u2('/api/reza/chat');
  t(!(mine.rooms || []).some(x => x.id === ROOM + 'org'),
    'ولی رضا که در گروه نیست، نمی‌بیندش');
}

console.log('\n===== دو مرورگر، یک گفت‌وگو =====');
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];
const openAs = async p => {
  const pg = await b.newPage({ viewport: { width: 1280, height: 960 } });
  pg.on('pageerror', e => errs.push(p.slug + ': ' + String(e).slice(0, 150)));
  await pg.goto(BASE + p.page, { waitUntil: 'networkidle' });
  await pg.evaluate(async ({ a, w }) => {
    await fetch('/api/' + a + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ password: w, remember: false }) });
  }, { a: p.api, w: p.pass });
  await pg.goto(BASE + p.page, { waitUntil: 'networkidle' });
  await pg.waitForTimeout(3500);
  return pg;
};
const a = await openAs(P1), c = await openAs(P2);

const navOk = await a.evaluate(r => {
  const btn = document.querySelector('.navbtn[data-view="chat-' + r + '"]');
  return btn ? { text: btn.textContent.trim(), shown: !!btn.offsetParent } : null;
}, ROOM);
t(navOk && navOk.shown && /گفت‌وگوی آزمون/.test(navOk.text), 'دکمهٔ گفت‌وگو در نوار آمد',
  navOk && navOk.text);
t(await a.evaluate(r => !document.querySelector('.navbtn[data-view="chat-' + r + 'x"]'), ROOM),
  'و اتاقی که عضوش نیست، اصلاً دکمه‌ای ندارد');

const openRoom = async (pg) => {
  await pg.evaluate(r => document.querySelector('.navbtn[data-view="chat-' + r + '"]').click(), ROOM);
  await pg.waitForTimeout(900);
};
await openRoom(a); await openRoom(c);
/* «آمد» کافی نیست، باید «دیده شود»: دکمه‌هایی که بعد از بارِ صفحه
   ساخته می‌شوند شنوندهٔ setupNav را ندارند، پس عوض کردنِ نما کارِ خودِ
   دکمه است. بی این سنجه، همهٔ آزمون‌های بعدی روی یک بخشِ پنهان
   می‌گذشتند و سبز هم می‌شدند. */
t(await a.evaluate(r => {
  const sec = document.getElementById('view-chat-' + r);
  return !!(sec && sec.classList.contains('active') && sec.offsetParent &&
            sec.getBoundingClientRect().height > 100);
}, ROOM), 'و با زدنش، بخش واقعاً باز و دیده می‌شود');
t(await a.evaluate(() => {
  const on = [...document.querySelectorAll('.view.active')];
  return on.length === 1 && on[0].id.indexOf('view-chat-') === 0;
}), 'و فقط همین یکی باز است — بخشِ قبلی بسته شد');

const blank = await a.evaluate(r => {
  const log = document.getElementById('ch-log-' + r);
  return { has: !!log, txt: log ? log.textContent.trim().slice(0, 30) : '' };
}, ROOM);
t(blank.has && /هنوز پیامی نیست/.test(blank.txt), 'اتاقِ خالی همین را می‌گوید', blank.txt);

const say = async (pg, text) => {
  await pg.evaluate(async ({ r, x }) => {
    const sec = document.getElementById('view-chat-' + r);
    sec.querySelector('.ch-in').value = x;
    sec.querySelector('.ch-send').click();
  }, { r: ROOM, x: text });
  await pg.waitForTimeout(900);
};
await say(a, 'سلام سینا، کارِ سرورِ شماره دو تمام شد؟');

const mineNow = await a.evaluate(r => {
  const ms = [...document.querySelectorAll('#ch-log-' + r + ' .ch-m')];
  return ms.map(m => ({ me: m.classList.contains('me'),
                        body: m.querySelector('.bd').textContent,
                        nm: m.querySelector('.nm') ? m.querySelector('.nm').textContent : '',
                        del: !!m.querySelector('[data-chdel]') }));
}, ROOM);
t(mineNow.length === 1 && mineNow[0].me && /کارِ سرور/.test(mineNow[0].body),
  'پیامِ خودم همان‌جا نشست، بی‌آنکه صفحه چیزی بپرسد', JSON.stringify(mineNow[0] || {}));
t(mineNow[0] && mineNow[0].nm === '' && mineNow[0].del,
  'پیامِ خودم نام نمی‌خواهد و دکمهٔ برداشتن دارد');

/* آن یکی باید بی‌آنکه کاری بکند ببیندش — دورِ خبر هر ۵ ثانیه است */
await c.waitForTimeout(6500);
const theirs = await c.evaluate(r => {
  const ms = [...document.querySelectorAll('#ch-log-' + r + ' .ch-m')];
  return ms.map(m => ({ me: m.classList.contains('me'),
                        nm: m.querySelector('.nm') ? m.querySelector('.nm').textContent.trim() : '',
                        del: !!m.querySelector('[data-chdel]'),
                        body: m.querySelector('.bd').textContent }));
}, ROOM);
t(theirs.length === 1 && !theirs[0].me && /کارِ سرور/.test(theirs[0].body),
  'و چند ثانیه بعد، خودش در صفحهٔ سینا پیدا شد', JSON.stringify(theirs[0] || {}));
t(theirs[0] && theirs[0].nm === 'سیامک', 'با نامِ فرستنده، نه شناسهٔ انگلیسی‌اش', theirs[0] && theirs[0].nm);
t(theirs[0] && !theirs[0].del, 'و پیامِ دیگری دکمهٔ برداشتن ندارد');

await say(c, 'آره، نصفِ شب تمام شد.');
await a.waitForTimeout(6500);
const both = await a.evaluate(r => [...document.querySelectorAll('#ch-log-' + r + ' .ch-m')]
  .map(m => (m.classList.contains('me') ? 'من: ' : 'او: ') + m.querySelector('.bd').textContent), ROOM);
t(both.length === 2 && /^او: /.test(both[1]), 'و جوابش هم برگشت — هر دو طرف یک گفت‌وگو را می‌بینند',
  both.join(' | '));
t(await a.evaluate(r => {
  const d = [...document.querySelectorAll('#ch-log-' + r + ' .ch-day')];
  return d.length === 1 && /[۰-۹]/.test(d[0].textContent);
}, ROOM), 'و یک سرخطِ تاریخ دارد، یکی برای هر روز');

console.log('\n===== خبر و صدا =====');
/* سینا اتاق را می‌بندد و می‌رود جای دیگر؛ پیامِ تازه باید شمارنده و
   خبر بدهد، نه اینکه بی‌صدا بیفتد ته صفحه‌ای که باز نیست. */
/* اول اتاق را باز می‌کند (یعنی دیدمش، شمارنده صفر) و بعد می‌رود جای
   دیگر — وگرنه عددِ آزمون به این بند می‌بود که پیش از این چند پیام
   وقتی تب جلوِ چشم نبود رسیده. */
await openRoom(c);
await c.evaluate(() => document.querySelector('.navbtn[data-view="dashboard"]').click());
await c.waitForTimeout(400);
await say(a, 'یک چیزِ دیگر هم بود.');
await c.waitForTimeout(6500);
const alert_ = await c.evaluate(r => {
  const btn = document.querySelector('.navbtn[data-view="chat-' + r + '"]');
  const dot = btn && btn.querySelector('.ch-dot');
  const note = document.querySelector('.chn');
  return { dot: dot ? dot.textContent : '', note: note ? note.textContent.replace(/\s+/g, ' ') : '' };
}, ROOM);
t(alert_.dot === '۱', 'شمارندهٔ نخوانده روی دکمهٔ گفت‌وگو آمد', alert_.dot);
t(/چیزِ دیگر/.test(alert_.note) && /سیامک/.test(alert_.note),
  'و خبرِ گوشهٔ صفحه، متن و فرستنده را می‌گوید', alert_.note.slice(0, 60));

const sound = await c.evaluate(() => {
  /* صدای پیام باید با صدای خبرِ کارها فرق کند. شکلِ موج و نت‌ها را
     می‌سنجیم، نه خودِ صدا را: AudioContext در آزمون اجازهٔ پخش ندارد. */
  const js = [...document.querySelectorAll('script')].map(s => s.src).find(s => /\/chat\.js/.test(s));
  return { js: !!js };
});
t(sound.js, 'فایلِ گفت‌وگو از همان صفحه بار شده');

const tone = await (await fetch(BASE + '/chat.js')).text();
t(/triangle/.test(tone) && /exponentialRampToValueAtTime\(860/.test(tone),
  'و صدایش یک سُرِ رو به بالا است، نه دو نتِ جدا مثل خبرِ کارها');
const shared = await (await fetch(BASE + '/shared.js')).text();
t(/o\.type = "sine"/.test(shared) && !/triangle/.test(shared),
  'که همان صدای بخش‌های مشترک نیست — دو خبر با یک صدا یعنی هر بار باید نگاه کرد');

/* باز کردنِ اتاق یعنی دیدمش */
await openRoom(c);
await c.waitForTimeout(400);
t(await c.evaluate(r => !document.querySelector('.navbtn[data-view="chat-' + r + '"] .ch-dot'), ROOM),
  'و با باز کردنِ اتاق، شمارنده صفر می‌شود');

console.log('\n===== دکمهٔ شناور =====');
/* نوارِ کنار همیشه جلوِ چشم نیست — روی گوشی تا شده و روی صفحهٔ بزرگ
   وقتی آدم پایینِ یک جدولِ بلند است، بالا مانده. */
const fab = await a.evaluate(() => {
  const w = document.getElementById('chFab');
  if (!w) return null;
  const b = w.querySelector('.ch-fab');
  const r = b.getBoundingClientRect(), cs = getComputedStyle(w);
  return { shown: !!b.offsetParent, pos: cs.position,
           left: Math.round(r.left), fromBottom: Math.round(innerHeight - r.bottom),
           w: Math.round(r.width), popShut: w.querySelector('.ch-pop').hidden };
});
t(fab && fab.shown && fab.pos === 'fixed', 'دکمهٔ شناور آمد و با صفحه نمی‌رود',
  fab && fab.pos);
t(fab && fab.left < 40 && fab.fromBottom < 40 && fab.w > 40,
  'و چپِ پایین نشسته — راستِ پایین جای خبرهاست',
  fab && ('چپ=' + fab.left + ' پایین=' + fab.fromBottom + ' قطر=' + fab.w));
t(fab && fab.popShut, 'و فهرستش بسته است تا زده نشود');
/* خبرها هم همین گوشه می‌نشینند — inset-inline-end در صفحهٔ راست‌به‌چپ
   یعنی چپ. اگر بالاتر نروند، روی دکمه می‌افتند. */
const clash = await a.evaluate(() => {
  /* ظرفِ خبر تنبل ساخته می‌شود، پس یکی موقتی می‌سازیم تا خودِ قاعده
     سنجیده شود، نه اینکه سنجه به بختِ «الان خبری هست یا نه» باشد. */
  const b = document.querySelector('#chFab .ch-fab').getBoundingClientRect();
  const out = {};
  for (const cls of ['chn-wrap', 'shn-wrap']) {
    const d = document.createElement('div');
    d.className = cls;
    document.body.appendChild(d);
    out[cls] = Math.round(parseFloat(getComputedStyle(d).bottom) || 0);
    d.remove();
  }
  out.fabTop = Math.round(innerHeight - b.top);
  return out;
});
t(clash['chn-wrap'] >= clash.fabTop && clash['shn-wrap'] >= clash.fabTop,
  'و ستونِ خبرها بالاتر از دکمه می‌نشیند تا رویش نیفتد — هر دو ستون',
  'گفت‌وگو=' + clash['chn-wrap'] + ' کارها=' + clash['shn-wrap'] +
  ' / بالای دکمه=' + clash.fabTop);

const popped = await a.evaluate(() => {
  document.querySelector('#chFab .ch-fab').click();
  const w = document.getElementById('chFab');
  const rows = [...w.querySelectorAll('.ch-pop-row')];
  const pr = w.querySelector('.ch-pop').getBoundingClientRect();
  const br = w.querySelector('.ch-fab').getBoundingClientRect();
  return { open: !w.querySelector('.ch-pop').hidden,
           rooms: rows.map(x => x.querySelector('.nm').textContent.trim()),
           ids: rows.map(x => x.getAttribute('data-chgo')),
           above: pr.bottom <= br.top + 1,
           expanded: w.querySelector('.ch-fab').getAttribute('aria-expanded') };
});
t(popped.open && popped.ids.length >= 1, 'با زدنش، نامِ گروه‌هایش می‌آید',
  popped.rooms.join(' | '));
t(popped.ids.includes(ROOM), 'و همان گفت‌وگوی این کاربر داخلش هست', popped.ids.join(','));
t(popped.above && popped.expanded === 'true', 'فهرست بالای دکمه باز می‌شود، نه زیرِ لبهٔ صفحه');

/* از یک بخشِ دیگر، با همین دکمه سرِ گفت‌وگو */
const jump = await a.evaluate(async r => {
  document.querySelector('.navbtn[data-view="dashboard"]').click();
  document.querySelector('#chFab .ch-fab').click();
  document.querySelector('#chFab [data-chgo="' + r + '"]').click();
  const sec = document.getElementById('view-chat-' + r);
  return { on: !!(sec && sec.classList.contains('active') && sec.offsetParent),
           shut: document.querySelector('#chFab .ch-pop').hidden };
}, ROOM);
t(jump.on, 'زدنِ نامِ گروه، همان گفت‌وگو را باز می‌کند — از هر جای کارتابل');
t(jump.shut, 'و فهرست خودش بسته می‌شود');

/* شمارِ روی دکمه جمعِ نخوانده‌هاست */
await c.evaluate(() => document.querySelector('.navbtn[data-view="dashboard"]').click());
await a.evaluate(() => document.querySelector('.navbtn[data-view="dashboard"]').click());
await say(c, 'یک پیام وقتی سیامک جای دیگری است.');
await a.waitForTimeout(6500);
const badge = await a.evaluate(r => {
  const n = document.querySelector('#chFab .ch-fab .n');
  const row = document.querySelector('#chFab [data-chgo="' + r + '"] .n');
  return { fab: n ? n.textContent : '', row: row ? row.textContent : '(فهرست باز نشده)' };
}, ROOM);
t(badge.fab === '۱', 'شمارِ نخوانده روی خودِ دکمه هم می‌نشیند', badge.fab);
await a.evaluate(r => {
  document.querySelector('#chFab .ch-fab').click();
  document.querySelector('#chFab [data-chgo="' + r + '"]').click();
}, ROOM);
await a.waitForTimeout(400);
t(await a.evaluate(() => !document.querySelector('#chFab .ch-fab .n')),
  'و با باز کردنِ گفت‌وگو صفر می‌شود');

console.log('\n===== برداشتنِ پیام =====');
const before = await a.evaluate(r => document.querySelectorAll('#ch-log-' + r + ' .ch-m').length, ROOM);
await a.evaluate(r => {
  window.confirm = () => true;
  /* همان پیامِ خودم، نه هر پیامی: دکمهٔ برداشتن فقط روی مالِ خودم هست */
  const mine = [...document.querySelectorAll('#ch-log-' + r + ' .ch-m')]
    .find(m => /چیزِ دیگر/.test(m.textContent));
  mine.querySelector('[data-chdel]').click();
}, ROOM);
await a.waitForTimeout(900);
const after = await a.evaluate(r => {
  const ms = [...document.querySelectorAll('#ch-log-' + r + ' .ch-m')];
  return { n: ms.length, still: ms.some(m => /چیزِ دیگر/.test(m.textContent)) };
}, ROOM);
t(after.n === before - 1 && !after.still, 'پیامِ خودم برداشته شد',
  before + ' → ' + after.n);
await c.waitForTimeout(1000);
await openRoom(c);
t(await c.evaluate(r => {
  const ms = [...document.querySelectorAll('#ch-log-' + r + ' .ch-m')];
  return !ms.some(m => /چیزِ دیگر/.test(m.textContent));
}, ROOM), 'و از صفحهٔ آن یکی هم رفت');

console.log('\n===== خطای صفحه =====');
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' // ') || '—');

await adm('/api/admin.planer/chat-rooms/' + ROOM + 'x', { method: 'DELETE' });
await adm('/api/admin.planer/chat-rooms/' + ROOM + 'org', { method: 'DELETE' });
if (org.id) await adm('/api/admin.planer/orgs/' + org.id, { method: 'DELETE' });
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
