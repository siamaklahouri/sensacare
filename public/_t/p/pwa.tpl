/* ==================== کارتابل روی گوشی، به شکلِ برنامه ====================
   سه کار، و هر سه از یک جنس‌اند: اینکه کارتابل روی گوشی مثلِ یک
   برنامه باشد، نه یک صفحهٔ وب داخلِ مرورگر.

   یک) ثبتِ سرویس‌ورکر — بی آن، اندروید اصلاً دکمهٔ «نصب» نشان نمی‌دهد
   و صفحه بی‌اینترنت باز نمی‌شود.
   دو) دکمهٔ نصب — اندروید خودش یک بار پیشنهاد می‌دهد و اگر رد شد دیگر
   نمی‌پرسد؛ پس پیشنهادش را نگه می‌داریم تا هر وقت کاربر خواست، از
   تنظیمات نصب کند.
   سه) وقتی برنامه نصب شده باز می‌شود، نوارِ پایینی می‌آید: چهار بخشِ
   پرکار به‌علاوهٔ «بخش‌ها» که بقیه را در یک کشوی پایینی باز می‌کند.

   نوارِ پایینی فقط در حالتِ نصب‌شده است. داخلِ مرورگر همان منوی
   همیشگی سرِ جایش می‌ماند — کسی که با مرورگر باز می‌کند نباید یک
   چیدمانِ تازه تحویل بگیرد. */
