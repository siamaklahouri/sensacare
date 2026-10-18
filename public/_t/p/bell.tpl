/* ==================== زنگوله‌ی خبرها ====================
   تا امروز خبرها پراکنده بودند: مهلتِ کارتابل یک پنجرهٔ تمام‌صفحه
   می‌شد، یادآورها یک مودال، و نخوانده‌های چت فقط یک نشانِ کوچک روی
   دکمهٔ شناور. حالا همه یک جا جمع‌اند، کنارِ ساعت.

   دو تصمیم:

   یک) خبرها «خوانده» می‌شوند. هر خبر یک کلید دارد که از محتوایش
       ساخته شده؛ با زدنِ «همه را دیدم» کلیدها در state می‌نشینند و
       شمارنده صفر می‌شود. خبری که عوض شود — مثلاً یک کارِ عقب‌افتادهٔ
       تازه — کلیدِ تازه دارد و دوباره شمرده می‌شود. این‌طور شمارنده
       روی یک عددِ همیشگی گیر نمی‌کند.

   دو) خبرِ دیده‌شده پاک نمی‌شود، فقط کم‌رنگ می‌شود. فهرست همان است،
       فقط شمارنده خاموش است.

   جای نگه‌داریِ «دیده‌شده‌ها» خودِ state است، نه مرورگر: کاربر از دو
   دستگاه وارد می‌شود و نباید دو بار همان خبر را ببیند. */
