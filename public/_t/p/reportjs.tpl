/* ==================== گزارش‌ساز ====================
   اکسل را همین‌جا در مرورگر می‌خوانیم؛ هیچ بایتی به سرور نمی‌رود.

   سه چیزی که شکلِ این کد را تعیین کرد:

   یک) سرستون همیشه سطرِ اول نیست. فایل‌های واقعی بالایشان عنوان و
   خطِ خالی دارند. پس دنبالِ اولین سطری می‌گردیم که بیشترِ خانه‌هایش
   پُر و متنی باشد و سطرِ بعدش هم داده داشته باشد.

   دو) عددهای فارسی. «۱۲۳» در اکسل رشته است نه عدد، و اگر همان‌طور
   جمع بزنیم صفر درمی‌آید. هر رقمِ فارسی و عربی به لاتین برمی‌گردد.

   سه) نوعِ ستون را از خودِ داده می‌فهمیم، نه از نامش: اگر بیشترِ
   خانه‌های پُرش عدد بود، عددی است. «محاسبه»های جمع و میانگین فقط
   ستون‌های عددی را پیشنهاد می‌دهند. */
(function(){
  "use strict";
  var sec = document.getElementById("view-report");
  if(!sec) return;

  var RP = { rows: [], cols: [], name: "", wb: null, chart: null, summary: [] };
  var $ = function(id){ return document.getElementById(id); };
  var esc = function(t){ return String(t == null ? "" : t)
    .replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;"); };
  var faD = function(n){ return String(n).replace(/[0-9]/g, function(d){ return "۰۱۲۳۴۵۶۷۸۹"[d]; }); };

  /* «۱٬۲۳۴٫۵» و «1,234.5» هر دو یک عددند */
  function num(v){
    if(typeof v === "number") return isFinite(v) ? v : null;
    if(v == null) return null;
    var t = String(v)
      .replace(/[۰-۹]/g, function(d){ return String("۰۱۲۳۴۵۶۷۸۹".indexOf(d)); })
      .replace(/[٠-٩]/g, function(d){ return String("٠١٢٣٤٥٦٧٨٩".indexOf(d)); })
      .replace(/[,٬\s]/g, "").replace(/٫/g, ".").trim();
    if(!t || !/^-?\d*\.?\d+$/.test(t)) return null;
    var n = Number(t);
    return isFinite(n) ? n : null;
  }
  var fmt = function(n){
    var r = Math.abs(n) >= 1000 ? Math.round(n) : Math.round(n * 100) / 100;
    return faD(r.toLocaleString("en-US"));
  };
  /* تاریخ‌ها را SheetJS شیء می‌دهد؛ برای دسته‌بندی، متنِ کوتاهش بس است */
  function cell(v){
    if(v == null) return "";
    if(v instanceof Date && !isNaN(v)) return v.toISOString().slice(0,10);
    return String(v).trim();
  }

  function pickHeader(aoa){
    var best = 0, score = -1;
    for(var i = 0; i < Math.min(aoa.length, 25); i++){
      var r = aoa[i] || [];
      var filled = 0, texty = 0;
      for(var j = 0; j < r.length; j++){
        var t = cell(r[j]);
        if(!t) continue;
        filled++;
        if(num(r[j]) === null) texty++;
      }
      if(filled < 2) continue;
      var next = aoa[i+1] || [];
      var nextFilled = next.filter(function(x){ return cell(x); }).length;
      var sc = filled + texty + (nextFilled >= 2 ? 3 : -4);
      if(sc > score){ score = sc; best = i; }
    }
    return best;
  }

  function load(aoa){
    var h = pickHeader(aoa);
    var head = (aoa[h] || []).map(function(x, i){
      var t = cell(x); return t || "ستون " + faD(i + 1);
    });
    /* نام‌های تکراری از هم جدا می‌شوند، وگرنه دو ستون یک کلید می‌گرفتند */
    var seen = {};
    head = head.map(function(t){
      if(!seen[t]){ seen[t] = 1; return t; }
      seen[t]++; return t + " (" + faD(seen[t]) + ")";
    });
    var rows = [];
    for(var i = h + 1; i < aoa.length; i++){
      var r = aoa[i] || [];
      if(!r.some(function(x){ return cell(x); })) continue;
      var o = {};
      for(var j = 0; j < head.length; j++) o[head[j]] = r[j];
      rows.push(o);
    }
    RP.rows = rows;
    RP.cols = head.map(function(t){
      var n = 0, filled = 0;
      for(var i = 0; i < rows.length; i++){
        var v = rows[i][t];
        if(cell(v) === "") continue;
        filled++;
        if(num(v) !== null) n++;
      }
      return { t: t, numeric: filled > 0 && n / filled >= 0.7, filled: filled };
    });
  }

  function note(t, bad){
    var el = $("rpNote");
    el.textContent = t || "";
    el.classList.toggle("bad", !!bad);
  }

  async function readFile(f){
    if(!f) return;
    note("در حال خواندن…");
    if(!(await ensureXlsxLib())){ note("کتابخانهٔ اکسل بار نشد. اینترنت را بررسی کنید.", true); return; }
    try{
      var buf = await f.arrayBuffer();
      var wb = XLSX.read(buf, { type:"array", cellDates:true });
      if(!wb.SheetNames.length){ note("این فایل برگه‌ای ندارد.", true); return; }
      RP.wb = wb; RP.name = f.name;
      $("rpSheet").innerHTML = wb.SheetNames.map(function(n){
        return '<option value="' + esc(n) + '">' + esc(n) + "</option>"; }).join("");
      $("rpName").textContent = f.name;
      note("");
      useSheet(wb.SheetNames[0]);
    }catch(e){
      note("این فایل خوانده نشد. اگر اکسل است، یک بار در خودِ اکسل ذخیره‌اش کنید و دوباره بدهید.", true);
    }
  }

  function useSheet(name){
    var ws = RP.wb.Sheets[name];
    var aoa = XLSX.utils.sheet_to_json(ws, { header:1, blankrows:false, defval:"" });
    load(aoa);
    if(!RP.rows.length || !RP.cols.length){
      note("در برگهٔ «" + name + "» داده‌ای پیدا نشد.", true);
      $("rpBody").hidden = true; return;
    }
    $("rpMeta").textContent = faD(RP.rows.length) + " ردیف · " + faD(RP.cols.length) + " ستون";
    $("rpBody").hidden = false;
    fillCols();
    draw();
  }

  function fillCols(){
    var cat = $("rpCat"), val = $("rpVal");
    /* دسته‌بندی با ستونِ متنی معنی دارد؛ ولی اگر همه عددی بودند، جلوی
       کسی گرفته نمی‌شود — فقط ترتیبِ پیشنهاد فرق می‌کند. */
    var order = RP.cols.slice().sort(function(a,b){ return (a.numeric?1:0) - (b.numeric?1:0); });
    cat.innerHTML = order.map(function(c){
      return '<option value="' + esc(c.t) + '">' + esc(c.t) + "</option>"; }).join("");
    var nums = RP.cols.filter(function(c){ return c.numeric; });
    val.innerHTML = (nums.length ? nums : RP.cols).map(function(c){
      return '<option value="' + esc(c.t) + '">' + esc(c.t) + "</option>"; }).join("");
    if(!nums.length) $("rpAgg").value = "count";
  }

  function agg(list, how){
    if(how === "count") return list.length;
    var ns = list.map(num).filter(function(x){ return x !== null; });
    if(!ns.length) return 0;
    if(how === "sum") return ns.reduce(function(a,b){ return a+b; }, 0);
    if(how === "avg") return ns.reduce(function(a,b){ return a+b; }, 0) / ns.length;
    if(how === "max") return Math.max.apply(null, ns);
    if(how === "min") return Math.min.apply(null, ns);
    return 0;
  }

  var AGG_NAME = { sum:"جمع", avg:"میانگین", count:"شمارش", max:"بیشینه", min:"کمینه" };

  function build(){
    var catName = $("rpCat").value, valName = $("rpVal").value, how = $("rpAgg").value;
    var groups = {}, order = [];
    for(var i = 0; i < RP.rows.length; i++){
      var k = cell(RP.rows[i][catName]) || "—";
      if(!groups[k]){ groups[k] = []; order.push(k); }
      groups[k].push(RP.rows[i][valName]);
    }
    var out = order.map(function(k){ return { k: k, n: agg(groups[k], how), rows: groups[k].length }; });
    var sort = $("rpSort").value;
    if(sort === "cat") out.sort(function(a,b){ return String(a.k).localeCompare(String(b.k), "fa"); });
    else out.sort(function(a,b){ return sort === "asc" ? a.n - b.n : b.n - a.n; });
    var top = Number($("rpTop").value) || 0;
    var cut = top > 0 && out.length > top;
    return { list: cut ? out.slice(0, top) : out, all: out, cut: cut };
  }

  function cards(d){
    var how = $("rpAgg").value, t = chartTone();
    var vals = d.all.map(function(x){ return x.n; });
    var total = vals.reduce(function(a,b){ return a+b; }, 0);
    var top = d.all.slice().sort(function(a,b){ return b.n - a.n; })[0];
    var box = [
      ["ردیف‌های فایل", faD(RP.rows.length), t.cat[0]],
      ["تعداد دسته", faD(d.all.length), t.cat[2]],
      [how === "avg" ? "میانگینِ کل" : "جمعِ کل",
       fmt(how === "avg" && vals.length ? total / vals.length : total), t.cat[1]],
      ["بیشترین", top ? esc(top.k) + " — " + fmt(top.n) : "—", t.cat[3]]
    ];
    $("rpCards").innerHTML = box.map(function(x){
      return '<div class="rp-card" style="--rc:' + x[2] + '">' +
        '<span class="n">' + x[1] + "</span><span class=\"t\">" + esc(x[0]) + "</span></div>";
    }).join("");
  }

  function table(d){
    var how = $("rpAgg").value;
    RP.summary = [[$("rpCat").value, AGG_NAME[how] + (how === "count" ? "" : " — " + $("rpVal").value), "ردیف"]];
    d.list.forEach(function(x){ RP.summary.push([x.k, x.n, x.rows]); });
    $("rpTab").innerHTML =
      "<thead><tr><th>" + esc(RP.summary[0][0]) + "</th><th>" + esc(RP.summary[0][1]) +
      "</th><th>ردیف</th></tr></thead><tbody>" +
      d.list.map(function(x){
        return "<tr><td>" + esc(x.k) + '</td><td class="num">' + fmt(x.n) +
               '</td><td class="num">' + faD(x.rows) + "</td></tr>"; }).join("") +
      "</tbody>";
  }

  async function chart(d){
    var kind = $("rpKind").value;
    var box = $("rpChartBox");
    if(RP.chart){ try{ RP.chart.destroy(); }catch(e){} RP.chart = null; }
    box.hidden = kind === "table";
    if(kind === "table") return;
    if(!(await ensureChartLib())) return;
    var t = chartTone();
    var labels = d.list.map(function(x){ return x.k; });
    var data = d.list.map(function(x){ return Math.round(x.n * 100) / 100; });
    /* یک سری با یک رنگ؛ دایره‌ای با پالتِ دسته‌ها چون آن‌جا هر برش
       یک هویتِ جداست، نه یک اندازه روی یک محور. */
    var colors = kind === "doughnut"
      ? labels.map(function(_, i){ return t.cat[i % t.cat.length]; })
      : t.cat[0];
    RP.chart = new Chart($("rpChart").getContext("2d"), {
      type: kind === "hbar" ? "bar" : kind,
      data: { labels: labels, datasets: [{
        label: AGG_NAME[$("rpAgg").value], data: data,
        backgroundColor: colors, borderColor: colors,
        borderWidth: kind === "line" ? 2 : 0, fill: false, tension: .25,
        borderRadius: kind === "doughnut" ? 0 : 6 }] },
      options: {
        indexAxis: kind === "hbar" ? "y" : "x",
        plugins: {
          legend: { display: kind === "doughnut", position: "bottom",
                    labels: { boxWidth: 12, font: { size: 11 } } },
          tooltip: { callbacks: { label: function(c){ return " " + fmt(c.parsed.y != null && kind !== "hbar" ? c.parsed.y : (c.parsed.x != null && kind === "hbar" ? c.parsed.x : c.parsed)); } } }
        },
        scales: kind === "doughnut" ? {} : {
          x: { ticks: { font: { size: 10.5 } } },
          y: { beginAtZero: true, ticks: { font: { size: 10.5 },
               callback: function(v){ return fmt(v); } } }
        }
      }
    });
  }

  function draw(){
    if(!RP.rows.length) return;
    var how = $("rpAgg").value;
    $("rpValWrap").hidden = how === "count";
    var d = build();
    var ttl = AGG_NAME[how] + (how === "count" ? " ردیف‌ها" : "ِ «" + $("rpVal").value + "»") +
              " بر اساس «" + $("rpCat").value + "»";
    $("rpTitle").textContent = ttl;
    $("rpWhy").textContent = d.cut
      ? "از " + faD(d.all.length) + " دسته، " + faD(d.list.length) + " تای اول نشان داده شده."
      : faD(d.all.length) + " دسته.";
    cards(d); table(d); chart(d);
  }

  /* ---- سیم‌کشی ---- */
  $("rpPick").addEventListener("click", function(){ $("rpFile").click(); });
  $("rpFile").addEventListener("change", function(e){ readFile(e.target.files[0]); e.target.value = ""; });
  var drop = $("rpDrop");
  ["dragenter","dragover"].forEach(function(n){ drop.addEventListener(n, function(e){
    e.preventDefault(); drop.classList.add("on"); }); });
  ["dragleave","drop"].forEach(function(n){ drop.addEventListener(n, function(e){
    e.preventDefault(); drop.classList.remove("on"); }); });
  drop.addEventListener("drop", function(e){
    if(e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0]) readFile(e.dataTransfer.files[0]); });
  $("rpSheet").addEventListener("change", function(){ useSheet($("rpSheet").value); });
  ["rpKind","rpCat","rpVal","rpAgg","rpTop","rpSort"].forEach(function(id){
    $(id).addEventListener("change", draw); });
  $("rpReset").addEventListener("click", function(){
    RP.rows = []; RP.cols = []; RP.wb = null;
    if(RP.chart){ try{ RP.chart.destroy(); }catch(e){} RP.chart = null; }
    $("rpBody").hidden = true; note("");
  });

  $("rpPng").addEventListener("click", function(){
    if(!RP.chart) return;
    var a = document.createElement("a");
    a.href = RP.chart.toBase64Image();
    a.download = "گزارش.png"; a.click();
  });
  $("rpXlsx").addEventListener("click", async function(){
    if(!RP.summary.length || !(await ensureXlsxLib())) return;
    var wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, XLSX.utils.aoa_to_sheet(RP.summary), "خلاصه");
    XLSX.writeFile(wb, "گزارش.xlsx");
  });
  $("rpPrint").addEventListener("click", function(){ window.print(); });

  /* تمِ شب که عوض شود، رنگِ نمودار هم باید عوض شود */
  new MutationObserver(function(){ if(RP.rows.length) draw(); })
    .observe(document.documentElement, { attributes:true, attributeFilter:["data-theme"] });
})();
