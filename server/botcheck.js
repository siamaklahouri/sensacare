/* ==================== ربات‌ها کجا گیر کرده‌اند ====================

   وقتی پیامی نمی‌رسد، چند چیز می‌تواند علتش باشد و از بیرون همه شبیه
   هم‌اند: سکوت.

     ۱. توکن نیست. botCall در این حالت {skipped:true} برمی‌گرداند و
        هیچ خطایی جایی ثبت نمی‌شود.
     ۲. توکن هست ولی راهِ خروج بسته است. api.telegram.org از ایران
        بسته است، پس بی TG_BASE هر فراخوانی در سکوت شکست می‌خورد.
     ۳. توکن و راه هر دو هست، ولی وب‌هوک جای دیگری اشاره می‌کند —
        مثلاً به ورکرِ قدیمی. پیامِ کاربر اصلاً به این سرور نمی‌رسد.

   دو سایت توکن‌هایشان را دو جور نگه می‌دارند و این تفاوت بارها گمراه
   کرده: فروشگاه از متغیرِ محیطی یا کلیدهای سادهٔ tgToken/baleToken
   می‌خواند، ولی اس‌ال‌تک هر دو را داخلِ یک تنظیمِ JSON به نامِ
   sltechSite دارد. پس این‌جا هر دو شکل خوانده می‌شود، وگرنه یکی‌شان
   بی‌دلیل «توکن ندارد» گزارش می‌شد.

     SLTECH_ENV=/etc/sensa/env  node server/botcheck.js
     SLTECH_ENV=/etc/sltech/env node server/botcheck.js

   با «--offline» به شبکه دست نمی‌زند و فقط می‌گوید توکن از کجا
   می‌آید و از کدام راه قرار است برود — وقتی راهِ خروج بسته است و
   نمی‌خواهی پایِ هر فراخوانی منتظر بمانی.

   هیچ توکنی چاپ نمی‌شود؛ فقط شناسهٔ پیش از «:» و طولش، تا بشود دو
   سرویس را مقایسه کرد بی‌آنکه رمزی در جایی بیفتد.                   */

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

const OFFLINE = process.argv.includes('--offline');
const ENVF = process.env.SLTECH_ENV || '/etc/sltech/env';
const cfg  = { ...loadEnvFile(ENVF), ...process.env };
const DBF  = cfg.DB_FILE || '/var/lib/sltech/sltech.db';

const ok   = m => console.log('   ok   ' + m);
const bad  = m => console.log('   BAD  ' + m);
const note = m => console.log('        ' + m);
const say  = m => console.log('\n== ' + m);

/* توکن را نشان نمی‌دهیم، فقط شناسه‌اش: توکنِ تلگرام با «<id>:» شروع
   می‌شود و همان بخش رازی نیست — برای تشخیصِ اینکه دو سرویس یک ربات
   را صدا می‌زنند یا نه کافی است. */
const fingerprint = t => {
  const s = String(t || '');
  if (!s) return '-';
  const id = s.includes(':') ? s.split(':')[0] : '?';
  return `${id}:…  (${s.length} نویسه)`;
};

let db = null;
try { db = new DatabaseSync(DBF, { readOnly: true }); }
catch (e) { bad(`دیتابیس باز نشد: ${DBF} — ${e.message}`); process.exit(1); }

const raw = k => {
  try { return db.prepare('SELECT v FROM settings WHERE k = ?').get(k)?.v ?? ''; }
  catch { return ''; }
};
/* مقدارها گاهی JSON‌اند و گاهی رشتهٔ ساده؛ هر دو را می‌پذیریم. */
const str = k => { const v = raw(k); try { const p = JSON.parse(v); return typeof p === 'string' ? p : v; } catch { return v; } };
const obj = k => { try { const p = JSON.parse(raw(k)); return p && typeof p === 'object' ? p : {}; } catch { return {}; } };

console.log(`تنظیمات: ${ENVF}`);
console.log(`دیتابیس: ${DBF}`);

const site = obj('sltechSite');

