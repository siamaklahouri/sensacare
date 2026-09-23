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
import { orgList, orgsOf, pathOf } from './orgs.js';

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
  /* «کارهای تیمی» با بقیهٔ جدول‌ها یک فرق بنیادی دارد: هر ستون صاحبِ
     خودش را دارد. متنِ کار دستِ کسی است که نوشته، مسئول و مهلت دستِ
     مدیر، و تاریخِ انجام دستِ همان کسی که باید انجامش بدهد. تاریخِ ثبت
     اصلاً ستونِ داده نیست — همان لحظه‌ای است که ردیف ساخته شده و
     سرور نگهش داشته، پس کسی نمی‌تواند عقب‌وجلویش کند. */
  { id: 'team', label: 'کارهای تیمی', icon: '🎯', cols: [
    { k: 'task', t: 'کار',         kind: 'text', w: 230, edit: 'owner' },
    { k: 'who',  t: 'مسئول',       kind: 'who',  w: 130, edit: 'mgr' },
    {            t: 'تاریخ ثبت',   kind: 'made', w: 110, edit: 'never' },
    { k: 'due',  t: 'مهلت',        kind: 'date', w: 115, edit: 'mgr' },
    { k: 'done', t: 'تاریخ انجام', kind: 'date', w: 115, edit: 'doer' },
    { k: 'stat', t: 'وضعیت',       kind: 'pick', w: 125, edit: 'doer',
      opts: ['انجام نشده', 'در حال انجام', 'انجام شد', 'متوقف'] },
    { k: 'note', t: 'یادداشت',     kind: 'long', edit: 'any' }
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
    /* ستون‌هایی که بعداً اضافه شدند. هر کدام جدا، چون روی دیتابیسی که
       یکی‌شان را دارد و آن یکی را ندارد نباید کلِ کار بخوابد. */
    for (const q of [
      "ALTER TABLE shared_boxes ADD COLUMN mgrs TEXT NOT NULL DEFAULT '[]'",
      /* پیش‌فرضِ ۰ عمدی است: بخش‌هایی که از قبل ساخته شده‌اند نباید یک
         روز صبح خودبه‌خود قفل شوند و کسی نفهمد چرا دیگر نمی‌تواند
         ردیفِ همکارش را درست کند. بخشِ تازه با کلیدِ روشن ساخته
         می‌شود؛ قدیمی‌ها را خودِ ادمین وقتی خواست روشن می‌کند. */
      'ALTER TABLE shared_boxes ADD COLUMN rowlock INTEGER NOT NULL DEFAULT 0',
      "ALTER TABLE shared_rows ADD COLUMN owner TEXT NOT NULL DEFAULT ''",
      'ALTER TABLE shared_rows ADD COLUMN created INTEGER NOT NULL DEFAULT 0',
      "ALTER TABLE shared_boxes ADD COLUMN org TEXT NOT NULL DEFAULT ''"
    ]) { try { await run(env, q); } catch (e) { /* از قبل هست */ } }
    ready = true;
  } catch (e) { /* اگر ساخته نشد، مسیرها خودشان خطا می‌دهند */ }
}

const parseMembers = s => { try { const a = JSON.parse(s); return Array.isArray(a) ? a : []; } catch { return []; } };

const shapeBox = r => {
  const t = typeById(r.type);
  return { id: r.id, title: r.title, type: r.type,
           label: t ? t.label : r.type, icon: t ? t.icon : '📋',
           cols: t ? t.cols : [], members: parseMembers(r.members),
           mgrs: parseMembers(r.mgrs), rowlock: Number(r.rowlock || 0),
           org: r.org || '', orgPath: '', created: r.created };
};

/* ---------- خواندن ----------
   بخشی که به گروه وصل است فهرستِ اعضای خودش را ندارد؛ اعضایش همان
   اعضای گروه‌اند. این‌جا جایگزین می‌شود تا بقیهٔ کد — قفل، مدیر، فهرستِ
   مسئول — فرقی بین این دو نبیند. */
async function withOrgs(env, boxes) {
  if (!boxes.some(b => b.org)) return boxes;
  const list = await orgList(env);
  const by = {};
  for (const o of list) by[o.id] = o;
  for (const b of boxes) {
    if (!b.org) continue;
    const o = by[b.org];
    /* گروهی که پاک شده: بخش بی‌عضو می‌ماند، نه اینکه ناگهان مالِ همه
       شود. ادمین در پنل می‌بیند که کسی نمی‌بیندش. */
    b.members = o ? o.members.slice() : [];
    b.orgPath = o ? pathOf(list, o.id) : '';
    b.mgrs = b.mgrs.filter(m => b.members.includes(m));
  }
  return boxes;
}

