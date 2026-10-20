/* ==================== تقویمِ برنامهٔ روزانه ====================
   سه کار را با هم می‌کند، چون هر سه یک چیزند: «این روز، چه کاری؟»

   یک) دکمهٔ «تقویم» کنارِ خروجی‌ها. با زدنش یک ماهِ شمسی باز می‌شود و
       روی هر روز، شمارِ کارهای همان روز نوشته است.
   دو) زدنِ یک روز، جدول را همان روز می‌کند. زدنِ خودِ تاریخ داخلِ
       جدول هم همین کار را می‌کند — همان‌جا که چشم است.
   سه) مرتب‌سازیِ جدول بر اساس تاریخ. سرستونِ «📅 تاریخ» زدنی است و
       بین سه حالت می‌چرخد: تاریخِ صعودی، نزولی، و «دستی» (همان
       ترتیبی که خودِ کاربر با کشیدنِ ردیف‌ها ساخته).

   چرا یک پاره و نه دو تا: فیلترِ روز و مرتب‌سازی هر دو روی همان
   فهرست می‌نشینند و باید از هم خبر داشته باشند. قالب‌ها فقط یک خط
   صدا می‌زنند — DAYCAL.arrange(rows) — و بقیه‌اش این‌جاست. */
(function () {
  "use strict";

  var dayFilter = "";          /* "" یعنی همهٔ روزها */
  var sortMode = "asc";        /* asc | desc | manual */
  var view = null;             /* ماهی که تقویم نشان می‌دهد: {jy, jm} */
  var pop = null;

  var FA = "۰۱۲۳۴۵۶۷۸۹";
  function faN(n, w) {
    var s = String(n);
    while (w && s.length < w) s = "0" + s;
    return s.replace(/[0-9]/g, function (d) { return FA[+d]; });
  }
  function latin(s) {
    return String(s == null ? "" : s)
      .replace(/[۰-۹]/g, function (d) { return String(FA.indexOf(d)); })
      .replace(/[٠-٩]/g, function (d) { return String("٠١٢٣٤٥٦٧٨٩".indexOf(d)); });
  }
  /* کلیدِ تاریخ: رقمِ لاتین، ماه و روزِ دورقمی. این‌طور مقایسهٔ رشته‌ای
     همان مقایسهٔ تاریخ است. */
  function key(v) {
    var m = latin(v).match(/(\d{3,4})\s*[\/\-.]\s*(\d{1,2})\s*[\/\-.]\s*(\d{1,2})/);
    if (!m) return "";
    return m[1] + "/" + ("0" + m[2]).slice(-2) + "/" + ("0" + m[3]).slice(-2);
  }
  function faKey(k) {
    var p = String(k || "").split("/");
    return p.length === 3 ? faN(p[0]) + "/" + faN(p[1]) + "/" + faN(p[2]) : "";
  }
  function rows() {
    try { return Array.isArray(state.days) ? state.days : []; } catch (e) { return []; }
  }
  function monthLen(jy, jm) {
    try { return daysInJalaliMonth(jy, jm); }
    catch (e) { return jm <= 6 ? 31 : (jm <= 11 ? 30 : 29); }
  }
  function monthName(jm) {
    try { return JALALI_MONTH_NAMES[jm - 1] || ""; } catch (e) { return String(jm); }
  }
  function today() {
    try { var t = DatePick.today(); return { jy: t.jy, jm: t.jm, jd: t.jd }; }
    catch (e) { return null; }
  }
  /* روزِ هفتهٔ شمسی: شنبه صفر */
  function weekStart(jy, jm) {
    try {
      var g = DatePick.toG(jy, jm, 1);
      var w = new Date(g.gy, g.gm - 1, g.gd).getDay();   /* یکشنبه صفر */
      return (w + 1) % 7;
    } catch (e) { return 0; }
  }

  /* ---------- آن یک خطی که قالب‌ها صدا می‌زنند ---------- */
  function arrange(list) {
    var out = list;
    if (dayFilter) out = out.filter(function (d) { return key(d && d.createdDate) === dayFilter; });
    if (sortMode !== "manual") {
      var dir = sortMode === "desc" ? -1 : 1;
      /* ردیفِ بی‌تاریخ همیشه ته فهرست می‌ماند، در هر دو جهت: «بی‌تاریخ»
         نه از همه قدیمی‌تر است نه از همه تازه‌تر. */
      out = out.slice().sort(function (a, b) {
        var ka = key(a && a.createdDate), kb = key(b && b.createdDate);
        if (!ka && !kb) return (a.idx || 0) - (b.idx || 0);
        if (!ka) return 1;
        if (!kb) return -1;
        if (ka === kb) return (a.idx || 0) - (b.idx || 0);
        return ka < kb ? -dir : dir;
      });
    }
    return out;
  }

  /* شمارِ کارهای هر روزِ یک ماه */
  function counts(jy, jm) {
    var out = {};
    rows().forEach(function (d) {
      var k = key(d && d.createdDate);
      if (!k) return;
      var p = k.split("/");
      if (+p[0] === jy && +p[1] === jm) out[+p[2]] = (out[+p[2]] || 0) + 1;
    });
    return out;
  }
  /* ماهی که تقویم با آن باز می‌شود: همین ماه، اگر کاری داشته باشد —
     چون «برنامهٔ روزانه» یعنی همین ماه. وگرنه آخرین ماهی که کاری در
     آن ثبت شده، تا تقویم خالی باز نشود. */
  function startView() {
    var t = today();
    if (t) {
      var here = counts(t.jy, t.jm);
      if (Object.keys(here).length) return { jy: t.jy, jm: t.jm };
    }
    var ks = rows().map(function (d) { return key(d && d.createdDate); })
      .filter(Boolean).sort();
    if (ks.length) {
      var p = ks[ks.length - 1].split("/");
      return { jy: +p[0], jm: +p[1] };
    }
    return t ? { jy: t.jy, jm: t.jm } : { jy: 1405, jm: 1 };
  }

  function redraw() {
    try { renderDaily(); } catch (e) { }
    paintBar();
    if (pop && !pop.hidden) paintCal();
    paintSortMark();
  }

  /* ---------- نوارِ بالای جدول ---------- */
  function bar() {
    var sec = document.getElementById("view-daily");
    if (!sec) return null;
    var b = sec.querySelector(".day-cal-bar");
    if (b) return b;
    /* کنارِ خروجی‌ها می‌نشیند. اگر ادمین خروجی‌ها را بسته باشد، آن
       کادر خالی است و همین‌جا یک کادرِ خودمان می‌سازیم. */
    var host = sec.querySelector(".day-ex");
    b = document.createElement("span");
    b.className = "day-cal-bar";
    if (host) host.appendChild(b);
    else {
      var wrap = sec.querySelector(".tbl-wrap");
      var own = document.createElement("div");
      own.className = "day-ex";
      own.appendChild(b);
      if (wrap && wrap.parentNode) wrap.parentNode.insertBefore(own, wrap);
      else sec.appendChild(own);
    }
    return b;
  }

  function paintBar() {
    var b = bar();
    if (!b) return;
    var n = dayFilter
      ? rows().filter(function (d) { return key(d && d.createdDate) === dayFilter; }).length : 0;
    b.innerHTML =
      '<button type="button" class="btn btn-ghost btn-sm dcal-btn" id="dayCalBtn" ' +
        'title="تقویمِ برنامهٔ روزانه">🗓 تقویم</button>' +
      (dayFilter
        ? '<span class="dcal-chip" id="dayCalChip">📅 ' + faKey(dayFilter) +
          ' <b>' + faN(n) + '</b> کار' +
          '<button type="button" title="نمایشِ همهٔ روزها" id="dayCalClear">✕</button></span>'
        : "");
    var btn = document.getElementById("dayCalBtn");
    if (btn) btn.addEventListener("click", function (e) { e.stopPropagation(); toggle(); });
    var clr = document.getElementById("dayCalClear");
    if (clr) clr.addEventListener("click", function () { pick(""); });
  }

  /* ---------- خودِ تقویم ---------- */
  function build() {
    if (pop) return pop;
    pop = document.createElement("div");
    pop.className = "dcal-pop";
    pop.hidden = true;
    pop.innerHTML =
      '<div class="dcal-head">' +
        '<button type="button" class="dcal-nav" data-dcal-step="-1" title="ماهِ قبل">‹</button>' +
        '<span class="dcal-ttl"></span>' +
        '<button type="button" class="dcal-nav" data-dcal-step="1" title="ماهِ بعد">›</button>' +
      '</div>' +
      '<div class="dcal-wd"><span>ش</span><span>ی</span><span>د</span><span>س</span>' +
        '<span>چ</span><span>پ</span><span>ج</span></div>' +
      '<div class="dcal-grid"></div>' +
      '<div class="dcal-foot">' +
        '<button type="button" class="dcal-all">همهٔ روزها</button>' +
        '<button type="button" class="dcal-today">امروز</button>' +
      '</div>';
    document.body.appendChild(pop);

    pop.addEventListener("click", function (e) {
      var st = e.target.closest ? e.target.closest("[data-dcal-step]") : null;
      if (st) {
        var n = Number(st.getAttribute("data-dcal-step"));
        view.jm += n;
        if (view.jm > 12) { view.jm = 1; view.jy++; }
        if (view.jm < 1) { view.jm = 12; view.jy--; }
        paintCal();
        return;
      }
      var d = e.target.closest ? e.target.closest("[data-dcal-day]") : null;
      if (d) {
        var k = view.jy + "/" + ("0" + view.jm).slice(-2) + "/" +
                ("0" + d.getAttribute("data-dcal-day")).slice(-2);
        pick(k === dayFilter ? "" : k);     /* همان روز را دوباره زدن، برش می‌دارد */
        return;
      }
      if (e.target.closest(".dcal-all")) { pick(""); return; }
      if (e.target.closest(".dcal-today")) {
        var t = today();
        if (!t) return;
        view = { jy: t.jy, jm: t.jm };
        var tk = t.jy + "/" + ("0" + t.jm).slice(-2) + "/" + ("0" + t.jd).slice(-2);
        /* اگر امروز کاری ندارد، فقط می‌رویم سرِ ماهِ امروز و فیلتر
           نمی‌گذاریم — وگرنه جدولِ خالی دستِ آدم می‌ماند. */
        var has = rows().some(function (r) { return key(r && r.createdDate) === tk; });
        if (has) pick(tk); else { paintCal(); }
      }
    });
    document.addEventListener("click", function (e) {
      if (pop.hidden) return;
      if (pop.contains(e.target)) return;
      if (e.target.closest && e.target.closest("#dayCalBtn")) return;
      close();
    });
    document.addEventListener("keydown", function (e) { if (e.key === "Escape") close(); });
    return pop;
  }

  function paintCal() {
    if (!pop) return;
    var t = today();
    var c = counts(view.jy, view.jm);
    var pad = weekStart(view.jy, view.jm);
    var len = monthLen(view.jy, view.jm);
    var html = "";
    for (var i = 0; i < pad; i++) html += '<span class="dcal-pad"></span>';
    for (var d = 1; d <= len; d++) {
      var k = view.jy + "/" + ("0" + view.jm).slice(-2) + "/" + ("0" + d).slice(-2);
      var n = c[d] || 0;
      var cls = "dcal-d" + (n ? " has" : "") + (k === dayFilter ? " on" : "") +
        (t && t.jy === view.jy && t.jm === view.jm && t.jd === d ? " now" : "");
      /* روزی که کاری ندارد زدنی نیست: زدنش یک جدولِ خالی می‌داد و آدم
         خیال می‌کرد چیزی خراب شده. خودِ تقویم هم همان را می‌گوید —
         روزِ بی‌کار، بی‌نشان است. */
      html += '<button type="button" class="' + cls + '" data-dcal-day="' + d + '"' +
        (n ? ' title="' + faN(n) + ' کار"' : ' disabled title="کاری ثبت نشده"') + '>' +
        '<i>' + faN(d) + '</i>' + (n ? '<b>' + faN(n) + '</b>' : "") + '</button>';
    }
    pop.querySelector(".dcal-grid").innerHTML = html;
    pop.querySelector(".dcal-ttl").textContent = monthName(view.jm) + " " + faN(view.jy);
  }

  function place() {
    var btn = document.getElementById("dayCalBtn");
    if (!btn || !pop) return;
    var r = btn.getBoundingClientRect();
    var w = pop.offsetWidth || 262, h = pop.offsetHeight || 300;
    var left = Math.min(Math.max(8, r.left - (w - r.width) / 2), innerWidth - w - 8);
    var top = r.bottom + 6;
    if (top + h > innerHeight - 8) top = Math.max(8, r.top - h - 6);
    pop.style.left = left + "px";
    pop.style.top = top + "px";
  }

  function toggle() { if (pop && !pop.hidden) close(); else open(); }
  function open() {
    build();
    if (!view) view = startView();
    pop.hidden = false;
    paintCal();
    place();
  }
  function close() { if (pop) pop.hidden = true; }

  function pick(k) {
    dayFilter = k || "";
    if (dayFilter) {
      var p = dayFilter.split("/");
      view = { jy: +p[0], jm: +p[1] };
    }
    redraw();
  }

  /* ---------- مرتب‌سازی ---------- */
  function sortTh() {
    var sec = document.getElementById("view-daily");
    if (!sec) return null;
    var ths = sec.querySelectorAll(".daily-plan-table thead tr:first-child th");
    for (var i = 0; i < ths.length; i++)
      if (/تاریخ/.test(ths[i].textContent) && !/انجام/.test(ths[i].textContent)) return ths[i];
    return null;
  }
  function paintSortMark() {
    var th = sortTh();
    if (!th) return;
    th.classList.add("dcal-sort");
    th.setAttribute("title", sortMode === "asc" ? "تاریخ: از قدیم به تازه — برای عوض کردن بزنید"
      : sortMode === "desc" ? "تاریخ: از تازه به قدیم — برای عوض کردن بزنید"
      : "ترتیبِ دستی (همان‌طور که ردیف‌ها را چیده‌اید) — برای مرتب‌سازی بزنید");
    var mark = th.querySelector(".dcal-arrow");
    if (!mark) {
      mark = document.createElement("span");
      mark.className = "dcal-arrow";
      th.appendChild(mark);
    }
    mark.textContent = sortMode === "asc" ? "▲" : sortMode === "desc" ? "▼" : "↕";
    mark.classList.toggle("off", sortMode === "manual");
  }
  function wireSort() {
    var th = sortTh();
    if (!th || th.__dcal) return;
    th.__dcal = true;
    th.addEventListener("click", function () {
      sortMode = sortMode === "asc" ? "desc" : sortMode === "desc" ? "manual" : "asc";
      redraw();
    });
    paintSortMark();
  }

  /* زدنِ خودِ تاریخ داخلِ جدول = همان روز را نشان بده. ردیف‌ها مدام از
     نو کشیده می‌شوند، پس شنونده روی خودِ جدول است نه روی خانه‌ها. */
  function wireCells() {
    var body = document.getElementById("dailyBody");
    if (!body || body.__dcal) return;
    body.__dcal = true;
    body.addEventListener("click", function (e) {
      var td = e.target.closest ? e.target.closest("td.daily-date-cell") : null;
      if (!td || td.classList.contains("daily-done-cell")) return;
      var k = key(td.textContent);
      if (!k) return;
      pick(k === dayFilter ? "" : k);
    });
  }

  function boot() {
    paintBar();
    wireSort();
    wireCells();
  }

  window.DAYCAL = {
    arrange: arrange,
    open: open, close: close,
    /* کشیدنِ ردیف یعنی «ترتیب را خودم می‌چینم» — وگرنه جابه‌جایی‌اش
       زیرِ مرتب‌سازیِ تاریخ دیده نمی‌شد و آدم خیال می‌کرد کار نکرد. */
    manual: function () { sortMode = "manual"; paintSortMark(); },
    refresh: boot,
    key: key
  };

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot);
  else boot();
  /* ردیف‌ها و دکمه‌ها بعد از ورود ساخته می‌شوند؛ یک تکانِ دوم تا
     دکمهٔ تقویم و سرستونِ زدنی جا بیفتند. */
  setTimeout(boot, 1200);
  setTimeout(boot, 3000);
})();
