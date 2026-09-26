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
{{PART:gatecss}}
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
<style>
  :root{
    --paper:#F2F5F7;
    --paper-deep:#E7ECF0;
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
    --line:#D8DFE4;
    --card-border:#DBE2E7;
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
    --radius:12px;
    --shadow: 0 1px 2px rgba(11,37,69,.06), 0 4px 14px rgba(11,37,69,.07);
  }
  *{box-sizing:border-box;}
  html,body{margin:0;padding:0;height:100%;}
  body{
    font-family:var(--font-body);
    background:var(--paper);
    color:var(--ink);
    min-height:100vh;
  }
  ::selection{ background:var(--brass); color:#fff; }

  /* ---------- Top bar ---------- */
  /* نوار بالا یک تختهٔ سرمه‌ایِ پررنگ بود و از تمامِ صفحه سنگین‌تر می‌زد؛
     چشم اول می‌رفت سراغِ نوار، نه سراغِ کار. حالا مثل پنل مدیر کاغذیِ
     مات است: یک خط نازک زیرش، متنِ جوهری، و رنگِ برند فقط جایی که باید
     دیده شود. */
  .topbar{
    height:68px;
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
  .brand h1{ font-family:var(--font-display); font-size:18px; margin:0; font-weight:700; color:var(--ink); }
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
{{PART:tablecss}}
{{PART:cellpopcss}}
  .mpop-note{ font-size:11.5px; color:var(--red-ink,#A6222B); line-height:1.9; min-height:19px; }
  .period label{ font-size:12px; color:var(--ink-faint); }

  /* ---------- ساعتِ نوارِ بالا ---------- */
  /* همان نوارِ ساعتِ کارتابلِ فنی، مو‌به‌مو: تاریخ کنارِ ساعت، هر دو
     کنارِ دکمهٔ ماه. پیش از این این قالب قرصِ ساعتِ خودش را داشت که
     تاریخ نداشت و جای دیگری از نوار می‌نشست. */
  .topbar-clock{
    font-family:var(--font-display); font-size:13.5px; font-weight:700; color:var(--brass-ink);
    background:var(--brass-bg); border:1px solid transparent;
    border-radius:20px; padding:7px 4px; letter-spacing:1px; margin-inline-end:6px;
    display:inline-block; width:104px; box-sizing:border-box; text-align:center;
    font-variant-numeric:tabular-nums; white-space:nowrap;
  }
  .period select{
    font-family:var(--font-body); font-size:13px;
    background:var(--white); border:1px solid var(--card-border);
    color:var(--ink); border-radius:9px; padding:7px 10px; min-width:120px; text-align:center;
  }
  .period select option{ color:var(--ink); }


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
  /* قابِ جدول به اندازهٔ خودِ جدول جمع می‌شود، نه تمامِ عرضِ کارت. */
  .tbl-wrap.tsz-hug{ width:max-content; max-width:100%; }
  /* جدولی که موتورِ پهنا رویش سوار است: خانه‌ها از ستونِ خودشان
     بیرون نمی‌زنند، و کادرِ داخلِ خانه تا لبهٔ ستون پُر می‌شود — وگرنه
     کشویی‌ای به پهنای پنجاه پیکسل وسطِ ستونی سیصد پیکسلی شناور
     می‌ماند و ستون «گشاد» به نظر می‌رسد. */
  .tsz-on th, .tsz-on td{ overflow:hidden; }
  .tsz-on tbody td > input, .tsz-on tbody td > select,
  .tsz-on tbody td > textarea{ width:100%; max-width:100%; box-sizing:border-box; }
  @media print{ .tsz-bar, .tsz-grip{ display:none !important; } }

  /* ---------- Shell ---------- */
  .shell{ display:flex; align-items:flex-start; min-height:calc(100vh - 68px); }
  .sidebar{
    width:230px; flex:none; background:var(--white); border-left:1px solid var(--card-border);
    height:calc(100vh - 68px); padding:18px 12px; position:sticky; top:68px;
    display:flex; flex-direction:column; overflow:hidden;
  }
  /* چهارده بخش با نام‌های بلند از ارتفاع صفحه می‌زد بیرون. حالا فهرست
     خودش اسکرول می‌شود و دکمه‌های پشتیبان و بازیابی و خروج همیشه
     دمِ دست می‌مانند. */
  .nav-list{
    flex:1 1 auto; min-height:0; overflow-y:auto;
    display:flex; flex-direction:column;
  }
  .nav-label{ font-size:11px; color:var(--ink-faint); font-weight:700; padding:0 8px 8px; }
  .navbtn{
    display:flex; align-items:center; gap:10px; width:100%; text-align:right;
    background:none; border:none; padding:10px 10px; border-radius:9px; cursor:pointer;
    font-family:var(--font-body); font-size:13px; color:var(--ink-soft); margin-bottom:2px;
    transition:background .12s, color .12s;
  }
  /* آیکن‌ها بدون قاب‌اند و فقط پررنگی‌شان عوض می‌شود — همان کاری که
     کارتابل فنی هم می‌کند، تا دو کارتابل یک‌شکل بمانند. */
  .navbtn .ic{ font-size:16px; width:22px; text-align:center;
    opacity:.62; transition:opacity .15s; }
  .navbtn:hover .ic{ opacity:.9; }
  .navbtn.active .ic{ opacity:1; }
  .navbtn:hover{ background:var(--paper-deep); }
  .navbtn.active{ background:var(--brass-bg); color:var(--brass-ink); font-weight:700;
    position:relative; }
  /* همان نوارِ باریکِ لبهٔ راست که کارتابل فنی دارد. */
  .navbtn.active::before{
    content:""; position:absolute; inset-inline-start:0; top:50%; transform:translateY(-50%);
    width:3px; height:20px; border-radius:0 3px 3px 0; background:var(--brass);
  }
  .navbtn-lock.active{ background:var(--purple-bg); color:var(--purple-ink); }
  .navbtn-lock.active::before{ background:var(--purple); }

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
{{PART:vaultcss}}
  .sidebar-foot{
    flex:0 0 auto; margin-top:12px; padding-top:14px;
    border-top:1px solid var(--line); font-size:11px; color:var(--ink-faint); line-height:1.7;
    display:flex; flex-direction:column; gap:7px;
  }
  .sidebar-foot .save-hint{ min-height:15px; }
  .foot-actions{ display:flex; gap:6px; }
  .sidebar-foot .btn{ padding:7px 6px; font-size:11px; }
  .foot-actions .btn{ flex:1; }
  .foot-lock{ width:100%; }

  .content{ flex:1; min-width:0; padding:26px 32px; }
  .view{ display:none; }
  .view.active{ display:block; animation:fade .25s ease; }
  @keyframes fade{ from{opacity:0; transform:translateY(4px);} to{opacity:1; transform:none;} }

  .section-title{
    font-family:var(--font-display); font-size:20px; font-weight:600; color:var(--ink);
    margin:2px 0 4px; position:relative; padding-right:14px;
  }
  .section-title::before{
    content:""; position:absolute; right:0; top:3px; bottom:3px; width:4px; border-radius:3px;
    background:linear-gradient(180deg,var(--brass),var(--brass-deep));
  }
  .section-sub{ color:var(--ink-faint); font-size:12.5px; margin-bottom:18px; }

  /* ---------- Stat cards ---------- */
  .cards{
    display:grid; grid-template-columns:repeat(auto-fit, minmax(186px,1fr)); gap:12px; margin-bottom:22px;
  }
  /* کارت‌ها قبلاً بلوک‌های تمام‌رنگِ اشباع بودند با یک ایموجی بزرگِ کم‌رنگ
     پشتشان. رنگِ پُر در سطح بزرگ، عدد را کم‌جان می‌کند و صفحه را شلوغ.
     حالا زمینه سفید است و رنگ فقط در دو جای کوچک می‌نشیند: نوار کناری و
     قاب آیکن. عدد — که حرف اصلی کارت است — پررنگ‌ترین چیز کارت شد. */
  .stat{
    background:var(--white); border:1px solid var(--card-border); border-radius:var(--radius);
    padding:14px 16px 13px; position:relative; overflow:hidden; box-shadow:var(--shadow);
    transition:transform .18s, box-shadow .18s;
    animation:statIn .4s ease backwards;
  }
  .stat::before{
    content:""; position:absolute; inset-inline-start:0; top:0; bottom:0;
    width:3px; background:var(--accent, var(--brass));
  }
  .stat:nth-child(1){ animation-delay:.02s; }
  .stat:nth-child(2){ animation-delay:.07s; }
  .stat:nth-child(3){ animation-delay:.12s; }
  .stat:nth-child(4){ animation-delay:.17s; }
  .stat:nth-child(5){ animation-delay:.22s; }
  .stat:nth-child(6){ animation-delay:.27s; }
  @keyframes statIn{ from{opacity:0; transform:translateY(8px);} to{opacity:1; transform:none;} }
  .stat:hover{ transform:translateY(-2px); box-shadow:0 6px 18px rgba(11,37,69,.13); }

  .stat-head{ display:flex; align-items:center; gap:8px; }
  .stat-ic{
    width:27px; height:27px; flex:none; border-radius:8px;
    display:grid; place-items:center; font-size:14px; line-height:1;
    background:var(--tint, var(--brass-bg));
  }
  .stat-lbl{ font-size:11.5px; font-weight:600; color:var(--ink-soft); line-height:1.45; }
  /* عددِ بزرگ با ارقام متناسب، نه tabular — در اندازهٔ درشت، ارقامِ
     هم‌عرض عدد را شل و بازنشان می‌دهند. */
  .stat-val{
    font-family:var(--font-display); font-size:25px; font-weight:700; color:var(--ink);
    margin-top:11px; line-height:1.15; letter-spacing:-.2px; word-break:break-word;
  }
  .stat-sub{ font-size:11px; color:var(--ink-faint); margin-top:3px; font-weight:500; }

  /* کارت‌های «معوق» وضعیت‌اند، نه اندازه: وقتی صفر است خبرِ خوب است و
     نباید قرمز باشد. رنگ به‌تنهایی هم حرف نمی‌زند — آیکن و متن هم هست. */
  .stat.is-clear{ --accent:var(--c4); --tint:var(--t4); }
  .stat.is-alert{ --accent:var(--bad); --tint:var(--bad-bg); }
  .stat.is-alert .stat-val{ color:var(--bad-ink); }

  /* کارتِ خوش‌آمد یک تختهٔ سرمه‌ایِ تمام‌عرض بود و بالای کارت‌های سفیدِ
     پایین‌تر مثل بنرِ تبلیغ می‌نشست. حالا خودش هم کارت است: کاغذِ روشن،
     یک نوارِ باریکِ رنگِ برند لبهٔ شروع، و ساعت و تاریخ دو چیپِ آرام. */
  .dash-hero{
    background:var(--white); color:var(--ink);
    border:1px solid var(--card-border);
    border-radius:14px; padding:18px 22px; margin-bottom:18px;
    display:flex; align-items:center; justify-content:space-between; gap:14px; flex-wrap:wrap;
    box-shadow:var(--shadow); position:relative; overflow:hidden;
  }
  .dash-hero::after{
    content:""; position:absolute; inset-block:0; inset-inline-start:0;
    width:3px; background:var(--brass); pointer-events:none;
  }
  .dash-hero .dh-greet{ font-family:var(--font-display); font-size:16px; font-weight:700; color:var(--ink); position:relative; z-index:1; }
  .dash-hero .dh-sub{ font-size:11.5px; color:var(--ink-soft); margin-top:4px; position:relative; z-index:1; }

  /* همان دو چیپِ کارتابلِ فنی، مو‌به‌مو: تاریخ روی کاغذ، ساعت روی رنگِ
     برند، هر دو هم‌عرض تا با عوض شدنِ ثانیه چیزی جابه‌جا نشود. */
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
  .dash-group-label.g-green{ --dgl-bg:var(--green-bg); }
  .dash-group-label.g-amber{ --dgl-bg:var(--amber-bg); }
  .dash-group-label.g-teal { --dgl-bg:var(--teal-bg); }

  /* هر گروه از کارت‌های داشبورد یک نوارِ رنگیِ سه‌پیکسلی بالایش داشت؛
     کنارِ هم نامنظم به نظر می‌رسید و رنگ چیزی نمی‌گفت که عنوانِ گروه
     نگفته باشد. حالا همهٔ کارت‌ها یک‌شکل‌اند. کلاس‌ها مانده‌اند چون
     جاوااسکریپت و آزمون‌ها با همین‌ها کارت‌ها را پیدا می‌کنند. */
  .panel.accent-blue, .panel.accent-amber, .panel.accent-teal,
  .panel.accent-green, .panel.accent-red{ border-top:1px solid var(--card-border); }

  /* ---------- Panels / grids ---------- */
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
    background:var(--white); border:1px solid var(--card-border); border-radius:12px;
    box-shadow:0 1px 3px rgba(11,37,69,.05); padding:18px 20px; transition:box-shadow .18s;
  }
  .panel:hover{ box-shadow:0 6px 16px rgba(11,37,69,.08); }
  .panel h3{
    font-family:var(--font-display); font-size:14.5px; margin:0 0 14px; color:var(--ink);
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

  .tbl-wrap{ overflow-x:auto; border-radius:10px; }
  /* ---------- Tables ---------- */
  table{ width:100%; border-collapse:collapse; font-size:12px; }
  /* سربرگِ جدول یک تختهٔ سرمه‌ای بود؛ حالا که نوار بالا روشن شده، همین
     تخته سنگین‌ترین چیزِ صفحه می‌شد. کاغذی‌اش می‌کنیم — خطِ پررنگِ زیرش
     همان کاری را می‌کند که رنگ می‌کرد. */
  thead th{
    background:var(--paper-deep); color:var(--ink-soft); font-weight:700; padding:9px 6px; text-align:center;
    position:sticky; top:0; font-size:11.5px;
    border-bottom:2px solid var(--card-border);
  }
  tbody td{ padding:5px 6px; border-bottom:1px solid var(--line); text-align:center; vertical-align:middle; font-size:12px; }
  tbody tr:nth-child(even){ background:var(--paper); }
  tbody tr:hover{ background:var(--brass-bg); }
  .filter-row th{ background:var(--paper-deep); padding:4px 5px; position:sticky; top:32px; }
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

  /* ---------- toggle switches ---------- */
  .edit-toggle-wrap{ display:inline-flex; align-items:center; gap:5px; font-size:10.5px; color:var(--ink-soft); user-select:none; white-space:nowrap; }
  .edit-switch{ position:relative; display:inline-block; width:28px; height:16px; flex:none; }
  .edit-switch input{ opacity:0; width:0; height:0; }
  .edit-switch .track{ position:absolute; inset:0; background:var(--line); border-radius:999px; transition:.18s; cursor:pointer; }
  .edit-switch .track::before{ content:""; position:absolute; width:12px; height:12px; left:2px; top:2px; background:var(--white); border-radius:50%; transition:.18s; box-shadow:0 1px 2px rgba(0,0,0,.3); }
  .edit-switch input:checked + .track{ background:var(--red); }
  .edit-switch input:checked + .track::before{ transform:translateX(-12px); }

  .btn{ font-family:var(--font-body); cursor:pointer; border:none; border-radius:8px; padding:9px 16px; font-size:13px; font-weight:600; transition:.15s; }
  .btn-brass{ background:var(--brass); color:#fff; }
  .btn-brass:hover{ background:var(--brass-deep); }
  .btn-ghost{ background:var(--paper-deep); color:var(--ink-soft); }
  .btn-ghost:hover{ background:var(--line); }
  .btn-sm{ padding:5px 12px !important; font-size:12px !important; }
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
  .star-btn{
    background:transparent; border:none; cursor:pointer; font-size:16px; padding:4px 6px;
    border-radius:6px; transition:transform .12s, background .12s; color:var(--ink-faint);
  }
  .star-btn:hover{ background:var(--amber-bg); transform:scale(1.15); }
  .star-btn.active{ color:#C98A2C; }
  .rm-field-row{ display:flex; gap:8px; margin-bottom:12px; }
  .rm-field-row input{
    flex:1; min-width:0; box-sizing:border-box; font-family:inherit; font-size:13px;
    padding:8px; border:1px solid var(--card-border); border-radius:7px; text-align:center;
  }
  .rm-time-input{ width:100%; box-sizing:border-box; font-family:inherit; font-size:13px; padding:8px; border:1px solid var(--card-border); border-radius:7px; margin-bottom:14px; }
  .rm-task-label{ font-size:12.5px; color:var(--ink-soft); margin-bottom:12px; }
  .rm-actions{ display:flex; gap:8px; }
  .rm-actions .btn{ flex:1; }
  .reminder-pop-title{ font-size:15px; font-weight:700; color:var(--ink); margin-bottom:8px; }
  .reminder-pop-meta{ font-size:12px; color:var(--ink-faint); margin-top:4px; }

  .toolbar{ display:flex; align-items:center; gap:10px; margin-bottom:16px; flex-wrap:wrap; }
  .save-hint{ color:var(--ink-faint); }

  .badge{ display:inline-block; padding:2px 10px; border-radius:999px; font-size:11px; font-weight:700; }
  .badge.done{ background:var(--green-bg); color:var(--green-ink); }
  .badge.doing{ background:var(--teal-bg); color:var(--teal-ink); }
  .badge.todo{ background:var(--red-bg); color:var(--red-ink); }

  .editable-cell{ cursor:text; }
  .editable-cell[data-field="enteredBy"]:not(:empty){
    font-size:11px; color:var(--brass-ink); font-weight:600;
  }
  .add-row input, .add-row select{ background:var(--paper); border:1px solid var(--line); border-radius:6px; padding:5px 7px; font-size:12px; font-family:inherit; }
  .add-row input:focus, .add-row select:focus{ outline:2px solid var(--brass); }
  .visit-add-bar{ display:flex; align-items:center; gap:8px; margin-top:10px; padding:8px 10px; background:var(--paper); border:1px solid var(--line); border-radius:8px; flex-wrap:wrap; }
  .visit-add-bar input, .visit-add-bar select{ background:var(--white); border:1px solid var(--line); border-radius:6px; padding:6px 8px; font-size:12.5px; font-family:inherit; }
  .visit-add-bar input:focus, .visit-add-bar select:focus{ outline:none; border-color:var(--brass); }
  .editable-text input{ width:100%; box-sizing:border-box; border:1px solid transparent; background:transparent; font-family:inherit; font-size:12px; padding:4px 5px; border-radius:5px; }
  .editable-text input:hover{ border-color:var(--card-border); }
  .editable-text input:focus{ outline:none; border-color:var(--brass); background:var(--white); }
  .daily-plan-table td, .daily-plan-table th{ padding-left:10px; padding-right:10px; }
  .daily-plan-table td:nth-child(5), .daily-plan-table th:nth-child(5){ border-right:1px solid var(--line); padding-right:14px; }
  .daily-plan-table td:nth-child(6), .daily-plan-table th:nth-child(6){ padding-right:14px; padding-left:14px; }
  .daily-plan-table td.editable-text input, .daily-plan-table td select{ width:100%; box-sizing:border-box; }
  .daily-date-cell{ color:var(--ink-faint); font-size:11.5px; white-space:nowrap; text-align:center; }

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

  .guide-item{ display:flex; gap:14px; padding:14px 0; border-bottom:1px solid var(--paper-deep); }
  .guide-item:last-child{ border-bottom:none; }
  .guide-item .ic{ font-size:22px; width:34px; text-align:center; flex:none; }
  .guide-item h4{ margin:0 0 4px; font-family:var(--font-display); font-size:13.5px; }
  .guide-item p{ margin:0; font-size:12.5px; color:var(--ink-soft); line-height:1.8; }

  .loading{ position:fixed; inset:0; background:var(--paper); z-index:999; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:14px; }
  .spin{ width:40px; height:40px; border:4px solid var(--card-border); border-top-color:var(--brass); border-radius:50%; animation:spin 1s linear infinite; }
  @keyframes spin{ to{ transform:rotate(360deg); } }

  .appfoot{ text-align:center; color:var(--ink-faint); font-size:11.5px; padding:20px 0 10px; }

{{PART:mobilecss}}

  /* شش کارتِ داشبورد با auto-fit به ۵+۱ می‌شکست و یک ردیفِ تک‌کارته با
     جای خالی کنارش می‌ماند. تعداد ستون را صریح می‌گذاریم تا همیشه
     ردیف‌های پر باشد: ۶ روی نمایشگر پهن، ۳ روی متوسط، ۲ روی گوشی. */
  #statCards{ grid-template-columns:repeat(2,1fr); }
  @media (min-width:640px){ #statCards{ grid-template-columns:repeat(3,1fr); } }
  @media (min-width:1380px){ #statCards{ grid-template-columns:repeat(6,1fr); } }
{{PART:navcss}}
  .theme-btn:hover{ border-color:var(--brass); background:var(--brass-bg); }
  .theme-btn:active{ transform:scale(.94); }
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
      <small>مطالبات، بدهی‌ها، هزینه‌ها و نقدینگی</small>
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
    <button class="navbtn" data-view="invoices" data-feat="view:invoices"><span class="ic">🧾</span> سررسید اسناد دریافتنی از مشتری</button>
    <button class="navbtn" data-view="payables" data-feat="view:payables"><span class="ic">💳</span> بدهی‌ها و پرداخت‌ها</button>
    <button class="navbtn" data-view="payablenotes" data-feat="view:payablenotes"><span class="ic">📄</span> اسناد پرداختنی نزد دیگران</button>
    <button class="navbtn" data-view="receivablenotes" data-feat="view:receivablenotes"><span class="ic">📃</span> اسناد دریافتنی به نفع شرکت</button>
    <button class="navbtn" data-view="expenses" data-feat="view:expenses"><span class="ic">🧮</span> منابع و مصارف</button>
    <button class="navbtn" data-view="bank" data-feat="view:bank"><span class="ic">🏦</span> حساب‌های بانکی</button>
    <button class="navbtn" data-view="budget" data-feat="view:budget"><span class="ic">📐</span> بودجه‌بندی ماهانه</button>
    <button class="navbtn" data-view="parties" data-feat="view:parties"><span class="ic">👥</span> طرف‌حساب‌ها</button>
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
      <div class="section-title">داشبورد مالی</div>
      <div class="section-sub">خلاصه‌ی زنده‌ی وضعیت مالی این ماه</div>

      <div class="dash-hero" id="dashHero"></div>

      <div class="cards" id="statCards"></div>

      <div class="dash-group-label g-blue"><span class="dgl-ic">📋</span> وظایف و برنامه‌ی این ماه</div>
      <div class="grid2">
        <div class="panel accent-green">
          <h3>🥧 وضعیت وظایف چک‌لیست ماهانه</h3>
          <div class="chart-box"><canvas id="chartChecklistStatus"></canvas></div>
        </div>
        <div class="panel accent-green">
          <h3>🗓️ وضعیت برنامه روزانه</h3>
          <div class="chart-box"><canvas id="chartDailyStatus"></canvas></div>
        </div>
      </div>

      <div class="dash-group-label g-blue"><span class="dgl-ic">🧾</span> سررسید اسناد پرداختنی و دریافتنی شرکت</div>
      <div class="grid2">
        <div class="panel accent-blue">
          <h3>🥧 وضعیت فاکتورها (مطالبات از مشتری)</h3>
          <div class="chart-box"><canvas id="chartInvoiceStatus"></canvas></div>
        </div>
        <div class="panel accent-blue">
          <h3>🥧 وضعیت بدهی به تامین‌کنندگان</h3>
          <div class="chart-box"><canvas id="chartPayableStatus"></canvas></div>
        </div>
      </div>

      <div class="dash-group-label g-amber"><span class="dgl-ic">🧮</span> هزینه‌ها و بودجه</div>
      <div class="grid2">
        <div class="panel accent-amber">
          <h3>📊 هزینه‌ها بر اساس دسته‌بندی</h3>
          <div class="chart-box"><canvas id="chartExpenseCategory"></canvas></div>
        </div>
        <div class="panel accent-amber">
          <h3>📐 بودجه در مقابل هزینه‌ی واقعی</h3>
          <div class="chart-box"><canvas id="chartBudgetVsActual"></canvas></div>
        </div>
      </div>

      <div class="dash-group-label g-teal"><span class="dgl-ic">🏦</span> نقدینگی و طرف‌حساب‌ها</div>
      <div class="grid2">
        <div class="panel accent-teal">
          <h3>🏦 موجودی حساب‌های بانکی</h3>
          <div class="chart-box"><canvas id="chartBankBalances"></canvas></div>
        </div>
        <div class="panel accent-teal">
          <h3>👥 بیشترین مطالبات باز به تفکیک مشتری</h3>
          <div class="chart-box"><canvas id="chartTopDebtors"></canvas></div>
        </div>
      </div>
    </section>

    <!-- CHECKLIST -->
    <section class="view" id="view-checklist">
      <div class="section-title">چک‌لیست وظایف ماهانه</div>
      <div class="section-sub">وظایف تکرارشونده‌ی این کارتابل — هر ردیف را ویرایش کنید یا وظیفه‌ی جدید اضافه کنید</div>
      <div class="toolbar">
        <button class="btn btn-brass" id="addTaskBtn">＋ افزودن وظیفه</button>
        <button class="btn btn-ghost" id="resetTasksBtn">بازنشانی چک‌لیست</button>
      </div>
      <div class="tbl-wrap">
        <table>
          <thead><tr>
            <th style="width:26px;">#</th><th>دسته‌بندی</th><th>وظیفه</th><th>مسئول</th>
            <th style="width:80px;">مهلت (روز)</th><th style="width:110px;">وضعیت</th><th style="width:90px;">اولویت</th>
            <th>یادداشت</th><th style="width:36px;" title="یادآور">⏰</th><th style="width:30px;"></th>
          </tr></thead>
          <tbody id="checklistBody"></tbody>
        </table>
      </div>
      <datalist id="taskCategoryOptions"></datalist>
    </section>

    <!-- DAILY -->
    <section class="view" id="view-daily">
      <div class="section-title">برنامه روزانه ماه</div>
      <div class="section-sub">وظایف اصلی، طرف‌حساب مرتبط و وضعیت هر روز</div>
      <div class="tbl-wrap">
        <table class="daily-plan-table">
          <thead>
          <tr><th style="width:44px;">ردیف</th><th style="width:100px;">📅 تاریخ</th><th>📌 وظایف اصلی</th><th>🤝 توضیحات</th><th style="width:150px;">👥 طرف‌حساب</th><th style="width:130px;">وضعیت</th><th style="width:36px;" title="یادآور">⏰</th><th style="width:40px;"></th></tr>
          <tr class="filter-row">
            <th></th><th></th><th></th><th></th>
            <th><div class="msf" id="msfDailyParty" data-key="company"></div></th>
            <th><div class="msf" id="msfDailyStatus" data-key="status"></div></th>
            <th></th><th></th>
          </tr>
          </thead>
          <tbody id="dailyBody"></tbody>
        </table>
      </div>
      <div class="visit-add-bar" style="margin-top:10px;">
        <button class="btn btn-brass btn-sm" id="addDayRowBtn">＋ افزودن ردیف/وظیفه</button>
      </div>
      <datalist id="dailyPartyOptions"></datalist>
    </section>

    <!-- INVOICES -->
    <section class="view" id="view-invoices" data-feat="view:invoices">
      <div class="section-title">سررسید اسناد دریافتنی از مشتری</div>
      <div class="section-sub">فهرست فاکتورهای صادرشده و وضعیت وصول مطالبات</div>
      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshInvoicesBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="invoicesSyncStatus"></span>
      </div>
      <div class="cards" id="invoiceCards"></div>
      <div class="panel">
        <h3>🧾 فهرست فاکتورها</h3>
        <div class="tbl-wrap">
          <table>
            <thead>
            <tr>
              <th style="width:26px;">#</th><th>شماره فاکتور</th><th>مشتری</th><th style="width:100px;">تاریخ</th>
              <th style="width:100px;">سررسید</th><th style="width:100px;">مبلغ کل</th><th style="width:100px;">پرداخت‌شده</th>
              <th style="width:100px;">وضعیت</th>
              <th style="width:110px;">واردکننده</th>
              <th style="width:70px;">
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
                  <span class="edit-switch"><input type="checkbox" id="editToggleInvoices"><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr>
            <tr class="filter-row">
              <th></th>
              <th><input type="text" class="invoice-filter" data-key="invoiceNo" placeholder="جستجو..."></th>
              <th><input type="text" class="invoice-filter" data-key="customer" placeholder="جستجو..."></th>
              <th></th><th></th><th></th><th></th>
              <th><div class="msf" id="msfInvoiceStatus" data-key="status"></div></th>
              <th></th><th></th>
            </tr>
            </thead>
            <tbody id="invoicesBody"></tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- PAYABLES -->
    <section class="view" id="view-payables" data-feat="view:payables">
      <div class="section-title">بدهی و پرداخت</div>
      <div class="section-sub">فهرست بدهی‌ها به تامین‌کنندگان به تفکیک پروژه</div>
      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshPayablesBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="payablesSyncStatus"></span>
      </div>
      <div class="cards" id="payableCards"></div>
      <div class="panel">
        <h3>💳 فهرست بدهی و پرداخت</h3>
        <div class="tbl-wrap">
          <table>
            <thead>
            <tr>
              <th style="width:26px;">#</th><th>ذینفع/تامین‌کننده</th><th style="width:130px;">پروژه</th>
              <th style="width:110px;">تاریخ سررسید</th><th>موضوع</th><th style="width:120px;">مبلغ</th>
              <th style="width:110px;">واردکننده</th>
              <th style="width:70px;">
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
                  <span class="edit-switch"><input type="checkbox" id="editTogglePayables"><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr>
            <tr class="filter-row">
              <th></th>
              <th><input type="text" class="payable-filter" data-key="beneficiary" placeholder="جستجو..."></th>
              <th><input type="text" class="payable-filter" data-key="project" placeholder="جستجو..."></th>
              <th></th>
              <th><input type="text" class="payable-filter" data-key="subject" placeholder="جستجو..."></th>
              <th></th><th></th><th></th>
            </tr>
            </thead>
            <tbody id="payablesBody"></tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- PAYABLE NOTES (چک‌های پرداختنی نزد دیگران) -->
    <section class="view" id="view-payablenotes" data-feat="view:payablenotes">
      <div class="section-title">اسناد پرداختنی نزد دیگران</div>
      <div class="section-sub">چک‌ها و اسنادی که شرکت به دیگران بدهکار است</div>
      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshPayableNotesBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="payableNotesSyncStatus"></span>
      </div>
      <div class="cards" id="payableNotesCards"></div>
      <div class="panel">
        <h3>📄 فهرست اسناد پرداختنی</h3>
        <div class="tbl-wrap">
          <table>
            <thead>
            <tr>
              <th style="width:26px;">#</th><th style="width:120px;">شماره چک</th><th style="width:120px;">تاریخ سررسید چک</th>
              <th style="width:120px;">مبلغ</th><th>ذینفع</th><th>موضوع</th>
              <th style="width:110px;">واردکننده</th>
              <th style="width:70px;">
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
                  <span class="edit-switch"><input type="checkbox" id="editTogglePayableNotes"><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr>
            <tr class="filter-row">
              <th></th><th></th><th></th><th></th>
              <th><input type="text" class="payablenote-filter" data-key="beneficiary" placeholder="جستجو..."></th>
              <th><input type="text" class="payablenote-filter" data-key="subject" placeholder="جستجو..."></th>
              <th></th><th></th>
            </tr>
            </thead>
            <tbody id="payableNotesBody"></tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- RECEIVABLE NOTES (چک‌های دریافتنی به نفع شرکت) -->
    <section class="view" id="view-receivablenotes" data-feat="view:receivablenotes">
      <div class="section-title">اسناد دریافتنی به نفع شرکت</div>
      <div class="section-sub">چک‌ها و اسنادی که دیگران به شرکت بدهکارند</div>
      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshReceivableNotesBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="receivableNotesSyncStatus"></span>
      </div>
      <div class="cards" id="receivableNotesCards"></div>
      <div class="panel">
        <h3>📃 فهرست اسناد دریافتنی</h3>
        <div class="tbl-wrap">
          <table>
            <thead>
            <tr>
              <th style="width:26px;">#</th><th style="width:120px;">شماره چک</th><th style="width:120px;">تاریخ سررسید چک</th>
              <th style="width:120px;">مبلغ</th><th>خریدار</th><th>موضوع</th>
              <th style="width:110px;">واردکننده</th>
              <th style="width:70px;">
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
                  <span class="edit-switch"><input type="checkbox" id="editToggleReceivableNotes"><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr>
            <tr class="filter-row">
              <th></th><th></th><th></th><th></th>
              <th><input type="text" class="receivablenote-filter" data-key="buyer" placeholder="جستجو..."></th>
              <th><input type="text" class="receivablenote-filter" data-key="subject" placeholder="جستجو..."></th>
              <th></th><th></th>
            </tr>
            </thead>
            <tbody id="receivableNotesBody"></tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- EXPENSES -->
    <section class="view" id="view-expenses" data-feat="view:expenses">
      <div class="section-title">منابع و مصارف</div>
      <div class="section-sub">ثبت منابع (دریافت‌ها و ورودی‌های نقدی) و مصارف (هزینه‌ها و خروجی‌های نقدی)</div>
      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshExpensesBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="expensesSyncStatus"></span>
      </div>
      <div class="cards" id="expenseCards"></div>
      <div class="panel">
        <h3>🧮 فهرست منابع و مصارف</h3>
        <div class="tbl-wrap">
          <table>
            <thead>
            <tr>
              <th style="width:26px;">#</th><th style="width:100px;">تاریخ</th><th style="width:90px;">نوع</th><th style="width:150px;">دسته‌بندی</th>
              <th>شرح</th><th style="width:110px;">مبلغ</th><th style="width:130px;">روش پرداخت</th>
              <th style="width:110px;">واردکننده</th>
              <th style="width:70px;">
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
                  <span class="edit-switch"><input type="checkbox" id="editToggleExpenses"><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr>
            <tr class="filter-row">
              <th></th><th></th>
              <th><div class="msf" id="msfExpenseType" data-key="type"></div></th>
              <th><div class="msf" id="msfExpenseCategory" data-key="category"></div></th>
              <th><input type="text" class="expense-filter" data-key="description" placeholder="جستجو..."></th>
              <th></th>
              <th><div class="msf" id="msfExpensePayment" data-key="paymentMethod"></div></th>
              <th></th><th></th>
            </tr>
            </thead>
            <tbody id="expensesBody"></tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- BANK ACCOUNTS -->
    <section class="view" id="view-bank" data-feat="view:bank">
      <div class="section-title">حساب‌های بانکی و نقدینگی</div>
      <div class="section-sub">فهرست حساب‌ها و موجودی هرکدام</div>
      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshBankBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="bankSyncStatus"></span>
      </div>
      <div class="cards" id="bankCards"></div>
      <div class="panel">
        <h3>🏦 فهرست حساب‌ها</h3>
        <div class="tbl-wrap">
          <table>
            <thead>
            <tr>
              <th style="width:26px;">#</th><th>نام حساب</th><th>بانک</th><th>شماره حساب</th>
              <th style="width:130px;">موجودی</th><th>یادداشت</th>
              <th style="width:110px;">واردکننده</th>
              <th style="width:70px;">
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
                  <span class="edit-switch"><input type="checkbox" id="editToggleBank"><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr>
            </thead>
            <tbody id="bankBody"></tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- BUDGET -->
    <section class="view" id="view-budget" data-feat="view:budget">
      <div class="section-title">بودجه‌بندی ماهانه</div>
      <div class="section-sub">مقایسه‌ی بودجه‌ی مصوب با هزینه‌ی واقعی هر دسته</div>
      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshBudgetBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="budgetSyncStatus"></span>
      </div>
      <div class="panel">
        <h3>📐 فهرست بودجه</h3>
        <div class="tbl-wrap">
          <table>
            <thead>
            <tr>
              <th style="width:26px;">#</th><th style="width:130px;">دوره</th><th>دسته‌بندی</th>
              <th style="width:120px;">بودجه</th><th style="width:120px;">هزینه‌ی واقعی</th><th style="width:100px;">انحراف</th>
              <th style="width:110px;">واردکننده</th>
              <th style="width:70px;">
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
                  <span class="edit-switch"><input type="checkbox" id="editToggleBudget"><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr>
            </thead>
            <tbody id="budgetBody"></tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- PARTIES -->
    <section class="view" id="view-parties" data-feat="view:parties">
      <div class="section-title">طرف‌حساب‌ها</div>
      <div class="section-sub">فهرست مشتریان و تامین‌کنندگان</div>
      <div class="toolbar" data-feat="xlsx">
        <button class="btn btn-brass" id="refreshPartiesBtn">⬆ خواندن از فایل اکسل</button>
        <span class="save-hint" id="partiesSyncStatus"></span>
      </div>
      <div class="panel">
        <h3>👥 فهرست طرف‌حساب‌ها</h3>
        <div class="tbl-wrap">
          <table>
            <thead>
            <tr>
              <th style="width:26px;">#</th><th>نام</th><th style="width:110px;">نوع</th>
              <th style="width:130px;">تلفن</th><th>مسئول تماس</th><th>یادداشت</th>
              <th style="width:110px;">واردکننده</th>
              <th style="width:70px;">
                <label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">
                  <span class="edit-switch"><input type="checkbox" id="editToggleParties"><span class="track"></span></span>
                  حذف/تغییر
                </label>
              </th>
            </tr>
            <tr class="filter-row">
              <th></th>
              <th><input type="text" class="party-filter" data-key="name" placeholder="جستجو..."></th>
              <th><div class="msf" id="msfPartyType" data-key="type"></div></th>
              <th></th><th></th><th></th><th></th><th></th>
            </tr>
            </thead>
            <tbody id="partiesBody"></tbody>
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

{{PART:settings}}
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
      <div class="section-sub">این کارتابل دستیار دیجیتال روزانه‌ی شماست</div>
      <div class="panel">
        <div class="guide-item">
          <div class="ic">📊</div>
          <div><h4>داشبورد</h4><p>خلاصه‌ی وضعیت مالی این ماه را با کارت و نمودار نشان می‌دهد — به‌طور خودکار از داده‌های بخش‌های دیگر محاسبه می‌شود.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">✅</div>
          <div><h4>چک‌لیست ماهانه</h4><p>وظایف تکرارشونده‌ی این کارتابل برای این ماه. هر ماه جدید که می‌سازید، این چک‌لیست خالی شروع می‌شود.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">🗓️</div>
          <div><h4>برنامه روزانه</h4><p>وظایف و طرف‌حساب‌های مرتبط با هر روز را ثبت کنید. با ساختن ماه جدید، فقط ردیف‌های «در حال انجام» یا «انجام نشده» به ماه جدید منتقل می‌شوند؛ ردیف‌های «انجام شد» در همان ماه می‌مانند.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">🗂️</div>
          <div><h4>ماه‌ها</h4><p>از منوی «ماه» بالای صفحه بین ماه‌های قبلی جابه‌جا شوید، یا با دکمه‌ی «＋ ماه جدید» یک ماه تازه بسازید. فاکتورها، بدهی‌ها، هزینه‌ها، حساب‌های بانکی، بودجه و طرف‌حساب‌ها مستقل از ماه هستند و در همه‌ی ماه‌ها یکسان می‌مانند.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">🧾</div>
          <div><h4>فاکتورها و مطالبات</h4><p>فاکتورهای صادرشده برای مشتریان را ثبت کنید. مبلغ کل، مبلغ پرداخت‌شده و وضعیت وصول هر فاکتور را وارد کنید.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">💳</div>
          <div><h4>بدهی‌ها و پرداخت‌ها</h4><p>صورت‌حساب‌های دریافتی از تامین‌کنندگان را ثبت و وضعیت پرداخت را دنبال کنید.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">🧮</div>
          <div><h4>هزینه‌های جاری</h4><p>هزینه‌های روزمره‌ی شرکت را با تاریخ، دسته‌بندی و روش پرداخت ثبت کنید.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">🏦</div>
          <div><h4>حساب‌های بانکی و نقدینگی</h4><p>حساب‌های بانکی و موجودی نقدی شرکت را مدیریت کنید — جمع کل نقدینگی در داشبورد نمایش داده می‌شود.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">📐</div>
          <div><h4>بودجه‌بندی ماهانه</h4><p>برای هر دسته‌ی هزینه، بودجه‌ی مصوب و هزینه‌ی واقعی را وارد کنید تا انحراف به‌طور خودکار محاسبه شود.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">👥</div>
          <div><h4>طرف‌حساب‌ها</h4><p>فهرست مشتریان و تامین‌کنندگان را مدیریت کنید تا در فرم‌های فاکتور و بدهی قابل انتخاب باشند.</p></div>
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

<div class="cm-overlay" id="reminderModalOverlay">
  <div class="cm-box" style="max-width:360px;">
    <div class="cm-head">
      <div class="cm-title">⭐ تنظیم یادآوری</div>
      <button class="cm-close" id="reminderModalClose">✕</button>
    </div>
    <div class="cm-body" id="reminderModalBody" style="padding:18px;"></div>
  </div>
</div>

<div class="cm-overlay" id="reminderPopupOverlay">
  <div class="cm-box" style="max-width:380px;">
    <div class="cm-head">
      <div class="cm-title">🔔 یادآوری</div>
      <button class="cm-close" id="reminderPopupClose">✕</button>
    </div>
    <div class="cm-body" id="reminderPopupBody" style="padding:18px;"></div>
  </div>
</div>
{{PART:gatejs}}
<script>
const PARTY_TYPES = ["مشتری","تامین‌کننده"];
const INVOICE_STATUS = ["پرداخت‌شده","جزئی","معوق"];
const PAYMENT_METHODS = ["نقدی","کارت بانکی","چک","انتقال بانکی"];
const EXPENSE_CATEGORIES = ["اجاره","حقوق و دستمزد","قبوض (آب/برق/گاز/تلفن)","نرم‌افزار و لایسنس","تجهیزات و تعمیرات","حمل‌ونقل","بازاریابی و تبلیغات","مالیات و بیمه","متفرقه"];
const SOURCE_USE_TYPES = ["منبع","مصرف"];

/* ---------- Resilient Chart.js loader ---------- */
const CHART_CDN_URLS = [
  /* همان نسخه‌ای که کارتابل IT هم از آن استفاده می‌کند — یک فایل روی
     سرور، نه دو کپی. سیاست امنیتی سایت فقط 'self' و cdnjs را می‌پذیرد،
     پس بقیهٔ میرورها روی این دامنه هرگز بالا نمی‌آیند. */
  "/v/chart.umd.min.js",
  "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.4/chart.umd.min.js"
];
/* فایل ۲۰۰ کیلوبایتی روی اینترنت کند — یا بار اولی که هنوز روی لبهٔ
   کلادفلر کش نشده — راحت از شش ثانیه رد می‌شود. برای فایل خودی مهلت
   بلندتری می‌دهیم. */
{{PART:chartlib}}
/* ---------- Resilient SheetJS (xlsx) loader ---------- */
const XLSX_CDN_URLS = [
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

function toPersianDigits(n){
  const map = {"0":"۰","1":"۱","2":"۲","3":"۳","4":"۴","5":"۵","6":"۶","7":"۷","8":"۸","9":"۹"};
  return String(n).replace(/[0-9]/g, d=>map[d]);
}
const fa = toPersianDigits;
function escapeHtml(s){
  if(s==null) return "";
  return String(s).replace(/[&<>"']/g, c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
}
function formatMoney(n){
  n = Math.round(parseFloat(n)||0);
  const s = Math.abs(n).toLocaleString("en-US");
  return (n<0?"-":"") + fa(s);
}
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

const JALALI_MONTH_NAMES = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور","مهر","آبان","آذر","دی","بهمن","اسفند"];

/* ---------- Jalali <-> Gregorian conversion (for reminder scheduling) ---------- */
function jalaliToGregorian(jy, jm, jd){
  jy = parseInt(jy); jm = parseInt(jm); jd = parseInt(jd);
  jy += 1595;
  let days = -355668 + (365 * jy) + (~~(jy / 33) * 8) + ~~(((jy % 33) + 3) / 4) + jd + ((jm < 7) ? (jm - 1) * 31 : ((jm - 7) * 30) + 186);
  let gy = 400 * ~~(days / 146097);
  days %= 146097;
  if (days > 36524) {
    gy += 100 * ~~(--days / 36524);
    days %= 36524;
    if (days >= 365) days++;
  }
  gy += 4 * ~~(days / 1461);
  days %= 1461;
  if (days > 365) {
    gy += ~~((days - 1) / 365);
    days = (days - 1) % 365;
  }
  let gd = days + 1;
  const sal_a = [0, 31, ((gy % 4 === 0 && gy % 100 !== 0) || (gy % 400 === 0)) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  let gm;
  for (gm = 1; gm <= 12; gm++) {
    const v = sal_a[gm];
    if (gd <= v) break;
    gd -= v;
  }
  return [gy, gm, gd];
}

/* ---------- Live clock: stable width, updates every second, no layout shift ---------- */
function updateLiveClock(){
  const now = new Date();
  try{
    const timeFmt = new Intl.DateTimeFormat("fa-IR-u-nu-latn", {hour:"2-digit", minute:"2-digit", second:"2-digit", hour12:false});
    const tp = timeFmt.formatToParts(now);
    const h = tp.find(p=>p.type==="hour").value;
    const mi = tp.find(p=>p.type==="minute").value;
    const se = tp.find(p=>p.type==="second").value;
    const timeStr = `${fa(h)}:${fa(mi)}:${fa(se)}`;
    const timeEl = document.getElementById("topbarClock");
    if(timeEl) timeEl.textContent = timeStr;
    const dhTimeEl = document.getElementById("dashHeroClock");
    if(dhTimeEl) dhTimeEl.textContent = timeStr;

    const dateFmt = new Intl.DateTimeFormat("fa-IR-u-ca-persian-nu-latn", {year:"numeric", month:"2-digit", day:"2-digit"});
    const dp = dateFmt.formatToParts(now);
    const y = dp.find(p=>p.type==="year").value;
    const m = dp.find(p=>p.type==="month").value;
    const d = dp.find(p=>p.type==="day").value;
    const dateStr = `${fa(d)} ${JALALI_MONTH_NAMES[parseInt(m,10)-1]} ${fa(y)}`;
    /* نوارِ بالا روزِ هفته را هم می‌گوید («پنجشنبه ۲ مهر») — همان چیزی
       که کارتابلِ فنی نشان می‌دهد. داشبورد تاریخِ کاملِ خودش را دارد. */
    const dateEl = document.getElementById("topbarDate");
    if(dateEl){
      try{
        dateEl.textContent = new Intl.DateTimeFormat("fa-IR-u-ca-persian",
          { weekday:"short", day:"numeric", month:"long" }).format(now);
      }catch(e){ dateEl.textContent = dateStr; }
    }
  }catch(e){ /* clock is decorative — fail silently */ }
}
setInterval(updateLiveClock, 1000);
updateLiveClock();

/* ---------- Reminder system for checklist tasks ---------- */
function openReminderSetter(kind, idx){
  const list = kind==="day" ? state.days : state.tasks;
  const item = list[idx];
  if(!item) return;
  const label = kind==="day" ? (item.main || "(بدون عنوان)") : (item.task || "(بدون عنوان)");
  const overlay = document.getElementById("reminderModalOverlay");
  const body = document.getElementById("reminderModalBody");
  const today = getTodayJalaliStr().split("/");
  const y = item.reminder ? item.reminder.y : today[0];
  const m = item.reminder ? item.reminder.m : today[1];
  const d = item.reminder ? item.reminder.d : today[2];
  const time = item.reminder ? item.reminder.time : "09:00";
  body.innerHTML = `
    <div class="rm-task-label">${kind==="day"?"وظیفه‌ی روزانه":"وظیفه"}: <b>${escapeHtml(label)}</b></div>
    <div class="rm-field-row">
      <input type="number" id="remYear" value="${parseInt(y)}" placeholder="سال">
      <input type="number" id="remMonth" value="${parseInt(m)}" min="1" max="12" placeholder="ماه">
      <input type="number" id="remDay" value="${parseInt(d)}" min="1" max="31" placeholder="روز">
    </div>
    <input type="time" id="remTime" value="${time}" class="rm-time-input">
    <div class="rm-actions">
      <button class="btn btn-brass btn-sm" id="saveReminderBtn">ذخیره یادآوری</button>
      ${item.reminder? `<button class="btn btn-ghost btn-sm" id="clearReminderBtn">حذف یادآوری</button>`:""}
    </div>
  `;
  overlay.classList.add("open");
  document.getElementById("saveReminderBtn").onclick = ()=>{
    const ry = parseInt(document.getElementById("remYear").value);
    const rm = parseInt(document.getElementById("remMonth").value);
    const rd = parseInt(document.getElementById("remDay").value);
    const rt = document.getElementById("remTime").value;
    if(!ry || !rm || !rd || !rt){ alert("تاریخ و ساعت را کامل وارد کنید."); return; }
    const [gy,gm,gd] = jalaliToGregorian(ry,rm,rd);
    const [hh,mm] = rt.split(":").map(Number);
    const ts = new Date(gy, gm-1, gd, hh, mm, 0).getTime();
    list[idx].reminder = { y:ry, m:rm, d:rd, time:rt, ts, fired:false };
    scheduleSave();
    if(kind==="day") renderDaily(); else renderChecklist();
    overlay.classList.remove("open");
  };
  const clearBtn = document.getElementById("clearReminderBtn");
  if(clearBtn) clearBtn.onclick = ()=>{
    delete list[idx].reminder;
    scheduleSave();
    if(kind==="day") renderDaily(); else renderChecklist();
    overlay.classList.remove("open");
  };
}
function closeReminderSetter(){
  const overlay = document.getElementById("reminderModalOverlay");
  if(overlay) overlay.classList.remove("open");
}

function playDing(){
  try{
    const ctx = new (window.AudioContext||window.webkitAudioContext)();
    const now = ctx.currentTime;
    [0, 0.16].forEach((offset, i)=>{
      const o = ctx.createOscillator();
      const g = ctx.createGain();
      o.type = "sine";
      o.frequency.setValueAtTime(i===0?988:1318, now+offset);
      g.gain.setValueAtTime(0.0001, now+offset);
      g.gain.exponentialRampToValueAtTime(0.22, now+offset+0.02);
      g.gain.exponentialRampToValueAtTime(0.0001, now+offset+0.5);
      o.connect(g); g.connect(ctx.destination);
      o.start(now+offset); o.stop(now+offset+0.55);
    });
  }catch(e){ /* audio not available — fail silently */ }
}

let reminderQueue = [];
let reminderShowing = false;
function showReminderPopup(item, kind){
  reminderQueue.push({item, kind});
  if(!reminderShowing) processReminderQueue();
}
function processReminderQueue(){
  if(reminderQueue.length===0){ reminderShowing=false; return; }
  reminderShowing = true;
  const {item, kind} = reminderQueue.shift();
  playDing();
  const overlay = document.getElementById("reminderPopupOverlay");
  const body = document.getElementById("reminderPopupBody");
  const title = kind==="day" ? (item.main||"وظیفه‌ی روزانه") : (item.task||"وظیفه");
  body.innerHTML = `
    <div class="reminder-pop-title">${escapeHtml(title)}</div>
    ${kind==="day" && item.meet? `<div class="reminder-pop-meta">🤝 ${escapeHtml(item.meet)}</div>`:""}
    ${kind==="day" && item.company? `<div class="reminder-pop-meta">👥 ${escapeHtml(item.company)}</div>`:""}
    ${kind==="task" && item.category? `<div class="reminder-pop-meta">📂 ${escapeHtml(item.category)}</div>`:""}
    ${kind==="task" && item.owner? `<div class="reminder-pop-meta">👤 ${escapeHtml(item.owner)}</div>`:""}
    <div class="reminder-pop-meta">⏰ زمان یادآوری: ${fa(item.reminder.d)}/${fa(item.reminder.m)}/${fa(item.reminder.y)} — ${escapeHtml(item.reminder.time)}</div>
  `;
  overlay.classList.add("open");
}
function getAllRemindableListsLive(){
  const taskLists = [];
  const dayLists = [];
  Object.keys(state.monthsData||{}).forEach(key=>{
    if(key===state.currentMonthKey) return;
    taskLists.push(state.monthsData[key].tasks || []);
    dayLists.push(state.monthsData[key].days || []);
  });
  if(state.currentMonthKey){ taskLists.push(state.tasks || []); dayLists.push(state.days || []); }
  return { taskLists, dayLists };
}
function checkReminders(){
  if(!state) return;
  const now = Date.now();
  let anyFired = false;
  const { taskLists, dayLists } = getAllRemindableListsLive();
  taskLists.forEach(tasks=>{
    (tasks||[]).forEach(t=>{
      if(t.reminder && !t.reminder.fired && t.reminder.ts<=now){
        t.reminder.fired = true;
        anyFired = true;
        showReminderPopup(t, "task");
      }
    });
  });
  dayLists.forEach(days=>{
    (days||[]).forEach(d=>{
      if(d.reminder && !d.reminder.fired && d.reminder.ts<=now){
        d.reminder.fired = true;
        anyFired = true;
        showReminderPopup(d, "day");
      }
    });
  });
  if(anyFired) scheduleSave();
}
function setupReminders(){
  const closeBtn = document.getElementById("reminderModalClose");
  if(closeBtn) closeBtn.addEventListener("click", closeReminderSetter);
  const overlay = document.getElementById("reminderModalOverlay");
  if(overlay) overlay.addEventListener("click", (e)=>{ if(e.target===overlay) closeReminderSetter(); });

  const popupClose = document.getElementById("reminderPopupClose");
  const popupOverlay = document.getElementById("reminderPopupOverlay");
  const dismissPopup = ()=>{
    popupOverlay.classList.remove("open");
    setTimeout(processReminderQueue, 300);
  };
  if(popupClose) popupClose.addEventListener("click", dismissPopup);
  if(popupOverlay) popupOverlay.addEventListener("click", (e)=>{ if(e.target===popupOverlay) dismissPopup(); });

  setInterval(checkReminders, 15000);
  setTimeout(checkReminders, 2000);
}

let dirHandle = null;
let saveHintTimer = null;
function flashSaveHint(text){
  const hint = document.getElementById("saveHint");
  if(!hint) return;
  hint.textContent = text;
  clearTimeout(saveHintTimer);
  saveHintTimer = setTimeout(()=>{ hint.textContent = ""; }, 3000);
}
{{PART:fadigits}}
{{PART:idb}}
function fsaSupported(){ return typeof window.showDirectoryPicker === "function"; }

async function readStateFromFolder(){
  if(!dirHandle) return;
  try{
    const fh = await dirHandle.getFileHandle(FILE_NAME, {create:false});
    const file = await fh.getFile();
    const text = await file.text();
    const parsed = JSON.parse(text);
    state = Object.assign(deepClone(DEFAULT_STATE), parsed);
    if(!state.tasks) state.tasks = [];
    if(!state.days || !Array.isArray(state.days) || !state.days.length) state.days = deepClone(DEFAULT_STATE.days);
    ensureMonthsMigration();
    localStorage.setItem(STORE_KEY, JSON.stringify(state));
    renderMonthSelector();
    renderChecklistAndDaily();
  }catch(e){
    // no existing JSON file in this folder yet — keep current state, it will be created on next save
  }
}
async function tryReconnectFolder(){
  /* ادمین این بخش را بسته: نه وصل می‌شویم، نه سراغِ پوشه‌ای که
     قبلاً وصل بوده می‌رویم. */
  if(featClosed("folder")) return;
  if(!fsaSupported()){
    updateFolderStatus("💡 اتصال به پوشه فقط در Chrome/Edge پشتیبانی می‌شود.");
    const btn = document.getElementById("connectFolderBtn");
    if(btn){ btn.disabled = true; btn.style.opacity = .5; btn.textContent = "🗂️ نامعتبر در این مرورگر"; }
    return;
  }
  const handle = await idbGet("dir");
  if(!handle){
    updateFolderStatus("داده‌ها فقط روی حافظه‌ی این مرورگر ذخیره می‌شود.");
    return;
  }
  try{
    const perm = await handle.queryPermission({mode:"readwrite"});
    if(perm === "granted"){
      dirHandle = handle;
      updateFolderStatus("🗂️ متصل به پوشه: «"+handle.name+"»");
      await readStateFromFolder();
      await loadDatabase();
    } else {
      updateFolderStatus("🗂️ قبلاً به پوشه «"+handle.name+"» وصل بودید — برای ادامه، دوباره روی «اتصال به پوشه» بزنید.");
    }
  }catch(e){
    updateFolderStatus("داده‌ها فقط روی حافظه‌ی این مرورگر ذخیره می‌شود.");
  }
}
async function connectFolder(){
  /* ادمین این بخش را بسته: نه وصل می‌شویم، نه سراغِ پوشه‌ای که
     قبلاً وصل بوده می‌رویم. */
  if(featClosed("folder")) return;
  if(!fsaSupported()){
    alert("اتصال به پوشه فقط در مرورگرهای Chrome یا Edge (نسخه‌ی دسکتاپ) پشتیبانی می‌شود.");
    return;
  }
  try{
    const handle = await window.showDirectoryPicker({ mode:"readwrite" });
    dirHandle = handle;
    await idbSet("dir", handle);
    updateFolderStatus("🗂️ متصل به پوشه: «"+handle.name+"»");
    await readStateFromFolder();
    await loadDatabase();
  }catch(e){
    // user cancelled the picker
  }
}

/* ---------- Single database workbook ---------- */
const DB_FILE_NAME = "{{FILEXLSX}}";
const DB_CACHE_KEY = "{{DBCACHE}}";
let dbWorkbook = null;
let dbFileName = null;

let partiesData = [];
let invoicesData = [];
let payablesData = [];
let payableNotesData = [];
let receivableNotesData = [];
let expensesData = [];
let bankData = [];
let budgetData = [];

let editMode = { invoices:false, payables:false, payablenotes:false, receivablenotes:false, expenses:false, bank:false, budget:false, parties:false };

function buildEmptyDatabaseWorkbook(){
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["نام","نوع","تلفن","مسئول تماس","یادداشت","واردکننده"]]), "طرف‌حساب‌ها");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["شماره فاکتور","مشتری","تاریخ","سررسید","مبلغ کل","پرداخت‌شده","وضعیت","واردکننده"]]), "اسناد دریافتنی از مشتری");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["ذینفع/تامین‌کننده","پروژه","تاریخ سررسید","موضوع","مبلغ","واردکننده"]]), "بدهی و پرداخت");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["شماره چک","تاریخ سررسید چک","مبلغ","ذینفع","موضوع","واردکننده"]]), "اسناد پرداختنی نزد دیگران");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["شماره چک","تاریخ سررسید چک","مبلغ","خریدار","موضوع","واردکننده"]]), "اسناد دریافتنی شرکت");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["تاریخ","نوع","دسته‌بندی","شرح","مبلغ","روش پرداخت","واردکننده"]]), "منابع و مصارف");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["نام حساب","بانک","شماره حساب","موجودی","یادداشت","واردکننده"]]), "حساب‌های بانکی");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["دوره","دسته‌بندی","بودجه","هزینه‌ی واقعی","واردکننده"]]), "بودجه‌بندی");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["ماه","دسته‌بندی","وظیفه","مسئول","مهلت","وضعیت","اولویت","یادداشت"]]), "چک‌لیست ماهانه");
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["ماه","روز","تاریخ ثبت","وظایف اصلی","توضیحات","طرف‌حساب","وضعیت"]]), "برنامه روزانه");
  /* بخش شخصی فقط به شکل رمزشده نوشته می‌شود؛ بدون این برگه،
     savePersonalSheet جایی برای نوشتن ندارد. */
  XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet([["EncryptedBlob"]]), "PersonalVault");
  return wb;
}
function ensureDbWorkbook(){
  if(!dbWorkbook) dbWorkbook = buildEmptyDatabaseWorkbook();
  return dbWorkbook;
}
function sheetToMatrix(wb, name){
  const ws = wb.Sheets[name];
  if(!ws) return null;
  return XLSX.utils.sheet_to_json(ws, {header:1, raw:true, defval:null});
}

