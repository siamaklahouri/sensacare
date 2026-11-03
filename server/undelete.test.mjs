/* حذفِ کارتابل، و راهِ برگشتش.

   تا دیروز حذف هیچ راهِ برگشتی نداشت: ردیفِ کارتابل، داده، تنظیمات، و
   حتی تاریخچهٔ نسخه‌ها — که خودش شبکهٔ ایمنیِ «برگرد به دیروز» است —
   همه با هم می‌رفتند. تأیید داشت (باید نشانی را تایپ کنی)، ولی تأیید
   جلوی اشتباهِ مطمئن را نمی‌گیرد.

   حالا پیش از پاک کردن یک نسخهٔ کامل کنار می‌ماند. این آزمون همان
   چرخه را می‌رود: بساز، داده بگذار، حذف کن، برگردان، و بسنج که همان
   داده و همان رمز برگشته باشد — نه فقط پوسته‌اش. */
import { execFileSync } from 'node:child_process';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AU = process.env.VS_ADMIN || 'admin';
const AP = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const SLUG = 'azmoon-hazf';
const PASS = 'hazfhazfhazf';
const MARK = 'دادهٔ-گران‌بها-' + Date.now();

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

function client() {
  let ck = '';
  return async (path, opt) => {
    const o = Object.assign({ headers: {} }, opt || {});
    o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
    const r = await fetch(BASE + path, o);
    for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
      const kv = c.split(';')[0], k = kv.split('=')[0];
      ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
    }
    const ct = r.headers.get('content-type') || '';
    return { status: r.status, body: ct.includes('json') ? await r.json().catch(() => ({})) : null };
  };
}

/* دستورهای خط‌فرمان روی همان دیتابیسی که سرور با آن بالاست */
const cli = (...args) => {
  try {
    return execFileSync('node', [new URL('./index.js', import.meta.url).pathname, ...args],
      { encoding: 'utf8', env: Object.assign({}, process.env), stdio: ['ignore','pipe','pipe'] });
  } catch (e) { return String(e.stdout || '') + String(e.stderr || ''); }
};

const a = client();
await a('/api/admin.planer/signin', { method: 'POST', body: JSON.stringify({ user: AU, password: AP }) });

/* پاک‌سازیِ بازماندهٔ اجرای قبلی */
await a('/api/admin.planer/planners/' + SLUG, { method: 'DELETE', body: JSON.stringify({ confirm: SLUG }) });
cli('--undelete', SLUG);
await a('/api/admin.planer/planners/' + SLUG, { method: 'DELETE', body: JSON.stringify({ confirm: SLUG }) });

console.log('===== ساختن و پر کردن =====');
const mk = await a('/api/admin.planer/planners', { method: 'POST', body: JSON.stringify({
  name: 'کارتابلِ آزمونِ حذف', slug: SLUG, kind: 'gen', password: PASS }) });
t(mk.status === 200, 'کارتابل ساخته شد', 'کد ' + mk.status);
const info = ((await a('/api/admin.planer/planners')).body.items || []).find(x => x.slug === SLUG);
t(!!info, 'و در فهرست آمد');
if (!info) { console.log('\n' + ok + ' ok، ' + bad + ' bad'); process.exit(1); }

const k = client();
t((await k('/api/' + info.api + '/login', { method: 'POST', body: JSON.stringify({ password: PASS }) })).status === 200,
  'و با رمزش باز می‌شود');
const cur = await k('/api/' + info.api + '/state');
await k('/api/' + info.api + '/state', { method: 'PUT', body: JSON.stringify({
  state: { meta: { نشانه: MARK }, tasks: [{ task: 'کارِ مهم' }] },
  db: { vm: [{ server: MARK }] }, baseRev: cur.body.rev, force: true }) });
t(JSON.stringify((await k('/api/' + info.api + '/state')).body).includes(MARK), 'و داده‌اش نشست');

console.log('===== حذف =====');
const noConfirm = await a('/api/admin.planer/planners/' + SLUG, { method: 'DELETE', body: JSON.stringify({ confirm: 'چیزِ دیگر' }) });
t(noConfirm.status !== 200, 'بی تأییدِ درست حذف نمی‌شود', 'کد ' + noConfirm.status);

