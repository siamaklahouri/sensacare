/* راه‌اندازیِ دوبارهٔ تلگرام — و اینکه از کدام راه می‌رود.

   تلگرام یک بار برداشته شد و حالا باید برگردد. برگرداندنش دو تکه
   دارد که هر دو بی‌صدا شکست می‌خورند:

   ۱) خانهٔ توکن باید پر شود. این را نمی‌شود در مخزن نوشت، پس از خطِ
      فرمان است: «--bot-on tg <توکن> <گفتگو>». و باید جلوی دو اشتباهِ
      رایج را بگیرد — شناسهٔ گفتگوی غیرعددی («chat not found»ِ بی‌صدا)
      و توکنی که شکلِ توکن نیست.

   ۲) راهِ خروج. از این سرور api.telegram.org باز نمی‌شود و باید از
      رله رد شود. اینجا یک سوراخِ واقعی بود: __TGBASE فقط داخلِ
      worker.fetch و worker.scheduled ست می‌شد، پس هر دستورِ خط‌فرمانی
      که پیش از اولین درخواست اجرا می‌شود — یعنی دقیقاً «کانال را
      بسنج» — مستقیم می‌رفت. ابزارِ سنجش از راهی می‌رفت که پشتیبان از
      آن نمی‌رود.

   این آزمون یک تلگرامِ قلابی روی لوکال بالا می‌آورد و می‌بیند
   درخواست واقعاً به آن رسید یا نه. اگر روزی __TGBASE دوباره از اولِ
   پروسه برداشته شود، درخواست به سرورِ قلابی نمی‌رسد و همین‌جا قرمز
   می‌شود — نه روی سرورِ کاربر، شبِ پشتیبان. */
import { createServer } from 'node:http';
import { spawn } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync, readFileSync } from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const TOKEN = '123456789:AAFakeTokenForTestsOnly_abcdefghij';
const CHAT = '-1001234567890';

/* ---------- تلگرامِ قلابی ----------
   هرچه رسید را نگه می‌دارد و جوابش را از صف می‌دهد. */
const hits = [];
let reply = { ok: true, result: {} };
const fake = createServer((req, res) => {
  let body = '';
  req.on('data', c => body += c);
  req.on('end', () => {
    hits.push({ url: req.url, body: (() => { try { return JSON.parse(body); } catch { return body; } })() });
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(reply));
  });
});
await new Promise(r => fake.listen(0, '127.0.0.1', r));
const RELAY = 'http://127.0.0.1:' + fake.address().port + '/tg/secret';

/* ---------- محیطِ خودش ----------
   دیتابیسِ جدا، تا هیچ آزمونِ دیگری را تکان ندهد. */
const dir = mkdtempSync(join(tmpdir(), 'bottg-'));
const envFile = join(dir, 'env');
writeFileSync(envFile, [
  'PORT=0', 'BIND=127.0.0.1', 'DB_FILE=' + join(dir, 't.db'),
  'ADMIN_USER=admin', 'ADMIN_PASS=adminadminadmin',
  'JWT_SECRET=testsecrettestsecrettestsecret12',
  'PANEL_HOST=sltech.ir', 'SHOP_HOST=sensacare.ir', 'PUSH_OFF=1',
  'CRON_UTC=-', 'TG_BASE=' + RELAY
].join('\n') + '\n');

/* جدول‌ها را خودمان می‌سازیم: دستورهای خط‌فرمان پیش از بالا آمدنِ
   سرور اجرا می‌شوند، پس روی دیتابیسِ خالی «no such table» می‌دهند. */
{
  const db = new DatabaseSync(join(dir, 't.db'));
  const root = new URL('../', import.meta.url).pathname;
  for (const f of ['schema.sql', 'migrations.sql'])
    db.exec(readFileSync(root + f, 'utf8'));
  db.close();
}

const idx = new URL('./index.js', import.meta.url).pathname;
/* محیط را از صفر می‌چینیم، نه با «...process.env».
   این یک بار قرمز شد و درسش این بود: cfg در server/index.js از
   «{...فایلِ env, ...process.env}» ساخته می‌شود، یعنی process.env
   برنده است. و اجراکنندهٔ آزمون‌ها DB_FILE را در محیط دارد — پس این
   آزمون توکن را در دیتابیسِ مشترکِ مجموعه می‌نوشت و خودش هم همان‌جا
   دو کانال می‌دید. تنها راهِ مطمئن این است که فایلِ env حرفِ آخر را
   بزند، پس چیزی که با آن می‌جنگد به پروسه نمی‌رسد. */
function cli(args, stdin) {
  return new Promise(res => {
    const p = spawn(process.execPath, [idx, ...args],
      { env: { PATH: process.env.PATH, HOME: process.env.HOME,
               NODE_OPTIONS: process.env.NODE_OPTIONS || '',
               SLTECH_ENV: envFile } });
    let out = '';
    p.stdout.on('data', d => out += d);
    p.stderr.on('data', d => out += d);
    if (stdin !== undefined) p.stdin.end(stdin);
    p.on('close', code => res({ code, out }));
  });
}

