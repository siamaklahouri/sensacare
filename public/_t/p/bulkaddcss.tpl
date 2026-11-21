
  /* ---------- «یک کار، چند روز» ----------
     زیرِ نوارِ ابزارِ چک‌لیست باز می‌شود، نه در یک پنجرهٔ شناور: کاربر
     هم‌زمان جدول را می‌بیند و می‌فهمد این ردیف‌ها کجا می‌نشینند. */
  .ba-box{
    border:1.5px solid var(--card-border); border-radius:14px;
    background:var(--white); padding:14px; margin-bottom:16px;
  }
  .ba-box[hidden]{ display:none !important; }
  .ba-row{ display:flex; gap:9px; margin-bottom:12px; flex-wrap:wrap; }
  .ba-task{
    flex:1 1 260px; min-width:0; font-family:inherit; font-size:13px;
    padding:8px 11px; border:1.5px solid var(--card-border); border-radius:10px;
    background:var(--paper); color:var(--ink);
  }
  .ba-cat{
    flex:0 0 auto; font-family:inherit; font-size:12.5px; padding:8px 10px;
    border:1.5px solid var(--card-border); border-radius:10px;
    background:var(--paper); color:var(--ink);
  }
  .ba-task:focus-visible, .ba-cat:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }

  .ba-cal{ max-width:360px; }
  .ba-m{ font-size:12.5px; font-weight:700; margin-bottom:8px; color:var(--ink-soft); }
  .ba-wd, .ba-grid{ display:grid; grid-template-columns:repeat(7, 1fr); gap:5px; }
  .ba-wd{ margin-bottom:5px; }
  .ba-w{
    font-family:inherit; font-size:11.5px; font-weight:700; padding:5px 0;
    border:1.5px solid transparent; border-radius:8px; cursor:pointer;
    background:var(--paper); color:var(--ink-faint);
  }
  .ba-w:hover{ color:var(--brass-ink); border-color:var(--brass); }
  /* روزِ هفته‌ای که کاملاً تیک است، خودش هم پر می‌شود — همان یک نگاه
     می‌گوید «همهٔ چهارشنبه‌ها». */
  .ba-w.on{ background:var(--brass); border-color:var(--brass); color:#fff; }
  .ba-gap{ display:block; }
  .ba-d{
    font-family:inherit; font-size:12px; padding:6px 0; cursor:pointer;
    border:1.5px solid var(--card-border); border-radius:8px;
    background:var(--white); color:var(--ink); transition:background .12s, border-color .12s, color .12s;
  }
  .ba-d:hover{ border-color:var(--brass); }
  .ba-d.on{ background:var(--brass-bg); border-color:var(--brass); color:var(--brass-ink); font-weight:700; }
  .ba-w:focus-visible, .ba-d:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }

  .ba-foot{
    display:flex; align-items:center; justify-content:space-between;
    gap:12px; margin-top:13px; flex-wrap:wrap;
  }
  .ba-sum{ font-size:12px; color:var(--ink-soft); }
  .ba-btns{ display:flex; gap:8px; }
  .ba-go[disabled]{ opacity:.45; cursor:not-allowed; }

  @media print{ .ba-box{ display:none !important; } }

  /* ---------- فلشِ ماه و خانه‌های تازه ---------- */
  .ba-owner, .ba-note{
    flex:1 1 180px; min-width:0; font-family:inherit; font-size:12.5px;
    padding:8px 11px; border:1.5px solid var(--card-border); border-radius:10px;
    background:var(--paper); color:var(--ink);
  }
  .ba-stat, .ba-pri, .ba-rep{
    flex:0 0 auto; font-family:inherit; font-size:12.5px; padding:8px 10px;
    border:1.5px solid var(--card-border); border-radius:10px;
    background:var(--paper); color:var(--ink);
  }
  .ba-owner:focus-visible, .ba-note:focus-visible,
  .ba-stat:focus-visible, .ba-pri:focus-visible, .ba-rep:focus-visible{
    outline:2px solid var(--brass); outline-offset:1px;
  }

  .ba-m{ display:flex; align-items:center; justify-content:space-between; gap:8px; }
  .ba-mn{ flex:1 1 auto; text-align:center; }
  .ba-nav{
    flex:0 0 auto; width:26px; height:26px; padding:0; cursor:pointer;
    font-family:inherit; font-size:14px; line-height:1;
    border:1.5px solid var(--card-border); border-radius:8px;
    background:var(--paper); color:var(--ink-soft);
  }
  .ba-nav:hover{ border-color:var(--brass); color:var(--brass-ink); }
  .ba-nav:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }

  /* وقتی تقویم روی ماهی جز ماهِ باز است — پیش از افزودن می‌گوید چه می‌شود */
  .ba-other{
    margin-top:9px; font-size:11.5px; line-height:1.8;
    color:var(--brass-ink, var(--brass));
    background:var(--brass-bg); border-radius:9px; padding:7px 10px;
  }
  .ba-other[hidden]{ display:none !important; }
