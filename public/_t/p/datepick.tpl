/* ==================== تقویمِ شمسی کنارِ هر خانهٔ تاریخ ====================
   تا امروز تاریخ را باید با دست می‌نوشتی: «۱۴۰۴/۰۷/۰۹». هم وقت‌گیر بود،
   هم هر کس یک‌جور می‌نوشت (۱۴۰۴/۷/۹ و ۱۴۰۴-۰۷-۰۹ و…) و مرتب‌سازی و
   «از مهلت گذشته» روی چنین داده‌ای درست درنمی‌آمد.

   حالا کنارِ هر خانهٔ تاریخ یک 📅 هست؛ با زدنش تقویم باز می‌شود و روز
   را انتخاب می‌کنی. خروجی همیشه یک شکل است: ۱۴۰۴/۰۷/۰۹.

   سه تصمیم:

   یک) خانه‌ها خودشان شناخته می‌شوند، نه اینکه یکی‌یکی علامت بخورند:
       هر ورودی یا خانهٔ ویرایش‌پذیری که نامِ میدانش در فهرستِ پایین
       باشد تقویم می‌گیرد. جدولِ فردا هم بدونِ کارِ اضافه همین را دارد.

   دو) نوشتن با دست هم سرِ جایش می‌ماند. تقویم یک راهِ اضافه است، نه
       جایگزین؛ کسی که تند تایپ می‌کند نباید معطل شود.

   سه) بعد از انتخاب، همان رویدادی فرستاده می‌شود که دستْ‌نوشتن
       می‌فرستد — input و change برای ورودی‌ها، blur برای خانه‌های
       contenteditable. پس هیچ‌کدام از مسیرهای ذخیرهٔ موجود لازم نیست
       چیزی دربارهٔ این تقویم بدانند. */
