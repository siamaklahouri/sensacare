  /* ---------- دستهٔ جابه‌جاییِ ردیف ---------- */
  /* شش نقطه، با خودِ CSS کشیده شده — نه یک نویسهٔ یونیکد (⠿ یا ⋮⋮)
     که روی ویندوز نیاید و مربعِ خالی بشود. */
  /* دو خطِ نازک، نه شش نقطهٔ درشت. نقطه‌ها هم زمخت بودند هم در
     جدولِ شلوغ به چشم می‌زدند؛ دو خطِ کوتاه همان معنی را می‌دهد و
     آرام‌تر است. با خودِ CSS کشیده شده، پس به هیچ قلمی بند نیست. */
  .rd-grip{
    display:inline-block; width:11px; height:18px; margin-inline-end:7px;
    vertical-align:middle; cursor:grab; flex:none; border-radius:3px;
    color:var(--ink-faint); opacity:.5;
    background-image:linear-gradient(currentColor, currentColor),
                     linear-gradient(currentColor, currentColor);
    background-size:1.5px 11px;
    background-position:3px center, 6.5px center;
    background-repeat:no-repeat;
    transition:opacity .12s, color .12s;
  }
  /* تا موس به ردیف نرسیده، آرام است؛ رسید، خودش را نشان می‌دهد */
  tr:hover > td > .rd-grip{ opacity:.85; color:var(--ink-soft); }
  .rd-grip:hover{ opacity:1; color:var(--brass); }
  .rd-grip:active{ cursor:grabbing; }

  tr.rd-moving{ opacity:.45; }
  /* خطِ راهنما: کجا می‌نشیند */
  tr.rd-before > td{ box-shadow:inset 0 2px 0 0 var(--brass); }
  tr.rd-after  > td{ box-shadow:inset 0 -2px 0 0 var(--brass); }

  @media print{ .rd-grip{ display:none !important; } }
