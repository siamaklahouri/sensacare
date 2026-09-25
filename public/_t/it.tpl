<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="icon" type="image/png" href="{{ICON}}">
<link rel="apple-touch-icon" href="{{ICON}}">
<script>
/* تم ذخیره‌شده را پیش از رسم شدن صفحه می‌گذاریم؛ وگرنه صفحهٔ ورود
   روشن می‌ماند و بعد از ورود یک دفعه تاریک می‌شود. */
try{ if(localStorage.getItem("{{STORE}}" + ":theme") === "dark")
  document.documentElement.setAttribute("data-theme","dark"); }catch(e){}
</script>
<script>
/* چک‌لیستِ آمادهٔ شغلی که ادمین برای این کارتابل انتخاب کرده.
   فقط دانهٔ اولیه است: بعد از اولین ذخیره، داده مالِ کاربر است. */
window.KARTABL_JOB = {{JOBSEED}};
/* بخش‌های «دیتای شخصی» که ادمین برای این کاربر باز گذاشته. */
window.KARTABL_VAULT = {{VAULTSECS}};
window.KARTABL_SLUG  = "{{SLUG}}";
/* بخش‌هایی که ادمین برای این کاربر بسته است. */
window.KARTABL_OFF = {{FEATOFF}};
/* تاریخِ پایانِ مهلت. صفر یعنی بی‌مهلت. */
window.KARTABL_UNTIL = {{UNTIL}};
</script>
<title>{{TITLE}}</title>
<style>
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:400;font-display:swap;
  src:url(/f/Vazirmatn-Regular.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:500;font-display:swap;
  src:url(/f/Vazirmatn-Medium.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:600;font-display:swap;
  src:url(/f/Vazirmatn-SemiBold.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:700;font-display:swap;
  src:url(/f/Vazirmatn-Bold.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:800;font-display:swap;
  src:url(/f/Vazirmatn-ExtraBold.2.woff2) format("woff2")}
</style>
<link rel="preload" as="font" type="font/woff2" href="/f/Vazirmatn-Regular.2.woff2" crossorigin>
{{PART:gatecss}}
<style>
  :root{
    --paper:#EEF2F6;
    --paper-deep:#E2E8EE;
    --ink:#0B2545;
    --ink-soft:#3E5164;
    --ink-faint:#8592A0;
    /* رنگِ هویت از لوگوی SLTech می‌آید، همان‌که پنل و صفحهٔ اصلی دارند. */
    --brass:#1A4FA3;
    --brass-deep:#123E80;
    --brass-bg:#E4EAF7;
    --green:#2F6B4F;
    --green-bg:#E3EFE7;
    --amber:#C98A2C;
    --amber-bg:#FBF1DF;
    --red:#A6222B;
    --red-bg:#F6E1E2;
    --teal:#0F6E63;
    --teal-bg:#E1EEEC;
    --purple:#5B3E8C;
    --purple-bg:#EAE4F2;
    --line:#DCE3E9;
    --card-border:#E1E7EC;
    --white:#FFFFFF;
    /* رنگ لهجهٔ کارت‌ها — در تم شب مقدار دیگری می‌گیرند (پایین شیوه‌نامه) */
    --c1:#0B9B95; --t1:#E2F3F2;
    --c2:#B07813; --t2:#F8F0DC;
    --c3:#6A45A8; --t3:#EDE7F5;
    --c4:#1E7A4A; --t4:#E3EFE7;
    --bad:#A6222B; --bad-bg:#F6E1E2; --bad-ink:#8E1D25;
    /* «جوهر» رنگ‌ها از خودِ رنگ جداست: همین رنگ وقتی متن می‌شود در شب باید
       روشن شود، ولی وقتی پس‌زمینهٔ دکمه است باید تیره بماند تا متنِ سفیدش
       خوانا بماند. --deep هم همان سرمه‌ایِ سطح‌هاست که نباید با متن قاطی شود. */
    --deep:#0B2545;
    --brass-ink:#14458F;
    --red-ink:#A6222B;
    --green-ink:#2F6B4F;
    --amber-ink:#C98A2C;
    --teal-ink:#0F6E63;
    --purple-ink:#5B3E8C;
    --font-display:'Vazirmatn', Tahoma, 'Segoe UI', 'Arial', sans-serif;
    --font-body:'Vazirmatn', Tahoma, 'Segoe UI', 'Arial', sans-serif;
    --radius:14px;
    --radius-sm:10px;
    --shadow: 0 1px 2px rgba(11,37,69,.05), 0 6px 18px rgba(11,37,69,.06);
    --shadow-lg: 0 4px 12px rgba(11,37,69,.08), 0 18px 40px rgba(11,37,69,.10);
  }
  *{box-sizing:border-box;}
  html,body{margin:0;padding:0;height:100%;}
  body{
    font-family:var(--font-body);
    background:
      radial-gradient(1200px 500px at 100% -5%, rgba(14,139,139,.06), transparent 60%),
      radial-gradient(1000px 480px at -10% 0%, rgba(91,62,140,.05), transparent 55%),
      var(--paper);
    background-attachment:fixed;
    color:var(--ink);
    min-height:100vh;
    -webkit-font-smoothing:antialiased;
  }
  ::selection{ background:var(--brass); color:#fff; }



/* ---------- هشدارِ پایانِ مهلت ----------
   وقتی یک هفته بیشتر نمانده، بعد از هر ورود یک بار گفته می‌شود. */
.exp-ov{ position:fixed; inset:0; z-index:88; display:flex; align-items:center;
  justify-content:center; padding:20px; background:rgba(11,37,69,.55); }
.exp-ov[hidden]{ display:none; }
.exp-box{ background:var(--white); border:1px solid var(--line);
  border-radius:var(--radius); box-shadow:var(--shadow-lg); padding:28px 24px;
  width:100%; max-width:390px; text-align:center; }
.exp-ic{ font-size:38px; line-height:1; margin-bottom:10px; }
.exp-box h3{ font-family:var(--font-display); font-size:16.5px; margin:0 0 8px; color:var(--ink); }
.exp-n{ font-size:30px; font-weight:800; color:var(--amber-ink); line-height:1.4;
  letter-spacing:-.02em; }
.exp-box p{ font-size:12.5px; color:var(--ink-soft); line-height:2.05; margin:6px 0 18px; }
.exp-box button{ width:100%; padding:11px; border:0; border-radius:var(--radius-sm);
  background:var(--brass); color:#fff; font-family:var(--font-body); font-size:13.5px;
  font-weight:600; cursor:pointer; }
.exp-box button:hover{ background:var(--brass-deep); }
  /* ---------- بخش تنظیمات و نوار تداخل نسخه ---------- */
  .set-h{ font-family:var(--font-display); font-size:15px; margin:0 0 6px; color:var(--ink); }
  .set-p{ margin:0 0 14px; font-size:12.5px; color:var(--ink-soft); line-height:2; }
  .set-grid{ display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:12px; margin-bottom:12px; }
  .set-grid label{ display:flex; flex-direction:column; gap:6px; font-size:12px; color:var(--ink-soft); }
  .set-grid input{
    font-family:var(--font-body); font-size:13px; padding:9px 11px;
    border:1px solid var(--line); border-radius:9px; background:var(--paper); color:var(--ink);
  }
  .set-grid input:focus{ outline:none; border-color:var(--brass); background:var(--white); }
  .set-row{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  .set-state{ font-size:12px; color:var(--ink-faint); }
  .set-state.ok{ color:var(--green-ink); font-weight:600; }
  .set-state.err{ color:var(--red-ink); font-weight:600; }
  .set-hr{ border:0; border-top:1px solid var(--line); margin:16px 0; }

  #syncConflict{
    position:fixed; inset-inline:0; bottom:0; z-index:9000;
    background:var(--amber-bg); border-top:1px solid var(--amber);
    padding:12px 18px; display:flex; align-items:center; gap:12px; flex-wrap:wrap;
    font-size:12.5px; color:var(--ink); box-shadow:0 -4px 18px rgba(11,37,69,.10);
  }
  #syncConflict button{
    font-family:var(--font-body); font-size:12px; font-weight:600; cursor:pointer;
    padding:7px 14px; border:1px solid var(--amber); border-radius:8px;
    background:var(--white); color:var(--ink);
  }

  /* ---------- Top bar ----------
     نوار بالا یک تختهٔ سرمه‌ایِ پررنگ بود و از تمامِ صفحه سنگین‌تر می‌زد؛
     چشم اول می‌رفت سراغِ نوار، نه سراغِ کار. حالا مثل پنل مدیر کاغذیِ
     مات است: یک خط نازک زیرش، متنِ جوهری، و رنگِ برند فقط جایی که باید
     دیده شود. */
  .topbar{
    height:70px;
    background:color-mix(in srgb, var(--white) 86%, transparent);
    backdrop-filter:blur(10px) saturate(1.3);
    color:var(--ink);
    display:flex;
    align-items:center;
    justify-content:space-between;
    padding:0 28px;
    box-shadow:0 1px 2px rgba(11,37,69,.05);
    position:sticky; top:0; z-index:40;
    border-bottom:1px solid var(--card-border);
  }
  @supports not (backdrop-filter: blur(1px)){ .topbar{ background:var(--white); } }
  .brand{ display:flex; align-items:center; gap:12px; }
  /* روی کاغذِ روشن، نشان گِرد بریده می‌شود تا مثل یک مستطیلِ چسبانده‌شده
     به نظر نرسد — همان کاری که پنل مدیر و صفحهٔ ورود می‌کنند. */
  .brand .mark{
    height:42px; width:42px; flex:none; display:block;
    border-radius:50%; object-fit:cover;
    box-shadow:0 3px 10px rgba(18,46,110,.22);
  }
  .brand .titles{ line-height:1.15; }
  .brand h1{ font-family:var(--font-display); font-size:18px; margin:0; font-weight:700; letter-spacing:.2px; color:var(--ink); }
  /* این سه برچسبِ ریز روی زمینهٔ روشن نشسته‌اند؛ با --ink-faint کنتراستشان
     ۳:۱ می‌شد که برای متنِ ۱۱ پیکسلی کم است. یک پله تیره‌تر. */
  .brand small{ color:var(--ink-soft); font-size:11.5px; }
  .period{ display:flex; align-items:center; gap:8px; }
  .period input{
    font-family:var(--font-body); font-size:13px;
    background:var(--white); border:1px solid var(--card-border);
    color:var(--ink); border-radius:9px; padding:7px 10px; width:88px; text-align:center;
  }
  .period input::placeholder{ color:var(--ink-faint); }
  .period label{ font-size:12px; color:var(--ink-faint); }
  .period select{
    font-family:var(--font-body); font-size:13px;
    background:var(--white); border:1px solid var(--card-border);
    color:var(--ink); border-radius:9px; padding:7px 10px; min-width:120px; text-align:center;
  }
  .period select option{ color:var(--ink); }
{{PART:tablecss}}
  .mpop-note{ font-size:11.5px; color:var(--red-ink,#A6222B); line-height:1.9; min-height:19px; }


  /* ---------- پهنای ستون‌ها ---------- */
  .tsz-grip{
    position:absolute; top:0; bottom:0; inset-inline-end:0; width:9px;
    cursor:col-resize; user-select:none; touch-action:none;
  }
  .tsz-grip:hover{ background:var(--brass); opacity:.45; }
  .tsz-bar{ display:flex; justify-content:flex-end; margin:0 0 6px; }
  .tsz-fit{
    font-family:var(--font-body); font-size:11px; padding:4px 9px; border-radius:7px;
    border:1px solid var(--card-border); background:transparent; color:var(--ink-faint);
    cursor:pointer; white-space:nowrap;
  }
  .tsz-fit:hover{ border-color:var(--brass); color:var(--brass); }
  /* جدولی که موتورِ پهنا رویش سوار است: خانه‌ها از ستونِ خودشان
     بیرون نمی‌زنند، و کادرِ داخلِ خانه تا لبهٔ ستون پُر می‌شود — وگرنه
     کشویی‌ای به پهنای پنجاه پیکسل وسطِ ستونی سیصد پیکسلی شناور
     می‌ماند و ستون «گشاد» به نظر می‌رسد. */
  .tsz-on th, .tsz-on td{ overflow:hidden; }
  .tsz-on tbody td > input, .tsz-on tbody td > select,
  .tsz-on tbody td > textarea{ width:100%; max-width:100%; box-sizing:border-box; }
  @media print{ .tsz-bar, .tsz-grip{ display:none !important; } }

  /* ---------- Shell ---------- */
  .shell{ display:flex; align-items:flex-start; min-height:calc(100vh - 70px); }
  .sidebar{
    width:216px; flex:0 0 216px;
    padding:22px 14px;
    position:sticky; top:70px;
    height:calc(100vh - 70px);
    overflow:hidden;
    border-left:1px solid rgba(11,37,69,.07);
    background:linear-gradient(180deg, rgba(255,255,255,.55), rgba(255,255,255,.15));
    backdrop-filter:blur(4px);
    display:flex; flex-direction:column;
  }
  .nav-label{
    font-size:10.5px; font-weight:700; color:var(--ink-faint); letter-spacing:.6px;
    padding:0 12px; margin-bottom:8px; text-transform:uppercase;
  }
  .navbtn{
    display:flex; align-items:center; gap:11px;
    width:100%; text-align:right; border:none; background:transparent;
    font-family:var(--font-body); font-size:13.6px; font-weight:600; color:var(--ink-soft);
    padding:10px 12px; border-radius:11px; cursor:pointer; margin-bottom:3px;
    transition:background .15s, color .15s, transform .12s, box-shadow .15s;
    position:relative;
  }
  /* آیکن‌ها قبلاً هر کدام داخل یک مربعِ خاکستری بودند؛ چهارده مربعِ
     پشتِ هم، ستون را شلوغ می‌کرد و قدیمی به نظر می‌رسید. حالا آیکن
     خودش تنهاست و فقط پررنگی‌اش عوض می‌شود. */
  .navbtn .ic{
    font-size:16px; width:22px; height:22px; flex:0 0 22px;
    display:flex; align-items:center; justify-content:center;
    background:none; opacity:.62; transition:opacity .15s, transform .15s;
  }
  .navbtn:hover{ background:rgba(11,37,69,.05); transform:translateX(-2px); }
  .navbtn:hover .ic{ opacity:.9; }
  /* حالتِ فعال هم روشن شد: یک قرصِ کم‌رنگِ رنگِ برند به‌جای تختهٔ
     سرمه‌ای، تا با بقیهٔ صفحه هم‌وزن بماند. */
  .navbtn.active{
    background:var(--brass-bg); color:var(--brass-ink); box-shadow:none; transform:none;
  }
  .navbtn.active .ic{ opacity:1; }
  .navbtn.active::before{
    content:""; position:absolute; inset-inline-start:0; top:50%; transform:translateY(-50%);
    width:3px; height:20px; border-radius:0 3px 3px 0; background:var(--brass);
  }
  .navbtn-lock.active{ background:var(--purple-bg); color:var(--purple-ink); }
  .navbtn-lock.active::before{ background:var(--purple); }
  /* فهرست بخش‌ها هرقدر بلند شود خودش اسکرول می‌شود و پاورقی — پشتیبان،
     بازیابی و خروج — همیشه دمِ دست می‌ماند. قبلاً روی نمایشگر کوتاه
     همین دکمه‌ها از ته ستون می‌زدند بیرون. */
  .nav-list{
    flex:1 1 auto; min-height:0; overflow-y:auto;
    display:flex; flex-direction:column;
  }
  .sidebar-foot{
    flex:0 0 auto; padding-top:14px; border-top:1px solid rgba(11,37,69,.08);
    font-size:11px; color:var(--ink-faint); line-height:1.7;
    display:flex; flex-direction:column; gap:7px;
  }
  .sidebar-foot .save-hint{ min-height:15px; }
  .foot-actions{ display:flex; gap:6px; }
  .sidebar-foot .btn{ padding:7px 6px; font-size:11px; }
  .foot-actions .btn{ flex:1; }
  .foot-lock{ width:100%; }



  .content{ flex:1; padding:26px 30px 60px; min-width:0; }
  .view{ display:none; }
  .view.active{ display:block; animation:fade .25s ease; }
  @keyframes fade{ from{opacity:0; transform:translateY(4px);} to{opacity:1; transform:none;} }

  .section-title{
    font-family:var(--font-display); font-size:21px; font-weight:700; color:var(--ink);
    margin:2px 0 4px; position:relative; padding-right:15px;
  }
  .section-title::before{
    content:""; position:absolute; right:0; top:2px; bottom:2px; width:5px; border-radius:3px;
    background:linear-gradient(180deg,var(--brass),var(--brass-deep));
    box-shadow:0 2px 8px rgba(14,139,139,.35);
  }
  .section-sub{ color:var(--ink-faint); font-size:12.5px; margin-bottom:18px; }

  /* ---------- Cards ---------- */
  .grid-auto{ display:grid; gap:16px;
    grid-template-columns:repeat(auto-fit, minmax(260px,1fr)); }
  .cards{
    display:grid; grid-template-columns:repeat(auto-fit, minmax(148px,1fr)); gap:12px; margin-bottom:22px;
  }
  /* کاشی‌ها قبلاً شش گرادیانِ اشباع بودند و کنار هم مثل تبلیغ به نظر
     می‌رسیدند. حالا کارتِ سفیدند با یک نوارِ رنگی و عددِ رنگی: رنگ
     همان معنی را می‌رساند، بی‌آنکه صفحه را فریاد بزند. */
  .stat{
    border-radius:var(--radius); padding:15px 16px 16px;
    background:var(--white); color:var(--ink);
    border:1px solid var(--card-border);
    box-shadow:0 1px 2px rgba(11,37,69,.04), 0 6px 18px rgba(11,37,69,.06);
    position:relative; overflow:hidden; transition:transform .18s, box-shadow .18s;
    animation:statIn .4s ease backwards;
  }
  .stat::before{
    content:""; position:absolute; inset:0 0 auto 0; height:3px;
    background:var(--tone, var(--brass));
  }
  .stat:nth-child(1){ animation-delay:.02s; }
  .stat:nth-child(2){ animation-delay:.07s; }
  .stat:nth-child(3){ animation-delay:.12s; }
  .stat:nth-child(4){ animation-delay:.17s; }
  .stat:nth-child(5){ animation-delay:.22s; }
  .stat:nth-child(6){ animation-delay:.27s; }
  @keyframes statIn{ from{opacity:0; transform:translateY(8px);} to{opacity:1; transform:none;} }
  .stat:hover{ transform:translateY(-2px);
    box-shadow:0 2px 6px rgba(11,37,69,.06), 0 14px 30px rgba(11,37,69,.10); }

  /* کارتِ خوش‌آمد یک تختهٔ سرمه‌ایِ تمام‌عرض بود و بالای کارت‌های سفیدِ
     پایین‌تر مثل بنرِ تبلیغ می‌نشست. حالا خودش هم کارت است: کاغذِ روشن،
     یک نوارِ باریکِ رنگِ برند لبهٔ شروع، و ساعت و تاریخ دو چیپِ آرام. */
  .dash-hero{
    background:var(--white); color:var(--ink);
    border:1px solid var(--card-border);
    border-radius:var(--radius); padding:18px 22px; margin-bottom:18px;
    display:flex; align-items:center; justify-content:space-between; gap:14px; flex-wrap:wrap;
    box-shadow:var(--shadow); position:relative; overflow:hidden;
  }
  .dash-hero::after{
    content:""; position:absolute; inset-block:0; inset-inline-start:0;
    width:3px; background:var(--brass); pointer-events:none;
  }
  .dash-hero .dh-greet{ font-family:var(--font-display); font-size:16px; font-weight:700; color:var(--ink); position:relative; z-index:1; }
  .dash-hero .dh-sub{ font-size:11.5px; color:var(--ink-soft); margin-top:4px; position:relative; z-index:1; }
  .dash-hero .dh-date{
    background:var(--paper); border:1px solid var(--card-border); border-radius:12px;
    padding:9px 18px; font-size:11px; font-weight:600; color:var(--ink-soft);
    text-align:center; position:relative; z-index:1; width:132px; box-sizing:border-box;
  }
  .dash-hero .dh-date b{
    display:block; font-family:var(--font-display); font-size:14.5px; margin-top:4px;
    font-weight:700; color:var(--ink);
  }
  .dash-hero .dh-clock{
    background:var(--brass-bg); border:1px solid transparent; border-radius:12px;
    padding:9px 18px; font-size:11px; font-weight:600; color:var(--brass-ink);
    text-align:center; position:relative; z-index:1; width:132px; box-sizing:border-box;
  }
  .dash-hero .dh-clock b{
    display:block; font-family:var(--font-display); font-size:19px; margin-top:4px;
    letter-spacing:1.5px; font-variant-numeric:tabular-nums; color:var(--brass-ink); font-weight:700;
    white-space:nowrap;
  }
  .topbar-clock{
    font-family:var(--font-display); font-size:13.5px; font-weight:700; color:var(--brass-ink);
    background:var(--brass-bg); border:1px solid transparent;
    border-radius:20px; padding:7px 4px; letter-spacing:1px; margin-inline-end:6px;
    display:inline-block; width:104px; box-sizing:border-box; text-align:center;
    font-variant-numeric:tabular-nums; white-space:nowrap;
  }

  /* ---------- Reminders banner ---------- */
  .reminders-banner{ display:flex; flex-direction:column; gap:8px; margin-bottom:16px; }
  .reminder-item{
    display:flex; align-items:center; gap:10px; padding:10px 14px; border-radius:10px;
    background:var(--amber-bg); border:1px solid var(--amber); font-size:12.5px; color:var(--ink);
  }
  .reminder-item.overdue{ background:var(--red-bg); border-color:var(--red); }
  .reminder-item .ric{ font-size:16px; flex:0 0 auto; }
  .reminder-item .rtxt{ flex:1; line-height:1.7; }
  .reminder-item .rtxt b{ font-weight:700; }
  .reminder-item .rdismiss{
    border:none; background:transparent; color:var(--ink-faint); cursor:pointer; font-size:13px; padding:2px 6px;
  }
  .reminder-item .rdismiss:hover{ color:var(--red-ink); }

  /* ---------- Important star toggle (daily plan) ---------- */
  .star-btn{
    border:none; background:transparent; cursor:pointer; font-size:17px; line-height:1; padding:2px 4px;
    color:var(--ink-faint); transition:transform .12s;
  }
  .star-btn:hover{ transform:scale(1.18); }
  .star-btn.is-important{ color:var(--brass); }
  .reminder-popup{
    position:fixed; z-index:210; background:var(--white); border:1px solid var(--card-border); border-radius:14px;
    box-shadow:0 14px 36px rgba(11,37,69,.28); padding:0; display:none; width:252px; overflow:hidden;
  }
  .reminder-popup.open{ display:block; }
  .reminder-popup label{
    font-size:11.5px; color:#fff; display:block; padding:10px 14px; margin:0;
    background:linear-gradient(120deg,var(--deep) 0%,#173B5C 100%); font-weight:600;
  }
  .reminder-popup .rp-dategrid{
    display:grid; grid-template-columns:0.8fr 1.3fr 1fr; gap:6px; margin:14px 14px 10px;
  }
  .reminder-popup .rp-timegrid{
    display:grid; grid-template-columns:1fr auto 1fr; gap:6px; margin:0 14px 14px; width:64%;
    align-items:center;
  }
  .reminder-popup select{
    width:100%; box-sizing:border-box; border:1px solid var(--card-border); border-radius:8px;
    padding:7px 4px; font-family:var(--font-body); font-size:12.5px; color:var(--ink); background:var(--paper);
    text-align:center; cursor:pointer; transition:border-color .15s;
  }
  .reminder-popup select:focus{ outline:none; border-color:var(--brass); }
  .reminder-popup .rp-row{ display:flex; gap:6px; padding:0 14px 14px; }
  .reminder-popup .rp-row button{
    flex:1; border-radius:8px; padding:8px 6px; font-size:11.5px; cursor:pointer; font-family:var(--font-body);
    transition:opacity .15s;
  }
  .reminder-popup .rp-row button:hover{ opacity:.85; }
  .reminder-popup .rp-save{ border:none; background:var(--brass); color:#fff; font-weight:700; }
  .reminder-popup .rp-clear{ border:1px solid var(--card-border); background:transparent; color:var(--red-ink); }
  .reminder-popup .rp-close{ border:1px solid var(--card-border); background:transparent; color:var(--ink-soft); }

  /* ---------- On-screen reminder alert modal ---------- */
  .reminder-modal-overlay{
    position:fixed; inset:0; z-index:500; background:rgba(11,20,33,.55);
    display:none; align-items:center; justify-content:center; padding:16px;
    backdrop-filter:blur(1px);
  }
  .reminder-modal-overlay.open{ display:flex; }
  .reminder-modal{
    background:var(--white); border-radius:16px; padding:26px 24px; max-width:340px; width:100%;
    text-align:center; box-shadow:0 20px 50px rgba(0,0,0,.35);
    animation:rmPop .22s cubic-bezier(.2,.9,.3,1.2);
  }
  @keyframes rmPop{ 0%{ transform:scale(.85); opacity:0; } 100%{ transform:scale(1); opacity:1; } }
  .reminder-modal .rm-icon{ font-size:38px; margin-bottom:8px; }
  .reminder-modal .rm-title{ font-family:var(--font-display); font-size:16px; font-weight:700; color:var(--ink); margin-bottom:8px; }
  .reminder-modal .rm-msg{ font-size:13px; color:var(--ink-soft); line-height:1.8; margin-bottom:18px; }
  .reminder-modal .rm-ok{
    border:none; background:var(--brass); color:#fff; font-weight:700; border-radius:9px;
    padding:9px 26px; font-size:13px; cursor:pointer; font-family:var(--font-body);
  }

  .company-just-added{ animation:flashGreen 1.8s ease; }
  @keyframes flashGreen{
    0%{ background:var(--green-bg); } 100%{ background:transparent; }
  }
  .visit-add-confirm{ font-size:11.5px; color:var(--green-ink); font-weight:600; margin-inline-start:8px; }

  .dash-group-label{
    display:flex; align-items:center; gap:9px; font-size:12.5px; font-weight:700; color:var(--ink-soft);
    margin:22px 0 10px; padding-bottom:7px; border-bottom:1px solid var(--card-border);
  }
  /* رنگِ گروه این‌جاست، نه روی تک‌تکِ کارت‌ها. */
  .dash-group-label .dgl-ic{
    font-size:13px; width:24px; height:24px; flex:none; border-radius:8px;
    display:flex; align-items:center; justify-content:center;
    background:var(--dgl-bg, var(--brass-bg));
  }
  .dash-group-label.g-blue { --dgl-bg:var(--brass-bg); }
  .dash-group-label.g-amber{ --dgl-bg:var(--amber-bg); }
  .dash-group-label.g-teal { --dgl-bg:var(--teal-bg); }

  /* هر گروه از کارت‌های داشبورد یک نوارِ رنگیِ سه‌پیکسلی بالایش داشت؛
     کنارِ هم نامنظم به نظر می‌رسید و رنگ چیزی نمی‌گفت که عنوانِ گروه
     نگفته باشد. حالا همهٔ کارت‌ها یک‌شکل‌اند. کلاس‌ها مانده‌اند چون
     جاوااسکریپت و آزمون‌ها با همین‌ها کارت‌ها را پیدا می‌کنند. */
  .panel.accent-blue, .panel.accent-amber, .panel.accent-teal{ border-top:1px solid var(--card-border); }
  .stat .lbl{ font-size:12px; font-weight:600; color:var(--ink-soft);
    display:flex; align-items:center; gap:6px; }
  .stat .val{ font-family:var(--font-display); font-size:30px; font-weight:700;
    margin-top:7px; color:var(--tone, var(--brass)); line-height:1.25; }
  .stat .sub{ font-size:11.5px; font-weight:600; color:var(--ink-faint); margin-top:2px; }
  .stat.blue  { --tone:#1A4FA3; }
  .stat.green { --tone:#1E7A4A; }
  .stat.teal  { --tone:#0A8F88; }
  .stat.amber { --tone:#B5791B; }
  .stat.red   { --tone:#A6222B; }
  .stat.purple{ --tone:#6E45B0; }
  :root[data-theme="dark"] .stat.blue  { --tone:#6AA3FF; }
  :root[data-theme="dark"] .stat.green { --tone:#5FB07E; }
  :root[data-theme="dark"] .stat.teal  { --tone:#1FA298; }
  :root[data-theme="dark"] .stat.amber { --tone:#DFA94F; }
  :root[data-theme="dark"] .stat.red   { --tone:#E8737C; }
  :root[data-theme="dark"] .stat.purple{ --tone:#A88FD8; }

  /* ---------- Panels / grid ---------- */
  .grid2{ display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:16px; }
  @media (max-width:900px){ .grid2{ grid-template-columns:1fr; } }
  .dt-row{ display:flex; gap:8px; }
  .dt-row select, .dt-row input[type="date"]{
    flex:1; box-sizing:border-box; border:1px solid var(--card-border); border-radius:8px;
    padding:9px 10px; font-family:var(--font-body); font-size:12.5px; color:var(--ink); background:var(--white);
  }
  .dt-row select:focus, .dt-row input:focus{ outline:none; border-color:var(--brass); }
  .dt-result{
    margin-top:14px; padding:12px 14px; background:var(--paper); border:1px solid var(--card-border); border-radius:10px;
    font-family:var(--font-display); font-size:15px; font-weight:700; color:var(--ink); text-align:center; min-height:20px;
  }
  .dt-diff-grid{ display:grid; grid-template-columns:1fr 1fr; gap:16px; }
  @media (max-width:700px){ .dt-diff-grid{ grid-template-columns:1fr; } }
  .dt-diff-grid label{ font-size:11.5px; color:var(--ink-soft); display:block; margin-bottom:6px; }
  .dt-diff-result{ font-size:13px; line-height:2; }
  .dt-diff-result b{ color:var(--brass-ink); font-family:var(--font-display); font-size:16px; }
  .grid3{ display:grid; grid-template-columns:1fr 1fr 1fr; gap:16px; margin-bottom:16px; }
  @media (max-width:1100px){ .grid3{ grid-template-columns:1fr 1fr; } }
  @media (max-width:700px){ .grid3{ grid-template-columns:1fr; } }
  .panel{
    background:var(--white); border:1px solid var(--card-border); border-radius:var(--radius);
    box-shadow:var(--shadow); padding:18px 20px; transition:box-shadow .2s, transform .2s;
  }
  .panel:hover{ box-shadow:var(--shadow-lg); transform:translateY(-1px); }
  .panel h3{
    font-family:var(--font-display); font-size:14.5px; margin:0 0 14px; color:var(--ink); font-weight:700;
    display:flex; align-items:center; gap:8px; padding-bottom:10px; border-bottom:1px solid var(--paper-deep);
  }
  /* دکمهٔ «کد بازیابی دارم» روی صفحهٔ قفل — نباید به چشمِ دکمهٔ خطرناک
     (پاک‌سازی) بیاید، پس رنگِ خنثی دارد. */
  .lock-screen .ls-recover{
    margin-top:10px; background:transparent; border:1px solid var(--line);
    border-radius:9px; padding:8px 14px; cursor:pointer;
    font-family:var(--font-body); font-size:12px; color:var(--ink-soft);
  }
  .lock-screen .ls-recover:hover{ border-color:var(--brass); color:var(--ink); }

  /* ---------- قابِ نمودارها ----------
     قبلاً بوم مستقیم توی کارت بود و فقط یک max-height داشت. Chart.js بوم را
     به اندازهٔ عرضِ کارت مربع می‌کرد، بعد CSS ارتفاعش را می‌بُرید و کتابخانه
     دوباره از روی ارتفاعِ بریده حساب می‌کرد؛ نتیجه این می‌شد که نمودار کوچک
     می‌ماند، می‌چسبید بالای کارت و زیرش جای خالی می‌افتاد — و چون این
     رفت‌وبرگشت در هر کارت به عددِ دیگری می‌رسید، سه نمودارِ کنار هم سه
     اندازهٔ مختلف داشتند.

     حالا بوم داخل قابی با ارتفاعِ مشخص می‌نشیند و کاملاً پُرش می‌کند، و
     Chart.js با maintainAspectRatio:false همان قاب را مبنا می‌گیرد. پس
     نمودار همیشه وسطِ قاب است و هر سه یک اندازه. */
  /* قابِ نمودارهای داشبورد. ۲۵۰ پیکسل برای یک دونات با راهنمای زیرش
     کم بود: خودِ دایره کمتر از نصفِ قاب می‌شد. حالا قاب بلندتر است و
     روی گوشی کوتاه‌تر می‌شود تا کارت از صفحه نزند بیرون. */
  .chart-box{ position:relative; width:100%; height:312px; margin-top:4px; }
  @media (max-width:760px){ .chart-box{ height:268px; } }
  .chart-box > canvas{ position:absolute; inset:0; width:100% !important; height:100% !important; }
  /* وقتی داده‌ای نیست یا کتابخانه نیامده، جای بوم یک پیام می‌نشیند؛
     آن هم باید وسطِ همین قاب بایستد. */
  .chart-box > div{
    position:absolute; inset:0; display:flex; align-items:center;
    justify-content:center; box-sizing:border-box;
  }

  /* signature stamp */
  .stamp-wrap{ display:flex; align-items:center; justify-content:center; padding:10px 0 4px; }
  .stamp{
    width:168px; height:168px; border-radius:50%;
    border:3px solid var(--brass); position:relative;
    display:flex; align-items:center; justify-content:center;
    color:var(--brass-ink);
    opacity:.95;
  }
  .stamp::before{
    content:""; position:absolute; inset:9px; border-radius:50%;
    border:1.5px dashed var(--brass);
  }
  .stamp .stxt{ text-align:center; font-family:var(--font-display); }
  .stamp .stxt .pct{ font-size:30px; font-weight:700; display:block; line-height:1; }
  .stamp .stxt .lab{ font-size:10.5px; font-weight:600; letter-spacing:.5px; display:block; margin-top:5px; }

  /* ---------- Tables ---------- */
  table{ width:100%; border-collapse:collapse; font-size:12px; }
  /* سربرگِ جدول یک تختهٔ سرمه‌ای بود؛ حالا که نوار بالا روشن شده، همین
     تخته سنگین‌ترین چیزِ صفحه می‌شد. کاغذی‌اش می‌کنیم — خطِ پررنگِ زیرش
     همان کاری را می‌کند که رنگ می‌کرد. */
  thead th{
    background:var(--paper-deep); color:var(--ink-soft); font-weight:700; padding:10px 6px; text-align:center;
    position:sticky; top:0; font-size:11.5px; letter-spacing:.2px;
    border-bottom:2px solid var(--card-border);
  }
  .tbl-wrap table thead tr:first-child th:first-child{ border-top-right-radius:var(--radius); }
  .tbl-wrap table thead tr:first-child th:last-child{ border-top-left-radius:var(--radius); }
  tbody td{ padding:6px 6px; border-bottom:1px solid var(--line); text-align:center; vertical-align:middle; font-size:12px; transition:background .1s; }
  tbody tr:nth-child(even){ background:var(--paper); }
  tbody tr:hover{ background:var(--brass-bg); }
  .filter-row th{ background:var(--paper-deep); padding:4px 5px; position:sticky; top:34px; }
  .filter-row input, .filter-row select{
    width:100%; box-sizing:border-box; font-family:var(--font-body); font-size:11px;
    padding:4px 5px; border:1px solid var(--card-border); border-radius:6px; color:var(--ink); background:var(--white);
  }
  .filter-row input:focus, .filter-row select:focus{ outline:none; border-color:var(--brass); }

  /* ---------- Multi-select filter dropdown ---------- */
  .msf{ position:relative; width:100%; }
  .msf-btn{
    width:100%; box-sizing:border-box; font-family:var(--font-body); font-size:11px;
    padding:4px 8px 4px 5px; border:1px solid var(--card-border); border-radius:6px; color:var(--ink); background:var(--white);
    cursor:pointer; text-align:right; display:flex; align-items:center; justify-content:space-between; gap:4px;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
  }
  .msf-btn:hover, .msf-btn.open{ border-color:var(--brass); }
  .msf-btn .arrow{ font-size:9px; color:var(--ink-faint); flex:none; transition:transform .12s; }
  .msf-btn.open .arrow{ transform:rotate(180deg); }
  .msf-count{ background:var(--brass); color:#fff; border-radius:999px; font-size:9.5px; padding:0px 5px; flex:none; }
  .msf-panel{
    position:fixed; z-index:250; background:var(--white); border:1px solid var(--card-border); border-radius:8px;
    box-shadow:0 10px 30px rgba(11,37,69,.25); padding:6px; display:none; max-height:220px; overflow-y:auto;
    min-width:150px;
  }
  .msf-panel.open{ display:block; }
  .msf-opt{ display:flex; align-items:center; gap:7px; padding:5px 6px; border-radius:5px; cursor:pointer; font-size:12px; white-space:nowrap; }
  .msf-opt:hover{ background:var(--brass-bg); }
  .msf-opt input{ margin:0; flex:none; accent-color:var(--brass); width:14px; height:14px; }
  .msf-clear{ font-size:10.5px; color:var(--brass-ink); text-align:center; padding:4px; cursor:pointer; border-top:1px solid var(--line); margin-top:3px; }
  .msf-clear:hover{ text-decoration:underline; }

  /* ---------- Chart drill-down modal ---------- */
  .cm-overlay{
    position:fixed; inset:0; background:rgba(11,37,69,.45); z-index:400; display:none;
    align-items:center; justify-content:center; padding:20px; backdrop-filter:blur(1px);
  }
  .cm-overlay.open{ display:flex; animation:cmFade .15s ease; }
  @keyframes cmFade{ from{opacity:0;} to{opacity:1;} }
  .cm-box{
    background:var(--white); border-radius:14px; width:100%; max-width:480px; max-height:80vh;
    display:flex; flex-direction:column; box-shadow:0 20px 60px rgba(11,37,69,.35);
    animation:cmPop .18s ease;
  }
  @keyframes cmPop{ from{opacity:0; transform:scale(.96) translateY(6px);} to{opacity:1; transform:none;} }
  .cm-head{
    display:flex; align-items:center; justify-content:space-between; gap:10px;
    padding:16px 18px; border-bottom:1px solid var(--line);
  }
  .cm-title{ font-family:var(--font-display); font-size:15px; font-weight:700; color:var(--ink); display:flex; align-items:center; gap:8px; }
  .cm-count{ background:var(--brass-bg); color:var(--brass-ink); border-radius:999px; padding:2px 10px; font-size:11.5px; font-weight:700; }
  .cm-close{ background:none; border:none; font-size:18px; color:var(--ink-faint); cursor:pointer; line-height:1; padding:4px; }
  .cm-close:hover{ color:var(--red-ink); }
  .cm-body{ padding:8px 10px; overflow-y:auto; }
  .cm-empty{ padding:30px 10px; text-align:center; color:var(--ink-faint); font-size:12.5px; }
  .cm-item{ padding:10px 10px; border-radius:8px; }
  .cm-item:hover{ background:var(--brass-bg); }
  .cm-item + .cm-item{ border-top:1px solid var(--line); }
  .cm-item-title{ font-weight:700; font-size:13px; color:var(--ink); margin-bottom:3px; }
  .cm-item-meta{ display:flex; flex-wrap:wrap; gap:8px; font-size:11px; color:var(--ink-faint); }
  .cm-item-meta span{ display:inline-flex; align-items:center; gap:3px; }
  .date-box{
    display:flex; align-items:center; gap:5px; border:1px solid var(--card-border); border-radius:6px;
    padding:5px 7px; cursor:pointer; background:var(--white); transition:border-color .15s;
  }
  .date-box:hover{ border-color:var(--brass); }
  .date-box .cal-ic{ font-size:12px; flex:0 0 auto; }
  .date-box input{ border:none; background:transparent; width:100%; font-size:12.6px; text-align:center; cursor:pointer; color:var(--ink); }
  .day-picker-popup{
    position:fixed; z-index:200; background:var(--white); border:1px solid var(--card-border); border-radius:10px;
    box-shadow:0 10px 30px rgba(11,37,69,.25); padding:10px; display:none;
  }
  .day-picker-popup.open{ display:block; }
  .day-picker-popup .dp-grid{ display:grid; grid-template-columns:repeat(7,28px); gap:4px; }
  .day-picker-popup button{
    width:28px; height:28px; border:none; border-radius:6px; background:var(--paper); color:var(--ink);
    font-family:var(--font-body); font-size:11.5px; cursor:pointer;
  }
  .day-picker-popup button:hover{ background:var(--brass); color:#fff; }
  .day-picker-popup button.selected{ background:var(--deep); color:#fff; }
  .day-picker-popup .dp-clear{
    width:100%; margin-top:8px; height:26px; border-radius:6px; background:transparent; color:var(--red-ink);
    border:1px solid var(--card-border); font-size:11px;
  }
  .remote-grid-wrap{ overflow-x:auto; border-radius:14px; }
  .remote-grid{ border-collapse:separate; border-spacing:0; font-size:12px; width:100%; }
  .remote-grid th, .remote-grid td{ border-bottom:1px solid var(--line); border-inline-start:1px solid var(--line); padding:10px 8px; text-align:center; }
  .remote-grid thead th{
    background:var(--paper-deep); color:var(--ink-soft); position:sticky; top:0; font-weight:700;
    border-inline-start:1px solid var(--card-border); border-bottom:2px solid var(--card-border); z-index:2;
  }
  .remote-grid thead th:first-child{ border-top-right-radius:12px; }
  .remote-grid thead th:last-child{ border-top-left-radius:12px; }
  .remote-grid tbody tr:nth-child(even) td{ background:var(--paper); }
  .remote-grid tbody tr:hover td{ background:var(--brass-bg); }
  .remote-grid tbody tr:nth-child(even) td.server-name{ background:var(--paper); }
  .remote-grid tbody tr:hover td.server-name{ background:var(--brass-bg); }
  .remote-grid td.server-name{ text-align:right; font-weight:600; white-space:normal; background:var(--white); position:sticky; right:0; padding:10px 12px; z-index:1; box-shadow:2px 0 4px rgba(0,0,0,.04); }
  /* چهل‌وچند دایرهٔ سبزِ توپُر کنار هم، تختهٔ چراغ می‌شد نه جدول. حالا
     تینتِ سبز با جوهرِ سبز — همان زبانی که نشان‌های بقیهٔ صفحه دارند. */
  .day-toggle{
    width:32px; height:32px; border-radius:50%; border:1.5px solid var(--card-border);
    background:var(--white); cursor:pointer; font-size:13px; font-weight:700;
    color:var(--ink-faint); transition:background .12s, color .12s, border-color .12s;
  }
  .day-toggle:hover{ border-color:var(--brass); background:var(--brass-bg); }
  .day-toggle.checked{ background:var(--green-bg); color:var(--green-ink); border-color:var(--green); }
  .remote-day-head{ display:flex; align-items:center; justify-content:center; gap:4px; }
  /* این دو تا سفید-روی-سرمه‌ای بودند، از وقتی که سربرگِ جدول‌ها تخته‌ای
     تیره بود. سربرگ که کاغذی شد، سفید روی سفید افتادند و تاریخ‌ها
     عملاً ناپیدا شدند. */
  .remote-date-header{
    width:52px; text-align:center; font-size:11px; font-family:var(--font-body);
    background:var(--white); color:var(--ink); border:1px solid var(--card-border);
    border-radius:6px; padding:4px 2px;
  }
  .remote-date-header::placeholder{ color:var(--ink-faint); }
  /* وقتی «حذف/تغییر» خاموش است، تاریخ فقط متن است نه کادرِ ورودی */
  .remote-date-header:disabled{ background:transparent; border-color:transparent;
    color:var(--ink-soft); -webkit-text-fill-color:var(--ink-soft); opacity:1; }
  .remote-date-header:focus{ outline:none; background:var(--white); color:var(--ink);
    border-color:var(--brass); box-shadow:0 0 0 3px rgba(26,79,163,.15); }
  .remote-day-del{
    border:none; background:transparent; color:var(--ink-faint); width:20px; height:20px;
    border-radius:6px; font-size:10px; line-height:1; cursor:pointer; flex:0 0 auto; padding:0;
    transition:background .12s, color .12s;
  }
  .remote-day-del:hover{ background:var(--red-bg); color:var(--red-ink); }
  /* خاموش که باشد اصلاً نباشد — وگرنه یک ردیف ✕ِ بی‌کار بالای جدول می‌ماند */
  .remote-day-del:disabled{ display:none; }
  .remote-grid-wrap .remote-count-cell{ font-weight:700; color:var(--brass-ink); }
  .tbl-wrap{ overflow-x:auto; border-radius:var(--radius); border:1px solid var(--card-border); box-shadow:var(--shadow); background:var(--white);}
  td input[type=text], td input[type=number], td select, textarea.cell{
    width:100%; border:1px solid transparent; background:transparent; font-family:var(--font-body);
    font-size:12.6px; padding:5px 4px; border-radius:5px; color:var(--ink); text-align:center;
  }
  td input[type=text]:focus, td input[type=number]:focus, td select:focus{
    border-color:var(--brass); background:var(--white); outline:none;
  }
  td.editable-text input{ text-align:right; }
  .badge{ display:inline-block; padding:3px 9px; border-radius:20px; font-size:11.5px; font-weight:700; }
  .badge.done{ background:var(--green-bg); color:var(--green-ink); }
  .badge.doing{ background:var(--amber-bg); color:var(--amber-ink); }
  .badge.todo{ background:var(--red-bg); color:var(--red-ink); }
  select.st-select{ font-weight:700; border-radius:20px; }
  .pr-high{ color:var(--red-ink); font-weight:800; }
  .pr-mid{ color:var(--amber-ink); font-weight:800; }
  .pr-low{ color:var(--green-ink); font-weight:800; }

  .toolbar{ display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; gap:10px; flex-wrap:wrap; }
  .btn{
    font-family:var(--font-body); font-weight:700; font-size:12.8px; border:none; border-radius:10px;
    padding:9px 16px; cursor:pointer; display:inline-flex; align-items:center; gap:6px;
    transition:transform .12s, box-shadow .15s, background .15s, border-color .15s, color .15s;
  }
  .btn:active{ transform:translateY(1px); }
  .btn-brass{ background:linear-gradient(135deg,var(--brass),var(--brass-deep)); color:#fff; box-shadow:0 3px 10px rgba(14,139,139,.30); }
  .btn-brass:hover{ box-shadow:0 6px 16px rgba(14,139,139,.42); transform:translateY(-1px); }
  .btn-ghost{ background:transparent; color:var(--ink-soft); border:1px solid var(--card-border); }
  .btn-ghost:hover{ border-color:var(--brass); color:var(--brass-ink); background:var(--brass-bg); }
  /* دکمهٔ حذف قبلاً همیشه قرمز بود و روی hover هم بزرگ می‌شد — در یک
     جدولِ چهل ردیفی، چهل لکهٔ قرمزِ جهنده. حالا تا دست رویش نرود خاکستریِ
     آرام است و فقط همان لحظه قرمز می‌شود. */
  .btn-del{
    display:inline-flex; align-items:center; justify-content:center;
    width:28px; height:28px; padding:0; box-sizing:border-box;
    background:transparent; border:1px solid transparent; border-radius:8px;
    color:var(--ink-faint); font-size:13px; line-height:1; cursor:pointer;
    transition:background .14s, color .14s;
  }
  .btn-del:hover{ background:var(--red-bg); color:var(--red-ink); }
  .btn-del:active{ transform:scale(.94); }
  .btn-del:focus-visible{ outline:2px solid var(--red); outline-offset:1px; }
  .btn-del[disabled]{ display:none; }
  .del-toggle-wrap, .edit-toggle-wrap{ display:inline-flex; align-items:center; gap:5px; font-size:10.5px; color:var(--ink-soft); user-select:none; white-space:nowrap; }
  .del-switch, .edit-switch{ position:relative; display:inline-block; width:28px; height:16px; flex:none; }
  .del-switch input, .edit-switch input{ opacity:0; width:0; height:0; }
  .del-switch .track, .edit-switch .track{ position:absolute; inset:0; background:var(--line); border-radius:999px; transition:.18s; cursor:pointer; }
  .del-switch .track::before, .edit-switch .track::before{ content:""; position:absolute; width:12px; height:12px; left:2px; top:2px; background:var(--white); border-radius:50%; transition:.18s; box-shadow:0 1px 2px rgba(0,0,0,.3); }
  .del-switch input:checked + .track, .edit-switch input:checked + .track{ background:var(--red); }
  .del-switch input:checked + .track::before, .edit-switch input:checked + .track::before{ transform:translateX(-12px); }
  .add-row input, .add-row select{ background:var(--paper); border:1px solid var(--line); border-radius:6px; padding:5px 7px; font-size:12px; font-family:inherit; }
  .add-row input:focus, .add-row select:focus{ outline:2px solid var(--brass); }
  .compound-field{ display:flex; align-items:stretch; border:1px solid var(--line); border-radius:8px; overflow:hidden; background:var(--paper); }
  .compound-field input{ border:none; background:transparent; padding:7px 9px; font-size:12.5px; font-family:inherit; flex:1; min-width:0; }
  .compound-field input:focus{ outline:none; background:var(--white); }
  .compound-field .divider{ width:1px; background:var(--line); }
  .compound-field:focus-within{ border-color:var(--brass); }
  .new-company-card{ display:flex; align-items:center; justify-content:center; gap:10px; padding:22px; border:1.5px dashed var(--line); border-radius:12px; background:var(--paper); flex-wrap:wrap; }
  .new-company-card input{ border:1px solid var(--line); border-radius:8px; padding:9px 14px; font-size:13px; font-family:inherit; min-width:220px; text-align:center; background:var(--white); }
  .new-company-card input:focus{ outline:2px solid var(--brass); border-color:var(--brass); }
  .company-last-visits{ display:flex; flex-direction:column; max-height:260px; overflow-y:auto; }
  .clv-row{ display:flex; align-items:center; justify-content:space-between; gap:10px; padding:9px 4px; border-bottom:1px solid var(--line); font-size:12.5px; }
  .clv-row:last-child{ border-bottom:none; }
  .clv-name{ font-weight:700; color:var(--ink); white-space:nowrap; }
  .clv-date{ display:flex; align-items:center; gap:6px; color:var(--ink-soft); font-size:12px; white-space:nowrap; }
  .clv-type{ background:var(--brass-bg); color:var(--brass-ink); border-radius:999px; padding:1px 8px; font-size:10.5px; font-weight:600; }
  .clv-empty{ color:var(--ink-faint); font-style:italic; }
  .daily-plan-table{ min-width:920px; }
  .daily-plan-table td, .daily-plan-table th{ padding-left:10px; padding-right:10px; }
  .daily-plan-table td:nth-child(4), .daily-plan-table th:nth-child(4){ border-right:1px solid var(--line); padding-right:14px; }
  .daily-plan-table td:nth-child(5), .daily-plan-table th:nth-child(5){ padding-right:14px; padding-left:14px; }
  .daily-plan-table td.editable-text input, .daily-plan-table td select{ width:100%; box-sizing:border-box; }
  .daily-date-cell{ color:var(--ink-faint); font-size:11.5px; white-space:nowrap; text-align:center; }
  .cal-block{ margin-bottom:20px; }
  .cal-head{ display:flex; align-items:center; gap:12px; flex-wrap:wrap; margin-bottom:10px; }
  .cal-head h4{ font-family:var(--font-display); font-size:13.5px; margin:0; color:var(--ink); }
  .cal-nav{ display:flex; align-items:center; gap:8px; background:var(--paper); border:1px solid var(--line); border-radius:8px; padding:3px 10px; }
  .cal-nav-btn{ background:none; border:none; cursor:pointer; font-size:15px; color:var(--brass-ink); font-weight:700; padding:0 4px; line-height:1; }
  .cal-nav-btn:hover{ color:var(--brass); }
  .cal-label{ font-size:12.5px; font-weight:700; min-width:100px; text-align:center; }
  .cal-count{ font-size:11.5px; color:var(--ink-faint); margin-inline-start:auto; }
  .cal-grid{ display:flex; flex-wrap:wrap; gap:6px; }
  .cal-day{ width:34px; height:34px; border-radius:8px; border:1.5px solid var(--line); background:var(--white); cursor:pointer; font-size:12px; font-weight:600; color:var(--ink-soft); transition:.12s; }
  .cal-day:hover{ border-color:var(--brass); }
  .cal-day.done{ background:var(--brass); border-color:var(--brass-ink); color:#fff; }
  .btn-sm{ padding:5px 12px !important; font-size:12px !important; }
  .visit-add-bar{ display:flex; align-items:center; gap:8px; margin-top:10px; padding:8px 10px; background:var(--paper); border:1px solid var(--line); border-radius:8px; }
  .visit-add-bar input, .visit-add-bar select{ background:var(--white); border:1px solid var(--line); border-radius:6px; padding:6px 8px; font-size:12.5px; font-family:inherit; }
  .visit-add-bar input:focus, .visit-add-bar select:focus{ outline:none; border-color:var(--brass); }
  .company-visits-table th, .company-visits-table td{ text-align:center; }
  /* چهار ستون روی تمام عرض صفحه کشیده می‌شدند: ستون تاریخ ۳۹۴ پیکسل
     می‌گرفت برای متنی مثل «05.06.25». حالا جدول به اندازهٔ ستون‌هایش
     است، نه به اندازهٔ صفحه. */
  .company-visits-table{ table-layout:fixed; }
  /* ستون نام سرور موقع اسکرول افقی سرِ جا می‌ماند، پس باید پس‌زمینه
     داشته باشد وگرنه تیک‌ها از زیرش رد می‌شوند. */
  .remote-grid td.server-name{ position:sticky; right:0; background:var(--white); z-index:1; }
  .remote-grid tbody tr:nth-child(even) td.server-name{ background:var(--paper); }
  .save-hint{ font-size:11px; color:var(--ink-faint); }

  /* Guide */
  .guide-item{ display:flex; gap:14px; padding:14px 0; border-bottom:1px dashed var(--line); }
  .guide-item:last-child{ border-bottom:none; }
  .guide-item .ic{ font-size:20px; width:34px; text-align:center; flex:0 0 34px; }
  .guide-item h4{ margin:0 0 4px; font-family:var(--font-display); font-size:14.5px; }
  .guide-item p{ margin:0; font-size:13px; color:var(--ink-soft); line-height:1.8; }
  .legend-row{ display:flex; gap:18px; flex-wrap:wrap; margin-top:14px; font-size:12.5px; color:var(--ink-soft); }
  .legend-row span{ display:inline-flex; align-items:center; gap:6px; }
  .dot{ width:11px; height:11px; border-radius:3px; display:inline-block; }

  .loading{
    position:fixed; inset:0; background:var(--paper); z-index:100; display:flex;
    align-items:center; justify-content:center; flex-direction:column; gap:10px;
  }
  .loading .spin{
    width:34px; height:34px; border-radius:50%; border:3px solid var(--line); border-top-color:var(--brass);
    animation:spin 0.9s linear infinite;
  }
  @keyframes spin{ to{ transform:rotate(360deg); } }
  .loading span{ font-size:13px; color:var(--ink-soft); font-family:var(--font-body); }

  footer.appfoot{ text-align:center; color:var(--ink-faint); font-size:11px; padding:18px 0 6px; }
{{PART:vaultcss}}
{{PART:mobilecss}}
{{PART:navcss}}
  .theme-btn:hover{ border-color:var(--brass); background:var(--brass-bg); }
  .theme-btn:active{ transform:scale(.94); }
  /* نوار کناریِ این پلنر پردهٔ سفیدِ نیمه‌شفاف روی صفحه است، نه توکن؛
     در شب باید پرده خیلی رقیق‌تر شود وگرنه یک تختهٔ خاکستری می‌شود. */
  [data-theme="dark"] .sidebar{
    background:linear-gradient(180deg, rgba(255,255,255,.05), rgba(255,255,255,.015));
    border-left-color:var(--line);
  }
  [data-theme="dark"] .reminder-item{ background:var(--amber-bg); border-color:#4A3D1F; }
  [data-theme="dark"] .reminder-item.overdue{ background:var(--red-bg); border-color:#5A2A2E; }
  [data-theme="dark"] .dt-result{ background:var(--paper-deep); }
  [data-theme="dark"] .day-picker-popup button{ background:var(--paper-deep); color:var(--ink); }
  [data-theme="dark"] .day-toggle:hover{ background:var(--paper-deep); }
  [data-theme="dark"] .compound-field,
  [data-theme="dark"] .new-company-card,
  [data-theme="dark"] .cal-nav{ background:var(--paper-deep); }
  [data-theme="dark"] .remote-grid tbody tr:nth-child(even) td,
  [data-theme="dark"] .remote-grid tbody tr:nth-child(even) td.server-name{ background:#18232F; }
  [data-theme="dark"] .remote-grid tbody tr:hover td,
  [data-theme="dark"] .remote-grid tbody tr:hover td.server-name{ background:#1E2B39; }
  [data-theme="dark"] .remote-grid td.server-name{ background:var(--white); }
</style>
</head>
<body>

<div id="gateScreen">
  <form class="gate-card" id="gateForm" autocomplete="off">
    <img class="gate-mark" src="/icon-sl.3.png" alt="SLTech" width="68" height="68">
    <div class="brandword">SLTech</div>
    <h2>{{TITLE}}</h2>
    <p>برای ورود، رمز عبور کارتابل را وارد کنید.</p>
    <input type="password" id="gatePass" placeholder="رمز عبور" autocomplete="current-password" required>
    <label class="gate-remember"><input type="checkbox" id="gateRemember" checked> ۳۰ روز مرا به خاطر بسپار</label>
    <button type="submit" id="gateBtn">ورود</button>
    <div class="gate-err" id="gateErr"></div>
    <div class="gate-note" id="gateNote"></div>
    <button type="button" class="gate-forgot" id="gateForgot">رمز را فراموش کرده‌ام</button>
  </form>
</div>

<div class="loading" id="loadingScreen"><div class="spin"></div><span>در حال بارگذاری کارتابل...</span></div>

<div class="topbar">
  <div class="brand">
    <img class="mark" src="/icon-sl.3.png" width="42" height="42" alt="SLTech">
    <div class="titles">
      <h1>{{TITLE}}</h1>
      <small>بکاپ، سرورها، امنیت و برنامه‌ی ماه</small>
    </div>
  </div>
  <!-- سه کنترلِ ماه (انتخاب، ساختن، تغییر نام) یکی شدند: یک دکمه که
       نامِ ماهِ جاری را نشان می‌دهد و با زدنش پنجرهٔ ماه‌ها باز می‌شود.
       نوارِ بالا جای تصمیم گرفتن نیست، جای دیدن است. -->
  <div class="period">
    <button type="button" class="month-btn" id="monthBtn" title="ماه‌ها">
      <span class="ic">🗓</span><span id="monthBtnLabel">—</span><span class="caret">▾</span>
    </button>
    <span class="topbar-date" id="topbarDate">—</span>
    <span class="topbar-clock" id="topbarClock">--:--:--</span>
    <button type="button" class="theme-btn" id="themeBtn" title="تم شب">🌙</button>
  </div>
</div>

<!-- پنجرهٔ ماه‌ها: رفتن به یک ماه، تغییر نامش، و ساختنِ ماهِ تازه —
     همه یک جا. پیش از این سه کنترلِ جدا در نوارِ بالا بودند. -->
<div class="mpop" id="monthPop" hidden>
  <div class="mpop-card" role="dialog" aria-label="ماه‌ها">
    <div class="mpop-h">ماه‌ها<button type="button" class="mpop-x" id="monthPopX" title="بستن">✕</button></div>
    <div class="mpop-list" id="monthPopList"></div>
    <div class="mpop-new">
      <div class="mpop-sub">ماه تازه</div>
      <div class="mpop-row">
        <input id="newMonthName" type="text" placeholder="نام ماه، مثلاً آبان">
        <input id="newMonthYear" type="text" placeholder="سال، مثلاً ۱۴۰۴">
        <button type="button" class="btn btn-brass btn-sm" id="confirmNewMonthBtn">بساز و برو</button>
      </div>
      <div class="mpop-note" id="monthPopNote"></div>
    </div>
  </div>
</div>

<div class="shell">
  <div class="sidebar">
    <div class="nav-label">بخش‌ها</div>
    <nav class="nav-list">
      <button class="navbtn active" data-view="dashboard"><span class="ic">📊</span> داشبورد</button>
      <button class="navbtn" data-view="checklist"><span class="ic">✅</span> چک‌لیست ماهانه</button>
      <button class="navbtn" data-view="daily"><span class="ic">🗓️</span> برنامه روزانه</button>
      <button class="navbtn" data-view="servers" data-feat="view:servers"><span class="ic">🖥️</span> سرورها و بکاپ</button>
      <button class="navbtn" data-view="companies" data-feat="view:companies"><span class="ic">🏢</span> شرکت‌ها</button>
      <button class="navbtn" data-view="mvpn" data-feat="view:mvpn"><span class="ic">📱</span> سرویس MVPN</button>
      <button class="navbtn navbtn-lock" data-view="personal" data-feat="vault"><span class="ic">🔒</span> دیتای شخصی</button>
      <button class="navbtn" data-view="datetools" data-feat="view:datetools"><span class="ic">🧮</span> تبدیل تاریخ</button>
      <button class="navbtn" data-view="report" data-feat="view:report"><span class="ic">📊</span> گزارش‌ساز</button>
      <button class="navbtn" data-view="assistant" data-feat="ai"><span class="ic">🤖</span> دستیار هوشمند</button>
      <button class="navbtn" data-view="guide"><span class="ic">📘</span> راهنما</button>
      <button class="navbtn" data-view="settings"><span class="ic">⚙️</span> تنظیمات</button>
    </nav>
    <div class="sidebar-foot">
      <div class="save-hint" id="saveHint"></div>
      <div class="foot-actions">
        <button class="btn btn-ghost" id="exportBtn" data-feat="files">⬇ پشتیبان</button>
        <button class="btn btn-ghost" id="importBtn" data-feat="files">⬆ بازیابی</button>
      </div>
      <input type="file" id="importFile" accept="application/json" style="display:none;">
      <button class="btn btn-ghost foot-lock" id="lockBtn">🔓 خروج از کارتابل</button>
    </div>
  </div>

  <div class="content">

    <!-- DASHBOARD -->
    <section class="view active" id="view-dashboard">
      <div class="section-title">داشبورد ماهانه</div>
<!--IT-->      <div class="section-sub">خلاصه‌ی زنده‌ی وضعیت وظایف فنی این ماه</div><!--/IT--><!--GEN-->      <div class="section-sub">خلاصه‌ی زنده‌ی وضعیت وظایف این ماه</div><!--/GEN-->

      <div class="dash-hero" id="dashHero"></div>

      <div class="reminders-banner" id="remindersBanner"></div>

      <div class="cards" id="statCards"></div>

      <div class="dash-group-label g-blue"><span class="dgl-ic">📋</span> وظایف و برنامه‌ی این ماه</div>
      <div class="grid-auto">
        <div class="panel accent-blue">
          <h3>🥧 وضعیت وظایف ماه</h3>
          <div class="chart-box"><canvas id="chartStatus"></canvas></div>
        </div>
        <div class="panel accent-blue">
          <h3>🗓️ وضعیت برنامه روزانه</h3>
          <div class="chart-box"><canvas id="chartDaily"></canvas></div>
        </div>
        <div class="panel accent-blue" data-feat="view:servers">
          <h3>✅ نرخ کلی موفقیت بکاپ روزانه</h3>
          <div class="chart-box"><canvas id="chartBackupSuccessRate"></canvas></div>
        </div>
      </div>

      <div data-feat="view:companies">
      <div class="dash-group-label g-amber"><span class="dgl-ic">🏢</span> شرکت‌ها</div>
      <div class="grid3">
        <div class="panel accent-amber">
          <h3>🏢 آخرین بازدید شرکت‌ها</h3>
          <div id="companyLastVisits" class="company-last-visits"></div>
        </div>
        <div class="panel accent-amber">
          <h3>🏢 پربازدیدترین شرکت‌ها</h3>
          <div class="chart-box"><canvas id="chartTopCompanies"></canvas></div>
        </div>
        <div class="panel accent-amber">
          <h3>🔧 نسبت نوع بازدید شرکت‌ها</h3>
          <div class="chart-box"><canvas id="chartVisitType"></canvas></div>
        </div>
      </div>

      </div>

      <div data-feat="view:mvpn">
      <div class="dash-group-label g-teal"><span class="dgl-ic">🖥️</span> زیرساخت و ارتباطات</div>
      <div class="grid2">
        <div class="panel accent-teal">
          <h3>📱 وضعیت خطوط MVPN</h3>
          <div class="chart-box"><canvas id="chartMvpnStage"></canvas></div>
        </div>
        <div class="panel accent-teal">
          <h3>📡 وضعیت چک‌لیست ریموت</h3>
          <div class="chart-box"><canvas id="chartRemoteStatus"></canvas></div>
        </div>
      </div>
      </div>

      <div class="panel">
        <h3>🕒 مهلت‌های نزدیک</h3>
        <div class="tbl-wrap">
          <table>
            <thead><tr><th>وظیفه</th><th>دسته‌بندی</th><th>مهلت (روز از ماه)</th><th>وضعیت</th><th>اولویت</th></tr></thead>
            <tbody id="deadlinesBody"></tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- CHECKLIST -->
    <section class="view" id="view-checklist">
      <div class="section-title">چک‌لیست وظایف ماهانه</div>
<!--IT-->      <div class="section-sub">وظایف تکرارشونده‌ی مدیر IT — هر ردیف را ویرایش کنید یا وظیفه‌ی جدید اضافه کنید</div><!--/IT--><!--GEN-->      <div class="section-sub">وظایف تکرارشونده‌ی این ماه — هر ردیف را ویرایش کنید یا وظیفه‌ی جدید اضافه کنید</div><!--/GEN-->
      <div class="toolbar">
        <button class="btn btn-brass" id="addTaskBtn">＋ افزودن وظیفه</button>
        <button class="btn btn-ghost" id="resetTasksBtn">بازنشانی چک‌لیست</button>
      </div>
      <div class="tbl-wrap">
        <table>
          <thead><tr>
            <th style="width:26px;">#</th><th>دسته‌بندی</th><th>وظیفه</th><th style="width:120px;">مسئول</th>
            <th style="width:70px;">مهلت</th><th style="width:110px;">وضعیت</th><th style="width:90px;">اولویت</th>
            <th>یادداشت</th><th style="width:30px;"></th>
          </tr></thead>
          <tbody id="checklistBody"></tbody>
        </table>
      </div>
    </section>

    <!-- DAILY -->
    <section class="view" id="view-daily">
      <div class="section-title">برنامه روزانه ماه</div>
      <div class="section-sub">وظایف اصلی، جلسات و وضعیت هر روز</div>
      <div class="tbl-wrap">
        <table class="daily-plan-table">
          <thead>
          <tr><th style="width:38px;">ردیف</th><th style="width:80px;">📅 تاریخ</th><th style="width:21%;">📌 وظایف اصلی</th><th style="width:34%;">🤝 توضیحات</th><th style="width:180px;">🏢 شرکت</th><th style="width:120px;">وضعیت</th><th style="width:36px;" title="مهم / یادآوری">⭐</th><th style="width:34px;"></th></tr>
          <tr class="filter-row">
            <th></th><th></th><th></th><th></th>
            <th><div class="msf" id="msfDailyCompany" data-key="company"></div></th>
            <th><div class="msf" id="msfDailyStatus" data-key="status"></div></th>
            <th></th>
            <th></th>
          </tr>
          </thead>
          <tbody id="dailyBody"></tbody>
        </table>
      </div>
      <div class="visit-add-bar" style="margin-top:10px;">
        <button class="btn btn-brass btn-sm" id="addDayRowBtn">＋ افزودن روز/وظیفه</button>
      </div>
      <datalist id="dailyCompanyOptions"></datalist>
    </section>

    <!-- SERVERS & BACKUP -->
    <section class="view" id="view-servers" data-feat="view:servers">
      <div class="section-title">سرورها و بکاپ</div>
      <div class="section-sub">فهرست سرورها و وضعیت بکاپ‌گیری بر اساس دیتای شما</div>

      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshExcelBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="backupSyncStatus" style="font-size:11.5px;"></span>
      </div>

      <div class="cards" id="serverCards"></div>

      <div class="grid2">
        <div class="panel">
          <h3>🗂️ تعداد سرورها بر اساس زمان‌بندی بکاپ</h3>
          <div class="chart-box"><canvas id="chartSchedule"></canvas></div>
        </div>
        <div class="panel">
          <h3>💽 حجم بکاپ به تفکیک محل ذخیره‌سازی (GB)</h3>
          <div class="chart-box"><canvas id="chartStorage"></canvas></div>
        </div>
      </div>

      <div class="panel">
        <h3>🖥️ فهرست سرورها</h3>
        <div class="tbl-wrap">
          <table>
            <thead>
            <tr>
              <th style="width:26px;">#</th><th>سرور</th><th style="width:135px;">IP / محل</th><th style="width:90px;">حجم (GB)</th>
              <th style="width:130px;">زمان‌بندی بکاپ</th><th style="width:110px;">آخرین ریستور</th><th style="width:110px;">آخرین فول بک‌آپ</th><th style="width:100px;">Storage</th>
              <th style="width:70px;">
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
                  <span class="edit-switch"><input type="checkbox" id="editToggleServers"><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr>
            <tr class="filter-row">
              <th></th>
              <th><input type="text" class="col-filter" data-key="server" placeholder="جستجو..."></th>
              <th><input type="text" class="col-filter" data-key="location" placeholder="جستجو..."></th>
              <th><input type="text" class="col-filter" data-key="size" placeholder="جستجو..."></th>
              <th><div class="msf" id="msfSchedule" data-key="schedule"></div></th>
              <th><input type="text" class="col-filter" data-key="lastRestore" placeholder="جستجو..."></th>
              <th><input type="text" class="col-filter" data-key="lastFullBackup" placeholder="جستجو..."></th>
              <th><div class="msf" id="msfStorage" data-key="storage"></div></th>
              <th></th>
            </tr>
            </thead>
            <tbody id="serversBody"></tbody>
          </table>
        </div>
      </div>

      <div class="panel">
        <h3>📅 تقویم موفقیت بکاپ روزانه</h3>
        <p style="font-size:12.5px; color:var(--ink-soft); line-height:1.9; margin:0 0 12px;">
          از <b id="dailySlotsTxt"></b> نوبت بکاپ برنامه‌ریزی‌شده، تعداد <b id="dailyMarksTxt"></b> نوبت با موفقیت ثبت شده — نرخ موفقیت کلی: <b id="dailyPctTxt"></b>. آخرین تاریخ ثبت‌شده: <b id="lastBackupDateTxt"></b>.
        </p>
        <div id="dailyRibbonTables"></div>
      </div>

      <div class="panel">
        <h3>🛰️ چک‌لیست بررسی ریموت روزانه</h3>
        <p style="font-size:12.5px; color:var(--ink-soft); line-height:1.9; margin:0 0 10px;">
          روی هر روز کلیک کنید تا به‌عنوان «بررسی‌شده و موفق» علامت بخورد.
        </p>
        <div class="toolbar" data-feat="xlsx" style="margin-bottom:12px;">
          <button class="btn btn-brass" id="refreshRemoteBtn">⬆ خواندن از فایل اکسل</button>
          <span class="save-hint" id="remoteSyncStatus" style="font-size:11.5px;"></span>
        </div>
        <div id="remoteChecklistWrap"></div>
      </div>
    </section>

    <!-- COMPANIES -->
    <section class="view" id="view-companies" data-feat="view:companies">
      <div class="section-title">شرکت‌ها</div>
      <div class="section-sub">تاریخچه‌ی بازدید/پشتیبانی شرکت‌ها</div>

      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshDateBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="dateSyncStatus" style="font-size:11.5px;"></span>
      </div>

      <div id="companiesWrap"></div>
    </section>

    <!-- MVPN -->
    <section class="view" id="view-mvpn" data-feat="view:mvpn">
      <div class="section-title">سرویس MVPN</div>
      <div class="section-sub">فهرست خطوط سازمانی</div>

      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshMvpnBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="mvpnSyncStatus" style="font-size:11.5px;"></span>
      </div>

      <div class="cards" id="mvpnCards"></div>

      <div class="panel">
        <h3>📱 فهرست خطوط</h3>
        <div class="tbl-wrap">
          <table>
            <thead>
            <tr>
              <th style="width:26px;">#</th><th style="width:135px;">شماره تماس</th><th>مالکیت سیم‌کارت</th><th>مرحله</th>
              <th style="width:90px;">داخلی</th><th>طرح انتخابی</th>
              <th style="width:70px;">
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
                  <span class="edit-switch"><input type="checkbox" id="editToggleMvpn"><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr>
            <tr class="filter-row">
              <th></th>
              <th><input type="text" class="mvpn-filter" data-key="phone" placeholder="جستجو..."></th>
              <th><input type="text" class="mvpn-filter" data-key="owner" placeholder="جستجو..."></th>
              <th><div class="msf" id="msfStage" data-key="stage"></div></th>
              <th><input type="text" class="mvpn-filter" data-key="ext" placeholder="جستجو..."></th>
              <th><div class="msf" id="msfPlan" data-key="plan"></div></th>
              <th></th>
            </tr>
            </thead>
            <tbody id="mvpnBody"></tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- PERSONAL (password protected) -->
    <section class="view" id="view-personal" data-feat="vault">
      <div class="section-title">🔒 دیتای شخصی</div>
      <div class="section-sub">این بخش با رمز عبور جداگانه محافظت می‌شود و داده‌هایش حتی در فایل اکسل و فایل ذخیره‌سازی به‌صورت رمزنگاری‌شده نگه‌داری می‌شود — بدون رمز درست، هیچ‌کس (از جمله خود این برنامه) نمی‌تواند آن را بخواند.</div>
      <div id="personalWrap"></div>
    </section>

    <!-- DATE TOOLS -->
    <section class="view" id="view-datetools" data-feat="view:datetools">
      <div class="section-title">🧮 تبدیل تاریخ و محاسبه‌ی بین دو تاریخ</div>
      <div class="section-sub">تبدیل دوطرفه‌ی تاریخ شمسی و میلادی، و محاسبه‌ی فاصله‌ی بین دو تاریخ شمسی</div>

      <div class="grid2">
        <div class="panel">
          <h3>📅 شمسی ← میلادی</h3>
          <div class="dt-row">
            <select id="dtJY"></select>
            <select id="dtJM"></select>
            <select id="dtJD"></select>
          </div>
          <div class="dt-result" id="dtJ2GResult">—</div>
        </div>
        <div class="panel">
          <h3>📅 میلادی ← شمسی</h3>
          <div class="dt-row">
            <input type="date" id="dtGDate">
          </div>
          <div class="dt-result" id="dtG2JResult">—</div>
        </div>
      </div>

      <div class="panel" style="margin-top:16px;">
        <h3>⏳ محاسبه‌ی فاصله‌ی بین دو تاریخ (شمسی)</h3>
        <div class="dt-diff-grid">
          <div>
            <label>تاریخ شروع</label>
            <div class="dt-row">
              <select id="dtStartY"></select>
              <select id="dtStartM"></select>
              <select id="dtStartD"></select>
            </div>
          </div>
          <div>
            <label>تاریخ پایان</label>
            <div class="dt-row">
              <select id="dtEndY"></select>
              <select id="dtEndM"></select>
              <select id="dtEndD"></select>
            </div>
          </div>
        </div>
        <button type="button" class="btn btn-brass btn-sm" id="dtDiffBtn" style="margin-top:10px;">محاسبه‌ی فاصله</button>
        <div class="dt-result dt-diff-result" id="dtDiffResult"></div>
      </div>
    </section>

    <!-- GUIDE -->
{{PART:settings}}
    <!-- ASSISTANT -->
{{PART:report}}

    <section class="view" id="view-assistant" data-feat="ai">
      <div class="section-title">🤖 دستیار هوشمند</div>
      <div class="section-sub">هر چیزی بپرسید — هم دربارهٔ همین کارتابل، هم هر سؤال دیگری</div>
      <div class="ai-wrap">
        <div class="ai-log" id="aiLog"></div>
        <div class="ai-tips" id="aiTips"></div>
        <div class="ai-bar">
          <textarea id="aiInput" rows="1" placeholder="سؤالتان را بنویسید…"></textarea>
          <button type="button" class="btn btn-brass ai-send" id="aiSend">بفرست</button>
        </div>
      </div>
      <div class="ai-foot">
        <div class="ai-note">Enter می‌فرستد، Shift+Enter خط تازه می‌آورد. جواب‌ها را هوش مصنوعی می‌سازد و ممکن است اشتباه باشند — عددهای مهم را از خودِ کارتابل هم ببینید. «دیتای شخصی» رمزنگاری‌شده است و به دستیار داده نمی‌شود.</div>
        <button type="button" class="btn btn-ghost" id="aiClear">🗑 پاک کردن گفتگو</button>
      </div>
    </section>

    <section class="view" id="view-guide">
      <div class="section-title">راهنمای استفاده</div>
      <div class="section-sub">این کارتابل جایگزین دیجیتال پلنر اکسل شماست</div>
      <div class="panel">
        <div class="guide-item">
          <div class="ic">📊</div>
          <div><h4>داشبورد</h4><p>خلاصه‌ی وضعیت ماه را به‌صورت کارت، نمودار و مهر پیشرفت نشان می‌دهد — به‌طور خودکار از چک‌لیست محاسبه می‌شود.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">✅</div>
          <div><h4>چک‌لیست وظایف ماهانه</h4><p>وظایف تکرارشونده را مدیریت کنید: وضعیت و اولویت را از منوی کشویی هر ردیف انتخاب نمایید، وظیفه اضافه یا حذف کنید.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">🗓️</div>
          <div><h4>برنامه روزانه</h4><p>برای هر روز ماه، وظایف اصلی، جلسات و وضعیت پیشرفت را ثبت کنید.</p></div>
        </div>
<!--IT-->
        <div class="guide-item">
          <div class="ic">📈</div>
          <div><h4>شاخص‌های کلیدی (KPI)</h4><p>هدف و مقدار واقعی هر شاخص فنی (مثل آپ‌تایم یا نرخ موفقیت بکاپ) را وارد کنید تا انحراف و درصد تحقق به‌طور خودکار محاسبه و نمودار آن رسم شود.</p></div>
        </div>
<!--/IT-->
        <div class="guide-item" data-feat="view:servers">
          <div class="ic">🖥️</div>
          <div><h4>سرورها و بکاپ</h4><p>فهرست سرورها، زمان‌بندی بکاپ و تقویم بکاپ روزانه. هر افزودن سرور، ویرایش سلول یا تیک‌زدنِ تقویم، همان لحظه روی سرور ذخیره می‌شود.</p></div>
        </div>
        <div class="guide-item" data-feat="view:companies">
          <div class="ic">🏢</div>
          <div><h4>شرکت‌ها</h4><p>تاریخچهٔ بازدید و پشتیبانی هر شرکت. می‌توانید بازدید تازه اضافه کنید یا شرکت جدید بسازید؛ همه‌چیز خودکار ذخیره می‌شود.</p></div>
        </div>
        <div class="guide-item" data-feat="view:mvpn">
          <div class="ic">📱</div>
          <div><h4>سرویس MVPN</h4><p>فهرست خطوط سازمانی. روی هر خانه کلیک کنید تا ویرایش شود، یا خط تازه اضافه کنید — خودکار ذخیره می‌شود.</p></div>
        </div>
        <div class="guide-item" data-feat="view:servers">
          <div class="ic">🛰️</div>
          <div><h4>چک‌لیست بررسی ریموت روزانه</h4><p>روی هر روز کلیک کنید تا علامت «بررسی‌شده و موفق» بخورد، یا سرور و روزِ تازه اضافه کنید.</p></div>
        </div>
        <div class="legend-row">
          <span><i class="dot" style="background:var(--green);"></i> انجام شد</span>
          <span><i class="dot" style="background:var(--amber);"></i> در حال انجام</span>
          <span><i class="dot" style="background:var(--red);"></i> انجام نشده</span>
        </div>
      </div>
    </section>

    <footer class="appfoot">{{TITLE}} — نسخه‌ی دیجیتال پلنر</footer>
  </div>
</div>

<div class="exp-ov" id="expOverlay" hidden>
  <div class="exp-box">
    <div class="exp-ic">⏳</div>
    <h3>مهلتِ این کارتابل رو به پایان است</h3>
    <div class="exp-n" id="expDays"></div>
    <p id="expNote"></p>
    <button type="button" id="expOk">باشه، متوجه شدم</button>
  </div>
</div>

<div class="cm-overlay" id="chartModalOverlay">
  <div class="cm-box">
    <div class="cm-head">
      <div class="cm-title" id="chartModalTitle"></div>
      <button class="cm-close" id="chartModalClose">✕</button>
    </div>
    <div class="cm-body" id="chartModalBody"></div>
  </div>
</div>
{{PART:gatejs}}
<script>
const STATUS = ["انجام نشده","در حال انجام","انجام شد"];
const PRIORITY = ["بالا","متوسط","پایین"];
const CATEGORIES = (window.KARTABL_JOB && window.KARTABL_JOB.categories)
  || ["بکاپ‌گیری","سرورها و زیرساخت","امنیت سایبری","شبکه","پشتیبانی کاربران","لایسنس و تمدیدها","مانیتورینگ","مستندسازی","سایر"];

/* گزینه‌های ستون «دسته» برای یک وظیفه.

   دستهٔ خودِ وظیفه هم — حتی اگر در فهرستِ شغل نباشد — اضافه می‌شود.
   بدون این، اگر مدیر شغلِ کاربر را عوض می‌کرد، دستهٔ وظیفه‌های قبلی از
   فهرست می‌افتاد و مرورگر گزینهٔ اول را انتخاب‌شده نشان می‌داد: کاربر
   می‌دید دستهٔ وظیفه‌اش بی‌آنکه دست بزند عوض شده، و اولین تغییرِ بعدی
   همان را ذخیره می‌کرد. */
function categoryOptions(cur){
  const c = cur == null ? "" : String(cur);
  const list = (c && !CATEGORIES.includes(c)) ? [c].concat(CATEGORIES) : CATEGORIES;
  return list.map(x=>`<option value="${escapeHtml(x)}" ${c===x?"selected":""}>${escapeHtml(x)}</option>`).join("");
}

/* ---------- Resilient Chart.js loader (tries several mirrors in case one is blocked) ---------- */
const CHART_CDN_URLS = [
  /* نسخهٔ محلی روی خودِ همین دامنه — از داخل ایران همیشه باز می‌شود.
     سیاست امنیتی سایت script-src 'self' و cdnjs است، پس jsdelivr و
     unpkg و fastly روی این دامنه هرگز بالا نمی‌آیند و فقط خطای کنسول
     می‌سازند؛ تنها پشتیبانی که واقعاً می‌تواند کار کند cdnjs است. */
  "/v/chart.umd.min.js",
  "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.4/chart.umd.min.js"
];
/* فایل ۲۰۰ کیلوبایتی روی اینترنت کند — یا بار اولی که هنوز روی لبهٔ
   کلادفلر کش نشده — راحت از شش ثانیه رد می‌شود. یک‌بار همین‌طور شد و
   صفحه بی‌دلیل سراغ CDN رفت. برای فایل خودی مهلت بلندتری می‌دهیم. */
{{PART:chartlib}}
/* ---------- Resilient SheetJS (xlsx) loader — lazy, only loads when needed ---------- */
const XLSX_CDN_URLS = [
  /* همان منطق نسخهٔ محلی برای کتابخانهٔ اکسل */
  "/v/xlsx.full.min.js",
  "https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"
];
let xlsxLibPromise = null;
function xlsxReady(){ return typeof XLSX !== "undefined"; }
async function ensureXlsxLib(){
  if(xlsxReady()) return true;
  if(!xlsxLibPromise){
    xlsxLibPromise = (async ()=>{
      for(const url of XLSX_CDN_URLS){
        try{
          await loadScriptOnce(url, timeoutFor(url));
          if(xlsxReady()) return true;
        }catch(e){ /* try next mirror */ }
      }
      return false;
    })();
  }
  return xlsxLibPromise;
}

const DEFAULT_STATE = {
  meta:{ month:"", year:"" },
  remoteChecks:{},
  remoteCheckDates: Array.from({length:15}, ()=>""),
  /* شغلِ انتخاب‌شده اگر چک‌لیستِ خودش را داشته باشد، همان می‌نشیند. */
  tasks: (window.KARTABL_JOB && window.KARTABL_JOB.tasks)
    ? JSON.parse(JSON.stringify(window.KARTABL_JOB.tasks))
    : [
    {category:"بکاپ‌گیری", task:"بررسی صحت بکاپ شبانه‌ی سرورها", owner:"کارشناس زیرساخت", deadline:1, status:"انجام شد", priority:"بالا", note:"نمونه تکمیل‌شده"},
    {category:"بکاپ‌گیری", task:"تست بازیابی اطلاعات (Restore Test) از بکاپ", owner:"مدیر IT", deadline:15, status:"انجام نشده", priority:"بالا", note:""},
    {category:"سرورها و زیرساخت", task:"بررسی سلامت و منابع سرورها (CPU/RAM/Disk)", owner:"کارشناس زیرساخت", deadline:5, status:"انجام نشده", priority:"بالا", note:""},
    {category:"سرورها و زیرساخت", task:"به‌روزرسانی و پچ سیستم‌عامل سرورها", owner:"کارشناس زیرساخت", deadline:20, status:"انجام نشده", priority:"بالا", note:""},
    {category:"سرورها و زیرساخت", task:"بررسی فضای ذخیره‌سازی و پاک‌سازی لاگ‌های اضافی", owner:"کارشناس زیرساخت", deadline:23, status:"انجام نشده", priority:"پایین", note:""},
    {category:"امنیت سایبری", task:"به‌روزرسانی آنتی‌ویروس و فایروال", owner:"کارشناس امنیت", deadline:10, status:"انجام نشده", priority:"بالا", note:""},
    {category:"امنیت سایبری", task:"بازبینی لاگ‌های امنیتی و هشدارهای مشکوک", owner:"کارشناس امنیت", deadline:7, status:"انجام نشده", priority:"بالا", note:""},
    {category:"امنیت سایبری", task:"ممیزی سطوح دسترسی و حساب‌های کاربری", owner:"مدیر IT", deadline:25, status:"انجام نشده", priority:"متوسط", note:""},
    {category:"شبکه", task:"بررسی وضعیت تجهیزات شبکه (روتر/سوییچ)", owner:"کارشناس شبکه", deadline:12, status:"انجام نشده", priority:"متوسط", note:""},
    {category:"شبکه", task:"تست سرعت و پایداری اینترنت دفاتر", owner:"کارشناس شبکه", deadline:18, status:"انجام نشده", priority:"پایین", note:""},
    {category:"پشتیبانی کاربران", task:"بررسی و بستن تیکت‌های باز پشتیبانی", owner:"کارشناس پشتیبانی", deadline:3, status:"انجام نشده", priority:"بالا", note:""},
    {category:"لایسنس و تمدیدها", task:"بررسی تاریخ انقضای لایسنس‌های نرم‌افزاری", owner:"مدیر IT", deadline:22, status:"انجام نشده", priority:"متوسط", note:""},
    {category:"لایسنس و تمدیدها", task:"تمدید دامنه و گواهی SSL", owner:"مدیر IT", deadline:28, status:"انجام نشده", priority:"بالا", note:""},
    {category:"مانیتورینگ", task:"بررسی داشبورد مانیتورینگ و آپ‌تایم سرویس‌ها", owner:"کارشناس زیرساخت", deadline:4, status:"انجام نشده", priority:"متوسط", note:""},
    {category:"مستندسازی", task:"به‌روزرسانی مستندات فنی و دیاگرام شبکه", owner:"مدیر IT", deadline:26, status:"انجام نشده", priority:"پایین", note:""},
    {category:"سایر", task:"جلسه هماهنگی هفتگی تیم IT", owner:"مدیر IT", deadline:2, status:"انجام نشده", priority:"پایین", note:""}
  ],
  days: Array.from({length:25}, (_,i)=>({day:i+1, createdDate:"", main:"", meet:"", company:"", status:"", important:false, reminderAt:"", reminderFired:false})),
  monthsData: {},
  currentMonthKey: null,
  personalVault: null
};

let state = null;
let charts = {};
const STORE_KEY = "{{STORE}}";
const FILE_NAME = "{{FILEJSON}}";
let saveTimer = null;
let dirHandle = null;

function deepClone(o){ return JSON.parse(JSON.stringify(o)); }
{{PART:idb}}

function fsaSupported(){ return typeof window.showDirectoryPicker === "function"; }

async function tryReconnectFolder(){
  /* ادمین این بخش را بسته: نه وصل می‌شویم، نه سراغِ پوشه‌ای که
     قبلاً وصل بوده می‌رویم. */
  if(featClosed("folder")) return;
  /* در سافاری و مرورگر گوشی این امکان نیست. قبلاً یک دکمهٔ خاکستریِ
     «نامعتبر در این مرورگر» ته ستون کناری می‌ماند که فقط جا می‌گرفت؛
     حالا کل بخش نشان داده نمی‌شود. */
  const panel = document.getElementById("folderPanel");
  if(!fsaSupported()) return;
  if(panel) panel.hidden = false;
  const handle = await idbGet("dir");
  if(!handle){
    updateFolderStatus("به هیچ پوشه‌ای وصل نیست.");
    return;
  }
  try{
    const perm = await handle.queryPermission({mode:"readwrite"});
    if(perm === "granted"){
      dirHandle = handle;
      updateFolderStatus("🗂️ متصل به پوشه: «"+handle.name+"» — فایل به‌روزرسانی می‌شود.");
      await writeToFolder();
      await loadDatabase();
    } else {
      updateFolderStatus("🗂️ قبلاً به پوشه «"+handle.name+"» وصل بودید — برای ادامه، دوباره روی «اتصال به پوشه» بزنید.");
    }
  }catch(e){
    updateFolderStatus("داده‌ها روی سرور ذخیره می‌شوند و از هر دستگاهی در دسترس‌اند.");
  }
}

async function connectFolder(){
  /* ادمین این بخش را بسته: نه وصل می‌شویم، نه سراغِ پوشه‌ای که
     قبلاً وصل بوده می‌رویم. */
  if(featClosed("folder")) return;
  if(!fsaSupported()) return;
  try{
    const handle = await window.showDirectoryPicker({ mode:"readwrite" });
    dirHandle = handle;
    await idbSet("dir", handle);

    let existing = null;
    try{
      const fh = await handle.getFileHandle(FILE_NAME, {create:false});
      const file = await fh.getFile();
      existing = JSON.parse(await file.text());
    }catch(e){ existing = null; }

    if(existing){
      const loadOld = confirm("این پوشه شامل داده‌ی ذخیره‌شده از قبل (مثلاً از یک سیستم دیگر) است.\nباز کردن همان داده‌؟\n\n«تایید» = بارگذاری داده‌ی موجود در پوشه\n«لغو» = نادیده گرفتن آن و ذخیره‌ی داده‌ی فعلی این مرورگر در پوشه");
      if(loadOld){
        state = Object.assign(deepClone(DEFAULT_STATE), existing);
        if(!state.tasks || !state.tasks.length) state.tasks = deepClone(DEFAULT_STATE.tasks);
        if(!state.days || !Array.isArray(state.days) || !state.days.length) state.days = deepClone(DEFAULT_STATE.days);
        if(!state.remoteChecks || typeof state.remoteChecks!=="object") state.remoteChecks = {};
        if(!state.remoteCheckDates || !Array.isArray(state.remoteCheckDates) || !state.remoteCheckDates.length) state.remoteCheckDates = deepClone(DEFAULT_STATE.remoteCheckDates);
        ensureMonthsMigration();
        renderMeta();
        renderMonthSelector();
        renderAll();
        localStorage.setItem(STORE_KEY, JSON.stringify(state));
      }
    }

    updateFolderStatus("🗂️ متصل به پوشه: «"+handle.name+"» — فایل به‌روزرسانی می‌شود.");
    await writeToFolder();
    await loadDatabase();
  }catch(e){
    // user cancelled the picker — no error needed
  }
}

async function writeToFolder(){
  if(!dirHandle) return;
  try{
    const perm = await dirHandle.queryPermission({mode:"readwrite"});
    if(perm !== "granted"){
      const req = await dirHandle.requestPermission({mode:"readwrite"});
      if(req !== "granted") return;
    }
    const fileHandle = await dirHandle.getFileHandle(FILE_NAME, {create:true});
    const writable = await fileHandle.createWritable();
    await writable.write(JSON.stringify(state, null, 2));
    await writable.close();
  }catch(e){
    updateFolderStatus("⚠️ نوشتن در پوشه ناموفق بود — داده‌ها فقط در مرورگر ذخیره می‌شوند.");
  }
}

/* ---------------- Monthly data (checklist + daily plan are per-month) ---------------- */

function monthKeyOf(month, year){
  return (String(year||"").trim()||"?") + "|" + (String(month||"").trim()||"?");
}
function monthLabelOf(key){
  const parts = String(key).split("|");
  return (parts[1]||"") + " " + (parts[0]||"");
}
function ensureMonthsMigration(){
  if(!state.monthsData || typeof state.monthsData!=="object") state.monthsData = {};
  if(!state.currentMonthKey || !state.monthsData[state.currentMonthKey]){
    // first run after upgrade, or missing key: adopt whatever tasks/days are already loaded as "the current month"
    const key = monthKeyOf(state.meta && state.meta.month, state.meta && state.meta.year);
    if(!state.monthsData[key]){
      state.monthsData[key] = { tasks: state.tasks, days: state.days };
    }
    state.currentMonthKey = key;
  }
}
function allMonthsSnapshot(){
  const snap = deepClone(state.monthsData||{});
  if(state.currentMonthKey) snap[state.currentMonthKey] = { tasks: state.tasks, days: state.days };
  return snap;
}
function switchToMonth(monthName, year){
  monthName = String(monthName||"").trim();
  year = String(year||"").trim();
  if(!monthName || !year){ alert("نام ماه و سال را کامل وارد کنید."); return; }
  const key = monthKeyOf(monthName, year);
  // flush current working copy back into the map before switching away
  if(state.currentMonthKey) state.monthsData[state.currentMonthKey] = { tasks: state.tasks, days: state.days };

  if(state.monthsData[key]){
    state.tasks = state.monthsData[key].tasks;
    state.days = state.monthsData[key].days;
  } else {
    // brand new month: checklist starts empty; daily plan carries over only pending/in-progress items
    const prevDays = state.currentMonthKey && state.monthsData[state.currentMonthKey] ? state.monthsData[state.currentMonthKey].days : [];
    const carried = (prevDays||[])
      .filter(d=> d.status==="در حال انجام" || d.status==="انجام نشده")
      .map((d,i)=>({ day:i+1, createdDate:d.createdDate||"", main:d.main||"", meet:d.meet||"", company:d.company||"", status:d.status }));
    state.tasks = [];
    state.days = carried.length ? carried : deepClone(DEFAULT_STATE.days);
    state.monthsData[key] = { tasks: state.tasks, days: state.days };
  }
  state.currentMonthKey = key;
  state.meta.month = monthName;
  state.meta.year = year;
  afterMonthChange();
}

/* هر چیزی که بعد از عوض شدنِ ماه باید دوباره کشیده شود. یک فهرست، دو
   صدازننده (عوض کردنِ ماه و تغییرِ نامش) — دو فهرست یعنی یکی‌شان یک
   روز چیزی می‌گیرد که آن یکی نمی‌گیرد. این دنباله در دو قالب فرق
   دارد، پس هر کدام مالِ خودش را دارد. */
function afterMonthChange(){
  renderMeta();
  renderMonthSelector();
  renderAll();
  scheduleSave();
}
{{PART:monthpop}}


/* ---------- دادهٔ داخلِ فایلِ پشتیبان ----------
   فایلِ پشتیبان تا حالا خالی باز می‌شد و آدم باید می‌فهمید که باید
   «⬆ بازیابی» بزند و کدام فایل را بدهد. حالا داده داخلِ خودِ صفحه
   نشسته و همان بار اول پُر باز می‌شود.

   مهرِ زمانِ پشتیبان نگه داشته می‌شود تا اگر همان فایل را دوباره باز
   کردید، چیزی که این وسط عوض کرده‌اید پاک نشود — ولی پشتیبانِ تازه‌تر
   جای قبلی را بگیرد. اگر localStorage در دسترس نباشد (روی file:// گاهی
   نیست) هر بار از خودِ فایل خوانده می‌شود، که همان رفتارِ درست است. */
let BK_SEED_READ = false, BK_SEED = null;
function bkSeed(){
  if(BK_SEED_READ) return BK_SEED;
  BK_SEED_READ = true;
  const s = (window.KARTABL_OFFLINE && window.KARTABL_SEED) ? window.KARTABL_SEED : null;
  if(s){
    try{
      if(localStorage.getItem(STORE_KEY + ":seed") === String(s.stamp)){ BK_SEED = null; return null; }
    }catch(e){ /* بدون حافظهٔ محلی هم باید باز شود */ }
  }
  BK_SEED = s;
  return BK_SEED;
}
function bkSeedDone(){
  const s = window.KARTABL_SEED;
  if(!s) return;
  try{ localStorage.setItem(STORE_KEY + ":seed", String(s.stamp)); }catch(e){}
}

async function loadState(){
  /* دادهٔ پشتیبان یک شاخهٔ جدا نیست، فقط یک سرچشمهٔ دیگر برای همان
     بایت‌هاست. اگر شاخهٔ جدا بود، پر کردنِ پیش‌فرض‌ها دو جا نوشته
     می‌شد و یکی‌شان یک روز عقب می‌افتاد. */
  const seed = bkSeed();
  try{
    const raw = (seed && seed.state) ? JSON.stringify(seed.state) : localStorage.getItem(STORE_KEY);
    if(raw){
      const parsed = JSON.parse(raw);
      state = Object.assign(deepClone(DEFAULT_STATE), parsed);
      if(!state.tasks || !state.tasks.length) state.tasks = deepClone(DEFAULT_STATE.tasks);
      if(!state.days || !Array.isArray(state.days) || !state.days.length) state.days = deepClone(DEFAULT_STATE.days);
      if(!state.remoteChecks || typeof state.remoteChecks!=="object") state.remoteChecks = {};
      if(!state.remoteCheckDates || !Array.isArray(state.remoteCheckDates) || !state.remoteCheckDates.length) state.remoteCheckDates = deepClone(DEFAULT_STATE.remoteCheckDates);
    } else {
      state = deepClone(DEFAULT_STATE);
    }
  }catch(e){
    state = deepClone(DEFAULT_STATE);
  }
  ensureMonthsMigration();
  /* آنچه از فایلِ پشتیبان آمد روی همین مرورگر هم می‌نشیند، تا اگر
     صفحه را دوباره باز کردی همان‌جا باشد. */
  if(seed && seed.state){ try{ localStorage.setItem(STORE_KEY, JSON.stringify(state)); }catch(e){} }
}

function scheduleSave(){
  const hint = document.getElementById("saveHint");
  if(hint) hint.textContent = "در حال ذخیره...";
  clearTimeout(saveTimer);
  saveTimer = setTimeout(async ()=>{
    try{
      localStorage.setItem(STORE_KEY, JSON.stringify(state));
      if(dirHandle) await writeToFolder();
      if(dirHandle){ saveTasksSheet(); saveDaysSheet(); }
      if(hint) hint.textContent = "✓ ذخیره شد";
      /* نسخهٔ محلی نوشته شد؛ حالا همان را روی سرور هم بگذار */
      try{ Cloud.push(); }catch(e){ /* هنوز بالا نیامده */ }
    }catch(e){
      if(hint) hint.textContent = "ذخیره ناموفق بود";
    }
  }, 500);
}

/* ---------------- Rendering ---------------- */

function renderMeta(){
  renderMonthSelector();
}

function statusBadgeClass(s){
  if(s==="انجام شد") return "done";
  if(s==="در حال انجام") return "doing";
  return "todo";
}
function priorityClass(p){
  if(p==="بالا") return "pr-high";
  if(p==="متوسط") return "pr-mid";
  return "pr-low";
}

function computeStats(){
  const total = state.tasks.length;
  const done = state.tasks.filter(t=>t.status==="انجام شد").length;
  const doing = state.tasks.filter(t=>t.status==="در حال انجام").length;
  const todo = state.tasks.filter(t=>t.status==="انجام نشده").length;
  const critical = state.tasks.filter(t=>t.priority==="بالا" && t.status!=="انجام شد").length;
  const pct = total ? Math.round((done/total)*100) : 0;
  return {total,done,doing,todo,critical,pct};
}

function computeDailyStats(){
  const doneDays = state.days.filter(d=>d.status==="انجام شد").length;
  const doingDays = state.days.filter(d=>d.status==="در حال انجام").length;
  const todoDays = state.days.filter(d=>d.status==="انجام نشده").length;
  const emptyDays = state.days.filter(d=>!d.status).length;
  const totalDays = state.days.length;
  return {doneDays, doingDays, todoDays, emptyDays, totalDays};
}

/* ---------------- Chart drill-down modal ---------------- */

function openChartModal(title, icon, items, renderItem){
  const overlay = document.getElementById("chartModalOverlay");
  const titleEl = document.getElementById("chartModalTitle");
  const bodyEl = document.getElementById("chartModalBody");
  titleEl.innerHTML = `<span>${icon||""}</span> ${escapeHtml(title)} <span class="cm-count">${fa(items.length)}</span>`;
  bodyEl.innerHTML = items.length
    ? items.map(renderItem).join("")
    : `<div class="cm-empty">موردی برای نمایش نیست.</div>`;
  overlay.classList.add("open");
}
function closeChartModal(){
  const overlay = document.getElementById("chartModalOverlay");
  if(overlay) overlay.classList.remove("open");
}
function setupChartModal(){
  const overlay = document.getElementById("chartModalOverlay");
  const closeBtn = document.getElementById("chartModalClose");
  if(closeBtn) closeBtn.addEventListener("click", closeChartModal);
  if(overlay) overlay.addEventListener("click", (e)=>{ if(e.target===overlay) closeChartModal(); });
  document.addEventListener("keydown", (e)=>{ if(e.key==="Escape") closeChartModal(); });
}
function renderTaskModalItem(t){
  return `<div class="cm-item">
    <div class="cm-item-title">${escapeHtml(t.task||"(بدون عنوان)")}</div>
    <div class="cm-item-meta">
      ${t.category? `<span>📂 ${escapeHtml(t.category)}</span>`:""}
      ${t.owner? `<span>👤 ${escapeHtml(t.owner)}</span>`:""}
      ${t.deadline!=null && t.deadline!==""? `<span>📅 روز ${fa(t.deadline)}</span>`:""}
      ${t.priority? `<span>🚦 ${escapeHtml(t.priority)}</span>`:""}
    </div>
  </div>`;
}
function renderDayModalItem(d, idx){
  return `<div class="cm-item">
    <div class="cm-item-title">ردیف ${fa((idx!=null?idx:0)+1)}${d.main? " — "+escapeHtml(d.main):""}</div>
    <div class="cm-item-meta">
      ${d.meet? `<span>🤝 ${escapeHtml(d.meet)}</span>`:""}
      ${d.company? `<span>🏢 ${escapeHtml(d.company)}</span>`:""}
    </div>
  </div>`;
}
function renderMvpnModalItem(l){
  return `<div class="cm-item">
    <div class="cm-item-title">${escapeHtml(l.owner||"(بدون نام)")}</div>
    <div class="cm-item-meta">
      <span>📞 ${escapeHtml(l.phone||"")}</span>
      ${l.ext? `<span>☎️ داخلی ${escapeHtml(l.ext)}</span>`:""}
      ${l.plan? `<span>📦 ${escapeHtml(l.plan)}</span>`:""}
    </div>
  </div>`;
}
function renderVisitModalItem(v){
  return `<div class="cm-item">
    <div class="cm-item-title">${escapeHtml(v.dateStr||"")}</div>
    <div class="cm-item-meta">
      ${v.time? `<span>⏱️ ${escapeHtml(v.time)}</span>`:""}
      ${v.type? `<span>🔧 ${escapeHtml(TYPE_LABELS_FA[v.type]||v.type)}</span>`:""}
    </div>
  </div>`;
}
function renderVisitModalItemWithCompany(v){
  return `<div class="cm-item">
    <div class="cm-item-title">${escapeHtml(v.company||"")} — ${escapeHtml(v.dateStr||"")}</div>
    <div class="cm-item-meta">
      ${v.time? `<span>⏱️ ${escapeHtml(v.time)}</span>`:""}
    </div>
  </div>`;
}
function renderRemoteStatusModalItem(p){
  return `<div class="cm-item">
    <div class="cm-item-title">${escapeHtml(p.server)}</div>
    <div class="cm-item-meta">
      <span>✅ ${fa(p.count)} روز بررسی‌شده</span>
      <span>📊 ${fa(p.pct)}٪</span>
    </div>
  </div>`;
}
function renderBackupDayModalItem(e){
  return `<div class="cm-item">
    <div class="cm-item-title">${fa(e.year)}/${fa(e.month)}/${fa(e.day)}</div>
    <div class="cm-item-meta">
      <span>${e.done? "✅ موفق" : "❌ ناموفق/بدون ثبت"}</span>
    </div>
  </div>`;
}
function chartHoverCursor(evt, elements){
  if(evt.native && evt.native.target) evt.native.target.style.cursor = elements.length ? "pointer" : "default";
}

function renderCompanyLastVisits(){
  const el = document.getElementById("companyLastVisits");
  if(!el) return;
  const names = companiesData ? Object.keys(companiesData.companies) : [];
  if(!names.length){
    el.innerHTML = `<p style="color:var(--ink-faint); font-size:12.5px; padding:8px 2px;">داده‌ای از شرکت‌ها بارگذاری نشده — از پوشه‌ی مشترک وصل شوید.</p>`;
    return;
  }
  const rows = names.map(name=>{
    const entries = companiesData.companies[name] || [];
    const last = entries.length ? entries[entries.length-1] : null;
    return { name, last };
  });
  rows.sort((a,b)=>{
    if(!a.last && !b.last) return a.name.localeCompare(b.name, "fa");
    if(!a.last) return 1;
    if(!b.last) return -1;
    return b.last.dateStr.localeCompare(a.last.dateStr);
  });
  el.innerHTML = rows.map(r=>`
    <div class="clv-row">
      <span class="clv-name">🏢 ${escapeHtml(r.name)}</span>
      ${r.last
        ? `<span class="clv-date">${escapeHtml(r.last.dateStr)}<span class="clv-type">${escapeHtml(TYPE_LABELS_FA[r.last.type]||r.last.type||"")}</span></span>`
        : `<span class="clv-date clv-empty">بدون بازدید ثبت‌شده</span>`}
    </div>
  `).join("");
}

function toPersianDigits(n){
  const map = {"0":"۰","1":"۱","2":"۲","3":"۳","4":"۴","5":"۵","6":"۶","7":"۷","8":"۸","9":"۹"};
  return String(n).replace(/[0-9]/g, d=>map[d]);
}
const fa = toPersianDigits;

function getTodayJalaliStr(){
  try{
    const fmt = new Intl.DateTimeFormat("fa-IR-u-ca-persian-nu-latn", {year:"numeric", month:"2-digit", day:"2-digit"});
    const parts = fmt.formatToParts(new Date());
    const y = parts.find(p=>p.type==="year").value;
    const m = parts.find(p=>p.type==="month").value;
    const d = parts.find(p=>p.type==="day").value;
    return `${y}/${m}/${d}`;
  }catch(e){
    return new Date().toLocaleDateString("fa-IR");
  }
}

function renderDashHero(){
  const el = document.getElementById("dashHero");
  if(!el) return;
  const hour = new Date().getHours();
  let greet = "شب بخیر";
  if(hour>=5 && hour<12) greet = "صبح بخیر";
  else if(hour>=12 && hour<17) greet = "ظهرتون بخیر";
  else if(hour>=17 && hour<21) greet = "عصر بخیر";
  const todayStr = getTodayJalaliStr();
  const parts = todayStr.split("/");
  const monthNames = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور","مهر","آبان","آذر","دی","بهمن","اسفند"];
  const monthName = parts[1] ? monthNames[parseInt(parts[1],10)-1] : "";
  el.innerHTML = `
    <div>
      <div class="dh-greet">👋 ${greet}، {{NAME}}</div>
      <div class="dh-sub">خلاصه‌ی وضعیت امروز و این ماه، همه‌جا یک نگاه</div>
    </div>
    <div class="dh-date">امروز<b>${parts[2]?fa(parts[2]):""} ${monthName} ${parts[0]?fa(parts[0]):""}</b></div>
    <div class="dh-clock">ساعت اکنون<b id="dashHeroClock">--:--:--</b></div>
  `;
  updateLiveClocks();
}

/* ---------------- Live clock ---------------- */
function updateLiveClocks(){
  const now = new Date();
  const hh = String(now.getHours()).padStart(2,"0");
  const mm = String(now.getMinutes()).padStart(2,"0");
  const ss = String(now.getSeconds()).padStart(2,"0");
  const txt = fa(`${hh}:${mm}:${ss}`);
  const topEl = document.getElementById("topbarClock");
  if(topEl) topEl.textContent = txt;
  /* تاریخِ امروز فقط وقتی عوض می‌شود که روز عوض شود، ولی ساختنش ارزان
     است و این‌طور نیازی به تایمرِ دوم نیست. */
  const dEl = document.getElementById("topbarDate");
  if(dEl){
    try{
      dEl.textContent = new Intl.DateTimeFormat("fa-IR-u-ca-persian",
        { weekday:"short", day:"numeric", month:"long" }).format(now);
    }catch(e){ dEl.textContent = ""; }
  }
  const heroEl = document.getElementById("dashHeroClock");
  if(heroEl) heroEl.textContent = txt;
}
setInterval(updateLiveClocks, 1000);

function renderCards(){
  const s = computeStats();
  const wrap = document.getElementById("statCards");
  wrap.innerHTML = `
    <div class="stat blue" data-ic="📋"><div class="lbl">📋 کل وظایف ماه</div><div class="val">${fa(s.total)}</div></div>
    <div class="stat green" data-ic="✅"><div class="lbl">✅ انجام شده</div><div class="val">${fa(s.done)}</div></div>
    <div class="stat teal" data-ic="🔄"><div class="lbl">🔄 در حال انجام</div><div class="val">${fa(s.doing)}</div></div>
    <div class="stat amber" data-ic="⏳"><div class="lbl">⏳ انجام نشده</div><div class="val">${fa(s.todo)}</div></div>
    <div class="stat red" data-ic="🔴"><div class="lbl">🔴 اولویت بالا (باز)</div><div class="val">${fa(s.critical)}</div></div>
    <div class="stat purple" data-ic="🎯"><div class="lbl">🎯 درصد پیشرفت</div><div class="val">${fa(s.pct)}٪</div></div>
  `;
}

function renderDeadlines(){
  const body = document.getElementById("deadlinesBody");
  const rows = [...state.tasks]
    .map((t,i)=>({...t, idx:i}))
    .sort((a,b)=>(a.deadline||0)-(b.deadline||0))
    .slice(0,10);
  body.innerHTML = rows.map(t=>`
    <tr>
      <td style="text-align:right;">${escapeHtml(t.task)}</td>
      <td>${escapeHtml(t.category)}</td>
      <td>${t.deadline!==""&&t.deadline!=null ? fa(t.deadline) : ""}</td>
      <td><span class="badge ${statusBadgeClass(t.status)}">${t.status}</span></td>
      <td class="${priorityClass(t.priority)}">${t.priority}</td>
    </tr>
  `).join("");
}

/* ---------------- Reminders / notifications ---------------- */
const NOTIFIED_KEY = "it-manager-notified-keys-v1";
let notifiedKeysCache = null;
function loadNotifiedKeys(){
  if(notifiedKeysCache) return notifiedKeysCache;
  try{
    const raw = localStorage.getItem(NOTIFIED_KEY);
    notifiedKeysCache = raw ? new Set(JSON.parse(raw)) : new Set();
  }catch(e){ notifiedKeysCache = new Set(); }
  return notifiedKeysCache;
}
function markNotified(key){
  const set = loadNotifiedKeys();
  set.add(key);
  try{ localStorage.setItem(NOTIFIED_KEY, JSON.stringify([...set])); }catch(e){}
}
function alreadyNotified(key){ return loadNotifiedKeys().has(key); }

function requestNotifyPermission(){
  try{
    if(typeof Notification !== "undefined" && Notification.permission === "default"){
      Notification.requestPermission();
    }
  }catch(e){ /* Notification API not available — banner-only fallback */ }
}
function fireBrowserNotification(title, body){
  try{
    if(typeof Notification !== "undefined" && Notification.permission === "granted"){
      new Notification(title, { body, icon:undefined });
    }
  }catch(e){ /* ignore */ }
}

/* ---------------- Reminder sound (Web Audio, no external file needed) ---------------- */
let sharedAudioCtx = null;
function getAudioCtx(){
  try{
    const AudioCtx = window.AudioContext || window.webkitAudioContext;
    if(!AudioCtx) return null;
    if(!sharedAudioCtx) sharedAudioCtx = new AudioCtx();
    if(sharedAudioCtx.state === "suspended") sharedAudioCtx.resume();
    return sharedAudioCtx;
  }catch(e){ return null; }
}
// اولین کلیک/لمس کاربر روی صفحه، پخش صدا را در مرورگرهایی که پخش خودکار صدا را محدود می‌کنند فعال می‌کند
["click","touchstart","keydown"].forEach(evt=>{
  document.addEventListener(evt, ()=>{ getAudioCtx(); }, { once:true });
});
function playReminderSound(){
  const ctx = getAudioCtx();
  if(!ctx) return;
  try{
    const now = ctx.currentTime;
    [880, 1320].forEach((freq, i)=>{
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "sine";
      osc.frequency.value = freq;
      const start = now + i*0.15;
      gain.gain.setValueAtTime(0.0001, start);
      gain.gain.exponentialRampToValueAtTime(0.30, start+0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, start+0.55);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(start);
      osc.stop(start+0.6);
    });
  }catch(e){ /* ignore */ }
}

function getTodayJalaliParts(){
  const str = getTodayJalaliStr();
  const p = str.split("/");
  const monthNames = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور","مهر","آبان","آذر","دی","بهمن","اسفند"];
  return { year: p[0]||"", monthNum: p[1]?parseInt(p[1],10):0, day: p[2]?parseInt(p[2],10):0, monthName: p[1] ? monthNames[parseInt(p[1],10)-1] : "" };
}

function computeChecklistReminders(){
  const today = getTodayJalaliParts();
  const isCurrentRealMonth = state.meta && String(state.meta.month||"").trim()===today.monthName
    && String(state.meta.year||"").trim()===String(today.year).trim();
  if(!isCurrentRealMonth) return [];
  const out = [];
  state.tasks.forEach((t,idx)=>{
    if(t.status === "انجام شد") return;
    const deadline = parseInt(t.deadline);
    if(!Number.isFinite(deadline)) return;
    const diff = deadline - today.day;
    if(diff === 1){
      const key = "chk|"+(state.currentMonthKey||"")+"|"+idx+"|"+deadline;
      out.push({ key, kind:"checklist", overdue:false,
        text: `فردا مهلت وظیفه‌ی «${t.task}» (${t.category}) فرا می‌رسد.` });
    }
  });
  return out;
}

function computeDailyImportantReminders(){
  const out = [];
  const now = new Date();
  state.days.forEach((d,idx)=>{
    if(!d.important || !d.reminderAt) return;
    const t = new Date(d.reminderAt);
    if(isNaN(t.getTime())) return;
    const key = "day|"+(state.currentMonthKey||"")+"|"+idx+"|"+d.reminderAt;
    const label = d.main ? d.main : ("روز "+(d.day!=null?fa(d.day):""));
    if(t.getTime() <= now.getTime()){
      out.push({ key, kind:"daily", overdue:true, idx,
        text: `یادآوری موعد رسیده برای «${escapeHtml(label)}» (${formatReminderAtFa(d.reminderAt)})` });
    } else if(t.getTime() - now.getTime() <= 24*3600*1000){
      out.push({ key: key+"|upcoming", kind:"daily", overdue:false, idx,
        text: `یادآوری نزدیک برای «${escapeHtml(label)}» — ${formatReminderAtFa(d.reminderAt)}` });
    }
  });
  return out;
}

let dismissedReminderKeys = new Set();
function renderRemindersBanner(){
  const el = document.getElementById("remindersBanner");
  if(!el) return;
  const items = [...computeChecklistReminders(), ...computeDailyImportantReminders()]
    .filter(r=> !dismissedReminderKeys.has(r.key));
  if(items.length === 0){ el.innerHTML = ""; return; }
  el.innerHTML = items.map(r=>`
    <div class="reminder-item ${r.overdue?'overdue':''}">
      <span class="ric">${r.overdue?'🔔':'⏰'}</span>
      <span class="rtxt">${r.text}</span>
      <button type="button" class="rdismiss" data-dismiss-key="${escapeHtml(r.key)}" title="بستن">✕</button>
    </div>
  `).join("");
  el.querySelectorAll("[data-dismiss-key]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      dismissedReminderKeys.add(btn.getAttribute("data-dismiss-key"));
      renderRemindersBanner();
    });
  });
}

function checkAndFireReminders(){
  if(!state) return;
  const chk = computeChecklistReminders();
  chk.forEach(r=>{
    if(!alreadyNotified(r.key)){
      fireBrowserNotification("🕒 مهلت نزدیک", r.text);
      enqueueReminderModal("🕒 مهلت نزدیک است", r.text, "🕒");
      markNotified(r.key);
    }
  });
  const daily = computeDailyImportantReminders().filter(r=>r.overdue);
  daily.forEach(r=>{
    if(!alreadyNotified(r.key)){
      fireBrowserNotification("⭐ یادآوری برنامه روزانه", r.text);
      enqueueReminderModal("⭐ یادآوری برنامه روزانه", r.text, "⭐");
      markNotified(r.key);
      if(state.days[r.idx]) state.days[r.idx].reminderFired = true;
    }
  });
  if(daily.length){ scheduleSave(); }
  renderRemindersBanner();
}

function escapeHtml(s){
  return (s||"").toString().replace(/[&<>"']/g, m=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[m]));
}

function destroyChart(key){ if(charts[key]){ charts[key].destroy(); delete charts[key]; } }

function chartsReady(){ return typeof Chart !== "undefined"; }

function placeholderBox(id, text, dashed){
  const el = document.getElementById(id);
  if(el && el.tagName === "CANVAS"){
    const p = document.createElement("div");
    p.id = id;
    p.style.cssText = "padding:36px 10px; text-align:center; color:var(--ink-faint); font-size:12.5px; border-radius:8px;" + (dashed ? " border:1px dashed var(--line);" : "");
    p.textContent = text;
    el.replaceWith(p);
  }
}
function noteNoCharts(ids){
  ids.forEach(id=> placeholderBox(id, "⚠️ نمودار در دسترس نیست (اتصال اینترنت لازم است). بقیه‌ی برنامه بدون اینترنت هم کار می‌کند.", true));
}
function noteLoadingCharts(ids){
  ids.forEach(id=> placeholderBox(id, "در حال بارگذاری نمودار...", false));
}
function restoreCanvas(id, heightAttr){
  const el = document.getElementById(id);
  if(el && el.tagName !== "CANVAS"){
    const c = document.createElement("canvas");
    c.id = id;
    if(heightAttr) c.setAttribute("height", heightAttr);
    el.replaceWith(c);
  }
}
{{PART:charttone}}
function renderCharts(){
  const s = computeStats();
  const d = computeDailyStats();
  renderCompanyLastVisits();
  const ids = ["chartStatus","chartMvpnStage","chartDaily","chartTopCompanies","chartRemoteStatus","chartVisitType","chartBackupSuccessRate"];

  if(!chartsReady()){
    noteLoadingCharts(ids);
    chartLibPromise.then(ok=>{
      if(ok){ ids.forEach(id=>restoreCanvas(id)); renderCharts(); }
      else noteNoCharts(ids);
    });
    return;
  }

  try{
    destroyChart("status");
    charts.status = new Chart(document.getElementById("chartStatus"), {
      type:"doughnut",
      data:{ labels:["انجام شده","در حال انجام","انجام نشده"],
        datasets:[{
          data:[s.done, s.doing, s.todo],
          backgroundColor:[chartTone().done, chartTone().doing, chartTone().todo],
          hoverBackgroundColor:chartHover([chartTone().done, chartTone().doing, chartTone().todo]),
          borderColor:chartTone().surface, borderWidth:2,
          hoverOffset:12, hoverBorderWidth:3
        }] },
      options:{
        layout:{ padding:14 }, cutout:"58%",
        plugins:{
          legend:{ position:"bottom", labels:{ font:{ family:"Vazirmatn, Tahoma, Arial, sans-serif" } } },
          tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, titleFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{ label:(ctx)=> " "+ctx.label+": "+fa(ctx.parsed) } }
        },
        animation:{ animateScale:true },
        onHover: chartHoverCursor,
        onClick:(evt, elements)=>{
          if(!elements.length) return;
          const displayLabels = ["انجام شده","در حال انجام","انجام نشده"];
          const statusValues = ["انجام شد","در حال انجام","انجام نشده"];
          const idx = elements[0].index;
          const items = state.tasks.filter(t=>t.status===statusValues[idx]);
          openChartModal("وظایف ماه — "+displayLabels[idx], "📋", items, renderTaskModalItem);
        }
      }
    });

    destroyChart("mvpnStage");
    if(document.getElementById("chartMvpnStage")) (function(){
      const mvpnLines = (mvpnData && mvpnData.lines) || [];
      const activeCount = mvpnLines.filter(l=>String(l.stage||"").includes("فعال شده")).length;
      const removeCount = mvpnLines.filter(l=>String(l.stage||"").includes("حذف")).length;
      const otherCount = mvpnLines.length - activeCount - removeCount;
      charts.mvpnStage = new Chart(document.getElementById("chartMvpnStage"), {
        type:"doughnut",
        data:{ labels:["فعال","در حال حذف","سایر"],
          datasets:[{
            data:[activeCount, removeCount, otherCount],
            backgroundColor:[chartTone().done, chartTone().bad, chartTone().todo],
            hoverBackgroundColor:chartHover([chartTone().done, chartTone().bad, chartTone().todo]),
            borderColor:chartTone().surface, borderWidth:2,
            hoverOffset:12, hoverBorderWidth:3
          }] },
        options:{
          layout:{ padding:14 }, cutout:"58%",
          plugins:{
            legend:{ position:"bottom", labels:{ font:{ family:"Vazirmatn, Tahoma, Arial, sans-serif" } } },
            tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, titleFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{ label:(ctx)=> " "+ctx.label+": "+fa(ctx.parsed)+" خط" } }
          },
          animation:{ animateScale:true },
          onHover: chartHoverCursor,
          onClick:(evt, elements)=>{
            if(!elements.length) return;
            const idx = elements[0].index;
            let items;
            if(idx===0) items = mvpnLines.filter(l=>String(l.stage||"").includes("فعال شده"));
            else if(idx===1) items = mvpnLines.filter(l=>String(l.stage||"").includes("حذف"));
            else items = mvpnLines.filter(l=>!String(l.stage||"").includes("فعال شده") && !String(l.stage||"").includes("حذف"));
            openChartModal("خطوط MVPN — "+["فعال","در حال حذف","سایر"][idx], "📱", items, renderMvpnModalItem);
          }
        }
      });
    })();

    destroyChart("topCompanies");
    if(document.getElementById("chartTopCompanies")) (function(){
      const names = companiesData ? Object.keys(companiesData.companies) : [];
      const counts = names.map(n=> (companiesData.companies[n]||[]).length);
      const paired = names.map((n,i)=>({name:n, count:counts[i]})).sort((a,b)=> b.count-a.count).slice(0,8);
      charts.topCompanies = new Chart(document.getElementById("chartTopCompanies"), {
        type:"bar",
        data:{ labels:paired.map(p=>p.name), datasets:[{ data:paired.map(p=>p.count), backgroundColor:chartTone().cat[0], hoverBackgroundColor:chartHover([chartTone().cat[0]])[0], borderRadius:4 }] },
        options:{
          indexAxis:"y",
          plugins:{ legend:{display:false}, tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{ label:(ctx)=> " "+fa(ctx.parsed.x)+" بازدید" } } },
          scales:{ x:{ ticks:{ precision:0, callback:v=>fa(v) } }, y:{ ticks:{ font:{ family:"Vazirmatn, Tahoma, Arial, sans-serif", size:11 } } } },
          onHover: chartHoverCursor,
          onClick:(evt, elements)=>{
            if(!elements.length) return;
            const name = paired[elements[0].index].name;
            const items = (companiesData.companies[name]||[]).slice().reverse();
            openChartModal("بازدیدهای "+name, "🏢", items, renderVisitModalItem);
          }
        }
      });
    })();

    destroyChart("remoteStatus");
    if(document.getElementById("chartRemoteStatus")) (function(){
      const roster = (remoteBackupData && remoteBackupData.roster) || [];
      const totalDays = state.remoteCheckDates.length || 1;
      const paired = roster.map(m=>{
        const checks = state.remoteChecks[m.server] || {};
        const count = Object.values(checks).filter(Boolean).length;
        return { server: m.server, count, pct: totalDays ? Math.round((count/totalDays)*100) : 0 };
      });
      charts.remoteStatus = new Chart(document.getElementById("chartRemoteStatus"), {
        type:"bar",
        data:{ labels:paired.map(p=>p.server), datasets:[{ data:paired.map(p=>p.pct), backgroundColor:chartTone().cat[2], hoverBackgroundColor:chartHover([chartTone().cat[2]])[0], borderRadius:4 }] },
        options:{
          indexAxis:"y",
          plugins:{ legend:{display:false}, tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{ label:(ctx)=> " "+fa(ctx.parsed.x)+"٪ بررسی‌شده" } } },
          scales:{ x:{ min:0, max:100, ticks:{ callback:v=>fa(v)+"٪" } }, y:{ ticks:{ font:{ family:"Vazirmatn, Tahoma, Arial, sans-serif", size:11 } } } },
          onHover: chartHoverCursor,
          onClick:(evt, elements)=>{
            if(!elements.length) return;
            const p = paired[elements[0].index];
            openChartModal("چک‌لیست ریموت", "📡", [p], renderRemoteStatusModalItem);
          }
        }
      });
    })();

    destroyChart("visitType");
    if(document.getElementById("chartVisitType")) (function(){
      const allVisits = [];
      const names = companiesData ? Object.keys(companiesData.companies) : [];
      names.forEach(n=> (companiesData.companies[n]||[]).forEach(v=> allVisits.push(Object.assign({company:n}, v))));
      const counts = TYPE_OPTIONS.map(t=> allVisits.filter(v=>v.type===t).length);
      charts.visitType = new Chart(document.getElementById("chartVisitType"), {
        type:"doughnut",
        data:{ labels:TYPE_OPTIONS.map(t=>TYPE_LABELS_FA[t]||t),
          datasets:[{
            data:counts,
            backgroundColor:chartTone().cat.slice(0,3),
            hoverBackgroundColor:chartHover(chartTone().cat.slice(0,3)),
            borderColor:chartTone().surface, borderWidth:2, hoverOffset:12, hoverBorderWidth:3
          }] },
        options:{
          layout:{ padding:14 }, cutout:"58%",
          plugins:{
            legend:{ position:"bottom", labels:{ font:{ family:"Vazirmatn, Tahoma, Arial, sans-serif" } } },
            tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, titleFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{ label:(ctx)=> " "+ctx.label+": "+fa(ctx.parsed)+" بازدید" } }
          },
          animation:{ animateScale:true },
          onHover: chartHoverCursor,
          onClick:(evt, elements)=>{
            if(!elements.length) return;
            const type = TYPE_OPTIONS[elements[0].index];
            const items = allVisits.filter(v=>v.type===type).slice().reverse();
            openChartModal("بازدیدهای "+(TYPE_LABELS_FA[type]||type), "🔧", items, renderVisitModalItemWithCompany);
          }
        }
      });
    })();

    destroyChart("backupSuccessRate");
    if(document.getElementById("chartBackupSuccessRate")) (function(){
      const merged = {};
      Object.keys(dailyLog).forEach(group=>{
        (dailyLog[group]||[]).forEach(e=>{
          const key = e.year+"-"+e.month+"-"+e.day;
          if(!merged[key]) merged[key] = { year:e.year, month:e.month, day:e.day, done:false };
          if(e.done) merged[key].done = true;
        });
      });
      const all = Object.values(merged);
      const successCount = all.filter(e=>e.done).length;
      const failCount = all.length - successCount;
      const pct = all.length ? Math.round((successCount/all.length)*100) : 0;
      charts.backupSuccessRate = new Chart(document.getElementById("chartBackupSuccessRate"), {
        type:"doughnut",
        data:{ labels:["موفق","ناموفق / بدون ثبت"],
          datasets:[{
            data:[successCount, failCount],
            backgroundColor:[chartTone().done, chartTone().bad],
            hoverBackgroundColor:chartHover([chartTone().done, chartTone().bad]),
            borderColor:chartTone().surface, borderWidth:2, hoverOffset:12, hoverBorderWidth:3
          }] },
        options:{
          layout:{ padding:14 }, cutout:"62%",
          plugins:{
            legend:{ position:"bottom", labels:{ font:{ family:"Vazirmatn, Tahoma, Arial, sans-serif" } } },
            tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, titleFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{ label:(ctx)=> " "+ctx.label+": "+fa(ctx.parsed)+" روز" } }
          },
          animation:{ animateScale:true },
          onHover: chartHoverCursor,
          onClick:(evt, elements)=>{
            if(!elements.length) return;
            const isSuccess = elements[0].index===0;
            const items = all.filter(e=> e.done===isSuccess)
              .sort((a,b)=> (b.year*10000+b.month*100+b.day)-(a.year*10000+a.month*100+a.day))
              .slice(0,40);
            openChartModal("روزهای "+(isSuccess?"موفق":"ناموفق/بدون ثبت")+" — "+fa(pct)+"٪ کل موفقیت", "✅", items, renderBackupDayModalItem);
          }
        }
      });
    })();

    destroyChart("daily");
    charts.daily = new Chart(document.getElementById("chartDaily"), {
      type:"doughnut",
      data:{ labels:["انجام شده","در حال انجام","انجام نشده","بدون وضعیت"],
        datasets:[{
          data:[d.doneDays, d.doingDays, d.todoDays, d.emptyDays],
          backgroundColor:[chartTone().done, chartTone().doing, chartTone().todo, chartTone().none],
          hoverBackgroundColor:chartHover([chartTone().done, chartTone().doing, chartTone().todo, chartTone().none]),
          borderColor:chartTone().surface, borderWidth:2,
          hoverOffset:12, hoverBorderWidth:3
        }] },
      options:{
        layout:{ padding:14 }, cutout:"58%",
        plugins:{
          legend:{ position:"bottom", labels:{ font:{ family:"Vazirmatn, Tahoma, Arial, sans-serif" } } },
          tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, titleFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{ label:(ctx)=> " "+ctx.label+": "+fa(ctx.parsed)+" روز" } }
        },
        animation:{ animateScale:true },
        onHover: chartHoverCursor,
        onClick:(evt, elements)=>{
          if(!elements.length) return;
          const displayLabels = ["انجام شده","در حال انجام","انجام نشده","بدون وضعیت"];
          const statusValues = ["انجام شد","در حال انجام","انجام نشده",""];
          const idx = elements[0].index;
          const items = idx===3 ? state.days.filter(dd=>!dd.status) : state.days.filter(dd=>dd.status===statusValues[idx]);
          openChartModal("وضعیت برنامه روزانه — "+displayLabels[idx], "🗓️", items, renderDayModalItem);
        }
      }
    });
  }catch(e){
    noteNoCharts(ids);
  }
}

function renderChecklist(){
  const body = document.getElementById("checklistBody");
  body.innerHTML = state.tasks.map((t,i)=>`
    <tr data-idx="${i}">
      <td>${fa(i+1)}</td>
      <td>
        <select data-field="category">${categoryOptions(t.category)}</select>
      </td>
      <td class="editable-text"><input type="text" data-field="task" value="${escapeHtml(t.task)}"></td>
      <td class="editable-text"><input type="text" data-field="owner" value="${escapeHtml(t.owner)}"></td>
      <td>
        <div class="date-box" data-idx="${i}">
          <span class="cal-ic">📅</span>
          <input type="text" class="day-picker-input" data-field="deadline" readonly
                 value="${t.deadline ? fa(t.deadline)+' ام' : ''}" placeholder="انتخاب روز">
        </div>
      </td>
      <td>
        <select data-field="status" class="st-select">
          ${STATUS.map(s=>`<option value="${s}" ${t.status===s?"selected":""}>${s}</option>`).join("")}
        </select>
      </td>
      <td>
        <select data-field="priority">
          ${PRIORITY.map(p=>`<option value="${p}" ${t.priority===p?"selected":""}>${p}</option>`).join("")}
        </select>
      </td>
      <td class="editable-text"><input type="text" data-field="note" value="${escapeHtml(t.note)}"></td>
      <td><button class="btn-del" data-del="${i}" title="حذف">✕</button></td>
    </tr>
  `).join("");

  body.querySelectorAll("[data-field]").forEach(el=>{
    el.addEventListener("change", onTaskFieldChange);
    if(el.tagName==="INPUT" && !el.readOnly) el.addEventListener("input", onTaskFieldChange);
  });
  body.querySelectorAll(".date-box").forEach(box=>{
    box.addEventListener("click", ()=>{
      const idx = parseInt(box.getAttribute("data-idx"));
      openDayPicker(box, idx);
    });
  });
  body.querySelectorAll("[data-del]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const idx = parseInt(btn.getAttribute("data-del"));
      state.tasks.splice(idx,1);
      renderAll(); scheduleSave();
    });
  });
}

let dayPickerEl = null;
function ensureDayPicker(){
  if(dayPickerEl) return dayPickerEl;
  dayPickerEl = document.createElement("div");
  dayPickerEl.className = "day-picker-popup";
  const grid = document.createElement("div");
  grid.className = "dp-grid";
  for(let d=1; d<=31; d++){
    const btn = document.createElement("button");
    btn.type = "button";
    btn.textContent = fa(d);
    btn.setAttribute("data-day", d);
    grid.appendChild(btn);
  }
  const clearBtn = document.createElement("button");
  clearBtn.type = "button";
  clearBtn.className = "dp-clear";
  clearBtn.textContent = "پاک کردن";
  dayPickerEl.appendChild(grid);
  dayPickerEl.appendChild(clearBtn);
  document.body.appendChild(dayPickerEl);

  grid.addEventListener("click", (e)=>{
    const btn = e.target.closest("button[data-day]");
    if(!btn) return;
    const day = parseInt(btn.getAttribute("data-day"));
    const idx = parseInt(dayPickerEl.getAttribute("data-target-idx"));
    state.tasks[idx].deadline = day;
    renderChecklist(); renderCards(); renderDeadlines(); renderCharts(); scheduleSave();
    closeDayPicker();
  });
  clearBtn.addEventListener("click", ()=>{
    const idx = parseInt(dayPickerEl.getAttribute("data-target-idx"));
    state.tasks[idx].deadline = "";
    renderChecklist(); renderCards(); renderDeadlines(); renderCharts(); scheduleSave();
    closeDayPicker();
  });
  document.addEventListener("click", (e)=>{
    if(!dayPickerEl.classList.contains("open")) return;
    if(dayPickerEl.contains(e.target) || e.target.closest(".date-box")) return;
    closeDayPicker();
  });
  return dayPickerEl;
}

function closeDayPicker(){
  if(dayPickerEl) dayPickerEl.classList.remove("open");
}

function openDayPicker(anchorEl, idx){
  const popup = ensureDayPicker();
  popup.setAttribute("data-target-idx", idx);
  const current = state.tasks[idx].deadline;
  popup.querySelectorAll("button[data-day]").forEach(b=>{
    b.classList.toggle("selected", current && parseInt(b.getAttribute("data-day"))===parseInt(current));
  });
  const rect = anchorEl.getBoundingClientRect();
  popup.style.top = (rect.bottom + 4) + "px";
  popup.style.left = Math.max(8, rect.left - 150) + "px";
  popup.classList.add("open");
}

function onTaskFieldChange(e){
  const tr = e.target.closest("tr");
  const idx = parseInt(tr.getAttribute("data-idx"));
  const field = e.target.getAttribute("data-field");
  let val = e.target.value;
  if(field==="deadline") val = val === "" ? "" : parseInt(val);
  state.tasks[idx][field] = val;
  renderCards(); renderDeadlines(); renderCharts(); renderRemindersBanner();
  scheduleSave();
}

let dailyStatusFilters = { status: [], company: [] };

function renderDaily(){
  const body = document.getElementById("dailyBody");
  const statusFilter = dailyStatusFilters.status || [];
  const companyFilter = dailyStatusFilters.company || [];
  const rowsToShow = state.days
    .map((d,i)=>({...d, idx:i}))
    .filter(d=> statusFilter.length===0 || statusFilter.includes(d.status))
    .filter(d=> companyFilter.length===0 || companyFilter.includes(d.company||""));
  const msfEl = document.getElementById("msfDailyStatus");
  if(msfEl) renderMultiFilter(msfEl, STATUS, dailyStatusFilters, "status", renderDaily);
  const msfCompanyEl = document.getElementById("msfDailyCompany");
  if(msfCompanyEl) renderMultiFilter(msfCompanyEl, state.days.map(d=>d.company).filter(Boolean), dailyStatusFilters, "company", renderDaily);
  body.innerHTML = rowsToShow.map((d,displayIdx)=>`
    <tr data-idx="${d.idx}">
      <td><strong>${fa(displayIdx+1)}</strong></td>
      <td class="daily-date-cell">${escapeHtml(d.createdDate||"—")}</td>
      <td class="editable-text"><input type="text" data-field="main" value="${escapeHtml(d.main)}" placeholder="وظایف اصلی امروز"></td>
      <td class="editable-text"><input type="text" data-field="meet" value="${escapeHtml(d.meet)}" placeholder="جلسات"></td>
      <td class="editable-text"><input type="text" data-field="company" value="${escapeHtml(d.company||'')}" placeholder="نام شرکت" list="dailyCompanyOptions"></td>
      <td>
        <select data-field="status">
          <option value="" ${d.status===""?"selected":""}>—</option>
          ${STATUS.map(s=>`<option value="${s}" ${d.status===s?"selected":""}>${s}</option>`).join("")}
        </select>
      </td>
      <td style="text-align:center;">
        <button type="button" class="star-btn ${d.important?'is-important':''}" data-star-idx="${d.idx}"
          title="${d.important && d.reminderAt ? 'یادآوری: '+formatReminderAtFa(d.reminderAt) : 'علامت‌گذاری به‌عنوان مهم برای یادآوری'}">${d.important?'⭐':'☆'}</button>
      </td>
      <td><button class="btn-del" data-remove-day="${d.idx}" title="حذف این ردیف">✕</button></td>
    </tr>
  `).join("") || `<tr><td colspan="8" style="color:var(--ink-faint);">موردی با این وضعیت پیدا نشد</td></tr>`;
  const companyNames = companiesData ? Object.keys(companiesData.companies) : [];
  const dl = document.getElementById("dailyCompanyOptions");
  if(dl) dl.innerHTML = companyNames.map(n=>`<option value="${escapeHtml(n)}">`).join("");
  body.querySelectorAll("[data-field]").forEach(el=>{
    el.addEventListener("change", onDayFieldChange);
    if(el.tagName==="INPUT") el.addEventListener("input", onDayFieldChange);
  });
  body.querySelectorAll("[data-remove-day]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این روز از برنامه حذف شود؟")) return;
      const idx = parseInt(btn.getAttribute("data-remove-day"));
      state.days.splice(idx,1);
      renderDaily();
      renderCharts();
      scheduleSave();
    });
  });
  body.querySelectorAll("[data-star-idx]").forEach(btn=>{
    btn.addEventListener("click", (e)=>{
      e.stopPropagation();
      const idx = parseInt(btn.getAttribute("data-star-idx"));
      openReminderPopup(btn, idx);
    });
  });
}

function addDayRow(){
  const maxDay = state.days.reduce((m,d)=> Math.max(m, parseInt(d.day)||0), 0);
  state.days.push({ day: maxDay+1, createdDate: getTodayJalaliStr(), main:"", meet:"", company:"", status:"", important:false, reminderAt:"", reminderFired:false });
  renderDaily();
  scheduleSave();
}

/* ---------------- Jalali <-> Gregorian conversion (jalaali algorithm) ---------------- */
function jDiv(a,b){ return ~~(a/b); }
function jMod(a,b){ return a - ~~(a/b)*b; }
function jalCal(jy){
  const breaks = [-61,9,38,199,426,686,756,818,1111,1181,1210,1635,2060,2097,2192,2262,2324,2394,2456,3178];
  const bl = breaks.length;
  const gy = jy + 621;
  let leapJ = -14, jp = breaks[0], jm, jump=0, n, i;
  for(i=1;i<bl;i++){
    jm = breaks[i];
    jump = jm - jp;
    if(jy < jm) break;
    leapJ = leapJ + jDiv(jump,33)*8 + jDiv(jMod(jump,33),4);
    jp = jm;
  }
  n = jy - jp;
  leapJ = leapJ + jDiv(n,33)*8 + jDiv(jMod(n,33)+3,4);
  if(jMod(jump,33)===4 && jump-n===4) leapJ += 1;
  const leapG = jDiv(gy,4) - jDiv((jDiv(gy,100)+1)*3,4) - 150;
  const march = 20 + leapJ - leapG;
  if(jump - n < 6) n = n - jump + jDiv(jump,33)*33;
  let leap = jMod(jMod(n+1,33)-1,4);
  if(leap===-1) leap=4;
  return { leap, gy, march };
}
function g2d(gy,gm,gd){
  let d = jDiv((gy+jDiv(gm-8,6)+100100)*1461,4) + jDiv(153*jMod(gm+9,12)+2,5) + gd - 34840408;
  d = d - jDiv(jDiv(gy+100100+jDiv(gm-8,6),100)*3,4) + 752;
  return d;
}
function j2d(jy,jm,jd){
  const r = jalCal(jy);
  return g2d(r.gy,3,r.march) + (jm-1)*31 - jDiv(jm,7)*(jm-7) + jd - 1;
}
function d2g(jdn){
  let j = 4*jdn + 139361631;
  j = j + jDiv(jDiv(4*jdn+183187720,146097)*3,4)*4 - 3908;
  const i = jDiv(jMod(j,1461),4)*5 + 308;
  const gd = jDiv(jMod(i,153),5) + 1;
  const gm = jMod(jDiv(i,153),12) + 1;
  const gy = jDiv(j,1461) - 100100 + jDiv(8-gm,6);
  return { gy, gm, gd };
}
function jalaliToGregorian(jy,jm,jd){ return d2g(j2d(jy,jm,jd)); }
function gregorianToJalali(gy,gm,gd){
  // find jy by iterating march-anchor; use standard approach via g2d/j2d comparison
  let jy = gy - 621;
  // adjust jy using jalCal until march date bounds gd correctly
  let r = jalCal(jy+1);
  const gd2jdn = g2d(gy,gm,gd);
  if(gd2jdn >= g2d(r.gy, 3, r.march)) jy += 1;
  r = jalCal(jy);
  const jdn1f = g2d(r.gy,3,r.march);
  let k = gd2jdn - jdn1f;
  let jm, jd;
  if(k >= 0){
    if(k <= 185){ jm = 1 + jDiv(k,31); jd = jMod(k,31) + 1; }
    else{ k -= 186; jm = 7 + jDiv(k,30); jd = jMod(k,30) + 1; }
  } else {
    // shouldn't normally happen given the guard above, but fallback
    jy -= 1;
    const r2 = jalCal(jy);
    k = gd2jdn - g2d(r2.gy,3,r2.march);
    if(k <= 185){ jm = 1 + jDiv(k,31); jd = jMod(k,31) + 1; }
    else{ k -= 186; jm = 7 + jDiv(k,30); jd = jMod(k,30) + 1; }
  }
  return { jy, jm, jd };
}

/* ---------------- Important-item reminder popup (daily plan) — تاریخ شمسی ---------------- */
let reminderPopupEl = null;
function jalaliMonthDayOptions(year, month, selectedDay){
  const n = daysInJalaliMonth(year, month);
  let out = "";
  for(let d=1; d<=n; d++) out += `<option value="${d}" ${d===selectedDay?"selected":""}>${fa(d)}</option>`;
  return out;
}
function ensureReminderPopup(){
  if(reminderPopupEl) return reminderPopupEl;
  reminderPopupEl = document.createElement("div");
  reminderPopupEl.className = "reminder-popup";
  reminderPopupEl.innerHTML = `
    <label>تاریخ و ساعت یادآوری (شمسی)</label>
    <div class="rp-dategrid">
      <select id="rpDay"></select>
      <select id="rpMonth"></select>
      <select id="rpYear"></select>
    </div>
    <div class="rp-timegrid">
      <select id="rpMinute"></select>
      <span style="align-self:center;">:</span>
      <select id="rpHour"></select>
    </div>
    <div class="rp-row">
      <button type="button" class="rp-save" id="reminderPopupSave">ذخیره</button>
      <button type="button" class="rp-clear" id="reminderPopupClear">پاک کردن</button>
      <button type="button" class="rp-close" id="reminderPopupClose">بستن</button>
    </div>
  `;
  document.body.appendChild(reminderPopupEl);

  const yearSel = reminderPopupEl.querySelector("#rpYear");
  const monthSel = reminderPopupEl.querySelector("#rpMonth");
  const daySel = reminderPopupEl.querySelector("#rpDay");
  const hourSel = reminderPopupEl.querySelector("#rpHour");
  const minuteSel = reminderPopupEl.querySelector("#rpMinute");

  monthSel.innerHTML = JALALI_MONTH_NAMES.map((m,i)=>`<option value="${i+1}">${m}</option>`).join("");
  for(let h=0; h<24; h++) hourSel.innerHTML += `<option value="${h}">${fa(String(h).padStart(2,"0"))}</option>`;
  for(let m=0; m<60; m++) minuteSel.innerHTML += `<option value="${m}">${fa(String(m).padStart(2,"0"))}</option>`;

  function refreshDayOptions(){
    const y = parseInt(yearSel.value), m = parseInt(monthSel.value);
    const keepDay = parseInt(daySel.value) || 1;
    daySel.innerHTML = jalaliMonthDayOptions(y, m, Math.min(keepDay, daysInJalaliMonth(y,m)));
  }
  yearSel.addEventListener("change", refreshDayOptions);
  monthSel.addEventListener("change", refreshDayOptions);

  document.getElementById("reminderPopupSave").addEventListener("click", ()=>{
    const idx = parseInt(reminderPopupEl.getAttribute("data-target-idx"));
    const jy = parseInt(yearSel.value), jm = parseInt(monthSel.value), jd = parseInt(daySel.value);
    const hh = parseInt(hourSel.value), mi = parseInt(minuteSel.value);
    if(!jy || !jm || !jd){ alert("لطفاً تاریخ را انتخاب کنید."); return; }
    const g = jalaliToGregorian(jy, jm, jd);
    const pad = n=>String(n).padStart(2,"0");
    const val = `${g.gy}-${pad(g.gm)}-${pad(g.gd)}T${pad(hh)}:${pad(mi)}`;
    state.days[idx].important = true;
    state.days[idx].reminderAt = val;
    state.days[idx].reminderFired = false;
    closeReminderPopup();
    renderDaily();
    renderRemindersBanner();
    scheduleSave();
  });
  document.getElementById("reminderPopupClear").addEventListener("click", ()=>{
    const idx = parseInt(reminderPopupEl.getAttribute("data-target-idx"));
    state.days[idx].important = false;
    state.days[idx].reminderAt = "";
    state.days[idx].reminderFired = false;
    closeReminderPopup();
    renderDaily();
    renderRemindersBanner();
    scheduleSave();
  });
  document.getElementById("reminderPopupClose").addEventListener("click", closeReminderPopup);

  document.addEventListener("click", (e)=>{
    if(!reminderPopupEl.classList.contains("open")) return;
    if(reminderPopupEl.contains(e.target)) return;
    if(e.target.closest("[data-star-idx]")) return;
    closeReminderPopup();
  });
  return reminderPopupEl;
}
function closeReminderPopup(){
  if(reminderPopupEl) reminderPopupEl.classList.remove("open");
}
function openReminderPopup(anchorEl, idx){
  const popup = ensureReminderPopup();
  const d = state.days[idx];
  const today = getTodayJalaliParts();
  let jy = parseInt(today.year)||1405, jm = today.monthNum||1, jd = today.day||1, hh = new Date().getHours(), mi = 0;
  if(d.reminderAt){
    const dt = new Date(d.reminderAt);
    if(!isNaN(dt.getTime())){
      const jp = gregorianToJalali(dt.getFullYear(), dt.getMonth()+1, dt.getDate());
      jy = jp.jy; jm = jp.jm; jd = jp.jd; hh = dt.getHours(); mi = dt.getMinutes();
    }
  }
  const yearSel = document.getElementById("rpYear");
  yearSel.innerHTML = "";
  for(let y=jy-1; y<=jy+2; y++) yearSel.innerHTML += `<option value="${y}" ${y===jy?"selected":""}>${fa(y)}</option>`;
  document.getElementById("rpMonth").value = jm;
  document.getElementById("rpDay").innerHTML = jalaliMonthDayOptions(jy, jm, jd);
  document.getElementById("rpHour").value = hh;
  document.getElementById("rpMinute").value = mi;

  popup.setAttribute("data-target-idx", idx);
  const rect = anchorEl.getBoundingClientRect();
  const popupHeight = 290, popupWidth = 252;
  let top = rect.bottom + 6;
  if(top + popupHeight > window.innerHeight) top = Math.max(8, rect.top - popupHeight - 6);
  let left = rect.left - popupWidth + rect.width;
  if(left < 8) left = 8;
  if(left + popupWidth > window.innerWidth - 8) left = window.innerWidth - popupWidth - 8;
  popup.style.top = top + "px";
  popup.style.left = left + "px";
  popup.classList.add("open");
}
function formatReminderAtFa(val){
  try{
    const d = new Date(val);
    if(isNaN(d.getTime())) return val;
    const jp = gregorianToJalali(d.getFullYear(), d.getMonth()+1, d.getDate());
    return fa(jp.jy)+"/"+fa(String(jp.jm).padStart(2,"0"))+"/"+fa(String(jp.jd).padStart(2,"0")) + " — " + fa(String(d.getHours()).padStart(2,"0")+":"+String(d.getMinutes()).padStart(2,"0"));
  }catch(e){ return val; }
}

/* ---------------- On-screen reminder alert modal ---------------- */
let reminderModalEl = null;
let reminderModalQueue = [];
function ensureReminderModal(){
  if(reminderModalEl) return reminderModalEl;
  reminderModalEl = document.createElement("div");
  reminderModalEl.className = "reminder-modal-overlay";
  reminderModalEl.innerHTML = `
    <div class="reminder-modal">
      <div class="rm-icon" id="reminderModalIcon">⏰</div>
      <div class="rm-title" id="reminderModalTitle"></div>
      <div class="rm-msg" id="reminderModalMsg"></div>
      <button type="button" class="rm-ok" id="reminderModalOk">متوجه شدم</button>
    </div>
  `;
  document.body.appendChild(reminderModalEl);
  document.getElementById("reminderModalOk").addEventListener("click", closeReminderModal);
  reminderModalEl.addEventListener("click", (e)=>{ if(e.target===reminderModalEl) closeReminderModal(); });
  return reminderModalEl;
}
function closeReminderModal(){
  if(reminderModalEl) reminderModalEl.classList.remove("open");
  setTimeout(showNextReminderModal, 350);
}
function showNextReminderModal(){
  if(reminderModalEl && reminderModalEl.classList.contains("open")) return;
  if(reminderModalQueue.length===0) return;
  const item = reminderModalQueue.shift();
  const modal = ensureReminderModal();
  document.getElementById("reminderModalIcon").textContent = item.icon || "⏰";
  document.getElementById("reminderModalTitle").textContent = item.title;
  document.getElementById("reminderModalMsg").textContent = item.msg;
  modal.classList.add("open");
  playReminderSound();
}
function enqueueReminderModal(title, msg, icon){
  reminderModalQueue.push({ title, msg, icon });
  showNextReminderModal();
}

function onDayFieldChange(e){
  const tr = e.target.closest("tr");
  const idx = parseInt(tr.getAttribute("data-idx"));
  const field = e.target.getAttribute("data-field");
  state.days[idx][field] = e.target.value;
  if(field==="status") renderCharts();
  scheduleSave();
}


/* =========================================================================
   یک‌پارچه‌سازی: به‌جای ۴ فایل اکسل، همه‌چیز در یک فایل واحد ذخیره می‌شود:
   «{{FILEXLSX}}» — با ۵ برگ: Servers، DailyBackupLog، Companies،
   MVPN، RemoteChecklist. هر تغییری که در همین صفحه بدهید (افزودن/ویرایش/تیک
   زدن) بلافاصله روی همین یک فایل نوشته می‌شود.
   ========================================================================= */
const DB_FILE_NAME = "{{FILEXLSX}}";
const DB_CACHE_KEY = "{{DBCACHE}}";

let dbWorkbook = null;      // SheetJS workbook currently loaded/edited in memory
let dbFileName = null;      // actual file name found in the folder (defaults to DB_FILE_NAME)
let dbSyncedAt = null;

let backupData = null;      // { vm:[{location,server,size,sizeUsed,schedule,lastRestore,lastFullBackup,time,storage}] }
let dailyLog = { "روزانه یک‌بار": [], "روزانه دوبار": [] }; // group -> [{year,month,day,done}]
let companiesData = null;   // { companies: { name: [{dateStr,time,type}] } }
let mvpnData = null;        // { lines: [{phone,owner,stage,ext,extFull,plan}] }
let remoteBackupData = null;// { roster: [{company,ip}] }

let vmFilters = {};
let mvpnFilters = {};
let editMode = { servers:false, mvpn:false, remote:false };
let editModeCompanies = {}; // per-company edit toggle, keyed by company name

function sheetToMatrix(wb, name){
  const ws = wb.Sheets[name];
  if(!ws) return null;
  return XLSX.utils.sheet_to_json(ws, {header:1, raw:true, defval:null});
}

function updateDbStatus(text){
  ["backupSyncStatus","dateSyncStatus","mvpnSyncStatus","remoteSyncStatus"].forEach(id=>{
    const el = document.getElementById(id);
    if(el) el.textContent = text;
  });
}

/* ---------------- finding / loading the single database file ---------------- */

async function findDbFileHandle(){
  if(!dirHandle) return null;
  try{
    return await dirHandle.getFileHandle(DB_FILE_NAME, {create:false});
  }catch(e){ /* fall through to a loose search below */ }
  for await (const [name, handle] of dirHandle.entries()){
    if(handle.kind === "file" && /\.xlsx$/i.test(name) && /دیتابیس|database/i.test(name)) return handle;
  }
  return null;
}

/* خواندنِ یک‌بارهٔ فایل، بی‌آنکه به پوشه‌ای وصل باشیم.
   پیش از این بدونِ اتصال به پوشه اصلاً راهی برای خواندنِ اکسل نبود و
   کاربر پشتِ یک پیامِ «اول وصل شوید» می‌ماند. حالا فایل را می‌گیرد،
   می‌خواند، داخل کارتابل می‌نشاند و رهایش می‌کند — داده روی سرور است،
   نه در آن فایل. */
async function importDatabaseFromFile(){
  if(xlsxOff()) return;
  const file = await pickFile(".xlsx,.xls");
  if(!file) return;
  updateDbStatus("در حال خواندن فایل...");
  const wb = await readWorkbook(file);
  if(!wb){ updateDbStatus(""); return; }
  try{
    dbWorkbook = wb;
    dbFileName = file.name;
    /* برگه‌ای که در فایل نیست یعنی «دربارهٔ این بخش حرفی ندارم»، نه
       «این بخش را خالی کن». پیش از این، خواندنِ هر فایلی که مثلاً برگهٔ
       MVPN نداشت، خطوط MVPN را بی‌صدا صفر می‌کرد — و چون بقیهٔ بخش‌ها
       سرِ جایشان بودند، افتِ کل آن‌قدر نبود که نگهبانِ سرور را بیدار
       کند. همین یک خط، داده را می‌برد.
       این چیزی است که کاربر دو بار دیدش: «بازم سرویس MVPN پرید». */
    const has = n=> (wb.SheetNames||[]).indexOf(n) >= 0;
    const skipped = [];
    if(has("Servers")) backupData = { vm: parseServersSheet(wb) }; else skipped.push("سرورها");
    if(has("DailyBackupLog")) dailyLog = parseDailyLogSheet(wb); else skipped.push("بکاپ روزانه");
    if(has("Companies")) companiesData = { companies: parseCompaniesSheet(wb) }; else skipped.push("شرکت‌ها");
    if(has("MVPN")) mvpnData = { lines: parseMvpnSheetFlat(wb) }; else skipped.push("MVPN");
    if(has("RemoteChecklist")){
      const remote = parseRemoteChecklistSheet(wb);
      remoteBackupData = { roster: remote.roster };
      if(remote.dates) state.remoteCheckDates = remote.dates;
      if(remote.checks) state.remoteChecks = remote.checks;
    } else skipped.push("چک‌لیست ریموت");
    /* بخشِ رمزدار عمداً از فایل خوانده نمی‌شود: کلیدش دستِ خودِ کاربر
       است و اگر این‌جا جایگزین شود، آن‌چه باز کرده بود قفل می‌ماند. */
    dbSyncedAt = new Date().toISOString();
    persistDbCache();
    scheduleSave();
    renderServers(); renderCompanies(); renderMvpn(); renderRemoteChecklist(); renderCharts();
    /* صادقانه بگوید چه چیزی را نخوانده، وگرنه آدم فکر می‌کند همه‌چیز
       از فایل آمده و بعداً سرِ یک بخشِ قدیمی گیج می‌شود. */
    updateDbStatus("✓ از «" + file.name + "» خوانده شد. فایل دیگر لازم نیست." +
      (skipped.length ? " — این بخش‌ها در فایل نبودند و دست‌نخورده ماندند: " + skipped.join("، ") : ""));
  }catch(e){
    console.error(e);
    updateDbStatus("⚠️ فایل خوانده شد ولی ساختارش با کارتابل نمی‌خواند.");
  }
}

async function loadDatabase(){
  /* بی‌پوشه هم باید بشود خواند — همان خواندنِ یک‌باره. */
  if(!dirHandle) return importDatabaseFromFile();
  updateDbStatus("در حال بارگذاری کتابخانه...");
  const ok = await ensureXlsxLib();
  if(!ok){
    updateDbStatus("⚠️ کتابخانه‌ی خواندن اکسل بارگذاری نشد (اینترنت را بررسی کنید).");
    return;
  }
  try{
    updateDbStatus("در حال جستجوی فایل دیتابیس در پوشه...");
    let fileHandle = await findDbFileHandle();
    if(!fileHandle){
      // no database file yet in this folder — create a brand new empty one
      dbWorkbook = buildEmptyDatabaseWorkbook();
      dbFileName = DB_FILE_NAME;
      backupData = { vm: [] };
      dailyLog = { "روزانه یک‌بار": [], "روزانه دوبار": [] };
      companiesData = { companies: {} };
      mvpnData = { lines: [] };
      remoteBackupData = { roster: [] };
      state.remoteChecks = {};
      state.remoteCheckDates = [];
      dbSyncedAt = new Date().toISOString();
      persistDbCache();
      await writeDbNow();
      renderServers(); renderCompanies(); renderMvpn(); renderRemoteChecklist(); renderCharts();
      updateDbStatus("✓ فایل دیتابیس جدید «"+DB_FILE_NAME+"» ساخته شد.");
      return;
    }
    const file = await fileHandle.getFile();
    const buf = await file.arrayBuffer();
    dbWorkbook = XLSX.read(buf, {type:"array", raw:true, cellDates:false});
    dbFileName = file.name;

    backupData = { vm: parseServersSheet(dbWorkbook) };
    dailyLog = parseDailyLogSheet(dbWorkbook);
    companiesData = { companies: parseCompaniesSheet(dbWorkbook) };
    mvpnData = { lines: parseMvpnSheetFlat(dbWorkbook) };
    const remote = parseRemoteChecklistSheet(dbWorkbook);
    remoteBackupData = { roster: remote.roster };
    if(remote.dates){
      state.remoteCheckDates = remote.dates;
    }
    if(remote.checks){
      state.remoteChecks = remote.checks;
    }
    const vaultFromFile = parsePersonalVaultSheet(dbWorkbook);
    if(vaultFromFile && vaultFromFile.cipher){
      // اگر بخش شخصی همین حالا در این نشست باز/رمزگشایی شده، آن را قفل می‌کنیم
      // تا با نسخه‌ی ذخیره‌شده روی فایل جایگزین شود و دچار ناهماهنگی نشویم.
      if(personalUnlocked) lockPersonal();
      state.personalVault = vaultFromFile;
    }

    dbSyncedAt = new Date().toISOString();
    persistDbCache();
    scheduleSave();
    renderServers(); renderCompanies(); renderMvpn(); renderRemoteChecklist(); renderCharts();
    updateDbStatus("✓ همگام با «"+dbFileName+"» — "+new Date().toLocaleString("fa-IR"));
  }catch(e){
    console.error(e);
    updateDbStatus("⚠️ خطا در خواندن فایل دیتابیس.");
  }
}

function buildEmptyDatabaseWorkbook(){
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["Location","Server","Size","SizeUsed","ScheduleBackup","LastRestore","LastFullBackup","Time","Storage"]]), "Servers");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["Group","Year","Month","Day","Done"]]), "DailyBackupLog");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["Company","Date","Time","Type"]]), "Companies");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["Phone","Owner","Stage","Ext","ExtFull","Plan"]]), "MVPN");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["Server"]]), "RemoteChecklist");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["Month","Category","Task","Owner","Deadline","Status","Priority","Note"]]), "Tasks");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["Month","Day","CreatedDate","Main","Meet","Company","Status"]]), "DailyPlan");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["EncryptedBlob"]]), "PersonalVault");
  return wb;
}

