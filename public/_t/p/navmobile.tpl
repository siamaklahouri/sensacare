/* ==================== منو روی گوشی ====================
   روی صفحهٔ باریک، نوارِ بخش‌ها یک ردیفِ افقیِ لغزان بود. سه ایراد
   داشت که هر سه از یک جنس‌اند: کارتابلِ مدیرِ IT هفده بخش دارد و
   صفحهٔ گوشی جای دو دکمه است.

   یک) از هفده دکمه، یکی‌ونیم‌تا دیده می‌شد — و آن نیمِ بریده، خودش
   بدترین بخشِ تصویر بود.
   دو) بقیه فقط با کشیدنِ انگشت پیدا می‌شدند، یعنی باید حدس می‌زدی که
   چیزی آن طرف هست.
   سه) ردیف به اندازهٔ یک دکمه بلند بود ولی مثل یک نوارِ جداگانه دیده
   می‌شد، چسبیده به سرصفحه.

   حالا یک دکمه است — نامِ بخشی که در آن هستی — و با زدنش فهرستِ کاملِ
   بخش‌ها در دو ستون باز می‌شود. یک ردیف جا می‌گیرد، و وقتی بازش
   می‌کنی همه‌چیز با هم دیده می‌شود، بی‌کشیدن و بی‌حدس.

   پیچیدنِ فهرست در حالت بسته، ارتفاع نمی‌گیرد؛ پس آن ایرادِ قدیمی
   («منو یک‌ششمِ صفحه را می‌خورد») برنمی‌گردد. */
(function () {
  "use strict";

  var SEL = ".sidebar";

  function build() {
    var bar = document.querySelector(SEL);
    var nav = bar && bar.querySelector(".nav-list");
    if (!bar || !nav || bar.querySelector(".nav-toggle")) return;

    var b = document.createElement("button");
    b.type = "button";
    b.className = "nav-toggle";
    b.setAttribute("aria-expanded", "false");
    b.innerHTML = '<span class="ic"></span><span class="t"></span><span class="caret">▾</span>';
    bar.insertBefore(b, nav);
    /* تا وقتی این کلاس نیامده، فهرست همان فهرستِ همیشگی است. پس اگر
       این اسکریپت اصلاً اجرا نشود، منو باز و قابلِ استفاده می‌ماند —
       نه بسته و بی‌دکمه. */
    bar.classList.add("nav-js");

    var close = function () {
      bar.classList.remove("nav-open");
      b.setAttribute("aria-expanded", "false");
    };
    b.addEventListener("click", function () {
      var open = !bar.classList.contains("nav-open");
      bar.classList.toggle("nav-open", open);
      b.setAttribute("aria-expanded", open ? "true" : "false");
    });
    /* زدنِ یک بخش یعنی «همین را می‌خواهم» — فهرست باید بسته شود،
       وگرنه آدم دو بار باید بزند تا محتوا را ببیند. */
    nav.addEventListener("click", function (e) {
      if (e.target && e.target.closest && e.target.closest(".navbtn")) close();
    });
    /* زدنِ جایی بیرون از منو هم می‌بندد */
    document.addEventListener("click", function (e) {
      if (!bar.classList.contains("nav-open")) return;
      if (e.target === b || (e.target.closest && e.target.closest(SEL))) return;
      close();
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") close();
    });

    sync();
    /* نامِ دکمه باید همیشه نامِ بخشِ باز باشد. کدِ خودِ کارتابل کلاسِ
       active را جابه‌جا می‌کند و خبری هم نمی‌دهد؛ پس خودمان نگاه
       می‌کنیم. این‌طوری بخش‌های مشترک که بعداً به نوار اضافه می‌شوند
       هم بی‌کارِ اضافه پوشش داده می‌شوند. */
    try {
      new MutationObserver(sync).observe(nav, {
        attributes: true, attributeFilter: ["class"], subtree: true, childList: true
      });
    } catch (e) { }
  }

  function sync() {
    var bar = document.querySelector(SEL);
    var b = bar && bar.querySelector(".nav-toggle");
    var on = bar && bar.querySelector(".navbtn.active");
    if (!b) return;
    var ic = on && on.querySelector(".ic");
    b.querySelector(".ic").textContent = ic ? ic.textContent.trim() : "☰";
    /* نامِ دکمه از خودِ دکمهٔ بخش درمی‌آید، منهای نشانه‌اش — تا اگر
       فردا بخشی اضافه شد، این‌جا چیزی لازم نباشد. */
    var t = on ? on.textContent.replace(ic ? ic.textContent : "", "").trim() : "بخش‌ها";
    b.querySelector(".t").textContent = t || "بخش‌ها";
  }

  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", build);
  else build();
  window.navMobileSync = sync;
})();
