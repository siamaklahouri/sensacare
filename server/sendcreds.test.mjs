/* دکمهٔ «ارسال مشخصات» — نام کاربری و رمزِ ورود، با رباتِ بله.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید، با یک خطِ
   بیشتر در فایلِ env:

     BALE_BASE=http://127.0.0.1:8913

   این آزمون خودش یک «بله»ی قلابی روی همان درگاه بالا می‌آورد و
   می‌خواند که سرور چه فرستاده. بی آن خط، سرور سراغِ بلهٔ واقعی
   می‌رود و آزمون — به‌درستی — می‌افتد. */
import { createServer } from 'node:http';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const PORT = Number(process.env.VS_BALE_PORT || 8913);
const DB = process.env.DB_FILE || '';
const TOKEN = '999999:TESTTESTTESTTESTTESTTEST';
const P = { slug: 'sina', api: 'sina', user: 'sina', pass: 'sinasinasina' };
const PHONE = '09121234567';
const PHONE_CHAT = '550011';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* ---- بلهٔ قلابی ---- */
let seen = [];
let reply = { ok: true, result: { message_id: 1 } };
const stub = createServer((req, res) => {
  let b = '';
  req.on('data', c => { b += c; });
  req.on('end', () => {
    let j = {};
    try { j = JSON.parse(b); } catch (e) { }
    seen.push({ url: req.url, body: j });
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(reply));
  });
});
await new Promise(r => stub.listen(PORT, '127.0.0.1', r));

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

/* ---- بی‌توکن، پیامی نمی‌رود ---- */
console.log('===== بی توکنِ بله =====');
await adm(A + '/site', { method: 'PUT', body: JSON.stringify({ baleToken: '-' }) });
seen = [];
const noTok = await adm(A + '/planners/' + P.slug + '/send-creds',
  { method: 'POST', body: JSON.stringify({ password: P.pass, chat: '12345' }) });
t(!!noTok.error && /توکن/.test(noTok.error), 'بی توکنِ بله جلویش گرفته می‌شود', noTok.error);
t(seen.length === 0, 'و هیچ‌چیز فرستاده نشده');
const sNo = await adm(A + '/planners');
t(sNo.baleReady === false, 'پنل هم می‌داند که توکن نیست', String(sNo.baleReady));

await adm(A + '/site', { method: 'PUT', body: JSON.stringify({ baleToken: TOKEN }) });
const sYes = await adm(A + '/planners');
t(sYes.baleReady === true, 'و با توکن، می‌داند که هست', String(sYes.baleReady));

/* رمزِ کارتابل را خودمان می‌گذاریم تا بدانیم چیست */
await adm(A + '/planners/' + P.slug + '/password',
  { method: 'POST', body: JSON.stringify({ password: P.pass }) });

/* ---- رمز ---- */
console.log('\n===== رمز =====');
seen = [];
const empty = await adm(A + '/planners/' + P.slug + '/send-creds',
  { method: 'POST', body: JSON.stringify({ chat: PHONE_CHAT }) });
t(!!empty.error && /رمز/.test(empty.error), 'رمزِ خالی بی‌«رمزِ تازه» قبول نمی‌شود', empty.error);
t(seen.length === 0, 'و پیامی نرفته');

seen = [];
const wrong = await adm(A + '/planners/' + P.slug + '/send-creds',
  { method: 'POST', body: JSON.stringify({ password: 'thisisnotthepassword', chat: PHONE_CHAT }) });
t(!!wrong.error && /یکی نیست/.test(wrong.error),
  'رمزِ اشتباه فرستاده نمی‌شود — پیامی که رمزش کار نکند بی‌فایده است', wrong.error);
t(seen.length === 0, 'و واقعاً چیزی نرفته');
/* و رمزِ کارتابل هم دست نخورده */
const still = await mk()('/api/' + P.api + '/login',
  { method: 'POST', body: JSON.stringify({ password: P.pass }) });
