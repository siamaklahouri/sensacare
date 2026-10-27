
  /* ---------- برو بالا / برو پایین ----------
     یک دکمهٔ گردِ کوچک در گوشهٔ پایینِ چپ.

     اول راست بود و غلط: در صفحهٔ راست‌به‌چپ، ستونِ بخش‌ها سمتِ راست
     است و تهش «پشتیبان»، «بازیابی» و «خروج از کارتابل» نشسته‌اند —
     دکمه درست روی «خروج از کارتابل» می‌افتاد. گوشهٔ چپ مالِ دکمهٔ
     گفتگوست، ولی آن‌جا جا هست: این یکی کنارش می‌ایستد، نه رویش. و
     «body.chat-fab» را خودِ chat.js می‌گذارد، پس در پنلِ ادمین که
     گفتگو ندارد، دکمه همان گوشه می‌نشیند بی‌فاصلهٔ بی‌دلیل.

     z-index عمداً پایین است (۹۰): هر پنجره و هر نوارِ هشدار از این
     بالاتر است و رویش می‌افتد. دکمهٔ پریدن وقتی یک پنجره باز است یا
     دارد خطایی خوانده می‌شود، کارِ درستی ندارد که بکند. */
  .updown{
    position:fixed; z-index:90;
    inset-inline-end:20px; bottom:20px;
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

  /* کنارِ دکمهٔ گفتگو، هم‌ردیفِ خودش: ۵۶ پیکسل عرضِ آن به‌علاوهٔ ۲۰
     فاصله‌اش از لبه و ۱۲ فاصلهٔ بینشان؛ و چون این یکی کوتاه‌تر است،
     نصفِ اختلاف پایین‌تر می‌نشیند تا مرکزشان یک خط شود. */
  body.chat-fab .updown{ inset-inline-end:88px; bottom:27px; }

  @media (max-width:760px){
    .updown{ width:38px; height:38px; inset-inline-end:16px; bottom:16px; }
    .updown svg{ width:17px; height:17px; }
    /* روی گوشی دکمهٔ گفتگو ۵۰ پیکسل است و از ۱۶ شروع می‌شود */
    body.chat-fab .updown{ inset-inline-end:78px; bottom:22px; }
  }

  /* ---------- کفِ صفحه همیشه خالی نیست ----------
     در حالتِ برنامه نوارِ پایینی آن‌جاست و در نسخهٔ نمایشی نوارِ «دمو».
     دکمه به اندازهٔ خودشان بالا می‌رود.

     این‌ها عمداً آخرِ فایل‌اند: «html[data-app] .updown» و
     «body.chat-fab .updown» دقیقاً هم‌وزن‌اند (یک کلاس و یک صفت و یک
     عنصر) و در هم‌وزنی، ترتیبِ فایل تصمیم می‌گیرد. اولین بار همین‌جا
     غلط شد — بالا نوشته بودمشان و قاعدهٔ «کنارِ گفتگو» از زیرشان
     ردشان می‌کرد، پس دکمه روی نوارِ پایینیِ برنامه می‌افتاد.

     و هر حالت دو عدد دارد، نه یکی: وقتی دکمهٔ گفتگو هم هست، این یکی
     باید همان‌قدر بالاتر برود که مرکزشان یک خط بماند — نصفِ اختلافِ
     قدشان. */
  html[data-demo="1"] .updown{ bottom:62px; }
  html[data-demo="1"] body.chat-fab .updown{ bottom:69px; }
  @media (max-width:900px){
    html[data-app="1"] .updown{
      bottom:calc(86px + env(safe-area-inset-bottom, 0px));
    }
    html[data-app="1"] body.chat-fab .updown{
      bottom:calc(92px + env(safe-area-inset-bottom, 0px));
    }
  }
