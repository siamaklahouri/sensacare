/* ==================== نسخهٔ نمایشی ====================
   کارتابلی که آدرسش «demo» است بی‌رمز باز می‌شود و نوشته‌هایش روی
   سرور نمی‌نشیند. دو کار این‌جا لازم است:

   یک) در را خودش باز کند — کسی که آمده ببیند، نباید پشتِ یک کادرِ
   رمز بماند که رمزی برایش ندارد.

   دو) صریح بگوید که نمایشی است. دموی بی‌برچسب بدتر از نبودنش است:
   آدم چیزی می‌نویسد، فردا برمی‌گردد و نیست، و خیال می‌کند کارتابل
   داده‌اش را گم می‌کند. */
(function () {
  "use strict";
  if (!window.KARTABL_DEMO) return;

  function banner() {
    if (document.getElementById("demoBar")) return;
    var d = document.createElement("div");
    d.id = "demoBar";
    d.className = "demobar";
    d.innerHTML =
      '<b>نسخهٔ نمایشی</b> — راحت بگردید و هرچه خواستید عوض کنید. ' +
      'هرچه بنویسید فقط روی همین مرورگر می‌ماند و روی سرور ذخیره نمی‌شود. ' +
      '<a href="https://sltech.ir/#buy">کارتابلِ خودم را می‌خواهم</a>';
    document.body.appendChild(d);
    document.documentElement.setAttribute("data-demo", "1");
  }

  /* ورود این‌جا نیست: نشستِ نمایشی را خودِ سرور در همان درخواستِ
     اولِ صفحه می‌دهد. پیش از این صفحه خودش وارد می‌شد و بعد خودش را
     دوباره باز می‌کرد — دو بارگذاری و یک پرش، برای کسی که فقط آمده
     ببیند. این‌جا فقط برچسب می‌ماند، که مهم‌ترین تکه است. */
  function init() { banner(); }

  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", init);
  else init();

  window.DEMO = { banner: banner };
})();
