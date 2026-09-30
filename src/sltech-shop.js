/* فروشِ کارتابل روی sltech.ir
   =================================================================
   همان شیوه‌ای که فروشگاهِ سِنسا دارد، ولی به اندازهٔ این کار: یک پلن،
   یک خریدار، یک شمارهٔ فاکتور. سبد و کرایه این‌جا معنا ندارد.

   مسیرِ کار:
     ۱. خریدار پلن را انتخاب می‌کند و فرم را پر.
     ۲. شمارهٔ فاکتور و شمارهٔ کارت به او داده می‌شود.
     ۳. کارت‌به‌کارت می‌کند و فیش را با همان شمارهٔ فاکتور برای ربات
        می‌فرستد — که از راهِ همان پیام‌رسانِ پشتیبانی به مدیر می‌رسد.
     ۴. مدیر در پنل «پرداخت شد» می‌زند و کارتابل را می‌سازد.

   پرداختِ آنلاین عمداً نیست: درگاه می‌خواهد و نماد و قرارداد، و تا
   آن روز کارت‌به‌کارت همان کاری را می‌کند که لازم است. */

import { getSetting, all, one, run } from './kartabl.js';
import { toAdmin, slContact, slSend, SL_PF } from './sltech-bot.js';
import { JOBS } from './kartabl-jobs.js';
import { PRESET_LABEL } from './sections.js';

const KINDS = { gen: 'عمومی', it: 'مدیر IT', fin: 'مالی' };

/* بخش‌هایی که در قیمتِ پایه هستند و پول نمی‌گیرند. بقیهٔ بخش‌های هر
   شغل، هرکدام جداگانه حساب می‌شوند. «تبدیل» این‌جاست چون در همهٔ
   شغل‌ها هست و رایگان است؛ «گزارش‌ساز» نیست، پس اضافه حساب می‌شود. */
export const FREE_VIEWS = ['datetools'];

/* نامِ فارسیِ بخش‌ها، برای فاکتور و پیامِ مدیر. */
export const VIEW_LABEL = {
  servers: 'سرورها و بکاپ', companies: 'شرکت‌ها', mvpn: 'سرویس MVPN',
  datetools: 'تبدیل', report: 'گزارش‌ساز',
  invoices: 'سررسید اسناد دریافتنی', payables: 'بدهی‌ها و پرداخت‌ها',
  payablenotes: 'اسناد پرداختنی', receivablenotes: 'اسناد دریافتنی',
  expenses: 'منابع و مصارف', bank: 'حساب‌های بانکی',
  budget: 'بودجه‌بندی ماهانه', parties: 'طرف‌حساب‌ها'
};
Object.assign(VIEW_LABEL, PRESET_LABEL);
const viewName = v => VIEW_LABEL[v] || v;

/* شمارهٔ فاکتور: کوتاه و بی‌ابهام. حرف‌های هم‌شکل (I, O, ۰, ۱) نیستند
   چون این شماره را آدم با دست در پیام می‌نویسد. */
const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
function newInvoice() {
  const r = crypto.getRandomValues(new Uint8Array(6));
  return 'SL-' + [...r].map(b => ALPHABET[b % ALPHABET.length]).join('');
}

const fa = n => String(n).replace(/[0-9]/g, d => '۰۱۲۳۴۵۶۷۸۹'[d]);
/* متنِ فاکتور با parse_mode=HTML می‌رود، پس هر چه از کاربر آمده باید
   بی‌خطر شود — وگرنه یک «<» در نامِ پلن کلِ پیام را می‌شکند. */
const esc = t => String(t == null ? '' : t)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const money = n => fa(Number(n || 0).toLocaleString('en-US')) + ' تومان';

/* جدول ممکن است هنوز ساخته نشده باشد (مهاجرت نرفته). در آن حالت
   به‌جای خطای گنگ، همان را می‌گوییم. */
