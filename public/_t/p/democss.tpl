  /* ---------- نوارِ نسخهٔ نمایشی ---------- */
  .demobar{
    position:fixed; inset-inline:0; bottom:0; z-index:140;
    background:var(--brass); color:#fff; text-align:center;
    font-size:12.5px; line-height:1.9; padding:9px 14px calc(9px + env(safe-area-inset-bottom, 0px));
    box-shadow:0 -4px 18px rgba(11,37,69,.22);
  }
  .demobar b{ font-weight:800; }
  .demobar a{
    color:#fff; font-weight:700; margin-inline-start:8px;
    border-bottom:1px solid rgba(255,255,255,.6); text-decoration:none;
  }
  .demobar a:hover{ border-bottom-color:#fff; }
  /* جا برای نوار، تا دکمه‌های ته صفحه زیرش نمانند */
  html[data-demo="1"] body{ padding-bottom:46px; }
  html[data-demo="1"] .chat-fab{ bottom:62px; }
  @media print{ .demobar{ display:none !important; } }
