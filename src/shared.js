/* بخش‌های مشترک بین چند کارتابل
   =================================================================
   تا حالا دادهٔ هر کارتابل مالِ خودش بود: دو تکه JSON در جدول kartabl
   که با شمارهٔ نسخه نوشته می‌شدند. این‌جا چیزِ سومی اضافه می‌شود —
   جدول‌هایی که چند کارتابل با هم دارند و هر کدام می‌توانند عوضش کنند.

   چرا ردیف‌به‌ردیف، نه یک تکهٔ JSON مثل بقیه؟
   چون بقیهٔ داده‌ها یک صاحب دارند و «آخرین نوشته برنده» مشکلی نمی‌سازد.
   این‌جا دو نفر هم‌زمان باز کرده‌اند؛ اگر کلِ جدول را بفرستند، آن‌که
   دیرتر ذخیره کرده کارِ اولی را پاک می‌کند. پس هر ردیف یک سطر است و
   هر کس فقط سطرِ خودش را می‌نویسد.

   حذف هم «نرم» است (ستون dead): اگر ردیف را واقعاً پاک کنیم، مرورگرِ
   آن یکی که هر چند ثانیه «چه چیزی عوض شده؟» می‌پرسد هیچ‌وقت نمی‌فهمد
   ردیف رفته و تا وقتی صفحه را نبندد نشانش می‌دهد.

   «دیتای شخصی» عمداً این‌جا نیست: محتوایش با کلیدِ خودِ کاربر در
   مرورگر رمز می‌شود و سرور فقط متنِ رمزشده را می‌بیند. مشترک کردنش
   یعنی پخش کردنِ کلید بین چند نفر، که کلِ آن لایه را بی‌معنی می‌کند. */

/* عمداً از kartabl.js چیزی وارد نمی‌شود: آن فایل خودش این‌جا را وارد
   می‌کند و حلقهٔ import، هرچند در ESM معمولاً کار می‌کند، یک روز سرِ
   ترتیبِ ارزیابی ما را زمین می‌زند. سه خطِ زیر همان سه‌تاست. */
const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();
const run = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).run();

/* ---------- انواعِ جدول ----------
   هر نوع یک فهرست ستون دارد. «kind» شکلِ خانه را می‌گوید:
     text  یک خطی | long متنِ بلند | num عدد | money مبلغ (تومان)
     date  تاریخ شمسی به شکل ۱۴۰۴/۰۷/۰۱ | pick فهرستِ بسته
   عرضِ ستون‌ها را صفحه از همین‌جا می‌گیرد، نه از CSS. */
