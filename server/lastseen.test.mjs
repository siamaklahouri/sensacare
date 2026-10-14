/* «آخرین استفاده» — عددی که پنلِ ادمین کنارِ «آخرین ورود با رمز»
   نشان می‌دهد. سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const DB = process.env.DB_FILE || '';
const P = { slug: 'sina', api: 'sina', pass: 'sinasinasina' };

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
await adm(A + '/planners/' + P.slug + '/password',
  { method: 'POST', body: JSON.stringify({ password: P.pass }) });
const seenOf = async () => {
  const r = await adm(A + '/planners');
  const row = (r.items || []).find(x => x.slug === P.slug) || {};
  return { seen: Number(row.lastSeen || 0), login: Number(row.lastLogin || 0) };
};

console.log('===== پنلِ ادمین =====');
const first = await seenOf();
t(Object.prototype.hasOwnProperty.call(await (async()=>{
    const r = await adm(A + '/planners');
    return (r.items || []).find(x => x.slug === P.slug) || {};
  })(), 'lastSeen'),
  'فهرستِ کارتابل‌ها «آخرین استفاده» را هم می‌دهد', String(first.seen));

console.log('\n===== کار کردن با کارتابل =====');
/* سقفِ پنج‌دقیقه‌ایِ نوشتن یعنی اگر همین حالا اجرا شده باشد، عددِ
   تازه نمی‌نشیند. پس اول عقبش می‌بریم تا آزمون دوباره‌اجراپذیر بماند. */
let putSetting = null;
if (DB) {
  const { DatabaseSync } = await import('node:sqlite');
  const db0 = new DatabaseSync(DB);
  putSetting = (k, v) => db0.prepare(
    'INSERT INTO settings(k,v) VALUES(?,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v').run(k, JSON.stringify(v));
  putSetting('seen:' + P.slug, Date.now() - 3600000);
}
const me = mk();
const inn = await me('/api/' + P.api + '/login', { method: 'POST', body: JSON.stringify({ password: P.pass }) });
t(!inn.error, 'ورود انجام شد', inn.error);
const t0 = Date.now();
await me('/api/' + P.api + '/state');
const after = await seenOf();
t(after.seen >= t0 - 2000 && after.seen <= Date.now() + 2000,
  'با یک درخواستِ واقعی، «آخرین استفاده» همین حالا می‌شود',
  new Date(after.seen).toISOString());
t(after.login > 0 && after.login < t0,
  'و «آخرین ورود» همان عددِ قبلی می‌ماند، نه این یکی',
  new Date(after.login).toISOString());

console.log('\n===== بی‌خودی نوشته نمی‌شود =====');
await me('/api/' + P.api + '/state');
await me('/api/' + P.api + '/state');
const again = await seenOf();
t(again.seen === after.seen,
  'چند درخواستِ پشتِ سر هم، فقط یک‌بار می‌نویسد (سقفِ پنج دقیقه)',
  again.seen + ' vs ' + after.seen);

if (DB) {
  const put = putSetting;
  const old = Date.now() - 3600000;

  console.log('\n===== خبرگیرِ پس‌زمینه حساب نیست =====');
  put('seen:' + P.slug, old);
  await me('/api/' + P.api + '/chat-news?since=0');
  await me('/api/' + P.api + '/shared-news');
  const poll = await seenOf();
  t(poll.seen === old, 'پرسشِ هر چند ثانیه‌ایِ چت و بخش‌های مشترک، «استفاده» حساب نمی‌شود',
    poll.seen + ' vs ' + old);

  console.log('\n===== ولی کارِ واقعی حساب است =====');
  const t1 = Date.now();
  await me('/api/' + P.api + '/state');
  const real = await seenOf();
  t(real.seen >= t1 - 2000, 'خواندنِ دادهٔ کارتابل تازه‌اش می‌کند',
    new Date(real.seen).toISOString());

  console.log('\n===== بی‌ورود، هیچ =====');
  put('seen:' + P.slug, old);
  const out = mk();
  await out('/api/' + P.api + '/state');
  const none = await seenOf();
  t(none.seen === old, 'درخواستِ بی‌نشست چیزی را تازه نمی‌کند', none.seen + ' vs ' + old);
} else {
  console.log('   —   DB_FILE داده نشده، پس سه آزمونِ آخر رد شد');
}

console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
