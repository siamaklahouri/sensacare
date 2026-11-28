  /* ---------- کشویِ جست‌وجو ---------- */
  .findbox{
    position:fixed; inset:0; z-index:140;
    background:rgba(8,18,30,.42); backdrop-filter:blur(2px);
    display:flex; align-items:flex-start; justify-content:center;
    padding:0 16px;
  }
  .findbox[hidden]{ display:none; }
  .find-card{
    width:100%; max-width:620px; margin-top:9vh;
    background:var(--white); border:1px solid var(--card-border);
    border-radius:18px; box-shadow:0 18px 50px rgba(11,37,69,.28);
    overflow:hidden; display:flex; flex-direction:column; max-height:76vh;
  }
  .find-head{ display:flex; align-items:center; gap:8px; padding:12px 14px;
    border-bottom:1px solid var(--line); }
  .find-head input{
    flex:1; min-width:0; font-family:var(--font-body); font-size:14px;
    padding:10px 12px; border-radius:11px;
    border:1px solid var(--card-border); background:var(--paper); color:var(--ink);
  }
  .find-head input:focus{ outline:none; border-color:var(--brass); }
  .find-x{
    flex:none; width:32px; height:32px; cursor:pointer; font-size:13px;
    border:1px solid var(--line); border-radius:10px;
    background:transparent; color:var(--ink-faint);
  }
  .find-list{ overflow-y:auto; -webkit-overflow-scrolling:touch; padding:6px; }
  .find-row{
    display:block; width:100%; text-align:start; cursor:pointer;
    padding:10px 12px; margin-bottom:4px; border-radius:12px;
    border:1px solid transparent; background:transparent;
    font-family:var(--font-body);
  }
  .find-row:hover, .find-row.on{ background:var(--paper); border-color:var(--card-border); }
  .fr-t{ display:block; font-size:13.5px; font-weight:700; color:var(--ink);
    overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .fr-w{ display:block; font-size:11px; font-weight:600; color:var(--brass); margin-top:2px; }
  .fr-x{ display:block; font-size:11.5px; color:var(--ink-faint); margin-top:3px;
    overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .find-empty{ padding:22px 14px; text-align:center; font-size:12.5px; color:var(--ink-faint); }
  .find-foot{ padding:9px 14px; border-top:1px solid var(--line);
    font-size:11px; color:var(--ink-faint); }
  html.find-open body{ overflow:hidden; }

  /* ردیفی که از نتیجه بازش کرده‌ایم، یک لحظه روشن می‌ماند — وگرنه آدم
     در یک جدولِ سی‌ردیفی نمی‌داند کدام را باید ببیند. */
  tr.find-hit > td{
    background:color-mix(in srgb, var(--brass) 16%, transparent) !important;
    transition:background .5s;
  }

  /* دکمهٔ جست‌وجو در نوارِ بالا.
     روی صفحهٔ بزرگ شکلِ یک کادرِ جست‌وجوست — با متنِ راهنما و
     میان‌برش — ولی کادر نیست: با کلیک همان پنجرهٔ جست‌وجو باز
     می‌شود. دلیلش ساده است: یک ذره‌بینِ ۳۶ پیکسلی را کسی که دنبالش
     نگردد پیدا نمی‌کند، و کادرِ واقعی در نوار یعنی دو سازوکارِ
     موازیِ جست‌وجو و تنگ‌کردنِ جای دکمهٔ ماه.
     روی گوشی و در حالتِ اپ، همان ذره‌بینِ کوچک می‌ماند. */
  .find-btn{
    display:inline-flex; align-items:center; justify-content:center;
    width:36px; height:36px; flex:none; cursor:pointer;
    border:1px solid var(--card-border); border-radius:11px;
    background:var(--white); color:var(--ink-soft); font-size:15px;
  }
  .find-btn:hover{ border-color:var(--brass); color:var(--brass); }
  .find-btn .fb-ic{ line-height:1; }
  .find-btn .fb-t, .find-btn .fb-k{ display:none; }

  @media (min-width:901px){
    /* وسطِ نوار، نه چسبیده به بقیهٔ دکمه‌ها: نوارِ بالا دو سرش پُر
       است (برند و کنترل‌ها) و وسطش خالی. کادر همان‌جا می‌نشیند و
       بقیه سرِ جای خودشان می‌مانند — بی‌آن‌که markup عوض شود. */
    .period{ flex:1 1 auto; min-width:0; justify-content:flex-end; }
    .find-btn{ margin-inline-start:auto; margin-inline-end:auto; }
    .find-btn{
      width:auto; min-width:260px; max-width:360px; height:38px;
      justify-content:flex-start; gap:9px; padding:0 12px;
      font-family:var(--font-body); font-size:12.5px;
      background:var(--paper); border-color:var(--line, var(--card-border));
      transition:border-color .15s, background .15s, box-shadow .15s;
    }
    .find-btn:hover{ background:var(--white); box-shadow:0 1px 6px rgba(11,37,69,.06); }
    .find-btn .fb-ic{ font-size:14px; opacity:.75; flex:none; }
    .find-btn .fb-t{
      display:block; flex:1 1 auto; min-width:0; text-align:start;
      color:var(--ink-faint); white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
    }
    .find-btn .fb-k{
      display:block; flex:none; font-size:10.5px; font-weight:700; letter-spacing:.3px;
      color:var(--ink-faint); background:var(--white);
      border:1px solid var(--card-border); border-radius:7px;
      padding:2px 7px; direction:ltr;
    }
    .find-btn:hover .fb-t{ color:var(--ink-soft); }
    .find-btn:hover .fb-k{ border-color:var(--brass); color:var(--brass-ink); }
  }

  @media (max-width:760px){
    .find-card{ margin-top:4vh; max-height:86vh; }
  }
