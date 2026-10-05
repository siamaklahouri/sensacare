/* بخش‌هایی که کارتابل‌های دیگر با گروهِ ما به اشتراک گذاشته‌اند
   =================================================================
   این‌جا جدولی نیست که ادمین از صفر ساخته باشد (آن کارِ /shared.js
   است). این‌ها بخشِ خودِ کارتابلِ یک نفرِ دیگرند — «سرورها و بکاپ»ِ
   سیامک، «حساب‌های بانکی»ِ سینا — که ادمین با گروهی که ما عضوش
   هستیم به اشتراک گذاشته.

   دادهٔ جداگانه‌ای ندارند: هر خواندن و نوشتن روی همان کلیدِ کارتابلِ
   مالک می‌نشیند. پس آن‌چه ما این‌جا می‌نویسیم، مالک در صفحهٔ خودش
   می‌بیند — نه یک رونوشت که از فردا با آن درمی‌رود.

   چون ردیف‌ها شناسهٔ ثابتی ندارند و با شمارهٔ جایشان شناخته می‌شوند،
   هر نوشتن `rev` همان خواندنِ آخر را با خودش می‌برد. اگر مالک وسطش
   ردیفی کم یا زیاد کرده باشد، سرور رد می‌کند و ما از نو می‌خوانیم —
   نه اینکه ردیفِ اشتباهی عوض شود.

   اسکریپتِ معمولی است نه ماژول، تا به apiCall و KARTABL_API که در
   خودِ صفحه‌اند برسد — همان قاعدهٔ /shared.js. */
