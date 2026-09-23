/* بخش‌های مشترک — سمتِ مرورگر
   =================================================================
   یک فایل است و هر دو کارتابل (فنی و مالی) همین را بار می‌کنند. اگر
   دو نسخه می‌شد، فردا یکی‌شان عوض می‌شد و آن یکی نه.

   اسکریپتِ معمولی است، نه ماژول: پس به apiCall و KARTABL_API که در
   خودِ صفحه تعریف شده‌اند دسترسی دارد — همان کاری که /admin.js در
   فروشگاه می‌کند.

   قاعدهٔ اصلیِ این‌جا: هر ردیف جدا ذخیره می‌شود. دو نفر هم‌زمان باز
   کرده‌اند و اگر کلِ جدول فرستاده شود، آن‌که دیرتر ذخیره کرده کارِ
   اولی را پاک می‌کند. */
(function () {
  "use strict";

  var BOXES = [];          /* تعریفِ بخش‌ها، از سرور */
  var STATE = {};          /* id → { rows: {rid: {...}}, since, timer, el } */
  var POLL_MS = 6000;
  var esc = function (t) {
    return String(t == null ? "" : t)
      .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
  };
  var faNum = function (n) { return String(n).replace(/[0-9]/g, function (d) { return "۰۱۲۳۴۵۶۷۸۹"[d]; }); };
  var money = function (n) { return faNum(Number(n || 0).toLocaleString("en-US")); };

  function newRid() {
    var a = "abcdefghijklmnopqrstuvwxyz0123456789", out = "";
    var b = new Uint8Array(12);
    (window.crypto || window.msCrypto).getRandomValues(b);
    for (var i = 0; i < b.length; i++) out += a[b[i] % a.length];
    return out;
  }

  /* ---------- شیوه‌نامه ----------
     توکن‌های رنگ از خودِ صفحه می‌آیند، پس در تم شب هم درست درمی‌آید. */
  var CSS = [
    ".sh-bar{display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:14px}",
    ".sh-live{font-size:11.5px;color:var(--ink-faint);display:flex;align-items:center;gap:6px}",
    ".sh-live .dot{width:7px;height:7px;border-radius:50%;background:var(--green,#2F6B4F);",
    "  box-shadow:0 0 0 0 rgba(47,107,79,.5);animation:shPulse 2.4s infinite}",
    "@keyframes shPulse{0%{box-shadow:0 0 0 0 rgba(47,107,79,.45)}70%{box-shadow:0 0 0 6px rgba(47,107,79,0)}100%{box-shadow:0 0 0 0 rgba(47,107,79,0)}}",
    ".sh-tab input,.sh-tab select,.sh-tab textarea{width:100%;box-sizing:border-box;",
    "  font-family:var(--font-body);font-size:12px;padding:6px 7px;border:1px solid transparent;",
    "  border-radius:7px;background:transparent;color:var(--ink);resize:none}",
    ".sh-tab input:hover,.sh-tab select:hover,.sh-tab textarea:hover{border-color:var(--card-border)}",
    ".sh-tab input:focus,.sh-tab select:focus,.sh-tab textarea:focus{outline:none;",
    "  border-color:var(--brass);background:var(--white);box-shadow:0 0 0 3px rgba(26,79,163,.14)}",
    ".sh-tab td{padding:3px 4px;vertical-align:top}",
    ".sh-tab td.who{font-size:10.5px;color:var(--ink-faint);white-space:nowrap;padding-top:10px}",
    ".sh-tab textarea{min-height:32px;line-height:1.8;overflow:hidden}",
    /* هم‌شکلِ دکمهٔ حذفِ بقیهٔ جدول‌های کارتابل: تا دست رویش نرود آرام است */
    ".sh-del{display:inline-flex;align-items:center;justify-content:center;",
    "  width:28px;height:28px;padding:0;box-sizing:border-box;background:transparent;",
    "  border:1px solid transparent;border-radius:8px;color:var(--ink-faint);",
    "  font-size:13px;line-height:1;cursor:pointer;transition:background .14s,color .14s}",
    ".sh-del:hover{background:var(--red-bg,#F6E1E2);color:var(--red-ink,#A6222B)}",
    ".sh-del:active{transform:scale(.94)}",
    ".sh-row.fresh{animation:shFresh 2.2s ease}",
    "@keyframes shFresh{0%{background:var(--brass-bg)}100%{background:transparent}}",
    ".sh-empty{padding:26px 10px;text-align:center;color:var(--ink-faint);font-size:12.5px;line-height:2}",
    ".sh-note{font-size:11.5px;color:var(--ink-faint);line-height:1.9;margin-top:10px}",
    ".sh-sum{font-size:12px;color:var(--ink-soft);font-weight:600}",
    /* خانه‌ای که این آدم اجازه‌اش را ندارد: خوانا می‌ماند ولی معلوم است
       که کادر نیست. خاکستریِ مرده نمی‌شود، چون محتوایش هنوز مهم است. */
    ".sh-tab .ro{display:block;font-size:12px;padding:6px 7px;color:var(--ink-soft);",
    "  line-height:1.8;white-space:pre-wrap;word-break:break-word;min-height:20px}",
    ".sh-tab td.locked{background:var(--paper-2,rgba(0,0,0,.02))}",
    ".sh-stamp{font-size:11px;color:var(--ink-faint);white-space:nowrap;padding-top:9px}",
    ".sh-mine{font-weight:600}",
    ".sh-kept{font-size:11.5px;color:var(--red-ink,#A6222B);line-height:1.9;margin-top:8px;min-height:19px}",
    /* سرفصلِ گروه در نوار کنار. دکمه نیست، پس نه hover دارد نه کلیک —
       وگرنه آدم رویش می‌زند و انتظار دارد چیزی باز شود. */
    ".sh-org{font-size:10.5px;letter-spacing:.02em;color:var(--ink-faint);",
    "  padding:12px 10px 5px;margin-top:4px;border-top:1px solid var(--card-border,rgba(11,37,69,.08));",
    "  white-space:nowrap;overflow:hidden;text-overflow:ellipsis}"
  ].join("\n");

  function addCss() {
    if (document.getElementById("sharedCss")) return;
    var st = document.createElement("style");
    st.id = "sharedCss"; st.textContent = CSS;
    document.head.appendChild(st);
  }

  /* ---------- ساختِ نما و دکمهٔ نوار کنار ---------- */
  function mount(box) {
    var vid = "view-shared-" + box.id;
    if (document.getElementById(vid)) return;

    var nav = document.querySelector(".nav-list");
    var host = document.querySelector(".content");
    if (!nav || !host) return;

    var btn = document.createElement("button");
    btn.className = "navbtn";
    btn.setAttribute("data-view", "shared-" + box.id);
    btn.innerHTML = '<span class="ic">' + esc(box.icon) + "</span> " + esc(box.title);
    /* پیش از دکمه‌های عمومی (راهنما و تنظیمات) بنشیند تا قاطیِ آن‌ها نشود */
    var before = nav.querySelector('.navbtn[data-view="guide"]')
              || nav.querySelector('.navbtn[data-view="settings"]');
    /* بخش‌هایی که به یک گروه وصل‌اند زیرِ نامِ همان گروه جمع می‌شوند.
       سرفصل فقط یک بار، پیش از اولین بخشِ آن گروه. بخش‌های بی‌گروه
       دقیقاً همان‌جا که بودند می‌مانند. */
    if (box.orgPath) {
      var key = "org-" + box.org;
      if (!nav.querySelector('[data-shorg="' + key + '"]')) {
        var head = document.createElement("div");
        head.className = "sh-org";
        head.setAttribute("data-shorg", key);
        head.textContent = box.orgPath;
        head.title = box.orgPath;
        nav.insertBefore(head, before || null);
      }
      /* بعد از سرفصلِ خودش، نه ته فهرست */
      var last = nav.querySelector('[data-shorg="' + key + '"]');
      var cur = last;
      while (cur.nextElementSibling &&
             cur.nextElementSibling.classList.contains("navbtn") &&
             String(cur.nextElementSibling.getAttribute("data-view") || "").indexOf("shared-") === 0)
        cur = cur.nextElementSibling;
      nav.insertBefore(btn, cur.nextSibling);
    } else {
      nav.insertBefore(btn, before || null);
    }

    var sec = document.createElement("section");
    sec.className = "view"; sec.id = vid;
    sec.innerHTML =
      '<div class="section-title">' + esc(box.title) + "</div>" +
      '<div class="section-sub">' + (box.rowlock
        ? "بخشِ مشترک — هر کس ردیفِ خودش را تغییر می‌دهد و ردیفِ بقیه را فقط می‌بیند."
        : "بخشِ مشترک — هر کسی که دسترسی دارد می‌تواند تغییر بدهد و تغییرِ بقیه را همین‌جا می‌بینید.") +
        (isMgr(box) ? " شما مدیرِ این بخش هستید." : "") + "</div>" +
      '<div class="panel">' +
        '<div class="sh-bar">' +
          '<button class="btn btn-brass btn-sm" data-shadd="' + esc(box.id) + '">＋ ردیف تازه</button>' +
          '<span class="sh-sum" data-shsum="' + esc(box.id) + '"></span>' +
          '<span class="sh-live" style="margin-inline-start:auto"><span class="dot"></span>زنده</span>' +
        "</div>" +
        '<div class="tbl-wrap"><table class="sh-tab"><thead><tr>' +
          box.cols.map(function (c) {
            return "<th" + (c.w ? ' style="width:' + c.w + 'px"' : "") + ">" + esc(c.t) + "</th>";
          }).join("") +
          '<th style="width:104px">صاحب</th><th style="width:40px"></th>' +
        "</tr></thead><tbody data-shbody=\"" + esc(box.id) + "\"></tbody></table></div>" +
        '<div class="sh-empty" data-shempty="' + esc(box.id) + '" hidden>' +
          "هنوز ردیفی نیست.<br>با «＋ ردیف تازه» اولین ردیف را بسازید." +
        "</div>" +
        '<div class="sh-kept" data-shkept="' + esc(box.id) + '"></div>' +
        '<div class="sh-note">تغییرها همان لحظه ذخیره می‌شوند؛ دکمهٔ ذخیره ندارد. ' +
          "هر چند ثانیه هم تغییرِ بقیه خودش می‌آید." +
          (box.rowlock ? "<br>خانه‌های خاکستری مالِ شما نیستند: هر کس ردیفی را که خودش ساخته تغییر می‌دهد." : "") +
        "</div>" +
      "</div>";
    /* پاورقیِ صفحه آخرِ .content است؛ اگر همین‌طور appendChild کنیم،
       نما زیرِ پاورقی می‌افتد و پاورقی بالای جدول دیده می‌شود. */
    var foot = host.querySelector(".appfoot");
    host.insertBefore(sec, foot || null);

    /* setupNav زودتر از این اجرا شده، پس دکمه را خودمان سیم‌کشی می‌کنیم */
    btn.addEventListener("click", function () {
      var all = document.querySelectorAll(".navbtn");
      for (var i = 0; i < all.length; i++) all[i].classList.remove("active");
      btn.classList.add("active");
      var vs = document.querySelectorAll(".view");
      for (var j = 0; j < vs.length; j++) vs[j].classList.remove("active");
      sec.classList.add("active");
      pull(box.id, true);
      startPoll(box.id);
    });

    sec.querySelector("[data-shadd]").addEventListener("click", function () { addRow(box.id); });
  }

  /* ---------- قاعده‌های دسترسی ----------
     دقیقاً همان چیزی که سرور اعمال می‌کند. این‌جا فقط برای این است که
     آدم کادرِ بی‌فایده نبیند و وسطِ تایپ نفهمد نوشته‌اش نمی‌رود.
     حرفِ آخر مالِ سرور است؛ اگر این‌جا چیزی از قلم افتاد، آن‌جا
     می‌گیردش. */
  function me() { return window.KARTABL_SLUG || ""; }
  function isMgr(box) { return (box.mgrs || []).indexOf(me()) >= 0; }

  function canEdit(box, col, r) {
    var rule = col.edit || (box.rowlock ? "owner" : "any");
    if (rule === "never") return false;
    if (rule === "any") return true;
    if (isMgr(box)) return true;
    var owner = r && r.owner;
    if (rule === "owner") return !owner || owner === me();
    if (rule === "mgr") return false;
    if (rule === "doer") {
      var who = r && r.v && r.v.who;
      return who ? who === me() : (!owner || owner === me());
    }
    return false;
  }

  function canKill(box, r) {
    if (!box.rowlock) return true;
    var owner = r && r.owner;
    return !owner || owner === me() || isMgr(box);
  }

  function nameOf(box, slug) {
    if (!slug) return "";
    var p = (box.people || []).find(function (x) { return x.slug === slug; });
    return p ? p.name : slug;
  }

  /* تاریخِ شمسیِ لحظه‌ای که ردیف ساخته شده. عدد از سرور می‌آید و
     این‌جا فقط خوانا می‌شود — پس کسی نمی‌تواند عقب‌وجلویش کند. */
  function shamsi(ms) {
    if (!ms) return "—";
    try {
      return new Intl.DateTimeFormat("fa-IR", {
        year: "numeric", month: "2-digit", day: "2-digit"
      }).format(new Date(ms));
    } catch (e) { return "—"; }
  }

  /* ---------- یک خانه ---------- */
  function cellHtml(col, val) {
    var v = val === undefined || val === null ? "" : val;
    var dir = col.ltr ? ' dir="ltr"' : "";
    /* مثل بقیهٔ جدول‌های کارتابل: هیچ خانه‌ای پیشنهادِ «نام کاربری» نگیرد */
    var name = ' data-k="' + esc(col.k) + '" autocomplete="off" spellcheck="false"' +
               ' data-lpignore="true" data-1p-ignore data-form-type="other"';
    if (col.kind === "pick") {
      return '<select' + name + '><option value=""></option>' +
        col.opts.map(function (o) {
          return '<option value="' + esc(o) + '"' + (String(v) === o ? " selected" : "") + ">" + esc(o) + "</option>";
        }).join("") + "</select>";
    }
    /* «مسئول» فهرستِ بسته‌ای از اعضای همین بخش است، نه یک کادرِ متن:
       اسمِ تایپ‌شده فردا با هیچ کارتابلی جور درنمی‌آید. */
    if (col.kind === "who") {
      return '<select' + name + '><option value="">— کسی —</option>' +
        (col.people || []).map(function (p) {
          return '<option value="' + esc(p.slug) + '"' + (String(v) === p.slug ? " selected" : "") +
                 ">" + esc(p.name) + "</option>";
        }).join("") + "</select>";
    }
    if (col.kind === "long")
      return "<textarea" + name + dir + ' rows="1">' + esc(v) + "</textarea>";
    if (col.kind === "money" || col.kind === "num")
      return '<input type="text" inputmode="numeric" dir="ltr"' + name +
             ' value="' + esc(v === "" ? "" : Number(v).toLocaleString("en-US")) + '">';
    if (col.kind === "date")
      return '<input type="text" dir="ltr" placeholder="۱۴۰۴/۰۷/۰۱"' + name + ' value="' + esc(v) + '">';
    return '<input type="text"' + name + dir + ' value="' + esc(v) + '">';
  }

  /* خانه‌ای که این آدم اجازه‌اش را ندارد کادر نمی‌شود. غیرفعال کردنِ
     input هم می‌شد، ولی آن وقت متنِ بلند بریده می‌ماند و رنگش مرده
     می‌شود؛ این‌طوری محتوا کامل و خواناست، فقط دست نمی‌خورد. */
  function roHtml(box, col, val) {
    var v = val === undefined || val === null || val === "" ? "—" : val;
    if (col.kind === "money" || col.kind === "num") v = money(val || 0);
    if (col.kind === "who") v = val ? nameOf(box, val) : "— کسی —";
    return '<span class="ro"' + (col.ltr ? ' dir="ltr"' : "") + ">" + esc(v) + "</span>";
  }

  function rowHtml(box, r) {
    return '<tr class="sh-row" data-rid="' + esc(r.rid) + '">' +
      box.cols.map(function (c) {
        /* «تاریخ ثبت» ستونِ داده نیست: همان لحظه‌ای است که سرور ردیف را
           ساخته. پس نه کادر دارد، نه ذخیره می‌شود. */
        if (c.kind === "made")
          return '<td class="locked"><span class="sh-stamp">' + esc(shamsi(r.created)) + "</span></td>";
        var col = c.kind === "who" ? Object.assign({}, c, { people: box.people || [] }) : c;
        return canEdit(box, c, r)
          ? "<td>" + cellHtml(col, r.v[c.k]) + "</td>"
          : '<td class="locked">' + roHtml(box, col, r.v[c.k]) + "</td>";
      }).join("") +
      '<td class="who">' + whoHtml(box, r) + "</td>" +
      "<td>" + (canKill(box, r)
        ? '<button class="sh-del" title="بردار">✕</button>'
        : "") + "</td>" +
      "</tr>";
  }

  /* چه کسی ردیف را ساخته، و کِی آخرین بار دست خورده. صاحبِ ردیف مهم‌تر
     از آخرین دست‌زننده است، چون قفل به او بسته است. */
  function whoHtml(box, r) {
    var owner = r.owner || r.by || "";
    var mine = owner === me();
    var t = "";
    if (r.updated) {
      try {
        t = new Intl.DateTimeFormat("fa-IR", { hour: "2-digit", minute: "2-digit", hour12: false })
          .format(new Date(r.updated));
      } catch (e) { t = ""; }
    }
    var label = mine ? "خودم" : (owner ? nameOf(box, owner) : "—");
    var tip = box.rowlock && !mine && owner
      ? ' title="این ردیف را ' + esc(nameOf(box, owner)) + ' ساخته؛ خانه‌های قفل مالِ اوست."'
      : "";
    return "<span" + tip + (mine ? ' class="sh-mine"' : "") + ">" + esc(label) + "</span>" +
           (t ? "<br>" + esc(t) : "");
  }

  /* ---------- خواندن از سرور ---------- */
  function st(id) {
    if (!STATE[id]) STATE[id] = { rows: {}, since: 0, timer: null, busy: false };
    return STATE[id];
  }

  async function pull(id, full) {
    var s = st(id);
    if (s.busy) return;
    s.busy = true;
    try {
      var since = full ? 0 : s.since;
      var r = await apiCall("/shared/" + id + "?since=" + since);
      if (!r.ok) return;
      if (full) s.rows = {};
      var list = (r.data.rows || []);
      for (var i = 0; i < list.length; i++) {
        var row = list[i];
        if (row.dead) delete s.rows[row.rid];
        else s.rows[row.rid] = row;
        s.since = Math.max(s.since, row.updated || 0);
      }
      if (r.data.now) s.since = Math.max(s.since, 0);
      paint(id, full ? null : list);
    } catch (e) { /* شبکه قطع بود؛ نوبتِ بعد */ }
    finally { s.busy = false; }
  }

  /* ردیفی که همین حالا زیرِ دستِ کاربر است بازنویسی نمی‌شود — وگرنه
     وسطِ تایپ، متن از زیرِ انگشتش عوض می‌شود. */
  function editing(tr) {
    return tr && document.activeElement && tr.contains(document.activeElement);
  }

  function paint(id, changed) {
    var box = BOXES.find(function (b) { return b.id === id; });
    if (!box) return;
    var body = document.querySelector('[data-shbody="' + id + '"]');
    if (!body) return;
    var s = st(id);
    var rids = Object.keys(s.rows).sort(function (a, b) {
      return (s.rows[a].updated || 0) - (s.rows[b].updated || 0);
    });

    var fresh = {};
    if (changed) for (var i = 0; i < changed.length; i++) fresh[changed[i].rid] = true;

    /* ردیف‌هایی که رفته‌اند */
    var have = body.querySelectorAll("tr[data-rid]");
    for (var j = have.length - 1; j >= 0; j--) {
      if (!s.rows[have[j].getAttribute("data-rid")]) have[j].remove();
    }
    /* تازه‌ها و عوض‌شده‌ها */
    for (var k = 0; k < rids.length; k++) {
      var rid = rids[k];
      var tr = body.querySelector('tr[data-rid="' + rid + '"]');
      if (!tr) {
        body.insertAdjacentHTML("beforeend", rowHtml(box, s.rows[rid]));
        tr = body.querySelector('tr[data-rid="' + rid + '"]');
        wire(box, tr);
        if (fresh[rid]) { tr.classList.add("fresh"); }
      } else if (fresh[rid] && !editing(tr)) {
        var next = document.createElement("tbody");
        next.innerHTML = rowHtml(box, s.rows[rid]);
        tr.replaceWith(next.firstElementChild);
        tr = body.querySelector('tr[data-rid="' + rid + '"]');
        wire(box, tr);
        tr.classList.add("fresh");
      }
    }
    var empty = document.querySelector('[data-shempty="' + id + '"]');
    if (empty) empty.hidden = rids.length > 0;
    summary(box);
  }

  /* اگر جدول ستونِ مبلغ دارد، جمعش پایِ کار می‌آید — همان چیزی که
     آدم بعد از پر کردنِ جدول دنبالش می‌گردد. */
  function summary(box) {
    var el = document.querySelector('[data-shsum="' + box.id + '"]');
    if (!el) return;
    var s = st(box.id);
    var rids = Object.keys(s.rows);
    var moneyCols = box.cols.filter(function (c) { return c.kind === "money"; });
    var bits = [faNum(rids.length) + " ردیف"];
    for (var i = 0; i < moneyCols.length; i++) {
      var sum = 0;
      for (var j = 0; j < rids.length; j++) sum += Number(s.rows[rids[j]].v[moneyCols[i].k] || 0);
      if (sum) bits.push(moneyCols[i].t + ": " + money(sum) + " تومان");
    }
    el.textContent = bits.join(" · ");
  }

  /* ---------- نوشتن ---------- */
  /* فقط خانه‌هایی خوانده می‌شوند که کادر دارند — یعنی همان‌هایی که این
     آدم اجازه‌شان را داشت. فرستادنِ بقیه هم بی‌خطر بود (سرور ردشان
     می‌کند) ولی بی‌جهت «نوشته نشد» می‌گرفتیم. */
  function readRow(box, tr) {
    var v = {};
    for (var i = 0; i < box.cols.length; i++) {
      var c = box.cols[i];
      if (!c.k) continue;
      var el = tr.querySelector('[data-k="' + c.k + '"]');
      if (!el) continue;
      v[c.k] = (c.kind === "money" || c.kind === "num")
        ? String(el.value || "").replace(/[,٬\s]/g, "")
        : el.value;
    }
    return v;
  }

  /* یک خطی می‌ماند تا وقتی متنش یک خط است؛ بعد خودش باز می‌شود.
     بدون این، یادداشتِ بلند پشتِ یک خانهٔ ۳۲ پیکسلی گم می‌شد. */
  function fit(el) {
    if (!el || el.tagName !== "TEXTAREA") return;
    el.style.height = "auto";
    el.style.height = Math.min(160, Math.max(32, el.scrollHeight)) + "px";
  }

  function wire(box, tr) {
    if (!tr) return;
    var rid = tr.getAttribute("data-rid");
    var save = function () { pushRow(box, tr, rid); };
    var fields = tr.querySelectorAll("[data-k]");
    for (var i = 0; i < fields.length; i++) {
      fields[i].addEventListener("change", save);
      if (fields[i].tagName === "TEXTAREA") {
        fit(fields[i]);
        fields[i].addEventListener("input", function (e) { fit(e.target); });
      }
    }
    var del = tr.querySelector(".sh-del");
    if (del) del.addEventListener("click", function () {
      if (!confirm("این ردیف برای همهٔ اعضای این بخش برداشته شود؟")) return;
      killRow(box, tr, rid);
    });
  }

  function kept(box, list) {
    var el = document.querySelector('[data-shkept="' + box.id + '"]');
    if (!el) return;
    el.textContent = (list && list.length)
      ? "نوشته نشد: " + list.join("، ") + " — این ستون‌ها دستِ شما نیست."
      : "";
    if (list && list.length) setTimeout(function () {
      if (el.textContent.indexOf("نوشته نشد") === 0) el.textContent = "";
    }, 6000);
  }

  async function pushRow(box, tr, rid) {
    var v = readRow(box, tr);
    var r = await apiCall("/shared/" + box.id + "/row", {
      method: "POST", body: JSON.stringify({ rid: rid, v: v })
    });
    var s = st(box.id);
    if (!r.ok) { flash(tr, false); kept(box, null); return; }
    var was = s.rows[rid] || {};
    s.rows[rid] = { rid: rid, v: r.data.v || v, updated: r.data.updated,
                    by: me(), dead: false,
                    owner: r.data.owner || was.owner || me(),
                    created: r.data.created || was.created || Date.now() };
    s.since = Math.max(s.since, r.data.updated || 0);

    /* اگر سرور چیزی را نپذیرفت، همان خانه را برمی‌گردانیم سرِ مقدارِ
       واقعی‑اش. کلِ ردیف از نو کشیده نمی‌شود چون انگشتِ کاربر همین
       حالا داخلِ یکی از خانه‌هاست و تمرکز می‌پرید. */
    var srv = r.data.v || {};
    for (var i = 0; i < box.cols.length; i++) {
      var c = box.cols[i];
      if (!c.k) continue;
      var el = tr.querySelector('[data-k="' + c.k + '"]');
      if (!el || el === document.activeElement) continue;
      var want = srv[c.k] === undefined ? "" : srv[c.k];
      if (c.kind === "money" || c.kind === "num")
        want = want === "" ? "" : Number(want).toLocaleString("en-US");
      if (String(el.value) !== String(want)) { el.value = want; fit(el); }
    }
    kept(box, r.data.kept);

    var who = tr.querySelector("td.who");
    if (who) who.innerHTML = whoHtml(box, s.rows[rid]);
    flash(tr, !(r.data.kept && r.data.kept.length));
    summary(box);
  }

  async function killRow(box, tr, rid) {
    var r = await apiCall("/shared/" + box.id + "/del", {
      method: "POST", body: JSON.stringify({ rid: rid })
    });
    if (!r.ok) { flash(tr, false); return; }
    var s = st(box.id);
    delete s.rows[rid];
    s.since = Math.max(s.since, r.data.updated || 0);
    tr.remove();
    var empty = document.querySelector('[data-shempty="' + box.id + '"]');
    if (empty) empty.hidden = Object.keys(s.rows).length > 0;
    summary(box);
  }

  function addRow(id) {
    var box = BOXES.find(function (b) { return b.id === id; });
    if (!box) return;
    var body = document.querySelector('[data-shbody="' + id + '"]');
    if (!body) return;
    var rid = newRid();
    var s = st(id);
    s.rows[rid] = { rid: rid, v: {}, updated: Date.now(), by: me(), dead: false,
                    owner: me(), created: Date.now() };
    body.insertAdjacentHTML("beforeend", rowHtml(box, s.rows[rid]));
    var tr = body.querySelector('tr[data-rid="' + rid + '"]');
    wire(box, tr);
    var empty = document.querySelector('[data-shempty="' + id + '"]');
    if (empty) empty.hidden = true;
    var first = tr.querySelector("[data-k]");
    if (first) first.focus();
    /* ردیفِ خالی همین حالا روی سرور ساخته می‌شود تا اگر مرورگر بسته
       شد، آن یکی هم ببیند کسی دارد چیزی اضافه می‌کند. */
    pushRow(box, tr, rid);
    summary(box);
  }

  function flash(tr, ok) {
    if (!tr) return;
    tr.style.transition = "background .25s";
    tr.style.background = ok ? "var(--green-bg,#E3EFE7)" : "var(--red-bg,#F6E1E2)";
    setTimeout(function () { tr.style.background = ""; }, ok ? 420 : 1500);
  }

  /* ---------- تازه‌سازیِ خودکار ----------
     فقط وقتی همین بخش باز است و پنجره جلوِ چشم است. وگرنه یک کارتابلِ
     بازمانده در یک تبِ فراموش‌شده تا ابد به سرور می‌زند. */
  function startPoll(id) {
    stopAll();
    var s = st(id);
    s.timer = setInterval(function () {
      var sec = document.getElementById("view-shared-" + id);
      if (!sec || !sec.classList.contains("active") || document.hidden) return;
      pull(id, false);
    }, POLL_MS);
  }

  function stopAll() {
    for (var k in STATE) if (STATE[k].timer) { clearInterval(STATE[k].timer); STATE[k].timer = null; }
  }

  /* وقتی کاربر از این بخش بیرون می‌رود، تایمر هم خاموش می‌شود */
  document.addEventListener("click", function (e) {
    var b = e.target.closest ? e.target.closest(".navbtn") : null;
    if (b && String(b.getAttribute("data-view") || "").indexOf("shared-") !== 0) stopAll();
  });
  document.addEventListener("visibilitychange", function () {
    if (document.hidden) return;
    for (var k in STATE) {
      var sec = document.getElementById("view-shared-" + k);
      if (sec && sec.classList.contains("active")) pull(k, false);
    }
  });

  /* ---------- راه‌اندازی ---------- */
  window.initSharedBoxes = async function () {
    try {
      var r = await apiCall("/shared");
      if (!r.ok) return;
      BOXES = r.data.boxes || [];
      if (!BOXES.length) return;
      addCss();
      /* اول بخش‌های بی‌گروه، بعد گروه‌به‌گروه. ترتیبِ سوار شدن همان
         ترتیبِ نوار کنار است، پس اگر مرتب نمی‌شد، یک بخشِ بی‌گروه
         می‌افتاد زیرِ سرفصلِ گروهِ قبلی و مالِ آن به نظر می‌رسید. */
      var order = BOXES.slice().sort(function (a, b) {
        var ao = a.orgPath || "", bo = b.orgPath || "";
        if (!ao && bo) return -1;
        if (ao && !bo) return 1;
        return ao === bo ? 0 : (ao < bo ? -1 : 1);
      });
      for (var i = 0; i < order.length; i++) mount(order[i]);
    } catch (e) { /* اگر نیامد، کارتابل بدون این بخش کار می‌کند */ }
  };
})();
