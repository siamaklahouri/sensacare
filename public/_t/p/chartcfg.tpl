/* ==================== نمودارهای دلخواهِ داشبورد ====================
   داشبورد تا امروز هفت نمودارِ ثابت داشت که در خودِ قالب نوشته شده
   بودند. برای کسی که بخشی را اصلاً ندارد، یکی‌شان همیشه خالی بود؛ و
   کسی که می‌خواست چیزِ دیگری ببیند — مثلاً هزینه به تفکیکِ دسته —
   راهی نداشت جز این‌که بگوید و من قالب را عوض کنم.

   این‌جا دو کار می‌شود: نمودارهای آماده را می‌شود خاموش کرد، و از
   روی همان جدول‌هایی که کارتابل دارد نمودارِ تازه ساخت.

   چرا ساختار این‌شکلی است: هر کارتابل دو چیز را معرفی می‌کند —
   CHART_BUILT (نمودارهای آماده‌اش) و CHART_SRC (جدول‌هایش و ستون‌های
   قابلِ گروه‌بندی). موتور این‌جا یکی است و هر دو کارتابل همان را
   می‌آورند، وگرنه فردا یکی‌شان از دیگری جا می‌ماند.

   چیدمان در state می‌نشیند، پس با خودِ کارتابل پشتیبان گرفته می‌شود
   و روی هر دستگاهی یکی است. */

function chartCfg() {
  if (!state) return { off: [], custom: [] };
  if (!state.chartCfg || typeof state.chartCfg !== "object") state.chartCfg = {};
  if (!Array.isArray(state.chartCfg.off)) state.chartCfg.off = [];
  if (!Array.isArray(state.chartCfg.custom)) state.chartCfg.custom = [];
  return state.chartCfg;
}
function chartBuilt() { return Array.isArray(window.CHART_BUILT) ? window.CHART_BUILT : []; }
function chartSrcs()  { return Array.isArray(window.CHART_SRC)   ? window.CHART_SRC   : []; }
function chartSrcOf(id) { return chartSrcs().find(s => s.id === id) || null; }

/* قابِ نموداری که در قالب نوشته شده. اگر بومش نباشد، چیزی هم نیست. */
function builtPanel(b) {
  const c = document.getElementById(b.canvas);
  return c ? c.closest(".panel") : null;
}

/* ---------- خاموش و روشنِ نمودارهای آماده ---------- */
function applyBuiltinCharts() {
  const off = new Set(chartCfg().off);
  chartBuilt().forEach(b => {
    const p = builtPanel(b);
    if (p) p.hidden = off.has(b.id);
  });
  /* گروهی که همهٔ نمودارهایش خاموش شده، عنوانش هم نماند. */
  document.querySelectorAll(".dash-group-label").forEach(lbl => {
    const grid = lbl.nextElementSibling;
    if (!grid || !grid.querySelector) return;
    const panels = [...grid.querySelectorAll(":scope > .panel")];
    if (!panels.length) return;
    lbl.hidden = panels.every(p => p.hidden);
    grid.hidden = lbl.hidden;
  });
}

/* ---------- دادهٔ یک نمودارِ دلخواه ----------
   گروه‌بندی روی یک ستون، و یا شمارشِ ردیف‌ها یا جمعِ یک ستونِ عددی.
   بیش از ده گروه در یک نمودار خوانده نمی‌شود، پس بقیه در «بقیه»
   جمع می‌شوند — حذفشان عددِ کل را دروغ می‌کرد. */
function customChartData(c) {
  const src = chartSrcOf(c.src);
  if (!src) return null;
  let rows = [];
  try { rows = src.rows() || []; } catch (e) { rows = []; }
  const num = v => {
    const n = parseFloat(String(v == null ? "" : v).replace(/[^\d.-]/g, ""));
    return Number.isFinite(n) ? n : 0;
  };
  const map = new Map();
  rows.forEach(r => {
    if (!r) return;
    let k = r[c.by];
    k = String(k == null ? "" : k).trim() || "نامشخص";
    const v = c.agg === "sum" ? num(r[c.num]) : 1;
    map.set(k, (map.get(k) || 0) + v);
  });
  let list = [...map.entries()].sort((a, b) => b[1] - a[1]);
  const CAP = 10;
  if (list.length > CAP) {
    const rest = list.slice(CAP).reduce((s, x) => s + x[1], 0);
    list = list.slice(0, CAP);
    if (rest) list.push(["بقیه", rest]);
  }
  return { labels: list.map(x => x[0]), values: list.map(x => x[1]), rows: rows.length };
}

/* عنوانی که اگر کاربر چیزی ننوشت، خودش معنا بدهد. */
function customChartTitle(c) {
  if (String(c.title || "").trim()) return c.title.trim();
  const src = chartSrcOf(c.src);
  const by = src && (src.fields || []).find(f => f.k === c.by);
  const nm = src && (src.nums || []).find(f => f.k === c.num);
  const what = c.agg === "sum" && nm ? "جمعِ " + nm.label : "شمارش";
  return what + " بر پایهٔ " + (by ? by.label : c.by) + " — " + (src ? src.label : c.src);
}

