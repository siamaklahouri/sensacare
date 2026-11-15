  /* ---------- کاری که از مهلتش گذشته ----------
     نشانه روی خودِ چیپِ مهلت می‌نشیند، نه روی کلِ ردیف: ردیفِ قرمز
     در جدولی که نیمی از کارهایش هنوز انجام نشده، صفحه را قرمز
     می‌کند و دیگر چیزی را برجسته نمی‌کند. */
  .date-box.od{
    background:var(--red-bg); border-color:var(--red);
    color:var(--red-ink, var(--red));
  }
  .date-box.od .dv{ font-weight:800; }
  .date-box.od::after{
    content:"!"; font-weight:900; font-size:11px;
    margin-inline-start:5px; color:var(--red);
  }
  /* در جدولِ «مهلت‌های نزدیک» جا برای متن هست، پس همان‌جا با حرف
     گفته می‌شود — عددِ تنها معنایش روشن نیست. */
  .od-cell{ color:var(--red); font-weight:800; white-space:nowrap; }
  .od-cell small{ font-weight:700; font-size:10.5px; margin-inline-start:4px; opacity:.9; }

  /* نوارِ بالای داشبورد: یک خطِ کوتاه، نه یک هشدارِ تمام‌صفحه. */
  .od-bar{
    display:flex; flex-direction:column; gap:8px; margin-bottom:14px;
    background:var(--red-bg); border:1px solid var(--red);
    border-radius:12px; padding:10px 14px; font-size:12.5px; color:var(--ink);
  }
  .od-line{ display:flex; align-items:center; gap:9px; }
  .od-line + .od-line{ border-top:1px dashed var(--red); padding-top:8px; }
  .od-bar[hidden]{ display:none !important; }
  .od-bar b{ color:var(--red); font-weight:800; }
  .od-bar .od-go{
    margin-inline-start:auto; background:none; border:1px solid var(--red);
    color:var(--red); border-radius:9px; padding:5px 12px; font-family:inherit;
    font-size:11.5px; font-weight:700; cursor:pointer;
  }
  .od-bar .od-go:hover{ background:var(--red); color:#fff; }
  @media print{ .od-bar{ -webkit-print-color-adjust:exact; print-color-adjust:exact; } }
