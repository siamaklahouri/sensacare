/* ==================== یادآورِ بسته‌بودنِ برنامه ====================
   یادآورها تا حالا فقط وقتی کار می‌کردند که کارتابل باز بود: یک
   setInterval داخلِ صفحه هر بیست ثانیه نگاه می‌کرد. یعنی «۲ روز قبل
   از قسط خبر بده» اگر آن روز کارتابل را باز نمی‌کردی، اصلاً نمی‌آمد.
   قولی بود که نیمه‌کاره مانده بود.

   حالا صف روی سرور است و سرور خودش هر دقیقه نگاه می‌کند.

   چرا پیامِ «بی‌محتوا»: در Web Push، محتوا باید با کلیدِ خودِ مرورگر
   رمز شود (RFC 8291) — یعنی ECDH و HKDF و AES-GCM با دستِ خالی. ولی
   پیامِ بی‌محتوا هم مرورگر را بیدار می‌کند. پس سرور فقط «بیدار شو»
   می‌فرستد و سرویس‌ورکر خودش صفِ سررسیده را از همین‌جا می‌خواند.
   نتیجه یکی است و رمزنگاریِ دست‌سازی در کار نیست — که بهترین
   رمزنگاریِ دست‌ساز است.

   چه چیزی از متنِ یادآور روی سرور می‌نشیند: همان چیزی که از قبل در
   state هست (نامِ کار). برای دیتای شخصی، صفحه عمداً متنِ کلی
   می‌فرستد («یک سررسید نزدیک است») — رمزِ صندوق به سرور نمی‌رسد و
   نباید هم برسد. */

const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();
const run = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).run();

const b64url = buf => btoa(String.fromCharCode(...new Uint8Array(buf)))
  .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
const fromB64url = s => {
  const t = String(s || '').replace(/-/g, '+').replace(/_/g, '/');
  const bin = atob(t + '='.repeat((4 - t.length % 4) % 4));
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
};

let ready = false;
export async function ensurePush(env) {
  if (ready) return;
  await env.DB.batch([
    env.DB.prepare(`CREATE TABLE IF NOT EXISTS push_subs (
      id       TEXT PRIMARY KEY,
      planner  TEXT NOT NULL,
      endpoint TEXT NOT NULL,
      created  INTEGER NOT NULL DEFAULT 0
    )`),
    env.DB.prepare('CREATE INDEX IF NOT EXISTS push_subs_planner ON push_subs(planner)'),
    env.DB.prepare(`CREATE TABLE IF NOT EXISTS reminders (
      id      TEXT PRIMARY KEY,
      planner TEXT NOT NULL,
      at      INTEGER NOT NULL DEFAULT 0,
      title   TEXT NOT NULL DEFAULT '',
      body    TEXT NOT NULL DEFAULT '',
      tag     TEXT NOT NULL DEFAULT '',
      sent    INTEGER NOT NULL DEFAULT 0,
      shown   INTEGER NOT NULL DEFAULT 0
    )`),
    env.DB.prepare('CREATE INDEX IF NOT EXISTS reminders_due ON reminders(sent, at)')
  ]);
  ready = true;
}

/* ---------- کلیدِ VAPID ----------
   یک بار ساخته می‌شود و در settings می‌ماند. عوض شدنش یعنی همهٔ
   اشتراک‌های موجود باطل‌اند، پس عمداً هیچ‌جا دوباره ساخته نمی‌شود. */
async function vapid(env) {
  const { getSetting, setSetting } = await import('./kartabl.js');
  let kp = await getSetting(env, 'push:vapid', null);
  if (!kp) {
    const k = await crypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, true,
      ['sign', 'verify']);
    const pub = await crypto.subtle.exportKey('raw', k.publicKey);
    const priv = await crypto.subtle.exportKey('jwk', k.privateKey);
    kp = { pub: b64url(pub), priv };
    await setSetting(env, 'push:vapid', kp);
  }
  return kp;
}

export async function publicKey(env) { return (await vapid(env)).pub; }

async function jwtFor(env, endpoint) {
  const kp = await vapid(env);
  const aud = new URL(endpoint).origin;
  const head = b64url(new TextEncoder().encode(JSON.stringify({ typ: 'JWT', alg: 'ES256' })));
  const body = b64url(new TextEncoder().encode(JSON.stringify({
    aud, exp: Math.floor(Date.now() / 1000) + 10 * 3600,
    sub: 'mailto:' + (env.PUSH_CONTACT || 'admin@sltech.ir')
  })));
  const key = await crypto.subtle.importKey('jwk', kp.priv,
    { name: 'ECDSA', namedCurve: 'P-256' }, false, ['sign']);
  const sig = await crypto.subtle.sign({ name: 'ECDSA', hash: 'SHA-256' }, key,
    new TextEncoder().encode(head + '.' + body));
  return { jwt: head + '.' + body + '.' + b64url(sig), pub: kp.pub };
}

/* ---------- اشتراک‌ها ---------- */
export async function addSub(env, planner, sub) {
  await ensurePush(env);
  const ep = String((sub && sub.endpoint) || '');
  if (!/^https:\/\//.test(ep)) return { error: 'اشتراکِ نامعتبر.' };
  const id = b64url(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(ep))).slice(0, 32);
  await run(env, 'INSERT OR REPLACE INTO push_subs(id,planner,endpoint,created) VALUES(?,?,?,?)',
    id, planner, ep, Date.now());
  return { ok: true, id };
}