(function () {
  "use strict";

  var SRC = [];                 /* منبع‌های بیرونی: چت، بخش‌های مشترک */
  var closePop = function () { };
  var MAX_SEEN = 240;           /* کلیدهای قدیمی دور ریخته می‌شوند */

  function faN(n) {
    try { return fa(String(n)); } catch (e) { return String(n); }
  }
  function esc(s) {
    try { return escapeHtml(String(s == null ? "" : s)); }
    catch (e) { return String(s == null ? "" : s).replace(/[&<>"]/g, ""); }
  }
  function st() { try { return state; } catch (e) { return null; } }
  function latin(s) {
    return String(s == null ? "" : s)
      .replace(/[۰-۹]/g, function (d) { return String("۰۱۲۳۴۵۶۷۸۹".indexOf(d)); })
      .replace(/[٠-٩]/g, function (d) { return String("٠١٢٣٤٥٦٧٨٩".indexOf(d)); });
  }
  function today() {
    try { return latin(getTodayJalaliStr()); } catch (e) { return ""; }
  }
  var isDone = function (v) { return String(v == null ? "" : v).trim() === "انجام شد"; };

  /* «برو به دیتای شخصی» = زدنِ همان دکمهٔ نوارِ کنار. این‌طور صفحهٔ
     قفل و پرسیدنِ رمز هم سرِ جای خودش می‌ماند و این‌جا تکرار نمی‌شود. */
  function goPersonal() {
    var nb = document.querySelector('.navbtn[data-view="personal"]');
    if (nb) { nb.click(); nb.scrollIntoView({ block: "nearest" }); }
  }

  /* ---------- دیده‌شده‌ها ---------- */
  function seenList() {
    var s = st();
    if (!s) return [];
    if (!Array.isArray(s.bellSeen)) s.bellSeen = [];
    return s.bellSeen;
  }
  function isSeen(k) { return seenList().indexOf(k) >= 0; }
  function markAll(items) {
    var s = st();
    if (!s) return;
    var keep = seenList().slice();
    items.forEach(function (i) { if (keep.indexOf(i.key) < 0) keep.push(i.key); });
    if (keep.length > MAX_SEEN) keep = keep.slice(keep.length - MAX_SEEN);
    s.bellSeen = keep;
    try { scheduleSave(); } catch (e) { }
  }

  /* ---------- خبرها ---------- */
  function items() {
    var out = [];
    var add = function (kind, icon, title, body, key, go) {
      out.push({ kind: kind, icon: icon, title: title, body: body, key: key, go: go });
    };
    var s = st();

    /* مهلتِ کارتابل */
    var until = Number(window.KARTABL_UNTIL || 0);
    if (until) {
      var left = Math.ceil((until - Date.now()) / 864e5);
      if (left <= 0)
        add("bad", "⏳", "مهلتِ کارتابل تمام شده", "برای ادامه با مدیر تماس بگیرید.", "exp-over");
      else if (left <= 7)
        add("warn", "⏳", "مهلتِ کارتابل نزدیک است", faN(left) + " روز مانده.", "exp-soon");
    }

    /* کارهای عقب‌افتادهٔ چک‌لیست */
    if (s && Array.isArray(s.tasks)) {
      var td = today();
      var late = s.tasks.filter(function (t) {
        var d = latin(t && t.deadline);
        return d && td && d < td && !isDone(t.status);
      }).map(function (t) { return String(t.task || "").trim() || "بی‌عنوان"; });
      if (late.length) {
        var head = late.slice(0, 3).join("، ");
        add("bad", "⚠️", "کارهای عقب‌افتاده",
          head + (late.length > 3 ? " و " + faN(late.length - 3) + " تای دیگر" : ""),
          "late|" + late.slice().sort().join("|"));
      }
    }

    /* یادآورهای ستاره‌دارِ برنامهٔ روزانه — شکلِ هر دو قالب */
    if (s && Array.isArray(s.days)) {
      var rem = s.days.filter(function (d) {
        if (!d) return false;
        if (d.important && d.reminderAt && !d.reminderFired) return true;
        if (d.reminder && !d.reminder.fired) return true;
        return false;
      }).map(function (d) { return String(d.main || "").trim() || "بی‌عنوان"; });
      if (rem.length)
        add("warn", "⭐", "یادآورهای برنامهٔ روزانه",
          rem.slice(0, 3).join("، ") + (rem.length > 3 ? " و " + faN(rem.length - 3) + " تای دیگر" : ""),
          "rem|" + rem.slice().sort().join("|"));
    }

    /* تلاشِ ناموفقِ ورود به همین کارتابل */
    var bp = window.__badPass;
    if (bp && Number(bp.n)) {
      var when = "";
      try { when = faDateTime(Number(bp.at)); } catch (e) { }
      add("bad", "🔐", "با رمزِ اشتباه وارد شدن را امتحان کرده‌اند",
        faN(bp.n) + " بار" + (when ? " — آخرین بار: " + when : "") +
        ". اگر خودتان نبوده‌اید، رمز را عوض کنید.",
        "badpass|" + bp.n);
    }

    /* سررسیدِ قسط یا چک — از «دیتای شخصی»
       این‌جا هیچ‌چیز از محتوای صندوق گفته نمی‌شود: نه عنوان، نه مبلغ،
       نه حتی اینکه قسط است یا چک. فقط «چند مورد» و «کِی» — همان‌قدر
       که برای خبر کردن لازم است. جزئیات را خودِ صفحهٔ دیتای شخصی
       می‌گوید، بعد از اینکه کاربر رمزش را زد. */
    var due = null;
    try { due = window.vaultDueDigest ? window.vaultDueDigest() : null; } catch (e) { due = null; }
    if (due && due.n) {
      var say = [];
      if (due.late) say.push(faN(due.late) + " سررسیدِ عقب‌افتاده");
      if (due.soon) say.push(faN(due.soon) + " سررسید تا " + faN(due.days) + " روز آینده");
      add(due.late ? "bad" : "warn", "🔔", "دیتای شخصی",
        say.join(" و ") + " (قسط یا چک). برای دیدنش رمزِ دیتای شخصی را بزنید.",
        "vdue|" + due.n + "|" + due.nearest, goPersonal);
    }

    /* نخوانده‌های گفت‌وگو و بخش‌های مشترک — این دو خودشان خبر می‌دهند */
    var ch = Number(window.CHAT_UNREAD || 0);
    if (ch) add("info", "💬", "پیامِ خوانده‌نشده",
      faN(ch) + " پیامِ تازه در گفت‌وگوها.", "chat|" + ch);
    var sh = Number(window.SHARED_UNREAD || 0);
    if (sh) add("info", "✅", "تغییر در بخش‌های مشترک",
      faN(sh) + " تغییرِ تازه.", "shared|" + sh);

    /* منبع‌های دیگری که خودشان را ثبت کرده‌اند */
    SRC.forEach(function (fn) {
      try { (fn() || []).forEach(function (i) { if (i && i.key) out.push(i); }); } catch (e) { }
    });
    return out;
  }

  /* ---------- ساختنِ دکمه و پنجره ---------- */
  function build() {
    var bar = document.querySelector(".topbar .period");
    if (!bar || document.getElementById("bellBtnK")) return;
    var wrap = document.createElement("div");
    wrap.className = "bellw";
    wrap.innerHTML =
      '<button type="button" class="bellb" id="bellBtnK" title="خبرها" aria-expanded="false">🔔</button>' +
      '<div class="bellp" id="bellPopK" hidden>' +
        '<div class="bellh"><span>خبرها</span>' +
          '<button type="button" id="bellXK" title="بستن">✕</button></div>' +
        '<div class="bell-l" id="bellListK"></div>' +
        '<div class="bell-f"><button type="button" id="bellSeenK">همه را دیدم</button></div>' +
      '</div>';
    var theme = bar.querySelector("#themeBtn");
    if (theme) bar.insertBefore(wrap, theme); else bar.appendChild(wrap);

    var btn = document.getElementById("bellBtnK");
    var pop = document.getElementById("bellPopK");
    var close = function () { pop.hidden = true; btn.setAttribute("aria-expanded", "false"); };
    closePop = close;
    btn.addEventListener("click", function (e) {
      e.stopPropagation();
      var open = pop.hidden;
      if (open) paint();
      pop.hidden = !open;
      btn.setAttribute("aria-expanded", open ? "true" : "false");
    });
    document.getElementById("bellXK").addEventListener("click", close);
    document.getElementById("bellSeenK").addEventListener("click", function () {
      markAll(items());
      paint();
    });
    document.addEventListener("click", function (e) {
      if (!pop.hidden && !pop.contains(e.target) && e.target !== btn) close();
    });
    document.addEventListener("keydown", function (e) { if (e.key === "Escape") close(); });
    paint();
    setInterval(paint, 30000);
  }

  function paint() {
    var btn = document.getElementById("bellBtnK");
    var list = document.getElementById("bellListK");
    if (!btn || !list) return;
    var all = items();
    var unseen = all.filter(function (i) { return !isSeen(i.key); });
    /* شمارنده فقط خبرهای نخوانده را می‌شمارد — و همین است که دیگر روی
       یک عدد گیر نمی‌کند. */
    var dot = btn.querySelector(".nd");
    if (unseen.length) {
      if (!dot) { dot = document.createElement("span"); dot.className = "nd"; btn.appendChild(dot); }
      dot.textContent = faN(unseen.length);
    } else if (dot) dot.remove();

    list.innerHTML = all.length ? all.map(function (i, n) {
      return '<div class="bell-i k-' + i.kind + (isSeen(i.key) ? " seen" : "") +
        (i.go ? ' go" data-bi="' + n : "") + '">' +
        '<span class="ic">' + i.icon + '</span>' +
        '<div class="tx"><b>' + esc(i.title) + '</b><p>' + esc(i.body) + '</p>' +
        (i.go ? '<span class="bell-go">نشانم بده ›</span>' : "") + '</div></div>';
    }).join("") : '<div class="bell-e">فعلاً خبری نیست.</div>';

    /* خبری که جایی برای رفتن دارد، زدنی است — و با زدنش همان یکی
       «دیده‌شده» می‌شود، نه همهٔ فهرست. */
    list.onclick = function (e) {
      var el = e.target && e.target.closest ? e.target.closest(".bell-i[data-bi]") : null;
      if (!el) return;
      var it = all[Number(el.getAttribute("data-bi"))];
      if (!it || typeof it.go !== "function") return;
      markAll([it]);
      closePop();
      try { it.go(); } catch (err) { }
      paint();
    };

    var sb = document.getElementById("bellSeenK");
    if (sb) sb.disabled = !unseen.length;
  }

  window.BELL = {
    add: function (fn) { if (typeof fn === "function") { SRC.push(fn); paint(); } },
    refresh: paint
  };

  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", build);
  else build();
})();
