/* گروه‌های سازمانی — شرکت، بخش، زیربخش
   =================================================================
   تا حالا بخشِ مشترک فهرستی از اسم‌ها بود: برای هر جدول باید تک‌تک
   کارتابل‌ها را تیک می‌زدید، و اگر کسی می‌آمد یا می‌رفت باید همهٔ
   جدول‌ها را دستی می‌گشتید.

   گروه همان فهرست است، ولی یک بار. «احیا › مالی» را یک جا تعریف
   می‌کنید و جدول‌ها به آن وصل می‌شوند؛ بعد هر کس را به مالی اضافه
   کنید، همان لحظه همهٔ جدول‌های مالی را می‌گیرد و هر کس را بردارید،
   دستش از همه‌شان کوتاه می‌شود.

   ارث‌بری عمداً نیست: عضوِ «احیا» جدول‌های «مالی» را نمی‌بیند مگر
   عضوِ مالی هم باشد. ارث‌بری اولش راحت به نظر می‌رسد ولی بعدِ سه لایه
   هیچ‌کس نمی‌تواند بگوید چه کسی چه چیزی را می‌بیند — و دسترسی‌ای که
   معلوم نباشد، دسترسیِ درستی نیست.

   مثل shared.js عمداً از kartabl.js چیزی وارد نمی‌شود تا حلقهٔ import
   درست نشود. */

const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();
const run = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).run();

let ready = false;
export async function ensureOrgs(env) {
  if (ready) return;
  try {
    /* سه دستور در یک رفت‌وبرگشت. هر «IF NOT EXISTS» است، پس هیچ‌کدام
       خطا نمی‌دهد و دسته‌ای فرستادنشان بی‌خطر است. */
    await env.DB.batch([
      env.DB.prepare(`CREATE TABLE IF NOT EXISTS orgs (
        id      TEXT PRIMARY KEY,
        name    TEXT NOT NULL DEFAULT '',
        parent  TEXT NOT NULL DEFAULT '',
        created INTEGER NOT NULL DEFAULT 0
      )`),
      env.DB.prepare(`CREATE TABLE IF NOT EXISTS org_members (
        org  TEXT NOT NULL,
        slug TEXT NOT NULL,
        PRIMARY KEY (org, slug)
      )`),
      env.DB.prepare('CREATE INDEX IF NOT EXISTS org_members_slug ON org_members(slug)'),
      /* مدیرِ گروه، جدا از اعضا. یک ستونِ mgr روی خودِ گروه هم می‌شد،
         ولی گروه می‌تواند بیش از یک مدیر داشته باشد و آن وقت یک رشتهٔ
         JSON می‌شد که نمی‌شود روی آن پرسش زد. */
      env.DB.prepare(`CREATE TABLE IF NOT EXISTS org_mgrs (
        org  TEXT NOT NULL,
        slug TEXT NOT NULL,
        PRIMARY KEY (org, slug)
      )`),
      env.DB.prepare('CREATE INDEX IF NOT EXISTS org_mgrs_slug ON org_mgrs(slug)')
    ]);
    ready = true;
  } catch (e) { /* مسیرها خودشان خطا می‌دهند */ }
}

/* شکلِ شناسهٔ گروه یک جا تعریف می‌شود. سه‌جا نوشتنش یعنی یک روز یکی‌شان
   عوض می‌شود و آن دو تا نه. */
export const ORG_ID_RE = /^[a-z0-9]{6,16}$/;
export const isOrgId = x => ORG_ID_RE.test(String(x || ''));
const ID_RE = ORG_ID_RE;
const newId = () => {
  const a = 'abcdefghijklmnopqrstuvwxyz0123456789';
  const b = crypto.getRandomValues(new Uint8Array(10));
  let s = '';
  for (const x of b) s += a[x % a.length];
  return s;
};

/* ---------- خواندن ---------- */