export const SHARED_TYPES = [
  { id: 'companies', label: 'شرکت‌ها', icon: '🏢', cols: [
    { k: 'name',  t: 'نام شرکت',    kind: 'text', w: 170 },
    { k: 'person',t: 'رابط',        kind: 'text', w: 130 },
    { k: 'phone', t: 'تلفن',        kind: 'text', w: 120, ltr: true },
    { k: 'addr',  t: 'نشانی',       kind: 'text', w: 200 },
    { k: 'note',  t: 'یادداشت',     kind: 'long' }
  ]},
  { id: 'servers', label: 'سرورها', icon: '🖥️', cols: [
    { k: 'name', t: 'نام سرور', kind: 'text', w: 150 },
    { k: 'ip',   t: 'آدرس',     kind: 'text', w: 130, ltr: true },
    { k: 'role', t: 'نقش',      kind: 'text', w: 130 },
    { k: 'stat', t: 'وضعیت',    kind: 'pick', w: 110, opts: ['فعال', 'خاموش', 'در حال کار'] },
    { k: 'note', t: 'یادداشت',  kind: 'long' }
  ]},
  { id: 'mvpn', label: 'خطوط MVPN', icon: '📱', cols: [
    { k: 'line',  t: 'شماره خط', kind: 'text', w: 130, ltr: true },
    { k: 'co',    t: 'شرکت',     kind: 'text', w: 160 },
    { k: 'stage', t: 'مرحله',    kind: 'pick', w: 130, opts: ['درخواست', 'در جریان', 'فعال', 'لغو'] },
    { k: 'date',  t: 'تاریخ',    kind: 'date', w: 120 },
    { k: 'note',  t: 'یادداشت',  kind: 'long' }
  ]},
  { id: 'tasks', label: 'کارها و چک‌لیست', icon: '✅', cols: [
    { k: 'task', t: 'کار',       kind: 'text', w: 220 },
    { k: 'cat',  t: 'دسته',      kind: 'text', w: 130 },
    { k: 'who',  t: 'مسئول',     kind: 'text', w: 120 },
    { k: 'due',  t: 'مهلت',      kind: 'date', w: 120 },
    { k: 'stat', t: 'وضعیت',     kind: 'pick', w: 120, opts: ['انجام نشده', 'در حال انجام', 'انجام شد'] },
    { k: 'pri',  t: 'اولویت',    kind: 'pick', w: 100, opts: ['بالا', 'متوسط', 'پایین'] },
    { k: 'note', t: 'یادداشت',   kind: 'long' }
  ]},
  { id: 'invoices', label: 'فاکتورها', icon: '🧾', cols: [
    { k: 'no',   t: 'شماره',      kind: 'text',  w: 110, ltr: true },
    { k: 'who',  t: 'مشتری',      kind: 'text',  w: 170 },
    { k: 'date', t: 'تاریخ',      kind: 'date',  w: 115 },
    { k: 'due',  t: 'سررسید',     kind: 'date',  w: 115 },
    { k: 'amt',  t: 'مبلغ',       kind: 'money', w: 130 },
    { k: 'paid', t: 'پرداخت‌شده', kind: 'money', w: 130 },
    { k: 'stat', t: 'وضعیت',      kind: 'pick',  w: 120, opts: ['باز', 'نیمه', 'تسویه', 'معوق'] }
  ]},
  { id: 'payables', label: 'بدهی‌ها و پرداخت‌ها', icon: '💳', cols: [
    { k: 'who',  t: 'تأمین‌کننده', kind: 'text',  w: 170 },
    { k: 'what', t: 'بابت',        kind: 'text',  w: 190 },
    { k: 'due',  t: 'سررسید',      kind: 'date',  w: 115 },
    { k: 'amt',  t: 'مبلغ',        kind: 'money', w: 130 },
    { k: 'stat', t: 'وضعیت',       kind: 'pick',  w: 120, opts: ['باز', 'نیمه', 'تسویه', 'معوق'] }
  ]},
  { id: 'expenses', label: 'هزینه‌ها', icon: '🧮', cols: [
    { k: 'date', t: 'تاریخ',   kind: 'date',  w: 115 },
    { k: 'cat',  t: 'دسته',    kind: 'text',  w: 140 },
    { k: 'what', t: 'شرح',     kind: 'text',  w: 220 },
    { k: 'amt',  t: 'مبلغ',    kind: 'money', w: 130 }
  ]},
  { id: 'banks', label: 'حساب‌های بانکی', icon: '🏦', cols: [
    { k: 'bank', t: 'بانک',       kind: 'text',  w: 150 },
    { k: 'no',   t: 'شماره حساب', kind: 'text',  w: 180, ltr: true },
    { k: 'bal',  t: 'موجودی',     kind: 'money', w: 140 },
    { k: 'note', t: 'یادداشت',    kind: 'long' }
  ]},
  { id: 'contacts', label: 'طرف‌حساب‌ها', icon: '👥', cols: [
    { k: 'name',  t: 'نام',     kind: 'text', w: 170 },
    { k: 'role',  t: 'نسبت',    kind: 'text', w: 130 },
    { k: 'phone', t: 'تلفن',    kind: 'text', w: 130, ltr: true },
    { k: 'mail',  t: 'ایمیل',   kind: 'text', w: 170, ltr: true },
    { k: 'note',  t: 'یادداشت', kind: 'long' }
  ]},
  { id: 'notes', label: 'یادداشت‌های مشترک', icon: '📝', cols: [
    { k: 'title', t: 'موضوع', kind: 'text', w: 200 },
    { k: 'body',  t: 'متن',   kind: 'long' },
    { k: 'stat',  t: 'وضعیت', kind: 'pick', w: 120, opts: ['باز', 'بسته'] }
  ]}
];

export const typeById = id => SHARED_TYPES.find(t => t.id === id) || null;

/* ---------- ساختِ جدول‌ها ----------
   در migrations هم هست؛ این‌جا هم می‌ماند تا اگر روی یک دیتابیسِ
   قدیمی‌تر اجرا شد، اولین درخواست خودش راه بیندازدش. */