/* ================= روشن کردن ================= */
console.log('===== روشن کردنِ تلگرام =====');
{
  const r = await cli(['--bot-on', 'tg', TOKEN, 'sltech_group']);
  t(r.code === 2, 'شناسهٔ گفتگوی غیرعددی رد می‌شود', 'کدِ خروج ' + r.code);
  t(/عدد/.test(r.out), 'و می‌گوید چرا');
}
{
  const r = await cli(['--bot-on', 'tg', 'not-a-token', CHAT]);
  t(r.code === 2, 'توکنِ بی‌شکل رد می‌شود', 'کدِ خروج ' + r.code);
}
{
  const r = await cli(['--bot-on', 'tg', TOKEN, CHAT]);
  t(r.code === 0, 'توکنِ درست پذیرفته می‌شود', 'کدِ خروج ' + r.code);
  t(!r.out.includes(TOKEN), 'و توکن در خروجی چاپ نمی‌شود');
  t(r.out.includes(TOKEN.slice(-4)), 'فقط چهار رقمِ آخرش');
  t(/پشتیبان الان به 1 کانال/.test(r.out), 'و پشتیبان یک کانال پیدا می‌کند',
    (r.out.match(/پشتیبان الان به .*/) || [''])[0]);
}
/* توکن از ورودیِ استاندارد: روی سرورِ واقعی همین راه است، چون
   آرگومان در تاریخِ شل و در «ps» می‌ماند. */
{
  const r = await cli(['--bot-on', 'tg', '-', CHAT], TOKEN + '\n');
  t(r.code === 0, 'توکن از ورودیِ استاندارد هم پذیرفته می‌شود', 'کدِ خروج ' + r.code);
  t(!r.out.includes(TOKEN), 'و این راه هم توکن را چاپ نمی‌کند');
  t(r.out.includes(TOKEN.slice(-4)), 'ولی ثبت شد — چهار رقمِ آخر همان است');
}
{
  const r = await cli(['--bots']);
  t(/تلگرام/.test(r.out) && /پشتیبان الان به 1 کانال/.test(r.out),
    'فهرستِ کانال‌ها هم همان را می‌گوید');
  t(!r.out.includes(TOKEN), 'و این یکی هم توکن را لو نمی‌دهد');
  /* «از کدام راه» باید همین‌جا باشد، نه فقط در لاگِ بالا آمدنِ سرویس:
     سرِ خرابی کسی آن لاگ را نمی‌خواند. */
  t(/تلگرام از راهِ:/.test(r.out) && /رله/.test(r.out),
    'و می‌گوید تلگرام از رله می‌رود', (r.out.match(/تلگرام از راهِ:.*/) || [''])[0]);
  t(!r.out.includes('secret'), 'بی آنکه رمزِ رله را چاپ کند');
}

/* ================= از کدام راه می‌رود ================= */
console.log('===== راهِ خروج =====');
{
  hits.length = 0;
  reply = { ok: true, result: { message_id: 1 } };
  const r = await cli(['--bot-test', 'tg']);
  t(r.code === 0, 'سنجشِ کانال موفق است', 'کدِ خروج ' + r.code);
  t(hits.length === 1, 'و درخواست واقعاً به رله رسید — نه به api.telegram.org',
    hits.length + ' درخواست');
  if (hits.length) {
    t(hits[0].url === '/tg/secret/bot' + TOKEN + '/sendMessage',
      'با همان مسیرِ رله و توکن', hits[0].url.replace(TOKEN, '…'));
    t(String(hits[0].body.chat_id) === CHAT, 'و همان شناسهٔ گفتگو', hits[0].body.chat_id);
    t(/آزمون/.test(hits[0].body.text || ''), 'و متنی که معلوم است آزمون است');
  }
  t(/رله/.test(r.out), 'و به آدم می‌گوید از رله رفت، نه مستقیم');
  t(!r.out.includes('secret'), 'و رمزِ رله را چاپ نمی‌کند');
}

/* ================= وقتی نمی‌رسد ================= */
console.log('===== پیامِ خطا =====');
{
  hits.length = 0;
  reply = { ok: false, description: 'Bad Request: chat not found' };
  const r = await cli(['--bot-test', 'tg']);
  t(r.code === 1, 'نرسیدن کدِ خروجِ ناموفق می‌دهد', 'کدِ خروج ' + r.code);
  t(/chat not found/.test(r.out), 'و خودِ جملهٔ تلگرام را می‌آورد');
  t(/گروه/.test(r.out), 'و می‌گوید باید چه کار کرد');
}
{
  hits.length = 0;
  reply = { ok: false, description: 'Unauthorized' };
  const r = await cli(['--bot-test', 'tg']);
  t(/BotFather/.test(r.out), 'توکنِ ردشده هم راهنمای خودش را دارد');
}
/* راهِ بسته: رله را می‌خوابانیم */
{
  await new Promise(r => fake.close(r));
  const r = await cli(['--bot-test', 'tg']);
  t(r.code === 1, 'راهِ بسته هم ناموفق است', 'کدِ خروج ' + r.code);
  t(/راه بسته/.test(r.out), 'و اسمش را می‌گوید، نه «سکوت»');
  t(!/api\.telegram\.org از این سرور/.test(r.out),
    'و چون از رله می‌رفت، تقصیر را گردنِ api.telegram.org نمی‌اندازد');
}

/* ================= برداشتن، دوباره ================= */
console.log('===== برداشتن =====');
{
  const r = await cli(['--bot-off', 'tg']);
  t(r.code === 0 && /برداشته شد/.test(r.out), 'برداشتنش هم کار می‌کند');
  t(/هیچ کانالی نمانده/.test(r.out), 'و هشدار می‌دهد که پشتیبان جایی نمی‌رود');
}

rmSync(dir, { recursive: true, force: true });
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