/* همهٔ گروه‌ها با اعضاشان. فهرست کوچک است (چند ده تا)، پس یک‌جا خوانده
   می‌شود و درخت در حافظه ساخته می‌شود — نه یک پرسش برای هر گره. */
export async function orgList(env) {
  await ensureOrgs(env);
  const [rows, mem, mgr] = await Promise.all([
    all(env, 'SELECT * FROM orgs ORDER BY created, id'),
    all(env, 'SELECT org, slug FROM org_members'),
    all(env, 'SELECT org, slug FROM org_mgrs').catch(() => [])
  ]);
  const byOrg = {}, mgrOf = {};
  for (const m of mem) (byOrg[m.org] = byOrg[m.org] || []).push(m.slug);
  for (const m of mgr) (mgrOf[m.org] = mgrOf[m.org] || []).push(m.slug);
  return rows.map(r => ({ id: r.id, name: r.name, parent: r.parent || '',
                          created: r.created, members: byOrg[r.id] || [],
                          mgrs: mgrOf[r.id] || [] }));
}

/* «احیا › مالی» — چیزی که در نوار کنارِ کارتابل دیده می‌شود. اگر حلقه‌ای
   در پدرها بود (که نباید باشد) هم این‌جا بی‌نهایت نمی‌چرخد. */
export function pathOf(list, id) {
  const by = {};
  for (const o of list) by[o.id] = o;
  const out = [];
  let cur = by[id], guard = 0;
  while (cur && guard++ < 20) { out.unshift(cur.name); cur = cur.parent ? by[cur.parent] : null; }
  return out.join(' › ');
}

export async function orgsOf(env, slug) {
  await ensureOrgs(env);
  const rows = await all(env, 'SELECT org FROM org_members WHERE slug=?', String(slug || ''));
  return rows.map(r => r.org);
}

export async function orgById(env, id) {
  await ensureOrgs(env);
  return await one(env, 'SELECT * FROM orgs WHERE id=?', String(id || ''));
}

/* پاک کردنِ فهرستِ نامِ کارتابل‌ها: خالی‌ها بیرون، تکراری‌ها یکی، و
   فقط آن‌هایی که واقعاً وجود دارند. سه جا همین کار را می‌کرد (اعضای
   بخش، مدیرها، اعضای گروه) و هر سه کپیِ هم بودند. */
export function cleanSlugs(list, known, max) {
  return (Array.isArray(list) ? list : [])
    .map(x => String(x || '').trim().toLowerCase())
    .filter((x, i, a) => x && a.indexOf(x) === i && known.includes(x))
    .slice(0, max);
}

export async function mgrsOf(env, id) {
  await ensureOrgs(env);
  try {
    const rows = await all(env, 'SELECT slug FROM org_mgrs WHERE org=?', String(id || ''));
    return rows.map(r => r.slug);
  } catch (e) { return []; }
}

export async function membersOf(env, id) {
  await ensureOrgs(env);
  const rows = await all(env, 'SELECT slug FROM org_members WHERE org=?', String(id || ''));
  return rows.map(r => r.slug);
}

