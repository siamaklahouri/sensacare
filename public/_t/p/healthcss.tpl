  /* ---------- گزارشِ سلامتِ ماهانه ---------- */
  .hr-when{ font-size:12px; color:var(--ink-faint); margin-bottom:12px; }

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

  .hr-grid{
    display:grid; grid-template-columns:repeat(3, minmax(0,1fr)); gap:12px; margin-top:14px;
  }
  .hr-box{
    background:var(--white); border:1px solid var(--card-border); border-radius:13px;
    padding:12px 14px;
  }
  .hr-box h4{
    margin:0 0 8px; font-size:12.5px; font-weight:700; color:var(--ink);
  }
  .hr-t{ width:100%; border-collapse:collapse; }
  .hr-t td{ font-size:12px; padding:5px 0; border-bottom:1px dashed rgba(11,37,69,.07); }
  .hr-t tr:last-child td{ border-bottom:none; }
  .hr-k{ color:var(--ink-soft); }
  .hr-v{ text-align:left; font-weight:700; color:var(--ink); white-space:nowrap; }

  .hr-sign{
    display:flex; flex-wrap:wrap; gap:18px; justify-content:space-between;
    margin-top:18px; padding-top:12px; border-top:1px dashed var(--card-border);
    font-size:12px; color:var(--ink-soft);
  }

  @media (max-width:980px){ .hr-grid{ grid-template-columns:repeat(2, minmax(0,1fr)); } }
  @media (max-width:620px){ .hr-grid{ grid-template-columns:1fr; } }

  @media print{
    .hr-grid{ grid-template-columns:repeat(3, minmax(0,1fr)); gap:9px; }
    .hr-box{ break-inside:avoid; }
    .hr-sign{ break-inside:avoid; }
  }
