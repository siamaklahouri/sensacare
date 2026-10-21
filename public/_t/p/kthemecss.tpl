  /* ---------- تم‌های کارتابل ----------
     هر تم فقط چند متغیر را عوض می‌کند: کاغذِ صفحه، هالهٔ پشتِ آن، و
     رنگِ «برند» (همان که دکمه و بخشِ باز و نوارِ سرفصل از آن رنگ
     می‌گیرند). جوهر، خط‌ها، و رنگ‌های معنادار — سبزِ «انجام شد»،
     کهرباییِ «نشده»، قرمزِ هشدار — دست نمی‌خورند، وگرنه با عوض کردنِ
     تم، معنیِ رنگ‌ها هم عوض می‌شد.

     تمِ شب هم برای هر کدام جدا نوشته شده، نه وارونهٔ خودکارِ روز.

     چرا «:not([data-theme="dark"])» روی گزینشگرها: پوستهٔ مشترک
     (themecss) همین متغیرها را با همان وزن می‌نویسد؛ بی این، کاغذِ تم
     اصلاً نمی‌نشست و فقط رنگِ برند عوض می‌شد. */

  /* ===== دریا ===== */
  html[data-kt="sea"]:not([data-theme="dark"]){
    --paper:#EAF2FA; --paper-deep:#D8E6F4;
    --brass:#1E7FD6; --brass-deep:#1663AA; --brass-bg:#DCEBFA; --brass-ink:#145FA6;
  }
  html[data-kt="sea"]:not([data-theme="dark"]) body{
    background:
      radial-gradient(1100px 520px at 100% -6%, rgba(30,127,214,.14), transparent 60%),
      radial-gradient(900px 460px at -8% 2%, rgba(15,168,156,.10), transparent 58%),
      var(--paper);
  }
  html[data-kt="sea"][data-theme="dark"]{
    --paper:#0A1722; --paper-deep:#0E1E2C;
    --brass:#4FA3F0; --brass-deep:#2E7FCB; --brass-bg:#10273C; --brass-ink:#8CC4F7;
  }

  /* ===== زمرد ===== */
  html[data-kt="mint"]:not([data-theme="dark"]){
    --paper:#EAF4EE; --paper-deep:#D9EBE1;
    --brass:#19876A; --brass-deep:#116B54; --brass-bg:#DCEFE7; --brass-ink:#116B54;
  }
  html[data-kt="mint"]:not([data-theme="dark"]) body{
    background:
      radial-gradient(1100px 520px at 100% -6%, rgba(25,135,106,.13), transparent 60%),
      radial-gradient(900px 460px at -8% 2%, rgba(176,120,19,.07), transparent 58%),
      var(--paper);
  }
  html[data-kt="mint"][data-theme="dark"]{
    --paper:#081611; --paper-deep:#0D2019;
    --brass:#3FBE92; --brass-deep:#2A9A74; --brass-bg:#0F2C23; --brass-ink:#7FD9B8;
  }

  /* ===== غروب ===== */
  html[data-kt="sunset"]:not([data-theme="dark"]){
    --paper:#FBF0E8; --paper-deep:#F3E1D4;
    --brass:#D2662F; --brass-deep:#AE4F22; --brass-bg:#FAE6D8; --brass-ink:#A8491F;
  }
  html[data-kt="sunset"]:not([data-theme="dark"]) body{
    background:
      radial-gradient(1100px 520px at 100% -6%, rgba(210,102,47,.13), transparent 60%),
      radial-gradient(900px 460px at -8% 2%, rgba(176,60,110,.08), transparent 58%),
      var(--paper);
  }
  html[data-kt="sunset"][data-theme="dark"]{
    --paper:#1A0F0A; --paper-deep:#23160F;
    --brass:#E8884F; --brass-deep:#C16734; --brass-bg:#32190F; --brass-ink:#F2AE83;
  }

  /* ===== بنفشه ===== */
  html[data-kt="violet"]:not([data-theme="dark"]){
    --paper:#F1EDF9; --paper-deep:#E2DAF2;
    --brass:#6B46C7; --brass-deep:#54349F; --brass-bg:#E8E1F7; --brass-ink:#54349F;
  }
  html[data-kt="violet"]:not([data-theme="dark"]) body{
    background:
      radial-gradient(1100px 520px at 100% -6%, rgba(107,70,199,.13), transparent 60%),
      radial-gradient(900px 460px at -8% 2%, rgba(30,127,214,.08), transparent 58%),
      var(--paper);
  }
  html[data-kt="violet"][data-theme="dark"]{
    --paper:#120C1F; --paper-deep:#191130;
    --brass:#9D7CF0; --brass-deep:#7B5AD6; --brass-bg:#211741; --brass-ink:#C0ABF8;
  }

  /* ===== گرافیت ===== */
  /* برای وقتی که آدم هیچ رنگی نمی‌خواهد: کاغذِ خنثی و یک برندِ آرام. */
  html[data-kt="graphite"]:not([data-theme="dark"]){
    --paper:#EFF1F3; --paper-deep:#E2E5E9;
    --brass:#4A5A6B; --brass-deep:#36434F; --brass-bg:#E3E7EB; --brass-ink:#36434F;
  }
  html[data-kt="graphite"]:not([data-theme="dark"]) body{
    background:
      radial-gradient(1100px 520px at 100% -6%, rgba(74,90,107,.09), transparent 60%),
      var(--paper);
  }
  html[data-kt="graphite"][data-theme="dark"]{
    --paper:#101418; --paper-deep:#161B21;
    --brass:#8FA3B8; --brass-deep:#6E8296; --brass-bg:#1C242D; --brass-ink:#B6C6D6;
  }

  /* ---------- خودِ انتخاب‌گر، در تنظیمات ---------- */
  .kt-grid{
    display:grid; gap:10px; grid-template-columns:repeat(auto-fill, minmax(150px,1fr));
    margin-top:4px;
  }
  .kt-card{
    display:flex; flex-direction:column; gap:8px; text-align:start; cursor:pointer;
    border:1px solid var(--card-border); border-radius:12px; padding:10px;
    background:var(--white); font-family:var(--font-body);
    transition:border-color .15s, box-shadow .15s;
  }
  .kt-card:hover{ border-color:var(--brass); }
  .kt-card.on{ border-color:var(--brass); box-shadow:0 0 0 2px var(--brass-bg); }
  /* نمونهٔ کوچکِ خودِ تم: کاغذ، برند، و یک خطِ جوهر */
  .kt-swatch{
    height:46px; border-radius:9px; position:relative; overflow:hidden;
    border:1px solid var(--card-border);
  }
  .kt-swatch i{ position:absolute; display:block; }
  .kt-swatch .s-bg{ inset:0; }
  .kt-swatch .s-ac{ inset-inline-start:8px; top:10px; width:30%; height:8px; border-radius:4px; }
  .kt-swatch .s-l1{ inset-inline-start:8px; top:24px; width:55%; height:5px; border-radius:3px; opacity:.55; }
  .kt-swatch .s-l2{ inset-inline-start:8px; top:33px; width:38%; height:5px; border-radius:3px; opacity:.3; }
  .kt-name{ font-size:12.5px; font-weight:600; color:var(--ink); }
  .kt-card.on .kt-name::after{ content:" ✓"; color:var(--brass); }
  .kt-note{ font-size:11px; color:var(--ink-faint); line-height:1.8; }
