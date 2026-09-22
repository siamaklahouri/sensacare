/* پنل ادمینِ کارتابل‌ها — <دامنهٔ پنل>/login
   =================================================================
   از این‌جا کارتابل تازه ساخته می‌شود، هر دو رمزِ هر کاربر عوض می‌شود
   و فهرستِ بخش‌های «دیتای شخصی»‌اش تعیین می‌گردد.

   دربارهٔ رمزِ دیتای شخصی یک قاعده هست که این فایل هم می‌شکندش و هم
   نمی‌شکند: کلیدِ رمزگشاییِ آن صندوق هیچ‌وقت به سرور نمی‌رسد. برای
   اینکه ادمین بتواند بازش کند، مرورگرِ کاربر رمزش را با «کلید عمومیِ
   ادمین» می‌پیچد و همان بستهٔ پیچیده روی سرور می‌ماند. کلیدِ خصوصیِ
   ادمین هم روی سرور است، ولی خودش با رمزِ ادمین رمز شده — رمزی که
   برای باز کردنِ این کلید فقط در مرورگرِ ادمین تایپ می‌شود و هیچ‌وقت
   فرستاده نمی‌شود (سرور نسخهٔ PBKDF2-شده‌اش را دارد، نه خودش). یعنی
   سرور هر دو تکه را دارد و باز هم نمی‌تواند بخواند. */

import {
  json, bad, hashPassword, checkPassword, makeSession, readSession, cookieHeader,
  getSetting, setSetting, all, one, run, newPassword, panelBySlug, allPanels,
  PANELS, kartablBot, tgMessage, botMessage, botsReady, FEATURES, VIEWS, isFeature, enabledViews, panelByUser,
  handleKartabl
} from './kartabl.js';
import { JOBS } from './kartabl-jobs.js';

export const ADMIN_PAGE = '/login';
/* نشانیِ قبلی. با ۳۰۱ به «/login» می‌رود تا بوکمارک‌ها و لینک‌هایی که
   دست کاربرهاست از کار نیفتند. */
export const ADMIN_PAGE_OLD = '/admin.planer';

/* ادمین هم مثل کارتابل‌ها یک «پنل» است، فقط بی‌داده: همان ساز و کارِ
   کوکی و شمارهٔ نسل بدون نوشتنِ دوبارهٔ آن. */
const ADMIN = {
  id: 'admin.planer',
  cookie: 'kartabl_admin',
  keys: { pass: 'adminPlanerPassHash', gen: 'adminPlanerPassGen' }
};

const SLUG_RE = /^[a-z0-9][a-z0-9-]{1,30}$/;
/* نام کاربری کمی بازتر از آدرس است — نقطه و زیرخط هم می‌گیرد — چون
   آدرس در URL می‌نشیند و این یکی فقط در فرمِ ورود. */
const USER_RE = /^[a-z0-9][a-z0-9._-]{1,30}$/;
const ADMIN_USER_KEY = 'adminPlanerUser';
const DEFAULT_ADMIN_USER = 'admin';
const adminUser = env => getSetting(env, ADMIN_USER_KEY, DEFAULT_ADMIN_USER);

/* نامِ کاربری نباید تکراری باشد؛ نه با کاربرِ دیگر، نه با خودِ ادمین.
   وگرنه یکی از آن دو دیگر نمی‌تواند وارد شود. */
async function userTaken(env, user, exceptSlug) {
  if (user === (await adminUser(env)).toLowerCase()) return true;
  const p = await panelByUser(env, user);
  return !!(p && p.slug !== exceptSlug);
}
/* آدرس‌هایی که قبلاً مالِ خودِ سایت‌اند و نباید کارتابل شوند */
const RESERVED = new Set(['admin', 'admin.planer', 'api', 'f', 'v', 'assets', 'cart',
  'checkout', 'shop', 'product', 'products', 'blog', 'about', 'contact', 'login',
  'logout', 'search', 'sitemap', 'robots', 'favicon', '_t', 'icon']);

const KINDS = new Set(['it', 'fin', 'gen']);
const VAULT_TYPES = new Set(['creds', 'inst', 'contacts', 'table']);

/* ---------- ساختنِ تنظیماتِ یک کارتابلِ تازه ---------- */

function freshConfig(slug, name, kind, job, vault) {
  return {
    title: 'کارتابل ماهانه ' + name,
    api: slug,
    cookie: 'kartabl_' + slug,
    icon: '/icon-' + (kind === 'it' ? 'siamak' : kind === 'fin' ? 'sina' : 'reza') + '.2.png',
    store: slug + '-planner-v1',
    idb: slug + '-fs-db',
    dbcache: slug + '-db-cache-v1',
    filejson: 'کارتابل-' + name + '-داده.json',
    filexlsx: 'کارتابل-' + name + '-دیتابیس.xlsx',
    folder: 'کارتابل ' + name,
    zip: 'kartabl-' + slug + '-',
    job: job || '',
    user: slug,
    vault: vault,
    keys: {
      state: slug + ':state', db: slug + ':db',
      pass: slug + 'PassHash', gen: slug + 'PassGen',
      last: slug + 'LastBackup', reset: slug + 'PassReset'
    }
  };
}

function cleanVault(list) {
  const seen = new Set();
  return (Array.isArray(list) ? list : [])
    .filter(s => s && typeof s.id === 'string' && SLUG_RE.test(s.id) && VAULT_TYPES.has(s.type))
    .filter(s => !seen.has(s.id) && seen.add(s.id))
    .slice(0, 12)
    .map(s => ({
      id: s.id, type: s.type, title: String(s.title || s.id).slice(0, 60),
      ...(Array.isArray(s.cols)
        ? { cols: s.cols.map(c => String(c).slice(0, 40)).filter(Boolean).slice(0, 10) }
        : {})
    }));
}

const DEFAULT_VAULT = [{ id: 'creds', type: 'creds', title: 'شرکت‌های من' },
                       { id: 'inst', type: 'inst', title: 'اقساط' }];

/* ---------- تنظیماتِ سایت ---------- */
const SITE_KEY = 'sltechSite';
const MAX_PLANS = 6;

