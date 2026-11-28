  /* ---------- منوی کشویی ----------
     ستونِ بخش‌ها تا یک نوارِ باریکِ آیکنی جمع می‌شود و دوباره باز
     می‌شود. روی صفحهٔ کوچک کاری نمی‌کند، چون آن‌جا خودِ ستون از قبل
     کشویی است (mobilecss) و دو سازوکارِ کشویی روی هم، هیچ‌کدام درست
     کار نمی‌کردند. */
  .nav-fold{
    display:none; align-items:center; justify-content:center;
    flex:none; width:32px; height:30px;
    margin:0 8px 10px; align-self:flex-start;
    font-family:var(--font-body); font-size:14px; line-height:1;
    color:var(--ink-faint); background:var(--white);
    border:1px solid var(--card-border); border-radius:9px;
    cursor:pointer; transition:color .15s, border-color .15s;
  }
  .nav-fold:hover{ color:var(--brass-ink); border-color:var(--brass); }
  .nav-fold .nf-ic{ pointer-events:none; }

  /* آیکنِ دکمه‌های پایینِ ستون را جاوااسکریپت از متنش جدا می‌کند؛
     فاصله‌شان این‌جا برمی‌گردد تا مثل قبل خوانده شوند. */
  .sidebar-foot .btn .ic{ margin-inline-end:4px; }

  @media (min-width:761px){
    .nav-fold{ display:flex; }
    .sidebar{ transition:width .18s ease, flex-basis .18s ease, padding .18s ease; }

    /* ستونِ بسته: فقط آیکن‌ها. نوشتهٔ دکمه‌ها متنِ لخت است و با
       انتخابگر نمی‌شود پنهانش کرد، پس اندازهٔ قلمِ خودِ دکمه را صفر
       می‌کنیم و به آیکن اندازهٔ خودش را برمی‌گردانیم. این‌طور
       دکمه‌هایی هم که بعداً با جاوااسکریپت اضافه می‌شوند (بخش‌های
       اشتراکی) همان رفتار را دارند. */
    html.nav-shut .sidebar{
      width:60px; flex:0 0 60px; padding-left:7px; padding-right:7px;
    }
    html.nav-shut .nav-fold{ align-self:center; margin:0 0 10px; }
    html.nav-shut .nav-label{ display:none; }
    html.nav-shut .nav-list .navbtn{
      justify-content:center; gap:0; font-size:0; padding:9px 0;
    }
    html.nav-shut .nav-list .navbtn .ic{ font-size:16px; flex:none; }
    html.nav-shut .nav-list .navbtn .tx,
    html.nav-shut .nav-list .navbtn .vs-t,
    html.nav-shut .sidebar-foot .tx{ display:none; }
    html.nav-shut .navbtn.active::before{ display:none; }
    html.nav-shut .sidebar-foot{ padding-left:0; padding-right:0; }
    html.nav-shut .sidebar-foot .save-hint{ display:none; }
    html.nav-shut .sidebar-foot .foot-actions{ display:flex; flex-direction:column; gap:4px; }
    html.nav-shut .sidebar-foot .btn{
      display:flex; align-items:center; justify-content:center;
      padding:8px 0; font-size:0; min-width:0;
    }
    html.nav-shut .sidebar-foot .btn .ic{ font-size:14px; line-height:1; }
  }