/* ---------- نوشتن ---------- */
export async function saveOrg(env, body, knownSlugs) {
  await ensureOrgs(env);
  const name = String(body.name || '').trim().slice(0, 60);
  if (!name) return { error: 'یک نام بنویسید.' };

  const id = String(body.id || '').trim();
  const isNew = !id;
  if (!isNew && !ID_RE.test(id)) return { error: 'شناسهٔ گروه درست نیست.' };

  const parent = String(body.parent || '').trim();
  if (parent && !ID_RE.test(parent)) return { error: 'گروهِ بالادست درست نیست.' };
  if (parent && parent === id) return { error: 'یک گروه نمی‌تواند زیرمجموعهٔ خودش باشد.' };

  const list = await orgList(env);
  const by = {};
  for (const o of list) by[o.id] = o;
  if (parent && !by[parent]) return { error: 'گروهِ بالادست پیدا نشد.' };
  if (!isNew && !by[id]) return { error: 'این گروه دیگر نیست.' };

  /* جابه‌جایی نباید حلقه بسازد: اگر پدرِ تازه خودش جایی زیرِ همین گروه
     باشد، درخت به خودش برمی‌گردد و هیچ مسیری به ریشه نمی‌رسد. */
  if (!isNew && parent) {
    let cur = by[parent], guard = 0;
    while (cur && guard++ < 50) {
      if (cur.id === id) return { error: 'این گروه بالای همان گروهی است که می‌خواهید زیرش ببرید.' };
      cur = cur.parent ? by[cur.parent] : null;
    }
  }

  const members = cleanSlugs(body.members, knownSlugs, 200);
  /* مدیر باید خودش عضو باشد؛ مدیری که گروه را نمی‌بیند مدیرِ چیزی
     نیست و فقط یک اسمِ گمراه‌کننده در تنظیمات می‌ماند. */
  const mgrs = cleanSlugs(body.mgrs, members, 10);

  const oid = isNew ? newId() : id;

  /* اعضا از نو نوشته می‌شوند. تفاضل گرفتن کوتاه‌تر بود ولی اگر وسطش
     چیزی می‌شکست، گروه نیمه‌عضو می‌ماند.
     همه در یک دسته می‌روند: یک ردیف‌به‌ردیف INSERT یعنی برای بخشی با
     سی نفر، سی‌ویک رفت‌وبرگشت پشتِ هم به دیتابیس. */
  const stmts = [
    env.DB.prepare(
      `INSERT INTO orgs(id,name,parent,created) VALUES(?,?,?,?)
       ON CONFLICT(id) DO UPDATE SET name=excluded.name, parent=excluded.parent`
    ).bind(oid, name, parent, Date.now()),
    env.DB.prepare('DELETE FROM org_members WHERE org=?').bind(oid),
    env.DB.prepare('DELETE FROM org_mgrs WHERE org=?').bind(oid)
  ];
  const fill = (table, list) => {
    if (!list.length) return;
    stmts.push(env.DB.prepare(
      'INSERT OR IGNORE INTO ' + table + '(org,slug) VALUES ' +
      list.map(() => '(?,?)').join(',')
    ).bind(...list.flatMap(m => [oid, m])));
  };
  fill('org_members', members);
  fill('org_mgrs', mgrs);
  await env.DB.batch(stmts);

  return { ok: true, id: oid, created: isNew };
}

/* گروهی که زیرمجموعه یا جدول دارد پاک نمی‌شود. می‌شد زیرمجموعه‌ها را
   بالا کشید و جدول‌ها را بی‌صاحب کرد، ولی آن وقت یک کلیک، دسترسیِ چند
   نفر را بی‌صدا عوض می‌کرد. */
export async function dropOrg(env, id) {
  await ensureOrgs(env);
  const oid = String(id || '');
  /* هر دو نگهبان هم‌شکل‌اند و خودشان می‌پرسند. قبلاً فهرستِ بخش‌ها را
     صدازننده باید آماده می‌کرد — یعنی برای یک جوابِ بله/خیر، همهٔ
     بخش‌ها و کلِ درختِ سازمان خوانده می‌شد. */
  const [kid, box] = await Promise.all([
    one(env, 'SELECT id FROM orgs WHERE parent=?', oid),
    one(env, "SELECT id FROM shared_boxes WHERE org=? LIMIT 1", oid).catch(() => null)
  ]);
  if (kid) return { error: 'این گروه زیرمجموعه دارد. اول آن‌ها را جابه‌جا یا پاک کنید.' };
  if (box) return { error: 'یک بخشِ مشترک به این گروه وصل است. اول آن را جدا کنید.' };
  await env.DB.batch([
    env.DB.prepare('DELETE FROM org_members WHERE org=?').bind(oid),
    env.DB.prepare('DELETE FROM org_mgrs WHERE org=?').bind(oid),
    env.DB.prepare('DELETE FROM orgs WHERE id=?').bind(oid)
  ]);
  return { ok: true };
}
