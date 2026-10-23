/* ==================== پیوستِ فایل ====================
   تا حالا هیچ راهی نبود که به یک وظیفه یا یک روزِ برنامه، تصویرِ
   فاکتور یا رسید یا یک کانفیگ چسبانده شود. آدم‌ها همین‌ها را در
   پیام‌رسان نگه می‌دارند و شش ماه بعد پیدا نمی‌کنند.

   دو تصمیمِ اصلی:

   یک) فایل داخلِ همان بلوبِ state نمی‌رود. state با هر ذخیره کامل
   بالا و پایین می‌رود؛ یک عکسِ دومگابایتی یعنی همان دو مگابایت در هر
   تایپ. پس جدولِ خودش را دارد و از راهِ خودش می‌آید و می‌رود.

   دو) جای خودِ بایت‌ها روی دیسکِ سرور است، نه داخلِ دیتابیس. پشتیبانِ
   ساعتیِ دیتابیس هر ساعت یک نسخهٔ کامل می‌گیرد؛ با فایل‌های داخلش،
   همان پشتیبان در یک هفته ده‌ها گیگ می‌شد. روی کلادفلر که دیسکی
   نیست، همان بایت‌ها در ستونِ blob می‌نشینند — کد یکی است، جایش فرق
   می‌کند. */

const MAX_FILE = 4 * 1024 * 1024;        /* هر فایل */
const QUOTA    = 40 * 1024 * 1024;       /* هر کارتابل روی هم */
export const FILE_LIMITS = { file: MAX_FILE, quota: QUOTA };

/* پسوند و نوعی که اجازه دارد. فهرستِ سفید است نه سیاه: چیزی که
   این‌جا نیست بالا نمی‌رود، و HTML و SVG عمداً نیستند — روی همین
   دامنه باز می‌شدند و اسکریپتشان همان‌جا اجرا می‌شد. */
const OK_TYPE = /^(image\/(png|jpeg|webp|gif|heic|heif)|application\/pdf|text\/plain|application\/(zip|x-zip-compressed|vnd\.openxmlformats-officedocument\.[a-z.]+|msword|vnd\.ms-excel))$/i;

const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();
const run = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).run();

let ready = false;
export async function ensureFiles(env) {
  if (ready) return;
  await env.DB.batch([
    env.DB.prepare(`CREATE TABLE IF NOT EXISTS attachments (
      id      TEXT PRIMARY KEY,
      planner TEXT NOT NULL,
      ref     TEXT NOT NULL,
      name    TEXT NOT NULL DEFAULT '',
      type    TEXT NOT NULL DEFAULT '',
      size    INTEGER NOT NULL DEFAULT 0,
      blob    TEXT,
      created INTEGER NOT NULL DEFAULT 0
    )`),
    env.DB.prepare('CREATE INDEX IF NOT EXISTS attachments_ref ON attachments(planner, ref)')
  ]);
  ready = true;
}

const rid = () => {
  const a = new Uint8Array(12);
  crypto.getRandomValues(a);
  return [...a].map(x => x.toString(16).padStart(2, '0')).join('');
};

/* base64 → بایت، و برعکس. بی‌کتابخانه، چون هم ورکر و هم نود همین دو
   تابع را دارند. */
function fromB64(s) {
  const bin = atob(String(s || '').replace(/^data:[^,]*,/, ''));
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}
function toB64(bytes) {
  let s = '';
  for (let i = 0; i < bytes.length; i++) s += String.fromCharCode(bytes[i]);
  return btoa(s);
}

export async function listFiles(env, planner, ref) {
  await ensureFiles(env);
  return await all(env,
    'SELECT id,name,type,size,created FROM attachments WHERE planner=? AND ref=? ORDER BY created',
    planner, String(ref || ''));
}

export async function filesOfPlanner(env, planner) {
  await ensureFiles(env);
  return await all(env,
    'SELECT ref, COUNT(*) AS n FROM attachments WHERE planner=? GROUP BY ref', planner);
}

