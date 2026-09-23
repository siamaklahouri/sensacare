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
/* این صفحه عمداً مو‌به‌مو شبیهِ صفحهٔ ورودِ مشترک (/login) است: کاربر
   از آن‌جا می‌آید و اگر این‌جا یک‌هو طرحِ دیگری ببیند، حس می‌کند جای
   دیگری افتاده. پس همان کاغذِ روشن، همان کارتِ سفید، همان نشان. */
#gateScreen{
  position:fixed; inset:0; z-index:9999;
  display:flex; align-items:center; justify-content:center; padding:20px;
  background:
    radial-gradient(700px 360px at 50% -10%, rgba(26,79,163,.10), transparent 60%),
    var(--paper);
}
#gateScreen[hidden]{ display:none; }
.gate-card{
  width:100%; max-width:390px; background:var(--white);
  border:1px solid var(--line); border-radius:18px;
  padding:34px 28px 28px; text-align:center;
  box-shadow:0 2px 6px rgba(11,37,69,.06), 0 12px 32px rgba(11,37,69,.09);
  animation:gateRise .4s cubic-bezier(.2,.8,.3,1);
}
@keyframes gateRise{ from{ opacity:0; transform:translateY(10px); } to{ opacity:1; transform:none; } }
/* نشانِ SLTech، گِرد بریده — همان‌که در نوار بالا و در پنل مدیر است. */
.gate-mark{ display:block; width:68px; height:68px; margin:0 auto 10px;
  border-radius:50%; object-fit:cover; }
/* «SLTech» متن است نه تصویر: در هر اندازه‌ای تیز می‌ماند. */
.brandword{ font-family:system-ui, -apple-system, "Segoe UI", Arial, sans-serif;
  font-size:19px; font-weight:600; letter-spacing:.14em; margin:0 0 14px;
  background:linear-gradient(180deg, var(--ink) 0%, var(--ink-soft) 100%);
  -webkit-background-clip:text; background-clip:text; color:transparent;
  -webkit-text-fill-color:transparent; }
@supports not (background-clip: text){ .brandword{ color:var(--ink); -webkit-text-fill-color:currentColor; } }
.gate-card h2{ font-family:var(--font-display); font-size:17.5px; margin:0 0 7px; color:var(--ink); }
.gate-card p{ margin:0 0 18px; font-size:12.5px; color:var(--ink-soft); line-height:2.05; }
.gate-card .lock-ic{ display:none; }
.gate-card input[type="password"]{
  font-family:var(--font-body); font-size:13.5px; width:100%; text-align:center;
  padding:12px 13px; border:1px solid var(--line); border-radius:13px;
  background:var(--paper); color:var(--ink); letter-spacing:.5px;
  transition:border-color .15s, box-shadow .15s;
}
.gate-card input[type="password"]:focus{ outline:none; border-color:var(--brass);
  background:var(--white); box-shadow:0 0 0 3px rgba(26,79,163,.18); }
