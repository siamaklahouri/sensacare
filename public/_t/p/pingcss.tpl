
  /* ---------- پینگِ دستگاه‌ها ---------- */
  /* ---------- قرصِ وضعیت ----------
     همان زبانِ چیپ‌های وضعیتِ بقیهٔ جدول‌ها، تا این بخش مهمانِ صفحه
     به نظر نرسد. */
  .pg-chip{
    display:inline-block; padding:3px 11px; border-radius:999px;
    font-size:11.5px; font-weight:700; white-space:nowrap;
    border:1px solid transparent;
  }
  .pg-chip.pg-up{ background:var(--green-bg, #E3F3E9); color:var(--green-ink, #1A7A47); border-color:var(--green-bg, #CFE9DA); }
  .pg-chip.pg-down{ background:var(--red-bg); color:var(--red-ink); border-color:var(--red-bg); }
  .pg-chip.pg-wait{
    background:var(--brass-bg); color:var(--brass-ink); border-color:var(--brass-bg);
    animation:pgPulse 1s ease-in-out infinite;
  }
  @keyframes pgPulse{ 0%,100%{ opacity:.55 } 50%{ opacity:1 } }
  @media (prefers-reduced-motion: reduce){ .pg-chip.pg-wait{ animation:none; } }
  .pg-chip.pg-idle{ background:var(--paper); color:var(--ink-faint); border-color:var(--card-border); }
  .pg-ms{ font-size:11.5px; color:var(--ink-soft); margin-inline-start:9px; }
  .pg-why{ font-size:11.5px; color:var(--ink-soft); margin-inline-start:9px; }

  /* نوارِ زمانِ پاسخ — سبز تا ۶۰، کهربایی تا ۱۵۰، قرمز بالاتر */
  .pg-bar{
    display:inline-block; vertical-align:middle; width:62px; height:5px;
    background:var(--paper); border-radius:999px; overflow:hidden;
    margin-inline-start:9px;
  }
  .pg-bar i{ display:block; height:100%; border-radius:999px; }
  .pg-fast i{ background:var(--green, #1F9254); }
  .pg-mid i{ background:var(--brass); }
  .pg-slow i{ background:var(--red); }

  /* ---------- حالِ ردیف ----------
     نوارِ باریکِ رنگی کنارِ ردیف و یک تهِ‌رنگِ بسیار کم‌رنگ. چشم در
     جدولِ ده‌ردیفی اول رنگ را می‌بیند، بعد متن را می‌خواند — و این
     ترتیب درست است، چون سؤال «کدام قرمز است؟» است نه «این یکی چه
     می‌گوید؟». */
  .pg-row > td:first-child{ position:relative; }
  .pg-row > td:first-child::before{
    content:""; position:absolute; inset-block:6px; inset-inline-start:0;
    width:3px; border-radius:999px; background:transparent;
  }
  .pg-row.is-up    > td:first-child::before{ background:var(--green, #1F9254); }
  .pg-row.is-down  > td:first-child::before{ background:var(--red); }
  .pg-row.is-wait  > td:first-child::before{ background:var(--brass); }
  .pg-row.is-down > td{ background:color-mix(in srgb, var(--red) 4%, transparent); }
  .pg-row.is-up   > td{ background:color-mix(in srgb, var(--green, #1F9254) 4%, transparent); }

  /* نشانی چپ‌به‌راست است و با رقمِ یک‌عرض خوانده می‌شود: ستونی از
     آی‌پی که ارقامش هم‌تراز نباشد، خواندنش کارِ اضافه دارد. */
  .pg-ipcell input.pg-ip{
    direction:ltr; text-align:center; font-variant-numeric:tabular-nums;
    letter-spacing:.2px;
  }
  .pg-unit{ font-size:11px; margin-inline-start:3px; opacity:.75; font-weight:600; }

  .pg-state{ white-space:nowrap; }
  .pg-when{ font-size:11.5px; color:var(--ink-faint); white-space:nowrap; text-align:center; }
  .pg-add{ display:flex; gap:8px; flex-wrap:wrap; align-items:center; margin-top:12px; }
  .pg-add input{
    font-family:inherit; font-size:12.5px; padding:8px 11px; min-width:0;
    border:1.5px solid var(--card-border); border-radius:10px;
    background:var(--paper); color:var(--ink);
  }
  .pg-add .pg-n{ flex:1 1 180px; }
  .pg-add .pg-h{ flex:1 1 180px; }
  .pg-add .pg-p{ flex:0 0 96px; }
  .pg-add input:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }

  /* ---------- پنجرهٔ تلنت ---------- */
  .pg-acts{ white-space:nowrap; }
  .pg-acts .btn + .btn{ margin-inline-start:5px; }

  .tl-ov{
    position:fixed; inset:0; z-index:720; display:flex;
    align-items:center; justify-content:center; padding:16px;
    background:rgba(11,20,33,.5);
  }
  .tl-ov[hidden]{ display:none !important; }
  .tl{
    background:var(--white); border-radius:16px; padding:18px 20px 14px;
    width:min(620px, 100%); box-shadow:0 20px 50px rgba(0,0,0,.3); color:var(--ink);
  }
  .tl-h{ font-family:var(--font-display); font-size:15px; font-weight:800; }
  .tl-sub{
    font-size:12px; color:var(--ink-soft); margin:3px 0 13px;
    direction:ltr; text-align:right; font-variant-numeric:tabular-nums;
  }
  .tl-lbl{ display:block; font-size:11.5px; color:var(--ink-faint); margin-bottom:5px; }
  .tl-in{
    width:100%; box-sizing:border-box; font-family:inherit; font-size:12.5px;
    padding:8px 11px; border:1.5px solid var(--card-border); border-radius:10px;
    background:var(--paper); color:var(--ink); direction:ltr; text-align:left;
  }
  .tl-in:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }
  /* جوابِ دستگاه متنِ خام است: چپ‌به‌راست، با قلمِ یک‌عرض، و در قابی
     که می‌لغزد — بنرِ بعضی دستگاه‌ها چند ده خط است. */
  .tl-out{
    margin:11px 0 0; max-height:40vh; overflow:auto; white-space:pre-wrap;
    word-break:break-word; direction:ltr; text-align:left;
    font-family:ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    font-size:11.5px; line-height:1.7; padding:10px 12px; border-radius:10px;
    background:var(--paper); color:var(--ink-soft); min-height:34px;
  }
  .tl-out.is-ok{ color:var(--ink); }
  .tl-out.is-bad{ background:var(--red-bg); color:var(--red-ink); }
  .tl-out.is-wait{ color:var(--brass-ink); }
  /* ---------- مرحله‌ها ----------
     کاربر گفت «می‌خواهم ببینم تا کجا می‌رود یا کجا گیر می‌کند». پس
     بالای متنِ خام، خودِ مسیر دیده می‌شود: هر مرحله یک سطر، با
     حالِ خودش و زمانی که برد. مرحلهٔ در جریان می‌تپد؛ همان سطری که
     بماند، همان‌جایی است که کار گیر کرده. */
  .tl-steps{
    margin-top:11px; display:none; flex-direction:column; gap:1px;
    border-radius:10px; overflow:hidden; background:var(--card-border);
  }
  .tl-steps.on{ display:flex; }
  .tl-st{
    display:grid; grid-template-columns:18px 1fr auto auto; align-items:center;
    gap:8px; padding:6px 10px; background:var(--white); font-size:11.5px;
  }
  .tl-st-ic{ font-size:11px; line-height:1; text-align:center; }
  .tl-st-t{ color:var(--ink); }
  .tl-st-n{
    color:var(--ink-faint); font-size:10.5px; direction:ltr; text-align:left;
    max-width:min(230px, 42vw); overflow:hidden; text-overflow:ellipsis; white-space:nowrap;
  }
  .tl-st-ms{
    color:var(--ink-faint); font-size:10.5px; font-variant-numeric:tabular-nums;
    min-width:54px; text-align:left; direction:ltr;
  }
  .tl-st.is-run{ background:var(--brass-bg, var(--paper)); }
  .tl-st.is-run .tl-st-t{ color:var(--brass-ink); font-weight:700; }
  .tl-st.is-run .tl-st-ic{ animation:tlPulse 1s ease-in-out infinite; }
  .tl-st.is-ok .tl-st-ic{ color:var(--green-ink, #137a4a); }
  .tl-st.is-bad{ background:var(--red-bg); }
  .tl-st.is-bad .tl-st-t{ color:var(--red-ink); font-weight:700; }
  .tl-st.is-skip .tl-st-t{ color:var(--ink-faint); }
  @keyframes tlPulse{ 0%,100%{ opacity:1; } 50%{ opacity:.35; } }
  @media (prefers-reduced-motion:reduce){
    .tl-st.is-run .tl-st-ic{ animation:none; }
  }
  .tl-f{ display:flex; justify-content:flex-end; gap:8px; margin-top:12px; }
  @media print{ .tl-ov{ display:none !important; } }
