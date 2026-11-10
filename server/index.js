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

/* ---------- IPv4 اول ----------
   این یک خط، یک روز گشتن را پشتِ سر دارد و دلیلش را باید نوشت.

   پشتیبانِ تلگرام نمی‌رسید: پیامِ متنی می‌رفت ولی فایلِ شش مگابایتی
   «fetch failed» می‌داد. مسیر سالم بود — همان فایل با curl از همان
   رله در دو ثانیه می‌رفت. پروتکل هم سالم بود: curl با HTTP/2 و
   HTTP/1.1 هر دو می‌رفت.

   تهش این بود: میزبانِ رله هم رکوردِ IPv4 دارد هم IPv6، و مسیرِ
   IPv6ِ این سرور یک چاهِ سیاه است — بستهٔ کوچک رد می‌شود ولی انتقالِ
   بزرگ وسطِ راه می‌خوابد. آزمونش روشن بود: با «-4» پاسخ در ۱٫۲
   ثانیه، با «-6» شصت ثانیه سکوت.

   و Node از نسخهٔ ۲۰ خودش بین دو خانواده انتخاب می‌کند، ولی فقط
   *برقراریِ اتصال* را مسابقه می‌دهد نه انتقال را. اتصالِ IPv6 برقرار
   می‌شد — پس پیامِ کوتاه می‌رفت و فایل معلق می‌ماند. curl تصادفاً
   IPv4 گرفته بود و برای همین همیشه کار می‌کرد.

   «ipv4first» یعنی اگر آدرسِ IPv4 هست، همان اول. IPv6 حذف نمی‌شود:
   میزبانی که فقط IPv6 دارد باز هم کار می‌کند.

   اگر روزی مسیرِ IPv6 درست شد یا جایی لازم شد، DNS_ORDER=verbatim
   رفتارِ پیش‌فرضِ Node را برمی‌گرداند. */
try {
  const { setDefaultResultOrder } = await import('node:dns');
  setDefaultResultOrder(cfg.DNS_ORDER === 'verbatim' ? 'verbatim' : 'ipv4first');
} catch (e) { console.error('ترتیبِ DNS تنظیم نشد:', e?.message || e); }

/* گزارشِ همین تنظیم، برای آزمون و برای وقتی که کسی شک می‌کند. */
if (process.argv.includes('--dns-order')) {
  const { getDefaultResultOrder } = await import('node:dns');
  console.log('ترتیبِ آدرس: ' + getDefaultResultOrder());
  DB.close();
  process.exit(0);
}

/* ---------- راهِ ربات‌ها، همین اول ----------
   این دو خط داخلِ worker.fetch و worker.scheduled هم هستند — آن‌جا
   لازم‌اند چون روی کلادفلر پروسه‌ای نیست که پیش از درخواست چیزی
   بچیند. ولی این‌جا بودنشان فقط آن‌جا یک سوراخ می‌گذاشت: هر دستورِ
   خط‌فرمانی که پیام می‌فرستد پیش از اولین درخواست اجرا می‌شود، پس
   __TGBASE خالی بود و مستقیم سراغِ api.telegram.org می‌رفت — همان
   میزبانی که از این سرور باز نمی‌شود. یعنی «سنجیدنِ کانال» از راهی
   می‌رفت که پشتیبانِ واقعی از آن نمی‌رود، و درست وقتی به جوابش
   احتیاج داشتیم دروغ می‌گفت.

   حالا یک بار، سرِ بالا آمدنِ پروسه. */
if (cfg.TG_BASE) globalThis.__TGBASE = cfg.TG_BASE;
if (cfg.BALE_BASE) globalThis.__BALEBASE = cfg.BALE_BASE;

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

/* ---------- کارتابلِ حذف‌شده: دیدن و برگرداندن ----------
   حذف حالا پیش از پاک کردن یک نسخهٔ کامل کنار می‌گذارد («سنگِ قبر»)،
   سی روز. این‌جا دیده و برگردانده می‌شود:

     node server/index.js --deleted             # چه چیزی برگشتنی است
     node server/index.js --undelete <نشانی>    # برگردانش

   چرا دستور و نه دکمه در پنل: کسی که همین الان اشتباهی حذف کرده،
   نباید برای برگرداندنش دنبالِ سربرگ بگردد؛ و این مسیر را می‌شود
   آزمود. دکمه‌اش بعداً، اگر لازم شد. */
