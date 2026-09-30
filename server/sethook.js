/* ==================== ثبتِ وب‌هوکِ ربات‌های فروشگاه ====================

   پنلِ اس‌ال‌تک دکمهٔ «وصل کردن ربات‌ها به سایت» را دارد، فروشگاه
   ندارد — وب‌هوکش یک بار روی کلادفلر ست شده بود و از آن به بعد کسی
   دستش نزده بود. تا وقتی دامنه عوض نمی‌شد اشکالی نداشت، ولی وقتی
   توکنِ تلگرام در BotFather ری‌ووک شود، تلگرام وب‌هوکِ آن توکن را هم
   پاک می‌کند و دیگر راهی برای برگرداندنش نبود.

     SLTECH_ENV=/etc/sensa/env node server/sethook.js            گزارش
     SLTECH_ENV=/etc/sensa/env node server/sethook.js --yes      ثبت

   آدرسِ هر سکّو از روی تنظیماتِ خودِ سرویس ساخته می‌شود، نه دستی:

   • تلگرام از رله می‌رود. api.telegram.org از ایران بسته است، پس
     خودِ تلگرام هم نمی‌تواند به آی‌پیِ ایران وصل شود — یعنی وب‌هوک
     باید روی میزبانِ رله بنشیند، نه روی sensacare.ir.

   • بله ایرانی است و مستقیم به خودِ سایت می‌آید.

   «رمزِ s» همان چیزی است که src/index.js موقعِ تحویل چک می‌کند
   (settings.botSecret یا BOT_SECRET). اگر جا بیفتد، هر کسی می‌تواند
   برای ربات پیامِ جعلی بفرستد؛ پس اگر نبود، کار متوقف می‌شود.       */

import { DatabaseSync } from 'node:sqlite';
import { readFileSync, existsSync } from 'node:fs';

function loadEnvFile(file) {
  const out = {};
  if (!file || !existsSync(file)) return out;
  for (const raw of readFileSync(file, 'utf8').split('\n')) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const i = line.indexOf('=');
    if (i < 0) continue;
    let v = line.slice(i + 1).trim();
    if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'")))
      v = v.slice(1, -1);
    out[line.slice(0, i).trim()] = v;
  }
  return out;
}

const GO   = process.argv.includes('--yes');
const ENVF = process.env.SLTECH_ENV || '/etc/sltech/env';
const cfg  = { ...loadEnvFile(ENVF), ...process.env };
const DBF  = cfg.DB_FILE || '/var/lib/sltech/sltech.db';

const ok   = m => console.log('   ok   ' + m);
const bad  = m => console.log('   BAD  ' + m);
const note = m => console.log('        ' + m);
const die  = m => { console.error('\n' + m + '\n'); process.exit(1); };

let db;
try { db = new DatabaseSync(DBF, { readOnly: true }); }
catch (e) { die(`دیتابیس باز نشد: ${DBF} — ${e.message}`); }

const val = k => {
  try { const v = db.prepare('SELECT v FROM settings WHERE k = ?').get(k)?.v ?? '';
        try { const p = JSON.parse(v); return typeof p === 'string' ? p : v; } catch { return v; } }
  catch { return ''; }
};

console.log(`تنظیمات: ${ENVF}`);
console.log(`دیتابیس: ${DBF}`);

const secret = val('botSecret') || cfg.BOT_SECRET || '';
if (!secret)
  die('botSecret نیست. بی آن، وب‌هوک بی‌محافظ می‌شود و هر کسی می‌تواند\n' +
      'پیامِ جعلی به سایت بفرستد. اول آن را در تنظیمات بگذار.');
ok(`رمزِ وب‌هوک هست (${secret.length} نویسه)`);

/* میزبانِ رله، از روی TG_BASE. TG_BASE خودش مسیرِ مخفی هم دارد؛ فقط
   میزبانش را می‌خواهیم. */
let tgHost = '';
if (cfg.TG_BASE) { try { tgHost = new URL(cfg.TG_BASE).host; } catch (e) {} }

const shopHost = cfg.PUBLIC_HOST || cfg.SHOP_HOST || '';
if (!shopHost) die('نه PUBLIC_HOST و نه SHOP_HOST در تنظیمات نیست.');

const PLAN = [
  { pf: 'telegram', fa: 'تلگرام',
    token: cfg.TELEGRAM_BOT_TOKEN || val('tgToken'),
    api:   (cfg.TG_BASE || 'https://api.telegram.org').replace(/\/+$/, ''),
    host:  tgHost,
    why:   'از رله، چون تلگرام به آی‌پیِ ایران نمی‌رسد' },
  { pf: 'bale', fa: 'بله',
    token: cfg.BALE_BOT_TOKEN || val('baleToken'),
    api:   (cfg.BALE_BASE || 'https://tapi.bale.ai').replace(/\/+$/, ''),
    host:  shopHost,
    why:   'مستقیم، چون بله ایرانی است' },
];

let problems = 0;
const todo = [];

for (const b of PLAN) {
  console.log(`\n== ${b.fa}`);
  if (!b.token) { problems++; bad('توکن ندارد — اول در پنل ثبتش کن'); continue; }
  if (!b.host)  { problems++; bad(b.pf === 'telegram'
    ? 'TG_BASE تنظیم نشده، پس میزبانِ رله معلوم نیست'
    : 'میزبانِ سایت معلوم نیست'); continue; }

  const hook = `https://${b.host}/api/bot/${b.pf}?s=${encodeURIComponent(secret)}`;
  ok(`آدرس: https://${b.host}/api/bot/${b.pf}?s=…`);
  note(b.why);
  todo.push({ ...b, hook });
}

db.close();

if (!todo.length) die('کاری نمی‌شود کرد.');

if (!GO) {
  console.log('\nچیزی ثبت نشد. برای انجام دادن: --yes\n');
  process.exit(problems ? 1 : 0);
}

for (const b of todo) {
  console.log(`\n== ثبتِ ${b.fa}`);
  try {
    const r = await fetch(`${b.api}/bot${b.token}/setWebhook`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ url: b.hook }),
      signal: AbortSignal.timeout(20000),
    });
    const d = await r.json().catch(() => ({}));
    if (!d.ok) { problems++; bad('نپذیرفت: ' + (d.description || JSON.stringify(d).slice(0, 150))); continue; }
    ok('ثبت شد');
  } catch (e) { problems++; bad('نرسید: ' + e.message); continue; }

  /* و بلافاصله از خودش می‌پرسیم چه چیزی ثبت شده — «ok گرفتیم» کافی
     نیست، باید همان آدرسی باشد که خواستیم. */
  try {
    const r = await fetch(`${b.api}/bot${b.token}/getWebhookInfo`,
      { signal: AbortSignal.timeout(20000) });
    const d = await r.json().catch(() => ({}));
    const u = d?.result?.url || '';
    if (u === b.hook) ok('و خودش هم همین را می‌گوید');
    else { problems++; bad(`ولی وب‌هوکش این است: ${u || '—'}`); }
    if (d?.result?.last_error_message)
      note('آخرین خطا: ' + d.result.last_error_message);
  } catch (e) { problems++; bad('چک نشد: ' + e.message); }
}

console.log();
console.log(problems ? `${problems} ایراد ماند.` : 'هر دو وب‌هوک ثبت شد.');
process.exit(problems ? 1 : 0);
