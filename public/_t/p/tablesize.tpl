/* ==================== پهنای ستون‌ها، در همهٔ جدول‌ها ====================
   هر جدولی در کارتابل — سرورها، شرکت‌ها، فاکتورها، بدهی‌ها، بخش‌های
   مشترک، هر چه — دو چیز می‌گیرد:

   • دستهٔ کشیدن کنارِ هر سرستون، تا پهنا را با دست بگیرید.
   • دکمهٔ «اندازهٔ خودکار» بالای هر جدول، که پهنا را از روی محتوا
     می‌چیند و هر چه با دست کشیده شده بود فراموش می‌کند.

   سه تصمیم که شکلش را تعیین کرد:

   یک) هیچ جدولی در HTML دست نمی‌خورد. این‌جا روی هر جدولی که پیدا
   شود سوار می‌شود، پس جدولِ فردا هم بدونِ کارِ اضافه همین را دارد.

   دو) پهنا روی <colgroup> می‌نشیند نه روی <th>. با table-layout ثابت،
   مرورگر پهنا را از colgroup می‌گیرد و ستون‌ها موقعِ تایپ نمی‌پرند.

   سه) اندازه‌گیری از روی *متنِ* خانه‌ها با بوم انجام می‌شود، نه از عرضِ
   عنصرها. بار اول عرضِ عنصر را گرفتم و یک حلقهٔ بازخورد درست شد:
   ستونی که پهن شده بود، «خودکار» همان پهنا را می‌دید و پهن‌ترش
   می‌کرد. کادرهای متن هم width:100% دارند و اصلاً پهنای محتوا را
   نشان نمی‌دهند. */
