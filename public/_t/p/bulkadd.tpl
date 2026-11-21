/* ==================== یک کار، چند روز ====================
   چک‌لیستِ ماهانه یک ردیف را یک‌بار می‌گیرد و «مهلت» هر ردیف یک
   روزِ ماه است. برای کاری که هر هفته تکرار می‌شود — «چهارشنبه‌ها
   بکاپ را تست کن» — باید چهار بار دکمهٔ افزودن را می‌زدی، چهار بار
   متن را می‌نوشتی و چهار بار شمارهٔ روز را پیدا می‌کردی. آدم یا
   این کار را نمی‌کند، یا یک ردیف می‌گذارد و بقیهٔ هفته‌ها را به
   حافظه‌اش می‌سپارد.

   این‌جا یک بار می‌نویسی و روزها را روی تقویمِ همان ماه می‌زنی.

   دو تصمیم:

   یک) روزِ هفته و روزِ دستی، دو راه نیستند؛ یک راه‌اند. زدنِ سرستونِ
   «چ» همهٔ چهارشنبه‌های ماه را تیک می‌زند و بعد می‌شود یکی‌شان را
   برداشت. بی این، باید دو حالت می‌ساختیم و کاربر باید می‌فهمید کدام
   حرفِ آخر را می‌زند — همان اشتباهی که در تقویمِ برنامهٔ روزانه یک
   بار از آن پرهیز شد.

   دو) تکرارِ ماهانه روی این ردیف‌ها خاموش است. چهارشنبهٔ آبان با
   چهارشنبهٔ آذر یکی نیست؛ ردیفی که با شمارهٔ روز به ماهِ بعد برود،
   روزِ هفته‌اش عوض شده و دروغ می‌گوید. ماهِ بعد دوباره از همین‌جا
   ساخته می‌شود. */
