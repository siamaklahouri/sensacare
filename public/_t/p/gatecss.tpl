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