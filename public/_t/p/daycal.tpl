/* ==================== تقویمِ برنامهٔ روزانه ====================
   «این روز، چه کاری؟» — همین یک سؤال، با یک تقویم.

   دکمهٔ «تقویم» کنارِ خروجی‌ها یک ماهِ شمسی باز می‌کند و روی هر روز،
   شمارِ کارهای همان روز نوشته است. زدنِ یک روز، جدول را همان روز
   می‌کند. زدنِ خودِ تاریخ داخلِ جدول هم همین کار را می‌کند — همان‌جا
   که چشم است.

   همهٔ این‌ها روی *همان* پالایهٔ ستونِ تاریخ می‌نشیند، نه یک فیلترِ
   جداگانه: ستونِ «📅 تاریخ» خودش پالایه دارد (مثلِ وضعیت و شرکت) و
   تقویم فقط راهی دیگر برای تیک زدنِ همان است. یک حالت، سه راهِ
   تنظیم — وگرنه آدم نمی‌دانست کدام‌یک حرفِ آخر را می‌زند. */
(function () {
  "use strict";

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
  /* کلیدِ تاریخ: رقمِ لاتین و دو رقمیِ ماه و روز — برای مقایسه و شمردن */
  function key(v) {
    var m = latin(v).match(/(\d{3,4})\s*[\/\-.]\s*(\d{1,2})\s*[\/\-.]\s*(\d{1,2})/);
    if (!m) return "";
    return m[1] + "/" + ("0" + m[2]).slice(-2) + "/" + ("0" + m[3]).slice(-2);
  }
  /* و همان تاریخ، به شکلی که در ستون و در پالایه دیده می‌شود */
  function faKey(k) {
    var p = String(k || "").split("/");
    return p.length === 3 ? faN(p[0]) + "/" + faN(p[1]) + "/" + faN(p[2]) : "";
  }
  function rows() {
    try { return Array.isArray(state.days) ? state.days : []; } catch (e) { return []; }
  }
  /* پالایهٔ ستونِ تاریخ — همان که قالب نگه می‌دارد */
  function picked() {
    try { return (window.DAY_DATE ? DAY_DATE.get() : []) || []; } catch (e) { return []; }
  }
  function setPicked(list) {
    try { if (window.DAY_DATE) DAY_DATE.set(list); } catch (e) { }
  }
  function pickedKeys() { return picked().map(key).filter(Boolean); }

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
      return (new Date(g.gy, g.gm - 1, g.gd).getDay() + 1) % 7;
    } catch (e) { return 0; }
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
  /* ماهی که تقویم با آن باز می‌شود: همین ماه اگر کاری داشته باشد،
     وگرنه آخرین ماهی که کاری در آن ثبت شده — تا خالی باز نشود. */
  function startView() {
    var t = today();
    var ks = pickedKeys();
    if (ks.length) { var q = ks[0].split("/"); return { jy: +q[0], jm: +q[1] }; }
    if (t && Object.keys(counts(t.jy, t.jm)).length) return { jy: t.jy, jm: t.jm };
    var all = rows().map(function (d) { return key(d && d.createdDate); }).filter(Boolean).sort();
    if (all.length) { var p = all[all.length - 1].split("/"); return { jy: +p[0], jm: +p[1] }; }
    return t ? { jy: t.jy, jm: t.jm } : { jy: 1405, jm: 1 };
  }

  function redraw() {
    try { renderDaily(); } catch (e) { }
    paintBar();
    if (pop && !pop.hidden) paintCal();
  }

  /* ---------- نوارِ بالای جدول ---------- */
  function bar() {
    var sec = document.getElementById("view-daily");
    if (!sec) return null;
    var b = sec.querySelector(".day-cal-bar");
    if (b) return b;
    /* کنارِ خروجی‌ها می‌نشیند. اگر ادمین خروجی‌ها را بسته باشد، آن
       کادر نیست و همین‌جا یک کادرِ خودمان می‌سازیم. */
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
    var ks = pickedKeys();
    var n = ks.length
      ? rows().filter(function (d) { return ks.indexOf(key(d && d.createdDate)) >= 0; }).length : 0;
    b.innerHTML =
      '<button type="button" class="btn btn-ghost btn-sm dcal-btn" id="dayCalBtn" ' +
        'title="تقویمِ برنامهٔ روزانه">🗓 تقویم</button>' +
      (ks.length
        ? '<span class="dcal-chip" id="dayCalChip">📅 ' +
          (ks.length === 1 ? faKey(ks[0]) : faN(ks.length) + ' روز') +
          ' <b>' + faN(n) + '</b> کار' +
          '<button type="button" title="نمایشِ همهٔ روزها" id="dayCalClear">✕</button></span>'
        : "");
    var btn = document.getElementById("dayCalBtn");
    if (btn) btn.addEventListener("click", function (e) { e.stopPropagation(); toggle(); });
    var clr = document.getElementById("dayCalClear");
    if (clr) clr.addEventListener("click", function () { setPicked([]); redraw(); });
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
      '<div class="dcal-note">روزی را بزنید تا کارهای همان روز را ببینید</div>' +
      '<div class="dcal-foot">' +
        '<button type="button" class="dcal-all">همهٔ روزها</button>' +
        '<button type="button" class="dcal-today">امروز</button>' +
      '</div>';
    document.body.appendChild(pop);

    pop.addEventListener("click", function (e) {
      var st = e.target.closest ? e.target.closest("[data-dcal-step]") : null;
      if (st) {
        view.jm += Number(st.getAttribute("data-dcal-step"));
        if (view.jm > 12) { view.jm = 1; view.jy++; }
        if (view.jm < 1) { view.jm = 12; view.jy--; }
        paintCal();
        return;
      }
      var d = e.target.closest ? e.target.closest("[data-dcal-day]") : null;
      if (d) {
        var k = view.jy + "/" + ("0" + view.jm).slice(-2) + "/" +
                ("0" + d.getAttribute("data-dcal-day")).slice(-2);
        /* با Ctrl/⌘ چند روز با هم؛ بی آن، همان یک روز. و زدنِ دوبارهٔ
           یک روزِ انتخاب‌شده، برش می‌دارد. */
        toggleDay(k, e.ctrlKey || e.metaKey);
        return;
      }
      if (e.target.closest(".dcal-all")) { setPicked([]); redraw(); return; }
      if (e.target.closest(".dcal-today")) {
        var t = today();
        if (!t) return;
        view = { jy: t.jy, jm: t.jm };
        var tk = t.jy + "/" + ("0" + t.jm).slice(-2) + "/" + ("0" + t.jd).slice(-2);
        /* اگر امروز کاری ندارد، فقط می‌رویم سرِ ماهِ امروز — وگرنه
           جدولِ خالی دستِ آدم می‌ماند. */
        if (rows().some(function (r) { return key(r && r.createdDate) === tk; })) toggleDay(tk, false);
        else paintCal();
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

  function toggleDay(k, many) {
    var cur = pickedKeys();
    var has = cur.indexOf(k) >= 0;
    var next;
    if (many) next = has ? cur.filter(function (x) { return x !== k; }) : cur.concat([k]);
    else next = has && cur.length === 1 ? [] : [k];
    setPicked(next.map(faKey));
    if (next.length) { var p = next[0].split("/"); view = { jy: +p[0], jm: +p[1] }; }
    redraw();
  }

  function paintCal() {
    if (!pop) return;
    var t = today();
    var c = counts(view.jy, view.jm);
    var on = pickedKeys();
    var pad = weekStart(view.jy, view.jm);
    var len = monthLen(view.jy, view.jm);
    var html = "";
    for (var i = 0; i < pad; i++) html += '<span class="dcal-pad"></span>';
    for (var d = 1; d <= len; d++) {
      var k = view.jy + "/" + ("0" + view.jm).slice(-2) + "/" + ("0" + d).slice(-2);
      var n = c[d] || 0;
      var cls = "dcal-d" + (n ? " has" : "") + (on.indexOf(k) >= 0 ? " on" : "") +
        (t && t.jy === view.jy && t.jm === view.jm && t.jd === d ? " now" : "");
      /* روزی که کاری ندارد زدنی نیست: زدنش یک جدولِ خالی می‌داد و آدم
         خیال می‌کرد چیزی خراب شده. */
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
    var w = pop.offsetWidth || 272, h = pop.offsetHeight || 320;
    var left = Math.min(Math.max(8, r.left - (w - r.width) / 2), innerWidth - w - 8);
    var top = r.bottom + 6;
    if (top + h > innerHeight - 8) top = Math.max(8, r.top - h - 6);
    pop.style.left = left + "px";
    pop.style.top = top + "px";
  }

  function toggle() { if (pop && !pop.hidden) close(); else open(); }
  function open() {
    build();
    view = startView();
    pop.hidden = false;
    paintCal();
    place();
  }
  function close() { if (pop) pop.hidden = true; }

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
      toggleDay(k, e.ctrlKey || e.metaKey);
    });
  }

  function boot() { paintBar(); wireCells(); }

  window.DAYCAL = { open: open, close: close, refresh: boot, key: key, pick: toggleDay };

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot);
  else boot();
  /* ردیف‌ها و دکمه‌ها بعد از ورود ساخته می‌شوند؛ دو تکانِ بعدی تا
     دکمهٔ تقویم جا بیفتد. */
  setTimeout(boot, 1200);
  setTimeout(boot, 3000);
})();