(function(){
  "use strict";

  /* ---------- تبدیلِ شمسی و میلادی ---------- */
  var BREAKS = [-61,9,38,199,426,686,756,818,1111,1181,1210,1635,2060,2097,2192,2262,2324,2394,2456,3178];
  function div(a,b){ return ~~(a/b); }
  function mod(a,b){ return a - ~~(a/b)*b; }
  function jalCal(jy){
    var bl = BREAKS.length, gy = jy + 621, leapJ = -14, jp = BREAKS[0], jm, jump = 0, leap, n, i;
    if(jy < jp || jy >= BREAKS[bl-1]) return null;
    for(i = 1; i < bl; i++){
      jm = BREAKS[i]; jump = jm - jp;
      if(jy < jm) break;
      leapJ = leapJ + div(jump,33)*8 + div(mod(jump,33),4);
      jp = jm;
    }
    n = jy - jp;
    leapJ = leapJ + div(n,33)*8 + div(mod(n,33)+3,4);
    if(mod(jump,33) === 4 && jump - n === 4) leapJ += 1;
    var leapG = div(gy,4) - div((div(gy,100)+1)*3,4) - 150;
    var march = 20 + leapJ - leapG;
    if(jump - n < 6) n = n - jump + div(jump+4,33)*33;
    leap = mod(mod(n+1,33)-1,4);
    if(leap === -1) leap = 4;
    return { leap:leap, gy:gy, march:march };
  }
  function g2d(gy,gm,gd){
    var d = div((gy + div(gm-8,6) + 100100)*1461,4) + div(153*mod(gm+9,12)+2,5) + gd - 34840408;
    return d - div(div(gy + 100100 + div(gm-8,6),100)*3,4) + 752;
  }
  function d2g(jdn){
    var j = 4*jdn + 139361631;
    j = j + div(div(4*jdn + 183187720,146097)*3,4)*4 - 3908;
    var i = div(mod(j,1461),4)*5 + 308;
    var gd = div(mod(i,153),5) + 1, gm = mod(div(i,153),12) + 1;
    return { gy: div(j,1461) - 100100 + div(8-gm,6), gm:gm, gd:gd };
  }
  function j2d(jy,jm,jd){
    var r = jalCal(jy);
    if(!r) return null;
    return g2d(r.gy,3,r.march) + (jm-1)*31 - div(jm,7)*(jm-7) + jd - 1;
  }
  function d2j(jdn){
    var gy = d2g(jdn).gy, jy = gy - 621, r = jalCal(jy);
    if(!r) return null;
    var k = jdn - g2d(gy,3,r.march), jm, jd;
    if(k >= 0){
      if(k <= 185) return { jy:jy, jm:1+div(k,31), jd:mod(k,31)+1 };
      k -= 186;
    } else { jy -= 1; k += 179; if(r.leap === 1) k += 1; }
    jm = 7 + div(k,30); jd = mod(k,30) + 1;
    return { jy:jy, jm:jm, jd:jd };
  }
  function monthLen(jy,jm){
    if(jm <= 6) return 31;
    if(jm <= 11) return 30;
    var r = jalCal(jy);
    return r && r.leap === 0 ? 30 : 29;
  }
  function today(){
    var n = new Date();
    return d2j(g2d(n.getFullYear(), n.getMonth()+1, n.getDate()));
  }

  /* ---------- رقم‌ها و قالبِ متن ---------- */
  var FA = "۰۱۲۳۴۵۶۷۸۹";
  function faN(n, w){
    var s = String(n);
    while(w && s.length < w) s = "0" + s;
    return s.replace(/[0-9]/g, function(d){ return FA[+d]; });
  }
  function latin(s){
    return String(s == null ? "" : s)
      .replace(/[۰-۹]/g, function(d){ return String(FA.indexOf(d)); })
      .replace(/[٠-٩]/g, function(d){ return String("٠١٢٣٤٥٦٧٨٩".indexOf(d)); });
  }
  function fmt(jy,jm,jd){ return faN(jy,4) + "/" + faN(jm,2) + "/" + faN(jd,2); }

  /* متنی که در خانه هست را می‌فهمد — هر جور که نوشته شده باشد */
  function parse(txt){
    var m = latin(txt).match(/(\d{3,4})\s*[\/\-.]\s*(\d{1,2})\s*[\/\-.]\s*(\d{1,2})/);
    if(!m) return null;
    var jy = +m[1], jm = +m[2], jd = +m[3];
    if(jm < 1 || jm > 12 || jd < 1 || jd > 31) return null;
    if(jy < 1200 || jy > 1700) return null;
    return { jy:jy, jm:jm, jd:jd };
  }

  var MONTHS = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور",
                "مهر","آبان","آذر","دی","بهمن","اسفند"];
  var WD = ["ش","ی","د","س","چ","پ","ج"];

  /* ---------- پنجره ---------- */
  var pop = null, target = null, view = null;

  function build(){
    if(pop) return pop;
    pop = document.createElement("div");
    pop.className = "dp-pop";
    pop.hidden = true;
    pop.innerHTML =
      '<div class="dp-head">' +
        '<button type="button" class="dp-nav" data-go="-1" title="ماه قبل">›</button>' +
        '<span class="dp-ttl"></span>' +
        '<button type="button" class="dp-nav" data-go="1" title="ماه بعد">‹</button>' +
      '</div>' +
      '<div class="dp-wd"></div><div class="dp-grid"></div>' +
      '<div class="dp-foot">' +
        '<button type="button" class="dp-today">امروز</button>' +
        '<button type="button" class="dp-clear">پاک کردن</button>' +
      '</div>';
    document.body.appendChild(pop);
    pop.querySelector(".dp-wd").innerHTML =
      WD.map(function(d){ return "<span>" + d + "</span>"; }).join("");

    pop.addEventListener("click", function(e){
      var nav = e.target.closest(".dp-nav");
      if(nav){ step(+nav.getAttribute("data-go")); return; }
      var day = e.target.closest("[data-d]");
      if(day){ pick(view.jy, view.jm, +day.getAttribute("data-d")); return; }
      if(e.target.closest(".dp-today")){ var t = today(); pick(t.jy, t.jm, t.jd); return; }
      if(e.target.closest(".dp-clear")){ write(""); close(); return; }
    });
    document.addEventListener("click", function(e){
      if(pop.hidden) return;
      if(pop.contains(e.target) || (e.target.closest && e.target.closest(".dp-host"))) return;
      close();
    });
    document.addEventListener("keydown", function(e){
      if(!pop.hidden && e.key === "Escape"){ e.preventDefault(); close(); }
    });
    addEventListener("resize", close);
    addEventListener("scroll", close, true);
    return pop;
  }

  function step(d){
    var jm = view.jm + d, jy = view.jy;
    if(jm < 1){ jm = 12; jy--; }
    if(jm > 12){ jm = 1; jy++; }
    view = { jy:jy, jm:jm };
    paint();
  }

  function paint(){
    pop.querySelector(".dp-ttl").textContent = MONTHS[view.jm-1] + " " + faN(view.jy,4);
    var first = j2d(view.jy, view.jm, 1);
    if(first == null) return;
    /* شنبه سرِ هفته است: روزِ هفتهٔ میلادی ۰=یکشنبه، پس +۱ و باقی‌ماندهٔ ۷ */
    var g = d2g(first);
    var wd = (new Date(g.gy, g.gm-1, g.gd).getDay() + 1) % 7;
    var len = monthLen(view.jy, view.jm);
    var cur = target ? parse(valueOf(target)) : null;
    var t = today();
    var html = "";
    for(var i = 0; i < wd; i++) html += '<span class="dp-pad"></span>';
    for(var d = 1; d <= len; d++){
      var cls = "dp-d";
      if(cur && cur.jy === view.jy && cur.jm === view.jm && cur.jd === d) cls += " on";
      if(t && t.jy === view.jy && t.jm === view.jm && t.jd === d) cls += " now";
      html += '<button type="button" class="' + cls + '" data-d="' + d + '">' + faN(d) + '</button>';
    }
    pop.querySelector(".dp-grid").innerHTML = html;
  }

  function valueOf(el){
    return el.tagName === "INPUT" ? el.value : el.textContent;
  }
  function write(text){
    if(!target) return;
    if(target.tagName === "INPUT"){
      target.value = text;
      target.dispatchEvent(new Event("input", { bubbles:true }));
      target.dispatchEvent(new Event("change", { bubbles:true }));
    } else {
      target.textContent = text;
      /* خانه‌های contenteditable روی blur ذخیره می‌شوند */
      target.dispatchEvent(new Event("input", { bubbles:true }));
      target.dispatchEvent(new FocusEvent("blur"));
    }
  }
  function pick(jy,jm,jd){ write(fmt(jy,jm,jd)); close(); }

  function close(){
    if(pop && !pop.hidden){ pop.hidden = true; target = null; }
  }

  function open(el, anchor){
    build();
    target = el;
    var cur = parse(valueOf(el)) || today();
    view = { jy:cur.jy, jm:cur.jm };
    pop.hidden = false;
    paint();
    var r = anchor.getBoundingClientRect();
    var w = pop.offsetWidth, h = pop.offsetHeight;
    var left = Math.min(Math.max(8, r.left - (w - r.width) / 2), innerWidth - w - 8);
    var top = r.bottom + 6;
    if(top + h > innerHeight - 8) top = Math.max(8, r.top - h - 6);
    pop.style.left = left + "px";
    pop.style.top = top + "px";
  }

  /* ---------- وصل کردن ---------- */
  /* نامِ میدان‌هایی که تاریخ‌اند. یک فهرست، نه یک علامت روی هر خانه. */
  var FIELDS = ["date","duedate","datestr","lastrestore","lastfullbackup",
                "createddate","due","expires","paydate","visitdate"];
  function isDateField(el){
    if(el.hasAttribute("data-nodate")) return false;
    if(el.hasAttribute("data-date")) return true;
    var f = (el.getAttribute("data-field") || "").toLowerCase();
    return FIELDS.indexOf(f) >= 0;
  }

  /* نشانهٔ تقویم یک ::after در شیوه‌نامه است، نه یک دکمهٔ واقعی داخلِ
     خانه. دلیلش دو چیزِ جدی بود:

     یک) خانه‌های ویرایش‌پذیر contenteditable هستند و برنامه مقدارشان
         را با textContent می‌خواند. دکمه‌ای داخلِ خانه یعنی «📅» هم
         جزوِ تاریخ حساب می‌شد و هر تاریخی با یک شکلک ذخیره می‌شد.
     دو) نوشتنِ تاریخِ انتخاب‌شده با textContent، خودِ دکمه را پاک
         می‌کرد؛ دفعهٔ بعد تقویمی در کار نبود.

     ::after نه در textContent می‌آید و نه با نوشتنِ متن پاک می‌شود.
     زدنش هم از روی جای کلیک فهمیده می‌شود: نوارِ باریکِ لبهٔ خانه. */
  var ZONE = 24;   /* پهنای نوارِ تقویم، در پیکسل */

  function hostOf(el){
    return el.tagName === "INPUT" ? (el.closest("td") || el.parentNode) : el;
  }
  function attach(el){
    var host = hostOf(el);
    if(!host) return;
    host.classList.add("dp-host");
    host.__dpFor = el;
  }

  /* آیا کلیک روی نوارِ تقویم بود؟ در راست‌به‌چپ لبهٔ شروع سمت چپ است. */
  function inZone(host, x){
    var r = host.getBoundingClientRect();
    var rtl = getComputedStyle(host).direction === "rtl";
    return rtl ? (x <= r.left + ZONE) : (x >= r.right - ZONE);
  }

  /* mousedown نه click: باید پیش از آنکه خانه به حالتِ ویرایش برود
     جلویش گرفته شود، وگرنه نشانه‌گرِ متن می‌پرد وسطِ تاریخ. */
  document.addEventListener("mousedown", function(e){
    var host = e.target.closest ? e.target.closest(".dp-host") : null;
    if(!host || !host.__dpFor) return;
    if(!inZone(host, e.clientX)) return;
    e.preventDefault(); e.stopPropagation();
    var el = host.__dpFor;
    if(!pop || pop.hidden || target !== el) open(el, host);
    else close();
  }, true);

  function scan(root){
    var host = root || document;
    var all = host.querySelectorAll(
      'input[type=text][data-field], td[contenteditable][data-field], [data-date]');
    for(var i = 0; i < all.length; i++){
      var el = all[i];
      if(el.classList.contains("day-picker-input")) continue;   /* تقویمِ خودش را دارد */
      if(isDateField(el)) attach(el);
    }
  }
  window.datePickScan = scan;

  var t = null;
  var later = function(){ clearTimeout(t); t = setTimeout(function(){ scan(); }, 150); };
  new MutationObserver(later).observe(document.body, { childList:true, subtree:true });
  if(document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", later);
  else later();

  window.DatePick = { open: open, close: close, parse: parse, fmt: fmt,
                      today: today, scan: scan, FIELDS: FIELDS };
})();
