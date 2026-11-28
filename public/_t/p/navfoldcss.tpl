  /* ---------- منوی کشویی ----------
     ستونِ بخش‌ها تا یک نوارِ باریکِ آیکنی جمع می‌شود و دوباره باز
     می‌شود. روی صفحهٔ کوچک کاری نمی‌کند، چون آن‌جا خودِ ستون از قبل
     کشویی است (mobilecss) و دو سازوکارِ کشویی روی هم، هیچ‌کدام درست
     کار نمی‌کردند. */
  .nav-fold{
    display:none; align-items:center; justify-content:center;
    flex:none; width:36px; height:32px;
    margin:0 6px 8px; align-self:flex-start;
    font-family:var(--font-body); font-size:15px; line-height:1;
    color:var(--ink-faint); background:transparent;
    border:1px solid transparent; border-radius:11px;
    cursor:pointer; transition:background .15s, color .15s;
  }
  .nav-fold:hover{ color:var(--brass-ink); background:rgba(11,37,69,.05); }
  .nav-fold .nf-ic{ pointer-events:none; }

  /* آیکنِ دکمه‌های پایینِ ستون را جاوااسکریپت از متنش جدا می‌کند؛
     فاصله‌شان این‌جا برمی‌گردد تا مثل قبل خوانده شوند. */
  .sidebar-foot .btn .ic{ margin-inline-end:4px; }

  @media (min-width:761px){
    .nav-fold{ display:flex; }
    .sidebar{ transition:width .18s ease, flex-basis .18s ease, padding .18s ease; }

    /* ستونِ بسته: فقط آیکن‌ها، هر کدام در یک کاشیِ هم‌اندازه. نوشتهٔ
       دکمه‌ها متنِ لخت است و با انتخابگر نمی‌شود پنهانش کرد، پس
       اندازهٔ قلمِ خودِ دکمه را صفر می‌کنیم و به آیکن اندازهٔ خودش را
       برمی‌گردانیم. این‌طور دکمه‌هایی هم که بعداً با جاوااسکریپت
       اضافه می‌شوند (بخش‌های اشتراکی) همان رفتار را دارند. */
    html.nav-shut .sidebar{
      width:58px; flex:0 0 58px; padding-left:5px; padding-right:5px;
    }
    html.nav-shut .nav-fold{ align-self:center; margin:0 0 6px; }
    html.nav-shut .nav-label{ display:none; }

    html.nav-shut .nav-list{ align-items:center; }
    html.nav-shut .nav-list .navbtn{
      width:40px; min-width:40px; height:38px;
      margin:0 auto 2px; padding:0;
      justify-content:center; gap:0; font-size:0;
      border-radius:12px;
    }
    html.nav-shut .nav-list .navbtn .ic{
      font-size:17px; width:auto; height:auto; flex:none; opacity:.72;
    }
    html.nav-shut .nav-list .navbtn:hover .ic{ opacity:.95; }
    html.nav-shut .nav-list .navbtn.active .ic{ opacity:1; }
    html.nav-shut .nav-list .navbtn .tx,
    html.nav-shut .nav-list .navbtn .vs-t,
    html.nav-shut .sidebar-foot .tx{ display:none; }
    /* نشانگرِ کناریِ بخشِ فعال، در نوارِ باریک فقط یک خطِ سرگردان
       می‌شد؛ خودِ کاشیِ رنگی کارش را می‌کند. */
    html.nav-shut .navbtn.active::before{ display:none; }

    /* خطِ جداکننده تا معلوم باشد این سه تا کارِ دیگری می‌کنند. */
    html.nav-shut .sidebar-foot{
      padding-left:0; padding-right:0; padding-top:7px; margin-top:3px;
      border-top:1px solid rgba(11,37,69,.08);
    }
    html.nav-shut .sidebar-foot .save-hint{ display:none; }
    html.nav-shut .sidebar-foot .foot-actions{
      display:flex; flex-direction:column; align-items:center; gap:3px; flex:none;
    }
    html.nav-shut .sidebar-foot .btn{
      display:flex; align-items:center; justify-content:center;
      flex:none; width:40px; min-width:40px; height:34px;
      margin:0 auto 3px; padding:0; font-size:0; border-radius:12px;
    }
    html.nav-shut .sidebar-foot .btn .ic{
      font-size:15px; line-height:1; margin:0; opacity:.78;
    }
    html.nav-shut .sidebar-foot .btn:hover .ic{ opacity:1; }
  }
