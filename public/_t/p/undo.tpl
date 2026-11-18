/* ==================== حذف، با راهِ برگشت ====================
   در هر دو کارتابل چهارده جا ردیف حذف می‌شد و همه یک الگو داشتند:
   یک پنجرهٔ confirm مرورگر، و بعد ردیف برای همیشه رفته.

   آن پنجره دو کار می‌کرد که هیچ‌کدام خوب نبود: کارِ روزمره را کُند
   می‌کرد، و با همهٔ کُندی‌اش محافظت هم نمی‌کرد — اگر اشتباهی تأیید
   می‌شد، تنها راه برگرداندنِ کلِ یک نسخهٔ پشتیبان بود.

   این‌جا جایش را می‌گیرد: یک کادرِ فارسیِ خودمان می‌پرسد «حذف شود؟»
   و نامِ همان ردیف را می‌گوید (ASKDEL، پایین‌تر)؛ و بعد از حذف هم یک
   نوارِ کوچک هشت ثانیه می‌ماند که با یک کلیک ردیف را دقیقاً سرِ جای
   خودش برمی‌گرداند. هم می‌پرسد، هم اگر پاسخِ اشتباه داده شد راهِ
   برگشت دارد — چون پرسیدن تنها، محافظت نیست: آدم پنجره‌ای را که هر
   روز می‌بیند، بی‌خواندن تأیید می‌کند.

   «برگرداندن» باید جای ردیف را هم برگرداند، نه فقط خودش را: هر
   فراخوان با splice(idx, 0, item) می‌نویسد، نه push. ردیفی که ته
   فهرست برگردد، برگشتِ نصفه است. */
(function () {
  "use strict";

  var SPAN = 8000;
  var box = null, timer = null, pending = null;

  function build() {
    if (box) return box;
    box = document.createElement("div");
    box.className = "undo-bar";
    box.setAttribute("role", "status");
    box.setAttribute("aria-live", "polite");
    box.hidden = true;
    box.innerHTML =
      '<span class="ub-txt"></span>' +
      '<button type="button" class="ub-go">برگرداندن</button>' +
      '<button type="button" class="ub-x" aria-label="بستن">✕</button>' +
      '<span class="ub-bar"></span>';
    document.body.appendChild(box);
    box.addEventListener("click", function (e) {
      if (e.target.closest(".ub-go")) { run(); return; }
      if (e.target.closest(".ub-x")) hide();
    });
    document.addEventListener("keydown", function (e) {
      if (box.hidden) return;
      if (e.key === "Escape") hide();
    });
    return box;
  }

  function hide() {
    if (timer) { clearTimeout(timer); timer = null; }
    pending = null;
    if (box) box.hidden = true;
  }

  function run() {
    var fn = pending;
    hide();
    if (typeof fn === "function") {
      try { fn(); } catch (e) { console.error("[برگرداندن]", e); }
    }
  }

  /* label: چه چیزی حذف شد. revert: همان را سرِ جایش برگردان. */
  function show(label, revert) {
    var el = build();
    pending = revert;
    el.querySelector(".ub-txt").textContent = label;
    el.hidden = false;
    /* نوارِ زمان از نو شروع شود، حتی اگر نوار از قبل باز بوده */
    var bar = el.querySelector(".ub-bar");
    bar.style.animation = "none";
    void bar.offsetWidth;
    bar.style.animation = "";
    if (timer) clearTimeout(timer);
    timer = setTimeout(hide, SPAN);
  }

  window.UNDO = { show: show, hide: hide, SPAN: SPAN };
})();

/* ==================== یک پرسش، پیش از حذف ====================
   نوارِ برگرداندن هست، ولی هشت ثانیه می‌ماند و بعد می‌رود. اگر کسی
   اشتباهی کلیک کند و همان لحظه حواسش جای دیگری باشد، فرصت را از دست
   می‌دهد. پس هم می‌پرسیم، هم راهِ برگشت را باز می‌گذاریم.

   این پرسش، confirm مرورگر نیست: آن پنجره انگلیسی و چپ‌به‌راست است،
   نشانیِ سایت را بالای خودش می‌نویسد، و نمی‌شود گفت چه چیزی دارد حذف
   می‌شود. این‌جا نامِ همان ردیف در متنِ پرسش هست.

   دکمهٔ آغازین «بی‌خیال» است، نه «حذف کن»: اگر کسی ناخودآگاه Enter
   بزند، چیزی حذف نمی‌شود. */
(function () {
  "use strict";

  var ov = null, yes = null, back = null;

  function build() {
    if (ov) return ov;
    ov = document.createElement("div");
    ov.className = "dq-ov";
    ov.hidden = true;
    ov.innerHTML =
      '<div class="dq" role="dialog" aria-modal="true" aria-labelledby="dq-h">' +
        '<div class="dq-ic" aria-hidden="true">' +
          '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" ' +
          'stroke-linecap="round" stroke-linejoin="round">' +
          '<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/></svg>' +
        '</div>' +
        '<div class="dq-h" id="dq-h">حذف شود؟</div>' +
        '<div class="dq-p"></div>' +
        '<div class="dq-f">' +
          '<button type="button" class="dq-no">بی‌خیال</button>' +
          '<button type="button" class="dq-yes">حذف کن</button>' +
        '</div>' +
      '</div>';
    document.body.appendChild(ov);
    ov.addEventListener("click", function (e) {
      if (e.target.closest(".dq-yes")) { go(); return; }
      /* کلیک روی پشتِ کادر هم «بی‌خیال» است */
      if (e.target.closest(".dq-no") || e.target === ov) close();
    });
    document.addEventListener("keydown", function (e) {
      if (!ov || ov.hidden) return;
      if (e.key === "Escape") { e.preventDefault(); close(); }
    });
    return ov;
  }

  function close() {
    yes = null;
    if (ov) ov.hidden = true;
    /* کاربر را سرِ همان جایی که بود برگردان */
    try { if (back && back.focus) back.focus(); } catch (e) {}
    back = null;
  }

  function go() {
    var fn = yes;
    close();
    if (typeof fn === "function") {
      try { fn(); } catch (e) { console.error("[حذف]", e); }
    }
  }

  /* label: همان چیزی که delRow هم می‌نویسد — «وظیفهٔ «...»» */
  function ask(label, onYes) {
    var el = build();
    yes = onYes;
    back = document.activeElement;
    el.querySelector(".dq-p").textContent =
      label + " حذف می‌شود. تا چند ثانیه می‌شود برگرداندش.";
    el.hidden = false;
    /* نشانگر روی «بی‌خیال» می‌نشیند: Enterِ ناخواسته چیزی نمی‌برد */
    try { el.querySelector(".dq-no").focus(); } catch (e) {}
  }

  window.ASKDEL = ask;
})();

/* کوتاه‌نویسِ همان کار برای ردیف‌های آرایه‌ای — چهارده جا همین است:
   ردیف را بردار، صفحه را تازه کن، و راهِ برگشت را بگذار. */
function delRow(arr, idx, label, after) {
  if (!arr || idx < 0 || idx >= arr.length) return;
  ASKDEL(label, function () {
    /* دوباره می‌سنجیم: بینِ پرسش و پاسخ، صفحه ممکن است تازه شده باشد */
    if (idx < 0 || idx >= arr.length) return;
    var item = arr[idx];
    arr.splice(idx, 1);
    if (typeof after === "function") after();
    try {
      UNDO.show(label + ' حذف شد', function () {
        arr.splice(idx, 0, item);
        if (typeof after === "function") after();
      });
    } catch (e) { console.error('[حذف]', e); }
  });
}
