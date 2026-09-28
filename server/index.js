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
const env = { ...cfg, DB, ASSETS: makeAssets(PUBLIC) };

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

const server = createServer(async (nreq, nres) => {
  try {
    const wres = await worker.fetch(toRequest(nreq), env, ctx);
    await send(nres, wres);
  } catch (e) {
    console.error('[fetch]', nreq.method, nreq.url, e?.stack || e?.message || e);
    if (!nres.headersSent) {
      nres.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
      nres.end('خطای داخلی سرور');
    } else { try { nres.end(); } catch {} }
  }
});

server.keepAliveTimeout = 65000;
server.headersTimeout   = 70000;

/* ---------- کرون ----------
   همان چهار نوبتِ wrangler.toml، به وقتِ گرینویچ:
   ۲:۳۰ و ۸:۳۰ و ۱۴:۳۰ و ۲۰:۳۰ = ۶ و ۱۲ و ۱۸ و ۲۴ به وقتِ تهران. */
const SLOTS = (cfg.CRON_UTC || '2:30,8:30,14:30,20:30')
  .split(',').map(s => s.trim().split(':').map(Number)).filter(a => a.length === 2);

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

/* ---------- راه‌اندازی ---------- */
if (process.argv.includes('--cron-now')) {
  await fireScheduled();
  DB.close();
  process.exit(0);
}

server.listen(PORT, BIND, () => {
  console.log(`sltech روی http://${BIND}:${PORT}`);
  console.log(`دیتابیس: ${DB_FILE}`);
  console.log(`فایل‌ها: ${PUBLIC}`);
  console.log(`کرون (UTC): ${SLOTS.map(s => s.join(':')).join('، ')}`);
  /* فقط نامِ میزبان، نه کلِ آدرس: رمزِ رله داخلِ مسیرِ TG_BASE است و
     لاگ جایی است که کپی می‌شود و دست‌به‌دست می‌گردد. */
  let tgWhere = 'api.telegram.org (مستقیم)';
  if (cfg.TG_BASE) {
    try { tgWhere = new URL(cfg.TG_BASE).host + ' (رله)'; } catch { tgWhere = 'رله'; }
  }
  console.log(`تلگرام از راهِ: ${tgWhere}`);
  setInterval(cronTick, 20000);
});

for (const sig of ['SIGTERM', 'SIGINT']) {
  process.on(sig, () => {
    console.log('خاموش می‌شود…');
    server.close(() => { DB.close(); process.exit(0); });
    setTimeout(() => { DB.close(); process.exit(0); }, 8000).unref();
  });
}

process.on('unhandledRejection', e => console.error('[unhandledRejection]', e?.stack || e));
