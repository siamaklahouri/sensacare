#!/usr/bin/env node
/* ==========================================================
   سِنسا — استقرار خودکار روی Cloudflare Workers با «توکن»
   بدون هیچ سؤال و بدون باز شدن مرورگر.

   اجرا:  npm run deploy

   متغیرهای لازم:
     CLOUDFLARE_API_TOKEN   توکن کلادفلر
     CLOUDFLARE_ACCOUNT_ID  شناسهٔ حساب کلادفلر

   متغیرهای اختیاری:
     ADMIN_PASS             رمز پنل مدیریت (اگر ندهید، خودش می‌سازد)
     ADMIN_USER             نام کاربری مدیر (پیش‌فرض admin)
     JWT_SECRET             کلید امضای توکن (اگر ندهید، خودش می‌سازد)
     SMS_PROVIDER / SMS_API_KEY / SMS_TEMPLATE
     TELEGRAM_BOT_TOKEN / BALE_BOT_TOKEN / BOT_SECRET
     D1_DATABASE_ID         اگر دیتابیس را از قبل ساخته‌اید
     RESET_DB=yes           جدول‌ها را پاک و از نو می‌سازد (خطرناک)
   ========================================================== */
const { execSync, spawnSync } = require('child_process');
const fs = require('fs');
const crypto = require('crypto');

const R = '\x1b[0m', B = '\x1b[1m', G = '\x1b[32m', Y = '\x1b[33m',
      C = '\x1b[36m', RED = '\x1b[31m', DIM = '\x1b[2m';
const say  = m => console.log(m);
const step = (n, t) => say(`\n${C}${B}[${n}]${R} ${B}${t}${R}`);
const ok   = m => say(`  ${G}✓${R} ${m}`);
const warn = m => say(`  ${Y}!${R} ${m}`);
const err  = m => say(`  ${RED}✗${R} ${m}`);
const info = m => say(`  ${DIM}${m}${R}`);
const die  = m => { err(m); process.exit(1); };

const WR = process.platform === 'win32' ? 'npx.cmd wrangler' : 'npx wrangler';
const WR_BIN = WR.split(' ')[0];
const WR_ARGS = WR.split(' ').slice(1);

const shq = cmd => {
  try { return execSync(cmd, { encoding: 'utf8', stdio: 'pipe' }); }
  catch (e) { return (e.stdout || '') + (e.stderr || ''); }
};
const sh = cmd => execSync(cmd, { encoding: 'utf8', stdio: 'pipe' });

/* wrangler گاهی JSON را با چند خط توضیح قاطی می‌کند */
const parseJSON = (text, open) => {
  const i = text.indexOf(open);
  if (i < 0) return null;
  try { return JSON.parse(text.slice(i)); } catch { return null; }
};

const putSecret = (name, value) => {
  const r = spawnSync(WR_BIN, [...WR_ARGS, 'secret', 'put', name],
    { input: String(value) + '\n', encoding: 'utf8' });
  return r.status === 0;
};