async function findDbFileHandle(){
  if(!dirHandle) return null;
  try{
    return await dirHandle.getFileHandle(DB_FILE_NAME, {create:false});
  }catch(e){ /* fall through */ }
  for await (const [name, handle] of dirHandle.entries()){
    if(handle.kind === "file" && /\.xlsx$/i.test(name) && /مالی|finance/i.test(name)) return handle;
  }
  return null;
}

function updateAllSyncStatus(text){
  ["invoicesSyncStatus","payablesSyncStatus","expensesSyncStatus","bankSyncStatus","budgetSyncStatus","partiesSyncStatus"].forEach(id=>{
    const el = document.getElementById(id);
    if(el) el.textContent = text;
  });
}

/* خواندنِ یک‌بارهٔ فایل، بی‌آنکه به پوشه‌ای وصل باشیم.
   پیش از این دکمه شما را می‌برد سراغِ «اتصال به پوشه»، یعنی برای یک بار
   خواندنِ فایل هم باید یک پوشه را همیشه در اختیار صفحه می‌گذاشتید.
   حالا فایل را می‌گیرد، می‌خواند، داخل کارتابل می‌نشاند و رهایش می‌کند —
   داده روی سرور است، نه در آن فایل. */
async function importDatabaseFromFile(){
  if(xlsxOff()) return;
  const file = await pickFile(".xlsx,.xls");
  if(!file) return;
  updateAllSyncStatus("در حال خواندن فایل...");
  const wb = await readWorkbook(file);
  if(!wb){ updateAllSyncStatus(""); return; }
  try{
    dbWorkbook = wb;
    dbFileName = file.name;
    partiesData = parsePartiesSheet(wb);
    invoicesData = parseInvoicesSheet(wb);
    payablesData = parsePayablesSheet(wb);
    payableNotesData = parsePayableNotesSheet(wb);
    receivableNotesData = parseReceivableNotesSheet(wb);
    expensesData = parseExpensesSheet(wb);
    bankData = parseBankSheet(wb);
    budgetData = parseBudgetSheet(wb);
    /* بخشِ رمزدار عمداً از فایل خوانده نمی‌شود: کلیدش دستِ خودِ کاربر
       است و اگر این‌جا جایگزین شود، آن‌چه باز کرده بود قفل می‌ماند. */
    persistCache();
    scheduleSave();
    renderEverything();
    updateAllSyncStatus("✓ از «" + file.name + "» خوانده شد. فایل دیگر لازم نیست.");
  }catch(e){
    console.error(e);
    updateAllSyncStatus("⚠️ فایل خوانده شد ولی ساختارش با کارتابل نمی‌خواند.");
  }
}