/* آنچه بیرون می‌رود: همه‌چیز جز توکن‌ها. */
const publicSite = st => ({
  telegram: st.telegram || '', bale: st.bale || '',
  phone: st.phone || '', email: st.email || '',
  card: st.card || '', cardName: st.cardName || '',
  /* هر ربات گفتگوی خودش را دارد: پشتیبان و پیام‌ها به هر دو می‌روند. */
  tgChat: st.tgChat || '', baleChat: st.baleChat || '',
  plans: Array.isArray(st.plans) ? st.plans : []
});

/* «هست یا نیست» و چهار رقمِ آخر — نه خودِ توکن. */
const tail = t => (typeof t === 'string' && t.length > 4) ? t.slice(-4) : '';
const botState = st => ({
  telegram: { set: !!st.tgToken, tail: tail(st.tgToken) },
  bale: { set: !!st.baleToken, tail: tail(st.baleToken) }
});

function cleanSite(body, cur) {
  const site = Object.assign({}, cur);
  const txt = (v, n) => String(v == null ? '' : v).trim().slice(0, n);

  for (const [k, n] of [['telegram', 80], ['bale', 80], ['phone', 30],
                        ['email', 80], ['cardName', 60],
                        ['tgChat', 40], ['baleChat', 40]])
    if (body[k] !== undefined) site[k] = txt(body[k], n);

  if (body.card !== undefined) {
    /* فقط رقم نگه می‌داریم؛ فاصله و خط تیره‌ای که آدم وسطش می‌گذارد
       نباید در داده بماند. */
    const card = txt(body.card, 30).replace(/[^0-9]/g, '');
    if (card && card.length !== 16) return { error: 'شمارهٔ کارت باید ۱۶ رقم باشد.' };
    site.card = card;
  }

  if (body.plans !== undefined) {
    if (!Array.isArray(body.plans)) return { error: 'فهرست پلن‌ها درست نیست.' };
    const plans = [];
    for (const raw of body.plans.slice(0, MAX_PLANS)) {
      const name = txt(raw && raw.name, 40);
      if (!name) continue;
      const price = Number(raw.price);
      const days = Number(raw.days);
      if (!Number.isFinite(price) || price < 0 || price > 1e12)
        return { error: 'قیمتِ «' + name + '» درست نیست.' };
      if (!Number.isFinite(days) || days < 0 || days > 3650)
        return { error: 'مدتِ «' + name + '» باید بین ۰ تا ۳۶۵۰ روز باشد.' };
      plans.push({ name, price: Math.round(price), days: Math.round(days),
                   note: txt(raw.note, 120) });
    }
    site.plans = plans;
  }

  /* توکن: خالی یعنی دست نزن، «-» یعنی پاکش کن. */
  for (const [field, key] of [['tgToken', 'tgToken'], ['baleToken', 'baleToken']]) {
    if (body[field] === undefined) continue;
    const v = String(body[field]).trim();
    if (!v) continue;
    if (v === '-') { delete site[key]; continue; }
    if (v.length < 20) return { error: 'توکنِ ربات کوتاه‌تر از آن است که درست باشد.' };
    site[key] = v.slice(0, 200);
  }
  return { site };
}

/* ---------- سیاههٔ کارها ----------
   هر کاری که ادمین می‌کند این‌جا می‌ماند. نه برای اینکه به کسی
   گزارش برود، برای اینکه اگر فردا چیزی سرِ جایش نبود بشود فهمید
   کِی و چه اتفاقی افتاده. */
async function log(env, what, slug, note) {
  try {
    await run(env, 'INSERT INTO admin_log(at, what, slug, note) VALUES(?,?,?,?)',
      Date.now(), what, slug || '', note || '');
  } catch (e) { /* جدول نبود؟ کارِ ادمین نباید بخاطرش بخوابد */ }
}

/* ---------- مسیرها ---------- */

