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

  /* ---------- ۱ بررسی توکن ---------- */
  step(1, 'بررسی توکن');
  if (!process.env.CLOUDFLARE_API_TOKEN)
    die('CLOUDFLARE_API_TOKEN تنظیم نشده است. راهنمای-توکن-کلادفلر.md را بخوانید.');
  if (!process.env.CLOUDFLARE_ACCOUNT_ID)
    warn('CLOUDFLARE_ACCOUNT_ID تنظیم نشده — اگر حسابتان بیش از یک اکانت دارد، خطا می‌گیرید.');

  const who = shq(`${WR} whoami`);
  if (/Unable to authenticate|Authentication error|10000/i.test(who))
    die('توکن پذیرفته نشد. دسترسی‌های توکن را با راهنما مطابقت دهید.');
  ok('توکن سالم است');

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
  step(3, 'جدول‌های دیتابیس');
  const q = shq(`${WR} d1 execute sensa-db --remote --json ` +
    `--command "SELECT name FROM sqlite_master WHERE type='table' AND name='products'"`);
  const res = parseJSON(q, '[');
  const hasTables = !!(res && res[0] && res[0].results && res[0].results.length);

  if (hasTables && process.env.RESET_DB !== 'yes') {
    ok('جدول‌ها از قبل هستند — دست نخوردند');
  } else {
    if (hasTables) warn('RESET_DB=yes — همهٔ داده‌ها پاک می‌شود!');
    const out = shq(`${WR} d1 execute sensa-db --remote --file=./schema.sql -y`);
    if (/error/i.test(out) && !/already exists/i.test(out)) {
      err('ساخت جدول‌ها انجام نشد:'); say(out.slice(-900)); process.exit(1);
    }
    ok('جدول‌ها ساخته شدند');
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

  /* ---------- ۷ دادهٔ اولیه ---------- */
  step(6, 'محصولات و مقالات اولیه');
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
