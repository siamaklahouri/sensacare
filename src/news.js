/* ==================== خبرِ تغییرها ====================
   هر بخشِ تازه‌ای که به کارتابل اضافه می‌شد، تا وقتی کسی اتفاقی
   نمی‌دیدش کشف نمی‌شد. آدم‌ها هم که معمولاً نوارِ کنار را از بالا تا
   پایین نمی‌خوانند؛ کارشان را می‌کنند و می‌روند.

   حالا هر تغییر یک خبر است. ولی خبر خودش نمی‌رود:

   یک) متنِ خبر همین‌جا در کد می‌نشیند (RELEASES) و با هر استقرار، هر
   کدام که تازه باشد به‌شکلِ «پیش‌نویس» در پنلِ ادمین ظاهر می‌شود. پس
   هیچ خبری بی‌آنکه آدمی دیده باشدش به کسی نمی‌رسد.

   دو) ادمین می‌تواند متنش را عوض کند، یا خبرِ از خودش بنویسد، و تا
   «ارسال به همه» را نزند هیچ کاربری نمی‌بیندش. این همان چیزی است که
   خواسته شده بود: اول پنلِ ادمین، بعد بقیه.

   سه) فرستادن یعنی «در کارتابلشان دیده شود» — زنگوله و یک پنجرهٔ
   «تازه چه خبر؟». اعلانِ گوشی جداست و تیکِ خودش را دارد: هر تغییرِ
   کوچکی ارزشِ لرزاندنِ گوشیِ کسی را ندارد. */

const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();
const run = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).run();

/* ---------- خودِ تغییرها ----------
   تازه‌ترین بالا. «ver» شناسه است و باید یکتا بماند: اگر عوضش کنید،
   همان خبر دوباره به‌شکلِ پیش‌نویس برمی‌گردد. */
export const RELEASES = [
  { ver: '1405.07-cal', icon: '📆', title: 'تقویم آمد',
    body: 'یک بخشِ تازه در نوارِ کنار: کارهای هر روز روی تقویمِ ماه، تعطیلی‌ها به‌رنگ، ' +
          'و برای هر روز می‌شود یادداشت گذاشت. هر ماه هم رنگِ خودش را دارد.' },
  { ver: '1405.07-remind', icon: '🔔', title: 'یادآور، حتی وقتی برنامه بسته است',
    body: 'تا حالا یادآورها فقط وقتی می‌آمدند که کارتابل باز بود. حالا از ' +
          '«تنظیمات ← یادآور» که روشنش کنید، مهلت‌ها و یادآورها به گوشی‌تان می‌رسند.' },
  { ver: '1405.07-files', icon: '📎', title: 'پیوستِ فایل سرِ هر ردیف',
    body: 'عکسِ فاکتور، رسید یا هر فایلی را می‌شود به خودِ ردیفِ چک‌لیست یا برنامهٔ روزانه چسباند.' },
  { ver: '1405.07-find', icon: '🔍', title: 'جست‌وجوی سراسری',
    body: 'با Ctrl+K یا ذره‌بینِ نوارِ بالا، بینِ همهٔ ماه‌ها و جدول‌ها بگردید.' },
  { ver: '1405.07-repeat', icon: '🔁', title: 'وظیفه‌های تکرارشونده',
    body: 'ستونِ 🔁 در چک‌لیست: هر وظیفه‌ای که تیک داشته باشد، ماهِ بعد خودش می‌آید.' }
];

