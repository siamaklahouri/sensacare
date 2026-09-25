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
  var MIN = 46, MAX = 460, DRAG_MAX = 900;
  /* پهنای دستهٔ کشیدن که روی سرستون می‌نشیند، و یک نفَسِ کوچک تا
     حرفِ آخر به لبه نچسبد. */
  var GRIP = 10, SLACK = 4;
  /* ستونی که از این پهن‌تر است، ستونِ متنی حساب می‌شود و می‌تواند
     فضای باقی‌ماندهٔ کارت را بگیرد — تا این سقف. */
  var GROW_MIN = 120, GROW_MAX = 620;
  /* کفِ پهنای ستونی که تویش تایپ می‌شود («وظیفه»، «یادداشت»، «شرح»)،
     و وزنِ بیشترِ کادرِ چندخطی که برای پاراگراف ساخته شده. */
  var TYPE_MIN = 168, LONG_WEIGHT = 1.45;
  /* ستونی که تویش تایپ می‌شود زودتر از ستونِ معمولی وارد تقسیمِ فضا
     می‌شود (۹۰ به‌جای ۱۲۰)، تا «یادداشت»ی که تازه یک کلمه تویش نوشته
     شده یک‌باره از سهم نیفتد. ولی وزنش همان محتوایش می‌ماند، وگرنه
     «مسئول» هم‌پای «وظیفه» پهن می‌شد. */
  var FIELD_MIN = 90;
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

  /* متنِ یک خانه: مقدارِ کادر اگر کادری هست، وگرنه متنِ خودش.
     راهنمای داخلِ کادر (placeholder) هم اندازه می‌گیرد، چون تا وقتی
     خانه خالی است همان دیده می‌شود. */
  function cellText(td){
    var f = td.querySelector("input,select,textarea");
    if(f) return f.tagName === "SELECT"
      ? (f.options[f.selectedIndex] || {}).text || ""
      : f.value || f.placeholder || "";
    return td.textContent || "";
  }

  /* ولی برای «این ستون پر است یا خالی؟» فقط خودِ مقدار حساب است.
     ستونِ «وظایف اصلی امروز» که هنوز چیزی تویش نوشته نشده، راهنمای
     داخلِ کادرش را دارد — و اگر آن را «پر» بگیریم، ستون به اندازهٔ
     همان راهنما می‌ماند و اولین جمله‌ای که بنویسند جا نمی‌شود. */
  function cellVal(td){
    var f = td.querySelector("input,select,textarea");
    if(f) return f.tagName === "SELECT"
      ? (f.options[f.selectedIndex] || {}).text || ""
      : f.value || "";
    return td.textContent || "";
  }

  /* قلمِ واقعیِ همان خانه. سرستون‌ها معمولاً ضخیم‌ترند؛ با قلمِ نازکِ
     بدنه اندازه‌شان کم در می‌آمد و عنوان زیرِ دستهٔ کشیدن می‌رفت. */
  function fontOf(el, fb){
    if(!el) return fb;
    var s = getComputedStyle(el);
    return (s.fontStyle === "normal" ? "" : s.fontStyle + " ") +
           (s.fontWeight && s.fontWeight !== "400" ? s.fontWeight + " " : "") +
           s.fontSize + " " + s.fontFamily;
  }

  /* حاشیهٔ افقیِ خانه را از خودِ شیوه‌نامه می‌گیریم، نه یک عددِ حدسی.
     جدولِ فشرده و جدولِ گشاد حاشیهٔ یکسان ندارند. */
  function padOf(el){
    if(!el) return 18;
    var s = getComputedStyle(el);
    return (parseFloat(s.paddingLeft) || 0) + (parseFloat(s.paddingRight) || 0) +
           (parseFloat(s.borderLeftWidth) || 0) + (parseFloat(s.borderRightWidth) || 0);
  }

  /* پهنای سربارِ خودِ کادر: فلشِ کشویی، یا حاشیهٔ درونیِ input.
     یک بار برای هر ستون، نه یک بار به ازای هر ردیف — اشکالِ قبلی
     همین بود: ستونی مثل «مسئول» که در هر ردیف کشویی دارد، به ازای
     هر ردیف ۲۴ پیکسل می‌گرفت و بعد از چند ردیف به سقف می‌خورد. */
  /* خانه‌ای که محتوایش یک نشانِ رنگی است (مثلِ «انجام نشده» در جدولِ
     مهلت‌ها) از متنش پهن‌تر است: حاشیهٔ درونیِ خودِ نشان هم جا
     می‌خواهد. بدونِ این، نشان دو خط می‌شد. */
  function chipPad(td){
    var k = td.children.length === 1 ? td.children[0] : null;
    if(!k || k.querySelector("input,select,textarea")) return 0;
    var s2 = getComputedStyle(k);
    if(s2.display === "inline" && !parseFloat(s2.paddingLeft)) return 0;
    return (parseFloat(s2.paddingLeft) || 0) + (parseFloat(s2.paddingRight) || 0) +
           (parseFloat(s2.borderLeftWidth) || 0) + (parseFloat(s2.borderRightWidth) || 0) +
           (parseFloat(s2.marginLeft) || 0) + (parseFloat(s2.marginRight) || 0);
  }

  function fieldPad(f){
    if(!f) return 0;
    var s = getComputedStyle(f);
    var p = (parseFloat(s.paddingLeft) || 0) + (parseFloat(s.paddingRight) || 0) +
            (parseFloat(s.borderLeftWidth) || 0) + (parseFloat(s.borderRightWidth) || 0);
    /* فلشِ کشویی جای ثابتی از عرضِ کادر را می‌گیرد و روی متن می‌افتد؛
       با ۱۸ پیکسل «انجام نشده» به «انجام نشد» بریده می‌شد. */
    return f.tagName === "SELECT" ? p + 30 : p;
  }

  /* ستون‌های واقعیِ جدول. «هر th در thead» جواب نمی‌داد: جدول‌هایی
     مثل سرورها یک سطرِ فیلتر هم زیرِ سرستون دارند، و آن‌وقت شمارشِ
     ستون‌ها دو برابر می‌شد و colgroup با جدول جور در نمی‌آمد. پس
     شمارش را از بدنه می‌گیریم و سرستون را سطری می‌گیریم که همان
     تعداد خانه دارد. */
  function colsOf(tab){
    var body = tab.querySelectorAll("tbody tr");
    var tally = {}, i, n = 0, best = -1;
    for(i = 0; i < body.length; i++){
      var c = body[i].children.length;
      if(c < 2) continue;
      tally[c] = (tally[c] || 0) + 1;
      if(tally[c] > best){ best = tally[c]; n = c; }
    }
    var hrows = tab.querySelectorAll("thead tr");
    var head = null;
    for(i = 0; i < hrows.length; i++)
      if(hrows[i].children.length === n){ head = hrows[i]; break; }
    if(!head){
      /* بدنه‌ای نبود یا با هیچ سطرِ سرستونی جور نشد: پرخانه‌ترین
         سطرِ سرستون، که سطرِ عنوان‌هاست نه سطرِ فیلتر. */
      for(i = 0; i < hrows.length; i++)
        if(!head || hrows[i].children.length > head.children.length) head = hrows[i];
      n = head ? head.children.length : 0;
    }
    /* سرستونِ گروهی (colspan) نقشهٔ ستون‌ها را به هم می‌زند */
    if(head) for(i = 0; i < head.children.length; i++)
      if(head.children[i].colSpan > 1) return { n: 0, head: null, cells: [] };
    return { n: n, head: head, cells: head ? head.children : [] };
  }

  function fit(tab, C){
    var cs = getComputedStyle(tab);
    var fb = cs.fontSize + " " + cs.fontFamily;
    var head = C.cells;
    var body = tab.querySelectorAll("tbody tr");
    var hFont = fontOf(head[0], fb);
    var firstTd = tab.querySelector("tbody td");
    var bFont = fontOf(firstTd, fb);
    var hPad = padOf(head[0]) + GRIP;
    var bPad = padOf(firstTd);
    var out = [], txt = [], typ = [], got = [];
    for(var i = 0; i < C.n; i++){
      var need = textW(head[i].textContent.trim(), hFont) + hPad;
      /* سربارِ کادر یک بار، از روی اولین خانه‌ای که کادر دارد */
      var extra = 0, gotExtra = false, free = true, kind = "", filled = false;
      for(var j = 0; j < body.length; j++){
        /* ردیفِ «چیزی ثبت نشده» یک خانهٔ کشیده روی همهٔ ستون‌هاست؛ اگر
           به حساب بیاید، متنِ بلندش پهنای ستونِ اول می‌شود. */
        if(body[j].children.length !== C.n) continue;
        var td = body[j].children[i];
        if(!td || td.colSpan > 1) continue;
        var chip = chipPad(td);
        if(chip > extra && !gotExtra) extra = chip;
        if(!gotExtra){
          var f = td.querySelector("input,select,textarea");
          if(f){
            extra = fieldPad(f); gotExtra = true;
            /* کشویی، عدد، تاریخ و تیک اندازهٔ خودشان را دارند: پهن‌تر
               کردنشان فقط فضای خالی می‌سازد. فقط متنِ آزاد رشد می‌کند. */
            var tp = (f.getAttribute("type") || "text").toLowerCase();
            if(f.tagName === "TEXTAREA") kind = "long";
            else if(f.tagName === "INPUT" && (tp === "text" || tp === "search")) kind = "text";
            free = !!kind;
          }
        }
        /* متنِ چندخطی: بلندترین خطش، نه کلِ متن */
        var cell = String(cellText(td));
        if(String(cellVal(td)).trim()) filled = true;
        var parts = cell.split("\n");
        for(var q = 0; q < parts.length; q++){
          var w = textW(parts[q].trim(), bFont) + bPad;
          if(w > need) need = w;
        }
      }
      out.push(Math.max(MIN, Math.min(MAX, Math.ceil(need + extra + SLACK))));
      txt.push(free);
      typ.push(kind);
      got.push(filled);
    }
    return { w: out, txt: txt, typ: typ, got: got };
  }

  function apply(tab, ignoreSaved){
    var C = colsOf(tab);
    if(!C.n || !C.head) return;
    var head = C.cells;
    var group = tab.querySelector("colgroup");
    if(!group || group.children.length !== C.n){
      if(group) group.remove();
      group = document.createElement("colgroup");
      for(var i = 0; i < C.n; i++) group.appendChild(document.createElement("col"));
      tab.insertBefore(group, tab.firstChild);
    }
    var saved = ignoreSaved ? null : load(tabId(tab));
    var F = fit(tab, C), auto = F.w;
    var w = [];
    for(var j = 0; j < C.n; j++){
      var k = head[j].textContent.trim() || String(j);
      w.push((saved && saved[k]) || auto[j] || MIN);
    }
    /* اگر مجموعِ ستون‌ها از پهنای کادر بیشتر شد، همه به نسبتِ فضای
       اضافه‌شان کوچک می‌شوند تا کلِ جدول یک‌جا دیده شود — «فیت»
       یعنی همین، نه اینکه ستونِ اول از لبه بزند بیرون. پهنایی که
       خودِ کاربر با دست کشیده دست نمی‌خورد؛ آن‌جا کادر می‌لغزد. */
    if(!saved){ shrink(tab, w); grow(tab, w, auto, F.txt, F.typ, F.got); }
    var total = 0;
    for(var q = 0; q < w.length; q++){
      group.children[q].style.width = w[q] + "px";
      total += w[q];
    }
    tab.classList.add("tsz-on");
    tab.style.tableLayout = "fixed";
    /* جدول دقیقاً به اندازهٔ مجموعِ ستون‌هایش، با عددِ پیکسلی.
       دو دام این‌جا بود:
       • width:100% (یا min-width:100%) ⟵ کمبودِ پهنا را بینِ ستون‌ها
         پخش می‌کرد؛ همان «گشاد شدن» که با دکمه می‌دیدید.
       • width:max-content ⟵ به نظر بی‌خطر می‌آمد، ولی چیدمانِ ثابت
         فقط وقتی به کار می‌افتد که پهنای جدول عددِ مشخصی باشد؛ با
         max-content مرورگر به چیدمانِ خودکار برمی‌گشت و colgroup را
         فقط یک پیشنهاد می‌گرفت — جدول ۱۲۳۵ می‌شد در حالی که مجموعِ
         ستون‌ها ۹۱۸ بود. */
    tab.style.width = total + "px";
    tab.style.minWidth = "0";
    tab.style.maxWidth = "none";
  }

  /* پهنای واقعیِ جایی که جدول در آن می‌نشیند */
  function roomFor(tab){
    var wrap = tab.closest(".tbl-wrap") || tab.parentNode;
    if(!wrap || !wrap.getBoundingClientRect) return 0;
    var r = wrap.getBoundingClientRect();
    if(!r.width) return 0;
    var cs = getComputedStyle(wrap);
    return Math.floor(r.width - (parseFloat(cs.paddingLeft) || 0)
                              - (parseFloat(cs.paddingRight) || 0) - 1);
  }

  /* بزرگ‌کردنِ فضای باقی‌مانده — ولی فقط برای ستون‌هایی که واقعاً
     متن دارند. اگر همه را به یک نسبت پهن کنیم، «مسئول» و «وضعیت»
     دوباره گشاد می‌شوند؛ و اگر هیچ‌کدام را پهن نکنیم، کارت نیمه‌خالی
     می‌ماند. پس سهمِ اضافه می‌رود سراغِ ستونی که متنش بریده شده. */
  function grow(tab, w, auto, txt, typ, got){
    var room = roomFor(tab);
    if(room < 120) return;
    var i, total = 0;
    for(i = 0; i < w.length; i++) total += w[i];
    var extra = room - total;
    if(extra < 8) return;
    /* وزنِ هر ستون در تقسیمِ فضای اضافه.
       ستونی که کادرِ متنِ آزاد دارد جایی است که کاربر *می‌نویسد* — و
       آنچه می‌نویسد هنوز آن‌جا نیست. اگر وزنش را از محتوای امروزش
       بگیریم، «یادداشت»ِ خالی برای همیشه هشتاد پیکسل می‌ماند و اولین
       جمله‌ای که تویش بنویسند سه خط می‌شود. پس کفِ وزن TYPE_MIN است،
       و کادرِ چندخطی (که برای پاراگراف ساخته شده) وزنِ بیشتری دارد. */
    var pick = [], wt = [], base = 0;
    for(i = 0; i < w.length; i++){
      if(!txt[i]) continue;
      var fieldy = typ && (typ[i] === "text" || typ[i] === "long");
      var empty = fieldy && got && !got[i];
      if(!fieldy && auto[i] < GROW_MIN) continue;
      if(fieldy && !empty && typ[i] !== "long" && auto[i] < FIELD_MIN) continue;
      var v = empty ? Math.max(auto[i], TYPE_MIN) : auto[i];
      if(typ && typ[i] === "long") v = Math.round(Math.max(v, TYPE_MIN) * LONG_WEIGHT);
      pick.push(i); wt[i] = v; base += v;
    }
    if(!pick.length || !base) return;
    /* اول کفِ ستون‌های نوشتنی، بعد تقسیمِ نسبتی.
       بدونِ این ترتیب، «یادداشت»ِ خالی و «مسئول» که یک نامِ کوتاه دارد
       هر دو به یک اندازه می‌رسیدند — در حالی که یکی جای نوشتن است و
       آن یکی نه. */
    for(var z = 0; z < pick.length && extra > 0; z++){
      var m = pick[z];
      var floorW = (typ && typ[m] === "long") ? Math.round(TYPE_MIN * LONG_WEIGHT)
                 : (got && !got[m] && typ && (typ[m] === "text" || typ[m] === "long")) ? TYPE_MIN
                 : 0;
      if(floorW <= w[m]) continue;
      var add = Math.min(floorW - w[m], extra);
      w[m] += add; extra -= add;
    }
    if(extra < 8) return;
    /* دو مرحله: اول با سقفِ «۲٫۲ برابرِ وزن» تا ستونِ کوتاه بی‌دلیل
       کش نیاید. اگر بعدش هنوز کارت نیمه‌خالی ماند (مثلِ جدولی که فقط
       یک ستونِ متنی دارد)، باقی‌مانده هم بینِ همان‌ها پخش می‌شود، این
       بار فقط با سقفِ مطلق. */
    spread(w, pick, wt, base, extra, 2.2);
    var used = 0;
    for(i = 0; i < w.length; i++) used += w[i];
    var left = room - used;
    if(left > 24) spread(w, pick, wt, base, left, 0);
  }

  function spread(w, pick, wt, base, extra, ratio){
    for(var q = 0; q < pick.length; q++){
      var k = pick[q];
      var want = w[k] + Math.floor(extra * (wt[k] / base));
      var cap = ratio ? Math.min(Math.round(wt[k] * ratio), GROW_MAX) : GROW_MAX;
      w[k] = Math.max(w[k], Math.min(want, cap));
    }
  }

  /* کوچک‌کردن به نسبتِ فضای اضافهٔ هر ستون: ستونی که فقط به اندازهٔ
     حداقل است دست نمی‌خورد، و ستونِ پهن بیشترِ بار را می‌برد. */
  function shrink(tab, w){
    var room = roomFor(tab);
    if(room < 120) return;
    var sum = 0, slackAll = 0, i;
    for(i = 0; i < w.length; i++){ sum += w[i]; slackAll += Math.max(0, w[i] - MIN); }
    if(sum <= room || slackAll <= 0) return;
    var cut = Math.min(sum - room, slackAll);
    var done = 0;
    for(i = 0; i < w.length; i++){
      var share = Math.round(cut * (Math.max(0, w[i] - MIN) / slackAll));
      if(i === w.length - 1) share = cut - done;
      done += share;
      w[i] = Math.max(MIN, w[i] - share);
    }
  }

  /* دستهٔ کشیدن. یک بار برای هر جدول سوار می‌شود. */
  function wire(tab){
    if(tab[SEEN]) return;
    tab[SEEN] = 1;
    var C = colsOf(tab);
    if(!C.n || !C.head){ tab[SEEN] = 0; return; }
    for(var i = 0; i < C.n; i++){
      var th = C.cells[i];
      if(th.querySelector(".tsz-grip")) continue;
      th.style.position = th.style.position || "relative";
      var g = document.createElement("i");
      g.className = "tsz-grip";
      th.appendChild(g);
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
      /* جدولِ خالی هم دسته و دکمه می‌گیرد: پهنا را پیش از پر شدنِ
         جدول هم باید بشود چید. ولی سرستونِ گروهی (colspan) و جدولِ
         تک‌ستونیِ داخلِ کارت نه. */
      if(colsOf(tab).n < 2) continue;
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