export async function handleAdminPlaner(env, req, p, m, body, helpers) {
  const { rateLimit, clientIp } = helpers;

  /* ---------- اولین راه‌اندازی ----------
     تا وقتی رمزی نیست این پنل بی‌صاحب است، و هر کسی که آدرس را حدس بزند
     می‌تواند صاحبش شود. پس رمزِ اول با کدی گذاشته می‌شود که فقط به همان
     گفتگوی تلگرامی می‌رود که پشتیبان‌ها می‌روند — یعنی فقط کسی که به آن
     ربات دسترسی دارد. */
  if (p === '/setup-code' && m === 'POST') {
    if (await getSetting(env, ADMIN.keys.pass, ''))
      return bad('رمز ادمین از قبل تنظیم شده.', 409);
    const rl = await rateLimit(env, 'adminplaner-code:' + clientIp(req), 5, 3600);
    if (!rl.ok) return bad('درخواست‌ها زیاد شد. یک ساعت دیگر.', 429);
    if (!(await botsReady(env)))
      return bad('ربات وصل نیست، پس جایی برای فرستادن کد نیست.', 503);
    const code = newPassword(2, 4);
    await setSetting(env, 'adminPlanerSetupCode',
      { hash: await hashPassword(code), until: Date.now() + 15 * 60 * 1000 });
    const sent = await botMessage(env,
      '🛠 <b>راه‌اندازی پنل کارتابل‌ها</b>\n\n' +
      `<code>${code}</code>\n\n` +
      'این کد تا ۱۵ دقیقه معتبر است و فقط برای گذاشتنِ رمزِ اولِ پنل به کار می‌آید. ' +
      'اگر شما این درخواست را نداده‌اید، یعنی کسی آدرس پنل را پیدا کرده — ' +
      'همین حالا خودتان رمز را بگذارید.');
    if (!sent.ok) return bad('به ربات نرسید: ' + sent.error, 502);
    return json({ ok: true });
  }

  if (p === '/setup' && m === 'POST') {
    if (await getSetting(env, ADMIN.keys.pass, ''))
      return bad('رمز ادمین از قبل تنظیم شده. از همان استفاده کنید.', 409);
    const rl = await rateLimit(env, 'adminplaner-setup:' + clientIp(req), 10, 3600);
    if (!rl.ok) return bad('تلاش زیاد بود.', 429);
    const saved = await getSetting(env, 'adminPlanerSetupCode', null);
    if (!saved || !saved.hash) return bad('اول کدِ راه‌اندازی را بگیرید.', 403);
    if (!(saved.until > Date.now())) return bad('کد منقضی شده. یکی تازه بگیرید.', 403);
    const codeCheck = await checkPassword(String(body.code || '').trim(), saved.hash);
    if (!codeCheck.ok) return bad('کدِ راه‌اندازی درست نیست.', 403);
    const pass = String(body.password || '').trim();
    if (pass.length < 10) return bad('رمزِ ادمین دست‌کم ۱۰ حرف باشد.');
    /* نامِ کاربریِ ادمین هم همین‌جا انتخاب می‌شود؛ نگفته باشد «admin». */
    const user = (String(body.user || '').trim() || DEFAULT_ADMIN_USER).toLowerCase();
    if (!USER_RE.test(user))
      return bad('نام کاربری فقط حروف انگلیسی کوچک، عدد، نقطه، خط تیره و زیرخط — بین ۲ تا ۳۱ حرف.');
    if (await panelByUser(env, user)) return bad('این نام کاربری مالِ یکی از کارتابل‌هاست.');
    await setSetting(env, ADMIN_USER_KEY, user);
    await setSetting(env, ADMIN.keys.pass, await hashPassword(pass));
    await setSetting(env, ADMIN.keys.gen, 1);
    await setSetting(env, 'login:admin.planer', Date.now());
    await run(env, 'DELETE FROM settings WHERE k=?', 'adminPlanerSetupCode');
    await log(env, 'setup', '', '');
    return json({ ok: true, lastLogin: 0 }, 200,
      { 'Set-Cookie': cookieHeader(ADMIN, await makeSession(env, ADMIN, 1), 1) });
  }

  /* ---------- ورودِ مشترک ----------
     یک صفحهٔ ورود برای همه: کاربر نام کاربری و رمزش را می‌زند و به
     کارتابلِ خودش می‌رود؛ ادمین همان‌جا وارد پنل می‌شود. چون هر دو از
     یک فرم می‌آیند، پیامِ خطا هم یکی است — وگرنه همین صفحه می‌شد
     فهرستی از اینکه کدام نام کاربری روی سایت هست.

     نشستی هم که این‌جا ساخته می‌شود دقیقاً همان نشستِ خودِ کارتابل
     است (همان کوکی، همان نسلِ رمز)، پس عوض‌شدنِ رمز از هر جایی که
     باشد این ورود را هم باطل می‌کند. */
  if (p === '/signin' && m === 'POST') {
    /* سقف را دست‌ودل‌بازتر از یک کارتابلِ تنها گرفته‌ایم: این‌جا همهٔ
       کاربرها از یک فرم وارد می‌شوند و چند نفرشان می‌توانند پشتِ یک
       IP باشند. جلوی حدسِ پیاپیِ رمز را هم PBKDF2 و هم مکثِ خودِ
       بررسیِ رمز می‌گیرد. */
    const rl = await rateLimit(env, 'adminplaner-signin:' + clientIp(req), 30, 900);
    if (!rl.ok) return bad('تلاش زیاد بود. چند دقیقه صبر کنید.', 429);
    const user = String(body.user || '').trim().toLowerCase();
    const pass = String(body.password || '');
    const nope = () => bad('نام کاربری یا رمز درست نیست.', 401);
    if (!user || !pass) return nope();
    const days = body.remember ? 7 : 1;

    if (user === (await adminUser(env)).toLowerCase()) {
      const stored = await getSetting(env, ADMIN.keys.pass, '');
      if (!stored) return bad('هنوز رمزِ ادمین گذاشته نشده.', 409);
      const check = await checkPassword(pass, stored);
      if (!check.ok) return check.status === 429 ? bad(check.error, 429) : nope();
      const prev = await getSetting(env, 'login:admin.planer', 0);
      await setSetting(env, 'login:admin.planer', Date.now());
      await log(env, 'login', '', 'ورودِ مشترک');
      return json({ ok: true, admin: true, name: 'ادمین', lastLogin: prev || 0 }, 200,
        { 'Set-Cookie': cookieHeader(ADMIN, await makeSession(env, ADMIN, days), days) });
    }

    const panel = await panelByUser(env, user);
    if (!panel) return nope();
    const stored = await getSetting(env, panel.keys.pass, '');
    if (!stored) return nope();
    const check = await checkPassword(pass, stored);
    if (!check.ok) return check.status === 429 ? bad(check.error, 429) : nope();
    /* رمزِ درست را اول بررسی می‌کنیم و بعد می‌گوییم کارتابل بسته است:
       این‌طور کسی که رمز را ندارد از پیام هم چیزی نمی‌فهمد. */
    if (panel.disabled)
      return bad(panel.expired && !panel.manualOff
        ? 'مهلتِ استفاده از این کارتابل تمام شده. با مدیر تماس بگیرید.'
        : 'این کارتابل فعلاً بسته است. با مدیر تماس بگیرید.', 403);
    const loginKey = 'login:' + panel.slug;
    const prev = await getSetting(env, loginKey, 0);
    await setSetting(env, loginKey, Date.now());
    return json({ ok: true, admin: false, go: panel.page, name: panel.name,
                  lastLogin: prev || 0 }, 200,
      { 'Set-Cookie': cookieHeader(panel, await makeSession(env, panel, days), days) });
  }

  /* فراموشیِ رمز از همین صفحه: نام کاربری را می‌گیریم تا بفهمیم کدام
     کارتابل، و بقیه‌اش دقیقاً همان مسیرِ فراموشیِ خودِ کارتابل است —
     رمزِ تازه فقط به تلگرام می‌رود، نه به این صفحه. */
  if (p === '/forgot' && m === 'POST') {
    const rl = await rateLimit(env, 'adminplaner-forgot:' + clientIp(req), 6, 3600);
    if (!rl.ok) return bad('درخواست‌ها زیاد شد. یک ساعت دیگر.', 429);
    const user = String(body.user || '').trim().toLowerCase();
    if (!user) return bad('اول نام کاربری را بنویسید.');
    const panel = await panelByUser(env, user);
    if (!panel) return bad('چنین نام کاربری‌ای نیست.', 404);
    if (panel.disabled) return bad('این کارتابل فعلاً بسته است. با مدیر تماس بگیرید.', 403);
    return handleKartabl(env, req, panel, '/forgot', 'POST', body, helpers);
  }

  if (p === '/login' && m === 'POST') {
    const rl = await rateLimit(env, 'adminplaner-login:' + clientIp(req), 10, 900);
    if (!rl.ok) return bad('تلاش زیاد بود. چند دقیقه صبر کنید.', 429);
    const stored = await getSetting(env, ADMIN.keys.pass, '');
    const check = await checkPassword(String(body.password || ''), stored);
    if (!check.ok) return bad(check.error, check.status);
    const days = body.remember ? 7 : 1;
    const prev = await getSetting(env, 'login:admin.planer', 0);
    await setSetting(env, 'login:admin.planer', Date.now());
    await log(env, 'login', '', '');
    return json({ ok: true, lastLogin: prev || 0 }, 200,
      { 'Set-Cookie': cookieHeader(ADMIN, await makeSession(env, ADMIN, days), days) });
  }

  if (p === '/logout' && m === 'POST')
    return json({ ok: true }, 200, { 'Set-Cookie': cookieHeader(ADMIN, '', 0) });

  const session = await readSession(env, ADMIN, req);
  if (p === '/me')
    return json(session
      ? { in: true, lastLogin: await getSetting(env, 'login:admin.planer', 0),
          user: await adminUser(env) }
      : { in: false, needsSetup: !(await getSetting(env, ADMIN.keys.pass, '')) });
  if (!session) return bad('وارد نشده‌اید.', 401);

  /* ---- فهرستِ کارتابل‌ها ---- */
  if (p === '/planners' && m === 'GET') {
    const rows = await all(env, 'SELECT slug, name, kind, cfg, created FROM planners ORDER BY created, slug');
    const known = new Set(rows.map(r => r.slug));
    const items = [];
    for (const r of rows) {
      let c = {};
      try { c = JSON.parse(r.cfg); } catch (e) { /* خرابش را هم نشان بده */ }
      items.push({
        slug: r.slug, name: r.name, kind: r.kind, job: c.job || '',
        user: String(c.user || r.slug).toLowerCase(),
        /* «disabled» یعنی ادمین با دست بسته؛ «closed» یعنی عملاً بسته
           است — چه با دست، چه چون مهلتش سر رسیده. */
        disabled: !!c.disabled,
        until: Number(c.until) || 0,
        closed: !!c.disabled || (Number(c.until) > 0 && Date.now() > Number(c.until)),
        off: (Array.isArray(c.off) ? c.off : []).filter(f => FEATURES.includes(f)),
        views: enabledViews(c, r.kind === 'it' ? 'it' : r.kind === 'fin' ? 'fin' : 'gen'),
        core: Object.values(PANELS).some(b => b.slug === r.slug),
        vault: Array.isArray(c.vault) ? c.vault : DEFAULT_VAULT,
        url: '/' + r.slug + '/', created: r.created,
        hasPassword: !!(await getSetting(env, (c.keys || {}).pass || '', '')),
        lastLogin: await getSetting(env, 'login:' + r.slug, 0),
        hasEscrow: !!(await getSetting(env, 'escrow:' + r.slug, null)),
        builtin: false
      });
    }
    /* کارتابل‌هایی که هنوز فقط داخل کد هستند هم دیده شوند */
    for (const b of Object.values(PANELS))
      if (!known.has(b.slug))
        items.push({ slug: b.slug, name: b.name, kind: b.kind, job: '', vault: DEFAULT_VAULT,
                     user: b.user || b.slug,
                     disabled: false, closed: false, core: true, off: [], until: 0,
                     views: (VIEWS[b.kind] || []).map(v => v.id),
                     url: b.page, created: 0, builtin: true,
                     hasPassword: !!(await getSetting(env, b.keys.pass, '')),
                     lastLogin: await getSetting(env, 'login:' + b.slug, 0),
                     hasEscrow: !!(await getSetting(env, 'escrow:' + b.slug, null)) });
    return json({
      items,
      kinds: [
        { id: 'gen', label: 'عمومی', icon: '🗂',
          note: 'داشبورد، چک‌لیست ماهانه، برنامهٔ روزانه، دیتای شخصی، دستیار — برای هر شغلی' },
        { id: 'it', label: 'مدیر IT', icon: '🖥',
          note: 'همهٔ بخش‌های عمومی، به‌علاوهٔ سرورها و بکاپ، شرکت‌ها، MVPN و تبدیل تاریخ' },
        { id: 'fin', label: 'مالی', icon: '💰',
          note: 'اسناد دریافتنی و پرداختنی، بدهی‌ها، منابع و مصارف، بانک، بودجه و طرف‌حساب‌ها' }
      ],
      /* پیشنهادِ هر شغل هم می‌رود، تا پنل با انتخابِ شغل تیک‌ها را
         همان‌جا جابه‌جا کند. */
      jobs: Object.entries(JOBS).map(([id, j]) => ({ id, label: j.label, views: j.views || [] })),
      vaultTypes: [{ id: 'creds', label: 'شرکت‌ها و رمزها' }, { id: 'inst', label: 'اقساط و وام' },
                   { id: 'contacts', label: 'دفتر تلفن' }, { id: 'table', label: 'جدول دل‌خواه' }],
      features: [
        { id: 'pass', label: 'عوض کردن رمز ورود', note: 'کاربر بتواند رمز ورودِ خودش را عوض کند' },
        { id: 'backup', label: 'تنظیم پشتیبان تلگرام', note: 'ربات و گفتگوی پشتیبان و ارسال دستی' },
        { id: 'ai', label: 'دستیار هوشمند', note: 'خودِ دستیار — بخشش از نوار کنار برداشته می‌شود' },
        { id: 'aikey', label: 'تنظیم موتور دستیار', note: 'کاربر نتواند کلید هوش مصنوعی را عوض کند' },
        { id: 'vault', label: 'دیتای شخصی', note: 'بخش رمزدارِ شخصی کاربر' },
        { id: 'files', label: 'پشتیبان و بازیابی دستی', note: 'دکمه‌های گرفتن و برگرداندن فایل' },
        { id: 'folder', label: 'آینهٔ اکسل روی سیستم', note: 'اتصال به پوشهٔ مشترک' }
      ],
      /* بخش‌های خودِ کارتابل، جدا برای هر نوع */
      views: VIEWS,
      escrowReady: !!(await getSetting(env, 'vaultEscrowPub', null))
    });
  }

  /* ---- ساختنِ کارتابل ---- */
  if (p === '/planners' && m === 'POST') {
    const name = String(body.name || '').trim().slice(0, 40);
    const slug = String(body.slug || '').trim().toLowerCase();
    const kind = String(body.kind || 'gen');
    const job = String(body.job || '');
    if (!name) return bad('نام شخص را بنویسید.');
    if (!SLUG_RE.test(slug))
      return bad('آدرس فقط حروف انگلیسی کوچک، عدد و خط تیره — بین ۲ تا ۳۱ حرف.');
    if (RESERVED.has(slug)) return bad('این آدرس مالِ خودِ سایت است. یکی دیگر انتخاب کنید.');
    if (!KINDS.has(kind)) return bad('نوع کارتابل درست نیست.');
    if (job && !JOBS[job]) return bad('شغل انتخاب‌شده را نمی‌شناسم.');
    if (await one(env, 'SELECT slug FROM planners WHERE slug=?', slug))
      return bad('کارتابلی با این آدرس هست.');
    if (Object.values(PANELS).some(b => b.slug === slug))
      return bad('کارتابلی با این آدرس هست.');

    /* نام کاربری: اگر چیزی نگفته باشد، همان آدرس. */
    const user = (String(body.user || '').trim() || slug).toLowerCase();
    if (!USER_RE.test(user))
      return bad('نام کاربری فقط حروف انگلیسی کوچک، عدد، نقطه، خط تیره و زیرخط — بین ۲ تا ۳۱ حرف.');
    if (await userTaken(env, user))
      return bad('این نام کاربری گرفته شده.');

    /* تیکِ ادمین در همان فرمِ ساخت هم خوانده می‌شود؛ اگر چیزی نگفته
       باشد، پیشنهادِ شغل می‌نشیند. */
    const allViews = (VIEWS[kind] || []).map(v => v.id);
    const views = Array.isArray(body.views)
      ? body.views.filter(v => allViews.includes(v)) : null;
    const vault = cleanVault(body.vault);
    const cfg = freshConfig(slug, name, kind, job, vault.length ? vault : DEFAULT_VAULT);
    cfg.user = user;
    if (views) cfg.views = views;
    const pass = String(body.password || '').trim() || newPassword();
    await run(env, 'INSERT INTO planners(slug,name,kind,cfg,created) VALUES(?,?,?,?,?)',
      slug, name, kind, JSON.stringify(cfg), Date.now());
    await setSetting(env, cfg.keys.pass, await hashPassword(pass));
    await setSetting(env, cfg.keys.gen, 1);
    await log(env, 'create', slug, kind + (job ? '/' + job : ''));
    /* رمز فقط همین یک‌بار برمی‌گردد — جایی ذخیره نمی‌شود. */
    return json({ ok: true, slug, url: '/' + slug + '/', user, password: pass });
  }

  /* از این‌جا به بعد همه دربارهٔ یک کارتابلِ مشخص‌اند */
  const mSlug = p.match(/^\/planners\/([a-z0-9-]+)(\/[a-z-]+)?$/);
  if (mSlug) {
    const slug = mSlug[1];
    const sub = mSlug[2] || '';
    const panel = await panelBySlug(env, slug);
    if (!panel) return bad('چنین کارتابلی نیست.', 404);
    const row = await one(env, 'SELECT cfg, kind FROM planners WHERE slug=?', slug);
    const row0 = row || {};
    const builtin = !row;
    /* سه کارتابلِ اصلی داخلِ خودِ کد هم هستند: با پاک شدنِ ردیفشان
       دوباره سبز می‌شوند، ولی داده‌شان رفته. پس حذفشان اصلاً نباید
       شروع شود. غیرفعال‌کردنشان اشکالی ندارد، چون برگشت‌پذیر است. */
    const core = Object.values(PANELS).some(b => b.slug === slug);

    /* --- ویرایش: نام، شغل، بخش‌های شخصی --- */
    if (sub === '' && m === 'PUT') {
      if (builtin) return bad('این کارتابل هنوز در جدول نیست؛ یک‌بار مهاجرتش کنید.', 409);
      let cfg;
      try { cfg = JSON.parse(row.cfg); } catch (e) { return bad('تنظیماتِ این کارتابل خوانا نیست.', 500); }
      const name = String(body.name || '').trim().slice(0, 40);
      if (name) { cfg.title = 'کارتابل ماهانه ' + name; }
      if (typeof body.job === 'string') {
        if (body.job && !JOBS[body.job]) return bad('شغل انتخاب‌شده را نمی‌شناسم.');
        cfg.job = body.job;
      }
      if (typeof body.user === 'string' && body.user.trim()) {
        const user = body.user.trim().toLowerCase();
        if (!USER_RE.test(user))
          return bad('نام کاربری فقط حروف انگلیسی کوچک، عدد، نقطه، خط تیره و زیرخط — بین ۲ تا ۳۱ حرف.');
        if (await userTaken(env, user, slug)) return bad('این نام کاربری گرفته شده.');
        cfg.user = user;
      }
      if (body.days !== undefined) {
        /* عددِ روز می‌گیریم و تاریخِ پایان را حساب می‌کنیم؛ خالی یا صفر
           یعنی بی‌مهلت. سقفِ ده سال تا یک صفرِ اضافه تاریخ را پرت نکند. */
        const d = Number(body.days);
        if (body.days === null || body.days === '' || d === 0) cfg.until = 0;
        else if (!Number.isFinite(d) || d < 0 || d > 3650)
          return bad('تعداد روز باید عددی بین ۱ تا ۳۶۵۰ باشد.');
        else cfg.until = Date.now() + Math.round(d) * 86400000;
      }
      if (body.off !== undefined) {
        if (!Array.isArray(body.off)) return bad('فهرست بخش‌های بسته درست نیست.');
        const bad_ = body.off.filter(f => !FEATURES.includes(f));
        if (bad_.length) return bad('بخشِ ناشناخته: ' + bad_.join('، '));
        cfg.off = [...new Set(body.off)];
      }
      if (body.views !== undefined) {
        if (!Array.isArray(body.views)) return bad('فهرست بخش‌های کارتابل درست نیست.');
        const kind = row0.kind === 'it' ? 'it' : row0.kind === 'fin' ? 'fin' : 'gen';
        const all = (VIEWS[kind] || []).map(v => v.id);
        const bad2 = body.views.filter(v => !all.includes(v));
        if (bad2.length) return bad('بخشِ ناشناخته: ' + bad2.join('، '));
        cfg.views = [...new Set(body.views)];
      }
      if (body.vault !== undefined) {
        const v = cleanVault(body.vault);
        if (!v.length) return bad('دست‌کم یک بخش باید باز بماند.');
        cfg.vault = v;
      }
      await run(env, 'UPDATE planners SET name=COALESCE(NULLIF(?,\'\'), name), cfg=? WHERE slug=?',
        name, JSON.stringify(cfg), slug);
      await log(env, 'update', slug, Object.keys(body).join(','));
      return json({ ok: true });
    }

    /* --- حذف --- */
    if (sub === '' && m === 'DELETE') {
      if (builtin || core) return bad('کارتابل‌های اصلی حذف نمی‌شوند — می‌توانید غیرفعالشان کنید.', 403);
      /* سافاری خودش آدرسِ کامل را داخل کادر می‌ریزد و تأیید هیچ‌وقت
         نمی‌خواند. آخرین تکهٔ آدرس همان چیزی است که خواسته‌ایم. */
      const typed = String(body.confirm || '').trim().toLowerCase()
        .replace(/^https?:\/\//, '').replace(/[?#].*$/, '')
        .replace(/\/+$/, '').split('/').filter(Boolean).pop() || '';
      if (typed !== slug)
        return bad('برای حذف، آدرس کارتابل را دقیقاً تایپ کنید.');
      const keys = panel.keys || {};
      await run(env, 'DELETE FROM planners WHERE slug=?', slug);
      await run(env, 'DELETE FROM kartabl WHERE k IN (?,?)', keys.state, keys.db);
      try { await run(env, 'DELETE FROM kartabl_hist WHERE k IN (?,?)', keys.state, keys.db); } catch (e) {}
      for (const k of [keys.pass, keys.gen, keys.last, keys.reset,
                       'login:' + slug, 'escrow:' + slug])
        await run(env, 'DELETE FROM settings WHERE k=?', k);
      await log(env, 'delete', slug, '');
      return json({ ok: true });
    }

    /* --- غیرفعال یا فعال کردن ---
       برخلافِ حذف، این کار برگشت‌پذیر است: داده و رمز و تاریخچه سرِ
       جایشان می‌مانند، فقط در بسته می‌شود و پشتیبانِ خودکار هم برایش
       نمی‌رود. */
    if (sub === '/state' && m === 'POST') {
      if (builtin) return bad('این کارتابل هنوز در جدول نیست؛ یک‌بار مهاجرتش کنید.', 409);
      let cfg;
      try { cfg = JSON.parse(row.cfg); } catch (e) { return bad('تنظیماتِ این کارتابل خوانا نیست.', 500); }
      const off = !!body.disabled;
      cfg.disabled = off;
      /* روشن‌کردنِ کارتابلی که مهلتش گذشته، بدون برداشتنِ مهلت بی‌فایده
         است: لحظهٔ بعد دوباره خودش بسته می‌شود. */
      if (!off && Number(cfg.until) && Date.now() > Number(cfg.until)) {
        const d = Number(body.days);
        cfg.until = (Number.isFinite(d) && d > 0 && d <= 3650)
          ? Date.now() + Math.round(d) * 86400000 : 0;
      }
      await run(env, 'UPDATE planners SET cfg=? WHERE slug=?', JSON.stringify(cfg), slug);
      /* هر دستگاهی که وارد مانده باید بیرون بیفتد، وگرنه تا وقتی کوکی
         دارد کارتابلِ بسته هم برایش باز می‌ماند. */
      if (off) await setSetting(env, panel.keys.gen, (await getSetting(env, panel.keys.gen, 1)) + 1);
      await log(env, off ? 'disable' : 'enable', slug, '');
      return json({ ok: true, disabled: off });
    }

    /* --- رمزِ ورود به کارتابل --- */
    if (sub === '/password' && m === 'POST') {
      const pass = String(body.password || '').trim() || newPassword();
      if (pass.length < 8) return bad('رمز کوتاه است — دست‌کم ۸ حرف.');
      await setSetting(env, panel.keys.pass, await hashPassword(pass));
      /* شمارهٔ نسل بالا می‌رود: هر دستگاهی که وارد مانده بیرون می‌افتد. */
      await setSetting(env, panel.keys.gen, (await getSetting(env, panel.keys.gen, 1)) + 1);
      await log(env, 'password', slug, '');
      return json({ ok: true, password: pass });
    }

    /* --- بستهٔ پیچیدهٔ رمزِ دیتای شخصی --- */
    if (sub === '/escrow' && m === 'GET') {
      const e = await getSetting(env, 'escrow:' + slug, null);
      if (!e) return bad('این کاربر هنوز رمزِ دیتای شخصی‌اش را به کلیدِ ادمین نسپرده.', 404);
      return json({ ok: true, escrow: e });
    }

    /* --- خواندن و نوشتنِ خودِ صندوق، برای عوض‌کردنِ رمزش --- */
    if (sub === '/vault' && m === 'GET') {
      const r = await one(env, 'SELECT v FROM kartabl WHERE k=?', panel.keys.state);
      if (!r) return bad('این کارتابل هنوز داده‌ای ندارد.', 404);
      let st;
      try { st = JSON.parse(r.v); } catch (e) { return bad('دادهٔ این کارتابل خوانا نیست.', 500); }
      return json({ ok: true, vault: st.personalVault || null,
                    recovery: st.personalRecovery || null });
    }

    if (sub === '/vault' && m === 'PUT') {
      if (!body.vault || !body.vault.cipher) return bad('صندوقِ تازه ناقص است.');
      const r = await one(env, 'SELECT v, rev FROM kartabl WHERE k=?', panel.keys.state);
      if (!r) return bad('این کارتابل هنوز داده‌ای ندارد.', 404);
      let st;
      try { st = JSON.parse(r.v); } catch (e) { return bad('دادهٔ این کارتابل خوانا نیست.', 500); }
      /* فقط همین سه کلید دست می‌خورد. بقیهٔ کارتابل حتی خوانده هم
         نمی‌شود که اشتباهی جایی برود. */
      st.personalVault = body.vault;
      st.personalRecovery = body.recovery || null;
      const rev = (r.rev || 0) + 1;
      await run(env, 'UPDATE kartabl SET v=?, rev=?, updated=? WHERE k=?',
        JSON.stringify(st), rev, Date.now(), panel.keys.state);
      if (body.escrow) await setSetting(env, 'escrow:' + slug, body.escrow);
      await log(env, 'vault-password', slug, '');
      return json({ ok: true, rev });
    }
  }

  /* ---- رمزِ خودِ ادمین ---- */
  /* ---- تنظیماتِ سایت ----
     چیزهایی که به کد ربطی ندارند و باید بدون انتشارِ تازه عوض شوند:
     راه‌های تماس، شمارهٔ کارت، پلن‌ها، و توکنِ ربات‌ها.

     توکن‌ها یک‌طرفه‌اند: نوشته می‌شوند ولی هیچ‌وقت برنمی‌گردند. پنل فقط
     می‌گوید «گذاشته شده یا نه» و چهار رقمِ آخر را نشان می‌دهد تا بشود
     تشخیص داد کدام است — وگرنه هر کسی که یک‌بار به پنل برسد می‌توانست
     توکن را بردارد و ببرد. */
  if (p === '/site' && m === 'GET') {
    const st = await getSetting(env, SITE_KEY, {});
    return json({ ok: true, site: publicSite(st), bots: botState(st) });
  }

  if (p === '/site' && m === 'PUT') {
    const cur = await getSetting(env, SITE_KEY, {});
    const next = cleanSite(body, cur);
    if (next.error) return bad(next.error);
    await setSetting(env, SITE_KEY, next.site);
    await log(env, 'site', '', Object.keys(body || {}).join(','));
    return json({ ok: true, site: publicSite(next.site), bots: botState(next.site) });
  }

  /* پیامِ آزمایشی، تا معلوم شود توکن درست است و ربات جواب می‌دهد */
  if (p === '/site/bot-test' && m === 'POST') {
    const st = await getSetting(env, SITE_KEY, {});
    const which = body.bot === 'bale' ? 'bale' : 'telegram';
    const token = which === 'bale' ? st.baleToken : st.tgToken;
    const chat = String(body.chat || '').trim() ||
                 (which === 'bale' ? st.baleChat : st.tgChat) || '';
    if (!token) return bad('اول توکنِ این ربات را بگذارید.');
    if (!chat) return bad('شناسهٔ گفتگو را بنویسید.');
    const base = which === 'bale'
      ? 'https://tapi.bale.ai/bot' + token
      : 'https://api.telegram.org/bot' + token;
    try {
      const r = await fetch(base + '/sendMessage', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ chat_id: chat, text: 'پیام آزمایشی از پنل SLTech — همه‌چیز درست است.' })
      });
      const d = await r.json().catch(() => ({}));
      if (!d.ok) return bad('ربات نپذیرفت: ' + (d.description || 'پاسخِ نامفهوم'), 502);
      return json({ ok: true });
    } catch (e) { return bad('به ربات نرسیدیم: ' + e.message, 502); }
  }

  /* ---- نام کاربریِ خودِ ادمین ---- */
  if (p === '/admin-user' && m === 'POST') {
    const user = String(body.user || '').trim().toLowerCase();
    if (!USER_RE.test(user))
      return bad('نام کاربری فقط حروف انگلیسی کوچک، عدد، نقطه، خط تیره و زیرخط — بین ۲ تا ۳۱ حرف.');
    if (user !== (await adminUser(env)).toLowerCase() && await panelByUser(env, user))
      return bad('این نام کاربری مالِ یکی از کارتابل‌هاست.');
    await setSetting(env, ADMIN_USER_KEY, user);
    await log(env, 'admin-user', '', user);
    return json({ ok: true, user });
  }

  /* رمزِ ادمین همان چیزی است که کلیدِ اضطراری را هم باز می‌کند، پس
     مرورگر باید بتواند پیش از پیچیدنِ کلید مطمئن شود درست تایپش کرده —
     وگرنه کلیدی ساخته می‌شود که هیچ‌وقت باز نمی‌شود. این مسیر فقط
     «درست است یا نه» می‌گوید و چیزی برنمی‌گرداند. */
  if (p === '/verify-password' && m === 'POST') {
    const rl = await rateLimit(env, 'adminplaner-verify:' + clientIp(req), 20, 900);
    if (!rl.ok) return bad('تلاش زیاد بود. چند دقیقه صبر کنید.', 429);
    const stored = await getSetting(env, ADMIN.keys.pass, '');
    const check = await checkPassword(String(body.password || ''), stored);
    if (!check.ok) return bad('رمز ادمین درست نیست.', check.status === 429 ? 429 : 401);
    return json({ ok: true });
  }

  if (p === '/password' && m === 'POST') {
    const stored = await getSetting(env, ADMIN.keys.pass, '');
    const check = await checkPassword(String(body.current || ''), stored);
    if (!check.ok) return bad('رمز فعلی درست نیست.', 401);
    const next = String(body.password || '').trim();
    if (next.length < 10) return bad('رمزِ ادمین دست‌کم ۱۰ حرف باشد.');
    /* اگر کلیدِ اضطراری هست، مرورگر آن را با رمزِ تازه دوباره پیچیده و
       همین‌جا می‌فرستد. هر دو با هم می‌نشینند تا رمز عوض نشود و کلید
       پشتِ رمزِ قدیمی جا نماند. */
    if (body.priv !== undefined) {
      if (!body.priv || !body.priv.cipher || !body.priv.salt || !body.priv.iv)
        return bad('بستهٔ کلیدِ اضطراری ناقص است.');
      if (!(await getSetting(env, 'vaultEscrowPriv', null)))
        return bad('کلیدِ اضطراری‌ای روی سرور نیست.', 409);
      await setSetting(env, 'vaultEscrowPriv', body.priv);
    }
    await setSetting(env, ADMIN.keys.pass, await hashPassword(next));
    const gen = (await getSetting(env, ADMIN.keys.gen, 1)) + 1;
    await setSetting(env, ADMIN.keys.gen, gen);
    await log(env, 'admin-password', '',
      body.priv ? 'کلید اضطراری هم دوباره پیچیده شد'
        : (await getSetting(env, 'vaultEscrowPriv', null))
          ? '⚠️ کلید اضطراری دوباره پیچیده نشد — پشتِ رمزِ قبلی ماند'
          : '');
    /* نشستِ خودِ ادمین هم باطل شد، پس یکی تازه می‌دهیم. */
    return json({ ok: true }, 200,
      { 'Set-Cookie': cookieHeader(ADMIN, await makeSession(env, ADMIN, 1), 1) });
  }

  /* ---- کلیدِ اضطراریِ ادمین ---- */
  if (p === '/escrow-key' && m === 'GET')
    return json({
      ok: true,
      pub: await getSetting(env, 'vaultEscrowPub', null),
      priv: await getSetting(env, 'vaultEscrowPriv', null)
    });

  /* ---- انتقالِ کلیدِ اضطراری به رمزِ ادمین ----
     همان جفت‌کلید می‌ماند و فقط پیچشِ کلیدِ خصوصی عوض می‌شود. «pub»
     دست نمی‌خورد، پس بسته‌های رمزِ کاربرها همه سرِ جایشان می‌مانند —
     برعکسِ ساختنِ کلیدِ تازه که آن‌ها را از دسترس خارج می‌کند.

     کلیدهایی که پیش از یکی‌شدنِ رمزها ساخته شده‌اند با عبارتِ جداگانهٔ
     قدیمی پیچیده‌اند؛ مرورگرِ ادمین آن را باز می‌کند، با رمزِ ادمین
     دوباره می‌پیچد و از همین مسیر می‌فرستد. */
  if (p === '/escrow-rewrap' && m === 'POST') {
    const rl = await rateLimit(env, 'adminplaner-rewrap:' + clientIp(req), 20, 900);
    if (!rl.ok) return bad('تلاش زیاد بود. چند دقیقه صبر کنید.', 429);
    const stored = await getSetting(env, ADMIN.keys.pass, '');
    const check = await checkPassword(String(body.password || ''), stored);
    if (!check.ok) return bad('رمز ادمین درست نیست.', check.status === 429 ? 429 : 401);
    if (!body.priv || !body.priv.cipher || !body.priv.salt || !body.priv.iv)
      return bad('بستهٔ کلیدِ اضطراری ناقص است.');
    if (!(await getSetting(env, 'vaultEscrowPriv', null)))
      return bad('کلیدِ اضطراری‌ای روی سرور نیست.', 409);
    await setSetting(env, 'vaultEscrowPriv', body.priv);
    await log(env, 'escrow-key', '', 'انتقال به رمز ادمین');
    return json({ ok: true });
  }

  if (p === '/escrow-key' && m === 'POST') {
    if (!body.pub || !body.priv || !body.priv.cipher)
      return bad('کلید ناقص است.');
    const had = await getSetting(env, 'vaultEscrowPub', null);
    if (had && !body.replace)
      return bad('کلید از قبل هست. برای جایگزینی باید صریح بگویید.', 409);
    await setSetting(env, 'vaultEscrowPub', body.pub);
    await setSetting(env, 'vaultEscrowPriv', body.priv);
    /* پاکت‌هایی که با کلیدِ قبلی پیچیده شده‌اند با کلیدِ تازه باز
       نمی‌شوند. نگه داشتنشان فقط پنل را دروغ‌گو می‌کرد («رمز شخصی نزد
       شما: بله») پس همین‌جا برداشته می‌شوند. کاربر هم لازم نیست کاری
       بکند: دفعهٔ بعد که صندوقش را باز کند، مرورگرش خودش پاکتِ تازه
       می‌سپارد. */
    let dropped = 0;
    if (had) {
      const rows = await all(env, "SELECT k FROM settings WHERE k LIKE 'escrow:%'");
      for (const r of rows) await run(env, 'DELETE FROM settings WHERE k=?', r.k);
      dropped = rows.length;
    }
    await log(env, 'escrow-key', '',
      (body.replace ? 'replace' : 'new') + (dropped ? ` — ${dropped} پاکتِ قدیمی برداشته شد` : ''));
    return json({ ok: true, dropped });
  }

  /* ---- گزارش ----
     همه‌چیز از همان جاهایی خوانده می‌شود که خودِ کارتابل‌ها می‌نویسند؛
     چیز تازه‌ای ذخیره نمی‌شود. محتوای کارتابل‌ها هم خوانده نمی‌شود،
     فقط اندازه و زمانِ آخرین تغییرشان. */
  if (p === '/report' && m === 'GET') {
    const list = await allPanels(env);
    const rows = await all(env, 'SELECT k, length(v) AS n, rev, updated FROM kartabl');
    const size = new Map(rows.map(r => [r.k, r]));
    let hist = new Map();
    try {
      const h = await all(env, 'SELECT k, COUNT(*) AS n FROM kartabl_hist GROUP BY k');
      hist = new Map(h.map(r => [r.k, r.n]));
    } catch (e) { /* تاریخچه هنوز نیست */ }

    const planners = [];
    for (const panel of list) {
      const st = size.get(panel.keys.state) || {};
      const db = size.get(panel.keys.db) || {};
      planners.push({
        slug: panel.slug, name: panel.name, kind: panel.kind,
        disabled: !!panel.manualOff,
        bytes: (st.n || 0) + (db.n || 0),
        rev: st.rev || 0,
        updated: Math.max(st.updated || 0, db.updated || 0),
        expired: !!panel.expired,
        snapshots: (hist.get(panel.keys.state) || 0) + (hist.get(panel.keys.db) || 0),
        lastLogin: await getSetting(env, 'login:' + panel.slug, 0),
        lastBackup: await getSetting(env, panel.keys.last, null)
      });
    }

    /* کارهای ادمین، روز به روز — برای اینکه معلوم باشد این پنل چقدر
       و کِی استفاده شده. */
    let activity = [];
    try {
      const day = 86400000;
      const from = Date.now() - 29 * day;
      const items = await all(env, 'SELECT at FROM admin_log WHERE at >= ?', from);
      const bucket = new Map();
      for (let i = 0; i < 30; i++) bucket.set(i, 0);
      for (const r of items) {
        const i = Math.floor((r.at - from) / day);
        if (i >= 0 && i < 30) bucket.set(i, bucket.get(i) + 1);
      }
      activity = [...bucket.entries()].map(([i, n]) => ({ at: from + i * day, n }));
    } catch (e) { /* سیاهه هنوز نیست */ }

    return json({ ok: true, planners, activity, now: Date.now() });
  }

  if (p === '/log' && m === 'GET') {
    try {
      const rows = await all(env, 'SELECT at, what, slug, note FROM admin_log ORDER BY at DESC LIMIT 100');
      return json({ ok: true, items: rows });
    } catch (e) { return json({ ok: true, items: [] }); }
  }

  return bad('مسیر پیدا نشد.', 404);
}
