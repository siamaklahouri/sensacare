/* ==================== خروجیِ «برنامهٔ ماه» ====================
   دو دکمه کنارِ جدولِ برنامهٔ ماه: اکسل و پی‌دی‌اف.

   سه تصمیم:

   یک) جدول را همان‌طور که روی صفحه دیده می‌شود می‌خوانَد، نه از روی
   state. پس اگر کاربر پالایه گذاشته باشد، خروجی هم همان چیزی است که
   جلوی چشمش است — نه بیشتر. کسی که «فقط انجام‌نشده‌ها» را فیلتر کرده
   و خروجی می‌گیرد، انتظارِ همان‌ها را دارد.

   دو) ستون‌ها از خودِ سرصفحهٔ جدول خوانده می‌شوند، نه از یک فهرستِ
   دستی. دو کارتابل دو جدولِ کمی متفاوت دارند و فردا ممکن است ستونی
   اضافه شود؛ فهرستِ دستی همان‌جا عقب می‌افتاد.

   سه) پی‌دی‌اف در یک iframeِ جدا چاپ می‌شود، نه با چاپِ خودِ صفحه.
   دلیلش این است که گزارش‌ساز شیوه‌نامهٔ چاپِ خودش را دارد که هر چیزی
   جز گزارش را از کاغذ برمی‌دارد — اگر همین صفحه را چاپ می‌کردیم، آن
   قاعده برنامهٔ ماه را هم برمی‌داشت و کاغذ سفید در می‌آمد. iframe
   سندِ خودش را دارد، پس هیچ قاعده‌ای از این صفحه رویش نمی‌افتد. */