(function () {
  "use strict";

  var SHARES = [];     /* تعریفِ بخش‌ها، از سرور */
  var ST = {};         /* id → { rows, rev, open, timer, busy } */
  var POLL_MS = 10000;

  var esc = function (t) {
    return String(t == null ? "" : t)
      .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
  };
  var fa = function (n) { return String(n).replace(/[0-9]/g, function (d) { return "۰۱۲۳۴۵۶۷۸۹"[d]; }); };
  var money = function (n) {
    if (n === "" || n == null) return "";
    var x = Number(n);
    return isFinite(x) ? fa(x.toLocaleString("en-US")) : esc(n);
  };
  /* رقمِ فارسی که کاربر تایپ می‌کند، پیش از رفتن به سرور لاتین می‌شود.
     سرور هم همین کار را می‌کند، ولی این‌جا هم لازم است تا آن‌چه بعدِ
     ذخیره نشان داده می‌شود همان باشد که ذخیره شد. */
  var enNum = function (v) {
    return String(v == null ? "" : v)
      .replace(/[۰-۹]/g, function (c) { return String(c.charCodeAt(0) - 0x06F0); })
      .replace(/[٠-٩]/g, function (c) { return String(c.charCodeAt(0) - 0x0660); });
  };

  var CSS = [
    ".vs-sub{font-size:12.5px;color:var(--ink-soft,#5b6672);margin-bottom:10px;line-height:1.9}",
    ".vs-own{font-weight:600;color:var(--ink,#22303c)}",
    ".vs-bar{display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:10px}",
    ".vs-note{font-size:11.5px;color:var(--ink-faint,#8c97a3);min-height:16px}",
    ".vs-note.bad{color:var(--red,#B3261E)}",
    ".vs-addbar{margin-top:10px;display:flex;justify-content:flex-start}",
    "td.vs-c[contenteditable=\"true\"]{cursor:text}",
    "tr.vs-ok>td{animation:vsOk .9s ease}",
    "@keyframes vsOk{0%{background:rgba(47,107,79,.18)}100%{background:transparent}}",
    "tr.vs-bad>td{animation:vsBad 1.4s ease}",
    "@keyframes vsBad{0%{background:rgba(179,38,30,.2)}100%{background:transparent}}"
  ].join("\n");

  function addCss() {
    if (document.getElementById("vshareCss")) return;
    var st = document.createElement("style");
    st.id = "vshareCss"; st.textContent = CSS;
    document.head.appendChild(st);
  }

  function st(id) {
    if (!ST[id]) ST[id] = { rows: [], rev: -1, open: false, timer: 0, edit: false };
    return ST[id];
  }
  var byId = function (id) { return SHARES.find(function (s) { return s.id === id; }); };

  /* ---------- ساختِ نما و دکمهٔ نوار ----------
     سرفصلِ گروه همان سرفصلی است که /shared.js می‌سازد (data-shorg)؛
     اگر هم بخشِ مشترک و هم بخشِ اشتراکی به یک گروه وصل باشند، زیرِ
     یک نام جمع می‌شوند نه دو تا سرفصلِ هم‌نام. */
  function mount(sh) {
    var vid = "view-vshare-" + sh.id;
    if (document.getElementById(vid)) return;

    var nav = document.querySelector(".nav-list");
    var host = document.querySelector(".content");
    if (!nav || !host) return;

    var btn = document.createElement("button");
    btn.className = "navbtn";
    btn.setAttribute("data-view", "vshare-" + sh.id);
    btn.innerHTML = '<span class="ic">' + esc(sh.icon) + "</span> " + esc(sh.label) +
                    ' <span style="opacity:.65">— ' + esc(sh.ownerName) + "</span>";

    var before = nav.querySelector('.navbtn[data-view="guide"]')
              || nav.querySelector('.navbtn[data-view="settings"]');

    var key = "org-" + sh.org;
    var head = nav.querySelector('[data-shorg="' + key + '"]');
    if (!head) {
      head = document.createElement("div");
      head.className = "sh-org";
      head.setAttribute("data-shorg", key);
      head.textContent = sh.orgPath || "گروه";
      head.title = sh.orgPath || "";
      nav.insertBefore(head, before || null);
    }
    /* تهِ همان گروه، بعد از هر چه الان زیرش هست */
    btn.classList.add("sh-ingroup");
    var cur = head;
    while (cur.nextElementSibling && cur.nextElementSibling.classList.contains("navbtn"))
      cur = cur.nextElementSibling;
    nav.insertBefore(btn, cur.nextSibling);

    var sec = document.createElement("section");
    sec.className = "view"; sec.id = vid;
    sec.innerHTML =
      '<div class="section-title">' + esc(sh.icon) + " " + esc(sh.label) + "</div>" +
      '<div class="vs-sub">این بخشِ کارتابلِ <span class="vs-own">' + esc(sh.ownerName) +
        "</span> است و از راهِ گروهِ «" + esc(sh.orgPath || "") + "» با شما به اشتراک گذاشته شده" +
        (sh.w ? " — می‌توانید تغییرش بدهید." : " — فقط می‌توانید ببینید.") +
        "<br>هر تغییری که این‌جا بدهید، در کارتابلِ خودِ " + esc(sh.ownerName) +
        " هم همان است؛ رونوشت نیست.</div>" +
      '<div class="panel">' +
        '<div class="vs-bar">' +
          (sh.w
            ? '<label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">' +
                '<span class="edit-switch"><input type="checkbox" data-vsedit="' + esc(sh.id) +
                '"><span class="track"></span></span> حذف/تغییر</label>'
            : "") +
          '<span class="vs-note" data-vsnote="' + esc(sh.id) + '"></span>' +
        "</div>" +
        '<div class="tbl-wrap"><table><thead><tr>' +
          '<th style="width:26px;">#</th>' +
          sh.cols.map(function (c) { return "<th>" + esc(c.t) + "</th>"; }).join("") +
          (sh.w ? '<th style="width:48px;"></th>' : "") +
        "</tr></thead>" +
        '<tbody data-vsbody="' + esc(sh.id) + '"></tbody></table></div>' +
        (sh.w ? '<div class="vs-addbar"><button class="btn btn-brass btn-sm" data-vsadd="' +
                esc(sh.id) + '">＋ ردیف تازه</button></div>' : "") +
      "</div>";
    host.appendChild(sec);

    btn.addEventListener("click", function () {
      document.querySelectorAll(".navbtn").forEach(function (b) { b.classList.remove("active"); });
      btn.classList.add("active");
      document.querySelectorAll(".view").forEach(function (v) { v.classList.remove("active"); });
      sec.classList.add("active");
      SHARES.forEach(function (x) { if (x.id !== sh.id) stopPoll(x.id); });
      st(sh.id).open = true;
      pull(sh.id);
      startPoll(sh.id);
    });

    var tog = sec.querySelector("[data-vsedit]");
    if (tog) tog.addEventListener("change", function () {
      st(sh.id).edit = !!tog.checked;
      paint(sh.id);
    });
    var add = sec.querySelector("[data-vsadd]");
    if (add) add.addEventListener("click", function () { addRow(sh.id); });
  }

  function note(id, t, bad) {
    var el = document.querySelector('[data-vsnote="' + id + '"]');
    if (!el) return;
    el.textContent = t || "";
    el.classList.toggle("bad", !!bad);
    if (t) setTimeout(function () {
      if (el.textContent === t) { el.textContent = ""; el.classList.remove("bad"); }
    }, 6000);
  }

  /* ---------- خواندن ---------- */
  async function pull(id, quiet) {
    var sh = byId(id); if (!sh) return;
    var s = st(id);
    if (s.busy) return;
    s.busy = true;
    try {
      var r = await apiCall("/vshare/" + id);
      if (!r.ok) { if (!quiet) note(id, "خوانده نشد. کمی بعد دوباره.", true); return; }
      s.rows = Array.isArray(r.data.rows) ? r.data.rows : [];
      s.rev = Number(r.data.rev) || 0;
      /* اجازهٔ نوشتن را هر بار سرور می‌گوید: اگر ادمین همین حالا
         پسش گرفته باشد، دکمه‌ها همان لحظه می‌روند. */
      if (typeof r.data.w === "boolean" && r.data.w !== sh.w) {
        sh.w = r.data.w;
        if (!sh.w) s.edit = false;
      }
      paint(id);
    } catch (e) { if (!quiet) note(id, "خوانده نشد.", true); }
    finally { s.busy = false; }
  }

  function startPoll(id) {
    stopPoll(id);
    st(id).timer = setInterval(function () {
      /* وقتی کاربر دستش روی خانه‌ای است، جدول از زیرِ دستش کشیده
         نمی‌شود: نوشتهٔ نیمه‌تمامش می‌پرید. */
      var a = document.activeElement;
      if (a && a.closest && a.closest('[data-vsbody="' + id + '"]')) return;
      pull(id, true);
    }, POLL_MS);
  }
  function stopPoll(id) {
    var s = st(id);
    if (s.timer) { clearInterval(s.timer); s.timer = 0; }
    s.open = false;
  }

  /* ---------- کشیدنِ جدول ---------- */
  function cellHtml(sh, c, v, open) {
    if (c.kind === "pick") {
      var opts = ['<option value=""' + (v === "" || v == null ? " selected" : "") + ">—</option>"]
        .concat((c.opts || []).map(function (o) {
          return '<option value="' + esc(o) + '"' + (String(v) === o ? " selected" : "") + ">" + esc(o) + "</option>";
        })).join("");
      return '<td><select class="vs-s" data-k="' + esc(c.k) + '"' + (open ? "" : " disabled") + ">" +
             opts + "</select></td>";
    }
    var shown = c.kind === "money" ? money(v) : (c.kind === "num" ? (v === "" || v == null ? "" : fa(v)) : esc(v == null ? "" : v));
    var able = open && c.edit !== "never";
    return '<td class="editable-cell vs-c" data-k="' + esc(c.k) + '" contenteditable="' +
           (able ? "true" : "false") + '" style="opacity:' + (able ? "1" : "0.85") + ';">' +
           shown + "</td>";
  }

  function paint(id) {
    var sh = byId(id); if (!sh) return;
    var body = document.querySelector('[data-vsbody="' + id + '"]');
    if (!body) return;
    var s = st(id);
    var open = !!(sh.w && s.edit);

    var span = sh.cols.length + (sh.w ? 2 : 1);
    body.innerHTML = s.rows.map(function (r, i) {
      return '<tr data-ix="' + i + '"><td>' + fa(i + 1) + "</td>" +
        sh.cols.map(function (c) { return cellHtml(sh, c, r[c.k], open); }).join("") +
        (sh.w ? '<td><button class="btn-del" data-vsdel="' + i + '"' +
                (open ? "" : " disabled") + ' title="حذف">✕</button></td>' : "") +
        "</tr>";
    }).join("") ||
      '<tr><td colspan="' + span + '" style="color:var(--ink-faint);">هنوز ردیفی ندارد.</td></tr>';

    body.querySelectorAll("td.vs-c[contenteditable=\"true\"]").forEach(function (td) {
      td.addEventListener("blur", function () { commit(id, td); });
      /* Enter یعنی «تمام شد»، نه یک خطِ تازه داخلِ خانه */
      td.addEventListener("keydown", function (e) {
        if (e.key === "Enter") { e.preventDefault(); td.blur(); }
        if (e.key === "Escape") { td.dataset.vsCancel = "1"; td.blur(); }
      });
    });
    body.querySelectorAll("select.vs-s:not([disabled])").forEach(function (sl) {
      sl.addEventListener("change", function () { commit(id, sl); });
    });
    body.querySelectorAll("[data-vsdel]:not([disabled])").forEach(function (b) {
      b.addEventListener("click", function () {
        if (!confirm("این ردیف از کارتابلِ " + sh.ownerName + " حذف شود؟")) return;
        kill(id, Number(b.getAttribute("data-vsdel")));
      });
    });
    if (window.tableSizeSweep) try { window.tableSizeSweep(); } catch (e) { /* بی‌خیال */ }
    if (window.cellPopScan) try { window.cellPopScan(); } catch (e) { /* بی‌خیال */ }
  }

  function flash(id, ix, ok) {
    var tr = document.querySelector('[data-vsbody="' + id + '"] tr[data-ix="' + ix + '"]');
    if (!tr) return;
    tr.classList.remove("vs-ok", "vs-bad");
    void tr.offsetWidth;
    tr.classList.add(ok ? "vs-ok" : "vs-bad");
  }

  /* ---------- نوشتن ----------
     هر نوشتن `baseRev` را با خودش می‌برد. اگر سرور بگوید جا عوض شده،
     از نو می‌خوانیم و به کاربر می‌گوییم — نه اینکه بی‌صدا روی ردیفِ
     بعدی بنویسیم. */
  async function send(id, path, payload) {
    var s = st(id);
    var r = await apiCall("/vshare/" + id + path, {
      method: "POST",
      body: JSON.stringify(Object.assign({ baseRev: s.rev }, payload))
    });
    if (r.ok) {
      s.rows = Array.isArray(r.data.rows) ? r.data.rows : s.rows;
      s.rev = Number(r.data.rev) || s.rev;
      return { ok: true };
    }
    if (r.status === 409 && r.data && r.data.conflict) {
      await pull(id, true);
      note(id, "همین حالا یک نفر دیگر این جدول را عوض کرد. جدول تازه شد — دوباره امتحان کنید.", true);
      return { ok: false, stale: true };
    }
    note(id, (r.data && r.data.error) || "ذخیره نشد.", true);
    return { ok: false };
  }

  async function commit(id, el) {
    var sh = byId(id); if (!sh) return;
    var tr = el.closest("tr"); if (!tr) return;
    if (el.dataset && el.dataset.vsCancel) { delete el.dataset.vsCancel; paint(id); return; }
    var ix = Number(tr.getAttribute("data-ix"));
    var k = el.getAttribute("data-k");
    var col = sh.cols.find(function (c) { return c.k === k; });
    if (!col) return;
    var raw = el.tagName === "SELECT" ? el.value : el.textContent;
    var val = (col.kind === "num" || col.kind === "money") ? enNum(raw).replace(/[,\s]/g, "") : String(raw).trim();

    var s = st(id);
    var was = s.rows[ix] ? s.rows[ix][k] : "";
    if (String(was == null ? "" : was) === String(val)) return;

    var r = await send(id, "/cell", { ix: ix, k: k, v: val });
    if (r.stale) return;
    paint(id);
    flash(id, ix, r.ok);
    if (r.ok) note(id, "ذخیره شد.");
  }

  async function kill(id, ix) {
    var r = await send(id, "/del", { ix: ix });
    if (r.stale) return;
    paint(id);
    if (r.ok) note(id, "ردیف حذف شد.");
  }

  /* ردیفِ تازه خالی اضافه می‌شود و بعد پر می‌شود. فرمِ جدا لازم نبود:
     خانه‌های همان ردیف از قبل قابلِ نوشتن‌اند. */
  async function addRow(id) {
    var s = st(id);
    if (!s.edit) { note(id, "اول «حذف/تغییر» را روشن کنید.", true); return; }
    var r = await send(id, "/row", { v: {} });
    if (r.stale) return;
    paint(id);
    if (!r.ok) return;
    note(id, "ردیف اضافه شد — خانه‌هایش را پر کنید.");
    var tr = document.querySelector('[data-vsbody="' + id + '"] tr[data-ix="' + (s.rows.length - 1) + '"]');
    if (tr) {
      var first = tr.querySelector('td.vs-c[contenteditable="true"]');
      if (first) first.focus();
      try { tr.scrollIntoView({ block: "nearest" }); } catch (e) { /* بی‌خیال */ }
    }
  }

  /* ---------- راه‌انداز ---------- */
  window.initViewShares = async function () {
    try {
      var r = await apiCall("/vshare");
      if (!r.ok || !r.data || !Array.isArray(r.data.shares)) return;
      SHARES = r.data.shares.filter(function (s) { return s && s.id && Array.isArray(s.cols); });
      if (!SHARES.length) return;
      addCss();
      SHARES.forEach(mount);
    } catch (e) { /* اگر نیامد، کارتابل بدون این بخش‌ها کار می‌کند */ }
  };
})();
