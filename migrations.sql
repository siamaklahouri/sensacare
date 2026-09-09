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
