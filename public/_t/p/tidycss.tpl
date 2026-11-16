  /* ==================== امروز، و جدولِ خالی ====================
     دو چیزِ کوچک که هر روز دیده می‌شوند.

     یک) «برنامهٔ روزانه» تا سی‌ویک ردیف دارد و هیچ‌کدام نمی‌گفت
     کدامشان امروز است. تقویم این را از قبل داشت (قابِ دورِ خانهٔ
     امروز) و جدول نداشت؛ آدم باید چشم می‌چرخاند.

     دو) جدولی که خالی است، تا امروز فقط یک سربرگ بود و یک صفحهٔ
     سفید. اولین چیزی که کاربرِ تازه می‌بیند همین است.

     و یک نکته که آزمونِ دسترس‌پذیری یادآوری کرد: متنِ راهنما
     (placeholder) برچسبِ خانه نیست. تا دیروز همان نقشِ برچسب را هم
     بازی می‌کرد، پس با برداشتنش از ردیف‌های دیگر، آن خانه‌ها برای
     صفحه‌خوان بی‌نام شدند. حالا هر خانه aria-label خودش را دارد و
     placeholder فقط راهنمای چشمی است — که از اولش هم باید همین
     می‌بود. */

  /* ردیفِ امروز: یک نوارِ باریک کنارش و زمینهٔ کم‌رنگ. رنگ از همان
     --brass می‌آید که همه‌جای کارتابل «اکنون» را با آن نشان
     می‌دهیم. */
  tbody tr.is-today > td{
    background:color-mix(in srgb, var(--brass) 7%, transparent);
  }
  @supports not (color: color-mix(in srgb, red 50%, transparent)){
    tbody tr.is-today > td{ background:var(--brass-bg); }
  }
  tbody tr.is-today > td:first-child{
    box-shadow:inset 3px 0 0 var(--brass);
  }
  html[dir="rtl"] tbody tr.is-today > td:first-child{
    box-shadow:inset -3px 0 0 var(--brass);
  }
  .today-tag{
    display:inline-block; margin-inline-start:6px; padding:1px 7px;
    border-radius:999px; background:var(--brass); color:#fff;
    font-size:9.5px; font-weight:800; vertical-align:middle;
  }

  /* جدولِ خالی: یک جمله و یک راهِ شروع، نه یک صفحهٔ سفید. */
  .tbl-empty td{ padding:30px 18px !important; text-align:center; }
  .tbl-empty .te-ic{ font-size:26px; display:block; margin-bottom:8px; opacity:.75; }
  .tbl-empty .te-h{
    font-family:var(--font-display); font-size:14px; font-weight:800;
    color:var(--ink); margin-bottom:5px;
  }
  .tbl-empty .te-p{ font-size:12px; color:var(--ink-soft); line-height:2; }
  .tbl-empty .te-p b{ color:var(--ink); }

  /* چشمکِ کوتاه پس از «برو به امروز» — تا چشم بداند کجا ایستاد.
     با prefers-reduced-motion خاموش می‌شود. */
  @keyframes rowFlash{
    0%{ box-shadow:inset 0 0 0 2px var(--brass); }
    100%{ box-shadow:inset 0 0 0 2px transparent; }
  }
  tbody tr.row-flash > td{ animation:rowFlash 1.4s ease-out 1; }
  @media (prefers-reduced-motion: reduce){
    tbody tr.row-flash > td{ animation:none; }
  }
