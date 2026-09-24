  /* جدول‌های دیتای شخصی: پهنای ستون از colgroup می‌آید، پس باید
     table-layout ثابت باشد. width:max-content می‌گذارد جدول از قاب
     پهن‌تر شود و tbl-wrap اسکرولِ افقی بدهد — بهتر از فشرده شدنِ
     همه‌چیز. */
  .pg-tab{ table-layout:fixed; width:max-content; min-width:100%; }
  .pg-tab th{ position:relative; }
  .pg-tab .pg-cell{ width:100%; box-sizing:border-box; }
  /* دستهٔ کشیدن روی لبهٔ پایانیِ ستون — در صفحهٔ راست‌به‌چپ یعنی سمت چپ */
  .pg-tab .pg-grip{
    position:absolute; top:0; bottom:0; inset-inline-end:0; width:9px;
    cursor:col-resize; user-select:none;
  }
  .pg-tab .pg-grip:hover{ background:var(--brass); opacity:.45; }
  /* فهرستِ نسخه‌های پیشین */
  .hist-row{
    display:flex; align-items:center; gap:10px; flex-wrap:wrap;
    padding:8px 10px; border:1px solid var(--card-border); border-radius:9px;
    margin-top:7px; font-size:12.5px; background:var(--paper-2);
  }
  .hist-row .hw{ font-weight:700; color:var(--ink-soft); min-width:90px; }
  .hist-row .ht{ color:var(--ink-faint); white-space:nowrap; }
  .hist-row .hs{ color:var(--ink-soft); flex:1; min-width:140px; line-height:1.8; }
  /* دکمهٔ ماه — سه کنترلِ پیشین (انتخاب، ساختن، تغییرِ نام) در یکی.
     نوار بالا جای دیدن است نه جای تصمیم‌گیری، پس دکمه فقط نامِ ماهِ
     جاری را می‌گوید و بقیهٔ کارها داخلِ پنجره‌اش می‌افتد. */
  .month-btn{
    display:inline-flex; align-items:center; gap:7px;
    font-family:var(--font-body); font-size:13px; font-weight:600;
    background:var(--white); border:1px solid var(--card-border); color:var(--ink);
    border-radius:999px; padding:7px 14px; cursor:pointer; white-space:nowrap;
    transition:border-color .15s, box-shadow .15s;
  }
  .month-btn:hover{ border-color:var(--brass); }
  .month-btn.on{ border-color:var(--brass); box-shadow:0 0 0 3px var(--brass-bg); }
  .month-btn .ic{ font-size:14px; line-height:1; }
  .month-btn .caret{ font-size:10px; color:var(--ink-faint); }
  .topbar-date{ font-size:12px; color:var(--ink-soft); white-space:nowrap; }

  /* پنجرهٔ ماه‌ها */
  .mpop{
    position:fixed; inset:0; z-index:90; display:flex; align-items:flex-start;
    justify-content:center; padding:76px 16px 16px;
    background:rgba(11,37,69,.28); backdrop-filter:blur(2px);
  }
  .mpop[hidden]{ display:none; }
  .mpop-card{
    width:100%; max-width:392px; background:var(--white);
    border:1px solid var(--card-border); border-radius:16px;
    box-shadow:0 18px 48px rgba(11,37,69,.22); padding:16px 18px 18px;
    max-height:calc(100vh - 110px); overflow:auto;
  }
  .mpop-h{
    display:flex; align-items:center; justify-content:space-between;
    font-size:14px; font-weight:700; color:var(--ink); margin-bottom:12px;
  }
  .mpop-x{
    background:transparent; border:0; color:var(--ink-faint); font-size:14px;
    cursor:pointer; padding:4px 7px; border-radius:7px; line-height:1;
  }
  .mpop-x:hover{ background:var(--paper-2); color:var(--ink); }
  .mpop-list{ display:flex; flex-direction:column; gap:3px; }
  .mpop-empty{ font-size:12.5px; color:var(--ink-faint); padding:10px 2px; line-height:1.9; }
  .mrow{
    display:flex; align-items:center; gap:4px;
    border:1px solid transparent; border-radius:10px;
  }
  .mrow:hover{ background:var(--paper-2); }
  .mrow.on{ background:var(--brass-bg); border-color:var(--brass); }
  .mrow .nm{
    flex:1; min-width:0; background:transparent; border:0; cursor:pointer;
    font-family:var(--font-body); font-size:13px; font-weight:600; color:var(--ink);
    text-align:start; padding:9px 10px; border-radius:10px;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
  }
  .mrow .ed{
    background:transparent; border:0; color:var(--ink-faint); font-size:12.5px;
    cursor:pointer; padding:6px 8px; border-radius:8px; line-height:1; flex:none;
  }
  .mrow .ed:hover{ background:var(--white); color:var(--brass); }
  .mrow .ed.ok{ color:var(--green,#2F6B4F); }
  /* تغییرِ نام همان‌جا در ردیفِ خودش انجام می‌شود؛ پنجرهٔ تازه‌ای باز
     نمی‌شود، چون آدم همان لحظه دارد به فهرستِ ماه‌ها نگاه می‌کند. */
  .mrow input{
    min-width:0; font-family:var(--font-body); font-size:12.5px;
    background:var(--white); border:1px solid var(--card-border); color:var(--ink);
    border-radius:8px; padding:6px 9px; box-sizing:border-box;
  }
  .mrow .me-n{ flex:1; }
  .mrow .me-y{ width:74px; flex:none; text-align:center; }
  .mpop-new{ margin-top:14px; padding-top:13px; border-top:1px solid var(--card-border); }
  .mpop-sub{ font-size:11.5px; color:var(--ink-faint); font-weight:700; margin-bottom:8px; }
  .mpop-row{ display:flex; gap:7px; flex-wrap:wrap; align-items:center; }
  .mpop-row input{
    flex:1; min-width:96px; font-family:var(--font-body); font-size:12.5px;
    background:var(--white); border:1px solid var(--card-border); color:var(--ink);
    border-radius:8px; padding:7px 10px; box-sizing:border-box;
  }