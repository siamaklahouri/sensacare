  /* ==================== کجای ماهی ====================
     داشبورد شش عدد می‌گفت و یک چیز را نمی‌گفت: امروز بیست‌وسومِ آبان
     است، یعنی سه‌چهارمِ ماه رفته، و شش درصدِ کارها انجام شده. هر دو
     عدد روی صفحه بودند — «۲۳ آبان» در قابِ خوش‌آمد و «۶٪» در یک
     کاشی — ولی کسی کنارِ هم نمی‌گذاشتشان.

     برای یک پلنرِ ماهانه این مهم‌ترین جمله است: جلویی یا عقب.

     جای خالیِ وسطِ قابِ خوش‌آمد دقیقاً همان‌جاست که چشم اول می‌افتد،
     و تا امروز هیچ‌چیز تویش نبود. */

  .dh-pace{
    flex:1 1 260px; min-width:240px; max-width:460px;
    position:relative; z-index:1;
  }
  .dh-pace-top{
    display:flex; align-items:baseline; justify-content:space-between;
    gap:10px; margin-bottom:7px;
  }
  .dh-pace-num{
    font-family:var(--font-display); font-size:21px; font-weight:800;
    line-height:1; color:var(--pace-ink, var(--brass-ink));
  }
  .dh-pace-num small{ font-size:12px; font-weight:700; margin-inline-start:2px; }
  .dh-pace-say{ font-size:11.5px; font-weight:700; color:var(--pace-ink, var(--ink-soft)); }

  /* ریل، و دو چیز رویش: کاری که شده، و جایی که تقویم رسیده. */
  .dh-rail{
    position:relative; height:9px; border-radius:999px;
    background:var(--paper-deep, var(--paper)); overflow:visible;
  }
  .dh-rail-fill{
    position:absolute; inset-block:0; inset-inline-start:0;
    border-radius:999px; background:var(--pace, var(--brass));
    transition:width .5s ease;
  }
  /* نشانهٔ «امروز»: یک خطِ باریکِ عمودی روی ریل. اگر پُر از آن عقب‌تر
     باشد، فاصله همان «عقب‌افتادگی» است و از یک نگاه دیده می‌شود. */
  .dh-rail-now{
    position:absolute; inset-block:-4px; width:2px; border-radius:2px;
    background:var(--ink); opacity:.55; transform:translateX(50%);
  }
  .dh-rail-now::after{
    content:attr(data-day); position:absolute; inset-block-start:-15px;
    inset-inline-start:50%; transform:translateX(50%);
    font-size:9px; font-weight:700; color:var(--ink-soft); white-space:nowrap;
  }
  .dh-pace-foot{
    margin-top:7px; font-size:11px; color:var(--ink-faint);
    display:flex; justify-content:space-between; gap:10px;
  }
  /* سمتِ چپ می‌تواند بشکند (در کارتابلِ مالی عددِ میلیاردی می‌آید)،
     ولی «۷۷٪ از ماه» نباید وسطش دو تکه شود. */
  .dh-pace-foot > :last-child{ white-space:nowrap; }

  /* رنگ معنادار است، نه تزئینی: جلو بودن سبز، کمی عقب کهربایی، خیلی
     عقب قرمز. پس با تم عوض نمی‌شود. */
  .dh-pace.ok   { --pace:var(--green); --pace-ink:var(--green-ink); }
  .dh-pace.warn { --pace:var(--amber); --pace-ink:var(--amber-ink); }
  .dh-pace.late { --pace:var(--red);   --pace-ink:var(--red-ink); }
  .dh-pace.done { --pace:var(--green); --pace-ink:var(--green-ink); }

  @media (max-width:760px){
    .dh-pace{ flex:1 1 100%; max-width:none; order:3; margin-top:4px; }
  }
  /* روی کاغذ نوار می‌ماند — خبر است، نه تزئین — ولی رنگش باید چاپ شود */
  @media print{
    .dh-rail-fill, .dh-rail{ -webkit-print-color-adjust:exact; print-color-adjust:exact; }
  }