.gate-card button[type="submit"]{
  font-family:var(--font-body); font-size:14px; font-weight:700; cursor:pointer;
  width:100%; margin-top:12px; padding:12px; border:0; border-radius:13px;
  background:linear-gradient(145deg,#1A4FA3,#123E80); color:#fff;
  box-shadow:0 4px 12px rgba(18,62,128,.28);
  transition:transform .12s, box-shadow .15s;
}
.gate-card button[type="submit"]:hover:not(:disabled){ transform:translateY(-1px);
  box-shadow:0 6px 18px rgba(18,62,128,.34); }
.gate-card button[type="submit"]:disabled{ opacity:.6; cursor:default; transform:none; }
.gate-remember{
  display:flex; align-items:center; justify-content:center; gap:7px;
  margin-top:12px; font-size:12px; color:var(--ink-soft); cursor:pointer;
}
.gate-err{ margin-top:9px; min-height:20px; font-size:12.5px; font-weight:600; color:var(--red-ink); }
.gate-note{ margin-top:8px; font-size:12.5px; font-weight:600; color:var(--green-ink); line-height:2; }
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
  .new-month-panel{
    display:flex; align-items:center; gap:8px; justify-content:flex-end; flex-wrap:wrap;
    padding:10px 32px; background:var(--paper-deep); border-bottom:1px solid var(--card-border);
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
    border:1px solid var(--red); background:var(--red-bg); color:var(--red-ink); border-radius:9px; padding:8px 14px;
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
    border:1px solid var(--card-border); border-radius:12px; padding:16px; margin-bottom:14px; background:var(--paper);
  }
  .inst-card-head{ display:flex; align-items:center; justify-content:space-between; margin-bottom:8px; }
  .inst-card-head h4{ margin:0; font-family:var(--font-display); font-size:14.5px; color:var(--ink); }
  .inst-summary{ font-size:12px; color:var(--ink-soft); line-height:2; margin-bottom:12px; }
  .inst-summary b{ color:var(--ink); }
  table.inst-schedule{ width:100%; border-collapse:collapse; font-size:12px; }
  table.inst-schedule th{ text-align:center; padding:6px 4px; color:var(--ink-soft); border-bottom:1px solid var(--card-border); background:transparent; position:static; }
  table.inst-schedule td{ text-align:center; padding:6px 4px; border-bottom:1px solid var(--card-border); }
  table.inst-schedule tr.paid td{ color:var(--ink-faint); text-decoration:line-through; }
  .inst-pay-toggle{
    border:1px solid var(--card-border); background:var(--white); border-radius:6px; padding:3px 10px; font-size:11px;
    cursor:pointer; font-family:var(--font-body);
  }
  .inst-pay-toggle.paid{ background:var(--green-bg); border-color:var(--green); color:var(--green-ink); }

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
    display:flex; align-items:center; gap:8px; padding:10px 12px; background:var(--paper); border:1px solid var(--card-border);
    border-radius:9px; margin-bottom:14px; flex-wrap:wrap;
  }
  .cred-import-bar p{ margin:0; font-size:11px; color:var(--ink-soft); line-height:1.8; flex:1; min-width:200px; }
  .cred-import-status{ font-size:11.5px; font-weight:600; color:var(--green-ink); }

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
      background:var(--white); border:1px solid var(--line);
    }
    .navbtn.active{ border-color:transparent; }
    /* در چیدمانِ افقی، نوارِ لبه جای درستی ندارد. */
    .navbtn.active::before{ display:none; }
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
  [data-theme="dark"] .tbl-wrap{ background-color:transparent; }
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
    background:var(--white); border:1px solid var(--card-border);
    border-radius:999px; font-size:14px; line-height:1; color:var(--ink-soft);
    transition:border-color .15s, background .15s, transform .12s;
  }
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
      <button class="navbtn" data-view="servers" data-feat="view:servers"><span class="ic">🖥️</span> سرورها و بکاپ</button>
      <button class="navbtn" data-view="companies" data-feat="view:companies"><span class="ic">🏢</span> شرکت‌ها</button>
      <button class="navbtn" data-view="mvpn" data-feat="view:mvpn"><span class="ic">📱</span> سرویس MVPN</button>
      <button class="navbtn navbtn-lock" data-view="personal" data-feat="vault"><span class="ic">🔒</span> دیتای شخصی</button>
      <button class="navbtn" data-view="datetools" data-feat="view:datetools"><span class="ic">🧮</span> تبدیل تاریخ</button>
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

      <div class="panel" data-feat="aikey">
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
/* بستنِ یک بخش گاهی بخشِ دیگری را هم می‌بندد: وقتی خودِ دستیار نیست،
   تنظیمِ موتورش هم بی‌معنی است. همین قاعده سمتِ سرور هم هست. */
const FEAT_IMPLIES = { ai: ["aikey"] };

function closedFeatures(){
  const off = Array.isArray(window.KARTABL_OFF) ? window.KARTABL_OFF : [];
  const all = new Set(off);
  off.forEach(f => (FEAT_IMPLIES[f] || []).forEach(x => all.add(x)));
  return all;
}
function featClosed(f){ return closedFeatures().has(f); }

