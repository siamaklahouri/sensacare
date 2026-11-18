  /* ---------- نوارِ «برگرداندن» ----------
     پایینِ صفحه می‌نشیند، نه وسط: کارِ کاربر را نمی‌برد و خودش هم
     دیده می‌شود. هشت ثانیه می‌ماند و نوارِ باریکِ زیرش می‌گوید چقدر
     وقت مانده. */
  .undo-bar{
    position:fixed; inset-inline:0; bottom:18px; margin-inline:auto;
    width:max-content; max-width:calc(100vw - 32px);
    display:flex; align-items:center; gap:12px;
    background:var(--ink); color:#fff; border-radius:12px;
    padding:11px 14px; font-size:12.5px; z-index:700;
    box-shadow:0 12px 34px rgba(0,0,0,.3); overflow:hidden;
  }
  .undo-bar[hidden]{ display:none !important; }
  .ub-txt{ white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:52vw; }
  .ub-go{
    background:none; border:1px solid rgba(255,255,255,.45); color:#fff;
    border-radius:8px; padding:5px 13px; font-family:inherit; font-size:12px;
    font-weight:700; cursor:pointer; flex:none;
  }
  .ub-go:hover{ background:rgba(255,255,255,.14); }
  .ub-go:focus-visible, .ub-x:focus-visible{ outline:2px solid #fff; outline-offset:2px; }
  .ub-x{
    background:none; border:none; color:rgba(255,255,255,.65); cursor:pointer;
    font-size:13px; line-height:1; padding:4px; flex:none;
  }
  .ub-x:hover{ color:#fff; }
  .ub-bar{
    position:absolute; inset-inline-start:0; bottom:0; height:2px;
    background:var(--brass); animation:ubRun 8s linear 1 forwards;
  }
  @keyframes ubRun{ from{ width:100%; } to{ width:0; } }
  @media (prefers-reduced-motion: reduce){
    .ub-bar{ animation:none; width:100%; }
  }
  /* روی کاغذ معنایی ندارد */
  @media print{ .undo-bar{ display:none !important; } }

  /* ---------- پرسشِ پیش از حذف ----------
     همان قالبِ کادرِ «جهتِ کاغذ»، تا صفحه دو زبانِ مختلف نداشته باشد.
     دکمهٔ «حذف کن» تنها جای قرمز است و «بی‌خیال» بی‌قاب می‌ماند:
     کارِ خطرناک باید دیده شود، کارِ بی‌خطر نباید بزرگ شود. */
  .dq-ov{
    position:fixed; inset:0; z-index:720; display:flex;
    align-items:center; justify-content:center; padding:16px;
    background:rgba(11,20,33,.5);
  }
  .dq-ov[hidden]{ display:none !important; }
  .dq{
    background:var(--white); border-radius:16px; padding:20px 22px 15px;
    width:min(330px, 100%); box-shadow:0 20px 50px rgba(0,0,0,.3);
    text-align:center; color:var(--ink);
  }
  .dq-ic{
    width:38px; height:38px; margin:0 auto 10px; border-radius:50%;
    display:flex; align-items:center; justify-content:center;
    background:var(--red-bg, rgba(200,60,60,.12)); color:var(--red);
  }
  .dq-ic svg{ width:19px; height:19px; display:block; }
  .dq-h{ font-family:var(--font-display); font-size:15px; font-weight:800; margin-bottom:5px; }
  .dq-p{ font-size:12px; line-height:1.85; color:var(--ink-soft); margin-bottom:16px; }
  .dq-f{ display:flex; gap:9px; }
  .dq-f button{
    flex:1 1 0; border-radius:10px; padding:9px 10px; cursor:pointer;
    font-family:inherit; font-size:12.5px; font-weight:700;
    transition:background .15s, border-color .15s, color .15s;
  }
  .dq-no{ background:var(--paper); border:1.5px solid var(--card-border); color:var(--ink-soft); }
  .dq-no:hover{ border-color:var(--ink-faint); color:var(--ink); }
  .dq-yes{ background:var(--red); border:1.5px solid var(--red); color:#fff; }
  .dq-yes:hover{ filter:brightness(1.08); }
  .dq-f button:focus-visible{ outline:2px solid var(--brass); outline-offset:2px; }
  @media print{ .dq-ov{ display:none !important; } }
