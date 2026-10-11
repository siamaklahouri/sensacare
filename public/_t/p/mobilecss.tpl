  /* دکمهٔ منو فقط روی صفحهٔ باریک معنا دارد. */
  .nav-toggle{ display:none; }

  /* ---------- گوشی و تبلت ----------
     تا حالا هیچ چیدمانی برای صفحهٔ باریک نبود: ستون کناریِ ۲۱۶ پیکسلی
     سر جایش می‌ماند و برای خودِ کارتابل چیزی حدود ۱۷۰ پیکسل باقی
     می‌گذاشت. حالا روی صفحهٔ باریک، ستون کناری می‌رود بالا و دکمه‌هایش
     مثل تب کنار هم می‌نشینند. */
  @media (max-width:860px){
    .topbar{
      height:auto; min-height:56px; flex-wrap:wrap; gap:8px;
      padding:10px 14px; position:static;
    }
    .brand .mark{ height:32px; }
    .brand h1{ font-size:15px; }
    .brand small{ display:none; }
    .period{ flex-wrap:wrap; gap:6px; }
    .period input{ width:70px; }

    /* نوارِ بالا ۱۳۴ پیکسل شده بود، چون نامِ ماه و تاریخِ امروز و
       ساعت و دکمهٔ تم هر کدام می‌پیچیدند و سه ردیف می‌شدند. روی
       گوشی، تاریخِ کاملِ امروز و ساعتِ زنده چیزی نیستند که جای یک
       ردیفِ کامل را بگیرند — ماه و تمِ روز و شب می‌مانند. */
    .topbar-date{ display:none; }
    .topbar-clock{ font-size:12px; padding:4px 9px; }
    .topbar{ row-gap:6px; }

    /* در حالت عمودی باید کشیده شوند؛ با align-items:flex-start که برای
       چیدمان افقی لازم است، بخش محتوا به اندازهٔ پهن‌ترین جدولش باز
       می‌شد و کل صفحه را از عرض گوشی پهن‌تر می‌کرد. */
    .shell{ flex-direction:column; align-items:stretch; }

    /* ستونِ کناری روی گوشی یک نوارِ تب می‌شود — ولی «پیچیده در چند
       ردیف» نه. کارتابلِ مدیر IT هفده دکمه دارد و وقتی می‌پیچیدند
       ۵۳۱ پیکسل می‌شدند: روی صفحهٔ ۶۶۴ پیکسلی، محتوا از پیکسلِ ۶۶۵
       شروع می‌شد. یعنی یک صفحهٔ کامل منو، پیش از آنکه چیزی دیده شود.

       حالا یک ردیف که افقی می‌لغزد: همان هفده دکمه سرِ جایشان‌اند،
       جای پنج ردیف یکی می‌گیرند، و بقیه با کشیدنِ انگشت می‌آیند. */
    .sidebar{
      width:auto; flex:none; height:auto; max-height:none;
      overflow:visible;
      padding:8px 0 0;
      border-left:none; border-bottom:1px solid rgba(11,37,69,.10);
      flex-direction:column; gap:6px;
      /* چسباندنش به بالا وسوسه‌انگیز بود و امتحانش کردم: با دکمه‌های
         پایین، ۱۰۸ پیکسل از هر صفحه را برای همیشه می‌گرفت — روی صفحهٔ
         ۶۶۴ پیکسلی یعنی یک‌ششمِ نما. و شکایت از همین بود که منو جا
         می‌گیرد. پس ثابت می‌ماند و با صفحه بالا می‌رود؛ وقتی جدولی را
         می‌خوانی، تمامِ صفحه مالِ خودِ جدول است. */
      position:static;
    }

    /* «.sidebar .nav-list» و نه «.nav-list»: navcss بعد از این فایل
       می‌آید و overflow-x:hidden دارد. با انتخابگرِ مشخص‌تر، بی‌آنکه
       ترتیبِ فایل‌ها عوض شود، این یکی می‌چربد. */
    /* دکمهٔ منو: نامِ بخشی که در آن هستی. تنها چیزی که در حالتِ بسته
       از نوارِ بخش‌ها دیده می‌شود. */
    .nav-toggle{
      display:flex; align-items:center; gap:9px;
      margin:0 12px 8px; padding:10px 13px;
      font-family:var(--font-body); font-size:13px; font-weight:600;
      color:var(--ink); background:var(--white);
      border:1px solid var(--card-border); border-radius:11px;
      cursor:pointer; text-align:start; width:calc(100% - 24px);
    }
    .nav-toggle .ic{ font-size:15px; line-height:1; flex:none }
    .nav-toggle .t{ flex:1; min-width:0; overflow:hidden;
      text-overflow:ellipsis; white-space:nowrap }
    .nav-toggle .caret{ flex:none; font-size:11px; color:var(--ink-faint);
      transition:transform .15s }
    .sidebar.nav-open .nav-toggle{ border-color:var(--brass); }
    .sidebar.nav-open .nav-toggle .caret{ transform:rotate(180deg) }

    /* فهرستِ بسته ارتفاع نمی‌گیرد — ایرادِ قدیمی («منو یک‌ششمِ صفحه را
       می‌خورد») این‌طور برنمی‌گردد. باز که شد، دو ستون: هفده بخش در
       نُه ردیف، همه با هم دیده می‌شوند.

       «.sidebar .nav-list» و نه «.nav-list»: navcss بعد از این فایل
       می‌آید و overflow-x:hidden دارد. با انتخابگرِ مشخص‌تر، بی‌آنکه
       ترتیبِ فایل‌ها عوض شود، این یکی می‌چربد. */
    .sidebar.nav-js .nav-list{ display:none; }
    .sidebar.nav-js.nav-open .nav-list{
      display:grid; grid-template-columns:1fr 1fr;
      align-content:start; gap:6px; padding:0 12px 10px;
      max-height:56vh; overflow-y:auto; overflow-x:hidden;
      -webkit-overflow-scrolling:touch;
    }

    .nav-label{ display:none; }
    .navbtn{
      width:auto; min-width:0; margin-bottom:0; padding:9px 11px;
      font-size:12.5px; gap:7px; border-radius:9px;
      background:var(--white); border:1px solid var(--line);
      /* در دو ستونِ باریک، نامِ بلند باید بشکند نه اینکه بیرون بزند. */
      white-space:normal; line-height:1.5; text-align:start;
    }
    .navbtn.active{ border-color:transparent; }
    /* در این چیدمان، نوارِ لبه جای درستی ندارد. */
    .navbtn.active::before{ display:none; }
    .navbtn .ic{ font-size:13px; flex:none; }

    /* بخش‌های مشترک در ستونِ عمودی تمامِ عرض را می‌گرفتند و تورفتگی
       داشتند؛ در خانه‌های یک گرید هر دو بی‌معنی‌اند. */
    .navbtn.sh-ingroup{
      width:auto; margin-inline-start:0; padding-inline-start:11px;
    }
    /* نامِ گروه، سرخطِ همان دو ستون می‌شود. */
    .sh-org{
      grid-column:1 / -1; margin:4px 2px 0; padding:0;
      border:none; font-size:10.5px;
    }

    .sidebar-foot{
      margin-top:0; padding:0 12px 8px;
      border-top:none;
      flex-direction:row; align-items:center; flex-wrap:nowrap; gap:6px;
      overflow-x:auto; scrollbar-width:none;
    }
    .sidebar-foot::-webkit-scrollbar{ display:none; }
    /* «✓ ذخیره شد» یک ردیفِ کامل می‌گرفت. حالا کنارِ دکمه‌ها می‌نشیند
       و وقتی خالی است جایی نمی‌گیرد. */
    .sidebar-foot .save-hint{
      flex:0 1 auto; min-height:0; order:3;
      font-size:11px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
    }
    .foot-actions{ flex:0 0 auto; order:1; gap:6px; }
    .foot-actions .btn, .foot-lock{
      padding:6px 10px; font-size:11.5px; white-space:nowrap;
    }
    .foot-lock{ width:auto; flex:0 0 auto; order:2; margin:0; }

    .content{ padding:16px 14px 48px; width:100%; max-width:100%; }
    .section-title{ font-size:16px; }
    /* جدول‌ها از قبل ظرفِ اسکرول‌دار داشتند؛ پنل‌های دیگر هم نباید
       صفحه را پهن کنند. */
    .panel{ padding:14px 13px; }
    .panel:hover{ transform:none; }
    .grid2, .grid3{ grid-template-columns:1fr; }
    /* خانه‌های گرید به‌طور پیش‌فرض کوچک‌تر از محتوایشان نمی‌شوند و روی
       صفحهٔ خیلی باریک (۳۲۰ پیکسل) کل صفحه را پهن می‌کردند. */
    .grid2 > *, .grid3 > *, .cards > *{ min-width:0; }
    .set-grid{ grid-template-columns:1fr; }
    .gate-card{ max-width:none; }

    /* نوارهایی که چند ورودی را کنار هم می‌گذارند روی عرض گوشی جا
       نمی‌شوند و کل صفحه را پهن می‌کنند. اجازه می‌دهیم بشکنند و
       ورودی‌ها تمام عرض را بگیرند. */
    .visit-add-bar, .dt-row, .inst-date-row, .cred-import-bar, .clv-row{
      flex-wrap:wrap;
    }
    .visit-add-bar input, .visit-add-bar select,
    .dt-row select, .dt-row input[type="date"]{
      flex:1 1 130px; min-width:0;
    }
    .visit-add-bar .btn{ flex:1 1 100%; justify-content:center; }
    .toolbar{ gap:8px; }
    .toolbar .btn{ flex:1 1 auto; justify-content:center; }
  }

  @media (max-width:420px){
    .brand h1{ font-size:13.5px; }
    .navbtn{ padding:7px 10px; font-size:12px; }
    .content{ padding:14px 11px 44px; }
  }