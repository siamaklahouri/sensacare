  /* ---------- خانه‌های بلند و پنجرهٔ متنِ کامل ----------
     هر خانه یک خط می‌ماند. متنی که بیشتر است بریده می‌شود و پیکانِ
     گوشه‌اش پنجره را باز می‌کند. */
  td.cp-long > textarea,
  td.cp-long > input[type="text"],
  td.cp-long > .ro{ padding-inline-end:24px; }
  .cp-more{
    position:absolute; inset-block-start:50%; inset-inline-end:3px;
    transform:translateY(-50%);
    width:19px; height:19px; padding:0; line-height:1;
    display:flex; align-items:center; justify-content:center;
    font-family:var(--font-body); font-size:12px;
    border:1px solid var(--card-border); border-radius:6px;
    background:var(--white); color:var(--ink-faint);
    cursor:pointer; z-index:2;
    transition:border-color .12s, color .12s, background .12s;
  }
  /* همان پیکانِ SVG؛ نویسهٔ ⌄ روی ویندوز نبود و مربعِ خالی می‌افتاد */
  .cp-more::before{
    content:""; width:11px; height:11px;
    background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23888' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E");
    background-repeat:no-repeat; background-position:center; background-size:11px 11px;
  }
  .cp-more:hover{ border-color:var(--brass); color:var(--brass); background:var(--brass-bg); }
  td.cp-long > .ro{ cursor:zoom-in; }

  /* ---------- خانه‌هایی که خودِ <td> ویرایش‌پذیرند ----------
     در بیشترِ جدول‌ها متن توی یک <input> نیست؛ خودِ <td> با
     contenteditable نوشته می‌شود و برنامه مقدارش را با textContent
     می‌خواند. پس این‌جا هیچ دکمه‌ای داخلِ خانه گذاشته نمی‌شود — دکمه
     هم جزوِ متن حساب می‌شد و با ذخیره، «⌄» ته هر مقدار می‌نشست.
     نشانه یک ::after در شیوه‌نامه است که در textContent نمی‌آید. */
  td.editable-cell{
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
    max-width:1px;   /* به مرورگر اجازه می‌دهد ستون‌ها را خودش پخش کند */
  }
  td.editable-cell.cp-long{ padding-inline-end:24px; cursor:zoom-in; }
  td.editable-cell.cp-long::after{
    /* پیکان را SVG می‌کشد، نه یک نویسهٔ یونیکد: ⌄ (U+2304) روی ویندوز
       در بیشترِ قلم‌ها نیست و به‌جای پیکان یک مربعِ خالی می‌افتاد. */
    content:"";
    position:absolute; inset-block-start:50%; inset-inline-end:3px;
    transform:translateY(-50%);
    width:19px; height:19px; line-height:17px; text-align:center;
    font-family:var(--font-body); font-size:12px;
    border:1px solid var(--card-border); border-radius:6px;
    background:var(--white); color:var(--ink-faint);
    /* حتماً بعد از خلاصه‌نویسِ background: آن خلاصه‌نویس
       background-image را به none برمی‌گرداند و پیکان ناپدید می‌شد. */
    background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23888' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E");
    background-repeat:no-repeat; background-position:center; background-size:11px 11px;
    pointer-events:none;   /* کلیک به خودِ خانه می‌رسد، نه به نشانه */
    z-index:2;
  }
  td.editable-cell.cp-long:hover::after{ border-color:var(--brass); color:var(--brass); }

  /* پنجره */
  .cp-back{
    position:fixed; inset:0; z-index:400;
    background:rgba(11,37,69,.42);
    display:flex; align-items:center; justify-content:center; padding:20px;
    -webkit-backdrop-filter:blur(2px); backdrop-filter:blur(2px);
  }
  .cp-back[hidden]{ display:none; }
  .cp-box{
    width:min(680px, 100%); max-height:min(76vh, 620px);
    display:flex; flex-direction:column; gap:0;
    background:var(--white); color:var(--ink);
    border:1px solid var(--card-border); border-radius:16px;
    box-shadow:0 18px 60px rgba(11,37,69,.28);
    overflow:hidden;
  }
  .cp-head{
    display:flex; align-items:center; gap:10px;
    padding:13px 16px; border-bottom:1px solid var(--card-border);
    background:var(--paper-2, transparent);
  }
  .cp-head b{ font-size:13.5px; flex:1; min-width:0;
    overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .cp-x{
    border:0; background:transparent; color:var(--ink-faint);
    font-size:14px; line-height:1; cursor:pointer; padding:4px 7px; border-radius:7px;
  }
  .cp-x:hover{ background:var(--card-border); color:var(--ink); }
  .cp-f{
    flex:1; min-height:180px; resize:none;
    font-family:var(--font-body); font-size:13.5px; line-height:2;
    padding:14px 16px; border:0; outline:none;
    background:transparent; color:var(--ink);
  }
  .cp-back.ro .cp-f{ color:var(--ink-soft); }
  .cp-foot{
    display:flex; align-items:center; gap:10px;
    padding:11px 16px; border-top:1px solid var(--card-border);
    background:var(--paper-2, transparent);
  }
  .cp-n{ font-size:11.5px; color:var(--ink-faint); flex:1;
    font-variant-numeric:tabular-nums; }
  .cp-acts{ display:flex; gap:8px; }
  .cp-foot button{
    font-family:var(--font-body); font-size:12px; padding:7px 14px;
    border-radius:9px; border:1px solid var(--card-border);
    background:var(--white); color:var(--ink-soft); cursor:pointer;
  }
  .cp-foot button:hover{ border-color:var(--brass); color:var(--brass); }
  .cp-ok{ background:var(--brass, #1A4FA3) !important;
    border-color:var(--brass, #1A4FA3) !important; color:#fff !important; font-weight:700; }
  .cp-ok:hover{ filter:brightness(1.08); }
  body.cp-open{ overflow:hidden; }
  @media print{ .cp-back, .cp-more{ display:none !important; } }