async function loadDatabase(){
  /* بی‌پوشه هم باید بشود خواند — همان خواندنِ یک‌باره. */
  if(!dirHandle) return importDatabaseFromFile();
  updateAllSyncStatus("در حال بارگذاری...");
  const ok = await ensureXlsxLib();
  if(!ok){
    updateAllSyncStatus("⚠️ کتابخانه‌ی خواندن اکسل بارگذاری نشد (اینترنت را بررسی کنید).");
    return;
  }
  try{
    let fileHandle = await findDbFileHandle();
    if(!fileHandle){
      dbWorkbook = buildEmptyDatabaseWorkbook();
      dbFileName = DB_FILE_NAME;
      partiesData = []; invoicesData = []; payablesData = []; payableNotesData = []; receivableNotesData = []; expensesData = []; bankData = []; budgetData = [];
      persistCache();
      await writeDbNow();
      renderEverything();
      updateAllSyncStatus("✓ فایل دیتابیس جدید «"+DB_FILE_NAME+"» ساخته شد.");
      return;
    }
    const file = await fileHandle.getFile();
    const buf = await file.arrayBuffer();
    dbWorkbook = XLSX.read(buf, {type:"array", raw:true, cellDates:false});
    dbFileName = file.name;

    partiesData = parsePartiesSheet(dbWorkbook);
    invoicesData = parseInvoicesSheet(dbWorkbook);
    payablesData = parsePayablesSheet(dbWorkbook);
    payableNotesData = parsePayableNotesSheet(dbWorkbook);
    receivableNotesData = parseReceivableNotesSheet(dbWorkbook);
    expensesData = parseExpensesSheet(dbWorkbook);
    bankData = parseBankSheet(dbWorkbook);
    budgetData = parseBudgetSheet(dbWorkbook);

    persistCache();
    renderEverything();
    updateAllSyncStatus("✓ همگام با «"+dbFileName+"» — "+new Date().toLocaleString("fa-IR"));
  }catch(e){
    console.error(e);
    updateAllSyncStatus("⚠️ خطا در خواندن فایل دیتابیس.");
  }
}