let ready = false;
export async function ensureNews(env) {
  if (ready) return;
  await env.DB.batch([
    env.DB.prepare(`CREATE TABLE IF NOT EXISTS news (
      id      TEXT PRIMARY KEY,
      ver     TEXT NOT NULL DEFAULT '',
      icon    TEXT NOT NULL DEFAULT '',
      title   TEXT NOT NULL DEFAULT '',
      body    TEXT NOT NULL DEFAULT '',
      created INTEGER NOT NULL DEFAULT 0,
      status  TEXT NOT NULL DEFAULT 'draft',
      sent_at INTEGER NOT NULL DEFAULT 0
    )`),
    env.DB.prepare('CREATE INDEX IF NOT EXISTS news_status ON news(status, sent_at)')
  ]);
  ready = true;
  /* تغییرهای تازه، به‌شکلِ پیش‌نویس. ترتیب برعکس می‌رود تا تازه‌ترین
     بزرگ‌ترین created را بگیرد و بالای فهرست بنشیند. */
  const now = Date.now();
  for (let i = RELEASES.length - 1; i >= 0; i--) {
    const r = RELEASES[i];
    const id = 'rel:' + r.ver;
    const has = await one(env, 'SELECT id FROM news WHERE id=?', id);
    if (has) continue;
    await run(env,
      'INSERT INTO news(id,ver,icon,title,body,created,status,sent_at) VALUES(?,?,?,?,?,?,?,0)',
      id, r.ver, r.icon || '', r.title || '', r.body || '',
      now - i * 1000, 'draft');
  }
}

const clean = (s, n) => String(s == null ? '' : s).replace(/\s+/g, ' ').trim().slice(0, n);

export async function listNews(env) {
  await ensureNews(env);
  return await all(env,
    'SELECT id,ver,icon,title,body,created,status,sent_at FROM news ORDER BY created DESC LIMIT 60');
}

export async function saveNews(env, id, data) {
  await ensureNews(env);
  const title = clean(data.title, 90);
  const bodyT = clean(data.body, 700);
  if (!title) return { error: 'عنوان لازم است.' };
  if (id) {
    const row = await one(env, 'SELECT id FROM news WHERE id=?', id);
    if (!row) return { error: 'این خبر پیدا نشد.' };
    await run(env, 'UPDATE news SET icon=?, title=?, body=? WHERE id=?',
      clean(data.icon, 8), title, bodyT, id);
    return { ok: true, id };
  }
  const nid = 'own:' + Math.random().toString(36).slice(2, 10) + Date.now().toString(36);
  await run(env,
    'INSERT INTO news(id,ver,icon,title,body,created,status,sent_at) VALUES(?,?,?,?,?,?,?,0)',
    nid, '', clean(data.icon, 8) || '📣', title, bodyT, Date.now(), 'draft');
  return { ok: true, id: nid, created: true };
}

/* فرستادن فقط وضعیت را عوض می‌کند. از همین لحظه کارتابل‌ها خبر را
   می‌بینند — نه زودتر. */
export async function publishNews(env, id) {
  await ensureNews(env);
  const row = await one(env, 'SELECT id,status FROM news WHERE id=?', id);
  if (!row) return { error: 'این خبر پیدا نشد.' };
  if (row.status === 'sent') return { ok: true, already: true };
  await run(env, "UPDATE news SET status='sent', sent_at=? WHERE id=?", Date.now(), id);
  return { ok: true };
}

/* پس گرفتن: خبر از کارتابل‌ها برمی‌گردد به پیش‌نویس. آن‌هایی که
   دیده‌اندش دیگر نمی‌بینند، ولی جلوی بقیه گرفته می‌شود. */
export async function unpublishNews(env, id) {
  await ensureNews(env);
  await run(env, "UPDATE news SET status='draft', sent_at=0 WHERE id=?", id);
  return { ok: true };
}

export async function dropNews(env, id) {
  await ensureNews(env);
  await run(env, 'DELETE FROM news WHERE id=?', id);
  return { ok: true };
}

/* آنچه یک کارتابل می‌بیند: فقط فرستاده‌شده‌ها، تازه‌ترین بالا. */
export async function newsFor(env) {
  await ensureNews(env);
  return await all(env,
    "SELECT id,icon,title,body,sent_at FROM news WHERE status='sent' ORDER BY sent_at DESC LIMIT 12");
}