/* نامِ پیوست‌ها، برای جست‌وجوی سراسری. فقط نام و شناسهٔ ردیف —
   خودِ فایل این‌جا جایی ندارد. */
export async function fileNames(env, planner) {
  await ensureFiles(env);
  return await all(env,
    'SELECT id, ref, name FROM attachments WHERE planner=? ORDER BY created DESC LIMIT 500', planner);
}

export async function usedBytes(env, planner) {
  await ensureFiles(env);
  const r = await one(env, 'SELECT COALESCE(SUM(size),0) AS s FROM attachments WHERE planner=?', planner);
  return Number((r && r.s) || 0);
}

export async function putFile(env, planner, { ref, name, type, data }) {
  await ensureFiles(env);
  const bytes = fromB64(data);
  if (!bytes.length) return { error: 'فایلی نیامد.' };
  if (bytes.length > MAX_FILE)
    return { error: 'هر فایل تا ' + Math.round(MAX_FILE / 1048576) + ' مگابایت.' };
  const kind = String(type || '').split(';')[0].trim();
  if (!OK_TYPE.test(kind)) return { error: 'این نوع فایل پذیرفته نمی‌شود: ' + (kind || 'ناشناس') };
  const used = await usedBytes(env, planner);
  if (used + bytes.length > QUOTA)
    return { error: 'جای پیوست‌های این کارتابل پر است (' + Math.round(QUOTA / 1048576) + ' مگابایت).' };

  const id = rid();
  /* نامِ فایل فقط برای نشان دادن و دانلود است؛ مسیر از آن ساخته
     نمی‌شود. باز هم پاک می‌شود تا در هیچ هدری چیزی نشکند. */
  const safe = String(name || 'file').replace(/[\\/\r\n"]+/g, '_').slice(0, 120);
  let stored = null;
  if (env.FILES && env.FILES.put) await env.FILES.put(id, bytes);
  else stored = toB64(bytes);
  await run(env,
    'INSERT INTO attachments(id,planner,ref,name,type,size,blob,created) VALUES(?,?,?,?,?,?,?,?)',
    id, planner, String(ref || ''), safe, kind, bytes.length, stored, Date.now());
  return { ok: true, file: { id, name: safe, type: kind, size: bytes.length, created: Date.now() } };
}

export async function getFile(env, planner, id) {
  await ensureFiles(env);
  const row = await one(env, 'SELECT * FROM attachments WHERE id=? AND planner=?', String(id || ''), planner);
  if (!row) return null;
  let bytes = null;
  if (env.FILES && env.FILES.get) bytes = await env.FILES.get(row.id);
  else if (row.blob) bytes = fromB64(row.blob);
  if (!bytes) return null;
  return { bytes, name: row.name, type: row.type, size: row.size };
}

export async function delFile(env, planner, id) {
  await ensureFiles(env);
  const row = await one(env, 'SELECT id FROM attachments WHERE id=? AND planner=?', String(id || ''), planner);
  if (!row) return { error: 'پیدا نشد.', status: 404 };
  if (env.FILES && env.FILES.del) await env.FILES.del(row.id).catch(() => {});
  await run(env, 'DELETE FROM attachments WHERE id=?', row.id);
  return { ok: true };
}

/* وقتی کارتابلی پاک می‌شود، پیوست‌هایش هم باید بروند — وگرنه بایتش
   روی دیسک می‌ماند و هیچ‌کس دیگر نمی‌داند مالِ چه بوده. */
export async function dropPlannerFiles(env, planner) {
  await ensureFiles(env);
  const rows = await all(env, 'SELECT id FROM attachments WHERE planner=?', planner);
  if (env.FILES && env.FILES.del)
    for (const r of rows) await env.FILES.del(r.id).catch(() => {});
  await run(env, 'DELETE FROM attachments WHERE planner=?', planner);
  return rows.length;
}