/* نوشتنِ محلی از فرستادن به سرور جدا شد، مثل کارتابل فنی: مسیرِ
   پشتیبانِ آفلاین فقط نوشتنِ محلی می‌خواهد و نباید از راهی برود که
   کارش رساندن به سرور است. */
function persistCacheLocal(){
  try{
    localStorage.setItem(DB_CACHE_KEY, JSON.stringify({
      parties:partiesData, invoices:invoicesData, payables:payablesData,
      expenses:expensesData, bank:bankData, budget:budgetData, fileName:dbFileName
    }));
  }catch(e){ /* non-fatal */ }
}
function persistCache(){
  try{ Cloud.push(); }catch(e){ /* هنوز بالا نیامده */ }
  persistCacheLocal();
}
function loadCachedDatabase(){
  const seed = bkSeed();
  if(seed && seed.db){
    applyDbSnapshot(seed.db);
    bkSeedDone();
    try{ persistCacheLocal(); }catch(e){}
    return;
  }
  try{
    const raw = localStorage.getItem(DB_CACHE_KEY);
    if(!raw) return;
    const c = JSON.parse(raw);
    partiesData = c.parties || [];
    invoicesData = c.invoices || [];
    payablesData = c.payables || [];
    expensesData = c.expenses || [];
    bankData = c.bank || [];
    budgetData = c.budget || [];
    dbFileName = c.fileName || null;
  }catch(e){ /* ignore corrupt cache */ }
}