if (process.argv.includes('--deleted') || process.argv.includes('--undelete')) {
  const { getSetting, setSetting, all, one, run } = await import('../src/kartabl.js');
  const env2 = env;
  const rows = await all(env2, "SELECT k, v FROM settings WHERE k LIKE 'tomb:%'").catch(() => []);
  const tombs = (rows || []).map(r => {
    let v = null; try { v = JSON.parse(r.v); } catch (e) {}
    return { slug: String(r.k).slice(5), t: v };
  }).filter(x => x.t && x.t.row);

  const show = () => {
    if (!tombs.length) { console.log('[حذف‌شده‌ها] چیزی برای برگرداندن نیست.'); return; }
    for (const x of tombs) {
      const days = Math.floor((Date.now() - (x.t.at || 0)) / 86400000);
      const st = JSON.stringify(x.t.state || {}).length;
      const db = JSON.stringify(x.t.db || {}).length;
      /* «۰KB» شبیهِ «خالی» است و آدم را می‌ترساند؛ زیرِ یک کیلوبایت
         خودِ بایت را می‌گوییم. */
      const size = (st + db) < 1024 ? (st + db) + ' بایت'
                                    : Math.round((st + db) / 1024) + ' کیلوبایت';
      console.log('  ' + (x.slug + '  ').padEnd(20) + ((x.t.row.name || '') + '  ').padEnd(26) +
        days + ' روز پیش · داده ' + size +
        (days >= 30 ? '  ⚠️ از سی روز گذشته، نوبتِ بعدیِ نظافت پاکش می‌کند' : ''));
      void size;
    }
  };

  if (!process.argv.includes('--undelete')) {
    console.log('[حذف‌شده‌ها]');
    show();
    DB.close();
    process.exit(0);
  }

  const want = String(process.argv[process.argv.indexOf('--undelete') + 1] || '').trim();
  const hit = tombs.find(x => x.slug === want);
  if (!want || !hit) {
    console.error('[حذف‌شده‌ها] «' + (want || '—') + '» پیدا نشد. برگشتنی‌ها:');
    show();
    DB.close();
    process.exit(2);
  }
  /* اگر کارتابلی با همین نشانی دوباره ساخته شده باشد، رویش
     نمی‌نویسیم: دادهٔ زنده از دادهٔ حذف‌شده مهم‌تر است. */
  const busy = await one(env2, 'SELECT slug FROM planners WHERE slug=?', want);
  if (busy) {
    console.error('[حذف‌شده‌ها] «' + want + '» الان وجود دارد. اول آن را ' +
                  'جابه‌جا یا حذف کنید، بعد برگردانید — رویش نمی‌نویسم.');
    DB.close();
    process.exit(3);
  }
  const r = hit.t.row;
  await run(env2, 'INSERT INTO planners(slug,name,kind,cfg,created) VALUES(?,?,?,?,?)',
    r.slug, r.name, r.kind, r.cfg, r.created || Date.now());
  const { panelBySlug } = await import('../src/kartabl.js');
  const panel = await panelBySlug(env2, want);
  const keys = (panel && panel.keys) || {};
  /* داده در جدولِ «kartabl» می‌نشیند، نه «settings». بارِ اول با
     setSetting نوشتمش و کارتابل خالی برمی‌گشت — بی هیچ خطایی، چون
     ردیف جایی نشسته بود که کسی نمی‌خوانَدش. */
  const putK = async (k, v) => run(env2,
    `INSERT INTO kartabl(k,v,rev,updated) VALUES(?,?,1,?)
     ON CONFLICT(k) DO UPDATE SET v=excluded.v, rev=kartabl.rev+1, updated=excluded.updated`,
    k, JSON.stringify(v), Date.now());
  if (hit.t.state != null) await putK(keys.state, hit.t.state);
  if (hit.t.db != null) await putK(keys.db, hit.t.db);
  if (hit.t.pass) await setSetting(env2, keys.pass, hit.t.pass);
  if (hit.t.gen) await setSetting(env2, keys.gen, hit.t.gen);
  await run(env2, 'DELETE FROM settings WHERE k=?', 'tomb:' + want);
  console.log('[حذف‌شده‌ها] «' + want + '» برگشت — با داده و رمزِ خودش.');
  console.log('   تاریخچهٔ نسخه‌هایش برنمی‌گردد؛ آن با حذف رفت.');
  DB.close();
  process.exit(0);
}

