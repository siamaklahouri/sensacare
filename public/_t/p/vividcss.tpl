  /* ==================== پوستهٔ «رنگی» ====================
     کارتابل درست بود ولی بی‌روح: کارتِ سفید روی کاغذِ خاکستری، و یک
     سرمه‌ای که همه‌جا تکرار می‌شد. این پوسته همان ساختار را نگه
     می‌دارد و فقط جانش را عوض می‌کند — رنگ، عمق، و کمی جنب‌وجوش.

     سه قاعده که این‌جا رعایت شده:

     یک) هیچ اندازه‌ای عوض نمی‌شود. نه padding، نه font-size، نه پهنا،
         نه حتی وزنِ قلم — یک بار «وضعیت» را بولد کردم و همان، متنِ
         «در حال انجام» را داخلِ ستونِ ۱۲۸ پیکسلی برید.
         فقط رنگ و سایه و گرادیان. این‌طور چیدمانِ جدول‌ها و ستون‌ها
         دست‌نخورده می‌ماند و چیزی از جا در نمی‌رود.

     دو) رنگ‌ها از همان متغیرهای خودِ کارتابل ساخته می‌شوند
         (color-mix روی --brass و --teal و …)، نه از هگزِ تازه. پس تمِ
         شب خودش درست می‌شود و لازم نیست دو بار نوشته شود.

     سه) رنگ در خدمتِ معنی است، نه تزیین: وضعیتِ «انجام شد» سبز است،
         «در حال انجام» آبی، «انجام نشده» کهربایی — همان‌ها که نمودارها
         هم می‌گویند.

     روشن/خاموشش دستِ پنل است: این شیوه‌نامه فقط زیرِ
     body[data-skin="vivid"] کار می‌کند. */

  body[data-skin="vivid"]{
    /* کاغذ، کمی گرم‌تر و زنده‌تر */
    background:
      radial-gradient(1100px 520px at 100% -8%, color-mix(in srgb, var(--teal) 16%, transparent), transparent 62%),
      radial-gradient(900px 460px at -8% 2%, color-mix(in srgb, var(--purple) 13%, transparent), transparent 58%),
      radial-gradient(800px 520px at 50% 112%, color-mix(in srgb, var(--brass) 11%, transparent), transparent 60%),
      var(--paper);
  }

  /* ---------- نوارِ بالا ---------- */
  body[data-skin="vivid"] .topbar{
    background:
      linear-gradient(118deg,
        color-mix(in srgb, var(--purple) 7%, var(--white)) 0%,
        color-mix(in srgb, var(--brass) 14%, var(--white)) 48%,
        color-mix(in srgb, var(--teal) 16%, var(--white)) 100%);
    border-bottom:0;
    box-shadow:0 1px 2px rgba(11,37,69,.06), 0 8px 24px -16px rgba(11,37,69,.35);
    position:sticky;
  }
  /* نوارِ رنگیِ زیرِ هدر — سه رنگِ هویت، پشتِ سرِ هم */
  body[data-skin="vivid"] .topbar::after{
    content:""; position:absolute; inset-inline:0; bottom:0; height:3px;
    background:linear-gradient(90deg, var(--teal), var(--brass) 42%, var(--purple) 78%, var(--amber));
    opacity:.85;
  }
  body[data-skin="vivid"] .brand .mark{
    box-shadow:0 0 0 3px color-mix(in srgb, var(--brass) 18%, transparent),
               0 4px 14px rgba(18,46,110,.28);
  }
  body[data-skin="vivid"] .topbar-clock{
    background:linear-gradient(135deg, color-mix(in srgb, var(--brass) 14%, var(--white)),
                                       color-mix(in srgb, var(--teal) 12%, var(--white)));
    color:var(--brass-ink);
  }

  /* ---------- نوارِ کنار ---------- */
  body[data-skin="vivid"] .sidebar{
    background:linear-gradient(180deg,
      color-mix(in srgb, var(--brass) 7%, var(--white)) 0%,
      color-mix(in srgb, var(--purple) 5%, var(--white)) 55%,
      color-mix(in srgb, var(--white) 70%, transparent) 100%);
    /* خودِ قالب border-left دارد؛ این‌جا فقط رنگش عوض می‌شود. اگر
       border-inline-start بنویسیم، در راست‌چین لبهٔ دیگری است و نوار
       یک پیکسل باریک‌تر می‌شود. */
    border-left-color:color-mix(in srgb, var(--brass) 22%, transparent);
  }
  /* هر بخش رنگِ خودش را دارد: چهارده ردیفِ یک‌رنگ همان چیزی بود که
     ستون را بی‌روح می‌کرد. رنگ‌ها می‌چرخند، پس هر ردیف از ردیفِ
     بالایی‌اش جدا دیده می‌شود. */
  body[data-skin="vivid"] .navbtn .ic{
    background:color-mix(in srgb, var(--nv, var(--brass)) 34%, var(--white));
    border-radius:8px; opacity:1;
    box-shadow:inset 0 0 0 1px color-mix(in srgb, var(--nv, var(--brass)) 42%, transparent);
  }
  body[data-skin="vivid"] .navbtn:nth-child(7n+1){ --nv:var(--brass); }
  body[data-skin="vivid"] .navbtn:nth-child(7n+2){ --nv:var(--green); }
  body[data-skin="vivid"] .navbtn:nth-child(7n+3){ --nv:var(--amber); }
  body[data-skin="vivid"] .navbtn:nth-child(7n+4){ --nv:var(--teal); }
  body[data-skin="vivid"] .navbtn:nth-child(7n+5){ --nv:var(--purple); }
  body[data-skin="vivid"] .navbtn:nth-child(7n+6){ --nv:var(--red); }
  body[data-skin="vivid"] .navbtn:nth-child(7n+7){ --nv:var(--brass-deep); }
  body[data-skin="vivid"] .navbtn:hover{
    background:color-mix(in srgb, var(--nv, var(--brass)) 12%, transparent);
    color:var(--ink);
  }
  /* بخشِ باز: یک قرصِ رنگیِ پُر، نه یک لکهٔ کم‌رنگ */
  body[data-skin="vivid"] .navbtn.active{
    background:linear-gradient(135deg,
      color-mix(in srgb, var(--nv, var(--brass)) 92%, #000 0%),
      color-mix(in srgb, var(--nv, var(--brass)) 72%, var(--brass-deep)));
    color:#fff;
    box-shadow:0 6px 16px -8px color-mix(in srgb, var(--nv, var(--brass)) 85%, transparent);
  }
  body[data-skin="vivid"] .navbtn.active .ic{
    background:rgba(255,255,255,.22); box-shadow:none;
  }
  body[data-skin="vivid"] .navbtn.active::before{
    background:#fff; opacity:.85;
  }
  body[data-skin="vivid"] .nav-label{ color:var(--brass-ink); }

  /* ---------- سرفصلِ بخش‌ها ---------- */
  /* نوشته از سرمه‌ای به آبیِ برند می‌رود — کم، ولی همان‌قدر که از
     «یک تیترِ مشکی» درش بیاورد. هر دو سرِ گرادیان تیره‌اند، پس
     خوانایی‌اش دست‌نخورده می‌ماند. */
  body[data-skin="vivid"] .section-title{
    background:linear-gradient(100deg, var(--ink) 25%, var(--brass-ink));
    -webkit-background-clip:text; background-clip:text;
    -webkit-text-fill-color:transparent; color:transparent;
  }
  body[data-skin="vivid"] .section-title::before{
    background:linear-gradient(180deg, var(--teal), var(--brass) 55%, var(--purple));
    box-shadow:0 2px 10px color-mix(in srgb, var(--brass) 45%, transparent);
  }

  /* ---------- کاشی‌های آمار ---------- */
  body[data-skin="vivid"] .stat{
    background:linear-gradient(158deg,
      color-mix(in srgb, var(--tone, var(--brass)) 13%, var(--white)) 0%,
      var(--white) 62%);
    border-color:color-mix(in srgb, var(--tone, var(--brass)) 26%, var(--card-border));
    box-shadow:0 1px 2px rgba(11,37,69,.04),
               0 10px 24px -14px color-mix(in srgb, var(--tone, var(--brass)) 70%, transparent);
  }
  body[data-skin="vivid"] .stat::before{
    height:4px;
    background:linear-gradient(90deg,
      var(--tone, var(--brass)),
      color-mix(in srgb, var(--tone, var(--brass)) 45%, var(--white)));
  }
  body[data-skin="vivid"] .stat:hover{
    box-shadow:0 2px 6px rgba(11,37,69,.06),
               0 18px 36px -16px color-mix(in srgb, var(--tone, var(--brass)) 85%, transparent);
  }

  /* ---------- کارتِ خوش‌آمد ---------- */
  body[data-skin="vivid"] .dash-hero{
    background:linear-gradient(125deg,
      color-mix(in srgb, var(--brass) 12%, var(--white)) 0%,
      var(--white) 48%,
      color-mix(in srgb, var(--teal) 11%, var(--white)) 100%);
    border-color:color-mix(in srgb, var(--brass) 20%, var(--card-border));
  }

  /* ---------- کارت‌های داشبورد، گروه‌به‌گروه ----------
     داشبورد سه گروه دارد — وظایف، شرکت‌ها، زیرساخت — و هر گروه از
     قبل رنگِ خودش را داشت، ولی فقط روی یک آیکنِ کوچک. حالا همان رنگ
     روی کارت‌های همان گروه هم می‌نشیند، پس با یک نگاه معلوم است کجای
     داشبوردی. */
  body[data-skin="vivid"] .panel.accent-blue { --acc:var(--brass); }
  body[data-skin="vivid"] .panel.accent-amber{ --acc:var(--amber); }
  body[data-skin="vivid"] .panel.accent-teal { --acc:var(--teal); }
  body[data-skin="vivid"] .panel.accent-blue,
  body[data-skin="vivid"] .panel.accent-amber,
  body[data-skin="vivid"] .panel.accent-teal{
    background:linear-gradient(170deg,
      color-mix(in srgb, var(--acc) 13%, var(--white)) 0%,
      color-mix(in srgb, var(--acc) 2%, var(--white)) 58%);
    border-color:color-mix(in srgb, var(--acc) 26%, var(--card-border));
    /* نوارِ رنگیِ بالای کارت با سایهٔ داخلی کشیده می‌شود، نه با
       border: یک border-topِ سه‌پیکسلی، قدِ کارت را سه پیکسل بلندتر
       می‌کرد و همان «هیچ اندازه‌ای عوض نمی‌شود» را می‌شکست. */
    box-shadow:inset 0 3px 0 color-mix(in srgb, var(--acc) 72%, var(--white)),
               0 1px 2px rgba(11,37,69,.04),
               0 14px 30px -18px color-mix(in srgb, var(--acc) 75%, transparent);
  }
  /* سرفصلِ گروه: خطِ زیرش هم‌رنگِ خودِ گروه */
  body[data-skin="vivid"] .dash-group-label{
    border-bottom-color:color-mix(in srgb, var(--dgl-bg, var(--brass-bg)) 65%, var(--brass));
    color:var(--ink);
  }
  body[data-skin="vivid"] .dash-group-label .dgl-ic{
    box-shadow:inset 0 0 0 1px color-mix(in srgb, var(--brass) 20%, transparent);
  }

  /* ---------- کارت‌ها و جدول‌ها ---------- */
  body[data-skin="vivid"] .panel{
    background:linear-gradient(180deg,
      color-mix(in srgb, var(--brass) 9%, var(--white)) 0%,
      color-mix(in srgb, var(--brass) 2%, var(--white)) 90px);
    border-color:color-mix(in srgb, var(--brass) 20%, var(--card-border));
    box-shadow:0 1px 2px rgba(11,37,69,.04),
               0 12px 28px -18px color-mix(in srgb, var(--brass) 60%, transparent);
  }
  /* خودِ قابِ جدول هم کاغذِ سفیدِ خالی نماند */
  body[data-skin="vivid"] .tbl-wrap{
    background:color-mix(in srgb, var(--brass) 3%, var(--white));
  }
  /* این‌جا یک قاعدهٔ عمومی برای رنگِ ستونِ اول و خانه‌های تاریخ بود.
     برداشته شد: جدولِ بخش‌های مشترک رنگِ خودش را دارد (ردیفِ تمام‌شده،
     ردیفِ صاحب، تاریخِ انجام) و آن قاعده رویشان می‌نشست — یک بار
     کنتراستِ متنِ ردیفِ تمام‌شده را به ۲٫۳ رساند. */
  body[data-skin="vivid"] thead th{
    background:linear-gradient(180deg,
      color-mix(in srgb, var(--brass) 24%, var(--white)),
      color-mix(in srgb, var(--brass) 12%, var(--white)));
    color:var(--brass-ink);
    border-bottom-color:color-mix(in srgb, var(--brass) 28%, var(--line));
  }
  /* ردیفِ یک‌درمیان، با لهجهٔ رنگِ برند — نه خاکستریِ خالی.
     فقط جدول‌های خودِ کارتابل: بخش‌های مشترک، بخش‌های به‌اشتراک‌گذاشته و
     دیتای شخصی رنگِ معنادارِ خودشان را دارند (چه کسی ردیف را ساخته، چه
     چیزی تمام شده، ورودی یا خروجی) و یک ته‌رنگِ عمومی رویشان، همان را
     می‌پوشاند — یک بار کنتراستِ ردیفِ تمام‌شده را به ۲٫۳ رساند. */
  body[data-skin="vivid"] .view:not([id^="view-shared-"]):not([id^="view-vshare-"]):not(#view-personal) tbody tr:nth-child(even) > td{
    background:color-mix(in srgb, var(--brass) 4%, transparent);
  }
  body[data-skin="vivid"] .view:not([id^="view-shared-"]):not([id^="view-vshare-"]):not(#view-personal) tbody tr:hover > td{
    background:color-mix(in srgb, var(--teal) 9%, transparent);
  }

  /* ---------- ردیف، به‌رنگِ وضعیتش ----------
     جدولِ سفید با یک ستونِ رنگی هنوز سفید است. این‌جا خودِ ردیف ته‌رنگ
     می‌گیرد — خیلی کم، در حدِ یک اشاره — تا با یک نگاه معلوم باشد چه
     چیزی تمام شده و چه چیزی مانده. فیلتر و موشواره رویش می‌نشینند و
     پررنگ‌ترند، پس قاطی نمی‌شود. */
  /* :has داخلِ :has مجاز نیست (و بی‌صدا هم رد می‌شود، نه با خطا).
     پس مستقیم سراغِ خودِ گزینه می‌رویم: option داخلِ همان ردیف است. */
  body[data-skin="vivid"] .view:not([id^="view-shared-"]):not([id^="view-vshare-"]):not(#view-personal) tbody tr:has(option[value="انجام شد"]:checked) > td{
    background:color-mix(in srgb, var(--green) 6%, transparent);
  }
  body[data-skin="vivid"] .view:not([id^="view-shared-"]):not([id^="view-vshare-"]):not(#view-personal) tbody tr:has(option[value="انجام نشده"]:checked) > td{
    background:color-mix(in srgb, var(--amber) 7%, transparent);
  }
  body[data-skin="vivid"] .view:not([id^="view-shared-"]):not([id^="view-vshare-"]):not(#view-personal) tbody tr:hover > td{
    background:color-mix(in srgb, var(--teal) 12%, transparent);
  }

  /* ---------- وضعیت و اولویت، با رنگِ خودشان ----------
     رنگ از روی گزینهٔ انتخاب‌شده خوانده می‌شود، پس هیچ خطِ جاوااسکریپتی
     لازم نیست. مرورگرِ قدیمی که :has را نشناسد، همان کشویی ساده را
     نشان می‌دهد — چیزی خراب نمی‌شود. */
  body[data-skin="vivid"] select:has(option[value="انجام شد"]:checked){
    background:color-mix(in srgb, var(--green) 14%, var(--white));
    color:var(--green-ink);
    border-color:color-mix(in srgb, var(--green) 38%, var(--card-border));
  }
  body[data-skin="vivid"] select:has(option[value="در حال انجام"]:checked){
    background:color-mix(in srgb, var(--brass) 13%, var(--white));
    color:var(--brass-ink);
    border-color:color-mix(in srgb, var(--brass) 36%, var(--card-border));
  }
  body[data-skin="vivid"] select:has(option[value="انجام نشده"]:checked){
    background:color-mix(in srgb, var(--amber) 15%, var(--white));
    color:var(--amber-ink);
    border-color:color-mix(in srgb, var(--amber) 40%, var(--card-border));
  }
  body[data-skin="vivid"] select:has(option[value="بالا"]:checked){
    background:color-mix(in srgb, var(--red) 12%, var(--white));
    color:var(--red-ink);
    border-color:color-mix(in srgb, var(--red) 34%, var(--card-border));
  }
  body[data-skin="vivid"] select:has(option[value="متوسط"]:checked){
    background:color-mix(in srgb, var(--amber) 11%, var(--white));
    color:var(--amber-ink);
    border-color:color-mix(in srgb, var(--amber) 30%, var(--card-border));
  }
  body[data-skin="vivid"] select:has(option[value="پایین"]:checked){
    background:color-mix(in srgb, var(--teal) 11%, var(--white));
    color:var(--teal-ink);
    border-color:color-mix(in srgb, var(--teal) 30%, var(--card-border));
  }

  /* ---------- دکمه‌ها ---------- */
  body[data-skin="vivid"] .btn-ghost:hover{
    background:color-mix(in srgb, var(--brass) 10%, var(--white));
    border-color:color-mix(in srgb, var(--brass) 32%, var(--card-border));
    color:var(--brass-ink);
  }
  body[data-skin="vivid"] .btn-brass{
    background:linear-gradient(135deg, var(--teal), var(--brass) 55%, var(--brass-deep));
  }
  body[data-skin="vivid"] .foot-lock:hover{
    background:color-mix(in srgb, var(--red) 10%, var(--white));
    border-color:color-mix(in srgb, var(--red) 30%, var(--card-border));
    color:var(--red-ink);
  }

  /* ---------- زنگوله و قرصِ ماه ---------- */
  body[data-skin="vivid"] .bellb,
  body[data-skin="vivid"] .month-btn,
  body[data-skin="vivid"] .theme-btn{
    background:color-mix(in srgb, var(--brass) 8%, var(--white));
    border-color:color-mix(in srgb, var(--brass) 24%, var(--card-border));
  }
  body[data-skin="vivid"] .bellb:hover,
  body[data-skin="vivid"] .month-btn:hover,
  body[data-skin="vivid"] .theme-btn:hover{
    background:color-mix(in srgb, var(--brass) 16%, var(--white));
    border-color:var(--brass);
  }

  /* ---------- تمِ شب ----------
     بیشترِ رنگ‌ها خودشان درست می‌شوند (color-mix روی --white که در شب
     تیره است). این چند تا دستی تنظیم می‌شوند چون در شب باید کم‌رنگ‌تر
     باشند، وگرنه مثل چراغِ روی کاغذِ تیره می‌زنند. */
  html[data-theme="dark"] body[data-skin="vivid"]{
    background:
      radial-gradient(1100px 520px at 100% -8%, color-mix(in srgb, var(--teal) 22%, transparent), transparent 62%),
      radial-gradient(900px 460px at -8% 2%, color-mix(in srgb, var(--purple) 20%, transparent), transparent 58%),
      radial-gradient(800px 520px at 50% 112%, color-mix(in srgb, var(--brass) 16%, transparent), transparent 60%),
      var(--paper);
  }
  html[data-theme="dark"] body[data-skin="vivid"] .topbar::after{ opacity:.6; }
  /* در شب، چیپِ آیکن باید روشن‌تر از کاغذ باشد نه تیره‌تر: مخلوط با
     --white (که در شب تیره است) چیپ را گم می‌کرد. */
  html[data-theme="dark"] body[data-skin="vivid"] .navbtn .ic{
    background:color-mix(in srgb, var(--nv, var(--brass)) 32%, transparent);
    box-shadow:inset 0 0 0 1px color-mix(in srgb, var(--nv, var(--brass)) 45%, transparent);
  }
  html[data-theme="dark"] body[data-skin="vivid"] .view:not([id^="view-shared-"]):not([id^="view-vshare-"]):not(#view-personal) tbody tr:nth-child(even) > td{
    background:color-mix(in srgb, var(--brass) 9%, transparent);
  }
  html[data-theme="dark"] body[data-skin="vivid"] .view:not([id^="view-shared-"]):not([id^="view-vshare-"]):not(#view-personal) tbody tr:hover > td{
    background:color-mix(in srgb, var(--teal) 14%, transparent);
  }

  /* ---------- چاپ ----------
     روی کاغذ، رنگِ پس‌زمینه نه چاپ می‌شود نه به درد می‌خورد. */
  @media print{
    body[data-skin="vivid"], body[data-skin="vivid"] .topbar,
    body[data-skin="vivid"] .sidebar, body[data-skin="vivid"] .panel,
    body[data-skin="vivid"] .stat, body[data-skin="vivid"] .dash-hero{
      background:#fff !important; box-shadow:none !important;
    }
    body[data-skin="vivid"] .topbar::after{ display:none; }
  }

  /* ---------- حرکت کمتر ---------- */
  @media (prefers-reduced-motion:reduce){
    body[data-skin="vivid"] .stat{ animation:none; }
  }
