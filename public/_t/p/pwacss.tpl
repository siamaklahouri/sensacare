  /* ==================== ظاهرِ برنامهٔ گوشی ====================
     این‌ها فقط وقتی دیده می‌شوند که کارتابل «نصب» شده باشد و از روی
     نشانهٔ صفحهٔ خانه باز شود (data-app روی <html> می‌نشیند). داخلِ
     مرورگر هیچ‌کدامشان نمی‌آیند: کسی که با مرورگر باز می‌کند نباید یک
     چیدمانِ تازه تحویل بگیرد. */
  .appbar, .appsheet{ display:none; }

  /* نوارِ «نسخهٔ تازه» در هر دو حالت هست — بعد از استقرار باید دیده شود */
  .pwa-up{
    position:fixed; z-index:120; inset-inline:12px; bottom:14px;
    display:flex; align-items:center; gap:10px;
    padding:11px 14px; border-radius:14px;
    background:var(--white); border:1px solid var(--card-border);
    box-shadow:var(--shadow-lg); font-size:12.5px; color:var(--ink);
    max-width:460px; margin-inline:auto;
  }
  .pwa-up span{ flex:1; min-width:0; }
  .pwa-up .pu-go{
    flex:none; padding:7px 13px; border:none; border-radius:9px; cursor:pointer;
    font-family:var(--font-body); font-size:12px; font-weight:700; color:#fff;
    background:linear-gradient(135deg,var(--brass),var(--brass-deep));
  }
  .pwa-up .pu-x{
    flex:none; width:26px; height:26px; padding:0; cursor:pointer;
    border:1px solid var(--line); border-radius:8px;
    background:transparent; color:var(--ink-faint); font-size:12px;
  }

  /* کارتِ «نصب روی گوشی» در تنظیمات.
     «!important» لازم است: قاعدهٔ مرورگر برای [hidden] فقط یک
     انتخابگرِ ساده است و «.btn{display:inline-flex}» از آن سنگین‌تر —
     بی این، دکمهٔ نصب در حالتِ نصب‌شده هم سرِ جایش می‌ماند. */
  #pwaInstall[hidden], #pwaHow[hidden]{ display:none !important; }

  .pwa-row{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; margin-top:10px; }
  .pwa-how{
    margin-top:10px; padding:11px 13px; border-radius:11px;
    background:var(--paper-deep); border:1px solid var(--line);
    font-size:12px; line-height:2; color:var(--ink-soft);
  }
  .pwa-how b{ color:var(--ink); }

  @media (max-width:900px){
    /* ---------- نوارِ پایینی ----------
       پنج دکمه: چهار بخشِ پرکار و یکی که بقیه را باز می‌کند. ارتفاعش
       با env(safe-area-inset-bottom) جمع می‌شود، وگرنه روی گوشی‌هایی
       که نوارِ خانهٔ اندروید را روی صفحه می‌کشند، ردیفِ آخر زیرِ آن
       می‌ماند. */
    html[data-app="1"] body{
      padding-bottom:calc(74px + env(safe-area-inset-bottom, 0px));
    }
    html[data-app="1"] .appbar{
      position:fixed; z-index:95; inset-inline:0; bottom:0;
      display:flex; align-items:stretch; gap:2px;
      padding:7px 8px calc(7px + env(safe-area-inset-bottom, 0px));
      background:color-mix(in srgb, var(--white) 92%, transparent);
      backdrop-filter:blur(14px) saturate(1.4);
      border-top:1px solid var(--card-border);
      box-shadow:0 -6px 24px rgba(11,37,69,.08);
    }
    @supports not (backdrop-filter: blur(1px)){
      html[data-app="1"] .appbar{ background:var(--white); }
    }
    .appbar .ab{
      flex:1 1 0; min-width:0; padding:0; cursor:pointer;
      display:flex; flex-direction:column; align-items:center; gap:3px;
      background:none; border:none; color:var(--ink-faint);
      font-family:var(--font-body); font-size:10.5px; font-weight:600;
    }
    .appbar .ab .i{
      display:flex; align-items:center; justify-content:center;
      width:46px; height:30px; border-radius:12px; font-size:16px; line-height:1;
      transition:background .18s, transform .18s;
    }
    .appbar .ab .l{
      max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;
    }
    .appbar .ab.on{ color:var(--brass); }
    .appbar .ab.on .i{
      background:color-mix(in srgb, var(--brass) 16%, transparent);
      transform:translateY(-1px);
    }
    .appbar .ab:active .i{ transform:scale(.94); }

    /* ---------- کشویِ «بخش‌ها» ----------
       همهٔ بخش‌ها با هم، در خانه‌های درشت. روی گوشی، دکمهٔ بزرگ یعنی
       دکمه‌ای که با شست هم درست زده می‌شود. */
    /* «:not([hidden])» لازم است، نه تزئین: «html[data-app] .appsheet»
       از «.appsheet[hidden]» سنگین‌تر است و بی این، کشو همیشه باز
       می‌ماند. */
    html[data-app="1"] .appsheet:not([hidden]){ display:block; }
    .appsheet{ position:fixed; inset:0; z-index:130; }
    .as-scrim{
      position:absolute; inset:0; background:rgba(8,18,30,.45);
      backdrop-filter:blur(2px);
      animation:asFade .18s ease-out;
    }
    .as-card{
      position:absolute; inset-inline:0; bottom:0;
      max-height:76vh; overflow-y:auto; -webkit-overflow-scrolling:touch;
      padding:8px 14px calc(18px + env(safe-area-inset-bottom, 0px));
      background:var(--white);
      border-radius:22px 22px 0 0;
      box-shadow:0 -10px 40px rgba(11,37,69,.22);
      animation:asUp .22s cubic-bezier(.2,.8,.3,1);
    }
    .as-grip{
      display:block; width:44px; height:5px; margin:2px auto 10px; padding:0;
      border:none; border-radius:99px; background:var(--line); cursor:pointer;
    }
    .as-ttl{
      margin:0 2px 12px; font-size:12.5px; font-weight:700; color:var(--ink-faint);
    }
    .as-grid{ display:grid; grid-template-columns:repeat(3,1fr); gap:9px; }
    .as-t{
      display:flex; flex-direction:column; align-items:center; gap:7px;
      padding:13px 6px; cursor:pointer;
      background:var(--paper); border:1px solid var(--line); border-radius:15px;
      font-family:var(--font-body); font-size:11.5px; font-weight:600;
      color:var(--ink); line-height:1.5; text-align:center;
    }
    .as-t .i{
      display:flex; align-items:center; justify-content:center;
      width:38px; height:38px; border-radius:13px; font-size:17px;
      background:var(--white); border:1px solid var(--card-border);
    }
    .as-t .l{ width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .as-t.on{
      border-color:var(--brass);
      background:color-mix(in srgb, var(--brass) 10%, var(--paper));
    }
    .as-t.on .i{ border-color:var(--brass); }
    .as-t:active{ transform:scale(.97); }
    /* پشتِ کشو نباید بلغزد */
    html.as-open body{ overflow:hidden; }

    @keyframes asUp{ from{ transform:translateY(22px); opacity:.6 } to{ transform:none; opacity:1 } }
    @keyframes asFade{ from{ opacity:0 } to{ opacity:1 } }

    /* ---------- هر چیزی که به کفِ صفحه چسبیده ----------
       دکمهٔ گفتگو، نوارِ هشدارِ همگام‌سازی و نوارِ «نسخهٔ تازه» همه
       bottom:0 بودند و حالا زیرِ نوارِ پایینی می‌افتند. یک پله بالاتر
       می‌روند — به اندازهٔ خودِ نوار به‌علاوهٔ حاشیهٔ امنِ گوشی.

       انتخابگرها عمداً با html[data-app] شروع می‌شوند: استایلِ گفتگو
       را خودِ chat.js موقعِ اجرا تزریق می‌کند و دیرتر از این فایل
       می‌نشیند؛ با این وزن، بی‌!important هم می‌چربد. */
    html[data-app="1"] .ch-fab-wrap{
      bottom:calc(86px + env(safe-area-inset-bottom, 0px));
    }
    html[data-app="1"] body.chat-fab .chn-wrap,
    html[data-app="1"] body.chat-fab .shn-wrap{
      bottom:calc(158px + env(safe-area-inset-bottom, 0px));
      inset-block-end:calc(158px + env(safe-area-inset-bottom, 0px));
    }
    html[data-app="1"] #syncConflict,
    html[data-app="1"] .sync-warn,
    html[data-app="1"] .pwa-up{
      bottom:calc(78px + env(safe-area-inset-bottom, 0px));
    }

    /* منوی مرورگری در حالتِ برنامه لازم نیست — کارش را نوارِ پایینی
       می‌کند. ولی خودِ دکمه‌ها در صفحه می‌مانند (display:none هم کلیک
       می‌پذیرد) چون نوارِ پایینی همان‌ها را می‌زند، نه کارِ تازه‌ای.
       پایینِ ستونِ کناری — ذخیره، پشتیبان و قفل — می‌ماند. */
    html[data-app="1"] .sidebar .nav-list,
    html[data-app="1"] .sidebar .nav-toggle,
    html[data-app="1"] .sidebar .nav-label{ display:none !important; }
    html[data-app="1"] .sidebar{ border-bottom:none; padding-top:4px; }
  }

  /* تا وقتی وارد نشده‌ایم یا صفحه بالا نیامده، نه نوار و نه کشو */
  #gateScreen:not([hidden]) ~ .appbar,
  #gateScreen:not([hidden]) ~ .appsheet,
  #gateScreen:not([hidden]) ~ .pwa-up{ display:none !important; }
