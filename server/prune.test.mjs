/* هرسِ جدول‌های نوشتنی.

   سه جدول فقط نوشته می‌شدند و هیچ‌وقت هرس نمی‌شدند. سیاههٔ کارها از
   همه بدتر: فقط با «LIMIT 100» خوانده می‌شود، پس هرچه بیش‌تر می‌شد
   کسی نمی‌دید — ولی در دیتابیس می‌ماند و با هر پشتیبان هم می‌رفت.

   و یک تلهٔ ظریف: نامِ ستونِ زمان در هر جدول یکی نیست. app_errors
   «last» دارد نه «at». بارِ اول برای هر سه «at» نوشتم؛ آن یکی بی‌صدا
   رد می‌شد، چون خطایش گرفته می‌شود. این آزمون دقیقاً همین را می‌گیرد:
   ردیفِ کهنه می‌گذارد و می‌سنجد که واقعاً رفته باشد. */
import { DatabaseSync } from 'node:sqlite';
import { readFileSync } from 'node:fs';

const DB = process.env.DB_FILE;
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

if (!DB) { console.log('DB_FILE لازم است'); process.exit(2); }
const db = new DatabaseSync(DB);
const DAY = 86400000, now = Date.now();

/* ---- ستونِ زمانِ هر جدول، از خودِ دیتابیس ---- */
console.log('===== ستونِ زمان =====');
const colsOf = tb => db.prepare('PRAGMA table_info(' + tb + ')').all().map(r => r.name);
const want = { job_runs: 'at', app_errors: 'last', admin_log: 'at' };
for (const [tb, col] of Object.entries(want)) {
  const cols = colsOf(tb);
  t(cols.includes(col), tb + ': ستونِ «' + col + '» دارد', cols.join(', '));
  /* و آن یکی نام را ندارد — یعنی اگر کد اشتباه بنویسد، واقعاً می‌افتد */
  if (col !== 'at') t(!cols.includes('at'), tb + ': و ستونِ «at» ندارد — پس نامش مهم است');
}

/* ---- کد باید همان ستونِ درست را بنویسد ---- */
console.log('===== کد =====');
const src = readFileSync(new URL('../src/index.js', import.meta.url), 'utf8');
const block = (src.match(/\[\[\s*'job_runs'[\s\S]{0,200}?\]\]/) || [''])[0];
t(/'job_runs', *'at'/.test(block), 'job_runs با at هرس می‌شود');
t(/'app_errors', *'last'/.test(block), 'app_errors با last هرس می‌شود — نه at', block.slice(0, 80));
t(/'admin_log', *'at'/.test(block), 'admin_log با at هرس می‌شود');
t(/tomb:/.test(src) && /30 \* DAY/.test(src), 'و سنگ‌قبرهای کهنه هم هرس می‌شوند');

/* ---- واقعاً پاک می‌کند؟ ردیفِ کهنه می‌گذاریم و دستورِ همان کد را
       روی همین دیتابیس اجرا می‌کنیم. ---- */
console.log('===== اجرای واقعی =====');
const old = now - 400 * DAY, mid = now - 60 * DAY, fresh = now - 1 * DAY;
db.prepare("INSERT INTO admin_log(at,what,slug,note) VALUES(?,?,?,?)").run(old, 'azmoon-kohne', '', '');
db.prepare("INSERT INTO admin_log(at,what,slug,note) VALUES(?,?,?,?)").run(fresh, 'azmoon-taze', '', '');
db.prepare("INSERT INTO app_errors(sig,first,last,n,method,path,msg) VALUES(?,?,?,?,?,?,?)")
  .run('azmoon-kohne', mid, mid, 1, 'GET', '/azmoon', 'kohne');
db.prepare("INSERT INTO app_errors(sig,first,last,n,method,path,msg) VALUES(?,?,?,?,?,?,?)")
  .run('azmoon-taze', fresh, fresh, 1, 'GET', '/azmoon', 'taze');

const cnt = (sql, ...b) => Number(db.prepare(sql).get(...b).n);
t(cnt("SELECT COUNT(*) n FROM admin_log WHERE what='azmoon-kohne'") === 1, 'ردیفِ کهنهٔ سیاهه نشست');
t(cnt("SELECT COUNT(*) n FROM app_errors WHERE sig='azmoon-kohne'") === 1, 'خطای کهنه نشست');

/* همان حلقهٔ کد، با همان جفت‌های جدول/ستون */
for (const [table, col, days] of [['job_runs', 'at', 30], ['app_errors', 'last', 30], ['admin_log', 'at', 365]])
  db.prepare('DELETE FROM ' + table + ' WHERE ' + col + ' < ?').run(now - days * DAY);

t(cnt("SELECT COUNT(*) n FROM admin_log WHERE what='azmoon-kohne'") === 0, 'سیاههٔ کهنه پاک شد');
t(cnt("SELECT COUNT(*) n FROM admin_log WHERE what='azmoon-taze'") === 1, 'ولی تازه‌اش ماند');
t(cnt("SELECT COUNT(*) n FROM app_errors WHERE sig='azmoon-kohne'") === 0, 'خطای کهنه پاک شد');
t(cnt("SELECT COUNT(*) n FROM app_errors WHERE sig='azmoon-taze'") === 1, 'ولی تازه‌اش ماند');

/* جارو */
db.prepare("DELETE FROM admin_log WHERE what LIKE 'azmoon-%'").run();
db.prepare("DELETE FROM app_errors WHERE sig LIKE 'azmoon-%'").run();
db.close();

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