/* ---------- کشیدنِ نمودارهای دلخواه ---------- */
function renderCustomCharts() {
  const wrap = document.getElementById("customCharts");
  const lbl = document.getElementById("customChartsLabel");
  if (!wrap) return;
  const list = chartCfg().custom;
  if (lbl) lbl.hidden = !list.length;
  wrap.hidden = !list.length;
  if (!list.length) { wrap.innerHTML = ""; return; }

  wrap.innerHTML = list.map(c =>
    '<div class="panel accent-blue">' +
      '<h3>📊 ' + escapeHtml(customChartTitle(c)) + '</h3>' +
      '<div class="chart-box"><canvas id="chartCustom-' + escapeHtml(c.id) + '"></canvas></div>' +
    '</div>').join("");

  if (typeof Chart === "undefined") {
    if (typeof chartLibPromise !== "undefined")
      chartLibPromise.then(ok => { if (ok) renderCustomCharts(); });
    return;
  }

  const tone = chartTone();
  list.forEach(c => {
    const el = document.getElementById("chartCustom-" + c.id);
    const d = customChartData(c);
    if (!el || !d) return;
    const key = "custom:" + c.id;
    try { destroyChart(key); } catch (e) {}
    const colors = d.labels.map((_, i) => tone.cat[i % tone.cat.length]);
    const pie = c.type === "doughnut";
    charts[key] = new Chart(el, {
      type: c.type === "line" ? "line" : (pie ? "doughnut" : "bar"),
      data: {
        labels: d.labels,
        datasets: [{
          label: customChartTitle(c),
          data: d.values,
          backgroundColor: pie ? colors : (c.type === "line" ? "transparent" : tone.cat[0]),
          borderColor: c.type === "line" ? tone.cat[0] : (pie ? tone.surface : "transparent"),
          borderWidth: pie ? 2 : (c.type === "line" ? 2 : 0),
          borderRadius: pie || c.type === "line" ? 0 : 8,
          tension: 0.3, pointRadius: 3, fill: false,
          hoverBackgroundColor: pie ? chartHover(colors) : chartHover([tone.cat[0]])[0]
        }]
      },
      options: {
        layout: { padding: pie ? 14 : 6 },
        cutout: pie ? "58%" : undefined,
        plugins: {
          legend: { display: pie, position: "bottom", labels: { font: chartFont() } },
          tooltip: { bodyFont: chartFont(), titleFont: chartFont(),
            callbacks: { label: ctx => " " + ctx.label + ": " + chartNum(ctx.parsed.y != null ? ctx.parsed.y : ctx.parsed) } }
        },
        scales: pie ? undefined : {
          x: { ticks: { font: chartFont(), color: tone.inkFaint }, grid: { display: false } },
          y: { ticks: { font: chartFont(), color: tone.inkFaint, callback: v => chartNum(v) },
               beginAtZero: true }
        },
        onHover: typeof chartHoverCursor === "function" ? chartHoverCursor : undefined
      },
      plugins: typeof dashEmpty !== "undefined" ? [dashEmpty] : []
    });
  });
}

/* ---------- بخشِ تنظیمات ---------- */
function chartCfgId() {
  return "c" + Date.now().toString(36) + Math.floor(Math.random() * 1e4).toString(36);
}

function renderChartSettings() {
  const host = document.getElementById("chartCfgBody");
  if (!host) return;
  const cfg = chartCfg();
  const off = new Set(cfg.off);

  const built = chartBuilt().filter(b => builtPanel(b));
  const builtHtml = built.length
    ? built.map(b =>
        '<label class="ccf-chk"><input type="checkbox" data-ccf-built="' + escapeHtml(b.id) + '"' +
        (off.has(b.id) ? "" : " checked") + '><span>' + escapeHtml(b.label) + '</span></label>').join("")
    : '<p class="set-p">نمودارِ آماده‌ای در این کارتابل نیست.</p>';

  const srcs = chartSrcs();
  const mine = cfg.custom.length
    ? '<ul class="ccf-list">' + cfg.custom.map(c =>
        '<li><span class="ccf-ttl">' + escapeHtml(customChartTitle(c)) + '</span>' +
        '<button type="button" class="btn btn-ghost ccf-del" data-ccf-del="' + escapeHtml(c.id) + '">حذف</button></li>'
      ).join("") + '</ul>'
    : '<p class="set-p">هنوز نمودارِ دلخواهی نساخته‌اید.</p>';

  host.innerHTML =
    '<h4 class="ccf-h">نمودارهای آمادهٔ داشبورد</h4>' +
    '<div class="ccf-chks">' + builtHtml + '</div>' +
    '<h4 class="ccf-h">نمودارهای خودتان</h4>' + mine +
    '<div class="ccf-new">' +
      '<div class="set-grid">' +
        '<label>از کدام بخش' +
          '<select id="ccfSrc">' + srcs.map(s =>
            '<option value="' + escapeHtml(s.id) + '">' + escapeHtml(s.label) + '</option>').join("") +
          '</select>' +
        '</label>' +
        '<label>گروه‌بندی بر پایهٔ<select id="ccfBy"></select></label>' +
        '<label>چه چیزی شمرده شود<select id="ccfAgg">' +
          '<option value="count">تعداد ردیف‌ها</option>' +
          '<option value="sum">جمعِ یک ستونِ عددی</option>' +
        '</select></label>' +
        '<label id="ccfNumWrap" hidden>ستونِ عددی<select id="ccfNum"></select></label>' +
        '<label>شکلِ نمودار<select id="ccfType">' +
          '<option value="bar">ستونی</option>' +
          '<option value="doughnut">دایره‌ای</option>' +
          '<option value="line">خطی</option>' +
        '</select></label>' +
        '<label>عنوان (خالی بگذارید تا خودش بنویسد)<input type="text" id="ccfTitle" placeholder="مثلاً: هزینه‌ها به تفکیک دسته"></label>' +
      '</div>' +
      '<div class="set-row">' +
        '<button type="button" class="btn btn-brass" id="ccfAdd">ساختنِ نمودار</button>' +
        '<span class="set-state" id="ccfState"></span>' +
      '</div>' +
    '</div>';

  syncChartFields();
}

