/* سفارشِ سازمانی با چند شغل.
   یک سازمان یک شغل نیست: «۱۵ کاربر» یعنی مثلاً ۱ مدیرعامل، ۵ حسابدار،
   ۲ دفتردار، ۳ بازرگانی و ۴ فنی — هر کدام قالبِ کارتابلِ خودش. فرم تا
   امروز فقط یک شغل می‌گرفت.
   مهم‌ترین سنجه این‌جا آخری است: سرور تعداد و قیمت را از روی ردیف‌ها
   حساب کند، نه از عددی که مرورگر فرستاده. */
import { launch } from './pw.mjs';
import { HOME } from './where.mjs';
import { DatabaseSync } from 'node:sqlite';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const DB = process.env.DB_FILE;
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* پلن‌های معلوم، تا عددها حدسی نباشند */
const PLANS = [
  { name: 'آزمونِ شخصی', tier: 'personal', price: 2000000, days: 365, baseSeats: 1, perSeat: 0 },
  { name: 'آزمونِ سازمانی', tier: 'org', price: 12000000, days: 365, baseSeats: 5, perSeat: 900000 }
];
/* هر سفارش یک پیام هم به مدیر می‌فرستد و آن پیام در support_msgs
   می‌نشیند — یعنی این آزمون شمارندهٔ «نخوانده» را بالا می‌برد و
   آزمونِ زنگوله را می‌شکند. پس هرچه این‌جا ساخته می‌شود، همین‌جا هم
   برداشته می‌شود. */
let saved = null, msgMark = 0;
const made = [];
if (DB) {
  const db = new DatabaseSync(DB);
  try { msgMark = db.prepare('SELECT COALESCE(MAX(rowid),0) n FROM support_msgs').get().n; }
  catch (e) { msgMark = 0; }
  const row = db.prepare('SELECT v FROM settings WHERE k=?').get('sltechSite');
  saved = row ? row.v : null;
  const st = JSON.parse(saved || '{}');
  st.plans = PLANS; st.extraPrice = 400000; st.customPrice = 3000000;
  db.prepare('INSERT INTO settings(k,v) VALUES(?,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v')
    .run('sltechSite', JSON.stringify(st));
  db.prepare("INSERT INTO bot_logins(nonce,status,phone,name,platform,chat_id,created) VALUES(?,'ready',?,?,?,?,?) ON CONFLICT(nonce) DO UPDATE SET status='ready', created=excluded.created")
    .run('orgtest-nonce', '09120000000', 'آزمون', 'sltg', '9999', Date.now());
}

const b = await launch();
const p = await (await b.newContext({ viewport: { width: 1200, height: 1000 } })).newPage();
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 130)));
await p.goto(HOME, { waitUntil: 'networkidle' });
await p.waitForTimeout(1500);

console.log('— فرم —');
{
  await p.evaluate(() => {
    const i = PLANS.findIndex(x => x.tier === 'personal');
    document.querySelector('#planList [data-plan="' + i + '"]').click();
  });
  await p.waitForTimeout(400);
  const per = await p.evaluate(() => ({
    one: !document.getElementById('oOneRow').hidden,
    roles: !document.getElementById('oRoles').hidden
  }));
  t(per.one && !per.roles, 'پلنِ شخصی همان یک شغل و یک عدد را می‌گیرد');

  await p.evaluate(() => {
    const i = PLANS.findIndex(x => x.tier === 'org');
    document.querySelector('#planList [data-plan="' + i + '"]').click();
  });
  await p.waitForTimeout(500);
  const org = await p.evaluate(() => ({
    one: !document.getElementById('oOneRow').hidden,
    roles: !document.getElementById('oRoles').hidden,
    rows: document.querySelectorAll('#oRoleList .orole').length
  }));
  t(!org.one && org.roles, 'و پلنِ سازمانی ردیف‌سازِ شغل‌ها را');
  t(org.rows >= 1, 'که با یک ردیفِ خالی شروع می‌شود', org.rows + ' ردیف');
}

const WANT = [['ceo', 1], ['acc', 5], ['office', 2], ['procure', 3], ['it', 4]];
console.log('— ۱ مدیرعامل، ۵ حسابدار، ۲ دفتردار، ۳ بازرگانی، ۴ فنی —');
{
  await p.evaluate(rr => {
    const list = document.getElementById('oRoleList');
    while (list.children.length < rr.length) document.getElementById('oRoleAdd').click();
    [...list.children].forEach((row, i) => {
      if (!rr[i]) return;
      const sel = row.querySelector('select');
      sel.value = rr[i][0]; sel.dispatchEvent(new Event('change', { bubbles: true }));
      const c = row.querySelector('.cnt input');
      c.value = String(rr[i][1]); c.dispatchEvent(new Event('input', { bubbles: true }));
    });
  }, WANT);
  await p.waitForTimeout(700);
  const r = await p.evaluate(() => ({
    rows: roleRows().map(x => x.job + '×' + x.count),
    seats: seatCount(),
    sum: document.getElementById('oRolesSum').textContent.trim(),
    total: calcTotal().total
  }));
  t(r.rows.join('،') === WANT.map(w => w[0] + '×' + w[1]).join('،'),
    'هر پنج ردیف با شغل و تعدادِ خودش خوانده می‌شوند', r.rows.join(' '));
  t(r.seats === 15, 'جمعِ نفرات ۱۵ است', String(r.seats));
  t(/۱۵/.test(r.sum), 'و همان را بالای ردیف‌ها نشان می‌دهد', r.sum);
  /* ۱۲ میلیون پایه + (۱۵−۵)×۹۰۰هزار */
  t(r.total === 21000000, 'و قیمت از روی جمع حساب می‌شود', r.total.toLocaleString());
}

