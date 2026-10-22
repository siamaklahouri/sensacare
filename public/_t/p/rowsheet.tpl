/* ==================== ویرایشِ ردیف روی گوشی ====================
   جدول‌های چک‌لیست و برنامهٔ روزانه هفت‌هشت ستون دارند. روی گوشی افقی
   می‌لغزند، یعنی برای پر کردنِ یک ردیف باید چند بار چپ و راست کرد و هر
   بار یک خانهٔ باریک را هدف گرفت. برنامه برای *خواندن* خوب بود و برای
   *نوشتن* نه.

   حالا در حالتِ نصب‌شده، زدن روی شمارهٔ ردیف همان ردیف را در یک کشوی
   پایینی باز می‌کند: هر ستون یک خانهٔ تمام‌عرض با نامِ خودش.

   نکتهٔ اصلیِ پیاده‌سازی: این کشو خانه‌های تازه نمی‌سازد که بعد لازم
   باشد جایی ذخیره شوند. همان کنترلِ داخلِ جدول را از راه دور می‌زند —
   مقدار را می‌گذارد و رویداد را می‌فرستد. پس هر کدی که از قبل به آن
   خانه وصل بوده (ذخیره، تاریخِ انجام، نمودارها) بی‌دست‌خوردن کار
   می‌کند.

   و چون بعضی تغییرها خودِ جدول را از نو می‌کشند (مثلِ وضعیت در برنامهٔ
   روزانه)، گره هر بار از نو پیدا می‌شود؛ نگه داشتنِ ارجاع یعنی نوشتن
   در گره‌ای که دیگر در صفحه نیست. */