(function () {
  "use strict";

  var SW = "/sw.js";
  var BASE = (function () {
    var m = String(location.pathname || "/").match(/^\/[^\/]+\//);
    return m ? m[0] : "/";
  })();
  /* دکمه‌هایی که روی نوارِ پایینی می‌نشینند، به همین ترتیب. هر کدام
     نبود (ادمین بسته باشد) از قلم می‌افتد و جایش را بعدی می‌گیرد. */
  var BAR = ["dashboard", "daily", "checklist", "personal", "invoices", "settings"];
  var MAX = 4;

  var deferred = null;        /* پیشنهادِ نصبِ اندروید، نگه‌داشته */
  var waiting = null;         /* نسخهٔ تازهٔ سرویس‌ورکر، منتظرِ اجازه */

  function app(){
    try{
      return matchMedia("(display-mode: standalone)").matches ||
             matchMedia("(display-mode: minimal-ui)").matches ||
             navigator.standalone === true;
    }catch(e){ return false; }
  }

  /* ---------- رنگِ نوارِ وضعیتِ گوشی ----------
     همان رنگِ کاغذِ کارتابل. تمِ شب و تم‌های رنگی هر دو این را عوض
     می‌کنند، پس از خودِ صفحه خوانده می‌شود نه از یک عددِ ثابت. */
  function tint(){
    var el = document.querySelector('meta[name="theme-color"]');
    if(!el){
      el = document.createElement("meta");
      el.setAttribute("name", "theme-color");
      document.head.appendChild(el);
    }
    var c = "";
    try{ c = getComputedStyle(document.body).backgroundColor; }catch(e){}
    if(c && c.indexOf("rgba(0, 0, 0, 0)") < 0) el.setAttribute("content", c);
  }

  /* ---------- نشانه‌ها و نامِ بخش‌ها ----------
     از خودِ دکمه‌های منو خوانده می‌شود، نه از یک فهرستِ موازی: بخشی که
     ادمین بسته باشد اصلاً در صفحه نیست، و بخشی که فردا اضافه شود
     بی‌دست‌زدن به این فایل می‌آید. */
  function buttons(){
    return [].slice.call(document.querySelectorAll(".nav-list .navbtn"));
  }
  /* ---------- نشانه‌های خودِ برنامه ----------
     منوی مرورگری ایموجی دارد و همان‌جا خوب است: رنگی است و سریع
     خوانده می‌شود. ولی روی نوارِ پایینی، ایموجی‌های سیستم هر کدام از
     یک خانواده‌اند — یکی تخت، یکی براق، یکی با سایه — و ردیفشان
     ناهماهنگ دیده می‌شود. این‌ها یک خانواده‌اند: خطِ یک‌دست، و رنگ را
     از خودِ دکمه می‌گیرند، پس در حالتِ فعال و در شب هم درست‌اند.

     هر بخشی که این‌جا نباشد نشانهٔ پیش‌فرض می‌گیرد، پس بخشِ تازه
     چیزی را نمی‌شکند. */
  var ICONS = {
    dashboard: '<rect x="3" y="3" width="8" height="8" rx="2"/><rect x="13" y="3" width="8" height="5" rx="2"/>' +
               '<rect x="13" y="10" width="8" height="11" rx="2"/><rect x="3" y="13" width="8" height="8" rx="2"/>',
    checklist: '<path d="M10 5.5h10M10 12h10M10 18.5h10"/>' +
               '<path d="M3.6 5.4l1.2 1.2 2.2-2.6M3.6 11.9l1.2 1.2 2.2-2.6M3.6 18.4l1.2 1.2 2.2-2.6"/>',
    daily:     '<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M8 2.8v4M16 2.8v4M3 10h18"/>' +
               '<path d="M7.6 14.3h.01M12 14.3h.01M16.4 14.3h.01M7.6 17.8h.01M12 17.8h.01"/>',
    cal:       '<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M8 2.8v4M16 2.8v4M3 10h18"/>' +
               '<rect x="6.6" y="13" width="4" height="3.6" rx="1"/>',
    personal:  '<rect x="4" y="10" width="16" height="11" rx="3"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/>' +
               '<path d="M12 14.6v2.8"/>',
    settings:  '<path d="M3.5 7.5h9M16.5 7.5h4M3.5 16.5h4M11.5 16.5h9"/>' +
               '<circle cx="14.5" cy="7.5" r="2.3"/><circle cx="8.5" cy="16.5" r="2.3"/>',
    servers:   '<rect x="3" y="4" width="18" height="7" rx="2.2"/><rect x="3" y="13" width="18" height="7" rx="2.2"/>' +
               '<path d="M6.8 7.5h.01M6.8 16.5h.01"/>',
    companies: '<path d="M4 21V5.8A1.8 1.8 0 0 1 5.8 4h7.4A1.8 1.8 0 0 1 15 5.8V21"/>' +
               '<path d="M15 10.5h3.2A1.8 1.8 0 0 1 20 12.3V21"/><path d="M7.6 8h3.8M7.6 12h3.8M7.6 16h3.8M2.5 21h19"/>',
    mvpn:      '<rect x="6.2" y="2.5" width="11.6" height="19" rx="3"/><path d="M10.4 18.6h3.2"/>',
    datetools: '<rect x="4" y="3" width="16" height="18" rx="3"/><path d="M7.8 7.6h8.4"/>' +
               '<path d="M8 12.4h3M8 16.4h3M15.4 11.4v4M13.4 13.4h4"/>',
    report:    '<path d="M14 3H7.4A2.4 2.4 0 0 0 5 5.4v13.2A2.4 2.4 0 0 0 7.4 21h9.2a2.4 2.4 0 0 0 2.4-2.4V8z"/>' +
               '<path d="M14 3v5h5"/><path d="M9 17.5v-3M12 17.5v-5.5M15 17.5v-2"/>',
    veeam:     '<path d="M12 2.8l7.2 3v5.4c0 4.5-3 8.4-7.2 10-4.2-1.6-7.2-5.5-7.2-10V5.8z"/><path d="M9 11.8l2.2 2.2 4-4.2"/>',
    assistant: '<path d="M11.2 3.2l1.5 3.9 3.9 1.5-3.9 1.5-1.5 3.9-1.5-3.9L5.8 8.6l3.9-1.5z"/>' +
               '<path d="M17.6 14.4l.8 2 2 .8-2 .8-.8 2-.8-2-2-.8 2-.8z"/>',
    guide:     '<path d="M5 4.6A2.6 2.6 0 0 1 7.6 2H19v17.4H7.6A2.6 2.6 0 0 0 5 22z"/><path d="M5 17.4A2.6 2.6 0 0 1 7.6 15H19"/>',
    invoices:  '<path d="M6 2.6h12v18.8l-2.4-1.6-2.4 1.6-2.4-1.6-2.4 1.6L6 19.8z"/><path d="M9.4 8h5.2M9.4 12.2h5.2"/>',
    payables:  '<circle cx="12" cy="12" r="9"/><path d="M12 16.4V7.8M8.6 11.2L12 7.8l3.4 3.4"/>',
    payablenotes: '<circle cx="12" cy="12" r="9"/><path d="M12 16.4V7.8M8.6 11.2L12 7.8l3.4 3.4"/>',
    receivablenotes: '<circle cx="12" cy="12" r="9"/><path d="M12 7.6v8.6M8.6 12.8L12 16.2l3.4-3.4"/>',
    expenses:  '<rect x="3" y="6" width="18" height="13" rx="3"/><path d="M3 10.2h18"/><path d="M16.8 14.6h.01"/>',
    bank:      '<path d="M12 3l9 4.6H3z"/><path d="M5.2 8.4v8.2M9.7 8.4v8.2M14.3 8.4v8.2M18.8 8.4v8.2M3 20h18"/>',
    budget:    '<circle cx="12" cy="12" r="9"/><path d="M12 12V3M12 12l7.4 4.4"/>',
    parties:   '<circle cx="9.2" cy="8" r="3.3"/><path d="M3.4 19.6a5.8 5.8 0 0 1 11.6 0"/>' +
               '<path d="M16.2 11.1a3.1 3.1 0 0 0 0-6M17.8 19.6a5.9 5.9 0 0 0-2.3-4.6"/>',
    shared:    '<circle cx="9.2" cy="8" r="3.3"/><path d="M3.4 19.6a5.8 5.8 0 0 1 11.6 0"/>' +
               '<path d="M16.2 11.1a3.1 3.1 0 0 0 0-6M17.8 19.6a5.9 5.9 0 0 0-2.3-4.6"/>',
    vshare:    '<circle cx="8" cy="12" r="4.2"/><path d="M12.2 12H21M18.2 12v3.2M15.4 12v2.4"/>',
    chat:      '<path d="M21 11.6a8.4 8.4 0 0 1-12.2 7.5L3.4 20.6l1.5-5A8.4 8.4 0 1 1 21 11.6z"/>',
    more:      '<rect x="3.4" y="3.4" width="7.2" height="7.2" rx="2.2"/><rect x="13.4" y="3.4" width="7.2" height="7.2" rx="2.2"/>' +
               '<rect x="3.4" y="13.4" width="7.2" height="7.2" rx="2.2"/><rect x="13.4" y="13.4" width="7.2" height="7.2" rx="2.2"/>',
    _:         '<rect x="3.4" y="3.4" width="17.2" height="17.2" rx="5"/><circle cx="12" cy="12" r="2.3"/>'
  };

  function svgFor(view){
    var v = String(view || "");
    var d = ICONS[v];
    if(!d){
      /* بخش‌های مشترک و گفتگو شناسهٔ ساختگی دارند (shared-…، vshare-…) */
      var pre = v.split("-")[0];
      d = ICONS[pre] || ICONS._;
    }
    return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" ' +
      'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">' + d + '</svg>';
  }
  function labelOf(b){
    var ic = b.querySelector(".ic");
    return b.textContent.replace(ic ? ic.textContent : "", "").trim();
  }

  function buildBar(){
    if(document.getElementById("appBar")) return;
    var all = buttons();
    if(!all.length) return;
    var byView = {};
    all.forEach(function(b){ byView[b.getAttribute("data-view")] = b; });

    var pick = [];
    BAR.forEach(function(v){ if(byView[v] && pick.length < MAX) pick.push(byView[v]); });
    /* اگر فهرستِ بالا هیچ‌کدام نبود، چهارتای اولِ خودِ منو */
    if(!pick.length) pick = all.slice(0, MAX);

    var bar = document.createElement("nav");
    bar.className = "appbar";
    bar.id = "appBar";
    bar.innerHTML = pick.map(function(b){
      return '<button type="button" class="ab" data-go="' + escapeHtml(b.getAttribute("data-view")) + '">' +
        '<span class="i">' + svgFor(b.getAttribute("data-view")) + '</span>' +
        '<span class="l">' + escapeHtml(labelOf(b)) + '</span></button>';
    }).join("") +
      '<button type="button" class="ab ab-more" id="abMore">' +
      '<span class="i">' + svgFor("more") + '</span><span class="l">بخش‌ها</span></button>';
    document.body.appendChild(bar);

    bar.addEventListener("click", function(e){
      var t = e.target.closest ? e.target.closest(".ab") : null;
      if(!t) return;
      if(t.id === "abMore"){ sheet(true); return; }
      go(t.getAttribute("data-go"));
    });

    var sh = document.createElement("div");
    sh.className = "appsheet";
    sh.id = "appSheet";
    sh.hidden = true;
    sh.innerHTML = '<div class="as-scrim" data-close="1"></div>' +
      '<div class="as-card" role="dialog" aria-label="بخش‌ها">' +
      '<button type="button" class="as-grip" data-close="1" aria-label="بستن"></button>' +
      '<div class="as-ttl">بخش‌ها</div><div class="as-grid"></div></div>';
    document.body.appendChild(sh);
    sh.addEventListener("click", function(e){
      if(e.target.getAttribute && e.target.getAttribute("data-close")){ sheet(false); return; }
      var t = e.target.closest ? e.target.closest(".as-t") : null;
      /* keep=true: پلهٔ کشو دست‌نخورده می‌ماند و خودِ track آن را به
         پلهٔ همین بخشِ تازه تبدیل می‌کند. اگر این‌جا پله برمی‌گشت،
         کاربر بخشی را می‌دید که هیچ پله‌ای نداشت و یک «بازگشت» او را
         دو بخش عقب می‌برد. */
      if(t){ go(t.getAttribute("data-go")); sheetClose(true); }
    });
    document.addEventListener("keydown", function(e){
      if(e.key === "Escape") sheet(false);
    });

    tuck();
    sync();
    try{
      new MutationObserver(sync).observe(document.querySelector(".nav-list"),
        { attributes: true, attributeFilter: ["class"], subtree: true, childList: true });
    }catch(e){}
  }

  /* ---------- چیدمانِ برنامه ----------
     ردیفِ «پشتیبان / بازیابی / خروج» بالای هر صفحه یک نوارِ کاملِ
     اضافه بود، و هیچ‌کدامشان کاری نیستند که آدم هر دقیقه بزند. می‌روند
     ته کشو — همان جایی که در هر برنامه‌ای «بیشتر» است — و صفحه یک
     ردیفِ تمام آزاد می‌کند.

     «در حال ذخیره…» ولی باید دیده شود، پس زیرِ نامِ کارتابل در نوارِ
     بالا می‌نشیند. خودِ گره جابه‌جا می‌شود، نه یک رونوشتش: شنونده‌ها و
     شناسه‌ها سرِ جایشان می‌مانند و هیچ کدی لازم نیست عوض شود. */
  function tuck(){
    var titles = document.querySelector(".topbar .brand .titles");
    var hint = document.getElementById("saveHint");
    if(titles && hint && hint.parentNode !== titles) titles.appendChild(hint);

    var card = document.querySelector("#appSheet .as-card");
    if(!card || card.querySelector(".as-foot")) return;
    var foot = document.createElement("div");
    foot.className = "as-foot";
    /* هر کدام ممکن است نباشد: ادمین می‌تواند «فایل‌ها» را بسته باشد. */
    [".sidebar-foot .foot-actions", "#importFile", "#lockBtn"].forEach(function(sel){
      var el = document.querySelector(sel);
      if(el) foot.appendChild(el);
    });
    if(foot.childNodes.length) card.appendChild(foot);
  }

  /* زدنِ دکمهٔ واقعیِ منو، نه تکرارِ کارش: هر بخش موقعِ باز شدن چیزی
     را از نو می‌کشد (نمودار، گزارشِ ویم، دیتای شخصی که رمز می‌خواهد) و
     همهٔ آن کارها به همان یک کلیک بسته است. */
  function go(view){
    var b = document.querySelector('.nav-list .navbtn[data-view="' + view + '"]');
    if(b) b.click();
    try{ window.scrollTo({ top: 0, behavior: "smooth" }); }catch(e){ window.scrollTo(0, 0); }
  }

  /* ---------- کشو و دکمهٔ «بازگشت»ِ اندروید ----------
     روی گوشی، «بازگشت» باید اول کشو را ببندد نه اینکه برنامه را
     ببندد. پس باز کردنِ کشو یک پله به تاریخچه اضافه می‌کند و بستنش
     همان پله را برمی‌دارد — تا تعدادِ پله‌ها نخوابد و یک «بازگشت»ِ
     اضافه لازم نشود. */
  function sheet(open){
    if(open) sheetOpen(); else sheetClose(false);
  }
  /* keep=true یعنی «پلهٔ تاریخچه را دست نزن»: یا از قبل برداشته شده
     (خودِ «بازگشت»)، یا قرار است جای خودش بماند و بخشِ تازه را
     بگیرد (زدنِ یک خانهٔ کشو). */
  function sheetOpen(){
    var sh = document.getElementById("appSheet");
    if(!sh || !sh.hidden) return;
    paintSheet();
    sh.hidden = false;
    document.documentElement.classList.add("as-open");
    if(app()){ try{ history.pushState({ kvSheet: 1 }, ""); }catch(e){} }
  }
  function sheetClose(keep){
    var sh = document.getElementById("appSheet");
    if(!sh || sh.hidden) return;
    sh.hidden = true;
    document.documentElement.classList.remove("as-open");
    if(!keep && app() && history.state && history.state.kvSheet){
      /* این history.back فقط پلهٔ خودِ کشو را برمی‌دارد و نباید بخش را
         عوض کند. بی این پرچم، زدنِ یک خانهٔ کشو بخش را باز می‌کرد و
         بلافاصله همین popstate آن را به بخشِ قبلی برمی‌گرداند — یعنی
         عملاً هیچ خانه‌ای کار نمی‌کرد. */
      skipPop = true;
      try{ history.back(); }catch(e){ skipPop = false; }
    }
  }

  function paintSheet(){
    var g = document.querySelector("#appSheet .as-grid");
    if(!g) return;
    g.innerHTML = buttons().map(function(b){
      var on = b.classList.contains("active") ? " on" : "";
      return '<button type="button" class="as-t' + on + '" data-go="' +
        escapeHtml(b.getAttribute("data-view")) + '">' +
        '<span class="i">' + svgFor(b.getAttribute("data-view")) + '</span>' +
        '<span class="l">' + escapeHtml(labelOf(b)) + '</span></button>';
    }).join("");
  }

  function sync(){
    var on = document.querySelector(".nav-list .navbtn.active");
    var v = on ? on.getAttribute("data-view") : "";
    var hit = false;
    [].slice.call(document.querySelectorAll("#appBar .ab")).forEach(function(b){
      var mine = b.getAttribute("data-go") === v;
      if(mine) hit = true;
      b.classList.toggle("on", mine);
    });
    /* بخشی که روی نوار نیست از داخلِ «بخش‌ها» باز شده؛ پس همان دکمه
       روشن می‌ماند، وگرنه نوار هیچ‌چیزِ روشنی ندارد و آدم خیال می‌کند
       جایی نیست. */
    var more = document.getElementById("abMore");
    if(more) more.classList.toggle("on", !hit && !!v);
    track(v);
    var sh = document.getElementById("appSheet");
    if(sh && !sh.hidden) paintSheet();
  }

  /* ---------- نصب ----------
     اندروید پیشنهادِ نصب را یک بار می‌دهد و اگر همان‌جا استفاده نشود
     دور می‌اندازد. نگهش می‌داریم تا دکمهٔ «نصب» در تنظیمات زنده باشد. */
  function paintInstall(){
    var box = document.getElementById("pwaBox");
    if(!box) return;
    var st = document.getElementById("pwaState");
    var btn = document.getElementById("pwaInstall");
    var how = document.getElementById("pwaHow");
    if(app()){
      if(st) st.textContent = "نصب شده — همین حالا دارید از خودِ برنامه استفاده می‌کنید.";
      if(btn) btn.hidden = true;
      if(how) how.hidden = true;
      return;
    }
    if(deferred){
      if(st) st.textContent = "آمادهٔ نصب است.";
      if(btn) btn.hidden = false;
      if(how) how.hidden = true;
    } else {
      if(st) st.textContent = "برای نصب، از منوی مرورگر استفاده کنید.";
      if(btn) btn.hidden = true;
      if(how) how.hidden = false;
    }
  }

  function install(){
    if(!deferred) return;
    var d = deferred;
    deferred = null;
    try{ d.prompt(); }catch(e){}
    if(d.userChoice) d.userChoice.then(function(){ paintInstall(); });
    paintInstall();
  }

  /* ---------- نسخهٔ تازه ----------
     بعد از هر استقرار، سرویس‌ورکرِ تازه پشتِ در منتظر می‌ماند تا همهٔ
     پنجره‌ها بسته شوند. یک نوارِ کوچک می‌گوید «تازه‌اش آمده» و با یک
     زدن جابه‌جا می‌شود. */
  function newVersion(reg){
    waiting = reg.waiting || null;
    if(!waiting) return;
    if(document.getElementById("pwaUp")) return;
    var d = document.createElement("div");
    d.className = "pwa-up";
    d.id = "pwaUp";
    d.innerHTML = '<span>نسخهٔ تازهٔ کارتابل آماده است.</span>' +
      '<button type="button" class="pu-go">به‌روزرسانی</button>' +
      '<button type="button" class="pu-x" aria-label="بعداً">✕</button>';
    document.body.appendChild(d);
    d.querySelector(".pu-x").addEventListener("click", function(){ d.remove(); });
    d.querySelector(".pu-go").addEventListener("click", function(){
      try{ waiting.postMessage("skip-waiting"); }catch(e){}
      d.remove();
      setTimeout(function(){ location.reload(); }, 400);
    });
  }

  function register(){
    if(window.KARTABL_OFFLINE) return;           /* نسخهٔ پشتیبان، بی‌سرور */
    if(!("serviceWorker" in navigator)) return;
    if(location.protocol !== "https:" && location.hostname !== "localhost" &&
       location.hostname !== "127.0.0.1") return;
    navigator.serviceWorker.register(SW, { scope: BASE }).then(function(reg){
      if(reg.waiting) newVersion(reg);
      reg.addEventListener("updatefound", function(){
        var sw = reg.installing;
        if(!sw) return;
        sw.addEventListener("statechange", function(){
          if(sw.state === "installed" && navigator.serviceWorker.controller) newVersion(reg);
        });
      });
    }).catch(function(){ /* بی سرویس‌ورکر هم کارتابل کار می‌کند */ });
  }

  /* ---------- میان‌بُرهای نشانهٔ برنامه ----------
     نگه داشتنِ نشانه روی صفحهٔ خانه، «برنامهٔ روزانه» و «چک‌لیست» را
     نشان می‌دهد؛ هر کدام با یک #نام باز می‌شود. */
  function fromHash(){
    var v = String(location.hash || "").replace(/^#/, "");
    if(!v || !/^[a-z-]+$/.test(v)) return;
    var b = document.querySelector('.nav-list .navbtn[data-view="' + v + '"]');
    /* «اگر از قبل باز نیست»: همین بخش ممکن است همان لحظه باز باشد
       (مثلاً میان‌بُری که روی بخشِ جاری می‌افتد) و زدنِ دوبارهٔ دکمه
       یعنی یک بار رسمِ بی‌دلیلِ همان جدول‌ها و نمودارها. */
    if(b && !b.classList.contains("active")) b.click();
  }

  /* هر بار که بخشی باز می‌شود یک پله به تاریخچه اضافه می‌شود، تا
     «بازگشت»ِ اندروید به بخشِ قبلی برگردد نه اینکه برنامه را ببندد.
     پلهٔ اول عمداً اضافه نمی‌شود: از اولین بخش، «بازگشت» یعنی بستنِ
     برنامه — همان چیزی که آدم انتظار دارد. */
  var back = false;
  function track(v){
    if(!v || !app()) return;
    if(back){ back = false; return; }
    var st = history.state;
    if(st && st.kv === v) return;
    try{
      /* نشانیِ صفحه عمداً دست نمی‌خورد (آرگومانِ سومی در کار نیست):
         اگر «#بخش» را روی آدرس می‌نشاندیم، هر بار که «بازگشت» یک پله
         عقب می‌رفت، کنارِ popstate یک hashchange هم می‌آمد و آن یکی
         دوباره بخش را عوض می‌کرد — یعنی خانه‌های کشو عملاً کار
         نمی‌کردند. در برنامهٔ نصب‌شده نوارِ آدرسی هم نیست که نشانی را
         نشان بدهد.

         پلهٔ اول جای خودش را می‌گیرد، نه یکی تازه: وگرنه از همان بخشِ
         اول، یک «بازگشت» هیچ کاری نمی‌کرد و باید دو بار می‌زدی. */
      if(st && st.kv) history.pushState({ kv: v }, "");
      else history.replaceState({ kv: v }, "");
    }catch(e){}
  }
  var skipPop = false;
  window.addEventListener("popstate", function(e){
    if(!app()) return;
    if(skipPop){ skipPop = false; return; }
    var sh = document.getElementById("appSheet");
    if(sh && !sh.hidden){ sheetClose(true); return; }
    var v = e.state && e.state.kv;
    if(!v) return;
    back = true;
    var b = document.querySelector('.nav-list .navbtn[data-view="' + v + '"]');
    if(b && !b.classList.contains("active")) b.click();
    else back = false;
  });

  function boot(){
    if(app()) document.documentElement.setAttribute("data-app", "1");
    tint();
    register();
    if(app()) buildBar();
    var ib = document.getElementById("pwaInstall");
    if(ib) ib.addEventListener("click", install);
    paintInstall();
    fromHash();
    window.addEventListener("hashchange", fromHash);
  }

  window.addEventListener("beforeinstallprompt", function(e){
    e.preventDefault();
    deferred = e;
    paintInstall();
  });
  window.addEventListener("appinstalled", function(){
    deferred = null;
    paintInstall();
  });

  window.PWA = { tint: tint, install: install, refresh: paintInstall,
                 isApp: app, sheet: sheet, build: buildBar };

  if(document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", boot);
  else boot();
})();
