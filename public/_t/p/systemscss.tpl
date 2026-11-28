  /* ---------- سیستم‌ها ---------- */
  .sy-bar{ display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-bottom:12px; }
  .sy-bar input{
    flex:1 1 220px; max-width:320px; font-family:inherit; font-size:12.5px;
    padding:7px 12px; border-radius:10px; border:1.5px solid var(--card-border);
    background:var(--white); color:var(--ink);
  }
  .sy-bar input:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }
  .sy-count{ font-size:11.5px; color:var(--ink-faint); }

  .sy-no{ color:var(--ink-faint); font-size:11.5px; width:26px; }
  .sy-in{
    width:100%; font-family:inherit; font-size:12px; color:var(--ink);
    padding:5px 7px; border:1px solid transparent; border-radius:8px;
    background:transparent;
  }
  .sy-in:hover{ border-color:var(--card-border); }
  .sy-in:focus{ outline:none; border-color:var(--brass); background:var(--white); }
  .sy-in::placeholder{ color:var(--ink-faint); opacity:.65; }
  /* مقدارِ تکراری: خودِ خانه می‌گوید، نه یک گزارشِ جدا. */
  .sy-in.is-dup{
    border-color:var(--red-ink,#A6222B); background:var(--red-bg);
    color:var(--red-ink,#A6222B); font-weight:700;
  }
  .sy-in[data-ascii]{ direction:ltr; text-align:left; }

  .sy-add{
    display:grid; grid-template-columns:repeat(4, minmax(0,1fr)); gap:7px;
    margin-top:10px; padding-top:11px; border-top:1px dashed var(--card-border);
  }
  .sy-add input{
    width:100%; font-family:inherit; font-size:12px; padding:7px 9px;
    border-radius:9px; border:1.5px solid var(--card-border);
    background:var(--white); color:var(--ink);
  }
  .sy-add input[data-ascii]{ direction:ltr; text-align:left; }
  .sy-add input:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }
  .sy-add .sy-go{ grid-column:span 1; }
  @media (max-width:900px){
    .sy-add{ grid-template-columns:repeat(2, minmax(0,1fr)); }
  }
  @media print{
    .sy-add, .sy-bar, .btn-del{ display:none !important; }
    .sy-in{ border-color:transparent !important; background:transparent !important; }
  }
