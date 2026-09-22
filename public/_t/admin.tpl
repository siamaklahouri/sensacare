<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex, nofollow">
<link rel="icon" type="image/png" sizes="64x64" href="/favicon-sl.3.png">
<link rel="icon" type="image/png" sizes="512x512" href="/icon-sl.3.png">
<link rel="apple-touch-icon" href="/icon-sl.3.png">
<script>
try{ if(localStorage.getItem("admin-planer:theme") === "dark")
  document.documentElement.setAttribute("data-theme","dark"); }catch(e){}
</script>
<title>پنل کارتابل‌ها</title>
<style>
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:400;font-display:swap;
  src:url(/f/Vazirmatn-Regular.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:500;font-display:swap;
  src:url(/f/Vazirmatn-Medium.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:600;font-display:swap;
  src:url(/f/Vazirmatn-SemiBold.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:700;font-display:swap;
  src:url(/f/Vazirmatn-Bold.2.woff2) format("woff2")}
</style>
<style>
/* ==========================================================================
   پنل کارتابل‌ها — شیوه‌نامه
   رنگ‌ها همان لهجهٔ کارتابل‌هاست تا وقتی بینشان جابه‌جا می‌شوید حس
   دو برنامهٔ جدا ندهد. تم شب رنگِ وارونه نیست؛ مقدارهای خودش را دارد.
   ========================================================================== */
:root{
  --paper:#EDF1F6; --paper-2:#F7F9FB;
  --ink:#0B2545; --ink-soft:#43586D; --ink-faint:#8697A8;
  /* رنگِ هویت از خودِ لوگو می‌آید: آبیِ SLTech. «btn» جدا از «brass»
     است چون متنِ دکمه سفید است و در تمِ شب یک آبیِ روشن، متنِ سفید را
     ناخوانا می‌کرد — این‌طور هم لینک خوانا می‌ماند هم دکمه. */
  --brass:#1A4FA3; --brass-deep:#123E80; --brass-bg:#E4EAF7; --brass-ink:#14458F;
  --btn:#1A4FA3; --btn-deep:#123E80;
  --green:#2F6B4F; --green-bg:#E4EFE8; --green-ink:#2F6B4F;
  --amber:#B5791B; --amber-bg:#FAF0DD; --amber-ink:#8E5E12;
  --red:#A6222B;   --red-bg:#F7E2E3;   --red-ink:#8E1D25;
  --purple:#5B3E8C;--purple-bg:#EBE5F3;--purple-ink:#5B3E8C;
  --line:#DCE3EA; --line-soft:#E9EEF3; --white:#FFFFFF;
  --font:'Vazirmatn', Tahoma, 'Segoe UI', Arial, sans-serif;
  --r-lg:18px; --r:13px; --r-sm:9px;
  --sh-1:0 1px 2px rgba(11,37,69,.04), 0 2px 8px rgba(11,37,69,.05);
  --sh-2:0 2px 6px rgba(11,37,69,.06), 0 12px 32px rgba(11,37,69,.09);
  --sh-3:0 8px 24px rgba(11,37,69,.12), 0 32px 64px rgba(11,37,69,.16);
  --glow:0 0 0 3px rgba(26,79,163,.18);
  /* رنگِ هویتِ سه نوع کارتابل. این سه با سنجهٔ کوررنگی بررسی شده‌اند:
     نزدیک‌ترین جفتشان در دید عادی ΔE ۱۹٫۶ و در پروتان ۱۲٫۸ فاصله دارد.
     جای ثابتی دارند و هیچ‌وقت چرخانده نمی‌شوند. */
  --s-it:#0A8F88; --s-fin:#B5791B; --s-gen:#6E45B0;
  --s-it-bg:#E2F3F2; --s-fin-bg:#FAF0DD; --s-gen-bg:#EDE7F6;
  --bar:#0A8F88; --bar-soft:#E2F3F2;
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --paper:#0B141D; --paper-2:#101C27;
    --ink:#E7EEF4; --ink-soft:#AAB9C7; --ink-faint:#78899A;
    --brass:#6AA3FF; --brass-deep:#4C88EE; --brass-bg:#11213C; --brass-ink:#9BC4FF;
  --btn:#2A5FBF; --btn-deep:#1D4794;
    --green:#5FB07E; --green-bg:#15301F; --green-ink:#7CC698;
    --amber:#DFA94F; --amber-bg:#382B11; --amber-ink:#EBBE72;
    --red:#E8737C;   --red-bg:#391A1D;   --red-ink:#F09099;
    --purple:#A88FD8;--purple-bg:#221A33;--purple-ink:#BCA8E4;
    --line:#1F2C38; --line-soft:#182430; --white:#121E29;
    --sh-1:0 1px 2px rgba(0,0,0,.3), 0 2px 8px rgba(0,0,0,.26);
    --sh-2:0 2px 6px rgba(0,0,0,.32), 0 12px 32px rgba(0,0,0,.36);
    --sh-3:0 8px 24px rgba(0,0,0,.45), 0 32px 64px rgba(0,0,0,.5);
    --glow:0 0 0 3px rgba(106,163,255,.22);
    /* گامِ شب از همان رنگ‌ها، ولی دوباره سنجیده — نه وارونهٔ خودکارِ روز */
    --s-it:#1FA298; --s-fin:#B8862C; --s-gen:#8B73C8;
    --s-it-bg:#10302E; --s-fin-bg:#382B11; --s-gen-bg:#221A33;
    --bar:#3FB6AE; --bar-soft:#12312F;
  }
}
:root[data-theme="dark"]{
  --paper:#0B141D; --paper-2:#101C27;
  --ink:#E7EEF4; --ink-soft:#AAB9C7; --ink-faint:#78899A;
  --brass:#3FB6AE; --brass-deep:#2E958F; --brass-bg:#10302E; --brass-ink:#5CCCC4;
  --green:#5FB07E; --green-bg:#15301F; --green-ink:#7CC698;
  --amber:#DFA94F; --amber-bg:#382B11; --amber-ink:#EBBE72;
  --red:#E8737C;   --red-bg:#391A1D;   --red-ink:#F09099;
  --purple:#A88FD8;--purple-bg:#221A33;--purple-ink:#BCA8E4;
  --line:#1F2C38; --line-soft:#182430; --white:#121E29;
  --sh-1:0 1px 2px rgba(0,0,0,.3), 0 2px 8px rgba(0,0,0,.26);
  --sh-2:0 2px 6px rgba(0,0,0,.32), 0 12px 32px rgba(0,0,0,.36);
  --sh-3:0 8px 24px rgba(0,0,0,.45), 0 32px 64px rgba(0,0,0,.5);
  --glow:0 0 0 3px rgba(63,182,174,.2);
  /* گامِ شب از همان رنگ‌ها، ولی دوباره سنجیده — نه وارونهٔ خودکارِ روز */
  --s-it:#1FA298; --s-fin:#B8862C; --s-gen:#8B73C8;
  --s-it-bg:#10302E; --s-fin-bg:#382B11; --s-gen-bg:#221A33;
  --bar:#3FB6AE; --bar-soft:#12312F;
}

*{box-sizing:border-box;}
html,body{margin:0;padding:0;}
body{
  font-family:var(--font); font-size:13.5px; line-height:1.75;
  color:var(--ink);
  background:
    radial-gradient(900px 420px at 100% -8%, rgba(26,79,163,.07), transparent 62%),
    radial-gradient(760px 380px at -8% 4%, rgba(91,62,140,.06), transparent 58%),
    var(--paper);
  background-attachment:fixed;
  min-height:100vh; -webkit-font-smoothing:antialiased;
}
::selection{ background:var(--brass); color:#fff; }
h1,h2,h3,h4{ font-weight:700; letter-spacing:-.01em; }
a{ color:var(--brass-ink); }

/* ---------- قفل ورود ---------- */
#gate{ position:fixed; inset:0; z-index:90; display:flex; align-items:center;
  justify-content:center; padding:20px;
  background:
    radial-gradient(700px 360px at 50% -10%, rgba(26,79,163,.10), transparent 60%),
    var(--paper); }
#gate[hidden]{ display:none; }
.gate-card{ background:var(--white); border:1px solid var(--line);
  border-radius:var(--r-lg); box-shadow:var(--sh-2); padding:34px 28px 28px;
  width:100%; max-width:390px; text-align:center;
  animation:rise .4s cubic-bezier(.2,.8,.3,1); }
@keyframes rise{ from{ opacity:0; transform:translateY(10px); } to{ opacity:1; transform:none; } }
/* نشانِ SLTech — همان لوگوی برند، گِرد بریده تا در کنارِ متن جا بیفتد. */
.gate-mark{ display:block; width:68px; height:68px; margin:0 auto 10px;
  border-radius:50%; }
/* «SLTech» به‌جای تصویر، متن است: در هر اندازه‌ای تیز می‌ماند و
   روی کارتِ سفید هم مثل تصویرِ پس‌زمینه‌دار یک مستطیلِ تیره نمی‌سازد. */
.brandword{ font-family:system-ui, -apple-system, "Segoe UI", Arial, sans-serif;
  font-size:19px; font-weight:600; letter-spacing:.14em; margin:0 0 14px;
  background:linear-gradient(180deg, var(--ink) 0%, var(--ink-soft) 100%);
  -webkit-background-clip:text; background-clip:text; color:transparent;
  -webkit-text-fill-color:transparent; }
@supports not (background-clip: text){ .brandword{ color:var(--ink); -webkit-text-fill-color:currentColor; } }

.gate-card h1{ font-size:17.5px; margin:0 0 7px; }
.gate-card p{ font-size:12.5px; color:var(--ink-soft); line-height:2.05; margin:0 0 18px; }
.gate-card input{ width:100%; padding:12px 13px; margin-bottom:9px;
  border:1px solid var(--line); border-radius:var(--r);
  font-family:var(--font); font-size:13.5px;
  background:var(--paper-2); color:var(--ink); transition:border-color .15s, box-shadow .15s; }
.gate-card input::placeholder{ color:var(--ink-faint); }
.gate-card input:focus{ outline:none; border-color:var(--brass);
  background:var(--white); box-shadow:var(--glow); }
.gate-card button[type="submit"]{ width:100%; padding:12px; border:0; border-radius:var(--r);
  background:linear-gradient(145deg, var(--btn), var(--btn-deep)); color:#fff;
  font-family:var(--font); font-size:14px; font-weight:700; cursor:pointer;
  box-shadow:0 4px 12px rgba(18,62,128,.28); transition:transform .12s, box-shadow .15s; }
.gate-card button[type="submit"]:hover{ transform:translateY(-1px);
  box-shadow:0 6px 18px rgba(18,62,128,.34); }
.gate-card button[type="submit"]:disabled{ opacity:.6; cursor:default; transform:none; }
.gate-err{ color:var(--red-ink); font-size:12.5px; min-height:20px; margin-top:9px; }
.gate-note{ color:var(--ink-soft); font-size:12.5px; margin-top:8px; line-height:2; }
.gate-forgot{ display:block; margin:10px auto 0; background:none; border:0; padding:4px;
  color:var(--ink-faint); font:inherit; font-size:12px; cursor:pointer;
  text-decoration:underline; text-underline-offset:3px; }
.gate-forgot:hover{ color:var(--brass); }
.gate-forgot:disabled{ cursor:default; opacity:.6; text-decoration:none; }

/* ---------- چارچوب ---------- */
/* یک متغیّر برای حاشیهٔ کناری، چون نوارِ چسبان با حاشیهٔ منفی از آن
   بیرون می‌زند: اگر دو عدد از هم بیفتند، روی موبایل نوارِ افقی می‌آید. */
:root{ --gut:18px; }
@media (max-width:560px){ :root{ --gut:14px; } }
.wrap{ max-width:1160px; margin:0 auto; padding:0 var(--gut) 70px; }

/* سربالا می‌چسبد تا «خروج» و تمِ شب همیشه دمِ دست باشد، و پشتش مات
   می‌شود تا کارت‌ها از زیرش رد شوند بی‌آنکه متن را شلوغ کنند. */
.topbar{ position:sticky; top:0; z-index:40;
  margin:0 calc(-1 * var(--gut)) 18px;
  padding:14px var(--gut); border-bottom:1px solid var(--line);
  background:color-mix(in srgb, var(--paper) 82%, transparent);
  backdrop-filter:blur(10px) saturate(1.4); }
@supports not (backdrop-filter: blur(1px)){ .topbar{ background:var(--paper); } }
.top{ display:flex; align-items:center; gap:13px;
  max-width:1160px; margin:0 auto; }
.mark{ width:42px; height:42px; flex:none; display:block; border-radius:50%;
  box-shadow:0 3px 10px rgba(18,46,110,.28); }
.top .titles{ flex:1; min-width:0; }
.top h1{ font-size:19px; margin:0; }
.top .sub2{ font-size:11.5px; color:var(--ink-faint); margin:1px 0 0; }
.icon-btn{ width:36px; height:36px; flex:none; display:flex; align-items:center;
  justify-content:center; border:1px solid var(--line); background:var(--white);
  color:var(--ink-soft); border-radius:11px; cursor:pointer; font-size:14px;
  transition:border-color .15s, color .15s, transform .12s; }
.icon-btn:hover{ border-color:var(--brass); color:var(--brass-ink); transform:translateY(-1px); }

/* ---------- نوار آمار ---------- */
.stats{ display:grid; grid-template-columns:repeat(auto-fit, minmax(160px,1fr));
  gap:11px; margin-bottom:18px; }
.stat{ position:relative; display:flex; align-items:center; gap:12px;
  background:var(--white); border:1px solid var(--line); border-radius:var(--r);
  padding:13px 15px; box-shadow:var(--sh-1); overflow:hidden;
  transition:box-shadow .2s, transform .15s; }
.stat:hover{ box-shadow:var(--sh-2); transform:translateY(-1px); }
/* نوارِ رنگی لبهٔ «شروع» است، پس در راست‌چین سمتِ راست می‌نشیند. */
.stat::before{ content:""; position:absolute; inset-block:0; inset-inline-start:0;
  width:3px; background:var(--sc, var(--brass)); }
.stat .si{ width:34px; height:34px; flex:none; border-radius:11px; font-size:15px;
  display:flex; align-items:center; justify-content:center;
  background:var(--sbg, var(--brass-bg)); }
.stat .sv{ min-width:0; }
.stat .n{ font-size:21px; font-weight:800; line-height:1.25; letter-spacing:-.02em;
  font-variant-numeric:tabular-nums; }
.stat .l{ font-size:11.5px; color:var(--ink-faint); line-height:1.7; }
.stat.s-all{ --sc:var(--brass); --sbg:var(--brass-bg); }
.stat.s-on{ --sc:var(--green); --sbg:var(--green-bg); }
.stat.s-on .n{ color:var(--green-ink); }
.stat.s-off{ --sc:var(--amber); --sbg:var(--amber-bg); }
.stat.s-off .n{ color:var(--amber-ink); }
.stat.s-key{ --sc:var(--purple); --sbg:var(--purple-bg); }
.stat.s-key .n{ font-size:14px; line-height:1.9; }

/* ---------- سربرگ‌ها ---------- */
.tabs{ display:flex; gap:4px; flex-wrap:wrap; margin-bottom:18px;
  background:var(--white); border:1px solid var(--line); border-radius:14px;
  padding:4px; box-shadow:var(--sh-1); width:fit-content; max-width:100%;
  overflow-x:auto; }
.tabs button{ padding:8px 16px; border:0; background:transparent; color:var(--ink-soft);
  border-radius:10px; font-family:var(--font); font-size:12.5px; font-weight:500;
  cursor:pointer; transition:background .15s, color .15s; white-space:nowrap; }
.tabs button:hover{ color:var(--ink); background:var(--paper-2); }
.tabs button.active{ background:var(--brass); color:#fff; font-weight:700;
  box-shadow:0 2px 8px rgba(18,62,128,.3); }

/* ---------- پنل ---------- */
.panel{ background:var(--white); border:1px solid var(--line); border-radius:var(--r-lg);
  box-shadow:var(--sh-1); padding:20px; margin-bottom:14px; }
.panel h2{ font-size:15px; margin:0 0 5px; display:flex; align-items:center; gap:7px; }
.panel .sub{ font-size:12px; color:var(--ink-soft); line-height:2; margin:0 0 16px; }

/* ---------- دکمه‌ها ---------- */
.btn{ padding:8px 14px; border:1px solid var(--line); background:var(--white);
  color:var(--ink-soft); border-radius:var(--r-sm); font-family:var(--font);
  font-size:12.5px; font-weight:500; cursor:pointer;
  transition:border-color .15s, color .15s, background .15s, transform .12s; }
.btn:hover{ border-color:var(--brass); color:var(--brass-ink); transform:translateY(-1px); }
.btn:active{ transform:none; }
.btn-main{ background:linear-gradient(145deg, var(--btn), var(--btn-deep));
  border-color:transparent; color:#fff; font-weight:700;
  box-shadow:0 3px 10px rgba(18,62,128,.26); }
.btn-main:hover{ color:#fff; border-color:transparent;
  box-shadow:0 5px 14px rgba(18,62,128,.32); }
.btn-danger{ color:var(--red-ink); border-color:var(--red-bg); background:var(--red-bg); }
.btn-danger:hover{ background:var(--red); color:#fff; border-color:var(--red); }
.btn-off{ color:var(--amber-ink); border-color:var(--amber-bg); background:var(--amber-bg); }
.btn-off:hover{ background:var(--amber); color:#fff; border-color:var(--amber); }
.btn-on{ color:var(--green-ink); border-color:var(--green-bg); background:var(--green-bg); }
.btn-on:hover{ background:var(--green); color:#fff; border-color:var(--green); }
.btn:disabled{ opacity:.5; cursor:default; transform:none; }

/* ---------- کادرها ---------- */
.row{ display:flex; gap:12px; flex-wrap:wrap; align-items:flex-end; }
.fld{ display:flex; flex-direction:column; gap:6px; min-width:150px; flex:1; }
.fld label{ font-size:11.5px; color:var(--ink-soft); font-weight:500; }
.fld input, .fld select{ padding:10px 11px; border:1px solid var(--line);
  border-radius:var(--r-sm); font-family:var(--font); font-size:13px;
  background:var(--paper-2); color:var(--ink);
  transition:border-color .15s, box-shadow .15s, background .15s; }
.fld input::placeholder{ color:var(--ink-faint); }
.fld input:focus, .fld select:focus{ outline:none; border-color:var(--brass);
  background:var(--white); box-shadow:var(--glow); }
.hint{ font-size:11.5px; color:var(--ink-faint); line-height:2; margin-top:8px; }
.hint2{ font-size:11px; color:var(--ink-faint); font-weight:400; }
/* یک ردیفِ پلن: نام، قیمت، مدت، توضیح، و دکمهٔ برداشتن */
.planrow{ display:grid; gap:8px; align-items:center; margin-bottom:8px;
  grid-template-columns: 1.3fr .9fr .6fr 1.6fr auto; }
@media (max-width:760px){ .planrow{ grid-template-columns:1fr 1fr; } }
.planrow input{ width:100%; padding:9px 11px; border:1px solid var(--line);
  border-radius:var(--r-sm); background:var(--paper-2); color:var(--ink);
  font-family:var(--font); font-size:13px; }
.planrow input:focus{ outline:none; border-color:var(--brass); box-shadow:var(--glow); }
.planrow .x{ width:32px; height:32px; border-radius:var(--r-sm); border:1px solid var(--line);
  background:var(--white); color:var(--red-ink); cursor:pointer; line-height:1; }
.planrow .x:hover{ background:var(--red-bg); border-color:var(--red-bg); }
.hint b{ color:var(--ink-soft); }

/* ---------- کارت کارتابل ---------- */
.plist{ display:grid; grid-template-columns:repeat(auto-fill, minmax(352px,1fr)); gap:14px;
  align-items:stretch; }
.pcard{ display:flex; flex-direction:column; }
.pcard .acts{ margin-top:auto; }
.pcard{ position:relative; background:var(--white); border:1px solid var(--line);
  border-radius:var(--r-lg); box-shadow:var(--sh-1); padding:18px 17px 16px;
  overflow:hidden; transition:box-shadow .22s, transform .18s, border-color .18s; }
.pcard::before{ content:""; position:absolute; inset:0 0 auto 0; height:3px;
  background:var(--accent, var(--brass)); opacity:.9; }
/* یک هالهٔ نرم از رنگِ خودِ نوع، که فقط موقعِ نزدیک‌شدن دیده می‌شود */
.pcard::after{ content:""; position:absolute; inset:-40% -30% auto auto;
  width:190px; height:190px; border-radius:50%; pointer-events:none;
  background:radial-gradient(circle, var(--accent, var(--brass)), transparent 68%);
  opacity:0; transition:opacity .3s; }
.pcard:hover{ box-shadow:var(--sh-2); transform:translateY(-3px);
  border-color:color-mix(in srgb, var(--accent, var(--brass)) 35%, var(--line)); }
.pcard:hover::after{ opacity:.07; }
.pcard > *{ position:relative; }
.pcard.k-it{ --accent:var(--s-it); }
.pcard.k-fin{ --accent:var(--s-fin); }
.pcard.k-gen{ --accent:var(--s-gen); }
.pcard.off{ opacity:.75; }
.pcard.off::before{ background:var(--amber); }
.pc-head{ display:flex; align-items:flex-start; gap:10px; margin-bottom:3px; }
.pc-ic{ width:36px; height:36px; flex:none; border-radius:12px; font-size:17px;
  display:flex; align-items:center; justify-content:center;
  background:var(--accent-bg, var(--brass-bg)); }
.pcard.k-it .pc-ic{ background:var(--s-it-bg); }
.pcard.k-fin .pc-ic{ background:var(--s-fin-bg); }
.pcard.k-gen .pc-ic{ background:var(--s-gen-bg); }
.pcard h3{ margin:0; font-size:15px; display:flex; align-items:center;
  gap:6px; flex-wrap:wrap; line-height:1.6; }
.pill{ font-size:10px; padding:2px 8px; border-radius:999px; font-weight:700;
  line-height:1.8; }
.pill-it{ background:var(--s-it-bg); color:var(--s-it); }
.pill-fin{ background:var(--s-fin-bg); color:var(--s-fin); }
.pill-gen{ background:var(--s-gen-bg); color:var(--s-gen); }
.pill-builtin{ background:var(--amber-bg); color:var(--amber-ink); }
.pill-off{ background:var(--red-bg); color:var(--red-ink); }
.urlrow{ display:flex; align-items:center; gap:5px; margin:3px 0 12px; }
.pcard .url{ font-size:11.5px; color:var(--brass-ink); text-decoration:none;
  direction:ltr; display:inline-block; padding:3px 9px; border-radius:7px;
  background:var(--paper-2); border:1px solid var(--line-soft);
  transition:border-color .15s, background .15s;
  max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.pcard .url:hover{ border-color:var(--brass); background:var(--white); }
.copy{ border:1px solid var(--line-soft); background:var(--paper-2);
  color:var(--ink-faint); border-radius:7px; padding:3px 7px; font-size:11px;
  cursor:pointer; line-height:1.7; transition:color .15s, border-color .15s; }
.copy:hover{ color:var(--brass-ink); border-color:var(--brass); }
.copy.done{ color:var(--green-ink); border-color:var(--green); }
.meta{ border-top:1px solid var(--line-soft); padding-top:11px; margin-bottom:13px; }
.meta .m{ display:flex; gap:8px; font-size:11.5px; line-height:2.15; }
.meta .m span:first-child{ color:var(--ink-faint); flex:none; min-width:112px; }
.meta .m span:last-child{ color:var(--ink-soft); min-width:0;
  overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.meta .m.warn span:last-child{ color:var(--amber-ink); font-weight:600; }
.pcard .acts{ display:flex; gap:6px; flex-wrap:wrap;
  border-top:1px solid var(--line-soft); padding-top:13px; }
.pcard .acts .btn{ padding:6px 11px; font-size:11.5px; }
.pcard .acts .btn-ic{ padding:6px 9px; font-size:13px; line-height:1.4; }

/* ---------- نوار جستجو ---------- */
.findbar{ display:flex; gap:9px; align-items:center; margin-bottom:14px; }
.findbar input{ flex:1; padding:10px 13px; border:1px solid var(--line);
  border-radius:var(--r); font-family:var(--font); font-size:13px;
  background:var(--white); color:var(--ink); box-shadow:var(--sh-1);
  transition:border-color .15s, box-shadow .15s; }
.findbar input::placeholder{ color:var(--ink-faint); }
.findbar input:focus{ outline:none; border-color:var(--brass); box-shadow:var(--glow); }
.findbar .n{ font-size:11.5px; color:var(--ink-faint); white-space:nowrap; }

/* ---------- انتخاب نوع کارتابل ---------- */
.kinds{ display:grid; grid-template-columns:repeat(auto-fit, minmax(210px,1fr));
  gap:10px; margin-bottom:16px; }
.kind{ text-align:right; border:1px solid var(--line); background:var(--paper-2);
  border-radius:var(--r); padding:13px 14px; cursor:pointer; font-family:var(--font);
  color:var(--ink); transition:border-color .15s, background .15s, box-shadow .15s; }
.kind:hover{ border-color:var(--brass); background:var(--white); }
.kind.on{ border-color:var(--brass); background:var(--white); box-shadow:var(--glow); }
.kind .kt{ font-size:13.5px; font-weight:700; display:flex; align-items:center; gap:7px; }
.kind .kn{ font-size:11.5px; color:var(--ink-faint); line-height:1.95; margin-top:5px; }

/* ---------- بخش‌هایی که باز یا بسته‌اند ---------- */
.feats{ display:grid; grid-template-columns:repeat(auto-fit, minmax(230px,1fr)); gap:8px; }
.feat{ display:flex; gap:9px; align-items:flex-start; padding:10px 11px;
  border:1px solid var(--line); border-radius:var(--r-sm); background:var(--paper-2);
  cursor:pointer; transition:border-color .15s, background .15s; }
.feat:hover{ border-color:var(--brass); background:var(--white); }
.feat input{ margin:3px 0 0; accent-color:var(--brass); width:15px; height:15px;
  flex:none; cursor:pointer; }
.feat .ft{ font-size:12.5px; font-weight:600; }
.feat .fn{ font-size:11.5px; color:var(--ink-faint); line-height:1.85; }
.feat.closed{ background:var(--red-bg); border-color:var(--red-bg); }
.feat.closed .ft{ color:var(--red-ink); }

/* ---------- بخش‌های شخصی ---------- */
.secrow{ display:flex; gap:8px; align-items:center; margin-bottom:8px; flex-wrap:wrap;
  background:var(--paper-2); border:1px solid var(--line-soft);
  border-radius:var(--r-sm); padding:8px; }
.secrow input, .secrow select{ padding:8px 10px; border:1px solid var(--line);
  border-radius:8px; font-family:var(--font); font-size:12.5px;
  background:var(--white); color:var(--ink); }
.secrow input:focus, .secrow select:focus{ outline:none; border-color:var(--brass);
  box-shadow:var(--glow); }
.secrow input.bad{ border-color:var(--red); background:var(--red-bg); }
.secrow .stitle{ flex:1; min-width:130px; }
.secrow .scols{ flex:1.4; min-width:160px; }
.x{ border:0; background:transparent; color:var(--red-ink); font-size:15px;
  cursor:pointer; padding:3px 7px; border-radius:7px; transition:background .15s; }
.x:hover{ background:var(--red-bg); }

/* ---------- پیام ---------- */
.msg{ padding:12px 14px; border-radius:var(--r); font-size:12.5px; line-height:2.1;
  margin-bottom:14px; white-space:pre-wrap; word-break:break-word;
  animation:rise .3s cubic-bezier(.2,.8,.3,1); box-shadow:var(--sh-1); }
.msg-ok{ background:var(--green-bg); color:var(--green-ink);
  border:1px solid transparent; border-right:3px solid var(--green); }
.msg-bad{ background:var(--red-bg); color:var(--red-ink);
  border:1px solid transparent; border-right:3px solid var(--red); }
.msg b{ font-weight:700; }
.msg code{ font-family:ui-monospace, Menlo, Consolas, monospace; direction:ltr;
  display:inline-block; background:var(--white); padding:5px 11px; border-radius:8px;
  font-size:13.5px; letter-spacing:.6px; margin:3px 0; box-shadow:var(--sh-1);
  color:var(--ink); }

/* ---------- گزارش ---------- */
.grid2{ display:grid; grid-template-columns:repeat(auto-fit, minmax(320px,1fr)); gap:14px; }
.mix{ display:flex; height:26px; border-radius:8px; overflow:hidden; gap:2px;
  background:var(--line-soft); margin-bottom:12px; }
.mix i{ display:block; }
.legend{ display:flex; gap:16px; flex-wrap:wrap; font-size:12px; color:var(--ink-soft); }
.legend b{ display:inline-flex; align-items:center; gap:6px; font-weight:500; }
.legend b::before{ content:""; width:10px; height:10px; border-radius:3px;
  background:var(--c); flex:none; }
.legend .v{ color:var(--ink); font-weight:700; }

/* میله‌های افقی — یک رنگ، چون اندازه را نشان می‌دهند نه هویت را */
.bars{ display:flex; flex-direction:column; gap:9px; }
.bar-row{ display:grid; grid-template-columns:86px 1fr auto; gap:10px; align-items:center;
  font-size:12px; }
.bar-row .nm{ color:var(--ink-soft); overflow:hidden; text-overflow:ellipsis;
  white-space:nowrap; }
/* فلکس، نه بلاک: در راست‌چین جای شروعِ میله باید بدون ابهام سمتِ راست
   باشد — میله از راست رشد می‌کند، هم‌جهت با خواندن. */
.bar-track{ display:flex; justify-content:flex-start; height:16px;
  background:var(--bar-soft); border-radius:5px; overflow:hidden; }
.bar-fill{ display:block; height:100%; flex:none; background:var(--bar); border-radius:5px;
  transition:width .5s cubic-bezier(.2,.8,.3,1); }
.bar-row .v{ color:var(--ink); font-weight:600; font-variant-numeric:tabular-nums;
  min-width:56px; text-align:left; direction:ltr; }

/* ستون‌های روزانه */
.cols{ display:flex; align-items:flex-end; gap:2px; height:104px;
  padding-bottom:2px; border-bottom:1px solid var(--line); }
.col{ flex:1; min-width:3px; background:var(--bar); border-radius:3px 3px 0 0;
  min-height:2px; transition:opacity .15s; }
.col.zero{ background:var(--line); }
.col:hover{ opacity:.65; }
.cols-x{ display:flex; justify-content:space-between; font-size:11px;
  color:var(--ink-faint); margin-top:7px; }

.chart-empty{ color:var(--ink-faint); font-size:12.5px; text-align:center;
  padding:26px 10px; }
.chip{ display:inline-flex; align-items:center; gap:5px; font-size:11px;
  padding:2px 9px; border-radius:999px; font-weight:600; white-space:nowrap; }
.chip-ok{ background:var(--green-bg); color:var(--green-ink); }
.chip-warn{ background:var(--amber-bg); color:var(--amber-ink); }
.chip-bad{ background:var(--red-bg); color:var(--red-ink); }
.chip-none{ background:var(--line-soft); color:var(--ink-faint); }

/* ---------- سیاهه ---------- */
.tbl{ overflow-x:auto; border:1px solid var(--line-soft); border-radius:var(--r); }
table{ width:100%; border-collapse:collapse; font-size:12px; }
th,td{ padding:9px 11px; border-bottom:1px solid var(--line-soft); text-align:right; }
tbody tr:last-child td{ border-bottom:0; }
tbody tr:hover{ background:var(--paper-2); }
th{ color:var(--ink-faint); font-weight:600; font-size:11px;
  background:var(--paper-2); position:sticky; top:0; }
td.ltr{ direction:ltr; text-align:left; color:var(--ink-soft); }

/* ---------- پنجره ---------- */
.ov{ position:fixed; inset:0; z-index:80; display:flex; align-items:center;
  justify-content:center; padding:18px;
  background:rgba(8,22,38,.55); backdrop-filter:blur(3px);
  animation:fade .2s ease; }
@keyframes fade{ from{ opacity:0; } to{ opacity:1; } }
.ov[hidden]{ display:none; }
.ov-box{ background:var(--white); border:1px solid var(--line);
  border-radius:var(--r-lg); box-shadow:var(--sh-3); padding:24px;
  width:100%; max-width:560px; max-height:88vh; overflow:auto;
  animation:rise .28s cubic-bezier(.2,.8,.3,1); }
.ov-box h2{ margin:0 0 5px; font-size:16px;
  position:sticky; top:-24px; background:var(--white); padding:2px 0 6px;
  z-index:2; }
/* کفِ پنجره می‌چسبد: در فهرست‌های بلند، «ذخیره» همیشه دیده می‌شود. */
.ov-acts{ display:flex; gap:9px; margin-top:20px;
  border-top:1px solid var(--line-soft); padding-top:16px;
  position:sticky; bottom:-24px; background:var(--white); padding-bottom:4px; }
#loading{ position:fixed; inset:0; background:var(--paper); z-index:95;
  display:flex; align-items:center; justify-content:center;
  color:var(--ink-faint); font-size:13px; }

/* ---------- موبایل ---------- */
@media (max-width:560px){
  .wrap{ padding-bottom:50px; }
  .top h1{ font-size:17px; }
  .plist{ grid-template-columns:1fr; }
  .tabs{ width:100%; }
  .tabs button{ flex:1; padding:8px 10px; font-size:12px; }
  .ov-box{ padding:18px; }
  .meta .m span:first-child{ min-width:96px; }
}
</style>
</head>
<body>

<div id="loading">در حال بارگذاری…</div>

<div id="gate" hidden>
  <form class="gate-card" id="gateForm">
    <img class="gate-mark" src="/icon-sl.3.png" alt="SLTech" width="68" height="68">
    <div class="brandword">SLTech</div>
    <h1 id="gateTitle">ورود به کارتابل</h1>
    <p id="gateSub">نام کاربری و رمزتان را بزنید تا وارد کارتابل خودتان شوید.</p>
    <input type="text" id="gateCode" placeholder="کد تلگرام" autocomplete="off" dir="ltr" hidden>
    <input type="text" id="gateUser" placeholder="نام کاربری" autocomplete="username"
           dir="ltr" spellcheck="false" autocapitalize="off">
    <input type="password" id="gatePass" placeholder="رمز" autocomplete="current-password">
    <input type="password" id="gatePass2" placeholder="تکرار رمز" autocomplete="new-password" hidden>
    <button type="submit" id="gateBtn">ورود</button>
    <button type="button" class="btn" id="gateCodeBtn" style="width:100%; margin-top:8px;" hidden>
      فرستادن کد به تلگرام</button>
    <div class="gate-err" id="gateErr"></div>
    <div class="gate-note" id="gateNote"></div>
    <button type="button" class="gate-forgot" id="gateForgot">رمزم را فراموش کرده‌ام</button>
  </form>
</div>

<div class="wrap" id="app" hidden>
  <div class="topbar"><div class="top">
    <img class="mark" src="/icon-sl.3.png" alt="SLTech" width="42" height="42">
    <div class="titles">
      <h1>پنل کارتابل‌ها</h1>
      <p class="sub2" id="topSub"></p>
    </div>
    <button class="icon-btn" id="themeBtn" title="تم روز و شب">🌙</button>
    <button class="btn" id="logoutBtn">خروج</button>
  </div></div>

  <div class="stats" id="stats"></div>

  <div class="tabs">
    <button data-tab="list" class="active">کارتابل‌ها</button>
    <button data-tab="report">گزارش</button>
    <button data-tab="new">کارتابل تازه</button>
    <button data-tab="site">تنظیمات سایت</button>
    <button data-tab="keys">کلیدها و رمز ادمین</button>
    <button data-tab="log">سیاههٔ کارها</button>
  </div>

  <div id="msg"></div>

  <section id="tab-list">
    <div class="findbar">
      <input type="search" id="find" placeholder="جستجو در نام یا آدرس کارتابل…"
        autocomplete="off" spellcheck="false">
      <span class="n" id="findCount"></span>
    </div>
    <div class="plist" id="plist"></div>
  </section>

  <section id="tab-report" hidden>
    <div class="panel">
      <h2>ترکیب کارتابل‌ها</h2>
      <p class="sub">هر کارتابل از کدام نوع است.</p>
      <div id="rMix"></div>
    </div>

    <div class="grid2">
      <div class="panel">
        <h2>حجم داده</h2>
        <p class="sub">اندازهٔ چیزی که هر کارتابل روی سرور دارد — خودِ داده خوانده نمی‌شود، فقط اندازه‌اش.</p>
        <div id="rSize"></div>
      </div>
      <div class="panel">
        <h2>کارهای این پنل</h2>
        <p class="sub">سی روز گذشته.</p>
        <div id="rAct"></div>
      </div>
    </div>

    <div class="panel">
      <h2>وضعیت هر کارتابل</h2>
      <p class="sub">همان چیزی که نمودارها نشان می‌دهند، عدد به عدد.</p>
      <div id="rTable"></div>
    </div>
  </section>

  <section id="tab-new" hidden>
    <div class="panel">
      <h2>ساختن کارتابل تازه</h2>
      <p class="sub">نامِ شخص، آدرسی که کارتابلش روی آن باز می‌شود، و نام کاربری‌ای که
        با آن از صفحهٔ ورود وارد می‌شود. رمزِ ورود همین‌جا یک‌بار نشان داده می‌شود و
        بعد دیگر هیچ‌جا نیست — همان لحظه جایی یادداشتش کنید.</p>
      <div class="kinds" id="nKinds"></div>
      <div id="nViewsWrap" hidden>
        <p class="sub" style="margin:0 0 9px;">این شغل معمولاً به این بخش‌ها کار دارد —
          هر کدام را نخواستید، همین‌جا تیکش را بردارید.</p>
        <div class="feats" id="nViews"></div>
      </div>
      <div class="row">
        <div class="fld"><label>نام شخص</label><input type="text" id="nName" placeholder="مثلاً: نسرین" autocomplete="off"></div>
        <div class="fld"><label>آدرس کارتابل</label><input type="text" id="nSlug" placeholder="nasrin" dir="ltr" autocomplete="off" spellcheck="false"></div>
        <div class="fld"><label>نام کاربری (خالی = مثل آدرس)</label>
          <input type="text" id="nUser" placeholder="nasrin" dir="ltr" autocomplete="off" spellcheck="false"></div>
        <div class="fld"><label>چک‌لیست آماده (اختیاری)</label><select id="nJob"></select></div>
        <div class="fld"><label>رمز ورود (خالی = خودکار)</label>
          <input type="text" id="nPass" placeholder="خودش می‌سازد" dir="ltr" autocomplete="off"></div>
      </div>
      <input type="hidden" id="nKind" value="gen">
      <div class="hint" id="nPreview"></div>
      <div style="margin-top:12px;"><button class="btn btn-main" id="nCreate">ساختن کارتابل</button></div>
    </div>
  </section>

  <section id="tab-site" hidden>
    <div class="panel">
      <h2>راه‌های تماس</h2>
      <p class="sub">همین‌ها روی صفحهٔ اصلیِ سایت می‌نشینند. هرکدام را خالی بگذارید،
        از صفحه هم برداشته می‌شود.</p>
      <div class="row">
        <div class="fld"><label>تلگرام (نام کاربری یا لینک)</label>
          <input type="text" id="stTelegram" dir="ltr" placeholder="@sltech_ir" autocomplete="off"></div>
        <div class="fld"><label>بله (نام کاربری یا لینک)</label>
          <input type="text" id="stBale" dir="ltr" placeholder="@sltech_ir" autocomplete="off"></div>
      </div>
      <div class="row">
        <div class="fld"><label>تلفن</label>
          <input type="text" id="stPhone" dir="ltr" placeholder="۰۲۱…" autocomplete="off"></div>
        <div class="fld"><label>ایمیل</label>
          <input type="text" id="stEmail" dir="ltr" placeholder="info@sltech.ir" autocomplete="off"></div>
      </div>
    </div>

    <div class="panel">
      <h2>پرداخت</h2>
      <p class="sub">شمارهٔ کارتی که برای خریدِ کارتابل اعلام می‌شود.</p>
      <div class="row">
        <div class="fld"><label>شمارهٔ کارت (۱۶ رقم)</label>
          <input type="text" id="stCard" dir="ltr" inputmode="numeric" placeholder="6037…" autocomplete="off"></div>
        <div class="fld"><label>به نام</label>
          <input type="text" id="stCardName" placeholder="نام صاحب کارت" autocomplete="off"></div>
      </div>
    </div>

    <div class="panel">
      <h2>پلن‌ها و قیمت</h2>
      <p class="sub">تا شش پلن. «مدت» همان تعداد روزی است که کارتابل باز می‌ماند —
        صفر یعنی بی‌مهلت. پلنی که نامش خالی باشد ذخیره نمی‌شود.</p>
      <div id="stPlans"></div>
      <div style="margin-top:10px;"><button class="btn" id="stAddPlan">＋ پلن تازه</button></div>
    </div>

    <div class="panel">
      <h2>ربات‌ها</h2>
      <p class="sub">پشتیبان‌ها و پیام‌ها به هر دو ربات می‌روند. توکن یک‌طرفه ذخیره
        می‌شود: بعد از ذخیره دیگر نشان داده نمی‌شود و فقط چهار رقمِ آخرش را می‌بینید.
        برای برداشتنِ یک توکن، به‌جایش یک خط تیره <code>-</code> بنویسید.</p>
      <div class="row">
        <div class="fld"><label>توکن تلگرام <span id="stTgHas" class="hint2"></span></label>
          <input type="password" id="stTgToken" dir="ltr" autocomplete="off" placeholder="خالی = دست نخورد"></div>
        <div class="fld"><label>شناسهٔ گفتگوی تلگرام</label>
          <input type="text" id="stTgChat" dir="ltr" autocomplete="off" placeholder="مثلاً ۱۲۳۴۵۶۷۸"></div>
        <div><button class="btn" id="stTgTest">پیام آزمایشی</button></div>
      </div>
      <div class="row" style="margin-top:8px;">
        <div class="fld"><label>توکن بله <span id="stBaleHas" class="hint2"></span></label>
          <input type="password" id="stBaleToken" dir="ltr" autocomplete="off" placeholder="خالی = دست نخورد"></div>
        <div class="fld"><label>شناسهٔ گفتگوی بله</label>
          <input type="text" id="stBaleChat" dir="ltr" autocomplete="off" placeholder="مثلاً ۱۲۳۴۵۶۷۸"></div>
        <div><button class="btn" id="stBaleTest">پیام آزمایشی</button></div>
      </div>
      <div class="hint">شناسهٔ گفتگو را از خودِ ربات می‌گیرید: یک پیام به ربات بدهید و
        بعد «پیام آزمایشی» را بزنید تا مطمئن شوید به همان‌جا می‌رسد.</div>
    </div>

    <div style="margin:4px 0 30px;"><button class="btn btn-main" id="stSave">ذخیرهٔ تنظیمات</button></div>
  </section>

  <section id="tab-keys" hidden>
    <div class="panel">
      <h2>نام کاربری ادمین</h2>
      <p class="sub">با همین نام از صفحهٔ ورودِ مشترک (<b dir="ltr" class="host-here">/login</b>)
        وارد این پنل می‌شوید — همان صفحه‌ای که کاربرها هم از آن وارد کارتابلِ خودشان می‌شوند.</p>
      <div class="row">
        <div class="fld"><label>نام کاربری</label>
          <input type="text" id="auName" dir="ltr" autocomplete="off" spellcheck="false"></div>
        <div><button class="btn btn-main" id="auGo">ذخیره</button></div>
      </div>
    </div>

    <div class="panel">
      <h2>رمز ادمین</h2>
      <p class="sub">با عوض شدنش همهٔ نشست‌های باز — روی هر دستگاهی — بسته می‌شوند.</p>
      <div class="row">
        <div class="fld"><label>رمز فعلی</label><input type="password" id="apCur"></div>
        <div class="fld"><label>رمز تازه (دست‌کم ۱۰ حرف)</label><input type="password" id="apNew"></div>
        <div class="fld"><label>تکرار</label><input type="password" id="apNew2"></div>
        <div><button class="btn btn-main" id="apGo">عوض کن</button></div>
      </div>
    </div>

    <div class="panel">
      <h2>کلید اضطراری دیتای شخصی</h2>
      <p class="sub">دیتای شخصیِ هر کاربر با رمزِ خودش قفل است و سرور کلیدش را ندارد.
        این کلید همان تورِ اضطراری است: مرورگرِ کاربر رمزش را با «کلید عمومی» می‌پیچد،
        و باز کردنش <b>رمزِ ادمینِ خودتان</b> را می‌خواهد — همان رمزی که با آن وارد
        این پنل شدید. رمز فقط در همین مرورگر تایپ می‌شود و برای باز کردنِ کلید
        هیچ‌وقت به سرور نمی‌رسد.</p>
      <div id="escrowState" class="hint"></div>
      <div class="row" style="margin-top:10px;">
        <div class="fld"><label>رمز ادمین</label>
          <input type="password" id="ekPass" autocomplete="current-password"></div>
        <div><button class="btn btn-main" id="ekGo">ساختن کلید</button></div>
      </div>
      <div class="hint">⚠️ از این به بعد رمزِ ادمین دو کار می‌کند: هم درِ این پنل را باز
        می‌کند، هم این کلید را. وقتی رمزِ ادمین را عوض کنید، کلید همان‌جا خودش با
        رمزِ تازه دوباره پیچیده می‌شود. ساختنِ کلیدِ تازه اما بسته‌های قدیمی را باز
        نمی‌کند — ولی دسترسی‌تان خودش برمی‌گردد: دفعهٔ بعد که هر کاربر صندوقش را باز
        کند، مرورگرش پاکتِ تازه می‌سپارد. دیتای شخصیِ کاربرها در هیچ حالتی از دست
        نمی‌رود؛ رمزِ خودشان همیشه بازش می‌کند.</div>
    </div>

    <div class="panel">
      <h2>کلید با رمز ادمین باز نمی‌شود؟</h2>
      <p class="sub">کلیدهایی که پیش از یکی‌شدنِ رمزها ساخته شده‌اند با «عبارت عبور ادمین»ِ
        جداگانهٔ قدیمی قفل‌اند، نه با رمزِ ورود. همان عبارت را همین یک‌بار این‌جا بزنید تا
        کلید به رمزِ ادمین منتقل شود. <b>جفت‌کلید عوض نمی‌شود</b>، پس رمزهای شخصیِ
        کاربرهای فعلی از دست نمی‌رود — برعکسِ «ساختن کلید تازه».</p>
      <div class="row">
        <div class="fld"><label>رمز ادمین (همان رمزِ ورود)</label>
          <input type="password" id="mgAdmin" autocomplete="current-password"></div>
        <div class="fld"><label>عبارت عبورِ قبلی</label>
          <input type="password" id="mgOld" autocomplete="off"></div>
        <div><button class="btn btn-main" id="mgGo">انتقال بده</button></div>
      </div>
      <div class="hint" id="mgNote"></div>
    </div>
  </section>

  <section id="tab-log" hidden>
    <div class="panel">
      <h2>سیاههٔ کارها</h2>
      <p class="sub">صد کارِ آخر.</p>
      <div id="logBody"></div>
    </div>
  </section>
</div>

<div class="ov" id="ov" hidden><div class="ov-box" id="ovBox"></div></div>

<script>
/* دامنه را از خودِ صفحه می‌خوانیم، نه از متنِ ثابت. این‌طور اگر دامنه
   عوض شود — یا پنل روی دامنهٔ دیگری هم بالا بیاید — هر آدرسی که به
   کاربر نشان داده یا رونوشت می‌شود خودش درست است.

   جایش بالای همه‌چیز است چون «const» مثل «function» بالا نمی‌رود:
   پایین‌تر که بنویسی، کدِ بالاتر موقع اجرا به آن نمی‌رسد. */
const HOST = location.host;
const ORIGIN = location.origin;

/* ==========================================================================
   پنل ادمینِ کارتابل‌ها
   ========================================================================== */

const API = "/api/admin.planer";
let DATA = { items: [], kinds: [], jobs: [], vaultTypes: [], escrowReady: false };

async function api(path, opt = {}){
  const res = await fetch(API + path, Object.assign({
    credentials: "same-origin",
    headers: { "Content-Type": "application/json" }
  }, opt));
  let data = null;
  try{ data = await res.json(); }catch(e){}
  return { ok: res.ok, status: res.status, data: data || {} };
}

const esc = t => String(t == null ? "" : t)
  .replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")
  .replace(/"/g,"&quot;").replace(/'/g,"&#39;");

function faDateTime(ms){
  if(!ms) return "—";
  try{
    const d = new Date(Number(ms));
    return new Intl.DateTimeFormat("fa-IR-u-ca-persian",{year:"numeric",month:"long",day:"numeric"}).format(d)
      + " — " + new Intl.DateTimeFormat("fa-IR",{hour:"2-digit",minute:"2-digit",hour12:false}).format(d);
  }catch(e){ return "—"; }
}

/* هر پیام شمارهٔ خودش را دارد: وگرنه تایمرِ پیامِ قبلی پیامِ بعدی را
   پاک می‌کرد و کار انجام‌شده بی‌جواب به نظر می‌رسید. */
let msgSeq = 0;
function say(text, bad){
  const el = document.getElementById("msg");
  const mine = ++msgSeq;
  el.innerHTML = `<div class="msg ${bad?'msg-bad':'msg-ok'}">${text}</div>`;
  el.querySelectorAll("[data-copy]").forEach(b=> b.onclick = ()=> copyText(b));
  if(!bad) setTimeout(()=>{ if(msgSeq === mine) el.innerHTML = ""; }, 12000);
  window.scrollTo({top:0, behavior:"smooth"});
}

/* ---------- ابزارِ رمزنگاری ---------- */
const b64 = buf => btoa(String.fromCharCode(...new Uint8Array(buf)));
const unb64 = s => Uint8Array.from(atob(s), c => c.charCodeAt(0));

async function keyFrom(pass, salt, uses){
  const base = await crypto.subtle.importKey("raw", new TextEncoder().encode(pass),
    "PBKDF2", false, ["deriveKey"]);
  return crypto.subtle.deriveKey({ name:"PBKDF2", salt, iterations:150000, hash:"SHA-256" },
    base, { name:"AES-GCM", length:256 }, false, uses);
}

/* جاهایی که دامنه در خودِ HTML نوشته شده بود، همین‌جا پر می‌شوند. */
document.querySelectorAll(".host-here").forEach(el=>{ el.textContent = HOST + el.textContent; });
const _topSub = document.getElementById("topSub");
if(_topSub) _topSub.textContent = HOST;

/* ---------- قفل ورود ---------- */
let needsSetup = false;
let ADMIN_USER = "admin";

(async function gate(){
  const me = await api("/me");
  document.getElementById("loading").style.display = "none";
  if(me.ok && me.data.in){ ADMIN_USER = me.data.user || "admin"; openApp(me.data.lastLogin); return; }
  needsSetup = !!(me.data && me.data.needsSetup);
  if(needsSetup){
    document.getElementById("gateTitle").textContent = "اولین بار: نام کاربری و رمز ادمین را بگذارید";
    document.getElementById("gateSub").innerHTML =
      "تا وقتی رمزی نیست این پنل بی‌صاحب است، پس رمزِ اول با کدی گذاشته می‌شود " +
      "که فقط به همان گفتگوی تلگرامیِ پشتیبان‌ها می‌رود.<br>" +
      "اول کد را بگیرید، بعد کد و رمزِ تازه را این‌جا بزنید.";
    document.getElementById("gateUser").placeholder = "نام کاربریِ ادمین (پیش‌فرض admin)";
    document.getElementById("gateUser").setAttribute("autocomplete","off");
    document.getElementById("gatePass").placeholder = "رمز تازه (دست‌کم ۱۰ حرف)";
    document.getElementById("gatePass").setAttribute("autocomplete","new-password");
    document.getElementById("gatePass2").hidden = false;
    document.getElementById("gateCode").hidden = false;
    document.getElementById("gateCodeBtn").hidden = false;
    document.getElementById("gateBtn").textContent = "بگذار و وارد شو";
    document.getElementById("gateForgot").hidden = true;
    document.getElementById("gateCodeBtn").addEventListener("click", async ()=>{
      const b = document.getElementById("gateCodeBtn");
      const note = document.getElementById("gateNote");
      b.disabled = true; note.textContent = "در حال فرستادن…";
      const r = await api("/setup-code", { method:"POST", body:"{}" });
      note.textContent = r.ok
        ? "کد به تلگرام رفت. تا ۱۵ دقیقه معتبر است."
        : (r.data.error || "نشد.");
      b.disabled = false;
    });
  }
  document.getElementById("gate").hidden = false;
  setTimeout(()=>{ try{ document.getElementById("gateUser").focus(); }catch(e){} }, 60);

  /* رمزِ تازه فقط به تلگرامِ پشتیبان‌ها می‌رود، نه به این صفحه. */
  document.getElementById("gateForgot").addEventListener("click", async ()=>{
    const b = document.getElementById("gateForgot");
    const err = document.getElementById("gateErr");
    const note = document.getElementById("gateNote");
    const user = document.getElementById("gateUser").value.trim().toLowerCase();
    err.textContent = ""; note.textContent = "";
    if(!user){ err.textContent = "اول نام کاربری را بنویسید."; return; }
    if(!confirm("رمزِ تازه ساخته می‌شود و به تلگرام می‌رود. رمزِ فعلی از کار می‌افتد.\n\nادامه؟")) return;
    b.disabled = true; note.textContent = "در حال فرستادن…";
    const r = await api("/forgot", { method:"POST", body: JSON.stringify({ user }) });
    note.textContent = "";
    if(r.ok) note.textContent = "رمزِ تازه به تلگرام رفت. از همان‌جا بردارید و این‌جا بزنید.";
    else err.textContent = r.data.error || "نشد.";
    b.disabled = false;
  });
})();

document.getElementById("gateForm").addEventListener("submit", async (e)=>{
  e.preventDefault();
  const user = document.getElementById("gateUser").value.trim();
  const pass = document.getElementById("gatePass").value;
  const btn = document.getElementById("gateBtn");
  const err = document.getElementById("gateErr");
  err.textContent = "";
  if(!pass) return;
  if(needsSetup){
    if(pass.length < 10){ err.textContent = "رمز ادمین دست‌کم ۱۰ حرف باشد."; return; }
    if(pass !== document.getElementById("gatePass2").value){ err.textContent = "تکرار رمز نمی‌خواند."; return; }
    if(!document.getElementById("gateCode").value.trim()){
      err.textContent = "اول کد را از تلگرام بگیرید و این‌جا بزنید."; return; }
  } else if(!user){
    err.textContent = "نام کاربری را بنویسید."; return;
  }
  btn.disabled = true; btn.textContent = "…";
  /* یک فرم، دو مقصد: «signin» هم ادمین را می‌شناسد هم کاربرها را و
     خودش می‌گوید کجا باید رفت. */
  const r = await api(needsSetup ? "/setup" : "/signin",
    { method:"POST", body: JSON.stringify({ user: user, password: pass, remember: true,
      code: document.getElementById("gateCode").value.trim() }) });
  if(r.ok){
    const prev = Number(r.data.lastLogin || 0);
    const note = document.getElementById("gateNote");
    /* کاربرِ عادی به کارتابلِ خودش می‌رود؛ ادمین همین صفحه را
       می‌گیرد، چون پنلش همین‌جاست. */
    if(r.data.go){
      btn.textContent = "در حال باز کردن کارتابل…";
      note.innerHTML = "خوش آمدید <b>" + esc(r.data.name || "") + "</b>" +
        (prev > 0 ? "<br>آخرین ورودِ قبلی شما: <b>" + esc(faDateTime(prev)) + "</b>" : "");
      setTimeout(()=>{ location.href = r.data.go; }, prev > 0 ? 1800 : 350);
      return;
    }
    if(prev > 0){
      note.innerHTML = "آخرین ورودِ شما به این پنل:<br><b>" + esc(faDateTime(prev)) + "</b>";
      btn.textContent = "در حال باز کردن…";
      setTimeout(()=> location.reload(), 2000);
    } else location.reload();
    return;
  }
  err.textContent = r.data.error || "نشد.";
  btn.disabled = false; btn.textContent = needsSetup ? "بگذار و وارد شو" : "ورود";
});

/* ---------- برنامه ---------- */
function openApp(lastLogin){
  document.getElementById("gate").hidden = true;
  document.getElementById("app").hidden = false;
  if(lastLogin) say("آخرین ورودِ قبلی شما: <b>" + esc(faDateTime(lastLogin)) + "</b>");
  setupTheme();
  setupTabs();
  setupNew();
  setupKeys();
  setupSite();
  loadPlanners();
}

function setupTheme(){
  const btn = document.getElementById("themeBtn");
  const cur = ()=> document.documentElement.getAttribute("data-theme")
    || (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
  const paint = ()=> btn.textContent = cur()==="dark" ? "☀️" : "🌙";
  paint();
  btn.addEventListener("click", ()=>{
    const next = cur()==="dark" ? "light" : "dark";
    document.documentElement.setAttribute("data-theme", next);
    try{ localStorage.setItem("admin-planer:theme", next); }catch(e){}
    paint();
  });
}

function setupTabs(){
  document.querySelectorAll(".tabs button").forEach(b=>{
    b.addEventListener("click", ()=>{
      document.querySelectorAll(".tabs button").forEach(x=> x.classList.toggle("active", x===b));
      /* فهرست از خودِ دکمه‌ها می‌آید، نه از یک آرایهٔ دستی — وگرنه هر
         سربرگِ تازه یادش می‌رفت و بخشش باز نمی‌شد. */
      document.querySelectorAll(".tabs button").forEach(x=>{
        const sec = document.getElementById("tab-" + x.dataset.tab);
        if(sec) sec.hidden = (x !== b);
      });
      if(b.dataset.tab === "log") loadLog();
      if(b.dataset.tab === "report") loadReport();
    });
  });
  const fx = document.getElementById("find");
  if(fx) fx.addEventListener("input", ()=>{ findText = fx.value; renderPlanners(); });
  document.getElementById("logoutBtn").addEventListener("click", async ()=>{
    await api("/logout", { method:"POST" });
    location.reload();
  });
}

/* ---------- فهرست ---------- */
async function loadPlanners(){
  const r = await api("/planners");
  if(!r.ok){ say(r.data.error || "فهرست نیامد.", true); return; }
  DATA = r.data;
  fillSelect("nJob", [{id:"",label:"— بدون چک‌لیست آماده —"}].concat(DATA.jobs));
  renderKindPicker();
  renderNewViews();
  renderPlanners();
  renderEscrowState();
}

function fillSelect(id, items){
  const el = document.getElementById(id);
  if(!el || el.options.length) return;
  el.innerHTML = items.map(i=>`<option value="${esc(i.id)}">${esc(i.label)}</option>`).join("");
}

function kindLabel(k){ const f = DATA.kinds.find(x=>x.id===k); return f ? f.label : k; }
function kindIcon(k){ const f = DATA.kinds.find(x=>x.id===k); return (f && f.icon) || "🗂"; }
function featLabel(id){
  if(id.startsWith("view:")){
    const v = Object.values(DATA.views||{}).flat().find(x=>x.id===id.slice(5));
    return v ? v.label : id.slice(5);
  }
  const f = (DATA.features||[]).find(x=>x.id===id);
  return f ? f.label : id;
}

/* مهلتِ کارتابل: چند روز مانده، یا کِی تمام شد. */
function daysLeft(until){
  if(!until) return null;
  /* همان گردکردنی که کارتابل‌ها هم می‌کنند، تا دو جا دو عدد نگویند. */
  if(until <= Date.now()) return 0;
  return Math.max(1, Math.round((until - Date.now()) / 86400000));
}
function untilText(p){
  const d = daysLeft(p.until);
  if(d === null) return "بی‌مهلت";
  if(d <= 0) return "تمام شد — " + esc(faDateTime(p.until));
  return "‏" + fa(d) + " روز مانده";
}

function renderStats(){
  const n = DATA.items.length;
  const off = DATA.items.filter(p=>p.closed).length;
  const keys = DATA.items.filter(p=>p.hasEscrow).length;
  const tile = (cls, ic, v, l) =>
    `<div class="stat ${cls}"><div class="si">${ic}</div>
      <div class="sv"><div class="n">${v}</div><div class="l">${l}</div></div></div>`;
  document.getElementById("stats").innerHTML =
    tile("s-all", "🗂", fa(n), "کارتابل") +
    tile("s-on",  "✓",  fa(n-off), "فعال") +
    tile("s-off", "⏸",  fa(off), "غیرفعال") +
    tile("s-key", DATA.escrowReady ? "🔑" : "⚠️",
      DATA.escrowReady ? "ساخته شده" : "ساخته نشده",
      DATA.escrowReady
        ? "کلید اضطراری — رمز " + fa(keys) + " نفر نزد شماست"
        : "کلید اضطراری هنوز نیست");
}

/* عددهای فارسی — همان چیزی که در کارتابل‌ها هم دیده می‌شود */
function fa(n){ return String(n).replace(/[0-9]/g, d=>"۰۱۲۳۴۵۶۷۸۹"[d]); }
function jobLabel(j){ const f = DATA.jobs.find(x=>x.id===j); return f ? f.label : ""; }

let findText = "";

function renderPlanners(){
  const wrap = document.getElementById("plist");
  const q = findText.trim().toLowerCase();
  const items = q
    ? DATA.items.filter(p => (p.name + " " + p.slug + " " + (p.user||"")).toLowerCase().includes(q))
    : DATA.items;
  const cnt = document.getElementById("findCount");
  if(cnt) cnt.textContent = q
    ? fa(items.length) + " از " + fa(DATA.items.length)
    : fa(DATA.items.length) + " کارتابل";
  wrap.innerHTML = items.map(p=>`
    <div class="pcard k-${esc(p.kind)}${p.closed?' off':''}">
      <div class="pc-head">
        <div class="pc-ic">${kindIcon(p.kind)}</div>
        <div style="min-width:0;flex:1;">
          <h3>${esc(p.name)}
            <span class="pill pill-${esc(p.kind)}">${esc(kindLabel(p.kind))}</span>
            ${p.core ? `<span class="pill pill-builtin">اصلی</span>` : ``}
            ${p.disabled ? `<span class="pill pill-off">غیرفعال</span>`
              : (p.until && daysLeft(p.until) <= 0)
                ? `<span class="pill pill-off">مهلت تمام</span>`
                : (p.until && daysLeft(p.until) <= 7)
                  ? `<span class="pill pill-builtin">${fa(daysLeft(p.until))} روز مانده</span>` : ``}</h3>
          <div class="urlrow">
            <a class="url" href="${esc(p.url)}" target="_blank" rel="noopener">${esc(HOST)}${esc(p.url)}</a>
            <button class="copy" data-copy="${esc(ORIGIN)}${esc(p.url)}"
              title="رونوشتِ آدرس">⧉</button>
          </div>
        </div>
      </div>
      <div class="meta">
        <div class="m"><span>نام کاربری</span><span dir="ltr">${esc(p.user || p.slug)}
          <button class="copy" data-copy="${esc(p.user || p.slug)}" title="رونوشتِ نام کاربری">⧉</button></span></div>
        <div class="m"><span>چک‌لیست آماده</span><span>${p.job ? esc(jobLabel(p.job)) : "—"}</span></div>
        <div class="m"><span>بخش‌های شخصی</span><span title="${esc((p.vault||[]).map(v=>v.title).join("، "))}">${
          esc((p.vault||[]).map(v=>v.title).join("، ") || "—")}</span></div>
        <div class="m"><span>آخرین ورود</span><span>${esc(faDateTime(p.lastLogin))}</span></div>
        <div class="m"><span>رمز شخصی نزد شما</span><span>${p.hasEscrow ? "بله" : "نه"}</span></div>
        <div class="m${p.until && daysLeft(p.until) <= 7 ? " warn" : ""}"><span>مهلت</span><span>${
          untilText(p)}</span></div>
        <div class="m"><span>بخش‌های کارتابل</span><span>${
          ((DATA.views||{})[p.kind]||[]).length
            ? ((p.views||[]).length
                ? esc(((DATA.views||{})[p.kind]||[])
                    .filter(v=> (p.views||[]).includes(v.id)).map(v=>v.label).join("، "))
                : "هیچ‌کدام")
            : "—"}</span></div>
        <div class="m"><span>دسترسی‌های بسته</span><span>${(p.off||[]).length
          ? esc((p.off||[]).map(featLabel).join("، ")) : "—"}</span></div>
      </div>
      <div class="acts">
        <button class="btn" data-edit="${esc(p.slug)}">ویرایش</button>
        <button class="btn" data-pw="${esc(p.slug)}">رمز ورود</button>
        <button class="btn" data-vpw="${esc(p.slug)}" title="رمز دیتای شخصی">رمز شخصی</button>
        ${p.builtin ? `` : `<button class="btn ${p.closed?'btn-on':'btn-off'}" data-off="${esc(p.slug)}">${
          p.closed ? "فعال کن" : "غیرفعال"}</button>`}
        ${p.builtin || p.core ? `` : `<button class="btn btn-danger btn-ic" data-del="${esc(p.slug)}" title="حذف کامل این کارتابل">🗑</button>`}
      </div>
    </div>`).join("") || `<div class="panel" style="text-align:center;color:var(--ink-faint);">
      ${q ? "چیزی با «" + esc(findText) + "» پیدا نشد."
          : "هنوز کارتابلی نیست. از سربرگ «کارتابل تازه» شروع کنید."}</div>`;
  renderStats();
  wrap.querySelectorAll("[data-copy]").forEach(b=> b.onclick = ()=> copyText(b));

  wrap.querySelectorAll("[data-edit]").forEach(b=> b.onclick = ()=> openEdit(b.dataset.edit));
  wrap.querySelectorAll("[data-pw]").forEach(b=> b.onclick = ()=> resetLoginPassword(b.dataset.pw));
  wrap.querySelectorAll("[data-vpw]").forEach(b=> b.onclick = ()=> openVaultReset(b.dataset.vpw));
  wrap.querySelectorAll("[data-off]").forEach(b=> b.onclick = ()=> toggleState(b.dataset.off));
  wrap.querySelectorAll("[data-del]").forEach(b=> b.onclick = ()=> openDelete(b.dataset.del));
}

const find = slug => DATA.items.find(p=>p.slug===slug);

/* رونوشت — قبلاً باید آدرس یا رمز را دستی انتخاب می‌کردید. */
async function copyText(btn){
  const t = btn.dataset.copy;
  try{
    if(navigator.clipboard && window.isSecureContext) await navigator.clipboard.writeText(t);
    else {
      const ta = document.createElement("textarea");
      ta.value = t; ta.style.position = "fixed"; ta.style.opacity = "0";
      document.body.appendChild(ta); ta.select();
      document.execCommand("copy"); ta.remove();
    }
    const was = btn.textContent;
    btn.textContent = "✓"; btn.classList.add("done");
    setTimeout(()=>{ btn.textContent = was; btn.classList.remove("done"); }, 1400);
  }catch(e){ /* بعضی مرورگرها اجازه نمی‌دهند — همان متن روی صفحه هست */ }
}

/* ---------- پنجره ---------- */
function openOverlay(html){
  document.getElementById("ovBox").innerHTML = html;
  document.getElementById("ov").hidden = false;
}
function closeOverlay(){ document.getElementById("ov").hidden = true; }
document.getElementById("ov").addEventListener("click", e=>{
  if(e.target.id === "ov") closeOverlay();
});

/* ---------- ویرایش ---------- */
function sectionRow(sec){
  const types = DATA.vaultTypes.map(t=>
    `<option value="${esc(t.id)}" ${sec.type===t.id?"selected":""}>${esc(t.label)}</option>`).join("");
  return `<div class="secrow" data-sec>
    <select class="stype">${types}</select>
    <input class="stitle" type="text" value="${esc(sec.title||"")}"
      placeholder="عنوان بخش (لازم)" autocomplete="off">
    <input class="scols" type="text" value="${esc((sec.cols||[]).join("، "))}"
      placeholder="ستون‌ها با ، جدا شوند (فقط جدول دل‌خواه)">
    <input class="sid" type="hidden" value="${esc(sec.id||"")}">
    <button type="button" class="x" title="بردار">✕</button>
  </div>`;
}

function openEdit(slug){
  const p = find(slug);
  if(!p) return;
  const jobs = [{id:"",label:"— بدون چک‌لیست آماده —"}].concat(DATA.jobs);
  openOverlay(`
    <h2>ویرایش «${esc(p.name)}»</h2>
    <p class="sub">${p.builtin ? "این کارتابل هنوز در جدول نیست، پس فقط دیده می‌شود." : esc(HOST)+esc(p.url)}</p>
    <div class="row">
      <div class="fld"><label>نام</label><input type="text" id="eName" value="${esc(p.name)}"></div>
      <div class="fld"><label>نام کاربری</label>
        <input type="text" id="eUser" dir="ltr" autocomplete="off" spellcheck="false"
          value="${esc(p.user || p.slug)}" ${p.builtin ? "disabled" : ""}></div>
      <div class="fld"><label>مهلت (روز)</label>
        <input type="number" id="eDays" min="0" max="3650" dir="ltr" autocomplete="off"
          placeholder="${p.until ? esc(String(Math.max(0, daysLeft(p.until)))) : "بی‌مهلت"}"></div>
      <div class="fld"><label>شغل (چک‌لیست آماده)</label><select id="eJob">${
        jobs.map(j=>`<option value="${esc(j.id)}" ${p.job===j.id?"selected":""}>${esc(j.label)}</option>`).join("")
      }</select></div>
    </div>
    <p class="hint">${p.until
      ? "این کارتابل " + (daysLeft(p.until) > 0
          ? "تا " + esc(faDateTime(p.until)) + " باز است و بعدش خودش بسته می‌شود."
          : "مهلتش " + esc(faDateTime(p.until)) + " تمام شده و الان بسته است.") +
        " برای برداشتنِ مهلت، صفر بزنید."
      : "بی‌مهلت است. اگر عددی بزنید، از همین حالا شمرده می‌شود و سرِ روزِ آخر خودش بسته می‌شود."}</p>

    <p class="sub" style="margin-top:18px;">کاربر به کدام بخش‌ها دسترسی داشته باشد —
      تیکِ برداشته‌شده یعنی آن بخش برایش بسته است و نه می‌بیندش نه می‌تواند
      از راهِ دیگری بازش کند.</p>
    <div class="feats">${(DATA.features||[]).map(f=>`
      <label class="feat${(p.off||[]).includes(f.id) ? ' closed' : ''}">
        <input type="checkbox" data-feat="${esc(f.id)}" ${(p.off||[]).includes(f.id) ? "" : "checked"}>
        <span><span class="ft">${esc(f.label)}</span><br>
          <span class="fn">${esc(f.note||"")}</span></span>
      </label>`).join("")}</div>

    ${(((DATA.views||{})[p.kind])||[]).length ? `
    <p class="sub" style="margin-top:18px;">کدام بخش‌های خودِ کارتابل را ببیند —
      داشبورد، چک‌لیست، برنامهٔ روزانه، راهنما و تنظیمات همیشه هستند.</p>
    <div class="feats">${(((DATA.views||{})[p.kind])||[]).map(v=>`
      <label class="feat${(p.views||[]).includes(v.id) ? '' : ' closed'}">
        <input type="checkbox" data-view="${esc(v.id)}"
          ${(p.views||[]).includes(v.id) ? "checked" : ""}>
        <span><span class="ft">${esc(v.label)}</span></span>
      </label>`).join("")}</div>` : ``}

    <p class="sub" style="margin-top:18px;">بخش‌های «دیتای شخصی» — برداشتنِ یک بخش
      محتوایش را پاک نمی‌کند؛ فقط از چشمِ کاربر پنهان می‌شود و با برگرداندنش
      دوباره پیدا می‌شود.</p>
    <div id="eSecs">${(p.vault||[]).map(sectionRow).join("")}</div>
    <button type="button" class="btn" id="eAddSec">＋ بخش تازه</button>
    <div class="ov-acts">
      ${p.builtin ? "" : `<button class="btn btn-main" id="eSave">ذخیره</button>`}
      <button class="btn" id="eCancel">بستن</button>
    </div>
    <div class="gate-err" id="eErr"></div>`);

  const wire = ()=>{
    document.querySelectorAll("#eSecs .x").forEach(x=>
      x.onclick = ()=> { x.closest("[data-sec]").remove(); });
    document.querySelectorAll("#eSecs .stitle").forEach(i=>
      i.oninput = ()=>{ i.classList.remove("bad");
        document.getElementById("eErr").textContent = ""; });
  };
  wire();
  document.getElementById("eAddSec").onclick = ()=>{
    document.getElementById("eSecs").insertAdjacentHTML("beforeend",
      sectionRow({ id:"", type:"table", title:"", cols:[] }));
    wire();
    /* مکان‌نما می‌رود داخلِ عنوان، چون همان است که لازم است. */
    const rows = document.querySelectorAll("#eSecs [data-sec] .stitle");
    const last = rows[rows.length - 1];
    if(last){ last.focus(); last.scrollIntoView({ block:"nearest" }); }
  };
  document.querySelectorAll(".feat input").forEach(inp=>{
    inp.onchange = ()=> inp.closest(".feat").classList.toggle("closed", !inp.checked);
  });
  document.getElementById("eCancel").onclick = closeOverlay;
  const save = document.getElementById("eSave");
  if(save) save.onclick = async ()=>{
    const secs = [];
    const used = new Set();
    document.querySelectorAll("#eSecs .stitle").forEach(i=> i.classList.remove("bad"));
    for(const row of document.querySelectorAll("#eSecs [data-sec]")){
      const box = row.querySelector(".stitle");
      const title = box.value.trim();
      /* قبلاً ردیفِ بی‌عنوان بی‌صدا دور ریخته می‌شد و ادمین خیال می‌کرد
         بخش ساخته شده ولی «پریده». حالا می‌گوید کدام ردیف. */
      if(!title){
        box.classList.add("bad");
        box.focus();
        box.scrollIntoView({ block:"nearest" });
        document.getElementById("eErr").textContent =
          "برای هر بخش یک عنوان بنویسید — ردیفِ بی‌عنوان ذخیره نمی‌شود.";
        return;
      }
      const type = row.querySelector(".stype").value;
      let id = row.querySelector(".sid").value.trim();
      if(!id){
        /* شناسه فقط یک‌بار ساخته می‌شود و بعد دست نمی‌خورد: داده‌ی هر بخش
           زیر همین شناسه نشسته، پس عوض کردنش یعنی گم کردنِ محتوا. */
        id = "s" + Date.now().toString(36) + Math.random().toString(36).slice(2,6);
      }
      if(used.has(id)) continue;
      used.add(id);
      const cols = row.querySelector(".scols").value.split(/[،,]/).map(c=>c.trim()).filter(Boolean);
      secs.push(Object.assign({ id, type, title }, type==="table" && cols.length ? { cols } : {}));
    }
    if(!secs.length){ document.getElementById("eErr").textContent = "دست‌کم یک بخش باید بماند."; return; }
    save.disabled = true;
    const off = Array.from(document.querySelectorAll(".feat input[data-feat]"))
      .filter(i=> !i.checked).map(i=> i.dataset.feat);
    const views = Array.from(document.querySelectorAll(".feat input[data-view]"))
      .filter(i=> i.checked).map(i=> i.dataset.view);
    const r = await api("/planners/" + slug, { method:"PUT", body: JSON.stringify({
      name: document.getElementById("eName").value.trim(),
      user: document.getElementById("eUser").value.trim().toLowerCase(),
      job: document.getElementById("eJob").value,
      off, views, vault: secs,
      days: document.getElementById("eDays").value.trim() === ""
        ? undefined : Number(document.getElementById("eDays").value)
    })});
    save.disabled = false;
    if(!r.ok){ document.getElementById("eErr").textContent = r.data.error || "نشد."; return; }
    closeOverlay();
    say("ذخیره شد.");
    loadPlanners();
  };
}

/* ---------- رمز ورود ---------- */
async function resetLoginPassword(slug){
  const p = find(slug);
  if(!p) return;
  const typed = prompt(
    "رمز تازهٔ ورود برای «" + p.name + "».\n" +
    "خالی بگذارید تا خودش یک رمزِ قوی بسازد.\n\n" +
    "⚠️ با این کار هر دستگاهی که وارد مانده بیرون می‌افتد. " +
    "دیتای کارتابل و دیتای شخصی دست نمی‌خورند.");
  if(typed === null) return;
  const r = await api("/planners/" + slug + "/password",
    { method:"POST", body: JSON.stringify({ password: typed.trim() }) });
  if(!r.ok){ say(r.data.error || "نشد.", true); return; }
  say("رمزِ ورودِ «" + esc(p.name) + "» عوض شد:<br><code>" + esc(r.data.password) + "</code>" +
      ` <button class="copy" data-copy="${esc(r.data.password)}" title="رونوشت">⧉</button><br>` +
      "همین حالا جایی یادداشتش کنید — بعد از بستنِ این پیام دیگر هیچ‌جا نیست.");
  loadPlanners();
}

/* ---------- رمز دیتای شخصی ---------- */
function openVaultReset(slug){
  const p = find(slug);
  if(!p) return;
  if(!DATA.escrowReady){
    say("اول باید از بخش «کلیدها» کلیدِ اضطراری را بسازید. بدونش رمزِ دیتای شخصی " +
        "هیچ راهِ بازگشتی ندارد — و این عمدی است.", true);
    return;
  }
  if(!p.hasEscrow){
    say("«" + esc(p.name) + "» هنوز رمزِ دیتای شخصی‌اش را به کلیدِ ادمین نسپرده، پس " +
        "چیزی برای باز کردن نیست.<br>این کار خودکار است ولی فقط یک‌بار لازم دارد: " +
        "خودش از کارتابلش برود به «دیتای شخصی» و رمزش را یک‌بار عوض کند (یا اگر " +
        "هنوز نگذاشته، بگذارد) — از همان لحظه بستهٔ رمزش نزد شما می‌نشیند.", true);
    return;
  }
  openOverlay(`
    <h2>رمز دیتای شخصی — ${esc(p.name)}</h2>
    <p class="sub">رمزِ ادمینِ خودتان را بزنید تا بستهٔ رمزِ او باز شود. همه‌چیز
      داخل همین مرورگر انجام می‌شود؛ نه رمزِ شما به سرور می‌رود نه رمزِ او.
      <b>محتوای صندوق دست نمی‌خورد</b> — فقط با رمزِ تازه دوباره قفل می‌شود.</p>
    <div class="row">
      <div class="fld"><label>رمز ادمین</label>
        <input type="password" id="vAdmin" autocomplete="current-password"></div>
    </div>
    <div class="row" style="margin-top:10px;">
      <div class="fld"><label>رمز تازهٔ کاربر (خالی = فقط رمز فعلی را نشانم بده)</label>
        <input type="text" id="vNew" dir="ltr"></div>
    </div>
    <div class="ov-acts">
      <button class="btn btn-main" id="vGo">ادامه</button>
      <button class="btn" id="vCancel">بستن</button>
    </div>
    <div class="gate-err" id="vErr"></div>
    <div id="vOut"></div>`);

  document.getElementById("vCancel").onclick = closeOverlay;
  document.getElementById("vGo").onclick = ()=> runVaultReset(slug);
}

/* ---------- کلیدِ اضطراری: باز کردن، پیچیدن، انتقال ----------

   کلیدهایی که پیش از یکی‌شدنِ رمزها ساخته شده‌اند با «عبارتِ عبورِ
   ادمین»ِ جداگانهٔ قدیمی پیچیده‌اند، نه با رمزِ ورود. برای همین هر
   جا کلید باز می‌شود، اگر رمزِ ادمین نگرفت همان یک‌بار عبارتِ قبلی
   پرسیده و کلید از همان‌جا به رمزِ ادمین منتقل می‌شود — بعدش دیگر
   سؤالی نیست. جفت‌کلید عوض نمی‌شود، پس بسته‌های رمزِ کاربرها همه
   سرِ جایشان می‌مانند. */
async function wrapPkcs8(pkcs8, pass){
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const key = await keyFrom(pass, salt, ["encrypt"]);
  const cipher = await crypto.subtle.encrypt({ name:"AES-GCM", iv }, key, pkcs8);
  return { salt: b64(salt), iv: b64(iv), cipher: b64(cipher) };
}

async function escrowPkcs8(adminPass, legacyPass){
  const k = await api("/escrow-key");
  if(!k.ok || !k.data.priv) throw new Error("کلیدِ اضطراری روی سرور نیست.");
  const { salt, iv, cipher } = k.data.priv;
  const open = async (pw)=>{
    const key = await keyFrom(pw, unb64(salt), ["decrypt"]);
    return crypto.subtle.decrypt({ name:"AES-GCM", iv: unb64(iv) }, key, unb64(cipher));
  };
  try{ return { pkcs8: await open(adminPass), legacy: false }; }
  catch(e){ /* پایین‌تر با عبارتِ قبلی امتحان می‌شود */ }

  const old = legacyPass || prompt(
    "این کلید با رمزِ ادمین باز نشد — یعنی پیش از یکی‌شدنِ رمزها، با " +
    "«عبارت عبورِ ادمین»ِ جداگانه ساخته شده.\n\n" +
    "همان عبارت را همین یک‌بار بزنید تا کلید به رمزِ ادمین منتقل شود.");
  if(!old) throw new Error(
    "کلید با رمزِ ادمین باز نمی‌شود. اگر عبارتِ قبلی را دارید، یک‌بار بزنید تا منتقل شود؛ " +
    "وگرنه باید کلیدِ تازه بسازید — که بسته‌های رمزِ فعلی را باز نمی‌کند.");
  try{ return { pkcs8: await open(old), legacy: true }; }
  catch(e){ throw new Error("با آن عبارت هم باز نشد. مطمئنید همان عبارتی است که کلید با آن ساخته شد؟"); }
}

/* کلید را برای استفاده باز می‌کند؛ اگر لازم شد، در همان مسیر منتقلش هم می‌کند. */
async function unwrapEscrowKey(adminPass, legacyPass){
  const { pkcs8, legacy } = await escrowPkcs8(adminPass, legacyPass);
  if(legacy){
    const r = await api("/escrow-rewrap", { method:"POST", body: JSON.stringify({
      password: adminPass, priv: await wrapPkcs8(pkcs8, adminPass) })});
    if(!r.ok) throw new Error("انتقالِ کلید به رمزِ ادمین نشد: " + (r.data.error || ""));
    DATA.escrowLegacy = false;
    say("کلیدِ اضطراری به رمزِ ادمین منتقل شد — از این به بعد همان رمزِ ورود کافی است.");
  }
  return crypto.subtle.importKey("pkcs8", pkcs8,
    { name:"RSA-OAEP", hash:"SHA-256" }, false, ["decrypt"]);
}

/* کلید را با رمزِ فعلی باز می‌کنیم و با رمزِ تازه دوباره می‌پیچیم؛
   هر دو کار داخل همین مرورگر. اگر کلید با عبارتِ جداگانهٔ قدیمی ساخته
   شده باشد، همان‌جا می‌پرسیمش تا کاربر گیر نکند. */
async function rewrapEscrowKey(curPass, newPass){
  const { pkcs8 } = await escrowPkcs8(curPass);
  return wrapPkcs8(pkcs8, newPass);
}

async function runVaultReset(slug){
  const p = find(slug);
  const err = document.getElementById("vErr");
  const out = document.getElementById("vOut");
  const go = document.getElementById("vGo");
  err.textContent = ""; out.innerHTML = "";
  const adminPass = document.getElementById("vAdmin").value;
  const newPass = document.getElementById("vNew").value.trim();
  if(!adminPass){ err.textContent = "رمز ادمین را بزنید."; return; }
  if(newPass && newPass.length < 4){ err.textContent = "رمزِ تازه دست‌کم ۴ حرف."; return; }
  go.disabled = true; go.textContent = "…";
  try{
    const priv = await unwrapEscrowKey(adminPass);

    const e = await api("/planners/" + slug + "/escrow");
    if(!e.ok) throw new Error(e.data.error || "بستهٔ رمزِ این کاربر نیامد.");
    const oldPassBuf = await crypto.subtle.decrypt({ name:"RSA-OAEP" }, priv, unb64(e.data.escrow.cipher));
    const oldPass = new TextDecoder().decode(oldPassBuf);

    if(!newPass){
      out.innerHTML = `<div class="msg msg-ok">رمزِ فعلیِ دیتای شخصیِ «${esc(p.name)}»:
        <br><code>${esc(oldPass)}</code><br>
        چیزی عوض نشد. اگر می‌خواهید رمزِ تازه بگذارید، آن را در کادرِ بالا بنویسید.</div>`;
      go.disabled = false; go.textContent = "ادامه";
      return;
    }

    /* صندوق را با رمزِ فعلی باز و با رمزِ تازه دوباره می‌بندیم. محتوا
       همان است که بود — فقط قفلش عوض می‌شود. */
    const v = await api("/planners/" + slug + "/vault");
    if(!v.ok) throw new Error(v.data.error || "صندوقِ این کاربر نیامد.");
    const vault = v.data.vault;
    if(!vault || !vault.cipher) throw new Error("این کاربر هنوز دیتای شخصی نگذاشته.");
    const oldKey = await keyFrom(oldPass, unb64(vault.salt), ["decrypt"]);
    let plain;
    try{
      plain = await crypto.subtle.decrypt({ name:"AES-GCM", iv: unb64(vault.iv) }, oldKey, unb64(vault.cipher));
    }catch(ex){ throw new Error("بستهٔ رمز با صندوق نمی‌خواند. شاید کاربر بعداً رمزش را بی‌کلیدِ ادمین عوض کرده."); }

    const salt = crypto.getRandomValues(new Uint8Array(16));
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const newKey = await keyFrom(newPass, salt, ["encrypt"]);
    const cipher = await crypto.subtle.encrypt({ name:"AES-GCM", iv }, newKey, plain);

    /* رمزِ تازه را هم دوباره با کلیدِ عمومی می‌پیچیم تا دفعهٔ بعد هم
       همین راه باز باشد. */
    const k = await api("/escrow-key");
    const pub = await crypto.subtle.importKey("jwk", k.data.pub,
      { name:"RSA-OAEP", hash:"SHA-256" }, false, ["encrypt"]);
    const wrapped = await crypto.subtle.encrypt({ name:"RSA-OAEP" }, pub,
      new TextEncoder().encode(newPass));

    const put = await api("/planners/" + slug + "/vault", { method:"PUT", body: JSON.stringify({
      vault: { salt: b64(salt), iv: b64(iv), cipher: b64(cipher) },
      recovery: null,
      escrow: { cipher: b64(wrapped), at: Date.now() }
    })});
    if(!put.ok) throw new Error(put.data.error || "ذخیره نشد.");

    out.innerHTML = `<div class="msg msg-ok">رمزِ دیتای شخصیِ «${esc(p.name)}» عوض شد و
      <b>محتوایش دست‌نخورده ماند</b>. رمزِ تازه:<br><code>${esc(newPass)}</code><br>
      کدِ بازیابیِ قبلی‌اش دیگر کار نمی‌کند؛ به او بگویید یک کدِ تازه بسازد.</div>`;
    go.textContent = "انجام شد";
    loadPlanners();
  }catch(ex){
    err.textContent = ex.message || String(ex);
    go.disabled = false; go.textContent = "ادامه";
  }
}

/* ---------- غیرفعال / فعال ---------- */
async function toggleState(slug){
  const p = find(slug);
  if(!p) return;
  const off = !p.closed;
  if(off && !confirm(
      "«" + p.name + "» غیرفعال شود؟\n\n" +
      "• آدرسش دیگر باز نمی‌شود و هر دستگاهی که وارد مانده بیرون می‌افتد.\n" +
      "• پشتیبان خودکار هم دیگر برایش نمی‌رود.\n" +
      "• هیچ داده‌ای پاک نمی‌شود؛ هر وقت خواستید با یک کلیک برمی‌گردد.")) return;
  /* اگر مهلتش گذشته، روشن‌کردنِ خالی بی‌فایده است — لحظهٔ بعد دوباره
     خودش بسته می‌شود. پس همان‌جا می‌پرسیم چند روز دیگر. */
  let days;
  if(!off && p.until && daysLeft(p.until) <= 0){
    const t = prompt(
      "مهلتِ «" + p.name + "» تمام شده.\n\n" +
      "چند روز دیگر باز بماند؟ خالی بگذارید تا بی‌مهلت شود.", "30");
    if(t === null) return;
    days = t.trim() === "" ? 0 : Number(t);
    if(!Number.isFinite(days) || days < 0 || days > 3650){ say("عدد روز درست نیست.", true); return; }
  }
  const r = await api("/planners/" + slug + "/state",
    { method:"POST", body: JSON.stringify({ disabled: off, days }) });
  if(!r.ok){ say(r.data.error || "نشد.", true); return; }
  say(off
    ? "«" + esc(p.name) + "» غیرفعال شد. داده‌هایش سرِ جایشان است و پشتیبان خودکار هم دیگر برایش نمی‌رود."
    : "«" + esc(p.name) + "» دوباره فعال شد. رمزِ ورودش همان است که بود.");
  loadPlanners();
}

/* ---------- حذف ---------- */
function openDelete(slug){
  const p = find(slug);
  if(!p) return;
  openOverlay(`
    <h2>حذف «${esc(p.name)}»</h2>
    <p class="sub">این کار برگشت ندارد: خودِ کارتابل، همهٔ داده‌هایش، تاریخچه‌اش و
      دیتای شخصی‌اش پاک می‌شوند. پشتیبان‌های تلگرام سرِ جایشان می‌مانند.</p>
    <div class="row">
      <div class="fld"><label>برای تأیید، <code>${esc(slug)}</code> را تایپ کنید</label>
        <input type="text" id="dSlug" dir="ltr" autocomplete="off" autocorrect="off"
          autocapitalize="off" spellcheck="false" name="confirm-text"
          placeholder="${esc(slug)}"></div>
    </div>
    <div class="ov-acts">
      <button class="btn btn-danger" id="dGo">حذف کن</button>
      <button class="btn" id="dCancel">بی‌خیال</button>
    </div>
    <div class="gate-err" id="dErr"></div>`);
  document.getElementById("dCancel").onclick = closeOverlay;
  document.getElementById("dGo").onclick = async ()=>{
    /* اگر مرورگر آدرسِ کامل را ریخته باشد، آخرین تکه‌اش همان چیزی است
       که خواسته‌ایم. یک‌بار همین باعث شد حذف اصلاً کار نکند. */
    const typed = document.getElementById("dSlug").value.trim().toLowerCase()
      .replace(/^https?:\/\//, "").replace(/[?#].*$/, "")
      .replace(/\/+$/, "").split("/").filter(Boolean).pop() || "";
    const r = await api("/planners/" + slug, { method:"DELETE",
      body: JSON.stringify({ confirm: typed }) });
    if(!r.ok){ document.getElementById("dErr").textContent = r.data.error || "نشد."; return; }
    closeOverlay();
    say("«" + esc(p.name) + "» حذف شد.");
    loadPlanners();
  };
}

/* ---------- کارتابل تازه ---------- */
function renderKindPicker(){
  const box = document.getElementById("nKinds");
  if(!box || !DATA.kinds.length) return;
  const cur = document.getElementById("nKind").value;
  box.innerHTML = DATA.kinds.map(k=>`
    <button type="button" class="kind${k.id===cur?' on':''}" data-kind="${esc(k.id)}">
      <div class="kt">${k.icon||"🗂"} ${esc(k.label)}</div>
      <div class="kn">${esc(k.note||"")}</div>
    </button>`).join("");
  box.querySelectorAll("[data-kind]").forEach(b=> b.onclick = ()=>{
    document.getElementById("nKind").value = b.dataset.kind;
    renderKindPicker();
    paintNew();
    renderNewViews();
  });
}

/* بخش‌هایی که این نوع کارتابل می‌تواند داشته باشد، با پیشنهادِ شغل
   از پیش تیک‌خورده. */
function renderNewViews(){
  const wrap = document.getElementById("nViewsWrap");
  const box  = document.getElementById("nViews");
  if(!wrap || !box) return;
  const kind = document.getElementById("nKind").value;
  const all  = ((DATA.views||{})[kind]) || [];
  if(!all.length){ wrap.hidden = true; box.innerHTML = ""; return; }
  const job  = (DATA.jobs||[]).find(j=> j.id === document.getElementById("nJob").value);
  /* برای «عمومی» پیشنهادِ شغل ملاک است؛ برای IT و مالی همه‌چیز باز. */
  const on = kind === "gen" ? new Set((job && job.views) || []) : new Set(all.map(v=>v.id));
  wrap.hidden = false;
  box.innerHTML = all.map(v=>`
    <label class="feat${on.has(v.id) ? '' : ' closed'}">
      <input type="checkbox" data-nview="${esc(v.id)}" ${on.has(v.id) ? "checked" : ""}>
      <span><span class="ft">${esc(v.label)}</span></span>
    </label>`).join("");
  box.querySelectorAll("input").forEach(i=>{
    i.onchange = ()=> i.closest(".feat").classList.toggle("closed", !i.checked);
  });
}

function paintNew(){
  const slug = document.getElementById("nSlug");
  const prev = document.getElementById("nPreview");
  if(!prev) return;
  const v = slug.value.trim().toLowerCase();
  prev.innerHTML = v
    ? "آدرسش می‌شود: <b>" + esc(HOST) + "/" + esc(v) + "</b>"
    : "آدرس فقط حروف انگلیسی کوچک، عدد و خط تیره.";
}

function setupNew(){
  const name = document.getElementById("nName");
  const slug = document.getElementById("nSlug");
  const kind = document.getElementById("nKind");
  slug.addEventListener("input", paintNew);
  document.getElementById("nJob").addEventListener("change", renderNewViews);
  const paint = paintNew;
  setTimeout(()=>{ paintNew(); renderNewViews(); }, 0);

  document.getElementById("nCreate").onclick = async ()=>{
    const btn = document.getElementById("nCreate");
    btn.disabled = true;
    const r = await api("/planners", { method:"POST", body: JSON.stringify({
      name: name.value.trim(),
      slug: slug.value.trim().toLowerCase(),
      user: document.getElementById("nUser").value.trim().toLowerCase(),
      kind: kind.value,
      job: document.getElementById("nJob").value,
      views: Array.from(document.querySelectorAll("#nViews input"))
        .filter(i=> i.checked).map(i=> i.dataset.nview),
      password: document.getElementById("nPass").value.trim()
    })});
    btn.disabled = false;
    if(!r.ok){ say(r.data.error || "نشد.", true); return; }
    name.value = ""; slug.value = ""; document.getElementById("nPass").value = "";
    document.getElementById("nUser").value = "";
    paint();
    say("کارتابل ساخته شد: <b>" + esc(HOST) + esc(r.data.url) + "</b><br>" +
        "از صفحهٔ ورود (<b>" + esc(HOST) + "/login</b>) با این نام کاربری وارد می‌شود:<br>" +
        "<code>" + esc(r.data.user) + "</code>" +
        ` <button class="copy" data-copy="${esc(r.data.user)}" title="رونوشت">⧉</button><br>` +
        "رمزِ ورودش:<br><code>" + esc(r.data.password) + "</code>" +
        ` <button class="copy" data-copy="${esc(r.data.password)}" title="رونوشت">⧉</button><br>` +
        "همین حالا جایی یادداشتش کنید — بعد از بستنِ این پیام دیگر هیچ‌جا نیست.");
    loadPlanners();
    document.querySelector('.tabs button[data-tab="list"]').click();
  };
}

/* ---------- تنظیماتِ سایت ---------- */
let SITE = { plans: [] };

function planRow(pl){
  pl = pl || { name:"", price:"", days:"", note:"" };
  const d = document.createElement("div");
  d.className = "planrow";
  d.innerHTML = `
    <input class="p-name"  type="text"   placeholder="نام پلن (لازم)" value="${esc(pl.name||"")}">
    <input class="p-price" type="number" dir="ltr" min="0" placeholder="قیمت (تومان)" value="${pl.price ?? ""}">
    <input class="p-days"  type="number" dir="ltr" min="0" max="3650" placeholder="روز" value="${pl.days ?? ""}">
    <input class="p-note"  type="text"   placeholder="یک خط توضیح (اختیاری)" value="${esc(pl.note||"")}">
    <button type="button" class="x" title="بردار">✕</button>`;
  d.querySelector(".x").onclick = ()=> d.remove();
  return d;
}

function renderPlans(list){
  const box = document.getElementById("stPlans");
  box.innerHTML = "";
  (list && list.length ? list : [null]).forEach(pl=> box.appendChild(planRow(pl)));
}

function readPlans(){
  return Array.from(document.querySelectorAll("#stPlans .planrow")).map(r=>({
    name: r.querySelector(".p-name").value.trim(),
    price: Number(r.querySelector(".p-price").value || 0),
    days: Number(r.querySelector(".p-days").value || 0),
    note: r.querySelector(".p-note").value.trim()
  })).filter(p=> p.name);
}

function paintBots(bots){
  const mark = (el, b)=>{
    el.textContent = b && b.set ? "— گذاشته شده (…" + b.tail + ")" : "— هنوز گذاشته نشده";
  };
  mark(document.getElementById("stTgHas"), bots && bots.telegram);
  mark(document.getElementById("stBaleHas"), bots && bots.bale);
}

function paintSite(d){
  SITE = d.site || { plans: [] };
  const v = (id, val)=>{ const el = document.getElementById(id); if(el) el.value = val || ""; };
  v("stTelegram", SITE.telegram); v("stBale", SITE.bale);
  v("stPhone", SITE.phone);       v("stEmail", SITE.email);
  v("stCard", SITE.card);         v("stCardName", SITE.cardName);
  v("stTgChat", SITE.tgChat);     v("stBaleChat", SITE.baleChat);
  renderPlans(SITE.plans);
  paintBots(d.bots);
}

async function setupSite(){
  document.getElementById("stAddPlan").onclick = ()=>{
    const box = document.getElementById("stPlans");
    const row = planRow(null);
    box.appendChild(row);
    row.querySelector(".p-name").focus();
  };

  const test = async (bot, btn)=>{
    btn.disabled = true; const t = btn.textContent; btn.textContent = "…";
    const chat = document.getElementById(bot === "bale" ? "stBaleChat" : "stTgChat").value.trim();
    const r = await api("/site/bot-test", { method:"POST", body: JSON.stringify({ bot, chat }) });
    say(r.ok ? "پیام آزمایشی رفت. اگر در گفتگو دیدیدش، این ربات درست تنظیم است."
             : (r.data.error || "نشد."), !r.ok);
    btn.disabled = false; btn.textContent = t;
  };
  document.getElementById("stTgTest").onclick = e => test("telegram", e.currentTarget);
  document.getElementById("stBaleTest").onclick = e => test("bale", e.currentTarget);

  document.getElementById("stSave").onclick = async ()=>{
    const btn = document.getElementById("stSave");
    const g = id => document.getElementById(id).value.trim();
    btn.disabled = true; btn.textContent = "…";
    const r = await api("/site", { method:"PUT", body: JSON.stringify({
      telegram: g("stTelegram"), bale: g("stBale"),
      phone: g("stPhone"), email: g("stEmail"),
      card: g("stCard"), cardName: g("stCardName"),
      tgChat: g("stTgChat"), baleChat: g("stBaleChat"),
      /* توکن فقط وقتی می‌رود که چیزی تایپ شده باشد */
      tgToken: g("stTgToken"), baleToken: g("stBaleToken"),
      plans: readPlans()
    })});
    btn.disabled = false; btn.textContent = "ذخیرهٔ تنظیمات";
    if(!r.ok){ say(r.data.error || "نشد.", true); return; }
    /* کادرِ توکن خالی می‌شود تا کسی از روی صفحه نخواندش */
    document.getElementById("stTgToken").value = "";
    document.getElementById("stBaleToken").value = "";
    paintSite(r.data);
    say("تنظیمات ذخیره شد.");
  };

  const r = await api("/site");
  if(r.ok) paintSite(r.data);
}

/* ---------- کلیدها ---------- */
function renderEscrowState(){
  document.getElementById("escrowState").innerHTML = DATA.escrowReady
    ? "✅ کلید ساخته شده. کارتابل‌هایی که رمزِ دیتای شخصی‌شان نزد شماست: <b>" +
      DATA.items.filter(p=>p.hasEscrow).length + "</b> از " + DATA.items.length + "."
    : "⚠️ هنوز کلیدی نیست. تا وقتی نباشد، رمزِ فراموش‌شدهٔ دیتای شخصی هیچ راهِ بازگشتی ندارد.";
  document.getElementById("ekGo").textContent = DATA.escrowReady ? "ساختن کلید تازه" : "ساختن کلید";
}

function setupKeys(){
  const au = document.getElementById("auName");
  au.value = ADMIN_USER || "admin";
  document.getElementById("auGo").onclick = async ()=>{
    const user = au.value.trim().toLowerCase();
    if(!user){ say("نام کاربری را بنویسید.", true); return; }
    const r = await api("/admin-user", { method:"POST", body: JSON.stringify({ user }) });
    if(!r.ok){ say(r.data.error || "نشد.", true); return; }
    ADMIN_USER = r.data.user; au.value = ADMIN_USER;
    say("از این به بعد با <code dir=\"ltr\">" + esc(ADMIN_USER) + "</code> وارد شوید.");
  };

  document.getElementById("apGo").onclick = async ()=>{
    const btn = document.getElementById("apGo");
    const cur = document.getElementById("apCur").value;
    const np = document.getElementById("apNew").value;
    if(np !== document.getElementById("apNew2").value){ say("تکرار رمز نمی‌خواند.", true); return; }
    if(np.length < 10){ say("رمزِ ادمین دست‌کم ۱۰ حرف باشد.", true); return; }

    /* کلیدِ اضطراری پشتِ همین رمز است، پس قبل از عوض‌شدنش باید با
       رمزِ تازه دوباره پیچیده شود — وگرنه پشتِ رمزِ قدیمی جا می‌ماند و
       دیگر هیچ‌وقت باز نمی‌شود.

       بودنِ کلید را از خودِ سرور می‌پرسیم، نه از فهرستی که لحظهٔ باز
       شدنِ صفحه بار شده: اگر کلید را در یک زبانهٔ دیگر ساخته باشید،
       این صفحه از آن بی‌خبر است و کلید پشتِ رمزِ قدیمی جا می‌ماند. */
    let priv;
    const ek = await api("/escrow-key");
    if(ek.ok && ek.data && ek.data.priv){
      btn.disabled = true; btn.textContent = "…";
      try{
        priv = await rewrapEscrowKey(cur, np);
      }catch(ex){
        btn.disabled = false; btn.textContent = "عوض کن";
        say(ex.message || String(ex), true);
        return;
      }
    }

    btn.disabled = true; btn.textContent = "…";
    const r = await api("/password", { method:"POST",
      body: JSON.stringify({ current: cur, password: np, ...(priv ? { priv } : {}) }) });
    btn.disabled = false; btn.textContent = "عوض کن";
    if(!r.ok){ say(r.data.error || "نشد.", true); return; }
    ["apCur","apNew","apNew2"].forEach(i=> document.getElementById(i).value = "");
    say("رمز ادمین عوض شد. بقیهٔ نشست‌ها بسته شدند." +
        (priv ? "<br>کلیدِ اضطراری هم با رمزِ تازه دوباره پیچیده شد." : ""));
  };

  document.getElementById("mgGo").onclick = async ()=>{
    const btn = document.getElementById("mgGo");
    const note = document.getElementById("mgNote");
    const adminPass = document.getElementById("mgAdmin").value;
    const oldPass = document.getElementById("mgOld").value;
    note.textContent = "";
    if(!adminPass || !oldPass){ say("هر دو کادر را پر کنید.", true); return; }
    btn.disabled = true; btn.textContent = "…";
    try{
      /* اگر کلید از قبل با رمزِ ادمین باز شود، همین را می‌گوییم و
         دست به چیزی نمی‌زنیم. */
      const { pkcs8, legacy } = await escrowPkcs8(adminPass, oldPass);
      if(!legacy){
        note.textContent = "این کلید از قبل با رمزِ ادمین باز می‌شود — چیزی برای انتقال نبود.";
      }else{
        const r = await api("/escrow-rewrap", { method:"POST", body: JSON.stringify({
          password: adminPass, priv: await wrapPkcs8(pkcs8, adminPass) })});
        if(!r.ok) throw new Error(r.data.error || "ذخیره نشد.");
        note.textContent = "✅ منتقل شد. از این به بعد همان رمزِ ورودِ ادمین کافی است.";
        say("کلیدِ اضطراری به رمزِ ادمین منتقل شد.");
      }
      document.getElementById("mgAdmin").value = "";
      document.getElementById("mgOld").value = "";
    }catch(ex){ say(ex.message || String(ex), true); }
    btn.disabled = false; btn.textContent = "انتقال بده";
  };

  document.getElementById("ekGo").onclick = async ()=>{
    const pass = document.getElementById("ekPass").value;
    if(!pass){ say("رمزِ ادمین را بزنید.", true); return; }
    /* اول از سرور می‌پرسیم رمز درست است یا نه. اگر نپرسیم، یک اشتباهِ
       تایپی کلیدی می‌سازد که هیچ‌وقت باز نمی‌شود. */
    const v = await api("/verify-password", { method:"POST", body: JSON.stringify({ password: pass }) });
    if(!v.ok){ say(v.data.error || "رمز ادمین درست نیست.", true); return; }
    if(DATA.escrowReady && !confirm(
        "کلیدِ تازه جایگزینِ کلیدِ فعلی می‌شود.\n\n" +
        "• بسته‌هایی که با کلیدِ قبلی پیچیده شده‌اند دیگر باز نمی‌شوند و " +
        "همین‌جا برداشته می‌شوند.\n" +
        "• دیتای شخصیِ هیچ کاربری از دست نمی‌رود؛ رمزِ خودش مثل قبل بازش می‌کند.\n" +
        "• دسترسیِ اضطراریِ شما خودش برمی‌گردد: دفعهٔ بعد که هر کاربر " +
        "صندوقش را باز کند، مرورگرش پاکتِ تازه می‌سپارد.\n\nادامه بدهم؟")) return;

    const btn = document.getElementById("ekGo");
    btn.disabled = true; btn.textContent = "در حال ساختن…";
    try{
      const pair = await crypto.subtle.generateKey(
        { name:"RSA-OAEP", modulusLength:2048, publicExponent:new Uint8Array([1,0,1]), hash:"SHA-256" },
        true, ["encrypt","decrypt"]);
      const pub = await crypto.subtle.exportKey("jwk", pair.publicKey);
      const pkcs8 = await crypto.subtle.exportKey("pkcs8", pair.privateKey);
      const salt = crypto.getRandomValues(new Uint8Array(16));
      const iv = crypto.getRandomValues(new Uint8Array(12));
      const key = await keyFrom(pass, salt, ["encrypt"]);
      const cipher = await crypto.subtle.encrypt({ name:"AES-GCM", iv }, key, pkcs8);
      const r = await api("/escrow-key", { method:"POST", body: JSON.stringify({
        pub, priv: { salt: b64(salt), iv: b64(iv), cipher: b64(cipher) },
        replace: !!DATA.escrowReady
      })});
      if(!r.ok) throw new Error(r.data.error || "ذخیره نشد.");
      document.getElementById("ekPass").value = "";
      const dropped = Number(r.data.dropped || 0);
      say("کلید ساخته و ذخیره شد. از این به بعد با همین رمزِ ادمین باز می‌شود." +
        (dropped
          ? "<br>" + fa(dropped) + " پاکتِ قدیمی که با کلیدِ قبلی پیچیده شده بود برداشته شد. " +
            "هر کاربر دفعهٔ بعد که صندوقش را باز کند، پاکتِ تازه‌اش خودش می‌نشیند."
          : ""));
      loadPlanners();
    }catch(ex){ say(ex.message || String(ex), true); }
    btn.disabled = false;
    renderEscrowState();
  };
}

/* ==========================================================================
   گزارش
   نمودارها با همین div و CSS ساخته می‌شوند، نه کتابخانهٔ بیرونی: این
   صفحه نباید برای نشان دادنِ چهار میله منتظرِ اینترنت بماند.
   ========================================================================== */
let REPORT = null;

/* رنگِ هویتِ هر نوع. جای ثابتی دارد و با فیلتر عوض نمی‌شود. */
const KIND_COLOR = { it:"var(--s-it)", fin:"var(--s-fin)", gen:"var(--s-gen)" };

function kb(n){
  if(!n) return "۰";
  if(n < 1024) return fa(n) + " بایت";
  if(n < 1024*1024) return fa((n/1024).toFixed(1)) + " کیلوبایت";
  return fa((n/1024/1024).toFixed(2)) + " مگابایت";
}
function daysAgo(ms, now){ return ms ? Math.floor((now - ms) / 86400000) : null; }
function agoText(ms, now){
  if(!ms) return "هرگز";
  const d = daysAgo(ms, now);
  if(d <= 0) return "امروز";
  if(d === 1) return "دیروز";
  if(d < 30) return fa(d) + " روز پیش";
  if(d < 365) return fa(Math.floor(d/30)) + " ماه پیش";
  return fa(Math.floor(d/365)) + " سال پیش";
}
function faDate(ms){
  try{ return new Intl.DateTimeFormat("fa-IR-u-ca-persian",
    {month:"long", day:"numeric"}).format(new Date(ms)); }
  catch(e){ return ""; }
}

async function loadReport(){
  const r = await api("/report");
  if(!r.ok){ say(r.data.error || "گزارش نیامد.", true); return; }
  REPORT = r.data;
  renderMix(); renderSize(); renderActivity(); renderReportTable();
}

/* ترکیب: یک میلهٔ افقی با برچسبِ مستقیم. برای چهار پنج کارتابل، نمودار
   دایره‌ای بیشتر تزئین است تا اطلاعات. */
function renderMix(){
  const el = document.getElementById("rMix");
  const items = REPORT.planners;
  const total = items.length || 1;
  const seen = DATA.kinds.map(k=>({ id:k.id, label:k.label,
    n: items.filter(p=>p.kind===k.id).length })).filter(k=>k.n > 0);
  if(!seen.length){ el.innerHTML = `<p class="chart-empty">کارتابلی نیست.</p>`; return; }
  el.innerHTML =
    `<div class="mix">${seen.map(k=>
      `<i style="width:${(k.n/total*100).toFixed(2)}%;background:${KIND_COLOR[k.id]||'var(--bar)'}"
          title="${esc(k.label)}: ${fa(k.n)}"></i>`).join("")}</div>
     <div class="legend">${seen.map(k=>
      `<b style="--c:${KIND_COLOR[k.id]||'var(--bar)'}">${esc(k.label)}
        <span class="v">${fa(k.n)}</span></b>`).join("")}</div>`;
}

/* حجم داده: اندازه است نه هویت، پس یک رنگ بس است. */
function renderSize(){
  const el = document.getElementById("rSize");
  const items = REPORT.planners.slice().sort((a,b)=> b.bytes - a.bytes);
  if(!items.length || !items[0].bytes){
    el.innerHTML = `<p class="chart-empty">هنوز داده‌ای ذخیره نشده.</p>`; return; }
  const max = items[0].bytes || 1;
  el.innerHTML = `<div class="bars">${items.map(p=>`
    <div class="bar-row">
      <span class="nm" title="${esc(p.name)}">${esc(p.name)}</span>
      <span class="bar-track"><span class="bar-fill" style="width:${
        Math.max(2, p.bytes/max*100).toFixed(1)}%"></span></span>
      <span class="v">${kb(p.bytes)}</span>
    </div>`).join("")}</div>`;
}

function renderActivity(){
  const el = document.getElementById("rAct");
  const a = REPORT.activity || [];
  if(!a.length || !a.some(d=>d.n)){
    el.innerHTML = `<p class="chart-empty">در سی روز گذشته کاری در پنل انجام نشده.</p>`; return; }
  const max = Math.max(...a.map(d=>d.n), 1);
  el.innerHTML = `
    <div class="cols">${a.map(d=>`
      <span class="col${d.n?'':' zero'}" style="height:${d.n? Math.max(6, d.n/max*100) : 2}%"
        title="${esc(faDate(d.at))} — ${fa(d.n)} کار"></span>`).join("")}</div>
    <div class="cols-x"><span>${esc(faDate(a[0].at))}</span>
      <span>${esc(faDate(a[a.length-1].at))}</span></div>`;
}

/* وضعیت — رنگ به‌تنهایی حرف نمی‌زند؛ نشانه و نوشته هم کنارش هست. */
function backupChip(b, now){
  if(!b || !b.at) return `<span class="chip chip-none">— بی‌سابقه</span>`;
  if(b.ok === false) return `<span class="chip chip-bad" title="${esc(b.error||"")}">✕ نرفت</span>`;
  const d = daysAgo(b.at, now);
  if(d > 2) return `<span class="chip chip-warn">! ${esc(agoText(b.at, now))}</span>`;
  return `<span class="chip chip-ok">✓ ${esc(agoText(b.at, now))}</span>`;
}

function renderReportTable(){
  const now = REPORT.now;
  document.getElementById("rTable").innerHTML = `
    <div class="tbl"><table>
      <thead><tr>
        <th>کارتابل</th><th>نوع</th><th>وضعیت</th><th>حجم</th>
        <th>نسخه</th><th>آخرین ذخیره</th><th>آخرین ورود</th><th>پشتیبان</th>
      </tr></thead>
      <tbody>${REPORT.planners.map(p=>`<tr>
        <td>${esc(p.name)}</td>
        <td><span class="pill pill-${esc(p.kind)}">${esc(kindLabel(p.kind))}</span></td>
        <td>${p.disabled
          ? `<span class="chip chip-warn">⏸ غیرفعال</span>`
          : p.expired
            ? `<span class="chip chip-warn">⏳ مهلت تمام</span>`
            : `<span class="chip chip-ok">✓ فعال</span>`}</td>
        <td>${kb(p.bytes)}</td>
        <td>${fa(p.rev)}${p.snapshots ? ` <span style="color:var(--ink-faint)">(${
          fa(p.snapshots)} عکس)</span>` : ``}</td>
        <td>${esc(agoText(p.updated, now))}</td>
        <td>${esc(agoText(p.lastLogin, now))}</td>
        <td>${backupChip(p.lastBackup, now)}</td>
      </tr>`).join("")}</tbody>
    </table></div>`;
}

/* ---------- سیاهه ---------- */
async function loadLog(){
  const r = await api("/log");
  const items = (r.data && r.data.items) || [];
  const WHAT = { login:"ورود ادمین", create:"ساختن کارتابل", update:"ویرایش",
    delete:"حذف", password:"رمز ورود", "vault-password":"رمز دیتای شخصی",
    "admin-password":"رمز ادمین", "escrow-key":"کلید اضطراری" };
  document.getElementById("logBody").innerHTML = items.length
    ? `<div class="tbl"><table><thead><tr><th>زمان</th><th>کار</th><th>کارتابل</th><th>توضیح</th></tr></thead>
       <tbody>${items.map(i=>`<tr>
         <td>${esc(faDateTime(i.at))}</td>
         <td>${esc(WHAT[i.what] || i.what)}</td>
         <td class="ltr">${esc(i.slug || "—")}</td>
         <td class="ltr">${esc(i.note || "")}</td></tr>`).join("")}</tbody></table></div>`
    : `<p class="hint">هنوز چیزی ثبت نشده.</p>`;
}
</script>
</body>
</html>
