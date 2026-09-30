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

  /* این بخش از بقیهٔ صفحه درشت‌تر به چشم می‌آمد: کنترل‌هایش بلندتر
     بودند، کادرِ جواب ۱۶px بود و ایموجیِ تیتر هم‌قدِ خودِ تیتر. یک
     ابزارِ جانبی است، نه محتوای اصلی؛ پس جمع‌وجور شد. همهٔ اندازه‌ها
     این‌جا و زیرِ #convBox‌اند تا جای دیگری کوچک نشود. */
  #convBox .panel h3{
    font-size:13px; margin-bottom:10px; padding-bottom:8px; gap:6px;
  }
  /* ایموجی به اندازهٔ تیتر بزرگ می‌شد و از متن هم درشت‌تر می‌نشست. */
  #convBox .cv-ico{
    font-size:11.5px; line-height:1; opacity:.72;
  }

  .cv-row{
    display:flex; flex-wrap:wrap; gap:6px;
    align-items:center; margin-bottom:8px;
  }
  /* ردیفِ نرخ فقط برای واحدِ پولی لازم است و کد با صفتِ hidden
     پنهانش می‌کند. ولی display در CSS بر hidden می‌چربد، پس همیشه
     دیده می‌شد — حتی وقتی تبدیلِ وزن بود و نرخی در کار نبود. */
  .cv-row[hidden]{ display:none; }
  .cv-row > select,
  .cv-row > input{
    flex:1 1 140px; min-width:0; height:34px;
    border:1px solid var(--card-border); border-radius:9px;
    padding:0 9px;
    font-family:var(--font-body); font-size:12.5px;
    background:var(--white); color:var(--ink);
  }
  .cv-row > select:focus,
  .cv-row > input:focus{
    outline:none; border-color:var(--brass,#8A6E3B);
    box-shadow:0 0 0 3px var(--brass-bg,rgba(138,110,59,.12));
  }
  /* دکمهٔ ⇄ کنارِ کشوهاست و باید هم‌قدشان باشد، نه کوچک‌تر. */
  .cv-row > button{
    flex:0 0 36px; height:34px; padding:0;
    display:flex; align-items:center; justify-content:center;
    font-size:13px; line-height:1;
  }
  .cv-lb{
    flex:0 0 auto; font-size:12px; color:var(--ink-soft);
    white-space:nowrap;
  }

  .cv-out{
    font-family:var(--font-display); font-size:14px; color:var(--ink);
    padding:10px 12px; border-radius:9px; background:var(--paper);
    border:1px solid var(--card-border); line-height:1.8;
    overflow-wrap:anywhere; min-height:42px;
    display:flex; align-items:center;
  }
  .cv-note{
    font-size:11px; color:var(--red-ink,#A6222B);
    margin-top:6px; min-height:15px;
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
    /* مبدأ و مقصد کنارِ هم، با ⇄ و دو فاصله بینشان. این عدد به عرضِ
       دکمه و فاصله بند است و با کوچک شدنشان عوض شد: ۳۶ + ۲×۶ = ۴۸،
       نصفش ۲۴. کمتر از این، مقصد به خطِ بعد می‌افتد. */
    .cv-row > .cv-unit{ flex:1 1 calc(50% - 24px); }
    .cv-out{ font-size:13.5px; padding:9px 11px; }
  }
