/* ---------- کارتابل‌ها: داده روی سرور، پشتیبان شبانه در تلگرام ----------

   تا دیروز کارتابل هیچ داده‌ای روی سرور نداشت و همه‌چیز در حافظهٔ مرورگر
   می‌ماند. به همین دلیل قفلِ سمتِ مرورگر کافی بود: هر کسی آدرس را باز
   می‌کرد فقط یک کارتابل خالی می‌دید.

   حالا که داده روی سرور می‌نشیند، آن قفل دیگر کافی نیست — کسی که کد صفحه
   را دور بزند به خودِ داده می‌رسد، نه به صفحهٔ خالی. پس ورود از این‌جا
   بررسی می‌شود: رمز با PBKDF2 (۱۰۰٬۰۰۰ دور، SHA-256 — سقف کلادفلر) نگه داشته می‌شود،
   نشست با همان JWT_SECRET فروشگاه امضا می‌شود، و هیچ مسیری داده نمی‌دهد
   مگر کوکی معتبر داشته باشد.

   «دیتای شخصی» همچنان با رمز جداگانهٔ خودش سمت مرورگر رمزنگاری می‌شود و
   سرور فقط متن رمزشده را نگه می‌دارد. این عمدی است: اگر سرور هم روزی لو
   برود، آن بخش باز نمی‌شود. */

import { buildKartablWorkbook, buildSinaWorkbook, buildGeneralWorkbook } from './kartabl-xlsx.js';
import { jobSeed, JOBS } from './kartabl-jobs.js';
import { makeZip } from './kartabl-zip.js';
import { buildAiContext, askKartablAI, looksPlannerRelated, CLAUDE_MODEL } from './kartabl-ai.js';

/* ---------- کارتابل‌ها ----------
   سه کارتابل داریم و هر سه از همین کد استفاده می‌کنند: سیامک روی
   /siamak، سینا روی /sina و رضا روی /reza. هر کدام رمز، نشست و دادهٔ
   کاملاً جداگانه دارد — ورود به یکی به آن یکی دسترسی نمی‌دهد — ولی
   پشتیبان شبانهٔ هر سه به همان یک ربات تلگرام می‌رود.

   کلیدهای کارتابل IT عمداً همان‌های قبلی ماندند («state»، «db»،
   «kartablPassHash»)، وگرنه دادهٔ زنده‌اش باید جابه‌جا می‌شد. */
export const PANELS = {
  it: {
    id: 'siamak', slug: 'siamak', user: 'siamak', name: 'سیامک', kind: 'it', api: 'kartabl',
    tpl: { title: 'کارتابل ماهانه سیامک', name: 'سیامک', api: '/api/kartabl',
           icon: '/icon-siamak.2.png', store: 'it-manager-planner-v1', idb: 'planner-fs-db',
           dbcache: 'it-manager-db-cache-v19', filejson: 'کارتابل-IT-داده.json',
           filexlsx: 'کارتابل-IT-دیتابیس.xlsx' },
    title: 'کارتابل ماهانه سیامک', page: '/siamak/', cookie: 'kartabl_s',
    keys: { state: 'state', db: 'db', pass: 'kartablPassHash', gen: 'kartablPassGen', last: 'kartablLastBackup',
            reset: 'kartablPassReset' },
    folder: 'It',
    files: { json: 'کارتابل-IT-داده.json', xlsx: 'کارتابل-IT-دیتابیس.xlsx', html: 'کارتابل مدیر IT.html' },
    icon: 'icon-siamak.2.png',
    zip: stamp => `کارتابل-IT-پشتیبان-${stamp}.zip`,
    workbook: buildKartablWorkbook,
    counts: (st, db) => ({
      سرور: (db.vm || []).length, شرکت: Object.keys(db.companies || {}).length,
      'خط MVPN': (db.lines || []).length
    })
  },
  sina: {
    id: 'sina', slug: 'sina', user: 'sina', name: 'سینا', kind: 'fin', api: 'sina',
    tpl: { title: 'کارتابل ماهانه سینا', name: 'سینا', api: '/api/sina',
           icon: '/icon-sina.2.png', store: 'finance-planner-v1', idb: 'finance-fs-db',
           dbcache: 'finance-db-cache-v1', filejson: 'کارتابل-مالی-داده.json',
           filexlsx: 'کارتابل-مالی-دیتابیس.xlsx' },
    title: 'کارتابل ماهانه سینا', page: '/sina/', cookie: 'sina_s',
    keys: { state: 'sina:state', db: 'sina:db', pass: 'sinaPassHash', gen: 'sinaPassGen', last: 'sinaLastBackup',
            reset: 'sinaPassReset' },
    folder: 'Mali',
    files: { json: 'کارتابل-مالی-داده.json', xlsx: 'کارتابل-مالی-دیتابیس.xlsx', html: 'کارتابل مدیر مالی.html' },
    icon: 'icon-sina.2.png',
    zip: stamp => `کارتابل-مالی-پشتیبان-${stamp}.zip`,
    workbook: buildSinaWorkbook,
    counts: (st, db) => ({
      'طرف‌حساب': (db.parties || []).length, فاکتور: (db.invoices || []).length,
      'حساب بانکی': (db.bank || []).length
    })
  },
  reza: {
    id: 'reza', slug: 'reza', user: 'reza', name: 'رضا', kind: 'fin', api: 'reza',
    tpl: { title: 'کارتابل ماهانه رضا', name: 'رضا', api: '/api/reza',
           icon: '/icon-reza.2.png', store: 'reza-planner-v1', idb: 'reza-fs-db',
           dbcache: 'reza-db-cache-v1', filejson: 'کارتابل-رضا-داده.json',
           filexlsx: 'کارتابل-رضا-دیتابیس.xlsx' },
    title: 'کارتابل ماهانه رضا', page: '/reza/', cookie: 'reza_s',
    keys: { state: 'reza:state', db: 'reza:db', pass: 'rezaPassHash', gen: 'rezaPassGen', last: 'rezaLastBackup',
            reset: 'rezaPassReset' },
    folder: 'Reza',
    files: { json: 'کارتابل-رضا-داده.json', xlsx: 'کارتابل-رضا-دیتابیس.xlsx', html: 'کارتابل ماهانه رضا.html' },
    icon: 'icon-reza.2.png',
    zip: stamp => `کارتابل-رضا-پشتیبان-${stamp}.zip`,
    /* ساختارش همان کارتابل مالی است، پس همان سازندهٔ برگه‌ها */
    workbook: buildSinaWorkbook,
    counts: (st, db) => ({
      'طرف‌حساب': (db.parties || []).length, فاکتور: (db.invoices || []).length,
      'حساب بانکی': (db.bank || []).length
    })
  }
};

/* ---------- کارتابل‌ها از روی دیتابیس ----------
   سه کارتابلِ اول داخل همین فایل نوشته شده‌اند (بالا) و همان‌ها پیش‌فرض
   می‌مانند: اگر جدولِ planners نباشد یا خوانده نشود، سایت سرِ پا می‌ماند.
   هرچه در جدول باشد روی آن‌ها می‌نشیند و کارتابل‌های تازه هم از همان‌جا
   می‌آیند. */

const WORKBOOKS = { it: buildKartablWorkbook, fin: buildSinaWorkbook, gen: buildGeneralWorkbook };
/* «عمومی» فایل جدایی ندارد: همان قالبِ IT است که تکه‌های مخصوصِ IT
   از آن برداشته می‌شود. یک فایل کمتر یعنی یک فایل کمتر برای عقب‌ماندن. */
const TEMPLATES = { it: 'it', fin: 'fin', gen: 'it' };

/* بخش‌هایی که می‌شود برای هر کاربر باز یا بسته گذاشت.
   «همگام‌سازی» عمداً این‌جا نیست: بدونش کارتابل اصلاً کار نمی‌کند. */
export const FEATURES = ['pass', 'ai', 'aikey', 'backup', 'folder', 'vault', 'files'];

/* بخش‌های خودِ کارتابل که می‌شود برای هر کاربر برداشت. داشبورد،
   چک‌لیست، برنامهٔ روزانه، راهنما و تنظیمات این‌جا نیستند: ستون‌فقراتِ
   کارتابل‌اند. «دیتای شخصی» و «دستیار» هم قبلاً بالا آمده‌اند. */
