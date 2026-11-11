/* ==================== چرا فایل به تلگرام نمی‌رسد ====================

   پشتیبان به بله می‌رسید و به تلگرام نه، با پیامِ «fetch failed» —
   که در Node تقریباً هیچ معنایی ندارد: قطعِ ارتباط، تمام‌شدنِ مهلت،
   DNS و گواهیِ بد همه همین یک جمله را می‌دهند.

   و یک نکتهٔ گیج‌کننده: همان فایل با curl از همان رله و همان توکن در
   دو ثانیه می‌رفت. یعنی رله و لینک سالم بودند و تفاوت در خودِ
   درخواستِ ما بود.

   این ابزار همان مسیرِ واقعیِ پشتیبان را، تنها و پله‌پله، اجرا
   می‌کند و دو شکلِ بدنه را با هم می‌سنجد:

     • FormData — راهی که بود
     • بدنهٔ دستی با Content-Length — راهی که حالا هست

   هیچ‌چیزی چاپ نمی‌شود جز نتیجه: نه توکن، نه رمزِ رله.

       node /opt/sltech/app/server/tgprobe.mjs
       node /opt/sltech/app/server/tgprobe.mjs 12      (تا ۱۲ مگابایت)
*/
import { DatabaseSync } from 'node:sqlite';
import { readFileSync, existsSync } from 'node:fs';
import { multipart } from '../src/multipart.js';

const envFile = process.env.SLTECH_ENV || '/etc/sltech/env';
if (!existsSync(envFile)) {
  console.error('فایلِ تنظیمات پیدا نشد: ' + envFile);
  process.exit(2);
}
const cfg = {};
for (const line of readFileSync(envFile, 'utf8').split('\n')) {
  const i = line.indexOf('=');
  if (i > 0 && !line.trim().startsWith('#')) cfg[line.slice(0, i).trim()] = line.slice(i + 1).trim();
}

const db = new DatabaseSync(cfg.DB_FILE);
const row = db.prepare('SELECT v FROM settings WHERE k=?').get('sltechSite');
const st = row ? JSON.parse(row.v) : {};
if (!st.tgToken || !st.tgChat) {
  console.error('تلگرام تنظیم نیست. اول: node server/index.js --bot-on tg <توکن> <گفتگو>');
  process.exit(1);
}

/* علتِ واقعی، نه «fetch failed» */
function why(e) {
  const bits = [(e && e.message) || String(e)];
  let c = e && e.cause;
  for (let i = 0; i < 4 && c; i++) {
    const t = c.code || c.message || '';
    if (t && !bits.includes(t)) bits.push(t);
    c = c.cause;
  }
  return bits.join('  ←  ');
}

const base = (cfg.TG_BASE || 'https://api.telegram.org') + '/bot' + st.tgToken;
const host = (() => { try { return new URL(cfg.TG_BASE || 'https://api.telegram.org').host; }
                      catch { return 'رله' } })();
const top = Number(process.argv[2]) || 8;
const SIZES = [1, 3, 6, top].filter((v, i, a) => v > 0 && a.indexOf(v) === i).sort((a, b) => a - b);

console.log('راه: ' + host + ' · گفتگو: ' + st.tgChat + ' · Node ' + process.version);
console.log('توکن: …' + String(st.tgToken).slice(-4));
console.log('');

async function send(how, mb) {
  const data = Buffer.alloc(mb * 1000000, 7);
  const t0 = Date.now();
  let req;
  if (how === 'form') {
    const fd = new FormData();
    fd.append('chat_id', String(st.tgChat));
    fd.append('caption', 'آزمونِ ' + mb + ' مگابایت — FormData');
    fd.append('parse_mode', 'HTML');
    fd.append('document', new Blob([data], { type: 'application/zip' }), 'probe.zip');
    req = { body: fd, headers: undefined };
  } else {
    const m = multipart({
      chat_id: String(st.tgChat),
      caption: 'آزمونِ ' + mb + ' مگابایت — بدنهٔ دستی',
      parse_mode: 'HTML'
    }, { field: 'document', name: 'probe.zip', type: 'application/zip', data });
    req = { body: m.body, headers: m.headers };
  }
  try {
    /* مهلت لازم است و نبودنش یک بار گران تمام شد: نسخهٔ اول این ابزار
       بی‌مهلت بود و روی سرورِ کاربر به‌جای خطا دادن، معلق ماند — یعنی
       ابزارِ تشخیص خودش همان‌جا خوابید. هر تلاش حداکثر یک دقیقه. */
    const r = await fetch(base + '/sendDocument',
      { method: 'POST', body: req.body, headers: req.headers,
        signal: AbortSignal.timeout(60000) });
    const d = await r.json().catch(() => ({}));
    return { ok: !!d.ok, note: d.ok ? '' : (d.description || ('HTTP ' + r.status)),
             s: (Date.now() - t0) / 1000 };
  } catch (e) {
    const timedOut = e && (e.name === 'TimeoutError' || e.name === 'AbortError');
    return { ok: false, timeout: timedOut,
             note: timedOut ? 'معلق ماند — یک دقیقه جوابی نیامد' : why(e),
             s: (Date.now() - t0) / 1000 };
  }
}

const pad = (s, n) => (s + '                 ').slice(0, n);
const times = [];
let bad = 0;

for (const mb of SIZES) {
  for (const how of ['form', 'buf']) {
    const r = await send(how, mb);
    if (!r.ok) bad++; else times.push(r.s);
    console.log('  ' + pad(mb + ' مگابایت', 12) +
      pad(how === 'form' ? 'FormData' : 'بدنهٔ دستی', 12) +
      (r.ok ? '✓ رسید' : '✗ ' + r.note) + '   (' + r.s.toFixed(2) + 's)');
  }
}

/* ---------- نتیجه ----------
   نسخهٔ اول این‌جا می‌گفت «FormData می‌افتد، بدنهٔ دستی می‌رود» و این
   از روی یک نمونه بود: در همان اجرا FormData در هشت مگابایت رفت،
   یعنی بزرگ‌تر از همانی که افتاد. یک شکستِ تکی روی لینکِ پُرنوسان
   قاعده نیست، و ابزاری که از یک نمونه قاعده بسازد بدتر از بی‌ابزاری
   است — آدم را مطمئن می‌کند که اشتباه می‌کند.

   پس حالا فقط آن‌چه دیده شده گزارش می‌شود: چند شکست، و پراکندگیِ
   زمان‌ها. قضاوت با آدم. */
console.log('');
if (times.length) {
  const lo = Math.min(...times), hi = Math.max(...times);
  console.log('زمانِ ارسال: از ' + lo.toFixed(1) + ' تا ' + hi.toFixed(1) + ' ثانیه' +
    (hi > lo * 4 ? '  ← پُرنوسان؛ لینک پایدار نیست' : ''));
}
console.log(bad === 0
  ? 'همه رسید.'
  : bad + ' تلاش از ' + (SIZES.length * 2) + ' نرسید. اگر در اندازه‌های بزرگ‌تر رفته و ' +
    'در کوچک‌تر افتاده، یعنی اندازه مقصر نیست — نوسانِ لینک است.');
