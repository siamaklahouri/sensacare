  /* این خانه یک <input> بود با width:100% داخلِ یک قابِ ۵۸ پیکسلی: متن
     ۳۰ پیکسل می‌خواست و ۲۲ پیکسل جا داشت، پس «۲۰ ام» می‌شد «٬۰». بدتر
     اینکه «خانه‌های بلند» همان بیرون‌زدگی را می‌دید و یک پیکانِ ⌄ هم
     گوشه‌اش می‌گذاشت که به‌جای تقویم، پنجرهٔ متن باز می‌کرد.
     حالا خودِ خانه یک دکمه است: به‌اندازهٔ متنش، بی‌شکستن، بی‌پیکان. */
  .date-box{
    display:inline-flex; align-items:center; justify-content:center; gap:5px;
    width:100%; box-sizing:border-box; min-width:0;
    border:1px solid var(--card-border); border-radius:7px;
    padding:5px 6px; cursor:pointer; background:var(--white);
    font-family:var(--font-body); font-size:12.6px; color:var(--ink);
    white-space:nowrap; transition:border-color .15s, background .15s, color .15s;
  }
  .date-box:hover{ border-color:var(--brass); background:var(--brass-bg); color:var(--brass-ink); }
  .date-box:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }
  .date-box .cal-ic{ font-size:11.5px; flex:0 0 auto; line-height:1; }
  .date-box .dv{ font-weight:700; }
  /* بی‌مهلت: خط‌چین و کم‌رنگ، تا از یک روزِ ثبت‌شده فرق کند */
  .date-box.empty{ color:var(--ink-faint); border-style:dashed; }
  .date-box.empty .dv{ font-weight:600; font-size:11.5px; }
  .day-picker-popup{
    position:fixed; z-index:200; background:var(--white); border:1px solid var(--card-border); border-radius:10px;
    box-shadow:0 10px 30px rgba(11,37,69,.25); padding:10px; display:none;
  }
  .day-picker-popup.open{ display:block; }
  .day-picker-popup .dp2-ttl{
    text-align:center; font-weight:800; font-size:12.5px; color:var(--ink);
    margin:0 0 7px; font-family:var(--font-display);
  }
  .day-picker-popup .dp2-wd{ display:grid; grid-template-columns:repeat(7,28px); gap:4px; margin-bottom:4px; }
  .day-picker-popup .dp2-wd span{
    text-align:center; font-size:10.5px; font-weight:700; color:var(--ink-faint); line-height:16px;
  }
  .day-picker-popup .dp2-wd span:last-child{ color:var(--red-ink); }
  .day-picker-popup .dp-grid{ display:grid; grid-template-columns:repeat(7,28px); gap:4px; }
  .day-picker-popup .dp2-pad{ display:block; }
  /* جمعه و تعطیلِ رسمی: همان رنگی که در بخشِ تقویم هم دارند */
  .day-picker-popup button.off{ background:var(--red-bg); color:var(--red-ink); font-weight:700; }
  .day-picker-popup button.now{ box-shadow:inset 0 0 0 2px var(--brass); }
  .day-picker-popup button{
    width:28px; height:28px; border:none; border-radius:6px; background:var(--paper); color:var(--ink);
    font-family:var(--font-body); font-size:11.5px; cursor:pointer;
  }
  .day-picker-popup button:hover{ background:var(--brass); color:#fff; }
  .day-picker-popup button.selected{ background:var(--deep); color:#fff; }
  .day-picker-popup .dp-clear{
    width:100%; margin-top:8px; height:26px; border-radius:6px; background:transparent; color:var(--red-ink);
    border:1px solid var(--card-border); font-size:11px;
  }
