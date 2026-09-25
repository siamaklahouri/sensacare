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
import { orgList, orgsOf, membersOf, mgrsOf, orgById, cleanSlugs, pathOf, ORG_ID_RE } from './orgs.js';

const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();
const run = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).run();

/* ---------- انواعِ جدول ----------
   هر نوع یک فهرست ستون دارد. «kind» شکلِ خانه را می‌گوید:
     text  یک خطی | long متنِ بلند | num عدد | money مبلغ (تومان)
     date  تاریخ شمسی به شکل ۱۴۰۴/۰۷/۰۱ | pick فهرستِ بسته
   عرضِ ستون‌ها را صفحه از همین‌جا می‌گیرد، نه از CSS. */
/* ستون‌فقرتِ جدولِ دلخواه — همان دو ستونی که «کارهای تیمی» را کار
   می‌اندازند. کلیدهایشان با c1..cN قاطی نمی‌شود. */
const CUSTOM_SPINE = [
  { k: 'who', t: 'مسئول',     kind: 'who',  w: 130, edit: 'any' },
  {           t: 'تاریخ ثبت', kind: 'made', w: 110, edit: 'never' }
];

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
    { k: 'task', t: 'کار',         kind: 'text', w: 230, edit: 'mgr' },
    /* مسئول را هر عضوی می‌گذارد، نه فقط مدیر: در عمل خودِ آدم‌ها بهتر
       می‌دانند کارِ تازه دستِ کیست و منتظر ماندن برای مدیر فقط کار را
       عقب می‌انداخت. اگر جایی خواستید فقط مدیر باشد، در پنل همین ستون
       را روی «فقط مدیر» بگذارید. */
    { k: 'who',  t: 'مسئول',       kind: 'who',  w: 130, edit: 'any' },
    {            t: 'تاریخ ثبت',   kind: 'made', w: 110, edit: 'never' },
    { k: 'due',  t: 'مهلت',        kind: 'date', w: 115, edit: 'mgr' },
    { k: 'done', t: 'تاریخ انجام', kind: 'date', w: 115, edit: 'doer' },
    { k: 'stat', t: 'وضعیت',       kind: 'pick', w: 125, edit: 'doer',
      opts: ['انجام نشده', 'در حال انجام', 'انجام شد', 'متوقف'] },
    { k: 'pri',  t: 'اولویت',      kind: 'pick', w: 105, edit: 'mgr',
      opts: ['بالا', 'متوسط', 'پایین'] },
    { k: 'note', t: 'یادداشت',     kind: 'long', edit: 'mgrdoer' }
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
  /* جدولِ دلخواه: ستون‌هایش را خودِ ادمین می‌نویسد. چیزی که این‌جا
     به‌عنوان cols می‌ماند فقط «ستون‌فقرات» است — مسئول و تاریخِ ثبت —
     که به هر جدولِ دلخواهی اضافه می‌شود. ستون‌های خودِ ادمین در
     shapeBox جلوی این‌ها می‌نشینند.

     چرا مسئول همیشه هست: خبرِ «کاری به شما سپرده شد»، فیلترِ «وظایفِ
     من»، نمای مدیر و قاعده‌های doer/mgrdoer همه از همین یک ستون
     می‌آیند. بدونش جدولِ دلخواه یک جدولِ ساده می‌شد، نه چیزی شبیه
     کارهای تیمی. */
  { id: 'custom', label: 'دلخواه — ستون‌هایش را خودم می‌نویسم', icon: '🧩',
    custom: true, cols: CUSTOM_SPINE },
  { id: 'notes', label: 'یادداشت‌های مشترک', icon: '📝', cols: [
    { k: 'title', t: 'موضوع', kind: 'text', w: 200 },
    { k: 'body',  t: 'متن',   kind: 'long' },
    { k: 'stat',  t: 'وضعیت', kind: 'pick', w: 120, opts: ['باز', 'بسته'] }
  ]}
];

export const typeById = id => SHARED_TYPES.find(t => t.id === id) || null;

/* چه کسانی می‌توانند یک ستون را عوض کنند. همین فهرست هم در پنل به
   ادمین نشان داده می‌شود، پس نامِ فارسی‌اش هم این‌جاست — دو فهرستِ
   جدا یعنی یک روز یکی‌شان گزینه‌ای می‌گیرد که آن یکی نمی‌شناسد. */
