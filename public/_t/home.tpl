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
section{ padding:52px 0; }
.sec-head{ margin-bottom:28px; }
.sec-head h2{ font-size:25px; margin:0 0 8px; }
.sec-head p{ color:var(--ink-soft); margin:0; max-width:640px; }
@media (max-width:640px){ section{ padding:38px 0; } .sec-head h2{ font-size:21px; } }

.grid{ display:grid; gap:15px; }
.g2{ grid-template-columns:repeat(2, 1fr); }
.g3{ grid-template-columns:repeat(3, 1fr); }
.g4{ grid-template-columns:repeat(auto-fill, minmax(215px, 1fr)); }
@media (max-width:860px){ .g3{ grid-template-columns:1fr 1fr; } }
@media (max-width:620px){ .g2, .g3{ grid-template-columns:1fr; } }

.card{ background:var(--white); border:1px solid var(--line); border-radius:var(--r-lg);
  padding:21px; box-shadow:var(--sh-1); }
.card h3{ margin:0 0 7px; font-size:16.5px; display:flex; align-items:center; gap:8px; }
.card p{ margin:0; color:var(--ink-soft); font-size:13.8px; }
.card .ic{ font-size:19px; line-height:1; }

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
  border:1px solid var(--line); border-radius:var(--r); padding:12px 14px; }
.job .n{ font-weight:600; font-size:14px; flex:1; min-width:0; }
.job .c{ font-size:11.5px; color:var(--brand-ink); background:var(--brand-soft);
  padding:2px 9px; border-radius:999px; white-space:nowrap; }
.job .e{ font-size:17px; line-height:1; }

/* ---------- گام‌ها ---------- */
.steps{ counter-reset:s; display:grid; gap:14px; grid-template-columns:repeat(3,1fr); }
@media (max-width:760px){ .steps{ grid-template-columns:1fr; } }
.step{ background:var(--white); border:1px solid var(--line); border-radius:var(--r-lg);
  padding:21px; position:relative; }
.step::before{ counter-increment:s; content:counter(s);
  position:absolute; inset-block-start:-13px; inset-inline-start:21px;
  width:30px; height:30px; border-radius:50%; display:grid; place-items:center;
  background:linear-gradient(145deg, var(--brand), var(--brand-deep)); color:#fff;
  font-weight:700; font-size:14px; box-shadow:0 3px 10px rgba(18,62,128,.3); }
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
.plans{ display:grid; gap:14px; grid-template-columns:repeat(auto-fit, minmax(230px, 1fr)); }
.plan{ background:var(--white); border:1px solid var(--line); border-radius:var(--r-lg);
  padding:22px; text-align:center; box-shadow:var(--sh-1); }
.plan h3{ margin:0 0 4px; font-size:17px; }
.plan .price{ font-size:25px; font-weight:700; color:var(--brand); margin:10px 0 2px; }
.plan .per{ font-size:12.5px; color:var(--ink-faint); }
.plan .pnote{ font-size:13px; color:var(--ink-soft); margin:10px 0 16px; min-height:38px; }
.order{ max-width:620px; margin:22px auto 0; }
.order h3{ margin:0 0 14px; font-size:16px; }
.order .ask-row{ display:grid; gap:10px; grid-template-columns:1fr 1fr; margin-bottom:10px; }
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
</style>
</head>
<body>

<div class="top"><div class="wrap">
  <a class="brand" href="/">
    <img src="/icon-sl.3.png" alt="SLTech" width="38" height="38">
    <b>SLTech</b>
  </a>
  <div class="sp"></div>
  <button class="icon-btn" id="themeBtn" title="تم روز و شب" aria-label="تم روز و شب">🌙</button>
  <a class="btn btn-main" href="/login">ورود به کارتابل</a>
</div></div>

