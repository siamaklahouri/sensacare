  /* ---------- گزارشِ سلامتِ ماهانه ---------- */
  .hr-bar-top[hidden]{ display:none; }
  .hr-bar-top{ display:flex; flex-wrap:wrap; gap:9px; align-items:center; margin-bottom:10px; }
  .hr-bar-top select{
    font-family:inherit; font-size:12.5px; padding:7px 11px; border-radius:10px;
    border:1.5px solid var(--card-border); background:var(--white); color:var(--ink);
  }
  .hr-bar-top .hr-lbl{ font-size:12px; color:var(--ink-soft); }

  .hr-when{
    display:flex; flex-wrap:wrap; gap:14px; align-items:center;
    font-size:12px; color:var(--ink-faint); margin-bottom:12px;
  }
  .hr-when b{ color:var(--ink); font-weight:700; }
  .hr-warnline{ color:var(--amber-ink, #8a6416); }
  .hr-dim{ font-size:11.5px; color:var(--ink-faint); margin-bottom:8px; }

  /* نمره */
  .hr-score{ display:flex; flex-wrap:wrap; gap:18px; align-items:center; }
  .hr-sc-n{ flex:0 0 150px; text-align:center; }
  .hr-sc-v{ font-size:42px; font-weight:800; line-height:1.1; color:var(--ink); }
  .hr-sc-l{ font-size:11.5px; color:var(--ink-faint); }
  .hr-sc-g{ margin-top:6px; font-size:12.5px; font-weight:700; display:inline-block;
    padding:3px 12px; border-radius:999px; }
  .hr-score.is-ok .hr-sc-v{ color:var(--green-ink, #137a4a); }
  .hr-score.is-ok .hr-sc-g{ background:var(--green-bg, #e8f6ef); color:var(--green-ink, #137a4a); }
  .hr-score.is-warn .hr-sc-v{ color:var(--amber-ink, #8a6416); }
  .hr-score.is-warn .hr-sc-g{ background:var(--amber-bg, #fdf4e3); color:var(--amber-ink, #8a6416); }
  .hr-score.is-bad .hr-sc-v{ color:var(--red-ink, #A6222B); }
  .hr-score.is-bad .hr-sc-g{ background:var(--red-bg); color:var(--red-ink, #A6222B); }
  .hr-score.is-none .hr-sc-g{ background:var(--paper-deep); color:var(--ink-faint); }
  .hr-trend{ margin-top:7px; font-size:11.5px; color:var(--ink-faint); }
  .hr-trend.up{ color:var(--green-ink, #137a4a); }
  .hr-trend.down{ color:var(--red-ink, #A6222B); }

  .hr-sc-b{ flex:1 1 320px; min-width:0; }
  .hr-bar{ display:flex; align-items:center; gap:9px; margin-bottom:7px; }
  .hr-bl{ flex:0 0 125px; font-size:12px; color:var(--ink-soft); }
  .hr-bt{ flex:1 1 auto; height:9px; border-radius:999px; background:var(--paper-deep);
    overflow:hidden; min-width:40px; }
  .hr-bt i{ display:block; height:100%; border-radius:999px; }
  .hr-bt i.is-ok{ background:var(--green, #1a9e63); }
  .hr-bt i.is-warn{ background:var(--amber, #e0a52b); }
  .hr-bt i.is-bad{ background:var(--red, #cf3b45); }
  .hr-bv{ flex:0 0 42px; font-size:12px; font-weight:700; text-align:left; }
  .hr-bw{ flex:0 0 62px; font-size:10.5px; color:var(--ink-faint); text-align:left; }

  /* جدولِ اقدام و کارهای باز */
  .hr-act{ width:100%; border-collapse:collapse; }
  .hr-act th{
    font-size:11.5px; font-weight:700; color:var(--ink-faint); text-align:right;
    padding:7px 9px; border-bottom:1px solid var(--card-border);
  }
  .hr-act td{
    font-size:12.5px; color:var(--ink); padding:8px 9px;
    border-bottom:1px solid var(--line, rgba(11,37,69,.06));
  }
  .hr-act .hr-why{ font-size:11.5px; color:var(--ink-soft); }
  .hr-act tr.hr-bad td{ background:var(--red-bg); }
  .hr-act tr.hr-warn td{ background:var(--amber-bg, #fdf4e3); }
  .hr-none{
    font-size:13px; color:var(--green-ink, #137a4a); background:var(--green-bg, #e8f6ef);
    border-radius:11px; padding:14px 16px; text-align:center; font-weight:600;
  }

  .hr-chart{ height:200px; }

  .hr-grid{
    display:grid; grid-template-columns:repeat(3, minmax(0,1fr)); gap:12px; margin-top:14px;
  }
  .hr-box{
    background:var(--white); border:1px solid var(--card-border); border-radius:13px;
    padding:12px 14px;
  }
  .hr-box h4{ margin:0 0 8px; font-size:12.5px; font-weight:700; color:var(--ink); }
  .hr-t{ width:100%; border-collapse:collapse; }
  .hr-t td{ font-size:12px; padding:5px 0; border-bottom:1px dashed rgba(11,37,69,.07); }
  .hr-t tr:last-child td{ border-bottom:none; }
  .hr-k{ color:var(--ink-soft); }
  .hr-v{ text-align:left; font-weight:700; color:var(--ink); white-space:nowrap; }

  /* یادداشت */
  .hr-note{
    width:100%; font-family:inherit; font-size:12.5px; line-height:1.9; color:var(--ink);
    padding:10px 12px; border-radius:11px; border:1.5px solid var(--card-border);
    background:var(--white); resize:vertical;
  }
  .hr-note:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }
  .hr-note-print{ display:none; font-size:12.5px; line-height:2; color:var(--ink); }

  .hr-sign{
    display:flex; flex-wrap:wrap; gap:18px; justify-content:space-between;
    margin-top:18px; padding-top:12px; border-top:1px dashed var(--card-border);
    font-size:12px; color:var(--ink-soft);
  }

  @media (max-width:980px){ .hr-grid{ grid-template-columns:repeat(2, minmax(0,1fr)); } }
  @media (max-width:620px){
    .hr-grid{ grid-template-columns:1fr; }
    .hr-bl{ flex-basis:92px; }
    .hr-bw{ display:none; }
  }

  @media print{
    .hr-bar-top{ display:none !important; }
    .hr-grid{ grid-template-columns:repeat(3, minmax(0,1fr)); gap:9px; }
    .hr-box, .hr-sign, .hr-score{ break-inside:avoid; }
    .hr-note{ display:none !important; }
    .hr-note-print{ display:block; }
  }