export const VIEWS = {
  it: [
    { id: 'servers',   label: 'سرورها و بکاپ' },
    { id: 'companies', label: 'شرکت‌ها' },
    { id: 'mvpn',      label: 'سرویس MVPN' },
    { id: 'datetools', label: 'تبدیل تاریخ' }
  ],
  fin: [
    { id: 'invoices',        label: 'سررسید اسناد دریافتنی' },
    { id: 'payables',        label: 'بدهی‌ها و پرداخت‌ها' },
    { id: 'payablenotes',    label: 'اسناد پرداختنی' },
    { id: 'receivablenotes', label: 'اسناد دریافتنی' },
    { id: 'expenses',        label: 'منابع و مصارف' },
    { id: 'bank',            label: 'حساب‌های بانکی' },
    { id: 'budget',          label: 'بودجه‌بندی ماهانه' },
    { id: 'parties',         label: 'طرف‌حساب‌ها' },
    { id: 'datetools',       label: 'تبدیل تاریخ' }
  ],
  /* «عمومی» از همان قالبِ IT ساخته می‌شود، پس همان بخش‌ها را هم
     می‌تواند داشته باشد — مثلاً هلپ‌دسکی که به سرورها و MVPN کار دارد.
     فرقش این است که این‌جا پیش‌فرض بسته است و شغل تعیین می‌کند کدام
     پیشنهاد شود. */
  gen: null
};
VIEWS.gen = VIEWS.it;

const ALL_VIEWS = new Set(Object.values(VIEWS).flat().map(v => v.id));

/* نامِ معتبر: یا یکی از بخش‌های بالا، یا «view:» به‌علاوهٔ نامِ نمایی
   که می‌شناسیم. هر چیزِ دیگری دور ریخته می‌شود. */
export const isFeature = f => typeof f === 'string' &&
  (FEATURES.includes(f) || (f.startsWith('view:') && ALL_VIEWS.has(f.slice(5))));

/* کدام بخش‌های خودِ کارتابل برای این کاربر باز است.
   ترتیبِ حرف: اول تیکِ صریحِ ادمین، بعد پیشنهادِ شغل، و اگر هیچ‌کدام
   نبود همهٔ بخش‌های آن نوع — مگر «عمومی» که پیش‌فرضش بسته است. */
export function enabledViews(cfg, kind) {
  const all = (VIEWS[kind] || []).map(v => v.id);
  if (Array.isArray(cfg.views)) return cfg.views.filter(v => all.includes(v));
  const job = JOBS[cfg.job];
  if (kind === 'gen') return job ? (job.views || []).filter(v => all.includes(v)) : [];
  return all;
}

/* فهرستِ نهاییِ «بسته‌ها» که به صفحه می‌رسد: هم بخش‌های عمومی، هم
   نماهایی که باز نیستند. صفحه فقط همین یک فهرست را می‌فهمد. */
export function effectiveOff(cfg, kind) {
  const off = (Array.isArray(cfg.off) ? cfg.off : []).filter(isFeature);
  const on = new Set(enabledViews(cfg, kind));
  for (const v of (VIEWS[kind] || []))
    if (!on.has(v.id) && !off.includes('view:' + v.id)) off.push('view:' + v.id);
  return off;
}

/* هر مسیرِ API زیرِ کدام بخش است. پنهان‌کردنِ دکمه کافی نیست؛ کسی که
   درخواست را دستی بفرستد باید همین‌جا جواب رد بگیرد. */
const FEATURE_ROUTES = [
  [/^\/password$/, 'pass'],
  /* تنظیمِ موتور جدا از خودِ دستیار است: می‌شود دستیار باز باشد ولی
     کاربر نتواند کلیدِ هوش مصنوعی را دست بزند. ترتیب مهم است — اگر
     «aikey» باز باشد، همین مسیر با قاعدهٔ بعدی سنجیده می‌شود. */
  [/^\/ai\/settings$/, 'aikey'],
  [/^\/ai(\/|$)/, 'ai'],
  [/^\/backup(\/|$)/, 'backup'],
  [/^\/(vault|escrow)(\/|$)/, 'vault'],
  [/^\/escrow-pub$/, 'vault']
];

export function featureOff(panel, p) {
  if (!panel.off || !panel.off.length) return null;
  for (const [re, f] of FEATURE_ROUTES)
    if (re.test(p) && panel.off.includes(f)) return f;
  return null;
}
const COUNTS = {
  it: (st, db) => ({ سرور: (db.vm || []).length, شرکت: Object.keys(db.companies || {}).length,
                     'خط MVPN': (db.lines || []).length }),
  fin: (st, db) => ({ 'طرف‌حساب': (db.parties || []).length, فاکتور: (db.invoices || []).length,
                      'حساب بانکی': (db.bank || []).length }),
  gen: (st) => ({ وظیفه: (st.tasks || []).length, 'روز برنامه': (st.days || []).length })
};

export function panelFromRow(row) {
  let c;
  try { c = JSON.parse(row.cfg); } catch (e) { return null; }
  /* نوعِ ناشناخته به «عمومی» می‌افتد، نه اینکه صفحه بالا نیاید. */
  const kind = TEMPLATES[row.kind] ? row.kind : 'gen';
  /* مهلت: از این تاریخ به بعد کارتابل خودش بسته می‌شود. صفر یعنی بی‌مهلت. */
  const until = Number(c.until) || 0;
  const expired = until > 0 && Date.now() > until;
  return {
    id: row.slug, slug: row.slug, name: row.name, kind,
    /* نامِ کاربری برای صفحهٔ ورودِ مشترک. پیش‌فرضش همان آدرسِ کارتابل
       است، ولی ادمین می‌تواند چیزِ دیگری بگذارد. */
    user: String(c.user || row.slug).toLowerCase(),
    title: c.title, page: '/' + row.slug + '/', api: c.api || row.slug,
    cookie: c.cookie, icon: (c.icon || '').replace(/^\//, ''),
    tpl: { title: c.title, name: row.name, api: '/api/' + (c.api || row.slug),
           icon: c.icon, store: c.store, idb: c.idb, dbcache: c.dbcache,
           filejson: c.filejson, filexlsx: c.filexlsx },
    keys: c.keys,
    /* غیرفعال یعنی همه‌چیزش سرِ جایش هست ولی در باز نمی‌شود و
       پشتیبانی هم برایش نمی‌رود. برگرداندنش یک کلیک است. */
    /* دو جور بسته بودن: یکی را ادمین با دست زده، آن یکی خودش سر رسیده.
       هر دو یک نتیجه دارند، ولی پیامشان به کاربر فرق می‌کند. */
    disabled: !!c.disabled || expired,
    manualOff: !!c.disabled,
    until, expired,
    /* بخش‌هایی که ادمین برای این کاربر بسته است. فقط اسمِ بخش‌های
       شناخته‌شده رد می‌شود تا یک مقدارِ عجیب چیزی را باز نکند. */
    off: effectiveOff(c, kind),
    job: c.job || '',
    vault: Array.isArray(c.vault) ? c.vault : null,
    folder: c.folder,
    files: { json: c.filejson, xlsx: c.filexlsx, html: c.filehtml },
    zip: stamp => `${c.zip}${stamp}.zip`,
    workbook: WORKBOOKS[kind],
    counts: COUNTS[kind]
  };
}

/* فهرستِ کامل: پیش‌فرض‌های داخل کد + هرچه در جدول هست */
export async function allPanels(env) {
  const out = new Map();
  for (const p of Object.values(PANELS)) out.set(p.slug, p);
  try {
    const rows = await all(env, 'SELECT slug, name, kind, cfg FROM planners ORDER BY created, slug');
    for (const r of rows) {
      const p = panelFromRow(r);
      if (p) out.set(p.slug, p);
    }
  } catch (e) { /* جدول نبود — همان سه تای داخل کد */ }
  return [...out.values()];
}

export async function panelBySlug(env, slug) {
  return (await allPanels(env)).find(p => p.slug === slug) || null;
}

/* ورودِ مشترک با نام کاربری: یک صفحهٔ ورود برای همه، و هر کس به
   کارتابلِ خودش می‌رسد. */
export async function panelByUser(env, user) {
  const u = String(user || '').trim().toLowerCase();
  if (!u) return null;
  return (await allPanels(env)).find(p => (p.user || p.slug) === u) || null;
}

export async function panelByApi(env, api) {
  return (await allPanels(env)).find(p => (p.api || p.id) === api) || null;
}

/* ---------- ساختنِ صفحهٔ کارتابل از قالب ----------
   قالب یک فایل ثابت است و جاهای خالی‌اش با مشخصاتِ همین کارتابل پر
   می‌شود. اسم و عنوان را آدمِ ادمین وارد می‌کند، پس پیش از نشستن در
   HTML فرار داده می‌شوند. */
const esc = t => String(t == null ? '' : t)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;').replace(/'/g, '&#39;');