let dbWriteTimer = null;
function scheduleDbWrite(){
  persistCache();
  flashSaveHint("در حال ذخیره روی اکسل...");
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
    updateAllSyncStatus("✓ ذخیره شد در «"+targetName+"» — "+new Date().toLocaleString("fa-IR"));
    flashSaveHint("✓ ذخیره شد");
  }catch(e){
    console.error(e);
    updateAllSyncStatus("⚠️ ذخیره در اکسل ناموفق بود.");
  }
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
function chartHoverCursor(evt, elements){
  if(evt.native && evt.native.target) evt.native.target.style.cursor = elements.length ? "pointer" : "default";
}
function renderInvoiceModalItem(inv){
  return `<div class="cm-item">
    <div class="cm-item-title">${escapeHtml(inv.invoiceNo)} — ${escapeHtml(inv.customer)}</div>
    <div class="cm-item-meta">
      <span>💰 ${formatMoney(inv.amount)} تومان</span>
      <span>✅ پرداخت‌شده: ${formatMoney(inv.paid)}</span>
      ${inv.dueDate? `<span>📅 سررسید: ${escapeHtml(inv.dueDate)}</span>`:""}
    </div>
  </div>`;
}
function renderPayableModalItem(p){
  return `<div class="cm-item">
    <div class="cm-item-title">${escapeHtml(p.beneficiary)}${p.subject? " — "+escapeHtml(p.subject):""}</div>
    <div class="cm-item-meta">
      <span>💰 ${formatMoney(p.amount)} تومان</span>
      ${p.project? `<span>🗂️ پروژه: ${escapeHtml(p.project)}</span>`:""}
      ${p.dueDate? `<span>📅 سررسید: ${escapeHtml(p.dueDate)}</span>`:""}
    </div>
  </div>`;
}
function renderExpenseModalItem(e){
  return `<div class="cm-item">
    <div class="cm-item-title">${escapeHtml(e.description||"(بدون شرح)")}</div>
    <div class="cm-item-meta">
      <span>💰 ${formatMoney(e.amount)} تومان</span>
      ${e.date? `<span>📅 ${escapeHtml(e.date)}</span>`:""}
      ${e.paymentMethod? `<span>💳 ${escapeHtml(e.paymentMethod)}</span>`:""}
    </div>
  </div>`;
}
function renderDebtorModalItem(d){
  return `<div class="cm-item">
    <div class="cm-item-title">${escapeHtml(d.customer)}</div>
    <div class="cm-item-meta"><span>💰 مانده: ${formatMoney(d.remaining)} تومان</span></div>
  </div>`;
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
function renderDayModalItem(d){
  return `<div class="cm-item">
    <div class="cm-item-title">${d.main? escapeHtml(d.main) : "(بدون عنوان)"}</div>
    <div class="cm-item-meta">
      ${d.meet? `<span>🤝 ${escapeHtml(d.meet)}</span>`:""}
      ${d.company? `<span>👥 ${escapeHtml(d.company)}</span>`:""}
      ${d.createdDate? `<span>📅 ${escapeHtml(d.createdDate)}</span>`:""}
    </div>
  </div>`;
}
/* ================= Parties ================= */
function parsePartiesSheet(wb){
  const rows = sheetToMatrix(wb, "طرف‌حساب‌ها");
  if(!rows) return [];
  const out = [];
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    if(!row[0]) continue;
    out.push({ name:row[0], type:row[1]||"", phone:row[2]||"", contact:row[3]||"", note:row[4]||"", enteredBy: row[5]||"" });
  }
  return out;
}
function partiesToAOA(){
  const header = ["نام","نوع","تلفن","مسئول تماس","یادداشت","واردکننده"];
  const rows = partiesData.map(p=>[p.name||"", p.type||"", p.phone||"", p.contact||"", p.note||"", p.enteredBy||""]);
  return [header, ...rows];
}
function savePartiesSheet(){
  ensureDbWorkbook().Sheets["طرف‌حساب‌ها"] = XLSX.utils.aoa_to_sheet(partiesToAOA());
  scheduleDbWrite();
}
let partyFilters = {};
function applyPartyFilters(list){
  return list.filter(p=>{
    for(const key of Object.keys(partyFilters)){
      const filters = partyFilters[key];
      if(!filters || filters.length===0) continue;
      const val = String(p[key]==null?"":p[key]).toLowerCase();
      if(key==="type"){
        if(!filters.some(f=> f.toLowerCase()===val)) return false;
      } else {
        if(!filters.some(f=> val.includes(f.toLowerCase()))) return false;
      }
    }
    return true;
  });
}
function commitPartyCell(idx, field, value){
  if(!partiesData[idx]) return;
  partiesData[idx][field] = value;
  savePartiesSheet();
}
function addPartyRow(vals){
  partiesData.push({ name:vals.name, type:vals.type||PARTY_TYPES[0], phone:vals.phone||"", contact:vals.contact||"", note:"", enteredBy: vals.enteredBy||"" });
  savePartiesSheet();
  renderParties();
}
function renderParties(){
  const body = document.getElementById("partiesBody");
  if(!body) return;
  const typeSel = document.getElementById("msfPartyType");
  if(typeSel) renderMultiFilter(typeSel, partiesData.map(p=>p.type), partyFilters, "type", renderParties);

  const list = applyPartyFilters(partiesData);
  const editableTd = (value, idx, field)=>
    `<td class="editable-cell" contenteditable="${editMode.parties?'true':'false'}" data-idx="${idx}" data-field="${field}" style="opacity:${editMode.parties?'1':'0.85'}; cursor:${editMode.parties?'text':'default'};">${escapeHtml(value==null?"":value)}</td>`;

  const bodyRows = list.map((p)=>{
    const idx = partiesData.indexOf(p);
    return `<tr>
      <td>${fa(idx+1)}</td>
      ${editableTd(p.name, idx, "name")}
      <td>
        <select data-idx="${idx}" class="party-type-select" ${editMode.parties?'':'disabled'}>
          ${PARTY_TYPES.map(t=>`<option value="${t}" ${p.type===t?"selected":""}>${t}</option>`).join("")}
        </select>
      </td>
      ${editableTd(p.phone, idx, "phone")}
      ${editableTd(p.contact, idx, "contact")}
      ${editableTd(p.note, idx, "note")}
      ${editableTd(p.enteredBy, idx, "enteredBy")}
      <td><button class="btn-del" data-remove-party="${idx}" ${editMode.parties?'':'disabled'} title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  const addRow = `
    <tr class="add-row">
      <td>＋</td>
      <td><input type="text" id="newPartyName" placeholder="نام" style="width:100%;"></td>
      <td>
        <select id="newPartyType" style="width:100%;">${PARTY_TYPES.map(t=>`<option value="${t}">${t}</option>`).join("")}</select>
      </td>
      <td><input type="text" id="newPartyPhone" placeholder="تلفن" style="width:100%;"></td>
      <td><input type="text" id="newPartyContact" placeholder="مسئول تماس" style="width:100%;"></td>
      <td></td>
      <td><input type="text" id="newPartyEnteredBy" placeholder="نام وارد کننده" style="width:100%;"></td>
      <td><button class="btn btn-brass btn-sm" id="addPartyBtn">افزودن</button></td>
    </tr>`;

  body.innerHTML = (bodyRows || `<tr><td colspan="8" style="color:var(--ink-faint);">موردی پیدا نشد</td></tr>`) + addRow;

  body.querySelectorAll(".editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=> commitPartyCell(parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim()));
  });
  body.querySelectorAll(".party-type-select").forEach(sel=>{
    sel.addEventListener("change", ()=>{ commitPartyCell(parseInt(sel.getAttribute("data-idx")), "type", sel.value); });
  });
  body.querySelectorAll("[data-remove-party]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این طرف‌حساب حذف شود؟")) return;
      partiesData.splice(parseInt(btn.getAttribute("data-remove-party")),1);
      savePartiesSheet();
      renderParties();
    });
  });
  const addBtn = document.getElementById("addPartyBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const name = document.getElementById("newPartyName").value.trim();
    if(!name){ alert("نام را وارد کنید."); return; }
    addPartyRow({
      name, type: document.getElementById("newPartyType").value,
      phone: document.getElementById("newPartyPhone").value.trim(),
      contact: document.getElementById("newPartyContact").value.trim(),
      enteredBy: document.getElementById("newPartyEnteredBy").value.trim()
    });
  });
}
function setupParties(){
  document.getElementById("refreshPartiesBtn").addEventListener("click", loadDatabase);
  document.querySelectorAll(".party-filter").forEach(el=>{
    el.addEventListener("input", ()=>{
      partyFilters[el.getAttribute("data-key")] = [el.value].filter(v=>v.trim()!=="");
      renderParties();
    });
  });
  const toggle = document.getElementById("editToggleParties");
  if(toggle) toggle.addEventListener("change", ()=>{ editMode.parties = toggle.checked; renderParties(); });
}
/* ================= Invoices (مطالبات از مشتری) ================= */
function parseInvoicesSheet(wb){
  const rows = sheetToMatrix(wb, "اسناد دریافتنی از مشتری");
  if(!rows) return [];
  const out = [];
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    if(!row[0] && !row[1]) continue;
    out.push({
      invoiceNo: row[0]||"", customer: row[1]||"", date: row[2]||"", dueDate: row[3]||"",
      amount: parseFloat(row[4])||0, paid: parseFloat(row[5])||0, status: row[6]||INVOICE_STATUS[2],
      enteredBy: row[7]||""
    });
  }
  return out;
}
function invoicesToAOA(){
  const header = ["شماره فاکتور","مشتری","تاریخ","سررسید","مبلغ کل","پرداخت‌شده","وضعیت","واردکننده"];
  const rows = invoicesData.map(i=>[i.invoiceNo||"", i.customer||"", i.date||"", i.dueDate||"", i.amount||0, i.paid||0, i.status||"", i.enteredBy||""]);
  return [header, ...rows];
}
function saveInvoicesSheet(){
  ensureDbWorkbook().Sheets["اسناد دریافتنی از مشتری"] = XLSX.utils.aoa_to_sheet(invoicesToAOA());
  scheduleDbWrite();
}
let invoiceFilters = {};
function applyInvoiceFilters(list){
  return list.filter(inv=>{
    for(const key of Object.keys(invoiceFilters)){
      const filters = invoiceFilters[key];
      if(!filters || filters.length===0) continue;
      const val = String(inv[key]==null?"":inv[key]).toLowerCase();
      if(key==="status"){
        if(!filters.some(f=> f.toLowerCase()===val)) return false;
      } else {
        if(!filters.some(f=> val.includes(f.toLowerCase()))) return false;
      }
    }
    return true;
  });
}
function commitInvoiceCell(idx, field, value){
  if(!invoicesData[idx]) return;
  if(field==="amount" || field==="paid") value = parseFloat(value)||0;
  invoicesData[idx][field] = value;
  saveInvoicesSheet();
}
function addInvoiceRow(vals){
  invoicesData.push({
    invoiceNo: vals.invoiceNo, customer: vals.customer, date: vals.date||getTodayJalaliStr(),
    dueDate: vals.dueDate||"", amount: parseFloat(vals.amount)||0, paid: parseFloat(vals.paid)||0,
    status: vals.status||INVOICE_STATUS[2], enteredBy: vals.enteredBy||""
  });
  saveInvoicesSheet();
  renderInvoices();
}
function invoiceStatusBadgeClass(s){
  if(s==="پرداخت‌شده") return "done";
  if(s==="جزئی") return "doing";
  return "todo";
}
function renderInvoices(){
  const body = document.getElementById("invoicesBody");
  if(!body) return;
  const cardsWrap = document.getElementById("invoiceCards");
  const total = invoicesData.reduce((s,i)=>s+ (i.amount||0), 0);
  const outstanding = invoicesData.filter(i=>i.status!=="پرداخت‌شده").reduce((s,i)=>s+ Math.max(0,(i.amount||0)-(i.paid||0)), 0);
  const overdueCount = invoicesData.filter(i=>i.status==="معوق").length;
  if(cardsWrap) cardsWrap.innerHTML = `
    <div class="stat" style="--accent:var(--c1); --tint:var(--t1)"><div class="stat-head"><span class="stat-ic">🧾</span><span class="stat-lbl">تعداد فاکتورها</span></div><div class="stat-val">${fa(invoicesData.length)}</div></div>
    <div class="stat" style="--accent:var(--c2); --tint:var(--t2)"><div class="stat-head"><span class="stat-ic">💰</span><span class="stat-lbl">جمع کل فاکتورها</span></div><div class="stat-val">${formatMoney(total)}</div></div>
    <div class="stat" style="--accent:var(--c3); --tint:var(--t3)"><div class="stat-head"><span class="stat-ic">⏳</span><span class="stat-lbl">مانده‌ی وصول‌نشده</span></div><div class="stat-val">${formatMoney(outstanding)}</div></div>
    <div class="stat ${(overdueCount) > 0 ? "is-alert" : "is-clear"}"><div class="stat-head"><span class="stat-ic">${(overdueCount) > 0 ? "⚠️" : "✅"}</span><span class="stat-lbl">فاکتورهای معوق</span></div><div class="stat-val">${fa(overdueCount)}</div><div class="stat-sub">${(overdueCount) > 0 ? "نیاز به پیگیری" : "چیزی عقب نیفتاده"}</div></div>
  `;

  const statusSel = document.getElementById("msfInvoiceStatus");
  if(statusSel) renderMultiFilter(statusSel, invoicesData.map(i=>i.status), invoiceFilters, "status", renderInvoices);

  const list = applyInvoiceFilters(invoicesData);
  const editableTd = (value, idx, field)=>
    `<td class="editable-cell" contenteditable="${editMode.invoices?'true':'false'}" data-idx="${idx}" data-field="${field}" style="opacity:${editMode.invoices?'1':'0.85'}; cursor:${editMode.invoices?'text':'default'};">${escapeHtml(value==null?"":value)}</td>`;

  const bodyRows = list.map((inv)=>{
    const idx = invoicesData.indexOf(inv);
    return `<tr>
      <td>${fa(idx+1)}</td>
      ${editableTd(inv.invoiceNo, idx, "invoiceNo")}
      ${editableTd(inv.customer, idx, "customer")}
      ${editableTd(inv.date, idx, "date")}
      ${editableTd(inv.dueDate, idx, "dueDate")}
      ${editableTd(inv.amount, idx, "amount")}
      ${editableTd(inv.paid, idx, "paid")}
      <td>
        <select class="invoice-status-select" data-idx="${idx}" ${editMode.invoices?'':'disabled'}>
          ${INVOICE_STATUS.map(s=>`<option value="${s}" ${inv.status===s?"selected":""}>${s}</option>`).join("")}
        </select>
      </td>
      ${editableTd(inv.enteredBy, idx, "enteredBy")}
      <td><button class="btn-del" data-remove-invoice="${idx}" ${editMode.invoices?'':'disabled'} title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  const addRow = `
    <tr class="add-row">
      <td>＋</td>
      <td><input type="text" id="newInvoiceNo" placeholder="شماره" style="width:100%;"></td>
      <td><input type="text" id="newInvoiceCustomer" placeholder="مشتری" list="partyCustomerOptions" style="width:100%;"></td>
      <td><input type="text" id="newInvoiceDate" placeholder="تاریخ" style="width:100%;"></td>
      <td><input type="text" id="newInvoiceDueDate" placeholder="سررسید" style="width:100%;"></td>
      <td><input type="number" id="newInvoiceAmount" placeholder="مبلغ" style="width:100%;"></td>
      <td><input type="number" id="newInvoicePaid" placeholder="پرداخت‌شده" style="width:100%;"></td>
      <td>
        <select id="newInvoiceStatus" style="width:100%;">${INVOICE_STATUS.map(s=>`<option value="${s}">${s}</option>`).join("")}</select>
      </td>
      <td><input type="text" id="newInvoiceEnteredBy" placeholder="نام وارد کننده" style="width:100%;"></td>
      <td><button class="btn btn-brass btn-sm" id="addInvoiceBtn">افزودن</button></td>
    </tr>
    <datalist id="partyCustomerOptions">${partiesData.filter(p=>p.type==="مشتری").map(p=>`<option value="${escapeHtml(p.name)}">`).join("")}</datalist>`;

  body.innerHTML = (bodyRows || `<tr><td colspan="10" style="color:var(--ink-faint);">موردی پیدا نشد</td></tr>`) + addRow;

  body.querySelectorAll(".editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=> commitInvoiceCell(parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim()));
  });
  body.querySelectorAll(".invoice-status-select").forEach(sel=>{
    sel.addEventListener("change", ()=>{ commitInvoiceCell(parseInt(sel.getAttribute("data-idx")), "status", sel.value); renderInvoices(); });
  });
  body.querySelectorAll("[data-remove-invoice]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این فاکتور حذف شود؟")) return;
      invoicesData.splice(parseInt(btn.getAttribute("data-remove-invoice")),1);
      saveInvoicesSheet();
      renderInvoices();
    });
  });
  const addBtn = document.getElementById("addInvoiceBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const invoiceNo = document.getElementById("newInvoiceNo").value.trim();
    const customer = document.getElementById("newInvoiceCustomer").value.trim();
    if(!invoiceNo || !customer){ alert("شماره فاکتور و نام مشتری را وارد کنید."); return; }
    addInvoiceRow({
      invoiceNo, customer,
      date: document.getElementById("newInvoiceDate").value.trim(),
      dueDate: document.getElementById("newInvoiceDueDate").value.trim(),
      amount: document.getElementById("newInvoiceAmount").value,
      paid: document.getElementById("newInvoicePaid").value,
      status: document.getElementById("newInvoiceStatus").value,
      enteredBy: document.getElementById("newInvoiceEnteredBy").value.trim()
    });
  });
}
function setupInvoices(){
  document.getElementById("refreshInvoicesBtn").addEventListener("click", loadDatabase);
  document.querySelectorAll(".invoice-filter").forEach(el=>{
    el.addEventListener("input", ()=>{
      invoiceFilters[el.getAttribute("data-key")] = [el.value].filter(v=>v.trim()!=="");
      renderInvoices();
    });
  });
  const toggle = document.getElementById("editToggleInvoices");
  if(toggle) toggle.addEventListener("change", ()=>{ editMode.invoices = toggle.checked; renderInvoices(); });
}
/* ================= Payables (بدهی به تامین‌کننده) ================= */
function parsePayablesSheet(wb){
  const rows = sheetToMatrix(wb, "بدهی و پرداخت");
  if(!rows) return [];
  const out = [];
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    if(!row[0]) continue;
    out.push({
      beneficiary: row[0]||"", project: row[1]||"", dueDate: row[2]||"",
      subject: row[3]||"", amount: parseFloat(row[4])||0, enteredBy: row[5]||""
    });
  }
  return out;
}
function payablesToAOA(){
  const header = ["ذینفع/تامین‌کننده","پروژه","تاریخ سررسید","موضوع","مبلغ","واردکننده"];
  const rows = payablesData.map(p=>[p.beneficiary||"", p.project||"", p.dueDate||"", p.subject||"", p.amount||0, p.enteredBy||""]);
  return [header, ...rows];
}
function savePayablesSheet(){
  ensureDbWorkbook().Sheets["بدهی و پرداخت"] = XLSX.utils.aoa_to_sheet(payablesToAOA());
  scheduleDbWrite();
}
let payableFilters = {};
function applyPayableFilters(list){
  return list.filter(p=>{
    for(const key of Object.keys(payableFilters)){
      const filters = payableFilters[key];
      if(!filters || filters.length===0) continue;
      const val = String(p[key]==null?"":p[key]).toLowerCase();
      if(!filters.some(f=> val.includes(f.toLowerCase()))) return false;
    }
    return true;
  });
}
function commitPayableCell(idx, field, value){
  if(!payablesData[idx]) return;
  if(field==="amount") value = parseFloat(value)||0;
  payablesData[idx][field] = value;
  savePayablesSheet();
}
function addPayableRow(vals){
  payablesData.push({
    beneficiary: vals.beneficiary, project: vals.project||"", dueDate: vals.dueDate||"",
    subject: vals.subject||"", amount: parseFloat(vals.amount)||0, enteredBy: vals.enteredBy||""
  });
  savePayablesSheet();
  renderPayables();
}
function renderPayables(){
  const body = document.getElementById("payablesBody");
  if(!body) return;
  const cardsWrap = document.getElementById("payableCards");
  const total = payablesData.reduce((s,p)=>s+ (p.amount||0), 0);
  const today = getTodayJalaliStr();
  const overdueCount = payablesData.filter(p=> p.dueDate && p.dueDate < today).length;
  if(cardsWrap) cardsWrap.innerHTML = `
    <div class="stat" style="--accent:var(--c1); --tint:var(--t1)"><div class="stat-head"><span class="stat-ic">💳</span><span class="stat-lbl">تعداد ردیف‌ها</span></div><div class="stat-val">${fa(payablesData.length)}</div></div>
    <div class="stat" style="--accent:var(--c2); --tint:var(--t2)"><div class="stat-head"><span class="stat-ic">💰</span><span class="stat-lbl">جمع کل بدهی‌ها</span></div><div class="stat-val">${formatMoney(total)}</div></div>
    <div class="stat ${(overdueCount) > 0 ? "is-alert" : "is-clear"}"><div class="stat-head"><span class="stat-ic">${(overdueCount) > 0 ? "⚠️" : "✅"}</span><span class="stat-lbl">سررسیدگذشته</span></div><div class="stat-val">${fa(overdueCount)}</div><div class="stat-sub">${(overdueCount) > 0 ? "نیاز به پیگیری" : "چیزی عقب نیفتاده"}</div></div>
  `;

  const list = applyPayableFilters(payablesData);
  const editableTd = (value, idx, field)=>
    `<td class="editable-cell" contenteditable="${editMode.payables?'true':'false'}" data-idx="${idx}" data-field="${field}" style="opacity:${editMode.payables?'1':'0.85'}; cursor:${editMode.payables?'text':'default'};">${escapeHtml(value==null?"":value)}</td>`;

  const bodyRows = list.map((p)=>{
    const idx = payablesData.indexOf(p);
    return `<tr>
      <td>${fa(idx+1)}</td>
      ${editableTd(p.beneficiary, idx, "beneficiary")}
      ${editableTd(p.project, idx, "project")}
      ${editableTd(p.dueDate, idx, "dueDate")}
      ${editableTd(p.subject, idx, "subject")}
      ${editableTd(p.amount, idx, "amount")}
      ${editableTd(p.enteredBy, idx, "enteredBy")}
      <td><button class="btn-del" data-remove-payable="${idx}" ${editMode.payables?'':'disabled'} title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  const addRow = `
    <tr class="add-row">
      <td>＋</td>
      <td><input type="text" id="newPayableBeneficiary" placeholder="ذینفع/تامین‌کننده" list="partySupplierOptions" style="width:100%;"></td>
      <td><input type="text" id="newPayableProject" placeholder="پروژه" style="width:100%;"></td>
      <td><input type="text" id="newPayableDueDate" placeholder="سررسید" style="width:100%;"></td>
      <td><input type="text" id="newPayableSubject" placeholder="موضوع" style="width:100%;"></td>
      <td><input type="number" id="newPayableAmount" placeholder="مبلغ" style="width:100%;"></td>
      <td><input type="text" id="newPayableEnteredBy" placeholder="نام وارد کننده" style="width:100%;"></td>
      <td><button class="btn btn-brass btn-sm" id="addPayableBtn">افزودن</button></td>
    </tr>
    <datalist id="partySupplierOptions">${partiesData.filter(p=>p.type==="تامین‌کننده").map(p=>`<option value="${escapeHtml(p.name)}">`).join("")}</datalist>`;

  body.innerHTML = (bodyRows || `<tr><td colspan="8" style="color:var(--ink-faint);">موردی پیدا نشد</td></tr>`) + addRow;

  body.querySelectorAll(".editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=> commitPayableCell(parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim()));
  });
  body.querySelectorAll("[data-remove-payable]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این ردیف حذف شود؟")) return;
      payablesData.splice(parseInt(btn.getAttribute("data-remove-payable")),1);
      savePayablesSheet();
      renderPayables();
    });
  });
  const addBtn = document.getElementById("addPayableBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const beneficiary = document.getElementById("newPayableBeneficiary").value.trim();
    if(!beneficiary){ alert("نام ذینفع/تامین‌کننده را وارد کنید."); return; }
    addPayableRow({
      beneficiary,
      project: document.getElementById("newPayableProject").value.trim(),
      dueDate: document.getElementById("newPayableDueDate").value.trim(),
      subject: document.getElementById("newPayableSubject").value.trim(),
      amount: document.getElementById("newPayableAmount").value,
      enteredBy: document.getElementById("newPayableEnteredBy").value.trim()
    });
  });
}
function setupPayables(){
  document.getElementById("refreshPayablesBtn").addEventListener("click", loadDatabase);
  document.querySelectorAll(".payable-filter").forEach(el=>{
    el.addEventListener("input", ()=>{
      payableFilters[el.getAttribute("data-key")] = [el.value].filter(v=>v.trim()!=="");
      renderPayables();
    });
  });
  const toggle = document.getElementById("editTogglePayables");
  if(toggle) toggle.addEventListener("change", ()=>{ editMode.payables = toggle.checked; renderPayables(); });
}

/* ================= Payable Notes (اسناد پرداختنی نزد دیگران) ================= */
function parsePayableNotesSheet(wb){
  const rows = sheetToMatrix(wb, "اسناد پرداختنی نزد دیگران");
  if(!rows) return [];
  const out = [];
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    if(!row[0] && !row[3]) continue;
    out.push({ checkNo: row[0]||"", dueDate: row[1]||"", amount: parseFloat(row[2])||0, beneficiary: row[3]||"", subject: row[4]||"", enteredBy: row[5]||"" });
  }
  return out;
}
function payableNotesToAOA(){
  const header = ["شماره چک","تاریخ سررسید چک","مبلغ","ذینفع","موضوع","واردکننده"];
  const rows = payableNotesData.map(n=>[n.checkNo||"", n.dueDate||"", n.amount||0, n.beneficiary||"", n.subject||"", n.enteredBy||""]);
  return [header, ...rows];
}
function savePayableNotesSheet(){
  ensureDbWorkbook().Sheets["اسناد پرداختنی نزد دیگران"] = XLSX.utils.aoa_to_sheet(payableNotesToAOA());
  scheduleDbWrite();
}
let payableNoteFilters = {};
function applyPayableNoteFilters(list){
  return list.filter(n=>{
    for(const key of Object.keys(payableNoteFilters)){
      const filters = payableNoteFilters[key];
      if(!filters || filters.length===0) continue;
      const val = String(n[key]==null?"":n[key]).toLowerCase();
      if(!filters.some(f=> val.includes(f.toLowerCase()))) return false;
    }
    return true;
  });
}
function commitPayableNoteCell(idx, field, value){
  if(!payableNotesData[idx]) return;
  if(field==="amount") value = parseFloat(value)||0;
  payableNotesData[idx][field] = value;
  savePayableNotesSheet();
}
function addPayableNoteRow(vals){
  payableNotesData.push({ checkNo: vals.checkNo||"", dueDate: vals.dueDate||"", amount: parseFloat(vals.amount)||0, beneficiary: vals.beneficiary||"", subject: vals.subject||"", enteredBy: vals.enteredBy||"" });
  savePayableNotesSheet();
  renderPayableNotes();
}
function renderPayableNotes(){
  const body = document.getElementById("payableNotesBody");
  if(!body) return;
  const cardsWrap = document.getElementById("payableNotesCards");
  const total = payableNotesData.reduce((s,n)=>s+(n.amount||0),0);
  if(cardsWrap) cardsWrap.innerHTML = `
    <div class="stat" style="--accent:var(--c1); --tint:var(--t1)"><div class="stat-head"><span class="stat-ic">📄</span><span class="stat-lbl">تعداد اسناد پرداختنی</span></div><div class="stat-val">${fa(payableNotesData.length)}</div></div>
    <div class="stat" style="--accent:var(--c2); --tint:var(--t2)"><div class="stat-head"><span class="stat-ic">💰</span><span class="stat-lbl">جمع کل مبلغ</span></div><div class="stat-val">${formatMoney(total)}</div></div>
  `;
  const list = applyPayableNoteFilters(payableNotesData);
  const editableTd = (value, idx, field)=>
    `<td class="editable-cell" contenteditable="${editMode.payablenotes?'true':'false'}" data-idx="${idx}" data-field="${field}" style="opacity:${editMode.payablenotes?'1':'0.85'}; cursor:${editMode.payablenotes?'text':'default'};">${escapeHtml(value==null?"":value)}</td>`;

  const bodyRows = list.map((n)=>{
    const idx = payableNotesData.indexOf(n);
    return `<tr>
      <td>${fa(idx+1)}</td>
      ${editableTd(n.checkNo, idx, "checkNo")}
      ${editableTd(n.dueDate, idx, "dueDate")}
      ${editableTd(n.amount, idx, "amount")}
      ${editableTd(n.beneficiary, idx, "beneficiary")}
      ${editableTd(n.subject, idx, "subject")}
      ${editableTd(n.enteredBy, idx, "enteredBy")}
      <td><button class="btn-del" data-remove-payablenote="${idx}" ${editMode.payablenotes?'':'disabled'} title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  const addRow = `
    <tr class="add-row">
      <td>＋</td>
      <td><input type="text" id="newPayableNoteCheckNo" placeholder="شماره چک" style="width:100%;"></td>
      <td><input type="text" id="newPayableNoteDueDate" placeholder="تاریخ سررسید" style="width:100%;"></td>
      <td><input type="number" id="newPayableNoteAmount" placeholder="مبلغ" style="width:100%;"></td>
      <td><input type="text" id="newPayableNoteBeneficiary" placeholder="ذینفع" list="partySupplierOptions" style="width:100%;"></td>
      <td><input type="text" id="newPayableNoteSubject" placeholder="موضوع" style="width:100%;"></td>
      <td><input type="text" id="newPayableNoteEnteredBy" placeholder="نام وارد کننده" style="width:100%;"></td>
      <td><button class="btn btn-brass btn-sm" id="addPayableNoteBtn">افزودن</button></td>
    </tr>`;

  body.innerHTML = (bodyRows || `<tr><td colspan="8" style="color:var(--ink-faint);">موردی پیدا نشد</td></tr>`) + addRow;

  body.querySelectorAll(".editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=> commitPayableNoteCell(parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim()));
  });
  body.querySelectorAll("[data-remove-payablenote]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این سند حذف شود؟")) return;
      payableNotesData.splice(parseInt(btn.getAttribute("data-remove-payablenote")),1);
      savePayableNotesSheet();
      renderPayableNotes();
    });
  });
  const addBtn = document.getElementById("addPayableNoteBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const checkNo = document.getElementById("newPayableNoteCheckNo").value.trim();
    const beneficiary = document.getElementById("newPayableNoteBeneficiary").value.trim();
    if(!checkNo || !beneficiary){ alert("شماره چک و ذینفع را وارد کنید."); return; }
    addPayableNoteRow({
      checkNo, beneficiary,
      dueDate: document.getElementById("newPayableNoteDueDate").value.trim(),
      amount: document.getElementById("newPayableNoteAmount").value,
      subject: document.getElementById("newPayableNoteSubject").value.trim(),
      enteredBy: document.getElementById("newPayableNoteEnteredBy").value.trim()
    });
  });
}
function setupPayableNotes(){
  document.getElementById("refreshPayableNotesBtn").addEventListener("click", loadDatabase);
  document.querySelectorAll(".payablenote-filter").forEach(el=>{
    el.addEventListener("input", ()=>{
      payableNoteFilters[el.getAttribute("data-key")] = [el.value].filter(v=>v.trim()!=="");
      renderPayableNotes();
    });
  });
  const toggle = document.getElementById("editTogglePayableNotes");
  if(toggle) toggle.addEventListener("change", ()=>{ editMode.payablenotes = toggle.checked; renderPayableNotes(); });
}

