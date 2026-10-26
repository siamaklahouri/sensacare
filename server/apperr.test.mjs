/* خطای سرور: ثبت می‌شود، در پنل دیده می‌شود، و جدولش اصلاً وجود دارد.
   آن سومی بی‌خود نیست: جدول با مهاجرت می‌آید و update.sh تا امروز
   مهاجرت‌ها را اجرا نمی‌کرد — یعنی قابلیت رفته بود روی سرور و بی‌صدا
   کار نمی‌کرد. این آزمون همان را می‌گیرد. */
import { DatabaseSync } from 'node:sqlite';
import { launch } from './pw.mjs';
import { ADMIN } from './where.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const DB = process.env.DB_FILE;
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('— جدول —');
{
  let has = false, cols = [];
  try {
    const db = new DatabaseSync(DB);
    has = !!db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='app_errors'").get();
    if (has) cols = db.prepare('PRAGMA table_info(app_errors)').all().map(c => c.name);
  } catch (e) {}
  t(has, 'جدولِ app_errors در دیتابیس هست', has ? cols.join('، ') : 'نیست');
  for (const c of ['sig', 'first', 'last', 'n', 'method', 'path', 'msg', 'notified'])
    t(cols.includes(c), 'ستونِ ' + c + ' هست');
}

console.log('— ثبتِ خطا —');
{
  const db = new DatabaseSync(DB);
  db.prepare('DELETE FROM app_errors').run();
  const now = Date.now();
  db.prepare('INSERT INTO app_errors(sig,first,last,n,method,path,msg,notified) VALUES(?,?,?,?,?,?,?,0)')
    .run('GET /test | نمونه', now, now, 4, 'GET', '/test-path', 'خطای نمونهٔ آزمون');
  const row = db.prepare('SELECT * FROM app_errors').get();
  t(row && row.n === 4, 'ردیف نشست و شمارش دارد', row ? 'n=' + row.n : 'نیست');
}

console.log('— در پنل دیده می‌شود —');
{
  const mk = () => { let ck = ''; return async (path, opt) => {
    const o = Object.assign({ headers: {} }, opt || {});
    o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
    const r = await fetch(BASE + path, o);
    for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
      const kv = c.split(';')[0], k = kv.split('=')[0];
      ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
    }
    let d = null; try { d = await r.json(); } catch (e) {}
    return { status: r.status, data: d || {} };
  }; };
  const adm = mk();
  await adm('/api/admin.planer/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
  const r = await adm('/api/admin.planer/planners');
  const ae = r.data.appErrors;
  t(!!ae, 'پنل خلاصهٔ خطاها را می‌دهد', ae ? JSON.stringify(ae).slice(0, 80) : 'نیامد');
  t(ae && ae.kinds === 1 && ae.total === 4, 'و عددهایش درست است',
    ae ? 'kinds=' + ae.kinds + ' total=' + ae.total : '-');
  t(ae && (ae.top || [])[0] && ae.top[0].path === '/test-path', 'و مسیرِ پرتکرار را می‌گوید',
    ae && ae.top[0] ? ae.top[0].path : '-');
}

console.log('— update.sh مهاجرت‌ها را اجرا می‌کند —');
{
  const { readFileSync } = await import('node:fs');
  const sh = readFileSync(new URL('./update.sh', import.meta.url), 'utf8');
  t(/node server\/migrate\.js/.test(sh),
    'دستورِ مهاجرت در update.sh هست — وگرنه جدولِ تازه روی سرور ساخته نمی‌شود');
  t(sh.indexOf('migrate.js') < sh.indexOf('systemctl restart sltech'),
    'و پیش از راه‌اندازیِ دوبارهٔ سرویس اجرا می‌شود');
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