export async function dropSub(env, planner, endpoint) {
  await ensurePush(env);
  await run(env, 'DELETE FROM push_subs WHERE planner=? AND endpoint=?', planner, String(endpoint || ''));
  return { ok: true };
}

export async function subCount(env, planner) {
  await ensurePush(env);
  const r = await one(env, 'SELECT COUNT(*) AS n FROM push_subs WHERE planner=?', planner);
  return Number((r && r.n) || 0);
}

/* ---------- صفِ یادآورها ----------
   صفحه کلِ صف را می‌فرستد، نه تکه‌تکه: حساب کردنِ «کدام عوض شده» سمتِ
   صفحه سخت‌تر از فرستادنِ دوبارهٔ یک فهرستِ کوچک است، و این‌طوری
   یادآورِ پاک‌شده هم خودبه‌خود می‌رود. آن‌هایی که از قبل فرستاده
   شده‌اند دست نمی‌خورند تا دوباره نیایند. */
export async function setQueue(env, planner, items) {
  await ensurePush(env);
  const keep = await all(env, 'SELECT id FROM reminders WHERE planner=? AND sent=1', planner);
  const kept = new Set(keep.map(r => r.id));
  await run(env, 'DELETE FROM reminders WHERE planner=? AND sent=0', planner);
  let n = 0;
  for (const it of (Array.isArray(items) ? items : []).slice(0, 200)) {
    const id = planner + ':' + String(it.id || '').slice(0, 80);
    if (!it.id || kept.has(id)) continue;
    const at = Number(it.at) || 0;
    if (!at || at > Date.now() + 400 * 86400000) continue;
    await run(env,
      'INSERT OR REPLACE INTO reminders(id,planner,at,title,body,tag,sent,shown) VALUES(?,?,?,?,?,?,0,0)',
      id, planner, at, String(it.title || '').slice(0, 120),
      String(it.body || '').slice(0, 300), String(it.tag || '').slice(0, 60));
    n++;
  }
  return { ok: true, n };
}

/* آنچه سرویس‌ورکر باید همین حالا نشان بدهد. خوانده که شد، «نشان
   داده شد» علامت می‌خورد تا دو بار نیاید. */
export async function dueFor(env, planner) {
  await ensurePush(env);
  const rows = await all(env,
    'SELECT id,title,body,tag,at FROM reminders WHERE planner=? AND sent=1 AND shown=0 ORDER BY at',
    planner);
  if (rows.length)
    await run(env, 'UPDATE reminders SET shown=1 WHERE planner=? AND sent=1 AND shown=0', planner);
  return rows;
}

/* ---------- خودِ فرستادن ----------
   یک پیامِ بی‌محتوا به هر اشتراکِ آن کارتابل. ۴۰۴ و ۴۱۰ یعنی مرورگر
   اشتراک را دور انداخته؛ همان‌جا از جدول هم می‌رود. */
async function wake(env, planner) {
  const subs = await all(env, 'SELECT id,endpoint FROM push_subs WHERE planner=?', planner);
  let ok = 0;
  for (const s of subs) {
    try {
      const { jwt, pub } = await jwtFor(env, s.endpoint);
      const r = await fetch(s.endpoint, { method: 'POST', headers: {
        'TTL': '86400',
        'Urgency': 'high',
        'Content-Length': '0',
        'Authorization': 'vapid t=' + jwt + ', k=' + pub
      } });
      if (r.status === 404 || r.status === 410)
        await run(env, 'DELETE FROM push_subs WHERE id=?', s.id);
      else if (r.ok || r.status === 201 || r.status === 202) ok++;
    } catch (e) { /* یک اشتراکِ خراب نباید بقیه را بخواباند */ }
  }
  return ok;
}

/* هر دقیقه: هرچه سررسیده، «فرستاده» علامت می‌خورد و مرورگر بیدار
   می‌شود. علامت پیش از فرستادن می‌خورد، نه بعدش — وگرنه یک خطای شبکه
   یعنی همان یادآور دقیقهٔ بعد دوباره فرستاده می‌شود. */
export async function tick(env) {
  await ensurePush(env);
  const due = await all(env,
    'SELECT DISTINCT planner FROM reminders WHERE sent=0 AND at<=?', Date.now());
  if (!due.length) return { planners: 0 };
  for (const d of due) {
    await run(env, 'UPDATE reminders SET sent=1 WHERE planner=? AND sent=0 AND at<=?',
      d.planner, Date.now());
    await wake(env, d.planner);
  }
  /* کهنه‌ها پاک می‌شوند: جدول نباید برای همیشه رشد کند. شرط روی
     «at» است و نه روی «نشان داده شد» — یادآوری که فرستاده شد و کاربر
     هیچ‌وقت برنامه را باز نکرد هم بالاخره باید برود. سه ماه هم برای
     یادِ «این را قبلاً فرستاده‌ام» بیش از کافی است. */
  await run(env, 'DELETE FROM reminders WHERE at < ?', Date.now() - 90 * 86400000);
  return { planners: due.length };
}

export async function dropPlannerPush(env, planner) {
  await ensurePush(env);
  await run(env, 'DELETE FROM push_subs WHERE planner=?', planner);
  await run(env, 'DELETE FROM reminders WHERE planner=?', planner);
}