/* ================= Receivable Notes (اسناد دریافتنی به نفع شرکت) ================= */
function parseReceivableNotesSheet(wb){
  const rows = sheetToMatrix(wb, "اسناد دریافتنی شرکت");
  if(!rows) return [];
  const out = [];
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    if(!row[0] && !row[3]) continue;
    out.push({ checkNo: row[0]||"", dueDate: row[1]||"", amount: parseFloat(row[2])||0, buyer: row[3]||"", subject: row[4]||"", enteredBy: row[5]||"" });
  }
  return out;
}
function receivableNotesToAOA(){
  const header = ["شماره چک","تاریخ سررسید چک","مبلغ","خریدار","موضوع","واردکننده"];
  const rows = receivableNotesData.map(n=>[n.checkNo||"", n.dueDate||"", n.amount||0, n.buyer||"", n.subject||"", n.enteredBy||""]);
  return [header, ...rows];
}
function saveReceivableNotesSheet(){
  ensureDbWorkbook().Sheets["اسناد دریافتنی شرکت"] = XLSX.utils.aoa_to_sheet(receivableNotesToAOA());
  scheduleDbWrite();
}
let receivableNoteFilters = {};
function applyReceivableNoteFilters(list){
  return list.filter(n=>{
    for(const key of Object.keys(receivableNoteFilters)){
      const filters = receivableNoteFilters[key];
      if(!filters || filters.length===0) continue;
      const val = String(n[key]==null?"":n[key]).toLowerCase();
      if(!filters.some(f=> val.includes(f.toLowerCase()))) return false;
    }
    return true;
  });
}
function commitReceivableNoteCell(idx, field, value){
  if(!receivableNotesData[idx]) return;
  if(field==="amount") value = parseFloat(value)||0;
  receivableNotesData[idx][field] = value;
  saveReceivableNotesSheet();
}
function addReceivableNoteRow(vals){
  receivableNotesData.push({ checkNo: vals.checkNo||"", dueDate: vals.dueDate||"", amount: parseFloat(vals.amount)||0, buyer: vals.buyer||"", subject: vals.subject||"", enteredBy: vals.enteredBy||"" });
  saveReceivableNotesSheet();
  renderReceivableNotes();
}
function renderReceivableNotes(){
  const body = document.getElementById("receivableNotesBody");
  if(!body) return;
  const cardsWrap = document.getElementById("receivableNotesCards");
  const total = receivableNotesData.reduce((s,n)=>s+(n.amount||0),0);
  if(cardsWrap) cardsWrap.innerHTML = `
    <div class="stat" style="--accent:var(--c1); --tint:var(--t1)"><div class="stat-head"><span class="stat-ic">📃</span><span class="stat-lbl">تعداد اسناد دریافتنی</span></div><div class="stat-val">${fa(receivableNotesData.length)}</div></div>
    <div class="stat" style="--accent:var(--c2); --tint:var(--t2)"><div class="stat-head"><span class="stat-ic">💰</span><span class="stat-lbl">جمع کل مبلغ</span></div><div class="stat-val">${formatMoney(total)}</div></div>
  `;
  const list = applyReceivableNoteFilters(receivableNotesData);
  const editableTd = (value, idx, field)=>
    `<td class="editable-cell" contenteditable="${editMode.receivablenotes?'true':'false'}" data-idx="${idx}" data-field="${field}" style="opacity:${editMode.receivablenotes?'1':'0.85'}; cursor:${editMode.receivablenotes?'text':'default'};">${escapeHtml(value==null?"":value)}</td>`;

  const bodyRows = list.map((n)=>{
    const idx = receivableNotesData.indexOf(n);
    return `<tr>
      <td>${fa(idx+1)}</td>
      ${editableTd(n.checkNo, idx, "checkNo")}
      ${editableTd(n.dueDate, idx, "dueDate")}
      ${editableTd(n.amount, idx, "amount")}
      ${editableTd(n.buyer, idx, "buyer")}
      ${editableTd(n.subject, idx, "subject")}
      ${editableTd(n.enteredBy, idx, "enteredBy")}
      <td><button class="btn-del" data-remove-receivablenote="${idx}" ${editMode.receivablenotes?'':'disabled'} title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  const addRow = `
    <tr class="add-row">
      <td>＋</td>
      <td><input type="text" id="newReceivableNoteCheckNo" placeholder="شماره چک" style="width:100%;"></td>
      <td><input type="text" id="newReceivableNoteDueDate" placeholder="تاریخ سررسید" style="width:100%;"></td>
      <td><input type="number" id="newReceivableNoteAmount" placeholder="مبلغ" style="width:100%;"></td>
      <td><input type="text" id="newReceivableNoteBuyer" placeholder="خریدار" list="partyCustomerOptions" style="width:100%;"></td>
      <td><input type="text" id="newReceivableNoteSubject" placeholder="موضوع" style="width:100%;"></td>
      <td><input type="text" id="newReceivableNoteEnteredBy" placeholder="نام وارد کننده" style="width:100%;"></td>
      <td><button class="btn btn-brass btn-sm" id="addReceivableNoteBtn">افزودن</button></td>
    </tr>`;

  body.innerHTML = (bodyRows || `<tr><td colspan="8" style="color:var(--ink-faint);">موردی پیدا نشد</td></tr>`) + addRow;

  body.querySelectorAll(".editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=> commitReceivableNoteCell(parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim()));
  });
  body.querySelectorAll("[data-remove-receivablenote]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این سند حذف شود؟")) return;
      receivableNotesData.splice(parseInt(btn.getAttribute("data-remove-receivablenote")),1);
      saveReceivableNotesSheet();
      renderReceivableNotes();
    });
  });
  const addBtn = document.getElementById("addReceivableNoteBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const checkNo = document.getElementById("newReceivableNoteCheckNo").value.trim();
    const buyer = document.getElementById("newReceivableNoteBuyer").value.trim();
    if(!checkNo || !buyer){ alert("شماره چک و خریدار را وارد کنید."); return; }
    addReceivableNoteRow({
      checkNo, buyer,
      dueDate: document.getElementById("newReceivableNoteDueDate").value.trim(),
      amount: document.getElementById("newReceivableNoteAmount").value,
      subject: document.getElementById("newReceivableNoteSubject").value.trim(),
      enteredBy: document.getElementById("newReceivableNoteEnteredBy").value.trim()
    });
  });
}
function setupReceivableNotes(){
  document.getElementById("refreshReceivableNotesBtn").addEventListener("click", loadDatabase);
  document.querySelectorAll(".receivablenote-filter").forEach(el=>{
    el.addEventListener("input", ()=>{
      receivableNoteFilters[el.getAttribute("data-key")] = [el.value].filter(v=>v.trim()!=="");
      renderReceivableNotes();
    });
  });
  const toggle = document.getElementById("editToggleReceivableNotes");
  if(toggle) toggle.addEventListener("change", ()=>{ editMode.receivablenotes = toggle.checked; renderReceivableNotes(); });
}

/* ================= Sources & Uses (منابع و مصارف) ================= */
function parseExpensesSheet(wb){
  const rows = sheetToMatrix(wb, "منابع و مصارف");
  if(!rows) return [];
  const out = [];
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    if(!row[0] && !row[3]) continue;
    out.push({ date: row[0]||"", type: row[1]||SOURCE_USE_TYPES[1], category: row[2]||"", description: row[3]||"", amount: parseFloat(row[4])||0, paymentMethod: row[5]||"", enteredBy: row[6]||"" });
  }
  return out;
}
function expensesToAOA(){
  const header = ["تاریخ","نوع","دسته‌بندی","شرح","مبلغ","روش پرداخت","واردکننده"];
  const rows = expensesData.map(e=>[e.date||"", e.type||SOURCE_USE_TYPES[1], e.category||"", e.description||"", e.amount||0, e.paymentMethod||"", e.enteredBy||""]);
  return [header, ...rows];
}
function saveExpensesSheet(){
  ensureDbWorkbook().Sheets["منابع و مصارف"] = XLSX.utils.aoa_to_sheet(expensesToAOA());
  scheduleDbWrite();
}
let expenseFilters = {};
function applyExpenseFilters(list){
  return list.filter(e=>{
    for(const key of Object.keys(expenseFilters)){
      const filters = expenseFilters[key];
      if(!filters || filters.length===0) continue;
      const val = String(e[key]==null?"":e[key]).toLowerCase();
      if(key==="category" || key==="paymentMethod" || key==="type"){
        if(!filters.some(f=> f.toLowerCase()===val)) return false;
      } else {
        if(!filters.some(f=> val.includes(f.toLowerCase()))) return false;
      }
    }
    return true;
  });
}
function commitExpenseCell(idx, field, value){
  if(!expensesData[idx]) return;
  if(field==="amount") value = parseFloat(value)||0;
  expensesData[idx][field] = value;
  saveExpensesSheet();
}
function addExpenseRow(vals){
  expensesData.push({ date: vals.date||getTodayJalaliStr(), type: vals.type||SOURCE_USE_TYPES[1], category: vals.category||EXPENSE_CATEGORIES[EXPENSE_CATEGORIES.length-1], description: vals.description||"", amount: parseFloat(vals.amount)||0, paymentMethod: vals.paymentMethod||PAYMENT_METHODS[0], enteredBy: vals.enteredBy||"" });
  saveExpensesSheet();
  renderExpenses();
}
function renderExpenses(){
  const body = document.getElementById("expensesBody");
  if(!body) return;
  const cardsWrap = document.getElementById("expenseCards");
  const totalSources = expensesData.filter(e=>e.type===SOURCE_USE_TYPES[0]).reduce((s,e)=>s+(e.amount||0),0);
  const totalUses = expensesData.filter(e=>e.type===SOURCE_USE_TYPES[1]).reduce((s,e)=>s+(e.amount||0),0);
  const net = totalSources - totalUses;
  if(cardsWrap) cardsWrap.innerHTML = `
    <div class="stat" style="--accent:var(--c1); --tint:var(--t1)"><div class="stat-head"><span class="stat-ic">📥</span><span class="stat-lbl">جمع منابع</span></div><div class="stat-val">${formatMoney(totalSources)}</div></div>
    <div class="stat" style="--accent:var(--c2); --tint:var(--t2)"><div class="stat-head"><span class="stat-ic">📤</span><span class="stat-lbl">جمع مصارف</span></div><div class="stat-val">${formatMoney(totalUses)}</div></div>
    <div class="stat" style="--accent:${net>=0?'var(--c4)':'var(--bad)'}; --tint:${net>=0?'var(--t4)':'var(--bad-bg)'}">
      <div class="stat-head"><span class="stat-ic">⚖️</span><span class="stat-lbl">تراز (منابع − مصارف)</span></div>
      <div class="stat-val" style="color:${net>=0?'var(--ink)':'var(--bad-ink)'}">${formatMoney(net)}</div>
      <div class="stat-sub">${net>=0?'مثبت — منابع بیشتر از مصارف':'منفی — مصارف بیشتر از منابع'}</div>
    </div>
  `;

  const typeSel = document.getElementById("msfExpenseType");
  if(typeSel) renderMultiFilter(typeSel, expensesData.map(e=>e.type), expenseFilters, "type", renderExpenses);
  const catSel = document.getElementById("msfExpenseCategory");
  if(catSel) renderMultiFilter(catSel, expensesData.map(e=>e.category), expenseFilters, "category", renderExpenses);
  const paySel = document.getElementById("msfExpensePayment");
  if(paySel) renderMultiFilter(paySel, expensesData.map(e=>e.paymentMethod), expenseFilters, "paymentMethod", renderExpenses);

  const list = applyExpenseFilters(expensesData);
  const editableTd = (value, idx, field)=>
    `<td class="editable-cell" contenteditable="${editMode.expenses?'true':'false'}" data-idx="${idx}" data-field="${field}" style="opacity:${editMode.expenses?'1':'0.85'}; cursor:${editMode.expenses?'text':'default'};">${escapeHtml(value==null?"":value)}</td>`;

  const bodyRows = list.map((e)=>{
    const idx = expensesData.indexOf(e);
    return `<tr>
      <td>${fa(idx+1)}</td>
      ${editableTd(e.date, idx, "date")}
      <td>
        <select class="expense-type-select" data-idx="${idx}" ${editMode.expenses?'':'disabled'}>
          ${SOURCE_USE_TYPES.map(t=>`<option value="${t}" ${e.type===t?"selected":""}>${t}</option>`).join("")}
        </select>
      </td>
      <td>
        <select class="expense-category-select" data-idx="${idx}" ${editMode.expenses?'':'disabled'}>
          ${EXPENSE_CATEGORIES.map(c=>`<option value="${c}" ${e.category===c?"selected":""}>${c}</option>`).join("")}
        </select>
      </td>
      ${editableTd(e.description, idx, "description")}
      ${editableTd(e.amount, idx, "amount")}
      <td>
        <select class="expense-payment-select" data-idx="${idx}" ${editMode.expenses?'':'disabled'}>
          ${PAYMENT_METHODS.map(m=>`<option value="${m}" ${e.paymentMethod===m?"selected":""}>${m}</option>`).join("")}
        </select>
      </td>
      ${editableTd(e.enteredBy, idx, "enteredBy")}
      <td><button class="btn-del" data-remove-expense="${idx}" ${editMode.expenses?'':'disabled'} title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  const addRow = `
    <tr class="add-row">
      <td>＋</td>
      <td><input type="text" id="newExpenseDate" placeholder="تاریخ" style="width:100%;"></td>
      <td>
        <select id="newExpenseType" style="width:100%;">${SOURCE_USE_TYPES.map(t=>`<option value="${t}">${t}</option>`).join("")}</select>
      </td>
      <td>
        <select id="newExpenseCategory" style="width:100%;">${EXPENSE_CATEGORIES.map(c=>`<option value="${c}">${c}</option>`).join("")}</select>
      </td>
      <td><input type="text" id="newExpenseDescription" placeholder="شرح" style="width:100%;"></td>
      <td><input type="number" id="newExpenseAmount" placeholder="مبلغ" style="width:100%;"></td>
      <td>
        <select id="newExpensePayment" style="width:100%;">${PAYMENT_METHODS.map(m=>`<option value="${m}">${m}</option>`).join("")}</select>
      </td>
      <td><input type="text" id="newExpenseEnteredBy" placeholder="نام وارد کننده" style="width:100%;"></td>
      <td><button class="btn btn-brass btn-sm" id="addExpenseBtn">افزودن</button></td>
    </tr>`;

  body.innerHTML = (bodyRows || `<tr><td colspan="9" style="color:var(--ink-faint);">موردی پیدا نشد</td></tr>`) + addRow;

  body.querySelectorAll(".editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=> commitExpenseCell(parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim()));
  });
  body.querySelectorAll(".expense-type-select").forEach(sel=>{
    sel.addEventListener("change", ()=>{ commitExpenseCell(parseInt(sel.getAttribute("data-idx")), "type", sel.value); renderExpenses(); });
  });
  body.querySelectorAll(".expense-category-select").forEach(sel=>{
    sel.addEventListener("change", ()=>{ commitExpenseCell(parseInt(sel.getAttribute("data-idx")), "category", sel.value); });
  });
  body.querySelectorAll(".expense-payment-select").forEach(sel=>{
    sel.addEventListener("change", ()=>{ commitExpenseCell(parseInt(sel.getAttribute("data-idx")), "paymentMethod", sel.value); });
  });
  body.querySelectorAll("[data-remove-expense]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این ردیف حذف شود؟")) return;
      expensesData.splice(parseInt(btn.getAttribute("data-remove-expense")),1);
      saveExpensesSheet();
      renderExpenses();
    });
  });
  const addBtn = document.getElementById("addExpenseBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const description = document.getElementById("newExpenseDescription").value.trim();
    const amount = document.getElementById("newExpenseAmount").value;
    if(!amount){ alert("مبلغ را وارد کنید."); return; }
    addExpenseRow({
      date: document.getElementById("newExpenseDate").value.trim(),
      type: document.getElementById("newExpenseType").value,
      category: document.getElementById("newExpenseCategory").value,
      description, amount,
      paymentMethod: document.getElementById("newExpensePayment").value,
      enteredBy: document.getElementById("newExpenseEnteredBy").value.trim()
    });
  });
}
function setupExpenses(){
  document.getElementById("refreshExpensesBtn").addEventListener("click", loadDatabase);
  document.querySelectorAll(".expense-filter").forEach(el=>{
    el.addEventListener("input", ()=>{
      expenseFilters[el.getAttribute("data-key")] = [el.value].filter(v=>v.trim()!=="");
      renderExpenses();
    });
  });
  const toggle = document.getElementById("editToggleExpenses");
  if(toggle) toggle.addEventListener("change", ()=>{ editMode.expenses = toggle.checked; renderExpenses(); });
}

/* ================= Bank Accounts ================= */
function parseBankSheet(wb){
  const rows = sheetToMatrix(wb, "حساب‌های بانکی");
  if(!rows) return [];
  const out = [];
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    if(!row[0]) continue;
    out.push({ accountName: row[0]||"", bank: row[1]||"", accountNumber: row[2]||"", balance: parseFloat(row[3])||0, note: row[4]||"", enteredBy: row[5]||"" });
  }
  return out;
}
function bankToAOA(){
  const header = ["نام حساب","بانک","شماره حساب","موجودی","یادداشت","واردکننده"];
  const rows = bankData.map(b=>[b.accountName||"", b.bank||"", b.accountNumber||"", b.balance||0, b.note||"", b.enteredBy||""]);
  return [header, ...rows];
}
function saveBankSheet(){
  ensureDbWorkbook().Sheets["حساب‌های بانکی"] = XLSX.utils.aoa_to_sheet(bankToAOA());
  scheduleDbWrite();
}
function commitBankCell(idx, field, value){
  if(!bankData[idx]) return;
  if(field==="balance") value = parseFloat(value)||0;
  bankData[idx][field] = value;
  saveBankSheet();
}
function addBankRow(vals){
  bankData.push({ accountName: vals.accountName, bank: vals.bank||"", accountNumber: vals.accountNumber||"", balance: parseFloat(vals.balance)||0, note:"", enteredBy: vals.enteredBy||"" });
  saveBankSheet();
  renderBank();
}
function renderBank(){
  const body = document.getElementById("bankBody");
  if(!body) return;
  const cardsWrap = document.getElementById("bankCards");
  const total = bankData.reduce((s,b)=>s+ (b.balance||0), 0);
  if(cardsWrap) cardsWrap.innerHTML = `
    <div class="stat" style="--accent:var(--c1); --tint:var(--t1)"><div class="stat-head"><span class="stat-ic">🏦</span><span class="stat-lbl">تعداد حساب‌ها</span></div><div class="stat-val">${fa(bankData.length)}</div></div>
    <div class="stat" style="--accent:var(--c2); --tint:var(--t2)"><div class="stat-head"><span class="stat-ic">💰</span><span class="stat-lbl">جمع نقدینگی</span></div><div class="stat-val">${formatMoney(total)}</div></div>
  `;
  const editableTd = (value, idx, field)=>
    `<td class="editable-cell" contenteditable="${editMode.bank?'true':'false'}" data-idx="${idx}" data-field="${field}" style="opacity:${editMode.bank?'1':'0.85'}; cursor:${editMode.bank?'text':'default'};">${escapeHtml(value==null?"":value)}</td>`;

  const bodyRows = bankData.map((b,idx)=>`<tr>
      <td>${fa(idx+1)}</td>
      ${editableTd(b.accountName, idx, "accountName")}
      ${editableTd(b.bank, idx, "bank")}
      ${editableTd(b.accountNumber, idx, "accountNumber")}
      ${editableTd(b.balance, idx, "balance")}
      ${editableTd(b.note, idx, "note")}
      ${editableTd(b.enteredBy, idx, "enteredBy")}
      <td><button class="btn-del" data-remove-bank="${idx}" ${editMode.bank?'':'disabled'} title="حذف">✕</button></td>
    </tr>`).join("");

  const addRow = `
    <tr class="add-row">
      <td>＋</td>
      <td><input type="text" id="newBankName" placeholder="نام حساب" style="width:100%;"></td>
      <td><input type="text" id="newBankBank" placeholder="بانک" style="width:100%;"></td>
      <td><input type="text" id="newBankNumber" placeholder="شماره حساب" style="width:100%;"></td>
      <td><input type="number" id="newBankBalance" placeholder="موجودی" style="width:100%;"></td>
      <td></td>
      <td><input type="text" id="newBankEnteredBy" placeholder="نام وارد کننده" style="width:100%;"></td>
      <td><button class="btn btn-brass btn-sm" id="addBankBtn">افزودن</button></td>
    </tr>`;

  body.innerHTML = (bodyRows || `<tr><td colspan="8" style="color:var(--ink-faint);">موردی پیدا نشد</td></tr>`) + addRow;

  body.querySelectorAll(".editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=> commitBankCell(parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim()));
  });
  body.querySelectorAll("[data-remove-bank]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این حساب حذف شود؟")) return;
      bankData.splice(parseInt(btn.getAttribute("data-remove-bank")),1);
      saveBankSheet();
      renderBank();
    });
  });
  const addBtn = document.getElementById("addBankBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const accountName = document.getElementById("newBankName").value.trim();
    if(!accountName){ alert("نام حساب را وارد کنید."); return; }
    addBankRow({
      accountName, bank: document.getElementById("newBankBank").value.trim(),
      accountNumber: document.getElementById("newBankNumber").value.trim(),
      balance: document.getElementById("newBankBalance").value,
      enteredBy: document.getElementById("newBankEnteredBy").value.trim()
    });
  });
}
function setupBank(){
  document.getElementById("refreshBankBtn").addEventListener("click", loadDatabase);
  const toggle = document.getElementById("editToggleBank");
  if(toggle) toggle.addEventListener("change", ()=>{ editMode.bank = toggle.checked; renderBank(); });
}