/* ---------- هشدارِ پایانِ مهلت ----------
   ادمین می‌تواند برای هر کارتابل مهلت بگذارد. از یک هفته مانده به
   پایان، هر بار که کارتابل باز می‌شود یک بار گفته می‌شود — تا کسی
   یک روز صبح با درِ بسته روبه‌رو نشود. */
function showExpiryWarning(){
  const until = Number(window.KARTABL_UNTIL || 0);
  if(!until || window.KARTABL_OFFLINE) return;
  /* گرد می‌کنیم، نه بالا و نه پایین: «۳ روز و یک ساعت» برای آدم
     «۳ روز» است، نه چهار. تاریخِ دقیق هم پایینش می‌آید. */
  const left = Math.round((until - Date.now()) / 86400000);
  if(left > 7 || until < Date.now()) return;
  const ov = document.getElementById("expOverlay");
  if(!ov) return;
  document.getElementById("expDays").textContent =
    left <= 0 ? "امروز آخرین روز است" : fa(left) + " روز مانده";
  document.getElementById("expNote").innerHTML =
    "تا <b>" + escapeHtml(faDateTime(until)) + "</b> باز است.<br>"
    + "بعد از آن بسته می‌شود و تا وقتی مدیر سیستم دوباره بازش نکند باز "
    + "نمی‌شود. داده‌هایتان سرِ جایشان می‌مانند و چیزی پاک نمی‌شود.";
  ov.hidden = false;
  const ok = document.getElementById("expOk");
  ok.addEventListener("click", ()=>{ ov.hidden = true; });
  setTimeout(()=>{ try{ ok.focus(); }catch(e){} }, 80);
}

