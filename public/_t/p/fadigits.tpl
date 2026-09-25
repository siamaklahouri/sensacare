/* ==================== ارقامِ فارسی، همان‌جا که تایپ می‌شود ====================
   کارتابل فارسی است و همهٔ عددهایی که خودش می‌نویسد فارسی‌اند؛ ولی
   عددی که کاربر با صفحه‌کلیدِ لاتین تایپ می‌کرد لاتین می‌ماند. نتیجه
   یک ستونِ تاریخ بود با «۱۴۰۵/۰۷/۰۱» در یک سطر و «1405/07/15» در سطرِ
   بعد.

   پس هر رقمی که در یک کادرِ متنی تایپ شود همان لحظه فارسی می‌شود —
   چه از صفحه‌کلید بیاید، چه از چسباندن، چه از پرکنندهٔ خودکار.

   سه جا دست‌نخورده می‌ماند:

   • «دیتای شخصی» — به خواستِ خودِ صاحبِ کارتابل. آن‌جا رمز و شماره و
     کدِ چیزهایی نوشته می‌شود که باید عیناً همان باشند که هستند.
   • کادرهایی که مقدارشان شناسه است نه عدد: نامِ کاربری، آدرسِ
     کارتابل، توکنِ ربات، شناسهٔ گفت‌وگو، کدِ تخفیف، ایمیل. این‌ها با
     data-ascii نشان شده‌اند.
   • کادرهای type=number و type=password و مانندشان، که یا خودِ
     مرورگر رقمِ فارسی را نمی‌پذیرد یا اصلاً عدد نیستند.

   و سمتِ دیگرش: هر جا عددی از متنِ کاربر خوانده می‌شود باید رقمِ
   فارسی را هم بفهمد. برای همین parseInt و parseFloat همین‌جا
   رقم‌شناس می‌شوند، و سرور هم در cleanRow همین کار را می‌کند. */
(function(){
  "use strict";

  var FA = "۰۱۲۳۴۵۶۷۸۹";
  /* لاتین و عربی، هر دو → فارسی */
  var TO_FA = /[0-9٠-٩]/g;
  function faDigits(s){
    return String(s).replace(TO_FA, function(c){
      var n = c.charCodeAt(0);
      return FA.charAt(n >= 0x660 ? n - 0x660 : n - 48);
    });
  }

  /* ---------- سمتِ خواندن ----------
     parseInt("۵") بدونِ این NaN است. صدها جای برنامه عدد را از متنِ
     کاربر می‌خوانند؛ به‌جای اینکه همهٔ آن‌ها را دست بزنیم، خودِ این دو
     تابع رقمِ فارسی و عربی را هم می‌فهمند. جداکنندهٔ هزارگانِ فارسی
     (٬) و ممیزِ فارسی (٫) هم همین‌جا ترجمه می‌شوند. */
  var TO_EN = /[۰-۹٠-٩]/g;
  function enDigits(v){
    if(typeof v !== "string") return v;
    return v.replace(TO_EN, function(c){
      var n = c.charCodeAt(0);
      return String(n >= 0x6F0 ? n - 0x6F0 : n - 0x660);
    }).replace(/٬/g, "").replace(/٫/g, ".");
  }
  window.toPersianNumerals = faDigits;
  window.toLatinNumerals = enDigits;

  var rawInt = window.parseInt, rawFloat = window.parseFloat;
  window.parseInt = function(v, radix){ return rawInt(enDigits(v), radix); };
  window.parseFloat = function(v){ return rawFloat(enDigits(v)); };

  /* ---------- سمتِ نوشتن ---------- */
  var SKIP_TYPE = {
    password:1, number:1, email:1, url:1, tel:1, date:1, time:1, month:1,
    week:1, "datetime-local":1, color:1, file:1, range:1, checkbox:1,
    radio:1, hidden:1, submit:1, button:1, reset:1, image:1
  };

  function skip(el){
    if(!el || !el.tagName) return true;
    if(el.tagName !== "INPUT" && el.tagName !== "TEXTAREA") return true;
    if(el.tagName === "INPUT" &&
       SKIP_TYPE[String(el.getAttribute("type") || "text").toLowerCase()]) return true;
    if(!el.closest) return true;
    /* دیتای شخصی، صفحهٔ ورود، و هر کادری که خودش یا والدش ascii خواسته */
    return !!el.closest("[data-ascii],#view-personal,#gateScreen,.ls-lock");
  }

  function convert(el){
    if(skip(el)) return;
    var v = el.value;
    if(!v) return;
    var out = faDigits(v);
    if(out === v) return;
    /* طولِ رشته عوض نمی‌شود (هر رقم یک نویسه)، پس مکانِ نشانگر سرِ
       جایش می‌ماند و تایپ نمی‌پرد. */
    var a = null, b = null;
    try{ a = el.selectionStart; b = el.selectionEnd; }catch(e){}
    el.value = out;
    if(a !== null) try{ el.setSelectionRange(a, b); }catch(e){}
  }

  /* در فازِ capture، پیش از شنونده‌های خودِ برنامه: آنچه آن‌ها
     می‌خوانند همان چیزی است که کاربر می‌بیند. */
  document.addEventListener("input", function(e){ convert(e.target); }, true);
  document.addEventListener("change", function(e){ convert(e.target); }, true);

  /* مقدارهایی که صفحه خودش در کادرها گذاشته (از حافظه یا از سرور)
     هم یک بار یکدست می‌شوند. */
  function sweep(root){
    var host = root && root.querySelectorAll ? root : document;
    var els = host.querySelectorAll("input,textarea");
    for(var i = 0; i < els.length; i++) convert(els[i]);
  }
  var t = null;
  var later = function(){ clearTimeout(t); t = setTimeout(function(){ sweep(); }, 220); };
  new MutationObserver(later).observe(document.body, { childList:true, subtree:true });
  if(document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", later);
  else later();
})();