/* ================= Budget ================= */
function parseBudgetSheet(wb){
  const rows = sheetToMatrix(wb, "بودجه‌بندی");
  if(!rows) return [];
  const out = [];
  for(let r=1;r<rows.length;r++){
    const row = rows[r]||[];
    if(!row[1]) continue;
    out.push({ period: row[0]||"", category: row[1]||"", budgetAmount: parseFloat(row[2])||0, actualAmount: parseFloat(row[3])||0, enteredBy: row[4]||"" });
  }
  return out;
}
function budgetToAOA(){
  const header = ["دوره","دسته‌بندی","بودجه","هزینه‌ی واقعی","واردکننده"];
  const rows = budgetData.map(b=>[b.period||"", b.category||"", b.budgetAmount||0, b.actualAmount||0, b.enteredBy||""]);
  return [header, ...rows];
}
function saveBudgetSheet(){
  ensureDbWorkbook().Sheets["بودجه‌بندی"] = XLSX.utils.aoa_to_sheet(budgetToAOA());
  scheduleDbWrite();
}
function commitBudgetCell(idx, field, value){
  if(!budgetData[idx]) return;
  if(field==="budgetAmount" || field==="actualAmount") value = parseFloat(value)||0;
  budgetData[idx][field] = value;
  saveBudgetSheet();
  renderBudget();
}
function addBudgetRow(vals){
  budgetData.push({ period: vals.period||getTodayJalaliStr(), category: vals.category, budgetAmount: parseFloat(vals.budgetAmount)||0, actualAmount: parseFloat(vals.actualAmount)||0, enteredBy: vals.enteredBy||"" });
  saveBudgetSheet();
  renderBudget();
}
function renderBudget(){
  const body = document.getElementById("budgetBody");
  if(!body) return;
  const editableTd = (value, idx, field)=>
    `<td class="editable-cell" contenteditable="${editMode.budget?'true':'false'}" data-idx="${idx}" data-field="${field}" style="opacity:${editMode.budget?'1':'0.85'}; cursor:${editMode.budget?'text':'default'};">${escapeHtml(value==null?"":value)}</td>`;

  const bodyRows = budgetData.map((b,idx)=>{
    const variance = (b.budgetAmount||0) - (b.actualAmount||0);
    const varColor = variance>=0 ? "var(--green)" : "var(--red)";
    return `<tr>
      <td>${fa(idx+1)}</td>
      ${editableTd(b.period, idx, "period")}
      ${editableTd(b.category, idx, "category")}
      ${editableTd(b.budgetAmount, idx, "budgetAmount")}
      ${editableTd(b.actualAmount, idx, "actualAmount")}
      <td style="color:${varColor}; font-weight:700;">${formatMoney(variance)}</td>
      ${editableTd(b.enteredBy, idx, "enteredBy")}
      <td><button class="btn-del" data-remove-budget="${idx}" ${editMode.budget?'':'disabled'} title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  const addRow = `
    <tr class="add-row">
      <td>＋</td>
      <td><input type="text" id="newBudgetPeriod" placeholder="دوره" style="width:100%;"></td>
      <td><input type="text" id="newBudgetCategory" placeholder="دسته‌بندی" list="expenseCategoryOptions" style="width:100%;"></td>
      <td><input type="number" id="newBudgetAmount" placeholder="بودجه" style="width:100%;"></td>
      <td><input type="number" id="newBudgetActual" placeholder="هزینه‌ی واقعی" style="width:100%;"></td>
      <td></td>
      <td><input type="text" id="newBudgetEnteredBy" placeholder="نام وارد کننده" style="width:100%;"></td>
      <td><button class="btn btn-brass btn-sm" id="addBudgetBtn">افزودن</button></td>
    </tr>
    <datalist id="expenseCategoryOptions">${EXPENSE_CATEGORIES.map(c=>`<option value="${c}">`).join("")}</datalist>`;

  body.innerHTML = (bodyRows || `<tr><td colspan="8" style="color:var(--ink-faint);">موردی پیدا نشد</td></tr>`) + addRow;

  body.querySelectorAll(".editable-cell").forEach(td=>{
    td.addEventListener("blur", ()=> commitBudgetCell(parseInt(td.getAttribute("data-idx")), td.getAttribute("data-field"), td.textContent.trim()));
  });
  body.querySelectorAll("[data-remove-budget]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این ردیف بودجه حذف شود؟")) return;
      budgetData.splice(parseInt(btn.getAttribute("data-remove-budget")),1);
      saveBudgetSheet();
      renderBudget();
    });
  });
  const addBtn = document.getElementById("addBudgetBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const category = document.getElementById("newBudgetCategory").value.trim();
    if(!category){ alert("دسته‌بندی را وارد کنید."); return; }
    addBudgetRow({
      period: document.getElementById("newBudgetPeriod").value.trim(),
      category,
      budgetAmount: document.getElementById("newBudgetAmount").value,
      actualAmount: document.getElementById("newBudgetActual").value,
      enteredBy: document.getElementById("newBudgetEnteredBy").value.trim()
    });
  });
}
function setupBudget(){
  document.getElementById("refreshBudgetBtn").addEventListener("click", loadDatabase);
  const toggle = document.getElementById("editToggleBudget");
  if(toggle) toggle.addEventListener("change", ()=>{ editMode.budget = toggle.checked; renderBudget(); });
}
/* ================= Monthly Checklist + Daily Plan (per-month state) ================= */
const CATEGORIES = (window.KARTABL_JOB && window.KARTABL_JOB.categories)
  || ["صورت‌های مالی","مطالبات و وصول","پرداخت به تامین‌کنندگان","حقوق و دستمزد","مالیات و بیمه","بودجه و گزارش‌گیری","بانک و نقدینگی","سایر"];
const STATUS = ["انجام نشده","در حال انجام","انجام شد"];
const PRIORITY = ["بالا","متوسط","پایین"];

const DEFAULT_STATE = {
  meta: { month:"", year:"" },
  /* بخش «دیتای شخصی» خالی شروع می‌شود: بار اول که بازش کنید خودتان یک
     رمز جداگانه می‌گذارید و از همان لحظه محتوایش با AES رمز می‌شود. */
  personalVault: null,
  /* شغلِ انتخاب‌شده اگر چک‌لیستِ خودش را داشته باشد، همان می‌نشیند —
     مثل کارتابل عمومی. فقط برای کارتابلِ تازه: بعد از اولین ذخیره،
     داده مالِ کاربر است و این‌جا دیگر به آن دست نمی‌زند. */
  tasks: (window.KARTABL_JOB && Array.isArray(window.KARTABL_JOB.tasks))
    ? JSON.parse(JSON.stringify(window.KARTABL_JOB.tasks))
    : [],
  days: Array.from({length:25}, (_,i)=>({day:i+1, createdDate:"", main:"", meet:"", company:"", status:""})),
  monthsData: {},
  currentMonthKey: null
};

let state = null;
const STORE_KEY = "{{STORE}}";
const FILE_NAME = "{{FILEJSON}}";
let saveTimer = null;

function deepClone(o){ return JSON.parse(JSON.stringify(o)); }

async function writeStateToFolder(){
  if(!dirHandle) return;
  try{
    const fh = await dirHandle.getFileHandle(FILE_NAME, {create:true});
    const writable = await fh.createWritable();
    await writable.write(JSON.stringify(state));
    await writable.close();
  }catch(e){ console.error(e); }
}
function scheduleSave(){
  flashSaveHint("در حال ذخیره...");
  clearTimeout(saveTimer);
  saveTimer = setTimeout(async ()=>{
    try{
      localStorage.setItem(STORE_KEY, JSON.stringify(state));
      if(dirHandle) await writeStateToFolder();
      if(dirHandle){ saveTasksSheet(); saveDaysSheet(); }
      flashSaveHint("✓ ذخیره شد");
      /* نسخهٔ محلی نوشته شد؛ حالا همان را روی سرور هم بگذار */
      try{ Cloud.push(); }catch(e){ /* هنوز بالا نیامده */ }
    }catch(e){
      flashSaveHint("ذخیره ناموفق بود");
    }
  }, 500);
}

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
     بایت‌هاست. شاخهٔ جدا پیش‌فرض‌های پایین را رد می‌کرد — همان
     واگرایی که در کارتابل فنی نبود و این‌جا بود. */
  const seed = bkSeed();
  try{
    const raw = (seed && seed.state) ? JSON.stringify(seed.state) : localStorage.getItem(STORE_KEY);
    if(raw){
      const parsed = JSON.parse(raw);
      state = Object.assign(deepClone(DEFAULT_STATE), parsed);
      if(!state.tasks) state.tasks = [];
      if(!state.days || !Array.isArray(state.days) || !state.days.length) state.days = deepClone(DEFAULT_STATE.days);
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

/* ---------------- Monthly data helpers ---------------- */
function monthKeyOf(month, year){
  return (String(year||"").trim()||"?") + "|" + (String(month||"").trim()||"?");
}
function monthLabelOf(key){
  const parts = String(key).split("|");
  return (parts[1]||"") + " " + (parts[0]||"");
}
function ensureMonthsMigration(){
  if(!state.monthsData || typeof state.monthsData!=="object") state.monthsData = {};
  // the old unnamed placeholder month (from early versions, before a month was ever named) —
  // remove the key itself, but keep any real data it holds by merging it into the active month
  const stray = state.monthsData["?|?"];
  if(stray){
    delete state.monthsData["?|?"];
    if(state.currentMonthKey === "?|?") state.currentMonthKey = null;
  }
  if(!state.currentMonthKey || !state.monthsData[state.currentMonthKey]){
    if(!state.meta || !state.meta.month || !state.meta.year || state.meta.month==="?" || state.meta.year==="?"){
      const todayParts = getTodayJalaliStr().split("/");
      state.meta = { month: JALALI_MONTH_NAMES[parseInt(todayParts[1],10)-1], year: todayParts[0] };
    }
    const key = monthKeyOf(state.meta.month, state.meta.year);
    if(!state.monthsData[key]){
      state.monthsData[key] = { tasks: state.tasks, days: state.days };
    }
    state.currentMonthKey = key;
    state.tasks = state.monthsData[key].tasks;
    state.days = state.monthsData[key].days;
  }
  if(stray){
    const target = state.monthsData[state.currentMonthKey];
    if(stray.tasks && stray.tasks.length){
      target.tasks = (target.tasks||[]).concat(stray.tasks);
      state.tasks = target.tasks;
    }
    const strayDays = (stray.days||[]).filter(d=> d.main || d.meet || d.status || d.company);
    if(strayDays.length){
      target.days = (target.days||[]).concat(strayDays);
      state.days = target.days;
    }
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
  if(state.currentMonthKey) state.monthsData[state.currentMonthKey] = { tasks: state.tasks, days: state.days };

  if(state.monthsData[key]){
    state.tasks = state.monthsData[key].tasks;
    state.days = state.monthsData[key].days;
  } else {
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
   صدازننده (عوض کردنِ ماه و تغییرِ نامش). این دنباله در دو قالب فرق
   دارد، پس هر کدام مالِ خودش را دارد. */
function afterMonthChange(){
  renderMonthSelector();
  renderChecklistAndDaily();
  renderCards(); renderCharts();
  scheduleSave();
}
{{PART:monthpop}}
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

/* ---------------- Excel mirror for Tasks / DailyPlan (all months, Month column) ---------------- */
function tasksToAOA(){
  const header = ["ماه","دسته‌بندی","وظیفه","مسئول","مهلت","وضعیت","اولویت","یادداشت"];
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
  ensureDbWorkbook().Sheets["چک‌لیست ماهانه"] = XLSX.utils.aoa_to_sheet(tasksToAOA());
  scheduleDbWrite();
}
function daysToAOA(){
  const header = ["ماه","روز","تاریخ ثبت","وظایف اصلی","توضیحات","طرف‌حساب","وضعیت"];
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
  ensureDbWorkbook().Sheets["برنامه روزانه"] = XLSX.utils.aoa_to_sheet(daysToAOA());
  scheduleDbWrite();
}

/* ---------------- Checklist rendering ---------------- */
function computeChecklistStats(){
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
function renderChecklist(){
  const body = document.getElementById("checklistBody");
  if(!body) return;
  const catList = document.getElementById("taskCategoryOptions");
  if(catList){
    const uniqueCats = [...new Set([...CATEGORIES, ...state.tasks.map(t=>t.category).filter(Boolean)])];
    catList.innerHTML = uniqueCats.map(c=>`<option value="${escapeHtml(c)}">`).join("");
  }
  body.innerHTML = state.tasks.map((t,i)=>`
    <tr data-idx="${i}">
      <td>${fa(i+1)}</td>
      <td class="editable-text"><input type="text" data-field="category" value="${escapeHtml(t.category)}" list="taskCategoryOptions" placeholder="دسته‌بندی"></td>
      <td class="editable-text"><input type="text" data-field="task" value="${escapeHtml(t.task)}"></td>
      <td class="editable-text"><input type="text" data-field="owner" value="${escapeHtml(t.owner)}"></td>
      <td class="editable-text"><input type="number" data-field="deadline" value="${t.deadline!=null?t.deadline:''}" placeholder="روز"></td>
      <td>
        <select data-field="status">
          ${STATUS.map(s=>`<option value="${s}" ${t.status===s?"selected":""}>${s}</option>`).join("")}
        </select>
      </td>
      <td>
        <select data-field="priority">
          ${PRIORITY.map(p=>`<option value="${p}" ${t.priority===p?"selected":""}>${p}</option>`).join("")}
        </select>
      </td>
      <td class="editable-text"><input type="text" data-field="note" value="${escapeHtml(t.note)}"></td>
      <td><button class="star-btn ${t.reminder && !t.reminder.fired ? 'active':''}" data-star="${i}" title="${t.reminder && !t.reminder.fired ? 'یادآور تنظیم‌شده — برای تغییر کلیک کنید':'تنظیم یادآور'}">${t.reminder && !t.reminder.fired ? '⭐':'☆'}</button></td>
      <td><button class="btn-del" data-del="${i}" title="حذف">✕</button></td>
    </tr>
  `).join("") || `<tr><td colspan="10" style="color:var(--ink-faint);">وظیفه‌ای ثبت نشده — با دکمه‌ی «افزودن وظیفه» شروع کنید.</td></tr>`;

  body.querySelectorAll("[data-star]").forEach(btn=>{
    btn.addEventListener("click", ()=> openReminderSetter("task", parseInt(btn.getAttribute("data-star"))));
  });

  body.querySelectorAll("[data-field]").forEach(el=>{
    el.addEventListener("change", onTaskFieldChange);
    if(el.tagName==="INPUT") el.addEventListener("input", onTaskFieldChange);
  });
  body.querySelectorAll("[data-del]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const idx = parseInt(btn.getAttribute("data-del"));
      state.tasks.splice(idx,1);
      renderChecklist(); renderCards(); renderCharts();
      scheduleSave();
    });
  });
}
function onTaskFieldChange(e){
  const tr = e.target.closest("tr");
  const idx = parseInt(tr.getAttribute("data-idx"));
  const field = e.target.getAttribute("data-field");
  let val = e.target.value;
  if(field==="deadline") val = val==="" ? "" : parseInt(val);
  state.tasks[idx][field] = val;
  renderCards(); renderCharts();
  scheduleSave();
}
function setupChecklist(){
  const addBtn = document.getElementById("addTaskBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    state.tasks.push({category:CATEGORIES[0], task:"وظیفه جدید", owner:"", deadline:1, status:"انجام نشده", priority:"متوسط", note:""});
    renderChecklist(); renderCards(); renderCharts();
    scheduleSave();
  });
  const resetBtn = document.getElementById("resetTasksBtn");
  if(resetBtn) resetBtn.addEventListener("click", ()=>{
    if(confirm("چک‌لیست این ماه پاک شود؟ این کار قابل بازگشت نیست.")){
      state.tasks = [];
      renderChecklist(); renderCards(); renderCharts();
      scheduleSave();
    }
  });
}

/* ---------------- Daily plan rendering ---------------- */
let dailyFilters = { status: [], company: [] };
function renderDaily(){
  const body = document.getElementById("dailyBody");
  if(!body) return;
  const statusFilter = dailyFilters.status || [];
  const companyFilter = dailyFilters.company || [];
  const rowsToShow = state.days
    .map((d,i)=>({...d, idx:i}))
    .filter(d=> statusFilter.length===0 || statusFilter.includes(d.status))
    .filter(d=> companyFilter.length===0 || companyFilter.includes(d.company||""));
  const msfStatusEl = document.getElementById("msfDailyStatus");
  if(msfStatusEl) renderMultiFilter(msfStatusEl, STATUS, dailyFilters, "status", renderDaily);
  const msfPartyEl = document.getElementById("msfDailyParty");
  if(msfPartyEl) renderMultiFilter(msfPartyEl, state.days.map(d=>d.company).filter(Boolean), dailyFilters, "company", renderDaily);

  body.innerHTML = rowsToShow.map((d,displayIdx)=>`
    <tr data-idx="${d.idx}">
      <td><strong>${fa(displayIdx+1)}</strong></td>
      <td class="daily-date-cell">${escapeHtml(d.createdDate||"—")}</td>
      <td class="editable-text"><input type="text" data-field="main" value="${escapeHtml(d.main)}" placeholder="وظایف اصلی امروز"></td>
      <td class="editable-text"><input type="text" data-field="meet" value="${escapeHtml(d.meet)}" placeholder="توضیحات"></td>
      <td class="editable-text"><input type="text" data-field="company" value="${escapeHtml(d.company||'')}" placeholder="نام طرف‌حساب" list="dailyPartyOptions"></td>
      <td>
        <select data-field="status">
          <option value="" ${d.status===""?"selected":""}>—</option>
          ${STATUS.map(s=>`<option value="${s}" ${d.status===s?"selected":""}>${s}</option>`).join("")}
        </select>
      </td>
      <td><button class="star-btn ${d.reminder && !d.reminder.fired ? 'active':''}" data-day-star="${d.idx}" title="${d.reminder && !d.reminder.fired ? 'یادآور تنظیم‌شده — برای تغییر کلیک کنید':'تنظیم یادآور'}">${d.reminder && !d.reminder.fired ? '⭐':'☆'}</button></td>
      <td><button class="btn-del" data-remove-day="${d.idx}" title="حذف این ردیف">✕</button></td>
    </tr>
  `).join("") || `<tr><td colspan="8" style="color:var(--ink-faint);">موردی با این وضعیت پیدا نشد</td></tr>`;

  const partyNames = partiesData.map(p=>p.name);
  const dl = document.getElementById("dailyPartyOptions");
  if(dl) dl.innerHTML = partyNames.map(n=>`<option value="${escapeHtml(n)}">`).join("");

  body.querySelectorAll("[data-day-star]").forEach(btn=>{
    btn.addEventListener("click", ()=> openReminderSetter("day", parseInt(btn.getAttribute("data-day-star"))));
  });

  body.querySelectorAll("[data-field]").forEach(el=>{
    el.addEventListener("change", onDayFieldChange);
    if(el.tagName==="INPUT") el.addEventListener("input", onDayFieldChange);
  });
  body.querySelectorAll("[data-remove-day]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این ردیف از برنامه حذف شود؟")) return;
      const idx = parseInt(btn.getAttribute("data-remove-day"));
      state.days.splice(idx,1);
      renderDaily(); renderCharts();
      scheduleSave();
    });
  });
}
function addDayRow(){
  const maxDay = state.days.reduce((m,d)=> Math.max(m, parseInt(d.day)||0), 0);
  state.days.push({ day: maxDay+1, createdDate: getTodayJalaliStr(), main:"", meet:"", company:"", status:"" });
  renderDaily();
  scheduleSave();
}
function onDayFieldChange(e){
  const tr = e.target.closest("tr");
  const idx = parseInt(tr.getAttribute("data-idx"));
  const field = e.target.getAttribute("data-field");
  state.days[idx][field] = e.target.value;
  if(field==="status") renderCharts();
  scheduleSave();
}
function setupDaily(){
  const addBtn = document.getElementById("addDayRowBtn");
  if(addBtn) addBtn.addEventListener("click", addDayRow);
}
function renderChecklistAndDaily(){
  renderChecklist();
  renderDaily();
}


/* ================= Dashboard ================= */
let charts = {};
function destroyChart(key){ if(charts[key]){ charts[key].destroy(); delete charts[key]; } }

function computeFinanceStats(){
  const totalReceivable = invoicesData.filter(i=>i.status!=="پرداخت‌شده").reduce((s,i)=>s+Math.max(0,(i.amount||0)-(i.paid||0)),0);
  const totalPayable = payablesData.filter(p=>p.status!=="پرداخت‌شده").reduce((s,p)=>s+Math.max(0,(p.amount||0)-(p.paid||0)),0);
  const totalCash = bankData.reduce((s,b)=>s+(b.balance||0),0);
  const totalExpenses = expensesData.reduce((s,e)=>s+(e.amount||0),0);
  const overdueInvoices = invoicesData.filter(i=>i.status==="معوق").length;
  const overduePayables = payablesData.filter(p=>p.status==="معوق").length;
  return { totalReceivable, totalPayable, totalCash, totalExpenses, overdueInvoices, overduePayables };
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
      <div class="dh-sub">خلاصه‌ی وضعیت مالی امروز و این ماه، همه‌جا یک نگاه</div>
    </div>
    <div class="dh-date">امروز<b>${parts[2]?fa(parts[2]):""} ${monthName} ${parts[0]?fa(parts[0]):""}</b></div>
    <div class="dh-clock">ساعت اکنون<b id="dashHeroClock">--:--:--</b></div>
  `;
  updateLiveClock();
}

function renderCards(){
  const s = computeFinanceStats();
  const wrap = document.getElementById("statCards");
  if(!wrap) return;
  /* ترتیب رنگ‌ها ثابت است و با اعتبارسنجِ راهنما سنجیده شده: بدترین جفتِ
     کنار هم زیر کوررنگی ΔE ۱۴.۸ فاصله دارد. هر کارت برچسب متنی و آیکن
     خودش را هم دارد، پس هویتش هیچ‌وقت فقط به رنگ بند نیست. */
  const money = (ic, label, val, accent, tint) =>
    `<div class="stat" style="--accent:${accent}; --tint:${tint}">
       <div class="stat-head"><span class="stat-ic">${ic}</span><span class="stat-lbl">${label}</span></div>
       <div class="stat-val">${formatMoney(val)}</div>
       <div class="stat-sub">تومان</div>
     </div>`;

  /* «معوق» اندازه نیست، وضعیت است: صفرِ آن خبر خوب است و نباید قرمز
     نشان داده شود. رنگ هم تنها نشانه نیست — آیکن و متن هم هست. */
  const overdue = (label, count, clearText) => {
    const alert = count > 0;
    return `<div class="stat ${alert ? "is-alert" : "is-clear"}">
       <div class="stat-head"><span class="stat-ic">${alert ? "⚠️" : "✅"}</span><span class="stat-lbl">${label}</span></div>
       <div class="stat-val">${fa(count)}</div>
       <div class="stat-sub">${alert ? "نیاز به پیگیری" : clearText}</div>
     </div>`;
  };

  wrap.innerHTML =
    money("🧾", "کل مطالبات باز",        s.totalReceivable, "#0B9B95", "#E2F3F2") +
    money("💳", "کل بدهی باز",            s.totalPayable,    "#B07813", "#F8F0DC") +
    money("🧮", "جمع هزینه‌های ثبت‌شده", s.totalExpenses,   "#6A45A8", "#EDE7F5") +
    money("🏦", "موجودی نقدی کل",         s.totalCash,       "#1E7A4A", "#E3EFE7") +
    overdue("فاکتورهای معوق", s.overdueInvoices, "همه به‌موقع") +
    overdue("بدهی‌های معوق",  s.overduePayables, "چیزی عقب نیفتاده");
}
{{PART:charttone}}
async function renderCharts(){
  const ok = await chartLibPromise;
  const ids = ["chartChecklistStatus","chartDailyStatus","chartInvoiceStatus","chartPayableStatus","chartExpenseCategory","chartBudgetVsActual","chartBankBalances","chartTopDebtors"];
  if(!ok){
    ids.forEach(id=>{
      const el = document.getElementById(id);
      if(el) el.parentElement.innerHTML = `<p style="color:var(--ink-faint); font-size:12px;">نمودار بارگذاری نشد (اینترنت را بررسی کنید).</p>`;
    });
    return;
  }

  destroyChart("checklistStatus");
  (function(){
    const s = computeChecklistStats();
    charts.checklistStatus = new Chart(document.getElementById("chartChecklistStatus"), {
      type:"doughnut",
      data:{ labels:["انجام شد","در حال انجام","انجام نشده"], datasets:[{
        data:[s.done, s.doing, s.todo],
        backgroundColor:[chartTone().done, chartTone().doing, chartTone().todo],
        hoverBackgroundColor:chartHover([chartTone().done, chartTone().doing, chartTone().todo]),
        borderColor:chartTone().surface, borderWidth:2, hoverOffset:12
      }] },
      options:{
        layout:{padding:14}, cutout:"58%",
        plugins:{ legend:{position:"bottom", labels:{font:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}}},
          tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+ctx.label+": "+fa(ctx.parsed)} } },
        animation:{animateScale:true}, onHover:chartHoverCursor,
        onClick:(evt, elements)=>{
          if(!elements.length) return;
          const displayLabels = ["انجام شد","در حال انجام","انجام نشده"];
          const idx = elements[0].index;
          const items = state.tasks.filter(t=>t.status===displayLabels[idx]);
          openChartModal("چک‌لیست ماهانه — "+displayLabels[idx], "✅", items, renderTaskModalItem);
        }
      }
    });
  })();

  destroyChart("dailyStatus");
  (function(){
    const d = computeDailyStats();
    charts.dailyStatus = new Chart(document.getElementById("chartDailyStatus"), {
      type:"doughnut",
      data:{ labels:["انجام شد","در حال انجام","انجام نشده","بدون وضعیت"], datasets:[{
        data:[d.doneDays, d.doingDays, d.todoDays, d.emptyDays],
        backgroundColor:[chartTone().done, chartTone().doing, chartTone().todo, chartTone().none],
        hoverBackgroundColor:chartHover([chartTone().done, chartTone().doing, chartTone().todo, chartTone().none]),
        borderColor:chartTone().surface, borderWidth:2, hoverOffset:12
      }] },
      options:{
        layout:{padding:14}, cutout:"58%",
        plugins:{ legend:{position:"bottom", labels:{font:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}}},
          tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+ctx.label+": "+fa(ctx.parsed)+" روز"} } },
        animation:{animateScale:true}, onHover:chartHoverCursor,
        onClick:(evt, elements)=>{
          if(!elements.length) return;
          const displayLabels = ["انجام شد","در حال انجام","انجام نشده","بدون وضعیت"];
          const idx = elements[0].index;
          const items = idx===3 ? state.days.filter(dd=>!dd.status) : state.days.filter(dd=>dd.status===displayLabels[idx]);
          openChartModal("برنامه روزانه — "+displayLabels[idx], "🗓️", items, renderDayModalItem);
        }
      }
    });
  })();

  destroyChart("invoiceStatus");
  (function(){
    const counts = INVOICE_STATUS.map(s=> invoicesData.filter(i=>i.status===s).length);
    charts.invoiceStatus = new Chart(document.getElementById("chartInvoiceStatus"), {
      type:"doughnut",
      data:{ labels:INVOICE_STATUS, datasets:[{
        data:counts, backgroundColor:[chartTone().done, chartTone().todo, chartTone().bad],
        hoverBackgroundColor:chartHover([chartTone().done, chartTone().todo, chartTone().bad]),
        borderColor:chartTone().surface, borderWidth:2, hoverOffset:12
      }] },
      options:{
        layout:{padding:14}, cutout:"58%",
        plugins:{ legend:{position:"bottom", labels:{font:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}}},
          tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+ctx.label+": "+fa(ctx.parsed)} } },
        animation:{animateScale:true}, onHover:chartHoverCursor,
        onClick:(evt, elements)=>{
          if(!elements.length) return;
          const status = INVOICE_STATUS[elements[0].index];
          openChartModal("فاکتورها — "+status, "🧾", invoicesData.filter(i=>i.status===status), renderInvoiceModalItem);
        }
      }
    });
  })();

  destroyChart("payableStatus");
  (function(){
    const projects = [...new Set(payablesData.map(p=>p.project||"بدون پروژه"))];
    const sums = projects.map(pr=> payablesData.filter(p=>(p.project||"بدون پروژه")===pr).reduce((s,p)=>s+(p.amount||0),0));
    charts.payableStatus = new Chart(document.getElementById("chartPayableStatus"), {
      type:"bar",
      data:{ labels:projects, datasets:[{ data:sums, backgroundColor:chartTone().cat[0], hoverBackgroundColor:chartHover([chartTone().cat[0]])[0], borderRadius:4 }] },
      options:{
        indexAxis:"y",
        plugins:{ legend:{display:false}, tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+formatMoney(ctx.parsed.x)} } },
        scales:{ x:{ ticks:{ callback:v=>fa(v) } }, y:{ ticks:{ font:{family:"Vazirmatn, Tahoma, Arial, sans-serif", size:11} } } },
        onHover:chartHoverCursor,
        onClick:(evt, elements)=>{
          if(!elements.length) return;
          const project = projects[elements[0].index];
          openChartModal("بدهی‌ها — پروژه‌ی "+project, "💳", payablesData.filter(p=>(p.project||"بدون پروژه")===project), renderPayableModalItem);
        }
      }
    });
  })();

  destroyChart("expenseCategory");
  (function(){
    const cats = [...new Set(expensesData.map(e=>e.category).filter(Boolean))];
    const sums = cats.map(c=> expensesData.filter(e=>e.category===c).reduce((s,e)=>s+(e.amount||0),0));
    charts.expenseCategory = new Chart(document.getElementById("chartExpenseCategory"), {
      type:"bar",
      data:{ labels:cats, datasets:[{ data:sums, backgroundColor:chartTone().cat[1], hoverBackgroundColor:chartHover([chartTone().cat[1]])[0], borderRadius:4 }] },
      options:{
        indexAxis:"y",
        plugins:{ legend:{display:false}, tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+formatMoney(ctx.parsed.x)} } },
        scales:{ x:{ ticks:{ callback:v=>fa(v) } }, y:{ ticks:{ font:{family:"Vazirmatn, Tahoma, Arial, sans-serif", size:11} } } },
        onHover:chartHoverCursor,
        onClick:(evt, elements)=>{
          if(!elements.length) return;
          const cat = cats[elements[0].index];
          openChartModal("هزینه‌ها — "+cat, "🧮", expensesData.filter(e=>e.category===cat), renderExpenseModalItem);
        }
      }
    });
  })();

  destroyChart("budgetVsActual");
  (function(){
    const cats = [...new Set(budgetData.map(b=>b.category).filter(Boolean))];
    const budgetSums = cats.map(c=> budgetData.filter(b=>b.category===c).reduce((s,b)=>s+(b.budgetAmount||0),0));
    const actualSums = cats.map(c=> budgetData.filter(b=>b.category===c).reduce((s,b)=>s+(b.actualAmount||0),0));
    charts.budgetVsActual = new Chart(document.getElementById("chartBudgetVsActual"), {
      type:"bar",
      data:{ labels:cats, datasets:[
        { label:"بودجه", data:budgetSums, backgroundColor:chartTone().cat[0], borderRadius:4 },
        { label:"هزینه‌ی واقعی", data:actualSums, backgroundColor:chartTone().cat[1], borderRadius:4 }
      ] },
      options:{
        plugins:{ legend:{position:"bottom", labels:{font:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}}},
          tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+ctx.dataset.label+": "+formatMoney(ctx.parsed.y)} } },
        scales:{ y:{ ticks:{ callback:v=>fa(v) } }, x:{ ticks:{ font:{family:"Vazirmatn, Tahoma, Arial, sans-serif"} } } }
      }
    });
  })();

  destroyChart("bankBalances");
  (function(){
    charts.bankBalances = new Chart(document.getElementById("chartBankBalances"), {
      type:"bar",
      data:{ labels:bankData.map(b=>b.accountName), datasets:[{ data:bankData.map(b=>b.balance||0), backgroundColor:chartTone().cat[2], hoverBackgroundColor:chartHover([chartTone().cat[2]])[0], borderRadius:4 }] },
      options:{
        indexAxis:"y",
        plugins:{ legend:{display:false}, tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+formatMoney(ctx.parsed.x)} } },
        scales:{ x:{ ticks:{ callback:v=>fa(v) } }, y:{ ticks:{ font:{family:"Vazirmatn, Tahoma, Arial, sans-serif", size:11} } } }
      }
    });
  })();

  destroyChart("topDebtors");
  (function(){
    const byCustomer = {};
    invoicesData.filter(i=>i.status!=="پرداخت‌شده").forEach(i=>{
      byCustomer[i.customer] = (byCustomer[i.customer]||0) + Math.max(0,(i.amount||0)-(i.paid||0));
    });
    const paired = Object.entries(byCustomer).map(([customer,remaining])=>({customer,remaining})).sort((a,b)=>b.remaining-a.remaining).slice(0,8);
    charts.topDebtors = new Chart(document.getElementById("chartTopDebtors"), {
      type:"bar",
      data:{ labels:paired.map(p=>p.customer), datasets:[{ data:paired.map(p=>p.remaining), backgroundColor:chartTone().cat[3], hoverBackgroundColor:chartHover([chartTone().cat[3]])[0], borderRadius:4 }] },
      options:{
        indexAxis:"y",
        plugins:{ legend:{display:false}, tooltip:{ bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+formatMoney(ctx.parsed.x)} } },
        scales:{ x:{ ticks:{ callback:v=>fa(v) } }, y:{ ticks:{ font:{family:"Vazirmatn, Tahoma, Arial, sans-serif", size:11} } } },
        onHover:chartHoverCursor,
        onClick:(evt, elements)=>{
          if(!elements.length) return;
          openChartModal("مطالبات باز", "👥", [paired[elements[0].index]], renderDebtorModalItem);
        }
      }
    });
  })();
}

