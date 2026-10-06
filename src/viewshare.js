/* اشتراکِ یک بخشِ کارتابل با یک گروه
   =================================================================
   بخشِ مشترک (shared.js) جدولی است که ادمین از صفر می‌سازد و هیچ‌کس
   مالکش نیست. این‌جا چیزِ دیگری است: سیامک «سرورها و بکاپ» را که
   بخشِ خودِ کارتابلِ خودش است، با گروهِ «احیا › فنی» به اشتراک
   می‌گذارد. دادهٔ همان یکی است — همان ردیف‌هایی که خودش می‌بیند —
   نه رونوشتی که از فردا با آن درمی‌رود.

   سه تصمیم که عمدی‌اند:

   ۱. اشتراک را فقط ادمین از پنل می‌سازد. کاربر نمی‌تواند بخشی از
      کارتابلش را خودش بدهد یا پس بگیرد؛ وگرنه معلوم نیست چه کسی چه
      چیزی را می‌بیند، و دسترسی‌ای که معلوم نباشد دسترسیِ درستی نیست.

   ۲. گیرنده یک گروه است، نه یک نفر. هر کس به گروه اضافه شود همان
      لحظه بخش را می‌گیرد و هر کس برداشته شود دستش کوتاه می‌شود —
      همان قاعدهٔ orgs.js، نه یک فهرستِ دومِ موازی.

   ۳. دادهٔ بخش جابه‌جا نمی‌شود. هر خواندن و نوشتن روی همان کلیدِ
      کارتابلِ مالک انجام می‌شود. پس مالک در صفحهٔ خودش همان چیزی را
      می‌بیند که عضوِ گروه نوشته، بدونِ هیچ هم‌گام‌سازیِ جداگانه.

   مثل shared.js و orgs.js از kartabl.js چیزی وارد نمی‌شود تا حلقهٔ
   import درست نشود: این فایل فقط با عکسِ دادهٔ `{state, db}` کار
   می‌کند و خواندن و نوشتنش کارِ صدازننده است. */

const all = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const one = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();

let ready = false;
export async function ensureViewShares(env) {
  if (ready) return;
  try {
    await env.DB.batch([
      env.DB.prepare(`CREATE TABLE IF NOT EXISTS view_shares (
        id      TEXT PRIMARY KEY,
        owner   TEXT NOT NULL DEFAULT '',
        view    TEXT NOT NULL DEFAULT '',
        org     TEXT NOT NULL DEFAULT '',
        w       INTEGER NOT NULL DEFAULT 0,
        created INTEGER NOT NULL DEFAULT 0
      )`),
      /* یک بخش از یک کارتابل، یک بار به یک گروه. دو ردیفِ تکراری
         یعنی یک گروه دو تا از همان جدول در نوارش می‌بیند. */
      env.DB.prepare('CREATE UNIQUE INDEX IF NOT EXISTS view_shares_u ON view_shares(owner, view, org)'),
      env.DB.prepare('CREATE INDEX IF NOT EXISTS view_shares_org ON view_shares(org)')
    ]);
    ready = true;
  } catch (e) { /* مسیرها خودشان خطا می‌دهند */ }
}

/* ---------- کدام بخش‌ها اشتراکی می‌شوند ----------
   هر بخشِ داده‌دارِ کارتابل. داشبورد و گزارش‌ساز و تبدیل این‌جا
   نیستند: آن‌ها جدولِ خودشان را ندارند و از همین داده‌ها ساخته
   می‌شوند. «دیتای شخصی» هم عمداً نیست — کلیدش روی سرور نیست و
   هیچ‌کس جز خودش نمی‌تواند بازش کند، حتی ادمین.

   `src` می‌گوید داده در `state` است یا `db`، و `path` نامِ آرایه.
   ستون‌ها همان ستون‌های جدولِ خودِ کارتابل‌اند تا عضوِ گروه همان
   چیزی را ببیند که مالک می‌بیند. */

