  /* ---------- گشتِ اولِ کار ---------- */
  .tourbox{ position:fixed; inset:0; z-index:200; }
  .tourbox[hidden]{ display:none; }
  /* پرده تیره می‌کند ولی جلوی کلیک را نمی‌گیرد: گشت یک راهنماست، نه
     یک درِ بسته. آدم باید بتواند وسطش خودش جایی را بزند — و پرده‌ای
     که روی کلِ صفحه کلیک بگیرد، دقیقاً همان کاری است که یک راهنما
     نباید بکند. */
  .tr-scrim{ position:absolute; inset:0; background:rgba(8,18,30,.42); pointer-events:none; }
  .tourbox{ pointer-events:none; }
  .tr-pop{ pointer-events:auto; }
  .tr-pop{
    position:absolute; inset-inline-end:16px; top:16px; width:min(330px, calc(100vw - 32px));
    background:var(--white); border:1px solid var(--card-border); border-radius:16px;
    box-shadow:0 16px 46px rgba(11,37,69,.3); padding:15px 17px 13px;
  }
  @media (max-width:900px){
    .tr-pop{ inset-inline:16px; top:auto; bottom:calc(84px + env(safe-area-inset-bottom, 0px)); width:auto; }
  }
  .tr-n{ font-size:11px; color:var(--ink-faint); font-weight:700; margin-bottom:5px; }
  .tr-pop h4{
    margin:0 0 7px; font-family:var(--font-display); font-size:15.5px;
    font-weight:800; color:var(--brass-ink);
  }
  .tr-pop p{ margin:0 0 13px; font-size:12.8px; line-height:2.05; color:var(--ink-soft); }
  .tr-f{ display:flex; align-items:center; justify-content:space-between; gap:10px; }
  .tr-skip{
    background:none; border:none; color:var(--ink-faint); cursor:pointer;
    font-family:inherit; font-size:12px; padding:6px 4px;
  }
  .tr-skip:hover{ color:var(--ink); text-decoration:underline; }
  .tr-next{
    background:var(--brass); color:#fff; border:none; border-radius:10px;
    padding:8px 20px; font-family:inherit; font-size:12.8px; font-weight:700; cursor:pointer;
  }
  .tr-next:hover{ filter:brightness(1.05); }
  /* چیزی که گشت دربارهٔ آن حرف می‌زند، باید دیده شود */
  .tour-on{
    position:relative; z-index:201;
    box-shadow:0 0 0 3px var(--brass), 0 0 0 9px color-mix(in srgb, var(--brass) 28%, transparent);
    border-radius:10px;
  }
  @supports not (color: color-mix(in srgb, red 50%, transparent)){
    .tour-on{ box-shadow:0 0 0 3px var(--brass); }
  }