console.log('— حذف و جمعِ دوباره —');
{
  await p.evaluate(() => {
    document.querySelector('#oRoleList .orole:last-child .x').click();
  });
  await p.waitForTimeout(500);
  const r = await p.evaluate(() => ({ seats: seatCount(), n: document.querySelectorAll('#oRoleList .orole').length }));
  t(r.n === 4 && r.seats === 11, 'با حذفِ یک ردیف، جمع هم کم می‌شود', r.n + ' ردیف، ' + r.seats + ' نفر');
  /* برگردانش */
  await p.evaluate(() => {
    document.getElementById('oRoleAdd').click();
    const row = document.querySelector('#oRoleList .orole:last-child');
    row.querySelector('select').value = 'it';
    row.querySelector('select').dispatchEvent(new Event('change', { bubbles: true }));
    const c = row.querySelector('.cnt input'); c.value = '4';
    c.dispatchEvent(new Event('input', { bubbles: true }));
  });
  await p.waitForTimeout(500);
  t(await p.evaluate(() => seatCount()) === 15, 'و با افزودنش دوباره ۱۵');
}

/* ---------------- سندِ اصلی: سرور ----------------
   عددِ مرورگر عمداً دروغ فرستاده می‌شود. اگر سرور به آن اعتماد کند،
   هر کسی می‌تواند سفارشِ پانزده‌نفره را به قیمتِ یک نفر ثبت کند. */
console.log('— سرور از روی ردیف‌ها حساب می‌کند، نه از حرفِ مرورگر —');
{
  const r = await fetch(BASE + '/api/sl/order', {
    method: 'POST', headers: { 'Content-Type': 'application/json', Host: 'sltech.ir' },
    body: JSON.stringify({
      plan: 'آزمونِ سازمانی', name: 'سازمانِ آزمون', nonce: 'orgtest-nonce',
      orgName: 'شرکتِ نمونه',
      seats: '1',                       /* دروغ */
      lines: WANT.map(([job, count]) => ({ job, count }))
    })
  });
  const d = await r.json().catch(() => ({}));
  if (d.id) made.push(d.id);
  t(d.ok === true, 'سفارش ثبت شد', d.error || d.id);
  t(d.price === 21000000, 'و سرور همان ۲۱ میلیون را حساب کرد، نه قیمتِ یک نفر',
    (d.price || 0).toLocaleString());

  if (DB) {
    const db = new DatabaseSync(DB);
    const row = db.prepare('SELECT seats, tier, lines FROM sl_orders WHERE id=?').get(d.id || '');
    t(row && row.seats === 15, 'و تعدادِ نفرات را از جمعِ ردیف‌ها گرفت، نه از «۱»',
      row ? String(row.seats) : 'ردیفی نیست');
    const ls = row ? JSON.parse(row.lines || '[]') : [];
    t(ls.length === 5, 'و هر پنج ردیف ذخیره شدند', ls.map(x => x.job + '×' + x.count).join('، '));
    t(ls.every(x => x.kind), 'با قالبِ کارتابلِ هر شغل — تا معلوم باشد چه چیزی باید ساخته شود',
      ls.map(x => x.kind).join(' '));
  }
}

console.log('— شغلِ ناشناخته و ردیفِ تکراری —');
{
  const r = await fetch(BASE + '/api/sl/order', {
    method: 'POST', headers: { 'Content-Type': 'application/json', Host: 'sltech.ir' },
    body: JSON.stringify({
      plan: 'آزمونِ سازمانی', name: 'آزمون', nonce: 'orgtest-nonce',
      lines: [{ job: 'acc', count: 4 }, { job: 'acc', count: 3 },
              { job: 'نیست-که', count: 90 }]
    })
  });
  const d = await r.json().catch(() => ({}));
  if (d.id) made.push(d.id);
  if (DB && d.ok) {
    const db = new DatabaseSync(DB);
    const row = db.prepare('SELECT seats, lines FROM sl_orders WHERE id=?').get(d.id);
    const ls = JSON.parse(row.lines || '[]');
    t(ls.length === 1 && ls[0].job === 'acc' && ls[0].count === 7,
      'شغلِ تکراری یکی می‌شود و تعدادش جمع', ls.map(x => x.job + '×' + x.count).join('، '));
    t(row.seats === 7, 'و شغلِ ناشناخته اصلاً شمرده نمی‌شود', String(row.seats));
  } else {
    t(false, 'سفارشِ دوم ثبت نشد', d.error || '');
  }
}

t(errs.length === 0, 'هیچ خطای صفحه‌ای نبود', errs.join(' | ') || 'پاک');

await b.close();
/* ---------- جمع کردنِ آنچه ساختیم ----------
   آزمونی که اثرش را روی دیتابیس جا بگذارد، آزمونِ بعدی را می‌شکند —
   و آن‌وقت به نظر می‌رسد ایراد از کدِ دیگری است. همین یک بار افتاد:
   پیام‌های همین سفارش‌ها شمارندهٔ نخواندهٔ bellgo را از ۲ به ۵ برد. */
if (DB) {
  const db = new DatabaseSync(DB);
  if (saved !== null) db.prepare('UPDATE settings SET v=? WHERE k=?').run(saved, 'sltechSite');
  for (const id of made) {
    try { db.prepare('DELETE FROM sl_orders WHERE id=?').run(id); } catch (e) {}
  }
  try { db.prepare('DELETE FROM support_msgs WHERE rowid > ?').run(msgMark); } catch (e) {}
  try { db.prepare("DELETE FROM bot_logins WHERE nonce='orgtest-nonce'").run(); } catch (e) {}
}
console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
