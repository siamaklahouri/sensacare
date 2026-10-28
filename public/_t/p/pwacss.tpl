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
      padding:9px 8px calc(7px + env(safe-area-inset-bottom, 0px));
      background:color-mix(in srgb, var(--white) 92%, transparent);
      backdrop-filter:blur(14px) saturate(1.4);
      /* لبهٔ گِرد و سایهٔ نرم، به‌جای یک خطِ صاف: نوار مثلِ یک تختهٔ
         جدا روی صفحه می‌نشیند، نه مثلِ ته‌ماندهٔ همان صفحه. */
      border-radius:18px 18px 0 0;
      box-shadow:0 -1px 0 var(--card-border), 0 -10px 28px rgba(11,37,69,.10);
    }
    @supports not (backdrop-filter: blur(1px)){
      html[data-app="1"] .appbar{ background:var(--white); }
    }
    .appbar .ab{
      flex:1 1 0; min-width:0; padding:0; cursor:pointer; position:relative;
      display:flex; flex-direction:column; align-items:center; gap:3px;
      background:none; border:none; color:var(--ink-faint);
      font-family:var(--font-body); font-size:10.5px; font-weight:600;
    }
    /* نشانهٔ تبِ فعال: یک خطِ کوتاه چسبیده به لبهٔ بالای نوار. */
    .appbar .ab.on::before{
      content:""; position:absolute; top:-4px; inset-inline-start:50%;
      width:22px; height:3px; margin-inline-start:-11px;
      border-radius:3px; background:var(--brass);
    }
    .appbar .ab .i{
      display:flex; align-items:center; justify-content:center;
      width:50px; height:31px; border-radius:13px; line-height:1;
      transition:background .18s, transform .18s;
    }
    .appbar .ab .i svg{ width:21px; height:21px; display:block; }
    .appbar .ab .l{
      max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;
    }
    .appbar .ab.on{ color:var(--brass); }
    .appbar .ab.on .i{
      background:linear-gradient(145deg,
        color-mix(in srgb, var(--brass) 22%, transparent),
        color-mix(in srgb, var(--brass) 9%, transparent));
      box-shadow:inset 0 0 0 1px color-mix(in srgb, var(--brass) 22%, transparent);
      transform:translateY(-1px);
    }
    .appbar .ab:active .i{ transform:scale(.94); }

    /* ---------- سرِ صفحه در حالتِ برنامه ----------
       یک ردیف، نه سه‌تا: ساعتِ زنده (که داشبورد خودش بزرگ‌تر نشانش
       می‌دهد) و زیرنویسِ برند می‌روند، ستونِ کناری هم که کارش را نوارِ
       پایینی می‌کند. چیزی که می‌ماند همان چیزی است که آدم روی گوشی
       لازم دارد: نشان، نامِ کارتابل، ماه، زنگوله و شب/روز.

       نوار چسبان می‌شود — در یک برنامه، سرصفحه با صفحه بالا نمی‌رود —
       ولی ۵۸ پیکسل است، یعنی کمتر از نصفِ آن سه ردیفی که برداشته. */
    html[data-app="1"] .topbar{
      position:sticky; top:0; z-index:60;
      min-height:0; height:auto; padding:8px 13px 9px;
      display:flex; flex-wrap:wrap; align-items:center; gap:8px;
      border-bottom:1px solid var(--card-border);
    }
    html[data-app="1"] .topbar-clock,
    html[data-app="1"] .topbar-date{ display:none; }
    /* ردیفِ اول فقط «این‌جا کجاست»: نشان و نام. هرچه فشار بیاید، نام
       کوتاه می‌شود و دکمه‌ها جابه‌جا نمی‌شوند. */
    html[data-app="1"] .brand{ flex:1 1 auto; min-width:0; gap:9px; }
    html[data-app="1"] .brand .mark{ height:30px; width:30px; }
    html[data-app="1"] .brand h1{
      font-size:14px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
    }
    html[data-app="1"] .brand .titles{ min-width:0; }

    /* ردیفِ دوم، کلِ پهنا: ماه که کشیده می‌شود و سه دکمهٔ هم‌اندازه.
       پیش از این همین چیزها بودند ولی هیچ‌کدام جای معینی نداشتند —
       نوار می‌شکست و دکمه‌ها هرجا که جا بود می‌نشستند، و نتیجه‌اش
       چیزی بود که به‌نظر می‌آمد کسی نچیده باشدش. */
    html[data-app="1"] .period{
      flex:1 1 100%; display:flex; align-items:center; gap:7px; min-width:0;
    }
    /* ماه اول می‌آید و کشیده می‌شود، سه دکمه بعدش: «این‌جا کدام ماه
       است» چیزی است که آدم اول می‌خواهد بداند، و دکمه‌ها ابزارند. */
    html[data-app="1"] .period .month-btn{
      order:1; flex:1 1 auto; min-width:0; justify-content:space-between;
      height:35px; padding:0 12px; border-radius:11px;
      font-size:13.5px; font-weight:700; gap:8px;
      background:var(--paper); border-color:var(--line);
    }
    html[data-app="1"] .period .month-btn .caret{ margin-inline-start:auto; }
    html[data-app="1"] .period .find-btn{ order:2; }
    html[data-app="1"] .period .bellw{ order:3; }
    html[data-app="1"] .period .theme-btn{ order:4; }
    html[data-app="1"] .period .month-btn:active{ background:var(--brass-bg); }
    /* سه دکمه، یک اندازه و یک شکل: ذره‌بین و زنگوله و شب/روز پیش از
       این سه قالبِ متفاوت داشتند (مربع، مربعِ گرد، دایره) و همین
       بی‌نظمی بیشتر از جایشان به چشم می‌آمد. */
    html[data-app="1"] .period .find-btn,
    html[data-app="1"] .period .bellb,
    html[data-app="1"] .period .theme-btn{
      width:35px; height:35px; flex:none; border-radius:11px;
      background:var(--paper); border:1px solid var(--line);
      font-size:15px; color:var(--ink-soft);
    }
    html[data-app="1"] .period .bellw{ flex:none; }
    html[data-app="1"] .period .bellb .nd{ box-shadow:0 0 0 2px var(--paper); }
    /* «✓ ذخیره شد» زیرِ نام، به جای زیرنویسِ ثابتِ برند */
    html[data-app="1"] .brand .titles .save-hint{
      display:block; min-height:0; margin:1px 0 0; padding:0;
      font-size:10.5px; line-height:1.5; color:var(--ink-faint);
      white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:46vw;
    }
    /* ستونِ کناری یک‌جا می‌رود: دکمه‌هایش را نوارِ پایینی و کشو می‌زنند و
       پایینش هم خالی شده. خودِ دکمه‌ها در صفحه می‌مانند — display:none
       کلیک می‌پذیرد — چون نوارِ پایینی همان‌ها را صدا می‌زند، نه کارِ
       تازه‌ای. */
    html[data-app="1"] .sidebar{ display:none; }
    html[data-app="1"] .content{ padding:13px 13px 12px; }
    /* عنوانِ بخش روی گوشی یک پله کوچک‌تر: جدولِ زیرش مهم‌تر است. */
    html[data-app="1"] .section-title{ font-size:18px; }
    html[data-app="1"] .section-sub{ font-size:12px; margin-bottom:11px; }

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
      width:38px; height:38px; border-radius:13px;
      background:var(--white); border:1px solid var(--card-border);
      color:var(--ink-soft);
    }
    .as-t .i svg{ width:21px; height:21px; display:block; }
    .as-t.on .i{ color:var(--brass); }
    .as-t .l{ width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .as-t.on{
      border-color:var(--brass);
      background:color-mix(in srgb, var(--brass) 10%, var(--paper));
    }
    .as-t.on .i{ border-color:var(--brass); }
    .as-t:active{ transform:scale(.97); }

    /* ته کشو: همان سه دکمه‌ای که از بالای صفحه برداشته شدند. */
    .as-foot{
      display:flex; flex-wrap:wrap; gap:8px;
      margin-top:15px; padding-top:13px; border-top:1px solid var(--line);
    }
    .as-foot .foot-actions{ display:flex; gap:8px; flex:1 1 100%; margin:0; }
    .as-foot .btn{
      flex:1 1 0; min-width:0; justify-content:center;
      padding:11px 10px; font-size:12px; border-radius:12px; white-space:nowrap;
    }
    .as-foot .foot-lock{ flex:1 1 100%; width:auto; margin:0; }
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

    /* ---------- لحظهٔ باز شدن ----------
       برنامه که از روی نشانه باز می‌شود، چند صدم ثانیه صفحهٔ سفید
       می‌ماند. همان نشانه وسطِ صفحه می‌نشیند تا آن لحظه هم مالِ خودِ
       برنامه باشد، نه یک صفحهٔ وبِ در حالِ بالا آمدن. */
    html[data-app="1"] #loadingScreen::before{
      content:""; width:76px; height:76px; border-radius:50%;
      background:url("/icon-sl.4.png") center/contain no-repeat;
      box-shadow:0 8px 26px rgba(11,37,69,.20);
      margin-bottom:4px;
    }

  }

  /* تا وقتی وارد نشده‌ایم یا صفحه بالا نیامده، نه نوار و نه کشو */
  #gateScreen:not([hidden]) ~ .appbar,
  #gateScreen:not([hidden]) ~ .appsheet,
  #gateScreen:not([hidden]) ~ .pwa-up{ display:none !important; }
