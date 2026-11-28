/* ---------------- منوی کشویی ----------------
   دکمهٔ ☰ بالای ستونِ بخش‌ها، ستون را تا یک نوارِ آیکنی جمع می‌کند و
   دوباره باز می‌کند. حالتش در localStorage می‌ماند، پس اگر بسته‌اش
   گذاشتی، بارِ بعد هم بسته است.

   نوشتهٔ دکمه‌های پایینِ ستون (پشتیبان، بازیابی، خروج) آیکن و متن را
   در یک متنِ لخت دارند؛ آن‌ها را این‌جا به دو span می‌شکنیم تا CSS
   بتواند فقط متن را پنهان کند. دکمه‌های فهرستِ بخش‌ها خودشان
   span.ic دارند و با font-size:0 جمع می‌شوند — یعنی بخش‌های
   اشتراکی هم که بعداً اضافه می‌شوند، بی‌هیچ کارِ تازه‌ای درست
   درمی‌آیند. */
var NAVFOLD = (function(){
  var KEY = "kb-nav-shut";
  var HTML = document.documentElement;
  var btn = null;

  function chars(s){
    try { if (Array.from) return Array.from(s); } catch(e){}
    return s.split("");
  }

  function split(el){
    if (!el || el.querySelector(".tx") || el.querySelector(".ic")) return;
    var all = (el.textContent || "").trim();
    if (!all) return;
    var cs = chars(all);
    var rest = cs.slice(1).join("").trim();
    if (!rest) return;
    el.textContent = "";
    var i = document.createElement("span");
    i.className = "ic"; i.textContent = cs[0];
    var t = document.createElement("span");
    t.className = "tx"; t.textContent = rest;
    el.appendChild(i); el.appendChild(t);
    if (!el.title) el.title = rest;
  }

  function titles(){
    [].slice.call(document.querySelectorAll(".nav-list .navbtn")).forEach(function(b){
      if (!b.title){
        var t = (b.textContent || "").trim();
        if (t) b.title = t;
      }
    });
  }

  function paint(){
    var shut = HTML.classList.contains("nav-shut");
    if (btn){
      btn.setAttribute("aria-expanded", shut ? "false" : "true");
      btn.title = shut ? "بازکردنِ فهرستِ بخش‌ها" : "بستنِ فهرستِ بخش‌ها";
    }
    /* نمودارها اندازه‌شان را از پهنای ستونِ کنار می‌گیرند؛ تا پایانِ
       انیمیشن صبر می‌کنیم و بعد خبر می‌دهیم. */
    setTimeout(function(){
      try { window.dispatchEvent(new Event("resize")); } catch(e){}
    }, 220);
  }

  function set(shut){
    if (shut) HTML.classList.add("nav-shut");
    else HTML.classList.remove("nav-shut");
    try { localStorage.setItem(KEY, shut ? "1" : "0"); } catch(e){}
    paint();
  }

  function wire(){
    var bar = document.querySelector(".sidebar");
    if (!bar || bar.querySelector(".nav-fold")) return;
    [].slice.call(document.querySelectorAll(".sidebar-foot .btn")).forEach(split);
    titles();
    btn = document.createElement("button");
    btn.type = "button";
    btn.className = "nav-fold";
    btn.setAttribute("aria-label", "باز و بستنِ فهرستِ بخش‌ها");
    btn.innerHTML = '<span class="nf-ic">☰</span>';
    btn.addEventListener("click", function(){
      set(!HTML.classList.contains("nav-shut"));
    });
    bar.insertBefore(btn, bar.firstChild);
    var saved = null;
    try { saved = localStorage.getItem(KEY); } catch(e){}
    if (saved === "1") HTML.classList.add("nav-shut");
    paint();
  }

  return { wire: wire, set: set, split: split };
})();
try { if (document.querySelector(".sidebar")) NAVFOLD.wire(); } catch(e){ console.warn("منوی کشویی:", e); }