/* هر ربات: از کجا توکن بگیر، با کدام پایه بیرون برو. */
const BOTS = [
  { fa: 'فروشگاه · تلگرام', kind: 'telegram',
    token: cfg.TELEGRAM_BOT_TOKEN || str('tgToken'),
    from:  cfg.TELEGRAM_BOT_TOKEN ? 'TELEGRAM_BOT_TOKEN' : 'settings.tgToken' },
  { fa: 'فروشگاه · بله', kind: 'bale',
    token: cfg.BALE_BOT_TOKEN || str('baleToken'),
    from:  cfg.BALE_BOT_TOKEN ? 'BALE_BOT_TOKEN' : 'settings.baleToken' },
  { fa: 'اس‌ال‌تک · تلگرام', kind: 'telegram',
    token: site.tgToken || '',   from: 'settings.sltechSite.tgToken' },
  { fa: 'اس‌ال‌تک · بله', kind: 'bale',
    token: site.baleToken || '', from: 'settings.sltechSite.baleToken' },
];

const BASE = {
  telegram: { key: 'TG_BASE',   direct: 'https://api.telegram.org', blocked: true },
  bale:     { key: 'BALE_BASE', direct: 'https://tapi.bale.ai',     blocked: false },
};

let problems = 0, found = 0;

for (const b of BOTS) {
  if (!b.token) { console.log(`\n== ${b.fa}\n        توکنی ندارد (${b.from}) — رد می‌شود`); continue; }
  found++;
  say(b.fa);
  ok(`توکن از ${b.from} — ${fingerprint(b.token)}`);

  const bs = BASE[b.kind];
  const base = cfg[bs.key] || bs.direct;
  if (base === bs.direct && bs.blocked) {
    problems++;
    bad(`${bs.key} تنظیم نشده، پس مستقیم به ${bs.direct} می‌رود.`);
    note('و آن از ایران بسته است — خروجی در سکوت شکست می‌خورد.');
  } else {
    ok(`راهِ خروج: ${base}`);
  }

  if (OFFLINE) continue;

  const api = `${base.replace(/\/+$/, '')}/bot${b.token}`;
  try {
    const r = await fetch(`${api}/getMe`, { signal: AbortSignal.timeout(15000) });
    const j = await r.json().catch(() => null);
    if (j && j.ok) ok(`ربات جواب داد: @${j.result.username}`);
    else { problems++; bad(`getMe: ${JSON.stringify(j || {}).slice(0, 200)}`); }
  } catch (e) { problems++; bad(`getMe نرسید: ${e.message}`); }

  try {
    const r = await fetch(`${api}/getWebhookInfo`, { signal: AbortSignal.timeout(15000) });
    const j = await r.json().catch(() => null);
    const w = j && j.ok ? j.result : null;
    if (!w) { problems++; bad('getWebhookInfo جواب نداد'); }
    else if (!w.url) {
      problems++;
      bad('وب‌هوک تنظیم نشده — پیامِ کاربرها به این سرور نمی‌رسد.');
      note('در پنل، «وصل کردن ربات‌ها به سایت» را بزن.');
    } else {
      ok(`وب‌هوک: ${w.url}`);
      if (w.pending_update_count) note(`${w.pending_update_count} پیامِ معطل`);
      if (w.last_error_message) {
        problems++;
        bad(`آخرین خطا: ${w.last_error_message}`);
        if (w.last_error_date)
          note(`در ${new Date(w.last_error_date * 1000).toISOString()}`);
      }
    }
  } catch (e) { problems++; bad(`getWebhookInfo نرسید: ${e.message}`); }
}

say('گفتگوهای ثبت‌شده');
try {
  const rows = db.prepare('SELECT platform, COUNT(*) n FROM bot_chats GROUP BY platform').all();
  if (!rows.length) note('هیچ — کسی هنوز با ربات‌ها حرف نزده');
  for (const r of rows) console.log(`        ${r.platform}: ${r.n}`);
} catch (e) { note('جدولِ bot_chats خوانده نشد: ' + e.message); }

db.close();
console.log();
if (!found) {
  console.log('هیچ رباتی توکن ندارد. این سرویس نمی‌تواند پیامی بفرستد.');
  process.exit(1);
}
console.log(problems ? `${problems} ایراد پیدا شد.` : 'هیچ ایرادی پیدا نشد.');
process.exit(problems ? 1 : 0);
