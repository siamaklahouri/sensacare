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
  function iconOf(b){
    var ic = b.querySelector(".ic");
    return ic ? ic.textContent.trim() : "•";
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
        '<span class="i">' + escapeHtml(iconOf(b)) + '</span>' +
        '<span class="l">' + escapeHtml(labelOf(b)) + '</span></button>';
    }).join("") +
      '<button type="button" class="ab ab-more" id="abMore">' +
      '<span class="i">☰</span><span class="l">بخش‌ها</span></button>';
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

    sync();
    try{
      new MutationObserver(sync).observe(document.querySelector(".nav-list"),
        { attributes: true, attributeFilter: ["class"], subtree: true, childList: true });
    }catch(e){}
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
        '<span class="i">' + escapeHtml(iconOf(b)) + '</span>' +
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
