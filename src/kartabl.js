/* ---------- کارتابل مدیر IT: داده روی سرور، پشتیبان شبانه در تلگرام ----------

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

import { buildKartablWorkbook, buildSinaWorkbook } from './kartabl-xlsx.js';
import { makeZip } from './kartabl-zip.js';

/* ---------- کارتابل‌ها ----------
   سه کارتابل داریم و هر سه از همین کد استفاده می‌کنند: سیامک روی
   /siamak، سینا روی /sina و رضا روی /reza. هر کدام رمز، نشست و دادهٔ
   کاملاً جداگانه دارد — ورود به یکی به آن یکی دسترسی نمی‌دهد — ولی
   پشتیبان شبانهٔ هر سه به همان یک ربات تلگرام می‌رود.

   کلیدهای کارتابل IT عمداً همان‌های قبلی ماندند («state»، «db»،
   «kartablPassHash»)، وگرنه دادهٔ زنده‌اش باید جابه‌جا می‌شد. */
export const PANELS = {
  it: {
    id: 'it', title: 'کارتابل مدیر IT', page: '/siamak/', cookie: 'kartabl_s',
    keys: { state: 'state', db: 'db', pass: 'kartablPassHash', gen: 'kartablPassGen', last: 'kartablLastBackup' },
    folder: 'It',
    files: { json: 'کارتابل-IT-داده.json', xlsx: 'کارتابل-IT-دیتابیس.xlsx', html: 'کارتابل مدیر IT.html' },
    zip: stamp => `کارتابل-IT-پشتیبان-${stamp}.zip`,
    workbook: buildKartablWorkbook,
    counts: (st, db) => ({
      سرور: (db.vm || []).length, شرکت: Object.keys(db.companies || {}).length,
      'خط MVPN': (db.lines || []).length
    })
  },
  sina: {
    id: 'sina', title: 'کارتابل مدیر مالی', page: '/sina/', cookie: 'sina_s',
    keys: { state: 'sina:state', db: 'sina:db', pass: 'sinaPassHash', gen: 'sinaPassGen', last: 'sinaLastBackup' },
    folder: 'Mali',
    files: { json: 'کارتابل-مالی-داده.json', xlsx: 'کارتابل-مالی-دیتابیس.xlsx', html: 'کارتابل مدیر مالی.html' },
    zip: stamp => `کارتابل-مالی-پشتیبان-${stamp}.zip`,
    workbook: buildSinaWorkbook,
    counts: (st, db) => ({
      'طرف‌حساب': (db.parties || []).length, فاکتور: (db.invoices || []).length,
      'حساب بانکی': (db.bank || []).length
    })
  },
  reza: {
    id: 'reza', title: 'کارتابل ماهانه رضا', page: '/reza/', cookie: 'reza_s',
    keys: { state: 'reza:state', db: 'reza:db', pass: 'rezaPassHash', gen: 'rezaPassGen', last: 'rezaLastBackup' },
    folder: 'Reza',
    files: { json: 'کارتابل-رضا-داده.json', xlsx: 'کارتابل-رضا-دیتابیس.xlsx', html: 'کارتابل ماهانه رضا.html' },
    zip: stamp => `کارتابل-رضا-پشتیبان-${stamp}.zip`,
    /* ساختارش همان کارتابل مالی است، پس همان سازندهٔ برگه‌ها */
    workbook: buildSinaWorkbook,
    counts: (st, db) => ({
      'طرف‌حساب': (db.parties || []).length, فاکتور: (db.invoices || []).length,
      'حساب بانکی': (db.bank || []).length
    })
  }
};

const enc = new TextEncoder();

const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();
const run = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).run();

const getSetting = async (env, k, d = null) => {
  const r = await one(env, 'SELECT v FROM settings WHERE k=?', k);
  try { return r ? JSON.parse(r.v) : d; } catch { return d; }
};
const setSetting = (env, k, v) =>
  run(env, 'INSERT INTO settings(k,v) VALUES(?,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v',
      k, JSON.stringify(v));

const json = (data, status = 200, extra = {}) => new Response(JSON.stringify(data), {
  status, headers: { 'Content-Type': 'application/json; charset=utf-8',
                     'Cache-Control': 'no-store', 'X-Robots-Tag': 'noindex', ...extra } });
const bad = (msg, status = 400) => json({ error: msg }, status);

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

function constantEqual(a, b) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/* { ok } یا { error } برمی‌گرداند. اگر خودِ محاسبه شکست بخورد، «رمز اشتباه
   است» جواب نمی‌دهیم: یک بار همین قورت دادنِ خطا باعث شد ساعت‌ها دنبال
   رمزِ درست بگردیم، درحالی‌که ایراد از جای دیگری بود. */
