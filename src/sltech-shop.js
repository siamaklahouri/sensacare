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
import { toAdmin, slContact } from './sltech-bot.js';
import { JOBS } from './kartabl-jobs.js';

const KINDS = { gen: 'عمومی', it: 'مدیر IT', fin: 'مالی' };

/* شمارهٔ فاکتور: کوتاه و بی‌ابهام. حرف‌های هم‌شکل (I, O, ۰, ۱) نیستند
   چون این شماره را آدم با دست در پیام می‌نویسد. */
const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
function newInvoice() {
  const r = crypto.getRandomValues(new Uint8Array(6));
  return 'SL-' + [...r].map(b => ALPHABET[b % ALPHABET.length]).join('');
}

const fa = n => String(n).replace(/[0-9]/g, d => '۰۱۲۳۴۵۶۷۸۹'[d]);
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
    'ALTER TABLE sl_orders ADD COLUMN discount INTEGER NOT NULL DEFAULT 0'
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

/* ---------- ثبت سفارش ---------- */
export async function placeOrder(env, body) {
  const st = (await getSetting(env, 'sltechSite', {})) || {};
  const plans = Array.isArray(st.plans) ? st.plans : [];
  if (!plans.length) return { error: 'فعلاً پلنی برای فروش تعریف نشده.', status: 503 };

  const txt = (v, n) => String(v == null ? '' : v).trim().slice(0, n);
  const name = txt(body.name, 60);
  const contact = txt(body.contact, 80);
  const job = txt(body.job, 30);
  const kind = KINDS[body.kind] ? body.kind : 'gen';
  const note = txt(body.note, 500);
  const seats = Math.min(Math.max(parseInt(body.seats, 10) || 1, 1), 200);

  if (!name) return { error: 'نامتان را بنویسید.' };
  if (!contact) return { error: 'یک راهِ تماس بگذارید، وگرنه نمی‌شود خبرتان کرد.' };
  if (job && !JOBS[job]) return { error: 'شغلِ انتخاب‌شده را نمی‌شناسم.' };

  /* پلن با نامش می‌آید ولی قیمت از سرور خوانده می‌شود، نه از مرورگر —
     وگرنه هر کسی می‌توانست قیمتِ دلخواهش را بفرستد. */
  const plan = plans.find(p => p.name === txt(body.plan, 40));
  if (!plan) return { error: 'این پلن را نمی‌شناسم.' };

  await ensure(env);
  const id = newInvoice();
  const now = Date.now();
  const full = Number(plan.price || 0) * seats;

  /* کدِ نامعتبر سفارش را رد نمی‌کند، فقط تخفیف نمی‌دهد و همان را
     می‌گوید — وگرنه کسی که کدِ منقضی داشته، کلِ خریدش می‌پرید. */
  const cp = await checkCoupon(env, body.coupon, full);
  const off = cp.error ? 0 : (cp.off || 0);
  const price = full - off;
  try {
    await run(env,
      `INSERT INTO sl_orders(id,created,plan,price,days,kind,job,name,contact,seats,note,status,updated,coupon,discount)
       VALUES(?,?,?,?,?,?,?,?,?,?,?, 'new', ?,?,?)`,
      id, now, plan.name, price, Number(plan.days || 0), kind, job, name, contact, seats, note, now,
      off ? cp.code : '', off);
    if (off) await run(env, 'UPDATE sl_coupons SET used = used + 1 WHERE code=?', cp.code);
  } catch (e) {
    return { error: 'سفارش ثبت نشد: ' + e.message, status: 500 };
  }

  /* خبرش به هر دو ربات — همان‌جایی که فیش هم قرار است بیاید. */
  const lines =
    `پلن: ${plan.name}${seats > 1 ? ` × ${fa(seats)} نفر` : ''}\n` +
    (off ? `مبلغ: ${money(full)}\nتخفیف (${cp.code}): ${money(off)}\nقابل پرداخت: ${money(price)}\n`
         : `مبلغ: ${money(price)}\n`) +
    `نوع کارتابل: ${KINDS[kind]}${job && JOBS[job] ? ` — ${JOBS[job].label}` : ''}\n` +
    `مدت: ${plan.days ? fa(plan.days) + ' روز' : 'بی‌مهلت'}\n` +
    (note ? `\nتوضیح خریدار:\n${note}\n` : '');
  await toAdmin(env,
    { pf: 'slweb', chat: 'order:' + id, name, phone: contact },
    `🧾 سفارشِ تازه — فاکتور ${id}\n\n${lines}`,
    'سفارش');

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