const STATUS   = ['انجام نشده', 'در حال انجام', 'انجام شد'];
const PRIORITY = ['بالا', 'متوسط', 'پایین'];
const PARTY_TYPES = ['مشتری', 'تامین‌کننده'];
const INVOICE_STATUS = ['پرداخت‌شده', 'جزئی', 'معوق'];
const PAYMENT_METHODS = ['نقدی', 'کارت بانکی', 'چک', 'انتقال بانکی'];
const SOURCE_USE_TYPES = ['منبع', 'مصرف'];
const EXPENSE_CATEGORIES = ['اجاره', 'حقوق و دستمزد', 'قبوض (آب/برق/گاز/تلفن)',
  'نرم‌افزار و لایسنس', 'تجهیزات و تعمیرات', 'حمل‌ونقل', 'بازاریابی و تبلیغات',
  'مالیات و بیمه', 'متفرقه'];

export const SHAREABLE = {
  /* --- هر دو قالب --- */
  checklist: {
    kinds: ['it', 'fin', 'gen'], label: 'چک‌لیست ماهانه', icon: '✅',
    src: 'state', path: 'tasks', month: true,
    cols: [
      { k: 'category', t: 'دسته‌بندی', kind: 'text' },
      { k: 'task',     t: 'وظیفه',     kind: 'text' },
      { k: 'owner',    t: 'مسئول',     kind: 'text' },
      { k: 'deadline', t: 'مهلت (روز از ماه)', kind: 'num' },
      { k: 'status',   t: 'وضعیت',     kind: 'pick', opts: STATUS },
      { k: 'priority', t: 'اولویت',    kind: 'pick', opts: PRIORITY }
    ]
  },
  daily: {
    kinds: ['it', 'fin', 'gen'], label: 'برنامه روزانه', icon: '🗓️',
    src: 'state', path: 'days', month: true,
    cols: [
      { k: 'createdDate', t: 'تاریخ',       kind: 'date', edit: 'never' },
      { k: 'main',        t: 'وظایف اصلی',  kind: 'text' },
      { k: 'meet',        t: 'توضیحات',     kind: 'text' },
      { k: 'company',     t: 'طرف‌حساب',    kind: 'text' },
      { k: 'status',      t: 'وضعیت',       kind: 'pick', opts: STATUS }
    ]
  },

  /* --- قالبِ IT --- */
  servers: {
    kinds: ['it', 'gen'], label: 'سرورها و بکاپ', icon: '🖥️',
    src: 'db', path: 'vm',
    cols: [
      { k: 'server',         t: 'نام سرور',          kind: 'text' },
      { k: 'location',       t: 'IP/محل',            kind: 'text' },
      { k: 'sizeUsed',       t: 'حجم vbk (GB)',      kind: 'num' },
      { k: 'sizeVib',        t: 'حجم vib (GB)',      kind: 'num' },
      { k: 'schedule',       t: 'زمان‌بندی',         kind: 'text' },
      { k: 'lastRestore',    t: 'آخرین ری‌استور',    kind: 'date' },
      { k: 'lastFullBackup', t: 'آخرین بکاپ کامل',   kind: 'date' },
      { k: 'storage',        t: 'محل ذخیره',         kind: 'text' }
    ]
  },
  mvpn: {
    kinds: ['it', 'gen'], label: 'سرویس MVPN', icon: '📱',
    src: 'db', path: 'lines',
    cols: [
      { k: 'phone', t: 'شماره',  kind: 'text' },
      { k: 'owner', t: 'مالک',   kind: 'text' },
      { k: 'stage', t: 'وضعیت',  kind: 'text' },
      { k: 'ext',   t: 'داخلی',  kind: 'text' },
      { k: 'plan',  t: 'طرح',    kind: 'text' }
    ]
  },
  companies: {
    kinds: ['it', 'gen'], label: 'شرکت‌ها', icon: '🏢',
    /* این یکی آرایه نیست: نقشه‌ای است از نامِ شرکت به فهرستِ
       مراجعه‌ها. برای نمایش صاف می‌شود و برای نوشتن از نو نقشه
       می‌شود — نامِ شرکت خودش یک ستون است. */
    src: 'db', path: 'companies', shape: 'map', mapKey: 'company',
    cols: [
      { k: 'company', t: 'شرکت',   kind: 'text' },
      { k: 'dateStr', t: 'تاریخ',  kind: 'date' },
      { k: 'time',    t: 'ساعت',   kind: 'text' },
      { k: 'type',    t: 'نوع',    kind: 'text' }
    ]
  },

  /* --- قالبِ مالی --- */
  invoices: {
    kinds: ['fin'], label: 'سررسید اسناد دریافتنی', icon: '🧾',
    src: 'db', path: 'invoices',
    cols: [
      { k: 'invoiceNo',  t: 'شماره فاکتور', kind: 'text' },
      { k: 'customer',   t: 'مشتری',        kind: 'text' },
      { k: 'date',       t: 'تاریخ',        kind: 'date' },
      { k: 'dueDate',    t: 'سررسید',       kind: 'date' },
      { k: 'amount',     t: 'مبلغ کل',      kind: 'money' },
      { k: 'paid',       t: 'پرداخت‌شده',   kind: 'money' },
      { k: 'status',     t: 'وضعیت',        kind: 'pick', opts: INVOICE_STATUS },
      { k: 'enteredBy',  t: 'واردکننده',    kind: 'text' }
    ]
  },
  payables: {
    kinds: ['fin'], label: 'بدهی‌ها و پرداخت‌ها', icon: '💳',
    src: 'db', path: 'payables',
    cols: [
      { k: 'beneficiary', t: 'ذینفع/تامین‌کننده', kind: 'text' },
      { k: 'project',     t: 'پروژه',             kind: 'text' },
      { k: 'dueDate',     t: 'تاریخ سررسید',      kind: 'date' },
      { k: 'subject',     t: 'موضوع',             kind: 'text' },
      { k: 'amount',      t: 'مبلغ',              kind: 'money' },
      { k: 'enteredBy',   t: 'واردکننده',         kind: 'text' }
    ]
  },
  payablenotes: {
    kinds: ['fin'], label: 'اسناد پرداختنی', icon: '📄',
    src: 'db', path: 'payableNotes',
    cols: [
      { k: 'checkNo',     t: 'شماره چک',        kind: 'text' },
      { k: 'dueDate',     t: 'تاریخ سررسید چک', kind: 'date' },
      { k: 'amount',      t: 'مبلغ',            kind: 'money' },
      { k: 'beneficiary', t: 'ذینفع',           kind: 'text' },
      { k: 'subject',     t: 'موضوع',           kind: 'text' },
      { k: 'enteredBy',   t: 'واردکننده',       kind: 'text' }
    ]
  },
  receivablenotes: {
    kinds: ['fin'], label: 'اسناد دریافتنی', icon: '📃',
    src: 'db', path: 'receivableNotes',
    cols: [
      { k: 'checkNo',   t: 'شماره چک',        kind: 'text' },
      { k: 'dueDate',   t: 'تاریخ سررسید چک', kind: 'date' },
      { k: 'amount',    t: 'مبلغ',            kind: 'money' },
      { k: 'buyer',     t: 'خریدار',          kind: 'text' },
      { k: 'subject',   t: 'موضوع',           kind: 'text' },
      { k: 'enteredBy', t: 'واردکننده',       kind: 'text' }
    ]
  },
  expenses: {
    kinds: ['fin'], label: 'منابع و مصارف', icon: '🧮',
    src: 'db', path: 'expenses',
    cols: [
      { k: 'date',          t: 'تاریخ',       kind: 'date' },
      { k: 'type',          t: 'نوع',         kind: 'pick', opts: SOURCE_USE_TYPES },
      { k: 'category',      t: 'دسته‌بندی',   kind: 'pick', opts: EXPENSE_CATEGORIES },
      { k: 'description',   t: 'شرح',         kind: 'text' },
      { k: 'amount',        t: 'مبلغ',        kind: 'money' },
      { k: 'paymentMethod', t: 'روش پرداخت',  kind: 'pick', opts: PAYMENT_METHODS },
      { k: 'enteredBy',     t: 'واردکننده',   kind: 'text' }
    ]
  },
  bank: {
    kinds: ['fin'], label: 'حساب‌های بانکی', icon: '🏦',
    src: 'db', path: 'bank',
    cols: [
      { k: 'accountName',   t: 'نام حساب',    kind: 'text' },
      { k: 'bank',          t: 'بانک',        kind: 'text' },
      { k: 'accountNumber', t: 'شماره حساب',  kind: 'text' },
      { k: 'balance',       t: 'موجودی',      kind: 'money' },
      { k: 'note',          t: 'یادداشت',     kind: 'text' },
      { k: 'enteredBy',     t: 'واردکننده',   kind: 'text' }
    ]
  },
  budget: {
    kinds: ['fin'], label: 'بودجه‌بندی ماهانه', icon: '📐',
    src: 'db', path: 'budget',
    cols: [
      { k: 'period',       t: 'دوره',          kind: 'text' },
      { k: 'category',     t: 'دسته‌بندی',     kind: 'text' },
      { k: 'budgetAmount', t: 'بودجه',         kind: 'money' },
      { k: 'actualAmount', t: 'هزینهٔ واقعی',  kind: 'money' },
      { k: 'enteredBy',    t: 'واردکننده',     kind: 'text' }
    ]
  },
  parties: {
    kinds: ['fin'], label: 'طرف‌حساب‌ها', icon: '👥',
    src: 'db', path: 'parties',
    cols: [
      { k: 'name',      t: 'نام',          kind: 'text' },
      { k: 'type',      t: 'نوع',          kind: 'pick', opts: PARTY_TYPES },
      { k: 'phone',     t: 'تلفن',         kind: 'text' },
      { k: 'contact',   t: 'مسئول تماس',   kind: 'text' },
      { k: 'note',      t: 'یادداشت',      kind: 'text' },
      { k: 'enteredBy', t: 'واردکننده',    kind: 'text' }
    ]
  }
};