function persistDbCacheLocal(){
  try{
    localStorage.setItem(DB_CACHE_KEY, JSON.stringify({
      vm: backupData && backupData.vm || [],
      dailyLog, companies: companiesData && companiesData.companies || {},
      lines: mvpnData && mvpnData.lines || [],
      roster: remoteBackupData && remoteBackupData.roster || [],
      fileName: dbFileName, syncedAt: dbSyncedAt
    }));
  }catch(e){ /* storage full or unavailable — non-fatal */ }
}

/* هر تغییرِ دیتابیس هم روی همین مرورگر می‌نشیند هم بالا می‌رود. نسخهٔ
   محلی اول نوشته می‌شود تا اگر اینترنت قطع بود چیزی گم نشود. */
function persistDbCache(){
  persistDbCacheLocal();
  try{ Cloud.push(); }catch(e){ /* هنوز بالا نیامده */ }
}

function loadCachedDatabase(){
  const seed = bkSeed();
  if(seed && seed.db){
    applyDbSnapshot(seed.db);
    bkSeedDone();
    try{ persistDbCacheLocal(); }catch(e){}
    return;
  }
  try{
    const raw = localStorage.getItem(DB_CACHE_KEY);
    if(!raw) return;
    const c = JSON.parse(raw);
    backupData = { vm: c.vm || [] };
    dailyLog = c.dailyLog || { "روزانه یک‌بار": [], "روزانه دوبار": [] };
    companiesData = { companies: c.companies || {} };
    mvpnData = { lines: c.lines || [] };
    remoteBackupData = { roster: c.roster || [] };
    dbFileName = c.fileName || null;
    dbSyncedAt = c.syncedAt || null;
  }catch(e){ /* ignore corrupt cache */ }
}

