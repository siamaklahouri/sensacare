/* ==================== مرتب‌سازی و فیلترِ ستونی ====================
   سیزده جدولِ دادهٔ دو کارتابل یک چیزِ مشترک کم داشتند: ترتیبِ هر جدول
   فقط همان بود که دستی کشیده شده. «کدام فاکتور مهلتش نزدیک‌تر است؟»
   یا «بزرگ‌ترین بدهی کدام است؟» فقط با چشم‌چرانیِ ستون جواب داشت.

   فیلتر هم بود، ولی لکه‌لکه: جدولِ سرورها شش ستونِ فیلتردار داشت،
   فاکتورها دوتا از ده ستون، و چک‌لیستِ ماهانه — که بیش از همه نگاهش
   می‌کنند — هیچ. بانک و بودجه هم هیچ.

   سه تصمیم:

   یک) فهرستِ جدول‌ها را از خودمان درنمی‌آوریم. ROWDRAG همین حالا
   می‌داند کدام tbodyها جدولِ دادهٔ واقعی‌اند (و کدام تقویم و ماتریسِ
   ریموت‌اند که ترتیبشان معنا دارد). همان فهرست را می‌گیریم؛ فردا
   جدولِ تازه که ثبت شود، خودش مرتب‌شدنی می‌شود.

   دو) مرتب‌سازی فقط نماست و به داده دست نمی‌زند. اگر ترتیبِ واقعی را
   عوض می‌کرد، با کشیدنِ دستی و با «برگرداندنِ حذف» سرِ جنگ می‌رفت:
   ردیفی که برگردانده می‌شود باید سرِ جای واقعیِ خودش بنشیند، نه جای
   دیده‌شده. و چون نما با داده یکی نیست، تا وقتی جدول مرتب است دستهٔ
   کشیدن خاموش می‌شود — وگرنه کاربر ردیفی را به جایی می‌کشید که در
   داده جای دیگری بود.

   سه) ستونِ عدد و ستونِ تاریخ رشته نیستند. «۱۰» از «۹» کوچک‌تر
   نیست، و «۱۴۰۵/۰۲/۳۰» از «۱۴۰۵/۱۰/۰۱» بزرگ‌تر نیست — مقایسهٔ
   رشته‌ای هر دو را وارونه می‌گوید. پس هر خانه اول از parseFloat
   (که رقمِ فارسی و جداکننده را می‌فهمد) و بعد از DatePick.parse رد
   می‌شود، و تنها اگر هیچ‌کدام نشد، متن است. */
