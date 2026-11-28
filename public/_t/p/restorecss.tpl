  /* ---------- تستِ ری‌استور ---------- */
  .rs-bar{ display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-bottom:12px;
    font-size:12px; color:var(--ink-soft); }
  .rs-bar input{
    width:72px; font-family:inherit; font-size:12.5px; padding:6px 10px; border-radius:9px;
    border:1.5px solid var(--card-border); background:var(--white); color:var(--ink);
    text-align:center;
  }
  .rs-bar input:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }
  .rs-chip{
    display:inline-block; min-width:150px; font-size:11.5px; padding:3px 11px;
    border-radius:999px; font-weight:700; white-space:nowrap; text-align:center;
  }
  /* قرص روی ردیفِ رنگی: پس‌زمینه‌اش سفید است و قابِ هم‌رنگِ متن
     دارد. تا دیروز پس‌زمینهٔ قرص همان رنگِ ردیف بود و قرص اصلاً
     دیده نمی‌شد — فقط یک متنِ قرمز وسطِ یک ردیفِ قرمز. */
  .rs-chip{ background:var(--white); border:1px solid currentColor; }
  .rs-chip.is-ok{ color:var(--green-ink, #137a4a); }
  .rs-chip.is-warn{ color:var(--amber-ink, #8a6416); }
  .rs-chip.is-bad{ color:var(--red-ink, #A6222B); }
  .rs-dim{ font-size:11px; color:var(--ink-faint); }
  /* وسط‌چین، مثلِ فهرستِ سیستم‌ها: ستون‌ها کوتاه و هم‌اندازه‌اند و
     راست‌چینِ فارسی کنارِ چپ‌چینِ لاتین، جدول را پلکانی می‌کرد. */
  #rsBody td, #view-restore thead th{ text-align:center; vertical-align:middle; }
  #view-restore thead th{ white-space:nowrap; }
  .rs-no{ color:var(--ink-faint); font-size:11.5px; }
  .rs-srv{ font-weight:700; }
  .rs-loc{ direction:ltr; font-size:12px; color:var(--ink-soft); }
  .rs-when{ direction:ltr; font-variant-numeric:tabular-nums; white-space:nowrap; }
  .rs-ago{ font-size:12px; color:var(--ink-soft); white-space:nowrap; }
  .rs-st{ white-space:nowrap; }
  .rs-acts{ white-space:nowrap; }
  .rs-acts .btn{ width:100%; max-width:124px; padding:6px 8px; font-size:11.5px; }
  /* دکمه در هر ردیف هست؛ اگر پررنگ باشد، چهارده دکمهٔ آبی جدول را
     می‌خورَد. کم‌رنگ می‌ماند و زیرِ موس پررنگ می‌شود. */
  .rs-go{ background:var(--white); }
  .rs-go:hover{ border-color:var(--brass); color:var(--brass-ink); }
  tr.rs-late td, tr.rs-never td{ background:var(--red-bg); }
  tr.rs-soon td{ background:var(--amber-bg, #fdf4e3); }
  @media print{ .rs-acts{ display:none !important; } }
  .rs-sort{ cursor:pointer; user-select:none; white-space:nowrap; }
  .rs-sort:hover{ color:var(--brass-ink); }
  .rs-arrow{ font-size:10px; opacity:.7; margin-inline-start:2px; }