async function ensure(env) {
  try {
    await run(env, `CREATE TABLE IF NOT EXISTS sl_orders (
      id TEXT PRIMARY KEY, created INTEGER NOT NULL, plan TEXT NOT NULL DEFAULT '',
      price INTEGER NOT NULL DEFAULT 0, days INTEGER NOT NULL DEFAULT 0,
      kind TEXT NOT NULL DEFAULT 'gen', job TEXT NOT NULL DEFAULT '',
      name TEXT NOT NULL DEFAULT '', contact TEXT NOT NULL DEFAULT '',
      seats INTEGER NOT NULL DEFAULT 1, note TEXT NOT NULL DEFAULT '',
      status TEXT NOT NULL DEFAULT 'new', slug TEXT NOT NULL DEFAULT '',
      updated INTEGER NOT NULL DEFAULT 0)`);
  } catch (e) { /* بود، یا نمی‌شود ساخت — پایین‌تر معلوم می‌شود */ }

  /* دو ستونِ تخفیف. «ADD COLUMN» بارِ دوم خطا می‌دهد و SQLite هم
     «IF NOT EXISTS» ندارد، پس خطایش را می‌بلعیم — همان بار اول
     می‌نشیند و بعدش بی‌اثر است. */
  for (const sql of [
    "ALTER TABLE sl_orders ADD COLUMN coupon TEXT NOT NULL DEFAULT ''",
    'ALTER TABLE sl_orders ADD COLUMN discount INTEGER NOT NULL DEFAULT 0',
    /* گفتگوی خریدار در ربات: فاکتور و خبرِ وضعیت به همین‌جا برمی‌گردد،
       و فیشی که می‌فرستد به همین سفارش می‌چسبد. */
    "ALTER TABLE sl_orders ADD COLUMN pf TEXT NOT NULL DEFAULT ''",
    "ALTER TABLE sl_orders ADD COLUMN chat TEXT NOT NULL DEFAULT ''",
    /* نوعِ پلن، بخش‌های انتخابی، و — برای سفارشِ سازمانی — نامِ سازمان
       و توضیحِ بخشِ مشترک. بدونِ این‌ها فاکتور می‌گفت «چند نفر» ولی
       نمی‌گفت «چه چیزی». */
    "ALTER TABLE sl_orders ADD COLUMN tier TEXT NOT NULL DEFAULT 'personal'",
    "ALTER TABLE sl_orders ADD COLUMN views TEXT NOT NULL DEFAULT '[]'",
    "ALTER TABLE sl_orders ADD COLUMN customs TEXT NOT NULL DEFAULT '[]'",
    "ALTER TABLE sl_orders ADD COLUMN orgname TEXT NOT NULL DEFAULT ''",
    "ALTER TABLE sl_orders ADD COLUMN sharednote TEXT NOT NULL DEFAULT ''"
  ]) { try { await run(env, sql); } catch (e) { /* از قبل بود */ } }

  try {
    await run(env, `CREATE TABLE IF NOT EXISTS sl_coupons (
      code TEXT PRIMARY KEY, kind TEXT NOT NULL DEFAULT 'percent',
      value INTEGER NOT NULL DEFAULT 0, min_total INTEGER NOT NULL DEFAULT 0,
      max_uses INTEGER NOT NULL DEFAULT 0, used INTEGER NOT NULL DEFAULT 0,
      expires INTEGER NOT NULL DEFAULT 0, active INTEGER NOT NULL DEFAULT 1,
      note TEXT NOT NULL DEFAULT '', created INTEGER NOT NULL DEFAULT 0)`);
  } catch (e) { /* بود */ }
}

/* ---------- کد تخفیف ----------
   کد از مرورگر می‌آید ولی حساب‌وکتابش این‌جاست. هیچ‌وقت به عددی که
   مرورگر فرستاده اعتماد نمی‌کنیم — مرورگر فقط می‌گوید «این کد را
   زده‌ام»، بقیه‌اش کارِ سرور است. */
export async function checkCoupon(env, rawCode, total) {
  const code = String(rawCode || '').trim().toUpperCase().slice(0, 40);
  if (!code) return { off: 0, code: '' };
  await ensure(env);
  const c = await one(env, 'SELECT * FROM sl_coupons WHERE code=?', code);
  if (!c || !c.active) return { error: 'این کد معتبر نیست.' };
  if (c.expires && Date.now() > c.expires) return { error: 'تاریخِ این کد گذشته.' };
  if (c.max_uses && c.used >= c.max_uses) return { error: 'سقفِ استفاده از این کد پر شده.' };
  if (c.min_total && total < c.min_total)
    return { error: 'این کد از ' + money(c.min_total) + ' به بالا کار می‌کند.' };

  /* تخفیف از خودِ مبلغ بیشتر نمی‌شود — وگرنه فاکتورِ منفی می‌ساخت. */
  const raw = c.kind === 'amount'
    ? Number(c.value || 0)
    : Math.round(total * Number(c.value || 0) / 100);
  const off = Math.max(0, Math.min(raw, total));
  return { off, code, kind: c.kind, value: Number(c.value || 0), final: total - off };
}

