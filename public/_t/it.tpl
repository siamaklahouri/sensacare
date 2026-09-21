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
/* بخش‌هایی که ادمین برای این کاربر بسته است. */
window.KARTABL_OFF = {{FEATOFF}};
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
<style>
/* ---------- صفحهٔ ورود کارتابل ----------
   کارتابل روی یک آدرس عمومی نشسته، پس بدون رمز باز نمی‌شود.
   این توضیح یک بار عوض شده: اولش قفل و داده هر دو سمتِ مرورگر بودند،
   ولی از وقتی کارتابل روی سرور نشست هر دو منتقل شدند. حالا:

   • بررسی رمز سمتِ سرور انجام می‌شود، نه اینجا. خودِ رمز هیچ‌جا ذخیره
     نشده؛ آن‌چه نگه داشته شده حاصلِ PBKDF2-SHA256 است. تعداد دورش
     ۱۰۰٬۰۰۰ است، نه بیشتر، چون سقفِ کلادفلر روی Workers همین است و
     بالاتر از آن خطا می‌دهد (این یک بار زنده ما را زمین زد؛ محلی اجرا
     می‌شد ولی روی سرور نه). تلاشِ ورود هم محدود است: ده بار در ربع ساعت.
   • بعد از ورود یک کوکیِ HttpOnly و امضاشده گذاشته می‌شود — یک روز، و
     با «مرا به خاطر بسپار» سی روز. نامِ کارتابل داخلِ خودِ کوکی است، پس
     کوکیِ یک کارتابل کارتابلِ دیگر را باز نمی‌کند.
   • دادهٔ کارتابل روی سرور است، پس این لایه تزئینی نیست: بدون نشستِ
     معتبر هیچ داده‌ای از سرور بیرون نمی‌آید.

   تنها چیزی که هنوز سمتِ مرورگر رمزنگاری می‌شود «دیتای شخصی» است؛ آن
   با کلیدِ جداگانهٔ خودتان قفل می‌شود و سرور فقط متنِ رمزشده را می‌بیند. */