/* بخش‌هایی که این نوع کارتابل دارد — برای فهرستِ بازشویِ پنل */
export function shareableFor(kind) {
  const k = String(kind || '');
  return Object.entries(SHAREABLE)
    .filter(([, s]) => s.kinds.includes(k))
    .map(([id, s]) => ({ id, label: s.label, icon: s.icon }));
}

export const specOf = view => SHAREABLE[String(view || '')] || null;

/* ---------- خواندن ---------- */

export async function viewShareRows(env) {
  await ensureViewShares(env);
  try {
    return await all(env, 'SELECT * FROM view_shares ORDER BY created, id');
  } catch (e) { return []; }
}

export async function viewShareById(env, id) {
  await ensureViewShares(env);
  try { return await one(env, 'SELECT * FROM view_shares WHERE id=?', String(id || '')); }
  catch (e) { return null; }
}

/* اشتراک‌هایی که این کارتابل باید ببیند: عضوِ گروه باشد و خودش مالک
   نباشد. مالک بخشش را در جای همیشگی‌اش دارد؛ یک نسخهٔ دومش در نوار،
   فقط آدم را سر کار می‌گذارد. */
export async function sharesFor(env, slug, orgIds) {
  await ensureViewShares(env);
  const me = String(slug || '');
  const orgs = (orgIds || []).map(String).filter(Boolean);
  if (!me || !orgs.length) return [];
  try {
    const rows = await all(env,
      'SELECT * FROM view_shares WHERE org IN (' + orgs.map(() => '?').join(',') + ') AND owner<>?',
      ...orgs, me);
    return rows.filter(r => specOf(r.view));
  } catch (e) { return []; }
}