/* ---------- ربات‌های پشتیبان: دیدن و برداشتن ----------

     node server/index.js --bots           # چه چیزی تنظیم است
     node server/index.js --bot-off tg     # هر کانالِ تلگرامی را بردار
     node server/index.js --bot-off bale   # بله را بردار
     node server/index.js --bot-off old    # فقط رباتِ قدیمیِ کارتابل

   توکن هیچ‌وقت چاپ نمی‌شود — فقط چهار رقمِ آخرش.

   نسخهٔ اولِ این دستور سه جا را دو جا می‌دید: فهرستش فقط
   sltechSite را می‌خواند، ولی شمارنده‌اش از siteBots می‌آمد که رباتِ
   قدیمیِ کارتابل را هم حساب می‌کند. نتیجه این شد که گفت «تلگرام
   برداشته شد» و در خطِ بعد «پشتیبان به ۲ کانال می‌رود» — و آن کانالِ
   دوم همان تلگرامی بود که باید می‌رفت. حالا فهرست از خودِ siteBots
   ساخته می‌شود، پس نمی‌تواند با شمارنده اختلاف پیدا کند. */
const BOT_SLOTS = [
  { id: 'tg',   label: 'تلگرامِ سایت',  kind: 'telegram',
    where: 'sltechSite', keys: ['tgToken', 'tgChat'] },
  { id: 'bale', label: 'بله',            kind: 'bale',
    where: 'sltechSite', keys: ['baleToken', 'baleChat'] },
  { id: 'old',  label: 'تلگرامِ قدیمیِ کارتابل', kind: 'telegram',
    where: 'settings',   keys: ['kartablBotToken', 'kartablChatId'] }
];

