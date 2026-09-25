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
      $("rpBody").hidden = true; $("rpDrop").classList.remove("fed"); return;
    }
    $("rpMeta").textContent = faD(RP.rows.length) + " ردیف · " + faD(RP.cols.length) + " ستون";
    $("rpBody").hidden = false;
    $("rpDrop").classList.add("fed");
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
  var SLICE = { doughnut:1, pie:1, polarArea:1 };
  var SIZE = { s:300, m:420, l:560, xl:720 };

  /* ارتفاعِ قاب. قابِ ثابتِ ۲۵۰ پیکسلیِ داشبورد برای نمودارهای این‌جا
     کم بود — دایره‌ای عملاً یک نقطه می‌شد. حالا:
     • برشی: مربع‌وار و بزرگ، چون قطرِ دایره همان ارتفاع است.
     • ستونیِ افقی: با تعدادِ دسته‌ها بلند می‌شود، وگرنه بیست ردیف
       روی هم فشرده می‌شدند.
     • بقیه: اندازهٔ انتخابیِ خودِ کاربر. */
  function plotHeight(kind, n){
    var base = SIZE[$("rpSize").value] || SIZE.m;
    if(SLICE[kind]) return Math.round(base * 1.05);
    if(kind === "hbar") return Math.max(base, Math.min(1400, n * 34 + 110));
    if(kind === "radar") return Math.round(base * 1.05);
    return base;
  }

  /* عددِ هر ستون روی خودش. بدونِ این، خواندنِ نمودار به نگه داشتنِ
     موشواره روی هر میله بند بود — و روی کاغذ اصلاً ممکن نبود. */
  var valueLabels = {
    id: "rpVals",
    afterDatasetsDraw: function(c, a, o){
      if(!o || !o.on) return;
      var g = c.ctx;
      g.save();
      g.font = "600 10.5px " + getComputedStyle(document.body).fontFamily;
      g.fillStyle = o.color;
      g.textAlign = o.horiz ? "left" : "center";
      g.textBaseline = o.horiz ? "middle" : "bottom";
      c.data.datasets.forEach(function(ds, di){
        var meta = c.getDatasetMeta(di);
        if(meta.hidden) return;
        meta.data.forEach(function(el, i){
          var v = ds.data[i];
          if(v == null || (typeof v === "object")) return;
          if(!v) return;
          /* در نمودارِ انباشته عددِ تک‌تکِ تکه‌ها روی هم می‌افتد */
          if(o.stacked) return;
          g.fillText(fmt(v), el.x + (o.horiz ? 6 : 0), el.y - (o.horiz ? 0 : 5));
        });
      });
      g.restore();
    }
  };

  /* عددِ کل، وسطِ دونات. جای خالیِ وسط بزرگ‌ترین فضای بی‌استفادهٔ
     نمودار است. */
  var centerTotal = {
    id: "rpCenter",
    afterDraw: function(c, a, o){
      if(!o || !o.on) return;
      var m = c.getDatasetMeta(0);
      if(!m || !m.data || !m.data.length) return;
      var el = m.data[0];
      var g = c.ctx, f = getComputedStyle(document.body).fontFamily;
      g.save();
      g.textAlign = "center"; g.textBaseline = "middle";
      g.fillStyle = o.sub;
      g.font = "11px " + f;
      g.fillText(o.label, el.x, el.y - 14);
      g.fillStyle = o.main;
      g.font = "700 21px " + f;
      g.fillText(o.total, el.x, el.y + 8);
      g.restore();
    }
  };

  /* راهنمای کناری برای نمودارهای برشی: نام، مقدار، درصد. زدن روی هر
     ردیف همان برش را خاموش و روشن می‌کند. */
  function sideLegend(d, colors, total){
    var box = $("rpLegend");
    var slice = SLICE[$("rpKind").value];
    box.hidden = !slice;
    if(!slice){ box.innerHTML = ""; RP.legend = null; return; }
    /* همین فهرست سرِ «⬇ تصویر» دوباره روی خودِ عکس کشیده می‌شود */
    RP.legend = d.list.map(function(x, i){
      return { k: x.k, v: fmt(x.n), c: colors[i % colors.length],
               pc: faD(Math.round((total ? x.n * 100 / total : 0) * 10) / 10) + "٪" };
    });
    RP.legend.push({ k: "جمع", v: fmt(total), c: "", pc: "" });
    box.innerHTML = d.list.map(function(x, i){
      var pc = total ? (x.n * 100 / total) : 0;
      return '<div class="rl-row" data-ri="' + i + '">' +
        '<span class="rl-sw" style="background:' + colors[i % colors.length] + '"></span>' +
        '<span class="rl-nm" title="' + esc(x.k) + '">' + esc(x.k) + "</span>" +
        '<span class="rl-vl">' + fmt(x.n) + "</span>" +
        '<span class="rl-pc"><i class="rl-tr"><i style="width:' +
          (Math.round(pc * 10) / 10) + "%;background:" + colors[i % colors.length] +
          '"></i></i>' + faD(Math.round(pc * 10) / 10) + "٪</span></div>";
    }).join("") +
    '<div class="rl-row tot"><span class="rl-sw" style="background:transparent"></span>' +
      '<span class="rl-nm">جمع</span><span class="rl-vl">' + fmt(total) + "</span></div>";
    box.querySelectorAll("[data-ri]").forEach(function(row){
      row.onclick = function(){
        if(!RP.chart) return;
        var i = Number(row.getAttribute("data-ri"));
        RP.chart.toggleDataVisibility(i);
        RP.chart.update();
        row.style.opacity = RP.chart.getDataVisibility(i) ? "" : ".4";
      };
    });
  }

  async function chart(d){
    var kind = $("rpKind").value;
    var plot = $("rpPlot");
    if(RP.chart){ try{ RP.chart.destroy(); }catch(e){} RP.chart = null; }
    plot.hidden = kind === "table";
    $("rpLegend").hidden = true;
    RP.legend = null;
    if(kind === "table") return;
    if(!(await ensureChartLib())) return;

    var t = chartTone();
    var labels = d.list.map(function(x){ return x.k; });
    var multi = d.series.length > 1;
    var slice = !!SLICE[kind];
    var stacked = kind === "stack";
    var horiz = kind === "hbar";

    /* ارتفاع پیش از ساختنِ نمودار، وگرنه بوم با اندازهٔ قبلی کشیده
       می‌شود و تار می‌ماند. */
    plot.style.setProperty("--rph", plotHeight(kind, labels.length) + "px");

    var palette = t.cat;
    /* یک سری از دسته‌های جدا (تهران، شیراز، …) با یک رنگِ واحد، دیوارِ
       آبیِ یکدستی می‌شد که چشم دسته‌ها را از هم جدا نمی‌کرد. پس وقتی
       فقط یک سری هست، هر دسته رنگِ خودش را می‌گیرد — مثل دایره‌ای. */
    var byCat = slice || (!multi && (kind === "bar" || kind === "hbar" || kind === "polarArea"));
    var sets = d.series.map(function(sr, i){
      var c = byCat
        ? labels.map(function(_, j){ return palette[j % palette.length]; })
        : palette[i % palette.length];
      var set = {
        label: sr.name || AGG_NAME[$("rpAgg").value] || "مقدار",
        data: sr.data.map(function(v){ return Math.round(v * 100) / 100; }),
        backgroundColor: kind === "line" ? "transparent" : c,
        borderWidth: (kind === "line" || kind === "radar" || kind === "area") ? 2.5
                   : slice ? 2 : 0,
        /* خطِ جداکنندهٔ برش‌ها همرنگِ کارت است، نه سفیدِ ثابت — در تمِ
           شب سفید مثل یک قاب می‌زد بیرون. */
        borderColor: slice ? t.surface : c,
        hoverBorderColor: slice ? t.surface : c,
        pointRadius: (kind === "line" || kind === "area") ? 3.5 : (kind === "scatter" ? 5 : 0),
        pointHoverRadius: 6,
        pointBackgroundColor: c,
        tension: .3,
        hoverOffset: slice ? 10 : 0
      };
      if(slice) set.backgroundColor = c;
      if(kind === "area"){ set.fill = true; set.backgroundColor = c + "33"; }
      if(kind === "radar"){ set.backgroundColor = c + "2E"; set.fill = true; }
      if(ROUND[kind]) set.borderRadius = 7;
      if(kind === "scatter")
        set.data = sr.data.map(function(v, j){ return { x: j + 1, y: Math.round(v * 100) / 100 }; });
      return set;
    });

    var total = d.list.reduce(function(a, x){ return a + x.n; }, 0);
    if(slice) sideLegend(d, palette, total);

    var type = horiz || stacked ? "bar" : kind === "area" ? "line" : kind;
    var flat = slice || kind === "radar";

    RP.chart = new Chart($("rpChart").getContext("2d"), {
      type: type,
      data: { labels: labels, datasets: sets },
      plugins: [valueLabels, centerTotal],
      options: {
        indexAxis: horiz ? "y" : "x",
        layout: { padding: { top: 14, bottom: 2, left: 6, right: horiz ? 46 : 6 } },
        /* برش‌ها فضای بیشتری بگیرند: ضخامتِ کمتر یعنی سوراخِ بزرگ‌تر
           برای عددِ وسط، ولی دایره همان‌قدر بزرگ می‌ماند. */
        cutout: kind === "doughnut" ? "58%" : undefined,
        plugins: {
          rpVals: { on: !slice && kind !== "radar" && kind !== "scatter",
                    horiz: horiz, stacked: stacked, color: t.none === "#CFD7E0" ? "#43586D" : "#AAB9C7" },
          rpCenter: { on: kind === "doughnut", total: fmt(total),
                      label: AGG_NAME[$("rpAgg").value] || "جمع",
                      main: t.done === "#1E7A4A" ? "#0B2545" : "#E7EEF4",
                      sub:  t.done === "#1E7A4A" ? "#8697A8" : "#78899A" },
          /* راهنمای زیرِ نمودار فقط برای چندسری؛ برشی‌ها راهنمای
             کناریِ خودشان را دارند. */
          legend: {
            display: multi && !slice,
            position: "bottom",
            labels: { boxWidth: 11, boxHeight: 11, usePointStyle: true,
                      pointStyle: "rectRounded", padding: 14,
                      font: { size: 12, family: getComputedStyle(document.body).fontFamily } }
          },
          tooltip: {
            backgroundColor: "rgba(11,37,69,.93)", padding: 11, cornerRadius: 9,
            titleFont: { size: 12.5 }, bodyFont: { size: 12.5 }, displayColors: true,
            callbacks: { label: function(c){
              var v = c.parsed;
              var n = (v && typeof v === "object") ? (horiz ? v.x : v.y) : v;
              var pc = total ? " (" + faD(Math.round(n * 1000 / total) / 10) + "٪)" : "";
              return " " + (c.dataset.label ? c.dataset.label + ": " : "") +
                     fmt(n) + (slice ? pc : "");
            } }
          }
        },
        scales: flat ? (kind === "radar" ? { r: {
            grid: { color: "rgba(128,128,128,.18)" },
            angleLines: { color: "rgba(128,128,128,.18)" },
            pointLabels: { font: { size: 11.5 } },
            ticks: { font: { size: 10 }, backdropColor: "transparent",
                     callback: function(v){ return fmt(v); } }
          } } : {}) : {
          x: { stacked: stacked,
               grid: { display: horiz, color: "rgba(128,128,128,.13)" },
               border: { display: false },
               ticks: { font: { size: 11 }, maxRotation: 0, autoSkip: true,
                        callback: function(v){
                          if(horiz || kind === "scatter") return fmt(v);
                          var t2 = this.getLabelForValue(v);
                          return String(t2).length > 16 ? String(t2).slice(0, 15) + "…" : t2;
                        } } },
          y: { stacked: stacked, beginAtZero: true,
               grid: { display: !horiz, color: "rgba(128,128,128,.13)" },
               border: { display: false },
               ticks: { font: { size: 11 }, autoSkip: true,
                        callback: function(v){
                          if(!horiz) return fmt(v);
                          var t2 = this.getLabelForValue(v);
                          return String(t2).length > 22 ? String(t2).slice(0, 21) + "…" : t2;
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
  ["rpKind","rpCat","rpVal","rpAgg","rpTop","rpSort","rpSer","rpFilVal","rpSize"].forEach(function(id){
    $(id).addEventListener("change", draw); });
  $("rpFilCol").addEventListener("change", function(){ fillFilVals(); draw(); });
  $("rpReset").addEventListener("click", function(){
    RP.rows = []; RP.cols = []; RP.wb = null;
    if(RP.chart){ try{ RP.chart.destroy(); }catch(e){} RP.chart = null; }
    $("rpBody").hidden = true; $("rpDrop").classList.remove("fed"); note("");
  });

  /* عکسِ گزارش، نه عکسِ بوم. بوم هم زمینهٔ شفاف دارد (پس روی هر
     پس‌زمینه‌ای تار می‌افتد) و هم به‌تنهایی عنوان ندارد — و برای
     نمودارهای برشی راهنمای کناری‌اش بیرونِ بوم است، یعنی عکسی در
     می‌آمد که هیچ‌کس نمی‌فهمید چه چیزی را نشان می‌دهد. پس زمینه و
     عنوان و راهنما و سطرِ پایین همین‌جا روی عکس کشیده می‌شوند. */
  $("rpPng").addEventListener("click", function(){
    if(!RP.chart){ note("این نوعِ گزارش نموداری ندارد.", true); return; }
    var src = $("rpChart"), t = chartTone();
    var dark = t.done !== "#1E7A4A";
    var ink  = dark ? "#E7EEF4" : "#0B2545";
    var dim  = dark ? "#8DA0B2" : "#5B6E82";
    var line = dark ? "#2A3A4B" : "#DCE4EC";
    var f = getComputedStyle(document.body).fontFamily;
    /* بوم با نسبتِ صفحه‌نمایش کشیده شده؛ همان نسبت را برای متن هم
       نگه می‌داریم تا نوشته‌ها تارتر از نمودار نباشند. */
    var k = Math.max(1, Math.round((src.width / Math.max(1, src.clientWidth)) * 100) / 100);
    var leg = (RP.legend && RP.legend.length) ? RP.legend : null;
    var PAD = 22 * k, HEAD = 58 * k, FOOT = 34 * k;
    var LEG  = leg ? 250 * k : 0;
    var LROW = 27 * k;
    var bodyH = Math.max(src.height, leg ? leg.length * LROW + 10 * k : 0);

    var out = document.createElement("canvas");
    out.width  = Math.round(src.width + LEG + PAD * 2);
    out.height = Math.round(bodyH + HEAD + FOOT + PAD);
    var g = out.getContext("2d");
    g.fillStyle = t.surface;
    g.fillRect(0, 0, out.width, out.height);
    g.direction = "rtl";

    /* سرصفحه */
    g.textBaseline = "middle";
    g.textAlign = "right";
    g.fillStyle = ink;
    g.font = "700 " + (17 * k) + "px " + f;
    g.fillText($("rpTitle").textContent || "گزارش", out.width - PAD, PAD + 9 * k);
    g.strokeStyle = line; g.lineWidth = Math.max(1, k);
    g.beginPath();
    g.moveTo(PAD, HEAD - 4 * k); g.lineTo(out.width - PAD, HEAD - 4 * k); g.stroke();

    /* نمودار زیرِ سرصفحه، و راهنما سمتِ چپش */
    g.drawImage(src, Math.round(PAD + LEG), Math.round(HEAD));

    if(leg){
      var lx = PAD + LEG - 6 * k, ly = HEAD + 8 * k;
      for(var i = 0; i < leg.length; i++){
        var r = leg[i], cy = ly + i * LROW + LROW / 2;
        if(r.c){
          g.fillStyle = r.c;
          var sw = 11 * k;
          if(g.roundRect){ g.beginPath(); g.roundRect(lx - sw, cy - sw / 2, sw, sw, 3 * k); g.fill(); }
          else g.fillRect(lx - sw, cy - sw / 2, sw, sw);
        }
        g.textAlign = "right";
        g.fillStyle = r.c ? ink : dim;
        g.font = (r.c ? "" : "700 ") + (12.5 * k) + "px " + f;
        g.fillText(r.k, lx - 17 * k, cy);
        /* مقدارها از راست هم‌تراز می‌شوند تا رقم‌ها زیرِ هم بیفتند */
        g.textAlign = "right";
        g.fillStyle = ink;
        g.font = "600 " + (12.5 * k) + "px " + f;
        g.fillText(r.v, PAD + 108 * k, cy);
        if(r.pc){
          g.fillStyle = dim;
          g.font = (11.5 * k) + "px " + f;
          g.textAlign = "left";
          g.fillText(r.pc, PAD, cy);
        }
      }
    }

    /* پانویس: از کدام فایل، کدام برگه، چند ردیف، چه روزی */
    g.textAlign = "right";
    g.fillStyle = dim;
    g.font = (11.5 * k) + "px " + f;
    g.fillText($("rpPrintMeta").textContent || "", out.width - PAD, out.height - PAD / 1.4);

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

  /* چاپ با Ctrl+P از کنارِ دکمه رد می‌شود؛ قابِ کاغذ عرضِ دیگری دارد
     و بومِ کشیده‌شده برای صفحه‌نمایش تار یا نصفه در می‌آمد. */
  window.addEventListener("beforeprint", function(){
    if(RP.chart) try{ RP.chart.resize(); }catch(e){}
  });
  window.addEventListener("afterprint", function(){
    if(RP.chart) try{ RP.chart.resize(); }catch(e){}
  });

  /* تمِ شب که عوض شود، رنگِ نمودار هم باید عوض شود */
  new MutationObserver(function(){ if(RP.rows.length) draw(); })
    .observe(document.documentElement, { attributes:true, attributeFilter:["data-theme"] });
})();