export async function boxesFor(env, slug) {
  await ensureShared(env);
  const rows = await all(env, 'SELECT * FROM shared_boxes ORDER BY created, id');
  const mine = await orgsOf(env, slug);
  const boxes = await withOrgs(env, rows.map(shapeBox));
  return withPeople(env, boxes.filter(b => b.org ? mine.includes(b.org) : b.members.includes(slug)));
}

/* ستونِ «مسئول» باید اسمِ آدم‌ها را نشان بدهد نه slug را. اسم‌ها یک بار
   خوانده می‌شوند، نه یک‌بار برای هر بخش. */
async function withPeople(env, boxes) {
  const need = [];
  for (const b of boxes) for (const m of b.members) if (!need.includes(m)) need.push(m);
  let names = {};
  if (need.length) {
    try {
      const rows = await all(env,
        `SELECT slug, name FROM planners WHERE slug IN (${need.map(() => '?').join(',')})`, ...need);
      for (const r of rows) names[r.slug] = r.name || r.slug;
    } catch (e) { names = {}; }
  }
  for (const b of boxes)
    b.people = b.members.map(m => ({ slug: m, name: names[m] || m }));
  return boxes;
}

export async function allBoxes(env) {
  await ensureShared(env);
  const rows = await all(env, 'SELECT * FROM shared_boxes ORDER BY created, id');
  return withOrgs(env, rows.map(shapeBox));
}

export async function getBox(env, id) {
  await ensureShared(env);
  const r = await one(env, 'SELECT * FROM shared_boxes WHERE id=?', String(id || ''));
  if (!r) return null;
  return (await withOrgs(env, [shapeBox(r)]))[0];
}

/* «since» یعنی: از این لحظه به بعد چه چیزی عوض شده؟ صفحه همین را هر
   چند ثانیه می‌پرسد، پس جوابش معمولاً خالی است و ارزان تمام می‌شود.
   ردیف‌های حذف‌شده هم می‌آیند (با dead=1) تا آن طرف بداند بردارد. */