async function main() {
  say(`
${B}╭──────────────────────────────────────────╮
│   سِنسا — استقرار با توکن کلادفلر        │
╰──────────────────────────────────────────╯${R}`);

  /* ---------- ۰ نسخهٔ Node ---------- */
  const major = Number(process.versions.node.split('.')[0]);
  if (major < 22)
    die(`wrangler به Node نسخهٔ ۲۲ یا بالاتر نیاز دارد. شما ${process.versions.node} دارید.`);

  /* ---------- ۱ بررسی توکن ---------- */
  step(1, 'بررسی توکن');
  const TOKEN = process.env.CLOUDFLARE_API_TOKEN;
  if (!TOKEN)
    die('CLOUDFLARE_API_TOKEN تنظیم نشده است. راهنمای-توکن-کلادفلر.md را بخوانید.');

  const CF = 'https://api.cloudflare.com/client/v4';
  const cf = async path => {
    const r = await fetch(CF + path, { headers: { Authorization: 'Bearer ' + TOKEN } });
    return await r.json().catch(() => ({ success: false, errors: [{ message: 'پاسخ نامفهوم از کلادفلر' }] }));
  };
  const cfErrors = d => (d.errors || []).map(e => `${e.message} [code: ${e.code}]`).join(' / ') || 'دلیل نامشخص';

  const v = await cf('/user/tokens/verify');
  if (!v.success) {
    err('توکن پذیرفته نشد: ' + cfErrors(v));
    info('اگر code برابر 1000 / 6003 / 6111 است: توکن ناقص یا غلط کپی شده — دوباره کپی کنید.');
    info('اگر code برابر 9109 است: توکن منقضی یا غیرفعال است — یکی جدید بسازید.');
    process.exit(1);
  }
  ok('توکن سالم است' + (v.result && v.result.status ? ` (${v.result.status})` : ''));

  /* شناسهٔ حساب — اگر ندادند، خودمان پیدا می‌کنیم */
  if (!process.env.CLOUDFLARE_ACCOUNT_ID) {
    const a = await cf('/accounts');
    const list = (a.success && a.result) || [];
    if (list.length === 1) {
      process.env.CLOUDFLARE_ACCOUNT_ID = list[0].id;
      ok(`شناسهٔ حساب خودکار پیدا شد: ${list[0].name}`);
    } else if (list.length > 1) {
      err('حساب شما بیش از یک اکانت دارد. CLOUDFLARE_ACCOUNT_ID را دستی بگذارید:');
      list.forEach(x => info(`${x.name} → ${x.id}`));
      process.exit(1);
    } else {
      warn('شناسهٔ حساب پیدا نشد. اگر خطا گرفتید، CLOUDFLARE_ACCOUNT_ID را دستی بگذارید.');
      info('دسترسی لازم برای پیدا کردن خودکار: Account Settings → Read');
    }
  }

  /* دسترسی D1 را همین‌جا چک کنیم تا وسط کار غافلگیر نشویم */
  const acct = process.env.CLOUDFLARE_ACCOUNT_ID;
  if (acct) {
    const d1 = await cf(`/accounts/${acct}/d1/database?per_page=1`);
    if (!d1.success) {
      err('توکن به D1 دسترسی ندارد: ' + cfErrors(d1));
      info('در صفحهٔ توکن، این ردیف را اضافه کنید:  Account → D1 → Edit');
      info('راهنمای-توکن-کلادفلر.md ← قدم ۴');
      process.exit(1);
    }
    ok('دسترسی D1 تأیید شد');
  }

  /* ---------- ۲ دیتابیس D1 ---------- */
  step(2, 'دیتابیس D1');
  let toml = fs.readFileSync('wrangler.toml', 'utf8');
  let id = process.env.D1_DATABASE_ID ||
           (/database_id\s*=\s*"([0-9a-f-]{30,})"/.exec(toml) || [])[1] || null;

  if (id) {
    ok(`از قبل تنظیم شده (${id.slice(0, 8)}…)`);
  } else {
    const arr = parseJSON(shq(`${WR} d1 list --json`), '[');
    const found = Array.isArray(arr) ? arr.find(d => d.name === 'sensa-db') : null;
    if (found) { id = found.uuid || found.database_id; ok('دیتابیس sensa-db از قبل وجود داشت'); }
  }
  if (!id) {
    info('در حال ساخت sensa-db …');
    const out = shq(`${WR} d1 create sensa-db`);
    const mm = out.match(/database_id\s*=\s*"([0-9a-f-]{30,})"/) ||
               out.match(/"uuid":\s*"([0-9a-f-]{30,})"/);
    if (!mm) { err('ساخت دیتابیس انجام نشد:'); say(out.slice(-900)); process.exit(1); }
    id = mm[1];
    ok('دیتابیس ساخته شد');
  }
  if (!new RegExp(`database_id\\s*=\\s*"${id}"`).test(toml)) {
    toml = toml.replace(/database_id\s*=\s*".*?"/, `database_id = "${id}"`);
    fs.writeFileSync('wrangler.toml', toml);
    ok('شناسهٔ دیتابیس در wrangler.toml نوشته شد');
  }

  /* ---------- ۳ نام کاربری مدیر ---------- */
  if (process.env.ADMIN_USER) {
    toml = fs.readFileSync('wrangler.toml', 'utf8')
      .replace(/ADMIN_USER\s*=\s*".*?"/, `ADMIN_USER = "${process.env.ADMIN_USER}"`);
    fs.writeFileSync('wrangler.toml', toml);
  }

  /* ---------- ۴ جدول‌ها ---------- */
  /* schema.sql با DROP TABLE شروع می‌شود، پس اجرایش داده‌ها را پاک می‌کند.
     فقط وقتی اجرایش می‌کنیم که *مطمئن* باشیم دیتابیس خالی است. اگر نتوانستیم
     مطمئن شویم، هیچ کاری نمی‌کنیم و با خطا می‌ایستیم — سکوت اینجا یعنی
     احتمال پاک شدن کل فروشگاه. */
  step(3, 'جدول‌های دیتابیس');
  const probe = shq(`${WR} d1 execute sensa-db --remote --json ` +
    `--command "SELECT name FROM sqlite_master WHERE type='table' AND name='products'"`);
  const res = parseJSON(probe, '[');
  if (!res || !res[0] || !Array.isArray(res[0].results)) {
    err('نتوانستم بفهمم جدول‌ها هستند یا نه. برای امنیت داده‌ها همین‌جا ایستادم.');
    info('پاسخ کلادفلر:'); say(probe.slice(-700));
    process.exit(1);
  }
  const hasTables = res[0].results.length > 0;

  if (hasTables && process.env.RESET_DB !== 'yes') {
    ok('جدول‌ها از قبل هستند — دست نخوردند');
  } else {
    if (hasTables) warn('RESET_DB=yes — همهٔ داده‌ها پاک می‌شود!');
    const out = shq(`${WR} d1 execute sensa-db --remote --json --file=./schema.sql -y`);
    const done = parseJSON(out, '[');
    if (!done) {
      err('ساخت جدول‌ها انجام نشد:'); say(out.slice(-900)); process.exit(1);
    }
    ok('جدول‌ها ساخته شدند');
  }

  /* ---------- مهاجرت‌ها ---------- */
  /* migrations.sql فقط CREATE ... IF NOT EXISTS دارد، پس اجرای دوباره‌اش
     بی‌خطر است و به داده‌های موجود دست نمی‌زند. */
  if (fs.existsSync('migrations.sql')) {
    const mout = shq(`${WR} d1 execute sensa-db --remote --json --file=./migrations.sql -y`);
    if (parseJSON(mout, '[')) ok('مهاجرت‌ها اعمال شد');
    else { err('اجرای مهاجرت‌ها انجام نشد:'); say(mout.slice(-700)); process.exit(1); }
  }

  /* ---------- ۵ استقرار ---------- */
  step(4, 'بالا آوردن سایت');
  let deployOut = '';
  try { deployOut = sh(`${WR} deploy`); }
  catch (e) { deployOut = (e.stdout || '') + (e.stderr || ''); }
  const urlM = deployOut.match(/https:\/\/[^\s]+\.workers\.dev/);
  if (!urlM) { err('استقرار انجام نشد:'); say(deployOut.slice(-1500)); process.exit(1); }
  const url = urlM[0];
  ok('سایت بالا آمد: ' + url);

  /* ---------- ۶ رمزها ---------- */
  step(5, 'رمزها و کلیدها');
  const list = shq(`${WR} secret list`);
  const has = k => new RegExp(`"${k}"`).test(list);
  let shownPass = null;

  if (process.env.JWT_SECRET) {
    putSecret('JWT_SECRET', process.env.JWT_SECRET) ? ok('JWT_SECRET ذخیره شد') : err('JWT_SECRET ذخیره نشد');
  } else if (has('JWT_SECRET')) {
    ok('JWT_SECRET از قبل هست');
  } else {
    putSecret('JWT_SECRET', crypto.randomBytes(32).toString('hex'))
      ? ok('JWT_SECRET خودکار ساخته شد') : err('JWT_SECRET ذخیره نشد');
  }

  if (process.env.ADMIN_PASS) {
    if (process.env.ADMIN_PASS.length < 8) die('ADMIN_PASS باید حداقل ۸ کاراکتر باشد.');
    putSecret('ADMIN_PASS', process.env.ADMIN_PASS) ? ok('رمز مدیر ذخیره شد') : err('رمز مدیر ذخیره نشد');
  } else if (has('ADMIN_PASS')) {
    ok('رمز مدیر از قبل هست');
  } else {
    shownPass = crypto.randomBytes(6).toString('base64url');
    putSecret('ADMIN_PASS', shownPass) ? ok('رمز مدیر خودکار ساخته شد') : err('رمز مدیر ذخیره نشد');
  }

  for (const k of ['SMS_PROVIDER', 'SMS_API_KEY', 'SMS_TEMPLATE',
                   'TELEGRAM_BOT_TOKEN', 'BALE_BOT_TOKEN', 'BOT_SECRET',
                   'TELEGRAM_CHAT_ID', 'BALE_CHAT_ID']) {
    if (process.env[k]) putSecret(k, process.env[k]) ? ok(k) : err(k + ' ذخیره نشد');
  }

  /* ---------- ربات‌ها: راز وب‌هوک و ثبت خودکار ---------- */
  const botTokens = { telegram: process.env.TELEGRAM_BOT_TOKEN, bale: process.env.BALE_BOT_TOKEN };
  if (botTokens.telegram || botTokens.bale) {
    step(6, 'ربات تلگرام و بله');
    const host = (process.env.PUBLIC_HOST || 'sensacare.ir').replace(/^https?:\/\//, '').replace(/\/$/, '');
    const secret = process.env.BOT_SECRET || crypto.randomBytes(12).toString('hex');
    putSecret('BOT_SECRET', secret) ? ok('راز وب‌هوک ذخیره شد') : err('راز وب‌هوک ذخیره نشد');

    const bases = { telegram: 'https://api.telegram.org', bale: 'https://tapi.bale.ai' };
    for (const [pf, token] of Object.entries(botTokens)) {
      if (!token) continue;
      const hook = `https://${host}/api/bot/${pf}?s=${secret}`;
      try {
        const r = await fetch(`${bases[pf]}/bot${token}/setWebhook`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ url: hook })
        });
        const d = await r.json().catch(() => ({}));
        d.ok ? ok(`وب‌هوک ${pf} ثبت شد`)
             : warn(`وب‌هوک ${pf} ثبت نشد: ${d.description || r.status}`);
      } catch (e) { warn(`وب‌هوک ${pf}: ${e.message}`); }
    }
  }

  /* ---------- ۷ دادهٔ اولیه ---------- */
  step(7, 'محصولات و مقالات اولیه');
  try {
    const r = await fetch(url + '/api/bootstrap');
    const d = await r.json();
    ok(`${d.products.length} محصول، ${d.articles.length} مقاله، ${d.categories.length} دسته`);
  } catch { warn('با اولین بازدید ساخته می‌شود.'); }

  /* ---------- پایان ---------- */
  say(`
${G}${B}╭──────────────────────────────────────────╮
│              کار تمام شد                 │
╰──────────────────────────────────────────╯${R}

  ${B}آدرس سایت:${R}   ${C}${url}${R}
  ${B}نام کاربری:${R}  ${process.env.ADMIN_USER || 'admin'}`);
  if (shownPass) say(`  ${B}رمز مدیر:${R}    ${C}${shownPass}${R}   ${Y}(یادداشتش کنید!)${R}`);
  say(`
  ${Y}توجه:${R} آدرس workers.dev از ایران باز نمی‌شود؛ برای تست فیلترشکن
  لازم است. بعد از وصل کردن دامنه، این مشکل تمام می‌شود.
`);
}

main().catch(e => { err(e.message); process.exit(1); });