t(!still.error, 'و رمزِ اصلی دست‌نخورده مانده', JSON.stringify(still).slice(0, 60));

seen = [];
const good = await adm(A + '/planners/' + P.slug + '/send-creds',
  { method: 'POST', body: JSON.stringify({ password: P.pass, chat: PHONE_CHAT }) });
t(good.ok === true, 'رمزِ درست پذیرفته می‌شود', JSON.stringify(good));
t(good.password === undefined, 'و چون رمزی گذاشته نشده، رمزی هم برنمی‌گردد');
t(seen.length === 1 && seen[0].url === '/bot' + TOKEN + '/sendMessage',
  'یک پیام، به همان رباتی که توکنش گذاشته شده', seen.length ? seen[0].url : '—');
t(String(seen[0] && seen[0].body.chat_id) === PHONE_CHAT, 'به همان گفتگو',
  String(seen[0] && seen[0].body.chat_id));

/* ---- متنِ پیام، خط به خط ---- */
console.log('\n===== متنِ پیام =====');
const txt = String((seen[0] || {}).body && seen[0].body.text || '');
const want = [
  'سلام دوست عزیز 🌹', '',
  'برای استفاده از سایت پلنر از لینک زیر وارد شو:', '',
  '🔗 https://sltech.ir/', '',
  '👤 یوزر: ' + P.user,
  '🔑 پسورد: ' + P.pass, '',
  '📱💻 سایت هم با گوشی و هم با کامپیوتر قابل استفاده‌ست.', '',
  'موفق باشی 😊'
].join('\n');
t(txt === want, 'متن مو‌به‌مو همان تمپلیت است، با یوزر و پسوردِ پرشده',
  txt === want ? '' : JSON.stringify(txt));
