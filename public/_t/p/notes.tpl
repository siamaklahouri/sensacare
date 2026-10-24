/* ==================== توضیحاتِ یک بخش ====================
   جدول‌ها جای عدد و وضعیت‌اند، نه جای «چرا». اینکه بکاپِ فلان سرور
   عمداً هفتگی است، یا شمارهٔ تماسِ پشتیبانِ استوریج چند است، یا
   قرارِ ماهِ بعد با فلان شرکت چه بود — هیچ‌کدام ستون ندارند و تا
   حالا یا در ذهن می‌ماندند یا در یک فایلِ دیگر.

   این یک دفترچهٔ ساده است که به هر بخشی می‌چسبد: هر توضیح یک کادر،
   با تاریخِ خودش. نوشتن که تمام شد، خودش ذخیره می‌شود — دکمهٔ
   «ذخیره» یعنی یک کارِ اضافه که آدم فراموشش می‌کند.

   جایش داخلِ همان state است، پس روی همهٔ دستگاه‌ها هست و در پشتیبان
   هم می‌آید. */
(function () {
  "use strict";

  var timer = null;

  function esc(s) {
    try { return escapeHtml(String(s == null ? "" : s)); }
    catch (e) { return String(s == null ? "" : s).replace(/[&<>"]/g, ""); }
  }
  function today() {
    try { return getTodayJalaliStr(); } catch (e) { return ""; }
  }
  function faN(s) {
    try { return fa(String(s == null ? "" : s)); } catch (e) { return String(s || ""); }
  }

  function all() {
    try {
      if (!state.notes || typeof state.notes !== "object" || Array.isArray(state.notes))
        state.notes = {};
      return state.notes;
    } catch (e) { return {}; }
  }
  function list(key) {
    var o = all();
    if (!Array.isArray(o[key])) o[key] = [];
    return o[key];
  }

  function save() {
    try { scheduleSave(); } catch (e) { }
  }

  function render(key) {
    var box = document.querySelector('[data-notes="' + key + '"]');
    if (!box) return;
    var rows = list(key);
    if (!rows.length) {
      box.innerHTML = '<div class="nt-empty">هنوز توضیحی نوشته نشده.</div>';
      return;
    }
    box.innerHTML = rows.map(function (n, i) {
      return '<div class="nt-row" data-i="' + i + '">' +
        '<textarea class="nt-txt" rows="2" placeholder="توضیح…">' + esc(n.text || "") + '</textarea>' +
        '<div class="nt-side">' +
          '<span class="nt-when">' + faN(n.at || "") + '</span>' +
          '<button type="button" class="nt-del" title="حذف این توضیح">✕</button>' +
        '</div></div>';
    }).join("");
    /* بزرگ شدنِ کادر با متن: متنی که سه خط است نباید در دو خط بلغزد */
    box.querySelectorAll(".nt-txt").forEach(grow);
  }

  function grow(ta) {
    ta.style.height = "auto";
    ta.style.height = Math.min(360, Math.max(46, ta.scrollHeight)) + "px";
  }

  function add(key) {
    list(key).unshift({ text: "", at: today() });
    save();
    render(key);
    var first = document.querySelector('[data-notes="' + key + '"] .nt-txt');
    if (first) first.focus();
  }

  /* یک شنوندهٔ واحد روی سند: این کادرها از نو ساخته می‌شوند و
     شنوندهٔ ردیفی هر بار باید دوباره بسته می‌شد. */
  document.addEventListener("input", function (e) {
    var ta = e.target;
    if (!ta.classList || !ta.classList.contains("nt-txt")) return;
    var box = ta.closest("[data-notes]");
    var row = ta.closest(".nt-row");
    if (!box || !row) return;
    var key = box.getAttribute("data-notes");
    var i = Number(row.getAttribute("data-i"));
    var n = list(key)[i];
    if (!n) return;
    n.text = ta.value;
    if (!n.at) n.at = today();
    grow(ta);
    clearTimeout(timer);
    timer = setTimeout(save, 700);
  });

  document.addEventListener("click", function (e) {
    var add2 = e.target.closest ? e.target.closest("[data-notes-add]") : null;
    if (add2) { add(add2.getAttribute("data-notes-add")); return; }
    var del = e.target.closest ? e.target.closest(".nt-del") : null;
    if (!del) return;
    var box = del.closest("[data-notes]");
    var row = del.closest(".nt-row");
    if (!box || !row) return;
    var key = box.getAttribute("data-notes");
    var i = Number(row.getAttribute("data-i"));
    var n = list(key)[i];
    /* کادرِ خالی پرسش ندارد؛ نوشته‌شده دارد. */
    if (n && String(n.text || "").trim() &&
        !confirm("این توضیح پاک شود؟")) return;
    list(key).splice(i, 1);
    save();
    render(key);
  });

  function init() {
    document.querySelectorAll("[data-notes]").forEach(function (box) {
      render(box.getAttribute("data-notes"));
    });
  }

  window.NOTES = { init: init, render: render, add: add, list: list };
})();