/* ستون‌های هر بخش با خودش عوض می‌شود. */
function syncChartFields() {
  const s = chartSrcOf((document.getElementById("ccfSrc") || {}).value);
  const by = document.getElementById("ccfBy");
  const num = document.getElementById("ccfNum");
  const agg = document.getElementById("ccfAgg");
  const wrap = document.getElementById("ccfNumWrap");
  if (!s || !by || !num || !agg) return;
  /* انتخابِ کاربر باید بماند: این تابع با عوض‌شدنِ «چه چیزی شمرده
     شود» هم صدا زده می‌شود، و اگر فهرست را کور بسازیم، ستونی که
     کاربر انتخاب کرده بود به اولی برمی‌گردد — بی آن‌که ببیند. */
  const keepBy = by.value, keepNum = num.value;
  by.innerHTML = (s.fields || []).map(f =>
    '<option value="' + escapeHtml(f.k) + '">' + escapeHtml(f.label) + '</option>').join("");
  if ([...by.options].some(o => o.value === keepBy)) by.value = keepBy;
  const nums = s.nums || [];
  num.innerHTML = nums.map(f =>
    '<option value="' + escapeHtml(f.k) + '">' + escapeHtml(f.label) + '</option>').join("");
  if ([...num.options].some(o => o.value === keepNum)) num.value = keepNum;
  /* بخشی که ستونِ عددی ندارد، «جمع» هم ندارد — گزینه‌ای که کار
     نمی‌کند نباید دیده شود. */
  const sumOpt = agg.querySelector('option[value="sum"]');
  if (sumOpt) sumOpt.hidden = !nums.length;
  if (!nums.length && agg.value === "sum") agg.value = "count";
  if (wrap) wrap.hidden = agg.value !== "sum";
}

function wireChartSettings() {
  const host = document.getElementById("chartCfgBody");
  if (!host || host.dataset.wired) return;
  host.dataset.wired = "1";

  host.addEventListener("change", e => {
    const b = e.target.closest("[data-ccf-built]");
    if (b) {
      const id = b.getAttribute("data-ccf-built");
      const cfg = chartCfg();
      const off = new Set(cfg.off);
      if (b.checked) off.delete(id); else off.add(id);
      cfg.off = [...off];
      applyBuiltinCharts();
      if (typeof scheduleSave === "function") scheduleSave();
      return;
    }
    if (e.target.id === "ccfSrc" || e.target.id === "ccfAgg") syncChartFields();
  });

  host.addEventListener("click", e => {
    const del = e.target.closest("[data-ccf-del]");
    if (del) {
      const id = del.getAttribute("data-ccf-del");
      const cfg = chartCfg();
      cfg.custom = cfg.custom.filter(c => c.id !== id);
      if (typeof scheduleSave === "function") scheduleSave();
      renderChartSettings();
      renderCustomCharts();
      return;
    }
    if (e.target.id !== "ccfAdd") return;

    const src = (document.getElementById("ccfSrc") || {}).value;
    const by = (document.getElementById("ccfBy") || {}).value;
    const agg = (document.getElementById("ccfAgg") || {}).value;
    const num = (document.getElementById("ccfNum") || {}).value;
    const type = (document.getElementById("ccfType") || {}).value;
    const title = (document.getElementById("ccfTitle") || {}).value;
    const st = document.getElementById("ccfState");
    const s = chartSrcOf(src);
    if (!s || !by) { if (st) st.textContent = "بخش و ستون را انتخاب کنید."; return; }
    if (agg === "sum" && !num) { if (st) st.textContent = "ستونِ عددی را انتخاب کنید."; return; }

    chartCfg().custom.push({ id: chartCfgId(), title: String(title || "").trim(),
      src, by, agg, num: agg === "sum" ? num : "", type });
    if (typeof scheduleSave === "function") scheduleSave();
    renderChartSettings();
    renderCustomCharts();
    const st2 = document.getElementById("ccfState");
    if (st2) st2.textContent = "ساخته شد — در داشبورد ببینیدش.";
  });
}
