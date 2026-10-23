/* ==================== جست‌وجوی سراسری ====================
   هر جدول پالایهٔ ستونیِ خودش را داشت، ولی هیچ راهی نبود که بپرسی
   «آن کارِ مربوط به فلان شرکت کجا بود؟» و بین ماه‌ها بگردد. با
   بایگانیِ یک‌ساله، این دیگر یک راحتی نیست.

   چه چیزی گشته می‌شود: چک‌لیست و برنامهٔ روزانهٔ *همهٔ* ماه‌ها (نه فقط
   ماهِ باز)، به‌علاوهٔ جدول‌های غیرماهانه‌ای که هر قالب در
   SEARCH_MAP معرفی می‌کند.

   چه چیزی گشته نمی‌شود: دیتای شخصی. رمزش دستِ خودِ کاربر است و حتی
   وقتی باز است، فهرستِ نتایج جای نشان دادنِ رمزِ یک شرکت نیست. این
   عمدی است، نه از قلم افتاده.

   زدنِ هر نتیجه، اگر لازم باشد اول ماه را عوض می‌کند، بعد بخش را باز
   می‌کند و همان ردیف را یک لحظه روشن نگه می‌دارد. */
(function () {
  "use strict";

  /* «می‌شود» و «ميشود» و «مي‌شود» باید یکی حساب شوند، وگرنه کاربر
     چیزی را که خودش نوشته پیدا نمی‌کند. ارقام هم یکدست می‌شوند. */
  function norm(s) {
    var t = String(s == null ? "" : s);
    try { t = faToEn(t); } catch (e) { }
    return t.replace(/[‌‏‎]/g, "")
      /* اعراب هم برداشته می‌شود: در خودِ این کارتابل «بررسیِ» با کسره
         نوشته می‌شود و کسی که «بررسی» را می‌گردد باید پیدایش کند. */
      .replace(/[\u064B-\u0652\u0670]/g, "")
      .replace(/[يى]/g, "ی").replace(/ك/g, "ک")
      .replace(/\s+/g, " ")
      .trim().toLowerCase();
  }

  var SKIP = { id: 1, idx: 1, day: 1, rev: 1, repeat: 1, reminderFired: 1,
               rid: 1, since: 1, every: 1, fid: 1 };

  var FILES = [];              /* نام پیوست‌ها، یک بار از سرور */
  async function loadFiles() {
    try {
      var r = await apiCall("/files?names=1");
      if (r.ok) FILES = (r.data && r.data.items) || [];
    } catch (e) { }
  }

  function faDate(k) {
    try { return fa(String(k)); } catch (e) { return String(k); }
  }

  /* پیوست به شناسهٔ ردیف بسته است، نه به شمارهٔ ردیف. پس باید در
     همهٔ ماه‌ها دنبالِ ردیفی گشت که آن شناسه را دارد. */
  function rowOfRef(ref) {
    var found = null;
    monthly().forEach(function (m) {
      if (found) return;
      m.tasks.forEach(function (t, i) {
        if (!found && t && t.fid === ref)
          found = { view: "checklist", body: "checklistBody", idx: i,
                    month: m.key, monthLabel: m.label, title: titleOf(t, "task") };
      });
      m.days.forEach(function (d, i) {
        if (!found && d && d.fid === ref)
          found = { view: "daily", body: "dailyBody", idx: i,
                    month: m.key, monthLabel: m.label, title: titleOf(d, "main") };
      });
    });
    return found;
  }

  function rowText(row) {
    if (!row || typeof row !== "object") return "";
    var out = [];
    Object.keys(row).forEach(function (k) {
      if (SKIP[k]) return;
      var v = row[k];
      if (v == null) return;
      if (typeof v === "string" || typeof v === "number") out.push(String(v));
    });
    return out.join(" • ");
  }

  function titleOf(row, field) {
    if (field && row[field]) return String(row[field]);
    var keys = Object.keys(row);
    for (var i = 0; i < keys.length; i++) {
      var v = row[keys[i]];
      if (typeof v === "string" && v.trim() && !SKIP[keys[i]]) return v;
    }
    return "—";
  }

  /* ---------- جمع کردنِ همهٔ جاهایی که گشته می‌شوند ---------- */
  function monthly() {
    var out = [];
    var snap = {};
    try { snap = allMonthsSnapshot() || {}; } catch (e) { }
    Object.keys(snap).forEach(function (key) {
      var m = snap[key] || {};
      out.push({ key: key, label: monthLabelOf(key), tasks: m.tasks || [], days: m.days || [] });
    });
    return out;
  }

  function dbRows() {
    var map = window.SEARCH_MAP || [];
    var snap = {};
    try { snap = dbSnapshot() || {}; } catch (e) { }
    return map.map(function (m) {
      var raw = snap[m.key];
      var rows = Array.isArray(raw) ? raw
        : (raw && typeof raw === "object" ? Object.keys(raw).map(function (k) {
            var r = raw[k];
            return (r && typeof r === "object") ? Object.assign({ نام: k }, r) : { نام: k, مقدار: r };
          }) : []);
      return Object.assign({}, m, { rows: rows });
    });
  }

  function search(q) {
    var n = norm(q);
    if (n.length < 2) return [];
    var hits = [];
    var push = function (h) { if (hits.length < 60) hits.push(h); };

    monthly().forEach(function (m) {
      m.tasks.forEach(function (t, i) {
        var txt = rowText(t);
        if (norm(txt).indexOf(n) >= 0)
          push({ where: "چک‌لیست ماهانه", month: m.key, monthLabel: m.label, view: "checklist",
                 body: "checklistBody", idx: i, title: titleOf(t, "task"), text: txt });
      });
      m.days.forEach(function (d, i) {
        var txt = rowText(d);
        if (norm(txt).indexOf(n) >= 0)
          push({ where: "برنامهٔ روزانه", month: m.key, monthLabel: m.label, view: "daily",
                 body: "dailyBody", idx: i, title: titleOf(d, "main"), text: txt });
      });
    });

    /* یادداشت‌های تقویم: از همان state می‌آیند و زدنشان همان روز را
       در بخشِ تقویم باز می‌کند. */
    var notes = {};
    try { notes = (state.calNotes && typeof state.calNotes === "object") ? state.calNotes : {}; }
    catch (e) { notes = {}; }
    Object.keys(notes).forEach(function (k) {
      var txt = String(notes[k] || "");
      if (!txt || norm(txt).indexOf(n) < 0) return;
      push({ where: "یادداشتِ تقویم", view: "cal", calDay: k,
             title: faDate(k), text: txt });
    });

    /* نامِ پیوست‌ها. فهرست یک بار از سرور گرفته می‌شود و در حافظه
       می‌ماند؛ خودِ فایل‌ها جابه‌جا نمی‌شوند. */
    FILES.forEach(function (f) {
      if (norm(f.name || "").indexOf(n) < 0) return;
      var at = rowOfRef(f.ref);
      push({ where: "پیوست", view: at ? at.view : "checklist",
             body: at ? at.body : "", idx: at ? at.idx : -1,
             month: at ? at.month : "", monthLabel: at ? at.monthLabel : "",
             title: f.name, text: at ? at.title : "" });
    });

    dbRows().forEach(function (src) {
      src.rows.forEach(function (r, i) {
        var txt = rowText(r);
        if (norm(txt).indexOf(n) >= 0)
          push({ where: src.label, view: src.view, body: src.body, idx: i,
                 title: titleOf(r, src.title), text: txt });
      });
    });
    return hits;
  }

  /* ---------- رفتن سرِ نتیجه ---------- */
  function jump(h) {
    close();
    /* یادداشتِ تقویم: بخشِ تقویم، همان ماه، همان روز */
    if (h.calDay) {
      try {
        var q = String(h.calDay).split("/");
        var nav2 = document.querySelector('.navbtn[data-view="cal"]');
        if (nav2) nav2.click();
        if (window.CAL && CAL.go) { /* فقط برای اطمینان از ساخته شدن */ }
        setTimeout(function () {
          try {
            CAL.show(+q[0], +q[1], +q[2]);
          } catch (e) { }
        }, 120);
      } catch (e) { }
      return;
    }
    var go = function () {
      var nav = document.querySelector('.nav-list .navbtn[data-view="' + h.view + '"]');
      if (nav) nav.click();
      setTimeout(function () { flash(h); }, 260);
    };
    /* نتیجه‌ای که در ماهِ دیگری است، اول ماه را عوض می‌کند. */
    if (h.month && h.month !== state.currentMonthKey) {
      var p = String(h.month).split("|");
      try { switchToMonth(p[1] || "", p[0] || ""); } catch (e) { }
      setTimeout(go, 120);
    } else go();
  }

  function flash(h) {
    if (!h.body) return;
    var tr = document.querySelector("#" + h.body + ' tr[data-idx="' + h.idx + '"]');
    if (!tr) return;
    try { tr.scrollIntoView({ behavior: "smooth", block: "center" }); } catch (e) { }
    tr.classList.add("find-hit");
    setTimeout(function () { tr.classList.remove("find-hit"); }, 2200);
  }

  /* ---------- خودِ کشو ---------- */
  var box = null, input = null, list = null, rows = [], sel = 0;

  function build() {
    if (box) return;
    box = document.createElement("div");
    box.className = "findbox";
    box.id = "findBox";
    box.hidden = true;
    box.innerHTML = '<div class="find-card" role="dialog" aria-label="جست‌وجو">' +
      '<div class="find-head">' +
      '<input type="search" id="findInput" placeholder="بگرد… نامِ کار، شرکت، سرور، یادداشت" autocomplete="off">' +
      '<button type="button" class="find-x" id="findX" title="بستن">✕</button></div>' +
      '<div class="find-list" id="findList"></div>' +
      '<div class="find-foot">بینِ همهٔ ماه‌ها می‌گردد. دیتای شخصی گشته نمی‌شود.</div></div>';
    document.body.appendChild(box);
    input = box.querySelector("#findInput");
    list = box.querySelector("#findList");
    box.querySelector("#findX").addEventListener("click", close);
    box.addEventListener("click", function (e) { if (e.target === box) close(); });
    input.addEventListener("input", paint);
    input.addEventListener("keydown", function (e) {
      if (e.key === "ArrowDown") { e.preventDefault(); move(1); }
      else if (e.key === "ArrowUp") { e.preventDefault(); move(-1); }
      else if (e.key === "Enter") { e.preventDefault(); if (rows[sel]) jump(rows[sel]); }
    });
    list.addEventListener("click", function (e) {
      var el = e.target.closest ? e.target.closest(".find-row") : null;
      if (el) jump(rows[parseInt(el.getAttribute("data-i"), 10)]);
    });
  }

  function move(d) {
    if (!rows.length) return;
    sel = (sel + d + rows.length) % rows.length;
    paintSel();
  }
  function paintSel() {
    [].slice.call(list.querySelectorAll(".find-row")).forEach(function (el, i) {
      el.classList.toggle("on", i === sel);
      if (i === sel) try { el.scrollIntoView({ block: "nearest" }); } catch (e) { }
    });
  }

  function paint() {
    var q = input.value || "";
    rows = search(q);
    sel = 0;
    if (norm(q).length < 2) {
      list.innerHTML = '<div class="find-empty">دستِ‌کم دو حرف بنویسید.</div>';
      return;
    }
    if (!rows.length) {
      list.innerHTML = '<div class="find-empty">چیزی پیدا نشد.</div>';
      return;
    }
    list.innerHTML = rows.map(function (h, i) {
      var tag = h.monthLabel ? h.where + " — " + h.monthLabel : h.where;
      return '<button type="button" class="find-row' + (i === 0 ? " on" : "") + '" data-i="' + i + '">' +
        '<span class="fr-t">' + escapeHtml(h.title) + '</span>' +
        '<span class="fr-w">' + escapeHtml(tag) + '</span>' +
        '<span class="fr-x">' + escapeHtml(h.text.slice(0, 120)) + '</span></button>';
    }).join("");
  }

  function open() {
    build();
    box.hidden = false;
    document.documentElement.classList.add("find-open");
    input.value = "";
    paint();
    setTimeout(function () { try { input.focus(); } catch (e) { } }, 30);
  }
  function close() {
    if (!box) return;
    box.hidden = true;
    document.documentElement.classList.remove("find-open");
  }

  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape" && box && !box.hidden) { close(); return; }
    /* Ctrl+K همان میان‌بُری است که آدم از بقیهٔ برنامه‌ها عادت دارد */
    if ((e.ctrlKey || e.metaKey) && (e.key === "k" || e.key === "K")) {
      e.preventDefault();
      if (box && !box.hidden) close(); else openPlus();
    }
  });

  function setup() {
    var btn = document.getElementById("findBtn");
    if (btn) btn.addEventListener("click", openPlus);
  }
  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", setup);
  else setup();

  /* فهرستِ نام‌ها را همان بارِ اولِ باز شدنِ جست‌وجو می‌گیریم: نه سرِ
     بارِ صفحه (که یک درخواستِ اضافه بود)، نه هر بار. */
  var filesOnce = false;
  function openPlus() {
    if (!filesOnce) { filesOnce = true; loadFiles(); }
    open();
  }

  window.FIND = { open: openPlus, close: close, search: search,
                  files: function () { return FILES; }, reload: loadFiles };
})();