let ready = false;
export async function ensureShared(env) {
  if (ready) return;
  try {
    await run(env, `CREATE TABLE IF NOT EXISTS shared_boxes (
      id      TEXT PRIMARY KEY,
      title   TEXT NOT NULL DEFAULT '',
      type    TEXT NOT NULL DEFAULT 'notes',
      members TEXT NOT NULL DEFAULT '[]',
      created INTEGER NOT NULL DEFAULT 0
    )`);
    await run(env, `CREATE TABLE IF NOT EXISTS shared_rows (
      box     TEXT NOT NULL,
      rid     TEXT NOT NULL,
      v       TEXT NOT NULL DEFAULT '{}',
      updated INTEGER NOT NULL DEFAULT 0,
      by      TEXT NOT NULL DEFAULT '',
      dead    INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (box, rid)
    )`);
    await run(env, 'CREATE INDEX IF NOT EXISTS shared_rows_box_upd ON shared_rows(box, updated)');
    ready = true;
  } catch (e) { /* اگر ساخته نشد، مسیرها خودشان خطا می‌دهند */ }
}

const parseMembers = s => { try { const a = JSON.parse(s); return Array.isArray(a) ? a : []; } catch { return []; } };

const shapeBox = r => {
  const t = typeById(r.type);
  return { id: r.id, title: r.title, type: r.type,
           label: t ? t.label : r.type, icon: t ? t.icon : '📋',
           cols: t ? t.cols : [], members: parseMembers(r.members), created: r.created };
};

/* ---------- خواندن ---------- */
export async function boxesFor(env, slug) {
  await ensureShared(env);
  const rows = await all(env, 'SELECT * FROM shared_boxes ORDER BY created, id');
  return rows.map(shapeBox).filter(b => b.members.includes(slug));
}

export async function allBoxes(env) {
  await ensureShared(env);
  return (await all(env, 'SELECT * FROM shared_boxes ORDER BY created, id')).map(shapeBox);
}

export async function getBox(env, id) {
  await ensureShared(env);
  const r = await one(env, 'SELECT * FROM shared_boxes WHERE id=?', String(id || ''));
  return r ? shapeBox(r) : null;
}

/* «since» یعنی: از این لحظه به بعد چه چیزی عوض شده؟ صفحه همین را هر
   چند ثانیه می‌پرسد، پس جوابش معمولاً خالی است و ارزان تمام می‌شود.
   ردیف‌های حذف‌شده هم می‌آیند (با dead=1) تا آن طرف بداند بردارد. */
export async function rowsSince(env, boxId, since = 0) {
  await ensureShared(env);
  const rows = await all(env,
    'SELECT rid, v, updated, by, dead FROM shared_rows WHERE box=? AND updated>? ORDER BY updated',
    String(boxId), Number(since) || 0);
  return rows.map(r => {
    let v = {};
    try { v = JSON.parse(r.v) || {}; } catch { v = {}; }
    return { rid: r.rid, v, updated: r.updated, by: r.by, dead: !!r.dead };
  });
}

/* ---------- نوشتن ----------
   مقدارها همین‌جا تمیز می‌شوند، نه در مرورگر: فقط ستون‌هایی که این نوع
   دارد نگه داشته می‌شوند و هر خانه سقفِ طول دارد. پس اگر کسی مستقیم
   به API بزند هم چیزی بیرون از شکلِ جدول ننشیند. */
const MAX_CELL = 4000;
const MAX_ROWS = 2000;

export function cleanRow(type, v) {
  const t = typeById(type);
  if (!t) return {};
  const out = {};
  for (const c of t.cols) {
    let x = v && v[c.k];
    if (x === undefined || x === null) continue;
    if (c.kind === 'num' || c.kind === 'money') {
      const n = Number(String(x).replace(/[,٬\s]/g, ''));
      out[c.k] = Number.isFinite(n) ? n : 0;
    } else {
      out[c.k] = String(x).slice(0, c.kind === 'long' ? MAX_CELL : 300);
    }
  }
  return out;
}

const RID_RE = /^[a-z0-9]{6,32}$/;

