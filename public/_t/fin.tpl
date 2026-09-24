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
  .period label{ font-size:12px; color:var(--ink-faint); }

  /* ---------- Live clock (stable width, no layout shift) ---------- */
  /* تاریخ از نوار بالا برداشته شد: همان تاریخ و همان ساعت یک بار دیگر
     در داشبورد هم بود. اینجا فقط ساعت می‌ماند، جمع‌وجور و کنار انتخاب ماه. */
  .live-clock{
    display:flex; align-items:center; justify-content:center; margin-inline-start:auto;
    background:var(--brass-bg); border:1px solid transparent;
    border-radius:999px; padding:6px 14px; user-select:none;
  }
  .lc-time{
    font-family:var(--font-display); font-variant-numeric:tabular-nums;
    font-size:15px; font-weight:700; color:var(--brass-ink); letter-spacing:.8px;
    line-height:1.3; white-space:nowrap;
  }
  .lc-date{ display:none; }
  .period select{
    font-family:var(--font-body); font-size:13px;
    background:var(--white); border:1px solid var(--card-border);
    color:var(--ink); border-radius:9px; padding:7px 10px; min-width:120px; text-align:center;
  }
  .period select option{ color:var(--ink); }

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
    display:flex; align-items:center; justify-content:space-between; gap:16px; flex-wrap:wrap;
    box-shadow:var(--shadow); position:relative; overflow:hidden;
  }
  .dash-hero::after{
    content:""; position:absolute; inset-block:0; inset-inline-start:0;
    width:3px; background:var(--brass); pointer-events:none;
  }
  .dash-hero .dh-greet{ font-family:var(--font-display); font-size:16px; font-weight:700; color:var(--ink); position:relative; z-index:1; }
  .dash-hero .dh-sub{ font-size:11.5px; color:var(--ink-soft); margin-top:4px; position:relative; z-index:1; }

  /* ساعت و تاریخ هر کدام کارت خودش — قبلاً یک بلوکِ بزرگ بودند و همان
     ساعت یک بار دیگر هم در نوار بالا تکرار می‌شد. */
  .dh-side{ display:flex; gap:10px; position:relative; z-index:1; flex-wrap:wrap; }
  .dh-box{
    background:var(--paper); border:1px solid var(--card-border);
    border-radius:12px; padding:9px 16px; text-align:center; min-width:124px;
  }
  /* چیپِ ساعت رنگِ برند می‌گیرد تا در میانِ کاغذِ روشن گم نشود. */
  .dh-box:first-child{ background:var(--brass-bg); border-color:transparent; }
  .dh-box:first-child .dh-cap{ color:var(--brass-ink); opacity:.85; }
  .dh-box:first-child .dh-time{ color:var(--brass-ink); }
  .dh-box .dh-cap{
    font-size:10px; font-weight:600; color:var(--ink-soft); letter-spacing:.3px;
    text-transform:none; margin-bottom:3px;
  }
  /* ساعت هر ثانیه عوض می‌شود؛ اینجا ارقامِ هم‌عرض لازم است وگرنه عدد
     مدام کمی جابه‌جا می‌شود. */
  .dh-time{
    font-family:var(--font-display); font-variant-numeric:tabular-nums;
    font-size:23px; font-weight:800; color:var(--ink); letter-spacing:1px;
    line-height:1.2; white-space:nowrap;
  }
  .dh-datestr{ font-family:var(--font-display); font-size:15px; font-weight:700; color:var(--ink); line-height:1.3; white-space:nowrap; }

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
  .chart-box{ position:relative; width:100%; height:250px; margin-top:4px; }
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

  /* شش کارتِ داشبورد با auto-fit به ۵+۱ می‌شکست و یک ردیفِ تک‌کارته با
     جای خالی کنارش می‌ماند. تعداد ستون را صریح می‌گذاریم تا همیشه
     ردیف‌های پر باشد: ۶ روی نمایشگر پهن، ۳ روی متوسط، ۲ روی گوشی. */
  #statCards{ grid-template-columns:repeat(2,1fr); }
  @media (min-width:640px){ #statCards{ grid-template-columns:repeat(3,1fr); } }
  @media (min-width:1380px){ #statCards{ grid-template-columns:repeat(6,1fr); } }

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
  <div class="live-clock" id="liveClock">
    <div class="lc-time" id="lcTime">--:--:--</div>
    <div class="lc-date" id="lcDate">در حال بارگذاری...</div>
  </div>
  <div class="period">
    <label>ماه</label>
    <select id="monthSelector"></select>
    <button class="btn btn-brass btn-sm" id="newMonthBtn">＋ ماه جدید</button>
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
    const timeEl = document.getElementById("lcTime");
    if(timeEl) timeEl.textContent = timeStr;
    const dhTimeEl = document.getElementById("dhTime");
    if(dhTimeEl) dhTimeEl.textContent = timeStr;

    const dateFmt = new Intl.DateTimeFormat("fa-IR-u-ca-persian-nu-latn", {year:"numeric", month:"2-digit", day:"2-digit"});
    const dp = dateFmt.formatToParts(now);
    const y = dp.find(p=>p.type==="year").value;
    const m = dp.find(p=>p.type==="month").value;
    const d = dp.find(p=>p.type==="day").value;
    const dateStr = `${fa(d)} ${JALALI_MONTH_NAMES[parseInt(m,10)-1]} ${fa(y)}`;
    const dateEl = document.getElementById("lcDate");
    if(dateEl) dateEl.textContent = dateStr;
    const dhDateEl = document.getElementById("dhDateStr");
    if(dhDateEl) dhDateEl.textContent = dateStr;
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
  renderMonthSelector();
  renderChecklistAndDaily();
  renderCards(); renderCharts();
  scheduleSave();
}
function renderMonthSelector(){
  const sel = document.getElementById("monthSelector");
  if(!sel) return;
  const keys = Object.keys(state.monthsData||{});
  sel.innerHTML = keys.map(k=> `<option value="${escapeHtml(k)}" ${k===state.currentMonthKey?"selected":""}>${escapeHtml(monthLabelOf(k))}</option>`).join("");
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
    <div class="dh-side">
      <div class="dh-box">
        <div class="dh-cap">ساعت اکنون</div>
        <div class="dh-time" id="dhTime">--:--:--</div>
      </div>
      <div class="dh-box">
        <div class="dh-cap">امروز</div>
        <div class="dh-datestr" id="dhDateStr">${parts[2]?fa(parts[2]):""} ${monthName} ${parts[0]?fa(parts[0]):""}</div>
      </div>
    </div>
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
    /* ردیفِ «＋» و ردیفِ جست‌وجو همیشه باید خالی شروع شوند. این‌ها را
       علامت می‌زنیم تا اگر مرورگر چیزی داخلشان ریخت، برداشته شود.

       چرا این لایه لازم است؟ چون کروم وقتی برای این دامنه رمزِ
       ذخیره‌شده دارد، autocomplete=off را روی کادرهایی که خودش «نام
       کاربری» تشخیص می‌دهد نادیده می‌گیرد — و همین ستونِ «داخلی» در
       جدول MVPN را «admin» می‌کرد.

       عمداً فقط همین‌ها: سه ورودیِ دیگر در صفحه هست (یادآور و ابزار
       تاریخ) که خودِ کد مقدارشان را می‌گذارد، و پاک کردنِ کورکورانه
       آن‌ها را خراب می‌کرد. */
    if(el.tagName === "INPUT" && el.closest(".add-row, .filter-row, .visit-add-bar")){
      el.dataset.mtEmpty = "1";
      el.value = "";
    }
    el.setAttribute("autocomplete", "off");
    el.setAttribute("autocorrect", "off");
    el.setAttribute("autocapitalize", "off");
    el.setAttribute("spellcheck", "false");
    el.setAttribute("data-lpignore", "true");   /* LastPass */
    el.setAttribute("data-1p-ignore", "");      /* 1Password */
    el.setAttribute("data-form-type", "other"); /* Dashlane */
  });
}

