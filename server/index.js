/* ==================== میزبانِ ورکر روی نود ====================
   کلادفلر خودش درخواست را به worker.fetch(req, env, ctx) می‌دهد و
   جوابش را به مرورگر برمی‌گرداند، و سرِ ساعت worker.scheduled را صدا
   می‌زند. این فایل همان دو کار را روی یک سرورِ معمولی انجام می‌دهد.

   هیچ‌چیز در src/ عوض نشده: همان فایل‌ها هم روی کلادفلر کار می‌کنند
   هم این‌جا. تفاوت فقط در چیزی است که به‌عنوانِ env به آن‌ها داده
   می‌شود — دیتابیس، فایل‌ها، و کلیدها. */

import './tplhook.js';

import { createServer } from 'node:http';
import { Readable } from 'node:stream';
import { pipeline } from 'node:stream/promises';
import { readFileSync, existsSync, mkdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { openDB } from './d1.js';
import { makeAssets } from './assets.js';
import { makeFiles } from './files-fs.js';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(HERE, '..');

/* ---------- تنظیمات ----------
   کلیدها از فایلِ /etc/sltech/env می‌آیند، نه از داخلِ کد و نه از
   داخلِ مخزن. متغیرهای خودِ سیستم بر فایل می‌چربند. */
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

const cfg = { ...loadEnvFile(process.env.SLTECH_ENV || '/etc/sltech/env'), ...process.env };

const PORT     = Number(cfg.PORT || 8787);
const BIND     = cfg.BIND || '127.0.0.1';
const DB_FILE  = cfg.DB_FILE || '/var/lib/sltech/sltech.db';
const PUBLIC   = cfg.PUBLIC_DIR || join(ROOT, 'public');

mkdirSync(dirname(DB_FILE), { recursive: true });

/* ---------- بایندینگ‌ها ----------
   همان نام‌هایی که کد انتظار دارد: DB، ASSETS و بقیهٔ کلیدها. */
const DB = openDB(DB_FILE);
/* پیوست‌ها کنارِ دیتابیس می‌نشینند، نه داخلش — چرایش در src/files.js */
const FILES_DIR = cfg.FILES_DIR || join(dirname(DB_FILE), 'files');
const env = { ...cfg, DB, ASSETS: makeAssets(PUBLIC), FILES: makeFiles(FILES_DIR) };

/* env.AI فقط روی کلادفلر وجود دارد. این‌جا نیست، و کد خودش برای
   نبودنش پیام روشن دارد؛ پس چیزی نمی‌شکند، فقط دستیار خاموش است. */
delete env.AI;

const worker = (await import('../src/index.js')).default;

/* ---------- ctx ----------
   waitUntil روی کلادفلر کارِ پس از پاسخ را زنده نگه می‌دارد. این‌جا
   پروسه خودش زنده است؛ تنها کاری که لازم است گرفتنِ خطاست، وگرنه یک
   خطای رهاشده کلِ سرویس را می‌خواباند. */
const inflight = new Set();
const ctx = {
  waitUntil(p) {
    const t = Promise.resolve(p)
      .catch(e => console.error('[waitUntil]', e?.stack || e?.message || e))
      .finally(() => inflight.delete(t));
    inflight.add(t);
  },
  passThroughOnException() {},
};

/* ---------- پلِ نود <-> وب ---------- */
function toRequest(nreq) {
  const xfProto = String(nreq.headers['x-forwarded-proto'] || '').split(',')[0].trim();
  const scheme  = xfProto || (cfg.SCHEME || 'https');
  const host    = nreq.headers['host'] || cfg.PANEL_HOST || 'localhost';
  const url     = new URL(nreq.url, `${scheme}://${host}`);

  const headers = new Headers();
  for (let i = 0; i < nreq.rawHeaders.length; i += 2) {
    try { headers.append(nreq.rawHeaders[i], nreq.rawHeaders[i + 1]); } catch {}
  }

  const hasBody = nreq.method !== 'GET' && nreq.method !== 'HEAD';
  return new Request(url, {
    method: nreq.method,
    headers,
    body: hasBody ? Readable.toWeb(nreq) : undefined,
    duplex: hasBody ? 'half' : undefined,
  });
}

async function send(nres, wres) {
  const headers = {};
  for (const [k, v] of wres.headers) {
    if (k.toLowerCase() === 'set-cookie') continue;
    headers[k] = v;
  }
  /* چند کوکی در یک هدر جمع نمی‌شوند؛ باید جدا بروند وگرنه مرورگر
     فقط یکی را می‌گیرد و ورود و خروج به هم می‌ریزد. */
  const cookies = typeof wres.headers.getSetCookie === 'function' ? wres.headers.getSetCookie() : [];
  if (cookies.length) headers['set-cookie'] = cookies;

  nres.writeHead(wres.status, headers);
  if (!wres.body || wres.status === 204 || wres.status === 304) return nres.end();
  await pipeline(Readable.fromWeb(wres.body), nres);
}

/* ---------- خطاهای سرور ----------
   تا امروز خطای ۵۰۰ فقط در journald می‌نشست. یعنی اگر یک مسیر برای
   یک کاربر می‌شکست، تنها راهِ فهمیدنش این بود که خودش شکایت کند —
   و تا آن موقع، چند نفرِ دیگر هم خورده بودند.

   این‌جا هر دو جورِ خطا از یک نقطه رد می‌شود: استثنایی که ورکر
   می‌اندازد، و پاسخی که خودش با کدِ ۵۰۰ یا بالاتر برمی‌گردد.

   هر خطا با امضایش یک ردیف است، نه یک ردیف در هر بار: یک حلقهٔ خراب
   می‌تواند هزاران بار بیفتد. پیام هم ساعتی یک بار می‌رود، وگرنه
   همان حلقه، ربات را هم خفه می‌کند.

   در پیام نه پرسمان (query) می‌آید نه بدنهٔ درخواست: آن‌ها همان‌جایی
   هستند که رمز و شمارهٔ کاربر رد می‌شود. فقط روش، مسیر و متنِ خطا. */
const ERR_QUIET = 60 * 60 * 1000;

async function noteError(method, rawPath, msg) {
  try {
    let path = String(rawPath || '').split('?')[0].slice(0, 120);
    const text = String(msg || '').split('\n')[0].slice(0, 200);
    const sig = method + ' ' + path + ' | ' + text;
    const now = Date.now();
    const { all, run } = await import('../src/kartabl.js');
    const row = (await all(env,
      'SELECT last, n, notified FROM app_errors WHERE sig=?', sig))[0];
    if (row) {
      await run(env, 'UPDATE app_errors SET last=?, n=n+1 WHERE sig=?', now, sig);
    } else {
      await run(env, `INSERT INTO app_errors(sig,first,last,n,method,path,msg,notified)
        VALUES(?,?,?,1,?,?,?,0)`, sig, now, now, method, path, text);
    }
    const quiet = row ? now - (row.notified || 0) < ERR_QUIET : false;
    if (quiet) return;
    await run(env, 'UPDATE app_errors SET notified=? WHERE sig=?', now, sig);
    const n = row ? row.n + 1 : 1;
    const { botMessage } = await import('../src/kartabl.js');
    await botMessage(env, '⚠️ خطای سرور SLTech\n' +
      method + ' ' + path + '\n' + text + (n > 1 ? `\n(${n} بار)` : ''));
  } catch (e) {
    /* خودِ گزارشِ خطا نباید درخواست را بخواباند */
    console.error('[noteError]', e?.message || e);
  }
}

const server = createServer(async (nreq, nres) => {
  try {
    const wres = await worker.fetch(toRequest(nreq), env, ctx);
    if (wres.status >= 500)
      ctx.waitUntil(noteError(nreq.method, nreq.url, 'پاسخ ' + wres.status));
    await send(nres, wres);
  } catch (e) {
    console.error('[fetch]', nreq.method, nreq.url, e?.stack || e?.message || e);
    ctx.waitUntil(noteError(nreq.method, nreq.url, e?.message || String(e)));
    if (!nres.headersSent) {
      nres.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
      nres.end('خطای داخلی سرور');
    } else { try { nres.end(); } catch {} }
  }
});

server.keepAliveTimeout = 65000;
server.headersTimeout   = 70000;

/* ---------- کرون ----------
   همان چیزی که در wrangler.toml است: هر ساعت، سرِ دقیقهٔ سی گرینویچ.
   کارهای روزانه خودشان قفلِ روزانه دارند و در src/index.js از نوبتِ
   ۰۲ به بعد امتحان می‌شوند، پس این‌جا چیزی جدا لازم نیست.

   CRON_UTC اگر تنظیم شده باشد بر این می‌چربد، و «-» یعنی هیچ. */
const HOURLY = Array.from({ length: 24 }, (_, h) => h + ':30').join(',');
const SLOTS = (cfg.CRON_UTC || HOURLY)
  .split(',').map(s => s.trim().split(':').map(Number))
  .filter(a => a.length === 2 && a.every(Number.isInteger));

let lastFired = '';
async function fireScheduled(now = new Date()) {
  console.log('[cron] شروع', now.toISOString());
  try {
    await worker.scheduled({ scheduledTime: now.getTime(), cron: 'node' }, env, ctx);
    await Promise.allSettled([...inflight]);
    console.log('[cron] پایان');
  } catch (e) { console.error('[cron]', e?.stack || e?.message || e); }
}

function cronTick() {
  const d = new Date();
  if (!SLOTS.some(([h, m]) => h === d.getUTCHours() && m === d.getUTCMinutes())) return;
  const key = d.toISOString().slice(0, 16);      /* دقتِ دقیقه: دوبار در یک نوبت نمی‌رود */
  if (key === lastFired) return;
  lastFired = key;
  fireScheduled(d);
}

/* ---------- یادآورها ----------
   جدا از کرونِ ساعتی: یادآور اگر یک ساعت دیر بیاید، یادآور نیست. */
const { tick: pushTick } = await import('../src/push.js');
let pushBusy = false;
async function remindTick() {
  if (pushBusy || cfg.PUSH_OFF === '1') return;
  pushBusy = true;
  try { await pushTick(env); }
  catch (e) { console.error('[یادآور]', e?.stack || e?.message || e); }
  finally { pushBusy = false; }
}

/* ---------- راه‌اندازی ---------- */
/* ---------- کلیدِ گامِ دومِ ادمین ----------
   اگر ربات از کار بیفتد، صاحبِ سایت نباید پشتِ درِ خودش بماند:

     node server/index.js --admin-2fa off
     node server/index.js --admin-2fa on

   دستش به سرور می‌رسد، یعنی این قفل اصلاً برای او نبوده. */
if (process.argv.includes('--admin-2fa')) {
  const i = process.argv.indexOf('--admin-2fa');
  const want = String(process.argv[i + 1] || '').toLowerCase();
  if (want !== 'on' && want !== 'off') {
    console.error('[ادمین] on یا off؟');
    DB.close(); process.exit(2);
  }
  const { setSetting } = await import('../src/kartabl.js');
  await setSetting(env, 'admin2fa', want === 'on');
  await setSetting(env, 'admin2fa:pending', null);
  console.log('[ادمین] ورودِ دومرحله‌ای ' + (want === 'on' ? 'روشن شد' : 'خاموش شد'));
  DB.close();
  process.exit(0);
}

/* ---------- یادداشتِ نگهداری ----------
   اسکریپت‌های پشتیبان و نگهبان نتیجه‌شان را این‌جا می‌گذارند تا پنلِ
   ادمین بتواند نشانش بدهد:

     node server/index.js --ops-note backup '{"at":1700,"size":"18M"}'

   چرا در جدولِ تنظیمات و نه یک فایل: پنل از همان دیتابیس می‌خواند و
   لازم نیست کدِ سایت به فایل‌سیستم دست بزند — همان کد روی ورکر هم
   باید کار کند. */
if (process.argv.includes('--ops-note')) {
  const i = process.argv.indexOf('--ops-note');
  const key = String(process.argv[i + 1] || '').replace(/[^a-z0-9_-]/gi, '');
  let val = null;
  try { val = JSON.parse(process.argv.slice(i + 2).join(' ') || 'null'); } catch (e) { val = null; }
  if (!key || val === null) { console.error('[نگهداری] ورودی درست نبود.'); DB.close(); process.exit(2); }
  const { setSetting } = await import('../src/kartabl.js');
  await setSetting(env, 'ops:' + key, Object.assign({ at: Date.now() }, val));
  console.log('[نگهداری] ثبت شد: ' + key);
  DB.close();
  process.exit(0);
}

/* ---------- پیام از خطِ فرمان ----------
   اسکریپت‌های نگهداری (پشتیبان، چکِ سلامت) باید بتوانند خبر بدهند.
   به‌جای اینکه هر کدام توکن را از env دربیاورد و خودش به تلگرام وصل
   شود — یعنی چهار جا که باید درست بمانند — همین‌جا از همان راهی
   می‌رود که بقیهٔ پیام‌های سایت می‌روند:

     node server/index.js --notify "متنِ پیام"

   توکن همان‌جایی می‌ماند که هست و در هیچ اسکریپتی تکرار نمی‌شود. */
if (process.argv.includes('--notify')) {
  const i = process.argv.indexOf('--notify');
  const text = process.argv.slice(i + 1).join(' ').trim();
  if (!text) { console.error('[خبر] متنی نیامد.'); DB.close(); process.exit(2); }
  const { botMessage } = await import('../src/kartabl.js');
  const r = await botMessage(env, text);
  console.log(r.ok ? '[خبر] رفت' + (r.to ? ' به ' + r.to.join(' و ') : '')
                   : '[خبر] نرفت — ' + (r.error || 'نامعلوم'));
  DB.close();
  process.exit(r.ok ? 0 : 1);
}

/* یک نوبتِ یادآور با دست — برای وقتی که باید دید چه می‌رود، بی
   انتظارِ شصت ثانیه */
if (process.argv.includes('--remind-now')) {
  const r = await (await import('../src/push.js')).tick(env);
  console.log('[یادآور] کارتابل‌های سررسیده: ' + r.planners);
  DB.close();
  process.exit(0);
}

if (process.argv.includes('--cron-now')) {
  await fireScheduled();
  DB.close();
  process.exit(0);
}

/* کارتابلِ نمایشی باید باشد، وگرنه دکمهٔ «همین حالا ببینم» در صفحهٔ
   اصلی به جایی نمی‌رسد. فقط وقتی اصلاً نباشد ساخته می‌شود؛ اگر
   خودتان ساختید یا پاکش کردید، دست نمی‌خورد. */
try {
  const { ensureDemoPanel } = await import('../src/admin-planer.js');
  if (await ensureDemoPanel(env)) console.log('کارتابلِ نمایشی ساخته شد: /demo/');
} catch (e) { console.error('کارتابلِ نمایشی ساخته نشد:', e?.message || e); }

server.listen(PORT, BIND, () => {
  console.log(`sltech روی http://${BIND}:${PORT}`);
  console.log(`دیتابیس: ${DB_FILE}`);
  console.log(`فایل‌ها: ${PUBLIC}`);
  console.log(SLOTS.length === 24 ? 'کرون: هر ساعت، سرِ دقیقهٔ سی گرینویچ'
    : SLOTS.length ? `کرون (UTC): ${SLOTS.map(s => s.join(':')).join('، ')}`
    : 'کرون: خاموش');
  /* فقط نامِ میزبان، نه کلِ آدرس: رمزِ رله داخلِ مسیرِ TG_BASE است و
     لاگ جایی است که کپی می‌شود و دست‌به‌دست می‌گردد. */
  let tgWhere = 'api.telegram.org (مستقیم)';
  if (cfg.TG_BASE) {
    try { tgWhere = new URL(cfg.TG_BASE).host + ' (رله)'; } catch { tgWhere = 'رله'; }
  }
  console.log(`تلگرام از راهِ: ${tgWhere}`);
  setInterval(cronTick, 20000);
  if (cfg.PUSH_OFF !== '1') setInterval(remindTick, 60000);
});

for (const sig of ['SIGTERM', 'SIGINT']) {
  process.on(sig, () => {
    console.log('خاموش می‌شود…');
    server.close(() => { DB.close(); process.exit(0); });
    setTimeout(() => { DB.close(); process.exit(0); }, 8000).unref();
  });
}

process.on('unhandledRejection', e => console.error('[unhandledRejection]', e?.stack || e));