export async function putRow(env, box, rid, v, by) {
  await ensureShared(env);
  const id = String(rid || '');
  if (!RID_RE.test(id)) return { error: 'شناسهٔ ردیف درست نیست.' };
  const clean = cleanRow(box.type, v);
  const now = Date.now();
  const exists = await one(env, 'SELECT rid FROM shared_rows WHERE box=? AND rid=?', box.id, id);
  if (!exists) {
    const n = await one(env, 'SELECT COUNT(*) AS n FROM shared_rows WHERE box=? AND dead=0', box.id);
    if ((n && n.n || 0) >= MAX_ROWS) return { error: 'این جدول پر شده است.' };
  }
  await run(env,
    `INSERT INTO shared_rows(box,rid,v,updated,by,dead) VALUES(?,?,?,?,?,0)
     ON CONFLICT(box,rid) DO UPDATE SET v=excluded.v, updated=excluded.updated,
                                        by=excluded.by, dead=0`,
    box.id, id, JSON.stringify(clean), now, String(by || '').slice(0, 40));
  return { ok: true, rid: id, updated: now, v: clean };
}

export async function killRow(env, box, rid, by) {
  await ensureShared(env);
  const id = String(rid || '');
  if (!RID_RE.test(id)) return { error: 'شناسهٔ ردیف درست نیست.' };
  const now = Date.now();
  await run(env,
    'UPDATE shared_rows SET dead=1, updated=?, by=? WHERE box=? AND rid=?',
    now, String(by || '').slice(0, 40), box.id, id);
  return { ok: true, rid: id, updated: now };
}

/* ---------- کارهای ادمین ---------- */
const BOX_ID_RE = /^[a-z0-9][a-z0-9-]{1,30}$/;

export async function saveBox(env, body, knownSlugs) {
  await ensureShared(env);
  const id = String(body.id || '').trim().toLowerCase();
  if (!BOX_ID_RE.test(id))
    return { error: 'شناسه فقط حروف کوچک انگلیسی، عدد و خط تیره — بین ۲ تا ۳۱ نویسه.' };
  const title = String(body.title || '').trim().slice(0, 60);
  if (!title) return { error: 'یک عنوان بنویسید.' };
  const type = String(body.type || '');
  if (!typeById(type)) return { error: 'این نوع جدول را نمی‌شناسم.' };

  /* فقط کارتابل‌هایی که واقعاً هستند؛ وگرنه فردا یک اسمِ غلط در
     فهرستِ اعضا می‌ماند و کسی نمی‌فهمد چرا آن یکی بخش را نمی‌بیند. */
  const members = (Array.isArray(body.members) ? body.members : [])
    .map(s => String(s || '').trim().toLowerCase())
    .filter((s, i, a) => s && a.indexOf(s) === i && knownSlugs.includes(s))
    .slice(0, 50);

  const cur = await one(env, 'SELECT id, type FROM shared_boxes WHERE id=?', id);
  /* عوض کردنِ نوعِ یک جدولِ پر یعنی ستون‌هایش دیگر نمی‌خوانند و داده
     بی‌صدا ناپدید می‌شود. جلویش گرفته می‌شود. */
  if (cur && cur.type !== type) {
    const n = await one(env, 'SELECT COUNT(*) AS n FROM shared_rows WHERE box=? AND dead=0', id);
    if (n && n.n > 0)
      return { error: 'این جدول داده دارد، پس نوعش عوض نمی‌شود. یک بخشِ تازه بسازید.' };
  }

  await run(env,
    `INSERT INTO shared_boxes(id,title,type,members,created) VALUES(?,?,?,?,?)
     ON CONFLICT(id) DO UPDATE SET title=excluded.title, type=excluded.type,
                                   members=excluded.members`,
    id, title, type, JSON.stringify(members), Date.now());
  return { ok: true, id, created: !cur };
}

export async function dropBox(env, id) {
  await ensureShared(env);
  const bid = String(id || '');
  await run(env, 'DELETE FROM shared_rows WHERE box=?', bid);
  await run(env, 'DELETE FROM shared_boxes WHERE id=?', bid);
  return { ok: true };
}

/* شمارِ ردیف‌های زندهٔ هر بخش — برای نشان دادن در پنل */
export async function boxCounts(env) {
  await ensureShared(env);
  try {
    const rows = await all(env,
      'SELECT box, COUNT(*) AS n FROM shared_rows WHERE dead=0 GROUP BY box');
    const out = {};
    for (const r of rows) out[r.box] = r.n;
    return out;
  } catch (e) { return {}; }
}
