DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS otps;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS articles;
DROP TABLE IF EXISTS pages;
DROP TABLE IF EXISTS settings;
DROP TABLE IF EXISTS counters;
DROP TABLE IF EXISTS bot_chats;

CREATE TABLE categories(
  id TEXT PRIMARY KEY, name TEXT, sub TEXT, acc TEXT, tint TEXT, pos INTEGER DEFAULT 0);

CREATE TABLE products(
  id TEXT PRIMARY KEY, n TEXT NOT NULL, b TEXT, pr INTEGER NOT NULL, old INTEGER DEFAULT 0,
  d TEXT, c TEXT, tag TEXT, img TEXT, stock INTEGER DEFAULT 50,
  size TEXT, thickness TEXT, count TEXT, material TEXT, lube TEXT, expiry TEXT,
  active INTEGER DEFAULT 1, pos INTEGER DEFAULT 0);

CREATE TABLE menu(
  id TEXT PRIMARY KEY, label TEXT, href TEXT, hot INTEGER DEFAULT 0,
  parent TEXT, pos INTEGER DEFAULT 0);

CREATE TABLE users(
  phone TEXT PRIMARY KEY, name TEXT, city TEXT, address TEXT, postal TEXT,
  created INTEGER, last_login INTEGER);

CREATE TABLE otps(
  phone TEXT PRIMARY KEY, code TEXT, expires INTEGER, tries INTEGER DEFAULT 0, sent INTEGER);

CREATE TABLE orders(
  id TEXT PRIMARY KEY, created INTEGER, phone TEXT, name TEXT, city TEXT,
  address TEXT, postal TEXT, note TEXT, lat REAL, lng REAL,
  method TEXT, method_name TEXT, ship INTEGER, goods INTEGER, total INTEGER,
  status TEXT DEFAULT 'ثبت شده', tracking TEXT, guest INTEGER DEFAULT 0,
  pay_method TEXT DEFAULT 'cash', paid INTEGER DEFAULT 0,
  authority TEXT, ref_id TEXT, paid_at INTEGER,
  invoice TEXT, receipt TEXT, notified INTEGER DEFAULT 0);

CREATE TABLE order_items(
  order_id TEXT, product_id TEXT, n TEXT, c TEXT, pr INTEGER, q INTEGER);

CREATE TABLE feedback(
  id INTEGER PRIMARY KEY AUTOINCREMENT, created INTEGER, rating INTEGER,
  text TEXT, order_id TEXT, city TEXT, phone TEXT);

CREATE TABLE articles(
  id TEXT PRIMARY KEY, slug TEXT, title TEXT, excerpt TEXT, body TEXT,
  cover TEXT, created INTEGER, published INTEGER DEFAULT 1, views INTEGER DEFAULT 0);

CREATE TABLE pages(slug TEXT PRIMARY KEY, title TEXT, body TEXT, updated INTEGER);

CREATE TABLE settings(k TEXT PRIMARY KEY, v TEXT);

CREATE TABLE counters(k TEXT PRIMARY KEY, n INTEGER DEFAULT 0);

CREATE TABLE bot_chats(
  platform TEXT, chat_id TEXT, role TEXT, phone TEXT, created INTEGER,
  PRIMARY KEY(platform, chat_id));

CREATE INDEX idx_orders_phone ON orders(phone);
CREATE INDEX idx_orders_created ON orders(created);
CREATE INDEX idx_items_order ON order_items(order_id);
CREATE INDEX idx_products_cat ON products(c);
CREATE INDEX idx_orders_invoice ON orders(invoice);