(function(){
  "use strict";

  /* نشانه‌ها از عنوانِ ستون برداشته می‌شوند: روی کاغذ و در اکسل
     «📌 وظایف اصلی» بد می‌نشیند و در جست‌وجوی اکسل هم گیر می‌کند. */
  function clean(s){
    return String(s || "")
      .replace(/[\u{1F000}-\u{1FAFF}\u{2190}-\u{2BFF}\u{2600}-\u{27BF}\u{FE0F}]/gu, "")
      .replace(/\s+/g, " ")
      .trim();
  }

  /* «—» روی صفحه یعنی «خالی» — هم در خانهٔ متنی، هم در گزینهٔ خالیِ
     یک فهرست. در اکسل اگر همین‌طور برود، ستون پر از خط تیره می‌شود و
     هیچ فرمول و پالایه‌ای هم رویش کار نمی‌کند. */
  function blankDash(v){
    var t = String(v == null ? "" : v).trim();
    return (t === "—" || t === "–" || t === "-") ? "" : t;
  }

  /* مقدارِ یک خانه، هر شکلی که در آن نشسته باشد */
  function cellText(td){
    if(!td) return "";
    var f = td.querySelector("input, textarea, select");
    if(f){
      if(f.tagName === "SELECT")
        return blankDash(f.selectedOptions && f.selectedOptions[0]
          ? f.selectedOptions[0].text : f.value);
      return blankDash(f.value);
    }
    /* ستونِ ستاره: «مهم» یا هیچ — نه خودِ شکلک */
    var star = td.querySelector(".star-btn");
    if(star) return star.classList.contains("is-important") ? "مهم" : "";
    return blankDash(clean(td.textContent));
  }

  function table(){ return document.querySelector("#view-daily .daily-plan-table"); }

  function collect(){
    var tbl = table();
    if(!tbl) return null;
    /* سطرِ اولِ سرصفحه؛ سطرِ دومْ پالایه است و عنوان ندارد */
    var head = tbl.querySelector("thead tr");
    if(!head) return null;

    /* ستونِ دکمهٔ حذف عنوان ندارد — همان نشانهٔ «این روی کاغذ نمی‌رود» */
    var keep = [];
    [].slice.call(head.children).forEach(function(th, i){
      var label = clean(th.getAttribute("title") || th.textContent);
      if(label) keep.push({ i: i, label: label });
    });

    var rows = [];
    [].slice.call(tbl.querySelectorAll("tbody tr")).forEach(function(tr){
      if(tr.offsetParent === null) return;            /* پالایه‌شده نمی‌رود */
      if(tr.children.length < 2) return;              /* سطرِ «موردی پیدا نشد» */
      var one = keep.map(function(k){ return cellText(tr.children[k.i]); });
      if(one.join("").trim()) rows.push(one);         /* ردیفِ یکسره خالی نمی‌رود */
    });
    return { head: keep.map(function(k){ return k.label; }), rows: rows };
  }

  function stamp(){
    var d = "";
    try{ if(typeof getTodayJalaliStr === "function") d = getTodayJalaliStr(); }catch(e){}
    /* بقیهٔ کارتابل رقم‌ها را فارسی نشان می‌دهد؛ این یکی هم باید */
    try{ if(d && typeof fa === "function") return fa(d); }catch(e){}
    return d;
  }
  /* همان تاریخ، ولی با رقمِ لاتین — این یکی برای نامِ فایل است */
  function stampLatin(){
    try{ if(typeof getTodayJalaliStr === "function") return getTodayJalaliStr(); }catch(e){}
    return "";
  }
  function title(){
    var t = document.querySelector("#view-daily .section-title");
    return clean(t && t.textContent) || "برنامهٔ ماه";
  }
  /* نامِ فایل عمداً اَسکی است. کروم نامِ دانلودِ غیرِاَسکی را دور
     می‌ریزد و فایل با نامِ «download» و بی‌پسوند ذخیره می‌شود — یعنی
     روی ویندوز با دوبار کلیک هم باز نمی‌شود. همان قاعده‌ای که
     گزارش‌ساز هم از آن پیروی می‌کند. */
  function fileName(){
    var d = stampLatin().replace(/[^0-9]+/g, "-").replace(/^-|-$/g, "");
    return ["barnameh-mah", d].filter(Boolean).join("-");
  }

  function say(msg, bad){
    try{
      if(typeof flashSaveHint === "function"){ flashSaveHint(msg); return; }
    }catch(e){}
    var h = document.getElementById("saveHint");
    if(h){ h.textContent = msg; return; }
    if(bad) alert(msg);
  }

  /* ---------------- اکسل ---------------- */
  async function toXlsx(){
    var d = collect();
    if(!d || !d.rows.length){ say("ردیفی برای خروجی نیست.", true); return; }
    var ok = false;
    try{ ok = await ensureXlsxLib(); }catch(e){ ok = false; }
    if(!ok || typeof XLSX === "undefined"){ say("کتابخانهٔ اکسل بار نشد.", true); return; }

    /* سرصفحه هم می‌رود، وگرنه فردا معلوم نیست این برگه مالِ چه ماهی بوده */
    var aoa = [[title()], [stamp()], []].concat([d.head]).concat(d.rows);
    var ws = XLSX.utils.aoa_to_sheet(aoa);
    ws["!cols"] = d.head.map(function(h){
      return { wch: Math.max(10, Math.min(42, String(h).length + 10)) };
    });
    /* راست‌چین، چون همهٔ محتوا فارسی است */
    ws["!views"] = [{ RTL: true }];
    var wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "برنامه ماه");
    XLSX.writeFile(wb, fileName() + ".xlsx");
    say("خروجیِ اکسل گرفته شد.");
  }

  /* ---------------- پی‌دی‌اف ---------------- */
  function esc(s){
    return String(s == null ? "" : s)
      .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  function paper(d){
    /* قلم از همین دامنه می‌آید، پس داخلِ iframe هم فارسی درست می‌نشیند */
    return '<!doctype html><html dir="rtl" lang="fa"><head><meta charset="utf-8">' +
      '<title>' + esc(fileName()) + '</title><style>' +
      '@font-face{font-family:Vazirmatn;font-weight:400;font-display:swap;' +
        'src:url(/f/Vazirmatn-Regular.2.woff2) format("woff2")}' +
      '@font-face{font-family:Vazirmatn;font-weight:700;font-display:swap;' +
        'src:url(/f/Vazirmatn-Bold.2.woff2) format("woff2")}' +
      '@page{size:A4 landscape; margin:12mm}' +
      'body{font-family:Vazirmatn,Tahoma,sans-serif; color:#111; margin:0; font-size:11px}' +
      'h1{font-size:15px; margin:0 0 2px}' +
      '.sub{font-size:10.5px; color:#555; margin:0 0 12px;' +
        'padding-bottom:8px; border-bottom:1px solid #999}' +
      'table{width:100%; border-collapse:collapse; table-layout:fixed}' +
      'th,td{border:1px solid #bbb; padding:5px 6px; text-align:right;' +
        'vertical-align:top; word-wrap:break-word}' +
      'th{background:#eee; font-weight:700; font-size:10.5px}' +
      /* ردیف نباید وسطِ دو صفحه نصف شود */
      'tr{page-break-inside:avoid}' +
      'thead{display:table-header-group}' +   /* سرصفحه سرِ هر صفحه تکرار شود */
      '</style></head><body>' +
      '<h1>' + esc(title()) + '</h1>' +
      '<div class="sub">' + esc(clean(document.title)) +
        (stamp() ? " — " + esc(stamp()) : "") +
        " — " + esc(d.rows.length) + " ردیف</div>" +
      '<table><thead><tr>' +
        d.head.map(function(h){ return "<th>" + esc(h) + "</th>"; }).join("") +
      '</tr></thead><tbody>' +
        d.rows.map(function(r){
          return "<tr>" + r.map(function(c){ return "<td>" + esc(c) + "</td>"; }).join("") + "</tr>";
        }).join("") +
      '</tbody></table></body></html>';
  }

  function toPdf(){
    var d = collect();
    if(!d || !d.rows.length){ say("ردیفی برای خروجی نیست.", true); return; }
    var old = document.getElementById("dayPrintFrame");
    if(old) old.remove();
    var ifr = document.createElement("iframe");
    ifr.id = "dayPrintFrame";
    ifr.setAttribute("aria-hidden", "true");
    ifr.style.cssText = "position:fixed; inset-block-start:-9999px; inset-inline-start:-9999px;" +
      "width:0; height:0; border:0; opacity:0;";
    ifr.srcdoc = paper(d);
    ifr.onload = function(){
      var w = ifr.contentWindow;
      /* کمی صبر تا قلم برسد؛ بی آن، چاپ با قلمِ جایگزین می‌رفت */
      setTimeout(function(){
        try{ w.focus(); w.print(); }catch(e){ say("چاپ باز نشد.", true); }
        setTimeout(function(){ try{ ifr.remove(); }catch(e){} }, 1500);
      }, 350);
    };
    document.body.appendChild(ifr);
    say("پنجرهٔ چاپ باز شد — «ذخیره به‌صورت PDF» را بزنید.");
  }

  /* ---------------- سیم‌کشی ---------------- */
  function wire(){
    var x = document.getElementById("dayXlsxBtn");
    var p = document.getElementById("dayPdfBtn");
    if(x && !x.__wired){ x.__wired = true; x.addEventListener("click", toXlsx); }
    if(p && !p.__wired){ p.__wired = true; p.addEventListener("click", toPdf); }
  }
  if(document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", wire);
  else wire();

  window.dayExport = { collect: collect, xlsx: toXlsx, pdf: toPdf };
})();
