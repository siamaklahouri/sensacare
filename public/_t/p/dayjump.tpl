/* ==================== پایین و بالای برنامهٔ روزانه ====================
   برنامهٔ روزانه یک ردیف برای هر روزِ ماه دارد و دکمهٔ «افزودن» هم
   تهِ همان جدول است. یعنی برای رسیدن به آخرِ لیست باید یک صفحهٔ بلند
   را با انگشت یا چرخِ موس پایین آورد — هر بار.

   این دو دکمه همان یک کار را می‌کنند: یکی بالای جدول که می‌برد تهِ
   لیست، یکی تهِ لیست که برمی‌گرداند سرِ جدول.

   مارک‌آپ را خودش می‌سازد تا در هر دو قالب (مدیر IT و مالی) با یک
   پاره کار کند، و کلاسِ .day-ex را قرض می‌گیرد تا CSSِ تازه‌ای لازم
   نباشد — همان نوارِ افقیِ دکمه‌ها، و در چاپ هم برداشته می‌شود.
   نوارِ خودِ خروجی‌ها data-feat دارد و اگر ادمین آن دسترسی را نداده
   باشد از صفحه برداشته می‌شود؛ پس این نوار جداست، وگرنه با آن
   می‌رفت. */
(function () {
  "use strict";

  /* فلشِ ساده (↓ ↑) نه فلشِ رنگی (⬇ ⬆): دومی روی ویندوز ایموجی
     می‌شود و کنارِ نوشتهٔ فارسی بد می‌نشیند. */
  function mk(txt, title) {
    var b = document.createElement("button");
    b.type = "button";
    b.className = "btn btn-ghost btn-sm";
    b.textContent = txt;
    b.title = title;
    return b;
  }

  function build() {
    var v = document.getElementById("view-daily");
    if (!v || v.querySelector(".day-jump")) return;

    var head = v.querySelector(".section-sub") || v.querySelector(".section-title");
    var tbl = v.querySelector(".tbl-wrap");
    if (!head || !tbl) return;

    /* تهِ لیست: اگر نوارِ «افزودن» هست همان، تا دکمه‌اش هم دیده شود؛
       وگرنه آخرین ردیفِ جدول. */
    var endOf = function () {
      return v.querySelector(".visit-add-bar") ||
             (v.querySelector("#dailyBody") || {}).lastElementChild || tbl;
    };
    /* inline:"nearest" لازم است: .tbl-wrap افقی می‌لغزد و بی این،
       مرورگر جدول را هم پهلو می‌کشد. */
    var go = function (el, where) {
      if (!el) return;
      try { el.scrollIntoView({ behavior: "smooth", block: where, inline: "nearest" }); }
      catch (e) { el.scrollIntoView(); }
    };

    var bar = document.createElement("div");
    bar.className = "day-ex day-jump";
    var down = mk("↓ پایینِ لیست", "برو تهِ جدول، جایی که دکمهٔ افزودن است");
    down.addEventListener("click", function () { go(endOf(), "end"); });
    bar.appendChild(down);

    /* هر چهار دکمه در یک خط: «پایینِ لیست» و «تقویم» این‌جا بودند و
       خروجی‌ها یک ردیف پایین‌تر، و دو نوارِ نیمه‌خالی روی هم خوب
       به‌نظر نمی‌رسید. نوارِ خروجی داخلِ همین ردیف می‌آید، نه برعکس:
       اگر ادمین خروجی‌ها را نداده باشد آن نوار اصلاً نیست، و دکمهٔ
       پرش نباید با آن برود. */
    var row = document.createElement("div");
    row.className = "day-bar";
    head.insertAdjacentElement("afterend", row);
    row.appendChild(bar);
    var ex = v.querySelector('.day-ex[data-feat="export"]');
    if (ex) row.appendChild(ex);

    /* و برگشت: از ته، سرِ جدول. همان‌جا کنارِ دکمهٔ افزودن می‌نشیند
       چون همان‌جاست که آدم تمام می‌کند.

       برگشت به خودِ بالای صفحه می‌رود، نه به عنوانِ بخش: سرصفحه
       چسبیده است و با scrollIntoView عنوان زیرش گم می‌شد. */
    var addBar = v.querySelector(".visit-add-bar");
    if (addBar) {
      var up = mk("↑ بالای لیست", "برگرد سرِ جدول");
      up.className += " day-jump-up";
      up.addEventListener("click", function () {
        try { window.scrollTo({ top: 0, behavior: "smooth" }); }
        catch (e) { window.scrollTo(0, 0); }
      });
      addBar.appendChild(up);
    }
  }

  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", build);
  else build();
})();