/* ---------------- writing the whole workbook back to disk ---------------- */

let dbWriteTimer = null;
function scheduleDbWrite(){
  persistDbCache();
  const hint = document.getElementById("saveHint");
  if(hint) hint.textContent = "در حال ذخیره روی اکسل...";
  clearTimeout(dbWriteTimer);
  dbWriteTimer = setTimeout(writeDbNow, 500);
}

async function writeDbNow(){
  if(!dirHandle || !dbWorkbook) return;
  const ok = await ensureXlsxLib();
  if(!ok) return;
  try{
    const buf = XLSX.write(dbWorkbook, {type:"array", bookType:"xlsx"});
    const targetName = dbFileName || DB_FILE_NAME;
    const fh = await dirHandle.getFileHandle(targetName, {create:true});
    const writable = await fh.createWritable();
    await writable.write(buf);
    await writable.close();
    updateDbStatus("✓ ذخیره شد در «"+targetName+"» — "+new Date().toLocaleString("fa-IR"));
    const hint = document.getElementById("saveHint");
    if(hint) hint.textContent = "✓ ذخیره شد";
  }catch(e){
    console.error(e);
    updateDbStatus("⚠️ ذخیره در اکسل ناموفق بود.");
  }
}

function ensureDbWorkbook(){
  if(!dbWorkbook) dbWorkbook = buildEmptyDatabaseWorkbook();
  return dbWorkbook;
}

