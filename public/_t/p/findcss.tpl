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

  /* دکمهٔ ذره‌بین در نوارِ بالا */
  .find-btn{
    display:inline-flex; align-items:center; justify-content:center;
    width:36px; height:36px; flex:none; cursor:pointer;
    border:1px solid var(--card-border); border-radius:11px;
    background:var(--white); color:var(--ink-soft); font-size:15px;
  }
  .find-btn:hover{ border-color:var(--brass); color:var(--brass); }

  @media (max-width:760px){
    .find-card{ margin-top:4vh; max-height:86vh; }
  }
