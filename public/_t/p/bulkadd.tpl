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
  /* ماهی که تقویمِ پنل نشان می‌دهد. با فلش‌ها جابه‌جا می‌شود و لازم
     نیست همان ماهی باشد که چک‌لیست باز کرده — ولی موقعِ افزودن،
     کارتابل به همان ماه می‌رود، چون چک‌لیست هر بار یک ماه را نشان
     می‌دهد و ردیفی که به ماهِ دیگر برود جایی دیده نمی‌شود. */
  var view = null;

  function faN(n) {
    return String(n).replace(/[0-9]/g, function (d) { return "۰۱۲۳۴۵۶۷۸۹"[+d]; });
  }

  /* ماهی که چک‌لیست دارد نشان می‌دهد — همان که state.meta می‌گوید،
     نه ماهِ امروز: کاربر ممکن است ماهِ دیگری را باز کرده باشد. */
  function openMonth() {
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
    return mk(jy, jm);
  }
  function mk(jy, jm) {
    var len = 30;
    try { len = daysInJalaliMonth(jy, jm); } catch (e) { }
    return { jy: jy, jm: jm, len: len, name: JALALI_MONTH_NAMES[jm - 1] || "" };
  }
  /* ماهی که همین حالا روی تقویمِ پنل است */
  function month() { return view || openMonth(); }
  function step(n) {
    var m = month();
    if (!m) return;
    var jm = m.jm + n, jy = m.jy;
    if (jm > 12) { jm = 1; jy++; }
    if (jm < 1) { jm = 12; jy--; }
    view = mk(jy, jm);
    /* روزهای تیک‌خورده مالِ ماهِ قبلی بودند */
    picked = {};
    paint();
  }
  function sameAsOpen() {
    var a = month(), b = openMonth();
    return !!(a && b && a.jy === b.jy && a.jm === b.jm);
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

    var mn = box.querySelector(".ba-mn");
    if (mn) mn.textContent = m.name + " " + faN(m.jy);

    /* ماهی که روی تقویم است همان ماهِ چک‌لیست نیست؟ بگو چه می‌شود،
       پیش از آنکه بشود. */
    var other = box.querySelector(".ba-other");
    if (other) {
      var ok2 = sameAsOpen();
      other.hidden = ok2;
      other.textContent = ok2 ? "" :
        "این ماه باز نیست — با افزودن، کارتابل به " + m.name + " " + faN(m.jy) + " می‌رود.";
    }

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
    var opts = function (list, sel) {
      try {
        return list.map(function (c) {
          var v = Array.isArray(c) ? c[0] : c, n = Array.isArray(c) ? c[1] : c;
          return '<option value="' + v + '"' + (String(v) === String(sel) ? " selected" : "") +
                 ">" + n + "</option>";
        }).join("");
      } catch (e) { return ""; }
    };
    var cats = "", stats = "", pris = "", reps = "";
    try { cats = opts(CATEGORIES); } catch (e) { }
    try { stats = opts(STATUS, "انجام نشده"); } catch (e) { }
    try { pris = opts(PRIORITY, "متوسط"); } catch (e) { }
    try { reps = opts(REPEATS, 0); } catch (e) { }
    box.innerHTML =
      '<div class="ba-row">' +
        '<input type="text" class="ba-task" placeholder="شرحِ کار — مثلاً: تست بکاپ سرورها" ' +
          'aria-label="شرحِ وظیفه">' +
        '<select class="ba-cat" aria-label="دسته‌بندی">' + cats + "</select>" +
      "</div>" +
      '<div class="ba-row">' +
        '<input type="text" class="ba-owner" placeholder="مسئول" aria-label="مسئول">' +
        '<select class="ba-stat" aria-label="وضعیت">' + stats + "</select>" +
        '<select class="ba-pri" aria-label="اولویت">' + pris + "</select>" +
        '<select class="ba-rep" aria-label="تکرار" title="تکرارِ ماه‌به‌ماه">' + reps + "</select>" +
      "</div>" +
      '<div class="ba-row">' +
        '<input type="text" class="ba-note" placeholder="یادداشت (اختیاری)" aria-label="یادداشت">' +
      "</div>" +
      '<div class="ba-cal">' +
        '<div class="ba-m">' +
          '<button type="button" class="ba-nav" data-step="-1" aria-label="ماهِ قبل">\u203A</button>' +
          '<span class="ba-mn">' + (m ? m.name + " " + faN(m.jy) : "") + "</span>" +
          '<button type="button" class="ba-nav" data-step="1" aria-label="ماهِ بعد">\u2039</button>' +
        "</div>" +
        '<div class="ba-wd"></div>' +
        '<div class="ba-grid"></div>' +
        '<div class="ba-other" hidden></div>' +
      "</div>" +
      '<div class="ba-foot">' +
        '<span class="ba-sum"></span>' +
        '<span class="ba-btns">' +
          '<button type="button" class="btn btn-ghost btn-sm ba-x">بی‌خیال</button>' +
          '<button type="button" class="btn btn-brass btn-sm ba-go">افزودن</button>' +
        "</span>" +
      "</div>";

    box.addEventListener("click", function (e) {
      var nv = e.target.closest(".ba-nav");
      if (nv) { step(+nv.getAttribute("data-step")); return; }
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
    /* هر بار از ماهِ خودِ چک‌لیست شروع می‌شود، نه ماهی که بارِ قبل
       رفته بودیم */
    view = null;
    el.hidden = false;
    paint();
    /* متنِ بارِ قبل پاک می‌شود. ماندنش یک تله بود: پنل که دوباره باز
       می‌شد، نامِ کارِ قبلی هنوز آن‌جا بود و یک کلیک کافی بود تا
       همان کار روی روزهای تازه بنشیند. */
    try {
      el.querySelector(".ba-task").value = "";
      el.querySelector(".ba-owner").value = "";
      el.querySelector(".ba-note").value = "";
      el.querySelector(".ba-task").focus();
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

  function val(sel, dflt) {
    try {
      var el = box.querySelector(sel);
      return el ? el.value : dflt;
    } catch (e) { return dflt; }
  }

  function add() {
    var got = days();
    if (!got.length) return;
    var txt = (val(".ba-task", "") || "").trim();
    if (!txt) { try { box.querySelector(".ba-task").focus(); } catch (e) { } return; }

    var cat = val(".ba-cat", ""), owner = (val(".ba-owner", "") || "").trim();
    var stat = val(".ba-stat", "انجام نشده"), pri = val(".ba-pri", "متوسط");
    var note = (val(".ba-note", "") || "").trim();
    var rep = parseInt(val(".ba-rep", "0"), 10) || 0;

    /* اگر تقویم روی ماهِ دیگری است، اول کارتابل را همان‌جا ببر —
       وگرنه ردیف‌ها در ماهی می‌نشینند که دیده نمی‌شود. راهش همان
       switchToMonth خودِ برنامه است، نه دست‌کاریِ مستقیمِ داده. */
    var m = month();
    if (m && !sameAsOpen()) {
      /* اگر ماه از قبل هست، فقط می‌رویم سراغش و چیزی عوض نمی‌شود.
         ولی اگر تازه ساخته می‌شود، چک‌لیستش باید خالی باشد.

         switchToMonth برای ماهِ تازه، کارهای تکرارشوندهٔ ماهِ قبل را
         می‌آورد — که سرِ جای خودش درست است: کسی که از پنجرهٔ ماه‌ها
         ماهِ تازه می‌سازد همین را می‌خواهد. ولی این‌جا نه. این‌جا
         کاربر گفته «این چند کار را در آذر بگذار»، و ما به‌جایش شانزده
         کارِ آبان را هم می‌ریختیم تو — از جمله آن‌هایی که انجام شده
         بودند و با وضعیتِ صفرشده دوباره ظاهر می‌شدند. ماهی که برای
         گذاشتنِ چهار کار ساخته می‌شود، باید همان چهار کار را داشته
         باشد.

         همین حکم برای برنامهٔ روزانه هم هست: ماهِ تازه کارهای
         نیمه‌کارهٔ ماهِ قبل را هم می‌آورد، با تاریخِ همان ماهِ قبل.
         نتیجه‌اش ردیف‌هایی بود در آذر با تاریخِ ۱۴۰۵/۰۸/۰۲ که
         دیگر در آبان هم وجود نداشتند. */
      var fresh = true;
      try {
        fresh = !state.monthsData[monthKeyOf(m.name, String(m.jy))];
      } catch (e) { }
      try {
        switchToMonth(m.name, String(m.jy),
          fresh ? { carryTasks: false, carryDays: false } : undefined);
      } catch (e) { console.error("[ماه]", e); }
    }

    /* عکسِ کلِ فهرست، پیش از دست‌زدن: هم ردیف‌ها و هم ترتیبشان.
       «برگرداندن» باید هر دو را برگرداند، وگرنه ردیف‌ها می‌روند و
       ترتیبِ دستیِ کاربر رفته می‌ماند. */
    var before = state.tasks.slice();

    var made = [];
    got.forEach(function (d) {
      var row = {
        category: cat, task: txt, owner: owner, deadline: d,
        status: stat, priority: pri, note: note,
        rid: "t-" + Math.random().toString(36).slice(2, 10),
        since: state.currentMonthKey || "",
        /* پیش‌فرض خاموش: چهارشنبهٔ این ماه، چهارشنبهٔ ماهِ بعد نیست.
           ولی دستِ کاربر باز است. */
        every: rep
      };
      state.tasks.push(row);
      made.push(row);
    });

    /* و بعد کلِ فهرست به ترتیبِ مهلت مرتب می‌شود. ردیف‌های تازه
       ته فهرست می‌نشستند و آدم باید دنبالشان می‌گشت — حالا هر کار
       سرِ روزِ خودش است.

       این بار با خودِ داده، نه با نمای مرتب‌شده (tsort): کاربر گفت
       «بعد از ثبت به ترتیب تاریخ نشون بده»، یعنی فهرست همان‌طور
       بماند، نه اینکه با یک کلیک به هم بریزد. برگشتش هم هست: نوارِ
       پایینِ صفحه ترتیبِ قبلی را دست‌نخورده نگه داشته.

       مرتب‌سازی پایدار است، پس کارهای یک روز ترتیبِ خودشان را
       نگه می‌دارند. ردیفِ بی‌مهلت ته می‌رود: عددِ صفر اول می‌نشست
       و فهرست با چند خانهٔ خالی شروع می‌شد. */
    var dayOf = function (t) {
      var n = parseInt((t || {}).deadline, 10);
      return (!isFinite(n) || n <= 0) ? 99 : n;
    };
    state.tasks.sort(function (a, b) { return dayOf(a) - dayOf(b); });

    close();
    redraw();
    scheduleSave();
    try {
      UNDO.show(faN(made.length) + " ردیف برای «" + txt + "» افزوده شد", function () {
        /* همان فهرستِ پیش از افزودن، با همان ترتیب */
        state.tasks.length = 0;
        before.forEach(function (r) { state.tasks.push(r); });
        redraw();
        scheduleSave();
      });
    } catch (e) { }
  }

  window.BULKADD = { open: open, close: close };
})();