function renderEverything(){
  renderDashHero();
  renderCards();
  renderCharts();
  renderChecklistAndDaily();
  renderParties();
  renderInvoices();
  renderPayables();
  renderPayableNotes();
  renderReceivableNotes();
  renderExpenses();
  renderBank();
  renderBudget();
}
{{PART:noautofill}}
/* ================= Navigation & init ================= */
function setupNav(){
  document.querySelectorAll(".navbtn").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      document.querySelectorAll(".navbtn").forEach(b=>b.classList.remove("active"));
      btn.classList.add("active");
      const view = btn.getAttribute("data-view");
      document.querySelectorAll(".view").forEach(v=>v.classList.remove("active"));
      document.getElementById("view-"+view).classList.add("active");
      if(view==="dashboard"){ renderDashHero(); renderCards(); renderCharts(); }
      /* بخش شخصی هر بار که باز می‌شود دوباره کشیده می‌شود: اگر قفل باشد
         صفحهٔ رمز و اگر باز باشد محتوایش. */
      if(view==="personal") renderPersonalView();
    });
  });
}

function daysInJalaliMonth(year, month){
  if(month>=1 && month<=6) return 31;
  if(month>=7 && month<=11) return 30;
  return JALALI_LEAP_YEARS.has(year) ? 30 : 29; // month 12 - اسفند
}
function jalaliMonthDayOptions(year, month, selectedDay){
  const n = daysInJalaliMonth(year, month);
  let out = "";
  for(let d=1; d<=n; d++) out += `<option value="${d}" ${d===selectedDay?"selected":""}>${fa(d)}</option>`;
  return out;
}
function getTodayJalaliParts(){
  const str = getTodayJalaliStr();
  const p = str.split("/");
  const monthNames = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور","مهر","آبان","آذر","دی","بهمن","اسفند"];
  return { year: p[0]||"", monthNum: p[1]?parseInt(p[1],10):0, day: p[2]?parseInt(p[2],10):0, monthName: p[1] ? monthNames[parseInt(p[1],10)-1] : "" };
}
function fillJalaliMonthSelect(sel, curM){
  sel.innerHTML = JALALI_MONTH_NAMES.map((m,i)=>`<option value="${i+1}" ${i+1===curM?"selected":""}>${m}</option>`).join("");
}
function fillJalaliYearSelect(sel, curY){
  sel.innerHTML = "";
  for(let y=1370; y<=curY+10; y++) sel.innerHTML += `<option value="${y}" ${y===curY?"selected":""}>${fa(y)}</option>`;
}
function formatJalaliLong(y,m,d){
  return `${fa(d)} ${JALALI_MONTH_NAMES[m-1]} ${fa(y)}`;
}
function formatGregorianLong(y,m,d){
  const names = ["January","February","March","April","May","June","July","August","September","October","November","December"];
  return `${d} ${names[m-1]} ${y}`;
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
{{PART:jalali}}
function dbSnapshot(){
  return {
    parties: partiesData, invoices: invoicesData, payables: payablesData,
    /* این دو در نسخهٔ قبلی از قلم افتاده بودند: در حافظهٔ محلی ذخیره
       نمی‌شدند و با هر بار باز کردن صفحه از بین می‌رفتند. */
    payableNotes: payableNotesData, receivableNotes: receivableNotesData,
    expenses: expensesData, bank: bankData, budget: budgetData
  };
}

function applyDbSnapshot(c){
  if(!c) return;
  partiesData = c.parties || [];
  invoicesData = c.invoices || [];
  payablesData = c.payables || [];
  payableNotesData = c.payableNotes || [];
  receivableNotesData = c.receivableNotes || [];
  expensesData = c.expenses || [];
  bankData = c.bank || [];
  budgetData = c.budget || [];
}
{{PART:cloudsync}}
      online = true; blocked = false;
      rev = srvRev;
      if(r.data.state){
        state = Object.assign(deepClone(DEFAULT_STATE), r.data.state);
        /* جای خالی را فقط وقتی با نمونه پر می‌کنیم که سرور اصلاً چیزی
           نداشته باشد؛ وگرنه ردیف‌های نمونه روی دادهٔ واقعی نوشته می‌شوند. */
        if(srvRev === 0 && (!state.days || !Array.isArray(state.days) || !state.days.length))
          state.days = deepClone(DEFAULT_STATE.days);
        if(!Array.isArray(state.tasks)) state.tasks = [];
        if(!Array.isArray(state.days)) state.days = [];
        ensureMonthsMigration();
        try{ localStorage.setItem(STORE_KEY, JSON.stringify(state)); }catch(e){}
      }
      if(r.data.db){
        applyDbSnapshot(r.data.db);
        try{ persistCache(); }catch(e){}
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
{{PART:vault}}
/* گرفتن و برگرداندن فایل پشتیبان JSON. کارتابل مالی این دو دکمه را
   نداشت و تنها راه بیرون بردن داده، «اتصال به پوشه» بود که فقط در
   کروم کار می‌کند. */
function setupToolbar(){
  const ex = document.getElementById("exportBtn");
  if(ex) ex.addEventListener("click", ()=>{
    const blob = new Blob([JSON.stringify(state, null, 1)], {type:"application/json"});
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = FILE_NAME;
    a.click();
    setTimeout(()=> URL.revokeObjectURL(a.href), 4000);
  });
  const im = document.getElementById("importBtn");
  const file = document.getElementById("importFile");
  if(im && file){
    im.addEventListener("click", ()=> file.click());
    file.addEventListener("change", (e)=>{
      const f = e.target.files[0];
      if(!f) return;
      const reader = new FileReader();
      reader.onload = ()=>{
        try{
          state = Object.assign(deepClone(DEFAULT_STATE), JSON.parse(reader.result));
          ensureMonthsMigration();
          renderMonthSelector();
          renderEverything();
          renderPersonalView();
          scheduleSave();
          alert("بازیابی با موفقیت انجام شد.");
        }catch(err){ alert("فایل پشتیبان معتبر نیست."); }
      };
      reader.readAsText(f);
      e.target.value = "";
    });
  }
}


/* ---------- تم روز و شب ----------
   انتخاب هر پلنر جداست و در حافظهٔ همان مرورگر می‌ماند. پیش‌فرض روز است
   تا چیزی بی‌خبر عوض نشود؛ تا وقتی دکمه را نزنید همان شکل قبلی می‌ماند. */
const THEME_KEY = STORE_KEY + ":theme";

function currentTheme(){
  return document.documentElement.getAttribute("data-theme") === "dark" ? "dark" : "light";
}

function redrawAfterTheme(){ renderEverything(); }
{{PART:theme}}
/* ---------- دستیار هوشمند ----------
   گفتگو در حافظهٔ همین مرورگر می‌ماند (هر کارتابل کلیدِ خودش را دارد) و
   هر بار چند پیامِ آخر همراه سؤال بالا می‌رود تا دستیار رشتهٔ حرف را گم
   نکند. متنِ داده‌های کارتابل را سرور خودش می‌سازد؛ این‌جا فقط تاریخِ
   امروز را می‌فرستیم تا سررسیدگذشته‌ها را درست تشخیص بدهد. */
const AI_KEY = STORE_KEY + ":ai";
const AI_TIPS = ["جمع بدهی‌های سررسیدگذشته چقدر است؟",
  "فاکتورهای وصول‌نشده را فهرست کن",
  "خلاصه‌ی وضعیت مالی این ماه را بگو",
  "بودجه با هزینه‌ی واقعی چقدر اختلاف دارد؟",
  "یک نامه‌ی مودبانه برای پیگیری طلب بنویس"];
{{PART:tablesize}}
{{PART:cellpop}}

{{PART:reportjs}}

{{PART:aiassist}}
async function init(){
  try{
    await loadState();
    loadCachedDatabase();
    /* نسخهٔ محلی فقط برای این است که صفحه فوری بالا بیاید؛ مرجع سرور
       است. منتظر می‌مانیم تا تکلیف ورود روشن شود، بعد داده را می‌گیریم. */
    try{ if(gateReady) await gateReady; }catch(e){}
    if(signedIn){
      try{ await Cloud.pull(); }catch(e){ /* آفلاین — با نسخهٔ محلی ادامه */ }
    }
    /* هر کدام جدا: اگر یکی بخورد زمین، بقیهٔ کارتابل نباید با آن برود. */
    [renderMonthSelector, setupNav, setupMeta, setupChartModal, setupDateTools, setupChecklist,
     setupDaily, setupReminders, setupParties, setupInvoices, setupPayables,
     setupPayableNotes, setupReceivableNotes, setupExpenses, setupBank,
     setupBudget, setupSettings, setupToolbar, setupTheme, setupAssistant,
     setupAiSettings, showLastLogin, showExpiryWarning, renderPersonalView,
     ()=>{ const cf = document.getElementById("connectFolderBtn");
           if(cf) cf.addEventListener("click", connectFolder); },
     renderEverything, setupShared, setupNoAutofill
    ].forEach(fn=>{ try{ fn(); }catch(e){ console.error("راه‌اندازی "+(fn.name||"")+":", e); } });
  }catch(e){
    console.error("خطا در راه‌اندازی کارتابل مالی:", e);
  }finally{
    document.getElementById("loadingScreen").style.display = "none";
  }
  try{ tryReconnectFolder(); }catch(e){ /* folder sync is optional */ }
}

init();
</script>
</body>
</html>
