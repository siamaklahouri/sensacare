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

  var OPT_NONE = '<option value="">— هیچ‌کدام —</option>';

  function fillCols(){
    var opts = function(list){
      return list.map(function(c){
        return '<option value="' + esc(c.t) + '">' + esc(c.t) + "</option>"; }).join("");
    };
    /* دسته‌بندی با ستونِ متنی معنی دارد، پس آن‌ها اول می‌آیند — ولی
       جلوی کسی گرفته نمی‌شود. */
    var byText = RP.cols.slice().sort(function(a,b){ return (a.numeric?1:0) - (b.numeric?1:0); });
    var nums = RP.cols.filter(function(c){ return c.numeric; });
    $("rpCat").innerHTML = opts(byText);
    $("rpSer").innerHTML = OPT_NONE + opts(byText);
    $("rpVal").innerHTML = OPT_NONE + opts(nums.length ? nums : RP.cols);
    $("rpFilCol").innerHTML = OPT_NONE + opts(byText);
    $("rpFilVal").innerHTML = OPT_NONE;
    if(nums.length) $("rpVal").value = nums[0].t; else $("rpAgg").value = "count";
  }

  /* مقدارهای یکتای یک ستون، برای کشویی فیلتر. سقف دارد چون ستونی با
     هزار مقدارِ متفاوت کشویی نمی‌خواهد. */
  function fillFilVals(){
    var col = $("rpFilCol").value, sel = $("rpFilVal");
    var keep = sel.value;
    if(!col){ sel.innerHTML = OPT_NONE; return; }
    var seen = {}, list = [];
    for(var i = 0; i < RP.rows.length; i++){
      var v = cell(RP.rows[i][col]);
      if(v === "" || seen[v]) continue;
      seen[v] = 1; list.push(v);
      if(list.length >= 300) break;
    }
    list.sort(function(a,b){ return a.localeCompare(b, "fa"); });
    sel.innerHTML = OPT_NONE + list.map(function(v){
      return '<option value="' + esc(v) + '">' + esc(v) + "</option>"; }).join("");
    if(keep) sel.value = keep;
  }

  function agg(list, how){
    if(how === "count") return list.length;
    if(how === "uniq"){
      var seen = {}, n = 0;
      for(var i = 0; i < list.length; i++){
        var t = cell(list[i]); if(t === "" || seen[t]) continue; seen[t] = 1; n++;
      }
      return n;
    }
    var ns = list.map(num).filter(function(x){ return x !== null; });
    if(!ns.length) return 0;
    /* «بدونِ محاسبه» یعنی خودِ مقدار — وقتی هر دسته یک ردیف بیشتر
       ندارد (مثلاً ستونِ تاریخ در محورِ افقی) جمع زدن بی‌معنی است. */
    if(!how) return ns.length === 1 ? ns[0] : ns.reduce(function(a,b){ return a+b; }, 0);
    if(how === "sum") return ns.reduce(function(a,b){ return a+b; }, 0);
    if(how === "avg") return ns.reduce(function(a,b){ return a+b; }, 0) / ns.length;
    if(how === "max") return Math.max.apply(null, ns);
    if(how === "min") return Math.min.apply(null, ns);
    return 0;
  }

  var AGG_NAME = { "":"مقدار", sum:"جمع", avg:"میانگین", count:"شمارش",
                   max:"بیشینه", min:"کمینه", uniq:"تعدادِ یکتا" };
  /* نمودارهایی که بیش از یک سری را می‌پذیرند */
  var MULTI = { bar:1, hbar:1, stack:1, line:1, area:1, radar:1 };

  /* ردیف‌هایی که فیلتر اجازه می‌دهد */
  function rowsNow(){
    var col = $("rpFilCol").value, want = $("rpFilVal").value;
    if(!col || !want) return RP.rows;
    return RP.rows.filter(function(r){ return cell(r[col]) === want; });
  }

  /* یک یا چند سری. بدونِ ستونِ «شکستن»، یک سری؛ با آن، یک سری به‌ازای
     هر مقدارِ آن ستون — که نمودارِ انباشته و خطیِ چندخطی از همین‌جا
     می‌آیند. */
  function build(){
    var catName = $("rpCat").value, valName = $("rpVal").value;
    var serName = MULTI[$("rpKind").value] ? $("rpSer").value : "";
    var how = $("rpAgg").value;
    var rows = rowsNow();

    var cats = [], catSeen = {}, sers = [], serSeen = {}, bag = {};
    for(var i = 0; i < rows.length; i++){
      var k = cell(rows[i][catName]) || "—";
      if(!catSeen[k]){ catSeen[k] = 1; cats.push(k); }
      var sName = serName ? (cell(rows[i][serName]) || "—") : "";
      if(serName && !serSeen[sName]){ serSeen[sName] = 1; sers.push(sName); }
      var key = k + "\u0000" + sName;
      (bag[key] || (bag[key] = [])).push(valName ? rows[i][valName] : 1);
    }
    if(!sers.length) sers = [""];

    var totals = cats.map(function(k){
      var t = 0;
      for(var j = 0; j < sers.length; j++) t += agg(bag[k + "\u0000" + sers[j]] || [], how);
      return { k: k, n: t, rows: (bag[k + "\u0000" + sers[0]] || []).length };
    });
    /* شمارِ واقعیِ ردیف‌های هر دسته، نه فقط سریِ اول */
    totals.forEach(function(x){
      var n = 0;
      for(var j = 0; j < sers.length; j++) n += (bag[x.k + "\u0000" + sers[j]] || []).length;
      x.rows = n;
    });

    var sort = $("rpSort").value;
    if(sort === "cat") totals.sort(function(a,b){ return String(a.k).localeCompare(String(b.k), "fa"); });
    else if(sort === "asc") totals.sort(function(a,b){ return a.n - b.n; });
    else if(sort === "desc") totals.sort(function(a,b){ return b.n - a.n; });
    /* ترتیبِ خالی یعنی همان ترتیبی که در فایل بود */

    var top = Number($("rpTop").value) || 0;
    var cut = top > 0 && totals.length > top;
    var list = cut ? totals.slice(0, top) : totals;
    var keys = list.map(function(x){ return x.k; });

    return {
      list: list, all: totals, cut: cut, sers: sers, rowCount: rows.length,
      series: sers.map(function(sn){
        return { name: sn, data: keys.map(function(k){
          return agg(bag[k + "\u0000" + sn] || [], how); }) };
      })
    };
  }

  function cards(d){
    var how = $("rpAgg").value, t = chartTone();
    var vals = d.all.map(function(x){ return x.n; });
    var total = vals.reduce(function(a,b){ return a+b; }, 0);
    var sorted = d.all.slice().sort(function(a,b){ return b.n - a.n; });
    var top = sorted[0], low = sorted[sorted.length - 1];
    var box = [
      ["ردیف‌های گزارش", faD(d.rowCount) +
        (d.rowCount !== RP.rows.length ? " از " + faD(RP.rows.length) : ""), t.cat[0], "📄"],
      ["تعداد دسته", faD(d.all.length) + (d.sers.length > 1 ? " × " + faD(d.sers.length) + " سری" : ""),
        t.cat[2], "🗂"],
      [how === "avg" ? "میانگینِ کل" : "جمعِ کل",
        fmt(how === "avg" && vals.length ? total / vals.length : total), t.cat[1], "Σ"],
      ["بیشترین", top ? top.k : "—", t.cat[3], "▲", top ? fmt(top.n) : ""],
      ["کمترین", low && d.all.length > 1 ? low.k : "—", t.cat[4], "▼",
        low && d.all.length > 1 ? fmt(low.n) : ""]
    ];
    $("rpCards").innerHTML = box.map(function(x){
      return '<div class="rp-card" style="--rc:' + x[2] + '">' +
        '<span class="t"><i>' + x[3] + "</i>" + esc(x[0]) + "</span>" +
        '<span class="n">' + esc(x[1]) + "</span>" +
        (x[4] ? '<span class="s">' + esc(x[4]) + "</span>" : "") + "</div>";
    }).join("");
  }

  function table(d){
    var how = $("rpAgg").value;
    var vname = $("rpVal").value;
    var head = AGG_NAME[how] + (how === "count" || how === "uniq" || !vname ? "" : " — " + vname);
    var multi = d.series.length > 1;
    var total = d.all.reduce(function(a,x){ return a + x.n; }, 0);

    RP.summary = [[$("rpCat").value].concat(
      multi ? d.series.map(function(s2){ return s2.name; }) : [head], ["ردیف", "سهم"])];
    d.list.forEach(function(x, i){
      var cells = multi ? d.series.map(function(s2){ return s2.data[i]; }) : [x.n];
      RP.summary.push([x.k].concat(cells, [x.rows,
        total ? Math.round(x.n * 1000 / total) / 10 + "%" : ""]));
    });

    var th = "<th>" + esc($("rpCat").value) + "</th>" +
      (multi ? d.series.map(function(s2){ return "<th>" + esc(s2.name) + "</th>"; }).join("")
             : "<th>" + esc(head) + "</th>") +
      "<th>ردیف</th><th>سهم</th>";
    $("rpTab").innerHTML = "<thead><tr>" + th + "</tr></thead><tbody>" +
      d.list.map(function(x, i){
        var pc = total ? (x.n * 100 / total) : 0;
        var cells = multi ? d.series.map(function(s2){
            return '<td class="num">' + fmt(s2.data[i]) + "</td>"; }).join("")
          : '<td class="num">' + fmt(x.n) + "</td>";
        return "<tr><td>" + esc(x.k) + "</td>" + cells +
          '<td class="num">' + faD(x.rows) + "</td>" +
          '<td class="num"><span class="rp-share"><i style="width:' +
            Math.max(2, Math.round(pc)) + '%"></i></span>' +
            faD(Math.round(pc * 10) / 10) + "٪</td></tr>";
      }).join("") +
      (d.cut ? '<tr class="rest"><td>بقیه (' + faD(d.all.length - d.list.length) +
        ' دسته)</td><td class="num" colspan="' + (multi ? d.series.length : 1) + '">' +
        fmt(total - d.list.reduce(function(a,x){ return a + x.n; }, 0)) + "</td><td></td><td></td></tr>" : "") +
      "</tbody>";
  }

  var ROUND = { bar:1, hbar:1, stack:1 };

  async function chart(d){
    var kind = $("rpKind").value;
    var box = $("rpChartBox");
    if(RP.chart){ try{ RP.chart.destroy(); }catch(e){} RP.chart = null; }
    box.hidden = kind === "table";
    if(kind === "table") return;
    if(!(await ensureChartLib())) return;
    var t = chartTone();
    var labels = d.list.map(function(x){ return x.k; });
    var multi = d.series.length > 1;

    /* یک سری → یک رنگ (چون فقط اندازه‌هاست). چند سری یا برش‌های
       دایره‌ای → پالتِ دسته‌ها، چون هر کدام یک هویتِ جداست. */
    var slice = ["doughnut","pie","polarArea"].indexOf(kind) >= 0;
    var sets = d.series.map(function(sr, i){
      var c = slice
        ? labels.map(function(_, j){ return t.cat[j % t.cat.length]; })
        : t.cat[i % t.cat.length];
      var set = {
        label: sr.name || AGG_NAME[$("rpAgg").value],
        data: sr.data.map(function(v){ return Math.round(v * 100) / 100; }),
        backgroundColor: kind === "line" ? "transparent" : c,
        borderColor: c, borderWidth: (kind === "line" || kind === "radar" || kind === "area") ? 2.5 : 0,
        pointRadius: (kind === "line" || kind === "area") ? 3 : (kind === "scatter" ? 5 : 0),
        pointBackgroundColor: c, tension: .3
      };
      if(kind === "area"){ set.fill = true; set.backgroundColor = c + "33"; }
      if(kind === "radar"){ set.backgroundColor = c + "2E"; set.fill = true; }
      if(ROUND[kind]) set.borderRadius = 7;
      if(kind === "scatter")
        set.data = sr.data.map(function(v, j){ return { x: j + 1, y: Math.round(v * 100) / 100 }; });
      return set;
    });

    var type = kind === "hbar" || kind === "stack" ? "bar"
             : kind === "area" ? "line" : kind;
    var stacked = kind === "stack";
    var flat = ["doughnut","pie","polarArea","radar"].indexOf(kind) >= 0;

    RP.chart = new Chart($("rpChart").getContext("2d"), {
      type: type,
      data: { labels: labels, datasets: sets },
      options: {
        indexAxis: kind === "hbar" ? "y" : "x",
        layout: { padding: { top: 6, bottom: 2 } },
        plugins: {
          legend: {
            display: multi || slice,
            position: "bottom",
            labels: { boxWidth: 11, boxHeight: 11, usePointStyle: true,
                      pointStyle: "rectRounded", padding: 14,
                      font: { size: 11.5, family: getComputedStyle(document.body).fontFamily } }
          },
          tooltip: {
            backgroundColor: "rgba(11,37,69,.92)", padding: 10, cornerRadius: 8,
            titleFont: { size: 12 }, bodyFont: { size: 12 }, displayColors: true,
            callbacks: { label: function(c){
              var v = c.parsed;
              var n = (v && typeof v === "object")
                ? (kind === "hbar" ? v.x : v.y)
                : v;
              return " " + (c.dataset.label ? c.dataset.label + ": " : "") + fmt(n);
            } }
          }
        },
        scales: flat ? (kind === "radar" ? { r: {
            grid: { color: "rgba(128,128,128,.18)" },
            angleLines: { color: "rgba(128,128,128,.18)" },
            ticks: { font: { size: 10 }, backdropColor: "transparent",
                     callback: function(v){ return fmt(v); } }
          } } : {}) : {
          x: { stacked: stacked,
               grid: { display: kind === "hbar", color: "rgba(128,128,128,.14)" },
               ticks: { font: { size: 10.5 }, maxRotation: 0, autoSkip: true,
                        callback: function(v){
                          if(kind === "hbar" || kind === "scatter") return fmt(v);
                          var t2 = this.getLabelForValue(v);
                          return String(t2).length > 14 ? String(t2).slice(0, 13) + "…" : t2;
                        } } },
          y: { stacked: stacked, beginAtZero: true,
               grid: { display: kind !== "hbar", color: "rgba(128,128,128,.14)" },
               border: { display: false },
               ticks: { font: { size: 10.5 },
                        callback: function(v){
                          if(kind === "hbar") {
                            var t2 = this.getLabelForValue(v);
                            return String(t2).length > 18 ? String(t2).slice(0, 17) + "…" : t2;
                          }
                          return fmt(v);
                        } } }
        }
      }
    });
  }

  function draw(){
    if(!RP.rows.length) return;
    var how = $("rpAgg").value, kind = $("rpKind").value;
    /* «شمارش» و «تعدادِ یکتا» ستونِ مقدار لازم ندارند، و نمودارهای
       تک‌سری ستونِ «شکستن» را. هر کدام که به کار نمی‌آید، پنهان. */
    $("rpValWrap").hidden = how === "count";
    $("rpSerWrap").hidden = !MULTI[kind];
    var d = build();

    var vname = $("rpVal").value;
    var ttl = AGG_NAME[how] +
      (how === "count" ? " ردیف‌ها" : (vname ? "ِ «" + vname + "»" : "")) +
      " بر اساس «" + $("rpCat").value + "»" +
      (MULTI[kind] && $("rpSer").value ? "، به تفکیکِ «" + $("rpSer").value + "»" : "");
    $("rpTitle").textContent = ttl;
    $("rpPrintTitle").textContent = ttl;
    $("rpPrintMeta").textContent = RP.name + " · " + $("rpSheet").value + " · " +
      faD(d.rowCount) + " ردیف · " + faDateNow();

    var why = [faD(d.all.length) + " دسته"];
    if(d.cut) why.push(faD(d.list.length) + " تای اول نشان داده شده");
    if(d.sers.length > 1) why.push(faD(d.sers.length) + " سری");
    if($("rpFilCol").value && $("rpFilVal").value)
      why.push("فقط «" + $("rpFilCol").value + " = " + $("rpFilVal").value + "»");
    $("rpWhy").textContent = why.join(" · ") + ".";

    cards(d); table(d); chart(d);
  }

  function faDateNow(){
    try{
      return new Intl.DateTimeFormat("fa-IR-u-ca-persian",
        { year:"numeric", month:"long", day:"numeric" }).format(new Date());
    }catch(e){ return ""; }
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
  ["rpKind","rpCat","rpVal","rpAgg","rpTop","rpSort","rpSer","rpFilVal"].forEach(function(id){
    $(id).addEventListener("change", draw); });
  $("rpFilCol").addEventListener("change", function(){ fillFilVals(); draw(); });
  $("rpReset").addEventListener("click", function(){
    RP.rows = []; RP.cols = []; RP.wb = null;
    if(RP.chart){ try{ RP.chart.destroy(); }catch(e){} RP.chart = null; }
    $("rpBody").hidden = true; note("");
  });

  /* تصویر: بوم زمینهٔ شفاف دارد، پس تصویرِ خام روی هر چیزی تار است.
     زمینهٔ خودِ کارت زیرش گذاشته می‌شود. */
  $("rpPng").addEventListener("click", function(){
    if(!RP.chart){ note("این نوعِ گزارش نموداری ندارد.", true); return; }
    var src = $("rpChart");
    var out = document.createElement("canvas");
    out.width = src.width; out.height = src.height;
    var g = out.getContext("2d");
    g.fillStyle = chartTone().surface;
    g.fillRect(0, 0, out.width, out.height);
    g.drawImage(src, 0, 0);
    var a = document.createElement("a");
    a.href = out.toDataURL("image/png");
    a.download = rpFileName() + ".png";
    document.body.appendChild(a); a.click(); a.remove();
  });

  /* نامِ فایل عمداً لاتین است. با نامِ فارسی، مرورگر فایل را «download»
     بدونِ پسوند تحویل می‌داد — یعنی فایلی که با دوبار کلیک باز نمی‌شود.
     عنوانِ گزارش از دست نمی‌رود: هم بالای کاغذِ چاپ هست، هم سطرِ اولِ
     فایلِ اکسل. */
  function rpFileName(){
    var d = "";
    try{
      var g = {};
      new Intl.DateTimeFormat("en-u-ca-persian-nu-latn",
        { year:"numeric", month:"2-digit", day:"2-digit" })
        .formatToParts(new Date()).forEach(function(x){ g[x.type] = x.value; });
      if(g.year) d = "-" + g.year + "-" + g.month + "-" + g.day;
    }catch(e){ /* بی‌تاریخ هم نامِ درستی است */ }
    /* اگر نامِ خودِ فایل لاتین بود، همان جلو بیاید تا دو گزارش از دو
       فایل در پوشهٔ دانلود قاطی نشوند. */
    var stem = String(RP.name || "").replace(/\.[^.]+$/, "").replace(/[^A-Za-z0-9_-]+/g, "-")
      .replace(/^-+|-+$/g, "").slice(0, 28);
    return (stem ? stem + "-" : "") + "report" + d;
  }

  $("rpXlsx").addEventListener("click", async function(){
    if(!RP.summary.length){ note("هنوز گزارشی نیست.", true); return; }
    if(!(await ensureXlsxLib())){ note("کتابخانهٔ اکسل بار نشد.", true); return; }
    /* سرصفحه هم می‌رود، وگرنه فردا معلوم نیست این اعداد مالِ چه بوده */
    var rows = [[$("rpTitle").textContent],
                [RP.name + " — " + $("rpSheet").value + " — " + faDateNow()],
                []].concat(RP.summary);
    var ws = XLSX.utils.aoa_to_sheet(rows);
    ws["!cols"] = (RP.summary[0] || []).map(function(){ return { wch: 18 }; });
    var wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "خلاصه");
    XLSX.writeFile(wb, rpFileName() + ".xlsx");
  });

  /* چاپ فقط همین گزارش است، نه کلِ صفحه — شیوه‌نامهٔ @media print
     همه‌چیزِ دیگر را از کاغذ برمی‌دارد. */
  $("rpPrint").addEventListener("click", function(){
    if(!RP.rows.length){ note("اول یک فایل بدهید.", true); return; }
    /* نمودار باید پیش از چاپ دوباره کشیده شود تا در اندازهٔ کاغذ تار نباشد */
    if(RP.chart) try{ RP.chart.resize(); }catch(e){}
    setTimeout(function(){ window.print(); }, 120);
  });

  /* تمِ شب که عوض شود، رنگِ نمودار هم باید عوض شود */
  new MutationObserver(function(){ if(RP.rows.length) draw(); })
    .observe(document.documentElement, { attributes:true, attributeFilter:["data-theme"] });
})();