/* ---------------- Tasks & DailyPlan sheets (mirror of state.tasks / state.days) ---------------- */

function tasksToAOA(){
  const header = ["Month","Category","Task","Owner","Deadline","Status","Priority","Note"];
  const rows = [];
  const snapshot = allMonthsSnapshot();
  Object.keys(snapshot).forEach(key=>{
    const label = monthLabelOf(key);
    (snapshot[key].tasks||[]).forEach(t=> rows.push([label, t.category||"", t.task||"", t.owner||"", t.deadline||"", t.status||"", t.priority||"", t.note||""]));
  });
  return [header, ...rows];
}
function saveTasksSheet(){
  if(!dirHandle) return;
  ensureDbWorkbook().Sheets["Tasks"] = XLSX.utils.aoa_to_sheet(tasksToAOA());
  scheduleDbWrite();
}

function daysToAOA(){
  const header = ["Month","Day","CreatedDate","Main","Meet","Company","Status"];
  const rows = [];
  const snapshot = allMonthsSnapshot();
  Object.keys(snapshot).forEach(key=>{
    const label = monthLabelOf(key);
    (snapshot[key].days||[]).forEach(d=> rows.push([label, d.day||"", d.createdDate||"", d.main||"", d.meet||"", d.company||"", d.status||""]));
  });
  return [header, ...rows];
}
function saveDaysSheet(){
  if(!dirHandle) return;
  ensureDbWorkbook().Sheets["DailyPlan"] = XLSX.utils.aoa_to_sheet(daysToAOA());
  scheduleDbWrite();
}

