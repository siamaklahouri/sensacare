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
    /* نامِ صاحبِ بخش روی دکمهٔ نوار: کم‌رنگ و در خطِ دوم، تا نامِ خودِ
       بخش همان‌قدر خوانا بماند که بقیهٔ دکمه‌ها. */
    ".navbtn .vs-who{display:block;font-size:10px;font-weight:400;opacity:.55;",
    "  margin-top:1px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}",
    /* متنِ دکمه ستونی می‌شود تا نامِ بخش و نامِ صاحبش زیرِ هم بنشینند،
       نه کنارِ هم: با نامِ بلند، «سیامک» وسطِ عنوان می‌افتاد. */
    ".navbtn[data-view^=\"vshare-\"]{align-items:flex-start}",
    ".navbtn[data-view^=\"vshare-\"] .ic{margin-top:1px}",
    ".navbtn .vs-t{display:flex;flex-direction:column;min-width:0;flex:1 1 auto}",

    /* سرفصلِ گروه و ریلِ زیرش.

       این‌ها را تا دیروز /shared.js می‌ساخت، و آن فایل فقط وقتی بار
       می‌شود که بخشِ مشترکِ ادمین‌ساخته‌ای هم باشد. کسی که فقط بخشِ
       اشتراکیِ یک کارتابلِ دیگر را داشت، سرفصل را بی‌شیوه‌نامه
       می‌دید: یک متنِ درشتِ ۱۶ پیکسلی وسطِ نوار، بزرگ‌تر از خودِ
       دکمه‌ها. همان چیزی که گزارش شد «توی منو قشنگ نیست».

       تعریفشان با /shared.js یکی است، پس هر کدام که زودتر بنشیند
       فرقی نمی‌کند. */
    ".sh-org{font-size:10.5px;font-weight:700;letter-spacing:.02em;color:var(--ink-faint,#8c97a3);",
    "  padding:6px 12px 5px;margin:14px 0 2px;",
    "  display:flex;align-items:center;gap:7px;",
    "  white-space:nowrap;overflow:hidden;text-overflow:ellipsis}",
    ".sh-org::before{content:\"\";width:4px;height:4px;border-radius:50%;flex:none;",
    "  background:var(--brass,#1A4FA3);opacity:.7}",
    ".navbtn.sh-ingroup{width:calc(100% - 9px);margin-inline-start:9px;padding-inline-start:13px;",
    "  border-inline-start:1px solid var(--card-border,rgba(11,37,69,.10));",
    "  border-radius:0 11px 11px 0}",
    ".navbtn.sh-ingroup.active{border-inline-start-color:var(--brass,#B08D57)}",
    ".vs-note{font-size:11.5px;color:var(--ink-faint,#8c97a3)}",

    /* نوارِ بالای جدول: جستجو، انتخابِ ستون‌ها، و شمارِ ردیف‌ها.

       بخشی که به اشتراک می‌رسد ابزارهای خودِ کارتابل را ندارد —
       نه مرتب‌سازی، نه پالایه. و بعضی از این جدول‌ها ده ستون دارند.
       این سه چیز کمینه‌ای است که «دیدنِ» یک جدولِ بیگانه را ممکن
       می‌کند. */
    ".vs-tools{display:flex;flex-wrap:wrap;align-items:center;gap:8px;margin:0 0 10px}",
    ".vs-find{flex:1 1 200px;min-width:0;max-width:320px;font-family:inherit;font-size:12.5px;",
    "  padding:7px 11px;border:1.5px solid var(--card-border,rgba(11,37,69,.12));",
    "  border-radius:10px;background:var(--paper,#f6f7f9);color:var(--ink,#0b2545)}",
    ".vs-find:focus-visible{outline:2px solid var(--brass,#B08D57);outline-offset:1px}",
    ".vs-colbtn.on{background:var(--brass-bg,rgba(176,141,87,.14))}",
    ".vs-count{font-size:11.5px;color:var(--ink-faint,#8c97a3);margin-inline-start:auto}",
    ".vs-cols{display:flex;flex-wrap:wrap;gap:6px;margin:0 0 10px}",
    ".vs-cols[hidden]{display:none}",
    ".vs-col{font-family:inherit;font-size:11.5px;padding:4px 11px;border-radius:999px;",
    "  border:1px solid var(--card-border,rgba(11,37,69,.12));cursor:pointer;",
    "  background:var(--white,#fff);color:var(--ink-faint,#8c97a3)}",
    ".vs-col.on{background:var(--brass,#B08D57);border-color:transparent;color:#fff;font-weight:700}",
    ".vs-note.bad{color:var(--red,#B3261E)}",
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


  /* کجای نوار بنشیند. تا حالا «پیش از راهنما» بود، که یعنی زیرِ همهٔ
     دکمه‌های ابزاری (دیتای شخصی، تبدیل، گزارش‌ساز، دستیار) — ته فهرست،
     جایی که چشم آخر از همه می‌رسد. حالا بالاتر می‌نشیند: بلافاصله بعد
     از بخش‌های دادهٔ خودِ کاربر و پیش از ابزارها.
     فهرست مرتب است و اولینی که پیدا شود جوابِ درست است؛ اگر ادمین
     بعضی‌شان را بسته باشد، همان بعدی. */
  var TOOL_VIEWS = ["personal", "datetools", "report", "veeam", "assistant", "guide", "settings"];
  /* دکمه‌ای که زیرِ سرفصلِ یک گروه نشسته — چه بخشِ مشترک باشد چه
     بخشِ اشتراکیِ کارتابلِ دیگری. هر دو زیرِ یک سرفصل جمع می‌شوند. */
  function inGroup(el) {
    if (!el || !el.classList || !el.classList.contains("navbtn")) return false;
    var v = String(el.getAttribute("data-view") || "");
    return v.indexOf("vshare-") === 0 || v.indexOf("shared-") === 0;
  }

  function navAnchor(nav) {
    for (var i = 0; i < TOOL_VIEWS.length; i++) {
      var b = nav.querySelector('.navbtn[data-view="' + TOOL_VIEWS[i] + '"]');
      if (b) return b;
    }
    return null;
  }

  /* ستون‌هایی که کاربر کنار گذاشته، برای خودش می‌مانَد: یک جدولِ
     ده‌ستونی روی لپ‌تاپ خوانده نمی‌شود، و هر کسی چند ستونِ اولش را
     می‌خواهد. مالِ همین مرورگر است و به کارتابلِ صاحبِ بخش کاری
     ندارد. */
  var HKEY = function (id) { return "vs-cols-" + id; };
  function loadHide(id) {
    try {
      var raw = localStorage.getItem(HKEY(id));
      var o = raw ? JSON.parse(raw) : null;
      return (o && typeof o === "object") ? o : {};
    } catch (e) { return {}; }
  }
  function saveHide(id) {
    try { localStorage.setItem(HKEY(id), JSON.stringify(st(id).hide || {})); } catch (e) { }
  }

  function st(id) {
    if (!ST[id]) ST[id] = { rows: [], rev: -1, open: false, timer: 0, edit: false,
                            q: "", hide: loadHide(id) };
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
    /* نامِ بخش و نامِ صاحبش زیرِ هم، نه کنارِ هم: دکمهٔ نوار یک ردیفِ
       flex است، پس تا وقتی هر دو مستقیماً زیرِ خودش بودند، «سیامک»
       کنارِ عنوان می‌نشست و با نامِ بلند نصفه می‌شد. */
    btn.innerHTML = '<span class="ic">' + esc(sh.icon) + "</span>" +
                    '<span class="vs-t">' + esc(sh.label) +
                    '<span class="vs-who">' + esc(sh.ownerName) + "</span></span>";
    btn.title = sh.label + " — کارتابلِ " + sh.ownerName;

    var before = navAnchor(nav);

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
    /* تهِ همان گروه، بعد از هر چه الان زیرش هست — ولی فقط تا جایی که
       دکمه‌ها مالِ همین گروه‌اند. بی این شرط، حلقه از کلِ نوار رد
       می‌شد و بخش‌ها ته فهرست، زیرِ «تنظیمات» می‌نشستند. */
    btn.classList.add("sh-ingroup");
    var cur = head;
    while (cur.nextElementSibling && inGroup(cur.nextElementSibling))
      cur = cur.nextElementSibling;
    nav.insertBefore(btn, cur.nextSibling);

    var sec = document.createElement("section");
    sec.className = "view"; sec.id = vid;
    /* همان شکلِ بقیهٔ بخش‌های کارتابل: سرخطِ پانل با یک h3 و یک
       نشانهٔ کوچک، کلیدِ «حذف/تغییر» در آخرین ستونِ سرِ جدول (نه
       شناور بالای آن)، و دکمهٔ ردیف تازه پایین. بخشی که شکلِ خودش را
       داشته باشد، در فهرستِ بخش‌ها وصله به نظر می‌رسد. */
    var sub = 'بخشِ کارتابلِ <b>' + esc(sh.ownerName) + '</b>' +
      (sh.orgPath ? ' — از راهِ گروهِ «' + esc(sh.orgPath) + '»' : '') +
      (sh.w
        ? '. آن‌چه این‌جا بنویسید، در کارتابلِ خودِ او هم همان است؛ رونوشت نیست.'
        : '. فقط می‌توانید ببینید.');

    sec.innerHTML =
      '<div class="section-title">' + esc(sh.icon) + " " + esc(sh.label) + "</div>" +
      '<div class="section-sub">' + sub + "</div>" +
      '<div class="panel">' +
        '<div class="vm-head">' +
          "<h3>" + esc(sh.icon) + " " + esc(sh.label) + "</h3>" +
          '<span class="save-hint vs-note" data-vsnote="' + esc(sh.id) + '"></span>' +
        "</div>" +
        '<div class="vs-tools">' +
          '<input type="text" class="vs-find" data-vsfind="' + esc(sh.id) + '" ' +
            'placeholder="جستجو در این بخش…" autocomplete="off" ' +
            'data-lpignore="true" data-1p-ignore data-form-type="other">' +
          '<button type="button" class="btn btn-ghost btn-sm vs-colbtn" data-vscols="' +
            esc(sh.id) + '">ستون‌ها</button>' +
          '<span class="vs-count" data-vscount="' + esc(sh.id) + '"></span>' +
        '</div>' +
        '<div class="vs-cols" data-vscolbox="' + esc(sh.id) + '" hidden></div>' +
        '<div class="tbl-wrap"><table>' +
        '<thead data-vshead="' + esc(sh.id) + '"></thead>' +
        '<tbody data-vsbody="' + esc(sh.id) + '"></tbody></table></div>' +
        (sh.w ? '<div class="visit-add-bar" style="margin-top:10px;">' +
                '<button class="btn btn-brass btn-sm" data-vsadd="' + esc(sh.id) +
                '">＋ ردیف تازه</button></div>' : "") +
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

    var add = sec.querySelector("[data-vsadd]");
    if (add) add.addEventListener("click", function () { addRow(sh.id); });

    var find = sec.querySelector("[data-vsfind]");
    if (find) find.addEventListener("input", function () {
      st(sh.id).q = find.value.trim();
      paint(sh.id);
    });
    var colBtn = sec.querySelector("[data-vscols]");
    var colBox = sec.querySelector("[data-vscolbox]");
    if (colBtn && colBox) colBtn.addEventListener("click", function () {
      colBox.hidden = !colBox.hidden;
      colBtn.classList.toggle("on", !colBox.hidden);
    });
    if (colBox) colBox.addEventListener("click", function (e) {
      var b = e.target.closest("[data-vscol]");
      if (!b) return;
      var k = b.getAttribute("data-vscol"), s2 = st(sh.id);
      if (s2.hide[k]) delete s2.hide[k]; else s2.hide[k] = 1;
      /* دستِ‌کم یک ستون باید بماند، وگرنه جدول می‌شود یک ستونِ شماره. */
      if (sh.cols.every(function (c) { return s2.hide[c.k]; })) delete s2.hide[k];
      saveHide(sh.id);
      paint(sh.id);
    });
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
      /* نامِ ستون روی خودِ کادر: صفحه‌خوان سرستونِ جدول را نمی‌خواند */
      return '<td><select class="vs-s" aria-label="' + esc(c.t || c.k) + '" data-k="' +
             esc(c.k) + '"' + (open ? "" : " disabled") + ">" + opts + "</select></td>";
    }
    var shown = c.kind === "money" ? money(v) : (c.kind === "num" ? (v === "" || v == null ? "" : fa(v)) : esc(v == null ? "" : v));
    var able = open && c.edit !== "never";
    return '<td class="editable-cell vs-c" data-k="' + esc(c.k) + '" contenteditable="' +
           (able ? "true" : "false") + '" style="opacity:' + (able ? "1" : "0.85") + ';">' +
           shown + "</td>";
  }

  /* ردیف با جستجو جور است؟ همهٔ ستون‌های دیده‌شدنی را می‌گردیم، چون
     کاربر دنبالِ چیزی است که می‌بیند. */
  function hit(sh, s, r) {
    if (!s.q) return true;
    var q = s.q.toLowerCase();
    for (var i = 0; i < sh.cols.length; i++) {
      var c = sh.cols[i];
      if (s.hide[c.k]) continue;
      var v = r[c.k];
      if (v != null && String(v).toLowerCase().indexOf(q) >= 0) return true;
    }
    return false;
  }

  function paint(id) {
    var sh = byId(id); if (!sh) return;
    var body = document.querySelector('[data-vsbody="' + id + '"]');
    if (!body) return;
    var s = st(id);
    var open = !!(sh.w && s.edit);
    var cols = sh.cols.filter(function (c) { return !s.hide[c.k]; });

    /* سرِ جدول هم این‌جا ساخته می‌شود، چون ستون‌ها عوض می‌شوند. */
    var head = document.querySelector('[data-vshead="' + id + '"]');
    if (head) head.innerHTML = "<tr>" +
      '<th style="width:26px;">#</th>' +
      cols.map(function (c) { return "<th>" + esc(c.t) + "</th>"; }).join("") +
      (sh.w
        ? '<th style="width:70px;">' +
            '<label class="edit-toggle-wrap" title="فعال/غیرفعال کردن امکان حذف و تغییر">' +
              '<span class="edit-switch"><input type="checkbox" data-vsedit="' + esc(sh.id) +
              '"' + (s.edit ? " checked" : "") + '><span class="track"></span></span> حذف/تغییر</label>' +
          "</th>"
        : "") + "</tr>";
    var tog = head && head.querySelector("[data-vsedit]");
    if (tog) tog.addEventListener("change", function () {
      st(sh.id).edit = !!tog.checked;
      paint(sh.id);
    });

    /* کدام ستون‌ها دیده شوند: یک ردیف قرص، با همان نامِ سرستون. */
    var box = document.querySelector('[data-vscolbox="' + id + '"]');
    if (box) box.innerHTML = sh.cols.map(function (c) {
      return '<button type="button" class="vs-col' + (s.hide[c.k] ? "" : " on") +
        '" data-vscol="' + esc(c.k) + '">' + esc(c.t) + "</button>";
    }).join("");

    var span = cols.length + (sh.w ? 2 : 1);
    var seen = 0;
    body.innerHTML = s.rows.map(function (r, i) {
      if (!hit(sh, s, r)) return "";
      seen++;
      return '<tr data-ix="' + i + '"><td>' + fa(i + 1) + "</td>" +
        cols.map(function (c) { return cellHtml(sh, c, r[c.k], open); }).join("") +
        (sh.w ? '<td><button class="btn-del" data-vsdel="' + i + '"' +
                (open ? "" : " disabled") + ' title="حذف">✕</button></td>' : "") +
        "</tr>";
    }).join("") ||
      '<tr><td colspan="' + span + '" style="color:var(--ink-faint);">' +
      (s.q ? "چیزی با «" + esc(s.q) + "» پیدا نشد." : "هنوز ردیفی ندارد.") + "</td></tr>";

    var cnt = document.querySelector('[data-vscount="' + id + '"]');
    if (cnt) cnt.textContent = s.rows.length
      ? (s.q ? fa(seen) + " از " + fa(s.rows.length) + " ردیف" : fa(s.rows.length) + " ردیف")
      : "";

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
