/* ==================== دیتابیس: D1 روی SQLite ====================
   کد در ۶۹ جا با env.DB حرف می‌زند، همیشه با همین چند دستور:

     env.DB.prepare(sql).bind(...).all()    -> { results: [...] }
     env.DB.prepare(sql).bind(...).first()  -> یک ردیف یا null
     env.DB.prepare(sql).bind(...).run()    -> { meta: { changes } }
     env.DB.batch([stmt, stmt, ...])        -> همه با هم، در یک تراکنش

   این فایل همان چند دستور را روی SQLite‌ی خودِ نود پیاده می‌کند، با
   همان شکلِ ورودی و خروجی. نتیجه: هیچ‌کدام از آن ۶۹ جا عوض نمی‌شود.

   SQLite‌ی نود همگام است و D1 ناهمگام؛ برای همین همه‌چیز در تابعِ
   async پیچیده شده تا await کردنش مثلِ قبل جواب بدهد. */

import { DatabaseSync } from 'node:sqlite';

/* D1 به undefined و boolean اجازه می‌دهد، SQLite‌ی نود نه. همان‌جا
   ترجمه می‌شوند تا یک فراموشیِ کوچک در کد، به خطای زمانِ اجرا نرسد. */
const val = v => {
  if (v === undefined || v === null) return null;
  if (typeof v === 'boolean') return v ? 1 : 0;
  if (typeof v === 'bigint') return Number(v);
  if (v instanceof Date) return v.getTime();
  return v;
};

class Stmt {
  constructor(db, sql, params) { this.db = db; this.sql = sql; this.params = params || []; }

  /* D1 با bind یک statementِ تازه می‌دهد و اصلی را دست نمی‌زند. */
  bind(...args) { return new Stmt(this.db, this.sql, args.map(val)); }

  _s() { return this.db._prep(this.sql); }

  async all() {
    const rows = this._s().all(...this.params);
    return { results: rows, success: true, meta: { rows_read: rows.length } };
  }

  /* D1 وقتی ردیفی نیست null می‌دهد؛ SQLite‌ی نود undefined. */
  async first(col) {
    const row = this._s().get(...this.params);
    if (row === undefined || row === null) return null;
    return col === undefined ? row : (row[col] ?? null);
  }

  async run() {
    const r = this._s().run(...this.params);
    return { success: true, meta: {
      changes: Number(r.changes ?? 0),
      last_row_id: Number(r.lastInsertRowid ?? 0),
    } };
  }

  async raw() {
    const rows = this._s().all(...this.params);
    return rows.map(r => Object.values(r));
  }
}

class D1 {
  constructor(file) {
    this.db = new DatabaseSync(file);
    /* WAL: خواندن و نوشتن همزمان قفلِ هم نمی‌شوند و در قطعِ برق
       دیتابیس سالم می‌ماند. busy_timeout هم جلوی خطای فوریِ
       «database is locked» را می‌گیرد. */
    this.db.exec('PRAGMA journal_mode = WAL');
    this.db.exec('PRAGMA busy_timeout = 5000');
    this.db.exec('PRAGMA synchronous = NORMAL');
    this._cache = new Map();
  }

  /* هر SQL یک بار آماده می‌شود و بعد دوباره به کار می‌رود. */
  _prep(sql) {
    let s = this._cache.get(sql);
    if (!s) { s = this.db.prepare(sql); this._cache.set(sql, s); }
    return s;
  }

  prepare(sql) { return new Stmt(this, sql); }

  /* مثلِ D1: یا همه انجام می‌شوند یا هیچ‌کدام. */
  async batch(stmts) {
    this.db.exec('BEGIN');
    try {
      const out = [];
      for (const st of stmts) out.push(await st.all());
      this.db.exec('COMMIT');
      return out;
    } catch (e) {
      try { this.db.exec('ROLLBACK'); } catch {}
      throw e;
    }
  }

  async exec(sql) {
    this.db.exec(sql);
    return { count: 0, duration: 0 };
  }

  close() { try { this.db.close(); } catch {} }
}

export const openDB = file => new D1(file);