const del = await a('/api/admin.planer/planners/' + SLUG, { method: 'DELETE', body: JSON.stringify({ confirm: SLUG }) });
t(del.status === 200, 'با تأییدِ درست حذف می‌شود', 'کد ' + del.status);
t(del.body && del.body.undoDays === 30, 'و پاسخ می‌گوید تا کِی برگشتنی است',
  del.body ? String(del.body.undoDays) : '—');
t(!((await a('/api/admin.planer/planners')).body.items || []).some(x => x.slug === SLUG),
  'و از فهرست رفت');
t((await k('/api/' + info.api + '/state')).status !== 200, 'و کارتابلش دیگر جواب نمی‌دهد');

console.log('===== فهرستِ برگشتنی‌ها =====');
const list = cli('--deleted');
t(new RegExp(SLUG).test(list), 'در فهرستِ حذف‌شده‌ها هست');
t(/بایت|کیلوبایت/.test(list), 'و اندازهٔ داده‌اش را می‌گوید — نه «۰KB» که شبیهِ خالی است',
  (list.match(/\d+ (بایت|کیلوبایت)/) || ['—'])[0]);
t(!new RegExp(MARK).test(list), 'ولی خودِ داده را چاپ نمی‌کند');

console.log('===== برگرداندن =====');
const badName = cli('--undelete', 'yek-chiz-ke-nist');
t(/پیدا نشد/.test(badName), 'نامِ بی‌ربط را رد می‌کند');

const un = cli('--undelete', SLUG);
t(/برگشت/.test(un), 'برگرداندن گزارش می‌دهد', (un.split('\n')[0] || '').slice(0, 60));
t(/تاریخچه/.test(un), 'و رُک می‌گوید تاریخچهٔ نسخه‌ها برنمی‌گردد');

const back = ((await a('/api/admin.planer/planners')).body.items || []).find(x => x.slug === SLUG);
t(!!back, 'کارتابل در فهرست برگشت');
t(back && back.name === 'کارتابلِ آزمونِ حذف', 'با نامِ خودش', back && back.name);
t(!!(back && back.hasPassword), 'و رمزش هم برگشت');

const k2 = client();
t((await k2('/api/' + info.api + '/login', { method: 'POST', body: JSON.stringify({ password: PASS }) })).status === 200,
  'با همان رمزِ قبلی وارد می‌شود — نه رمزِ تازه');
const st2 = await k2('/api/' + info.api + '/state');
t(JSON.stringify(st2.body.state || {}).includes(MARK), 'نیمهٔ «state» برگشت');
t(JSON.stringify(st2.body.db || {}).includes(MARK), 'نیمهٔ «db» هم برگشت');

console.log('===== رویِ کارتابلِ زنده نمی‌نویسد =====');
/* دوباره حذفش کن، بعد با همان نشانی یکی تازه بساز، بعد برگرداندن را
   امتحان کن: نباید رویِ دادهٔ زنده بنویسد. */
await a('/api/admin.planer/planners/' + SLUG, { method: 'DELETE', body: JSON.stringify({ confirm: SLUG }) });
await a('/api/admin.planer/planners', { method: 'POST', body: JSON.stringify({
  name: 'کارتابلِ تازه با همان نشانی', slug: SLUG, kind: 'gen', password: PASS }) });
const clash = cli('--undelete', SLUG);
t(/الان وجود دارد|رویش نمی‌نویسم/.test(clash), 'جلوی نوشتن روی کارتابلِ زنده را می‌گیرد',
  (clash.split('\n')[0] || '').slice(0, 70));
const still = ((await a('/api/admin.planer/planners')).body.items || []).find(x => x.slug === SLUG);
t(still && still.name === 'کارتابلِ تازه با همان نشانی', 'و کارتابلِ زنده دست‌نخورده ماند',
  still && still.name);

/* جارو */
await a('/api/admin.planer/planners/' + SLUG, { method: 'DELETE', body: JSON.stringify({ confirm: SLUG }) });
cli('--undelete', SLUG);
await a('/api/admin.planer/planners/' + SLUG, { method: 'DELETE', body: JSON.stringify({ confirm: SLUG }) });

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