#gateScreen{
  position:fixed; inset:0; z-index:9999;
  display:flex; align-items:center; justify-content:center; padding:20px;
  background:
    radial-gradient(900px 420px at 100% -10%, rgba(14,139,139,.18), transparent 60%),
    linear-gradient(135deg, #0A2143 0%, #123258 55%, #0F3D54 120%);
}
#gateScreen[hidden]{ display:none; }
.gate-card{
  width:100%; max-width:360px; background:var(--white); border-radius:16px;
  padding:26px 24px 22px; box-shadow:0 20px 50px rgba(6,20,40,.35);
  text-align:center;
}
.gate-card h2{ font-family:var(--font-display); font-size:18px; margin:0 0 6px; color:var(--ink); }
.gate-card p{ margin:0 0 18px; font-size:12px; color:var(--ink-faint); line-height:1.9; }
.gate-card .lock-ic{ font-size:32px; display:block; margin-bottom:10px; }
.gate-card input[type="password"]{
  font-family:var(--font-body); font-size:14px; width:100%; text-align:center;
  padding:11px 12px; border:1px solid var(--line); border-radius:10px;
  background:var(--paper); color:var(--ink); letter-spacing:.5px;
}
.gate-card input[type="password"]:focus{ outline:none; border-color:var(--brass); background:var(--white); }
.gate-card button[type="submit"]{
  font-family:var(--font-body); font-size:14px; font-weight:600; cursor:pointer;
  width:100%; margin-top:12px; padding:11px 12px; border:0; border-radius:10px;
  background:var(--brass); color:#fff;
}
.gate-card button[type="submit"]:disabled{ opacity:.6; cursor:default; }
.gate-remember{
  display:flex; align-items:center; justify-content:center; gap:7px;
  margin-top:12px; font-size:12px; color:var(--ink-soft); cursor:pointer;
}
.gate-err{ margin-top:12px; min-height:17px; font-size:12px; font-weight:600; color:var(--red-ink); }
.gate-note{ margin-top:6px; font-size:12px; font-weight:600; color:var(--green-ink); line-height:1.9; }
.gate-forgot{
  margin-top:8px; background:none; border:0; padding:4px;
  font-family:var(--font-body); font-size:12px; color:var(--ink-faint);
  cursor:pointer; text-decoration:underline; text-underline-offset:3px;
}
.gate-forgot:hover{ color:var(--brass); }
.gate-forgot:disabled{ cursor:default; opacity:.6; text-decoration:none; }
</style>
<style>
  :root{
    --paper:#EEF2F6;
    --paper-deep:#E2E8EE;
    --ink:#0B2545;
    --ink-soft:#3E5164;
    --ink-faint:#8592A0;
    --brass:#0E8B8B;
    --brass-deep:#0B6E6E;
    --brass-bg:#E3F4F3;
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
    --brass-ink:#0B6E6E;
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

  /* ---------- Top bar ---------- */
  .topbar{
    height:70px;
    background:linear-gradient(135deg, #0A2143 0%, #123258 55%, #0F3D54 120%);
    color:#fff;
    display:flex;
    align-items:center;
    justify-content:space-between;
    padding:0 28px;
    box-shadow:0 4px 20px rgba(6,20,40,.25);
    position:sticky; top:0; z-index:40;
    border-bottom:1px solid rgba(255,255,255,.06);
  }
  .brand{ display:flex; align-items:center; gap:12px; }
  .brand .mark{
    height:40px; width:auto; display:block;
    filter:drop-shadow(0 1px 3px rgba(0,0,0,.35));
  }
  .brand .titles{ line-height:1.15; }
  .brand h1{ font-family:var(--font-display); font-size:18px; margin:0; font-weight:700; letter-spacing:.2px; }
  .brand small{ color:#B9C6D6; font-size:11.5px; }
  .period{ display:flex; align-items:center; gap:8px; }
  .period input{
    font-family:var(--font-body); font-size:13px;
    background:rgba(255,255,255,.08); border:1px solid rgba(255,255,255,.22);
    color:#fff; border-radius:7px; padding:7px 10px; width:88px; text-align:center;
  }
  .period input::placeholder{ color:#B9C3CE; }
  .period label{ font-size:12px; color:#C9D2DC; }
  .period select{
    font-family:var(--font-body); font-size:13px;
    background:rgba(255,255,255,.08); border:1px solid rgba(255,255,255,.22);
    color:#fff; border-radius:7px; padding:7px 10px; min-width:120px; text-align:center;
  }
  .period select option{ color:#0B2545; }
  .new-month-panel{
    display:flex; align-items:center; gap:8px; justify-content:flex-end; flex-wrap:wrap;
    padding:10px 32px; background:rgba(11,37,69,.94); border-bottom:1px solid rgba(255,255,255,.15);
  }
  .new-month-panel input{
    font-family:var(--font-body); font-size:12.5px; background:var(--white); border:1px solid var(--card-border);
    color:var(--ink); border-radius:7px; padding:6px 10px; width:130px; text-align:center;
  }

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
  .navbtn .ic{
    font-size:14.5px; width:28px; height:28px; border-radius:9px; flex:0 0 28px;
    display:flex; align-items:center; justify-content:center;
    background:rgba(11,37,69,.06); transition:background .15s, transform .15s;
  }
  .navbtn:hover{ background:rgba(11,37,69,.055); transform:translateX(-2px); }
  .navbtn:hover .ic{ transform:scale(1.05); }
  .navbtn.active{
    background:linear-gradient(120deg,var(--deep),#173B5C); color:#fff; box-shadow:0 6px 16px rgba(11,37,69,.26);
  }
  .navbtn.active .ic{ background:var(--brass); box-shadow:0 2px 6px rgba(14,139,139,.4); }
  .navbtn.active::before{
    content:""; position:absolute; right:-14px; top:50%; transform:translateY(-50%);
    width:4px; height:22px; border-radius:3px; background:var(--brass);
  }
  .navbtn-lock.active{ background:linear-gradient(120deg,#5B3E8C,#3E2A63); }
  .navbtn-lock.active .ic{ background:#8163C0; box-shadow:0 2px 6px rgba(91,62,140,.45); }
  .navbtn-lock.active::before{ background:#8163C0; }
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
  .cards{
    display:grid; grid-template-columns:repeat(auto-fit, minmax(148px,1fr)); gap:12px; margin-bottom:22px;
  }
  .stat{
    border-radius:var(--radius); padding:16px 15px; color:#fff; box-shadow:0 4px 14px rgba(11,37,69,.14);
    position:relative; overflow:hidden; transition:transform .2s, box-shadow .2s;
    animation:statIn .4s ease backwards;
  }
  .stat:nth-child(1){ animation-delay:.02s; }
  .stat:nth-child(2){ animation-delay:.07s; }
  .stat:nth-child(3){ animation-delay:.12s; }
  .stat:nth-child(4){ animation-delay:.17s; }
  .stat:nth-child(5){ animation-delay:.22s; }
  .stat:nth-child(6){ animation-delay:.27s; }
  @keyframes statIn{ from{opacity:0; transform:translateY(8px);} to{opacity:1; transform:none;} }
  .stat::after{
    content:attr(data-ic); position:absolute; left:-6px; bottom:-14px; font-size:56px; opacity:.16;
    line-height:1; pointer-events:none; transform:rotate(-8deg);
  }
  .stat:hover{ transform:translateY(-3px); box-shadow:0 12px 26px rgba(11,37,69,.24); }

  .dash-hero{
    background:linear-gradient(120deg,#0A2143 0%,#173B5C 52%,var(--brass-deep) 128%);
    border-radius:var(--radius); padding:20px 24px; margin-bottom:18px; color:#fff;
    display:flex; align-items:center; justify-content:space-between; gap:14px; flex-wrap:wrap;
    box-shadow:0 10px 30px rgba(11,37,69,.22); position:relative; overflow:hidden;
  }
  .dash-hero::after{
    content:""; position:absolute; inset:0; pointer-events:none;
    background:radial-gradient(600px 200px at 90% -40%, rgba(255,255,255,.10), transparent 70%);
  }
  .dash-hero::before{
    content:"🗂️"; position:absolute; font-size:120px; opacity:.08; left:-12px; bottom:-34px; transform:rotate(-12deg);
  }
  .dash-hero .dh-greet{ font-family:var(--font-display); font-size:16px; font-weight:700; position:relative; z-index:1; }
  .dash-hero .dh-sub{ font-size:11.5px; opacity:.85; margin-top:4px; position:relative; z-index:1; }
  .dash-hero .dh-date{
    background:rgba(255,255,255,.12); border:1px solid rgba(255,255,255,.22); border-radius:12px;
    padding:9px 18px; font-size:11px; font-weight:600; text-align:center; position:relative; z-index:1;
    backdrop-filter:blur(3px); opacity:.92; width:132px; box-sizing:border-box;
  }
  .dash-hero .dh-date b{
    display:block; font-family:var(--font-display); font-size:14.5px; margin-top:4px; font-weight:700;
  }
  .dash-hero .dh-clock{
    background:rgba(255,255,255,.16); border:1px solid rgba(217,168,86,.55); border-radius:12px;
    padding:9px 18px; font-size:11px; font-weight:600; text-align:center; position:relative; z-index:1;
    backdrop-filter:blur(3px); width:132px; box-sizing:border-box;
    box-shadow:0 0 0 1px rgba(255,255,255,.05) inset, 0 4px 14px rgba(0,0,0,.15);
  }
  .dash-hero .dh-clock b{
    display:block; font-family:var(--font-display); font-size:19px; margin-top:4px;
    letter-spacing:1.5px; font-variant-numeric:tabular-nums; color:#F5D48A; font-weight:700;
    white-space:nowrap;
  }
  .topbar-clock{
    font-family:var(--font-display); font-size:13.5px; font-weight:700; color:#F5D48A;
    background:rgba(255,255,255,.08); border:1px solid rgba(217,168,86,.4);
    border-radius:20px; padding:7px 4px; letter-spacing:1px; margin-inline-end:6px;
    display:inline-block; width:104px; box-sizing:border-box; text-align:center;
    font-variant-numeric:tabular-nums; white-space:nowrap;
  }

  /* ---------- Reminders banner ---------- */
  .reminders-banner{ display:flex; flex-direction:column; gap:8px; margin-bottom:16px; }
  .reminder-item{
    display:flex; align-items:center; gap:10px; padding:10px 14px; border-radius:10px;
    background:#FFF6E0; border:1px solid #E9CE8A; font-size:12.5px; color:var(--ink);
  }
  .reminder-item.overdue{ background:#FDEAEA; border-color:#E9A5A5; }
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
    color:#C9BE9E; transition:transform .12s;
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
    padding:7px 4px; font-family:var(--font-body); font-size:12.5px; color:var(--ink); background:#F9F7F1;
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
    0%{ background:#DFF3DF; } 100%{ background:transparent; }
  }
  .visit-add-confirm{ font-size:11.5px; color:#2E7D32; font-weight:600; margin-inline-start:8px; }

  .dash-group-label{
    display:flex; align-items:center; gap:8px; font-size:12.5px; font-weight:700; color:var(--ink-soft);
    margin:20px 0 10px; padding-bottom:6px; border-bottom:1px dashed var(--card-border);
  }
  .dash-group-label .dgl-ic{ font-size:15px; }

  .panel.accent-blue{ border-top:3px solid #2A5C8A; }
  .panel.accent-amber{ border-top:3px solid #B8862B; }
  .panel.accent-teal{ border-top:3px solid #128075; }
  .stat .lbl{ font-size:11.5px; font-weight:600; opacity:.92; display:flex; align-items:center; gap:6px; position:relative; z-index:1; }
  .stat .val{ font-family:var(--font-display); font-size:31px; font-weight:700; margin-top:9px; position:relative; z-index:1; }
  .stat .sub{ font-size:11px; font-weight:600; opacity:.82; margin-top:2px; position:relative; z-index:1; }
  .stat.blue{ background:linear-gradient(155deg,#2A5C8A,#173B5C); }
  .stat.green{ background:linear-gradient(155deg,#458A47,#2A5A2C); }
  .stat.teal{ background:linear-gradient(155deg,#128075,#0B534A); }
  .stat.amber{ background:linear-gradient(155deg,#D69A2B,#93690F); }
  .stat.red{ background:linear-gradient(155deg,#C42E37,#821B21); }
  .stat.purple{ background:linear-gradient(155deg,#7A52A8,#4C3169); }

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
    margin-top:14px; padding:12px 14px; background:#F9F6EC; border:1px solid var(--card-border); border-radius:10px;
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
  .chart-box{ position:relative; width:100%; height:250px; margin-top:4px; }
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
  thead th{
    background:linear-gradient(120deg,var(--deep) 0%,#173B5C 100%); color:#fff; font-weight:600; padding:9px 6px; text-align:center;
    position:sticky; top:0; font-size:11.5px; letter-spacing:.2px;
  }
  .tbl-wrap table thead tr:first-child th:first-child{ border-top-right-radius:var(--radius); }
  .tbl-wrap table thead tr:first-child th:last-child{ border-top-left-radius:var(--radius); }
  tbody td{ padding:6px 6px; border-bottom:1px solid var(--line); text-align:center; vertical-align:middle; font-size:12px; transition:background .1s; }
  tbody tr:nth-child(even){ background:#FAF8F2; }
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
    width:28px; height:28px; border:none; border-radius:6px; background:#F5F2EA; color:var(--ink);
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
    background:linear-gradient(120deg,var(--deep) 0%,#173B5C 100%); color:#fff; position:sticky; top:0; font-weight:700; border-inline-start:1px solid rgba(255,255,255,.15); z-index:2;
  }
  .remote-grid thead th:first-child{ border-top-right-radius:12px; }
  .remote-grid thead th:last-child{ border-top-left-radius:12px; }
  .remote-grid tbody tr:nth-child(even) td{ background:#FAF8F2; }
  .remote-grid tbody tr:hover td{ background:#F4EEDD; }
  .remote-grid tbody tr:nth-child(even) td.server-name{ background:#FAF8F2; }
  .remote-grid tbody tr:hover td.server-name{ background:#F4EEDD; }
  .remote-grid td.server-name{ text-align:right; font-weight:600; white-space:normal; background:var(--white); position:sticky; right:0; padding:10px 12px; z-index:1; box-shadow:2px 0 4px rgba(0,0,0,.04); }
  .day-toggle{
    width:36px; height:36px; border-radius:50%; border:1.5px solid var(--line); background:var(--white);
    cursor:pointer; font-size:15px; font-weight:700; color:var(--ink-faint); transition:background .12s, color .12s, transform .1s, box-shadow .12s;
  }
  .day-toggle:hover{ border-color:var(--brass); background:#fbf9f3; transform:scale(1.12); }
  .day-toggle.checked{ background:var(--green); color:#fff; border-color:var(--green-ink); box-shadow:0 2px 8px rgba(46,125,50,.35); }
  .remote-day-head{ display:flex; align-items:center; justify-content:center; gap:4px; }
  .remote-date-header{
    width:52px; text-align:center; font-size:11px; font-family:var(--font-body);
    background:rgba(255,255,255,.14); color:#fff; border:1px solid rgba(255,255,255,.3);
    border-radius:6px; padding:4px 2px;
  }
  .remote-date-header::placeholder{ color:rgba(255,255,255,.6); }
  .remote-date-header:focus{ outline:none; background:var(--white); color:var(--ink); border-color:var(--brass); }
  .remote-day-del{
    border:none; background:rgba(255,255,255,.16); color:#fff; width:18px; height:18px; border-radius:50%;
    font-size:10px; line-height:1; cursor:pointer; flex:0 0 auto; padding:0; transition:background .12s;
  }
  .remote-day-del:hover{ background:var(--red); }
  .remote-day-del:disabled{ opacity:.35; cursor:default; }
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
  .btn-del{ background:transparent; color:var(--red-ink); border:1px solid transparent; cursor:pointer; font-size:15px; padding:5px 8px; border-radius:6px; transition:all .12s; }
  .btn-del:hover{ background:rgba(166,34,43,0.1); border-color:var(--red); transform:scale(1.05); }
  .btn-del[disabled]{ display:none; }
  .del-toggle-wrap, .edit-toggle-wrap{ display:inline-flex; align-items:center; gap:5px; font-size:10.5px; color:var(--ink-soft); user-select:none; white-space:nowrap; }
  .del-switch, .edit-switch{ position:relative; display:inline-block; width:28px; height:16px; flex:none; }
  .del-switch input, .edit-switch input{ opacity:0; width:0; height:0; }
  .del-switch .track, .edit-switch .track{ position:absolute; inset:0; background:#c9c2b3; border-radius:999px; transition:.18s; cursor:pointer; }
  .del-switch .track::before, .edit-switch .track::before{ content:""; position:absolute; width:12px; height:12px; left:2px; top:2px; background:var(--white); border-radius:50%; transition:.18s; box-shadow:0 1px 2px rgba(0,0,0,.3); }
  .del-switch input:checked + .track, .edit-switch input:checked + .track{ background:var(--red); }
  .del-switch input:checked + .track::before, .edit-switch input:checked + .track::before{ transform:translateX(-12px); }
  .add-row input, .add-row select{ background:#fbf9f3; border:1px solid var(--line); border-radius:6px; padding:5px 7px; font-size:12px; font-family:inherit; }
  .add-row input:focus, .add-row select:focus{ outline:2px solid var(--brass); }
  .compound-field{ display:flex; align-items:stretch; border:1px solid var(--line); border-radius:8px; overflow:hidden; background:#fbf9f3; }
  .compound-field input{ border:none; background:transparent; padding:7px 9px; font-size:12.5px; font-family:inherit; flex:1; min-width:0; }
  .compound-field input:focus{ outline:none; background:var(--white); }
  .compound-field .divider{ width:1px; background:var(--line); }
  .compound-field:focus-within{ border-color:var(--brass); }
  .new-company-card{ display:flex; align-items:center; justify-content:center; gap:10px; padding:22px; border:1.5px dashed var(--line); border-radius:12px; background:#fbf9f3; flex-wrap:wrap; }
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
  .cal-nav{ display:flex; align-items:center; gap:8px; background:#fbf9f3; border:1px solid var(--line); border-radius:8px; padding:3px 10px; }
  .cal-nav-btn{ background:none; border:none; cursor:pointer; font-size:15px; color:var(--brass-ink); font-weight:700; padding:0 4px; line-height:1; }
  .cal-nav-btn:hover{ color:var(--brass); }
  .cal-label{ font-size:12.5px; font-weight:700; min-width:100px; text-align:center; }
  .cal-count{ font-size:11.5px; color:var(--ink-faint); margin-inline-start:auto; }
  .cal-grid{ display:flex; flex-wrap:wrap; gap:6px; }
  .cal-day{ width:34px; height:34px; border-radius:8px; border:1.5px solid var(--line); background:var(--white); cursor:pointer; font-size:12px; font-weight:600; color:var(--ink-soft); transition:.12s; }
  .cal-day:hover{ border-color:var(--brass); }
  .cal-day.done{ background:var(--brass); border-color:var(--brass-ink); color:#fff; }
  .btn-sm{ padding:5px 12px !important; font-size:12px !important; }
  .visit-add-bar{ display:flex; align-items:center; gap:8px; margin-top:10px; padding:8px 10px; background:#fbf9f3; border:1px solid var(--line); border-radius:8px; }
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
  .remote-grid tbody tr:nth-child(even) td.server-name{ background:#FAFBFC; }
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

  /* ---------- Personal vault (password protected) ---------- */
  .navbtn-lock{ border-top:1px dashed var(--line); margin-top:6px; padding-top:14px; }
  .lock-screen{
    max-width:400px; margin:36px auto; background:linear-gradient(160deg,var(--deep) 0%,#173B5C 100%);
    border-radius:18px; padding:34px 28px; text-align:center; color:#fff;
    box-shadow:0 20px 45px rgba(11,37,69,.28);
  }
  .lock-screen .ls-icon{ font-size:44px; margin-bottom:10px; }
  .lock-screen h3{ font-family:var(--font-display); font-size:17px; margin:0 0 6px; }
  .lock-screen p{ font-size:12px; opacity:.82; line-height:1.9; margin:0 0 20px; }
  .lock-screen input{
    width:100%; box-sizing:border-box; border:1px solid rgba(255,255,255,.25); border-radius:10px;
    padding:11px 14px; font-family:var(--font-body); font-size:13.5px; margin-bottom:10px;
    background:rgba(255,255,255,.08); color:#fff; text-align:center; letter-spacing:2px;
  }
  .lock-screen input::placeholder{ color:rgba(255,255,255,.5); letter-spacing:normal; }
  .lock-screen button{
    width:100%; border:none; border-radius:10px; padding:11px; font-size:13.5px; font-weight:700;
    cursor:pointer; font-family:var(--font-body); background:var(--brass); color:#fff; margin-top:4px;
  }
  .lock-screen .ls-error{ color:#FF9E9E; font-size:12px; margin-top:8px; min-height:16px; }
  .lock-screen .ls-reset{
    display:inline-block; margin-top:16px; font-size:11px; color:rgba(255,255,255,.55);
    background:none; border:none; text-decoration:underline; cursor:pointer; width:auto; padding:0;
  }

  .personal-toolbar{ display:flex; align-items:center; justify-content:space-between; gap:10px; margin-bottom:16px; flex-wrap:wrap; }
  .personal-tabs{ display:flex; gap:6px; }
  .personal-tabs button{
    border:1px solid var(--card-border); background:var(--white); border-radius:9px; padding:8px 16px;
    font-size:12.5px; font-family:var(--font-body); cursor:pointer; color:var(--ink-soft);
  }
  .personal-tabs button.active{ background:var(--deep); color:#fff; border-color:var(--deep); font-weight:600; }
  .btn-lock-now{
    border:1px solid #E9A5A5; background:#FDEAEA; color:var(--red-ink); border-radius:9px; padding:8px 14px;
    font-size:12px; cursor:pointer; font-family:var(--font-body); font-weight:600;
  }

  .cred-table{ table-layout:fixed; }
  .cred-table input{
    width:100%; box-sizing:border-box; border:1px solid transparent; border-radius:6px; padding:6px 8px;
    font-family:var(--font-body); font-size:12.5px; background:transparent; color:var(--ink);
  }
  .cred-table input:focus{ outline:none; border-color:var(--brass); background:var(--white); }
  .cred-table td{ position:relative; }
  .pw-toggle-btn{
    border:none; background:transparent; cursor:pointer; font-size:13px; color:var(--ink-faint); padding:2px 4px;
  }
  .pw-cell{ display:flex; align-items:center; gap:2px; }
  .pw-cell input{ flex:1; }

  .inst-form{
    display:grid; grid-template-columns:1.4fr 1fr 0.8fr 0.8fr; gap:8px; margin-bottom:8px;
  }
  .inst-form input{
    box-sizing:border-box; border:1px solid var(--card-border); border-radius:8px; padding:9px 10px;
    font-family:var(--font-body); font-size:12.5px;
  }
  .inst-date-row{ display:flex; align-items:center; gap:8px; margin-bottom:10px; }
  .inst-date-row label{ font-size:12px; color:var(--ink-soft); white-space:nowrap; }
  .inst-date-row select{
    border:1px solid var(--card-border); border-radius:8px; padding:8px 6px; font-family:var(--font-body);
    font-size:12.5px; background:var(--white);
  }
  .inst-note{ font-size:11.5px; color:var(--ink-faint); margin:0 0 12px; line-height:1.8; }
  .inst-card{
    border:1px solid var(--card-border); border-radius:12px; padding:16px; margin-bottom:14px; background:#FCFBF7;
  }
  .inst-card-head{ display:flex; align-items:center; justify-content:space-between; margin-bottom:8px; }
  .inst-card-head h4{ margin:0; font-family:var(--font-display); font-size:14.5px; color:var(--ink); }
  .inst-summary{ font-size:12px; color:var(--ink-soft); line-height:2; margin-bottom:12px; }
  .inst-summary b{ color:var(--ink); }
  table.inst-schedule{ width:100%; border-collapse:collapse; font-size:12px; }
  table.inst-schedule th{ text-align:center; padding:6px 4px; color:var(--ink-soft); border-bottom:1px solid var(--card-border); background:transparent; position:static; }
  table.inst-schedule td{ text-align:center; padding:6px 4px; border-bottom:1px solid #F0EDE4; }
  table.inst-schedule tr.paid td{ color:var(--ink-faint); text-decoration:line-through; }
  .inst-pay-toggle{
    border:1px solid var(--card-border); background:var(--white); border-radius:6px; padding:3px 10px; font-size:11px;
    cursor:pointer; font-family:var(--font-body);
  }
  .inst-pay-toggle.paid{ background:#E4F3E4; border-color:#9FCF9F; color:#2E7D32; }

  .cred-toolbar{ display:flex; align-items:center; gap:10px; margin-bottom:12px; flex-wrap:wrap; }
  .company-tabs{ display:flex; flex-wrap:wrap; gap:8px; }
  .company-tab-btn{
    border:1px solid var(--card-border); background:var(--white); border-radius:9px; padding:8px 16px;
    font-size:12.5px; font-family:var(--font-body); cursor:pointer; color:var(--ink-soft);
  }
  .company-tab-btn:hover{ border-color:var(--brass); color:var(--ink); }
  .company-tab-btn.active{ background:var(--deep); color:#fff; border-color:var(--deep); font-weight:600; }
  .company-tab-btn .cnt{ opacity:.7; font-size:11px; }
  .cred-import-bar{
    display:flex; align-items:center; gap:8px; padding:10px 12px; background:#F4F0E4; border:1px solid var(--card-border);
    border-radius:9px; margin-bottom:14px; flex-wrap:wrap;
  }
  .cred-import-bar p{ margin:0; font-size:11px; color:var(--ink-soft); line-height:1.8; flex:1; min-width:200px; }
  .cred-import-status{ font-size:11.5px; font-weight:600; color:#2E7D32; }

  /* ---------- گوشی و تبلت ----------
     تا حالا هیچ چیدمانی برای صفحهٔ باریک نبود: ستون کناریِ ۲۱۶ پیکسلی
     سر جایش می‌ماند و برای خودِ کارتابل چیزی حدود ۱۷۰ پیکسل باقی
     می‌گذاشت. حالا روی صفحهٔ باریک، ستون کناری می‌رود بالا و دکمه‌هایش
     مثل تب کنار هم می‌نشینند. */
  @media (max-width:860px){
    .topbar{
      height:auto; min-height:56px; flex-wrap:wrap; gap:8px;
      padding:10px 14px; position:static;
    }
    .brand .mark{ height:32px; }
    .brand h1{ font-size:15px; }
    .brand small{ display:none; }
    .period{ flex-wrap:wrap; gap:6px; }
    .period input{ width:70px; }

    /* در حالت عمودی باید کشیده شوند؛ با align-items:flex-start که برای
       چیدمان افقی لازم است، بخش محتوا به اندازهٔ پهن‌ترین جدولش باز
       می‌شد و کل صفحه را از عرض گوشی پهن‌تر می‌کرد. */
    .shell{ flex-direction:column; align-items:stretch; }
    .sidebar{
      width:auto; flex:none; height:auto; max-height:none;
      position:static; overflow:visible;
      padding:10px 12px;
      border-left:none; border-bottom:1px solid rgba(11,37,69,.10);
      flex-direction:column; gap:6px;
    }
    .nav-list{
      flex:none; min-height:0; overflow:visible;
      flex-direction:row; flex-wrap:wrap; gap:6px;
    }
    .nav-label{ display:none; }
    .navbtn{
      width:auto; margin-bottom:0; padding:8px 12px;
      font-size:12.5px; gap:7px; border-radius:9px;
      background:rgba(255,255,255,.75); border:1px solid var(--line);
    }
    .navbtn .ic{ font-size:13px; }
    .sidebar-foot{
      margin-top:2px; padding-top:10px;
      flex-direction:row; align-items:center; flex-wrap:wrap; gap:6px;
    }
    .sidebar-foot .save-hint{ flex:1 1 100%; min-height:0; }
    .foot-actions{ flex:1 1 auto; }
    .foot-lock{ width:auto; flex:0 0 auto; }

    .content{ padding:16px 14px 48px; width:100%; max-width:100%; }
    .section-title{ font-size:16px; }
    /* جدول‌ها از قبل ظرفِ اسکرول‌دار داشتند؛ پنل‌های دیگر هم نباید
       صفحه را پهن کنند. */
    .panel{ padding:14px 13px; }
    .panel:hover{ transform:none; }
    .grid2, .grid3{ grid-template-columns:1fr; }
    /* خانه‌های گرید به‌طور پیش‌فرض کوچک‌تر از محتوایشان نمی‌شوند و روی
       صفحهٔ خیلی باریک (۳۲۰ پیکسل) کل صفحه را پهن می‌کردند. */
    .grid2 > *, .grid3 > *, .cards > *{ min-width:0; }
    .set-grid{ grid-template-columns:1fr; }
    .gate-card{ max-width:none; }

    /* نوارهایی که چند ورودی را کنار هم می‌گذارند روی عرض گوشی جا
       نمی‌شوند و کل صفحه را پهن می‌کنند. اجازه می‌دهیم بشکنند و
       ورودی‌ها تمام عرض را بگیرند. */
    .visit-add-bar, .dt-row, .inst-date-row, .cred-import-bar, .clv-row{
      flex-wrap:wrap;
    }
    .visit-add-bar input, .visit-add-bar select,
    .dt-row select, .dt-row input[type="date"]{
      flex:1 1 130px; min-width:0;
    }
    .visit-add-bar .btn{ flex:1 1 100%; justify-content:center; }
    .toolbar{ gap:8px; }
    .toolbar .btn{ flex:1 1 auto; justify-content:center; }
  }

  @media (max-width:420px){
    .brand h1{ font-size:13.5px; }
    .navbtn{ padding:7px 10px; font-size:12px; }
    .content{ padding:14px 11px 44px; }
  }

  /* ---------- فهرستِ کنار ----------
     overflow-y:auto به‌تنهایی کافی نبود: در CSS وقتی یک محور auto می‌شود،
     محورِ دیگر از visible به auto می‌افتد، و همان یک نوارِ اسکرولِ افقیِ
     بی‌مصرف را زیر فهرست می‌آورد. صریح خاموشش می‌کنیم.
     نوارِ عمودی هم باریک و کم‌رنگ شد تا مثل یک تختهٔ خاکستری وسطِ فهرست
     ننشیند. */
  .nav-list{ overflow-x:hidden; scrollbar-width:thin; scrollbar-color:var(--line) transparent; }
  .nav-list::-webkit-scrollbar{ width:6px; height:0; }
  .nav-list::-webkit-scrollbar-track{ background:transparent; }
  .nav-list::-webkit-scrollbar-thumb{ background:var(--line); border-radius:3px; }
  .nav-list::-webkit-scrollbar-thumb:hover{ background:var(--ink-faint); }
  /* دکمه‌ها با padding از عرضِ فهرست می‌زدند بیرون و خودشان هم به آن
     نوارِ افقی دامن می‌زدند. */
  .navbtn{ box-sizing:border-box; max-width:100%; }

  /* نوارِ هشدارِ همگام‌سازی — همان شکلِ نوارِ تداخل */
  .sync-warn{
    position:fixed; inset-inline:0; bottom:0; z-index:9998;
    display:flex; align-items:center; justify-content:center; gap:10px; flex-wrap:wrap;
    background:var(--bad-bg); color:var(--bad-ink);
    border-top:1px solid var(--bad); padding:10px 16px;
    font-family:var(--font-body); font-size:12.5px;
  }
  .sync-warn button{
    font-family:var(--font-body); font-size:12px; cursor:pointer;
    border:1px solid var(--bad); background:transparent; color:var(--bad-ink);
    border-radius:8px; padding:5px 12px;
  }
  .sync-warn button:hover{ background:var(--bad); color:#fff; }

  /* ---------- دستیار هوشمند ----------
     همه‌چیزش از توکن‌ها می‌خواند، پس در تم شب هم بدون قاعدهٔ جداگانه درست
     درمی‌آید. ارتفاعِ ثابت دارد تا فهرستِ گفتگو خودش اسکرول شود و نوارِ
     نوشتن همیشه پایین بماند، نه اینکه صفحه بلند و بلندتر شود. */
  .ai-wrap{
    display:flex; flex-direction:column;
    height:calc(100vh - 235px); min-height:420px;
    background:var(--white); border:1px solid var(--card-border);
    border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden;
  }
  .ai-log{
    flex:1 1 auto; min-height:0; overflow-y:auto;
    padding:18px; display:flex; flex-direction:column; gap:12px;
  }
  .ai-msg{
    max-width:78%; padding:10px 14px; border-radius:14px;
    font-size:13px; line-height:2; white-space:pre-wrap; word-break:break-word;
  }
  /* در راست‌به‌چپ، flex-end سمتِ چپ است: پیام خودِ کاربر چپ، جواب راست */
  .ai-msg.me{ align-self:flex-end; background:var(--brass); color:#fff; border-bottom-left-radius:4px; }
  .ai-msg.bot{ align-self:flex-start; background:var(--paper-deep); color:var(--ink); border-bottom-right-radius:4px; }
  .ai-msg.err{ align-self:flex-start; background:var(--red-bg); color:var(--red-ink); }
  .ai-msg code{ background:rgba(127,127,127,.18); border-radius:4px; padding:1px 5px; font-size:12px; }
  .ai-empty{ margin:auto; text-align:center; color:var(--ink-faint); font-size:12.5px; line-height:2.2; }
  .ai-empty .big{ font-size:30px; display:block; margin-bottom:6px; }
  .ai-tips{ display:flex; flex-wrap:wrap; gap:6px; padding:0 18px 12px; }
  .ai-tip{
    border:1px solid var(--line); border-radius:999px; padding:5px 11px;
    font-size:11.5px; cursor:pointer; background:transparent; color:var(--ink-soft);
    font-family:var(--font-body);
  }
  .ai-tip:hover{ border-color:var(--brass); color:var(--ink); }
  .ai-bar{ display:flex; gap:8px; padding:12px; border-top:1px solid var(--line); background:var(--paper); }
  .ai-bar textarea{
    flex:1 1 auto; resize:none; min-height:42px; max-height:150px; box-sizing:border-box;
    font-family:var(--font-body); font-size:13px; line-height:1.9;
    padding:10px 12px; border:1px solid var(--line); border-radius:10px;
    background:var(--white); color:var(--ink);
  }
  .ai-bar textarea:focus{ outline:none; border-color:var(--brass); }
  .ai-send{ flex:none; align-self:flex-end; }
  .ai-foot{
    display:flex; align-items:center; justify-content:space-between; gap:10px;
    flex-wrap:wrap; margin-top:10px;
  }
  .ai-note{ font-size:11.5px; color:var(--ink-faint); line-height:1.9; flex:1 1 260px; }
  @media (max-width:860px){
    .ai-wrap{ height:auto; min-height:0; }
    .ai-log{ max-height:60vh; }
    .ai-msg{ max-width:92%; }
  }

  /* ---------- تم شب ----------
     رنگ‌های تم شب «برعکسِ» تم روز نیستند؛ جداگانه انتخاب و روی سطحِ تیره
     سنجیده شده‌اند. هر جوهر روی تینتِ خودش بالای ۵:۱ کنتراست دارد. */
  [data-theme="dark"]{
    --paper:#0D1620;
    --paper-deep:#111C28;
    --white:#16212E;
    --ink:#E9EFF5;
    --ink-soft:#AFBDCB;
    --ink-faint:#7E8D9C;
    --line:#27323F;
    --card-border:#27323F;
    --brass-bg:#10312F;
    --green-bg:#122A1F;
    --amber-bg:#2E2515;
    --red-bg:#331A1C;
    --teal-bg:#0F2B28;
    --purple-bg:#241C33;
    --shadow: 0 1px 2px rgba(0,0,0,.45), 0 4px 14px rgba(0,0,0,.35);
    --shadow-lg: 0 4px 12px rgba(0,0,0,.5), 0 18px 40px rgba(0,0,0,.45);
    --c1:#12A29A; --t1:#0F2E2C;
    --c2:#BF881F; --t2:#2E2616;
    --c3:#8561C7; --t3:#231B33;
    --c4:#2B8C59; --t4:#13291E;
    --bad:#D4646C; --bad-bg:#331E20; --bad-ink:#E48E94;
    --deep:#203042;
    --brass-ink:#58CFC6;
    --red-ink:#E4757C;
    --green-ink:#56B97E;
    --amber-ink:#E0A63A;
    --teal-ink:#3FBDB0;
    --purple-ink:#A585DC;
    color-scheme: dark;
  }
  /* پس‌زمینهٔ صفحه گرادیانی دارد که برای زمینهٔ روشن ساخته شده */
  [data-theme="dark"] body{ background:var(--paper); }
  [data-theme="dark"] .tbl-wrap,
  [data-theme="dark"] thead th{ background-color:transparent; }
  [data-theme="dark"] tbody tr:nth-child(even){ background:rgba(255,255,255,.03); }
  [data-theme="dark"] tbody tr:hover{ background:rgba(255,255,255,.06); }
  /* قاب آیکن کارت‌ها: رنگِ روشنِ inline در شب کور می‌زند */
  [data-theme="dark"] .stat-ic{ background:rgba(255,255,255,.08); }
  [data-theme="dark"] input, [data-theme="dark"] select, [data-theme="dark"] textarea{
    background:var(--paper-deep); color:var(--ink); border-color:var(--line);
  }
  [data-theme="dark"] input::placeholder, [data-theme="dark"] textarea::placeholder{ color:var(--ink-faint); }
  [data-theme="dark"] option{ background:var(--paper-deep); color:var(--ink); }

  /* سطح‌هایی که هگزِ روشنِ ثابت داشتند و توکن نبودند */
  [data-theme="dark"] .btn-lock-now{ background:var(--red-bg); border-color:#5A2A2E; color:var(--red-ink); }
  [data-theme="dark"] .inst-card{ background:var(--paper-deep); }
  [data-theme="dark"] .inst-pay-toggle.paid{ background:var(--green-bg); border-color:#2E5C42; color:var(--green-ink); }
  [data-theme="dark"] .cred-import-bar,
  [data-theme="dark"] .visit-add-bar{ background:var(--paper-deep); }
  [data-theme="dark"] .add-row input, [data-theme="dark"] .add-row select{ background:var(--paper-deep); }

  /* در موبایل نوار کناری ردیفی از دکمه می‌شود و پس‌زمینهٔ سفیدِ
     نیمه‌شفاف می‌گیرد؛ در شب متنِ روشن رویش گم می‌شد. */
  @media (max-width:860px){
    [data-theme="dark"] .navbtn{ background:rgba(255,255,255,.06); border-color:var(--line); }
  }

  /* ---------- دکمهٔ تم ---------- */
  .theme-btn{
    display:inline-flex; align-items:center; justify-content:center;
    width:30px; height:30px; flex:none; cursor:pointer; user-select:none;
    background:rgba(255,255,255,.08); border:1px solid rgba(255,255,255,.2);
    border-radius:999px; font-size:14px; line-height:1; color:#fff;
    transition:background .15s, transform .12s;
  }
  .theme-btn:hover{ background:rgba(255,255,255,.16); }
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
    <span class="lock-ic">🔐</span>
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
    <img class="mark" src="data:image/png;base64,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" alt="SLTech">
    <div class="titles">
      <h1>{{TITLE}}</h1>
      <small>بکاپ، سرورها، امنیت و برنامه‌ی ماه</small>
    </div>
  </div>
  <div class="period">
    <label>ماه</label>
    <select id="monthSelector"></select>
    <button class="btn btn-brass btn-sm" id="newMonthBtn">＋ ماه جدید</button>
    <span class="topbar-clock" id="topbarClock">--:--:--</span>
    <button type="button" class="theme-btn" id="themeBtn" title="تم شب">🌙</button>
  </div>
</div>

<div class="new-month-panel" id="newMonthPanel" style="display:none;">
  <input id="newMonthName" type="text" placeholder="نام ماه، مثلاً آبان">
  <input id="newMonthYear" type="text" placeholder="سال، مثلاً ۱۴۰۴">
  <button class="btn btn-brass btn-sm" id="confirmNewMonthBtn">شروع این ماه</button>
  <button class="btn btn-ghost btn-sm" id="cancelNewMonthBtn">انصراف</button>
</div>

<div class="shell">
  <div class="sidebar">
    <div class="nav-label">بخش‌ها</div>
    <nav class="nav-list">
      <button class="navbtn active" data-view="dashboard"><span class="ic">📊</span> داشبورد</button>
      <button class="navbtn" data-view="checklist"><span class="ic">✅</span> چک‌لیست ماهانه</button>
      <button class="navbtn" data-view="daily"><span class="ic">🗓️</span> برنامه روزانه</button>
<!--IT-->
      <button class="navbtn" data-view="servers"><span class="ic">🖥️</span> سرورها و بکاپ</button>
      <button class="navbtn" data-view="companies"><span class="ic">🏢</span> شرکت‌ها</button>
      <button class="navbtn" data-view="mvpn"><span class="ic">📱</span> سرویس MVPN</button>
<!--/IT-->
      <button class="navbtn navbtn-lock" data-view="personal" data-feat="vault"><span class="ic">🔒</span> دیتای شخصی</button>
<!--IT-->
      <button class="navbtn" data-view="datetools"><span class="ic">🧮</span> تبدیل تاریخ</button>
<!--/IT-->
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

      <div class="dash-group-label"><span class="dgl-ic">📋</span> وظایف و برنامه‌ی این ماه</div>
<!--IT-->      <div class="grid3"><!--/IT--><!--GEN-->      <div class="grid2"><!--/GEN-->
        <div class="panel accent-blue">
          <h3>🥧 وضعیت وظایف ماه</h3>
          <div class="chart-box"><canvas id="chartStatus"></canvas></div>
        </div>
        <div class="panel accent-blue">
          <h3>🗓️ وضعیت برنامه روزانه</h3>
          <div class="chart-box"><canvas id="chartDaily"></canvas></div>
        </div>
<!--IT-->
        <div class="panel accent-blue">
          <h3>✅ نرخ کلی موفقیت بکاپ روزانه</h3>
          <div class="chart-box"><canvas id="chartBackupSuccessRate"></canvas></div>
        </div>
<!--/IT-->
      </div>

<!--IT-->
      <div class="dash-group-label"><span class="dgl-ic">🏢</span> شرکت‌ها</div>
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

      <div class="dash-group-label"><span class="dgl-ic">🖥️</span> زیرساخت و ارتباطات</div>
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
<!--/IT-->

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

<!--IT-->
    <!-- SERVERS & BACKUP -->
    <section class="view" id="view-servers">
      <div class="section-title">سرورها و بکاپ</div>
      <div class="section-sub">فهرست سرورها و وضعیت بکاپ‌گیری بر اساس دیتای شما</div>

      <div class="toolbar">
        <button class="btn btn-brass" id="refreshExcelBtn">🔄 بارگذاری/به‌روزرسانی از فایل دیتابیس</button>
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
          فهرست سرورها از برگ RemoteChecklist در فایل «{{FILEXLSX}}» خوانده می‌شود؛ روی هر روز کلیک کنید تا به‌عنوان «بررسی‌شده و موفق» علامت بخورد، یا سرور/روز جدید اضافه کنید — هر تغییری خودکار روی همان اکسل ذخیره می‌شود.
        </p>
        <div class="toolbar" style="margin-bottom:12px;">
          <button class="btn btn-brass" id="refreshRemoteBtn">🔄 بارگذاری/به‌روزرسانی از فایل دیتابیس</button>
          <span class="save-hint" id="remoteSyncStatus" style="font-size:11.5px;"></span>
        </div>
        <div id="remoteChecklistWrap"></div>
      </div>
    </section>

    <!-- COMPANIES -->
    <section class="view" id="view-companies">
      <div class="section-title">شرکت‌ها</div>
      <div class="section-sub">تاریخچه‌ی بازدید/پشتیبانی شرکت‌ها — برگ Companies در فایل دیتابیس یکپارچه</div>

      <div class="toolbar">
        <button class="btn btn-brass" id="refreshDateBtn">🔄 بارگذاری/به‌روزرسانی از فایل دیتابیس</button>
        <span class="save-hint" id="dateSyncStatus" style="font-size:11.5px;"></span>
      </div>

      <div id="companiesWrap"></div>
    </section>

    <!-- MVPN -->
    <section class="view" id="view-mvpn">
      <div class="section-title">سرویس MVPN</div>
      <div class="section-sub">فهرست خطوط سازمانی — برگ MVPN در فایل دیتابیس یکپارچه</div>

      <div class="toolbar">
        <button class="btn btn-brass" id="refreshMvpnBtn">🔄 بارگذاری/به‌روزرسانی از فایل دیتابیس</button>
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
<!--/IT-->

    <!-- PERSONAL (password protected) -->
    <section class="view" id="view-personal" data-feat="vault">
      <div class="section-title">🔒 دیتای شخصی</div>
      <div class="section-sub">این بخش با رمز عبور جداگانه محافظت می‌شود و داده‌هایش حتی در فایل اکسل و فایل ذخیره‌سازی به‌صورت رمزنگاری‌شده نگه‌داری می‌شود — بدون رمز درست، هیچ‌کس (از جمله خود این برنامه) نمی‌تواند آن را بخواند.</div>
      <div id="personalWrap"></div>
    </section>

<!--IT-->
    <!-- DATE TOOLS -->
    <section class="view" id="view-datetools">
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
<!--/IT-->

    <!-- GUIDE -->
    <!-- SETTINGS -->
    <section class="view" id="view-settings">
      <div class="section-title">تنظیمات کارتابل</div>
      <div class="section-sub">رمز ورود، ربات پشتیبان، و وضعیت همگام‌سازی</div>

      <div class="panel">
        <h3 class="set-h">☁️ همگام‌سازی</h3>
        <p class="set-p">داده‌های کارتابل روی سرور می‌مانند، پس با هر مرورگر و هر دستگاهی که وارد شوید همین‌ها را می‌بینید. اگر اینترنت قطع شود کارتابل با نسخهٔ همین مرورگر کار می‌کند و به‌محض وصل شدن، تغییرها بالا می‌روند.</p>
        <div class="set-row">
          <span class="set-state" id="cloudStatus">در حال بررسی…</span>
        </div>
        <div class="set-row">
          <span class="set-state" id="lastLoginRow"></span>
        </div>
      </div>

      <div class="panel" data-feat="pass">
        <h3 class="set-h">🔑 رمز ورود</h3>
        <p class="set-p">رمز روی سرور و به شکل PBKDF2 با ۱۰۰٬۰۰۰ دور نگه داشته می‌شود؛ نه در این صفحه هست و نه از روی چیزی که ذخیره شده درمی‌آید. با عوض کردنش، همهٔ دستگاه‌های دیگر که وارد مانده‌اند بیرون می‌افتند.</p>
        <form id="passForm" autocomplete="off">
          <div class="set-grid">
            <label>رمز فعلی
              <input type="password" id="passCurrent" autocomplete="current-password" required>
            </label>
            <label>رمز تازه (دست‌کم ۸ کاراکتر)
              <input type="password" id="passNext" autocomplete="new-password" minlength="8" required>
            </label>
            <label>تکرار رمز تازه
              <input type="password" id="passRepeat" autocomplete="new-password" minlength="8" required>
            </label>
          </div>
          <div class="set-row">
            <button type="submit" class="btn btn-brass" id="passBtn">ثبت رمز تازه</button>
            <span class="set-state" id="passState"></span>
          </div>
        </form>
      </div>

      <div class="panel" data-feat="ai">
        <h3 class="set-h">🤖 موتور دستیار هوشمند</h3>
        <p class="set-p">دستیار به‌طور پیش‌فرض روی هوش مصنوعیِ رایگانِ کلادفلر کار می‌کند — چیزی لازم ندارد، ولی کیفیتش متوسط است و گاهی در فارسی گیج می‌زند. اگر کلید API کلاد داشته باشید، این‌جا بگذاریدش تا دستیار از همان لحظه با کلاد کار کند. کلید را از <code dir="ltr">console.anthropic.com</code> می‌سازید و هزینه‌اش پای مصرف خودتان است.</p>
        <div class="set-row">
          <span class="set-state" id="aiProvider">در حال بررسی…</span>
        </div>
        <div class="set-grid">
          <label>کلید API کلاد (خالی بگذارید تا رایگان بماند)
            <input type="password" id="aiKey" placeholder="sk-ant-..." autocomplete="off" dir="ltr">
          </label>
        </div>
        <div class="set-row">
          <button type="button" class="btn btn-brass" id="aiKeySaveBtn">ثبت کلید</button>
          <button type="button" class="btn btn-ghost" id="aiKeyClearBtn">برگرد به رایگان</button>
          <span class="set-state" id="aiKeyState"></span>
        </div>
      </div>

      <div class="panel" data-feat="backup">
        <h3 class="set-h">🤖 پشتیبان شبانه در تلگرام</h3>
        <p class="set-p">هر شب یک زیپ کامل — فایل داده، فایل اکسل، و خودِ صفحهٔ کارتابل — برای ربات شما فرستاده می‌شود. با همان زیپ، کارتابل بدون سرور و بدون اینترنت هم باز می‌شود.</p>
        <div class="set-grid">
          <label>توکن ربات تلگرام
            <input type="text" id="botToken" placeholder="مثل: 8926574603:AAE..." autocomplete="off" dir="ltr">
          </label>
        </div>
        <div class="set-row">
          <button type="button" class="btn btn-brass" id="botSaveBtn">ثبت توکن</button>
          <span class="set-state" id="botState"></span>
        </div>
        <hr class="set-hr">
        <p class="set-p">بعد از ثبت توکن، در تلگرام ربات را باز کنید و <code>/start</code> بزنید، بعد دکمهٔ زیر را بزنید تا معلوم شود پشتیبان برای چه کسی برود.</p>
        <div class="set-row">
          <button type="button" class="btn btn-ghost" id="botConnectBtn">اتصال به گفتگوی من</button>
          <span class="set-state" id="connectState"></span>
        </div>
        <hr class="set-hr">
        <div class="set-row">
          <button type="button" class="btn btn-ghost" id="backupNowBtn">📤 همین حالا یک پشتیبان بفرست</button>
          <button type="button" class="btn btn-ghost" id="backupDownloadBtn">⬇ دانلود زیپ پشتیبان</button>
          <span class="set-state" id="backupState"></span>
        </div>
        <div class="set-row">
          <span class="set-state" id="lastBackup"></span>
        </div>
      </div>

      <!-- فقط در مرورگرهایی که File System Access دارند دیده می‌شود -->
      <div class="panel" id="folderPanel" data-feat="folder" hidden>
        <h3 class="set-h">🗂️ آینهٔ اکسل روی سیستم (اختیاری)</h3>
        <p class="set-p">اگر بخواهید، کارتابل می‌تواند هم‌زمان یک فایل اکسل را در پوشه‌ای روی سیستم شما به‌روز نگه دارد. برای کار کردن با کارتابل لازم نیست — داده‌ها روی سرور هستند و پشتیبان شبانه هم می‌رود. این فقط برای وقتی است که بخواهید همان فایل اکسل همیشه روی دیسک خودتان تازه باشد. (فقط Chrome و Edge این امکان را دارند.)</p>
        <div class="set-row">
          <button type="button" class="btn btn-brass" id="connectFolderBtn">اتصال به پوشه روی سیستم</button>
          <span class="set-state" id="folderStatus"></span>
        </div>
      </div>
    </section>

    <!-- ASSISTANT -->
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
        <div class="guide-item">
          <div class="ic">🖥️</div>
          <div><h4>سرورها و بکاپ</h4><p>همه‌ی داده‌ها اکنون در یک فایل واحد به‌نام «{{FILEXLSX}}» نگه‌داری می‌شود. کافی‌ست یک‌بار از «🗂️ اتصال به پوشه» همان پوشه را انتخاب کنید — فایل خودش خوانده و بارگذاری می‌شود. هر افزودن سرور، ویرایش سلول (کلیک روی هر خانه از جدول)، یا تیک‌زدن تقویم بکاپ روزانه، بلافاصله و خودکار روی همان فایل اکسل ذخیره می‌شود؛ لازم نیست خودتان چیزی را در اکسل دستی تغییر دهید (فقط Chrome/Edge؛ به اینترنت هم برای بارگذاری یک‌بارهٔ ابزار خواندن اکسل نیاز دارد).</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">🏢</div>
          <div><h4>شرکت‌ها</h4><p>از برگ Companies در همان فایل دیتابیس خوانده می‌شود. برای هر شرکت می‌توانید بازدید جدید اضافه کنید یا شرکت تازه بسازید — همه روی همان اکسل ذخیره می‌شود.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">📱</div>
          <div><h4>سرویس MVPN</h4><p>از برگ MVPN در همان فایل دیتابیس خوانده می‌شود. خطوط را می‌توانید ویرایش (کلیک روی هر خانه) یا خط جدید اضافه کنید — خودکار روی اکسل ذخیره می‌شود.</p></div>
        </div>
        <div class="guide-item">
          <div class="ic">🛰️</div>
          <div><h4>چک‌لیست بررسی ریموت روزانه</h4><p>از برگ RemoteChecklist در همان فایل دیتابیس خوانده می‌شود؛ روی هر روز کلیک کنید تا علامت «بررسی‌شده و موفق» بخورد، یا سرور/روز جدید اضافه کنید — همه‌ی این‌ها خودکار روی همان اکسل ذخیره می‌شود.</p></div>
        </div>
<!--/IT-->
        <div class="guide-item">
          <div class="ic">💾</div>
          <div><h4>ذخیره‌سازی</h4><p>تغییرات به‌صورت خودکار در حافظه‌ی همین مرورگر و همین سیستم ذخیره می‌شود — روی سیستم دیگری از صفر شروع می‌شود، مگر یکی از این دو راه را استفاده کنید:</p>
          <p style="margin-top:8px;"><b>راه ۱ — پشتیبان دستی:</b> روی سیستم قبلی «⬇ پشتیبان» را بزنید، فایل JSON را به سیستم جدید منتقل کنید (فلش/ایمیل/تلگرام)، سپس روی سیستم جدید «⬆ بازیابی» را بزنید و همان فایل را انتخاب کنید.</p>
          <p style="margin-top:8px;"><b>راه ۲ — پوشه‌ی مشترک:</b> اگر یک پوشه‌ی هم‌گام‌شده دارید (مثلاً پوشه‌ی Google Drive یا OneDrive روی سیستم، یا یک فلش‌مموری)، روی «🗂️ اتصال به پوشه» همان پوشه را در هر دو سیستم انتخاب کنید — برنامه خودش داده‌ی موجود را تشخیص داده و پیشنهاد بارگذاری آن را می‌دهد (فقط Chrome/Edge).</p></div>
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

<div class="cm-overlay" id="chartModalOverlay">
  <div class="cm-box">
    <div class="cm-head">
      <div class="cm-title" id="chartModalTitle"></div>
      <button class="cm-close" id="chartModalClose">✕</button>
    </div>
    <div class="cm-body" id="chartModalBody"></div>
  </div>
</div>

<script>
/* ---------- قفل ورودی کارتابل ----------
   تا وقتی داده فقط در حافظهٔ همین مرورگر بود، بررسی رمز در خودِ صفحه کافی
   بود: کسی که از قفل رد می‌شد هم چیزی جز کارتابل خالی نمی‌دید.

   حالا داده روی سرور است، پس رمز هم همان‌جا بررسی می‌شود. این صفحه فقط
   رمز را می‌فرستد؛ نه خودش رمز را دارد و نه حاصلش را، و تا کوکی نشست
   نگیرد هیچ مسیری داده نمی‌دهد. کوکی HttpOnly است، یعنی حتی کد همین
   صفحه هم نمی‌تواند بخواندش. */
const KARTABL_API = "{{API}}";

async function apiCall(path, opts){
  const res = await fetch(KARTABL_API + path, Object.assign({
    credentials: "same-origin",
    headers: { "Content-Type": "application/json" }
  }, opts || {}));
  let data = null;
  try{ data = await res.json(); }catch(e){ /* پاسخ بدون بدنه */ }
  return { ok: res.ok, status: res.status, data: data || {} };
}

/* تاریخ و ساعتِ فارسی برای پیامِ «آخرین ورود». این‌جا بالای گیت لازم
   است، پیش از اینکه بقیهٔ کارتابل بار شود. */
function faDateTime(ms){
  try{
    const d = new Date(ms);
    const day = new Intl.DateTimeFormat("fa-IR-u-ca-persian", {year:"numeric", month:"long", day:"numeric"}).format(d);
    const time = new Intl.DateTimeFormat("fa-IR", {hour:"2-digit", minute:"2-digit", hour12:false}).format(d);
    return day + " — ساعت " + time;
  }catch(e){ return new Date(ms).toLocaleString("fa-IR"); }
}
function escapeGateHtml(t){
  return String(t == null ? "" : t)
    .replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");
}

/* ---------- بخش‌هایی که ادمین بسته است ----------
   فهرستش را سرور داخل صفحه می‌گذارد. این‌جا فقط از چشم برداشته می‌شوند؛
   جلوگیریِ واقعی سمتِ سرور است، چون پنهان‌کردنِ یک دکمه کسی را که
   درخواست را دستی بفرستد نگه نمی‌دارد. */
function hideClosedFeatures(){
  const off = Array.isArray(window.KARTABL_OFF) ? window.KARTABL_OFF : [];
  if(!off.length) return;
  off.forEach(f=>{
    document.querySelectorAll('[data-feat="' + f + '"]').forEach(el=> el.remove());
  });
}
hideClosedFeatures();

let gateReady = null;   /* وعده‌ای که وقتی تکلیف ورود روشن شد باز می‌شود */
let signedIn = false;   /* نتیجه‌اش: وارد شده‌ایم یا نه */

(function(){
  const screenEl = document.getElementById("gateScreen");
  const form     = document.getElementById("gateForm");
  const input    = document.getElementById("gatePass");
  const btn      = document.getElementById("gateBtn");
  const errEl    = document.getElementById("gateErr");
  const remember = document.getElementById("gateRemember");
  const noteEl    = document.getElementById("gateNote");

  let letMeIn;
  gateReady = new Promise(r => { letMeIn = r; });

  function openGate(){
    screenEl.hidden = false;
    setTimeout(()=>{ try{ input.focus(); }catch(e){} }, 60);
    /* حتی وقتی وارد نشده‌ایم، بقیهٔ صفحه باید راه بیفتد. یک بار همین‌جا
       معلق ماند و صفحه پشتِ قفل برای همیشه روی «در حال بارگذاری» ماند. */
    letMeIn(false);
  }
  function closeGate(){ screenEl.hidden = true; }

  if(window.KARTABL_OFFLINE){
    /* نسخهٔ داخل فایل پشتیبان: سروری در کار نیست، پس نه قفل معنا دارد
       نه همگام‌سازی. باز می‌شود و با «⬆ بازیابی» پر می‌شود. */
    closeGate(); letMeIn(false);
  } else {
    /* آیا کوکی نشست هنوز معتبر است؟ */
    apiCall("/me").then(r=>{
      if(r.ok && r.data.in){
        signedIn = true;
        /* همان عدد در تنظیمات هم نشان داده می‌شود تا بعداً هم در دسترس باشد */
        if(r.data.lastLogin) window.__lastLogin = Number(r.data.lastLogin);
        closeGate(); letMeIn(true);
      }
      else openGate();
    }).catch(()=>{
      /* سرور در دسترس نیست — با همان نسخهٔ محلی ادامه می‌دهیم، وگرنه
         کارتابل در قطعی اینترنت اصلاً باز نمی‌شود. */
      closeGate(); letMeIn(false);
    });
  }

  form.addEventListener("submit", async (e)=>{
    e.preventDefault();
    const pass = input.value;
    if(!pass) return;
    btn.disabled = true; btn.textContent = "در حال بررسی..."; errEl.textContent = "";
    try{
      const r = await apiCall("/login", { method: "POST",
        body: JSON.stringify({ password: pass, remember: remember.checked }) });
      if(r.ok){
        input.value = "";
        /* «آخرین ورود» را همین‌جا نشان می‌دهیم، بعد از ورودِ موفق — نه
           قبلش. اگر قبل از ورود نشان داده می‌شد، هر کسی که آدرس را دارد
           می‌فهمید این کارتابل کِی استفاده شده. */
        const prev = Number(r.data.lastLogin || 0);
        if(prev > 0 && noteEl){
          noteEl.innerHTML = "آخرین ورودِ شما به این کارتابل:<br><b>" +
            escapeGateHtml(faDateTime(prev)) + "</b>";
          btn.textContent = "در حال باز کردن…";
          setTimeout(()=> location.reload(), 2200);
        } else {
          location.reload();
        }
        return;
      }
      errEl.textContent = r.data.error || "رمز عبور اشتباه است.";
      input.select();
    }catch(err){
      errEl.textContent = "به سرور نرسیدم. اینترنت را بررسی کنید.";
    }
    btn.disabled = false; btn.textContent = "ورود";
  });

  /* ---------- رمز را فراموش کرده‌ام ----------
     رمزِ تازه را سرور می‌سازد و فقط به همان گفتگوی تلگرامی می‌فرستد که
     پشتیبان‌ها می‌روند. اینجا هیچ‌وقت دیده نمی‌شود، حتی در پاسخِ درخواست؛
     یعنی زدنِ این دکمه به‌تنهایی به کسی رمز نمی‌دهد. */
  const forgotBtn = document.getElementById("gateForgot");
  if(forgotBtn && window.KARTABL_OFFLINE) forgotBtn.style.display = "none";
  if(forgotBtn) forgotBtn.addEventListener("click", async ()=>{
    const go = confirm(
      "رمز تازه به همان گفتگوی تلگرامی فرستاده می‌شود که پشتیبان‌ها می‌روند.\n" +
      "از همان لحظه رمز فعلی از کار می‌افتد و هر دستگاهی که وارد مانده بیرون می‌افتد.\n\n" +
      "ادامه بدهم؟");
    if(!go) return;
    forgotBtn.disabled = true; errEl.textContent = "";
    noteEl.textContent = "در حال فرستادن به تلگرام...";
    try{
      const r = await apiCall("/forgot", { method: "POST" });
      if(r.ok){
        noteEl.textContent = "رمز تازه به تلگرام رفت. پیام ربات را ببینید و همان را این‌جا وارد کنید.";
        input.value = "";
        try{ input.focus(); }catch(e){}
      }else{
        noteEl.textContent = "";
        errEl.textContent = r.data.error || "نشد.";
      }
    }catch(e){
      noteEl.textContent = "";
      errEl.textContent = "به سرور نرسیدم. اینترنت را بررسی کنید.";
    }
    forgotBtn.disabled = false;
  });

  document.addEventListener("DOMContentLoaded", ()=>{
    const lock = document.getElementById("lockBtn");
    if(!lock) return;
    if(window.KARTABL_OFFLINE){ lock.style.display = "none"; return; }
    lock.addEventListener("click", async ()=>{
      try{ await apiCall("/logout", { method: "POST" }); }catch(e){}
      /* نسخهٔ محلی هم پاک می‌شود، وگرنه روی یک دستگاه مشترک داده‌ها
         بعد از «خروج» هنوز روی صفحه می‌ماند. */
      try{ localStorage.removeItem(STORE_KEY); }catch(e){}
      try{ localStorage.removeItem(DB_CACHE_KEY); }catch(e){}
      location.reload();
    });
  });
})();
</script>

<script>
const STATUS = ["انجام نشده","در حال انجام","انجام شد"];
const PRIORITY = ["بالا","متوسط","پایین"];
const CATEGORIES = (window.KARTABL_JOB && window.KARTABL_JOB.categories)
  || ["بکاپ‌گیری","سرورها و زیرساخت","امنیت سایبری","شبکه","پشتیبانی کاربران","لایسنس و تمدیدها","مانیتورینگ","مستندسازی","سایر"];

/* ---------- Resilient Chart.js loader (tries several mirrors in case one is blocked) ---------- */
const CHART_CDN_URLS = [
  /* نسخهٔ محلی روی خودِ sensacare.ir — از داخل ایران همیشه باز می‌شود.
     سیاست امنیتی سایت script-src 'self' و cdnjs است، پس jsdelivr و
     unpkg و fastly روی این دامنه هرگز بالا نمی‌آیند و فقط خطای کنسول
     می‌سازند؛ تنها پشتیبانی که واقعاً می‌تواند کار کند cdnjs است. */
  "/v/chart.umd.min.js",
  "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.4/chart.umd.min.js"
];
/* فایل ۲۰۰ کیلوبایتی روی اینترنت کند — یا بار اولی که هنوز روی لبهٔ
   کلادفلر کش نشده — راحت از شش ثانیه رد می‌شود. یک‌بار همین‌طور شد و
   صفحه بی‌دلیل سراغ CDN رفت. برای فایل خودی مهلت بلندتری می‌دهیم. */
function timeoutFor(url){ return url.charAt(0) === "/" ? 25000 : 8000; }
function loadScriptOnce(src, timeoutMs){
  return new Promise((resolve,reject)=>{
    let settled = false;
    const tag = document.createElement("script");
    const timer = setTimeout(()=>{
      if(settled) return; settled = true; tag.remove(); reject(new Error("timeout"));
    }, timeoutMs);
    tag.onload = ()=>{ if(settled) return; settled = true; clearTimeout(timer); resolve(); };
    tag.onerror = ()=>{ if(settled) return; settled = true; clearTimeout(timer); tag.remove(); reject(new Error("load-error")); };
    tag.src = src;
    document.head.appendChild(tag);
  });
}
/* بوم داخل قابی با ارتفاعِ ثابت نشسته (به .chart-box نگاه کن)، پس
   Chart.js نباید خودش نسبتِ ابعاد را نگه دارد؛ اگر نگه دارد بوم را مربع
   می‌کند و نمودار از وسطِ قاب می‌افتد بالا. */
function tuneChartDefaults(){
  if(typeof Chart === "undefined") return false;
  Chart.defaults.maintainAspectRatio = false;
  return true;
}
async function ensureChartLib(){
  if(typeof Chart !== "undefined") return tuneChartDefaults();
  for(const url of CHART_CDN_URLS){
    try{
      await loadScriptOnce(url, timeoutFor(url));
      if(typeof Chart !== "undefined") return tuneChartDefaults();
    }catch(e){ /* try the next mirror */ }
  }
  return false;
}
const chartLibPromise = ensureChartLib();

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

/* ---- tiny IndexedDB helper to remember the chosen folder handle across visits ---- */
function idbOpen(){
  return new Promise((resolve,reject)=>{
    const req = indexedDB.open("{{IDB}}", 1);
    req.onupgradeneeded = ()=> req.result.createObjectStore("handles");
    req.onsuccess = ()=> resolve(req.result);
    req.onerror = ()=> reject(req.error);
  });
}
async function idbGet(key){
  try{
    const db = await idbOpen();
    return await new Promise((resolve,reject)=>{
      const tx = db.transaction("handles","readonly");
      const rq = tx.objectStore("handles").get(key);
      rq.onsuccess = ()=> resolve(rq.result || null);
      rq.onerror = ()=> reject(rq.error);
    });
  }catch(e){ return null; }
}
async function idbSet(key,val){
  try{
    const db = await idbOpen();
    return await new Promise((resolve,reject)=>{
      const tx = db.transaction("handles","readwrite");
      tx.objectStore("handles").put(val,key);
      tx.oncomplete = ()=> resolve(true);
      tx.onerror = ()=> reject(tx.error);
    });
  }catch(e){ return false; }
}

function updateFolderStatus(text){
  const el = document.getElementById("folderStatus");
  if(el) el.textContent = text;
}

function fsaSupported(){ return typeof window.showDirectoryPicker === "function"; }

async function tryReconnectFolder(){
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
  renderMeta();
  renderMonthSelector();
  renderAll();
  scheduleSave();
}
function renderMonthSelector(){
  const sel = document.getElementById("monthSelector");
  if(!sel) return;
  const keys = Object.keys(state.monthsData||{});
  sel.innerHTML = keys.map(k=> `<option value="${escapeHtml(k)}" ${k===state.currentMonthKey?"selected":""}>${escapeHtml(monthLabelOf(k))}</option>`).join("");
}


async function loadState(){
  try{
    const raw = localStorage.getItem(STORE_KEY);
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
      type:"pie",
      data:{ labels:["انجام شده","در حال انجام","انجام نشده"],
        datasets:[{
          data:[s.done, s.doing, s.todo],
          backgroundColor:["#3C7A3E","#0F6E63","#C08A1E"],
          hoverBackgroundColor:["#4F9A52","#14897A","#DC9F27"],
          borderColor:"#fff", borderWidth:2,
          hoverOffset:12, hoverBorderWidth:3
        }] },
      options:{
        layout:{ padding:14 },
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
            backgroundColor:["#3C7A3E","#A6222B","#C08A1E"],
            hoverBackgroundColor:["#4F9A52","#C13540","#DC9F27"],
            borderColor:"#fff", borderWidth:2,
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
        data:{ labels:paired.map(p=>p.name), datasets:[{ data:paired.map(p=>p.count), backgroundColor:"#1F4E79", hoverBackgroundColor:"#2E66A0", borderRadius:4 }] },
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
        data:{ labels:paired.map(p=>p.server), datasets:[{ data:paired.map(p=>p.pct), backgroundColor:"#0F6E63", hoverBackgroundColor:"#14897A", borderRadius:4 }] },
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
            backgroundColor:["#0F6E63","#B8862B","#5B3E8C"],
            hoverBackgroundColor:["#14897A","#D69A2B","#7A55B5"],
            borderColor:"#fff", borderWidth:2, hoverOffset:12, hoverBorderWidth:3
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
            backgroundColor:["#3C7A3E","#C42E37"],
            hoverBackgroundColor:["#4F9A52","#DC4048"],
            borderColor:"#fff", borderWidth:2, hoverOffset:12, hoverBorderWidth:3
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
      type:"pie",
      data:{ labels:["انجام شده","در حال انجام","انجام نشده","بدون وضعیت"],
        datasets:[{
          data:[d.doneDays, d.doingDays, d.todoDays, d.emptyDays],
          backgroundColor:["#3C7A3E","#0F6E63","#C08A1E","#D8D2C0"],
          hoverBackgroundColor:["#4F9A52","#14897A","#DC9F27","#C4BCA4"],
          borderColor:"#fff", borderWidth:2,
          hoverOffset:12, hoverBorderWidth:3
        }] },
      options:{
        layout:{ padding:14 },
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
        <select data-field="category">
          ${CATEGORIES.map(c=>`<option value="${c}" ${t.category===c?"selected":""}>${c}</option>`).join("")}
        </select>
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
      <td><button class="btn-del" data-del="${i}" title="حذف">🗑️</button></td>
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

async function loadDatabase(){
  if(!dirHandle){
    alert("اول باید به پوشه‌ی مشترک وصل شوید — از دکمه‌ی «🗂️ اتصال به پوشه روی سیستم» در نوار کناری.");
    return;
  }
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
      data:{ labels:Object.keys(byScheduleCount), datasets:[{ data:Object.values(byScheduleCount), backgroundColor:"#1F4E79", hoverBackgroundColor:"#2E66A0", borderRadius:4 }] },
      options:{ indexAxis:"y", plugins:{legend:{display:false}, tooltip:{bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+fa(ctx.parsed.x)+" سرور"}}}, scales:{ x:{ticks:{callback:v=>fa(v), precision:0}}, y:{ticks:{font:{family:"Vazirmatn, Tahoma, Arial, sans-serif", size:11}}} } }
    });
    charts.storage = new Chart(document.getElementById("chartStorage"), {
      type:"pie",
      data:{ labels:Object.keys(byStorage), datasets:[{ data:Object.values(byStorage).map(v=>Math.round(v)), backgroundColor:["#0F6E63","#B8862B","#5B3E8C","#A6222B","#3C7A3E"], hoverOffset:12, borderColor:"#fff", borderWidth:2 }] },
      options:{ layout:{padding:14}, plugins:{legend:{position:"bottom", labels:{font:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}}}, tooltip:{bodyFont:{family:"Vazirmatn, Tahoma, Arial, sans-serif"}, callbacks:{label:(ctx)=>" "+ctx.label+": "+fa(ctx.parsed)+" GB"}}} }
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

function stageBadgeClass(stage){
  const s = String(stage||"");
  if(s.includes("فعال شده")) return "done";
  if(s.includes("حذف")) return "todo";
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
  const activeCount = all.filter(l=>String(l.stage).includes("فعال شده")).length;
  const removeCount = all.filter(l=>String(l.stage).includes("حذف")).length;

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

/* =========================================================================
   PERSONAL VAULT — بخش رمزدار «دیتای شخصی»
   داده‌ها همیشه با AES-256-GCM (کلید مشتق‌شده از رمز عبور با PBKDF2) رمزنگاری
   می‌شوند؛ نسخه‌ی رمزگشایی‌شده فقط در حافظه‌ی مرورگر (RAM) نگه‌داری می‌شود و
   هرگز به state، localStorage یا فایل اکسل نوشته نمی‌شود. اگر رمز را فراموش
   کنید، هیچ راه بازیابی‌ای وجود ندارد — این یعنی هیچ درِ پشتی‌ای هم نیست.
   ========================================================================= */
let personalUnlocked = false;
let personalCryptoKey = null;   // CryptoKey — فقط در حافظه، هرگز ذخیره نمی‌شود
let personalVaultPlain = null;  // { credentials:[], installments:[] } — فقط در حافظه
let personalActiveTab = "creds";
let personalShowPw = new Set();
let personalBusy = false;

function b64FromBuf(buf){
  const bytes = new Uint8Array(buf);
  let bin = "";
  for(let i=0;i<bytes.length;i++) bin += String.fromCharCode(bytes[i]);
  return btoa(bin);
}
function bufFromB64(b64){
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for(let i=0;i<bin.length;i++) bytes[i] = bin.charCodeAt(i);
  return bytes.buffer;
}
async function derivePersonalKey(password, saltBytes){
  const enc = new TextEncoder();
  const baseKey = await crypto.subtle.importKey("raw", enc.encode(password), "PBKDF2", false, ["deriveKey"]);
  return crypto.subtle.deriveKey(
    { name:"PBKDF2", salt:saltBytes, iterations:150000, hash:"SHA-256" },
    baseKey, { name:"AES-GCM", length:256 }, false, ["encrypt","decrypt"]
  );
}
async function encryptPersonalVault(){
  if(!personalCryptoKey || !personalVaultPlain) return;
  const enc = new TextEncoder();
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const data = enc.encode(JSON.stringify(personalVaultPlain));
  const cipherBuf = await crypto.subtle.encrypt({ name:"AES-GCM", iv }, personalCryptoKey, data);
  state.personalVault.iv = b64FromBuf(iv);
  state.personalVault.cipher = b64FromBuf(cipherBuf);
  scheduleSave();
  savePersonalSheet();
}

/* ---------- کلیدِ اضطراریِ ادمین ----------
   اگر ادمین کلیدی ساخته باشد، رمزِ این صندوق با کلیدِ عمومیِ او پیچیده
   و همان‌جا روی سرور گذاشته می‌شود. با کلیدِ عمومی فقط می‌شود پیچید؛
   باز کردنش عبارتِ عبورِ ادمین را می‌خواهد که هیچ‌وقت به سرور نمی‌رسد.

   اگر ادمین کلیدی نساخته باشد یا اینترنت نباشد، بی‌سر و صدا رد می‌شود:
   این یک تورِ اضافه است، نه شرطِ کار کردنِ صندوق. */
async function escrowVaultPassword(password){
  if(window.KARTABL_OFFLINE) return false;
  try{
    const r = await apiCall("/escrow-pub");
    const jwk = r.ok && r.data && r.data.pub;
    if(!jwk) return false;
    const pub = await crypto.subtle.importKey("jwk", jwk,
      { name:"RSA-OAEP", hash:"SHA-256" }, false, ["encrypt"]);
    const buf = await crypto.subtle.encrypt({ name:"RSA-OAEP" }, pub,
      new TextEncoder().encode(password));
    const put = await apiCall("/escrow", { method:"POST",
      body: JSON.stringify({ bundle: { cipher: b64FromBuf(buf), at: Date.now() } }) });
    return !!put.ok;
  }catch(e){ return false; }
}
async function createPersonalPassword(password){
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const key = await derivePersonalKey(password, salt);
  state.personalVault = { salt: b64FromBuf(salt), iv:"", cipher:"" };
  personalCryptoKey = key;
  personalVaultPlain = { credentials: [], installments: [], sections: {} };
  personalUnlocked = true;
  await encryptPersonalVault();
  escrowVaultPassword(password);
  renderPersonalView();
}
async function tryUnlockPersonal(password){
  if(!state.personalVault || !state.personalVault.cipher){ return createPersonalPassword(password); }
  try{
    const salt = bufFromB64(state.personalVault.salt);
    const key = await derivePersonalKey(password, salt);
    const iv = bufFromB64(state.personalVault.iv);
    const cipher = bufFromB64(state.personalVault.cipher);
    const plainBuf = await crypto.subtle.decrypt({ name:"AES-GCM", iv:new Uint8Array(iv) }, key, cipher);
    const dec = new TextDecoder();
    const parsed = JSON.parse(dec.decode(plainBuf));
    personalCryptoKey = key;
    /* هرچه در صندوق بود برمی‌گردد، نه فقط کلیدهایی که این نسخه می‌شناسد:
       اگر بخشی را ادمین خاموش کرده باشد، محتوایش این‌جا باید سالم بماند
       وگرنه اولین باز و بسته‌کردنِ صندوق پاکش می‌کند. */
    personalVaultPlain = Object.assign({}, parsed);
    if(!Array.isArray(personalVaultPlain.credentials)) personalVaultPlain.credentials = [];
    if(!Array.isArray(personalVaultPlain.installments)) personalVaultPlain.installments = [];
    if(!personalVaultPlain.sections || typeof personalVaultPlain.sections !== "object") personalVaultPlain.sections = {};
    personalUnlocked = true;
    renderPersonalView();
  }catch(e){
    const err = document.getElementById("personalLockError");
    if(err) err.textContent = "❌ رمز عبور اشتباه است.";
  }
}
function lockPersonal(){
  personalUnlocked = false;
  personalCryptoKey = null;
  personalVaultPlain = null;
  personalShowPw = new Set();
  renderPersonalView();
}
async function resetPersonalVault(){
  if(!confirm("با این کار همه‌ی داده‌های این بخش (شرکت‌ها و اقساط) برای همیشه پاک می‌شود و قابل بازگشت نیست. مطمئنید؟")) return;
  state.personalVault = null;
  state.personalRecovery = null;   /* پاکتِ بازیابی هم با صندوق می‌رود */
  lockPersonal();
  savePersonalSheet();
}

function savePersonalSheet(){
  /* آینهٔ اکسل اختیاری است و کتابخانه‌اش تنبل بار می‌شود. بدون این محافظ،
     ذخیرهٔ صندوق یک استثنای بی‌صاحب می‌انداخت: خودِ داده سرِ جایش ذخیره
     شده بود (scheduleSave قبلش اجرا می‌شود) و فقط همین آینه عقب می‌ماند،
     ولی هیچ‌کس خبردار نمی‌شد چون هیچ‌کس این promise را نمی‌گرفت. */
  if(typeof XLSX === "undefined") return;
  const blob = state.personalVault ? JSON.stringify(state.personalVault) : "";
  ensureDbWorkbook().Sheets["PersonalVault"] = XLSX.utils.aoa_to_sheet([["EncryptedBlob"],[blob]]);
  scheduleDbWrite();
}
function parsePersonalVaultSheet(wb){
  const rows = sheetToMatrix(wb, "PersonalVault");
  if(!rows || !rows[1] || !rows[1][0]) return null;
  try{ return JSON.parse(rows[1][0]); }catch(e){ return null; }
}

/* ---------- بازیابیِ رمزِ «دیتای شخصی» ----------
   سرور کلیدِ این بخش را ندارد و نمی‌تواند رمزِ تازه بسازد؛ هر رمزِ تازه‌ای
   فقط یک صندوقِ خالی باز می‌کند. پس «فراموشی» این‌جا فقط با چیزی کار
   می‌کند که از قبل خودتان ساخته باشید:

   موقع ساختنِ کد، همین‌جا در مرورگر یک کد تصادفی ساخته می‌شود، رمزِ فعلی
   با آن قفل می‌شود، و پاکتِ قفل‌شده کنار بقیهٔ داده می‌ماند. خودِ کد
   هیچ‌جا ذخیره نمی‌شود و فقط یک بار از سرور رد می‌شود تا به تلگرام برسد.
   یعنی هر کس فقط به دادهٔ سرور برسد، پاکت را دارد و کلیدش را ندارد. */

const VAULT_CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";

function makeVaultRecoveryCode(groups, per){
  groups = groups || 4; per = per || 5;
  const need = groups * per;
  /* باقی‌ماندهٔ ساده شانسِ حرف‌های اول را بیشتر می‌کند؛ بایت‌های اضافه را
     دور می‌ریزیم تا همه برابر باشند. */
  const limit = 256 - (256 % VAULT_CODE_ALPHABET.length);
  const out = [];
  while(out.length < need){
    for(const b of crypto.getRandomValues(new Uint8Array(need))){
      if(b >= limit) continue;
      out.push(VAULT_CODE_ALPHABET[b % VAULT_CODE_ALPHABET.length]);
      if(out.length === need) break;
    }
  }
  const parts = [];
  for(let i=0;i<groups;i++) parts.push(out.slice(i*per,(i+1)*per).join(""));
  return parts.join("-");
}

async function wrapVaultPassword(password, code){
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const key = await derivePersonalKey(code, salt);   /* همان PBKDF2 با ۱۵۰٬۰۰۰ دور */
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const cipher = await crypto.subtle.encrypt({ name:"AES-GCM", iv }, key,
    new TextEncoder().encode(password));
  return { salt: b64FromBuf(salt), iv: b64FromBuf(iv), cipher: b64FromBuf(cipher), at: Date.now() };
}

async function unwrapVaultPassword(envelope, code){
  const key = await derivePersonalKey(code, bufFromB64(envelope.salt));
  const buf = await crypto.subtle.decrypt(
    { name:"AES-GCM", iv:new Uint8Array(bufFromB64(envelope.iv)) }, key, bufFromB64(envelope.cipher));
  return new TextDecoder().decode(buf);
}

/* رمز را واقعاً امتحان می‌کنیم، نه اینکه حرفش را باور کنیم */
async function vaultPasswordWorks(password){
  if(!state.personalVault || !state.personalVault.cipher) return false;
  try{
    const key = await derivePersonalKey(password, bufFromB64(state.personalVault.salt));
    await crypto.subtle.decrypt(
      { name:"AES-GCM", iv:new Uint8Array(bufFromB64(state.personalVault.iv)) },
      key, bufFromB64(state.personalVault.cipher));
    return true;
  }catch(e){ return false; }
}

async function sendVaultRecoveryCode(code){
  const r = await apiCall("/vault/recovery", { method:"POST", body: JSON.stringify({ code }) });
  if(!r.ok) throw new Error(r.data.error || "به تلگرام نرسید.");
}

/* ساختنِ کدِ تازه — از داخلِ صندوقِ باز. رمز را دوباره می‌پرسیم چون
   خودمان نگهش نداشته‌ایم و برای قفل کردنش لازم است. */
async function armVaultRecovery(){
  if(window.KARTABL_OFFLINE){ alert("در نسخهٔ پشتیبان به سرور وصل نیستیم، پس کد فرستاده نمی‌شود."); return; }
  const had = !!(state.personalRecovery && state.personalRecovery.cipher);
  if(!confirm(had
    ? "یک کد بازیابیِ تازه ساخته و به تلگرام فرستاده می‌شود.\nکد قبلی از کار می‌افتد.\n\nادامه بدهم؟"
    : "یک کد بازیابی ساخته و به همان گفتگوی تلگرامیِ پشتیبان‌ها فرستاده می‌شود.\nاگر روزی رمز این بخش را فراموش کردید، با همان کد باز می‌شود و داده‌ها سرِ جایشان می‌مانند.\n\nادامه بدهم؟")) return;

  const pw = prompt("برای ساختن کد، رمزِ فعلیِ همین بخش را وارد کنید:");
  if(pw === null) return;
  if(!(await vaultPasswordWorks(pw))){ alert("❌ رمز درست نیست."); return; }

  try{
    const code = makeVaultRecoveryCode();
    const envelope = await wrapVaultPassword(pw, code);
    /* اول فرستادن، بعد ذخیره: اگر تلگرام نرفت، پاکتی که کدش به دستتان
       نرسیده روی داده نمی‌نشیند. */
    await sendVaultRecoveryCode(code);
    state.personalRecovery = envelope;
    scheduleSave();
    renderPersonalView();
    alert("✓ کد بازیابی به تلگرام رفت. آن پیام را نگه دارید.");
  }catch(e){
    alert("نشد — " + (e.message || e));
  }
}

/* بازکردن با کد — از صفحهٔ قفل */
async function recoverVaultWithCode(){
  const env = state.personalRecovery;
  if(!env || !env.cipher){ alert("کد بازیابی‌ای برای این بخش ساخته نشده."); return; }
  const code = prompt("کد بازیابی را از پیام تلگرام این‌جا وارد کنید:");
  if(code === null) return;
  let pw;
  try{
    pw = await unwrapVaultPassword(env, code.trim());
  }catch(e){
    const err = document.getElementById("personalLockError");
    if(err) err.textContent = "❌ این کد باز نکرد. دوباره از روی پیام تلگرام نگاه کنید.";
    return;
  }
  await tryUnlockPersonal(pw);
  if(personalUnlocked){
    alert("✓ باز شد و داده‌ها سرِ جایشان هستند.\nحالا یک رمز تازه بگذارید که یادتان بماند.");
    openChangePersonalPassword();
  }
}

function renderPersonalView(){
  const wrap = document.getElementById("personalWrap");
  if(!wrap) return;

  if(!personalUnlocked){
    const hasVault = !!(state.personalVault && state.personalVault.cipher);
    wrap.innerHTML = `
      <div class="lock-screen">
        <div class="ls-icon">🔒</div>
        <h3>${hasVault ? "ورود به دیتای شخصی" : "تعیین رمز عبور برای دیتای شخصی"}</h3>
        <p>${hasVault
          ? "این بخش رمزنگاری‌شده است. برای مشاهده، رمز عبور را وارد کنید."
          : "این اولین باری است که به این بخش سر می‌زنید. یک رمز عبور انتخاب کنید — این رمز، کلید رمزنگاری داده‌هاست و در هیچ‌جا ذخیره نمی‌شود. بعد از ورود، حتماً از دکمهٔ «ساختن کد بازیابی» یک کد بگیرید؛ وگرنه اگر رمز را فراموش کنید هیچ راهی برای باز کردن این بخش نمی‌ماند."}</p>
        <input type="password" id="personalPwInput" placeholder="رمز عبور" autocomplete="off">
        ${hasVault ? "" : `<input type="password" id="personalPwInput2" placeholder="تکرار رمز عبور" autocomplete="off">`}
        <button type="button" id="personalUnlockBtn">${hasVault ? "🔓 ورود" : "✅ تعیین رمز و ادامه"}</button>
        <div class="ls-error" id="personalLockError"></div>
        ${hasVault && state.personalRecovery && state.personalRecovery.cipher
          ? `<button type="button" class="ls-recover" id="personalRecoverBtn">🔐 رمز را فراموش کرده‌ام — کد بازیابی دارم</button>` : ""}
        ${hasVault ? `<button type="button" class="ls-reset" id="personalResetBtn">${state.personalRecovery && state.personalRecovery.cipher ? "پاک‌سازی کامل این بخش" : "رمز را فراموش کرده‌ام — پاک‌سازی کامل این بخش"}</button>` : ""}
      </div>`;

    const doUnlock = ()=>{
      const pw = document.getElementById("personalPwInput").value;
      if(!pw){ document.getElementById("personalLockError").textContent = "رمز عبور را وارد کنید."; return; }
      if(!hasVault){
        const pw2 = document.getElementById("personalPwInput2").value;
        if(pw.length < 4){ document.getElementById("personalLockError").textContent = "رمز عبور باید حداقل ۴ کاراکتر باشد."; return; }
        if(pw !== pw2){ document.getElementById("personalLockError").textContent = "❌ تکرار رمز عبور مطابقت ندارد."; return; }
      }
      document.getElementById("personalUnlockBtn").disabled = true;
      tryUnlockPersonal(pw);
    };
    document.getElementById("personalUnlockBtn").addEventListener("click", doUnlock);
    wrap.querySelectorAll("#personalPwInput, #personalPwInput2").forEach(inp=>{
      inp.addEventListener("keydown", e=>{ if(e.key==="Enter") doUnlock(); });
    });
    const recoverBtn = document.getElementById("personalRecoverBtn");
    if(recoverBtn) recoverBtn.addEventListener("click", recoverVaultWithCode);
    const resetBtn = document.getElementById("personalResetBtn");
    if(resetBtn) resetBtn.addEventListener("click", resetPersonalVault);
    return;
  }

  // ---- Unlocked content ----
  /* اگر ادمین بخشی را خاموش کرده و همان باز بود، می‌رویم سراغ اولی. */
  const secs = vaultSections();
  if(!secs.some(s=> s.id === personalActiveTab)) personalActiveTab = secs[0].id;
  wrap.innerHTML = `
    <div class="personal-toolbar">
      <div class="personal-tabs">
        ${vaultSections().map(s=>`<button type="button" data-ptab="${escapeHtml(s.id)}" class="${personalActiveTab===s.id?'active':''}">${VAULT_TYPE_ICON[s.type]||'📋'} ${escapeHtml(s.title||s.id)}</button>`).join("")}
      </div>
      <div style="display:flex; gap:8px;">
        <button type="button" class="btn-lock-now" id="personalRecoveryBtn">${state.personalRecovery && state.personalRecovery.cipher ? "🔐 کد بازیابی تازه" : "🔐 ساختن کد بازیابی"}</button>
        <button type="button" class="btn-lock-now" id="personalChangePwBtn">🔑 تغییر رمز</button>
        <button type="button" class="btn-lock-now" id="personalLockBtn">🔒 قفل کن</button>
      </div>
    </div>
    <div id="personalTabBody"></div>
  `;
  wrap.querySelectorAll("[data-ptab]").forEach(btn=>{
    btn.addEventListener("click", ()=>{ personalActiveTab = btn.getAttribute("data-ptab"); renderPersonalView(); });
  });
  document.getElementById("personalLockBtn").addEventListener("click", lockPersonal);
  document.getElementById("personalChangePwBtn").addEventListener("click", openChangePersonalPassword);
  document.getElementById("personalRecoveryBtn").addEventListener("click", armVaultRecovery);

  personalCurrentSection = secs.find(s=> s.id === personalActiveTab) || secs[0];
  const stype = personalCurrentSection.type;
  if(stype === "creds") renderPersonalCreds();
  else if(stype === "inst") renderPersonalInstallments();
  else renderPersonalGrid(personalCurrentSection);
}

function openChangePersonalPassword(){
  const np = prompt("رمز عبور جدید را وارد کنید (حداقل ۴ کاراکتر):");
  if(np===null) return;
  if(np.length < 4){ alert("رمز عبور باید حداقل ۴ کاراکتر باشد."); return; }
  const np2 = prompt("رمز عبور جدید را دوباره وارد کنید:");
  if(np !== np2){ alert("تکرار رمز عبور مطابقت نداشت."); return; }
  (async ()=>{
    const salt = crypto.getRandomValues(new Uint8Array(16));
    personalCryptoKey = await derivePersonalKey(np, salt);
    state.personalVault.salt = b64FromBuf(salt);
    await encryptPersonalVault();
    escrowVaultPassword(np);
    /* پاکتِ بازیابی رمزِ قبلی را قفل کرده بود، پس با عوض شدن رمز دیگر به
       درد نمی‌خورد. یا تازه‌اش می‌کنیم یا صریح می‌گوییم که خاموش شد —
       بدترین حالت این بود که کاربر خیال کند هنوز کد دارد. */
    if(state.personalRecovery && state.personalRecovery.cipher && !window.KARTABL_OFFLINE){
      try{
        const code = makeVaultRecoveryCode();
        const envelope = await wrapVaultPassword(np, code);
        await sendVaultRecoveryCode(code);
        state.personalRecovery = envelope;
        scheduleSave();
        alert("✓ رمز عوض شد. کد بازیابیِ تازه هم به تلگرام رفت؛ کد قبلی دیگر کار نمی‌کند.");
      }catch(e){
        state.personalRecovery = null;
        scheduleSave();
        alert("✓ رمز عوض شد.\n\n⚠️ ولی کد بازیابیِ تازه به تلگرام نرفت (" + (e.message||e) + ")، پس بازیابی خاموش شد. از دکمهٔ «ساختن کد بازیابی» دوباره راهش بیندازید.");
      }
      renderPersonalView();
    } else {
      alert("✓ رمز عبور با موفقیت تغییر کرد.");
    }
  })();
}


/* ---------------- بخش‌های «دیتای شخصی» ----------------
   کدام بخش‌ها برای این کاربر باز باشد را ادمین تعیین می‌کند و سرور
   همان فهرست را داخل صفحه می‌گذارد. خاموش‌کردنِ یک بخش فقط آن را از
   چشم پنهان می‌کند؛ محتوایش دست‌نخورده داخل همان صندوقِ رمزدار می‌ماند
   و با روشن‌کردنِ دوباره برمی‌گردد. */

const VAULT_DEFAULT_SECTIONS = [
  { id:"creds", type:"creds", title:"شرکت‌های من" },
  { id:"inst",  type:"inst",  title:"اقساط" }
];
const VAULT_TYPE_ICON = { creds:"🏢", inst:"💳", contacts:"📞", table:"📋" };
const VAULT_CONTACT_COLS = ["نام", "سمت / نسبت", "تلفن", "تلفن دوم", "ایمیل", "یادداشت"];

let personalCurrentSection = null;

function vaultSections(){
  const list = Array.isArray(window.KARTABL_VAULT) ? window.KARTABL_VAULT : [];
  const clean = list.filter(s=> s && s.id && s.type && VAULT_TYPE_ICON[s.type]);
  return clean.length ? clean : VAULT_DEFAULT_SECTIONS;
}

/* آرایهٔ همان بخش، داخلِ نسخهٔ رمزگشایی‌شده. دو بخشِ قدیمی کلیدِ قدیمیِ
   خودشان را نگه می‌دارند تا صندوق‌های موجود بدون دست‌کاری باز شوند. */
function vaultRows(sec){
  if(!personalVaultPlain || !sec) return [];
  if(sec.id === "creds"){ if(!personalVaultPlain.credentials) personalVaultPlain.credentials = []; return personalVaultPlain.credentials; }
  if(sec.id === "inst"){  if(!personalVaultPlain.installments) personalVaultPlain.installments = []; return personalVaultPlain.installments; }
  if(!personalVaultPlain.sections) personalVaultPlain.sections = {};
  return personalVaultPlain.sections[sec.id] || (personalVaultPlain.sections[sec.id] = []);
}
function credRows(){ return vaultRows(personalCurrentSection); }
function instRows(){ return vaultRows(personalCurrentSection); }

function vaultGridCols(sec){
  if(sec.type === "contacts") return VAULT_CONTACT_COLS;
  const cols = Array.isArray(sec.cols) ? sec.cols.filter(c=> String(c||"").trim()) : [];
  return cols.length ? cols : ["عنوان", "توضیح", "یادداشت"];
}

/* جدولِ ساده و ویرایش‌پذیر — هم برای «دفتر تلفن» و هم برای جدول‌هایی
   که ادمین ستون‌هایشان را خودش تعیین کرده. ستون‌ها با شماره ذخیره
   می‌شوند نه با نام، تا عوض‌کردنِ نامِ ستون داده را گم نکند. */
function renderPersonalGrid(sec){
  const body = document.getElementById("personalTabBody");
  if(!body) return;
  const cols = vaultGridCols(sec);
  const rows = vaultRows(sec);

  const head = cols.map(c=>`<th>${escapeHtml(c)}</th>`).join("") + `<th style="width:34px;"></th>`;
  const bodyHtml = rows.map((r, i)=>
    "<tr>" + cols.map((c, ci)=>
      `<td><input type="text" class="pg-cell" data-row="${i}" data-col="c${ci}"
         value="${escapeHtml(r["c"+ci]||"")}" placeholder="${escapeHtml(c)}"></td>`).join("") +
    `<td><button type="button" class="btn-del" data-pg-del="${i}" title="حذف این ردیف">✕</button></td></tr>`
  ).join("");

  body.innerHTML = `
    <div class="panel" style="padding:14px;">
      <div class="tbl-wrap">
        <table>
          <thead><tr>${head}</tr></thead>
          <tbody>${bodyHtml || `<tr><td colspan="${cols.length+1}" style="color:var(--ink-faint); font-size:12.5px; text-align:center; padding:14px;">هنوز چیزی ثبت نشده.</td></tr>`}</tbody>
        </table>
      </div>
      <button type="button" class="btn btn-brass btn-sm" id="pgAddRow" style="margin-top:10px;">＋ افزودن ردیف</button>
    </div>`;

  body.querySelectorAll(".pg-cell").forEach(inp=>{
    inp.addEventListener("change", ()=>{
      const r = rows[parseInt(inp.getAttribute("data-row"))];
      if(!r) return;
      r[inp.getAttribute("data-col")] = inp.value;
      encryptPersonalVault();
    });
  });
  body.querySelectorAll("[data-pg-del]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این ردیف حذف شود؟")) return;
      rows.splice(parseInt(btn.getAttribute("data-pg-del")), 1);
      encryptPersonalVault();
      renderPersonalGrid(sec);
    });
  });
  document.getElementById("pgAddRow").addEventListener("click", ()=>{
    const row = {};
    cols.forEach((c, ci)=> row["c"+ci] = "");
    rows.push(row);
    encryptPersonalVault();
    renderPersonalGrid(sec);
  });
}

/* ---------------- Personal: Companies (credentials) ---------------- */
let personalCredSelectedCompany = ""; // "" یعنی «همه»
function renderPersonalCreds(){
  const body = document.getElementById("personalTabBody");
  if(!body) return;
  const allCompanyNames = [...new Set(credRows().map(c=>String(c.company||"").trim()).filter(Boolean))]
    .sort((a,b)=> a.localeCompare(b,"fa"));
  // اگر شرکت انتخاب‌شده دیگر وجود ندارد (مثلاً حذف شده)، یا هنوز چیزی انتخاب نشده، برو روی اولین شرکت
  if((!personalCredSelectedCompany || !allCompanyNames.includes(personalCredSelectedCompany)) && allCompanyNames.length){
    personalCredSelectedCompany = allCompanyNames[0];
  }
  if(!allCompanyNames.length) personalCredSelectedCompany = "";
  const sel = personalCredSelectedCompany;
  const visibleIdx = credRows()
    .map((c,idx)=>idx)
    .filter(idx=> !sel || String(credRows()[idx].company||"").trim() === sel);

  const rows = visibleIdx.map(idx=>{
    const c = credRows()[idx];
    const shown = personalShowPw.has(idx);
    return `<tr>
      <td><input type="text" data-cred-idx="${idx}" data-cred-field="company" value="${escapeHtml(c.company||'')}" placeholder="نام شرکت"></td>
      <td><input type="text" data-cred-idx="${idx}" data-cred-field="username" value="${escapeHtml(c.username||'')}" placeholder="یوزرنیم"></td>
      <td>
        <div class="pw-cell">
          <input type="${shown?'text':'password'}" data-cred-idx="${idx}" data-cred-field="password" value="${escapeHtml(c.password||'')}" placeholder="پسورد">
          <button type="button" class="pw-toggle-btn" data-toggle-pw="${idx}" title="نمایش/مخفی‌کردن">${shown?'🙈':'👁'}</button>
        </div>
      </td>
      <td><input type="text" data-cred-idx="${idx}" data-cred-field="ip" value="${escapeHtml(c.ip||'')}" placeholder="IP / آدرس"></td>
      <td><input type="text" data-cred-idx="${idx}" data-cred-field="note" value="${escapeHtml(c.note||'')}" placeholder="توضیحات"></td>
      <td><button class="btn-del" data-remove-cred="${idx}" title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  body.innerHTML = `
    <div class="cred-import-bar">
      <p>📥 یک فایل اکسل بارگذاری کنید که هر برگه (Sheet) آن نام یک شرکت، و ردیف‌هایش به‌ترتیب عنوان/IP/یوزرنیم/پسورد باشد — همه‌چیز فقط در همین مرورگر پردازش و بلافاصله رمزنگاری می‌شود.</p>
      <button type="button" class="btn btn-brass btn-sm" id="importCredBtn">📥 انتخاب فایل اکسل/CSV</button>
      <input type="file" id="importCredFile" accept=".xlsx,.xls,.csv" style="display:none;">
      <span class="cred-import-status" id="importCredStatus"></span>
    </div>
    <div class="cred-toolbar" style="flex-direction:column; align-items:stretch;">
      <label style="font-size:12px; color:var(--ink-soft); white-space:nowrap; margin-bottom:8px;">🏢 شرکت‌ها:</label>
      <div class="company-tabs" id="companyTabs">
        ${allCompanyNames.map(name=>{
          const cnt = credRows().filter(c=>String(c.company||"").trim()===name).length;
          return `<button type="button" class="company-tab-btn ${name===sel?'active':''}" data-company-tab="${escapeHtml(name)}">
            ${escapeHtml(name)} <span class="cnt">${fa(cnt)}</span>
          </button>`;
        }).join("") || `<span style="font-size:11.5px; color:var(--ink-faint);">هنوز شرکتی اضافه نشده.</span>`}
      </div>
    </div>
    <div class="tbl-wrap">
      <table class="cred-table">
        <colgroup>
          <col style="width:14%;"><col style="width:15%;"><col style="width:30%;">
          <col style="width:18%;"><col style="width:23%;"><col style="width:36px;">
        </colgroup>
        <thead><tr><th>شرکت</th><th>یوزرنیم</th><th>پسورد</th><th>IP / آدرس</th><th>توضیحات</th><th></th></tr></thead>
        <tbody>${rows || `<tr><td colspan="6" style="color:var(--ink-faint);">${sel ? "موردی برای این شرکت پیدا نشد." : "هنوز موردی اضافه نشده."}</td></tr>`}</tbody>
      </table>
    </div>
    <div class="visit-add-bar" style="margin-top:12px;">
      <button class="btn btn-brass btn-sm" id="addCredBtn">＋ افزودن شرکت جدید</button>
    </div>
  `;
  body.querySelectorAll("[data-cred-idx]").forEach(inp=>{
    inp.addEventListener("change", onCredFieldChange);
    inp.addEventListener("input", onCredFieldChange);
  });
  body.querySelectorAll("[data-toggle-pw]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const idx = parseInt(btn.getAttribute("data-toggle-pw"));
      if(personalShowPw.has(idx)) personalShowPw.delete(idx); else personalShowPw.add(idx);
      renderPersonalCreds();
    });
  });
  body.querySelectorAll("[data-remove-cred]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این مورد حذف شود؟")) return;
      credRows().splice(parseInt(btn.getAttribute("data-remove-cred")),1);
      encryptPersonalVault();
      renderPersonalCreds();
    });
  });
  document.getElementById("addCredBtn").addEventListener("click", ()=>{
    const name = (prompt("نام شرکت جدید را وارد کنید:") || "").trim();
    if(!name){ return; }
    credRows().push({ company:name, username:"", password:"", ip:"", note:"" });
    personalCredSelectedCompany = name;
    encryptPersonalVault();
    renderPersonalCreds();
  });

  body.querySelectorAll("[data-company-tab]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      personalCredSelectedCompany = btn.getAttribute("data-company-tab");
      renderPersonalCreds();
    });
  });

  document.getElementById("importCredBtn").addEventListener("click", ()=>{
    document.getElementById("importCredFile").click();
  });
  document.getElementById("importCredFile").addEventListener("change", async (e)=>{
    const file = e.target.files[0];
    if(!file) return;
    const status = document.getElementById("importCredStatus");
    status.textContent = "در حال خواندن فایل...";
    try{
      if(typeof ensureXlsxLib === "function"){
        const ok = await ensureXlsxLib();
        if(!ok){ status.textContent = "⚠️ کتابخانه‌ی خواندن فایل بارگذاری نشد."; return; }
      }
      const buf = await file.arrayBuffer();
      const wb = XLSX.read(buf, {type:"array", raw:true, cellDates:false});
      let added = 0;
      wb.SheetNames.forEach(sheetName=>{
        const rows2 = XLSX.utils.sheet_to_json(wb.Sheets[sheetName], {header:1, raw:true, defval:null});
        if(!rows2 || !rows2.length) return;
        rows2.forEach(row=>{
          if(!row || row.every(c=>c==null || String(c).trim()==="")) return;
          const c1 = row[1]!=null ? String(row[1]).trim().toLowerCase() : "";
          const c2 = row[2]!=null ? String(row[2]).trim().toLowerCase() : "";
          const c3 = row[3]!=null ? String(row[3]).trim().toLowerCase() : "";
          if(c1==="ip" || c2==="user" || c2==="username" || c3==="pass" || c3==="password") return; // ردیف سربرگ
          const label = row[0]!=null ? String(row[0]).trim() : "";
          const ip = row[1]!=null ? String(row[1]).trim() : "";
          const username = row[2]!=null ? String(row[2]).trim() : "";
          const password = row[3]!=null ? String(row[3]).trim() : "";
          const extra = row.slice(4).filter(v=>v!=null && String(v).trim()!=="").map(v=>String(v).trim());
          const noteParts = [];
          if(label) noteParts.push(label);
          if(extra.length) noteParts.push(extra.join(" | "));
          credRows().push({
            company: sheetName, username, password, ip, note: noteParts.join(" — ")
          });
          added++;
        });
      });
      encryptPersonalVault();
      renderPersonalCreds();
      status.textContent = `✓ ${toPersianDigits(added)} ردیف بارگذاری و رمزنگاری شد.`;
    }catch(err){
      console.error(err);
      status.textContent = "⚠️ خطا در خواندن فایل.";
    }
    e.target.value = "";
  });
}
function onCredFieldChange(e){
  const idx = parseInt(e.target.getAttribute("data-cred-idx"));
  const field = e.target.getAttribute("data-cred-field");
  credRows()[idx][field] = e.target.value;
  encryptPersonalVault();
}

/* ---------------- Personal: Installments ---------------- */
function addJalaliMonths(y, m, d, n){
  let totalM = (m-1) + n;
  let ny = y + Math.floor(totalM/12);
  let nm = (totalM%12) + 1;
  if(nm<1){ nm+=12; ny-=1; }
  const maxD = daysInJalaliMonth(ny, nm);
  return { y:ny, m:nm, d:Math.min(d, maxD) };
}
function formatJalaliYMD(y,m,d){
  return fa(y)+"/"+fa(String(m).padStart(2,"0"))+"/"+fa(String(d).padStart(2,"0"));
}
function calcInstallment(principal, count, annualPercent){
  const r = (parseFloat(annualPercent)||0)/100/12; // نرخ سود ماهانه
  let per;
  if(r > 0){
    per = principal * r * Math.pow(1+r, count) / (Math.pow(1+r, count) - 1);
  } else {
    per = principal / count;
  }
  return { per, total: per * count };
}
function formatThousandsInput(input){
  const raw = input.value.replace(/[^\d]/g,"");
  input.value = raw ? Number(raw).toLocaleString("en-US") : "";
}
function numFromFormatted(id){
  const v = document.getElementById(id).value.replace(/,/g,"");
  return v ? parseFloat(v) : NaN;
}
function renderPersonalInstallments(){
  const body = document.getElementById("personalTabBody");
  if(!body) return;
  const todayParts = getTodayJalaliParts();
  const today = { year: parseInt(todayParts.year)||1405, month: todayParts.monthNum||1, day: todayParts.day||1 };
  const nDaysStart = daysInJalaliMonth(today.year, today.month);

  const cardsHtml = instRows().map((plan, pIdx)=>{
    const { per, total } = calcInstallment(plan.principal, plan.count, plan.percent);
    const paidCount = plan.paid.filter(Boolean).length;
    const remaining = total - (per*paidCount);
    const scheduleRows = Array.from({length:plan.count}, (_,i)=>{
      const due = addJalaliMonths(plan.startY, plan.startM, plan.startD, i);
      const isPaid = !!plan.paid[i];
      return `<tr class="${isPaid?'paid':''}">
        <td>${fa(i+1)}</td>
        <td>${formatJalaliYMD(due.y,due.m,due.d)}</td>
        <td>${fa(Math.round(per).toLocaleString("en-US"))}</td>
        <td><button type="button" class="inst-pay-toggle ${isPaid?'paid':''}" data-pay-plan="${pIdx}" data-pay-inst="${i}">${isPaid?'✓ پرداخت‌شده':'پرداخت‌نشده'}</button></td>
      </tr>`;
    }).join("");
    return `
      <div class="inst-card">
        <div class="inst-card-head">
          <h4>${escapeHtml(plan.title||'بدون عنوان')}</h4>
          <button class="btn-del" data-remove-inst="${pIdx}" title="حذف این وام">✕</button>
        </div>
        <div class="inst-summary">
          مبلغ اصل وام: <b>${fa(plan.principal.toLocaleString("en-US"))}</b> تومان — نرخ سود سالانه: <b>${fa(plan.percent)}٪</b> — تعداد اقساط: <b>${fa(plan.count)}</b><br>
          مبلغ کل قابل‌پرداخت: <b>${fa(Math.round(total).toLocaleString("en-US"))}</b> تومان — مبلغ هر قسط: <b>${fa(Math.round(per).toLocaleString("en-US"))}</b> تومان<br>
          پرداخت‌شده: <b>${fa(paidCount)}/${fa(plan.count)}</b> قسط — مانده: <b>${fa(Math.round(remaining).toLocaleString("en-US"))}</b> تومان
        </div>
        <table class="inst-schedule">
          <thead><tr><th>#</th><th>تاریخ سررسید</th><th>مبلغ (تومان)</th><th>وضعیت</th></tr></thead>
          <tbody>${scheduleRows}</tbody>
        </table>
      </div>`;
  }).join("");

  body.innerHTML = `
    <div class="panel" style="padding:16px; margin-bottom:16px;">
      <h4 style="margin:0 0 10px; font-family:var(--font-display); font-size:14px;">＋ افزودن وام/قسط جدید</h4>
      <div class="inst-form">
        <input type="text" id="instTitle" placeholder="عنوان — مثلاً: وام خرید تجهیزات">
        <input type="text" inputmode="numeric" id="instPrincipal" placeholder="مبلغ اصل وام (تومان)">
        <input type="number" id="instCount" placeholder="تعداد اقساط" min="1">
        <input type="number" id="instPercent" placeholder="نرخ سود سالانه (٪)" step="0.1" min="0">
      </div>
      <div class="inst-date-row">
        <label>تاریخ شروع اقساط (شمسی):</label>
        <select id="instDay"></select>
        <select id="instMonth"></select>
        <select id="instYear"></select>
      </div>
      <p class="inst-note">📌 محاسبه به روش استاندارد «اقساط مساوی» (فرمول تنزیل / همان روشی که وام‌های بانکی و اکثر سایت‌های محاسبه‌ی اقساط استفاده می‌کنند) انجام می‌شود: نرخ سود سالانه به نرخ ماهانه تبدیل شده و قسط ثابت ماهانه از روی آن محاسبه می‌شود. سررسید هر قسط، یک ماه شمسی بعد از قسط قبلی است.</p>
      <button type="button" class="btn btn-brass btn-sm" id="addInstallmentBtn">محاسبه و افزودن</button>
    </div>
    ${cardsHtml || `<p style="color:var(--ink-faint); font-size:12.5px;">هنوز وام/قسطی ثبت نشده.</p>`}
  `;

  const daySel = document.getElementById("instDay");
  const monthSel = document.getElementById("instMonth");
  const yearSel = document.getElementById("instYear");
  monthSel.innerHTML = JALALI_MONTH_NAMES.map((m,i)=>`<option value="${i+1}" ${i+1===today.month?"selected":""}>${m}</option>`).join("");
  for(let y=1400; y<=today.year+5; y++) yearSel.innerHTML += `<option value="${y}" ${y===today.year?"selected":""}>${fa(y)}</option>`;
  function refreshInstDays(){
    const y = parseInt(yearSel.value), m = parseInt(monthSel.value);
    const keep = parseInt(daySel.value) || today.day;
    daySel.innerHTML = jalaliMonthDayOptions(y, m, Math.min(keep, daysInJalaliMonth(y,m)));
  }
  daySel.innerHTML = jalaliMonthDayOptions(today.year, today.month, today.day);
  yearSel.addEventListener("change", refreshInstDays);
  monthSel.addEventListener("change", refreshInstDays);

  const principalInput = document.getElementById("instPrincipal");
  principalInput.addEventListener("input", ()=> formatThousandsInput(principalInput));

  document.getElementById("addInstallmentBtn").addEventListener("click", ()=>{
    const title = document.getElementById("instTitle").value.trim();
    const principal = numFromFormatted("instPrincipal");
    const count = parseInt(document.getElementById("instCount").value);
    const percent = parseFloat(document.getElementById("instPercent").value) || 0;
    if(!principal || principal<=0){ alert("مبلغ اصل وام را درست وارد کنید."); return; }
    if(!count || count<=0){ alert("تعداد اقساط را درست وارد کنید."); return; }
    const startY = parseInt(yearSel.value), startM = parseInt(monthSel.value), startD = parseInt(daySel.value);
    instRows().push({
      title, principal, count, percent, startY, startM, startD, paid: Array.from({length:count}, ()=>false)
    });
    encryptPersonalVault();
    renderPersonalInstallments();
  });

  body.querySelectorAll("[data-remove-inst]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این وام/قسط حذف شود؟")) return;
      instRows().splice(parseInt(btn.getAttribute("data-remove-inst")),1);
      encryptPersonalVault();
      renderPersonalInstallments();
    });
  });
  body.querySelectorAll("[data-pay-plan]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const pIdx = parseInt(btn.getAttribute("data-pay-plan"));
      const iIdx = parseInt(btn.getAttribute("data-pay-inst"));
      const plan = instRows()[pIdx];
      plan.paid[iIdx] = !plan.paid[iIdx];
      encryptPersonalVault();
      renderPersonalInstallments();
    });
  });
}

function renderAll(){
  renderDashHero();
  renderCards();
  renderDeadlines();
  renderCharts();
  renderChecklist();
  renderDaily();
  renderRemindersBanner();
}

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
  const sel = document.getElementById("monthSelector");
  if(sel) sel.addEventListener("change", ()=>{
    const key = sel.value;
    const [year, month] = key.split("|");
    switchToMonth(month, year);
  });
  const newBtn = document.getElementById("newMonthBtn");
  const panel = document.getElementById("newMonthPanel");
  if(newBtn) newBtn.addEventListener("click", ()=>{
    panel.style.display = panel.style.display==="none" ? "flex" : "none";
    document.getElementById("newMonthName").focus();
  });
  const cancelBtn = document.getElementById("cancelNewMonthBtn");
  if(cancelBtn) cancelBtn.addEventListener("click", ()=>{ panel.style.display = "none"; });
  const confirmBtn = document.getElementById("confirmNewMonthBtn");
  if(confirmBtn) confirmBtn.addEventListener("click", ()=>{
    const name = document.getElementById("newMonthName").value.trim();
    const year = document.getElementById("newMonthYear").value.trim();
    if(!name || !year){ alert("نام ماه و سال را کامل وارد کنید."); return; }
    const key = monthKeyOf(name, year);
    if(state.monthsData[key] && !confirm("این ماه از قبل وجود دارد. بروید به همان ماه؟")) return;
    switchToMonth(name, year);
    panel.style.display = "none";
    document.getElementById("newMonthName").value = "";
    document.getElementById("newMonthYear").value = "";
  });
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

function setupDateTools(){
  /* در کارتابلِ عمومی این نما وجود ندارد */
  if(!document.getElementById("dtDiffBtn")) return;
  const today = getTodayJalaliParts();
  const ty = parseInt(today.year)||1405, tm = today.monthNum||1, td = today.day||1;

  // ---- شمسی → میلادی ----
  const jy = document.getElementById("dtJY"), jm = document.getElementById("dtJM"), jd = document.getElementById("dtJD");
  fillJalaliYearSelect(jy, ty);
  fillJalaliMonthSelect(jm, tm);
  jd.innerHTML = jalaliMonthDayOptions(ty, tm, td);
  function recomputeJ2G(){
    const y=parseInt(jy.value), m=parseInt(jm.value), keepD=parseInt(jd.value)||1;
    jd.innerHTML = jalaliMonthDayOptions(y, m, Math.min(keepD, daysInJalaliMonth(y,m)));
    const d = parseInt(jd.value);
    const g = jalaliToGregorian(y,m,d);
    document.getElementById("dtJ2GResult").textContent = formatGregorianLong(g.gy, g.gm, g.gd);
  }
  [jy,jm,jd].forEach(el=> el.addEventListener("change", recomputeJ2G));
  recomputeJ2G();

  // ---- میلادی → شمسی ----
  const gInput = document.getElementById("dtGDate");
  const now = new Date();
  gInput.value = `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,"0")}-${String(now.getDate()).padStart(2,"0")}`;
  function recomputeG2J(){
    if(!gInput.value){ document.getElementById("dtG2JResult").textContent = "—"; return; }
    const [gy,gm,gd] = gInput.value.split("-").map(Number);
    const j = gregorianToJalali(gy,gm,gd);
    document.getElementById("dtG2JResult").textContent = formatJalaliLong(j.jy, j.jm, j.jd);
  }
  gInput.addEventListener("change", recomputeG2J);
  recomputeG2J();

  // ---- محاسبه‌ی فاصله‌ی بین دو تاریخ شمسی ----
  const sy=document.getElementById("dtStartY"), sm=document.getElementById("dtStartM"), sd=document.getElementById("dtStartD");
  const ey=document.getElementById("dtEndY"), em=document.getElementById("dtEndM"), ed=document.getElementById("dtEndD");
  fillJalaliYearSelect(sy, ty); fillJalaliMonthSelect(sm, tm); sd.innerHTML = jalaliMonthDayOptions(ty, tm, td);
  fillJalaliYearSelect(ey, ty); fillJalaliMonthSelect(em, tm); ed.innerHTML = jalaliMonthDayOptions(ty, tm, td);
  function refreshDayOptions(ySel,mSel,dSel){
    const y=parseInt(ySel.value), m=parseInt(mSel.value), keepD=parseInt(dSel.value)||1;
    dSel.innerHTML = jalaliMonthDayOptions(y, m, Math.min(keepD, daysInJalaliMonth(y,m)));
  }
  sy.addEventListener("change", ()=>refreshDayOptions(sy,sm,sd));
  sm.addEventListener("change", ()=>refreshDayOptions(sy,sm,sd));
  ey.addEventListener("change", ()=>refreshDayOptions(ey,em,ed));
  em.addEventListener("change", ()=>refreshDayOptions(ey,em,ed));

  document.getElementById("dtDiffBtn").addEventListener("click", ()=>{
    const y1=parseInt(sy.value), m1=parseInt(sm.value), d1=parseInt(sd.value);
    const y2=parseInt(ey.value), m2=parseInt(em.value), d2=parseInt(ed.value);
    const jdn1 = j2d(y1,m1,d1), jdn2 = j2d(y2,m2,d2);
    const totalDays = Math.abs(jdn2 - jdn1);
    // شکست تقویمی فاصله به سال/ماه/روز (مستقل از جهت، همیشه تاریخ کوچک‌تر را به‌عنوان مبدا در نظر می‌گیرد)
    let [ay1,am1,ad1,ay2,am2,ad2] = jdn1<=jdn2 ? [y1,m1,d1,y2,m2,d2] : [y2,m2,d2,y1,m1,d1];
    let dd = ad2-ad1, mm = am2-am1, yy = ay2-ay1;
    if(dd<0){
      mm -= 1;
      let bm = am2-1, by = ay2;
      if(bm<1){ bm = 12; by -= 1; }
      dd += daysInJalaliMonth(by, bm);
    }
    if(mm<0){ mm += 12; yy -= 1; }
    const resultEl = document.getElementById("dtDiffResult");
    resultEl.innerHTML = `
      مجموع فاصله: <b>${fa(totalDays)}</b> روز (تقریباً <b>${fa(Math.round(totalDays/7))}</b> هفته)<br>
      به‌صورت تقویمی: <b>${fa(yy)}</b> سال، <b>${fa(mm)}</b> ماه و <b>${fa(dd)}</b> روز
    `;
  });
}

/* ---------- همگام‌سازی با سرور ----------
   کارتابل تا دیروز فقط در حافظهٔ همین مرورگر زندگی می‌کرد: با عوض کردن
   دستگاه یا پاک شدن حافظهٔ مرورگر همه‌چیز می‌رفت. حالا سرور مرجع است و
   حافظهٔ مرورگر فقط نسخهٔ آفلاین می‌ماند — اگر اینترنت نبود کارتابل باز
   می‌شود و کار می‌کند، و به‌محض وصل شدن، تغییرها بالا می‌روند.

   دو تکه بالا و پایین می‌رود: «state» (وظایف، برنامهٔ روزانه، ماه‌ها،
   بخش شخصیِ رمزشده) و «db» (سرورها، شرکت‌ها، MVPN، لاگ بکاپ، ریموت). */

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

const Cloud = (function(){
  let rev = null;          /* نسخه‌ای که این مرورگر از آن شروع کرده */
  let online = false;      /* آخرین بار توانستیم با سرور حرف بزنیم؟ */
  let blocked = false;     /* سرور علامت خرابی داده — تا روشن نشدن ننویس */
  let timer = null;
  let inFlight = false;
  let again = false;       /* وسط ارسال، تغییر تازه‌ای رسید */

  function setHint(text){
    const h = document.getElementById("saveHint");
    if(h) h.textContent = text;
  }
  function setCloudStatus(text){
    const el = document.getElementById("cloudStatus");
    if(el) el.textContent = text;
  }

  /* وقتی دو دستگاه هم‌زمان کار کرده‌اند، بی‌صدا روی کار دیگری نمی‌نویسیم */
  function showConflict(){
    if(document.getElementById("syncConflict")) return;
    const bar = document.createElement("div");
    bar.id = "syncConflict";
    bar.innerHTML =
      '<span>این کارتابل از دستگاه دیگری هم تغییر کرده است. کدام نسخه بماند؟</span>' +
      '<button type="button" id="conflictTake">نسخهٔ سرور را بیاور</button>' +
      '<button type="button" id="conflictKeep">نسخهٔ من را بنویس</button>';
    document.body.appendChild(bar);
    document.getElementById("conflictTake").addEventListener("click", ()=> location.reload());
    document.getElementById("conflictKeep").addEventListener("click", async ()=>{
      /* این دکمه کارِ دستگاه دیگر را دور می‌ریزد. قبلاً بی‌هشدار بود. */
      if(!confirm("هر تغییری که از دستگاه دیگر ذخیره شده برای همیشه با نسخهٔ همین صفحه جایگزین می‌شود.\n\nمطمئنید؟")) return;
      bar.remove();
      rev = null;                 /* بدون baseRev یعنی «همین را بنویس» */
      await push(true, true);
    });
  }

  /* سرور جلوی نوشتنی را گرفته که بخش بزرگی از داده را می‌برد */
  function showLoss(why){
    if(document.getElementById("syncLoss")) return;
    const bar = document.createElement("div");
    bar.id = "syncLoss"; bar.className = "sync-warn";
    bar.innerHTML =
      '<span>این ذخیره ' + escapeHtml(why) + '. عمدی بود؟</span>' +
      '<button type="button" id="lossKeep">بله، همین را بنویس</button>' +
      '<button type="button" id="lossTake">نه، نسخهٔ سرور را بیاور</button>';
    document.body.appendChild(bar);
    document.getElementById("lossTake").addEventListener("click", ()=> location.reload());
    document.getElementById("lossKeep").addEventListener("click", async ()=>{
      bar.remove();
      await push(true, true);
    });
  }

  async function pull(){
    if(window.KARTABL_OFFLINE){ setCloudStatus("نسخهٔ پشتیبان — روی سرور نیست."); return false; }
    try{
      const r = await apiCall("/state");
      if(r.status === 401){ online = false; setCloudStatus("وارد نشده‌اید."); return false; }
      if(!r.ok) throw new Error(r.data.error || "خطای سرور");
      /* تلهٔ اصلی این‌جا بود: اگر سرور چیزی برنمی‌گرداند، کدِ قبلی نسخهٔ
         کهنهٔ همین مرورگر را نگه می‌داشت، خودش را «آنلاین» اعلام می‌کرد و
         با اولین ویرایش همان کهنه را روی سرور می‌نوشت. حالا فرق می‌گذاریم
         بین «سرور تازه است و هنوز چیزی ندارد» (rev صفر) و «سرور داده دارد
         ولی نیامد» (rev بزرگ‌تر از صفر) — دومی یعنی یک جای کار خراب است و
         تا روشن نشده هیچ نوشتنی نباید انجام شود. */
      const srvRev = r.data.rev || 0;
      if(!r.data.state && srvRev > 0){
        online = false; blocked = true; rev = null;
        setCloudStatus("⚠️ سرور دادهٔ این کارتابل را برنگرداند. تا روشن نشدن، ذخیره متوقف است — چیزی را عوض نکنید.");
        return false;
      }
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

  async function push(force, confirmed){
    if(window.KARTABL_OFFLINE) return;
    /* وقتی سرور علامت خرابی داده، هیچ چیزی بالا نمی‌رود — حتی با force */
    if(blocked){ setHint("ذخیره متوقف است"); return; }
    if(!online && !force) return;
    /* نسخهٔ سرور را نشناخته‌ایم، پس نمی‌دانیم روی چه چیزی می‌نویسیم */
    if(rev === null && !confirmed){ setHint("هنوز با سرور هماهنگ نشده‌ایم"); return; }
    if(inFlight){ again = true; return; }
    inFlight = true;
    setHint("در حال ذخیره روی سرور...");
    try{
      const payload = { state: state, db: dbSnapshot() };
      if(rev !== null) payload.baseRev = rev;
      if(confirmed) payload.force = true;
      const r = await apiCall("/state", { method: "PUT", body: JSON.stringify(payload) });
      if(r.status === 409){
        inFlight = false;
        if(r.data.broken){
          blocked = true;
          setHint("ذخیره متوقف شد");
          setCloudStatus("⚠️ دادهٔ روی سرور خوانا نیست. چیزی را عوض نکنید و خبر بدهید.");
          return;
        }
        if(r.data.loss){ showLoss(r.data.loss); setHint("ذخیره نشد — منتظر تأیید"); return; }
        showConflict(); setHint("ذخیره نشد — تداخل نسخه"); return;
      }
      if(r.status === 401){ inFlight = false; online = false; setHint("وارد نشده‌اید"); return; }
      if(!r.ok) throw new Error(r.data.error || "خطای سرور");
      rev = r.data.rev;
      online = true;
      setHint("✓ ذخیره شد");
      setCloudStatus("آخرین همگام‌سازی: " + new Date(r.data.updated).toLocaleString("fa-IR"));
    }catch(e){
      /* نسخهٔ محلی از قبل نوشته شده، پس چیزی گم نمی‌شود */
      setHint("✓ ذخیره شد (فقط روی این مرورگر)");
      setCloudStatus("آفلاین — تغییرها با وصل شدن بالا می‌روند.");
    }
    inFlight = false;
    if(again){ again = false; schedule(); }
  }

  function schedule(){
    clearTimeout(timer);
    timer = setTimeout(()=> push(false), 900);
  }

  return { pull, push: schedule, pushNow: push, isOnline: ()=> online };
})();

/* ---------- بخش تنظیمات ----------
   رمز ورود و ربات پشتیبان، هر دو از داخل خودِ کارتابل. هیچ‌کدام از این‌ها
   در فایل صفحه ننشسته‌اند؛ همه روی سرور تنظیم می‌شوند. */

function setState(id, text, kind){
  const el = document.getElementById(id);
  if(!el) return;
  el.textContent = text;
  el.className = "set-state" + (kind ? " " + kind : "");
}

function faTime(ms){
  try{ return new Date(ms).toLocaleString("fa-IR"); }catch(e){ return ""; }
}

async function refreshBackupSettings(){
  /* روی نسخهٔ پشتیبان یا بدون اینترنت، این درخواست می‌افتد. بدون این
     try، همان افتادن یک unhandled rejection می‌شد. */
  if(window.KARTABL_OFFLINE || !signedIn) return;
  let r;
  try{ r = await apiCall("/backup/settings"); }
  catch(e){ setState("botState", "به سرور نرسیدم.", "err"); return; }
  if(!r.ok) return;
  const d = r.data;
  setState("botState", d.hasToken
    ? ("ربات ثبت شده" + (d.botName ? ": @" + d.botName : ""))
    : "هنوز توکنی ثبت نشده.", d.hasToken ? "ok" : "");
  setState("connectState", d.chat ? "وصل است (گفتگوی " + d.chat + ")" : "هنوز وصل نشده.",
    d.chat ? "ok" : "");
  if(d.last){
    setState("lastBackup", d.last.ok
      ? "آخرین پشتیبان: " + faTime(d.last.at) + " — " + Math.round((d.last.size||0)/1024) + " کیلوبایت"
      : "آخرین تلاش ناموفق بود (" + faTime(d.last.at) + "): " + (d.last.error||""),
      d.last.ok ? "ok" : "err");
  } else {
    setState("lastBackup", "هنوز پشتیبانی فرستاده نشده.");
  }
}

function setupSettings(){
  if(window.KARTABL_OFFLINE){
    /* در نسخهٔ پشتیبان نه رمزی هست که عوض شود نه رباتی که تنظیم شود */
    const nav = document.querySelector('.navbtn[data-view="settings"]');
    if(nav) nav.style.display = "none";
    return;
  }
  /* --- عوض کردن رمز --- */
  const form = document.getElementById("passForm");
  if(form) form.addEventListener("submit", async (e)=>{
    e.preventDefault();
    const cur = document.getElementById("passCurrent").value;
    const next = document.getElementById("passNext").value;
    const rep = document.getElementById("passRepeat").value;
    if(next !== rep){ setState("passState", "دو رمز تازه یکی نیستند.", "err"); return; }
    if(next.length < 8){ setState("passState", "رمز تازه باید دست‌کم ۸ کاراکتر باشد.", "err"); return; }
    const btn = document.getElementById("passBtn");
    btn.disabled = true; setState("passState", "در حال ثبت…");
    const r = await apiCall("/password", { method:"POST", body: JSON.stringify({ current: cur, next: next }) });
    btn.disabled = false;
    if(r.ok){
      form.reset();
      setState("passState", "✓ رمز عوض شد. دستگاه‌های دیگر باید دوباره وارد شوند.", "ok");
    } else {
      setState("passState", r.data.error || "ثبت نشد.", "err");
    }
  });

  /* --- ثبت توکن ربات --- */
  const saveBtn = document.getElementById("botSaveBtn");
  if(saveBtn) saveBtn.addEventListener("click", async ()=>{
    const token = document.getElementById("botToken").value.trim();
    if(!token){ setState("botState", "توکن را بنویسید.", "err"); return; }
    saveBtn.disabled = true; setState("botState", "در حال بررسی توکن…");
    const r = await apiCall("/backup/settings", { method:"POST", body: JSON.stringify({ token }) });
    saveBtn.disabled = false;
    if(r.ok){
      document.getElementById("botToken").value = "";
      setState("botState", "✓ ثبت شد: @" + r.data.botName, "ok");
    } else {
      setState("botState", r.data.error || "ثبت نشد.", "err");
    }
  });

  /* --- پیدا کردن گفتگو --- */
  const connectBtn = document.getElementById("botConnectBtn");
  if(connectBtn) connectBtn.addEventListener("click", async ()=>{
    connectBtn.disabled = true; setState("connectState", "دنبال پیام شما در ربات می‌گردم…");
    const r = await apiCall("/backup/connect", { method:"POST", body: "{}" });
    connectBtn.disabled = false;
    if(r.ok) setState("connectState", "✓ وصل شد به «" + (r.data.name||r.data.chat) + "»", "ok");
    else setState("connectState", r.data.error || "وصل نشد.", "err");
  });

  /* --- پشتیبان دستی --- */
  const nowBtn = document.getElementById("backupNowBtn");
  if(nowBtn) nowBtn.addEventListener("click", async ()=>{
    nowBtn.disabled = true; setState("backupState", "در حال ساختن و فرستادن پشتیبان…");
    const r = await apiCall("/backup/now", { method:"POST", body: "{}" });
    nowBtn.disabled = false;
    if(r.ok){
      setState("backupState", "✓ فرستاده شد — " + Math.round(r.data.size/1024) + " کیلوبایت", "ok");
      refreshBackupSettings();
    } else {
      setState("backupState", r.data.error || "فرستاده نشد.", "err");
    }
  });

  const dlBtn = document.getElementById("backupDownloadBtn");
  if(dlBtn) dlBtn.addEventListener("click", ()=>{
    setState("backupState", "در حال آماده کردن فایل…");
    location.href = KARTABL_API + "/backup/download";
    setTimeout(()=> setState("backupState", ""), 3000);
  });

  refreshBackupSettings();
}


/* ---------- تم روز و شب ----------
   انتخاب هر پلنر جداست و در حافظهٔ همان مرورگر می‌ماند. پیش‌فرض روز است
   تا چیزی بی‌خبر عوض نشود؛ تا وقتی دکمه را نزنید همان شکل قبلی می‌ماند. */
const THEME_KEY = STORE_KEY + ":theme";

function currentTheme(){
  return document.documentElement.getAttribute("data-theme") === "dark" ? "dark" : "light";
}

function redrawAfterTheme(){ renderAll(); }

function applyTheme(mode){
  const dark = mode === "dark";
  document.documentElement.setAttribute("data-theme", dark ? "dark" : "light");
  const btn = document.getElementById("themeBtn");
  if(btn){
    btn.textContent = dark ? "\u2600\ufe0f" : "\ud83c\udf19";
    btn.title = dark ? "تم روز" : "تم شب";
    btn.setAttribute("aria-label", btn.title);
  }
  /* نمودارها رنگ متن و خطوطشان را موقع ساخته شدن می‌گیرند، پس باید
     دوباره کشیده شوند وگرنه در شب سیاه روی سیاه می‌مانند. */
  try{
    if(typeof Chart !== "undefined"){
      Chart.defaults.color = dark ? "#AFBDCB" : "#3E5164";
      Chart.defaults.borderColor = dark ? "rgba(255,255,255,.10)" : "rgba(11,37,69,.10)";
    }
  }catch(e){}
  try{ localStorage.setItem(THEME_KEY, mode); }catch(e){}
}

function setupTheme(){
  let saved = null;
  try{ saved = localStorage.getItem(THEME_KEY); }catch(e){}
  applyTheme(saved === "dark" ? "dark" : "light");
  const btn = document.getElementById("themeBtn");
  if(btn) btn.addEventListener("click", ()=>{
    applyTheme(currentTheme() === "dark" ? "light" : "dark");
    try{ redrawAfterTheme(); }catch(e){}
  });
}

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
let aiHistory = [];
let aiBusy = false;

function aiLoadHistory(){
  try{ const v = JSON.parse(localStorage.getItem(AI_KEY)); aiHistory = Array.isArray(v) ? v : []; }
  catch(e){ aiHistory = []; }
}
function aiSaveHistory(){
  /* فقط چهل پیامِ آخر می‌ماند، وگرنه حافظهٔ مرورگر بی‌خود پر می‌شود */
  try{ localStorage.setItem(AI_KEY, JSON.stringify(aiHistory.slice(-40))); }catch(e){}
}

/* متنِ جواب با textContent نمی‌رود چون می‌خواهیم **پررنگ** و `کد` را
   نشان بدهیم؛ پس اول کامل escape می‌شود و بعد فقط همین دو تا برمی‌گردند.
   این‌طوری هیچ HTMLی از جوابِ مدل اجرا نمی‌شود. */
function aiFormat(text){
  const safe = String(text)
    .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  return safe
    .replace(/`([^`\n]+)`/g, "<code>$1</code>")
    .replace(/\*\*([^*\n]+)\*\*/g, "<strong>$1</strong>");
}

function aiRenderLog(){
  const log = document.getElementById("aiLog");
  if(!log) return;
  if(!aiHistory.length){
    log.innerHTML = '<div class="ai-empty"><span class="big">🤖</span>' +
      'سلام! هر چه می‌خواهید بپرسید.<br>هم از کارتابل می‌دانم، هم سؤال‌های دیگرتان را جواب می‌دهم.</div>';
    return;
  }
  log.innerHTML = aiHistory.map(m =>
    '<div class="ai-msg ' + (m.role === "user" ? "me" : (m.error ? "err" : "bot")) + '">' +
    aiFormat(m.content) + '</div>').join("");
  log.scrollTop = log.scrollHeight;
}

function aiSetBusy(on){
  aiBusy = on;
  const b = document.getElementById("aiSend");
  const t = document.getElementById("aiInput");
  if(b){ b.disabled = on; b.textContent = on ? "…" : "بفرست"; }
  if(t) t.disabled = on;
}

async function aiAsk(text){
  const q = String(text || "").trim();
  if(!q || aiBusy) return;
  if(window.KARTABL_OFFLINE){
    aiHistory.push({ role:"assistant", content:"این نسخهٔ پشتیبان است و به سرور وصل نیست، پس دستیار کار نمی‌کند.", error:true });
    aiRenderLog(); return;
  }
  aiHistory.push({ role:"user", content:q });
  aiSaveHistory(); aiRenderLog(); aiSetBusy(true);

  const log = document.getElementById("aiLog");
  if(log){
    const wait = document.createElement("div");
    wait.className = "ai-msg bot"; wait.id = "aiWait"; wait.textContent = "در حال فکر کردن…";
    log.appendChild(wait); log.scrollTop = log.scrollHeight;
  }

  try{
    const r = await apiCall("/ai", { method:"POST", body: JSON.stringify({
      messages: aiHistory.filter(m => !m.error).slice(-12).map(m => ({ role:m.role, content:m.content })),
      today: (typeof getTodayJalaliStr === "function") ? getTodayJalaliStr() : ""
    }) });
    if(r.ok && r.data.reply) aiHistory.push({ role:"assistant", content:r.data.reply });
    else aiHistory.push({ role:"assistant", error:true,
      content: r.data.error || "دستیار جواب نداد. کمی بعد دوباره امتحان کنید." });
  }catch(e){
    aiHistory.push({ role:"assistant", error:true, content:"به سرور نرسیدم. اینترنت را بررسی کنید." });
  }
  aiSetBusy(false); aiSaveHistory(); aiRenderLog();
  const t = document.getElementById("aiInput");
  if(t){ try{ t.focus(); }catch(e){} }
}

function setupAssistant(){
  const input = document.getElementById("aiInput");
  const send  = document.getElementById("aiSend");
  const clear = document.getElementById("aiClear");
  const tips  = document.getElementById("aiTips");
  if(!input || !send) return;

  aiLoadHistory(); aiRenderLog();

  if(tips) AI_TIPS.forEach(q => {
    const b = document.createElement("button");
    b.type = "button"; b.className = "ai-tip"; b.textContent = q;
    b.addEventListener("click", ()=>{ input.value = q; aiAsk(q); input.value = ""; });
    tips.appendChild(b);
  });

  const fire = ()=>{ const v = input.value; input.value = ""; input.style.height = "auto"; aiAsk(v); };
  send.addEventListener("click", fire);
  input.addEventListener("keydown", e => {
    if(e.key === "Enter" && !e.shiftKey){ e.preventDefault(); fire(); }
  });
  /* نوارِ نوشتن با متن بلند بزرگ می‌شود، تا سقفی که در CSS هست */
  input.addEventListener("input", ()=>{
    input.style.height = "auto";
    input.style.height = Math.min(input.scrollHeight, 150) + "px";
  });

  if(clear) clear.addEventListener("click", ()=>{
    if(!aiHistory.length || !confirm("کلِ این گفتگو پاک شود؟")) return;
    aiHistory = []; aiSaveHistory(); aiRenderLog();
  });

  const nav = document.querySelector('.navbtn[data-view="assistant"]');
  if(nav) nav.addEventListener("click", ()=> setTimeout(()=>{ try{ input.focus(); }catch(e){} }, 60));
}

/* ---------- موتور دستیار ----------
   کلید روی سرور می‌ماند و هیچ‌وقت به این صفحه برنمی‌گردد؛ فقط چند حرف
   اولش می‌آید تا معلوم باشد کدام کلید نشسته. */
async function refreshAiSettings(){
  const el = document.getElementById("aiProvider");
  if(!el || window.KARTABL_OFFLINE || !signedIn) return;
  try{
    const r = await apiCall("/ai/settings");
    if(!r.ok) return;
    el.textContent = r.data.provider === "claude"
      ? "الان با کلاد کار می‌کند — " + r.data.model + (r.data.hint ? " (کلید " + r.data.hint + ")" : "")
      : "الان با هوش مصنوعیِ رایگانِ کلادفلر کار می‌کند.";
    el.className = "set-state" + (r.data.provider === "claude" ? " ok" : "");
  }catch(e){ /* اینترنت نبود — همان «در حال بررسی» می‌ماند */ }
}

function showLastLogin(){
  const el = document.getElementById("lastLoginRow");
  if(!el || !window.__lastLogin) return;
  el.textContent = "آخرین ورود به این کارتابل: " + faDateTime(window.__lastLogin);
}

function setupAiSettings(){
  const save  = document.getElementById("aiKeySaveBtn");
  const clear = document.getElementById("aiKeyClearBtn");
  const input = document.getElementById("aiKey");
  if(!save || !input) return;

  const send = async (key, btn, busyText)=>{
    btn.disabled = true; setState("aiKeyState", busyText);
    try{
      const r = await apiCall("/ai/settings", { method:"POST", body: JSON.stringify({ key }) });
      if(r.ok){
        input.value = "";
        setState("aiKeyState", key ? "✓ کلید ثبت شد — دستیار حالا با کلاد کار می‌کند" : "✓ برگشت به رایگان", "ok");
        refreshAiSettings();
      }else setState("aiKeyState", r.data.error || "نشد.", "err");
    }catch(e){ setState("aiKeyState", "به سرور نرسیدم.", "err"); }
    btn.disabled = false;
  };

  save.addEventListener("click", ()=>{
    const k = input.value.trim();
    if(!k){ setState("aiKeyState", "کلید را بنویسید.", "err"); return; }
    send(k, save, "در حال امتحان کردن کلید…");
  });
  if(clear) clear.addEventListener("click", ()=>{
    if(!confirm("دستیار برگردد به هوش مصنوعیِ رایگانِ کلادفلر؟")) return;
    send("", clear, "در حال برداشتن کلید…");
  });

  refreshAiSettings();
}

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
     setupAiSettings, showLastLogin, setupBackup, setupServers, setupCompanies,
     setupMvpn, setupRemote, setupChartModal, setupDateTools, setupSettings,
     renderAll, renderServers, renderCompanies, renderMvpn, renderRemoteChecklist,
     renderPersonalView, requestNotifyPermission, checkAndFireReminders
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
