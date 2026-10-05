  /* ---------- دستهٔ جابه‌جاییِ ردیف ---------- */
  /* شش نقطه، با خودِ CSS کشیده شده — نه یک نویسهٔ یونیکد (⠿ یا ⋮⋮)
     که روی ویندوز نیاید و مربعِ خالی بشود. */
  .rd-grip{
    display:inline-block; width:12px; height:16px; margin-inline-end:6px;
    vertical-align:middle; cursor:grab; opacity:.45; flex:none;
    background-image:radial-gradient(currentColor 1.1px, transparent 1.2px);
    background-size:5px 5px; background-position:0 2px;
    background-repeat:repeat; color:var(--ink-faint);
  }
  .rd-grip:hover{ opacity:1; color:var(--brass); }
  .rd-grip:active{ cursor:grabbing; }

  tr.rd-moving{ opacity:.45; }
  /* خطِ راهنما: کجا می‌نشیند */
  tr.rd-before > td{ box-shadow:inset 0 2px 0 0 var(--brass); }
  tr.rd-after  > td{ box-shadow:inset 0 -2px 0 0 var(--brass); }

  @media print{ .rd-grip{ display:none !important; } }
