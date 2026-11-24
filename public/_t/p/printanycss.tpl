  /* ==================== کاغذ ====================
     جفتِ printany. سه کار می‌کند: دکمهٔ کوچکِ کنارِ عنوان، سربرگی که
     فقط روی کاغذ دیده می‌شود، و برداشتنِ هرچه روی کاغذ معنی ندارد.

     قاعده‌ها به «html.kb-printing» قید شده‌اند، نه به «@media print»
     تنها. چون چاپ ممکن است از بخشی باشد که روی صفحه باز نیست، و
     بی این کلاس هیچ راهی نبود که بگوییم «این یکی را چاپ کن». */

  .kb-print-btn{
    margin-inline-start:10px; border:1px solid var(--line); background:var(--white);
    color:var(--ink-soft); border-radius:8px; cursor:pointer;
    padding:5px 7px; font-family:inherit;
    display:inline-flex; align-items:center; justify-content:center;
    vertical-align:middle; opacity:.65; transition:opacity .15s, border-color .15s, background .15s, color .15s;
  }
  /* آیکن برداری است و رنگش از دکمه می‌آید، پس با تم می‌چرخد و روی
     هیچ سیستمی به مربعِ خالی تبدیل نمی‌شود. */
  .kb-print-btn svg{ display:block; width:14px; height:14px; }
  /* «nowrap» لازم است: دکمه‌های قدیمی عرضشان برای یک کلمهٔ تنها کوک
     شده بود و با آمدنِ آیکن، «چاپ» دو خط می‌شد. */
  .kb-print-all{ display:inline-flex; align-items:center; gap:7px; white-space:nowrap; }
  .kb-print-all svg{ width:15px; height:15px; flex:none; }
  .kb-print-btn:hover{ opacity:1; border-color:var(--brass);
    background:var(--brass-bg); color:var(--brass-ink); }
  .kb-print-btn:focus-visible{ outline:2px solid var(--brass); outline-offset:2px; opacity:1; }

  /* سربرگ فقط مالِ کاغذ است. روی صفحه ساخته می‌شود ولی دیده نمی‌شود،
     وگرنه لحظه‌ای قبل از باز شدنِ پنجرهٔ چاپ صفحه تکان می‌خورد. */
  .kb-phead{ display:none; }

  @media print{
    .kb-print-btn{ display:none !important; }

    html.kb-printing body{ background:#fff !important; }
    /* هیچ‌چیز روی کاغذ حرکت نمی‌کند.

       کارت‌های آمار با «animation:statIn .4s backwards» می‌آیند، یعنی
       فریمِ صفرشان شفاف است. چیدمانِ کاغذ که عوض می‌شود انیمیشن از نو
       شروع می‌شود و برگه می‌تواند درست همان فریمِ صفر را بگیرد: شش
       کارتِ نامرئی. همین برای هر محوشدن و لغزشِ دیگری هم هست. */
    html.kb-printing *, html.kb-printing *::before, html.kb-printing *::after{
      animation:none !important; transition:none !important;
    }
    html.kb-printing .sidebar, html.kb-printing .topbar,
    html.kb-printing .appbar, html.kb-printing .ch-fab-wrap,
    html.kb-printing .reminders-banner,
    /* پانویسِ «نسخهٔ دیجیتال پلنر» روی صفحه امضاست، روی کاغذ یک خطِ
       سرگردان بود که گاهی تنهایی می‌افتاد صفحهٔ دوم. */
    html.kb-printing .appfoot{ display:none !important; }
    html.kb-printing .content{ padding:0 !important; margin:0 !important; }

    /* فقط بخش‌های نشان‌شده */
    html.kb-printing .content > .view{ display:none !important; }
    html.kb-printing .content > .view.kb-print{ display:block !important; }
    /* هر بخش سرِ صفحهٔ خودش، جز آخری که دنبالش کاغذِ خالی نمی‌خواهد */
    html.kb-printing .view.kb-print{ break-after:page; page-break-after:always; }
    html.kb-printing .view.kb-print-last{ break-after:auto; page-break-after:auto; }

    /* عنوانِ خودِ بخش دوباره نمی‌آید — سربرگ گفته است. */
    html.kb-printing .kb-print > .section-title,
    html.kb-printing .kb-print > .section-sub{ display:none !important; }

    html.kb-printing .kb-phead{
      display:block; margin:0 0 14px; padding-bottom:10px;
      border-bottom:1.5px solid #666; break-inside:avoid; page-break-inside:avoid;
    }
    html.kb-printing .kb-phead-who{ font-size:10.5px; color:#555; letter-spacing:.02em; }
    html.kb-printing .kb-phead-ttl{ font-size:16px; font-weight:800; margin-top:2px; color:#000; }
    html.kb-printing .kb-phead-sub{ font-size:11px; color:#444; margin-top:3px; }
    html.kb-printing .kb-phead-foot{ font-size:10px; color:#666; margin-top:6px; }

    /* ---- چیزهایی که روی کاغذ کار نمی‌کنند ----
       دکمه، کادرِ افزودن، دستهٔ کشیدن، سوییچ. این‌ها روی صفحه ابزارند و
       روی کاغذ فقط جا می‌گیرند و برگه را شلوغ نشان می‌دهند. */
    html.kb-printing .kb-print button:not(.keep-print),
    html.kb-printing .kb-print .rd-grip,
    html.kb-printing .kb-print .updown,
    html.kb-printing .kb-print .cp-back, html.kb-printing .kb-print .cp-more,
    html.kb-printing .kb-print .nt-del,
    html.kb-printing .kb-print [data-notes-add],
    /* ردیفِ افزودن: یک فرمِ خالی ته هر جدول. روی کاغذ نه پُر می‌شود
       نه معنایی دارد، و در جدول‌های مالی یک ردیفِ عجیب می‌ساخت با
       یک «+» و یک کشویی که «پرداخت‌شده» نشان می‌داد. نامش در
       قالب‌ها «add-row» است، با خط تیره — قاعدهٔ قبلی «addrow» را
       می‌گرفت و این یکی سال‌ها از زیرش رد می‌شد. */
    html.kb-printing .kb-print tr.add-row,
    html.kb-printing .kb-print .addrow,
    html.kb-printing .kb-print .visit-add-bar,
    html.kb-printing .kb-print .del-switch,
    html.kb-printing .kb-print .edit-switch,
    html.kb-printing .kb-print .save-hint,
    /* ساعتِ زندهٔ داشبورد: روی کاغذ یک عددِ یخ‌زده است که تا کاغذ
       از چاپگر بیرون بیاید هم غلط شده. سربرگِ خودِ برگه ساعتِ چاپ
       را می‌نویسد و همان کافی است. */
    html.kb-printing .kb-print .dh-clock{ display:none !important; }

    /* کادرهای ورودی روی کاغذ «متن» می‌شوند، نه کادر: قابِ خاکستری دورِ
       هر خانه، جدول را مثلِ فرمِ پُرنشده نشان می‌داد. و چون input
       نمی‌شکند، printany کنارش یک span با همان متن می‌گذارد و خودِ
       کادر از کاغذ می‌رود. */
    html.kb-printing .kb-print input:not([type="checkbox"]):not([type="radio"]),
    html.kb-printing .kb-print textarea{ display:none !important; }
    html.kb-printing .kb-print .kb-pval{
      display:block; white-space:normal; overflow-wrap:anywhere;
      word-break:break-word; font-size:11px; line-height:1.75; color:#000;
    }
    html.kb-printing .kb-print select{
      border-color:transparent !important; background:transparent !important;
      box-shadow:none !important; color:#000 !important;
      appearance:none; -webkit-appearance:none;
    }
    /* ستونی که روی صفحه عرضِ ثابت داشت، روی کاغذ باید به اندازهٔ متنش
       باز شود — وگرنه span هم همان‌قدر تنگ می‌ماند که input بود. */
    html.kb-printing .kb-print table{ table-layout:auto !important; }
    html.kb-printing .kb-print th,
    html.kb-printing .kb-print td{
      white-space:normal !important; width:auto !important;
      min-width:0 !important; max-width:none !important;
      font-size:11px; padding:5px 6px;
    }
    /* جز چیپ‌های وضعیت و اولویت، که رنگشان خودِ خبر است */
    html.kb-printing .kb-print select.st-select,
    html.kb-printing .kb-print select.pr-select{
      -webkit-print-color-adjust:exact; print-color-adjust:exact;
    }
    html.kb-printing .kb-print select.st-select{
      border-color:#bbb !important; background:#f6f6f6 !important;
    }
    /* وضعیتِ خالی، قاب نمی‌خواهد: قرصِ خاکستریِ خالی روی کاغذ فقط
       یک شکلِ بی‌معنی بود، در برنامهٔ روزانه به‌ازای هر ردیف یکی. */
    html.kb-printing .kb-print select.st-select[data-st=""]{
      border-color:transparent !important; background:transparent !important;
    }

    /* ---- چیپِ «مهلت» ----
       این یکی دکمه است ولی داده دارد، نه کار: روزِ مهلتِ همان ردیف.
       قاعدهٔ بالا همهٔ دکمه‌ها را برمی‌داشت و نتیجه‌اش یک ستونِ
       کاملاً خالی روی کاغذ بود — در جدولی که نصفِ معنایش همان
       تاریخ است. با keep-print می‌مانَد، ولی قابِ دکمه‌ای‌اش می‌رود
       و متن می‌شود؛ شکلکِ تقویمِ داخلش هم تکرارِ بیست‌باره بود و
       روی کاغذ فقط شلوغی. */
    html.kb-printing .kb-print .date-box{
      border:none !important; background:transparent !important;
      padding:0 !important; box-shadow:none !important;
      font-size:11px !important; color:#000 !important;
      -webkit-print-color-adjust:exact; print-color-adjust:exact;
    }
    html.kb-printing .kb-print .date-box.od{ font-weight:700; }
    html.kb-printing .kb-print .date-box .cal-ic{ display:none !important; }

    /* نشانهٔ تقویمِ کنارِ خانه‌های تاریخ (dp-host::after) روی کاغذ
       کاری ندارد: روی صفحه می‌گوید «این‌جا کلیک کن»، روی برگه یک
       لکهٔ قرمزِ کنارِ هر ردیف بود. */
    html.kb-printing .kb-print .dp-host::after{ display:none !important; content:none !important; }

    html.kb-printing .kb-print .kb-pskip{ display:none !important; }
    /* «col-hide-s» در عرضِ زیر ۷۶۰ ستونِ جدول را برمی‌دارد — برای
       گوشی درست است. ولی عرضِ رسانه در چاپ عرضِ کاغذ است، و کاغذِ
       کوچک‌تر یا حاشیهٔ بزرگ‌تر می‌تواند زیر ۷۶۰ بیاورَدش. آن‌وقت
       ستون‌هایی بی‌صدا از برگه می‌افتند و کسی نمی‌فهمد چیزی کم است.
       روی کاغذ هیچ ستونی پنهان نمی‌شود؛ اگر جا کم باشد، متن می‌شکند. */
    html.kb-printing .kb-print th.col-hide-s,
    html.kb-printing .kb-print td.col-hide-s{ display:table-cell !important; }
    /* ردیفِ جست‌وجوی بالای جدول ابزار است، نه داده: روی کاغذ یک ردیفِ
       کاملاً خالی می‌شد که آدم را دنبالِ خودش می‌فرستاد. */
    html.kb-printing .kb-print tr:has(.col-filter){ display:none !important; }
    /* پیامِ «با این فیلتر چیزی نیست» هم ابزار است، نه داده — و
       چون خانه‌اش colspan=30 دارد، روی کاغذ جدول را به زور پهن
       می‌کرد و ردیفی می‌ساخت پهن‌تر از سرصفحه‌اش. */
    html.kb-printing .kb-print tr.ts-none{ display:none !important; }
    /* جدول‌ها روی کاغذ: سرصفحه سرِ هر صفحه، و ردیف نصف نشود. */
    html.kb-printing .kb-print thead{ display:table-header-group; }
    html.kb-printing .kb-print tr{ break-inside:avoid; page-break-inside:avoid; }
    /* جدول به اندازهٔ خودش، نه به زورِ عرضِ برگه.

       «width:100%» هر جدولی را تا لبهٔ کاغذ می‌کشید: جدولِ چهار
       ستونه روی کاغذِ خوابیده می‌شد چند خانهٔ غول‌پیکر با یک کلمه
       وسطشان. کاربر گفت «انگار کشیده شده‌اند» و درست می‌گفت.
       حالا جدول عرضِ طبیعیِ خودش را می‌گیرد و فقط اگر از برگه
       بزند بیرون، تا همان‌جا جمع می‌شود. */
    html.kb-printing .kb-print table{
      width:auto !important; max-width:100% !important;
    }
    /* ستونِ چسبنده روی کاغذ معنی ندارد و سایه‌اش روی چاپ خاکستری می‌شود */
    html.kb-printing .kb-print td.server-name,
    html.kb-printing .kb-print th.server-name{ position:static !important; }
    /* چیزی روی کاغذ نمی‌لغزد: هر قابِ اسکرول‌دار باید کاملش را نشان بدهد */
    html.kb-printing .kb-print .tablewrap,
    html.kb-printing .kb-print [style*="overflow"]{
      overflow:visible !important; max-height:none !important;
    }
    html.kb-printing .kb-print .panel{
      box-shadow:none !important; border-color:#bbb !important;
      break-inside:avoid; page-break-inside:avoid;
    }
    html.kb-printing .kb-print .panel::after{ display:none !important; }
    html.kb-printing .kb-print .stat{
      box-shadow:none !important; border-color:#bbb !important;
      -webkit-print-color-adjust:exact; print-color-adjust:exact;
    }
    /* ---- تقویم: کارِ هر روز باید خوانده شود ----
       کمربند و بندِ شلوار. قاعدهٔ «صفحهٔ باریک» در calcss حالا فقط
       مالِ screen است، ولی اگر روزی قاعدهٔ باریکِ دیگری اضافه شود،
       این‌ها از آن قوی‌ترند و متن سرِ جایش می‌ماند. */
    html.kb-printing .kb-print .c2-items{
      flex-direction:column !important; flex-wrap:nowrap !important; gap:2px !important;
    }
    html.kb-printing .kb-print .c2-it{
      width:auto !important; height:auto !important; border-radius:5px !important;
      font-size:10px !important; line-height:1.55 !important;
      padding:1px 5px !important; background:transparent !important;
      white-space:normal !important; overflow:visible !important;
      border-right:2px solid #777 !important; color:#000 !important;
    }
    html.kb-printing .kb-print .c2-more{
      font-size:9.5px !important; line-height:1.5 !important; padding:0 4px !important;
    }
    html.kb-printing .kb-print .c2-cell{ min-height:74px; }
    html.kb-printing .kb-print .c2-wd span{ font-size:11px !important; }
    html.kb-printing .kb-print .c2-wd span::after{ content:none !important; }

    /* ---- نمودارها روی کاغذ ----
       کارتی که نمودارش داده ندارد اصلاً چاپ نمی‌شود. روی صفحه جایش
       درست است — می‌گوید «این بخش هنوز پر نشده» — ولی روی کاغذ
       یک‌سومِ صفحه می‌گیرد برای یک جملهٔ خالی. در داشبوردِ واقعی
       چهار تا از این‌ها دو صفحهٔ کامل بودند و کلِ برگه را چهار صفحه
       کرده بودند. */
    html.kb-printing .kb-print .panel:has(canvas[data-empty="1"]){ display:none !important; }
    /* عنوانِ گروه نباید تهِ صفحه تنها بماند و کارت‌هایش بروند صفحهٔ
       بعد — سرفصلی که از زیرِ خودش جدا شده، سرفصل نیست. */
    html.kb-printing .kb-print .dash-group-label{
      break-after:avoid; page-break-after:avoid;
    }
    /* و بقیه کوتاه‌تر می‌شوند تا بیشترشان در یک صفحه جا شوند: روی
       صفحه ارتفاع برای خواندنِ راحت است، روی کاغذ برای شمردن. */
    html.kb-printing .kb-print .chart-box{ max-height:62mm; }
    html.kb-printing .kb-print canvas{ max-height:62mm !important; }
  }

  /* ---------- انتخابِ جهتِ کاغذ ----------
     «@page{size:…}» بر انتخابِ کاربر در پنجرهٔ چاپ می‌چربد، پس
     انتخاب باید پیش از آن پنجره گرفته شود. این یک پنجرهٔ کوچک است
     با همان زبانِ بقیهٔ کارتابل، نه یک فرمِ تنظیمات. */
  .kb-orient-ov{
    position:fixed; inset:0; z-index:600; display:flex;
    align-items:center; justify-content:center; padding:16px;
    background:rgba(11,20,33,.5);
  }
  .kb-orient{
    background:var(--white); border-radius:16px; padding:22px 22px 16px;
    width:min(340px, 100%); box-shadow:0 20px 50px rgba(0,0,0,.3);
    text-align:center; color:var(--ink);
  }
  .ko-h{ font-family:var(--font-display); font-size:15px; font-weight:800; margin-bottom:4px; }
  .ko-p{ font-size:12px; color:var(--ink-soft); margin-bottom:14px; }
  .ko-opts{ display:flex; gap:10px; justify-content:center; margin-bottom:16px; }
  .ko-opt{
    flex:1 1 0; display:flex; flex-direction:column; align-items:center; gap:7px;
    background:var(--paper); border:1.5px solid var(--card-border); border-radius:12px;
    padding:12px 8px; cursor:pointer; font-family:inherit; font-size:12px;
    font-weight:700; color:var(--ink-soft); transition:border-color .15s, color .15s, background .15s;
  }
  .ko-opt:hover{ border-color:var(--brass); }
  .ko-opt.on{ border-color:var(--brass); color:var(--brass-ink); background:var(--brass-bg); }
  .ko-opt:focus-visible{ outline:2px solid var(--brass); outline-offset:2px; }
  /* شکلِ کاغذ، نه شکلک: یک مستطیل که خودش می‌گوید ایستاده است یا
     خوابیده. رنگش از متن می‌آید، پس با انتخاب و با تم می‌چرخد. */
  .ko-ic{ display:block; border:2px solid currentColor; border-radius:3px; opacity:.85; }
  .ko-p-ic{ width:22px; height:30px; }
  .ko-l-ic{ width:30px; height:22px; }
  .ko-f{ display:flex; align-items:center; justify-content:space-between; gap:10px; }
  .ko-cancel{
    background:none; border:none; color:var(--ink-faint); cursor:pointer;
    font-family:inherit; font-size:12px; padding:6px 4px;
  }
  .ko-cancel:hover{ color:var(--ink); text-decoration:underline; }
  .ko-go{
    background:var(--brass); color:#fff; border:none; border-radius:10px;
    padding:9px 26px; font-family:inherit; font-size:13px; font-weight:700; cursor:pointer;
  }
  .ko-go:hover{ filter:brightness(1.05); }
  .ko-go:focus-visible, .ko-cancel:focus-visible{ outline:2px solid var(--brass); outline-offset:2px; }
  /* روی کاغذ خودش هم نباید بیفتد */
  @media print{ .kb-orient-ov{ display:none !important; } }
