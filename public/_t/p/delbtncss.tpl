/* دکمهٔ حذفِ ردیف — مشترکِ هر دو کارتابل */
  /* دکمهٔ حذف قبلاً همیشه قرمز بود و روی hover هم بزرگ می‌شد — در یک
     جدولِ چهل ردیفی، چهل لکهٔ قرمزِ جهنده. حالا تا دست رویش نرود خاکستریِ
     آرام است و فقط همان لحظه قرمز می‌شود. */
  /* بی‌قاب که بود، یک ✕ِ خاکستریِ معلق بود نه دکمه — کسی نمی‌دانست
     زدنی است. یک خطِ نازکِ خنثی کافی است؛ قرمز همچنان فقط روی hover. */
  .btn-del{
    display:inline-flex; align-items:center; justify-content:center;
    width:26px; height:26px; padding:0; box-sizing:border-box;
    background:transparent; border:1px solid var(--line); border-radius:7px;
    color:var(--ink-soft); font-size:12px; line-height:1; cursor:pointer;
    transition:background .14s, color .14s, border-color .14s;
  }
  .btn-del:hover{ background:var(--red-bg); color:var(--red-ink); border-color:var(--red); }
  .btn-del:active{ transform:scale(.94); }
  .btn-del:focus-visible{ outline:2px solid var(--red); outline-offset:1px; }
  /* قفل‌شده یعنی «الان نمی‌شود»، نه «وجود ندارد». پیش‌تر display:none
     بود و ستونِ حذف کاملاً خالی می‌ماند — صفحه را که باز می‌کردی هیچ
     دکمه‌ای نبود و خیال می‌کردی حذف خراب است. حالا 🔒ِ کم‌رنگ با قابِ
     خط‌چین سرِ جایش می‌ماند و می‌گوید فقط قفل است. */
  .btn-del[disabled]{
    cursor:not-allowed; font-size:0;
    background:transparent; border-style:dashed; border-color:var(--line);
    color:var(--ink-faint);
  }
  .btn-del[disabled]::before{ content:"🔒"; font-size:10.5px; line-height:1; }
  .btn-del[disabled]:hover{ background:transparent; color:var(--ink-faint); border-color:var(--line); }
  .btn-del[disabled]:active{ transform:none; }
  /* و کلیدِ همان ستون از دور بگوید باز است یا بسته */
  .edit-toggle-wrap::before, .del-toggle-wrap::before{ content:"🔒"; font-size:10px; line-height:1; }
  .edit-toggle-wrap.open::before, .del-toggle-wrap.open::before{ content:"🔓"; }