/* ---------- نوشتنِ خودِ اشتراک (فقط ادمین) ---------- */

const ID_RE = /^[a-z0-9]{6,16}$/;
const newId = () => {
  const a = 'abcdefghijklmnopqrstuvwxyz0123456789';
  const b = crypto.getRandomValues(new Uint8Array(10));
  let s = '';
  for (const x of b) s += a[x % a.length];
  return s;
};

/* `kinds` نقشه‌ای است از نامِ کارتابل به قالبش. فهرستِ نام‌ها تنها
   کافی نبود: بخشِ «حساب‌های بانکی» را می‌شد به کارتابلِ فنی بست و
   هیچ‌کس نمی‌فهمید، چون آن کارتابل اصلاً چنین بخشی ندارد — عضوِ گروه
   یک جدولِ همیشه‌خالی می‌دید. */
export async function saveViewShare(env, body, kinds, knownOrgs) {
  await ensureViewShares(env);
  const id = String(body.id || '').trim();
  if (id && !ID_RE.test(id)) return { error: 'شناسهٔ اشتراک درست نیست.' };

  const owner = String(body.owner || '').trim().toLowerCase();
  const kind = kinds ? kinds[owner] : undefined;
  if (!owner || kind === undefined) return { error: 'کارتابلِ صاحبِ بخش را انتخاب کنید.' };

  const view = String(body.view || '').trim();
  const spec = specOf(view);
  if (!spec) return { error: 'این بخش اشتراکی نمی‌شود.' };
  if (!spec.kinds.includes(kind))
    return { error: 'کارتابلِ «' + owner + '» بخشی به نامِ «' + spec.label + '» ندارد.' };

  const org = String(body.org || '').trim();
  if (!org || !knownOrgs.includes(org)) return { error: 'گروهِ گیرنده را انتخاب کنید.' };

  const w = body.w ? 1 : 0;

  /* ادمین یک بخش را دو بار به یک گروه نمی‌دهد. اگر دوباره داد، همان
     ردیفِ قبلی است که دسترسی‌اش عوض می‌شود — نه یک ردیفِ دوم. */
  try {
    await env.DB.prepare(
      `INSERT INTO view_shares(id,owner,view,org,w,created) VALUES(?,?,?,?,?,?)
       ON CONFLICT(owner,view,org) DO UPDATE SET w=excluded.w`
    ).bind(id || newId(), owner, view, org, w, Date.now()).run();
  } catch (e) { return { error: 'ذخیره نشد: ' + (e && e.message || e) }; }

  const row = await one(env, 'SELECT id FROM view_shares WHERE owner=? AND view=? AND org=?',
                        owner, view, org);
  return { ok: true, id: row ? row.id : (id || '') };
}

