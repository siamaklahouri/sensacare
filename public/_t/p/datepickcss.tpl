
  /* ---------- تقویمِ شمسی ---------- */
  /* نشانهٔ تقویم ::after است، نه عنصر — پس نه در متنِ خانه می‌آید و نه
     با نوشتنِ تاریخ پاک می‌شود. */
  .dp-host{ position:relative; }
  .dp-host::after{
    content:"📅"; position:absolute; inset-inline-end:4px; top:50%;
    transform:translateY(-50%); font-size:11.5px; line-height:1;
    opacity:.42; pointer-events:none; transition:opacity .14s;
  }
  .dp-host:hover::after{ opacity:1; }
  /* جا برای نشانه، وگرنه روی رقم‌های تاریخ می‌افتد */
  td.dp-host{ padding-inline-end:24px; }
  td.dp-host > input{ padding-inline-end:4px; }

  .dp-pop{
    position:fixed; z-index:320; background:var(--white);
    border:1px solid var(--card-border); border-radius:12px;
    box-shadow:0 14px 40px rgba(11,37,69,.28); padding:10px;
    font-family:var(--font-body); width:250px;
  }
  .dp-pop[hidden]{ display:none; }
  .dp-head{ display:flex; align-items:center; justify-content:space-between; gap:6px; margin-bottom:8px; }
  .dp-ttl{ font-weight:700; font-size:13px; color:var(--ink); }
  .dp-nav{
    width:26px; height:26px; border:1px solid var(--line); border-radius:7px;
    background:transparent; color:var(--ink-soft); cursor:pointer; font-size:15px; line-height:1;
  }
  .dp-nav:hover{ border-color:var(--brass); color:var(--brass-ink); background:var(--brass-bg); }
  .dp-wd, .dp-grid{ display:grid; grid-template-columns:repeat(7,1fr); gap:3px; }
  .dp-wd{ margin-bottom:4px; }
  .dp-wd span{ text-align:center; font-size:10.5px; color:var(--ink-faint); font-weight:700; }
  .dp-d{
    height:28px; border:1px solid transparent; border-radius:7px; background:transparent;
    color:var(--ink); font-family:var(--font-body); font-size:12px; cursor:pointer;
    transition:background .12s, color .12s, border-color .12s;
  }
  .dp-d:hover{ background:var(--brass-bg); color:var(--brass-ink); }
  /* امروز قاب دارد، روزِ انتخاب‌شده پُر است — دو چیزِ جدا، دو نشانِ جدا */
  .dp-d.now{ border-color:var(--brass); }
  .dp-d.on{ background:var(--brass); color:#fff; border-color:var(--brass); font-weight:700; }
  .dp-pad{ height:28px; }
  .dp-foot{ display:flex; gap:6px; margin-top:9px; }
  .dp-foot button{
    flex:1; height:27px; border:1px solid var(--line); border-radius:7px;
    background:transparent; font-family:var(--font-body); font-size:11.5px; cursor:pointer;
    color:var(--ink-soft);
  }
  .dp-foot .dp-today:hover{ border-color:var(--brass); color:var(--brass-ink); background:var(--brass-bg); }
  .dp-foot .dp-clear:hover{ border-color:var(--red); color:var(--red-ink); background:var(--red-bg); }
