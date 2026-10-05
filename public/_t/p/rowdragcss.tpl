  /* ---------- دستهٔ جابه‌جاییِ ردیف ---------- */
  /* شش نقطه، با خودِ CSS کشیده شده — نه یک نویسهٔ یونیکد (⠿ یا ⋮⋮)
     که روی ویندوز نیاید و مربعِ خالی بشود. */
  /* بارِ اول آن‌قدر ریز و کم‌رنگ بود که کاربر پیدایش نکرد و خیالش
     رسید جابه‌جایی اصلاً کار نمی‌کند. حالا بزرگ‌تر و پررنگ‌تر است و
     با رسیدنِ موس به ردیف، خودش را نشان می‌دهد. */
  .rd-grip{
    display:inline-block; width:16px; height:20px; margin-inline-end:7px;
    vertical-align:middle; cursor:grab; opacity:.72; flex:none;
    border-radius:4px;
    background-image:radial-gradient(currentColor 1.35px, transparent 1.45px);
    background-size:6px 6px; background-position:1px 3px;
    background-repeat:repeat; color:var(--ink-soft);
    transition:opacity .12s, color .12s, background-color .12s;
  }
  tr:hover > td > .rd-grip{ opacity:1; color:var(--brass); }
  .rd-grip:hover{ opacity:1; color:var(--brass);
    background-color:color-mix(in srgb, var(--brass) 14%, transparent); }
  .rd-grip:active{ cursor:grabbing; }

  tr.rd-moving{ opacity:.45; }
  /* خطِ راهنما: کجا می‌نشیند */
  tr.rd-before > td{ box-shadow:inset 0 2px 0 0 var(--brass); }
  tr.rd-after  > td{ box-shadow:inset 0 -2px 0 0 var(--brass); }

  @media print{ .rd-grip{ display:none !important; } }
