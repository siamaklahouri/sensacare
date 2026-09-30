
  /* ==================== لایهٔ رنگ ====================
     کارتابل درست بود ولی سفید: یک ستونِ خاکستری، یک زمینهٔ تخت، و
     دوازده آیکنِ هم‌رنگ که چشم بینشان دنبالِ چیزی نمی‌گشت. این پاره
     فقط رنگ اضافه می‌کند — هیچ اندازه و چیدمانی را دست نمی‌زند، و هرچه
     می‌گذارد از توکن‌های خودِ شیوه‌نامه می‌آید، پس تمِ شب خودش درمی‌آید.

     بعد از navcss می‌آید تا حرفش روی قاعده‌های پیش از خودش بنشیند. */

  /* ---------- ۱) هالهٔ زمینه ----------
     دو هاله بود با شفافیتِ ۰٫۰۵ — عملاً دیده نمی‌شد. سه تا شد، کمی
     جان‌دارتر، و تمِ شب هم برای اولین بار هالهٔ خودش را گرفت (پیش از
     این فقط یک خاکستریِ تخت بود). */
  body{
    background:
      radial-gradient(1100px 520px at 100% -8%, color-mix(in srgb, var(--teal) 13%, transparent), transparent 62%),
      radial-gradient(900px 460px at -8% 2%, color-mix(in srgb, var(--purple) 11%, transparent), transparent 58%),
      radial-gradient(780px 420px at 45% 108%, color-mix(in srgb, var(--brass) 9%, transparent), transparent 60%),
      var(--paper);
    background-attachment:fixed;
  }
  [data-theme="dark"] body{
    background:
      radial-gradient(1100px 520px at 100% -8%, color-mix(in srgb, var(--teal) 20%, transparent), transparent 62%),
      radial-gradient(900px 460px at -8% 2%, color-mix(in srgb, var(--purple) 17%, transparent), transparent 58%),
      radial-gradient(780px 420px at 45% 108%, color-mix(in srgb, var(--brass) 14%, transparent), transparent 60%),
      var(--paper);
    background-attachment:fixed;
  }

  /* ---------- ۲) آیکن‌های فهرستِ کنار ----------
     شش رنگ که می‌چرخند. یکی‌درمیان نیست، شش‌تا‌درمیان: دو همسایه هیچ‌وقت
     یک رنگ نمی‌شوند و چشم می‌تواند «سومی از بالا، سبز» را به خاطر
     بسپارد. آیکنِ پنهان‌شده هم نوبتش را نگه می‌دارد، پس با باز و بسته
     شدنِ بخش‌ها رنگ‌ها جابه‌جا نمی‌شوند. */
  .nav-list .navbtn:nth-of-type(6n+1){ --nv:var(--brass);  --nv-bg:var(--brass-bg); }
  .nav-list .navbtn:nth-of-type(6n+2){ --nv:var(--green);  --nv-bg:var(--green-bg); }
  .nav-list .navbtn:nth-of-type(6n+3){ --nv:var(--amber);  --nv-bg:var(--amber-bg); }
  .nav-list .navbtn:nth-of-type(6n+4){ --nv:var(--teal);   --nv-bg:var(--teal-bg); }
  .nav-list .navbtn:nth-of-type(6n+5){ --nv:var(--purple); --nv-bg:var(--purple-bg); }
  .nav-list .navbtn:nth-of-type(6n+6){ --nv:var(--red);    --nv-bg:var(--red-bg); }
  /* بخشِ قفل‌دار رنگِ خودش را دارد، هرجای فهرست که بیفتد */
  .nav-list .navbtn-lock{ --nv:var(--purple); --nv-bg:var(--purple-bg); }

  /* تینت از خودِ رنگ ساخته می‌شود، نه از توکنِ آمادهٔ --nv-bg: آن‌ها
     برای زمینهٔ کاغذی کوک شده‌اند و در شب زیادی تیره می‌افتادند. این‌طور
     هر دو تم از یک قاعده درمی‌آیند. */
  .nav-list .navbtn .ic{
    opacity:1; border-radius:9px;
    background:color-mix(in srgb, var(--nv) 15%, var(--white));
    box-shadow:inset 0 0 0 1px color-mix(in srgb, var(--nv) 32%, transparent);
    transition:box-shadow .15s, background .15s;
  }
  /* بزرگ‌شدنِ چیپ هم همان لرزش را می‌داد — و حالا که چیپ رنگ دارد،
     ۷ درصد بزرگ‌تر شدنش خیلی بیشتر از قبل به چشم می‌آید. فقط تینت
     پررنگ‌تر و حلقه ضخیم‌تر می‌شود؛ هیچ‌چیز تکان نمی‌خورد. */
  .nav-list .navbtn:hover .ic{
    background:color-mix(in srgb, var(--nv) 26%, var(--white));
    box-shadow:inset 0 0 0 1.5px color-mix(in srgb, var(--nv) 55%, transparent); }

  /* ---------- ۳) بخشِ باز ----------
     قرصِ تختِ کم‌رنگ بود؛ حالا از رنگِ خودِ همان بخش محو می‌شود، و
     خطِ کنارش هم گرادیان دارد نه یک رنگِ تخت. */
  .nav-list .navbtn.active{
    background:linear-gradient(90deg,
      color-mix(in srgb, var(--nv) 22%, transparent),
      color-mix(in srgb, var(--nv) 7%, transparent) 72%, transparent);
    color:var(--ink);
  }
  /* پُرِ تخت نه: شکلک روی رنگِ سیر گم می‌شد. تینتِ پررنگ‌تر با حلقهٔ
     ضخیم‌تر همان «این باز است» را می‌گوید و شکلک خوانا می‌ماند. */
  .nav-list .navbtn.active .ic{
    background:color-mix(in srgb, var(--nv) 28%, var(--white));
    box-shadow:inset 0 0 0 1.5px color-mix(in srgb, var(--nv) 62%, transparent);
  }
  .nav-list .navbtn.active::before{
    background:linear-gradient(180deg, var(--nv), color-mix(in srgb, var(--nv) 55%, transparent));
    width:3.5px; height:22px;
  }

  /* ---------- ۴) سربرگِ هر نما ----------
     خطِ کنارِ عنوان همه‌جا یک آبی بود. حالا هر نما رنگِ خودش را دارد،
     همان رنگی که در فهرستِ کنار هم دیده — پس جابه‌جایی بینشان یک
     پیوستگیِ رنگی دارد. */
  .content > .view:nth-of-type(6n+1){ --vw:var(--brass); }
  .content > .view:nth-of-type(6n+2){ --vw:var(--green); }
  .content > .view:nth-of-type(6n+3){ --vw:var(--amber); }
  .content > .view:nth-of-type(6n+4){ --vw:var(--teal); }
  .content > .view:nth-of-type(6n+5){ --vw:var(--purple); }
  .content > .view:nth-of-type(6n+6){ --vw:var(--red); }
  .section-title::before{
    background:linear-gradient(180deg, var(--vw, var(--brass)),
               color-mix(in srgb, var(--vw, var(--brass)) 45%, transparent));
    box-shadow:0 2px 10px color-mix(in srgb, var(--vw, var(--brass)) 40%, transparent);
  }

  /* ---------- ۵) قاب‌ها ----------
     یک نوارِ سه‌پیکسلیِ رنگی بالای هر قاب، چرخشی. همان کاری که کارت‌های
     آماری می‌کنند — حالا نمودارها و جدول‌ها هم همان زبان را دارند. */
  .panel{ position:relative; overflow:hidden; }
  .panel::after{
    content:""; position:absolute; inset:0 0 auto 0; height:3px;
    background:linear-gradient(90deg, var(--pn, var(--brass)),
               color-mix(in srgb, var(--pn, var(--brass)) 35%, transparent));
  }
  .panel:nth-of-type(6n+1){ --pn:var(--teal); }
  .panel:nth-of-type(6n+2){ --pn:var(--brass); }
  .panel:nth-of-type(6n+3){ --pn:var(--purple); }
  .panel:nth-of-type(6n+4){ --pn:var(--green); }
  .panel:nth-of-type(6n+5){ --pn:var(--amber); }
  .panel:nth-of-type(6n+6){ --pn:var(--red); }
  .panel h3{ border-bottom-color:color-mix(in srgb, var(--pn, var(--brass)) 22%, transparent); }

  /* ---------- ۶) کارتِ خوش‌آمد و نوارِ بالا ----------
     هر دو کاغذِ سفیدِ تخت بودند. یک شستِ رنگِ بسیار ملایم کافی است تا
     از جدولِ زیرشان جدا شوند. */
  .dash-hero{
    background:
      linear-gradient(115deg, color-mix(in srgb, var(--brass) 8%, transparent),
                      color-mix(in srgb, var(--teal) 6%, transparent) 55%, transparent 80%),
      var(--white);
  }
  .topbar{
    background:
      linear-gradient(90deg, color-mix(in srgb, var(--brass) 6%, transparent),
                      transparent 40%, color-mix(in srgb, var(--purple) 5%, transparent)),
      var(--white);
  }
  .sidebar{
    background:
      linear-gradient(180deg, color-mix(in srgb, var(--brass) 5%, transparent), transparent 45%),
      linear-gradient(180deg, rgba(255,255,255,.55), rgba(255,255,255,.15));
  }
  [data-theme="dark"] .sidebar{
    background:
      linear-gradient(180deg, color-mix(in srgb, var(--brass) 10%, transparent), transparent 45%),
      linear-gradient(180deg, rgba(255,255,255,.05), rgba(255,255,255,.01));
  }

  /* در موبایل فهرست یک ردیفِ افقی از دکمه‌ها می‌شود؛ چیپِ رنگی آن‌جا
     هم می‌ماند ولی قرصِ گرادیانیِ «باز» جا ندارد. */
  @media (max-width:860px){
    .nav-list .navbtn.active{ background:var(--nv-bg); }
  }
