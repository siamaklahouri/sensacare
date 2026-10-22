/* ==================== پیوستِ فایل ====================
   تصویرِ فاکتور، رسید، کانفیگ — چیزهایی که تا حالا در پیام‌رسان
   می‌ماندند و شش ماه بعد پیدا نمی‌شدند.

   سه نکته:

   • شناسهٔ ردیف. پیوست به «ردیفِ سوم» بسته نمی‌شود، چون با افزودن و
     حذف، ردیفِ سوم فردا چیزِ دیگری است. هر ردیف بارِ اول یک شناسهٔ
     تصادفی می‌گیرد (fid) و پیوست به آن بسته می‌شود.

   • خودِ بایت‌ها از راهِ state نمی‌روند و نمی‌آیند؛ مسیرِ /files
     دارند. state با هر تایپ کامل بالا می‌رود و یک عکس یعنی همان عکس
     در هر تایپ.

   • شمارشِ پیوست‌ها یک بار سرِ بارِ صفحه می‌آید و بعد در حافظه
     به‌روز می‌شود — نه یک درخواست به ازای هر ردیف. */
(function () {
  "use strict";

  var counts = {};          /* fid → تعداد */
  var limits = { file: 4194304, quota: 41943040 };
  var used = 0;
  var box = null, curRef = null, curLabel = "";

  function rnd() {
    var a = new Uint8Array(8);
    crypto.getRandomValues(a);
    return [].map.call(a, function (x) { return x.toString(16).padStart(2, "0"); }).join("");
  }

  /* ردیف شناسه‌اش را همان بار اولی می‌گیرد که کسی پیوستش را باز
     می‌کند — نه زودتر، تا دادهٔ همه با یک مشت شناسهٔ بی‌مصرف پر نشود. */
  function refOf(kind, idx) {
    var arr = kind === "task" ? state.tasks : state.days;
    var row = arr && arr[idx];
    if (!row) return null;
    if (!row.fid) { row.fid = kind.charAt(0) + "-" + rnd(); scheduleSave(); }
    return row.fid;
  }

  function fmtSize(n) {
    if (n < 1024) return fa(n) + " بایت";
    if (n < 1048576) return fa((n / 1024).toFixed(0)) + " کیلوبایت";
    return fa((n / 1048576).toFixed(1)) + " مگابایت";
  }

  async function refresh() {
    if (window.KARTABL_OFFLINE || !signedIn) return;
    var r = await apiCall("/files");
    if (!r.ok) return;
    counts = r.data.counts || {};
    used = r.data.used || 0;
    if (r.data.limits) limits = r.data.limits;
    paintCells();
  }

  function count(fid) { return fid && counts[fid] ? counts[fid] : 0; }

  /* خانهٔ 📎 هر جدول. بی‌رسمِ دوبارهٔ جدول عوض می‌شود تا فهرست نپرد. */
  function paintCells() {
    [].slice.call(document.querySelectorAll(".clip-cell")).forEach(function (td) {
      var kind = td.getAttribute("data-kind");
      var idx = parseInt(td.getAttribute("data-i"), 10);
      var arr = kind === "task" ? state.tasks : state.days;
      var row = arr && arr[idx];
      var n = row ? count(row.fid) : 0;
      var b = td.querySelector(".clip-btn");
      if (!b) return;
      b.classList.toggle("has", n > 0);
      b.textContent = n > 0 ? "📎 " + fa(n) : "📎";
      b.title = n > 0 ? fa(n) + " پیوست" : "افزودن پیوست";
    });
  }

  function build() {
    if (box) return;
    box = document.createElement("div");
    box.className = "rowsheet attachbox";
    box.id = "attachBox";
    box.hidden = true;
    box.innerHTML = '<div class="rs-scrim" data-close="1"></div>' +
      '<div class="rs-card" role="dialog" aria-label="پیوست‌ها">' +
      '<button type="button" class="rs-grip" data-close="1" aria-label="بستن"></button>' +
      '<div class="rs-ttl" id="atTitle">پیوست‌ها</div>' +
      '<div class="at-list" id="atList"></div>' +
      '<label class="at-add">' +
      '<input type="file" id="atFile" hidden accept="image/*,application/pdf,.txt,.zip,.doc,.docx,.xls,.xlsx">' +
      '<span>＋ افزودن فایل</span></label>' +
      '<div class="at-note" id="atNote"></div>' +
      '<button type="button" class="rs-done" data-close="1">تمام</button></div>';
    document.body.appendChild(box);
    box.addEventListener("click", function (e) {
      if (e.target.getAttribute && e.target.getAttribute("data-close")) close();
    });
    box.querySelector("#atFile").addEventListener("change", onPick);
    box.querySelector("#atList").addEventListener("click", onListClick);
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && box && !box.hidden) close();
    });
  }

  function note(t, bad) {
    var el = box.querySelector("#atNote");
    el.textContent = t || "";
    el.classList.toggle("bad", !!bad);
  }

  async function paintList() {
    var list = box.querySelector("#atList");
    list.innerHTML = '<div class="at-empty">در حال خواندن…</div>';
    var r = await apiCall("/files?ref=" + encodeURIComponent(curRef));
    var files = (r.ok && r.data.files) || [];
    counts[curRef] = files.length;
    paintCells();
    if (!files.length) {
      list.innerHTML = '<div class="at-empty">هنوز فایلی پیوست نشده.</div>';
      return;
    }
    list.innerHTML = files.map(function (f) {
      return '<div class="at-row">' +
        '<a class="at-name" href="' + escapeHtml(KARTABL_API + "/files/" + f.id) + '" download>' +
        escapeHtml(f.name) + '</a>' +
        '<span class="at-size">' + escapeHtml(fmtSize(f.size)) + '</span>' +
        '<button type="button" class="at-del" data-del="' + escapeHtml(f.id) + '" title="حذف">✕</button>' +
        '</div>';
    }).join("");
  }

  async function onListClick(e) {
    var btn = e.target.closest ? e.target.closest(".at-del") : null;
    if (!btn) return;
    if (!confirm("این فایل پاک شود؟")) return;
    var r = await apiCall("/files/" + btn.getAttribute("data-del"), { method: "DELETE" });
    if (!r.ok) { note((r.data && r.data.error) || "پاک نشد.", true); return; }
    note("پاک شد.");
    await refreshUsed();
    paintList();
  }

  async function refreshUsed() {
    var r = await apiCall("/files");
    if (r.ok) { counts = r.data.counts || {}; used = r.data.used || 0; paintCells(); }
  }

  function onPick(e) {
    var f = e.target.files && e.target.files[0];
    e.target.value = "";
    if (!f) return;
    if (f.size > limits.file) {
      note("هر فایل تا " + fa(Math.round(limits.file / 1048576)) + " مگابایت.", true);
      return;
    }
    note("در حال فرستادن…");
    var fr = new FileReader();
    fr.onload = async function () {
      var b64 = String(fr.result || "").split(",")[1] || "";
      var r = await apiCall("/files", { method: "POST", body: JSON.stringify({
        ref: curRef, name: f.name, type: f.type || "application/octet-stream", data: b64 }) });
      if (!r.ok) { note((r.data && r.data.error) || "فرستاده نشد.", true); return; }
      note("اضافه شد.");
      await refreshUsed();
      paintList();
    };
    fr.onerror = function () { note("فایل خوانده نشد.", true); };
    fr.readAsDataURL(f);
  }

  function open(kind, idx, label) {
    if (window.KARTABL_OFFLINE) { alert("روی نسخهٔ پشتیبان، پیوست‌ها در دسترس نیستند."); return; }
    var ref = refOf(kind, idx);
    if (!ref) return;
    build();
    curRef = ref;
    curLabel = label || "";
    box.querySelector("#atTitle").textContent = "پیوست‌های: " + (curLabel || "این ردیف");
    note("جای پیوست‌ها: " + fmtSize(used) + " از " + fmtSize(limits.quota));
    box.hidden = false;
    document.documentElement.classList.add("rs-open");
    paintList();
  }

  function close() {
    if (!box || box.hidden) return;
    box.hidden = true;
    document.documentElement.classList.remove("rs-open");
    curRef = null;
  }

  /* خانه‌های 📎 را خودِ رسمِ جدول می‌سازد؛ این‌جا فقط زدنشان را
     می‌گیریم — یک شنونده روی کلِ صفحه، نه یکی به ازای هر ردیف. */
  document.addEventListener("click", function (e) {
    var b = e.target.closest ? e.target.closest(".clip-btn") : null;
    if (!b) return;
    var td = b.closest(".clip-cell");
    if (!td) return;
    e.preventDefault();
    var kind = td.getAttribute("data-kind");
    var idx = parseInt(td.getAttribute("data-i"), 10);
    var arr = kind === "task" ? state.tasks : state.days;
    var row = (arr && arr[idx]) || {};
    open(kind, idx, row.task || row.main || "");
  });

  window.ATTACH = { refresh: refresh, paint: paintCells, count: count, open: open, close: close };
})();
