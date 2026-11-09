  /* ---------- چیپ‌های «وضعیت» و «اولویت» ----------
     هر دو کارتابل همین دو ستون را دارند و شیوه‌نامهٔ «وضعیت» در هر دو
     مو‌به‌مو یکی نوشته شده بود. دیروز سرِ فایلِ پشتیبان همین تکرار یک
     باگ را دو جا کرد؛ پس پیش از اینکه «اولویت» هم دو نسخه شود، هر دو
     این‌جا نشستند.

     تفاوتِ عمدیِ دو ستون:
       وضعیت  — چیپِ پُر. حالِ کار است و باید از دور داد بزند.
       اولویت — چیپِ خط‌دار. صفتِ کار است و فقط باید تفکیک شود.
     اگر هر دو پُر می‌شدند، «انجام نشده»ی قرمز کنارِ «بالا»ی قرمز
     می‌نشست و چشم نمی‌فهمید کدام حالت است و کدام دسته‌بندی. */
  select.st-select, select.pr-select{
    font-weight:700; border-radius:999px; text-align:center;
    font-size:12.2px; padding:6px 2px; border:1px solid var(--line);
    transition:background .15s, color .15s, border-color .15s; }
  select.st-select:hover, select.pr-select:hover{ border-color:var(--brass); }

  select.st-select{ background:var(--paper); }
  select.st-select[data-st="انجام شد"]{
    background:var(--green-bg); color:var(--green-ink); border-color:transparent; }
  select.st-select[data-st="در حال انجام"]{
    background:var(--amber-bg); color:var(--amber-ink); border-color:transparent; }
  select.st-select[data-st="انجام نشده"]{
    background:var(--red-bg); color:var(--red-ink); border-color:transparent; }

  /* قابِ اولویت همیشه خنثی می‌مانَد و فقط متنش رنگ می‌گیرد.
     بارِ اول قاب را هم رنگی کردم و در عکس معلوم شد بد است: کنارِ
     «انجام نشده»ی قرمز، یک «بالا»ی قرمزِ قاب‌دار می‌نشست و ردیف دو
     آژیر داشت؛ و در ردیفِ «انجام شد»، همان قابِ قرمز معنایش گم بود.
     رنگ محورِ وضعیت است؛ اولویت فقط باید خوانده شود، نه داد بزند. */
  select.pr-select{
    background:transparent; color:var(--ink-soft); border-color:var(--line); }
  select.pr-select[data-pr="بالا"]{ color:var(--red-ink); font-weight:800; }
  select.pr-select[data-pr="متوسط"]{ color:var(--amber-ink); }
  select.pr-select[data-pr="پایین"]{ color:var(--ink-faint); }