t(/پسورد: /.test(txt) && txt.includes(P.pass), 'رمز داخلش هست');
t(!/undefined|null|\{\{/.test(txt), 'و هیچ جای خالیِ پرنشده‌ای نمانده');

/* ---- رمزِ تازه ---- */
console.log('\n===== رمزِ تازه =====');
seen = [];
const fresh = await adm(A + '/planners/' + P.slug + '/send-creds',
  { method: 'POST', body: JSON.stringify({ reset: true, chat: PHONE_CHAT }) });
t(fresh.ok === true && typeof fresh.password === 'string' && fresh.password.length >= 8,
  'با «رمزِ تازه»، سرور خودش یکی می‌سازد', fresh.password);
t(seen.length === 1 && String(seen[0].body.text).includes(fresh.password),
  'و همان رمزِ تازه داخلِ پیام است');
const logIn = await mk()('/api/' + P.api + '/login',
  { method: 'POST', body: JSON.stringify({ password: fresh.password }) });
t(!logIn.error, 'و با همان رمز واقعاً می‌شود وارد شد — یعنی پیام راست است',
  JSON.stringify(logIn).slice(0, 60));
const oldIn = await mk()('/api/' + P.api + '/login',
  { method: 'POST', body: JSON.stringify({ password: P.pass }) });
t(!!oldIn.error, 'و رمزِ قبلی دیگر کار نمی‌کند', oldIn.error);

seen = [];
const short = await adm(A + '/planners/' + P.slug + '/send-creds',
  { method: 'POST', body: JSON.stringify({ reset: true, password: 'abc', chat: PHONE_CHAT }) });
t(!!short.error && /کوتاه/.test(short.error), 'رمزِ کوتاه گذاشته نمی‌شود', short.error);
t(seen.length === 0, 'و پیامی هم نرفته');

/* ---- مقصد ---- */
console.log('\n===== مقصد =====');
const badPhone = await adm(A + '/planners/' + P.slug + '/send-creds',
  { method: 'POST', body: JSON.stringify({ password: fresh.password, phone: '12345' }) });
t(!!badPhone.error && /شمارهٔ موبایل/.test(badPhone.error), 'شمارهٔ بی‌ربط رد می‌شود', badPhone.error);

const unknown = await adm(A + '/planners/' + P.slug + '/send-creds',
  { method: 'POST', body: JSON.stringify({ password: fresh.password, phone: '09129999999' }) });
t(!!unknown.error && /سلام نکرده/.test(unknown.error),
  'شماره‌ای که به ربات سلام نکرده، با توضیحِ درست رد می‌شود', unknown.error);

if (DB) {
  const { DatabaseSync } = await import('node:sqlite');
  const db = new DatabaseSync(DB);
  db.prepare(`INSERT INTO bot_chats(platform,chat_id,role,phone,created) VALUES(?,?,?,?,?)
    ON CONFLICT(platform,chat_id) DO UPDATE SET phone=excluded.phone`)
    .run('bale', PHONE_CHAT, 'customer', PHONE, Date.now());
  seen = [];
  const byPhone = await adm(A + '/planners/' + P.slug + '/send-creds',
    { method: 'POST', body: JSON.stringify({ reset: true, phone: '۰۹۱۲۱۲۳۴۵۶۷' }) });
  t(byPhone.ok === true, 'با شمارهٔ موبایل — و با رقمِ فارسی هم — پیدا می‌شود',
    JSON.stringify(byPhone).slice(0, 80));
  t(seen.length === 1 && String(seen[0].body.chat_id) === PHONE_CHAT,
    'و به همان گفتگویی می‌رود که آن شماره با آن سلام کرده',
    seen.length ? String(seen[0].body.chat_id) : '—');

  /* مقصدی که کار کرد باید یادِ کارتابل بماند */
  const after = await adm(A + '/planners');
  const row = (after.items || []).find(x => x.slug === P.slug) || {};
  t(row.phone === PHONE, 'شماره یادِ کارتابل می‌ماند تا بارِ بعد تایپ نشود', row.phone);
  t(row.bale === PHONE_CHAT, 'و شناسهٔ گفتگویش هم', row.bale);

  seen = [];
  const remembered = await adm(A + '/planners/' + P.slug + '/send-creds',
    { method: 'POST', body: JSON.stringify({ reset: true }) });
  t(remembered.ok === true && seen.length === 1 &&
    String(seen[0].body.chat_id) === PHONE_CHAT,
    'بارِ بعد بی‌نوشتنِ مقصد هم می‌رود', JSON.stringify(remembered).slice(0, 60));
} else {
  console.log('   —   DB_FILE داده نشده، پس آزمونِ «پیدا کردن از روی شماره» رد شد');
}

/* ---- ربات که نپذیرد ---- */
console.log('\n===== ربات که نپذیرد =====');
reply = { ok: false, description: 'chat not found' };
const refused = await adm(A + '/planners/' + P.slug + '/send-creds',
  { method: 'POST', body: JSON.stringify({ reset: true, chat: '777' }) });
t(!!refused.error && /chat not found/.test(refused.error),
  'جوابِ خودِ ربات بی‌کم‌و‌کاست به ادمین می‌رسد', refused.error);
t(typeof refused.password === 'string' && refused.password.length >= 8,
  'و چون رمز گذاشته شده بود، همان رمز برمی‌گردد تا ادمین دستی برساندش',
  refused.password);
const stillIn = await mk()('/api/' + P.api + '/login',
  { method: 'POST', body: JSON.stringify({ password: refused.password }) });
t(!stillIn.error, 'و آن رمز واقعاً همان رمزِ کارتابل است');
reply = { ok: true, result: { message_id: 1 } };

/* ---- درِ بسته ---- */
console.log('\n===== بی‌ورودِ ادمین =====');
const out = mk();
const guest = await out(A + '/planners/' + P.slug + '/send-creds',
  { method: 'POST', body: JSON.stringify({ reset: true, chat: PHONE_CHAT }) });
t(!!guest.error, 'بی‌ورودِ ادمین هیچ‌کس مشخصات نمی‌فرستد', guest.error);

stub.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
