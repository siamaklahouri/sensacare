/* ==================== «تازه چه خبر؟» ====================
   بخشِ تازه‌ای که به کارتابل اضافه می‌شد، تا وقتی کسی اتفاقی نمی‌دیدش
   کشف نمی‌شد — آدم‌ها نوارِ کنار را از بالا تا پایین نمی‌خوانند، کارشان
   را می‌کنند و می‌روند.

   حالا خبرها از سرور می‌آیند، ولی فقط آن‌هایی که ادمین فرستاده باشد.
   اگر خبرِ نخوانده‌ای بود، یک بار — و فقط یک بار — پنجره‌اش باز
   می‌شود؛ بعد از آن در زنگوله می‌ماند تا هر وقت خواست بخواندش.

   «خوانده‌شده» در همان bellSeen می‌نشیند که با state همگام می‌شود:
   کاربر از دو دستگاه وارد می‌شود و نباید دو بار همان پنجره را
   ببیند. */
(function () {
  "use strict";

  var LIST = [];
  var shown = false;

  function esc(s) {
    try { return escapeHtml(String(s == null ? "" : s)); }
    catch (e) { return String(s == null ? "" : s).replace(/[&<>"]/g, ""); }
  }
  function keyOf(n) { return "news|" + n.id; }
  function seen() {
    try { return Array.isArray(state.bellSeen) ? state.bellSeen : []; }
    catch (e) { return []; }
  }
  function unread() {
    var s = seen();
    return LIST.filter(function (n) { return s.indexOf(keyOf(n)) < 0; });
  }

  function markRead(items) {
    try {
      if (!Array.isArray(state.bellSeen)) state.bellSeen = [];
      (items || LIST).forEach(function (n) {
        var k = keyOf(n);
        if (state.bellSeen.indexOf(k) < 0) state.bellSeen.push(k);
      });
      scheduleSave();
      /* و همان لحظه بالا می‌رود، نه با مکثِ معمولِ ذخیره: کسی که
         «فهمیدم» را می‌زند ممکن است همان ثانیه صفحه را ببندد، و
         دفعهٔ بعد همان پنجره دوباره جلویش می‌پرید. */
      if (window.Cloud && Cloud.pushNow) Cloud.pushNow();
    } catch (e) { }
    try { if (window.BELL) BELL.refresh(); } catch (e) { }
  }

  /* ---------- پنجره ---------- */
  function close(mark) {
    var box = document.getElementById("nwBox");
    if (box) box.hidden = true;
    if (mark) markRead();
  }

  function open(only) {
    var items = (only && only.length) ? only : LIST;
    if (!items.length) return;
    var box = document.getElementById("nwBox");
    if (!box) {
      box = document.createElement("div");
      box.id = "nwBox";
      box.className = "nwbox";
      document.body.appendChild(box);
      box.addEventListener("click", function (e) {
        if (e.target.closest(".nw-x") || e.target.closest(".nw-ok") ||
            e.target.classList.contains("nw-scrim")) close(true);
      });
    }
    var s = seen();
    box.innerHTML =
      '<div class="nw-scrim"></div>' +
      '<div class="nw-card" role="dialog" aria-label="خبرهای تازه">' +
        '<div class="nw-h">تازه چه خبر؟' +
          '<button type="button" class="nw-x" title="بستن">✕</button></div>' +
        '<div class="nw-l">' + items.map(function (n) {
          return '<div class="nw-i' + (s.indexOf(keyOf(n)) < 0 ? " new" : "") + '">' +
            '<span class="nw-ic">' + esc(n.icon || "📣") + '</span>' +
            '<div><b>' + esc(n.title) + '</b>' +
              (n.body ? '<p>' + esc(n.body) + '</p>' : "") + '</div></div>';
        }).join("") + '</div>' +
        '<div class="nw-f"><button type="button" class="nw-ok">فهمیدم</button></div>' +
      '</div>';
    box.hidden = false;
  }

  /* ---------- زنگوله ----------
     خبرِ خوانده‌نشده همان‌جایی می‌نشیند که بقیهٔ خبرها می‌نشینند. */
  function bellItems() {
    return unread().map(function (n) {
      return { kind: "info", icon: n.icon || "📣",
               title: n.title, body: n.body || "",
               key: keyOf(n), go: function () { open([n]); } };
    });
  }

  async function load() {
    try {
      var r = await apiCall("/news");
      if (!r.ok) return;
      LIST = (r.data && r.data.news) || [];
    } catch (e) { return; }
    try { if (window.BELL) BELL.refresh(); } catch (e) { }
    /* یک بار، و فقط وقتی واقعاً چیزی نخوانده مانده */
    var u = unread();
    if (u.length && !shown) { shown = true; setTimeout(function () { open(u); }, 1200); }
  }

  function init() {
    try { if (window.BELL) BELL.add(bellItems); } catch (e) { }
    load();
  }

  window.NEWS = { init: init, open: open, close: close, list: function () { return LIST; },
                  unread: unread, reload: load };
})();