/* ---------- حسابِ قیمت ----------
   یک فرمول برای هر دو نوعِ پلن:

     پایه   = price + max(۰، نفرات − baseSeats) × perSeat
     اضافه  = تعدادِ بخش‌های غیرِ دیفالت × extraPrice
     سفارشی = تعدادِ بخش‌هایی که کاستوم می‌شوند × customPrice

   «شخصی» یعنی baseSeats=۱ و perSeat=price، پس همان «هر کارتابل یک
   قیمت» می‌شود. «سازمانی» تا تعدادِ پایه ثابت است و بعد نفر به نفر.

   این‌جا و در صفحهٔ خرید یک حساب اجرا می‌شود؛ ولی آن‌که فاکتور را
   می‌سازد همین است، نه مرورگر. */
/* قیمتِ یک بخش. اگر برایش قیمتِ جدا گذاشته شده باشد همان، وگرنه
   قیمتِ عمومیِ بخش‌ها. این‌طور می‌شود «شرکت‌ها» را ارزان و «گزارش‌ساز»
   را گران گذاشت، بدونِ اینکه لازم باشد برای همه عدد نوشت. */
/* قیمتِ پیشنهادیِ چند بخش، تا سایت از روزِ اول عددِ معقول نشان دهد
   حتی پیش از آنکه ادمین چیزی نوشته باشد. هر کدام در پنل قابلِ
   عوض کردن است و عددِ پنل همیشه می‌چربد. */
/* دو پلنِ پیشنهادی. پنل با یک دکمه همین‌ها را در فرم می‌گذارد تا
   لازم نباشد هفت خانه را دستی و بی‌اشتباه پر کرد. عددها همان‌هایی‌اند
   که قرار شد؛ هر کدام در پنل قابلِ عوض کردن است. */
export const DEFAULT_PLANS = [
  { name: 'پلنر شخصی', tier: 'personal',
    price: 1000000, baseSeats: 1, perSeat: 1000000, days: 30,
    note: 'برای یک نفر — هر شغلی' },
  { name: 'سازمانی', tier: 'org',
    price: 4000000, baseSeats: 2, perSeat: 750000, days: 30,
    note: 'از دو نفر به بالا' }
];

export const DEFAULT_VIEW_PRICE = {
  report: 450000,
  contracts: 350000, assets: 300000, vendors: 300000,
  meetings: 250000, feedback: 250000, training: 250000
};

export function viewPrice(st, v) {
  const map = (st && st.viewPrices) || {};
  const own = Number(map[v]);
  if (Number.isFinite(own) && own >= 0) return Math.round(own);
  const std = Number(st && st.extraPrice);
  if (Number.isFinite(std) && std > 0) return Math.round(std);
  return Math.max(0, Math.round(DEFAULT_VIEW_PRICE[v] || 0));
}

export function planTotal(plan, st, { seats = 1, views = [], customs = [] } = {}) {
  const base = Math.max(0, Number(plan.price || 0));
  const baseSeats = Math.max(1, Math.round(Number(plan.baseSeats) || 1));
  const perSeat = Math.max(0, Math.round(Number(plan.perSeat) || 0));
  const n = Math.max(1, Math.round(Number(seats) || 1));
  const arr = v => Array.isArray(v) ? v : [];

  const seatPart = base + Math.max(0, n - baseSeats) * perSeat;
  /* هر بخش قیمتِ خودش. پیش از این همه یک عدد بودند و نمی‌شد گفت
     «این یکی گران‌تر است».

     و قیمتِ هر بخش «به ازای هر نفر» است، نه یک‌بار برای کلِ سازمان:
     بخش را همهٔ کارتابل‌ها می‌گیرند، پس مثلِ خودِ پلن نفر به نفر
     حساب می‌شود. پیش از این ضرب نمی‌شد، یعنی سازمانِ پنجاه‌نفره
     بابتِ گزارش‌ساز همان‌قدر می‌داد که سازمانِ دونفره. */
  const extraPart = n * arr(views).reduce((t, v) => t + viewPrice(st, v), 0);
  /* ولی سفارشی‌سازی ضرب نمی‌شود: آن هزینهٔ یک‌بارِ ساختنِ آن بخش است،
     نه اجازهٔ استفاده‌اش. ضرب کردنش یعنی بابتِ یک کارِ توسعه، به
     تعدادِ نفرات پول گرفتن. */
  const customPart = arr(customs).length *
                     Math.max(0, Math.round(Number(st && st.customPrice) || 0));

  return { seatPart, extraPart, customPart, total: seatPart + extraPart + customPart };
}

