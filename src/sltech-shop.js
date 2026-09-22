/* فروشِ کارتابل روی sltech.ir
   =================================================================
   همان شیوه‌ای که فروشگاهِ سِنسا دارد، ولی به اندازهٔ این کار: یک پلن،
   یک خریدار، یک شمارهٔ فاکتور. سبد و کرایه و تخفیف این‌جا معنا ندارد.

   مسیرِ کار:
     ۱. خریدار پلن را انتخاب می‌کند و فرم را پر.
     ۲. شمارهٔ فاکتور و شمارهٔ کارت به او داده می‌شود.
     ۳. کارت‌به‌کارت می‌کند و فیش را با همان شمارهٔ فاکتور برای ربات
        می‌فرستد — که از راهِ همان پیام‌رسانِ پشتیبانی به مدیر می‌رسد.
     ۴. مدیر در پنل «پرداخت شد» می‌زند و کارتابل را می‌سازد.

   پرداختِ آنلاین عمداً نیست: درگاه می‌خواهد و نماد و قرارداد، و تا
   آن روز کارت‌به‌کارت همان کاری را می‌کند که لازم است. */

import { getSetting, all, one, run } from './kartabl.js';
import { toAdmin } from './sltech-bot.js';
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
  const price = Number(plan.price || 0) * seats;
  try {
    await run(env,
      `INSERT INTO sl_orders(id,created,plan,price,days,kind,job,name,contact,seats,note,status,updated)
       VALUES(?,?,?,?,?,?,?,?,?,?,?, 'new', ?)`,
      id, now, plan.name, price, Number(plan.days || 0), kind, job, name, contact, seats, note, now);
  } catch (e) {
    return { error: 'سفارش ثبت نشد: ' + e.message, status: 500 };
  }

  /* خبرش به هر دو ربات — همان‌جایی که فیش هم قرار است بیاید. */
  const lines =
    `پلن: ${plan.name}${seats > 1 ? ` × ${fa(seats)} نفر` : ''}\n` +
    `مبلغ: ${money(price)}\n` +
    `نوع کارتابل: ${KINDS[kind]}${job && JOBS[job] ? ` — ${JOBS[job].label}` : ''}\n` +
    `مدت: ${plan.days ? fa(plan.days) + ' روز' : 'بی‌مهلت'}\n` +
    (note ? `\nتوضیح خریدار:\n${note}\n` : '');
  await toAdmin(env,
    { pf: 'slweb', chat: 'order:' + id, name, phone: contact },
    `🧾 سفارشِ تازه — فاکتور ${id}\n\n${lines}`,
    'سفارش');

  return {
    ok: true, id,
    price, plan: plan.name, days: Number(plan.days || 0),
    card: st.card || '', cardName: st.cardName || '',
    telegram: st.telegram || '', bale: st.bale || ''
  };
}

/* ---------- برای پنل ---------- */
export async function listOrders(env, limit = 100) {
  await ensure(env);
  try {
    return await all(env,
      `SELECT id, created, plan, price, days, kind, job, name, contact, seats, note,
              status, slug, updated
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
