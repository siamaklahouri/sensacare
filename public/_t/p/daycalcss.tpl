  /* ---------- تقویمِ برنامهٔ روزانه ---------- */
  .day-cal-bar{ display:inline-flex; align-items:center; gap:8px; flex-wrap:wrap; }
  .dcal-chip{
    display:inline-flex; align-items:center; gap:6px; font-size:11.5px;
    background:var(--brass-bg); color:var(--brass-ink);
    border:1px solid var(--brass); border-radius:9px; padding:5px 9px;
  }
  .dcal-chip b{ font-weight:700; }
  .dcal-chip button{
    border:0; background:none; cursor:pointer; color:inherit; font-size:12px;
    line-height:1; padding:0 2px; opacity:.7;
  }
  .dcal-chip button:hover{ opacity:1; }


  .dcal-pop{
    position:fixed; z-index:330; width:272px; padding:10px;
    background:var(--white); border:1px solid var(--card-border); border-radius:12px;
    box-shadow:0 14px 40px rgba(11,37,69,.28); font-family:var(--font-body);
  }
  .dcal-pop[hidden]{ display:none; }
  .dcal-head{ display:flex; align-items:center; justify-content:space-between; gap:6px; margin-bottom:8px; }
  .dcal-ttl{ font-weight:700; font-size:13px; color:var(--ink); }
  .dcal-nav{
    width:26px; height:26px; border:1px solid var(--line); border-radius:7px;
    background:transparent; color:var(--ink-soft); cursor:pointer; font-size:15px; line-height:1;
  }
  .dcal-nav:hover{ border-color:var(--brass); color:var(--brass-ink); background:var(--brass-bg); }
  .dcal-wd, .dcal-grid{ display:grid; grid-template-columns:repeat(7,1fr); gap:3px; }
  .dcal-wd{ margin-bottom:4px; }
  .dcal-wd span{ text-align:center; font-size:10.5px; color:var(--ink-faint); font-weight:700; }
  .dcal-pad{ height:32px; }
  /* روزِ خالی کم‌رنگ است، روزِ کاردار شمارِ کارهایش را نشان می‌دهد،
     و روزِ انتخاب‌شده پُر. سه حالتِ جدا، سه نشانِ جدا. */
  .dcal-d{
    height:32px; display:flex; flex-direction:column; align-items:center; justify-content:center;
    gap:1px; border:1px solid transparent; border-radius:7px; background:transparent;
    color:var(--ink-faint); font-family:var(--font-body); cursor:pointer; padding:0;
    transition:background .12s, color .12s, border-color .12s;
  }
  .dcal-d i{ font-style:normal; font-size:12px; line-height:1; }
  .dcal-d b{ font-size:9px; line-height:1; font-weight:700; opacity:.9; }
  .dcal-d.has{ color:var(--ink); background:var(--brass-bg); }
  .dcal-d:hover{ border-color:var(--brass); color:var(--brass-ink); }
  .dcal-d.now{ border-color:var(--amber); }
  .dcal-d.on{ background:var(--brass); color:#fff; border-color:var(--brass); }
  .dcal-d.on b{ opacity:1; }
  .dcal-d[disabled]{ cursor:default; opacity:.55; }
  .dcal-d[disabled]:hover{ border-color:transparent; color:var(--ink-faint); }
  .dcal-note{ font-size:10.5px; color:var(--ink-faint); text-align:center; margin-top:8px; }
  .dcal-foot{ display:flex; gap:6px; margin-top:7px; }
  .dcal-foot button{
    flex:1; height:27px; border:1px solid var(--line); border-radius:7px;
    background:transparent; font-family:var(--font-body); font-size:11.5px; cursor:pointer;
    color:var(--ink-soft);
  }
  .dcal-foot button:hover{ border-color:var(--brass); color:var(--brass-ink); background:var(--brass-bg); }
  /* خانهٔ تاریخ داخلِ جدول هم زدنی است: همان روز را نشان می‌دهد */
  td.daily-date-cell:not(.daily-done-cell){ cursor:pointer; }
  td.daily-date-cell:not(.daily-done-cell):hover{ color:var(--brass-ink); text-decoration:underline; }
  @media (max-width:760px){
    .dcal-pop{ inset-inline:12px; width:auto; }
  }
