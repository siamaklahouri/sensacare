  /* ---------- پنجرهٔ «تازه چه خبر؟» ---------- */
  .nwbox{ position:fixed; inset:0; z-index:150; display:block; }
  .nwbox[hidden]{ display:none; }
  .nw-scrim{ position:absolute; inset:0; background:rgba(8,18,30,.45); backdrop-filter:blur(2px); }
  .nw-card{
    position:absolute; inset-inline:0; margin:auto; top:50%; transform:translateY(-50%);
    width:min(430px, calc(100vw - 32px)); max-height:80vh; display:flex; flex-direction:column;
    background:var(--white); border:1px solid var(--card-border); border-radius:18px;
    box-shadow:0 18px 50px rgba(11,37,69,.28); overflow:hidden;
  }
  .nw-h{
    display:flex; align-items:center; justify-content:space-between;
    padding:13px 16px; border-bottom:1px solid var(--line);
    font-family:var(--font-display); font-size:15px; font-weight:800; color:var(--ink);
  }
  .nw-x{
    background:none; border:none; color:var(--ink-faint); font-size:15px; cursor:pointer;
    width:28px; height:28px; border-radius:8px;
  }
  .nw-x:hover{ background:var(--paper); color:var(--ink); }
  .nw-l{ overflow-y:auto; padding:6px 14px 10px; }
  .nw-i{
    display:flex; gap:11px; align-items:flex-start;
    padding:11px 2px; border-bottom:1px solid var(--line);
  }
  .nw-i:last-child{ border-bottom:none; }
  .nw-ic{ font-size:19px; line-height:1.4; flex:none; }
  .nw-i b{ display:block; font-size:13.5px; color:var(--ink); }
  .nw-i.new b::after{
    content:"تازه"; margin-inline-start:7px; vertical-align:2px;
    background:var(--brass-bg); color:var(--brass); border-radius:999px;
    padding:1px 7px; font-size:10px; font-weight:700;
  }
  .nw-i p{ margin:4px 0 0; font-size:12.5px; line-height:1.95; color:var(--ink-soft); }
  .nw-f{ padding:11px 14px; border-top:1px solid var(--line); text-align:left; }
  .nw-ok{
    background:var(--brass); color:#fff; border:none; border-radius:10px;
    padding:9px 22px; font-family:inherit; font-size:13px; font-weight:700; cursor:pointer;
  }
  .nw-ok:hover{ filter:brightness(1.05); }