export const EDIT_RULES = [
  { id: 'mgr',     label: 'فقط مدیر' },
  { id: 'owner',   label: 'فقط سازندهٔ ردیف' },
  { id: 'doer',    label: 'فقط مسئولِ کار' },
  { id: 'mgrdoer', label: 'مدیر و مسئول' },
  { id: 'any',     label: 'همهٔ اعضا' },
  { id: 'never',   label: 'هیچ‌کس — فقط دیده می‌شود' }
];
const RULE_IDS = EDIT_RULES.map(r => r.id);

/* ---------- ساختِ جدول‌ها ----------
   در migrations هم هست؛ این‌جا هم می‌ماند تا اگر روی یک دیتابیسِ
   قدیمی‌تر اجرا شد، اولین درخواست خودش راه بیندازدش. */
let ready = false;
export async function ensureShared(env) {
  if (ready) return;
  try {
    await env.DB.batch([
      env.DB.prepare(`CREATE TABLE IF NOT EXISTS shared_boxes (
        id      TEXT PRIMARY KEY,
        title   TEXT NOT NULL DEFAULT '',
        type    TEXT NOT NULL DEFAULT 'notes',
        members TEXT NOT NULL DEFAULT '[]',
        created INTEGER NOT NULL DEFAULT 0
      )`),
      env.DB.prepare(`CREATE TABLE IF NOT EXISTS shared_rows (
        box     TEXT NOT NULL,
        rid     TEXT NOT NULL,
        v       TEXT NOT NULL DEFAULT '{}',
        updated INTEGER NOT NULL DEFAULT 0,
        by      TEXT NOT NULL DEFAULT '',
        dead    INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (box, rid)
      )`),
      env.DB.prepare('CREATE INDEX IF NOT EXISTS shared_rows_box_upd ON shared_rows(box, updated)')
    ]);

    /* ستون‌هایی که بعداً اضافه شدند. اول می‌پرسیم چه ستون‌هایی هست و
       فقط نداشته‌ها را اضافه می‌کنیم. قبلاً هر پنج ALTER کورکورانه
       فرستاده می‌شد و روی هر دیتابیسِ به‌روز هر پنج‌تا خطا می‌خوردند —
       و چون ready فقط برای همین ایزوله است، این با هر بار بالا آمدنِ
       یک ایزولهٔ تازه دوباره تکرار می‌شد.

       ALTERها دسته‌ای فرستاده نمی‌شوند: دسته تراکنشی است و اگر یکی
       بخورد بقیه هم برمی‌گردند، پس اضافه شدنِ تدریجی از بین می‌رفت. */
    const cols = async t => {
      try { return new Set((await all(env, `PRAGMA table_info(${t})`)).map(r => r.name)); }
      catch (e) { return null; }
    };
    const [bx, rw] = await Promise.all([cols('shared_boxes'), cols('shared_rows')]);
    for (const [have, q, name] of [
      [bx, "ALTER TABLE shared_boxes ADD COLUMN mgrs TEXT NOT NULL DEFAULT '[]'", 'mgrs'],
      /* پیش‌فرضِ ۰ عمدی است: بخش‌هایی که از قبل ساخته شده‌اند نباید یک
         روز صبح خودبه‌خود قفل شوند و کسی نفهمد چرا دیگر نمی‌تواند
         ردیفِ همکارش را درست کند. بخشِ تازه با کلیدِ روشن ساخته
         می‌شود؛ قدیمی‌ها را خودِ ادمین وقتی خواست روشن می‌کند. */
      [bx, 'ALTER TABLE shared_boxes ADD COLUMN rowlock INTEGER NOT NULL DEFAULT 0', 'rowlock'],
      [bx, "ALTER TABLE shared_boxes ADD COLUMN org TEXT NOT NULL DEFAULT ''", 'org'],
      [bx, "ALTER TABLE shared_boxes ADD COLUMN perms TEXT NOT NULL DEFAULT '{}'", 'perms'],
      [bx, "ALTER TABLE shared_boxes ADD COLUMN cols TEXT NOT NULL DEFAULT ''", 'cols'],
      [rw, "ALTER TABLE shared_rows ADD COLUMN owner TEXT NOT NULL DEFAULT ''", 'owner'],
      [rw, 'ALTER TABLE shared_rows ADD COLUMN created INTEGER NOT NULL DEFAULT 0', 'created']
    ]) {
      if (have && have.has(name)) continue;
      try { await run(env, q); } catch (e) { /* از قبل هست */ }
    }
    ready = true;
  } catch (e) { /* اگر ساخته نشد، مسیرها خودشان خطا می‌دهند */ }
}

