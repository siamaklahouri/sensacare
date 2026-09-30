/* ==================== قفلِ دکمهٔ حذف ====================
   جدول‌هایی که کلیدِ «حذف/تغییر» دارند، دکمهٔ حذفشان تا آن کلید روشن
   نشود disabled است — و CSS آن را display:none می‌کرد. نتیجه یک
   ستونِ کاملاً خالی بود: صفحه را که باز می‌کردی هیچ دکمه‌ای نبود و
   خیال می‌کردی حذف خراب است.

   حالا دکمه سرِ جایش می‌ماند، قفل‌شده. دو کارِ کوچک از CSS برنمی‌آمد
   و این‌جا انجام می‌شود:
   یک) خودِ دکمه بگوید چرا نمی‌شود زدش،
   دو) کلیدِ سربرگ نشان بدهد باز است یا بسته.

   همان الگوی «خانه‌های بلند» را دارد: جدول‌ها پشتِ سر هم از نو ساخته
   می‌شوند، پس یک بار بعد از آرام شدنشان جارو می‌کند. */
(function(){
  "use strict";
  var LOCKED = "برای حذف، کلیدِ «حذف/تغییر» همین ستون را روشن کنید";

  function sweep(){
    var b = document.querySelectorAll(".btn-del"), i;
    for(i = 0; i < b.length; i++){
      /* عنوانِ اصلی یک بار کنار گذاشته می‌شود تا با باز شدنِ قفل
         همان برگردد — «حذف»، «حذف این ردیف»، هرچه بوده. */
      if(b[i].getAttribute("data-t") === null)
        b[i].setAttribute("data-t", b[i].title || "حذف");
      var want = b[i].disabled ? LOCKED : b[i].getAttribute("data-t");
      if(b[i].title !== want) b[i].title = want;
    }
    var w = document.querySelectorAll(".edit-toggle-wrap, .del-toggle-wrap");
    for(i = 0; i < w.length; i++){
      var inp = w[i].querySelector('input[type="checkbox"]');
      w[i].classList.toggle("open", !!(inp && inp.checked));
    }
  }
  window.delLockSweep = sweep;

  var t = null;
  var later = function(){ clearTimeout(t); t = setTimeout(sweep, 150); };
  new MutationObserver(later).observe(document.body, { childList:true, subtree:true });
  /* زدنِ خودِ کلید، پیش از آنکه جدول از نو ساخته شود */
  document.addEventListener("change", function(e){
    if(e.target && e.target.type === "checkbox" &&
       e.target.closest(".edit-toggle-wrap, .del-toggle-wrap")) sweep();
  });
  if(document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", later);
  else later();
})();
