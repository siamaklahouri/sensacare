  /* ---------- کشویِ ویرایشِ ردیف ---------- */
  .rowsheet{ position:fixed; inset:0; z-index:135; }
  .rowsheet[hidden]{ display:none; }
  .rs-scrim{ position:absolute; inset:0; background:rgba(8,18,30,.45); backdrop-filter:blur(2px); }
  .rs-card{
    position:absolute; inset-inline:0; bottom:0; max-height:84vh; overflow-y:auto;
    -webkit-overflow-scrolling:touch;
    padding:8px 14px calc(16px + env(safe-area-inset-bottom, 0px));
    background:var(--white); border-radius:22px 22px 0 0;
    box-shadow:0 -10px 40px rgba(11,37,69,.22);
    animation:rsUp .22s cubic-bezier(.2,.8,.3,1);
  }
  @keyframes rsUp{ from{ transform:translateY(22px); opacity:.6 } to{ transform:none; opacity:1 } }
  .rs-grip{
    display:block; width:44px; height:5px; margin:2px auto 10px; padding:0;
    border:none; border-radius:99px; background:var(--line); cursor:pointer;
  }
  .rs-ttl{ margin:0 2px 12px; font-size:12.5px; font-weight:700; color:var(--ink-faint); }
  .rs-f{ display:block; margin-bottom:11px; }
  .rs-f > span{ display:block; margin-bottom:5px; font-size:11.5px; color:var(--ink-soft); }
  .rs-f input, .rs-f select, .rs-date{
    width:100%; box-sizing:border-box; font-family:var(--font-body); font-size:14px;
    padding:11px 12px; border-radius:12px;
    border:1px solid var(--card-border); background:var(--paper); color:var(--ink);
  }
  .rs-f input:focus, .rs-f select:focus{ outline:none; border-color:var(--brass); }
  .rs-f input[readonly]{ color:var(--ink-faint); }
  .rs-date{ text-align:start; cursor:pointer; }
  .rs-check{ display:flex; align-items:center; gap:9px; margin:4px 0 13px; }
  .rs-check input{ width:18px; height:18px; accent-color:var(--brass); }
  .rs-check span{ margin:0; font-size:13px; color:var(--ink); }
  .rs-done{
    width:100%; margin-top:4px; padding:12px; cursor:pointer;
    border:none; border-radius:13px; color:#fff; font-family:var(--font-body);
    font-size:13.5px; font-weight:700;
    background:linear-gradient(135deg,var(--brass),var(--brass-deep));
  }
  html.rs-open body{ overflow:hidden; }

  /* دستهٔ ردیف: فقط در حالتِ برنامه، و فقط روی دو جدولی که برای
     نوشتن‌اند. ✎ می‌گوید که زدنی است. */
  html[data-app="1"] #checklistBody td:first-child,
  html[data-app="1"] #dailyBody td:first-child{
    cursor:pointer; white-space:nowrap; color:var(--brass); font-weight:700;
  }
  html[data-app="1"] #checklistBody td:first-child::after,
  html[data-app="1"] #dailyBody td:first-child::after{
    content:"✎"; margin-inline-start:4px; font-size:11px; opacity:.75;
  }
