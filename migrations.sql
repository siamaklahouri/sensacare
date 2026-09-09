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
