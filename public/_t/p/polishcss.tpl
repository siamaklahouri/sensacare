  /* ==================== آرام‌کردنِ ردیف ====================
     در نماگرفتِ دو برابر، یک ردیفِ چک‌لیست شش چیزِ قاب‌دار داشت:
     مهلت، وضعیت، اولویت، تکرار، پیوست و حذف. هر کدام قاب و زمینهٔ
     خودش را داشت، پس هیچ‌کدام برجسته نبود — شانزده ردیف که کنارِ هم
     می‌نشست، چشم جایی برای ایستادن نداشت.

     قاعده‌ای که این‌جا اعمال می‌شود: هر چیزی که کم عوض می‌شود،
     ساکت می‌ماند تا موشواره یا صفحه‌کلید سراغش برود. آن‌چه حالِ کار
     را می‌گوید — وضعیت، و مهلتی که گذشته — پررنگ می‌ماند.

     این «کمتر نشان دادن» نیست؛ همان چیزها سرِ جایشان‌اند. فقط
     بلندیِ صدایشان با اهمیتشان یکی شده. */

  /* «هر ماه» داده‌ای است که ماه‌ها عوض نمی‌شود. تا وقتی کسی سراغش
     نرفته، قاب و زمینه لازم ندارد. */
  .rep-box{
    background:transparent;
    border-color:transparent;
  }
  .rep-cell:hover .rep-box,
  .rep-box:hover,
  .rep-box:focus{
    background:var(--paper); border-color:var(--line);
  }

  /* مهلت هم همین‌طور — مگر وقتی گذشته باشد، که آن یکی باید داد
     بزند. قابِ قرمزِ .od دست‌نخورده می‌ماند. */
  .date-box:not(.od){
    background:transparent;
    border-color:color-mix(in srgb, var(--card-border) 60%, transparent);
  }
  @supports not (color: color-mix(in srgb, red 50%, transparent)){
    .date-box:not(.od){ border-color:var(--card-border); }
  }
  tbody tr:hover .date-box:not(.od){
    background:var(--white); border-color:var(--card-border);
  }

  /* ==================== جای ایستادنِ صفحه‌کلید ====================
     خانه‌های جدول روی فوکوس فقط قابِ یک‌پیکسلی‌شان عوض می‌شد و
     «outline:none» هم داشتند. با Tab هیچ‌چیز دیده نمی‌شد — نه برای
     کسی که با صفحه‌کلید کار می‌کند، نه برای کسی که صفحه‌خوان دارد.

     حلقه فقط با :focus-visible می‌آید، پس با کلیکِ موشواره ظاهر
     نمی‌شود و شلوغی اضافه نمی‌کند. */
  .content :is(input, select, textarea, button):focus-visible,
  .nav-list .navbtn:focus-visible,
  .topbar button:focus-visible{
    outline:2px solid var(--brass);
    outline-offset:1px;
    border-radius:7px;
  }
  /* خانه‌های جدول قاعدهٔ «outline:none» خودشان را دارند و وزنش از
     قاعدهٔ بالا بیشتر است؛ پس این‌جا صریح نوشته می‌شود، وگرنه حلقه
     بی‌صدا بی‌اثر می‌ماند — همان اول همین شد و با اندازه‌گیری
     معلوم شد. */
  .content td input[type=text]:focus-visible,
  .content td input[type=number]:focus-visible,
  .content td select:focus-visible,
  .content td textarea:focus-visible{
    outline:2px solid var(--brass);
    outline-offset:0;
  }

  /* ==================== نوارِ لغزش ====================
     جدول‌ها افقی می‌لغزند و نوارِ پیش‌فرضِ مرورگر کنارِ این رنگ‌ها
     درشت و بی‌ربط می‌نشیند. */
  .tbl-wrap, .content, .nav-list{
    scrollbar-width:thin;
    scrollbar-color:var(--card-border) transparent;
  }
  .tbl-wrap::-webkit-scrollbar, .content::-webkit-scrollbar,
  .nav-list::-webkit-scrollbar{ width:9px; height:9px; }
  .tbl-wrap::-webkit-scrollbar-track, .content::-webkit-scrollbar-track,
  .nav-list::-webkit-scrollbar-track{ background:transparent; }
  .tbl-wrap::-webkit-scrollbar-thumb, .content::-webkit-scrollbar-thumb,
  .nav-list::-webkit-scrollbar-thumb{
    background:var(--card-border); border-radius:999px;
    border:2px solid transparent; background-clip:content-box;
  }
  .tbl-wrap::-webkit-scrollbar-thumb:hover, .content::-webkit-scrollbar-thumb:hover,
  .nav-list::-webkit-scrollbar-thumb:hover{ background-clip:content-box; background:var(--ink-faint); }