export async function rowsSince(env, boxId, since = 0) {
  await ensureShared(env);
  const rows = await all(env,
    `SELECT rid, v, updated, by, dead, owner, created FROM shared_rows
      WHERE box=? AND updated>? ORDER BY updated`,
    String(boxId), Number(since) || 0);
  return rows.map(r => {
    let v = {};
    try { v = JSON.parse(r.v) || {}; } catch { v = {}; }
    /* ردیف‌های قدیمی صاحب ندارند؛ «آخرین کسی که دست زد» نزدیک‌ترین
       چیزی است که داریم و بهتر از بی‌صاحب گذاشتنشان است. */
    return { rid: r.rid, v, updated: r.updated, by: r.by, dead: !!r.dead,
             owner: r.owner || r.by || '', created: r.created || r.updated || 0 };
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
    if (!c.k) continue;          /* ستونِ نمایشی مثل «تاریخ ثبت» داده ندارد */
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

/* ---------- چه کسی چه ستونی را می‌تواند عوض کند ----------
   این‌جا روی سرور است، نه در صفحه. خانهٔ خاکستریِ مرورگر ادب است، قفل
   نیست: هر کسی می‌تواند مستقیم به API بزند. پس صفحه هم همین را نشان
   می‌دهد و سرور هم همین را اعمال می‌کند، و حرفِ آخر مالِ سرور است.

   قاعده‌ها:
     any    هر عضوی
     owner  فقط کسی که ردیف را ساخته
     mgr    فقط مدیرِ این بخش
     doer   فقط کسی که مسئولِ این کار است (تا وقتی مسئولی نیست، سازنده)
     never  هیچ‌کس — سرور خودش پرش می‌کند

   ستونی که قاعده ندارد از کلیدِ «قفلِ مالکیت»ِ خودِ بخش پیروی می‌کند:
   روشن یعنی فقط صاحبِ ردیف، خاموش یعنی هر عضوی. جدولِ سرورها قفل
   نمی‌خواهد، یادداشتِ مشترک می‌خواهد. */
const isMgr = (box, by) => !!by && (box.mgrs || []).includes(by);

export function canEdit(box, col, by, row) {
  const rule = col.edit || (box.rowlock ? 'owner' : 'any');
  if (rule === 'never') return false;
  if (rule === 'any') return true;
  /* مدیر بقیهٔ قفل‌ها را باز می‌کند — وگرنه اگر کسی شرکت را ترک کند،
     ردیف‌هایش برای همیشه دست‌نخوردنی می‌مانند. */
  if (isMgr(box, by)) return true;
  const owner = row && row.owner;
  if (rule === 'owner') return !owner || owner === by;
  if (rule === 'mgr') return false;
  if (rule === 'doer') {
    const who = row && row.v && row.v.who;
    return who ? who === by : (!owner || owner === by);
  }
  return false;
}

/* آنچه فرستاده شده با آنچه بود ادغام می‌شود: هر خانه‌ای که این آدم
   اجازه‌اش را ندارد، مقدارِ قبلی‌اش سرِ جایش می‌ماند. عمداً خطا
   نمی‌دهیم و کلِ ذخیره را رد نمی‌کنیم — وگرنه یک خانهٔ قفل، نوشتنِ
   خانه‌های مجاز را هم می‌خوابانَد. اسمِ خانه‌های ردشده برمی‌گردد تا
   صفحه بتواند بگوید چه چیزی نوشته نشد. */
function mergeRow(box, by, old, incoming) {
  const t = typeById(box.type);
  const clean = cleanRow(box.type, incoming);
  const out = {};
  const kept = [];
  for (const c of (t ? t.cols : [])) {
    if (!c.k) continue;
    const prev = old && old.v ? old.v[c.k] : undefined;
    const keep = () => { if (prev !== undefined) out[c.k] = prev; };
    if (!(c.k in clean)) { keep(); continue; }
    let x = clean[c.k];
    /* «مسئول» باید یکی از اعضای همین بخش باشد؛ وگرنه فردا یک اسمِ
       غریبه در ستون می‌ماند و هیچ‌کس نمی‌تواند آن ردیف را جلو ببرد. */
    if (c.kind === 'who' && x && !(box.members || []).includes(x)) { keep(); kept.push(c.t); continue; }
    if (!canEdit(box, c, by, old)) {
      keep();
      if (String(prev == null ? '' : prev) !== String(x)) kept.push(c.t);
      continue;
    }
    out[c.k] = x;
  }
  return { v: out, kept };
}

const sameRow = (a, b) => JSON.stringify(a) === JSON.stringify(b);

export async function putRow(env, box, rid, v, by) {
  await ensureShared(env);
  const id = String(rid || '');
  if (!RID_RE.test(id)) return { error: 'شناسهٔ ردیف درست نیست.' };
  const me = String(by || '').slice(0, 40);
  const now = Date.now();

  const prev = await one(env,
    'SELECT v, owner, created, updated FROM shared_rows WHERE box=? AND rid=?', box.id, id);
  let oldV = {};
  if (prev) { try { oldV = JSON.parse(prev.v) || {}; } catch { oldV = {}; } }
  const old = prev
    ? { v: oldV, owner: prev.owner || '', created: prev.created || now }
    : { v: {}, owner: me, created: now };

  if (!prev) {
    const n = await one(env, 'SELECT COUNT(*) AS n FROM shared_rows WHERE box=? AND dead=0', box.id);
    if ((n && n.n || 0) >= MAX_ROWS) return { error: 'این جدول پر شده است.' };
  }

  const m = mergeRow(box, me, old, v);

  /* اگر هیچ‌چیز واقعاً عوض نشد، ننویس. وگرنه هر بار که کسی روی یک
     خانهٔ قفل کلیک کند، updated جلو می‌رود و مرورگرِ بقیه بی‌دلیل
     ردیف را از نو می‌کشد و وسطِ تایپشان می‌پرد. */
  if (prev && sameRow(m.v, oldV))
    return { ok: true, rid: id, updated: prev.updated || now, v: oldV,
             owner: old.owner, created: old.created, kept: m.kept, noop: true };

  await run(env,
    `INSERT INTO shared_rows(box,rid,v,updated,by,dead,owner,created)
     VALUES(?,?,?,?,?,0,?,?)
     ON CONFLICT(box,rid) DO UPDATE SET v=excluded.v, updated=excluded.updated,
                                        by=excluded.by, dead=0`,
    box.id, id, JSON.stringify(m.v), now, me, old.owner, old.created);
  return { ok: true, rid: id, updated: now, v: m.v,
           owner: old.owner, created: old.created, kept: m.kept };
}

export async function killRow(env, box, rid, by) {
  await ensureShared(env);
  const id = String(rid || '');
  if (!RID_RE.test(id)) return { error: 'شناسهٔ ردیف درست نیست.' };
  const me = String(by || '').slice(0, 40);
  /* برداشتن از هر ویرایشی سنگین‌تر است: چیزی که رفت برنمی‌گردد. پس
     وقتی قفلِ مالکیت روشن است، فقط صاحبِ ردیف یا مدیر. */
  if (box.rowlock) {
    const r = await one(env, 'SELECT owner, by FROM shared_rows WHERE box=? AND rid=?', box.id, id);
    const owner = r ? (r.owner || r.by || '') : '';
    if (owner && owner !== me && !isMgr(box, me))
      return { error: 'این ردیف را کسی دیگر ساخته؛ فقط خودش یا مدیرِ این بخش می‌تواند برش دارد.' };
  }
  const now = Date.now();
  await run(env,
    'UPDATE shared_rows SET dead=1, updated=?, by=? WHERE box=? AND rid=?',
    now, me, box.id, id);
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

  /* دو راهِ عضویت، و هم‌زمان نمی‌شوند: یا فهرستِ دستیِ اسم‌ها، یا یک
     گروه. اگر هر دو بود، فردا معلوم نبود کدام حرفِ آخر را می‌زند. */
  const org = String(body.org || '').trim();
  if (org && !/^[a-z0-9]{6,16}$/.test(org)) return { error: 'گروه درست نیست.' };
  if (org) {
    const o = await one(env, 'SELECT id FROM orgs WHERE id=?', org).catch(() => null);
    if (!o) return { error: 'این گروه پیدا نشد.' };
  }

  /* فقط کارتابل‌هایی که واقعاً هستند؛ وگرنه فردا یک اسمِ غلط در
     فهرستِ اعضا می‌ماند و کسی نمی‌فهمد چرا آن یکی بخش را نمی‌بیند. */
  const members = org ? [] : (Array.isArray(body.members) ? body.members : [])
    .map(s => String(s || '').trim().toLowerCase())
    .filter((s, i, a) => s && a.indexOf(s) === i && knownSlugs.includes(s))
    .slice(0, 50);

  /* مدیر باید خودش عضو باشد؛ مدیری که بخش را نمی‌بیند مدیرِ چیزی نیست
     و فقط یک اسمِ گمراه‌کننده در تنظیمات می‌ماند. */
  const eff = org
    ? (await all(env, 'SELECT slug FROM org_members WHERE org=?', org)).map(r => r.slug)
    : members;
  const mgrs = (Array.isArray(body.mgrs) ? body.mgrs : [])
    .map(x => String(x || '').trim().toLowerCase())
    .filter((x, i, a) => x && a.indexOf(x) === i && eff.includes(x))
    .slice(0, 10);

  /* نوعِ «کارهای تیمی» بدونِ قفل بی‌معنی است: کلِ حرفش این است که کارِ
     هر کس دستِ خودش باشد. پس کلید برایش همیشه روشن. */
  const rowlock = type === 'team' ? 1 : (body.rowlock ? 1 : 0);

  const cur = await one(env, 'SELECT id, type FROM shared_boxes WHERE id=?', id);
  /* عوض کردنِ نوعِ یک جدولِ پر یعنی ستون‌هایش دیگر نمی‌خوانند و داده
     بی‌صدا ناپدید می‌شود. جلویش گرفته می‌شود. */
  if (cur && cur.type !== type) {
    const n = await one(env, 'SELECT COUNT(*) AS n FROM shared_rows WHERE box=? AND dead=0', id);
    if (n && n.n > 0)
      return { error: 'این جدول داده دارد، پس نوعش عوض نمی‌شود. یک بخشِ تازه بسازید.' };
  }

  await run(env,
    `INSERT INTO shared_boxes(id,title,type,members,created,mgrs,rowlock,org)
     VALUES(?,?,?,?,?,?,?,?)
     ON CONFLICT(id) DO UPDATE SET title=excluded.title, type=excluded.type,
                                   members=excluded.members, mgrs=excluded.mgrs,
                                   rowlock=excluded.rowlock, org=excluded.org`,
    id, title, type, JSON.stringify(members), Date.now(), JSON.stringify(mgrs), rowlock, org);
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
