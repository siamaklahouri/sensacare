/* ==================== خواندنِ اکسل: ستون از روی نام ====================
   تا امروز هر برگه با «جای» ستون خوانده می‌شد: اولی شماره، دومی نام،
   سومی وضعیت… . سه ایراد داشت:

   یک) فایلی که نامِ برگه‌اش «Sheet1» بود — یعنی هر فایلی که خودِ
       کارتابل نساخته باشد — اصلاً پیدا نمی‌شد، و صفحه می‌گفت
       «✓ خوانده شد». کاربر حق داشت بگوید «هیچی نشون نمیده».
   دو) فایلی که ستون‌هایش جابه‌جا بود، داده را در خانهٔ اشتباه می‌نشاند
       و هیچ‌کس خبردار نمی‌شد.
   سه) ستونی که نمی‌شناختیم بی‌صدا دور ریخته می‌شد.

   حالا سطرِ اولِ فایل سرستون است: هر ستون از روی نامش سرِ جای خودش
   می‌نشیند، به هر ترتیبی که باشد. نامی که نشناسیم هم دور ریخته
   نمی‌شود — زیرِ _x همراهِ ردیف می‌ماند تا جدول نشانش بدهد.

   هیچ‌کدامِ این‌ها فایلِ خودِ کارتابل را نمی‌شکند: سرستون‌های آن فایل
   جزوِ همین نام‌هاست. */
