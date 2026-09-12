-- مهاجرت‌های امن.
-- این فایل هر بار موقع استقرار اجرا می‌شود، پس فقط چیزهایی اینجا می‌آید
-- که اجرای دوباره‌شان بی‌خطر باشد. هیچ‌وقت DROP یا DELETE اینجا ننویسید —
-- برای ساخت اولیهٔ دیتابیس، schema.sql هست.

-- ورود با ربات تلگرام/بله
CREATE TABLE IF NOT EXISTS bot_logins(
  nonce TEXT PRIMARY KEY,
  created INTEGER,
  platform TEXT,
  chat_id TEXT,
  phone TEXT,
  name TEXT,
  status TEXT DEFAULT 'pending');

CREATE INDEX IF NOT EXISTS idx_bot_logins_created ON bot_logins(created);

-- مشتری در مرحلهٔ سفارش می‌تواند بخواهد فاکتور چاپی داخل بسته باشد
CREATE TABLE IF NOT EXISTS order_extras(
  order_id TEXT PRIMARY KEY,
  wants_invoice INTEGER DEFAULT 0);

-- عکس محصولات جدا از جدول محصولات نگهداری می‌شود، تا در هر بار باز شدن
-- صفحه همراه فهرست محصولات فرستاده نشود.
CREATE TABLE IF NOT EXISTS product_images(
  product_id TEXT PRIMARY KEY,
  data TEXT,
  updated INTEGER);

-- گفتگوی پشتیبانی: پیام مشتری در ربات به مدیر می‌رسد و جواب مدیر
-- به همان مشتری برمی‌گردد.
CREATE TABLE IF NOT EXISTS support_msgs(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created INTEGER,
  platform TEXT,
  chat_id TEXT,
  name TEXT,
  phone TEXT,
  dir TEXT,                       -- in: از مشتری، out: جواب پشتیبان
  text TEXT);

CREATE INDEX IF NOT EXISTS idx_support_created ON support_msgs(created);

-- وقتی پیام مشتری برای مدیر فرستاده می‌شود، شمارهٔ همان پیام اینجا
-- می‌ماند تا اگر مدیر رویش «ریپلای» کرد، بدانیم جواب برای کیست.
CREATE TABLE IF NOT EXISTS support_relay(
  platform TEXT,
  admin_chat TEXT,
  message_id TEXT,
  cust_platform TEXT,
  cust_chat TEXT,
  created INTEGER,
  PRIMARY KEY(platform, admin_chat, message_id));

-- شمارندهٔ محدودیت درخواست. هر ردیف یک پنجرهٔ زمانی برای یک کلید است.
CREATE TABLE IF NOT EXISTS rate_limits(
  k TEXT PRIMARY KEY,
  n INTEGER DEFAULT 0,
  reset INTEGER);
CREATE INDEX IF NOT EXISTS idx_rate_reset ON rate_limits(reset);

-- کد تخفیف. مقدار و شرط‌ها اینجا می‌مانند و همیشه سمت سرور حساب می‌شوند،
-- تا از مرورگر قابل دستکاری نباشد.
CREATE TABLE IF NOT EXISTS coupons(
  code TEXT PRIMARY KEY,            -- همیشه با حروف بزرگ ذخیره می‌شود
  kind TEXT DEFAULT 'percent',      -- percent یا amount
  value INTEGER DEFAULT 0,          -- درصد، یا مبلغ به تومان
  min_total INTEGER DEFAULT 0,      -- حداقل خرید لازم
  max_uses INTEGER DEFAULT 0,       -- ۰ یعنی بی‌نهایت
  used INTEGER DEFAULT 0,
  expires INTEGER DEFAULT 0,        -- ۰ یعنی بدون تاریخ انقضا
  active INTEGER DEFAULT 1,
  created INTEGER);

-- آمار بازدید. فقط شمارش روزانه نگه داشته می‌شود — نه آی‌پی، نه شناسهٔ
-- کاربر، نه هیچ چیزی که بشود با آن کسی را دنبال کرد. هیچ سرویس بیرونی
-- هم در کار نیست، چون فرستادن رفتار بازدیدکنندهٔ این فروشگاه به شرکت
-- دیگری با قول محرمانگی جور درنمی‌آید.
CREATE TABLE IF NOT EXISTS visits(
  day TEXT,                         -- YYYY-MM-DD
  kind TEXT,                        -- home | product | article | page | other
  key TEXT,                         -- شناسهٔ محصول یا نشانی صفحه
  n INTEGER DEFAULT 0,
  PRIMARY KEY(day, kind, key));
CREATE INDEX IF NOT EXISTS idx_visits_day ON visits(day);

-- تخفیفِ هر سفارش در جدول خودش می‌ماند. ALTER TABLE اینجا نمی‌آید چون این
-- فایل هر بار موقع استقرار اجرا می‌شود و بار دوم خطا می‌داد و کل استقرار
-- را می‌خواباند.
CREATE TABLE IF NOT EXISTS order_discounts(
  order_id TEXT PRIMARY KEY,
  code TEXT,
  amount INTEGER DEFAULT 0);

-- ۴ پرسش بی‌نام روی صفحهٔ محصول. هیچ نام و شماره‌ای ذخیره نمی‌شود؛ فقط
-- خودِ متن. تا وقتی مدیر تأیید نکند، نمایش داده نمی‌شود.
CREATE TABLE IF NOT EXISTS questions(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id TEXT,
  q TEXT,
  a TEXT,
  created INTEGER,
  answered INTEGER DEFAULT 0,
  published INTEGER DEFAULT 0);
CREATE INDEX IF NOT EXISTS idx_q_product ON questions(product_id, published);

-- ۵ «خبرم کن» وقتی کالا موجود شد. به گفتگوی ربات وصل است، نه به شماره.
CREATE TABLE IF NOT EXISTS restock_watch(
  product_id TEXT,
  platform TEXT,
  chat_id TEXT,
  created INTEGER,
  PRIMARY KEY(product_id, platform, chat_id));

-- ۲ یادآور خرید دوباره — تا برای یک سفارش دوبار فرستاده نشود.
CREATE TABLE IF NOT EXISTS reorder_sent(
  order_id TEXT PRIMARY KEY,
  sent INTEGER);

-- ۷ محصول‌های مرتبط با هر مقاله (چند شناسه با ویرگول)
CREATE TABLE IF NOT EXISTS article_products(
  slug TEXT PRIMARY KEY,
  ids TEXT);

/* آستانهٔ ارسال رایگان روی ۶۰۰ هزار تومان. ارسال ۲۵۰ تا ۴۰۰ هزار است و
   میانگین قیمت کالا حدود ۱۵۰ هزار، یعنی خریدِ تک‌قلمی برای مشتری صرف
   نمی‌کرد. فقط یک‌بار اجرا می‌شود؛ بعد از آن هر عددی که در پنل بگذارید
   دست‌نخورده می‌ماند، حتی اگر صفر باشد. */
UPDATE settings SET v='600000'
  WHERE k='freeOver'
    AND NOT EXISTS (SELECT 1 FROM settings WHERE k='freeOverSet');
INSERT OR IGNORE INTO settings(k,v) VALUES('freeOverSet','1');