function hideClosedFeatures(){
  const off = closedFeatures();
  if(!off.size) return;
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
  /* بستن یعنی برداشتن از صفحه، نه فقط پنهان کردن.
     دلیلش یک ایرادِ واقعی بود: تا وقتی این فرم در صفحه می‌ماند، مرورگر
     یک «کادرِ رمز» می‌بیند و دنبالِ کادرِ نام کاربری کنارش می‌گردد؛
     نزدیک‌ترین ورودیِ متنیِ صفحه را برمی‌دارد و نام کاربریِ ذخیره‌شده
     («admin») را داخلش می‌ریزد. نتیجه این شد که ستونِ «داخلی» در
     جدولِ MVPN خودبه‌خود «admin» می‌گرفت.
     بعد از ورودِ موفق صفحه همیشه reload می‌شود، پس این فرم دیگر لازم
     نیست و برداشتنش چیزی را خراب نمی‌کند. */
  function closeGate(){
    screenEl.hidden = true;
    /* خودِ گره می‌ماند (جاهایی به وجودش تکیه شده) ولی محتوایش می‌رود:
       کادرِ رمز باید از صفحه برود، نه فقط پنهان شود. */
    try{ screenEl.innerHTML = ""; }catch(e){}
  }

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

/* ---------- رنگِ نمودارها ----------
   این‌ها «وضعیت»اند نه «هویت»، پس رنگشان معنا دارد و جابه‌جا نمی‌شود:
   سبز یعنی انجام شده، آبی یعنی در جریان، کهربایی یعنی نشده. خاکستری
   هم «بی‌وضعیت» است، نه یک دستهٔ چهارم.

   گامِ روز و شب جدا انتخاب شده‌اند، نه وارونهٔ خودکارِ هم — و هر دو با
   سنجهٔ کوررنگی بررسی شده‌اند: بدترین جفتِ کنارِ هم در دید عادی ΔE ۲۰
   و در دوترانوپی ۱۸٫۷ فاصله دارد.

   خطِ بینِ تکه‌ها همرنگِ خودِ کارت است، نه سفیدِ ثابت — وگرنه در تمِ شب
   مثل یک قابِ روشن می‌زد بیرون. */
/* دو دسته رنگ، و کارشان فرق دارد:
   • done/doing/todo/bad/none «وضعیت»اند — معنایشان ثابت است و هیچ‌وقت
     برای «سریِ چهارم» قرض داده نمی‌شوند.
   • cat «هویت»‌اند: وقتی برش‌ها یا ستون‌ها فقط با هم فرق دارند، نه
     خوب و بد. ترتیبشان ثابت است و هیچ‌وقت چرخانده نمی‌شود، وگرنه با
     عوض شدنِ یک فیلتر رنگِ بقیه هم عوض می‌شود.

   هر دو ستون با سنجهٔ کوررنگی بررسی شده‌اند و هر پنج آزمون را پاس
   می‌کنند (باندِ روشنایی، کفِ اشباع، جدایی در پروتان/دوتان/تریتان،
   کفِ دیدِ عادی، و کنتراست با سطح). بدترین جفتِ همسایه در روز
   ΔE ۱۲٫۸ و در شب ΔE ۱۰٫۳ است. دست بردن در یکی از این هگزها یعنی
   باید دوباره سنجیده شود.

   رنگ‌های شب «وارونهٔ» روز نیستند؛ جداگانه روی سطحِ تیره انتخاب
   شده‌اند. مقدارهای قبلیِ شب برای «متن» ساخته شده بودند و برای پر
   کردنِ نمودار از باندِ مجاز روشن‌تر بودند. */
function chartTone(){
  const dark = document.documentElement.getAttribute("data-theme") === "dark";
  return dark
    ? { done:"#46976A", doing:"#5A8FE8", todo:"#B07F26", none:"#3A4653",
        bad:"#B0524F", surface:"#121E29",
        cat:["#4A85E0","#B8821F","#1FA298","#8B6FC4","#D25B65"] }
    : { done:"#1E7A4A", doing:"#1A4FA3", todo:"#B5791B", none:"#CFD7E0",
        bad:"#A6222B", surface:"#FFFFFF",
        cat:["#1A4FA3","#B5791B","#0A8F88","#6E45B0","#A6222B"] };
}
/* کمی روشن‌تر برای وقتی موشواره رویش می‌رود */
function chartHover(list){ return list.map(c=> c + "D9"); }

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
    backupData = { vm: parseServersSheet(wb) };
    dailyLog = parseDailyLogSheet(wb);
    companiesData = { companies: parseCompaniesSheet(wb) };
    mvpnData = { lines: parseMvpnSheetFlat(wb) };
    const remote = parseRemoteChecklistSheet(wb);
    remoteBackupData = { roster: remote.roster };
    if(remote.dates) state.remoteCheckDates = remote.dates;
    if(remote.checks) state.remoteChecks = remote.checks;
    /* بخشِ رمزدار عمداً از فایل خوانده نمی‌شود: کلیدش دستِ خودِ کاربر
       است و اگر این‌جا جایگزین شود، آن‌چه باز کرده بود قفل می‌ماند. */
    dbSyncedAt = new Date().toISOString();
    persistDbCache();
    scheduleSave();
    renderServers(); renderCompanies(); renderMvpn(); renderRemoteChecklist(); renderCharts();
    updateDbStatus("✓ از «" + file.name + "» خوانده شد. فایل دیگر لازم نیست.");
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
   باز کردنش رمزِ ادمین را می‌خواهد که برای این کار هیچ‌وقت به سرور نمی‌رسد.

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
    /* نشانهٔ کلید را هم می‌فرستیم تا بعداً معلوم باشد این پاکت با کدام
       کلیدِ ادمین پیچیده شده. */
    const put = await apiCall("/escrow", { method:"POST",
      body: JSON.stringify({ bundle: { cipher: b64FromBuf(buf), at: Date.now(),
                                       fp: (r.data.fp || "") } }) });
    return !!put.ok;
  }catch(e){ return false; }
}

/* اگر ادمین کلیدِ اضطراری را عوض کرده باشد، پاکتِ قبلیِ این کاربر با
   کلیدِ قدیمی پیچیده است و دیگر باز نمی‌شود. همان لحظه‌ای که کاربر
   صندوقش را باز می‌کند رمز در دست است، پس بی‌سر و صدا پاکتِ تازه
   می‌سپاریم — نه پیامی، نه کاری که کاربر باید بکند.

   فقط وقتی پاکت با کلیدِ فعلی نمی‌خواند این کار انجام می‌شود، وگرنه
   هر بار باز کردنِ صندوق یک نوشتنِ بی‌دلیل بود. */
