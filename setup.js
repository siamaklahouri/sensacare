#!/usr/bin/env node
/* ==========================================================
   سِنسا — راه‌انداز خودکار
   اجرا:  npm run setup
   ========================================================== */
const { execSync, spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const readline = require('readline');
const crypto = require('crypto');

const R = '\x1b[0m', B = '\x1b[1m', G = '\x1b[32m', Y = '\x1b[33m',
      C = '\x1b[36m', RED = '\x1b[31m', DIM = '\x1b[2m';

const say = m => console.log(m);
const step = (n, t) => say(`\n${C}${B}[${n}]${R} ${B}${t}${R}`);
const ok = m => say(`  ${G}✓${R} ${m}`);
const warn = m => say(`  ${Y}!${R} ${m}`);
const err = m => say(`  ${RED}✗${R} ${m}`);
const info = m => say(`  ${DIM}${m}${R}`);

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const ask = q => new Promise(res => rl.question(q, a => res(a.trim())));

const sh = (cmd, opts = {}) =>
  execSync(cmd, { encoding: 'utf8', stdio: opts.quiet ? 'pipe' : 'inherit', ...opts });
const shq = cmd => { try { return execSync(cmd, { encoding: 'utf8', stdio: 'pipe' }); }
                     catch (e) { return (e.stdout || '') + (e.stderr || ''); } };

const WR = process.platform === 'win32' ? 'npx.cmd wrangler' : 'npx wrangler';

async function main() {
  say(`
${B}╭──────────────────────────────────────────╮
│   سِنسا — راه‌انداز خودکار کلادفلر        │
╰──────────────────────────────────────────╯${R}`);
  say(`${DIM}این اسکریپت همهٔ مراحل را خودش انجام می‌دهد.
هر جا لازم باشد از شما می‌پرسد.${R}`);

  /* ---------- ۱ بررسی Node ---------- */
  step(1, 'بررسی Node.js');
  const v = process.versions.node.split('.')[0];
  if (Number(v) < 18) {
    err(`نسخهٔ Node شما ${process.versions.node} است. باید ۱۸ یا بالاتر باشد.`);
    info('از nodejs.org نسخهٔ LTS را نصب کنید و دوباره اجرا کنید.');
    process.exit(1);
  }
  ok(`Node ${process.versions.node}`);

  /* ---------- ۲ نصب وابستگی‌ها ---------- */
  step(2, 'نصب ابزارها');
  if (!fs.existsSync('node_modules')) {
    info('چند دقیقه طول می‌کشد…');
    try { sh('npm install'); ok('نصب شد'); }
    catch { err('نصب انجام نشد. اینترنت را بررسی کنید (شاید نیاز به فیلترشکن باشد).'); process.exit(1); }
  } else ok('از قبل نصب شده');

  /* ---------- ۳ ورود به کلادفلر ---------- */
  step(3, 'ورود به حساب کلادفلر');
  let who = shq(`${WR} whoami`);
  if (!/You are logged in|associated with the email/i.test(who)) {
    warn('وارد نشده‌اید. الان مرورگر باز می‌شود — دکمهٔ Allow را بزنید.');
    info('اگر مرورگر باز نشد یا صفحه بالا نیامد، فیلترشکن را روشن کنید.');
    await ask('  آماده‌اید؟ Enter بزنید… ');
    try { sh(`${WR} login`); } catch {}
    who = shq(`${WR} whoami`);
    if (!/You are logged in|associated with the email/i.test(who)) {
      err('ورود انجام نشد. دوباره امتحان کنید.'); process.exit(1);
    }
  }
  const email = (who.match(/[\w.+-]+@[\w-]+\.[\w.]+/) || ['—'])[0];
  ok(`وارد شدید: ${email}`);

  /* ---------- ۴ ساخت دیتابیس ---------- */
  step(4, 'ساخت دیتابیس D1');
  let toml = fs.readFileSync('wrangler.toml', 'utf8');
  const hasId = /database_id\s*=\s*"([0-9a-f-]{30,})"/.exec(toml);

  if (hasId) {
    ok(`دیتابیس از قبل تنظیم شده (${hasId[1].slice(0, 8)}…)`);
  } else {
    const list = shq(`${WR} d1 list --json`);
    let id = null;
    try {
      const arr = JSON.parse(list.slice(list.indexOf('[')));
      const found = arr.find(d => d.name === 'sensa-db');
      if (found) { id = found.uuid || found.database_id; ok('دیتابیس sensa-db از قبل وجود داشت'); }
    } catch {}

    if (!id) {
      info('در حال ساخت…');
      const out = shq(`${WR} d1 create sensa-db`);
      const mm = out.match(/database_id\s*=\s*"([0-9a-f-]{30,})"/) ||
                 out.match(/"uuid":\s*"([0-9a-f-]{30,})"/);
      if (!mm) { err('ساخت دیتابیس انجام نشد:'); say(out); process.exit(1); }
      id = mm[1]; ok('دیتابیس ساخته شد');
    }
    toml = toml.replace(/database_id\s*=\s*".*?"/, `database_id = "${id}"`);
    fs.writeFileSync('wrangler.toml', toml);
    ok('شناسهٔ دیتابیس در wrangler.toml ذخیره شد');
  }

  /* ---------- ۵ ساخت جدول‌ها ---------- */
  step(5, 'ساخت جدول‌های دیتابیس');
  const marker = '.setup-tables-done';
  if (fs.existsSync(marker)) {
    ok('از قبل ساخته شده');
  } else {
    const out = shq(`${WR} d1 execute sensa-db --remote --file=./schema.sql -y`);
    if (/error|Error/.test(out) && !/already exists/i.test(out)) {
      err('ساخت جدول‌ها انجام نشد:'); say(out.slice(0, 900)); process.exit(1);
    }
    fs.writeFileSync(marker, String(Date.now()));
    ok('جدول‌ها ساخته شدند');
  }

  /* ---------- ۶ رمزها ---------- */
  step(6, 'تنظیم رمزها');
  const secrets = shq(`${WR} secret list`);
  const has = k => secrets.includes(`"${k}"`) || secrets.includes(k);

  if (has('JWT_SECRET')) {
    ok('JWT_SECRET از قبل تنظیم شده');
  } else {
    const jwt = crypto.randomBytes(32).toString('hex');
    const r = spawnSync(WR.split(' ')[0], [...WR.split(' ').slice(1), 'secret', 'put', 'JWT_SECRET'],
      { input: jwt + '\n', encoding: 'utf8' });
    if (r.status === 0) ok('JWT_SECRET خودکار ساخته و ذخیره شد');
    else { err('ذخیره نشد'); say(r.stderr || ''); }
  }

  if (has('ADMIN_PASS')) {
    ok('رمز مدیر از قبل تنظیم شده');
    info('برای تغییر: npx wrangler secret put ADMIN_PASS');
  } else {
    say('');
    warn('یک رمز برای پنل مدیریت انتخاب کنید (حداقل ۸ کاراکتر).');
    let pass = '';
    while (pass.length < 8) {
      pass = await ask('  رمز مدیر: ');
      if (pass.length < 8) err('خیلی کوتاه است.');
    }
    const r = spawnSync(WR.split(' ')[0], [...WR.split(' ').slice(1), 'secret', 'put', 'ADMIN_PASS'],
      { input: pass + '\n', encoding: 'utf8' });
    if (r.status === 0) ok('رمز مدیر ذخیره شد');
    else { err('ذخیره نشد'); say(r.stderr || ''); }
  }

  const user = await ask('  نام کاربری مدیر (Enter = admin): ') || 'admin';
  toml = fs.readFileSync('wrangler.toml', 'utf8');
  toml = toml.replace(/ADMIN_USER\s*=\s*".*?"/, `ADMIN_USER = "${user}"`);
  fs.writeFileSync('wrangler.toml', toml);
  ok(`نام کاربری: ${user}`);

  /* ---------- ۷ پیامک ---------- */
  step(7, 'سرویس پیامک (اختیاری)');
  if (has('SMS_API_KEY')) {
    ok('از قبل تنظیم شده');
  } else {
    const want = (await ask('  الان تنظیمش کنیم؟ (y = بله / Enter = بعداً): ')).toLowerCase();
    if (want === 'y') {
      const prov = await ask('  سرویس (kavenegar / smsir): ');
      const key = await ask('  کلید API: ');
      const tpl = await ask('  نام یا شمارهٔ الگو: ');
      for (const [k, val] of [['SMS_PROVIDER', prov], ['SMS_API_KEY', key], ['SMS_TEMPLATE', tpl]]) {
        spawnSync(WR.split(' ')[0], [...WR.split(' ').slice(1), 'secret', 'put', k],
          { input: val + '\n', encoding: 'utf8' });
      }
      ok('تنظیم شد');
    } else {
      info('فعلاً کد تأیید داخل صفحه نشان داده می‌شود. هر وقت خواستید:');
      info('npm run sms');
    }
  }

  /* ---------- ۸ استقرار ---------- */
  step(8, 'بالا آوردن سایت');
  let deployOut = '';
  try { deployOut = sh(`${WR} deploy`, { quiet: true }); }
  catch (e) { deployOut = (e.stdout || '') + (e.stderr || ''); }
  const urlM = deployOut.match(/https:\/\/[^\s]+\.workers\.dev/);
  if (!urlM) { err('استقرار انجام نشد:'); say(deployOut.slice(-1200)); process.exit(1); }
  const url = urlM[0];
  ok('سایت بالا آمد');

  /* ---------- ۹ آماده‌سازی داده ---------- */
  step(9, 'ساخت محصولات و مقالات اولیه');
  try {
    const r = await fetch(url + '/api/bootstrap');
    const d = await r.json();
    ok(`${d.products.length} محصول، ${d.articles.length} مقاله، ${d.categories.length} دسته`);
  } catch { warn('بعداً با اولین بازدید ساخته می‌شود.'); }

  /* ---------- ۱۰ دامنه ---------- */
  step(10, 'دامنه');
  const dom = await ask('  دامنه‌تان (مثلاً sensacare.ir) یا Enter برای رد شدن: ');
  if (dom) {
    const zones = shq(`${WR} zones list 2>&1`);
    say('');
    info('اتصال دامنه از خط فرمان ممکن نیست و باید از پنل انجام شود:');
    say(`  ${B}۱.${R} dash.cloudflare.com → Workers & Pages → sensa`);
    say(`  ${B}۲.${R} Settings → Domains & Routes → Add → Custom domain`);
    say(`  ${B}۳.${R} بنویسید: ${C}${dom}${R}`);
    info('اگر نیم‌سرورها هنوز تأیید نشده‌اند، اول باید کلادفلر دامنه را فعال کند.');
  }

  /* ---------- پایان ---------- */
  say(`
${G}${B}╭──────────────────────────────────────────╮
│              کار تمام شد                 │
╰──────────────────────────────────────────╯${R}

  ${B}آدرس سایت:${R}  ${C}${url}${R}
  ${B}پنل مدیریت:${R}  پایین صفحه → «ورود مدیر»
  ${B}نام کاربری:${R}  ${user}

  ${Y}توجه:${R} آدرس workers.dev از ایران باز نمی‌شود.
  برای تست فیلترشکن روشن کنید. بعد از وصل کردن دامنه
  این مشکل حل می‌شود.

  ${DIM}دستورهای بعدی:
    npm run update   به‌روزرسانی سایت بعد از تغییر
    npm run sms      تنظیم سرویس پیامک
    npm run backup   گرفتن پشتیبان کامل${R}
`);
  rl.close();
}

main().catch(e => { err(e.message); rl.close(); process.exit(1); });
