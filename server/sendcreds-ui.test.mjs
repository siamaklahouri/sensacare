/* پنجرهٔ «ارسال مشخصات» در پنلِ ادمین — از دکمه تا پیامی که واقعاً
   می‌رود. مهم‌ترین سنجه همین آخری است: پیش‌نمایشی که ادمین می‌بیند
   باید مو‌به‌مو همان چیزی باشد که به بله رفته.

   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید، با:
     BALE_BASE=http://127.0.0.1:8913 */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
import { createServer } from 'node:http';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const PORT = Number(process.env.VS_BALE_PORT || 8913);
const TOKEN = '999999:TESTTESTTESTTESTTESTTEST';
const SLUG = 'sina', PASS = 'sinasinasina', CHAT = '550011';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

let seen = [];
const stub = createServer((req, res) => {
  let b = ''; req.on('data', c => { b += c; });
  req.on('end', () => {
    try { seen.push(JSON.parse(b)); } catch (e) { seen.push({}); }
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true, result: { message_id: 1 } }));
  });
});
await new Promise(r => stub.listen(PORT, '127.0.0.1', r));

/* توکن و رمز را از راهِ API می‌گذاریم؛ کارِ این آزمون خودِ پنجره است. */
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
  await call('/api/admin.planer/signin',
    { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
  await call('/api/admin.planer/site', { method: 'PUT', body: JSON.stringify({ baleToken: TOKEN }) });
  await call('/api/admin.planer/planners/' + SLUG + '/password',
    { method: 'POST', body: JSON.stringify({ password: PASS }) });
}

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];
const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
await p.goto(BASE + '/login', { waitUntil: 'networkidle' });
await p.evaluate(async (a) => {
  await fetch('/api/admin.planer/signin', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ user: a.u, password: a.p }) });
}, { u: AUSER, p: APASS });
await p.goto(BASE + '/login', { waitUntil: 'networkidle' });
await p.waitForTimeout(2000);

console.log('===== دکمه، زیرِ همان کاربر =====');
const btn = await p.evaluate(s => {
  const card = [...document.querySelectorAll('.pcard')]
    .find(c => c.querySelector('[data-edit="' + s + '"]'));
  if (!card) return { miss: true };
  const b = card.querySelector('[data-creds="' + s + '"]');
  if (!b) return { noBtn: true };
  const acts = b.closest('.acts');
  return { txt: b.textContent.trim(), shown: !!b.offsetParent,
           inActs: !!acts,
           /* زیرِ نامِ کاربری، نه جایی دیگر: همان نوارِ دکمه‌های کارت */
           belowUser: card.querySelector('.meta').getBoundingClientRect().bottom
                      <= b.getBoundingClientRect().top + 1 };
}, SLUG);
t(!btn.miss && !btn.noBtn && btn.shown, 'دکمه زیرِ کارتِ همان کاربر هست', btn.txt || JSON.stringify(btn));
t(btn.txt === 'ارسال مشخصات', 'و نامش همان است که خواسته شده', btn.txt);
t(btn.inActs && btn.belowUser, 'و پایینِ مشخصاتِ کاربر نشسته، کنارِ بقیهٔ دکمه‌ها');

console.log('\n===== پنجره =====');
await p.evaluate(s => document.querySelector('[data-creds="' + s + '"]').click(), SLUG);
await p.waitForTimeout(400);
const dlg = await p.evaluate(() => {
  const u = document.getElementById('scUser'), pv = document.getElementById('scPrev');
  return { open: !document.getElementById('ov').hidden,
           user: u && u.value, userLocked: !!(u && u.disabled),
           prev: pv ? pv.textContent : '',
           hasPass: !!document.getElementById('scPass'),
           hasDest: !!document.getElementById('scDest'),
           hasReset: !!document.getElementById('scReset') };
});
t(dlg.open && dlg.hasPass && dlg.hasDest && dlg.hasReset, 'پنجره با هر سه کادر باز می‌شود');
t(dlg.user === 'sina' && dlg.userLocked,
  'نام کاربری خودش پر شده و دست‌نخوردنی است', dlg.user + ' / قفل=' + dlg.userLocked);
t(/سلام دوست عزیز/.test(dlg.prev) && /🔗 https:\/\/sltech\.ir\//.test(dlg.prev) &&
  /👤 یوزر: sina/.test(dlg.prev), 'و پیش‌نمایشِ پیام همان تمپلیت است، با یوزرِ پرشده',
  JSON.stringify(dlg.prev.slice(0, 40)));

await p.fill('#scPass', PASS);
await p.waitForTimeout(200);
const live = await p.evaluate(() => document.getElementById('scPrev').textContent);
t(live.includes('🔑 پسورد: ' + PASS), 'با تایپِ رمز، پیش‌نمایش همان لحظه عوض می‌شود',
  (live.split('\n').find(l => l.includes('پسورد')) || '').trim());

console.log('\n===== فرستادن =====');
seen = [];
await p.fill('#scDest', CHAT);
await p.evaluate(() => document.getElementById('scSend').click());
await p.waitForTimeout(1200);
const after = await p.evaluate(() => ({
  closed: document.getElementById('ov').hidden,
  msg: (document.querySelector('#msg .msg') || {}).textContent || '',
  okMsg: !!document.querySelector('#msg .msg-ok')
}));
t(after.closed && after.okMsg, 'پنجره بسته می‌شود و پیامِ «فرستاده شد» می‌آید',
  after.msg.trim().slice(0, 60));
t(seen.length === 1 && String(seen[0].chat_id) === CHAT, 'یک پیام، به همان مقصد',
  seen.length ? String(seen[0].chat_id) : '—');
t(seen.length === 1 && seen[0].text === live,
  'و متنی که رفته مو‌به‌مو همان پیش‌نمایشی است که ادمین دید',
  seen.length ? (seen[0].text === live ? '' : JSON.stringify(seen[0].text)) : '—');

/* مقصد باید یادِ کارت بماند — پنل بی‌رفرش هم باید نشانش بدهد */
await p.waitForTimeout(600);
const remembered = await p.evaluate(s => {
  const card = [...document.querySelectorAll('.pcard')]
    .find(c => c.querySelector('[data-creds="' + s + '"]'));
  return card ? card.innerText.includes('مقصد بله') && card.innerText.includes('550011') : false;
}, SLUG);
t(remembered === true, 'و مقصدِ بله روی خودِ کارت دیده می‌شود');

console.log('\n===== رمزِ اشتباه =====');
await p.evaluate(s => document.querySelector('[data-creds="' + s + '"]').click(), SLUG);
await p.waitForTimeout(300);
seen = [];
await p.fill('#scPass', 'definitelynotthepassword');
await p.fill('#scDest', CHAT);
await p.evaluate(() => document.getElementById('scSend').click());
await p.waitForTimeout(1000);
const refused = await p.evaluate(() => ({
  open: !document.getElementById('ov').hidden,
  err: (document.getElementById('scErr') || {}).textContent || ''
}));
t(refused.open && /یکی نیست/.test(refused.err),
  'رمزِ اشتباه همان‌جا گفته می‌شود و پنجره بسته نمی‌شود', refused.err.trim().slice(0, 70));
t(seen.length === 0, 'و هیچ پیامی نرفته');

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی در پنل نیست', errs.join(' | ') || '—');
await b.close();
stub.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