/* ---------- ثبت سفارش ---------- */
export async function placeOrder(env, body) {
  const st = (await getSetting(env, 'sltechSite', {})) || {};
  const plans = Array.isArray(st.plans) ? st.plans : [];
  if (!plans.length) return { error: 'فعلاً پلنی برای فروش تعریف نشده.', status: 503 };

  const txt = (v, n) => String(v == null ? '' : v).trim().slice(0, n);
  /* خریدار باید به رباتِ خودِ SLTech وصل شده باشد. شماره و گفتگو از
     همان ردیفی خوانده می‌شود که ربات پر کرده، نه از حرفِ مرورگر —
     وگرنه هر کسی می‌توانست شمارهٔ دیگری را به سفارش بچسباند. */
  const nonce = txt(body.nonce, 40);
  const login = nonce
    ? await one(env, "SELECT * FROM bot_logins WHERE nonce=? AND status='ready'", nonce)
    : null;
  if (!login || !login.phone)
    return { error: 'اول با تلگرام یا بله وصل شوید تا شماره‌تان تأیید شود.', status: 401 };
  if (Date.now() - login.created > 30 * 60000)
    return { error: 'وقتِ اتصال گذشت. دوباره وصل شوید.', status: 410 };

  const name = txt(body.name, 60) || txt(login.name, 60);
  const contact = login.phone;
  const job = txt(body.job, 30);
  const kind = KINDS[body.kind] ? body.kind : 'gen';
  const note = txt(body.note, 500);
  const rawSeats = Math.min(Math.max(parseInt(body.seats, 10) || 1, 1), 200);

  if (!name) return { error: 'نامتان را بنویسید.' };
  if (job && !JOBS[job]) return { error: 'شغلِ انتخاب‌شده را نمی‌شناسم.' };

  /* بخش‌هایی که خریدار خواسته. فقط آن‌هایی پذیرفته می‌شوند که واقعاً
     بخشی از همین شغل‌اند — وگرنه کسی می‌توانست بخشی را سفارش دهد که
     در قالبِ کارتابلش اصلاً وجود ندارد و بعد پولش را داده باشد. */
  /* آنچه می‌شود سفارش داد: بخش‌های خودِ قالب، به‌علاوهٔ بخش‌های آماده
     که از روی الگو ساخته می‌شوند. */
  const j = job && JOBS[job] ? JOBS[job] : null;
  const jobViews = j ? [...(j.views || []), ...(j.extras || [])] : [];
  const pickList = (v, pool) => {
    const seen = new Set();
    return (Array.isArray(v) ? v : [])
      .map(x => txt(x, 30))
      .filter(x => x && pool.includes(x) && !seen.has(x) && seen.add(x))
      .slice(0, 30);
  };
  const views = pickList(body.views, jobViews.filter(v => !FREE_VIEWS.includes(v)));
  const customs = pickList(body.customs, views);
  const orgName = txt(body.orgName, 80);
  const sharedNote = txt(body.sharedNote, 300);

  /* پلن با نامش می‌آید ولی قیمت از سرور خوانده می‌شود، نه از مرورگر —
     وگرنه هر کسی می‌توانست قیمتِ دلخواهش را بفرستد. */
  const plan = plans.find(p => p.name === txt(body.plan, 40));
  if (!plan) return { error: 'این پلن را نمی‌شناسم.' };

  /* پلنِ سازمانی از تعدادِ پایه شروع می‌شود و کمتر از آن معنا ندارد.
     صفحه هم همین را می‌گذارد، ولی حرفِ مرورگر سند نیست: بی این،
     می‌شد سفارشِ «سازمانی، ۱ نفر» فرستاد و فاکتور همان را می‌نوشت. */
  const minSeats = Math.max(1, Math.round(Number(plan.baseSeats) || 1));
  if (rawSeats < minSeats)
    return { error: 'این پلن از ' + fa(minSeats) + ' نفر به بالاست.' };
  const seats = rawSeats;

  await ensure(env);
  const id = newInvoice();
  const now = Date.now();
  const bill = planTotal(plan, st, { seats, views, customs });
  const full = bill.total;

  /* کدِ نامعتبر سفارش را رد نمی‌کند، فقط تخفیف نمی‌دهد و همان را
     می‌گوید — وگرنه کسی که کدِ منقضی داشته، کلِ خریدش می‌پرید. */
  const cp = await checkCoupon(env, body.coupon, full);
  const off = cp.error ? 0 : (cp.off || 0);
  const price = full - off;
  try {
    await run(env,
      `INSERT INTO sl_orders(id,created,plan,price,days,kind,job,name,contact,seats,note,status,updated,coupon,discount,pf,chat,tier,views,customs,orgname,sharednote)
       VALUES(?,?,?,?,?,?,?,?,?,?,?, 'new', ?,?,?,?,?,?,?,?,?,?)`,
      id, now, plan.name, price, Number(plan.days || 0), kind, job, name, contact, seats, note, now,
      off ? cp.code : '', off, login.platform || '', String(login.chat_id || ''),
      plan.tier === 'org' ? 'org' : 'personal',
      JSON.stringify(views), JSON.stringify(customs), orgName, sharedNote);
    if (off) await run(env, 'UPDATE sl_coupons SET used = used + 1 WHERE code=?', cp.code);
  } catch (e) {
    return { error: 'سفارش ثبت نشد: ' + e.message, status: 500 };
  }

  /* خبرش به هر دو ربات — همان‌جایی که فیش هم قرار است بیاید. */
  const unit = plan.tier === 'org' ? 'نفر' : 'کارتابل';
  const lines =
    `پلن: ${plan.name}${seats > 1 ? ` × ${fa(seats)} ${unit}` : ''}\n` +
    (orgName ? `سازمان: ${orgName}\n` : '') +
    `شغل: ${job && JOBS[job] ? JOBS[job].label : KINDS[kind]}\n` +
    (views.length
      ? `بخش‌های اضافه: ${views.map(viewName).join('، ')}\n` +
        (customs.length ? `سفارشی‌سازی: ${customs.map(viewName).join('، ')}\n` : '')
      : '') +
    (sharedNote ? `بخشِ مشترک: ${sharedNote}\n` : '') +
    `مدت: ${plan.days ? fa(plan.days) + ' روز' : 'بی‌مهلت'}\n\n` +
    `پایه: ${money(bill.seatPart)}\n` +
    /* «× چند نفر» در فاکتور می‌آید، وگرنه عدد با قیمتی که کنارِ هر
       بخش دیده بود نمی‌خواند و به نظرش اشتباه می‌رسد. */
    (bill.extraPart ? `بخش‌های اضافه (${fa(seats)} ${unit}): ${money(bill.extraPart)}\n` : '') +
    (bill.customPart ? `سفارشی‌سازی (یک‌بار): ${money(bill.customPart)}\n` : '') +
    (off ? `جمع: ${money(full)}\nتخفیف (${cp.code}): ${money(off)}\nقابل پرداخت: ${money(price)}\n`
         : `قابل پرداخت: ${money(price)}\n`) +
    (note ? `\nتوضیح خریدار:\n${note}\n` : '');
  /* خبر به مدیر — با گفتگوی واقعیِ خریدار، پس ریپلای هم به خودش
     می‌رسد؛ برخلافِ پیامِ فرمِ سایت که گفتگویی نداشت. */
  await toAdmin(env,
    { pf: login.platform || 'slweb', chat: String(login.chat_id || 'order:' + id),
      name, phone: contact },
    `🧾 سفارشِ تازه — فاکتور ${id}\n\n${lines}`,
    'سفارش');

  /* و فاکتور برای خودِ خریدار، در همان گفتگویی که با آن وصل شده. */
  const kindOf = { sltg: 'telegram', slbale: 'bale' };
  const myKind = kindOf[login.platform];
  if (myKind && login.chat_id) {
    const ct = slContact(st);
    await slSend(env, myKind, { chat_id: String(login.chat_id), parse_mode: 'HTML',
      text: `🧾 <b>فاکتور ${esc(id)}</b>\n\n${esc(lines)}\n` +
            (st.card ? `💳 کارت: <code>${esc(st.card)}</code>` +
                       (st.cardName ? `\n به نامِ ${esc(st.cardName)}` : '') + '\n\n' : '') +
            `مبلغ را کارت‌به‌کارت کن و <b>عکسِ فیش را همین‌جا بفرست</b>.\n` +
            `بعدش کارتابلت ساخته می‌شود و آدرس و رمزش را همین‌جا می‌گیری.\n\n` +
            `سؤالی بود همین‌جا بنویس — یا ${esc('@' + (ct.telegram || ''))}` });
  }

  return {
    ok: true, id,
    price, full, discount: off, coupon: off ? cp.code : '',
    couponError: cp.error || '',
    plan: plan.name, days: Number(plan.days || 0),
    card: st.card || '', cardName: st.cardName || '',
    ...slContact(st)
  };
}