/* ---------- ستون‌های جدولِ دلخواه ----------
   ادمین اسم‌ها را با کاما (یا «،»، نقطه‌ویرگول، خطِ تیرهٔ فاصله‌دار، یا
   خطِ تازه) جدا می‌نویسد. نوعِ هر ستون اختیاری است و بعد از دونقطه
   می‌آید؛ ننوشتنش یعنی متنِ یک‌خطی:

     مشتری, مبلغ:مبلغ, سررسید:تاریخ, وضعیت:باز/بسته, شرح:بلند

   خطِ تیره فقط وقتی جداکننده است که دو طرفش فاصله باشد، وگرنه اسمی
   مثل «پیش‌فاکتور - ۲» وسطش نصف می‌شد. */
const CUSTOM_MAX = 12;
const KIND_WORDS = [
  ['بلند', 'long'], ['متن بلند', 'long'], ['توضیح', 'long'], ['یادداشت', 'long'],
  ['تاریخ', 'date'], ['مبلغ', 'money'], ['پول', 'money'],
  ['عدد', 'num'], ['رقم', 'num'], ['متن', 'text']
];
const KIND_W = { text: 150, long: 0, date: 115, money: 130, num: 110, pick: 125 };

export function parseCustomCols(raw) {
  const out = [];
  for (const piece of String(raw || '').split(/[,،;؛\n]+|\s+-\s+/)) {
    const line = piece.trim();
    if (!line) continue;
    const at = line.search(/[:：]/);
    const name = (at < 0 ? line : line.slice(0, at)).trim().slice(0, 30);
    if (!name) continue;
    const spec = at < 0 ? '' : line.slice(at + 1).trim();
    const col = { t: name };
    if (spec.includes('/')) {
      /* «باز/بسته/معوق» یعنی کشویی با همین گزینه‌ها */
      col.kind = 'pick';
      col.opts = spec.split('/').map(o => o.trim().slice(0, 24)).filter(Boolean).slice(0, 12);
      if (!col.opts.length) { col.kind = 'text'; delete col.opts; }
    } else {
      const hit = KIND_WORDS.find(([w]) => w === spec);
      col.kind = hit ? hit[1] : 'text';
    }
    const w = KIND_W[col.kind];
    if (w) col.w = w;
    out.push(col);
    if (out.length >= CUSTOM_MAX) break;
  }
  return out;
}

/* کلیدها c1..cN‌اند و به جایگاه بسته نیستند: وقتی ادمین فهرست را عوض
   می‌کند، ستونی که نامش همان مانده کلیدِ قبلی‌اش را نگه می‌دارد. وگرنه
   جابه‌جا کردنِ دو ستون، دادهٔ همهٔ ردیف‌ها را با هم عوض می‌کرد. */
export function keyCustomCols(cols, prev) {
  const byName = {};
  for (const c of (prev || [])) if (c.k && c.t) byName[c.t] = c.k;
  const used = new Set();
  const out = cols.map(c => {
    const k = byName[c.t];
    if (k && !used.has(k)) { used.add(k); return { ...c, k }; }
    return { ...c };
  });
  let n = 1;
  for (const c of out) {
    if (c.k) continue;
    while (used.has('c' + n)) n++;
    c.k = 'c' + n; used.add(c.k);
  }
  return out;
}

const readCustom = raw => { try { const a = JSON.parse(raw); return Array.isArray(a) ? a : []; } catch { return []; } };

/* ستون‌های خودِ ادمین جلو، ستون‌فقرات آخر */
const customCols = raw => [...readCustom(raw), ...CUSTOM_SPINE];

const parseMembers = s => { try { const a = JSON.parse(s); return Array.isArray(a) ? a : []; } catch { return []; } };

