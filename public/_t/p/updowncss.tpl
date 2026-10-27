
  /* ---------- برو بالا / برو پایین ----------
     یک دکمهٔ گردِ کوچک، سمتِ راستِ پایینِ صفحه.

     ولی نه چسبیده به لبهٔ راست: در صفحهٔ راست‌به‌چپ، ستونِ بخش‌ها همان
     سمت است و تهش «پشتیبان»، «بازیابی» و «خروج از کارتابل» نشسته‌اند —
     دکمه درست روی «خروج از کارتابل» می‌افتاد. پس به اندازهٔ همان ستون
     تو می‌آید و کنارش می‌ایستد، نه رویش. جایی که ستون نیست — پنلِ
     ادمین، یا گوشی که ستون می‌رود بالا — همان گوشهٔ راست می‌نشیند.

     دکمهٔ گفتگو سمتِ چپ است («left» در chat.js) و این‌طور اصلاً به هم
     نمی‌رسند.

     z-index عمداً پایین است (۹۰): هر پنجره و هر نوارِ هشدار از این
     بالاتر است و رویش می‌افتد. دکمهٔ پریدن وقتی یک پنجره باز است یا
     دارد خطایی خوانده می‌شود، کارِ درستی ندارد که بکند. */
  .updown{
    position:fixed; z-index:90;
    inset-inline-start:20px; bottom:20px;
    width:42px; height:42px; padding:0; flex:none;
    display:flex; align-items:center; justify-content:center;
    cursor:pointer; border-radius:50%;
    background:var(--white); color:var(--ink-soft);
    border:1px solid var(--line);
    box-shadow:0 2px 6px rgba(11,37,69,.08), 0 10px 26px rgba(11,37,69,.14);
    transition:opacity .18s, transform .18s, border-color .15s, color .15s;
  }
  .updown svg{
    width:19px; height:19px; display:block;
    transition:transform .24s cubic-bezier(.2,.8,.3,1);
  }
  /* همان یک پیکان می‌چرخد، نه دو آیکنِ جدا: چرخشش خودش می‌گوید که
     این همان دکمه است با جهتِ برگشته. */
  .updown.up svg{ transform:rotate(180deg); }
  .updown:hover{ border-color:var(--brass); color:var(--brass); }
  .updown:active{ transform:scale(.93); }
  .updown:focus-visible{ outline:2px solid var(--brass); outline-offset:2px; }
  /* صفحه‌ای که اسکرول ندارد، دکمه هم ندارد — دکمه‌ای که کاری نمی‌کند
     بدتر از نبودنش است. برداشته نمی‌شود، محو می‌شود، تا جابه‌جاییِ
     ناگهانی در گوشهٔ چشم نیفتد. */
  .updown.off{ opacity:0; transform:translateY(10px) scale(.9); pointer-events:none; }
  /* «!important» لازم است: قاعدهٔ مرورگر برای [hidden] یک انتخابگرِ
     ساده است و «display:flex» بالا از آن سنگین‌تر. */
  .updown[hidden]{ display:none !important; }
  @media print{ .updown{ display:none !important; } }
  @media (prefers-reduced-motion: reduce){
    .updown, .updown svg{ transition:none; }
  }

  /* ---------- کنارِ ستونِ بخش‌ها ----------
     ۲۱۶ پیکسل عرضِ ستون به‌علاوهٔ ۱۸ فاصله. کلاسِ «ud-side» را خودِ
     اسکریپت می‌گذارد، وقتی صفحه واقعاً ستونِ بخش‌ها داشته باشد — پنلِ
     ادمین ندارد و آن‌جا دکمه همان گوشهٔ راست می‌ماند.

     آستانهٔ ۷۶۱ همان آستانهٔ خودِ چیدمان است (mobilecss): از آن پایین‌تر
     ستون می‌رود بالای صفحه و لبهٔ راست آزاد می‌شود. */
  @media (min-width:761px){
    body.ud-side .updown{ inset-inline-start:234px; }
  }

  @media (max-width:760px){
    .updown{ width:38px; height:38px; inset-inline-start:16px; bottom:16px; }
    .updown svg{ width:17px; height:17px; }
  }

  /* در حالتِ برنامه، ستونِ بخش‌ها تا ۹۰۰ پیکسل برداشته می‌شود (pwacss)
     و کارش را نوارِ پایینی می‌کند؛ پس آن فاصله دیگر معنا ندارد. */
  @media (min-width:761px) and (max-width:900px){
    html[data-app="1"] body.ud-side .updown{ inset-inline-start:20px; }
  }

  /* ---------- کفِ صفحه همیشه خالی نیست ----------
     در حالتِ برنامه نوارِ پایینی آن‌جاست و در نسخهٔ نمایشی نوارِ «دمو».
     دکمه به اندازهٔ خودشان بالا می‌رود.

     این‌ها عمداً آخرِ فایل‌اند: قاعده‌هایی که جای افقیِ دکمه را عوض
     می‌کنند هم‌وزنشان‌اند و در هم‌وزنی ترتیبِ فایل تصمیم می‌گیرد. یک بار
     همین‌جا غلط شد — بالا نوشته بودمشان و قاعدهٔ بعدی از زیرشان ردشان
     می‌کرد، پس دکمه روی نوارِ پایینیِ برنامه می‌افتاد. */
  html[data-demo="1"] .updown{ bottom:62px; }
  @media (max-width:900px){
    html[data-app="1"] .updown{
      bottom:calc(86px + env(safe-area-inset-bottom, 0px));
    }
  }
