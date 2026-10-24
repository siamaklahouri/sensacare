/* ==================== گشتِ اولِ کار ====================
   کاربرِ تازه با یک جدولِ آمادهٔ شغلش روبه‌رو می‌شود و هیچ‌کس نگفته
   از کجا شروع کند. بخش‌ها در نوارِ کنار هستند، ولی آدم نوارِ کنار را
   از بالا تا پایین نمی‌خواند — کارش را می‌کند و می‌رود، و نصفِ
   کارتابل کشف‌نشده می‌ماند.

   این یک گشتِ کوتاه است: چهار قدم، هر قدم روی همان چیزی که دربارهٔ
   آن حرف می‌زند. فقط یک بار می‌آید و از همان قدمِ اول می‌شود ردش
   کرد. «دیده شد» در خودِ state می‌نشیند، پس از دستگاهِ دوم دوباره
   شروع نمی‌شود.

   دکمه‌اش در راهنما هم هست: کسی که ردش کرده و بعد پشیمان شده، نباید
   دنبالِ کوکی پاک کردن بگردد. */
(function () {
  "use strict";

  var i = 0, box = null, steps = [];

  function esc(s) {
    try { return escapeHtml(String(s == null ? "" : s)); }
    catch (e) { return String(s == null ? "" : s); }
  }
  function seen() {
    try { return state.tourDone === true; } catch (e) { return true; }
  }
  function markSeen() {
    try {
      state.tourDone = true;
      scheduleSave();
      if (window.Cloud && Cloud.pushNow) Cloud.pushNow();
    } catch (e) { }
  }

  function build() {
    steps = [
      { sel: '.navbtn[data-view="checklist"]', title: "چک‌لیست ماهانه",
        body: "کارهای تکرارشوندهٔ شغلتان. ستونِ 🔁 می‌گوید هر کدام چند وقت یک‌بار برگردد — " +
              "هر ماه، هر سه ماه، یا سالانه. ماهِ بعد خودشان می‌آیند." },
      { sel: '.navbtn[data-view="daily"]', title: "برنامهٔ روزانه",
        body: "کارِ هر روز، با شرکت و وضعیت. تاریخِ هر ردیف همان روزی است که ساخته شده. " +
              "ستونِ 📎 برای چسباندنِ عکسِ فاکتور و رسید است." },
      { sel: '.navbtn[data-view="cal"]', title: "تقویم",
        body: "همان کارها روی تقویمِ ماه، با تعطیلی‌های رسمی. برای هر روز هم می‌شود یادداشت گذاشت." },
      { sel: '#findBtn', title: "جست‌وجو",
        body: "با Ctrl+K بینِ همهٔ ماه‌ها و جدول‌ها بگردید — حتی یادداشت‌ها و نامِ پیوست‌ها." },
      { sel: '.navbtn[data-view="settings"]', title: "تنظیمات",
        body: "رمز، تمِ رنگ، نسخه‌های پیشین، و یادآورها — که اگر روشنشان کنید حتی وقتی " +
              "کارتابل بسته است خبر می‌دهند." }
    ].filter(function (s) { return !!document.querySelector(s.sel); });

    box = document.createElement("div");
    box.className = "tourbox";
    box.hidden = true;
    box.innerHTML = '<div class="tr-scrim"></div><div class="tr-pop" role="dialog">' +
      '<div class="tr-n"></div><h4></h4><p></p>' +
      '<div class="tr-f">' +
        '<button type="button" class="tr-skip">بی‌خیال</button>' +
        '<button type="button" class="tr-next">بعدی</button>' +
      '</div></div>';
    document.body.appendChild(box);
    box.addEventListener("click", function (e) {
      if (e.target.closest(".tr-skip") || e.target.classList.contains("tr-scrim")) { done(); return; }
      if (e.target.closest(".tr-next")) { i++; paint(); }
    });
    document.addEventListener("keydown", function (e) {
      if (box.hidden) return;
      if (e.key === "Escape") done();
      else if (e.key === "Enter") { i++; paint(); }
    });
    return box;
  }

  function clearMark() {
    document.querySelectorAll(".tour-on").forEach(function (el) { el.classList.remove("tour-on"); });
  }

  function paint() {
    if (!box) return;
    if (i >= steps.length) { done(); return; }
    var st = steps[i];
    var el = document.querySelector(st.sel);
    clearMark();
    if (el) el.classList.add("tour-on");
    box.querySelector(".tr-n").textContent =
      (typeof fa === "function" ? fa(i + 1) + " از " + fa(steps.length) : (i + 1) + "/" + steps.length);
    box.querySelector("h4").textContent = st.title;
    box.querySelector("p").textContent = st.body;
    box.querySelector(".tr-next").textContent = (i === steps.length - 1) ? "تمام" : "بعدی";
    box.hidden = false;
    /* پنجره کنارِ همان چیزی می‌نشیند که دربارهٔ آن حرف می‌زند — روی
       گوشی وسطِ صفحه، چون نوارِ کنار اصلاً نیست. */
    var pop = box.querySelector(".tr-pop");
    pop.style.cssText = "";
    if (el && window.innerWidth > 900) {
      var r = el.getBoundingClientRect();
      pop.style.top = Math.max(12, Math.min(r.top - 10, innerHeight - 220)) + "px";
      pop.style.insetInlineEnd = Math.max(12, innerWidth - r.left + 14) + "px";
    }
  }

  function done() {
    clearMark();
    if (box) box.hidden = true;
    markSeen();
  }

  function start(force) {
    if (!box) build();
    if (!steps.length) return;
    if (!force && seen()) return;
    i = 0;
    paint();
  }

  /* کارتابلی که کسی ماه‌هاست در آن کار می‌کند، راهنمای «از کجا شروع
     کنم» نمی‌خواهد. گشت فقط روی کارتابلی خودش باز می‌شود که هنوز
     دست‌نخورده است؛ بقیه هر وقت خواستند از راهنما صدایش می‌کنند. */
  function fresh() {
    try {
      var md = state.monthsData || {};
      if (Object.keys(md).length > 1) return false;
      var days = (state.days || []).filter(function (d) {
        return d && (d.main || d.meet || d.company || d.status || d.doneDate);
      });
      if (days.length) return false;
      var tasks = (state.tasks || []).filter(function (t) {
        return t && (t.owner || t.note ||
          t.status === "انجام شد" || t.status === "در حال انجام");
      });
      if (tasks.length) return false;
      if (state.calNotes && Object.keys(state.calNotes).length) return false;
      if (state.notes && Object.keys(state.notes).length) return false;
      if (state.personalDue && state.personalDue.length) return false;
      return true;
    } catch (e) { return false; }
  }

  function init() {
    if (seen()) return;
    if (!fresh()) return;
    /* یک مکثِ کوتاه: بگذار صفحه بنشیند و دادهٔ سرور بیاید، وگرنه گشت
       روی یک کارتابلِ نیمه‌بارگذاری‌شده باز می‌شود. */
    setTimeout(function () { start(false); }, 1800);
  }

  window.TOUR = { init: init, start: start, done: done, fresh: fresh };
})();