(function(){
  "use strict";

  var FA = "۰۱۲۳۴۵۶۷۸۹", AR = "٠١٢٣٤٥٦٧٨٩";

  /* برای مقایسه: بی‌فاصله و نیم‌فاصله، ی و ک عربی و فارسی یکی، رقم‌ها
     لاتین، و بی‌نشانه. پس «شمارهٔ تماس»، «شماره تماس» و «شماره_تماس»
     یکی‌اند. */
  function norm(s){
    s = String(s == null ? "" : s).toLowerCase();
    s = s.replace(/[‌‎‏]/g, "");
    s = s.replace(/[ يﻱﻲ]/g, function(c){ return c === " " ? " " : "ی"; });
    s = s.replace(/[كﻙﻚ]/g, "ک").replace(/ۀ/g, "ه").replace(/ة/g, "ه").replace(/أ|إ|آ/g, "ا");
    s = s.replace(/[۰-۹]/g, function(d){ return String(FA.indexOf(d)); });
    s = s.replace(/[٠-٩]/g, function(d){ return String(AR.indexOf(d)); });
    s = s.replace(/[\s_\-./\\()\[\]:#،,'"]+/g, "");
    return s;
  }

  function matrix(wb, name){
    var ws = wb && wb.Sheets && wb.Sheets[name];
    if(!ws) return null;
    try{ return XLSX.utils.sheet_to_json(ws, { header:1, raw:true, defval:null }); }
    catch(e){ return null; }
  }

  function rowEmpty(r){
    if(!r) return true;
    for(var i = 0; i < r.length; i++)
      if(r[i] != null && String(r[i]).trim() !== "") return false;
    return true;
  }

  function headRow(m){
    var h = 0;
    while(h < m.length && rowEmpty(m[h])) h++;
    return h < m.length ? h : -1;
  }

  /* نامِ این سرستون با کدام ستونِ ما می‌خواند؟ اول برابریِ کامل، بعد
     دربرگیری — «شمارهٔ تماسِ مشتری» همان «شماره تماس» است. */
  function findKey(label, schema){
    var v = norm(label), i, j, a;
    if(!v) return null;
    for(i = 0; i < schema.length; i++)
      for(j = 0; j < schema[i].as.length; j++)
        if(norm(schema[i].as[j]) === v) return schema[i].k;
    for(i = 0; i < schema.length; i++)
      for(j = 0; j < schema[i].as.length; j++){
        a = norm(schema[i].as[j]);
        if(a.length >= 3 && (v.indexOf(a) >= 0 || a.indexOf(v) >= 0)) return schema[i].k;
      }
    return null;
  }

  function score(head, schema){
    var n = 0, seen = {};
    for(var i = 0; i < (head || []).length; i++){
      var k = findKey(head[i], schema);
      if(k && !seen[k]){ seen[k] = 1; n++; }
    }
    return n;
  }

  /* کدام برگه؟ نامی که خواسته‌ایم، وگرنه آن که سرستون‌هایش از همه
     بیشتر با این بخش می‌خواند، وگرنه اولین برگهٔ پُر. */
  /* strict یعنی «اگر نشناختی، هیچ»: برای برگه‌هایی که ستونِ ثابت
     ندارند و نمی‌شود از روی سرستون شناختشان. بی این، چک‌لیستِ ریموت
     اولین برگهٔ هر فایلی را برمی‌داشت و ستونِ اولش را نامِ سرور
     می‌خواند — یعنی یک فایلِ بی‌ربط هم «۲ ردیف» می‌شد. */
  function pickSheet(wb, want, schema, strict){
    var names = (wb && wb.SheetNames) || [], i, m, h;
    if(want && names.indexOf(want) >= 0) return want;
    var best = null, bestScore = 0, first = null;
    for(i = 0; i < names.length; i++){
      m = matrix(wb, names[i]);
      if(!m || !m.length) continue;
      h = headRow(m);
      if(h < 0) continue;
      if(first == null) first = names[i];
      var sc = score(m[h], schema);
      if(sc > bestScore){ bestScore = sc; best = names[i]; }
    }
    if(bestScore > 0) return best;
    return strict ? null : first;
  }

  /* خروجی:
       sheet   نامِ برگه‌ای که خوانده شد
       rows    ردیف‌ها، با کلیدهای خودِ بخش و (اگر بود) _x برای اضافه‌ها
       extras  نامِ ستون‌هایی که نمی‌شناختیم، به ترتیبِ خودِ فایل
       matched چند ستون را شناختیم
       byName  از روی نام خواندیم یا از روی جای ستون */
  function read(wb, want, schema){
    var out = { sheet:null, rows:[], extras:[], matched:0, byName:false, found:false };
    var name = pickSheet(wb, want, schema);
    if(!name) return out;
    var m = matrix(wb, name);
    if(!m || !m.length) return out;
    var h = headRow(m);
    if(h < 0) return out;
    out.sheet = name; out.found = true;

    var head = m[h] || [], map = [], extras = [], hit = 0, i, k, lbl;
    for(i = 0; i < head.length; i++){
      k = findKey(head[i], schema);
      if(k){ map[i] = k; hit++; continue; }
      map[i] = null;
      lbl = String(head[i] == null ? "" : head[i]).trim();
      if(lbl) extras.push({ at:i, label:lbl });
    }
    out.matched = hit;
    out.byName = hit > 0;

    /* هیچ سرستونی را نشناختیم. دو حالت دارد و باید از هم جدا شوند:
       اگر این سطر اصلاً سرستون نیست (مثلاً فایلِ بی‌عنوان)، همان
       ترتیبِ قدیمیِ ستون‌ها را می‌گذاریم؛ وگرنه همه‌اش «ستونِ اضافه»
       است و دست‌نخورده می‌ماند تا جدول نشانش بدهد. */
    if(hit === 0 && looksLikeData(head)){
      extras.length = 0;
      map = [];
      for(i = 0; i < schema.length; i++) map[i] = schema[i].k;
      out.extras = [];
      return collect(out, m, h, map, extras);      /* از همین سطر */
    }
    out.extras = extras.map(function(e){ return e.label; });
    return collect(out, m, h + 1, map, extras);
  }

  /* سطری که عدد یا تاریخ دارد سرستون نیست، داده است. */
  function looksLikeData(head){
    for(var i = 0; i < (head || []).length; i++){
      var v = head[i];
      if(typeof v === "number") return true;
      if(v instanceof Date) return true;
      if(typeof v === "string" && /^\s*[-+]?[\d۰-۹٠-٩][\d۰-۹٠-٩\s/.,:-]*$/.test(v) && v.trim().length > 1)
        return true;
    }
    return false;
  }

  function collect(out, m, start, map, extras){
    for(var r = start; r < m.length; r++){
      var row = m[r];
      if(rowEmpty(row)) continue;
      var obj = {}, x = null, i, v;
      for(i = 0; i < map.length; i++){
        if(!map[i]) continue;
        v = row[i];
        obj[map[i]] = v == null ? "" : v;
      }
      for(i = 0; i < extras.length; i++){
        v = row[extras[i].at];
        if(v == null || String(v).trim() === "") continue;
        if(!x) x = {};
        x[extras[i].label] = v;
      }
      if(x) obj._x = x;
      out.rows.push(obj);
    }
    return out;
  }

  /* ---------- ستون‌های اضافه در جدول ----------
     نامِ ستون‌ها از خودِ ردیف‌ها درمی‌آید، نه از جایی که ذخیره شده
     باشد — پس با پشتیبان و بازیابی هم می‌آید و یک فهرستِ موازی نیست
     که روزی عقب بماند. */
  function extraNames(rows){
    var seen = {}, out = [];
    for(var i = 0; i < (rows || []).length; i++){
      var x = rows[i] && rows[i]._x;
      if(!x) continue;
      for(var k in x) if(!seen[k]){ seen[k] = 1; out.push(k); }
    }
    return out;
  }

  /* بعد از ساخته‌شدنِ جدول صدا زده می‌شود: سرستون‌های اضافه را به
     سربرگ و خانه‌هایشان را به هر ردیف می‌چسباند. ردیف‌ها با همان
     ترتیبی که رسم شده‌اند خوانده می‌شوند. */
  function paintExtras(table, rows, opt){
    if(!table) return;
    opt = opt || {};
    var old = table.querySelectorAll("[data-xtra]");
    for(var i = 0; i < old.length; i++) old[i].remove();
    var names = extraNames(rows);
    if(!names.length) return;

    var hr = table.querySelector("thead tr");
    var before = opt.beforeLast == null ? true : opt.beforeLast;
    var j;
    if(hr){
      for(j = 0; j < names.length; j++){
        var th = document.createElement("th");
        th.setAttribute("data-xtra", "1");
        th.textContent = names[j];
        th.title = "ستونی که از فایل اکسل آمده";
        if(before && hr.lastElementChild) hr.insertBefore(th, hr.lastElementChild);
        else hr.appendChild(th);
      }
    }
    var trs = table.querySelectorAll("tbody tr");
    for(i = 0; i < trs.length; i++){
      var row = rows[i];
      /* ردیفِ «موردی پیدا نشد» یا ردیفِ افزودن، ردیفِ داده نیست */
      if(trs[i].classList.contains("add-row") || trs[i].children.length === 1){
        if(trs[i].children.length === 1 && trs[i].children[0].hasAttribute("colspan"))
          trs[i].children[0].setAttribute("colspan",
            String(Number(trs[i].children[0].getAttribute("colspan") || 1) + names.length));
        continue;
      }
      for(j = 0; j < names.length; j++){
        var td = document.createElement("td");
        td.setAttribute("data-xtra", "1");
        var v = row && row._x ? row._x[names[j]] : "";
        td.textContent = v == null ? "" : String(v);
        if(before && trs[i].lastElementChild) trs[i].insertBefore(td, trs[i].lastElementChild);
        else trs[i].appendChild(td);
      }
    }
  }

  window.XMap = {
    norm: norm, read: read, pickSheet: pickSheet, matrix: matrix,
    extraNames: extraNames, paintExtras: paintExtras
  };
})();