(function () {
  "use strict";

  var WD = ["ش", "ی", "د", "س", "چ", "پ", "ج"];
  var WDFULL = ["شنبه", "یک‌شنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنج‌شنبه", "جمعه"];
  var box = null, picked = {};

  function faN(n) {
    return String(n).replace(/[0-9]/g, function (d) { return "۰۱۲۳۴۵۶۷۸۹"[+d]; });
  }

  /* ماهی که چک‌لیست دارد نشان می‌دهد — همان که state.meta می‌گوید،
     نه ماهِ امروز: کاربر ممکن است ماهِ دیگری را باز کرده باشد. */
  function month() {
    var jm = 0, jy = 0;
    try {
      jm = JALALI_MONTH_NAMES.indexOf(String((state.meta || {}).month || "")) + 1;
      jy = parseInt((state.meta || {}).year, 10) || 0;
    } catch (e) { }
    if (!jm || !jy) {
      try {
        var p = String(getTodayJalaliStr()).split("/");
        jy = parseInt(p[0], 10); jm = parseInt(p[1], 10);
      } catch (e) { return null; }
    }
    if (!jm || !jy) return null;
    var len = 30;
    try { len = daysInJalaliMonth(jy, jm); } catch (e) { }
    return { jy: jy, jm: jm, len: len, name: JALALI_MONTH_NAMES[jm - 1] || "" };
  }

  /* ۰ = شنبه.

     دو کارتابل یک نامِ یکسان را دو شکل برمی‌گردانند: در یکی
     jalaliToGregorian شیء می‌دهد ({gy,gm,gd}) و در دیگری آرایه
     ([y,m,d]). بی این، کارتابل مالی بی‌صدا هیچ روزی را تیک
     نمی‌زد — نه خطایی، نه پیامی، فقط دکمه‌ای که کار نمی‌کرد. */
  function weekday(m, d) {
    try {
      var g = jalaliToGregorian(m.jy, m.jm, d);
      var gy = Array.isArray(g) ? g[0] : g.gy;
      var gm = Array.isArray(g) ? g[1] : g.gm;
      var gd = Array.isArray(g) ? g[2] : g.gd;
      var w = new Date(gy, gm - 1, gd).getDay();
      return isNaN(w) ? -1 : (w + 1) % 7;
    } catch (e) { return -1; }
  }

  function days() {
    return Object.keys(picked).filter(function (k) { return picked[k]; })
      .map(Number).sort(function (a, b) { return a - b; });
  }

  function paint() {
    var m = month();
    if (!m || !box) return;
    var got = days();

    var head = box.querySelector(".ba-wd");
    var i, h = "";
    for (i = 0; i < 7; i++) {
      /* روزِ هفته‌ای که همهٔ روزهایش تیک است، خودش هم تیک می‌خورَد */
      var all = [], d;
      for (d = 1; d <= m.len; d++) if (weekday(m, d) === i) all.push(d);
      var on = all.length && all.every(function (x) { return picked[x]; });
      h += '<button type="button" class="ba-w' + (on ? " on" : "") + '" data-w="' + i +
           '" title="همهٔ ' + WDFULL[i] + 'های ' + m.name + '">' + WD[i] + "</button>";
    }
    head.innerHTML = h;

    var grid = box.querySelector(".ba-grid");
    h = "";
    var first = weekday(m, 1);
    for (i = 0; i < first; i++) h += '<span class="ba-gap"></span>';
    for (d = 1; d <= m.len; d++)
      h += '<button type="button" class="ba-d' + (picked[d] ? " on" : "") +
           '" data-d="' + d + '">' + faN(d) + "</button>";
    grid.innerHTML = h;

    box.querySelector(".ba-sum").textContent = got.length
      ? faN(got.length) + " روز: " + got.map(faN).join("، ")
      : "هنوز روزی انتخاب نشده";
    box.querySelector(".ba-go").disabled = !got.length;
  }

  function build() {
    if (box) return box;
    var m = month();
    box = document.createElement("div");
    box.className = "ba-box";
    box.hidden = true;
    var cats = "";
    try {
      cats = CATEGORIES.map(function (c) {
        return '<option value="' + c + '">' + c + "</option>";
      }).join("");
    } catch (e) { }
    box.innerHTML =
      '<div class="ba-row">' +
        '<input type="text" class="ba-task" placeholder="مثلاً: تست بکاپ سرورها" ' +
          'aria-label="شرحِ وظیفه">' +
        '<select class="ba-cat" aria-label="دسته‌بندی">' + cats + "</select>" +
      "</div>" +
      '<div class="ba-cal">' +
        '<div class="ba-m">' + (m ? m.name + " " + faN(m.jy) : "") + "</div>" +
        '<div class="ba-wd"></div>' +
        '<div class="ba-grid"></div>' +
      "</div>" +
      '<div class="ba-foot">' +
        '<span class="ba-sum"></span>' +
        '<span class="ba-btns">' +
          '<button type="button" class="btn btn-ghost btn-sm ba-x">بی‌خیال</button>' +
          '<button type="button" class="btn btn-brass btn-sm ba-go">افزودن</button>' +
        "</span>" +
      "</div>";

    box.addEventListener("click", function (e) {
      var w = e.target.closest(".ba-w");
      if (w) { toggleWeek(+w.getAttribute("data-w")); return; }
      var d = e.target.closest(".ba-d");
      if (d) { var n = +d.getAttribute("data-d"); picked[n] = !picked[n]; paint(); return; }
      if (e.target.closest(".ba-x")) { close(); return; }
      if (e.target.closest(".ba-go")) add();
    });
    box.addEventListener("keydown", function (e) {
      if (e.key === "Escape") close();
      if (e.key === "Enter" && e.target.classList.contains("ba-task")) {
        e.preventDefault();
        if (days().length) add();
      }
    });
    return box;
  }

  function toggleWeek(w) {
    var m = month(), d, all = [];
    if (!m) return;
    for (d = 1; d <= m.len; d++) if (weekday(m, d) === w) all.push(d);
    var on = all.length && all.every(function (x) { return picked[x]; });
    all.forEach(function (x) { picked[x] = !on; });
    paint();
  }

  function open() {
    var host = document.getElementById("view-checklist");
    if (!host) return;
    var bar = host.querySelector(".toolbar");
    var el = build();
    if (el.parentNode !== host) host.insertBefore(el, bar ? bar.nextSibling : host.firstChild);
    picked = {};
    /* ماه ممکن است از بارِ قبل عوض شده باشد */
    var m = month();
    var ttl = el.querySelector(".ba-m");
    if (m && ttl) ttl.textContent = m.name + " " + faN(m.jy);
    el.hidden = false;
    paint();
    /* متنِ بارِ قبل پاک می‌شود. ماندنش یک تله بود: پنل که دوباره باز
       می‌شد، نامِ کارِ قبلی هنوز آن‌جا بود و یک کلیک کافی بود تا
       همان کار روی روزهای تازه بنشیند. */
    try {
      var box2 = el.querySelector(".ba-task");
      box2.value = "";
      box2.focus();
    } catch (e) { }
  }
  function close() {
    if (box) { box.hidden = true; picked = {}; }
  }

  /* دو کارتابل دو جور صفحه را تازه می‌کنند: یکی renderAll دارد و
     دیگری سه تابعِ جدا. این‌جا هرکدام که بود صدا زده می‌شود، تا این
     جزو به ساختارِ داخلیِ هیچ‌کدام گره نخورد. */
  function redraw() {
    try {
      if (typeof renderAll === "function") { renderAll(); return; }
    } catch (e) { }
    [["renderChecklist"], ["renderCards"], ["renderCharts"]].forEach(function (n) {
      try { if (typeof window[n[0]] === "function") window[n[0]](); } catch (e) { }
    });
  }

  function add() {
    var got = days();
    if (!got.length) return;
    var txt = (box.querySelector(".ba-task").value || "").trim();
    if (!txt) { try { box.querySelector(".ba-task").focus(); } catch (e) { } return; }
    var cat = box.querySelector(".ba-cat").value;
    var made = [];
    got.forEach(function (d) {
      var row = {
        category: cat, task: txt, owner: "", deadline: d,
        status: "انجام نشده", priority: "متوسط", note: "",
        rid: "t-" + Math.random().toString(36).slice(2, 10),
        since: state.currentMonthKey || "",
        /* تکرارِ ماهانه خاموش: چهارشنبهٔ این ماه، چهارشنبهٔ ماهِ بعد نیست */
        every: 0
      };
      state.tasks.push(row);
      made.push(row);
    });
    close();
    redraw();
    scheduleSave();
    try {
      UNDO.show(faN(made.length) + " ردیف برای «" + txt + "» افزوده شد", function () {
        made.forEach(function (r) {
          var i = state.tasks.indexOf(r);
          if (i >= 0) state.tasks.splice(i, 1);
        });
        redraw();
        scheduleSave();
      });
    } catch (e) { }
  }

  window.BULKADD = { open: open, close: close };
})();
