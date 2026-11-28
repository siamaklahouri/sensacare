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
    display:inline-block; font-size:11.5px; padding:2px 11px; border-radius:999px;
    font-weight:700; white-space:nowrap;
  }
  .rs-chip.is-ok{ background:var(--green-bg, #e8f6ef); color:var(--green-ink, #137a4a); }
  .rs-chip.is-warn{ background:var(--amber-bg, #fdf4e3); color:var(--amber-ink, #8a6416); }
  .rs-chip.is-bad{ background:var(--red-bg); color:var(--red-ink); }
  .rs-dim{ font-size:11px; color:var(--ink-faint); }
  .rs-when{ direction:ltr; text-align:right; font-variant-numeric:tabular-nums; }
  .rs-acts{ white-space:nowrap; }
  tr.rs-late td, tr.rs-never td{ background:var(--red-bg); }
  tr.rs-soon td{ background:var(--amber-bg, #fdf4e3); }
  @media print{ .rs-acts{ display:none !important; } }