/* ---------------- Servers sheet ---------------- */

function parseServersSheet(wb){
  const rows = sheetToMatrix(wb, "Servers");
  if(!rows) return [];
  const out = [];
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    if(!row[1]) continue; // Server name
    out.push({
      location: row[0]||"", server: row[1], size: row[2]||0, sizeUsed: row[3]||0,
      schedule: row[4]||"", lastRestore: row[5]||"", lastFullBackup: row[6]||"",
      time: row[7]||"", storage: row[8]||""
    });
  }
  return out;
}

function serversToAOA(){
  const header = ["Location","Server","Size","SizeUsed","ScheduleBackup","LastRestore","LastFullBackup","Time","Storage"];
  const rows = (backupData && backupData.vm || []).map(m=>[
    m.location||"", m.server||"", m.size||0, m.sizeUsed||0, m.schedule||"", m.lastRestore||"", m.lastFullBackup||"", m.time||"", m.storage||""
  ]);
  return [header, ...rows];
}

function saveServersSheet(){
  ensureDbWorkbook().Sheets["Servers"] = XLSX.utils.aoa_to_sheet(serversToAOA());
  scheduleDbWrite();
}

function commitServerCell(idx, field, value){
  if(!backupData || !backupData.vm[idx]) return;
  backupData.vm[idx][field] = value;
  saveServersSheet();
}