/* فهرستِ بخش‌های دیتای شخصی، به شکلی که داخلِ <script> بنشیند.
   فقط نوع‌های شناخته‌شده رد می‌شوند تا صفحه با یک مقدارِ عجیب نشکند. */
const VAULT_TYPES = ['creds', 'inst', 'contacts', 'table'];
const VAULT_FALLBACK = [{ id: 'creds', type: 'creds', title: 'شرکت‌های من' },
                        { id: 'inst', type: 'inst', title: 'اقساط' }];

export function vaultSeed(list) {
  const clean = (Array.isArray(list) ? list : [])
    .filter(s => s && typeof s.id === 'string' && VAULT_TYPES.includes(s.type))
    .map(s => ({ id: s.id, type: s.type, title: String(s.title || s.id),
                 ...(Array.isArray(s.cols) ? { cols: s.cols.map(String) } : {}) }));
  return JSON.stringify(clean.length ? clean : VAULT_FALLBACK).replace(/</g, '\\u003c');
}

export async function renderPanelPage(env, req, panel) {
  /* پسوندِ .tpl عمدی است: با .html تنظیمِ auto-trailing-slash آدرس را
     ریدایرکت می‌کرد و خواندنش از داخلِ ورکر ۳۰۷ می‌گرفت. */
  const file = '/_t/' + (TEMPLATES[panel.kind] || 'fin') + '.tpl';
  const res = await env.ASSETS.fetch(new Request(new URL(file, req.url), req));
  if (!res.ok) return null;
  let html = await res.text();
  /* <!--IT-->…<!--/IT--> فقط برای کارتابلِ IT می‌ماند و <!--GEN-->…<!--/GEN-->
     فقط برای بقیه. تکه‌های جاوااسکریپتِ IT سرِ جایشان می‌مانند؛ همه‌شان
     پیش از دست‌زدن به صفحه وجودِ عنصر را بررسی می‌کنند. */
  const drop = panel.kind === 'it' ? 'GEN' : 'IT';
  html = html.replace(new RegExp('<!--' + drop + '-->[\\s\\S]*?<!--/' + drop + '-->', 'g'), '');
  html = html.replace(/<!--\/?(?:IT|GEN)-->/g, '');
  const t = panel.tpl;
  /* دانهٔ چک‌لیست جداگانه جاسازی می‌شود چون JSON است، نه متنِ ساده:
     از esc() رد نمی‌شود وگرنه گیومه‌هایش خراب می‌شود. */
  html = html.replaceAll('{{JOBSEED}}', jobSeed(panel.job));
  html = html.replaceAll('{{VAULTSECS}}', vaultSeed(panel.vault));
  html = html.replaceAll('{{FEATOFF}}', JSON.stringify(panel.off || []).replace(/</g, '\\u003c'));
  html = html.replaceAll('{{UNTIL}}', String(Number(panel.until) || 0));
  for (const [k, v] of [['TITLE', t.title], ['NAME', t.name], ['API', t.api],
                        ['ICON', t.icon], ['STORE', t.store], ['IDB', t.idb],
                        ['DBCACHE', t.dbcache], ['FILEJSON', t.filejson],
                        ['FILEXLSX', t.filexlsx]])
    html = html.replaceAll('{{' + k + '}}', esc(v));
  return html;
}

const enc = new TextEncoder();

export const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
export const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();
export const run = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).run();

export const getSetting = async (env, k, d = null) => {
  const r = await one(env, 'SELECT v FROM settings WHERE k=?', k);
  try { return r ? JSON.parse(r.v) : d; } catch { return d; }
};
export const setSetting = (env, k, v) =>
  run(env, 'INSERT INTO settings(k,v) VALUES(?,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v',
      k, JSON.stringify(v));

export const json = (data, status = 200, extra = {}) => new Response(JSON.stringify(data), {
  status, headers: { 'Content-Type': 'application/json; charset=utf-8',
                     'Cache-Control': 'no-store', 'X-Robots-Tag': 'noindex', ...extra } });
export const bad = (msg, status = 400) => json({ error: msg }, status);

/* ---------- رمز عبور ----------
   مقایسه با زمان ثابت انجام می‌شود تا از روی مدتِ پاسخ نشود حدس زد چند
   کاراکتر اول درست بوده. */

/* کلادفلر بیشتر از ۱۰۰٬۰۰۰ دور را رد می‌کند:
     «Pbkdf2 failed: iteration counts above 100000 are not supported»
   نکتهٔ خطرناکش این بود که wrangler dev --local این سقف را اعمال نمی‌کند،
   پس محلی کار می‌کرد و فقط روی سایت زنده شکست می‌خورد. */
const PBKDF2_ROUNDS = 100000;

const b64 = buf => btoa(String.fromCharCode(...new Uint8Array(buf)));
const unb64 = s => Uint8Array.from(atob(s), c => c.charCodeAt(0));

async function derive(password, salt, rounds) {
  const base = await crypto.subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, ['deriveBits']);
  return b64(await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations: rounds, hash: 'SHA-256' }, base, 256));
}

export async function hashPassword(password) {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  return `pbkdf2$${PBKDF2_ROUNDS}$${b64(salt)}$${await derive(password, salt, PBKDF2_ROUNDS)}`;
}

/* رمزِ تازه را باید از روی صفحهٔ تلگرام دستی تایپ کرد، پس حرف‌هایی که
   به هم می‌آیند (O و 0، I و l و 1) داخلش نیست. بیست حرف از این الفبا
   حدود ۱۱۶ بیت است — برای چیزی که چند دقیقه بعد عوضش می‌کنید بیش از کافی. */
const PW_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';

export function newPassword(groups = 4, per = 5) {
  const need = groups * per;
  /* باقی‌ماندهٔ ساده (b % 56) شانسِ حرف‌های اول را کمی بیشتر می‌کند؛
     بایت‌های بالای این حد را دور می‌ریزیم تا همه برابر باشند. */
  const limit = 256 - (256 % PW_ALPHABET.length);
  const out = [];
  while (out.length < need) {
    for (const b of crypto.getRandomValues(new Uint8Array(need))) {
      if (b >= limit) continue;
      out.push(PW_ALPHABET[b % PW_ALPHABET.length]);
      if (out.length === need) break;
    }
  }
  const parts = [];
  for (let i = 0; i < groups; i++) parts.push(out.slice(i * per, (i + 1) * per).join(''));
  return parts.join('-');
}

function constantEqual(a, b) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/* { ok } یا { error } برمی‌گرداند. اگر خودِ محاسبه شکست بخورد، «رمز اشتباه
   است» جواب نمی‌دهیم: یک بار همین قورت دادنِ خطا باعث شد ساعت‌ها دنبال
   رمزِ درست بگردیم، درحالی‌که ایراد از جای دیگری بود. */
export async function checkPassword(password, stored) {
  if (!stored || typeof stored !== 'string') return { error: 'رمز کارتابل روی سرور تنظیم نشده است.', status: 503 };
  const [kind, rounds, salt, want] = stored.split('$');
  if (kind !== 'pbkdf2' || !salt || !want)
    return { error: 'رمزِ ذخیره‌شده روی سرور خوانا نیست.', status: 500 };
  let got;
  try {
    got = await derive(password, unb64(salt), parseInt(rounds, 10) || PBKDF2_ROUNDS);
  } catch (e) {
    return { error: 'بررسی رمز روی سرور انجام نشد: ' + (e.name || '') + ' ' + (e.message || ''), status: 500 };
  }
  return constantEqual(got, want) ? { ok: true } : { error: 'رمز عبور اشتباه است.', status: 401 };
}

/* ---------- نشست ----------
   کوکی HttpOnly است، پس کد صفحه (و هر اسکریپت تزریق‌شده‌ای) نمی‌تواند
   بخواندش. امضا با همان کلیدی است که فروشگاه استفاده می‌کند. */