(function () {
  "use strict";

  var sortOf = {};      /* شناسهٔ جدول → { col, dir } یا نبودن */
  var busy = false;

  /* یک استثنا: چک‌لیستِ ریموت جدولِ داده نیست، یک ماتریس است —
     هر ستون یک روزِ ماه. فیلترِ متنی زیرِ سی ستونِ «۱، ۲، ۳…» فقط
     جدول را شلوغ می‌کند، و مرتب‌سازی‌اش هم معنای روشنی ندارد. */
  var SKIP = { remoteBody: 1 };

  function tbodies() {
    var out = [], ids = (window.ROWDRAG && ROWDRAG.ids) ? ROWDRAG.ids() : [], i, el;
    for (i = 0; i < ids.length; i++) {
      if (SKIP[ids[i]]) continue;
      el = document.getElementById(ids[i]);
      if (el && el.id && out.indexOf(el) < 0) out.push(el);
    }
    return out;
  }

  /* ردیفِ دادهٔ واقعی — نه ردیفِ افزودن، نه پیامِ خالی، نه پیامِ خودِ ما */
  function dataRows(tb) {
    var out = [], tr = tb.children, i;
    for (i = 0; i < tr.length; i++) {
      if (tr[i].classList.contains("add-row")) continue;
      if (tr[i].classList.contains("ts-none")) continue;
      if (tr[i].children.length < 2) continue;
      out.push(tr[i]);
    }
    return out;
  }

  function headRow(tb) {
    var tbl = tb.closest("table");
    if (!tbl || !tbl.tHead) return null;
    return tbl.tHead.rows[0] || null;
  }
  function filterRow(tb) {
    var tbl = tb.closest("table");
    if (!tbl || !tbl.tHead) return null;
    return tbl.tHead.querySelector("tr.filter-row");
  }

  /* ستونی که سرش خالی است، یا شمارهٔ ردیف است، یا کلیدِ «حذف/تغییر» را
     دارد، نه مرتب می‌شود نه فیلتر. */
  function usable(th) {
    if (!th) return false;
    if (th.querySelector(".edit-toggle-wrap, .del-toggle-wrap")) return false;
    var t = th.textContent.replace(/\s+/g, "");
    if (!t || t === "#") return false;
    return true;
  }

  function cellOf(tr, i) {
    var td = tr.children[i];
    if (!td) return "";
    /* بعضی خانه‌ها هم متن دارند هم یک کادرِ پنهان کنارش — ستونِ
       سررسید یکی از همان‌هاست: متن را می‌بینی و کادرش خالی است. پس
       کادر فقط وقتی حرفِ آخر را می‌زند که خودش چیزی داشته باشد. */
    var f = td.querySelector("select, input[type=text], textarea");
    if (f && String(f.value).trim()) return f.value;
    /* تیک‌ها: زده یا نزده، خودش یک ترتیب است */
    var cb = td.querySelector("input[type=checkbox]");
    if (cb) return cb.checked ? "۱" : "۰";
    return td.textContent.trim();
  }

  /* عدد؟ تاریخ؟ وگرنه متن. خالی همیشه ته فهرست می‌نشیند، چه صعودی
     چه نزولی — ردیفِ نیمه‌پُر خبری نیست که بخواهد اول بیاید. */
  var NUMISH = /^[-+]?[\d۰-۹٠-٩][\d۰-۹٠-٩\s,،٬٫.\-+]*$/;
  function keyOf(txt) {
    var s = String(txt == null ? "" : txt).trim();
    if (!s) return { e: 1 };
    if (NUMISH.test(s)) {
      var n = parseFloat(s);
      if (!isNaN(n)) return { n: n };
    }
    if (window.DatePick && DatePick.parse) {
      var d = DatePick.parse(s);
      /* toStamp سه آرگومان می‌گیرد، نه یک شیء — با شیء NaN می‌دهد و
         NaN در مقایسه نه بزرگ‌تر است نه کوچک‌تر، پس جدول بی‌صدا
         مرتب‌نشده می‌ماند. */
      if (d) {
        var ms = DatePick.toStamp(d.jy, d.jm, d.jd);
        if (!isNaN(ms)) return { n: ms };
      }
    }
    return { s: s };
  }

  function cmp(a, b, dir) {
    if (a.k.e || b.k.e) return a.k.e && b.k.e ? a.i - b.i : (a.k.e ? 1 : -1);
    var r;
    if ("n" in a.k && "n" in b.k) r = a.k.n - b.k.n;
    else if ("n" in a.k) r = -1;
    else if ("n" in b.k) r = 1;
    else r = String(a.k.s).localeCompare(String(b.k.s), "fa");
    /* برابرها ترتیبِ خودشان را نگه می‌دارند */
    return r ? r * dir : a.i - b.i;
  }

  /* ---------- فیلتر ---------- */
  function boxes(tb) {
    var fr = filterRow(tb);
    return fr ? fr.querySelectorAll(".ts-f") : [];
  }
  function shows(tb, tr) {
    var bs = boxes(tb), i, v;
    for (i = 0; i < bs.length; i++) {
      v = (bs[i].value || "").trim();
      if (!v) continue;
      var col = +bs[i].getAttribute("data-col");
      var hay = cellOf(tr, col);
      if (window.toLatinNumerals) { hay = toLatinNumerals(hay); v = toLatinNumerals(v); }
      if (hay.toLowerCase().indexOf(v.toLowerCase()) < 0) return false;
    }
    return true;
  }

  function apply(tb) {
    if (busy) return;
    busy = true;
    try {
      var rows = dataRows(tb), i, seen = 0;
      for (i = 0; i < rows.length; i++) {
        var on = shows(tb, rows[i]);
        rows[i].style.display = on ? "" : "none";
        if (on) seen++;
      }

      var st = sortOf[tb.id];
      if (st) {
        var vis = [];
        for (i = 0; i < rows.length; i++) vis.push({ tr: rows[i], i: i, k: keyOf(cellOf(rows[i], st.col)) });
        vis.sort(function (a, b) { return cmp(a, b, st.dir); });
        var moved = false;
        for (i = 0; i < vis.length; i++) if (vis[i].i !== i) { moved = true; break; }
        if (moved) {
          var frag = document.createDocumentFragment();
          for (i = 0; i < vis.length; i++) frag.appendChild(vis[i].tr);
          var add = tb.querySelector(".add-row");
          if (add) tb.insertBefore(frag, add); else tb.appendChild(frag);
        }
      }

      /* جدولی که فیلترش چیزی نگذاشته، خالی به نظر نرسد */
      var none = tb.querySelector(".ts-none");
      if (rows.length && !seen) {
        if (!none) {
          none = document.createElement("tr");
          none.className = "ts-none";
          none.innerHTML = '<td colspan="30">با این فیلتر چیزی نیست</td>';
          tb.insertBefore(none, tb.firstChild);
        }
      } else if (none) none.remove();

      var tbl = tb.closest("table");
      if (tbl) {
        if (sortOf[tb.id]) tbl.setAttribute("data-tsorted", "1");
        else tbl.removeAttribute("data-tsorted");
      }
    } catch (e) { console.error("[مرتب‌سازی]", e); }
    busy = false;
  }

  /* ---------- ساختِ سرستون‌ها ---------- */
  function build(tb) {
    var hr = headRow(tb);
    if (!hr || hr.getAttribute("data-ts") === "1") return;
    hr.setAttribute("data-ts", "1");

    var fr = filterRow(tb), made = false;
    if (!fr) {
      fr = document.createElement("tr");
      /* «ts-fr» یعنی این ردیف را ما ساخته‌ایم — روی گوشی کلاً
         برداشته می‌شود، بی آنکه ردیفِ فیلترِ خودِ جدول‌های قدیمی
         دست بخورد. */
      fr.className = "filter-row ts-fr";
      var k;
      for (k = 0; k < hr.cells.length; k++) fr.appendChild(document.createElement("th"));
      made = true;
    }

    var i;
    for (i = 0; i < hr.cells.length; i++) {
      var th = hr.cells[i];
      if (!usable(th)) continue;

      th.classList.add("ts-h");
      th.setAttribute("role", "button");
      th.setAttribute("tabindex", "0");
      th.setAttribute("data-col", String(i));
      th.title = "برای مرتب‌سازی کلیک کنید";
      var ar = document.createElement("span");
      ar.className = "ts-ar";
      ar.setAttribute("aria-hidden", "true");
      th.appendChild(ar);

      /* فیلتر فقط جایی که از قبل نیست — ستونِ فهرستی (msf) و کادرهای
         خودِ جدول سرِ جای خودشان می‌مانند. */
      var cell = fr.cells[i];
      if (cell && !cell.querySelector("input, select, .msf")) {
        var inp = document.createElement("input");
        inp.type = "text";
        inp.className = "ts-f";
        /* بی این، کمینه‌عرضِ ذاتیِ input (بیستِ نویسه) ستونِ کناری را
           له می‌کرد: «وظیفه» روی صفحهٔ ۳۹۰ پیکسلی ۱۸ پیکسل می‌شد. */
        inp.setAttribute("size", "1");
        inp.setAttribute("data-col", String(i));
        inp.placeholder = "جستجو...";
        inp.setAttribute("aria-label", "فیلترِ " + th.textContent.trim());
        cell.appendChild(inp);
      }
    }

    if (made && fr.querySelector(".ts-f")) hr.parentNode.appendChild(fr);
  }

  function arrow(tb) {
    var hr = headRow(tb);
    if (!hr) return;
    var st = sortOf[tb.id], i;
    for (i = 0; i < hr.cells.length; i++) {
      var th = hr.cells[i], on = st && st.col === i;
      th.classList.toggle("ts-on", !!on);
      if (on) th.setAttribute("aria-sort", st.dir > 0 ? "ascending" : "descending");
      else th.removeAttribute("aria-sort");
      var ar = th.querySelector(".ts-ar");
      if (ar) ar.textContent = on ? (st.dir > 0 ? "▲" : "▼") : "";
    }
    /* تا وقتی جدول مرتب است، جابه‌جاییِ دستی معنا ندارد */
    var grips = tb.querySelectorAll(".rd-grip"), j;
    for (j = 0; j < grips.length; j++)
      grips[j].title = st ? "تا وقتی جدول مرتب است، جابه‌جایی خاموش است"
                          : "برای جابه‌جایی بکشید";
  }

  /* کلیک: صعودی → نزولی → همان ترتیبِ دستیِ خودت.

     برای برگشتن به ترتیبِ دستی، ردیف‌ها را دوباره رندر نمی‌کنیم —
     رندر یعنی ذخیره، و ذخیره‌ای که هیچ داده‌ای را عوض نکرده فقط
     نسخه را جلو می‌برد. به‌جایش همان ترتیبِ اولیه را پیش از اولین
     مرتب‌سازی نگه می‌داریم و برش می‌گردانیم. اگر جدول در این فاصله
     از نو رندر شده باشد، خودش ترتیبِ داده را دارد و کاری نمانده. */
  var orig = {};

  function keep(tb) {
    orig[tb.id] = dataRows(tb);
  }
  function restore(tb) {
    var rows = orig[tb.id], i;
    delete orig[tb.id];
    if (!rows || !rows.length) return;
    for (i = 0; i < rows.length; i++) if (rows[i].parentNode !== tb) return;
    var frag = document.createDocumentFragment();
    for (i = 0; i < rows.length; i++) frag.appendChild(rows[i]);
    var add = tb.querySelector(".add-row");
    if (add) tb.insertBefore(frag, add); else tb.appendChild(frag);
  }

  function turn(tb, col) {
    var st = sortOf[tb.id];
    if (!st || st.col !== col) {
      if (!st) keep(tb);
      sortOf[tb.id] = { col: col, dir: 1 };
    }
    else if (st.dir > 0) st.dir = -1;
    else { delete sortOf[tb.id]; restore(tb); }
    arrow(tb);
    apply(tb);
  }

  function ownerOf(el) {
    var tbl = el.closest ? el.closest("table") : null;
    var tb = tbl ? tbl.querySelector("tbody[id]") : null;
    return tb && sortableId(tb) ? tb : null;
  }
  function sortableId(tb) {
    if (SKIP[tb.id]) return false;
    var ids = (window.ROWDRAG && ROWDRAG.ids) ? ROWDRAG.ids() : [];
    return ids.indexOf(tb.id) >= 0;
  }

  document.addEventListener("click", function (e) {
    var th = e.target.closest ? e.target.closest("th.ts-h") : null;
    if (!th) return;
    var tb = ownerOf(th);
    if (tb) turn(tb, +th.getAttribute("data-col"));
  });
  document.addEventListener("keydown", function (e) {
    if (e.key !== "Enter" && e.key !== " ") return;
    var th = e.target.closest ? e.target.closest("th.ts-h") : null;
    if (!th) return;
    e.preventDefault();
    var tb = ownerOf(th);
    if (tb) turn(tb, +th.getAttribute("data-col"));
  });
  document.addEventListener("input", function (e) {
    if (!e.target.classList || !e.target.classList.contains("ts-f")) return;
    var tb = ownerOf(e.target);
    if (tb) apply(tb);
  });
  document.addEventListener("keydown", function (e) {
    if (e.key !== "Escape" || !e.target.classList ||
        !e.target.classList.contains("ts-f")) return;
    e.target.value = "";
    var tb = ownerOf(e.target);
    if (tb) apply(tb);
  });

  var t = null;
  function sweep() {
    var tbs = tbodies(), i;
    for (i = 0; i < tbs.length; i++) { build(tbs[i]); arrow(tbs[i]); apply(tbs[i]); }
  }
  var later = function () { if (busy) return; clearTimeout(t); t = setTimeout(sweep, 180); };
  new MutationObserver(later).observe(document.body, { childList: true, subtree: true });
  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", later);
  else later();

  window.TSORT = { sweep: sweep, state: sortOf };
})();