async function reEscrowIfStale(password){
  if(window.KARTABL_OFFLINE) return false;
  try{
    const r = await apiCall("/escrow-pub");
    if(!(r.ok && r.data && r.data.pub)) return false;
    const fp = r.data.fp || "";
    const mine = r.data.mine;
    if(mine && mine.fp && fp && mine.fp === fp) return false;
    return await escrowVaultPassword(password);
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
    reEscrowIfStale(password);
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
/* ---------------- خواندن از اکسل، داخلِ دیتای شخصی ----------------
   ستون‌ها با جای‌شان می‌نشینند، نه با نامشان: ستونِ اول به ستونِ اول
   این بخش، دومی به دومی و همین‌طور تا آخر. اگر ردیفِ اول سربرگ باشد
   خودش کنار گذاشته می‌شود.

   نکتهٔ امنیتی: این فایل هیچ‌وقت به سرور نمی‌رود. همین‌جا در مرورگر
   خوانده می‌شود و نتیجه‌اش با کلیدِ خودتان رمز می‌شود — همان مسیری که
   بقیهٔ دیتای شخصی می‌رود. */
async function importVaultGridFromXlsx(sec){
  if(xlsxOff() || !sec) return;
  const cols = vaultGridCols(sec);
  const file = await pickFile();
  if(!file) return;
  const wb = await readWorkbook(file);
  if(!wb) return;

  const rows = vaultRows(sec);
  let added = 0, sheets = 0;
  for(const name of wb.SheetNames){
    const list = sheetRows(wb, name);
    if(!list.length) continue;
    sheets++;
    let start = looksLikeHeader(list[0], cols) ? 1 : 0;
    for(let i = start; i < list.length; i++){
      const r = list[i];
      const obj = {};
      for(let ci = 0; ci < cols.length; ci++){
        const v = r[ci];
        obj["c" + ci] = v == null ? "" : String(v).trim();
      }
      /* اگر همهٔ ستون‌های این بخش خالی درآمدند، ردیف را نمی‌سازیم —
         وگرنه یک فایلِ پهن‌تر، ده‌ها ردیفِ خالی اضافه می‌کند. */
      if(Object.values(obj).every(v=> v === "")) continue;
      rows.push(obj);
      added++;
    }
  }
  if(!added){
    alert("چیزی برای افزودن پیدا نشد. ستون‌های فایل باید به ترتیبِ ستون‌های همین بخش باشند.");
    return;
  }
  await encryptPersonalVault();
  renderPersonalView();
  alert("✓ " + toPersianDigits(added) + " ردیف از " + toPersianDigits(sheets) +
        " برگه خوانده شد و رمز شد.\n\nفایل دیگر لازم نیست؛ داده داخلِ کارتابل نشست.");
}

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
      <div style="display:flex; gap:8px; flex-wrap:wrap; margin-top:10px;">
        <button type="button" class="btn btn-brass btn-sm" id="pgAddRow">＋ افزودن ردیف</button>
        ${xlsxOff() ? "" : '<button type="button" class="btn btn-ghost btn-sm" id="pgImportXlsx" title="ستون‌ها به ترتیب می‌نشینند">⬆ خواندن از اکسل</button>'}
      </div>
    </div>`;

  const pgImp = document.getElementById("pgImportXlsx");
  if(pgImp) pgImp.addEventListener("click", ()=> importVaultGridFromXlsx(sec));

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
    ${xlsxOff() ? "" : `<div class="cred-import-bar">
      <p>📥 یک فایل اکسل بارگذاری کنید که هر برگه (Sheet) آن نام یک شرکت، و ردیف‌هایش به‌ترتیب عنوان/IP/یوزرنیم/پسورد باشد — همه‌چیز فقط در همین مرورگر پردازش و بلافاصله رمزنگاری می‌شود.</p>
      <button type="button" class="btn btn-brass btn-sm" id="importCredBtn">📥 انتخاب فایل اکسل/CSV</button>
      <input type="file" id="importCredFile" accept=".xlsx,.xls,.csv" style="display:none;">
      <span class="cred-import-status" id="importCredStatus"></span>
    </div>`}
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

  /* وقتی ادمین «خواندن از اکسل» را بسته، این نوار اصلاً ساخته نشده */
  if(document.getElementById("importCredBtn")){
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

/* ---------------- جلوی تکمیلِ خودکارِ مرورگر ----------------
   کادرِ رمزِ صفحهٔ ورود که برداشته شد، ریشهٔ ماجرا خشکید. این لایهٔ دوم
   است برای مرورگرها و افزونه‌های مدیریتِ رمز که با حدس‌های خودشان کار
   می‌کنند: هیچ خانهٔ جدولی نباید پیشنهادِ «نام کاربری» بگیرد.

   جدول‌ها مدام با innerHTML از نو ساخته می‌شوند، پس یک بار نشانه‌گذاری
   کافی نیست و یک ناظر هم لازم است. */
function markNoAutofill(root){
  const sel = 'input[type="text"], input[type="search"], input:not([type]), textarea';
  (root || document).querySelectorAll(sel).forEach(el=>{
    if(el.dataset.naf) return;
    el.dataset.naf = "1";
    el.setAttribute("autocomplete", "off");
    el.setAttribute("autocorrect", "off");
    el.setAttribute("autocapitalize", "off");
    el.setAttribute("spellcheck", "false");
    el.setAttribute("data-lpignore", "true");   /* LastPass */
    el.setAttribute("data-1p-ignore", "");      /* 1Password */
    el.setAttribute("data-form-type", "other"); /* Dashlane */
  });
}

function setupNoAutofill(){
  const host = document.querySelector(".content") || document.body;
  markNoAutofill(host);
  try{
    new MutationObserver(muts=>{
      for(const m of muts){
        for(const n of m.addedNodes){
          if(n.nodeType !== 1) continue;
          markNoAutofill(n);
          if(n.matches && n.matches("input, textarea")) markNoAutofill(n.parentNode || host);
        }
      }
    }).observe(host, { childList:true, subtree:true });
  }catch(e){ /* ناظر نشد؟ همان یک بارِ اول هم بهتر از هیچ است */ }
}

/* ---------------- خواندن از اکسل ----------------
   یک‌بار فایل را می‌خواند و داخل کارتابل می‌نشاند. بعد از آن به فایل
   کاری ندارد — دادهٔ کارتابل روی سرور است، نه در آن فایل. این با
   «آینهٔ اکسل روی سیستم» فرق دارد: آن یکی به یک پوشه بند می‌ماند و
   هر تغییری را همان‌جا هم می‌نویسد.

   ادمین می‌تواند این را ببندد؛ آن‌وقت نه دکمه‌ای هست نه راهی. */
function xlsxOff(){ return featClosed("xlsx"); }

/* یک انتخابگرِ فایل که خودش را جمع می‌کند. input را در صفحه نگه
   نمی‌داریم چون یک بار مصرف است و اگر بماند، دفعهٔ بعد همان فایلِ قبلی
   را به یاد دارد و «change» شلیک نمی‌شود. */
function pickFile(accept){
  return new Promise(resolve=>{
    const el = document.createElement("input");
    el.type = "file";
    el.accept = accept || ".xlsx,.xls,.csv";
    el.style.display = "none";
    el.addEventListener("change", ()=>{
      const f = el.files && el.files[0] ? el.files[0] : null;
      el.remove();
      resolve(f);
    });
    /* اگر کاربر پنجره را ببندد، «change» هیچ‌وقت نمی‌آید. این نگهبان
       بعد از برگشتنِ فوکوس به صفحه، input را برمی‌دارد. */
    window.addEventListener("focus", ()=> setTimeout(()=>{
      if(document.body.contains(el) && !(el.files && el.files.length)){ el.remove(); resolve(null); }
    }, 400), { once:true });
    document.body.appendChild(el);
    el.click();
  });
}

/* فایل را می‌خواند و کتابِ اکسل را برمی‌گرداند. اگر کتابخانه نیامد یا
   فایل خراب بود، پیامِ روشن می‌دهد و null برمی‌گرداند. */
async function readWorkbook(file){
  if(!file) return null;
  if(typeof ensureXlsxLib === "function"){
    const ok = await ensureXlsxLib();
    if(!ok){ alert("کتابخانهٔ خواندن اکسل بارگذاری نشد. اینترنت را بررسی کنید."); return null; }
  }
  try{
    /* CSV و xlsx دو جورند و این تفاوت یک بار ما را زمین زد:
       xlsx یک زیپ است و متنش داخلش UTF-8 است، پس بایتِ خام درست خوانده
       می‌شود. ولی CSV خودش یک فایلِ متنی است و اگر بایت‌بایت بدهیمش،
       کتابخانه هر بایت را یک نویسه حساب می‌کند و «نام» می‌شود «ÙØ§Ù».
       پس CSV را با متنِ رمزگشایی‌شده می‌دهیم، نه با بایت. */
    const isCsv = /\.csv$/i.test(file.name || "") || /csv|text\/plain/i.test(file.type || "");
    if(isCsv){
      let txt = await file.text();
      if(txt.charCodeAt(0) === 0xFEFF) txt = txt.slice(1);   /* BOM ویندوز */
      return XLSX.read(txt, { type:"string", raw:true });
    }
    const buf = await file.arrayBuffer();
    return XLSX.read(buf, { type:"array", raw:true, cellDates:false });
  }catch(e){
    console.error(e);
    alert("این فایل خوانده نشد. مطمئن شوید یک فایل اکسل یا CSV سالم است.");
    return null;
  }
}

/* ردیف‌های یک برگه، به شکلِ آرایه‌ای از آرایه‌ها و بدونِ ردیف‌های خالی */
function sheetRows(wb, name){
  const sh = wb.Sheets[name];
  if(!sh) return [];
  const rows = XLSX.utils.sheet_to_json(sh, { header:1, raw:true, defval:null }) || [];
  return rows.filter(r=> r && r.some(c=> c != null && String(c).trim() !== ""));
}

/* آیا این ردیف سربرگ است؟ وقتی هیچ خانه‌ای عدد نیست و دست‌کم یکی از
   خانه‌ها با نامِ ستونی که انتظار داریم می‌خواند. */
function looksLikeHeader(row, cols){
  if(!row) return false;
  const anyNumber = row.some(c=> c != null && String(c).trim() !== "" && !isNaN(Number(c)));
  if(anyNumber) return false;
  const norm = s => String(s == null ? "" : s).trim().toLowerCase();
  const want = (cols || []).map(norm);
  return row.some(c=> c != null && want.includes(norm(c)));
}

/* ---------------- بخش‌های مشترک ----------------
   جدول‌هایی که ادمین بین چند کارتابل مشترک کرده. کدش در یک فایلِ
   جداست (/shared.js) چون هر دو کارتابل همان را بار می‌کنند؛ اگر دو
   نسخه می‌شد، فردا یکی‌شان عوض می‌شد و آن یکی نه.
   فقط بعد از ورود بار می‌شود: پیش از آن هر درخواستی یک ۴۰۱ است. */
function setupShared(){
  if(!signedIn) return;
  if(document.getElementById("sharedJs")) { if(window.initSharedBoxes) window.initSharedBoxes(); return; }
  const el = document.createElement("script");
  el.id = "sharedJs";
  el.src = "/shared.js";
  el.onload = ()=>{ if(window.initSharedBoxes) window.initSharedBoxes(); };
  el.onerror = ()=>{ console.warn("بخش‌های مشترک بار نشد."); };
  document.head.appendChild(el);
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

/* دو کارتابل دو پیادهٔ متفاوت از تبدیل تاریخ دارند: یکی شیء برمی‌گرداند
   و آن یکی آرایه. این‌جا هر دو را یک‌شکل می‌کنیم تا ابزار تبدیل تاریخ
   در هر دو یکسان کار کند. */
function asGreg(g){
  return Array.isArray(g) ? { gy:g[0], gm:g[1], gd:g[2] } : g;
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
    const g = asGreg(jalaliToGregorian(y,m,d));
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
