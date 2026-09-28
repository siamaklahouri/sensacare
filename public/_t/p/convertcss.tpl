  /* ==================== تبدیل ====================
     پیش از این هر کنترل اندازهٔ دلخواهِ خودش را می‌گرفت: کادرِ عدد
     `flex:1 1 120px` بود و تا آخرِ ردیف کش می‌آمد، در حالی که کشوها
     `flex:0 1 auto` بودند و به اندازهٔ متنشان جمع می‌شدند. نتیجه یک
     ردیفِ ناهمگون بود — یکی خیلی بزرگ، یکی خیلی کوچک.

     حالا همه یک پایه و یک ضریبِ رشد دارند، پس فضای ردیف بینشان
     برابر پخش می‌شود و هم‌قد هم می‌مانند. فقط دکمهٔ جابه‌جایی
     عرضِ ثابت دارد، چون یک نشانه است نه یک کادرِ ورودی.

     این پاره در هر دو قالب (it و fin) درج می‌شود؛ پیش‌تر دو نسخهٔ
     جدا بود و هر اصلاحی باید دو بار انجام می‌شد. */

  .cv-row{
    display:flex; flex-wrap:wrap; gap:8px;
    align-items:center; margin-bottom:10px;
  }
  /* ردیفِ نرخ فقط برای واحدِ پولی لازم است و کد با صفتِ hidden
     پنهانش می‌کند. ولی display در CSS بر hidden می‌چربد، پس همیشه
     دیده می‌شد — حتی وقتی تبدیلِ وزن بود و نرخی در کار نبود. */
  .cv-row[hidden]{ display:none; }
  .cv-row > select,
  .cv-row > input{
    flex:1 1 150px; min-width:0; height:40px;
    border:1px solid var(--card-border); border-radius:10px;
    padding:0 11px;
    font-family:var(--font-body); font-size:13px;
    background:var(--white); color:var(--ink);
  }
  .cv-row > select:focus,
  .cv-row > input:focus{
    outline:none; border-color:var(--brass,#8A6E3B);
    box-shadow:0 0 0 3px var(--brass-bg,rgba(138,110,59,.12));
  }
  /* دکمهٔ ⇄ کنارِ کشوهاست و باید هم‌قدشان باشد، نه کوچک‌تر. */
  .cv-row > button{
    flex:0 0 44px; height:40px; padding:0;
    display:flex; align-items:center; justify-content:center;
    font-size:15px; line-height:1;
  }
  .cv-lb{
    flex:0 0 auto; font-size:12.5px; color:var(--ink-soft);
    white-space:nowrap;
  }

  .cv-out{
    font-family:var(--font-display); font-size:16px; color:var(--ink);
    padding:13px 15px; border-radius:11px; background:var(--paper);
    border:1px solid var(--card-border); line-height:1.9;
    overflow-wrap:anywhere; min-height:52px;
    display:flex; align-items:center;
  }
  .cv-note{
    font-size:11.5px; color:var(--red-ink,#A6222B);
    margin-top:7px; min-height:16px;
  }

  /* روی موبایل ردیفِ پنج‌تایی در یک خط جا نمی‌شود.
     دستهٔ تبدیل و کادرِ عدد هرکدام یک خطِ کامل می‌گیرند — بیشترین
     خواندن و تایپ آن‌جاست. واحدِ مبدأ و مقصد کنارِ هم می‌مانند با ⇄
     وسطشان، چون جفت‌اند و جدا افتادنشان رابطه‌شان را گم می‌کند. */
  @media (max-width:620px){
    /* پیش‌فرض: کشوها دوتایی — ردیفِ «سال و ماه» همین را می‌خواهد. */
    .cv-row > select{ flex:1 1 calc(50% - 4px); }
    .cv-row > input{ flex:1 1 100%; }
    /* دستهٔ تبدیل تنهاست و نامش بلند می‌شود. */
    .cv-row > #cvCat{ flex:1 1 100%; }
    /* مبدأ و مقصد کنارِ هم، با ⇄ (۴۴px) و دو فاصلهٔ ۸px بینشان:
       ۵۰٪ منهای نصفِ ۶۰ = ۳۰. کمتر از این، مقصد به خطِ بعد می‌افتد. */
    .cv-row > .cv-unit{ flex:1 1 calc(50% - 30px); }
    .cv-out{ font-size:14.5px; padding:11px 13px; }
  }
