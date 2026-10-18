  /* ---------- زنگوله‌ی خبرها ---------- */
  /* همان زبانِ بصریِ پنلِ ادمین، با نشانه‌های خودِ کارتابل. */
  .bellw{ position:relative; flex:none; }
  .bellb{
    border:1px solid var(--card-border); background:var(--white); color:var(--ink);
    width:34px; height:34px; border-radius:10px; cursor:pointer; font-size:15px;
    display:inline-flex; align-items:center; justify-content:center; position:relative;
    transition:border-color .15s, transform .12s;
  }
  .bellb:hover{ border-color:var(--brass); transform:translateY(-1px); }
  .bellb .nd{
    position:absolute; top:-5px; inset-inline-end:-5px; min-width:18px; height:18px;
    padding:0 4px; border-radius:9px; background:var(--red,#A6222B); color:#fff;
    font-size:10.5px; font-weight:700; display:inline-flex; align-items:center;
    justify-content:center; box-shadow:0 0 0 2px var(--white);
  }
  .bellp{
    position:absolute; top:calc(100% + 9px); inset-inline-end:0; width:min(320px, calc(100vw - 28px));
    background:var(--white); border:1px solid var(--card-border); border-radius:14px;
    box-shadow:var(--shadow-lg, 0 18px 50px rgba(0,0,0,.18)); z-index:70; overflow:hidden;
  }
  .bellp[hidden]{ display:none; }
  .bellh{
    display:flex; align-items:center; justify-content:space-between; gap:8px;
    padding:8px 11px; border-bottom:1px solid var(--line); font-size:12px; font-weight:700;
  }
  .bellh button{ border:0; background:none; cursor:pointer; color:var(--ink-faint); font-size:13px; }
  .bellh button:hover{ color:var(--ink); }
  .bell-l{ max-height:min(52vh, 320px); overflow-y:auto; }
  /* کادرِ هر خبر کوچک است و دو خط بیشتر نمی‌شود: فهرستی که هر خبرش
     چهار خط بود، با سه خبر تمامِ صفحه را می‌گرفت. */
  .bell-i{
    display:flex; align-items:center; gap:8px; padding:7px 10px;
    border-bottom:1px solid var(--line-soft, var(--line));
    border-inline-start:3px solid transparent;
  }
  .bell-i:last-child{ border-bottom:0; }
  .bell-i .ic{ font-size:14px; line-height:1.4; flex:none; }
  .bell-i .tx{ min-width:0; flex:1; }
  .bell-i b{ font-size:12px; display:block; line-height:1.5;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .bell-i p{
    margin:1px 0 0; font-size:11px; line-height:1.6; color:var(--ink-soft);
    overflow-wrap:anywhere;
    /* بیشتر از دو خط نه: بقیه‌اش با سه‌نقطه */
    display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;
  }
  .bell-i .ar{ flex:none; font-size:15px; color:var(--ink-faint); line-height:1; }
  .bell-i.k-bad{ border-inline-start-color:var(--red,#A6222B); }
  .bell-i.k-warn{ border-inline-start-color:var(--amber,#B4801F); }
  .bell-i.k-ok{ border-inline-start-color:var(--green,#2C7A4B); }
  .bell-i.k-info{ border-inline-start-color:var(--line); }
  /* خبرِ دیده‌شده پاک نمی‌شود، کم‌رنگ می‌شود: شاید فردا بخواهی دوباره بخوانی‌اش. */
  .bell-i.seen{ opacity:.52; }
  .bell-e{ padding:18px 14px; text-align:center; font-size:11.5px; color:var(--ink-faint); }
  .bell-f{ padding:7px 9px; border-top:1px solid var(--line); display:flex; justify-content:flex-start; }
  .bell-f button{
    border:1px solid var(--card-border); background:var(--paper); color:var(--ink);
    border-radius:9px; padding:5px 11px; font-family:inherit; font-size:11px; cursor:pointer;
  }
  .bell-f button:hover{ border-color:var(--brass); }
  .bell-f button[disabled]{ opacity:.5; cursor:default; }
  @media (max-width:760px){
    .bellp{ position:fixed; top:64px; inset-inline:12px; width:auto; }
  }

  /* هر خبر زدنی است (دستِ‌کم «خواندم»)، و آن‌که جایی برای رفتن
     دارد یک پیکانِ کوچک هم می‌گیرد — به‌جای یک خطِ نوشتهٔ اضافه. */
  .bell-i{ cursor:pointer; }
  .bell-i:hover{ background:var(--paper-deep,rgba(0,0,0,.04)); }
  .bell-i:focus-visible{ outline:2px solid var(--brass); outline-offset:-2px; }
  .bell-i.go .ar{ color:var(--brass); }