async function hmac(env, body) {
  const key = await crypto.subtle.importKey('raw', enc.encode(env.JWT_SECRET || 'dev-secret-change-me'),
    { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  return b64(await crypto.subtle.sign('HMAC', key, enc.encode(body)))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

export async function makeSession(env, panel, days = 30) {
  /* شمارهٔ نسل رمز داخل توکن است: با هر بار عوض شدن رمز بالا می‌رود و
     همهٔ نشست‌های قبلی — روی هر دستگاهی — از کار می‌افتند. */
  const gen = await getSetting(env, panel.keys.gen, 1);
  const body = b64(enc.encode(JSON.stringify({ k: panel.id, gen, exp: Date.now() + days * 864e5 })))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  return body + '.' + await hmac(env, body);
}

export async function readSession(env, panel, req) {
  const raw = (req.headers.get('Cookie') || '').split(';')
    .map(c => c.trim()).find(c => c.startsWith(panel.cookie + '='));
  if (!raw) return null;
  const token = raw.slice(panel.cookie.length + 1);
  if (!token.includes('.')) return null;
  const [body, sig] = token.split('.');
  if (!constantEqual(sig, await hmac(env, body))) return null;
  try {
    const pad = body.replace(/-/g, '+').replace(/_/g, '/');
    const p = JSON.parse(new TextDecoder().decode(
      Uint8Array.from(atob(pad + '==='.slice((pad.length + 3) % 4)), c => c.charCodeAt(0))));
    if (!(p.exp > Date.now())) return null;
    if (p.gen !== await getSetting(env, panel.keys.gen, 1)) return null;
    /* کوکیِ یک کارتابل نباید درِ آن یکی را باز کند */
    if (p.k !== panel.id) return null;
    return p;
  } catch (e) { return null; }
}

export const cookieHeader = (panel, value, days) =>
  `${panel.cookie}=${value}; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=${days * 86400}`;

/* ---------- داده ----------
   دو تکه نگه داشته می‌شود، دقیقاً همان دو تکه‌ای که خودِ کارتابل دارد:
   «state» (وظایف، برنامهٔ روزانه، ماه‌ها، بخش شخصیِ رمزشده) و «db»
   (سرورها، شرکت‌ها، MVPN، لاگ بکاپ روزانه، فهرست ریموت).

   هر تکه به شکل یک JSON در یک ردیف می‌نشیند، نه جدولِ ستون‌بندی‌شده. دلیلش
   این است که ساختار کارتابل مدام تغییر می‌کند و هر تغییر یک migration
   می‌خواست؛ این‌طوری داده همان چیزی می‌ماند که صفحه می‌فهمد. */

const REV_CONFLICT = 409;

export async function loadKartabl(env, panel) {
  const rows = await all(env, 'SELECT k, v, rev, updated FROM kartabl WHERE k IN (?,?)',
    panel.keys.state, panel.keys.db);
  const out = { state: null, db: null, rev: 0, updated: 0, broken: null, rows: rows.length };
  for (const r of rows) {
    const which = r.k === panel.keys.state ? 'state' : 'db';
    /* اگر ردیف هست ولی خوانده نمی‌شود، «خالی» گزارش نمی‌کنیم. این دقیقاً
       همان تله است: صفحه خیال می‌کند سرور چیزی ندارد، نسخهٔ قدیمیِ خودش
       را نگه می‌دارد و با اولین ویرایش رویش می‌نویسد. */
    try { out[which] = JSON.parse(r.v); }
    catch (e) { out[which] = null; out.broken = (out.broken || []).concat(which); }
    out.rev = Math.max(out.rev, r.rev || 0);
    out.updated = Math.max(out.updated, r.updated || 0);
  }
  return out;
}

/* ---------- محافظِ نوشتنِ ویرانگر ----------
   سرور نباید به کلاینت اعتماد کند. یک بار یک مرورگر نسخهٔ کهنهٔ خودش را
   روی کارِ یک روز نوشت و چون سرور فقط «هرچه فرستادی می‌نویسم» بود، هیچ‌جا
   جلویش را نگرفت.

   حالا پیش از نوشتن، اندازهٔ محتوا سنجیده می‌شود: شمارِ ماه‌ها و شمارِ
   خانه‌های پُرِ جدول‌ها. اگر نوشتنِ تازه بخش بزرگی از محتوا را ببرد، رد
   می‌شود و صفحه باید صریح بپرسد. حذف‌های واقعی هم ممکن‌اند، پس رد کردن
   نهایی نیست — فقط بی‌صدا نیست. */
const LOSS_LIMIT = 0.4;     /* بیش از چهل درصدِ محتوا؟ بپرس */

function countFilled(rows) {
  let n = 0;
  for (const row of Array.isArray(rows) ? rows : []) {
    if (!row || typeof row !== 'object') continue;
    for (const v of Object.values(row))
      if (v !== '' && v !== null && v !== undefined && v !== false && v !== 0) n++;
  }
  return n;
}

function monthMap(st) {
  const s = st && typeof st === 'object' ? st : {};
  const months = Object.assign({}, s.monthsData || {});
  if (s.currentMonthKey) months[s.currentMonthKey] = { tasks: s.tasks, days: s.days };
  return months;
}

function stateStats(st) {
  const s = st && typeof st === 'object' ? st : {};
  const months = monthMap(s);
  const per = {};
  let filled = 0;
  for (const [k, m] of Object.entries(months)) {
    per[k] = countFilled(m && m.tasks) + countFilled(m && m.days);
    filled += per[k];
  }
  filled += countFilled(s.remoteCheckDates ? [Object.assign({}, s.remoteCheckDates)] : []);
  return { months: Object.keys(months).length, filled, per,
           vault: !!(s.personalVault && s.personalVault.cipher) };
}

const monthLabel = key => String(key || '').split('|').reverse().join(' ');

function dbStats(d) {
  const c = d && typeof d === 'object' ? d : {};
  let filled = countFilled(c.vm) + countFilled(c.lines) + countFilled(c.roster) +
               countFilled(c.parties) + countFilled(c.invoices) + countFilled(c.payables) +
               countFilled(c.payableNotes) + countFilled(c.receivableNotes) +
               countFilled(c.expenses) + countFilled(c.bank) + countFilled(c.budget);
  for (const v of Object.values(c.companies || {})) filled += countFilled(v);
  for (const v of Object.values(c.dailyLog || {})) filled += countFilled(v);
  return { filled, groups: Object.keys(c.companies || {}).length };
}

/* برمی‌گرداند: پیام، اگر این نوشتن ویرانگر باشد */
function lossReason(before, after, kind) {
  const b = kind === 'state' ? stateStats(before) : dbStats(before);
  const a = kind === 'state' ? stateStats(after)  : dbStats(after);
  if (kind === 'state') {
    if (b.months && a.months < b.months)
      return `${b.months - a.months} ماه از کارتابل کم می‌شود`;
    if (b.vault && !a.vault)
      return 'بخش «دیتای شخصی» پاک می‌شود';
    /* مهم‌ترین حالت و همانی که یک بار اتفاق افتاد: ماه‌ها سرِ جایشان
       می‌مانند ولی محتوای یکی‌شان خالی می‌شود. جمعِ کل آن‌قدر نمی‌افتد که
       آستانهٔ کلی را رد کند، پس هر ماه را جدا می‌سنجیم. */
    for (const [key, bf] of Object.entries(b.per || {})) {
      const af = (a.per || {})[key] || 0;
      if (bf >= 10 && af < bf * 0.25)
        return `محتوای ماه «${monthLabel(key)}» تقریباً خالی می‌شود (${bf} خانه به ${af} می‌رسد)`;
    }
  }
  if (b.filled >= 20 && a.filled < b.filled * (1 - LOSS_LIMIT))
    return `${b.filled - a.filled} خانهٔ پرشده از ${b.filled} تا حذف می‌شود`;
  return null;
}

async function saveKartabl(env, panel, { state, db, baseRev, force }) {
  const current = await loadKartabl(env, panel);

  /* ردیفی که خوانده نمی‌شود یعنی یک جای کار خراب است. تا وقتی آدم خبردار
     نشده، اجازهٔ نوشتن رویش را نمی‌دهیم. */
  if (current.broken && !force)
    return { broken: current.broken, rev: current.rev, updated: current.updated };
  /* اگر از دستگاه دیگری چیزی ذخیره شده که این مرورگر ندیده، بی‌صدا
     رویش نمی‌نویسیم — صفحه خبردار می‌شود و تازه‌اش را می‌گیرد. */
  if (baseRev != null && current.rev && Number(baseRev) !== current.rev)
    return { conflict: true, rev: current.rev, updated: current.updated };

  if (!force) {
    for (const [kind, before, after] of [['state', current.state, state], ['db', current.db, db]]) {
      if (after === undefined || before == null) continue;
      const why = lossReason(before, after, kind);
      if (why) return { loss: why, kind, rev: current.rev, updated: current.updated };
    }
  }

  const rev = current.rev + 1;
  const now = Date.now();
  const stmts = [];
  for (const [k, v] of [[panel.keys.state, state], [panel.keys.db, db]]) {
    if (v === undefined) continue;
    stmts.push(env.DB.prepare(
      `INSERT INTO kartabl(k,v,rev,updated) VALUES(?,?,?,?)
       ON CONFLICT(k) DO UPDATE SET v=excluded.v, rev=excluded.rev, updated=excluded.updated`
    ).bind(k, JSON.stringify(v ?? null), rev, now));
  }
  if (stmts.length) {
    /* عکسِ نسخهٔ قبلی را پیش از بازنویسی نگه می‌داریم — ولی جدا، نه در
       همان batch. اگر جدولِ تاریخچه نباشد یا نوشتنش بگیرد، نباید ذخیرهٔ
       خودِ کاربر را بشکند: مکانیزمِ پشتیبان هیچ‌وقت نباید مسیرِ اصلی را
       زمین بزند. نبودنِ یک عکس بد است، از کار افتادنِ ذخیره فاجعه. */
    try {
      const h = await histStatements(env, panel, current, now);
      if (h.length) await env.DB.batch(h);
    } catch (e) { console.log('kartabl-hist', e.message); }
    await env.DB.batch(stmts);
  }
  return { rev, updated: now };
}

/* ---------- تاریخچه ----------
   یک بار دادهٔ یک کارتابل روی سرور بازنویسی شد و تنها راهِ برگرداندنش
   پشتیبانِ شبانه بود که تا ۲۴ ساعت عقب است. حالا پیش از هر بازنویسی،
   نسخهٔ قبلی این‌جا می‌ماند.

   هر ذخیره عکس نمی‌گیرد: تایپ کردن در جدول هر چند ثانیه یک ذخیره
   می‌سازد و جدول را پر می‌کرد. پس فاصلهٔ حداقلی می‌گذاریم و در عوض
   عمقِ تاریخچه را بیشتر نگه می‌داریم. */
const HIST_GAP  = 10 * 60 * 1000;   /* دست‌کم ده دقیقه بین دو عکس */
const HIST_KEEP = 60;               /* آخرین شصت عکسِ هر کلید */

async function histStatements(env, panel, current, now) {
  const out = [];
  for (const [k, v] of [[panel.keys.state, current.state], [panel.keys.db, current.db]]) {
    if (v == null) continue;            /* چیزی نبوده که عکسش را بگیریم */
    const last = await one(env, 'SELECT at FROM kartabl_hist WHERE k=? ORDER BY at DESC LIMIT 1', k);
    if (last && now - last.at < HIST_GAP) continue;
    out.push(env.DB.prepare('INSERT INTO kartabl_hist(k,v,rev,at) VALUES(?,?,?,?)')
      .bind(k, JSON.stringify(v), current.rev, now));
    out.push(env.DB.prepare(
      `DELETE FROM kartabl_hist WHERE k=? AND id NOT IN
         (SELECT id FROM kartabl_hist WHERE k=? ORDER BY at DESC LIMIT ?)`
    ).bind(k, k, HIST_KEEP));
  }
  return out;
}

/* فهرستِ عکس‌ها و برگرداندنِ یکی از آن‌ها */
export async function listKartablHistory(env, panel) {
  try {
    return await historyRows(env, panel);
  } catch (e) { return []; }      /* جدول نبود؟ فهرست خالی، نه خطا */
}

async function historyRows(env, panel) {
  const rows = await all(env,
    `SELECT id, k, rev, at, length(v) AS size FROM kartabl_hist
     WHERE k IN (?,?) ORDER BY at DESC LIMIT 120`, panel.keys.state, panel.keys.db);
  return rows.map(r => ({ id: r.id, which: r.k === panel.keys.state ? 'state' : 'db',
                          rev: r.rev, at: r.at, size: r.size }));
}

export async function restoreKartablSnapshot(env, panel, id) {
  const row = await one(env, 'SELECT k, v FROM kartabl_hist WHERE id=?', id);
  if (!row) return { ok: false, error: 'این نسخه پیدا نشد.' };
  if (row.k !== panel.keys.state && row.k !== panel.keys.db)
    return { ok: false, error: 'این نسخه مالِ این کارتابل نیست.' };
  let value;
  try { value = JSON.parse(row.v); } catch (e) { return { ok: false, error: 'این نسخه خوانا نیست.' }; }
  /* بدون baseRev می‌نویسیم — خودِ همین نوشتن هم از نسخهٔ فعلی عکس می‌گیرد،
     پس اگر اشتباهی برگرداندید، برگشتنش هم ممکن است. */
  const which = row.k === panel.keys.state ? 'state' : 'db';
  const r = await saveKartabl(env, panel, { [which]: value });
  return { ok: true, which, rev: r.rev };
}

/* ---------- پشتیبان کامل ----------
   همان سه فایلی که کارتابل روی سیستم می‌سازد: دادهٔ JSON، فایل اکسل، و
   خودِ صفحهٔ کارتابل. با همین سه تا، پشتیبان بدون هیچ سرور و اینترنتی
   باز می‌شود — فایل HTML را باز می‌کنی و JSON را «بازیابی» می‌زنی. */

function faDigits(n) {
  return String(n).replace(/[0-9]/g, d => '۰۱۲۳۴۵۶۷۸۹'[d]);
}

export async function buildKartablBackup(env, req, panel) {
  const { state, db, updated } = await loadKartabl(env, panel);
  const st = state || {};
  const database = db || {};

  const stamp = new Date().toISOString().slice(0, 16).replace(/[:T]/g, '-');
  const stateJson = JSON.stringify(st, null, 1);
  const xlsx = await panel.workbook(st, database);

  /* خودِ صفحهٔ کارتابل هم داخل زیپ می‌رود تا پشتیبان کامل باشد.

     آدرس با اسلش گرفته می‌شود، نه /siamak/index.html: کلادفلر آدرس‌های
     ختم‌به‑.html را با ۳۰۷ به نسخهٔ بدون پسوند می‌فرستد و آن ۳۰۷ اینجا
     «ناموفق» حساب می‌شد — یک بار فایل HTML از پشتیبان جا ماند.

     آدرس‌های نسبیِ کتابخانه‌ها هم مطلق می‌شوند، وگرنه فایلِ بازشده روی
     سیستم نمودارها را بالا نمی‌آورد. */
  /* پشتیبان باید بدون هیچ اینترنتی کامل باز شود، پس کتابخانه‌ها و فونت
     هم داخلش می‌روند و صفحه به‌جای آدرس‌های مطلق، کنار خودش را نگاه
     می‌کند. بار اول که این را نگذاشتم، فایلِ آفلاین باز می‌شد ولی
     نمودارها روی «در حال بارگذاری» می‌ماندند. */
  const grab = async path => {
    try {
      const r = await env.ASSETS.fetch(new Request(new URL(path, req.url), req));
      return r.ok ? new Uint8Array(await r.arrayBuffer()) : null;
    } catch (e) { return null; }
  };

  /* همهٔ کارتابل‌ها کتابخانه‌ها را از /v/ می‌گیرند — یک نسخه برای
     هر دو، نه دو کپی روی سرور. */
  const F = panel.folder;
  const extras = [];
  for (const [from, to] of [
    ['/v/chart.umd.min.js', F + '/v/chart.umd.min.js'],
    ['/v/xlsx.full.min.js', F + '/v/xlsx.full.min.js'],
    ['/f/Vazirmatn-Regular.2.woff2',   F + '/f/Vazirmatn-Regular.2.woff2'],
    ['/f/Vazirmatn-Medium.2.woff2',    F + '/f/Vazirmatn-Medium.2.woff2'],
    ['/f/Vazirmatn-SemiBold.2.woff2',  F + '/f/Vazirmatn-SemiBold.2.woff2'],
    ['/f/Vazirmatn-Bold.2.woff2',      F + '/f/Vazirmatn-Bold.2.woff2'],
    ['/f/Vazirmatn-ExtraBold.2.woff2', F + '/f/Vazirmatn-ExtraBold.2.woff2'],
    ['/' + panel.icon, F + '/' + panel.icon]
  ]) {
    const data = await grab(from);
    /* woff2 خودش فشرده است؛ دوباره فشردنش فقط وقت می‌برد */
    if (data) extras.push({ name: to, data, store: to.endsWith('.woff2') });
  }

  let html = '';
  try {
    const res = await env.ASSETS.fetch(new Request(new URL(panel.page, req.url), req));
    if (res.ok) {
      html = (await res.text())
        /* نسخهٔ داخل پشتیبان نباید سراغ سرور برود: نه ورود می‌خواهد و نه
           همگام‌سازی. بدون این پرچم، فایلِ بازشده روی سیستم منتظر جوابی
           می‌ماند که هیچ‌وقت نمی‌آید. */
        .replace('<head>', '<head>\n<script>window.KARTABL_OFFLINE = true;<\/script>')
        /* آدرس‌های مطلق روی file:// به جایی نمی‌رسند */
        .replace(/"\/siamak\/v\//g, '"v/')
        .replace(/\(\/f\//g, '(f/')
        .replace(/"\/f\//g, '"f/')
        .replace(/"\/(icon-[a-z]+\.\d+\.png)"/g, '"$1"');
    }
  } catch (e) { /* بدون صفحه هم پشتیبان می‌رود، بهتر از نرفتنش */ }

  const entries = [
    { name: F + '/' + panel.files.json, data: stateJson },
    { name: F + '/' + panel.files.xlsx, data: xlsx, store: true }  /* خودش زیپ است */
  ];
  if (html) { entries.push({ name: F + '/' + panel.files.html, data: html }); entries.push(...extras); }

  const zip = await makeZip(entries);
  const counts = {
    months: Object.keys(st.monthsData || {}).length + (st.currentMonthKey ? 1 : 0),
    vault: !!(st.personalVault && st.personalVault.cipher),
    own: panel.counts(st, database)
  };
  return { zip, name: panel.zip(stamp), counts, html: !!html, updated };
}

/* ---------- فرستادن به ربات ----------
   ربات کارتابل از ربات فروشگاه جداست، پس توکن و شناسهٔ گفتگویش هم جداست.
   توکن در تنظیمات دیتابیس می‌نشیند، نه در مخزن گیت‌هاب — مخزن عمومی است. */

/* یکی برای هر سه کارتابل، مثل توکنِ ربات — یک کلید بس است */
const AI_KEY_SETTING = 'kartablAiKey';

const TG = t => `https://api.telegram.org/bot${t}`;

export async function kartablBot(env) {
  return { token: await getSetting(env, 'kartablBotToken', ''),
           chat: await getSetting(env, 'kartablChatId', '') };
}

export async function tgMessage(token, chat, text) {
  try {
    const r = await fetch(`${TG(token)}/sendMessage`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chat_id: String(chat), text, parse_mode: 'HTML' })
    });
    const d = await r.json().catch(() => ({}));
    return d.ok ? { ok: true } : { ok: false, error: d.description || 'تلگرام پیام را نپذیرفت.' };
  } catch (e) {
    return { ok: false, error: e.message };
  }
}

export async function sendKartablBackup(env, req, panel, note = '') {
  const { token, chat } = await kartablBot(env);
  if (!token) return { ok: false, error: 'توکن ربات کارتابل تنظیم نشده است.' };
  if (!chat) return { ok: false, error: 'هنوز در ربات /start نزده‌اید، پس معلوم نیست پشتیبان برای چه کسی برود.' };

  const { zip, name, counts, html } = await buildKartablBackup(env, req, panel);
  const own = Object.entries(counts.own).map(([k, v]) => `${faDigits(v)} ${k}`).join(' · ');
  const caption =
    `🗂 <b>پشتیبان ${panel.title}</b>${note ? ' — ' + note : ''}\n` +
    `${own} · ${faDigits(counts.months)} ماه\n` +
    `حجم: ${faDigits(Math.round(zip.length / 1024))} کیلوبایت\n\n` +
    `داخل زیپ: فایل داده، فایل اکسل${html ? '، و خودِ صفحهٔ کارتابل' : ''}.\n` +
    (counts.vault ? 'بخش شخصی رمزنگاری‌شده داخلش هست — با رمز خودش باز می‌شود.\n' : '') +
    `برای برگرداندن: صفحه را باز کن و «⬆ بازیابی» را با فایل JSON بزن.`;

  const fd = new FormData();
  fd.append('chat_id', String(chat));
  fd.append('caption', caption);
  fd.append('parse_mode', 'HTML');
  fd.append('document', new Blob([zip], { type: 'application/zip' }), name);
  try {
    const r = await fetch(`${TG(token)}/sendDocument`, { method: 'POST', body: fd });
    const d = await r.json().catch(() => ({}));
    if (!d.ok) return { ok: false, error: d.description || 'تلگرام فایل را نپذیرفت.' };
    await setSetting(env, panel.keys.last, { at: Date.now(), size: zip.length, ok: true });
    return { ok: true, size: zip.length, name, counts };
  } catch (e) {
    return { ok: false, error: e.message };
  }
}

/* هر شب همراه پشتیبان فروشگاه صدا زده می‌شود — برای هر دو کارتابل */
export async function nightlyKartablBackup(env, slot) {
  /* ورکر در cron درخواستی ندارد، ولی برای گرفتن فایل HTML از ASSETS یک
     Request لازم است. یکی می‌سازیم. */
  const out = {};
  for (const panel of await allPanels(env)) {
    /* کارتابلِ غیرفعال پشتیبان نمی‌خواهد. حذف‌شده که اصلاً در فهرست
       نیست، چون فهرست از همان جدول خوانده می‌شود. */
    if (panel.disabled) continue;
    const req = new Request('https://sensacare.ir' + panel.page);
    /* اگر یکی نرفت، آن یکی نباید قربانی شود */
    const r = await sendKartablBackup(env, req, panel, slot === 'noon' ? 'خودکار — ظهر' : 'خودکار — شبانه')
      .catch(e => ({ ok: false, error: e.message }));
    if (!r.ok) await setSetting(env, panel.keys.last, { at: Date.now(), ok: false, error: r.error });
    out[panel.id] = r;
  }
  return out;
}

/* ---------- مسیرها ---------- */

export async function handleKartabl(env, req, panel, p, m, body, helpers) {
  const { rateLimit, clientIp } = helpers;

  /* ورود */
  if (p === '/login' && m === 'POST') {
    const rl = await rateLimit(env, `${panel.id}-login:` + clientIp(req), 10, 900);
    if (!rl.ok) return bad('تلاش زیاد بود. چند دقیقه صبر کنید.', 429);
    const stored = await getSetting(env, panel.keys.pass, '');
    const check = await checkPassword(String(body.password || ''), stored);
    if (!check.ok) return bad(check.error, check.status);
    const days = body.remember ? 30 : 1;
    /* ورودِ قبلی را برمی‌گردانیم، نه همین یکی: فایدهٔ این عدد این است که
       صاحبِ کارتابل ببیند آخرین بار کِی وارد شده و اگر یادش نمی‌آید،
       بفهمد کسِ دیگری وارد شده. */
    const loginKey = 'login:' + panel.slug;
    const prev = await getSetting(env, loginKey, 0);
    await setSetting(env, loginKey, Date.now());
    return json({ ok: true, lastLogin: prev || 0 }, 200,
      { 'Set-Cookie': cookieHeader(panel, await makeSession(env, panel, days), days) });
  }

  if (p === '/logout' && m === 'POST')
    return json({ ok: true }, 200,
      { 'Set-Cookie': `${panel.cookie}=; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=0` });

  /* ---------- فراموشی رمز ----------
     تنها مسیری است که بدون ورود رمز را عوض می‌کند، پس چند چیز نگهش می‌دارد:

     • رمزِ تازه در پاسخِ HTTP نمی‌آید. فقط به همان گفتگوی تلگرامی می‌رود که
       پشتیبان‌ها می‌روند. یعنی زدنِ این دکمه به‌تنهایی به کسی رمز نمی‌دهد؛
       باید به آن گفتگو هم دسترسی داشته باشد.
     • اول به تلگرام فرستاده می‌شود، بعد رمز عوض می‌شود. اگر تلگرام جواب
       ندهد هیچ‌چیز دست نمی‌خورد — وگرنه یک قطعیِ تلگرام می‌توانست شما را
       بیرونِ کارتابلِ خودتان جا بگذارد.
     • بین دو ریست پانزده دقیقه فاصله است و هر IP در ساعت پنج بار. بدون
       این، هر کسی که آدرس را می‌داند می‌توانست با زدنِ پیاپیِ دکمه رمز را
       مدام عوض کند و عملاً قفلتان کند. */
  if (p === '/forgot' && m === 'POST') {
    const rl = await rateLimit(env, `${panel.id}-forgot:` + clientIp(req), 5, 3600);
    if (!rl.ok) return bad('درخواست‌ها زیاد شد. یک ساعت دیگر.', 429);

    const gap = 15 * 60 * 1000;
    const wait = (await getSetting(env, panel.keys.reset, 0)) + gap - Date.now();
    if (wait > 0)
      return bad(`همین چند دقیقه پیش رمز تازه فرستاده شد. پیام ربات را ببینید، یا ${faDigits(Math.ceil(wait / 60000))} دقیقهٔ دیگر دوباره بزنید.`, 429);

    const { token, chat } = await kartablBot(env);
    if (!token || !chat)
      return bad('ربات تلگرام به کارتابل وصل نیست، پس جایی برای فرستادن رمز تازه نیست.', 503);

    const next = newPassword();
    const sent = await tgMessage(token, chat,
      `🔑 <b>رمز تازهٔ ${panel.title}</b>\n\n` +
      `<code>${next}</code>\n\n` +
      `از همین حالا رمز قبلی کار نمی‌کند و هر دستگاهی که وارد مانده بود بیرون افتاد.\n` +
      `بعد از ورود، از «تنظیمات ← رمز ورود» به چیزی که خودتان می‌پسندید عوضش کنید.\n\n` +
      `اگر این را شما نخواسته‌اید: کسی رمز را ندارد، فقط دکمهٔ «رمز را فراموش کرده‌ام» را زده. ` +
      `همین رمز تازه را وارد کنید و عوضش کنید.`);
    if (!sent.ok) return bad('به تلگرام نرسید، پس رمز هم عوض نشد: ' + sent.error, 502);

    await setSetting(env, panel.keys.pass, await hashPassword(next));
    await setSetting(env, panel.keys.gen, (await getSetting(env, panel.keys.gen, 1)) + 1);
    await setSetting(env, panel.keys.reset, Date.now());
    return json({ ok: true });
  }

  /* از این‌جا به بعد بدون نشست معتبر هیچ‌چیز */
  const session = await readSession(env, panel, req);
  if (p === '/me')
    /* زمانِ آخرین ورود فقط برای کسی که وارد شده. بیرونِ در، این عدد
       به هر کسی که آدرس را دارد می‌گفت این کارتابل کِی استفاده شده. */
    return json(session
      ? { in: true, lastLogin: await getSetting(env, 'login:' + panel.slug, 0) }
      : { in: false });
  if (!session) return bad('وارد نشده‌اید.', 401);

  /* بخشی که ادمین بسته، حتی با نشستِ معتبر هم باز نمی‌شود. */
  {
    const f = featureOff(panel, p);
    if (f) return bad('این بخش برای شما بسته است. با مدیر سیستم تماس بگیرید.', 403);
  }

  if (p === '/state' && m === 'GET') {
    const d = await loadKartabl(env, panel);
    return json({ state: d.state, db: d.db, rev: d.rev, updated: d.updated });
  }

  if (p === '/state' && (m === 'PUT' || m === 'POST')) {
    if (body.state === undefined && body.db === undefined) return bad('داده‌ای نیامد.');
    const r = await saveKartabl(env, panel, { state: body.state, db: body.db,
                                              baseRev: body.baseRev, force: !!body.force });
    if (r.conflict) return json({ conflict: true, rev: r.rev, updated: r.updated }, REV_CONFLICT);
    /* ردیفِ ناخوانا روی سرور: نوشتن رویش قفل است تا آدم خبردار شود */
    if (r.broken) return json({ broken: r.broken, rev: r.rev, updated: r.updated }, REV_CONFLICT);
    /* نوشتنِ ویرانگر: رد نمی‌شود، ولی بی‌صدا هم انجام نمی‌شود */
    if (r.loss) return json({ loss: r.loss, kind: r.kind, rev: r.rev, updated: r.updated }, REV_CONFLICT);
    return json({ ok: true, rev: r.rev, updated: r.updated });
  }

  /* ---------- دستیار هوشمند ----------
     پشتِ همان قفلِ ورود است، و متنِ داده‌هایی که به مدل می‌رود را خودِ سرور
     از روی دادهٔ همین کارتابل می‌سازد — نه از چیزی که مرورگر فرستاده. پس
     دستیارِ یک کارتابل به دادهٔ آن دو تای دیگر نمی‌رسد، حتی اگر کسی بدنهٔ
     درخواست را دست‌کاری کند. تنها چیزی که از مرورگر می‌گیریم تاریخِ امروز
     است (برای تشخیص سررسیدگذشته) و آن هم اول شکلش بررسی می‌شود. */
  if (p === '/ai' && m === 'POST') {
    const rl = await rateLimit(env, `${panel.id}-ai:` + clientIp(req), 80, 3600);
    if (!rl.ok) return bad('سؤال‌ها زیاد شد. کمی بعد دوباره بپرسید.', 429);
    const today = /^\d{4}\/\d{2}\/\d{2}$/.test(String(body.today || '')) ? String(body.today) : '';
    const claudeKey = await getSetting(env, AI_KEY_SETTING, '');
    const d = await loadKartabl(env, panel);
    /* کلاد متنِ کامل را می‌گیرد. مدل‌های رایگان فقط وقتی سؤال به کارتابل
       می‌خورد، وگرنه جدول‌ها حواسشان را از سؤال پرت می‌کند. */
    const detail = !!claudeKey || looksPlannerRelated(body.messages, panel.kind);
    const ctx = buildAiContext(panel, d.state, d.db, today, detail);
    const r = await askKartablAI(env, panel, body.messages, ctx, { claudeKey });
    return r.ok ? json({ reply: r.reply, model: r.model, via: r.via }) : bad(r.error, r.status || 502);
  }

  /* ---------- نسخه‌های قبلی ----------
     پیش از هر بازنویسی یک عکس از نسخهٔ قبلی نگه داشته می‌شود؛ این دو
     مسیر همان‌ها را نشان می‌دهند و برمی‌گردانند. */
  if (p === '/state/history' && m === 'GET')
    return json({ items: await listKartablHistory(env, panel) });

  if (p === '/state/restore' && m === 'POST') {
    const id = parseInt(body.id, 10);
    if (!id) return bad('کدام نسخه؟');
    const r = await restoreKartablSnapshot(env, panel, id);
    return r.ok ? json(r) : bad(r.error, 400);
  }

  /* عوض کردن رمز — رمز فعلی لازم است، و همهٔ نشست‌های دیگر بسته می‌شوند */
  if (p === '/password' && m === 'POST') {
    const stored = await getSetting(env, panel.keys.pass, '');
    const check = await checkPassword(String(body.current || ''), stored);
    if (!check.ok) return bad(check.status === 401 ? 'رمز فعلی درست نیست.' : check.error, check.status);
    const next = String(body.next || '');
    if (next.length < 8) return bad('رمز تازه باید دست‌کم ۸ کاراکتر باشد.');
    await setSetting(env, panel.keys.pass, await hashPassword(next));
    await setSetting(env, panel.keys.gen, (await getSetting(env, panel.keys.gen, 1)) + 1);
    /* نشست خودِ این مرورگر با نسل تازه دوباره ساخته می‌شود تا کاربر
       وسط کار بیرون نیفتد؛ بقیه باید دوباره وارد شوند. */
    return json({ ok: true }, 200,
      { 'Set-Cookie': cookieHeader(panel, await makeSession(env, panel, 30), 30) });
  }

  /* ---------- کلیدِ اضطراریِ ادمین ----------
     ادمین یک جفت کلید دارد: عمومی روی سرور و خصوصی هم روی سرور ولی
     قفل‌شده با عبارتی که فقط در مرورگرِ خودش تایپ می‌شود. این‌جا
     مرورگرِ کاربر کلیدِ عمومی را می‌گیرد، رمزِ دیتای شخصی‌اش را با آن
     می‌پیچد و بستهٔ پیچیده را پس می‌فرستد.

     نتیجه‌اش این است: سرور هر دو تکه را دارد و باز هم نمی‌تواند بخواند؛
     ادمین با رمزِ خودش می‌تواند. */
  if (p === '/escrow-pub' && m === 'GET')
    return json({ ok: true, pub: await getSetting(env, 'vaultEscrowPub', null) });

  if (p === '/escrow' && m === 'POST') {
    if (!body.bundle || !body.bundle.cipher) return bad('بستهٔ کلید ناقص است.');
    await setSetting(env, 'escrow:' + panel.slug, body.bundle);
    return json({ ok: true });
  }

  /* ---------- کد بازیابیِ «دیتای شخصی» ----------
     این بخش سمتِ مرورگر رمز می‌شود و کلیدش هیچ‌وقت به سرور نمی‌رسد، پس
     برخلافِ رمزِ ورود، سرور نمی‌تواند رمزِ تازه بسازد — هر رمزِ تازه‌ای
     فقط یک صندوقِ خالی باز می‌کند.

     راهِ بازیابی این است: مرورگر یک کد می‌سازد، رمزِ فعلی را با همان کد
     قفل می‌کند، و پاکتِ قفل‌شده کنار بقیهٔ داده می‌ماند. کارِ سرور فقط
     همین است که کد را یک بار به تلگرام برساند — نه می‌سازدش نه نگهش
     می‌دارد. یعنی کسی که به دادهٔ سرور برسد پاکت را دارد ولی کلیدش را نه. */
  if (p === '/vault/recovery' && m === 'POST') {
    const rl = await rateLimit(env, `${panel.id}-vaultrec:` + clientIp(req), 10, 3600);
    if (!rl.ok) return bad('درخواست‌ها زیاد شد. یک ساعت دیگر.', 429);
    const code = String(body.code || '').trim();
    /* کد داخل پیامِ HTMLی تلگرام می‌نشیند، پس فقط همین حروف اجازه دارند */
    if (!/^[A-Za-z0-9-]{8,64}$/.test(code)) return bad('کد بازیابی خوانا نیست.');
    const { token, chat } = await kartablBot(env);
    if (!token || !chat)
      return bad('ربات تلگرام به کارتابل وصل نیست، پس جایی برای فرستادن کد نیست.', 503);
    const sent = await tgMessage(token, chat,
      `🔐 <b>کد بازیابیِ دیتای شخصی — ${panel.title}</b>\n\n` +
      `<code>${code}</code>\n\n` +
      `این کد جایگزینِ رمز نیست. فقط اگر رمزِ «دیتای شخصی» را فراموش کردید، ` +
      `با همین کد باز می‌شود و داده‌ها سرِ جایشان می‌مانند.\n` +
      `این پیام را پاک نکنید. اگر قبلاً کدی داشتید، آن یکی دیگر کار نمی‌کند.`);
    if (!sent.ok) return bad('به تلگرام نرسید: ' + sent.error, 502);
    return json({ ok: true });
  }

  /* ---------- انتخابِ سرویسِ دستیار ----------
     کلید مثل توکنِ ربات در تنظیماتِ دیتابیس می‌نشیند، نه در مخزن گیت‌هاب.
     خودِ کلید هیچ‌وقت به مرورگر برنگردانده نمی‌شود؛ فقط چند حرف اولش تا
     معلوم باشد کدام کلید نشسته. */
  if (p === '/ai/settings' && m === 'GET') {
    const key = await getSetting(env, AI_KEY_SETTING, '');
    return json({
      provider: key ? 'claude' : 'workers-ai',
      model: key ? CLAUDE_MODEL : 'Workers AI (رایگان)',
      hint: key ? key.slice(0, 11) + '…' + key.slice(-4) : ''
    });
  }

  if (p === '/ai/settings' && m === 'POST') {
    const key = String(body.key || '').trim();
    if (!key) {
      await setSetting(env, AI_KEY_SETTING, '');
      return json({ ok: true, provider: 'workers-ai', model: 'Workers AI (رایگان)', hint: '' });
    }
    if (!/^sk-ant-\S{20,}$/.test(key)) return bad('این شکلِ کلید آنتروپیک نیست.');
    /* همان‌جا امتحانش می‌کنیم، وگرنه کلیدِ غلط تا اولین سؤال معلوم نمی‌شود */
    const t = await askKartablAI(env, panel, [{ role: 'user', content: 'فقط بنویس: باشد' }],
      'آزمایشِ کلید است؛ داده‌ای لازم نیست.', { claudeKey: key });
    if (!t.ok) return bad(t.error, 502);
    await setSetting(env, AI_KEY_SETTING, key);
    return json({ ok: true, provider: 'claude', model: CLAUDE_MODEL,
                  hint: key.slice(0, 11) + '…' + key.slice(-4) });
  }

  /* تنظیمات ربات و پشتیبان */
  if (p === '/backup/settings' && m === 'GET') {
    const { token, chat } = await kartablBot(env);
    let botName = '';
    if (token) {
      try {
        const d = await (await fetch(`${TG(token)}/getMe`)).json();
        botName = d.ok ? d.result.username : '';
      } catch (e) { /* اینترنت نبود — فقط اسم ربات را نشان نمی‌دهیم */ }
    }
    return json({ hasToken: !!token, botName, chat: chat || '',
                  last: await getSetting(env, panel.keys.last, null) });
  }

  if (p === '/backup/settings' && m === 'POST') {
    const token = String(body.token || '').trim();
    if (!token) return bad('توکن خالی است.');
    if (!/^\d+:[\w-]{20,}$/.test(token)) return bad('این شکلِ توکن ربات تلگرام نیست.');
    let d;
    try { d = await (await fetch(`${TG(token)}/getMe`)).json(); }
    catch (e) { return bad('به تلگرام نرسیدم: ' + e.message, 502); }
    if (!d.ok) return bad('تلگرام این توکن را نپذیرفت.', 400);
    await setSetting(env, 'kartablBotToken', token);
    return json({ ok: true, botName: d.result.username });
  }

  /* پیدا کردن شناسهٔ گفتگو: بعد از اینکه در ربات /start زد */
  if (p === '/backup/connect' && m === 'POST') {
    const { token } = await kartablBot(env);
    if (!token) return bad('اول توکن ربات را بگذارید.');
    let d;
    try { d = await (await fetch(`${TG(token)}/getUpdates?limit=20`)).json(); }
    catch (e) { return bad('به تلگرام نرسیدم: ' + e.message, 502); }
    if (!d.ok) return bad(d.description || 'تلگرام جواب نداد.', 502);
    const chats = [];
    for (const u of d.result || []) {
      const c = u.message?.chat || u.channel_post?.chat;
      if (c && !chats.find(x => x.id === c.id))
        chats.push({ id: c.id, name: [c.first_name, c.last_name].filter(Boolean).join(' ')
                     || c.title || c.username || String(c.id) });
    }
    if (!chats.length) return bad('هنوز پیامی به ربات نرسیده. در تلگرام ربات را باز کنید و /start بزنید، بعد دوباره همین دکمه را بزنید.', 404);
    const pick = chats[chats.length - 1];
    await setSetting(env, 'kartablChatId', String(pick.id));
    try {
      await fetch(`${TG(token)}/sendMessage`, { method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ chat_id: pick.id,
          text: `✅ ${panel.title} به این گفتگو وصل شد. از امشب هر شب پشتیبان کامل همین‌جا می‌آید.` }) });
    } catch (e) { /* پیام خوش‌آمد اختیاری است */ }
    return json({ ok: true, chat: String(pick.id), name: pick.name, found: chats.length });
  }

  if (p === '/backup/now' && m === 'POST') {
    const rl = await rateLimit(env, `${panel.id}-backup:` + clientIp(req), 6, 3600);
    if (!rl.ok) return bad('فعلاً بس است. یک ساعت دیگر.', 429);
    const r = await sendKartablBackup(env, req, panel, 'دستی');
    return r.ok ? json(r) : bad(r.error, 502);
  }

  /* گرفتن همان زیپ مستقیم از مرورگر */
  if (p === '/backup/download' && m === 'GET') {
    const { zip, name } = await buildKartablBackup(env, req, panel);
    return new Response(zip, { headers: {
      'Content-Type': 'application/zip',
      'Content-Disposition': `attachment; filename*=UTF-8''${encodeURIComponent(name)}`,
      'Cache-Control': 'no-store', 'X-Robots-Tag': 'noindex' } });
  }

  return bad('این مسیر کارتابل وجود ندارد.', 404);
}
