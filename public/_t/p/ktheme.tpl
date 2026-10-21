/* ==================== تم‌های کارتابل ====================
   تا امروز کارتابل یک ظاهر داشت و فقط «شب/روز» عوض می‌شد. حالا چند
   تمِ رنگی هم هست و خودِ کاربر از تنظیمات انتخابش می‌کند — نه اینکه
   یک ظاهرِ تازه به همه تحمیل شود.

   هر تم فقط کاغذ و رنگِ برند را عوض می‌کند (شیوه‌نامه‌اش در پارهٔ
   kthemecss). رنگ‌های معنادار — سبزِ «انجام شد»، کهربایی، قرمز — و
   رنگِ نمودارها دست نمی‌خورند، وگرنه با عوض کردنِ تم، معنیِ رنگ‌ها هم
   عوض می‌شد.

   کجا ذخیره می‌شود: هم در state (پس روی همهٔ دستگاه‌ها یکی است) و هم
   در localStorage (پس همان لحظهٔ باز شدنِ صفحه اعمال می‌شود، نه بعد
   از رسیدنِ داده از سرور). */
(function () {
  "use strict";

  /* کلیدِ مرورگر باید مالِ همین کارتابل باشد: همهٔ کارتابل‌ها روی یک
     دامنه‌اند و یک کلیدِ مشترک یعنی تمِ یکی روی آن یکی هم می‌نشست. */
  var LS = (function () {
    try { return STORE_KEY + ":kt"; } catch (e) { }
    try { return (window.KARTABL_SLUG || "kartabl") + ":kt"; } catch (e) { }
    return "kartabl:kt";
  })();

  var THEMES = [
    { id: "",         name: "کلاسیک", note: "همان کاغذِ همیشگی",
      bg: "#EEF2F6", ac: "#1A4FA3", ink: "#0B2545" },
    { id: "sea",      name: "دریا",   note: "آبیِ روشن",
      bg: "#EAF2FA", ac: "#1E7FD6", ink: "#0B2545" },
    { id: "mint",     name: "زمرد",   note: "سبزِ آرام",
      bg: "#EAF4EE", ac: "#19876A", ink: "#0B2545" },
    { id: "sunset",   name: "غروب",   note: "نارنجیِ گرم",
      bg: "#FBF0E8", ac: "#D2662F", ink: "#2B1A12" },
    { id: "violet",   name: "بنفشه",  note: "بنفشِ ملایم",
      bg: "#F1EDF9", ac: "#6B46C7", ink: "#18123A" },
    { id: "graphite", name: "گرافیت", note: "بی‌رنگ و آرام",
      bg: "#EFF1F3", ac: "#4A5A6B", ink: "#0B2545" }
  ];
  var IDS = THEMES.map(function (t) { return t.id; });

  function clean(v) {
    v = String(v == null ? "" : v);
    return IDS.indexOf(v) >= 0 ? v : "";
  }
  function current() {
    /* state حرفِ آخر را می‌زند؛ localStorage فقط برای لحظهٔ اول است */
    try {
      if (state && state.ui && typeof state.ui.theme === "string") return clean(state.ui.theme);
    } catch (e) { }
    try { return clean(localStorage.getItem(LS)); } catch (e) { return ""; }
  }
  function apply(id) {
    id = clean(id);
    var el = document.documentElement;
    if (id) el.setAttribute("data-kt", id); else el.removeAttribute("data-kt");
    /* رنگِ نوارِ وضعیتِ گوشی هم با تم عوض می‌شود */
    try { if (window.PWA) PWA.tint(); } catch (e) { }
  }
  function save(id) {
    id = clean(id);
    try {
      if (!state.ui || typeof state.ui !== "object") state.ui = {};
      state.ui.theme = id;
      scheduleSave();
    } catch (e) { }
    try { localStorage.setItem(LS, id); } catch (e) { }
    apply(id);
    paint();
  }

  /* ---------- انتخاب‌گر، داخلِ تنظیمات ---------- */
  function paint() {
    var box = document.getElementById("ktList");
    if (!box) return;
    var cur = current();
    box.innerHTML = THEMES.map(function (t) {
      return '<button type="button" class="kt-card' + (t.id === cur ? " on" : "") +
        '" data-kt-pick="' + t.id + '">' +
        '<span class="kt-swatch">' +
          '<i class="s-bg" style="background:' + t.bg + '"></i>' +
          '<i class="s-ac" style="background:' + t.ac + '"></i>' +
          '<i class="s-l1" style="background:' + t.ink + '"></i>' +
          '<i class="s-l2" style="background:' + t.ink + '"></i>' +
        '</span>' +
        '<span class="kt-name">' + t.name + '</span>' +
        '<span class="kt-note">' + t.note + '</span>' +
      '</button>';
    }).join("");
    box.querySelectorAll("[data-kt-pick]").forEach(function (b) {
      b.addEventListener("click", function () { save(b.getAttribute("data-kt-pick")); });
    });
  }

  /* صفحه که بالا می‌آید، تمِ ذخیره‌شده را همان لحظه می‌گذاریم؛ و بعد
     از رسیدنِ داده از سرور، اگر آن‌جا چیزِ دیگری بود، همان می‌نشیند. */
  apply(current());
  function boot() { apply(current()); paint(); }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot);
  else boot();
  setTimeout(boot, 1500);
  setTimeout(boot, 3500);

  window.KTHEME = { list: THEMES, get: current, set: save, apply: apply, refresh: boot };
})();