async function checkPassword(password, stored) {
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

async function makeSession(env, panel, days = 30) {
  /* شمارهٔ نسل رمز داخل توکن است: با هر بار عوض شدن رمز بالا می‌رود و
     همهٔ نشست‌های قبلی — روی هر دستگاهی — از کار می‌افتند. */
  const gen = await getSetting(env, panel.keys.gen, 1);
  const body = b64(enc.encode(JSON.stringify({ k: panel.id, gen, exp: Date.now() + days * 864e5 })))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  return body + '.' + await hmac(env, body);
}

async function readSession(env, panel, req) {
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

const cookieHeader = (panel, value, days) =>
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
  const out = { state: null, db: null, rev: 0, updated: 0 };
  for (const r of rows) {
    const which = r.k === panel.keys.state ? 'state' : 'db';
    try { out[which] = JSON.parse(r.v); } catch (e) { out[which] = null; }
    out.rev = Math.max(out.rev, r.rev || 0);
    out.updated = Math.max(out.updated, r.updated || 0);
  }
  return out;
}

async function saveKartabl(env, panel, { state, db, baseRev }) {
  const current = await loadKartabl(env, panel);
  /* اگر از دستگاه دیگری چیزی ذخیره شده که این مرورگر ندیده، بی‌صدا
     رویش نمی‌نویسیم — صفحه خبردار می‌شود و تازه‌اش را می‌گیرد. */
  if (baseRev != null && current.rev && Number(baseRev) !== current.rev)
    return { conflict: true, rev: current.rev, updated: current.updated };

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
  if (stmts.length) await env.DB.batch(stmts);
  return { rev, updated: now };
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

  /* هر دو کارتابل کتابخانه‌ها را از /siamak/v/ می‌گیرند — یک نسخه برای
     هر دو، نه دو کپی روی سرور. */
  const F = panel.folder;
  const extras = [];
  for (const [from, to] of [
    ['/siamak/v/chart.umd.min.js', F + '/v/chart.umd.min.js'],
    ['/siamak/v/xlsx.full.min.js', F + '/v/xlsx.full.min.js'],
    ['/f/Vazirmatn-Regular.2.woff2',   F + '/f/Vazirmatn-Regular.2.woff2'],
    ['/f/Vazirmatn-Medium.2.woff2',    F + '/f/Vazirmatn-Medium.2.woff2'],
    ['/f/Vazirmatn-SemiBold.2.woff2',  F + '/f/Vazirmatn-SemiBold.2.woff2'],
    ['/f/Vazirmatn-Bold.2.woff2',      F + '/f/Vazirmatn-Bold.2.woff2'],
    ['/f/Vazirmatn-ExtraBold.2.woff2', F + '/f/Vazirmatn-ExtraBold.2.woff2']
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
        .replace(/"\/f\//g, '"f/');
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

const TG = t => `https://api.telegram.org/bot${t}`;

async function kartablBot(env) {
  return { token: await getSetting(env, 'kartablBotToken', ''),
           chat: await getSetting(env, 'kartablChatId', '') };
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
export async function nightlyKartablBackup(env) {
  /* ورکر در cron درخواستی ندارد، ولی برای گرفتن فایل HTML از ASSETS یک
     Request لازم است. یکی می‌سازیم. */
  const out = {};
  for (const panel of Object.values(PANELS)) {
    const req = new Request('https://sensacare.ir' + panel.page);
    /* اگر یکی نرفت، آن یکی نباید قربانی شود */
    const r = await sendKartablBackup(env, req, panel, 'خودکار')
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
    return json({ ok: true }, 200,
      { 'Set-Cookie': cookieHeader(panel, await makeSession(env, panel, days), days) });
  }

  if (p === '/logout' && m === 'POST')
    return json({ ok: true }, 200,
      { 'Set-Cookie': `${panel.cookie}=; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=0` });

  /* از این‌جا به بعد بدون نشست معتبر هیچ‌چیز */
  const session = await readSession(env, panel, req);
  if (p === '/me')
    return json({ in: !!session });
  if (!session) return bad('وارد نشده‌اید.', 401);

  if (p === '/state' && m === 'GET') {
    const d = await loadKartabl(env, panel);
    return json({ state: d.state, db: d.db, rev: d.rev, updated: d.updated });
  }

  if (p === '/state' && (m === 'PUT' || m === 'POST')) {
    if (body.state === undefined && body.db === undefined) return bad('داده‌ای نیامد.');
    const r = await saveKartabl(env, panel, { state: body.state, db: body.db, baseRev: body.baseRev });
    if (r.conflict) return json({ conflict: true, rev: r.rev, updated: r.updated }, REV_CONFLICT);
    return json({ ok: true, rev: r.rev, updated: r.updated });
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
          text: '✅ کارتابل مدیر IT به این گفتگو وصل شد. از امشب هر شب پشتیبان کامل همین‌جا می‌آید.' }) });
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
