
  /* ---------- فهرستِ کنار ----------
     overflow-y:auto به‌تنهایی کافی نبود: در CSS وقتی یک محور auto می‌شود،
     محورِ دیگر از visible به auto می‌افتد، و همان یک نوارِ اسکرولِ افقیِ
     بی‌مصرف را زیر فهرست می‌آورد. صریح خاموشش می‌کنیم.
     نوارِ عمودی هم باریک و کم‌رنگ شد تا مثل یک تختهٔ خاکستری وسطِ فهرست
     ننشیند. */
  .nav-list{ overflow-x:hidden; scrollbar-width:thin; scrollbar-color:var(--line) transparent; }
  .nav-list::-webkit-scrollbar{ width:6px; height:0; }
  .nav-list::-webkit-scrollbar-track{ background:transparent; }
  .nav-list::-webkit-scrollbar-thumb{ background:var(--line); border-radius:3px; }
  .nav-list::-webkit-scrollbar-thumb:hover{ background:var(--ink-faint); }
  /* دکمه‌ها با padding از عرضِ فهرست می‌زدند بیرون و خودشان هم به آن
     نوارِ افقی دامن می‌زدند. */
  .navbtn{ box-sizing:border-box; max-width:100%; }

  /* نوارِ هشدارِ همگام‌سازی — همان شکلِ نوارِ تداخل */
  .sync-warn{
    position:fixed; inset-inline:0; bottom:0; z-index:9998;
    display:flex; align-items:center; justify-content:center; gap:10px; flex-wrap:wrap;
    background:var(--bad-bg); color:var(--bad-ink);
    border-top:1px solid var(--bad); padding:10px 16px;
    font-family:var(--font-body); font-size:12.5px;
  }
  .sync-warn button{
    font-family:var(--font-body); font-size:12px; cursor:pointer;
    border:1px solid var(--bad); background:transparent; color:var(--bad-ink);
    border-radius:8px; padding:5px 12px;
  }
  .sync-warn button:hover{ background:var(--bad); color:#fff; }

  /* ---------- دستیار هوشمند ----------
     همه‌چیزش از توکن‌ها می‌خواند، پس در تم شب هم بدون قاعدهٔ جداگانه درست
     درمی‌آید. ارتفاعِ ثابت دارد تا فهرستِ گفتگو خودش اسکرول شود و نوارِ
     نوشتن همیشه پایین بماند، نه اینکه صفحه بلند و بلندتر شود. */
  .ai-wrap{
    display:flex; flex-direction:column;
    height:calc(100vh - 235px); min-height:420px;
    background:var(--white); border:1px solid var(--card-border);
    border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden;
  }
  .ai-log{
    flex:1 1 auto; min-height:0; overflow-y:auto;
    padding:18px; display:flex; flex-direction:column; gap:12px;
  }
  .ai-msg{
    max-width:78%; padding:10px 14px; border-radius:14px;
    font-size:13px; line-height:2; white-space:pre-wrap; word-break:break-word;
  }
  /* در راست‌به‌چپ، flex-end سمتِ چپ است: پیام خودِ کاربر چپ، جواب راست */
  .ai-msg.me{ align-self:flex-end; background:var(--brass); color:#fff; border-bottom-left-radius:4px; }
  .ai-msg.bot{ align-self:flex-start; background:var(--paper-deep); color:var(--ink); border-bottom-right-radius:4px; }
  .ai-msg.err{ align-self:flex-start; background:var(--red-bg); color:var(--red-ink); }
  .ai-msg code{ background:rgba(127,127,127,.18); border-radius:4px; padding:1px 5px; font-size:12px; }
  .ai-empty{ margin:auto; text-align:center; color:var(--ink-faint); font-size:12.5px; line-height:2.2; }
  .ai-empty .big{ font-size:30px; display:block; margin-bottom:6px; }
  .ai-tips{ display:flex; flex-wrap:wrap; gap:6px; padding:0 18px 12px; }
  .ai-tip{
    border:1px solid var(--line); border-radius:999px; padding:5px 11px;
    font-size:11.5px; cursor:pointer; background:transparent; color:var(--ink-soft);
    font-family:var(--font-body);
  }
  .ai-tip:hover{ border-color:var(--brass); color:var(--ink); }
  .ai-bar{ display:flex; gap:8px; padding:12px; border-top:1px solid var(--line); background:var(--paper); }
  .ai-bar textarea{
    flex:1 1 auto; resize:none; min-height:42px; max-height:150px; box-sizing:border-box;
    font-family:var(--font-body); font-size:13px; line-height:1.9;
    padding:10px 12px; border:1px solid var(--line); border-radius:10px;
    background:var(--white); color:var(--ink);
  }
  .ai-bar textarea:focus{ outline:none; border-color:var(--brass); }
  .ai-send{ flex:none; align-self:flex-end; }
  .ai-foot{
    display:flex; align-items:center; justify-content:space-between; gap:10px;
    flex-wrap:wrap; margin-top:10px;
  }
  .ai-note{ font-size:11.5px; color:var(--ink-faint); line-height:1.9; flex:1 1 260px; }
  @media (max-width:860px){
    .ai-wrap{ height:auto; min-height:0; }
    .ai-log{ max-height:60vh; }
    .ai-msg{ max-width:92%; }
  }

  /* ---------- تم شب ----------
     رنگ‌های تم شب «برعکسِ» تم روز نیستند؛ جداگانه انتخاب و روی سطحِ تیره
     سنجیده شده‌اند. هر جوهر روی تینتِ خودش بالای ۵:۱ کنتراست دارد. */
  [data-theme="dark"]{
    --paper:#0D1620;
    --paper-deep:#111C28;
    --white:#16212E;
    --ink:#E9EFF5;
    --ink-soft:#AFBDCB;
    --ink-faint:#7E8D9C;
    --line:#27323F;
    --card-border:#27323F;
    --brass-bg:#10312F;
    --green-bg:#122A1F;
    --amber-bg:#2E2515;
    --red-bg:#331A1C;
    --teal-bg:#0F2B28;
    --purple-bg:#241C33;
    --shadow: 0 1px 2px rgba(0,0,0,.45), 0 4px 14px rgba(0,0,0,.35);
    --shadow-lg: 0 4px 12px rgba(0,0,0,.5), 0 18px 40px rgba(0,0,0,.45);
    --c1:#12A29A; --t1:#0F2E2C;
    --c2:#BF881F; --t2:#2E2616;
    --c3:#8561C7; --t3:#231B33;
    --c4:#2B8C59; --t4:#13291E;
    --bad:#D4646C; --bad-bg:#331E20; --bad-ink:#E48E94;
    --deep:#203042;
    --brass-ink:#58CFC6;
    --red-ink:#E4757C;
    --green-ink:#56B97E;
    --amber-ink:#E0A63A;
    --teal-ink:#3FBDB0;
    --purple-ink:#A585DC;
    color-scheme: dark;
  }
  /* پس‌زمینهٔ صفحه گرادیانی دارد که برای زمینهٔ روشن ساخته شده */
  [data-theme="dark"] body{ background:var(--paper); }
  [data-theme="dark"] .tbl-wrap{ background-color:transparent; }
  [data-theme="dark"] tbody tr:nth-child(even){ background:rgba(255,255,255,.03); }
  [data-theme="dark"] tbody tr:hover{ background:rgba(255,255,255,.06); }
  /* قاب آیکن کارت‌ها: رنگِ روشنِ inline در شب کور می‌زند */
  [data-theme="dark"] .stat-ic{ background:rgba(255,255,255,.08); }
  [data-theme="dark"] input, [data-theme="dark"] select, [data-theme="dark"] textarea{
    background:var(--paper-deep); color:var(--ink); border-color:var(--line);
  }
  [data-theme="dark"] input::placeholder, [data-theme="dark"] textarea::placeholder{ color:var(--ink-faint); }
  [data-theme="dark"] option{ background:var(--paper-deep); color:var(--ink); }

  /* سطح‌هایی که هگزِ روشنِ ثابت داشتند و توکن نبودند */
  [data-theme="dark"] .btn-lock-now{ background:var(--red-bg); border-color:#5A2A2E; color:var(--red-ink); }
  [data-theme="dark"] .inst-card{ background:var(--paper-deep); }
  [data-theme="dark"] .inst-pay-toggle.paid{ background:var(--green-bg); border-color:#2E5C42; color:var(--green-ink); }
  [data-theme="dark"] .cred-import-bar,
  [data-theme="dark"] .visit-add-bar{ background:var(--paper-deep); }
  [data-theme="dark"] .add-row input, [data-theme="dark"] .add-row select{ background:var(--paper-deep); }

  /* در موبایل نوار کناری ردیفی از دکمه می‌شود و پس‌زمینهٔ سفیدِ
     نیمه‌شفاف می‌گیرد؛ در شب متنِ روشن رویش گم می‌شد. */
  @media (max-width:860px){
    [data-theme="dark"] .navbtn{ background:rgba(255,255,255,.06); border-color:var(--line); }
  }

  /* ---------- دکمهٔ تم ---------- */
  .theme-btn{
    display:inline-flex; align-items:center; justify-content:center;
    width:30px; height:30px; flex:none; cursor:pointer; user-select:none;
    background:var(--white); border:1px solid var(--card-border);
    border-radius:999px; font-size:14px; line-height:1; color:var(--ink-soft);
    transition:border-color .15s, background .15s, transform .12s;
  }