(function(){
  "use strict";
  var MIN = 56, MAX = 460, DRAG_MAX = 900;
  var SEEN = "__tsz";

  var key = function(id){ return "tsz:" + STORE_KEY + ":" + id; };
  var load = function(id){
    try{ var v = JSON.parse(localStorage.getItem(key(id)) || "null");
         return v && typeof v === "object" ? v : null; }catch(e){ return null; }
  };
  var save = function(id, map){
    try{ if(map) localStorage.setItem(key(id), JSON.stringify(map));
         else localStorage.removeItem(key(id)); }catch(e){}
  };

  /* شناسهٔ پایدارِ هر جدول: id خودش اگر داشت، وگرنه نامِ نما به‌علاوهٔ
     جایگاهش در همان نما. تا وقتی جدولی جابه‌جا نشود، ثابت می‌ماند. */
  function tabId(tab){
    if(tab.id) return tab.id;
    var view = tab.closest(".view");
    var vid = view ? view.id : "x";
    var all = view ? view.querySelectorAll("table") : [tab];
    return vid + ":" + Array.prototype.indexOf.call(all, tab);
  }

  var cv = null;
  function textW(t, font){
    if(!cv) cv = document.createElement("canvas").getContext("2d");
    cv.font = font;
    return cv.measureText(String(t == null ? "" : t)).width;
  }

  /* متنِ یک خانه: مقدارِ کادر اگر کادری هست، وگرنه متنِ خودش */
  function cellText(td){
    var f = td.querySelector("input,select,textarea");
    if(f) return f.tagName === "SELECT"
      ? (f.options[f.selectedIndex] || {}).text || ""
      : f.value || f.placeholder || "";
    return td.textContent || "";
  }

  function fit(tab){
    var cs = getComputedStyle(tab);
    var font = cs.fontSize + " " + cs.fontFamily;
    var head = tab.querySelectorAll("thead th");
    var body = tab.querySelectorAll("tbody tr");
    var out = [];
    for(var i = 0; i < head.length; i++){
      var need = textW(head[i].textContent.trim(), font) * 1.12 + 26;
      for(var j = 0; j < body.length; j++){
        var td = body[j].children[i];
        if(!td) continue;
        /* متنِ چندخطی: بلندترین خطش، نه کلِ متن */
        var parts = String(cellText(td)).split("\n");
        for(var q = 0; q < parts.length; q++){
          var w = textW(parts[q].trim(), font) + 30;
          if(w > need) need = w;
        }
        if(td.querySelector("select")) need += 24;
      }
      out.push(Math.max(MIN, Math.min(MAX, Math.round(need))));
    }
    return out;
  }

  function apply(tab, ignoreSaved){
    var head = tab.querySelectorAll("thead th");
    if(!head.length) return;
    var group = tab.querySelector("colgroup");
    if(!group || group.children.length !== head.length){
      if(group) group.remove();
      group = document.createElement("colgroup");
      for(var i = 0; i < head.length; i++) group.appendChild(document.createElement("col"));
      tab.insertBefore(group, tab.firstChild);
    }
    var saved = ignoreSaved ? null : load(tabId(tab));
    var auto = fit(tab);
    for(var j = 0; j < head.length; j++){
      var k = head[j].textContent.trim() || String(j);
      group.children[j].style.width = ((saved && saved[k]) || auto[j] || MIN) + "px";
    }
    tab.style.tableLayout = "fixed";
    tab.style.width = "max-content";
    tab.style.minWidth = "100%";
  }

  /* دستهٔ کشیدن. یک بار برای هر جدول سوار می‌شود. */
  function wire(tab){
    if(tab[SEEN]) return;
    tab[SEEN] = 1;
    var head = tab.querySelectorAll("thead th");
    for(var i = 0; i < head.length; i++){
      if(head[i].querySelector(".tsz-grip")) continue;
      head[i].style.position = head[i].style.position || "relative";
      var g = document.createElement("i");
      g.className = "tsz-grip";
      head[i].appendChild(g);
    }
    apply(tab);
  }

  document.addEventListener("pointerdown", function(e){
    var grip = e.target.closest ? e.target.closest(".tsz-grip") : null;
    if(!grip) return;
    var th = grip.closest("th"), tab = grip.closest("table");
    if(!th || !tab) return;
    e.preventDefault();
    var idx = Array.prototype.indexOf.call(th.parentNode.children, th);
    var group = tab.querySelector("colgroup");
    var col = group && group.children[idx];
    if(!col) return;
    var x0 = e.clientX, w0 = th.getBoundingClientRect().width;
    var rtl = getComputedStyle(tab).direction === "rtl";
    grip.setPointerCapture(e.pointerId);
    var move = function(ev){
      var d = (ev.clientX - x0) * (rtl ? -1 : 1);
      col.style.width = Math.max(MIN, Math.min(DRAG_MAX, Math.round(w0 + d))) + "px";
    };
    var up = function(){
      grip.removeEventListener("pointermove", move);
      grip.removeEventListener("pointerup", up);
      var map = load(tabId(tab)) || {};
      map[th.textContent.trim() || String(idx)] = parseInt(col.style.width, 10) || MIN;
      save(tabId(tab), map);
    };
    grip.addEventListener("pointermove", move);
    grip.addEventListener("pointerup", up);
  });

  /* دکمهٔ «اندازهٔ خودکار» بالای هر جدول */
  document.addEventListener("click", function(e){
    var b = e.target.closest ? e.target.closest(".tsz-fit") : null;
    if(!b) return;
    var wrap = b.closest(".panel") || b.parentNode;
    var tabs = wrap ? wrap.querySelectorAll("table") : [];
    for(var i = 0; i < tabs.length; i++){
      save(tabId(tabs[i]), null);
      apply(tabs[i], true);
    }
  });

  function mountBtn(tab){
    var wrap = tab.closest(".tbl-wrap") || tab.parentNode;
    if(!wrap || wrap.previousElementSibling &&
       wrap.previousElementSibling.classList &&
       wrap.previousElementSibling.classList.contains("tsz-bar")) return;
    var bar = document.createElement("div");
    bar.className = "tsz-bar";
    bar.innerHTML = '<button type="button" class="tsz-fit" ' +
      'title="پهنای ستون‌ها را به اندازهٔ محتوا برگردان">↔ اندازهٔ خودکار</button>';
    wrap.parentNode.insertBefore(bar, wrap);
  }

  /* هر جدولی که در نمای باز هست. بعد از هر رندرِ تازه دوباره صدا
     زده می‌شود، چون جدول‌ها از نو ساخته می‌شوند. */
  function sweep(){
    var views = document.querySelectorAll(".view.active table");
    for(var i = 0; i < views.length; i++){
      var tab = views[i];
      if(!tab.querySelector("thead th")) continue;
      /* جدول‌های ریزِ داخلِ کارت (مثل خلاصه‌ها) ستون‌بندی نمی‌خواهند */
      if(tab.rows.length < 2) continue;
      mountBtn(tab);
      if(tab[SEEN]) apply(tab); else wire(tab);
    }
  }
  window.tableSizeSweep = sweep;

  /* رندرها پشتِ سر هم می‌آیند؛ یک بار بعد از آرام شدنشان کافی است. */
  var t = null;
  var later = function(){ clearTimeout(t); t = setTimeout(sweep, 140); };
  new MutationObserver(later).observe(document.body, { childList:true, subtree:true });
  document.addEventListener("click", function(e){
    if(e.target.closest && e.target.closest(".navbtn")) later();
  });
  if(document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", later);
  else later();
})();
