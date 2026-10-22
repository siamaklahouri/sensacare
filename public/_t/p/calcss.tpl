  /* ---------- تقویم ----------
     رنگ از --c2 می‌آید که جاوااسکریپت برای هر ماه عوضش می‌کند؛ بقیهٔ
     رنگ‌ها با شفافیت از خودِ آن درمی‌آیند، پس در حالتِ شب هم همان‌قدر
     درست است و برای هر ماه جدا تعریف نشده. */
  #view-cal{ --c2:var(--brass); --c2-bg:var(--brass-bg); --c2-soft:var(--brass-bg); --c2-line:var(--line); }
  .c2-bar{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; margin-bottom:14px; }
  .c2-nav{
    background:var(--white); border:1px solid var(--line); color:var(--c2);
    width:34px; height:34px; border-radius:10px; cursor:pointer;
    font-size:18px; font-weight:800; line-height:1; display:flex;
    align-items:center; justify-content:center; transition:border-color .15s, background .15s;
  }
  .c2-nav:hover{ border-color:var(--c2); background:var(--c2-bg); }
  .c2-ttl{
    font-family:var(--font-display); font-size:17px; font-weight:800; color:var(--c2);
    min-width:170px; text-align:center;
  }
  .c2-today-btn{
    background:var(--c2-bg); border:1px solid var(--c2-line); color:var(--c2);
    border-radius:999px; padding:6px 14px; font-family:inherit; font-size:12.5px;
    font-weight:700; cursor:pointer;
  }
  .c2-today-btn:hover{ background:var(--c2-soft); }
  .c2-shift{ display:flex; align-items:center; gap:6px; margin-right:auto; color:var(--ink-soft); font-size:12px; }
  .c2-shift select{
    background:var(--white); border:1px solid var(--line); border-radius:8px;
    padding:5px 8px; font-family:inherit; font-size:12px; color:var(--ink); cursor:pointer;
  }
  .c2-main{ display:grid; grid-template-columns:1fr 300px; gap:16px; align-items:start; }
  .c2-box{
    background:var(--white); border:1px solid var(--card-border);
    border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden;
  }
  .c2-wd{
    display:grid; grid-template-columns:repeat(7,1fr); background:var(--c2-bg);
    border-bottom:1px solid var(--c2-line);
  }
  .c2-wd span{
    text-align:center; padding:9px 2px; font-size:12px; font-weight:700; color:var(--c2);
  }
  .c2-wd span:last-child{ color:var(--red-ink); }
  .c2-grid{ display:grid; grid-template-columns:repeat(7,1fr); }
  .c2-cell{
    min-height:92px; border-left:1px solid var(--line); border-bottom:1px solid var(--line);
    padding:5px 6px 6px; cursor:pointer; position:relative; overflow:hidden;
    transition:background .12s;
  }
  .c2-cell:nth-child(7n){ border-left:none; }
  .c2-cell:hover{ background:var(--c2-bg); }
  .c2-blank{ background:var(--paper); cursor:default; }
  .c2-blank:hover{ background:var(--paper); }
  .c2-top{ display:flex; align-items:center; justify-content:space-between; gap:4px; }
  .c2-num{ font-weight:800; font-size:14px; color:var(--ink); }
  .c2-note{ font-size:10.5px; opacity:.85; }
  .c2-cell.off{ background:var(--red-bg); }
  .c2-cell.off .c2-num{ color:var(--red-ink); }
  .c2-cell.off:hover{ background:var(--red-bg); filter:brightness(.98); }
  .c2-hol{
    font-size:10px; color:var(--red-ink); font-weight:700; margin-top:1px;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
  }
  .c2-hol i{ font-style:normal; opacity:.7; }
  /* امروز: حلقه، نه رنگِ پر — وگرنه با تعطیلی قاطی می‌شد */
  .c2-cell.today{ box-shadow:inset 0 0 0 2px var(--c2); }
  .c2-cell.sel{ background:var(--c2-soft); }
  .c2-items{ display:flex; flex-direction:column; gap:2px; margin-top:4px; }
  .c2-it{
    font-size:10.5px; line-height:1.5; color:var(--ink-soft); background:var(--paper);
    border-radius:5px; padding:1px 5px; white-space:nowrap; overflow:hidden;
    text-overflow:ellipsis; border-right:2px solid var(--c2);
  }
  .c2-it.tsk{ border-right-color:var(--amber); }
  .c2-more{ font-size:10px; color:var(--ink-faint); padding-right:4px; }

  /* ---------- کنارهٔ روز ---------- */
  .c2-side{
    background:var(--white); border:1px solid var(--card-border); border-radius:var(--radius);
    box-shadow:var(--shadow); padding:14px; position:sticky; top:14px;
  }
  .c2-sh{ border-bottom:1px solid var(--line); padding-bottom:10px; margin-bottom:10px; }
  .c2-sh-d{ font-family:var(--font-display); font-size:20px; font-weight:800; color:var(--c2); }
  .c2-sh-w{ font-size:12.5px; color:var(--ink-soft); margin-top:2px; }
  .c2-sh-x{ font-size:11px; color:var(--ink-faint); margin-top:3px; }
  .c2-sh-h{ font-size:12px; color:var(--red-ink); font-weight:700; margin-top:6px; }
  .c2-ap{
    background:var(--amber-bg); color:var(--amber-ink); border-radius:999px;
    padding:1px 7px; font-size:10px; font-weight:700;
  }
  .c2-sw{ display:flex; flex-wrap:wrap; gap:6px; margin-bottom:10px; }
  .c2-btn{
    background:var(--paper); border:1px solid var(--line); color:var(--ink-soft);
    border-radius:8px; padding:6px 10px; font-family:inherit; font-size:11.5px;
    font-weight:700; cursor:pointer;
  }
  .c2-btn:hover{ border-color:var(--c2); color:var(--c2); background:var(--c2-bg); }
  .c2-list{ display:flex; flex-direction:column; gap:6px; margin-bottom:12px; }
  .c2-row{
    display:flex; align-items:center; gap:6px; flex-wrap:wrap;
    background:var(--paper); border-radius:8px; padding:6px 8px; font-size:12px;
  }
  .c2-tag{
    background:var(--c2-bg); color:var(--c2); border-radius:999px; padding:1px 7px;
    font-size:10px; font-weight:700; white-space:nowrap;
  }
  .c2-tag.tsk{ background:var(--amber-bg); color:var(--amber-ink); }
  .c2-txt{ color:var(--ink); font-weight:600; }
  .c2-sub{ color:var(--ink-faint); font-size:11px; }
  .c2-st{ color:var(--ink-soft); font-size:10.5px; margin-right:auto; }
  .c2-empty{ color:var(--ink-faint); font-size:12px; font-style:italic; padding:6px 0; }
  .c2-nl{ display:block; font-size:12px; font-weight:700; color:var(--ink-soft); margin-bottom:5px; }
  .c2-note-in{
    width:100%; box-sizing:border-box; background:var(--paper); border:1px solid var(--line);
    border-radius:10px; padding:9px 10px; font-family:inherit; font-size:12.5px;
    color:var(--ink); resize:vertical; line-height:1.9;
  }
  .c2-note-in:focus{ border-color:var(--c2); outline:none; background:var(--white); }
  .c2-hint{ font-size:11px; color:var(--ink-faint); min-height:15px; margin-top:4px; }
  .c2-legend{ display:flex; gap:12px; flex-wrap:wrap; font-size:11.5px; color:var(--ink-faint); margin-top:10px; }
  .c2-legend b{ font-weight:700; color:var(--ink-soft); }
  /* سالی که تاریخ‌هایش از جدولِ رسمی آمده، نه جابه‌جایی می‌خواهد نه
     ستاره؛ و سالی که نیامده، باید همین را بگوید. */
  #view-cal[data-exact="1"] .c2-shift,
  #view-cal[data-exact="1"] .c2-approx{ display:none; }
  #view-cal[data-exact="0"] .c2-exact{ display:none; }
  .c2-legend .sw{ display:inline-block; width:10px; height:10px; border-radius:3px; vertical-align:-1px; margin-left:4px; }

  @media (max-width:900px){
    .c2-main{ grid-template-columns:1fr; }
    .c2-side{ position:static; }
    .c2-cell{ min-height:62px; padding:4px 4px 5px; }
    .c2-hol{ font-size:9px; }
    .c2-ttl{ min-width:0; font-size:15px; }
    /* نامِ روزها روی گوشی یک حرف می‌شود: «چهارشنبه» در ستونی به پهنای
       انگشت جا نمی‌شد و ستون‌ها را به هم می‌چسباند. */
    .c2-wd span{ font-size:0; padding:7px 0; }
    .c2-wd span::after{ content:attr(data-s); font-size:12px; }
    /* و خودِ کارها نقطه می‌شوند: متنِ سه‌حرفیِ بریده به درد نمی‌خورد،
       ولی «این روز کار دارد» همان چیزی است که از یک نگاه می‌خواهی. */
    .c2-items{ flex-direction:row; flex-wrap:wrap; gap:3px; margin-top:4px; }
    .c2-it{
      width:6px; height:6px; padding:0; border:none; border-radius:50%;
      background:var(--c2); font-size:0; line-height:0; overflow:hidden;
    }
    .c2-it.tsk{ background:var(--amber); }
    .c2-more{ font-size:9px; padding:0; line-height:6px; }
  }