export async function dropViewShare(env, id) {
  await ensureViewShares(env);
  try { await env.DB.prepare('DELETE FROM view_shares WHERE id=?').bind(String(id || '')).run(); }
  catch (e) { return { error: 'پاک نشد.' }; }
  return { ok: true };
}

/* ---------- داده: خواندن و نوشتنِ آرایهٔ بخش ----------
   هر دو تابع روی عکسِ `{state, db}` کار می‌کنند. چیزی را خودشان
   ذخیره نمی‌کنند؛ صدازننده با saveKartabl و baseRev می‌نویسد تا اگر
   مالک همان لحظه داشت چیزی عوض می‌کرد، نوشتن رویش نرود. */

const cleanStr = (v, n) => String(v == null ? '' : v).slice(0, n || 400);

/* صاف کردنِ نقشهٔ شرکت‌ها. ترتیب از خودِ نقشه می‌آید تا دو بار
   خواندن، دو ترتیبِ مختلف ندهد. */
function mapToRows(obj, spec) {
  const out = [];
  for (const name of Object.keys(obj || {}))
    for (const e of (obj[name] || []))
      out.push(Object.assign({ [spec.mapKey]: name }, e));
  return out;
}

function rowsToMap(rows, spec) {
  const out = {};
  for (const r of rows) {
    const name = cleanStr(r[spec.mapKey], 120).trim();
    if (!name) continue;
    const e = {};
    for (const c of spec.cols) if (c.k !== spec.mapKey) e[c.k] = r[c.k] == null ? '' : r[c.k];
    (out[name] = out[name] || []).push(e);
  }
  return out;
}

export function readViewRows(d, spec) {
  const src = (spec.src === 'state' ? d && d.state : d && d.db) || {};
  const raw = src[spec.path];
  if (spec.shape === 'map') return mapToRows(raw, spec);
  return Array.isArray(raw) ? raw : [];
}

/* نوشتنِ آرایهٔ تازه در جای خودش. دو نکته:

   ۱. اگر `state` یا `db` نبود ساخته می‌شود، ولی بقیهٔ کلیدها دست
      نمی‌خورند — این‌جا فقط همین یک بخش نوشته می‌شود.

   ۲. چک‌لیست و برنامهٔ روزانه دو جا هستند: یکی `state.tasks` که
      نسخهٔ کاریِ ماهِ جاری است و یکی `state.monthsData[ماهِ جاری]`.
      صفحه هر دو را به یک شیء وصل می‌کند، ولی روی سرور که JSON
      می‌شوند دو رونوشتِ جدا می‌شوند. اگر فقط یکی نوشته شود، صفحه
      دفعهٔ بعد ماه را عوض می‌کند و نوشتهٔ عضوِ گروه ناپدید می‌شود. */
