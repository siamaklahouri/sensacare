  /* ---------- توضیحاتِ بخش ---------- */
  .nt-wrap{ display:flex; flex-direction:column; gap:9px; margin-bottom:12px; }
  .nt-row{
    display:flex; align-items:flex-start; gap:9px;
    background:var(--paper); border:1px solid var(--line); border-radius:12px;
    padding:9px 11px; transition:border-color .15s;
  }
  .nt-row:focus-within{ border-color:var(--brass); background:var(--white); }
  .nt-txt{
    flex:1 1 auto; min-width:0; resize:none; overflow:hidden;
    background:transparent; border:none; outline:none;
    font-family:var(--font-body); font-size:12.8px; line-height:2;
    color:var(--ink); padding:0;
  }
  .nt-txt::placeholder{ color:var(--ink-faint); }
  .nt-side{ display:flex; align-items:center; gap:8px; flex:none; padding-top:2px; }
  .nt-when{ font-size:10.5px; color:var(--ink-faint); white-space:nowrap; }
  .nt-del{
    background:none; border:none; cursor:pointer; color:var(--ink-faint);
    font-size:12px; width:24px; height:24px; border-radius:7px; line-height:1;
  }
  .nt-del:hover{ background:var(--red-bg); color:var(--red-ink); }
  .nt-empty{ color:var(--ink-faint); font-size:12.5px; font-style:italic; padding:4px 0 10px; }
  @media print{ .nt-del, [data-notes-add]{ display:none !important; } }
