  /* ---------- پورت‌چکر ---------- */
  .pc-bar{ display:flex; flex-wrap:wrap; gap:8px; align-items:flex-end; margin-bottom:10px; }
  .pc-fld{ display:flex; flex-direction:column; gap:4px; }
  .pc-fld label{ font-size:11.5px; color:var(--ink-faint); }
  .pc-fld input{
    font-family:inherit; font-size:12.5px; padding:8px 11px; border-radius:10px;
    border:1.5px solid var(--card-border); background:var(--white); color:var(--ink);
    direction:ltr; text-align:left;
  }
  .pc-fld input:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }
  .pc-host input{ min-width:200px; }
  .pc-ports input{ min-width:240px; }

  .pc-sets{ display:flex; flex-wrap:wrap; gap:6px; margin:0 0 12px; }
  .pc-set{
    font-family:inherit; font-size:11.5px; padding:4px 11px; border-radius:999px;
    border:1px solid var(--card-border); background:var(--white);
    color:var(--ink-soft); cursor:pointer;
  }
  .pc-set:hover{ border-color:var(--brass); color:var(--ink); }

  .pc-say{ font-size:12px; color:var(--ink-soft); margin:0 0 10px; }
  .pc-port{ direction:ltr; text-align:center; font-variant-numeric:tabular-nums; font-weight:700; }
  .pc-ms{ direction:ltr; text-align:center; font-variant-numeric:tabular-nums; color:var(--ink-faint); }
  .pc-chip{
    display:inline-block; font-size:11.5px; padding:2px 11px; border-radius:999px;
    font-weight:700; white-space:nowrap;
  }
  .pc-chip.is-open{ background:var(--green-bg, #e8f6ef); color:var(--green-ink, #137a4a); }
  .pc-chip.is-shut{ background:var(--red-bg); color:var(--red-ink); }
  tr.pc-open td{ background:var(--green-bg, #e8f6ef); }
  .pc-why{ font-size:11.5px; color:var(--ink-faint); }