export function writeViewRows(d, spec, rows) {
  const out = { state: d && d.state ? d.state : null, db: d && d.db ? d.db : null };
  const key = spec.src === 'state' ? 'state' : 'db';
  const box = out[key] = Object.assign({}, out[key] || {});
  box[spec.path] = spec.shape === 'map' ? rowsToMap(rows, spec) : rows;

  if (spec.src === 'state' && spec.month) {
    const mk = box.currentMonthKey;
    if (mk && box.monthsData && typeof box.monthsData === 'object' && box.monthsData[mk]) {
      const md = Object.assign({}, box.monthsData);
      md[mk] = Object.assign({}, md[mk], { [spec.path]: box[spec.path] });
      box.monthsData = md;
    }
  }
  return out;
}

/* ---------- کارهای ردیف ----------
   شناسهٔ ردیف همان شمارهٔ جایش در آرایه است، چون خودِ کارتابل هم
   همین‌طور کار می‌کند و آرایه‌ها شناسهٔ ثابتی ندارند. برای همین هر
   نوشتن `baseRev` می‌خواهد: اگر بین خواندن و نوشتن کسی ردیفی اضافه
   یا کم کرده، درخواست رد می‌شود و صفحه از نو می‌خواند — نه اینکه
   ردیفِ اشتباهی عوض شود. */

function fits(col, v) {
  if (col.kind === 'pick') return !col.opts || col.opts.includes(v) || v === '';
  return true;
}

function coerce(col, v) {
  if (col.kind === 'num' || col.kind === 'money') {
    const s = String(v == null ? '' : v)
      .replace(/[۰-۹]/g, c => String(c.charCodeAt(0) - 0x06F0))
      .replace(/[٠-٩]/g, c => String(c.charCodeAt(0) - 0x0660))
      .replace(/[,\s]/g, '');
    if (s === '') return '';
    const n = Number(s);
    return Number.isFinite(n) ? n : '';
  }
  return cleanStr(v, col.kind === 'text' ? 400 : 60);
}

export function editViewCell(rows, spec, ix, k, v) {
  const i = Number(ix);
  if (!Number.isInteger(i) || i < 0 || i >= rows.length) return { error: 'این ردیف دیگر نیست. صفحه را تازه کنید.' };
  const col = spec.cols.find(c => c.k === String(k));
  if (!col) return { error: 'این ستون را نمی‌شناسم.' };
  if (col.edit === 'never') return { error: 'این ستون دستِ کسی نیست.' };
  const val = coerce(col, v);
  if (!fits(col, val)) return { error: 'این مقدار برای این ستون نیست.' };
  const next = rows.slice();
  next[i] = Object.assign({}, next[i], { [col.k]: val });
  return { rows: next };
}

export function addViewRow(rows, spec, v) {
  if (rows.length >= 5000) return { error: 'این جدول پر است.' };
  const row = {};
  for (const c of spec.cols) {
    const raw = v && v[c.k] != null ? v[c.k] : '';
    const val = coerce(c, raw);
    if (!fits(c, val)) return { error: 'مقدارِ ستونِ «' + c.t + '» درست نیست.' };
    row[c.k] = val;
  }
  /* کلیدهای کمکی که خودِ صفحه می‌سازد و ستون نیستند */
  if (spec.path === 'days') row.day = rows.length + 1;
  return { rows: rows.concat([row]) };
}

export function killViewRow(rows, ix) {
  const i = Number(ix);
  if (!Number.isInteger(i) || i < 0 || i >= rows.length) return { error: 'این ردیف دیگر نیست. صفحه را تازه کنید.' };
  const next = rows.slice();
  next.splice(i, 1);
  return { rows: next };
}

export function moveViewRow(rows, from, to) {
  const a = Number(from), b = Number(to);
  if (!Number.isInteger(a) || !Number.isInteger(b)) return { error: 'جابه‌جایی درست نیست.' };
  if (a < 0 || a >= rows.length || b < 0 || b >= rows.length) return { error: 'این ردیف دیگر نیست. صفحه را تازه کنید.' };
  const next = rows.slice();
  next.splice(b, 0, next.splice(a, 1)[0]);
  return { rows: next };
}
