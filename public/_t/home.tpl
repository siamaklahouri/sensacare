<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script>
try{ const t = localStorage.getItem("sltech:theme");
  if(t === "dark" || (!t && matchMedia("(prefers-color-scheme: dark)").matches))
    document.documentElement.setAttribute("data-theme","dark"); }catch(e){}
</script>
<title>کارتابل ماهانه SLTech — برنامهٔ ماه هر شغلی، یک‌جا</title>
<meta name="description" content="کارتابل ماهانه: چک‌لیست آمادهٔ شغل خودتان، برنامهٔ روزانه، داشبورد، و بخش رمزدار شخصی. برای مدیر IT، مالی، منابع انسانی، فروش، انبار، پشتیبانی و ده شغل دیگر.">
<link rel="icon" type="image/png" sizes="64x64" href="/favicon-sl.3.png">
<link rel="icon" type="image/png" sizes="512x512" href="/icon-sl.3.png">
<link rel="apple-touch-icon" href="/icon-sl.3.png">
<meta property="og:type" content="website">
<meta property="og:title" content="کارتابل ماهانه SLTech">
<meta property="og:description" content="برنامهٔ ماهِ هر شغلی، یک‌جا — با چک‌لیست آماده، برنامهٔ روزانه و بخش رمزدار شخصی.">
<meta property="og:image" content="/icon-sl.3.png">
<style>
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:400;font-display:swap;
  src:url(/f/Vazirmatn-Regular.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:500;font-display:swap;
  src:url(/f/Vazirmatn-Medium.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:600;font-display:swap;
  src:url(/f/Vazirmatn-SemiBold.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:700;font-display:swap;
  src:url(/f/Vazirmatn-Bold.2.woff2) format("woff2")}

/* رنگ‌ها همان‌هایی‌اند که پنل و لوگو دارند، تا صفحهٔ فروش و خودِ
   محصول دو چیز جدا به نظر نرسند. */
:root{
  --paper:#EDF1F6; --paper-2:#F7F9FB; --white:#FFFFFF;
  --ink:#0B2545; --ink-soft:#43586D; --ink-faint:#8697A8;
  --brand:#1A4FA3; --brand-deep:#123E80; --brand-soft:#E4EAF7; --brand-ink:#14458F;
  --line:#DCE3EA; --line-soft:#E9EEF3;
  /* سه رنگِ نوعِ کارتابل — همان‌هایی که داخل خودِ پنل هم هستند و با
     سنجهٔ کوررنگی انتخاب شده‌اند، پس این‌جا هم عوض نمی‌شوند. */
  --s-gen:#6E45B0; --s-it:#0A8F88; --s-fin:#B5791B;
  --s-gen-bg:#EDE7F6; --s-it-bg:#E2F3F2; --s-fin-bg:#FAF0DD;
  --r-lg:20px; --r:14px; --r-sm:10px;
  --sh-1:0 1px 2px rgba(11,37,69,.04), 0 2px 10px rgba(11,37,69,.05);
  --sh-2:0 2px 6px rgba(11,37,69,.06), 0 14px 36px rgba(11,37,69,.09);
  --gut:20px;
}
:root[data-theme="dark"]{
  --paper:#0B141D; --paper-2:#101C27; --white:#121E29;
  --ink:#E7EEF4; --ink-soft:#AAB9C7; --ink-faint:#78899A;
  --brand:#6AA3FF; --brand-deep:#4C88EE; --brand-soft:#11213C; --brand-ink:#9BC4FF;
  --line:#1F2C38; --line-soft:#182430;
  --s-gen:#8B73C8; --s-it:#1FA298; --s-fin:#B8862C;
  --s-gen-bg:#221A33; --s-it-bg:#10302E; --s-fin-bg:#382B11;
  --sh-1:0 1px 2px rgba(0,0,0,.3), 0 2px 10px rgba(0,0,0,.26);
  --sh-2:0 2px 6px rgba(0,0,0,.32), 0 14px 36px rgba(0,0,0,.38);
}
@media (max-width:560px){ :root{ --gut:15px; } }

*{box-sizing:border-box;}
html,body{margin:0;padding:0;}
body{
  font-family:Vazirmatn, Tahoma, "Segoe UI", Arial, sans-serif;
  background:var(--paper); color:var(--ink); line-height:2;
  font-size:15px; -webkit-font-smoothing:antialiased;
  background-image:
    radial-gradient(900px 480px at 100% -10%, rgba(26,79,163,.08), transparent 60%),
    radial-gradient(700px 400px at 0% 0%, rgba(26,79,163,.05), transparent 55%);
  background-attachment:fixed;
}
.wrap{ max-width:1080px; margin:0 auto; padding:0 var(--gut); }

/* ---------- نوار بالا ---------- */
.top{ position:sticky; top:0; z-index:40; border-bottom:1px solid var(--line);
  background:color-mix(in srgb, var(--paper) 84%, transparent);
  backdrop-filter:blur(10px) saturate(1.4); }
@supports not (backdrop-filter: blur(1px)){ .top{ background:var(--paper); } }
.top .wrap{ display:flex; align-items:center; gap:12px; padding-block:12px; }
.brand{ display:flex; align-items:center; gap:10px; text-decoration:none; color:inherit; }
.brand img{ width:38px; height:38px; border-radius:50%; display:block;
  box-shadow:0 3px 10px rgba(18,46,110,.28); }
.brand b{ font-size:17px; letter-spacing:.1em; }
.top .sp{ flex:1; }

/* ---------- منوی بالا ----------
   روی صفحهٔ باریک یک ردیفِ لغزان می‌شود، نه اینکه بشکند و نوار را
   دو طبقه کند. ماسکِ لبه نشان می‌دهد که هنوز چیزی آن طرف هست. */
.topnav{ display:flex; align-items:center; gap:2px; min-width:0;
  overflow-x:auto; overflow-y:hidden; scrollbar-width:none;
  scroll-snap-type:x proximity; margin-inline-start:6px; }
.topnav::-webkit-scrollbar{ display:none; }
.topnav a{ flex:0 0 auto; scroll-snap-align:center; white-space:nowrap;
  text-decoration:none; color:var(--ink-soft); font-size:13.5px; font-weight:600;
  padding:7px 11px; border-radius:999px; position:relative;
  transition:color .15s, background .15s; }
.topnav a:hover{ color:var(--brand); background:var(--brand-soft); }
.topnav a[hidden]{ display:none; }
/* بخشی که همین حالا جلوِ چشم است پررنگ می‌شود — وگرنه منو می‌گوید
   کجا می‌شود رفت ولی نمی‌گوید کجا هستیم. */
.topnav a.on{ color:var(--brand); background:var(--brand-soft); }
@media (max-width:980px){
  .topnav{ order:3; flex-basis:100%; margin-inline-start:0;
    -webkit-mask-image:linear-gradient(to left, transparent 0, #000 16px,
                        #000 calc(100% - 16px), transparent 100%);
            mask-image:linear-gradient(to left, transparent 0, #000 16px,
                        #000 calc(100% - 16px), transparent 100%); }
  .top .wrap{ flex-wrap:wrap; padding-bottom:6px; }
  .top .sp{ order:2; }
}
.icon-btn{ width:38px; height:38px; border-radius:50%; border:1px solid var(--line);
  background:var(--white); color:var(--ink); cursor:pointer; font-size:15px; line-height:1;
  display:grid; place-items:center; }
.icon-btn:hover{ border-color:var(--brand); }

.btn{ display:inline-flex; align-items:center; justify-content:center; gap:7px;
  padding:11px 20px; border-radius:var(--r); border:1px solid var(--line);
  background:var(--white); color:var(--ink); font:inherit; font-weight:600;
  text-decoration:none; cursor:pointer; transition:transform .12s, box-shadow .15s, border-color .15s; }
.btn:hover{ transform:translateY(-1px); border-color:var(--brand); }
.btn-main{ background:linear-gradient(145deg, var(--brand), var(--brand-deep));
  color:#fff; border-color:transparent; box-shadow:0 3px 12px rgba(18,62,128,.28); }
.btn-main:hover{ box-shadow:0 6px 18px rgba(18,62,128,.34); border-color:transparent; }

/* ---------- سرصفحه ---------- */
.hero{ padding:68px 0 54px; text-align:center; }
.hero h1{ font-size:37px; line-height:1.55; margin:0 0 16px; letter-spacing:-.01em; }
.hero h1 .hl{ color:var(--brand); }
.hero p.lead{ font-size:17px; color:var(--ink-soft); max-width:660px; margin:0 auto 28px; }
.hero .cta{ display:flex; gap:11px; justify-content:center; flex-wrap:wrap; }
.hero .note{ margin-top:16px; font-size:12.5px; color:var(--ink-faint); }
@media (max-width:640px){ .hero{ padding:44px 0 36px; } .hero h1{ font-size:27px; } .hero p.lead{ font-size:15px; } }

/* ---------- بخش‌ها ---------- */
/* نوارِ بالا چسبان است، پس پرش به یک بخش عنوانش را زیرِ نوار پنهان
   می‌کرد. این حاشیه فقط برای پرشِ لنگر است، نه برای چیدمان. */
section{ padding:52px 0; scroll-margin-top:86px; }
.sec-head{ margin-bottom:28px; }
/* هر بخش یک نشانِ رنگی می‌گیرد. تا پیش از این همهٔ تیترها یک‌جور
   سرمه‌ای بودند و صفحه از بالا تا پایین یک رنگ به نظر می‌رسید. */
.sec-head h2{ font-size:25px; margin:0 0 8px; display:flex; align-items:center; gap:10px; }
.sec-head h2::before{ content:""; flex:0 0 auto; width:5px; height:24px; border-radius:99px;
  background:linear-gradient(180deg, var(--tone, var(--brand)),
             color-mix(in srgb, var(--tone, var(--brand)) 55%, transparent)); }
.sec-head p{ color:var(--ink-soft); margin:0; max-width:640px; }
#why   { --tone:#C0532B; }
#what  { --tone:var(--brand); }
#kinds { --tone:var(--s-gen); }
#jobs  { --tone:var(--s-it); }
#safe  { --tone:#1E7A4A; }
#buy   { --tone:var(--s-fin); }
#how   { --tone:var(--brand); }
#faq   { --tone:var(--s-gen); }
@media (max-width:640px){ section{ padding:38px 0; } .sec-head h2{ font-size:21px; } }

.grid{ display:grid; gap:15px; }
.g2{ grid-template-columns:repeat(2, 1fr); }
.g3{ grid-template-columns:repeat(3, 1fr); }
.g4{ grid-template-columns:repeat(auto-fill, minmax(215px, 1fr)); }
@media (max-width:860px){ .g3{ grid-template-columns:1fr 1fr; } }
@media (max-width:620px){ .g2, .g3{ grid-template-columns:1fr; } }

.card{ background:var(--white); border:1px solid var(--line); border-radius:var(--r-lg);
  padding:21px; box-shadow:var(--sh-1);
  transition:border-color .15s, box-shadow .18s, transform .15s; }
.card:hover{ transform:translateY(-2px); box-shadow:var(--sh-2);
  border-color:color-mix(in srgb, var(--tone, var(--brand)) 40%, var(--line)); }
.card h3{ margin:0 0 7px; font-size:16.5px; display:flex; align-items:center; gap:9px; }
.card p{ margin:0; color:var(--ink-soft); font-size:13.8px; }
/* ایموجیِ تنها روی کارتِ سفید گم می‌شد. حالا داخلِ یک مربعِ رنگی
   می‌نشیند و هر کارت رنگِ خودش را دارد — رنگ‌ها از همان پالتی که
   داخلِ کارتابل هم هست، نه چیزی تازه. */
.card .ic{ font-size:17px; line-height:1; flex:0 0 auto;
  width:34px; height:34px; border-radius:10px; display:grid; place-items:center;
  background:color-mix(in srgb, var(--tone, var(--brand)) 13%, var(--white));
  box-shadow:inset 0 0 0 1px color-mix(in srgb, var(--tone, var(--brand)) 22%, transparent); }

/* شش رنگ که پشتِ سرِ هم روی کارت‌ها می‌افتند، پس هر شبکه‌ای
   رنگارنگ می‌شود بی‌آنکه لازم باشد به هر کارت دستی رنگ بدهیم. */
.grid > .card:nth-child(6n+1){ --tone:var(--brand); }
.grid > .card:nth-child(6n+2){ --tone:var(--s-it); }
.grid > .card:nth-child(6n+3){ --tone:var(--s-fin); }
.grid > .card:nth-child(6n+4){ --tone:var(--s-gen); }
.grid > .card:nth-child(6n+5){ --tone:#1E7A4A; }
.grid > .card:nth-child(6n+6){ --tone:#C0532B; }

/* مشکل‌ها — کارت‌های کم‌رنگ‌تر، چون حرفِ خوشایندی نیستند */
.pain{ background:transparent; border-style:dashed; box-shadow:none; }
.pain h3{ font-size:15.5px; color:var(--ink); }

/* ---------- سه نوع ---------- */
.kind{ position:relative; overflow:hidden; }
.kind::before{ content:""; position:absolute; inset:0 0 auto 0; height:4px; background:var(--accent); }
.kind.k-gen{ --accent:var(--s-gen); --accent-bg:var(--s-gen-bg); }
.kind.k-it{ --accent:var(--s-it); --accent-bg:var(--s-it-bg); }
.kind.k-fin{ --accent:var(--s-fin); --accent-bg:var(--s-fin-bg); }
.kind .tag{ display:inline-block; font-size:11.5px; font-weight:600; padding:3px 10px;
  border-radius:999px; background:var(--accent-bg); color:var(--accent); margin-bottom:9px; }
.kind ul{ margin:12px 0 0; padding:0 17px 0 0; color:var(--ink-soft); font-size:13.5px; }
.kind ul li{ margin-bottom:4px; }

/* ---------- شغل‌ها ---------- */
.jobs{ display:grid; gap:9px; grid-template-columns:repeat(auto-fill, minmax(230px, 1fr)); }
.job{ display:flex; align-items:center; gap:10px; background:var(--white);
  border:1px solid var(--line); border-radius:var(--r); padding:12px 14px;
  transition:border-color .15s, box-shadow .15s; }
.job:hover{ border-color:color-mix(in srgb, var(--tone, var(--brand)) 45%, var(--line));
  box-shadow:var(--sh-1); }
.job .n{ font-weight:600; font-size:14px; flex:1; min-width:0; }
.job .c{ font-size:11.5px; white-space:nowrap; padding:2px 9px; border-radius:999px;
  color:var(--tone, var(--brand-ink));
  background:color-mix(in srgb, var(--tone, var(--brand)) 13%, var(--white)); }
.job .e{ font-size:16px; line-height:1; flex:0 0 auto;
  width:30px; height:30px; border-radius:9px; display:grid; place-items:center;
  background:color-mix(in srgb, var(--tone, var(--brand)) 13%, var(--white)); }
/* شغل‌ها زیادند و یک‌دست آبی بودنشان فهرست را یکنواخت می‌کرد. */
.jobs > .job:nth-child(5n+1){ --tone:var(--brand); }
.jobs > .job:nth-child(5n+2){ --tone:var(--s-it); }
.jobs > .job:nth-child(5n+3){ --tone:var(--s-fin); }
.jobs > .job:nth-child(5n+4){ --tone:var(--s-gen); }
.jobs > .job:nth-child(5n+5){ --tone:#1E7A4A; }

/* ---------- گام‌ها ---------- */
.steps{ counter-reset:s; display:grid; gap:14px; grid-template-columns:repeat(3,1fr); }
@media (max-width:760px){ .steps{ grid-template-columns:1fr; } }
.step{ background:var(--white); border:1px solid var(--line); border-radius:var(--r-lg);
  padding:21px; position:relative; }
.step::before{ counter-increment:s; content:counter(s);
  position:absolute; inset-block-start:-13px; inset-inline-start:21px;
  width:30px; height:30px; border-radius:50%; display:grid; place-items:center;
  background:linear-gradient(145deg, var(--tone, var(--brand)),
             color-mix(in srgb, var(--tone, var(--brand)) 70%, #000)); color:#fff;
  font-weight:700; font-size:14px; box-shadow:0 3px 10px rgba(18,62,128,.3); }
/* سه گام، سه رنگ — پیشرفت را دیدنی‌تر می‌کند تا سه دایرهٔ یک‌شکل. */
.steps > .step:nth-child(1){ --tone:var(--brand); }
.steps > .step:nth-child(2){ --tone:var(--s-it); }
.steps > .step:nth-child(3){ --tone:#1E7A4A; }
.step{ transition:border-color .15s, box-shadow .15s; }
.step:hover{ border-color:color-mix(in srgb, var(--tone, var(--brand)) 40%, var(--line));
  box-shadow:var(--sh-1); }
.step h3{ margin:9px 0 6px; font-size:16px; }
.step p{ margin:0; color:var(--ink-soft); font-size:13.8px; }

/* ---------- امنیت ---------- */
.safe{ background:var(--white); border:1px solid var(--line); border-radius:var(--r-lg);
  padding:26px; box-shadow:var(--sh-1); }
.safe ul{ margin:0; padding:0 19px 0 0; }
.safe li{ margin-bottom:11px; color:var(--ink-soft); font-size:14px; }
.safe li b{ color:var(--ink); font-weight:600; }

/* ---------- پرسش‌ها ---------- */
details{ background:var(--white); border:1px solid var(--line); border-radius:var(--r);
  padding:14px 18px; margin-bottom:9px; }
details[open]{ border-color:var(--brand); }
summary{ cursor:pointer; font-weight:600; font-size:14.5px; list-style:none; }
summary::-webkit-details-marker{ display:none; }
summary::after{ content:"+"; float:left; color:var(--brand); font-weight:700; }
details[open] summary::after{ content:"−"; }
details p{ margin:10px 0 0; color:var(--ink-soft); font-size:13.8px; }

/* ---------- پایان ---------- */
.final{ background:linear-gradient(150deg, var(--brand), var(--brand-deep));
  border-radius:var(--r-lg); padding:40px 28px; text-align:center; color:#fff;
  box-shadow:var(--sh-2); }
.final h2{ margin:0 0 10px; font-size:24px; color:#fff; }
.final p{ margin:0 auto 22px; max-width:520px; color:rgba(255,255,255,.88); font-size:14.5px; }
.final .btn{ background:#fff; color:var(--brand-deep); border-color:transparent; }
.final .btn-ghost{ background:transparent; color:#fff; border-color:rgba(255,255,255,.55); }
.ask{ max-width:560px; margin:0 auto; text-align:start; }
.ask-row{ display:grid; gap:10px; grid-template-columns:1fr 1fr; margin-bottom:10px; }
@media (max-width:520px){ .ask-row{ grid-template-columns:1fr; } }
.ask input, .ask textarea{ width:100%; padding:12px 14px; border-radius:var(--r);
  border:1px solid rgba(255,255,255,.3); background:rgba(255,255,255,.12); color:#fff;
  font-family:inherit; font-size:14px; }
.ask input::placeholder, .ask textarea::placeholder{ color:rgba(255,255,255,.6); }
.ask input:focus, .ask textarea:focus{ outline:none; border-color:#fff;
  background:rgba(255,255,255,.18); }
.ask textarea{ resize:vertical; line-height:1.9; }
.ask-acts{ display:flex; gap:10px; justify-content:center; flex-wrap:wrap; margin-top:12px; }
.ask-note{ margin-top:10px; font-size:13px; color:rgba(255,255,255,.9); min-height:20px;
  text-align:center; }
.ways{ margin-top:18px; display:flex; gap:9px; justify-content:center; flex-wrap:wrap; }
.ways a{ color:#fff; text-decoration:none; font-size:13px; padding:7px 14px; border-radius:999px;
  border:1px solid rgba(255,255,255,.35); }
.ways a:hover{ background:rgba(255,255,255,.14); }

/* ---------- پلن‌ها و سفارش ---------- */
/* شش پلن روی یک شبکهٔ سه‌ستونه: سه بالا، سه پایین. auto-fit پیش از
   این چهار تا را بالا می‌چید و دو تا را پایین، که هم بی‌قواره بود هم
   ستونِ آخر را تنها می‌گذاشت. */
/* دو کارت، وسطِ صفحه. شبکهٔ سه‌ستونی برای شش کارت بود؛ با دو کارت
   همان شبکه آن‌ها را به لبه می‌چسباند و ستونِ سوم خالی می‌ماند. حالا
   هر کارت عرضِ خودش را دارد و مجموعشان وسط می‌نشیند. */
.plans{ display:flex; flex-wrap:wrap; justify-content:center; align-items:stretch;
  gap:20px; max-width:760px; margin-inline:auto; }
.plans > .plan{ flex:1 1 320px; max-width:360px; }
@media (max-width:620px){ .plans{ gap:16px; } .plans > .plan{ flex:1 1 100%; max-width:none; } }
/* کارت‌ها ستونی‌اند تا قدشان با هم یکی شود و دکمه‌ها در یک خط بنشینند —
   بدون آن، هر کارت به اندازهٔ متنِ خودش بلند می‌شد. */
.plan{ display:flex; flex-direction:column; position:relative; overflow:hidden;
  background:var(--white); border:1px solid var(--line); border-radius:var(--r-lg);
  padding:30px 26px 24px; text-align:center; box-shadow:var(--sh-1);
  transition:transform .18s, box-shadow .18s, border-color .18s; }
.plan::before{ content:""; position:absolute; inset-inline:0; top:0; height:4px;
  background:linear-gradient(90deg, var(--brand), var(--brand-deep)); }
.plan:hover{ transform:translateY(-3px); box-shadow:var(--sh-2); border-color:var(--brand); }
/* کارتِ سازمانی برجسته‌تر است، چون گران‌تر و کامل‌تر است و معمولاً
   همان چیزی است که سازمان‌ها دنبالش می‌آیند. */
.plan-org{ border-color:var(--brand); box-shadow:var(--sh-2); }
.plan-org::after{ content:"برای تیم‌ها"; position:absolute; top:14px; inset-inline-start:14px;
  font-size:10.5px; font-weight:700; letter-spacing:.02em;
  color:var(--brand); background:var(--brand-bg,rgba(26,79,163,.10));
  border-radius:999px; padding:4px 10px; }

.plan h3{ margin:0 0 4px; font-size:18px; font-weight:700; line-height:1.7; }
.plan .price{ font-size:30px; font-weight:800; color:var(--brand); margin:10px 0 4px;
  font-variant-numeric:tabular-nums; letter-spacing:-.01em; }
/* خطِ اول زیرِ قیمت می‌گوید عدد بابتِ چیست؛ خطِ دوم مدت. اولی مهم‌تر
   است، پس پررنگ‌تر می‌ماند. */
.plan .per{ font-size:12.5px; color:var(--ink-soft); line-height:1.95; }
.plan .per + .per{ color:var(--ink-faint); font-size:11.5px; }
.plan .pnote{ flex:1; font-size:13.5px; color:var(--ink-soft); line-height:2;
  text-align:center; margin:16px 0 20px; padding-top:16px;
  border-top:1px dashed var(--line); }
.plan .btn{ width:100%; padding-block:12px; font-size:14px; }
.order{ max-width:620px; margin:22px auto 0; }
.order h3{ margin:0 0 14px; font-size:16px; }
.order .ask-row{ display:grid; gap:10px; grid-template-columns:1fr 1fr; margin-bottom:10px; }
/* ردیف‌هایی که فقط برای یک نوعِ پلن‌اند با صفتِ hidden بسته می‌شوند،
   ولی display در CSS بر hidden می‌چربد و همیشه دیده می‌شدند. */
.order .ask-row[hidden], .ask-row[hidden]{ display:none; }
.order input[hidden]{ display:none; }

/* ---------- انتخابِ بخش‌ها ----------
   کاربر باید در یک نگاه ببیند چه چیزی در قیمت هست و چه چیزی نیست؛
   پس قیمتِ هر بخش کنارِ خودش می‌نشیند، نه در یک جدولِ جدا. */
.oseat{ display:flex; align-items:center; gap:9px; }
.oseat label{ font-size:12.5px; color:var(--ink-soft); white-space:nowrap; }
.oseat input{ flex:1 1 auto; min-width:0; }

.osec{ border:1px solid var(--card-border); border-radius:12px;
       padding:12px 13px; margin-bottom:10px; background:var(--paper); }
.osec-head{ display:flex; align-items:baseline; gap:9px; flex-wrap:wrap; margin-bottom:9px; }
.osec-head b{ font-size:13px; }
.osec-head span{ font-size:11.5px; color:var(--ink-faint); }
.osec-list{ display:grid; gap:7px; }
/* جدول، نه flex: با flex هر ردیف عرضِ خودش را می‌گرفت و نام‌ها
   وسطِ ردیف دو خطی می‌شدند. این‌طور چهار ستون در همهٔ ردیف‌ها
   هم‌تراز می‌مانند و نام جای کافی دارد. */
.osec-item{
  display:grid; grid-template-columns:auto 1fr auto auto;
  align-items:center; gap:10px; cursor:pointer;
  border:1px solid var(--card-border); border-radius:10px;
  padding:9px 11px; background:var(--white); font-size:12.5px;
}
.osec-item > input[type=checkbox]{ margin:0; }
.osec-item:hover{ border-color:var(--brass,#1A4FA3); }
/* بخشِ داخلِ قیمت انتخابی نیست، پس نباید شبیهِ دکمه باشد. */
.osec-item.free{ cursor:default; opacity:.8; background:transparent; }
.osec-item.free:hover{ border-color:var(--card-border); }
.osec-nm{ min-width:0; }
.osec-pr{ font-size:11.5px; color:var(--ink-soft); white-space:nowrap; }
.osec-cu{ display:flex; align-items:center; gap:5px; font-size:11.5px;
          color:var(--ink-faint); white-space:nowrap; cursor:pointer; }
.osec-cu input:disabled + *, .osec-cu input:disabled{ cursor:not-allowed; }

/* تفکیکِ مبلغ — تا «۷٬۰۵۰٬۰۰۰» عددی از ناکجا نباشد. */
/* پیغامِ «کمتر از پایه» زیرِ شمارشگر. جا همیشه هست تا با آمدنش
   فرم بالا و پایین نپرد. */
.seatnote{ min-height:17px; font-size:11.5px; color:var(--bad,#A6222B);
  margin:-4px 0 8px; }
.order input.bad{ border-color:var(--bad,#A6222B); }

.obill{ display:grid; gap:4px; margin:2px 0 10px; }
.obill div{ display:flex; justify-content:space-between; gap:12px;
            font-size:12px; color:var(--ink-soft); }
.obill b{ color:var(--ink); font-weight:600; }

/* روی موبایل «سفارشی» زیرِ همان ردیف می‌رود، وگرنه نام له می‌شود. */
@media (max-width:520px){
  .osec-item{ grid-template-columns:auto 1fr auto; row-gap:6px; }
  .osec-cu{ grid-column:2 / -1; justify-self:start; }
}
@media (max-width:520px){ .order .ask-row{ grid-template-columns:1fr; } }
.order input, .order select, .order textarea{ width:100%; padding:11px 13px;
  border:1px solid var(--line); border-radius:var(--r); background:var(--paper-2);
  color:var(--ink); font-family:inherit; font-size:14px; }
.order input:focus, .order select:focus, .order textarea:focus{ outline:none;
  border-color:var(--brand); }
.order textarea{ resize:vertical; line-height:1.9; }
.order .ask-acts{ justify-content:flex-start; }
.order .ask-note{ text-align:start; color:var(--ink-soft); }
.osum{ display:flex; align-items:center; font-weight:600; color:var(--brand-ink);
  background:var(--brand-soft); border-radius:var(--r); padding:0 14px; font-size:14px; }
.osum .was{ text-decoration:line-through; color:var(--ink-faint); font-weight:400;
  margin-inline-end:8px; font-size:13px; }
.cprow{ grid-template-columns:1fr auto !important; }
.cpnote{ font-size:13px; margin:2px 0 10px; min-height:20px; }
.cpnote.good{ color:#1E7A4A; }
.cpnote.bad{ color:#A6222B; }
:root[data-theme="dark"] .cpnote.good{ color:#5FB07E; }
:root[data-theme="dark"] .cpnote.bad{ color:#E8737C; }
.invoice{ max-width:620px; margin:22px auto 0; }
.invoice h3{ margin:0 0 10px; font-size:17px; }
.invoice .no{ font-size:23px; font-weight:700; letter-spacing:.06em; color:var(--brand);
  direction:ltr; }
.invoice .kv{ display:flex; justify-content:space-between; gap:12px; padding:9px 0;
  border-bottom:1px dashed var(--line); font-size:14px; }
.invoice .kv:last-of-type{ border-bottom:0; }
.invoice .kv b{ direction:ltr; }
.invoice .steps2{ margin:14px 0 0; padding:0 18px 0 0; color:var(--ink-soft); font-size:13.5px; }
.invoice .steps2 li{ margin-bottom:6px; }

footer{ padding:34px 0 46px; text-align:center; color:var(--ink-faint); font-size:12.5px; }
footer a{ color:var(--ink-soft); text-decoration:none; }
footer a:hover{ color:var(--brand); }
footer .sep{ opacity:.5; margin:0 8px; }
/* ---------- اتصال به ربات، بالای فرمِ سفارش ---------- */
.conn{ border:1px solid var(--line); border-radius:14px; padding:14px;
  background:var(--paper-2, rgba(127,127,127,.05)); margin-bottom:14px; }
.conn-head{ display:flex; gap:11px; align-items:flex-start; margin-bottom:11px; }
.conn-step{ width:26px; height:26px; flex:none; border-radius:50%; display:flex;
  align-items:center; justify-content:center; font-size:12.5px; font-weight:700;
  background:var(--btn, #123e80); color:#fff; }
.conn-head b{ font-size:13.5px; }
.conn-head p{ margin:3px 0 0; font-size:12px; line-height:1.9; opacity:.75; }
.conn-btns{ display:flex; gap:8px; flex-wrap:wrap; }
.conn-b{ text-decoration:none; }
.conn-load{ opacity:.6; font-size:13px; }
.conn-wait{ display:flex; align-items:center; gap:7px; flex-wrap:wrap;
  margin-top:10px; font-size:12px; opacity:.8; }
.conn-wait .dot{ width:7px; height:7px; border-radius:50%; background:var(--btn, #123e80);
  animation:connPulse 1.2s ease-in-out infinite; }
@keyframes connPulse{ 0%,100%{ opacity:.25; } 50%{ opacity:1; } }
@media (prefers-reduced-motion:reduce){ .conn-wait .dot{ animation:none; opacity:.7; } }
.conn-ok{ font-size:13px; display:flex; align-items:center; gap:8px; flex-wrap:wrap; }
.linkish{ border:0; background:none; padding:0; cursor:pointer; font:inherit;
  font-size:12px; color:var(--btn, #123e80); text-decoration:underline; }

</style>
</head>
<body>

<div class="top"><div class="wrap">
  <a class="brand" href="/">
    <img src="/icon-sl.3.png" alt="SLTech" width="38" height="38">
    <b>SLTech</b>
  </a>
  <!-- تا پیش از این نوارِ بالا فقط لوگو و دکمهٔ ورود بود. صفحه هشت
       بخش دارد و هیچ راهی به آن‌ها نبود جز اسکرول کردن تا ته. -->
  <nav class="topnav" id="topnav" aria-label="بخش‌های صفحه">
    <a href="#why">چرا؟</a>
    <a href="#kinds">انواع</a>
    <a href="#jobs">شغل‌ها</a>
    <a href="#buy" class="buyLink" hidden>پلن‌ها</a>
    <a href="#how">شروع</a>
    <a href="#faq">پرسش‌ها</a>
  </nav>
  <div class="sp"></div>
  <button class="icon-btn" id="themeBtn" title="تم روز و شب" aria-label="تم روز و شب">🌙</button>
  <a class="btn btn-main" href="/login">ورود به کارتابل</a>
</div></div>

<div class="wrap">

  <header class="hero">
    <h1>کارِ این ماهتان <span class="hl">یک‌جا</span> جمع است — نه در ذهن، نه پخش در چند جا</h1>
    <p class="lead">
      کارتابل ماهانه یک صفحهٔ کاری است برای خودتان: چک‌لیستِ آمادهٔ همان شغلی که دارید،
      برنامهٔ روزانه، داشبوردی که می‌گوید ماه چطور پیش می‌رود، و یک بخشِ رمزدار برای
      چیزهایی که نباید جایی بنویسیدشان.
    </p>
    <div class="cta">
      <a class="btn btn-main" href="#jobs">شغل‌ها را ببینم</a>
      <a class="btn buyLink" href="#buy" hidden>پلن‌ها و قیمت</a>
      <a class="btn" href="#how">چطور شروع کنم؟</a>
    </div>
    <p class="note">بدون نصب. در مرورگر باز می‌شود — روی موبایل هم.</p>
  </header>

  <section id="why">
    <div class="sec-head">
      <h2>چرا اصلاً چنین چیزی لازم است؟</h2>
      <p>اگر هیچ‌کدام از این‌ها برایتان آشنا نیست، احتمالاً لازمتان نمی‌شود.</p>
    </div>
    <div class="grid g3">
      <div class="card pain">
        <h3><span class="ic">🧠</span> کارها در سرتان است</h3>
        <p>کارِ ماه جایی نوشته نشده. یادتان می‌آید، ولی آخرِ ماه یکی‌شان یادتان نمی‌آید — و
           همان یکی معمولاً همانی است که نباید فراموش می‌شد.</p>
      </div>
      <div class="card pain">
        <h3><span class="ic">💬</span> پخش است بین چند جا</h3>
        <p>چند تا در پیام‌ها، چند تا روی کاغذ، چند تا در یک اکسل روی لپ‌تاپ. هیچ‌کدام
           نمی‌داند آن یکی چه خبر دارد.</p>
      </div>
      <div class="card pain">
        <h3><span class="ic">📉</span> گزارش دادن سخت است</h3>
        <p>مدیر می‌پرسد «ماه چطور پیش رفت؟» و شما باید از حافظه جواب بدهید یا نیم ساعت
           دنبال ردِ کارها بگردید.</p>
      </div>
      <div class="card pain">
        <h3><span class="ic">🔑</span> رمزها در یادداشتِ گوشی‌اند</h3>
        <p>رمزِ پنلِ شرکت‌ها، شمارهٔ قسط‌ها، دفترِ تلفنِ کاری — همه در جایی که اگر گوشی
           دست کسی بیفتد، همه‌اش را دارد.</p>
      </div>
      <div class="card pain">
        <h3><span class="ic">💾</span> یک نسخه بیشتر ندارد</h3>
        <p>آن فایل اکسل روی یک لپ‌تاپ است. اگر لپ‌تاپ برود، هرچه در آن بوده هم رفته.</p>
      </div>
      <div class="card pain">
        <h3><span class="ic">🔁</span> هر ماه از صفر</h3>
        <p>اولِ هر ماه دوباره می‌نشینید و فهرستِ کارها را از نو می‌نویسید — همان فهرستی
           که ماه قبل هم نوشته بودید.</p>
      </div>
    </div>
  </section>

  <section id="what">
    <div class="sec-head">
      <h2>داخلِ هر کارتابل چه هست</h2>
      <p>این شش‌تا ستون‌فقرات‌اند و در همهٔ کارتابل‌ها هستند.</p>
    </div>
    <div class="grid g3">
      <div class="card"><h3><span class="ic">📊</span> داشبورد</h3>
        <p>یک نگاه و می‌فهمید ماه چطور پیش می‌رود: چند کار مانده، چند تا سررسیدش نزدیک است،
           کدام دسته عقب افتاده.</p></div>
      <div class="card"><h3><span class="ic">✅</span> چک‌لیست ماهانه</h3>
        <p>کارهای ماه با دسته، مسئول، روزِ مهلت و اولویت. ماهِ بعد از صفر شروع نمی‌کنید.</p></div>
      <div class="card"><h3><span class="ic">🗓️</span> برنامهٔ روزانه</h3>
        <p>بیست‌وپنج روزِ کاری، هر روز کارِ اصلی و جلسه و شرکتِ مربوطه‌اش.</p></div>
      <div class="card"><h3><span class="ic">🔒</span> دیتای شخصی</h3>
        <p>بخشی با رمزِ جداگانهٔ خودتان: رمزِ شرکت‌ها، اقساط، دفتر تلفن، یا هر جدولی که
           خودتان تعریف کنید.</p></div>
      <div class="card"><h3><span class="ic">🤖</span> دستیار هوشمند</h3>
        <p>از دادهٔ خودِ کارتابلتان می‌پرسید: «این ماه چه چیزهایی عقب است؟» و جواب می‌گیرید.</p></div>
      <div class="card"><h3><span class="ic">📘</span> راهنما و تنظیمات</h3>
        <p>راهنمای داخلِ خودِ صفحه، و تنظیماتی مثل رمز ورود و تم روز و شب.</p></div>
    </div>
  </section>

  <section id="kinds">
    <div class="sec-head">
      <h2>سه نوع کارتابل</h2>
      <p>هر سه همان ستون‌فقرات را دارند؛ فرقشان در بخش‌های تخصصی است.</p>
    </div>
    <div class="grid g3">
      <div class="card kind k-gen">
        <span class="tag">عمومی</span>
        <h3>برای هر شغلی</h3>
        <p>همان شش بخشِ اصلی، بدون چیزِ اضافه. اگر شغلتان در فهرستِ پایین هست،
           چک‌لیستِ آماده‌اش هم رویش می‌نشیند.</p>
        <ul><li>داشبورد و چک‌لیست و برنامهٔ روزانه</li>
            <li>دیتای شخصی و دستیار</li>
            <li>بخش‌های اختیاری: شرکت‌ها، تبدیل تاریخ</li></ul>
      </div>
      <div class="card kind k-it">
        <span class="tag">مدیر IT</span>
        <h3>زیرساخت و پشتیبانی</h3>
        <p>برای کسی که سرور و شبکه و کاربر دستش است.</p>
        <ul><li>سرورها و وضعیت بکاپ</li>
            <li>تاریخچهٔ بازدید و پشتیبانیِ شرکت‌ها</li>
            <li>خطوط و سرویس MVPN</li>
            <li>تبدیل تاریخ شمسی و میلادی</li></ul>
      </div>
      <div class="card kind k-fin">
        <span class="tag">مالی</span>
        <h3>حساب و سررسید</h3>
        <p>برای مدیر مالی و حسابداری، با هشت بخشِ مخصوص خودش.</p>
        <ul><li>اسناد دریافتنی و پرداختنی و سررسیدها</li>
            <li>بدهی‌ها، منابع و مصارف</li>
            <li>حساب‌های بانکی و بودجهٔ ماهانه</li>
            <li>طرف‌حساب‌ها</li></ul>
      </div>
    </div>
  </section>

  <section id="jobs">
    <div class="sec-head">
      <h2>چک‌لیستِ آمادهٔ شانزده شغل</h2>
      <p>با انتخابِ شغل، کارتابل از روزِ اول پر است — نه یک جدولِ خالی. هر وظیفه دسته و
         مسئول و روزِ مهلت دارد، و همه‌شان از همان لحظه قابل ویرایش‌اند.</p>
    </div>
    <div class="jobs">
      <div class="job"><span class="e">👥</span><span class="n">منابع انسانی</span><span class="c">۱۵ وظیفه</span></div>
      <div class="job"><span class="e">📈</span><span class="n">فروش و بازاریابی</span><span class="c">۱۴ وظیفه</span></div>
      <div class="job"><span class="e">🧾</span><span class="n">حسابداری</span><span class="c">۱۵ وظیفه</span></div>
      <div class="job"><span class="e">🛠️</span><span class="n">پشتیبانی فنی و هلپ‌دسک</span><span class="c">۱۳ وظیفه</span></div>
      <div class="job"><span class="e">🏢</span><span class="n">مدیرعامل و مدیریت کلان</span><span class="c">۱۴ وظیفه</span></div>
      <div class="job"><span class="e">📦</span><span class="n">انبار و تدارکات</span><span class="c">۱۴ وظیفه</span></div>
      <div class="job"><span class="e">📋</span><span class="n">مدیریت پروژه</span><span class="c">۱۴ وظیفه</span></div>
      <div class="job"><span class="e">🏭</span><span class="n">تولید و کارخانه</span><span class="c">۱۴ وظیفه</span></div>
      <div class="job"><span class="e">📣</span><span class="n">بازاریابی دیجیتال و محتوا</span><span class="c">۱۴ وظیفه</span></div>
      <div class="job"><span class="e">🔬</span><span class="n">کنترل کیفیت</span><span class="c">۱۳ وظیفه</span></div>
      <div class="job"><span class="e">🩺</span><span class="n">مطب و کلینیک</span><span class="c">۱۳ وظیفه</span></div>
      <div class="job"><span class="e">🚚</span><span class="n">حمل‌ونقل و توزیع</span><span class="c">۱۲ وظیفه</span></div>
      <div class="job"><span class="e">🌍</span><span class="n">خرید خارجی و ترخیص</span><span class="c">۱۲ وظیفه</span></div>
      <div class="job"><span class="e">🛒</span><span class="n">فروشگاه و خرده‌فروشی</span><span class="c">۱۲ وظیفه</span></div>
      <div class="job"><span class="e">⚖️</span><span class="n">حقوقی و قراردادها</span><span class="c">۱۲ وظیفه</span></div>
      <div class="job"><span class="e">🗂️</span><span class="n">امور اداری و دفتری</span><span class="c">۱۲ وظیفه</span></div>
    </div>
    <p style="color:var(--ink-faint); font-size:13px; margin-top:14px;">
      شغلتان این‌جا نیست؟ کارتابلِ خالی هم هست — خودتان دسته‌ها و کارها را می‌نویسید.
      یا بگویید چه کاری می‌کنید تا چک‌لیستش را برایتان بسازیم.
    </p>
  </section>

  <section id="safe">
    <div class="sec-head">
      <h2>دادهٔ شما کجاست و چه کسی می‌بیندش</h2>
      <p>این بخش را با دقت بخوانید؛ اگر قرار است کارِ روزانه‌تان این‌جا بنشیند، حقتان است
         بدانید پشتش چه خبر است.</p>
    </div>
    <div class="safe">
      <ul>
        <li><b>هر کارتابل درِ خودش را دارد.</b> ورود با نام کاربری و رمز، و نشست با امضای
          دیجیتال نگه داشته می‌شود. ورود به یکی، به آن یکی دسترسی نمی‌دهد.</li>
        <li><b>رمزها خام ذخیره نمی‌شوند.</b> با PBKDF2 و صدهزار دور نگه داشته می‌شوند؛
          یعنی حتی کسی که به دیتابیس برسد رمزِ شما را ندارد.</li>
        <li><b>«دیتای شخصی» را خودِ سرور هم نمی‌تواند باز کند.</b> محتوایش در مرورگرِ
          خودتان با AES-256 رمز می‌شود و کلیدش هیچ‌وقت به سرور نمی‌رسد. اگر روزی دادهٔ
          سرور هم لو برود، آن بخش باز نمی‌شود.</li>
        <li><b>پشتیبان خودکار، دو بار در روز.</b> نسخهٔ کاملِ کارتابل نزد ما نگه داشته
          می‌شود. اگر روزی چیزی پاک شد یا خراب رفت، برمی‌گردانیمش.</li>
        <li><b>تاریخچه دارد.</b> هر تغییرِ مهم نسخهٔ قبلی‌اش نگه داشته می‌شود، پس یک
          اشتباه قابل برگشت است.</li>

      </ul>
    </div>
  </section>

  <section id="buy" hidden>
    <div class="sec-head">
      <h2>پلن‌ها</h2>
      <p>پلن را انتخاب کنید و فرم را پر. شمارهٔ فاکتور همان‌جا به شما داده می‌شود.</p>
    </div>
    <div class="plans" id="planList"></div>

    <form class="order card" id="orderForm" hidden>
      <h3 id="orderHead"></h3>
      <!-- اتصال به ربات: تا وصل نشود، شماره‌ای برای خبر دادن نداریم و
           فاکتور جایی نمی‌رود. برای همین اول از هر چیزِ دیگری می‌آید. -->
      <div class="conn" id="oConn">
        <div class="conn-head">
          <span class="conn-step">۱</span>
          <div>
            <b>اول وصل شوید</b>
            <p>سفارش و فاکتور از همین راه به خودتان می‌رسد. شماره‌تان را خودِ پیام‌رسان تأیید می‌کند.</p>
          </div>
        </div>
        <div class="conn-btns" id="oConnBtns"></div>
        <div class="conn-wait" id="oConnWait" hidden>
          <span class="dot"></span> منتظرِ تأییدِ شما در پیام‌رسان…
          <button type="button" class="linkish" id="oConnAgain">لینک دوباره</button>
        </div>
        <div class="conn-ok" id="oConnOk" hidden></div>
        <div class="ask-note" id="oConnNote"></div>
      </div>

      <div class="ask-row">
        <input type="text" id="oName" placeholder="نام و نام خانوادگی" autocomplete="name">
        <!-- فقط برای پلنِ سازمانی؛ برای شخصی پنهان می‌ماند. -->
        <input type="text" id="oOrgName" placeholder="نام سازمان" hidden>
      </div>
      <div class="ask-row">
        <select id="oJob"><option value="">— شغل را انتخاب کنید —</option></select>
        <div class="oseat">
          <label for="oSeats" id="oSeatLb">تعداد کارتابل</label>
          <input type="number" id="oSeats" min="1" max="200" value="1" dir="ltr">
        </div>
      </div>
      <div class="seatnote" id="oSeatNote"></div>

      <!-- بخش‌های همان شغل. آن‌هایی که در قیمت هستند نشان داده می‌شوند
           ولی تیکشان قفل است؛ بقیه هرکدام قیمتِ خودش را دارد. -->
      <div class="osec" id="oSecBox" hidden>
        <div class="osec-head">
          <b>بخش‌های کارتابل</b>
          <span id="oSecHint"></span>
        </div>
        <div class="osec-list" id="oSecList"></div>
      </div>

      <div class="ask-row" id="oSharedRow" hidden>
        <input type="text" id="oSharedNote"
               placeholder="بخشِ مشترکِ سازمان — چه چیزی بین نفرات مشترک باشد؟">
      </div>

      <div class="obill" id="oBill"></div>
      <div class="ask-row">
        <div class="osum" id="oSum"></div>
      </div>
      <div class="ask-row cprow">
        <input type="text" id="oCoupon" dir="ltr" placeholder="کد تخفیف (اگر دارید)" autocomplete="off">
        <button class="btn" type="button" id="oCpGo">اعمال کد</button>
      </div>
      <div class="cpnote" id="oCpNote"></div>
      <textarea id="oNote" rows="2" placeholder="توضیح (اختیاری)"></textarea>
      <div class="ask-acts">
        <button class="btn btn-main" type="submit" id="oGo">ثبت سفارش</button>
        <button class="btn" type="button" id="oCancel">بی‌خیال</button>
      </div>
      <div class="ask-note" id="oNote2"></div>
    </form>

    <div class="card invoice" id="invoice" hidden></div>
  </section>

  <section id="how">
    <div class="sec-head">
      <h2>چطور شروع می‌شود</h2>
      <p>ثبت‌نامِ خودکار نداریم — عمدی است. هر کارتابل دستی ساخته می‌شود تا از همان اول
         شغل و بخش‌هایش درست تنظیم باشد.</p>
    </div>
    <div class="steps">
      <div class="step">
        <h3>می‌گویید چه کاری می‌کنید</h3>
        <p>شغلتان را می‌گویید و اینکه چند نفر قرار است کارتابل داشته باشند.</p>
      </div>
      <div class="step">
        <h3>کارتابل ساخته می‌شود</h3>
        <p>با چک‌لیستِ همان شغل، بخش‌هایی که لازم دارید، و نام کاربری و رمزِ خودتان.</p>
      </div>
      <div class="step">
        <h3>وارد می‌شوید</h3>
        <p>از همین سایت، با نام کاربری و رمز. از همان روزِ اول پر است و آماده.</p>
      </div>
    </div>
  </section>

  <section id="faq">
    <div class="sec-head"><h2>پرسش‌های پرتکرار</h2></div>

    <details>
      <summary>روی موبایل هم کار می‌کند؟</summary>
      <p>بله. چیزی نصب نمی‌شود؛ در مرورگر باز می‌شود و برای صفحهٔ کوچک هم چیده شده.</p>
    </details>
    <details>
      <summary>اگر اینترنت قطع باشد چه؟</summary>
      <p>کارتابل با نسخهٔ داخلِ مرورگر بالا می‌آید و کار می‌کند؛ به‌محض وصل شدن، تغییرها
         خودشان بالا می‌روند.</p>
    </details>
    <details>
      <summary>چند نفر می‌توانند کارتابل داشته باشند؟</summary>
      <p>هر تعداد. هر کس کارتابل و دادهٔ کاملاً جدا دارد و هیچ‌کس دادهٔ دیگری را نمی‌بیند.</p>
    </details>
    <details>
      <summary>می‌شود بخش‌ها را کم و زیاد کرد؟</summary>
      <p>بله. برای هر کاربر جداگانه تعیین می‌شود کدام بخش‌ها باز باشد — مثلاً یک هلپ‌دسک
         شاید به بخش MVPN کاری نداشته باشد.</p>
    </details>
    <details>
      <summary>اگر رمزم را فراموش کنم؟</summary>
      <p>از همان صفحهٔ ورود دکمهٔ «رمز را فراموش کرده‌ام» هست؛ رمزِ تازه به پشتیبانی
         می‌رسد و از همان‌جا به دستتان می‌رسد — رمزِ قبلی از همان لحظه دیگر کار نمی‌کند.
         برای «دیتای شخصی» هم یک راهِ اضطراری هست، به شرطی که از قبل تنظیم شده باشد.</p>
    </details>
    <details>
      <summary>دادهٔ قبلی‌ام را می‌شود وارد کرد؟</summary>
      <p>اگر در اکسل است، بله. بگویید چه دارید تا ببینیم چطور منتقلش کنیم.</p>
    </details>
  </section>

  <section>
    <div class="final">
      <h2>کارتابلِ شغلِ خودتان را بگیرید</h2>
      <p>بگویید چه کاری می‌کنید و چند نفرید؛ کارتابل با چک‌لیستِ همان شغل آماده می‌شود.</p>
      <form id="askForm" class="ask">
        <div class="ask-row">
          <input type="text" id="askName" placeholder="نام شما" autocomplete="name">
          <input type="text" id="askContact" placeholder="تلگرام، شماره یا ایمیل" dir="ltr" autocomplete="off">
        </div>
        <textarea id="askText" rows="3" placeholder="چه کاری می‌کنید و چند نفرید؟"></textarea>
        <div class="ask-acts">
          <button class="btn" type="submit" id="askGo">بفرست</button>
          <a class="btn btn-ghost" href="/login">ورود به کارتابل</a>
        </div>
        <div class="ask-note" id="askNote"></div>
      </form>
      <div class="ways" id="ways"></div>
    </div>
  </section>

</div>

<footer>
  <div class="wrap">
    <a href="/login">ورود به کارتابل</a>
    <span class="sep">·</span>
    <a href="#jobs">شغل‌ها</a>
    <span class="sep">·</span>
    <a href="#safe">امنیت</a>
    <div style="margin-top:9px;">SLTech — کارتابل ماهانه</div>
  </div>
</footer>

<script>
/* تم: انتخابِ کاربر روی همین مرورگر می‌ماند. */
(function(){
  const root = document.documentElement;
  const btn = document.getElementById("themeBtn");
  const paint = ()=>{ btn.textContent = root.getAttribute("data-theme") === "dark" ? "☀️" : "🌙"; };
  paint();
  btn.addEventListener("click", ()=>{
    const dark = root.getAttribute("data-theme") === "dark";
    if(dark) root.removeAttribute("data-theme"); else root.setAttribute("data-theme","dark");
    try{ localStorage.setItem("sltech:theme", dark ? "light" : "dark"); }catch(e){}
    paint();
  });
})();

/* ---------- منوی بالا ----------
   کدام بخش جلوِ چشم است؟ IntersectionObserver این را ارزان می‌گوید،
   بی‌آنکه لازم باشد در رویدادِ اسکرول هر بار موقعیتِ همه حساب شود.

   نوارِ بالا چسبان است و حدودِ ۸۶px از دید را می‌گیرد، پس مرزِ بالا
   همان‌قدر پایین آورده می‌شود — وگرنه بخشی که زیرِ نوار پنهان است
   «فعال» حساب می‌شد. */
(function(){
  const nav = document.getElementById("topnav");
  if(!nav || !("IntersectionObserver" in window)) return;
  const links = [...nav.querySelectorAll("a[href^='#']")];
  const byId = {};
  links.forEach(a => { byId[a.getAttribute("href").slice(1)] = a; });

  /* روی صفحهٔ باریک نوار می‌لغزد و تبِ فعال ممکن است بیرون از دید
     باشد؛ خودش را وسط می‌آورد. همان کاری که نوارِ کارتابل می‌کند. */
  const show = a => {
    if(!a || nav.scrollWidth <= nav.clientWidth + 2) return;
    try{ a.scrollIntoView({ behavior:"smooth", inline:"center", block:"nearest" }); }catch(e){}
  };

  let current = null;
  const mark = id => {
    if(id === current) return;
    current = id;
    links.forEach(a => a.classList.remove("on"));
    const a = byId[id];
    if(a){ a.classList.add("on"); show(a); }
  };

  /* از میانِ بخش‌هایی که همین حالا دیده می‌شوند بالاترین انتخاب
     می‌شود: وقتی دو بخش هم‌زمان در دیدند، آن که خوانده می‌شود
     بالایی است. ترتیب از خودِ منو می‌آید، نه از ترتیبِ رویدادها. */
  const order = links.map(a => a.getAttribute("href").slice(1));

  /* اول با IntersectionObserver نوشته بودمش و جواب نداد: با حاشیهٔ
     پایینی، کادرِ دید آن‌قدر کوچک می‌شد که بخش‌های آخر اصلاً داخلش
     نمی‌افتادند و منو روی «شروع» گیر می‌کرد. تنظیمِ آن حاشیه هم یعنی
     حدس زدنِ عددی که با بلند و کوتاه شدنِ بخش‌ها عوض می‌شود.

     این ساده‌تر است و حدس ندارد: «بخشِ جاری» آخرین بخشی است که سرش
     از زیرِ نوارِ بالا رد شده. هشت تا getBoundingClientRect در هر
     قابِ اسکرول هزینه‌ای ندارد. */
  const LINE = 96;                       /* کمی پایین‌ترِ نوارِ چسبان */
  const atEnd = () =>
    innerHeight + scrollY >= document.documentElement.scrollHeight - 4;

  const pick = () => {
    let best = null;
    for(const id of order){
      const el = document.getElementById(id);
      if(!el || el.hidden) continue;
      if(el.getBoundingClientRect().top <= LINE) best = id;
    }
    /* ته صفحه استثناست: آخرین بخش هیچ‌وقت سرش به آن خط نمی‌رسد،
       چون جایی برای اسکرول کردن نمانده. */
    if(atEnd()){
      for(let i = order.length - 1; i >= 0; i--){
        const el = document.getElementById(order[i]);
        if(el && !el.hidden){ best = order[i]; break; }
      }
    }
    if(best) mark(best);
  };

  let queued = false;
  const onScroll = () => {
    if(queued) return;
    queued = true;
    requestAnimationFrame(() => { queued = false; pick(); });
  };
  addEventListener("scroll", onScroll, { passive: true });
  addEventListener("resize", onScroll);
  pick();
})();

/* ---------- فرمِ تماس ----------
   پیام همان‌جا ذخیره می‌شود و در پنل دیده می‌شود؛ خبرش هم به هر دو
   ربات می‌رود. پس «رسید» را وقتی می‌گوییم که واقعاً ثبت شده باشد. */
document.getElementById("askForm").addEventListener("submit", async (e)=>{
  e.preventDefault();
  const btn = document.getElementById("askGo");
  const note = document.getElementById("askNote");
  const text = document.getElementById("askText").value.trim();
  const contact = document.getElementById("askContact").value.trim();
  note.textContent = "";
  if(!text){ note.textContent = "یک خط بنویسید تا بدانیم چه می‌خواهید."; return; }
  if(!contact){ note.textContent = "یک راهِ تماس بگذارید، وگرنه جوابی نمی‌شود داد."; return; }
  btn.disabled = true; btn.textContent = "…";
  try{
    const r = await fetch("/api/sl/contact", { method:"POST",
      headers:{ "Content-Type":"application/json" },
      body: JSON.stringify({ name: document.getElementById("askName").value.trim(),
                             contact, text }) });
    const d = await r.json().catch(()=>({}));
    if(r.ok && d.ok){
      document.getElementById("askForm").reset();
      note.textContent = "✅ رسید. به‌زودی از همان راهی که گفتید جواب می‌دهیم.";
    } else note.textContent = d.error || "نشد. کمی بعد دوباره امتحان کنید.";
  }catch(err){ note.textContent = "نشد. اتصالتان را ببینید و دوباره بفرستید."; }
  btn.disabled = false; btn.textContent = "بفرست";
});

/* ---------- پلن‌ها و سفارش ----------
   پلن‌ها از تنظیماتِ پنل می‌آیند. اگر پلنی تعریف نشده باشد، این بخش
   اصلاً نشان داده نمی‌شود — بهتر از یک فهرستِ خالیِ «به‌زودی». */
/* شغل‌ها و بخش‌هایشان از سرور می‌آیند (همان جایی که کارتابل از آن
   ساخته می‌شود). پیش از این یک نسخهٔ دستی هم این‌جا بود و با اضافه
   شدنِ هر شغل، یکی‌شان عقب می‌ماند. */
let JOBS = [], SITE = { extraPrice: 0, customPrice: 0 }, FREE = ["datetools"], VLB = {};
const faD = n => String(n).replace(/[0-9]/g, d=>"۰۱۲۳۴۵۶۷۸۹"[d]);
const money = n => faD(Number(n||0).toLocaleString("en-US")) + " تومان";
const escH = t => String(t==null?"":t).replace(/[<>&"]/g,
  c=>({"<":"&lt;",">":"&gt;","&":"&amp;",'"':"&quot;"}[c]));
let PLANS = [], PICKED = null;

function showPlans(plans){
  PLANS = plans || [];
  if(!PLANS.length) return;
  document.getElementById("buy").hidden = false;
  document.querySelectorAll(".buyLink").forEach(a=> a.hidden = false);
  document.getElementById("planList").innerHTML = PLANS.map((p,i)=>{
    const org = p.tier === "org";
    const base = Math.max(1, Number(p.baseSeats) || 1);
    const per  = Number(p.perSeat) || 0;
    /* زیرِ قیمت باید بگوید این عدد بابتِ چیست، وگرنه «۴ میلیون» کنارِ
       «۱ میلیون» گران به نظر می‌رسد بی‌آنکه معلوم باشد چند نفر است. */
    const per1 = org
      ? "برای " + faD(base) + " نفر" + (per ? " — هر نفرِ اضافه " + money(per) : "")
      : "برای هر کارتابل";
    return `
    <div class="plan${org ? " plan-org" : ""}">
      <h3>${escH(p.name)}</h3>
      <div class="price">${escH(money(p.price))}</div>
      <div class="per">${escH(per1)}</div>
      <div class="per">${p.days ? faD(p.days) + " روز" : "بی‌مهلت"}</div>
      <div class="pnote">${escH(p.note || "")}</div>
      <button class="btn btn-main" data-plan="${i}">انتخاب</button>
    </div>`;
  }).join("");

  const jobSel = document.getElementById("oJob");
  JOBS.forEach(j=>{
    const o = document.createElement("option"); o.value = j.id; o.textContent = j.label;
    jobSel.appendChild(o);
  });
  jobSel.addEventListener("change", paintSections);

  document.querySelectorAll("[data-plan]").forEach(b=>{
    b.onclick = ()=>{
      PICKED = PLANS[Number(b.dataset.plan)];
      COUPON = null;
      document.getElementById("oCpNote").textContent = "";
      document.getElementById("invoice").hidden = true;
      const f = document.getElementById("orderForm");
      f.hidden = false;
      document.getElementById("orderHead").textContent =
        "سفارشِ پلنِ «" + PICKED.name + "»";
      tuneForm();
      /* کدِ اتصال همان لحظه ساخته می‌شود تا کاربر منتظرِ کلیکِ دوم
         نماند؛ اگر قبلاً وصل شده، دست نمی‌خورد. */
      connPaint();
      if(!CONN.ready) connStart();
      sumUp();
      f.scrollIntoView({ behavior:"smooth", block:"center" });
    };
  });
  /* عددِ کمتر از پایه را همان‌جا می‌گوییم، نه سرِ ثبتِ سفارش —
     صفتِ min جلوی تایپ را نمی‌گیرد، فقط اعتبارسنجیِ فرم را. */
  document.getElementById("oSeats").addEventListener("input", ()=>{
    const el = document.getElementById("oSeats");
    const lo = seatMin();
    const n = Number(el.value) || 0;
    const note = document.getElementById("oSeatNote");
    note.textContent = (el.value !== "" && n < lo)
      ? "این پلن از " + faD(lo) + " نفر به بالاست." : "";
    el.classList.toggle("bad", el.value !== "" && n < lo);
    sumUp();
  });
  document.getElementById("oCpGo").addEventListener("click", applyCoupon);
  document.getElementById("oCoupon").addEventListener("keydown", e=>{
    if(e.key === "Enter"){ e.preventDefault(); applyCoupon(); }
  });
  document.getElementById("oCancel").onclick = ()=>{
    document.getElementById("orderForm").hidden = true; PICKED = null;
    connStop();
  };
}

let COUPON = null;   /* {code, off} — فقط بعد از تأییدِ سرور پر می‌شود */

/* کمترین تعدادِ این پلن. سازمانی از تعدادِ پایه شروع می‌شود. */
function seatMin(){
  if(!PICKED) return 1;
  return PICKED.tier === "org" ? Math.max(1, Number(PICKED.baseSeats) || 1) : 1;
}

function seatCount(){
  const n = Number(document.getElementById("oSeats").value) || 0;
  return Math.max(seatMin(), Math.min(200, n));
}

/* فرم را به نوعِ پلن تنظیم می‌کند. «شخصی» و «سازمانی» فیلدهای متفاوتی
   می‌خواهند: سازمانی نامِ سازمان و بخشِ مشترک دارد، و شمارشگرش «نفر»
   است نه «کارتابل». */
function tuneForm(){
  if(!PICKED) return;
  const org = PICKED.tier === "org";
  const base = Math.max(1, Number(PICKED.baseSeats) || 1);

  document.getElementById("oOrgName").hidden  = !org;
  document.getElementById("oSharedRow").hidden = !org;
  document.getElementById("oSeatLb").textContent = org ? "تعداد نفرات" : "تعداد کارتابل";

  /* سازمانی از تعدادِ پایه شروع می‌شود؛ کمتر از آن معنایی ندارد و
     قیمت را هم کم نمی‌کند، پس نگذاریم کاربر عددِ گمراه‌کننده بزند. */
  /* تعداد از پایهٔ همین پلن شروع می‌شود. اگر عددِ پلنِ قبلی بماند،
     کاربر کارتی را انتخاب می‌کند که «۴ میلیون» نوشته و فرم مبلغِ
     دیگری نشان می‌دهد — و دلیلش هیچ‌جا پیدا نیست. */
  const seat = document.getElementById("oSeats");
  seat.min = org ? String(base) : "1";
  seat.value = String(org ? base : 1);

  paintSections();
}

/* بخش‌های شغلِ انتخاب‌شده. آن‌هایی که در قیمت هستند تیکِ قفل دارند؛
   بقیه هرکدام قیمتِ خودش را نشان می‌دهد، و کنارِ هرکدام گزینهٔ
   «سفارشی» که هزینهٔ جداگانه دارد. */
/* قیمتِ یک بخش: اگر قیمتِ جدا دارد همان، وگرنه قیمتِ پیش‌فرض.
   همان قاعده‌ای که سرور دارد — این‌جا فقط برای نشان دادن. */
/* سرور قیمتِ هر بخش را حل‌شده می‌فرستد، پس این‌جا فقط خوانده می‌شود.
   پیش از این این تابع فرمولِ خودش را داشت و با سرور یکی نبود — آن‌جا
   قیمتِ پیش‌فرضِ هر بخش هم بود و این‌جا نه. نتیجه‌اش «۰ تومان» روی
   صفحه بود و عددی دیگر در فاکتور. */
function viewPrice(v){
  const own = Number((SITE.viewPrices || {})[v]);
  if(Number.isFinite(own) && own >= 0) return Math.round(own);
  return Math.max(0, Math.round(Number(SITE.extraPrice) || 0));
}

/* واحدِ شمارش: سازمانی «نفر» می‌شمارد و شخصی «کارتابل». یک جا نوشته
   شده تا در فهرستِ بخش‌ها و در فاکتور یکی باشد. */
function unitName(){
  return PICKED && PICKED.tier === "org" ? "نفر" : "کارتابل";
}

function paintSections(){
  const jid = document.getElementById("oJob").value;
  const job = JOBS.find(j => j.id === jid);
  const box = document.getElementById("oSecBox");
  const list = document.getElementById("oSecList");
  if(!job || !(job.views||[]).length){ box.hidden = true; list.innerHTML = ""; sumUp(); return; }

  box.hidden = false;
  /* سفارشی‌سازی یک‌بار حساب می‌شود، بخش‌ها نفر به نفر. چون این دو
     کنارِ هم‌اند و هر دو عدد دارند، باید در خودِ متن فرق بگذارند —
     وگرنه کاربر یکی را جای دیگری می‌خواند. */
  document.getElementById("oSecHint").textContent =
    SITE.customPrice ? "سفارشی‌سازیِ هر بخش " + money(SITE.customPrice) + " (یک‌بار)" : "";

  list.innerHTML = job.views.map(v=>{
    const free = FREE.indexOf(v) >= 0;
    const nm = VLB[v] || v;
    return `<label class="osec-item${free ? " free" : ""}">
      <input type="checkbox" data-view="${escH(v)}"${free ? " checked disabled" : ""}>
      <span class="osec-nm">${escH(nm)}</span>
      <span class="osec-pr">${free ? "در قیمت"
        : escH(money(viewPrice(v)) + " / " + unitName())}</span>
      ${free ? "" : `<label class="osec-cu"><input type="checkbox" data-custom="${escH(v)}" disabled>
         سفارشی</label>`}
    </label>`;
  }).join("");

  list.querySelectorAll("[data-view]").forEach(cb=>{
    cb.addEventListener("change", ()=>{
      /* «سفارشی» فقط وقتی معنا دارد که خودِ بخش خریده شده باشد. */
      const cu = list.querySelector('[data-custom="' + cb.dataset.view + '"]');
      if(cu){ cu.disabled = !cb.checked; if(!cb.checked) cu.checked = false; }
      sumUp();
    });
  });
  list.querySelectorAll("[data-custom]").forEach(cb=> cb.addEventListener("change", sumUp));
  sumUp();
}

/* بخش‌هایی که کاربر انتخاب کرده — رایگان‌ها شمرده نمی‌شوند. */
function pickedViews(){
  return [...document.querySelectorAll('#oSecList [data-view]')]
    .filter(cb => cb.checked && !cb.disabled).map(cb => cb.dataset.view);
}
function pickedCustoms(){
  return [...document.querySelectorAll('#oSecList [data-custom]')]
    .filter(cb => cb.checked && !cb.disabled).map(cb => cb.dataset.custom);
}

/* همان فرمولِ سرور. این‌جا فقط برای نشان دادن است؛ فاکتور را سرور
   می‌سازد و اگر جایی فرق کند، حرفِ سرور درست است. */
function calcTotal(){
  if(!PICKED) return { seatPart:0, extraPart:0, customPart:0, total:0 };
  const base = Math.max(0, Number(PICKED.price) || 0);
  const baseSeats = Math.max(1, Number(PICKED.baseSeats) || 1);
  const per = Math.max(0, Number(PICKED.perSeat) || 0);
  const seatPart = base + Math.max(0, seatCount() - baseSeats) * per;
  /* بخش‌ها نفر به نفر، سفارشی‌سازی یک‌بار — عینِ فرمولِ سرور. */
  const extraPart = seatCount() * pickedViews().reduce((t, v)=> t + viewPrice(v), 0);
  const customPart = pickedCustoms().length * Math.max(0, Number(SITE.customPrice) || 0);
  return { seatPart, extraPart, customPart, total: seatPart + extraPart + customPart };
}

function sumUp(){
  if(!PICKED) return;
  const b = calcTotal();
  const full = b.total;

  /* تفکیک، تا معلوم باشد این عدد از کجا آمده. */
  const rows = [];
  const unit = unitName();
  rows.push(["پایه — " + faD(seatCount()) + " " + unit, b.seatPart]);
  /* عدد بدونِ «× چند نفر» گیج‌کننده بود: کاربر قیمتِ کنارِ بخش را
     می‌دید و جمعِ دیگری در فاکتور. حالا ضرب در خودِ سطر نوشته است. */
  if(b.extraPart)  rows.push(["بخش‌های اضافه — " + faD(seatCount()) + " " + unit, b.extraPart]);
  if(b.customPart) rows.push(["سفارشی‌سازی — یک‌بار", b.customPart]);
  document.getElementById("oBill").innerHTML =
    rows.length > 1
      ? rows.map(r=>`<div><span>${escH(r[0])}</span><b>${escH(money(r[1]))}</b></div>`).join("")
      : "";

  const box = document.getElementById("oSum");
  if(COUPON && COUPON.off > 0 && COUPON.total === full){
    box.innerHTML = `<span class="was">${escH(money(full))}</span>` + escH(money(full - COUPON.off));
  } else {
    /* هر چیزی که مبلغ را عوض کند، تخفیفِ قبلی را بی‌اعتبار می‌کند. */
    if(COUPON && COUPON.total !== full){
      COUPON = null;
      const n = document.getElementById("oCpNote");
      n.className = "cpnote"; n.textContent = "مبلغ عوض شد — کد را دوباره اعمال کنید.";
    }
    box.textContent = money(full);
  }
}

async function applyCoupon(){
  if(!PICKED) return;
  const btn = document.getElementById("oCpGo");
  const note = document.getElementById("oCpNote");
  const code = document.getElementById("oCoupon").value.trim();
  note.className = "cpnote"; note.textContent = "";
  if(!code){ COUPON = null; sumUp(); return; }
  btn.disabled = true;
  try{
    const r = await fetch("/api/sl/coupon", { method:"POST",
      headers:{ "Content-Type":"application/json" },
      body: JSON.stringify({ code, plan: PICKED.name, seats: seatCount(),
        views: pickedViews(), customs: pickedCustoms() }) });
    const d = await r.json().catch(()=>({}));
    if(r.ok && d.ok){
      COUPON = { code: d.code, off: d.off, total: d.total };
      note.className = "cpnote good";
      note.textContent = "✅ کد اعمال شد — " + money(d.off) + " تخفیف.";
    } else {
      COUPON = null;
      note.className = "cpnote bad";
      note.textContent = d.error || "این کد کار نکرد.";
    }
  }catch(e){ note.className = "cpnote bad"; note.textContent = "نشد. دوباره امتحان کنید."; }
  btn.disabled = false;
  sumUp();
}

/* ---------- اتصال به رباتِ SLTech ----------
   سایت کدی می‌گیرد، کاربر با آن به ربات می‌رود و شماره‌اش را تأیید
   می‌کند، و ما هر چند ثانیه می‌پرسیم تمام شد یا نه. شماره هیچ‌وقت از
   این‌جا فرستاده نمی‌شود — سرور خودش از همان کد برش می‌دارد. */
const CONN = { nonce:"", ready:false, phone:"", name:"", via:"" };
let connTimer = null;

function connStop(){ if(connTimer){ clearInterval(connTimer); connTimer = null; } }

function connPaint(){
  const btns = document.getElementById("oConnBtns");
  const wait = document.getElementById("oConnWait");
  const okb  = document.getElementById("oConnOk");
  if(CONN.ready){
    btns.hidden = true; wait.hidden = true; okb.hidden = false;
    okb.innerHTML = "✅ وصل شدید — <b>" + escH(faD(CONN.phone)) + "</b>" +
      (CONN.name ? " (" + escH(CONN.name) + ")" : "") +
      ' <button type="button" class="linkish" id="oConnOff">تغییر</button>';
    document.getElementById("oConnOff").onclick = ()=>{
      connStop(); CONN.nonce=""; CONN.ready=false; CONN.phone=""; CONN.name="";
      document.getElementById("oConnNote").textContent = "";
      connPaint();
    };
    return;
  }
  okb.hidden = true; btns.hidden = false;
}

async function connStart(){
  const note = document.getElementById("oConnNote");
  const btns = document.getElementById("oConnBtns");
  note.textContent = "";
  btns.innerHTML = '<span class="conn-load">…</span>';
  try{
    const r = await fetch("/api/sl/bot/start", { method:"POST" });
    const d = await r.json().catch(()=>({}));
    if(!(r.ok && d.ok)){
      btns.innerHTML = "";
      note.textContent = d.error || "اتصال آماده نیست.";
      return;
    }
    CONN.nonce = d.nonce;
    const L = d.links || {};
    btns.innerHTML =
      (L.telegram ? `<a class="btn btn-main conn-b" target="_blank" rel="noopener" href="${escH(L.telegram)}">ادامه با تلگرام</a>` : "") +
      (L.bale ? `<a class="btn conn-b" target="_blank" rel="noopener" href="${escH(L.bale)}">ادامه با بله</a>` : "");
    document.getElementById("oConnWait").hidden = false;
    connStop();
    connTimer = setInterval(connPoll, 3000);
    setTimeout(connStop, 10 * 60000);
  }catch(e){ btns.innerHTML = ""; note.textContent = "نشد. اتصالتان را ببینید."; }
}

async function connPoll(){
  if(!CONN.nonce || CONN.ready) return connStop();
  try{
    const r = await fetch("/api/sl/bot/check?nonce=" + encodeURIComponent(CONN.nonce));
    const d = await r.json().catch(()=>({}));
    if(r.status === 410){ connStop(); CONN.nonce = "";
      document.getElementById("oConnWait").hidden = true;
      document.getElementById("oConnNote").textContent = "وقتش گذشت — دوباره بزنید."; return; }
    if(d && d.status === "ready"){
      connStop();
      CONN.ready = true; CONN.phone = d.phone || ""; CONN.name = d.name || ""; CONN.via = d.via || "";
      const nm = document.getElementById("oName");
      if(nm && !nm.value.trim() && CONN.name) nm.value = CONN.name;
      connPaint();
    }
  }catch(e){ /* شبکه لغزید؛ دورِ بعد */ }
}

document.getElementById("oConnAgain").onclick = connStart;

document.getElementById("orderForm").addEventListener("submit", async (e)=>{
  e.preventDefault();
  if(!PICKED) return;
  const note = document.getElementById("oNote2");
  const btn = document.getElementById("oGo");
  const g = id => document.getElementById(id).value.trim();
  note.textContent = "";
  if(!CONN.ready){ note.textContent = "اول با تلگرام یا بله وصل شوید."; 
    document.getElementById("oConn").scrollIntoView({behavior:"smooth", block:"center"}); return; }
  if(!g("oName")){ note.textContent = "نامتان را بنویسید."; return; }
  btn.disabled = true; btn.textContent = "…";
  try{
    const r = await fetch("/api/sl/order", { method:"POST",
      headers:{ "Content-Type":"application/json" },
      body: JSON.stringify({ plan: PICKED.name, name: g("oName"), nonce: CONN.nonce,
        /* قالبِ کارتابل از خودِ شغل می‌آید، نه از یک کشوی جدا — کاربر
           نباید بداند «مالی» یا «عمومی» یعنی چه؛ شغلش را می‌گوید. */
        kind: (JOBS.find(j=>j.id===g("oJob"))||{}).kind || "gen",
        job: g("oJob"), seats: g("oSeats"), note: g("oNote"),
        views: pickedViews(), customs: pickedCustoms(),
        orgName: g("oOrgName"), sharedNote: g("oSharedNote"),
        coupon: g("oCoupon") }) });
    const d = await r.json().catch(()=>({}));
    if(!(r.ok && d.ok)){ note.textContent = d.error || "نشد. کمی بعد دوباره."; }
    else showInvoice(d);
  }catch(err){ note.textContent = "نشد. اتصالتان را ببینید."; }
  btn.disabled = false; btn.textContent = "ثبت سفارش";
});

function showInvoice(d){
  document.getElementById("orderForm").hidden = true;
  const box = document.getElementById("invoice");
  const card = d.card
    ? `<div class="kv"><span>شمارهٔ کارت</span><b>${escH(d.card.replace(/(\d{4})(?=\d)/g, "$1-"))}</b></div>
       ${d.cardName ? `<div class="kv"><span>به نام</span><b>${escH(d.cardName)}</b></div>` : ""}`
    : `<div class="kv"><span>شمارهٔ کارت</span><b>در پیام به شما داده می‌شود</b></div>`;
  const at = u => String(u||"").replace(/^@/,"").replace(/^https?:\/\/[^/]+\//,"");
  const ways = [];
  if(d.telegram) ways.push(`<a href="https://t.me/${escH(at(d.telegram))}" target="_blank" rel="noopener">تلگرام</a>`);
  if(d.bale) ways.push(`<a href="https://ble.ir/${escH(at(d.bale))}" target="_blank" rel="noopener">بله</a>`);
  box.innerHTML = `
    <h3>✅ سفارشتان ثبت شد</h3>
    <div class="kv"><span>شمارهٔ فاکتور</span><span class="no">${escH(d.id)}</span></div>
    <div class="kv"><span>پلن</span><b>${escH(d.plan)}</b></div>
    ${d.discount > 0
      ? `<div class="kv"><span>مبلغ پلن</span><b>${escH(money(d.full))}</b></div>
         <div class="kv"><span>تخفیف (${escH(d.coupon)})</span><b>${escH(money(d.discount))}</b></div>
         <div class="kv"><span>قابل پرداخت</span><b>${escH(money(d.price))}</b></div>`
      : `<div class="kv"><span>مبلغ</span><b>${escH(money(d.price))}</b></div>` +
        (d.couponError ? `<div class="kv"><span>کد تخفیف</span><b>${escH(d.couponError)}</b></div>` : ``)}
    ${card}
    <ol class="steps2">
      <li>مبلغ را به همان کارت واریز کنید.</li>
      <li>تصویرِ فیش را همراهِ شمارهٔ فاکتور <b>${escH(d.id)}</b> برای ما بفرستید
          ${ways.length ? "— " + ways.join(" یا ") : ""}.</li>
      <li>تأیید که شد، کارتابلتان ساخته می‌شود و نام کاربری و رمزش را می‌گیرید.</li>
    </ol>
    <p style="color:var(--ink-faint); font-size:12.5px; margin:12px 0 0;">
      این شماره را یادداشت کنید؛ بدونش فیشتان معلوم نیست مالِ کدام سفارش است.</p>`;
  box.hidden = false;
  box.scrollIntoView({ behavior:"smooth", block:"center" });
}

/* راه‌های تماس از تنظیماتِ پنل می‌آید، نه از متنِ ثابتِ این صفحه. */
(async function ways(){
  try{
    const r = await fetch("/api/sl/site");
    const d = await r.json().catch(()=>({}));
    const s = (d && d.site) || {};
    const box = document.getElementById("ways");
    const esc = t => String(t==null?"":t).replace(/[<>&"]/g, c=>({"<":"&lt;",">":"&gt;","&":"&amp;",'"':"&quot;"}[c]));
    const link = (href, label)=> `<a href="${esc(href)}" target="_blank" rel="noopener">${esc(label)}</a>`;
    const at = u => String(u||"").replace(/^@/,"").replace(/^https?:\/\/[^/]+\//,"");
    const out = [];
    if(s.telegram) out.push(link("https://t.me/" + at(s.telegram), "تلگرام"));
    if(s.bale)     out.push(link("https://ble.ir/" + at(s.bale), "بله"));
    if(s.phone)    out.push(link("tel:" + s.phone, s.phone));
    if(s.email)    out.push(link("mailto:" + s.email, s.email));
    box.innerHTML = out.join("");
    SITE = s;
    JOBS = Array.isArray(d.jobs) ? d.jobs : [];
    FREE = Array.isArray(d.freeViews) ? d.freeViews : ["datetools"];
    VLB  = d.viewLabels || {};
    showPlans(s.plans);
  }catch(e){ /* نبودنش صفحه را خراب نمی‌کند */ }
})();

/* لینک‌های داخلِ صفحه نرم بروند، ولی نوارِ چسبانِ بالا رویشان نیفتد. */
document.querySelectorAll('a[href^="#"]').forEach(a=>{
  a.addEventListener("click", e=>{
    const el = document.querySelector(a.getAttribute("href"));
    if(!el) return;
    e.preventDefault();
    const y = el.getBoundingClientRect().top + window.scrollY - 70;
    window.scrollTo({ top:y, behavior:"smooth" });
  });
});
</script>

</body>
</html>