function addServerRow(vals){
  if(!backupData) backupData = { vm: [] };
  backupData.vm.push({
    location: vals.location||"", server: vals.server, size: parseFloat(vals.size)||0, sizeUsed: parseFloat(vals.sizeUsed)||0,
    schedule: vals.schedule||"", lastRestore: "", lastFullBackup: "", time: vals.time||"", storage: vals.storage||""
  });
  // با افزودن ردیف جدید، حالت «حذف/تغییر» به‌طور خودکار فعال می‌شود تا ردیف
  // بلافاصله قابل مشاهده و ویرایش باشد و نیازی به کلیک جداگانه یا جابه‌جایی ماه نباشد.
  editMode.servers = true;
  saveServersSheet();
  renderServers();
}

/* ---------------- DailyBackupLog sheet (shared روزانه یک‌بار / روزانه دوبار) ---------------- */

function parseDailyLogSheet(wb){
  const rows = sheetToMatrix(wb, "DailyBackupLog");
  const out = { "روزانه یک‌بار": [], "روزانه دوبار": [] };
  if(!rows) return out;
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    const group = row[0];
    if(!group || !out[group]) continue;
    const year = parseInt(row[1],10), month = parseInt(row[2],10), day = parseInt(row[3],10);
    if(isNaN(year)||isNaN(month)||isNaN(day)) continue;
    const done = String(row[4]).trim().toUpperCase()==="TRUE";
    out[group].push({year, month, day, done});
  }
  Object.keys(out).forEach(g=> out[g].sort((a,b)=> (a.year*10000+a.month*100+a.day) - (b.year*10000+b.month*100+b.day)));
  return out;
}

function dailyLogToAOA(){
  const header = ["Group","Year","Month","Day","Done"];
  const rows = [];
  Object.keys(dailyLog).forEach(group=>{
    dailyLog[group].forEach(e=> rows.push([group, e.year, e.month, e.day, e.done ? "TRUE":"FALSE"]));
  });
  return [header, ...rows];
}

function saveDailyLogSheet(){
  ensureDbWorkbook().Sheets["DailyBackupLog"] = XLSX.utils.aoa_to_sheet(dailyLogToAOA());
  scheduleDbWrite();
}

function toggleDailyLogEntry(group, idx){
  if(!dailyLog[group] || !dailyLog[group][idx]) return;
  dailyLog[group][idx].done = !dailyLog[group][idx].done;
  saveDailyLogSheet();
  renderDailyCalendar();
}

function removeDailyLogEntry(group, idx){
  if(!dailyLog[group]) return;
  dailyLog[group].splice(idx,1);
  saveDailyLogSheet();
  renderDailyCalendar();
}

function getDailyEntry(group, year, month, day){
  if(!dailyLog[group]) return null;
  return dailyLog[group].find(e=> e.year===year && e.month===month && e.day===day) || null;
}

function toggleCalendarDay(group, year, month, day){
  if(!dailyLog[group]) dailyLog[group] = [];
  let e = getDailyEntry(group, year, month, day);
  if(!e){
    e = { year, month, day, done:true };
    dailyLog[group].push(e);
  } else {
    e.done = !e.done;
  }
  saveDailyLogSheet();
  renderServers();
}

const JALALI_LEAP_YEARS = new Set([1403,1408,1412,1416,1420,1424,1428,1432,1436]);
function daysInJalaliMonth(year, month){
  if(month>=1 && month<=6) return 31;
  if(month>=7 && month<=11) return 30;
  return JALALI_LEAP_YEARS.has(year) ? 30 : 29; // month 12 - اسفند
}
const JALALI_MONTH_NAMES = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور","مهر","آبان","آذر","دی","بهمن","اسفند"];