<div class="wrap">

  <header class="hero">
    <h1>برنامهٔ ماهِ شما، <span class="hl">یک‌جا</span> — نه در ذهن، نه در تلگرام</h1>
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
        <p>چند تا در تلگرام، چند تا روی کاغذ، چند تا در یک اکسل روی لپ‌تاپ. هیچ‌کدام
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
      <p>این هفت‌تا ستون‌فقرات‌اند و در همهٔ کارتابل‌ها هستند.</p>
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
        <p>همان هفت بخشِ اصلی، بدون چیزِ اضافه. اگر شغلتان در فهرستِ پایین هست،
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
      <div class="ask-row">
        <input type="text" id="oName" placeholder="نام و نام خانوادگی" autocomplete="name">
        <input type="text" id="oContact" placeholder="تلگرام، شماره یا ایمیل" dir="ltr" autocomplete="off">
      </div>
      <div class="ask-row">
        <select id="oKind">
          <option value="gen">کارتابل عمومی</option>
          <option value="it">کارتابل مدیر IT</option>
          <option value="fin">کارتابل مالی</option>
        </select>
        <select id="oJob"><option value="">— چک‌لیست آماده (اختیاری) —</option></select>
      </div>
      <div class="ask-row">
        <input type="number" id="oSeats" min="1" max="200" value="1" dir="ltr" placeholder="چند نفر؟">
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
      <p>رمزِ ورود از همان صفحهٔ ورود بازیابی می‌شود و رمزِ تازه فقط به تلگرامِ خودتان
         می‌رود. برای «دیتای شخصی» هم یک راهِ اضطراری هست، به شرطی که از قبل تنظیم شده باشد.</p>
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
const JOB_LIST = [
  ["hr","منابع انسانی"], ["sales","فروش و بازاریابی"], ["acc","حسابداری"],
  ["support","پشتیبانی فنی و هلپ‌دسک"], ["ceo","مدیرعامل و مدیریت کلان"],
  ["wh","انبار و تدارکات"], ["pm","مدیریت پروژه"], ["prod","تولید و کارخانه"],
  ["marketing","بازاریابی دیجیتال و محتوا"], ["qc","کنترل کیفیت"],
  ["clinic","مطب و کلینیک"], ["logistics","حمل‌ونقل و توزیع"],
  ["procure","خرید خارجی و ترخیص"], ["retail","فروشگاه و خرده‌فروشی"],
  ["legal","حقوقی و قراردادها"], ["office","امور اداری و دفتری"]
];
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
  document.getElementById("planList").innerHTML = PLANS.map((p,i)=>`
    <div class="plan">
      <h3>${escH(p.name)}</h3>
      <div class="price">${escH(money(p.price))}</div>
      <div class="per">${p.days ? faD(p.days) + " روز" : "بی‌مهلت"}</div>
      <div class="pnote">${escH(p.note || "")}</div>
      <button class="btn btn-main" data-plan="${i}">انتخاب</button>
    </div>`).join("");

  const jobSel = document.getElementById("oJob");
  JOB_LIST.forEach(([id,label])=>{
    const o = document.createElement("option"); o.value = id; o.textContent = label;
    jobSel.appendChild(o);
  });

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
      sumUp();
      f.scrollIntoView({ behavior:"smooth", block:"center" });
    };
  });
  document.getElementById("oSeats").addEventListener("input", sumUp);
  document.getElementById("oCpGo").addEventListener("click", applyCoupon);
  document.getElementById("oCoupon").addEventListener("keydown", e=>{
    if(e.key === "Enter"){ e.preventDefault(); applyCoupon(); }
  });
  document.getElementById("oCancel").onclick = ()=>{
    document.getElementById("orderForm").hidden = true; PICKED = null;
  };
}

let COUPON = null;   /* {code, off} — فقط بعد از تأییدِ سرور پر می‌شود */

function seatCount(){
  return Math.max(1, Math.min(200, Number(document.getElementById("oSeats").value)||1));
}

function sumUp(){
  if(!PICKED) return;
  const full = PICKED.price * seatCount();
  const box = document.getElementById("oSum");
  if(COUPON && COUPON.off > 0 && COUPON.total === full){
    box.innerHTML = `<span class="was">${escH(money(full))}</span>` + escH(money(full - COUPON.off));
  } else {
    /* تعداد که عوض شود، تخفیفِ قبلی دیگر مالِ این مبلغ نیست. */
    if(COUPON && COUPON.total !== full){
      COUPON = null;
      const n = document.getElementById("oCpNote");
      n.className = "cpnote"; n.textContent = "تعداد عوض شد — کد را دوباره اعمال کنید.";
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
      body: JSON.stringify({ code, plan: PICKED.name, seats: seatCount() }) });
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

document.getElementById("orderForm").addEventListener("submit", async (e)=>{
  e.preventDefault();
  if(!PICKED) return;
  const note = document.getElementById("oNote2");
  const btn = document.getElementById("oGo");
  const g = id => document.getElementById(id).value.trim();
  note.textContent = "";
  if(!g("oName")){ note.textContent = "نامتان را بنویسید."; return; }
  if(!g("oContact")){ note.textContent = "یک راهِ تماس بگذارید."; return; }
  btn.disabled = true; btn.textContent = "…";
  try{
    const r = await fetch("/api/sl/order", { method:"POST",
      headers:{ "Content-Type":"application/json" },
      body: JSON.stringify({ plan: PICKED.name, name: g("oName"), contact: g("oContact"),
        kind: g("oKind"), job: g("oJob"), seats: g("oSeats"), note: g("oNote"),
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