/* ادمین می‌تواند برای هر ستون بگوید چه کسی عوضش کند. آنچه ذخیره شده
   روی پیش‌فرضِ خودِ نوع می‌نشیند، نه جایش را می‌گیرد: ستونی که ادمین
   دربارهٔ آن حرفی نزده، همان رفتارِ همیشگی‌اش را دارد. */
const applyPerms = (cols, raw) => {
  let p = {};
  try { p = JSON.parse(raw || '{}') || {}; } catch { p = {}; }
  return cols.map(c => (c.k && RULE_IDS.includes(p[c.k])) ? { ...c, edit: p[c.k] } : c);
};

const shapeBox = r => {
  const t = typeById(r.type);
  return { id: r.id, title: r.title, type: r.type,
           label: t ? t.label : r.type, icon: t ? t.icon : '📋',
           cols: t ? applyPerms(t.custom ? customCols(r.cols) : t.cols, r.perms) : [],
           /* متنی که ادمین نوشته، برای برگرداندن در فرمِ پنل */
           colspec: t && t.custom ? readCustom(r.cols) : null,
           members: parseMembers(r.members),
           mgrs: parseMembers(r.mgrs), rowlock: Number(r.rowlock || 0),
           org: r.org || '', orgPath: '',
           /* خامش هم می‌رود تا پنل بداند ادمین کدام ستون را دست زده و
              کدام هنوز پیش‌فرضِ نوع است. */
           perms: (() => { try { return JSON.parse(r.perms || '{}') || {}; } catch { return {}; } })(),
           created: r.created };
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
    /* مدیرِ گروه، مدیرِ همهٔ بخش‌های همان گروه هم هست. بخش می‌تواند
       مدیرِ خودش را هم داشته باشد — این دو با هم جمع می‌شوند، نه اینکه
       یکی جای آن یکی را بگیرد. */
    b.mgrs = [...new Set([...(o ? o.mgrs : []), ...b.mgrs])]
      .filter(m => b.members.includes(m));
  }
  return boxes;
}

export async function boxesFor(env, slug) {
  await ensureShared(env);
  /* دو پرسشِ مستقل، پس با هم. */
  const [rows, mine] = await Promise.all([
    all(env, 'SELECT * FROM shared_boxes ORDER BY created, id'),
    orgsOf(env, slug)
  ]);
  /* اول غربال، بعد پر کردن. برعکسش یعنی اگر فقط یک بخش در کلِ سیستم به
     گروهی وصل باشد، هر کاربری — حتی کسی که هیچ بخشِ گروهی ندارد —
     هزینهٔ خواندنِ درختِ سازمان را می‌داد. غربال کردن این‌جا امن است
     چون شاخهٔ گروه فقط b.org را می‌خواند، نه اعضا را. */
  const mineBoxes = rows.map(shapeBox)
    .filter(b => b.org ? mine.includes(b.org) : b.members.includes(slug));
  return withPeople(env, await withOrgs(env, mineBoxes));
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
  const b = shapeBox(r);
  /* یک بخش، پس کلِ درختِ سازمان خوانده نمی‌شود — فقط اعضای همین گروه.
     این مسیر هر شش ثانیه صدا زده می‌شود و با هر ویرایش و هر حذف، پس
     یک پرسشِ اضافه این‌جا ضرب می‌شود در تعدادِ آدم‌ها و ساعت‌ها.
     «مسیرِ گروه» هم این‌جا به کار نمی‌آید و فرستاده نمی‌شود. */
  if (b.org) {
    const [mem, mgr] = await Promise.all([membersOf(env, b.org), mgrsOf(env, b.org)]);
    b.members = mem;
    b.mgrs = [...new Set([...mgr, ...b.mgrs])].filter(m => mem.includes(m));
  }
  return b;
}