/* ---------- برای پنل ---------- */
export async function listOrders(env, limit = 100) {
  await ensure(env);
  try {
    return await all(env,
      `SELECT id, created, plan, price, days, kind, job, name, contact, seats, note,
              status, slug, updated, coupon, discount
         FROM sl_orders ORDER BY created DESC LIMIT ?`, limit);
  } catch (e) { return []; }
}

const STATUS = new Set(['new', 'paid', 'done', 'canceled']);

export async function setOrder(env, id, patch) {
  await ensure(env);
  const row = await one(env, 'SELECT id FROM sl_orders WHERE id=?', id);
  if (!row) return { error: 'چنین فاکتوری نیست.', status: 404 };
  const status = patch.status;
  if (status !== undefined && !STATUS.has(status)) return { error: 'وضعیت درست نیست.' };
  const slug = patch.slug === undefined ? null : String(patch.slug || '').slice(0, 40);
  await run(env,
    `UPDATE sl_orders SET status = COALESCE(?, status),
                          slug = COALESCE(?, slug),
                          updated = ? WHERE id = ?`,
    status === undefined ? null : status, slug, Date.now(), id);
  return { ok: true };
}


/* ---------- کدها، برای پنل ---------- */
export async function listCoupons(env) {
  await ensure(env);
  try {
    return await all(env,
      `SELECT code, kind, value, min_total, max_uses, used, expires, active, note, created
         FROM sl_coupons ORDER BY created DESC LIMIT 200`);
  } catch (e) { return []; }
}

