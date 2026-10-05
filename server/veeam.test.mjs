/* گزارشِ Veeam، سر تا ته روی سرورِ واقعیِ محلی:
   ساختنِ کلید در پنل → فرستادنِ گزارش با آن کلید → دیدنش در کارتابل.

   سه چیز که عمداً سنجیده می‌شوند، چون هر سه قفلِ این مسیرند:
     • بدونِ کلیدِ درست هیچ گزارشی پذیرفته نمی‌شود
     • کلیدِ کهنه بعد از ساختنِ کلیدِ تازه از کار می‌افتد
     • خودِ «/veeam/push» نشست نمی‌خواهد (اسکریپت مرورگر نیست)، ولی
       خواندنِ گزارش بدونِ نشست ممنوع است

   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
const BASE  = process.env.VS_BASE || 'http://127.0.0.1:8911';
const SLUG  = process.env.VS_SLUG || 'siamak';
const API   = process.env.VS_API  || 'kartabl';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const PUSER = process.env.VS_USER || 'siamak';
const PPASS = process.env.VS_PASS || 'siamaksiamak';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* کوکی‌ها را خودمان نگه می‌داریم: دو نشستِ جدا لازم است (ادمین و کاربر)
   و fetch خودش ظرفِ کوکی ندارد. */
function jar() {
  let c = '';
  return {
    get header() { return c; },
    eat(res) {
      const sc = res.headers.getSetCookie ? res.headers.getSetCookie() : [];
      for (const s of sc) {
        const kv = s.split(';')[0];
        const k = kv.split('=')[0];
        c = c.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
      }
    }
  };
}
async function call(j, path, opt) {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers,
                            j && j.header ? { cookie: j.header } : {});
  const r = await fetch(BASE + path, o);
  if (j) j.eat(r);
  let d = null;
  try { d = await r.json(); } catch (e) { /* بدنه نداشت */ }
  return { status: r.status, ok: r.ok, data: d || {} };
}

const admin = jar(), user = jar();