/* ---------- خبرِ کارهای تازه ----------
   تازه‌سازیِ عادی فقط وقتی کار می‌کند که همان بخش باز باشد، وگرنه یک
   کارتابلِ رهاشده تا ابد به سرور می‌زند. ولی خبر دقیقاً وقتی لازم است
   که آدم جای دیگری از کارتابلش نشسته — پس این مسیر هست: پس‌زمینه هر
   نیم‌دقیقه یک بار می‌پرسد «چیزی تازه هست؟».

   عمداً از boxesFor استفاده نمی‌کند: آن اسمِ آدم‌ها و درختِ گروه را هم
   می‌آورد که این‌جا به کار نمی‌آید و چهار-پنج پرسش خرج دارد. این‌جا سه
   پرسش است، هر چند بخش که باشد — نه یکی به‌ازای هر بخش. D1 روی شبکه
   است و پرسشِ داخلِ حلقه گران تمام می‌شود.

   سقفِ شصت ردیف عمدی است: کسی که یک هفته نیامده، شصت خبر هم برایش
   همان‌قدر بی‌معناست که ششصد تا. */
export async function newsFor(env, slug, since = 0) {
  await ensureShared(env);
  const [rows, mine] = await Promise.all([
    all(env, 'SELECT id, members, org FROM shared_boxes'),
    orgsOf(env, slug)
  ]);
  const ids = rows
    .filter(r => r.org ? mine.includes(r.org) : parseMembers(r.members).includes(slug))
    .map(r => r.id);
  if (!ids.length) return [];
  const got = await all(env,
    `SELECT box, rid, v, updated, by, owner FROM shared_rows
      WHERE box IN (${ids.map(() => '?').join(',')}) AND updated>? AND dead=0
      ORDER BY updated LIMIT 60`, ...ids, Number(since) || 0);
  return got.map(r => {
    let v = {};
    try { v = JSON.parse(r.v) || {}; } catch { v = {}; }
    return { box: r.box, rid: r.rid, v, updated: r.updated,
             by: r.by, owner: r.owner || r.by || '' };
  });
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

/* ستون‌ها از خودِ بخش می‌آیند، نه از نوعش: نوعِ «دلخواه» ستون‌های
   ثابت ندارد و ستون‌هایش روی همان بخش نشسته‌اند. تا وقتی این‌جا از نوع
   خوانده می‌شد، هر چیزی که ادمین خودش ساخته بود بی‌صدا دور ریخته
   می‌شد — ردیف ذخیره می‌شد ولی خانه‌هایش خالی. */
export function cleanRow(cols, v) {
  const out = {};
  for (const c of (cols || [])) {
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
  if (rule === 'doer' || rule === 'mgrdoer') {
    /* مدیر بالاتر رد شده، پس این‌جا mgrdoer و doer یک کار می‌کنند.
       تا وقتی مسئولی انتخاب نشده، سازندهٔ ردیف همان نقش را دارد —
       وگرنه کارِ تازه‌نوشته تا انتخابِ مسئول دست‌نخوردنی می‌ماند. */
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
  const clean = cleanRow(box.cols, incoming);
  const out = {};
  const kept = [];
  /* ستون‌های خودِ این بخش، نه ستون‌های خامِ نوع: قاعده‌هایی که ادمین
     عوض کرده روی همین‌ها نشسته‌اند. */
  for (const c of (box.cols || [])) {
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
             owner: old.owner, created: old.created, kept: m.kept };

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
  if (org && !ORG_ID_RE.test(org)) return { error: 'گروه درست نیست.' };

  /* فقط کارتابل‌هایی که واقعاً هستند؛ وگرنه فردا یک اسمِ غلط در
     فهرستِ اعضا می‌ماند و کسی نمی‌فهمد چرا آن یکی بخش را نمی‌بیند. */
  const members = org ? [] : cleanSlugs(body.members, knownSlugs, 50);

  /* مدیر باید خودش عضو باشد؛ مدیری که بخش را نمی‌بیند مدیرِ چیزی نیست
     و فقط یک اسمِ گمراه‌کننده در تنظیمات می‌ماند. */
  /* سه پرسشی که به هم کاری ندارند، با هم می‌روند. */
  const [orgRow, orgMem, cur] = await Promise.all([
    org ? orgById(env, org) : null,
    org ? membersOf(env, org) : [],
    one(env, 'SELECT id, type, cols FROM shared_boxes WHERE id=?', id)
  ]);
  if (org && !orgRow) return { error: 'این گروه پیدا نشد.' };

  const eff = org ? orgMem : members;
  const mgrs = cleanSlugs(body.mgrs, eff, 10);

  /* نوعِ «کارهای تیمی» بدونِ قفل بی‌معنی است: کلِ حرفش این است که کارِ
     هر کس دستِ خودش باشد. پس کلید برایش همیشه روشن. */
  const rowlock = type === 'team' ? 1 : (body.rowlock ? 1 : 0);

  /* قاعدهٔ دسترسیِ هر ستون. فقط کلیدهایی که این نوع واقعاً دارد و فقط
     قاعده‌هایی که می‌شناسیم — وگرنه یک کلیدِ غلط در تنظیمات می‌ماند و
     کسی نمی‌فهمد چرا آن ستون رفتارِ عجیبی دارد.
     ستونِ نمایشی (بی‌کلید، مثل «تاریخ ثبت») قاعده نمی‌گیرد. */
  /* ستون‌های جدولِ دلخواه را همین‌جا می‌سازیم، چون هم قاعده‌ها روی
     همین‌ها بسته می‌شوند و هم خودشان باید ذخیره شوند. */
  const tDef = typeById(type) || { cols: [] };
  let cols = '';
  let tCols = tDef.cols;
  if (tDef.custom) {
    const parsed = parseCustomCols(body.cols);
    if (!parsed.length) return { error: 'دست‌کم یک ستون بنویسید — با کاما یا خطِ تازه جدایشان کنید.' };
    const keyed = keyCustomCols(parsed, cur ? readCustom(cur.cols) : []);
    cols = JSON.stringify(keyed);
    tCols = [...keyed, ...CUSTOM_SPINE];
  }
  const perms = {};
  const pin = (body.perms && typeof body.perms === 'object') ? body.perms : {};
  for (const c of tCols) {
    if (!c.k || c.edit === 'never') continue;
    /* پنل ستون‌های دلخواه را با «@نام» می‌فرستد، چون کلیدِ واقعی را
       همین‌جا می‌سازیم و آن‌طرف هنوز نمی‌داندش. */
    const r = String(pin[c.k] || pin['@' + c.t] || '');
    if (RULE_IDS.includes(r) && r !== (c.edit || '')) perms[c.k] = r;
  }

  /* عوض کردنِ نوعِ یک جدولِ پر یعنی ستون‌هایش دیگر نمی‌خوانند و داده
     بی‌صدا ناپدید می‌شود. جلویش گرفته می‌شود. */
  if (cur && cur.type !== type) {
    const n = await one(env, 'SELECT COUNT(*) AS n FROM shared_rows WHERE box=? AND dead=0', id);
    if (n && n.n > 0)
      return { error: 'این جدول داده دارد، پس نوعش عوض نمی‌شود. یک بخشِ تازه بسازید.' };
  }

  await run(env,
    `INSERT INTO shared_boxes(id,title,type,members,created,mgrs,rowlock,org,perms,cols)
     VALUES(?,?,?,?,?,?,?,?,?,?)
     ON CONFLICT(id) DO UPDATE SET title=excluded.title, type=excluded.type,
                                   members=excluded.members, mgrs=excluded.mgrs,
                                   rowlock=excluded.rowlock, org=excluded.org,
                                   perms=excluded.perms, cols=excluded.cols`,
    id, title, type, JSON.stringify(members), Date.now(), JSON.stringify(mgrs), rowlock, org,
    JSON.stringify(perms), cols);
  return { ok: true, id, created: !cur };
}

export async function dropBox(env, id) {
  await ensureShared(env);
  const bid = String(id || '');
  await run(env, 'DELETE FROM shared_rows WHERE box=?', bid);
  await run(env, 'DELETE FROM shared_boxes WHERE id=?', bid);
  return { ok: true };
}

/* چند بخشِ مشترک به هر گروه وصل است — برای درختِ سازمان در پنل.
   قبلاً برای همین عدد، همهٔ بخش‌ها خوانده و شکل داده می‌شدند و درختِ
   سازمان بارِ دوم از دیتابیس درمی‌آمد. */
export async function orgBoxCounts(env) {
  await ensureShared(env);
  try {
    const rows = await all(env,
      "SELECT org, COUNT(*) AS n FROM shared_boxes WHERE org <> '' GROUP BY org");
    const out = {};
    for (const r of rows) out[r.org] = r.n;
    return out;
  } catch (e) { return {}; }
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