function currentJalaliYM(){
  const t = getTodayJalaliParts();
  return { year: parseInt(t.year)||1405, month: t.monthNum||1 };
}

let dailyCalSel = (function(){
  const ym = currentJalaliYM();
  return {
    "روزانه یک‌بار": { year: ym.year, month: ym.month },
    "روزانه دوبار": { year: ym.year, month: ym.month }
  };
})();

function shiftDailyCalMonth(group, delta){
  const sel = dailyCalSel[group] || (dailyCalSel[group] = currentJalaliYM());
  let m = sel.month + delta;
  let y = sel.year;
  if(m<1){ m=12; y--; }
  if(m>12){ m=1; y++; }
  sel.month = m; sel.year = y;
  renderDailyCalendar();
}

/* ---------------- Companies sheet ---------------- */

function parseCompaniesSheet(wb){
  const rows = sheetToMatrix(wb, "Companies");
  const out = {};
  if(!rows) return out;
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    const company = row[0];
    if(!company) continue;
    if(!out[company]) out[company] = [];
    out[company].push({ dateStr: String(row[1]||""), time: String(row[2]||""), type: String(row[3]||"") });
  }
  Object.keys(out).forEach(name=> out[name].sort((a,b)=> a.dateStr.localeCompare(b.dateStr)));
  return out;
}

function companiesToAOA(){
  const header = ["Company","Date","Time","Type"];
  const rows = [];
  Object.keys(companiesData.companies).forEach(name=>{
    companiesData.companies[name].forEach(e=> rows.push([name, e.dateStr, e.time, e.type]));
  });
  return [header, ...rows];
}

function saveCompaniesSheet(){
  ensureDbWorkbook().Sheets["Companies"] = XLSX.utils.aoa_to_sheet(companiesToAOA());
  scheduleDbWrite();
}

function addCompanyVisit(name, dateStr, time, type){
  if(!companiesData) companiesData = { companies:{} };
  if(!companiesData.companies[name]) companiesData.companies[name] = [];
  companiesData.companies[name].push({ dateStr, time, type });
  companiesData.companies[name].sort((a,b)=> a.dateStr.localeCompare(b.dateStr));
  // فعال‌سازی خودکار حالت «حذف/تغییر» برای این شرکت تا ردیف تازه‌اضافه‌شده
  // بلافاصله قابل‌مشاهده، ویرایش و بررسی باشد و نیازی به کلیک جداگانه نباشد.
  editModeCompanies[name] = true;
  saveCompaniesSheet();
  renderCompanies();
  flashCompanySaved(name);
}

let companySavedFlashTimer = null;
function flashCompanySaved(name){
  const wrap = document.getElementById("companiesWrap");
  if(!wrap) return;
  const panels = wrap.querySelectorAll(".panel");
  panels.forEach(p=>{
    const h3 = p.querySelector("h3");
    if(h3 && h3.textContent.trim() === ("🏢 "+name)){
      p.classList.add("company-just-added");
      const bar = p.querySelector(".visit-add-bar");
      if(bar && !bar.querySelector(".visit-add-confirm")){
        const span = document.createElement("span");
        span.className = "visit-add-confirm";
        span.textContent = "✓ ثبت و ذخیره شد";
        bar.appendChild(span);
        clearTimeout(companySavedFlashTimer);
        companySavedFlashTimer = setTimeout(()=>{ span.remove(); }, 2500);
      }
    }
  });
}

function addNewCompany(name){
  if(!companiesData) companiesData = { companies:{} };
  if(!name || companiesData.companies[name]) return;
  companiesData.companies[name] = [];
  saveCompaniesSheet();
  renderCompanies();
}

function removeCompanyVisit(name, idx){
  if(!companiesData || !companiesData.companies[name]) return;
  companiesData.companies[name].splice(idx,1);
  saveCompaniesSheet();
  renderCompanies();
}

/* ---------------- MVPN sheet ---------------- */

function parseMvpnSheetFlat(wb){
  const rows = sheetToMatrix(wb, "MVPN");
  const out = [];
  if(!rows) return out;
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    if(!row[0]) continue;
    out.push({ phone:String(row[0]), owner:row[1]||"", stage:row[2]||"", ext: row[3]!=null?String(row[3]):"", extFull: row[4]!=null?String(row[4]):"", plan:row[5]||"" });
  }
  return out;
}

function mvpnToAOA(){
  const header = ["Phone","Owner","Stage","Ext","ExtFull","Plan"];
  const rows = (mvpnData && mvpnData.lines || []).map(l=>[l.phone||"", l.owner||"", l.stage||"", l.ext||"", l.extFull||"", l.plan||""]);
  return [header, ...rows];
}

function saveMvpnSheet(){
  ensureDbWorkbook().Sheets["MVPN"] = XLSX.utils.aoa_to_sheet(mvpnToAOA());
  scheduleDbWrite();
}

function commitMvpnCell(idx, field, value){
  if(!mvpnData || !mvpnData.lines[idx]) return;
  mvpnData.lines[idx][field] = value;
  saveMvpnSheet();
}

function addMvpnLine(vals){
  if(!mvpnData) mvpnData = { lines: [] };
  mvpnData.lines.push({ phone: vals.phone||"", owner: vals.owner||"", stage: vals.stage||"فعال شده", ext: vals.ext||"", extFull: vals.ext ? ("50"+vals.ext) : "", plan: vals.plan||"" });
  editMode.mvpn = true;
  saveMvpnSheet();
  renderMvpn();
}

/* ---------------- RemoteChecklist sheet ---------------- */

function parseRemoteChecklistSheet(wb){
  const rows = sheetToMatrix(wb, "RemoteChecklist");
  if(!rows) return { roster: [], dates: null, checks: null };
  const header = rows[0]||[];
  const dateCols = [];
  for(let c=1;c<header.length;c++){
    if(header[c]!=null && String(header[c]).trim()!=="") dateCols.push(c);
  }
  const roster = [];
  const checks = {};
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    const server = row[0];
    if(!server) continue;
    const serverStr = String(server);
    roster.push({ server: serverStr });
    const rowChecks = {};
    dateCols.forEach((c,i)=>{ if(String(row[c]||"").trim()==="*") rowChecks[i+1] = true; });
    checks[serverStr] = rowChecks;
  }
  const dates = dateCols.map(c=> String(header[c]||""));
  return { roster, dates: dates.length?dates:null, checks: Object.keys(checks).length?checks:null };
}

function remoteChecklistToAOA(){
  const header = ["Server", ...state.remoteCheckDates.map((d,i)=> (d&&d.trim()) ? d : ("Day "+(i+1)))];
  const rows = (remoteBackupData && remoteBackupData.roster || []).map(m=>{
    const checks = state.remoteChecks[m.server] || {};
    return [m.server, ...state.remoteCheckDates.map((_,i)=> checks[i+1] ? "*" : "")];
  });
  return [header, ...rows];
}

function saveRemoteChecklistSheet(){
  ensureDbWorkbook().Sheets["RemoteChecklist"] = XLSX.utils.aoa_to_sheet(remoteChecklistToAOA());
  scheduleDbWrite();
}

function addRemoteServer(server){
  if(!remoteBackupData) remoteBackupData = { roster: [] };
  if(remoteBackupData.roster.some(m=>m.server===server)){ alert("این سرور از قبل در فهرست هست."); return; }
  remoteBackupData.roster.push({ server });
  editMode.remote = true;
  saveRemoteChecklistSheet();
  renderRemoteChecklist();
}

function addRemoteDay(label){
  state.remoteCheckDates.push(label || "");
  editMode.remote = true;
  saveRemoteChecklistSheet();
  scheduleSave();
  renderRemoteChecklist();
}

function removeRemoteDay(idx){
  state.remoteCheckDates.splice(idx,1);
  // شماره‌ی روزهای بعد از ستون حذف‌شده یک واحد عقب کشیده می‌شود تا با موقعیت ستون‌ها هماهنگ بماند
  Object.keys(state.remoteChecks).forEach(server=>{
    const checks = state.remoteChecks[server] || {};
    const shifted = {};
    Object.keys(checks).forEach(dayStr=>{
      const day = parseInt(dayStr);
      if(day === idx+1) return; // حذف تیک همان روز
      shifted[day > idx+1 ? day-1 : day] = checks[dayStr];
    });
    state.remoteChecks[server] = shifted;
  });
  saveRemoteChecklistSheet();
  scheduleSave();
  renderRemoteChecklist();
}

/* ---------------- Rendering: Servers & daily calendar ---------------- */

const SCHEDULE_OPTIONS = ["روزانه یک بار","روزانه دوبار","ماهانه یک بار","چهارماه یک بار","شش ماه یک بار"];

function applyVmFilters(vm){
  return vm.filter(m=>{
    for(const key of Object.keys(vmFilters)){
      const filters = vmFilters[key];
      if(!filters || filters.length===0) continue;
      const val = String(m[key]==null?"":m[key]).toLowerCase();
      if(key==="schedule" || key==="storage"){
        // For select filters, check if value is in the selected list
        if(!filters.some(f=> f.toLowerCase()===val)) return false;
      } else {
        // For text filters, check if value includes the search term
        if(!filters.some(f=> val.includes(f.toLowerCase()))) return false;
      }
    }
    return true;
  });
}

function fillFilterOptions(selectEl, values, keepValue){
  const unique = [...new Set(values.filter(v=>v!=null && v!==""))];
  selectEl.innerHTML = `<option value="">همه</option>` + unique.map(v=>`<option value="${escapeHtml(v)}" ${v===keepValue?"selected":""}>${escapeHtml(v)}</option>`).join("");
}

/* ---------------- Multi-select filter dropdown widget ---------------- */

let msfPanelEl = null;
function ensureMsfPanel(){
  if(msfPanelEl) return msfPanelEl;
  msfPanelEl = document.createElement("div");
  msfPanelEl.className = "msf-panel";
  document.body.appendChild(msfPanelEl);
  document.addEventListener("click", (e)=>{
    if(msfPanelEl.classList.contains("open") && !msfPanelEl.contains(e.target) && !e.target.closest(".msf-btn")){
      closeMsfPanel();
    }
  });
  return msfPanelEl;
}
function closeMsfPanel(){
  if(!msfPanelEl) return;
  msfPanelEl.classList.remove("open");
  document.querySelectorAll(".msf-btn.open").forEach(b=>b.classList.remove("open"));
}

function renderMultiFilter(containerEl, values, filtersObj, key, onChange){
  const unique = [...new Set(values.filter(v=>v!=null && v!==""))];
  const selected = filtersObj[key] || [];
  const label = selected.length===0 ? "همه" : (selected.length===1 ? selected[0] : `${fa(selected.length)} مورد`);
  containerEl.innerHTML = `
    <button type="button" class="msf-btn">
      <span class="lbl">${escapeHtml(label)}</span>
      ${selected.length>0 ? `<span class="msf-count">${fa(selected.length)}</span>` : ""}
      <span class="arrow">▾</span>
    </button>`;
  const btn = containerEl.querySelector(".msf-btn");
  btn.addEventListener("click", (e)=>{
    e.stopPropagation();
    const panel = ensureMsfPanel();
    const alreadyOpenForThis = panel.classList.contains("open") && panel.getAttribute("data-owner")===containerEl.id;
    closeMsfPanel();
    if(alreadyOpenForThis) return;
    panel.setAttribute("data-owner", containerEl.id);
    panel.innerHTML = unique.map(v=>`
      <label class="msf-opt">
        <input type="checkbox" value="${escapeHtml(v)}" ${selected.includes(v)?"checked":""}>
        <span>${escapeHtml(v)}</span>
      </label>`).join("") + (selected.length>0 ? `<div class="msf-clear">پاک‌کردن انتخاب</div>` : "");
    panel.querySelectorAll('input[type="checkbox"]').forEach(cb=>{
      cb.addEventListener("change", ()=>{
        const vals = Array.from(panel.querySelectorAll('input[type="checkbox"]:checked')).map(c=>c.value);
        filtersObj[key] = vals;
        onChange();
      });
    });
    const clearBtn = panel.querySelector(".msf-clear");
    if(clearBtn) clearBtn.addEventListener("click", ()=>{
      filtersObj[key] = [];
      onChange();
      closeMsfPanel();
    });
    const rect = btn.getBoundingClientRect();
    panel.style.minWidth = rect.width+"px";
    panel.classList.add("open");
    btn.classList.add("open");
    const panelRect = panel.getBoundingClientRect();
    let top = rect.bottom + 4;
    if(top + panelRect.height > window.innerHeight) top = Math.max(8, rect.top - panelRect.height - 4);
    panel.style.top = top + "px";
    panel.style.left = Math.max(8, rect.left) + "px";
  });
}

function updateEditableMode(section){
  const enabled = editMode[section];
  document.querySelectorAll(`[data-section="${section}"]`).forEach(td=>{
    td.contentEditable = enabled ? "true" : "false";
    td.style.opacity = enabled ? "1" : "0.7";
    td.style.cursor = enabled ? "text" : "default";
  });
}

function editableTd(value, idx, field, section){
  return `<td class="editable-cell" contenteditable="false" data-idx="${idx}" data-field="${field}" data-section="${section}">${escapeHtml(value==null?"":value)}</td>`;
}

function renderServers(){
  const cardsWrap = document.getElementById("serverCards");
  const body = document.getElementById("serversBody");
  if(!cardsWrap || !body) return;
  const svToggle = document.getElementById("editToggleServers");
  if(svToggle) svToggle.checked = !!editMode.servers;

  const vmAll = (backupData && backupData.vm) || [];
  const totalSize = vmAll.reduce((s,m)=>s+(parseFloat(m.sizeUsed)||0),0);
  const byStorage = {};
  vmAll.forEach(m=>{ const k=m.storage||"نامشخص"; byStorage[k]=(byStorage[k]||0)+(parseFloat(m.sizeUsed)||0); });
  const byScheduleCount = {};
  vmAll.forEach(m=>{ const k=m.schedule||"نامشخص"; byScheduleCount[k]=(byScheduleCount[k]||0)+1; });

  let dailySlots=0, dailyMarks=0, lastDate=null;
  Object.keys(dailyLog).forEach(group=>{
    (dailyLog[group]||[]).forEach(e=>{
      dailySlots++;
      if(e.done) dailyMarks++;
      const key = e.year*10000+e.month*100+e.day;
      if(!lastDate || key>lastDate.key) lastDate = {key, ...e};
    });
  });
  const dailyPct = dailySlots ? Math.round((dailyMarks/dailySlots)*100) : 0;

  cardsWrap.innerHTML = `
    <div class="stat blue"><div class="lbl">🖥️ تعداد سرورها</div><div class="val">${fa(vmAll.length)}</div></div>
    <div class="stat teal"><div class="lbl">💾 حجم کل (GB)</div><div class="val">${fa(Math.round(totalSize))}</div></div>
    <div class="stat green"><div class="lbl">✅ نرخ موفقیت بکاپ روزانه</div><div class="val">${fa(dailyPct)}٪</div></div>
    <div class="stat amber"><div class="lbl">🗂️ گروه‌های زمان‌بندی</div><div class="val">${fa(Object.keys(byScheduleCount).length)}</div></div>
  `;

  const schedSel = document.getElementById("msfSchedule");
  const storSel = document.getElementById("msfStorage");
  if(schedSel) renderMultiFilter(schedSel, vmAll.map(m=>m.schedule), vmFilters, "schedule", renderServers);
  if(storSel) renderMultiFilter(storSel, vmAll.map(m=>m.storage), vmFilters, "storage", renderServers);

  const vm = applyVmFilters(vmAll);
  const bodyRows = vm.map((m)=>{
    const idx = vmAll.indexOf(m);
    return `
    <tr>
      <td>${fa(idx+1)}</td>
      ${editableTd(m.server, idx, "server", "servers")}
      ${editableTd(m.location, idx, "location", "servers")}
      ${editableTd(m.sizeUsed, idx, "sizeUsed", "servers")}
      ${editableTd(m.schedule, idx, "schedule", "servers")}
      ${editableTd(m.lastRestore, idx, "lastRestore", "servers")}
      ${editableTd(m.lastFullBackup, idx, "lastFullBackup", "servers")}
      ${editableTd(m.storage, idx, "storage", "servers")}
      <td><button class="btn-del" data-remove-server="${idx}" ${editMode.servers?'':'disabled'} title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  const addRow = `
    <tr class="add-row">
      <td>＋</td>
      <td><input type="text" id="newServerName" placeholder="نام سرور" style="width:100%;"></td>
      <td><input type="text" id="newServerLocation" placeholder="IP/محل" style="width:100%;"></td>
      <td><input type="number" id="newServerSize" placeholder="GB" style="width:100%;"></td>
      <td><input type="text" id="newServerSchedule" placeholder="روزانه یک بار" list="scheduleOptions" style="width:100%;"></td>
      <td colspan="2"><input type="text" id="newServerTime" placeholder="زمان بکاپ" style="width:100%;"></td>
      <td><input type="text" id="newServerStorage" placeholder="Storage-01" style="width:100%;"></td>
      <td><button class="btn btn-brass" id="addServerBtn" style="padding:4px 8px; font-size:12px;">افزودن</button></td>
    </tr>
    <datalist id="scheduleOptions">${SCHEDULE_OPTIONS.map(o=>`<option value="${o}">`).join("")}</datalist>
  `;

  body.innerHTML = (bodyRows || `<tr><td colspan="9" style="color:var(--ink-faint);">موردی با این فیلتر پیدا نشد</td></tr>`) + addRow;

  body.querySelectorAll(".editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=>{
      commitServerCell(parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim());
    });
  });
  body.querySelectorAll("[data-remove-server]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این سرور از فهرست حذف شود؟")) return;
      backupData.vm.splice(parseInt(btn.getAttribute("data-remove-server")),1);
      saveServersSheet();
      renderServers();
    });
  });
  const addBtn = document.getElementById("addServerBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const server = document.getElementById("newServerName").value.trim();
    if(!server){ alert("نام سرور را وارد کنید."); return; }
    addServerRow({
      server, location: document.getElementById("newServerLocation").value.trim(),
      size: document.getElementById("newServerSize").value,
      sizeUsed: document.getElementById("newServerSize").value,
      schedule: document.getElementById("newServerSchedule").value.trim(),
      time: document.getElementById("newServerTime").value.trim(),
      storage: document.getElementById("newServerStorage").value.trim()
    });
  });

  document.getElementById("dailySlotsTxt").textContent = fa(dailySlots);
  document.getElementById("dailyMarksTxt").textContent = fa(dailyMarks);
  document.getElementById("dailyPctTxt").textContent = fa(dailyPct)+"٪";
  document.getElementById("lastBackupDateTxt").textContent = lastDate ? `${fa(lastDate.year)}/${fa(lastDate.month)}/${fa(lastDate.day)}` : "-";

  renderDailyCalendar();

  destroyChart("schedule");
  destroyChart("storage");
  if(!chartsReady()) return;
  try{
    charts.schedule = new Chart(document.getElementById("chartSchedule"), {
      type:"bar",
      data:{ labels:Object.keys(byScheduleCount), datasets:[{ data:Object.values(byScheduleCount), backgroundColor:chartTone().cat[0], hoverBackgroundColor:chartHover([chartTone().cat[0]])[0], borderRadius:4 }] },
      options:{ indexAxis:"y", plugins:{legend:{display:false}, tooltip:{bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+fa(ctx.parsed.x)+" سرور"}}}, scales:{ x:{ticks:{callback:v=>fa(v), precision:0}}, y:{ticks:{font:{family:"Vazirmatn, Tahoma, Arial, sans-serif", size:11}}} } }
    });
    charts.storage = new Chart(document.getElementById("chartStorage"), {
      type:"doughnut",
      data:{ labels:Object.keys(byStorage), datasets:[{ data:Object.values(byStorage).map(v=>Math.round(v)), backgroundColor:chartTone().cat, hoverBackgroundColor:chartHover(chartTone().cat), hoverOffset:12, borderColor:chartTone().surface, borderWidth:2 }] },
      options:{ layout:{padding:14}, cutout:"58%", plugins:{legend:{position:"bottom", labels:{font:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}}}, tooltip:{bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+ctx.label+": "+fa(ctx.parsed)+" GB"}}} }
    });
  }catch(e){ /* charts optional here */ }
}

function renderDailyCalendar(){
  const wrap = document.getElementById("dailyRibbonTables");
  if(!wrap) return;

  const blocks = Object.keys(dailyLog).map(group=>{
    const sel = dailyCalSel[group] || (dailyCalSel[group] = currentJalaliYM());
    const nDays = daysInJalaliMonth(sel.year, sel.month);
    const cells = Array.from({length:nDays}, (_,i)=>{
      const day = i+1;
      const e = getDailyEntry(group, sel.year, sel.month, day);
      const done = !!(e && e.done);
      return `<button type="button" class="cal-day ${done?'done':''}" data-group="${escapeHtml(group)}" data-y="${sel.year}" data-m="${sel.month}" data-d="${day}" title="${fa(sel.year)}/${fa(sel.month)}/${fa(day)}">${fa(day)}</button>`;
    }).join("");
    const doneCount = Array.from({length:nDays}, (_,i)=> getDailyEntry(group, sel.year, sel.month, i+1)).filter(e=>e&&e.done).length;
    return `
      <div class="cal-block">
        <div class="cal-head">
          <h4>${escapeHtml(group)}</h4>
          <div class="cal-nav">
            <button type="button" class="cal-nav-btn" data-nav="${escapeHtml(group)}|-1">‹</button>
            <span class="cal-label">${JALALI_MONTH_NAMES[sel.month-1]} ${fa(sel.year)}</span>
            <button type="button" class="cal-nav-btn" data-nav="${escapeHtml(group)}|1">›</button>
          </div>
          <span class="cal-count">${fa(doneCount)} / ${fa(nDays)} روز موفق</span>
        </div>
        <div class="cal-grid">${cells}</div>
      </div>`;
  }).join("");

  wrap.innerHTML = blocks || `<p style="color:var(--ink-faint); font-size:12.5px;">داده‌ای برای نمایش نیست.</p>`;

  wrap.querySelectorAll(".cal-day").forEach(btn=>{
    btn.addEventListener("click", ()=> toggleCalendarDay(
      btn.getAttribute("data-group"),
      parseInt(btn.getAttribute("data-y")),
      parseInt(btn.getAttribute("data-m")),
      parseInt(btn.getAttribute("data-d"))
    ));
  });
  wrap.querySelectorAll("[data-nav]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const [group, delta] = btn.getAttribute("data-nav").split("|");
      shiftDailyCalMonth(group, parseInt(delta));
    });
  });
}

function setupServers(){
  /* در کارتابلِ عمومی این نما وجود ندارد */
  if(!document.getElementById("refreshExcelBtn")) return;
  document.getElementById("refreshExcelBtn").addEventListener("click", loadDatabase);
  document.querySelectorAll(".col-filter").forEach(el=>{
    const evt = el.tagName==="SELECT" ? "change" : "input";
    el.addEventListener(evt, ()=>{
      if(el.tagName==="SELECT"){
        // For select (possibly multiple), get selected values
        vmFilters[el.getAttribute("data-key")] = Array.from(el.selectedOptions).map(o=>o.value).filter(v=>v!=="");
      } else {
        // For text input
        vmFilters[el.getAttribute("data-key")] = [el.value].filter(v=>v.trim()!=="");
      }
      renderServers();
    });
  });
  const delToggle = document.getElementById("editToggleServers");
  if(delToggle) delToggle.addEventListener("change", ()=>{
    editMode.servers = delToggle.checked;
    renderServers();
    updateEditableMode("servers");
  });
}

/* ---------------- Rendering: Companies ---------------- */

const TYPE_LABELS_FA = { "Remote":"ریموت", "Person":"حضوری", "Remote+Person":"ریموت + حضوری" };
const TYPE_OPTIONS = ["Remote","Person","Remote+Person"];

function commitCompanyVisitCell(name, idx, field, value){
  if(!companiesData || !companiesData.companies[name] || !companiesData.companies[name][idx]) return;
  companiesData.companies[name][idx][field] = value;
  saveCompaniesSheet();
}

function renderCompanies(){
  const wrap = document.getElementById("companiesWrap");
  if(!wrap) return;

  const names = companiesData ? Object.keys(companiesData.companies) : [];
  const panels = names.map(name=>{
    const isEditable = !!editModeCompanies[name];
    const entries = companiesData.companies[name] || [];
    const total = entries.length;
    const byType = {};
    entries.forEach(e=>{ const k=e.type||"نامشخص"; byType[k]=(byType[k]||0)+1; });
    const last = entries[entries.length-1];
    const rows = [...entries].reverse().map(e=>{
      const idx = entries.indexOf(e);
      const typeOptions = TYPE_OPTIONS.map(o=>`<option value="${o}" ${o===e.type?"selected":""}>${TYPE_LABELS_FA[o]}</option>`).join("");
      return `
      <tr>
        <td class="editable-cell" contenteditable="${isEditable?'true':'false'}" data-section="companies" data-company="${escapeHtml(name)}" data-idx="${idx}" data-field="dateStr" style="opacity:${isEditable?'1':'0.7'}; cursor:${isEditable?'text':'default'};">${escapeHtml(e.dateStr)}</td>
        <td class="editable-cell" contenteditable="${isEditable?'true':'false'}" data-section="companies" data-company="${escapeHtml(name)}" data-idx="${idx}" data-field="time" style="opacity:${isEditable?'1':'0.7'}; cursor:${isEditable?'text':'default'};">${escapeHtml(e.time)}</td>
        <td><select class="visit-type-select" data-company="${escapeHtml(name)}" data-idx="${idx}" ${isEditable?'':'disabled'}>${typeOptions}</select></td>
        <td><button class="btn-del" data-remove-visit="${escapeHtml(name)}|${idx}" ${isEditable?'':'disabled'} title="حذف">✕</button></td>
      </tr>`;
    }).join("");
    const typeChips = Object.entries(byType).map(([k,v])=>
      `<span class="badge doing" style="margin-inline-end:6px;">${escapeHtml(TYPE_LABELS_FA[k]||k)}: ${fa(v)}</span>`).join("");
    return `
      <div class="panel" style="margin-bottom:16px;">
        <h3>🏢 ${escapeHtml(name)}</h3>
        <div style="display:flex; gap:18px; flex-wrap:wrap; align-items:center; margin-bottom:12px; font-size:12.5px;">
          <span><b>${fa(total)}</b> بازدید ثبت‌شده</span>
          <span>آخرین بازدید: <b>${last? escapeHtml(last.dateStr) : "-"}</b></span>
          <span>${typeChips}</span>
        </div>
        <div class="tbl-wrap visits-wrap" style="max-height:280px; overflow-y:auto;">
          <table class="company-visits-table">
            <colgroup>
              <col style="width:22%;"><col style="width:20%;"><col style="width:38%;"><col style="width:20%;">
            </colgroup>
            <thead><tr>
              <th>تاریخ</th><th>مدت زمان</th><th>نوع</th>
              <th>
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر برای این شرکت">
                  <span class="edit-switch"><input type="checkbox" class="edit-toggle-company" data-company="${escapeHtml(name)}" ${isEditable?'checked':''}><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr></thead>
            <tbody>${rows || '<tr><td colspan="4" style="color:var(--ink-faint);">داده‌ای نیست</td></tr>'}</tbody>
          </table>
        </div>
        <div class="visit-add-bar">
          <input type="text" class="new-visit-date" data-company="${escapeHtml(name)}" placeholder="تاریخ — ۱۴۰۵.۰۵.۲۰" style="width:160px;">
          <input type="text" class="new-visit-time" data-company="${escapeHtml(name)}" placeholder="مدت — ۳۰m" style="width:130px;">
          <select class="new-visit-type" data-company="${escapeHtml(name)}" style="width:70px;">${TYPE_OPTIONS.map(o=>`<option value="${o}">${TYPE_LABELS_FA[o]}</option>`).join("")}</select>
          <button class="btn btn-brass btn-sm" data-add-visit="${escapeHtml(name)}">＋</button>
        </div>
      </div>`;
  }).join("");

  wrap.innerHTML = panels + `
    <div class="new-company-card">
      <span style="font-size:13px; color:var(--ink-soft);">🏢 شرکت جدید:</span>
      <input type="text" id="newCompanyName" placeholder="نام شرکت را وارد کنید...">
      <button class="btn btn-brass btn-sm" id="addCompanyBtn">＋ افزودن شرکت</button>
    </div>`;

  wrap.querySelectorAll("[data-add-visit]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const name = btn.getAttribute("data-add-visit");
      const dateStr = wrap.querySelector(`.new-visit-date[data-company="${name}"]`).value.trim();
      const time = wrap.querySelector(`.new-visit-time[data-company="${name}"]`).value.trim();
      const type = wrap.querySelector(`.new-visit-type[data-company="${name}"]`).value;
      if(!dateStr){ alert("تاریخ بازدید را وارد کنید."); return; }
      addCompanyVisit(name, dateStr, time, type);
    });
  });
  wrap.querySelectorAll("[data-remove-visit]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const [name, idx] = btn.getAttribute("data-remove-visit").split("|");
      if(!confirm("این بازدید حذف شود؟")) return;
      removeCompanyVisit(name, parseInt(idx));
    });
  });
  wrap.querySelectorAll(".editable-cell[data-section=\"companies\"]").forEach(td=>{
    td.addEventListener("blur", ()=>{
      commitCompanyVisitCell(td.getAttribute("data-company"), parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim());
    });
  });
  wrap.querySelectorAll(".visit-type-select").forEach(sel=>{
    sel.addEventListener("change", ()=>{
      commitCompanyVisitCell(sel.getAttribute("data-company"), parseInt(sel.getAttribute("data-idx")), "type", sel.value);
      renderCompanies();
    });
  });
  wrap.querySelectorAll(".edit-toggle-company").forEach(cb=>{
    cb.addEventListener("change", ()=>{
      const company = cb.getAttribute("data-company");
      editModeCompanies[company] = cb.checked;
      renderCompanies();
    });
  });
  const addCompanyBtn = document.getElementById("addCompanyBtn");
  if(addCompanyBtn) addCompanyBtn.addEventListener("click", ()=>{
    const name = document.getElementById("newCompanyName").value.trim();
    if(!name){ alert("نام شرکت را وارد کنید."); return; }
    addNewCompany(name);
  });
}

function setupCompanies(){
  /* در کارتابلِ عمومی این نما وجود ندارد */
  if(!document.getElementById("refreshDateBtn")) return;
  document.getElementById("refreshDateBtn").addEventListener("click", loadDatabase);
}

/* ---------------- Rendering: MVPN ---------------- */

/* ترتیبِ این دو شرط مهم است و یک بار اشتباه بود.
   مرحلهٔ واقعیِ یکی از خط‌ها این است:
     «حذف شود-از شرکت دیگه براشون فعال شده»
   چون «فعال شده» اول بررسی می‌شد، این خط سبزِ «فعال» می‌گرفت و در
   کارتِ بالا هم جزوِ فعال‌ها شمرده می‌شد — یعنی کل ۳۹، فعال ۳۹ و
   حذف‌شونده ۱، که با هم نمی‌خواند. «حذف» حرفِ آخر را می‌زند. */
function mvpnIsRemoved(stage){ return String(stage||"").includes("حذف"); }
function mvpnIsActive(stage){
  return !mvpnIsRemoved(stage) && String(stage||"").includes("فعال شده");
}
function stageBadgeClass(stage){
  if(mvpnIsRemoved(stage)) return "todo";
  if(mvpnIsActive(stage))  return "done";
  return "doing";
}

function applyMvpnFilters(lines){
  return lines.filter(l=>{
    for(const key of Object.keys(mvpnFilters)){
      const filters = mvpnFilters[key];
      if(!filters || filters.length===0) continue;
      const val = String(l[key]||"").toLowerCase();
      if(key==="stage" || key==="plan"){
        if(!filters.some(f=> f.toLowerCase()===val)) return false;
      } else {
        if(!filters.some(f=> val.includes(f.toLowerCase()))) return false;
      }
    }
    return true;
  });
}

function renderMvpn(){
  const cardsWrap = document.getElementById("mvpnCards");
  const body = document.getElementById("mvpnBody");
  if(!cardsWrap || !body) return;
  const mvToggle = document.getElementById("editToggleMvpn");
  if(mvToggle) mvToggle.checked = !!editMode.mvpn;

  const all = (mvpnData && mvpnData.lines) || [];
  const activeCount = all.filter(l=> mvpnIsActive(l.stage)).length;
  const removeCount = all.filter(l=> mvpnIsRemoved(l.stage)).length;

  cardsWrap.innerHTML = `
    <div class="stat blue"><div class="lbl">📱 کل خطوط</div><div class="val">${fa(all.length)}</div></div>
    <div class="stat green"><div class="lbl">✅ فعال</div><div class="val">${fa(activeCount)}</div></div>
    <div class="stat red"><div class="lbl">🗑️ حذف‌شونده</div><div class="val">${fa(removeCount)}</div></div>
  `;

  const stageSel = document.getElementById("msfStage");
  const planSel = document.getElementById("msfPlan");
  if(stageSel) renderMultiFilter(stageSel, all.map(l=>l.stage), mvpnFilters, "stage", renderMvpn);
  if(planSel) renderMultiFilter(planSel, all.map(l=>l.plan), mvpnFilters, "plan", renderMvpn);

  const lines = applyMvpnFilters(all);
  const bodyRows = lines.map((l)=>{
    const idx = all.indexOf(l);
    return `
    <tr>
      <td>${fa(idx+1)}</td>
      ${editableTd(l.phone, idx, "phone", "mvpn")}
      ${editableTd(l.owner, idx, "owner", "mvpn")}
      <td><span class="badge ${stageBadgeClass(l.stage)}">${escapeHtml(l.stage)}</span></td>
      ${editableTd(l.ext, idx, "ext", "mvpn")}
      ${editableTd(l.plan, idx, "plan", "mvpn")}
      <td><button class="btn-del" data-remove-mvpn="${idx}" ${editMode.mvpn?'':'disabled'} title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  const addRow = `
    <tr class="add-row">
      <td>＋</td>
      <td><input type="text" id="newMvpnPhone" placeholder="09xxxxxxxxx" style="width:100%;"></td>
      <td><input type="text" id="newMvpnOwner" placeholder="نام مالک" style="width:100%;"></td>
      <td><input type="text" id="newMvpnStage" placeholder="فعال شده" style="width:100%;"></td>
      <td><input type="text" id="newMvpnExt" placeholder="داخلی" style="width:100%;"></td>
      <td><input type="text" id="newMvpnPlan" placeholder="طرح" style="width:100%;"></td>
      <td><button class="btn btn-brass" id="addMvpnBtn" style="padding:4px 8px; font-size:12px;">افزودن</button></td>
    </tr>`;

  body.innerHTML = (bodyRows || `<tr><td colspan="6" style="color:var(--ink-faint);">موردی با این فیلتر پیدا نشد</td></tr>`) + addRow;

  body.querySelectorAll(".editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=>{
      commitMvpnCell(parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim());
    });
  });
  body.querySelectorAll("[data-remove-mvpn]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این خط از فهرست حذف شود؟")) return;
      mvpnData.lines.splice(parseInt(btn.getAttribute("data-remove-mvpn")),1);
      saveMvpnSheet();
      renderMvpn();
    });
  });
  const addBtn = document.getElementById("addMvpnBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const phone = document.getElementById("newMvpnPhone").value.trim();
    if(!phone){ alert("شماره تماس را وارد کنید."); return; }
    addMvpnLine({
      phone, owner: document.getElementById("newMvpnOwner").value.trim(),
      stage: document.getElementById("newMvpnStage").value.trim(),
      ext: document.getElementById("newMvpnExt").value.trim(),
      plan: document.getElementById("newMvpnPlan").value.trim()
    });
  });
}