if (process.argv.includes('--bots') || process.argv.includes('--bot-off') ||
    process.argv.includes('--bot-on') || process.argv.includes('--bot-test')) {
  const { getSetting, setSetting, siteBots, BOT_API } = await import('../src/kartabl.js');
  const tail = t => { const x = String(t || ''); return x ? '…' + x.slice(-4) : '—'; };

  const slotValues = async (slot) => {
    if (slot.where === 'sltechSite') {
      const st = (await getSetting(env, 'sltechSite', {})) || {};
      return [st[slot.keys[0]] || '', st[slot.keys[1]] || ''];
    }
    return [await getSetting(env, slot.keys[0], ''),
            await getSetting(env, slot.keys[1], '')];
  };

  const show = async () => {
    /* اول خامِ هر خانه — چه چیزی نوشته شده */
    for (const slot of BOT_SLOTS) {
      const [tk, ch] = await slotValues(slot);
      console.log('  ' + (slot.label + '  ').padEnd(26) +
        (tk ? 'توکن ' + tail(tk) : 'توکن ندارد') + ' · ' +
        (ch ? 'گفتگو ' + ch : 'گفتگو ندارد') +
        (tk && !ch ? '  ← ناقص، پس کانالِ فعالی نیست' : ''));
    }
    /* بعد آن‌چه پشتیبان واقعاً به آن می‌رود. اگر این دو با هم نخوانند،
       همین‌جا دیده می‌شود، نه سرِ نوبتِ بعدیِ پشتیبان. */
    const live = await siteBots(env);
    console.log('  ——');
    console.log('  پشتیبان الان به ' + live.length + ' کانال می‌رود' +
                (live.length ? ': ' + live.map(b => b.label).join('، ') : ''));
    /* و از کدام راه. وقتی تلگرام ساکت می‌شود این اولین سؤال است، و
       تا حالا جوابش فقط در لاگِ بالا آمدنِ سرویس بود — جایی که کسی
       سرِ خرابی سراغش نمی‌رود. فقط نامِ میزبان: رمزِ رله داخلِ مسیرِ
       TG_BASE است. */
    if (live.some(b => b.kind === 'telegram')) {
      let via = 'api.telegram.org (مستقیم — از سرورِ ایران باز نمی‌شود)';
      if (cfg.TG_BASE) {
        try { via = new URL(cfg.TG_BASE).host + ' (رله)'; } catch { via = 'رله'; }
      }
      console.log('  تلگرام از راهِ: ' + via);
    }
  };

  const slotById = id => BOT_SLOTS.find(x => x.id === id) || null;

  const writeSlot = async (slot, token, chat) => {
    if (slot.where === 'sltechSite') {
      const st = (await getSetting(env, 'sltechSite', {})) || {};
      st[slot.keys[0]] = token; st[slot.keys[1]] = chat;
      await setSetting(env, 'sltechSite', st);
    } else {
      await setSetting(env, slot.keys[0], token);
      await setSetting(env, slot.keys[1], chat);
    }
  };

  /* ---------- روشن کردنِ یک کانال ----------
     از خطِ فرمان، نه از پنل: توکن نباید در هیچ فایلی از مخزن بنشیند و
     کادرِ وب هم روی گوشی و با چسباندنِ یک رشتهٔ ۴۶ نویسه‌ای کارِ راحتی
     نیست. چاپ هم نمی‌شود — فقط چهار رقمِ آخر.

     و توکن به‌جای آرگومان می‌تواند از ورودیِ استاندارد بیاید («-»):
     آرگومان در تاریخِ شل می‌ماند و در «ps» هم دیده می‌شود، یعنی روی
     سروری که چند نفر دسترسی دارند یک رمز لو رفته است. */
  if (process.argv.includes('--bot-on')) {
    const i = process.argv.indexOf('--bot-on');
    const which = String(process.argv[i + 1] || '').toLowerCase();
    let token = String(process.argv[i + 2] || '').trim();
    const chat  = String(process.argv[i + 3] || '').trim();
    if (token === '-') {
      const chunks = [];
      for await (const c of process.stdin) chunks.push(c);
      token = Buffer.concat(chunks).toString('utf8').trim();
    }
    const slot = which === 'tg' || which === 'telegram' ? slotById('tg')
               : which === 'bale' ? slotById('bale')
               : which === 'old' ? slotById('old') : null;
    if (!slot || !token || !chat) {
      console.error('[ربات‌ها] روشن کردن: --bot-on <tg|bale|old> <توکن> <شناسهٔ گفتگو>');
      console.error('          مثال: node server/index.js --bot-on tg 123456:AA… -1001234567890');
      console.error('          یا بی آنکه توکن در تاریخِ شل بماند، با «-» و ورودیِ استاندارد:');
      console.error('          printf %s "123456:AA…" | node server/index.js --bot-on tg - -1001234567890');
      DB.close();
      process.exit(2);
    }
    /* شناسهٔ گفتگو عددی است (گروه با منفی شروع می‌شود). اگر کسی نامِ
       کاربری بدهد، تلگرام «chat not found» می‌دهد و پشتیبان بی‌صدا
       نمی‌رود — پس همین‌جا جلویش گرفته می‌شود. */
    if (!/^-?[0-9]+$/.test(chat)) {
      console.error('[ربات‌ها] شناسهٔ گفتگو باید عدد باشد (گروه با «-» شروع می‌شود)، نه «' + chat + '».');
      DB.close();
      process.exit(2);
    }
    if (!/:/.test(token) || token.length < 20) {
      console.error('[ربات‌ها] این توکن به توکنِ ربات نمی‌خورد؛ شکلش «۱۲۳۴۵۶:AA…» است.');
      DB.close();
      process.exit(2);
    }
    await writeSlot(slot, token, chat);
    console.log('[ربات‌ها] ' + slot.label + ': گذاشته شد (توکن …' + token.slice(-4) +
                ' · گفتگو ' + chat + ').');
    await show();
    console.log('  ——');
    console.log('  حالا درستی‌اش را بسنج:  node server/index.js --bot-test ' + slot.id);
    DB.close();
    process.exit(0);
  }

  /* ---------- سنجیدنِ کانال ----------
     «سکوت» چند علت دارد و از بیرون همه یکی‌اند. این دستور از همان
     مسیرِ واقعیِ پشتیبان می‌رود — همان BOT_API، همان رله — و اگر نشد
     می‌گوید چه چیزی نشد: راه بسته بود، توکن رد شد، یا گفتگو پیدا نشد. */
  if (process.argv.includes('--bot-test')) {
    const which = String(process.argv[process.argv.indexOf('--bot-test') + 1] || 'all').toLowerCase();
    const live = await siteBots(env);
    const pick = which === 'all' ? live
      : which === 'tg' || which === 'telegram' ? live.filter(b => b.kind === 'telegram')
      : which === 'bale' ? live.filter(b => b.kind === 'bale') : null;
    if (!pick) {
      console.error('[ربات‌ها] کدام کانال؟ tg، bale، یا all.');
      DB.close();
      process.exit(2);
    }
    if (!pick.length) {
      console.error('[ربات‌ها] این کانال تنظیم نیست. اول: --bot-on ' +
                    (which === 'all' ? '<tg|bale>' : which) + ' <توکن> <گفتگو>');
      DB.close();
      process.exit(1);
    }
    /* نامِ میزبان بس است. رمزِ رله داخلِ مسیرِ TG_BASE است و این خروجی
       جایی است که کپی می‌شود و دست‌به‌دست می‌گردد. */
    const hostOf = u => { try { return new URL(u).host; } catch { return '؟'; } };
    let bad = 0;
    for (const bot of pick) {
      const base = BOT_API[bot.kind](bot.token);
      const via = hostOf(base);
      const relay = bot.kind === 'telegram' && via !== 'api.telegram.org';
      console.log('[ربات‌ها] ' + (bot.label || bot.kind) + ' — از راهِ ' + via +
                  (relay ? ' (رله)' : bot.kind === 'telegram' ? ' (مستقیم)' : ''));
      try {
        const r = await fetch(base + '/sendMessage', {
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ chat_id: bot.chat,
            text: 'آزمونِ کانال — ' + new Date().toLocaleString('fa-IR') +
                  '\nاگر این را می‌بینی، پشتیبان هم از همین راه می‌رود.' })
        });
        const d = await r.json().catch(() => ({}));
        if (d.ok) { console.log('   ✓ رسید.'); continue; }
        bad++;
        console.log('   ✗ نپذیرفت: ' + (d.description || ('HTTP ' + r.status)));
        if (/chat not found/i.test(d.description || ''))
          console.log('     شناسهٔ گفتگو درست نیست، یا ربات هنوز به آن گروه اضافه نشده.');
        if (/unauthorized/i.test(d.description || ''))
          console.log('     توکن رد شد. از BotFather دوباره بگیرید و --bot-on را دوباره بزنید.');
      } catch (e) {
        bad++;
        console.log('   ✗ راه بسته است: ' + (e.message || e));
        if (bot.kind === 'telegram' && !relay)
          console.log('     api.telegram.org از این سرور باز نمی‌شود. TG_BASE در ' +
                      '/etc/sltech/env باید به رله اشاره کند.');
        else
          console.log('     میزبانِ ' + via + ' از این سرور جواب نداد.');
      }
    }
    DB.close();
    process.exit(bad ? 1 : 0);
  }

  if (!process.argv.includes('--bot-off')) {
    console.log('[ربات‌ها]');
    await show();
    DB.close();
    process.exit(0);
  }

  const which = String(process.argv[process.argv.indexOf('--bot-off') + 1] || '').toLowerCase();
  /* «tg» یعنی تلگرام، و تلگرام دو خانه دارد. کسی که می‌گوید تلگرام را
     بردار، منظورش «یکی از دو تلگرام» نیست. */
  const targets =
    which === 'tg' || which === 'telegram' ? BOT_SLOTS.filter(x => x.kind === 'telegram') :
    which === 'bale' ? BOT_SLOTS.filter(x => x.id === 'bale') :
    which === 'old' ? BOT_SLOTS.filter(x => x.id === 'old') : null;
  if (!targets) {
    console.error('[ربات‌ها] کدام کانال؟ tg (هر دو تلگرام)، bale، یا old (فقط رباتِ قدیمی).');
    DB.close();
    process.exit(2);
  }

  let touched = 0;
  for (const slot of targets) {
    const [tk, ch] = await slotValues(slot);
    if (!tk && !ch) { console.log('[ربات‌ها] ' + slot.label + ': از قبل تنظیم نبود.'); continue; }
    if (slot.where === 'sltechSite') {
      const st = (await getSetting(env, 'sltechSite', {})) || {};
      delete st[slot.keys[0]]; delete st[slot.keys[1]];
      await setSetting(env, 'sltechSite', st);
    } else {
      for (const k of slot.keys) await setSetting(env, k, '');
    }
    console.log('[ربات‌ها] ' + slot.label + ': برداشته شد.');
    touched++;
  }
  if (!touched) console.log('[ربات‌ها] چیزی عوض نشد.');
  await show();
  if (!(await siteBots(env)).length)
    console.log('⚠️  حالا هیچ کانالی نمانده: پشتیبان ساخته می‌شود ولی جایی ' +
                'نمی‌رود. در پنل، زنگوله همین را خواهد گفت.');
  DB.close();
  process.exit(0);
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