console.log('===== ورود =====');
let r = await call(admin, '/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
t(r.ok, 'ادمین وارد شد', String(r.status));

/* رمزِ کاربر را خودِ ادمین می‌گذارد، تا آزمون به رمزِ واقعی کار نداشته باشد */
r = await call(admin, '/api/admin.planer/planners/' + SLUG + '/password',
  { method: 'POST', body: JSON.stringify({ password: PPASS }) });
t(r.ok, 'رمزِ کارتابل گذاشته شد', String(r.status));

console.log('\n===== پیش از ساختنِ کلید =====');
r = await call(null, '/api/' + API + '/veeam/push',
  { method: 'POST', body: JSON.stringify({ jobs: [] }) });
t(r.status === 403, 'بدونِ کلید، گزارش رد می‌شود', String(r.status));

console.log('\n===== ساختنِ کلید =====');
/* گزارشِ قبلی (اگر از اجرای پیشین مانده) پیش از ساختنِ کلید برداشته
   می‌شود: «ساختنِ کلید گزارش را دست نمی‌زند» را باید سنجید، نه اینکه
   آزمون فقط روی دیتابیسِ نو سبز شود. */
r = await call(admin, '/api/admin.planer/planners/' + SLUG + '/veeam-key');
const before = r.data.last ? JSON.stringify(r.data.last) : 'null';

r = await call(admin, '/api/admin.planer/planners/' + SLUG + '/veeam-key', { method: 'POST', body: '{}' });
t(r.ok && typeof r.data.key === 'string' && r.data.key.length >= 24,
  'کلید ساخته شد', r.data.key ? r.data.key.length + ' حرف' : JSON.stringify(r.data));
const KEY = r.data.key;

r = await call(admin, '/api/admin.planer/planners/' + SLUG + '/veeam-key');
t(r.ok && r.data.set === true, 'پنل می‌گوید کلید هست');
t(r.data.key === undefined, 'ولی خودِ کلید را دیگر پس نمی‌دهد — درهم‌شده ذخیره شده');
t((r.data.last ? JSON.stringify(r.data.last) : 'null') === before,
  'ساختنِ کلید، گزارشِ ذخیره‌شده را دست نزد', before.slice(0, 60));

console.log('\n===== فرستادنِ گزارش =====');
const jobs = [
  { name: 'Daily-VMs', type: 'Backup', result: 'Success', state: 'Stopped',
    last: '2026-10-05 02:00', next: '2026-10-06 02:00', objects: '14' },
  { name: 'SQL-Hourly', type: 'Backup', result: 'Warning', state: 'Working',
    last: '2026-10-05 17:00', next: '2026-10-05 18:00', objects: '3' },
  { name: 'Archive', type: 'BackupCopy', result: 'Failed', state: 'Stopped',
    last: '2026-10-04 23:00', next: '', objects: '58' }
];
r = await call(null, '/api/' + API + '/veeam/push', {
  method: 'POST', headers: { 'x-veeam-key': KEY },
  body: JSON.stringify({ host: 'veeam01.company.local', agent: 'test', jobs })
});
t(r.ok && r.data.jobs === 3, 'گزارش با کلیدِ درست پذیرفته شد', JSON.stringify(r.data));

r = await call(null, '/api/' + API + '/veeam/push', {
  method: 'POST', headers: { 'x-veeam-key': KEY + 'x' },
  body: JSON.stringify({ jobs })
});
t(r.status === 403, 'با کلیدِ غلط رد شد', String(r.status));

console.log('\n===== خواندنِ گزارش =====');
r = await call(null, '/api/' + API + '/veeam');
t(r.status === 401, 'بدونِ ورود، گزارش خوانده نمی‌شود', String(r.status));

r = await call(user, '/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: PUSER, password: PPASS }) });
t(r.ok, 'کاربر وارد شد', String(r.status));

r = await call(user, '/api/' + API + '/veeam');
const rep = r.data.report || {};
t(r.ok && (rep.jobs || []).length === 3, 'کاربر هر سه جاب را می‌بیند', (rep.jobs || []).length + ' جاب');
t(rep.host === 'veeam01.company.local', 'و نامِ سرورِ Veeam هم آمده', rep.host);
t((rep.jobs[0] || {}).objects === '14', 'ستونِ تعدادِ آبجکت درست رسید', (rep.jobs[0] || {}).objects);
t(typeof rep.at === 'number' && rep.at > 0, 'و زمانِ گزارش را سرور زده، نه فرستنده');

console.log('\n===== کلیدِ تازه، کلیدِ کهنه =====');
r = await call(admin, '/api/admin.planer/planners/' + SLUG + '/veeam-key', { method: 'POST', body: '{}' });
const KEY2 = r.data.key;
t(r.ok && KEY2 && KEY2 !== KEY, 'کلیدِ دوم ساخته شد و با اولی فرق دارد');

r = await call(null, '/api/' + API + '/veeam/push',
  { method: 'POST', headers: { 'x-veeam-key': KEY }, body: JSON.stringify({ jobs: [] }) });
t(r.status === 403, 'کلیدِ کهنه دیگر کار نمی‌کند', String(r.status));

r = await call(null, '/api/' + API + '/veeam/push',
  { method: 'POST', headers: { 'x-veeam-key': KEY2 }, body: JSON.stringify({ jobs: [jobs[0]] }) });
t(r.ok && r.data.jobs === 1, 'کلیدِ تازه کار می‌کند', JSON.stringify(r.data));

r = await call(admin, '/api/admin.planer/planners/' + SLUG + '/veeam-key');
t(r.ok && r.data.last && r.data.last.jobs === 1, 'و پنل آخرین گزارش را نشان می‌دهد',
  JSON.stringify(r.data.last));

console.log('\n===== برداشتنِ کلید =====');
r = await call(admin, '/api/admin.planer/planners/' + SLUG + '/veeam-key', { method: 'DELETE' });
t(r.ok, 'کلید برداشته شد');
r = await call(null, '/api/' + API + '/veeam/push',
  { method: 'POST', headers: { 'x-veeam-key': KEY2 }, body: JSON.stringify({ jobs: [] }) });
t(r.status === 403, 'و دیگر هیچ گزارشی پذیرفته نمی‌شود', String(r.status));
r = await call(user, '/api/' + API + '/veeam');
t(r.ok && (r.data.report || {}).jobs !== undefined,
  'ولی گزارشی که رسیده بود دست نخورد — برداشتنِ کلید، پاک کردنِ گزارش نیست');

console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