/* کروم معمولاً بعد از ساخته‌شدنِ ورودی پُرش می‌کند، پس یک بار پاک
   کردن کافی نیست. چند بار سر می‌زنیم — ولی هیچ‌وقت به کادری که همین
   حالا زیرِ دستِ کاربر است دست نمی‌زنیم. */
function scrubAutofilled(){
  document.querySelectorAll('[data-mt-empty="1"]').forEach(el=>{
    if(el === document.activeElement) return;
    if(el.value !== "") el.value = "";
  });
}
function scrubSoon(){
  requestAnimationFrame(scrubAutofilled);
  setTimeout(scrubAutofilled, 400);
  setTimeout(scrubAutofilled, 1200);
}

function setupNoAutofill(){
  const host = document.querySelector(".content") || document.body;
  markNoAutofill(host);
  scrubSoon();
  /* وقتی کاربر خودش چیزی تایپ کرد، دیگر نگهبانی لازم نیست */
  host.addEventListener("input", e=>{
    const t = e.target;
    if(t && t.dataset && t.dataset.mtEmpty && e.isTrusted && t === document.activeElement)
      delete t.dataset.mtEmpty;
  }, true);
  try{
    new MutationObserver(muts=>{
      for(const m of muts){
        for(const n of m.addedNodes){
          if(n.nodeType !== 1) continue;
          markNoAutofill(n);
          if(n.matches && n.matches("input, textarea")) markNoAutofill(n.parentNode || host);
          scrubSoon();
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
const AI_TIPS = ["جمع بدهی‌های سررسیدگذشته چقدر است؟",
  "فاکتورهای وصول‌نشده را فهرست کن",
  "خلاصه‌ی وضعیت مالی این ماه را بگو",
  "بودجه با هزینه‌ی واقعی چقدر اختلاف دارد؟",
  "یک نامه‌ی مودبانه برای پیگیری طلب بنویس"];
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
