
  /* ---------- سرستونِ مرتب‌شونده و فیلترِ ستونی ----------
     فلش فقط روی ستونی دیده می‌شود که جدول رویش مرتب است؛ بقیه سر که
     می‌کشی رنگ عوض می‌کنند و می‌گویند کلیک‌شدنی‌اند. بی این، یازده
     سرستونِ همه‌فلش‌دار شلوغ‌تر از آن بود که چیزی بگوید. */
  th.ts-h{ cursor:pointer; user-select:none; }
  @media (min-width: 761px){ th.ts-h{ white-space:nowrap; } }
  th.ts-h:hover{ color:var(--brass-ink, var(--brass)); }
  th.ts-h:focus-visible{ outline:2px solid var(--brass); outline-offset:-2px; }
  .ts-ar{ font-size:9px; margin-inline-start:4px; opacity:.9; letter-spacing:0; }
  th.ts-on{ color:var(--brass-ink, var(--brass)); }

  .ts-f{
    width:100%; min-width:0; box-sizing:border-box;
    font-family:inherit; font-size:11px; padding:3px 6px;
    border:1px solid var(--card-border); border-radius:6px;
    background:var(--white); color:var(--ink); font-weight:400;
  }
  .ts-f::placeholder{ color:var(--ink-faint); font-weight:400; }
  .ts-f:focus-visible{ outline:2px solid var(--brass); outline-offset:1px; }

  tr.ts-none td{
    color:var(--ink-faint); font-size:12px; padding:14px 8px; text-align:center;
  }

  /* نماِ مرتب‌شده با ترتیبِ دادهٔ واقعی یکی نیست، پس کشیدنِ ردیف
     خاموش می‌شود — ولی برداشته نمی‌شود، که ستون نپرد. */
  table[data-tsorted] .rd-grip{ opacity:.25; pointer-events:none; }

  /* روی گوشی، ردیفِ فیلتر جا ندارد: هر کادر یک کمینه‌عرض می‌آورد و
     ستونِ اصلی — همان چیزی که آدم می‌خواهد بخواند — له می‌شود. آن‌جا
     جست‌وجوی سراسری (Ctrl+K) و کشویِ ردیف کار را می‌کنند. */
  @media (max-width: 760px){
    tr.ts-fr{ display:none !important; }
    .ts-f{ display:none !important; }
    /* و سرستون روی گوشی باید بشکند: nowrap عرضِ ذاتیِ هر ستون را
       بالا می‌برد و ستونِ اصلی را له می‌کند. */
    th.ts-h{ white-space:normal; }
  }

  @media print{
    .filter-row{ display:none !important; }
    .ts-ar{ display:none !important; }
  }
