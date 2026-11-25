  /* ---------- مصرف اینترنت ---------- */
  .nu-bar{
    display:flex; flex-wrap:wrap; gap:8px; align-items:flex-end; margin-bottom:12px;
  }
  .nu-fld{ display:flex; flex-direction:column; gap:4px; }
  .nu-fld label{ font-size:11.5px; color:var(--ink-faint); }
  .nu-fld input{
    font-family:inherit; font-size:12.5px; padding:8px 11px; border-radius:10px;
    border:1.5px solid var(--card-border); background:var(--white); color:var(--ink);
    direction:ltr; text-align:left; min-width:180px;
  }
  .nu-fld input:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }
  .nu-hint{ font-size:11.5px; color:var(--ink-faint); margin:-4px 0 12px; }

  /* کاوشگرِ داخلِ شبکه: حالش، و اگر نیست، راهِ راه‌اندازی‌اش. */
  .nu-agent{
    margin:0 0 12px; padding:9px 14px; border-radius:11px;
    background:var(--paper); border:1px solid var(--card-border);
    font-size:12px; color:var(--ink-soft);
    display:flex; flex-wrap:wrap; align-items:center; gap:10px;
  }
  .nu-agent.is-on{ background:var(--green-bg, #e8f6ef); border-color:transparent; }
  .nu-get{ display:flex; gap:8px; flex-wrap:wrap; margin-inline-start:auto; }
  .nu-get .btn{ text-decoration:none; }
  .nu-steps{ margin:7px 0 0; padding-inline-start:18px; }
  .nu-steps li{ margin-bottom:3px; }

  /* وقتی کاوش چیزی پیدا نکرد، همین‌جا می‌گوید چرا — «صفر» بی‌توضیح،
     خرابی به نظر می‌رسد. */
  .nu-why{
    margin:0 0 12px; padding:9px 14px; border-radius:11px;
    background:var(--amber-bg, #fdf4e3); color:var(--ink-soft);
    border:1px solid var(--card-border); font-size:12px;
  }
  .nu-why[hidden]{ display:none; }
  .nu-dead td{ background:var(--paper); }
  /* دستگاهی که در گزارشِ آخر نبود: هست، ولی کم‌رنگ. */
  .nu-gone td{ opacity:.6; }

  .nu-prog{
    display:none; align-items:center; gap:10px; margin:0 0 12px;
    font-size:12px; color:var(--ink-soft);
  }
  .nu-prog.on{ display:flex; }
  .nu-track{
    flex:1; height:6px; border-radius:99px; background:var(--card-border); overflow:hidden;
  }
  .nu-fill{ height:100%; width:0; background:var(--brass); transition:width .2s ease; }

  .nu-tag{
    display:inline-block; font-size:10.5px; padding:1px 7px; border-radius:99px;
    background:var(--paper); color:var(--ink-soft); margin-inline-end:4px;
    border:1px solid var(--card-border);
  }
  .nu-tag.is-good{ background:var(--green-bg, #e8f6ef); color:var(--green-ink, #137a4a); border-color:transparent; }
  .nu-ip{ direction:ltr; text-align:right; font-variant-numeric:tabular-nums; }
  .nu-num{ direction:ltr; text-align:center; font-variant-numeric:tabular-nums; white-space:nowrap; }
  .nu-dim{ color:var(--ink-faint); }

  /* پنجرهٔ انتخابِ پورت */
  .nu-ov{
    position:fixed; inset:0; z-index:720; display:flex; align-items:center;
    justify-content:center; padding:16px; background:rgba(11,20,33,.5);
  }
  .nu-ov[hidden]{ display:none !important; }
  .nu-box{
    background:var(--white); border-radius:16px; padding:18px 20px 14px;
    width:min(640px, 100%); max-height:86vh; overflow:auto;
    box-shadow:0 20px 50px rgba(0,0,0,.3); color:var(--ink);
  }
  .nu-box h4{ margin:0 0 3px; font-family:var(--font-display); font-size:15px; }
  .nu-box .nu-sub{ font-size:12px; color:var(--ink-soft); margin-bottom:12px; direction:ltr; text-align:right; }
  .nu-if{
    display:grid; grid-template-columns:1fr auto auto auto; gap:10px; align-items:center;
    padding:9px 11px; border:1.5px solid var(--card-border); border-radius:11px;
    margin-bottom:7px; cursor:pointer; background:var(--white);
  }
  .nu-if:hover{ border-color:var(--brass); }
  .nu-if.is-off{ opacity:.55; }
  .nu-if-n{ font-size:12.5px; font-weight:700; }
  .nu-if-note{ font-size:11px; color:var(--ink-faint); }
  .nu-f{ display:flex; justify-content:flex-end; gap:8px; margin-top:12px; }
  @media print{ .nu-ov{ display:none !important; } }
