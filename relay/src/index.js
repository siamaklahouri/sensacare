/* ==================== رلهٔ تلگرام ====================
   سرورِ ایرانی به api.telegram.org راه ندارد (سنجیده شد: صفر). این
   ورکرِ کوچک روی کلادفلر می‌ماند و فقط همین یک کار را می‌کند: پیام‌ها
   را رد می‌کند. نه دیتابیسی دارد، نه چیزی نگه می‌دارد.

   دو جهت دارد، چون ارتباطِ ربات دوطرفه است:

   ۱) از سایت به تلگرام — «پشتیبان را بفرست»، «به این کاربر جواب بده»
      سایت:   TG_BASE/bot<توکن>/<متد>
      رله:    api.telegram.org/bot<توکن>/<متد>
      مسیرِ /tg/<رمز> جلویش می‌آید تا این ورکر پروکسیِ باز نشود.

   ۲) از تلگرام به سایت — کسی به ربات پیام می‌دهد
      تلگرام: <آدرسِ رله>/api/sl/bot/telegram?s=…
      رله:    <آدرسِ سایت>/api/sl/bot/telegram?s=…
      این جهت رمزِ جداگانه نمی‌خواهد: فقط همان یک مسیر را رد می‌کند و
      خودِ سایت درستیِ ?s= را می‌سنجد؛ یعنی چیزی که این‌جا رد شود، آن‌جا
      دوباره بررسی می‌شود.

   اگر تلگرام مستقیم به سرورِ ایران برسد، جهتِ دوم لازم نیست و وب‌هوک
   را می‌شود مستقیم روی خودِ سایت گذاشت. این‌جا هست تا اگر نرسید،
   راهِ دیگری لازم نشود. */

/* مقایسهٔ رمز بدونِ نشت دادنِ طولِ تطابق. */
function sameSecret(a, b) {
  if (typeof a !== 'string' || typeof b !== 'string') return false;
  if (a.length !== b.length || !a.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return d === 0;
}

/* هدرهایی که نباید رد شوند: یا مالِ اتصالِ قبلی‌اند یا مالِ کلادفلر. */
const DROP = /^(host|connection|keep-alive|transfer-encoding|upgrade|expect|cf-|x-forwarded-|x-real-ip)/i;

function fwdHeaders(h) {
  const out = new Headers();
  for (const [k, v] of h) if (!DROP.test(k)) out.set(k, v);
  return out;
}

function pass(req, target) {
  const bodyless = req.method === 'GET' || req.method === 'HEAD';
  return fetch(target, {
    method: req.method,
    headers: fwdHeaders(req.headers),
    body: bodyless ? undefined : req.body,
  });
}

const no = (msg, code = 404) =>
  new Response(msg, { status: code, headers: { 'Content-Type': 'text/plain; charset=utf-8' } });

export default {
  async fetch(req, env) {
    const url = new URL(req.url);
    const p = url.pathname;

    /* ---------- زنده‌ای؟ ---------- */
    if (p === '/' || p === '/health')
      return new Response('relay ok', { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });

    /* ---------- ۱) سایت → تلگرام ---------- */
    const out = p.match(/^\/tg\/([^/]+)\/(bot.+)$/);
    if (out) {
      if (!sameSecret(decodeURIComponent(out[1]), env.RELAY_SECRET || ''))
        return no('forbidden', 403);
      return pass(req, 'https://api.telegram.org/' + out[2] + url.search);
    }

    /* ---------- ۲) تلگرام → سایت ---------- */
    if (p.startsWith('/api/sl/bot/')) {
      if (!env.ORIGIN) return no('origin not set', 503);
      return pass(req, env.ORIGIN.replace(/\/+$/, '') + p + url.search);
    }

    return no('not found');
  },
};