const CODE_RE = /^[A-Z0-9][A-Z0-9-]{1,30}$/;

export async function saveCoupon(env, body) {
  await ensure(env);
  const code = String(body.code || '').trim().toUpperCase().slice(0, 40);
  if (!CODE_RE.test(code))
    return { error: 'کد فقط حروف انگلیسی، عدد و خط تیره — بین ۲ تا ۳۱ حرف.' };
  const kind = body.kind === 'amount' ? 'amount' : 'percent';
  const value = Number(body.value);
  if (!Number.isFinite(value) || value <= 0)
    return { error: 'مقدارِ تخفیف باید عددی بزرگ‌تر از صفر باشد.' };
  if (kind === 'percent' && value > 100)
    return { error: 'درصد نمی‌تواند از ۱۰۰ بیشتر باشد.' };
  const minTotal = Math.max(0, Number(body.min_total) || 0);
  const maxUses = Math.max(0, Number(body.max_uses) || 0);
  /* مهلت به روز گرفته می‌شود، مثل مهلتِ خودِ کارتابل‌ها. */
  const days = Number(body.days);
  const expires = Number.isFinite(days) && days > 0
    ? Date.now() + Math.round(days) * 86400000 : 0;

  await run(env,
    `INSERT INTO sl_coupons(code,kind,value,min_total,max_uses,used,expires,active,note,created)
     VALUES(?,?,?,?,?, COALESCE((SELECT used FROM sl_coupons WHERE code=?),0), ?,?,?,?)
     ON CONFLICT(code) DO UPDATE SET kind=excluded.kind, value=excluded.value,
       min_total=excluded.min_total, max_uses=excluded.max_uses,
       expires=excluded.expires, active=excluded.active, note=excluded.note`,
    code, kind, Math.round(value), minTotal, maxUses, code, expires,
    body.active === false ? 0 : 1, String(body.note || '').slice(0, 120), Date.now());
  return { ok: true, code };
}

export async function dropCoupon(env, code) {
  await ensure(env);
  await run(env, 'DELETE FROM sl_coupons WHERE code=?', String(code || '').toUpperCase());
  return { ok: true };
}