function setupMvpn(){
  /* در کارتابلِ عمومی این نما وجود ندارد */
  if(!document.getElementById("refreshMvpnBtn")) return;
  document.getElementById("refreshMvpnBtn").addEventListener("click", loadDatabase);
  document.querySelectorAll(".mvpn-filter").forEach(el=>{
    const evt = el.tagName==="SELECT" ? "change" : "input";
    el.addEventListener(evt, ()=>{
      if(el.tagName==="SELECT"){
        // For select (possibly multiple), get selected values
        mvpnFilters[el.getAttribute("data-key")] = Array.from(el.selectedOptions).map(o=>o.value).filter(v=>v!=="");
      } else {
        // For text input
        mvpnFilters[el.getAttribute("data-key")] = [el.value].filter(v=>v.trim()!=="");
      }
      renderMvpn();
    });
  });
  const delToggle = document.getElementById("editToggleMvpn");
  if(delToggle) delToggle.addEventListener("change", ()=>{
    editMode.mvpn = delToggle.checked;
    renderMvpn();
    updateEditableMode("mvpn");
  });
}

/* ---------------- Rendering: Remote checklist ---------------- */

function removeRemoteServer(server){
  if(!remoteBackupData) return;
  remoteBackupData.roster = remoteBackupData.roster.filter(m=>m.server!==server);
  delete state.remoteChecks[server];
  saveRemoteChecklistSheet();
  scheduleSave();
  renderRemoteChecklist();
}

function commitRemoteServerName(oldServer, newServer){
  if(!remoteBackupData || !newServer || newServer===oldServer) return;
  const m = remoteBackupData.roster.find(r=>r.server===oldServer);
  if(!m) return;
  if(remoteBackupData.roster.some(r=>r.server===newServer)){
    alert("سروری با این نام از قبل هست.");
    renderRemoteChecklist();
    return;
  }
  m.server = newServer;
  if(state.remoteChecks[oldServer]){
    state.remoteChecks[newServer] = state.remoteChecks[oldServer];
    delete state.remoteChecks[oldServer];
  }
  saveRemoteChecklistSheet();
  scheduleSave();
  renderRemoteChecklist();
}

function renderRemoteChecklist(){
  const wrap = document.getElementById("remoteChecklistWrap");
  if(!wrap) return;
  const roster = (remoteBackupData && remoteBackupData.roster) || [];
  const days = state.remoteCheckDates.length;
  const dayHeaders = Array.from({length:days}, (_,i)=>
    `<th><div class="remote-day-head">
      <input type="text" class="remote-date-header" data-idx="${i}" value="${escapeHtml(state.remoteCheckDates[i]||'')}" placeholder="${fa(i+1)}" ${editMode.remote?'':'disabled'}>
      <button type="button" class="remote-day-del" data-remove-day="${i}" ${editMode.remote?'':'disabled'} title="حذف این روز">✕</button>
    </div></th>`
  ).join("");
  const rows = roster.map(m=>{
    const checks = state.remoteChecks[m.server] || {};
    const count = Object.values(checks).filter(Boolean).length;
    const cells = Array.from({length:days}, (_,i)=>{
      const d = i+1;
      const on = !!checks[d];
      return `<td><button type="button" class="day-toggle ${on?'checked':''}" data-server="${escapeHtml(m.server)}" data-day="${d}">${on?'✓':''}</button></td>`;
    }).join("");
    return `<tr><td class="server-name editable-cell" contenteditable="${editMode.remote?'true':'false'}" data-section="remote" data-server="${escapeHtml(m.server)}" style="opacity:${editMode.remote?'1':'0.85'}; cursor:${editMode.remote?'text':'default'};">${escapeHtml(m.server)}</td>${cells}<td class="remote-count-cell">${fa(count)}/${fa(days)}</td><td><button class="btn-del" data-remove-remote="${escapeHtml(m.server)}" ${editMode.remote?'':'disabled'} title="حذف">✕</button></td></tr>`;
  }).join("");

  wrap.innerHTML = `
    <div class="remote-grid-wrap tbl-wrap">
      <table class="remote-grid">
        <thead><tr>
          <th style="position:sticky; right:0; min-width:180px;">سرور</th>${dayHeaders}<th>تعداد</th>
          <th style="width:70px;">
            <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
              <span class="edit-switch"><input type="checkbox" id="editToggleRemote"><span class="track"></span></span>
              حذف/تغییر
            </label>
          </th>
        </tr></thead>
        <tbody>${rows || `<tr><td colspan="${days+3}" style="color:var(--ink-faint);">فهرستی ثبت نشده — از فرم پایین سرور اضافه کنید.</td></tr>`}</tbody>
      </table>
    </div>
    <div class="visit-add-bar" style="margin-top:12px;">
      <input type="text" id="newRemoteServer" placeholder="نام سرور — مثل: قیر هرمزگان - 192.168.1.10" style="width:280px;">
      <button class="btn btn-brass btn-sm" id="addRemoteServerBtn">＋ افزودن سرور</button>
      <button class="btn btn-ghost btn-sm" id="addRemoteDayBtn">＋ افزودن روز</button>
    </div>`;

  wrap.querySelectorAll(".remote-date-header").forEach(inp=>{
    inp.addEventListener("input", ()=>{
      const idx = parseInt(inp.getAttribute("data-idx"));
      state.remoteCheckDates[idx] = inp.value;
      scheduleSave();
      saveRemoteChecklistSheet();
    });
  });

  wrap.querySelectorAll("[data-remove-day]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!editMode.remote) return;
      const idx = parseInt(btn.getAttribute("data-remove-day"));
      const label = state.remoteCheckDates[idx] || `روز ${toPersianDigits(idx+1)}`;
      if(!confirm(`ستون «${label}» حذف شود؟ تیک‌های ثبت‌شده برای این روز هم پاک می‌شوند.`)) return;
      removeRemoteDay(idx);
    });
  });

  wrap.querySelectorAll(".server-name.editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=>{
      commitRemoteServerName(td.getAttribute("data-server"), td.textContent.trim());
    });
  });

  wrap.querySelectorAll("[data-remove-remote]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این سرور از چک‌لیست حذف شود؟")) return;
      removeRemoteServer(btn.getAttribute("data-remove-remote"));
    });
  });

  const delToggle = document.getElementById("editToggleRemote");
  if(delToggle){
    delToggle.checked = !!editMode.remote;
    delToggle.addEventListener("change", ()=>{
      editMode.remote = delToggle.checked;
      renderRemoteChecklist();
    });
  }

  wrap.querySelectorAll(".day-toggle").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const server = btn.getAttribute("data-server");
      const day = btn.getAttribute("data-day");
      if(!state.remoteChecks[server]) state.remoteChecks[server] = {};
      state.remoteChecks[server][day] = !state.remoteChecks[server][day];
      // به‌جای بازسازی کامل جدول (که باعث می‌شد اسکرول افقی جدول ناگهان به ابتدا برگردد
      // و ظاهراً «چپ‌وراست» شود)، فقط همین دکمه و شمارنده‌ی همان ردیف به‌روزرسانی می‌شود.
      const isOn = !!state.remoteChecks[server][day];
      btn.classList.toggle("checked", isOn);
      btn.textContent = isOn ? "✓" : "";
      const row = btn.closest("tr");
      if(row){
        const days = state.remoteCheckDates.length;
        const checks = state.remoteChecks[server] || {};
        const count = Object.values(checks).filter(Boolean).length;
        const countCell = row.children[row.children.length-2];
        if(countCell) countCell.textContent = fa(count)+"/"+fa(days);
      }
      scheduleSave();
      saveRemoteChecklistSheet();
    });
  });

  const addServerBtn = document.getElementById("addRemoteServerBtn");
  if(addServerBtn) addServerBtn.addEventListener("click", ()=>{
    const server = document.getElementById("newRemoteServer").value.trim();
    if(!server){ alert("نام سرور را وارد کنید."); return; }
    addRemoteServer(server);
  });
  const addDayBtn = document.getElementById("addRemoteDayBtn");
  if(addDayBtn) addDayBtn.addEventListener("click", ()=> addRemoteDay(""));
}

function setupRemote(){
  /* در کارتابلِ عمومی این نما وجود ندارد */
  if(!document.getElementById("refreshRemoteBtn")) return;
  document.getElementById("refreshRemoteBtn").addEventListener("click", loadDatabase);
}
{{PART:vault}}
function renderAll(){
  renderDashHero();
  renderCards();
  renderDeadlines();
  renderCharts();
  renderChecklist();
  renderDaily();
  renderRemindersBanner();
}
{{PART:noautofill}}
/* ---------------- Navigation ---------------- */
function setupNav(){
  document.querySelectorAll(".navbtn").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      document.querySelectorAll(".navbtn").forEach(b=>b.classList.remove("active"));
      btn.classList.add("active");
      const view = btn.getAttribute("data-view");
      document.querySelectorAll(".view").forEach(v=>v.classList.remove("active"));
      document.getElementById("view-"+view).classList.add("active");
      if(view==="dashboard"){ renderCharts(); renderRemindersBanner(); }
      if(view==="servers"){ renderServers(); renderRemoteChecklist(); }
      if(view==="companies") renderCompanies();
      if(view==="mvpn") renderMvpn();
      if(view==="personal") renderPersonalView();
    });
  });
}

function setupMeta(){
  const btn = document.getElementById("monthBtn");
  const pop = document.getElementById("monthPop");
  if(!btn || !pop) return;
  const list = document.getElementById("monthPopList");
  const nameEl = document.getElementById("newMonthName");
  const yearEl = document.getElementById("newMonthYear");
  const okEl = document.getElementById("confirmNewMonthBtn");
  const noteEl = document.getElementById("monthPopNote");
  const xEl = document.getElementById("monthPopX");

  const note = t=>{ if(noteEl) noteEl.textContent = t||""; };
  const open = ()=>{
    MP_EDIT = null;
    renderMonthSelector();
    pop.hidden = false; btn.classList.add("on"); note("");
    if(nameEl) nameEl.value = "";
    /* سالِ ماهِ جاری از قبل پُر است، چون ماهِ تازه تقریباً همیشه در
       همان سال است و دوباره تایپ کردنش کارِ اضافه است. */
    if(yearEl) yearEl.value = (state.meta && state.meta.year) || "";
  };
  const close = ()=>{ pop.hidden = true; btn.classList.remove("on"); MP_EDIT = null; note(""); };

  btn.addEventListener("click", ()=>{ if(pop.hidden) open(); else close(); });
  if(xEl) xEl.addEventListener("click", close);
  /* زدن روی زمینهٔ تاریک یعنی «بستن» — ولی فقط خودِ زمینه، نه کارت */
  pop.addEventListener("click", e=>{ if(e.target === pop) close(); });
  document.addEventListener("keydown", e=>{ if(e.key === "Escape" && !pop.hidden) close(); });

  const commitRename = (key, row)=>{
    const n = row.querySelector(".me-n"), y = row.querySelector(".me-y");
    if(!n || !y) return;
    MP_EDIT = null;
    if(!renameMonth(key, n.value, y.value)) MP_EDIT = key;
    renderMonthSelector();
  };

  if(list){
    list.addEventListener("click", e=>{
      const go = e.target.closest("[data-go]");
      if(go){
        const parts = go.getAttribute("data-go").split("|");
        switchToMonth(parts[1], parts[0]);
        close();
        return;
      }
      const ren = e.target.closest("[data-ren]");
      if(ren){
        MP_EDIT = ren.getAttribute("data-ren");
        renderMonthSelector();
        const el = list.querySelector(".me-n");
        if(el){ el.focus(); el.select(); }
        return;
      }
      if(e.target.closest("[data-cancel]")){ MP_EDIT = null; renderMonthSelector(); return; }
      const ok = e.target.closest("[data-ok]");
      if(ok) commitRename(ok.getAttribute("data-ok"), ok.closest(".mrow"));
    });
    /* Enter ثبت می‌کند و Escape بی‌خیال می‌شود — بدون اینکه Escape تا
       خودِ پنجره بالا برود و ببنددش. */
    list.addEventListener("keydown", e=>{
      const row = e.target.closest(".mrow");
      if(!row || !MP_EDIT) return;
      if(e.key === "Enter"){ e.preventDefault(); commitRename(MP_EDIT, row); }
      else if(e.key === "Escape"){ e.stopPropagation(); MP_EDIT = null; renderMonthSelector(); }
    });
  }

  if(okEl) okEl.addEventListener("click", ()=>{
    const name = (nameEl.value||"").trim(), year = (yearEl.value||"").trim();
    if(!name || !year){ note("نام ماه و سال را کامل وارد کنید."); return; }
    /* ماهی که از قبل هست دوباره ساخته نمی‌شود؛ فقط می‌رویم سراغش */
    switchToMonth(name, year);
    close();
  });
  [nameEl, yearEl].forEach(el=> el && el.addEventListener("keydown", e=>{
    if(e.key === "Enter"){ e.preventDefault(); okEl.click(); }
  }));
}

function setupToolbar(){
  document.getElementById("addTaskBtn").addEventListener("click", ()=>{
    state.tasks.push({category:CATEGORIES[0], task:"وظیفه جدید", owner:"", deadline:1, status:"انجام نشده", priority:"متوسط", note:""});
    renderAll(); scheduleSave();
  });
  document.getElementById("resetTasksBtn").addEventListener("click", ()=>{
    if(confirm("چک‌لیست به حالت پیش‌فرض بازنشانی شود؟ این کار قابل بازگشت نیست.")){
      state.tasks = deepClone(DEFAULT_STATE.tasks);
      renderAll(); scheduleSave();
    }
  });
  const addDayBtn = document.getElementById("addDayRowBtn");
  if(addDayBtn) addDayBtn.addEventListener("click", addDayRow);
}

function setupBackup(){
  document.getElementById("connectFolderBtn").addEventListener("click", connectFolder);
  document.getElementById("exportBtn").addEventListener("click", ()=>{
    const blob = new Blob([JSON.stringify(state, null, 2)], {type:"application/json"});
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    const stamp = new Date().toISOString().slice(0,10);
    a.href = url;
    a.download = `کارتابل-پشتیبان-${stamp}.json`;
    document.body.appendChild(a); a.click(); a.remove();
    URL.revokeObjectURL(url);
  });
  document.getElementById("importBtn").addEventListener("click", ()=>{
    document.getElementById("importFile").click();
  });
  document.getElementById("importFile").addEventListener("change", (e)=>{
    const file = e.target.files[0];
    if(!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      try{
        const parsed = JSON.parse(reader.result);
        state = Object.assign(deepClone(DEFAULT_STATE), parsed);
        renderMeta(); renderAll(); scheduleSave();
        alert("بازیابی با موفقیت انجام شد.");
      }catch(err){
        alert("فایل پشتیبان معتبر نیست.");
      }
    };
    reader.readAsText(file);
    e.target.value = "";
  });
}

/* =========================================================================
   ابزار تبدیل تاریخ و محاسبه‌ی فاصله‌ی بین دو تاریخ
   ========================================================================= */
function fillJalaliYearSelect(sel, curY){
  sel.innerHTML = "";
  for(let y=1370; y<=curY+10; y++) sel.innerHTML += `<option value="${y}" ${y===curY?"selected":""}>${fa(y)}</option>`;
}
function fillJalaliMonthSelect(sel, curM){
  sel.innerHTML = JALALI_MONTH_NAMES.map((m,i)=>`<option value="${i+1}" ${i+1===curM?"selected":""}>${m}</option>`).join("");
}
function formatJalaliLong(y,m,d){
  return `${fa(d)} ${JALALI_MONTH_NAMES[m-1]} ${fa(y)}`;
}
function formatGregorianLong(y,m,d){
  const names = ["January","February","March","April","May","June","July","August","September","October","November","December"];
  return `${d} ${names[m-1]} ${y}`;
}
{{PART:jalali}}
function dbSnapshot(){
  return {
    vm: backupData && backupData.vm || [],
    dailyLog: dailyLog,
    companies: companiesData && companiesData.companies || {},
    lines: mvpnData && mvpnData.lines || [],
    roster: remoteBackupData && remoteBackupData.roster || []
  };
}

function applyDbSnapshot(c){
  if(!c) return;
  backupData = { vm: c.vm || [] };
  dailyLog = c.dailyLog || { "روزانه یک‌بار": [], "روزانه دوبار": [] };
  companiesData = { companies: c.companies || {} };
  mvpnData = { lines: c.lines || [] };
  remoteBackupData = { roster: c.roster || [] };
}
{{PART:cloudsync}}
      online = true; blocked = false;
      rev = srvRev;
      if(r.data.state){
        state = Object.assign(deepClone(DEFAULT_STATE), r.data.state);
        /* جای خالی را فقط وقتی با نمونه پر می‌کنیم که سرور اصلاً چیزی
           نداشته باشد؛ وگرنه ردیف‌های نمونه روی دادهٔ واقعی نوشته می‌شوند. */
        if(srvRev === 0){
          if(!state.tasks || !state.tasks.length) state.tasks = deepClone(DEFAULT_STATE.tasks);
          if(!state.days || !Array.isArray(state.days) || !state.days.length) state.days = deepClone(DEFAULT_STATE.days);
        }
        if(!Array.isArray(state.tasks)) state.tasks = [];
        if(!Array.isArray(state.days)) state.days = [];
        if(!state.remoteChecks || typeof state.remoteChecks !== "object") state.remoteChecks = {};
        if(!state.remoteCheckDates || !Array.isArray(state.remoteCheckDates) || !state.remoteCheckDates.length)
          state.remoteCheckDates = deepClone(DEFAULT_STATE.remoteCheckDates);
        ensureMonthsMigration();
        try{ localStorage.setItem(STORE_KEY, JSON.stringify(state)); }catch(e){}
      }
      if(r.data.db){
        applyDbSnapshot(r.data.db);
        try{ persistDbCacheLocal(); }catch(e){}
      }
      setCloudStatus(r.data.updated
        ? "آخرین همگام‌سازی: " + new Date(r.data.updated).toLocaleString("fa-IR")
        : "روی سرور هنوز چیزی ذخیره نشده.");
      return true;
    }catch(e){
      online = false;
      setCloudStatus("آفلاین — فعلاً روی همین مرورگر کار می‌کنید.");
      return false;
    }
  }

{{PART:cloudpush}}


/* ---------- تم روز و شب ----------
   انتخاب هر پلنر جداست و در حافظهٔ همان مرورگر می‌ماند. پیش‌فرض روز است
   تا چیزی بی‌خبر عوض نشود؛ تا وقتی دکمه را نزنید همان شکل قبلی می‌ماند. */
const THEME_KEY = STORE_KEY + ":theme";

function currentTheme(){
  return document.documentElement.getAttribute("data-theme") === "dark" ? "dark" : "light";
}

function redrawAfterTheme(){ renderAll(); }
{{PART:theme}}
/* ---------- دستیار هوشمند ----------
   گفتگو در حافظهٔ همین مرورگر می‌ماند (هر کارتابل کلیدِ خودش را دارد) و
   هر بار چند پیامِ آخر همراه سؤال بالا می‌رود تا دستیار رشتهٔ حرف را گم
   نکند. متنِ داده‌های کارتابل را سرور خودش می‌سازد؛ این‌جا فقط تاریخِ
   امروز را می‌فرستیم تا سررسیدگذشته‌ها را درست تشخیص بدهد. */
const AI_KEY = STORE_KEY + ":ai";
const AI_TIPS = ["این ماه چه کارهایی عقب افتاده؟",
  "وضعیت بکاپ سرورها را خلاصه کن",
  "کدام شرکت‌ها بیشترین بازدید را داشته‌اند؟",
  "خطوط MVPN که هنوز فعال نشده‌اند کدام‌اند؟",
  "یک ایمیل رسمی فارسی برای پیگیری یک تیکت بنویس"];
{{PART:tablesize}}

{{PART:reportjs}}

{{PART:aiassist}}
async function init(){

  try{
    await loadState();
    loadCachedDatabase();
    /* نسخهٔ محلی فقط برای این است که صفحه فوری بالا بیاید؛ مرجع سرور
       است. منتظر می‌مانیم تا ورود قطعی شود، بعد داده را می‌گیریم. */
    try{ if(gateReady) await gateReady; }catch(e){}
    /* وقتی وارد نشده‌ایم، درخواست داده فقط یک ۴۰۱ بی‌فایده می‌سازد؛
       بعد از ورود، صفحه تازه می‌شود و همه‌چیز از سرور می‌آید. */
    if(signedIn){
      try{ await Cloud.pull(); }catch(e){ /* آفلاین — با نسخهٔ محلی ادامه */ }
    }
    /* هر کدام جدا: اگر یکی بخورد زمین، بقیهٔ کارتابل نباید با آن برود.
       یک‌بار همین اتفاق افتاد و نیمی از صفحه بی‌صدا راه نیفتاد. */
    [renderMeta, setupNav, setupMeta, setupToolbar, setupTheme, setupAssistant,
     setupAiSettings, showLastLogin, showExpiryWarning, setupBackup, setupServers, setupCompanies,
     setupMvpn, setupRemote, setupChartModal, setupDateTools, setupSettings,
     renderAll, renderServers, renderCompanies, renderMvpn, renderRemoteChecklist,
     renderPersonalView, setupShared, setupNoAutofill, requestNotifyPermission, checkAndFireReminders
    ].forEach(fn=>{ try{ fn(); }catch(e){ console.error("راه‌اندازی "+fn.name+":", e); } });
    setInterval(checkAndFireReminders, 20*1000);
  }catch(e){
    console.error("خطا در راه‌اندازی کارتابل:", e);
    if(!state) state = deepClone(DEFAULT_STATE);
  }finally{
    document.getElementById("loadingScreen").style.display = "none";
  }
  try{ tryReconnectFolder(); }catch(e){ /* folder sync is optional */ }
}

init();
</script>
</body>
</html>