(function () {
  "use strict";

  var TABLES = ["checklistBody", "dailyBody"];
  var box = null, cur = null;   /* cur = {body, idx} */

  function appMode() {
    return document.documentElement.getAttribute("data-app") === "1";
  }

  function rowOf(body, idx) {
    return document.querySelector("#" + body + ' tr[data-idx="' + idx + '"]');
  }

  /* نامِ ستون از سرستونِ همان جدول می‌آید، نه از یک فهرستِ موازی — پس
     ستونی که فردا اضافه شود نامش را خودش با خود می‌آورد. */
  function headOf(tr, cell) {
    try {
      var table = tr.closest("table");
      var head = table && table.tHead && table.tHead.rows[0];
      var th = head && head.cells[cell.cellIndex];
      var txt = th ? th.textContent.replace(/\s+/g, " ").trim() : "";
      return txt || "—";
    } catch (e) { return "—"; }
  }

  function controls(tr) {
    return [].slice.call(tr.querySelectorAll("[data-field], .rep-box, .date-box"));
  }

  function build() {
    if (box) return;
    box = document.createElement("div");
    box.className = "rowsheet";
    box.id = "rowSheet";
    box.hidden = true;
    box.innerHTML = '<div class="rs-scrim" data-close="1"></div>' +
      '<div class="rs-card" role="dialog" aria-label="ویرایشِ ردیف">' +
      '<button type="button" class="rs-grip" data-close="1" aria-label="بستن"></button>' +
      '<div class="rs-ttl" id="rsTitle">ردیف</div>' +
      '<div class="rs-body" id="rsBody"></div>' +
      '<button type="button" class="rs-done" data-close="1">تمام</button></div>';
    document.body.appendChild(box);
    box.addEventListener("click", function (e) {
      if (e.target.getAttribute && e.target.getAttribute("data-close")) close();
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") close();
    });
  }

  /* نوشتن: مقدار روی خانهٔ خودِ جدول می‌نشیند و رویداد می‌رود، عیناً
     مثل وقتی که کاربر داخلِ جدول تایپ کرده باشد. */
  function write(key, val, kind) {
    var tr = rowOf(cur.body, cur.idx);
    if (!tr) return;
    var el = tr.querySelector('[data-field="' + key + '"]');
    if (!el) return;
    if (kind === "check") el.checked = !!val; else el.value = val;
    el.dispatchEvent(new Event(kind === "select" ? "change" : "input", { bubbles: true }));
    if (kind !== "select") el.dispatchEvent(new Event("change", { bubbles: true }));
  }

  function field(c, tr) {
    var td = c.closest("td");
    var label = headOf(tr, td);
    var key = c.getAttribute("data-field");

    if (c.classList.contains("date-box")) {
      return '<label class="rs-f"><span>' + escapeHtml(label) + '</span>' +
        '<button type="button" class="rs-date" data-open-date="1">' +
        escapeHtml(c.textContent.replace(/\s+/g, " ").trim() || "انتخاب") + '</button></label>';
    }
    if (c.classList.contains("rep-box")) {
      return '<label class="rs-f rs-check"><input type="checkbox" data-rep="1"' +
        (c.checked ? " checked" : "") + '><span>ماهِ بعد هم بیاید</span></label>';
    }
    if (c.tagName === "SELECT") {
      return '<label class="rs-f"><span>' + escapeHtml(label) + '</span>' +
        '<select data-k="' + escapeHtml(key) + '">' + c.innerHTML + '</select></label>';
    }
    if (c.readOnly) {
      return '<label class="rs-f"><span>' + escapeHtml(label) + '</span>' +
        '<input type="text" value="' + escapeHtml(c.value) + '" readonly></label>';
    }
    return '<label class="rs-f"><span>' + escapeHtml(label) + '</span>' +
      '<input type="' + (c.type === "number" ? "number" : "text") + '" data-k="' +
      escapeHtml(key) + '" value="' + escapeHtml(c.value) + '"></label>';
  }

  function open(tr) {
    build();
    var body = tr.closest("tbody");
    cur = { body: body.id, idx: tr.getAttribute("data-idx") };
    var list = box.querySelector("#rsBody");
    list.innerHTML = controls(tr).map(function (c) { return field(c, tr); }).join("");

    var num = tr.cells[0] ? tr.cells[0].textContent.trim() : "";
    box.querySelector("#rsTitle").textContent = "ردیف " + num;

    list.querySelectorAll("[data-k]").forEach(function (el) {
      var k = el.getAttribute("data-k");
      var kind = el.tagName === "SELECT" ? "select" : "text";
      el.addEventListener(kind === "select" ? "change" : "input", function () {
        write(k, el.value, kind);
      });
    });
    var rep = list.querySelector("[data-rep]");
    if (rep) rep.addEventListener("change", function () {
      var tr2 = rowOf(cur.body, cur.idx);
      var el = tr2 && tr2.querySelector(".rep-box");
      if (el) { el.checked = rep.checked; el.dispatchEvent(new Event("change", { bubbles: true })); }
    });
    var dateBtn = list.querySelector("[data-open-date]");
    if (dateBtn) dateBtn.addEventListener("click", function () {
      var tr2 = rowOf(cur.body, cur.idx);
      var el = tr2 && tr2.querySelector(".date-box");
      close();
      if (el) setTimeout(function () { el.click(); }, 120);
    });

    box.hidden = false;
    document.documentElement.classList.add("rs-open");
  }

  function close() {
    if (!box || box.hidden) return;
    box.hidden = true;
    document.documentElement.classList.remove("rs-open");
    cur = null;
  }

  /* ---------- راهِ باز کردن ----------
     شمارهٔ ردیف دستهٔ آن ردیف است (در حالتِ برنامه ✎ هم می‌گیرد تا
     معلوم باشد زدنی است). نگه داشتنِ انگشت روی هر جای ردیف هم همان
     کار را می‌کند، برای کسی که شماره را نمی‌بیند. */
  function handleFor(e) {
    if (!appMode()) return null;
    var td = e.target.closest ? e.target.closest("td") : null;
    if (!td || td.cellIndex !== 0) return null;
    var tr = td.closest("tr[data-idx]");
    if (!tr) return null;
    var body = tr.closest("tbody");
    return (body && TABLES.indexOf(body.id) >= 0) ? tr : null;
  }

  document.addEventListener("click", function (e) {
    var tr = handleFor(e);
    if (tr) { e.preventDefault(); open(tr); }
  });

  var hold = null;
  document.addEventListener("pointerdown", function (e) {
    if (!appMode()) return;
    var tr = e.target.closest ? e.target.closest("tr[data-idx]") : null;
    var body = tr && tr.closest("tbody");
    if (!body || TABLES.indexOf(body.id) < 0) return;
    hold = setTimeout(function () { hold = null; open(tr); }, 480);
  });
  ["pointerup", "pointercancel", "pointermove", "scroll"].forEach(function (ev) {
    document.addEventListener(ev, function () { if (hold) { clearTimeout(hold); hold = null; } }, true);
  });

  window.ROWSHEET = { open: open, close: close };
})();
