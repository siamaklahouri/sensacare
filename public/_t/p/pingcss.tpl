
  /* ---------- پینگِ دستگاه‌ها ---------- */
  /* ---------- قرصِ وضعیت ----------
     همان زبانِ چیپ‌های وضعیتِ بقیهٔ جدول‌ها، تا این بخش مهمانِ صفحه
     به نظر نرسد. */
  .pg-chip{
    display:inline-block; padding:3px 11px; border-radius:999px;
    font-size:11.5px; font-weight:700; white-space:nowrap;
    border:1px solid transparent;
  }
  .pg-chip.pg-up{ background:var(--green-bg, #E3F3E9); color:var(--green-ink, #1A7A47); border-color:var(--green-bg, #CFE9DA); }
  .pg-chip.pg-down{ background:var(--red-bg); color:var(--red-ink); border-color:var(--red-bg); }
  .pg-chip.pg-wait{ background:var(--brass-bg); color:var(--brass-ink); border-color:var(--brass-bg); }
  .pg-chip.pg-idle{ background:var(--paper); color:var(--ink-faint); border-color:var(--card-border); }
  .pg-ms{ font-size:11.5px; color:var(--ink-soft); margin-inline-start:9px; }
  .pg-why{ font-size:11.5px; color:var(--ink-soft); margin-inline-start:9px; }

  /* نوارِ زمانِ پاسخ — سبز تا ۶۰، کهربایی تا ۱۵۰، قرمز بالاتر */
  .pg-bar{
    display:inline-block; vertical-align:middle; width:62px; height:5px;
    background:var(--paper); border-radius:999px; overflow:hidden;
    margin-inline-start:9px;
  }
  .pg-bar i{ display:block; height:100%; border-radius:999px; }
  .pg-fast i{ background:var(--green, #1F9254); }
  .pg-mid i{ background:var(--brass); }
  .pg-slow i{ background:var(--red); }

  /* خطِ خلاصه بالای جدول */
  .pg-sum{ display:flex; gap:8px; flex-wrap:wrap; align-items:center; }
  .pg-sum-it{
    font-size:11.5px; padding:4px 11px; border-radius:999px;
    background:var(--paper); color:var(--ink-soft); border:1px solid var(--card-border);
  }
  .pg-sum-it b{ font-weight:800; margin-inline-end:3px; }
  .pg-s-up{ background:var(--green-bg, #E3F3E9); color:var(--green-ink, #1A7A47); border-color:transparent; }
  .pg-s-down{ background:var(--red-bg); color:var(--red-ink); border-color:transparent; }
  .pg-s-wait{ background:var(--brass-bg); color:var(--brass-ink); border-color:transparent; }

  .pg-dot{
    display:inline-block; width:8px; height:8px; border-radius:50%;
    margin-inline-end:7px; vertical-align:middle; flex:none;
  }
  .pg-idle{ background:var(--ink-faint); opacity:.5; }
  .pg-up{ background:var(--green, #1F9254); }
  .pg-down{ background:var(--red); }
  .pg-wait{ background:var(--brass); animation:pgPulse 1s ease-in-out infinite; }
  @keyframes pgPulse{ 0%,100%{ opacity:.35 } 50%{ opacity:1 } }
  @media (prefers-reduced-motion: reduce){ .pg-wait{ animation:none; } }
  .pg-txt{ font-size:12px; }
  .pg-state{ white-space:nowrap; }
  .pg-when{ font-size:11.5px; color:var(--ink-faint); white-space:nowrap; text-align:center; }
  .pg-add{ display:flex; gap:8px; flex-wrap:wrap; align-items:center; margin-top:12px; }
  .pg-add input{
    font-family:inherit; font-size:12.5px; padding:8px 11px; min-width:0;
    border:1.5px solid var(--card-border); border-radius:10px;
    background:var(--paper); color:var(--ink);
  }
  .pg-add .pg-n{ flex:1 1 180px; }
  .pg-add .pg-h{ flex:1 1 180px; }
  .pg-add .pg-p{ flex:0 0 96px; }
  .pg-add input:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }
