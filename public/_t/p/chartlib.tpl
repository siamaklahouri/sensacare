function timeoutFor(url){ return url.charAt(0) === "/" ? 25000 : 8000; }
function loadScriptOnce(src, timeoutMs){
  return new Promise((resolve,reject)=>{
    let settled = false;
    const tag = document.createElement("script");
    const timer = setTimeout(()=>{
      if(settled) return; settled = true; tag.remove(); reject(new Error("timeout"));
    }, timeoutMs);
    tag.onload = ()=>{ if(settled) return; settled = true; clearTimeout(timer); resolve(); };
    tag.onerror = ()=>{ if(settled) return; settled = true; clearTimeout(timer); tag.remove(); reject(new Error("load-error")); };
    tag.src = src;
    document.head.appendChild(tag);
  });
}
/* بوم داخل قابی با ارتفاعِ ثابت نشسته (به .chart-box نگاه کن)، پس
   Chart.js نباید خودش نسبتِ ابعاد را نگه دارد؛ اگر نگه دارد بوم را مربع
   می‌کند و نمودار از وسطِ قاب می‌افتد بالا. */

/* نموداری که راهنما یا عددِ وسطِ خودش را دارد (گزارش‌ساز، نمای مدیر)
   نباید یک بار دیگر هم از این‌جا عدد بگیرد. */
function chartHasOwnLabels(c){
  const p = (c.options && c.options.plugins) || {};
  return !!(p.rpVals || p.rpCenter || p.mgVals || p.mgCenter);
}
function chartFont(){
  try{ return getComputedStyle(document.body).fontFamily; }
  catch(e){ return "Vazirmatn, Tahoma, Arial, sans-serif"; }
}
/* همان ارقامِ فارسیِ بقیهٔ صفحه؛ عددِ لاتین وسطِ یک نمودارِ فارسی
   مثل یک وصله است. */
function chartNum(n){
  const t = Math.abs(n) >= 1000 ? Math.round(n).toLocaleString("en-US") : String(n);
  return t.replace(/[0-9]/g, d => "۰۱۲۳۴۵۶۷۸۹"[+d]);
}

/* عددِ هر ستون، روی خودش. بدونِ این، خواندنِ نمودار به نگه داشتنِ
   موشواره بند بود — و روی کاغذ اصلاً ممکن نبود. */
const dashValues = {
  id: "dashValues",
  afterDatasetsDraw(c){
    if(chartHasOwnLabels(c)) return;
    if(c.config.type !== "bar") return;
    const o = (c.options.plugins && c.options.plugins.dashValues) || {};
    if(o.on === false) return;
    const sc = c.options.scales || {};
    if((sc.x && sc.x.stacked) || (sc.y && sc.y.stacked)) return;
    if(c.data.datasets.length > 2) return;
    const horiz = c.options.indexAxis === "y";
    const area = c.chartArea;
    const t = chartTone();
    const g = c.ctx;
    g.save();
    g.font = "600 10.5px " + chartFont();
    g.textBaseline = horiz ? "middle" : "bottom";
    c.data.datasets.forEach((ds, di)=>{
      const meta = c.getDatasetMeta(di);
      if(meta.hidden) return;
      meta.data.forEach((el, i)=>{
        const v = ds.data[i];
        if(v == null || typeof v === "object" || !v) return;
        const s = chartNum(v);
        const w = g.measureText(s).width;
        /* میلهٔ صددرصدی تا لبهٔ قاب می‌رسد و عددش می‌افتاد بیرونِ بوم.
           اگر بیرون جا نشد، عدد می‌رود داخلِ خودِ میله — همان‌جا هم
           خوانا است، فقط رنگش باید روشن شود. */
        if(horiz){
          const base = el.base == null ? area.x : el.base;
          const dir = el.x >= base ? 1 : -1;          /* RTL یعنی dir منفی */
          const out = el.x + dir * (6 + w);
          const fits = dir > 0 ? out <= area.right : out >= area.left;
          if(fits){
            g.fillStyle = t.ink;
            g.textAlign = dir > 0 ? "left" : "right";
            g.fillText(s, el.x + dir * 6, el.y);
          } else if(Math.abs(el.x - base) > w + 16){
            g.fillStyle = "#FFFFFF";
            g.textAlign = dir > 0 ? "right" : "left";
            g.fillText(s, el.x - dir * 7, el.y);
          }
        } else {
          const inside = el.y - 16 < area.top;
          g.textAlign = "center";
          if(inside && Math.abs((el.base == null ? area.bottom : el.base) - el.y) > 22){
            g.fillStyle = "#FFFFFF";
            g.fillText(s, el.x, el.y + 15);
          } else {
            g.fillStyle = t.ink;
            g.fillText(s, el.x, el.y - 5);
          }
        }
      });
    });
    g.restore();
  }
};

/* جای خالیِ وسطِ دونات بزرگ‌ترین فضای بی‌استفادهٔ نمودار است؛ جمعِ کل
   آن‌جا می‌نشیند. */
const dashCenter = {
  id: "dashCenter",
  afterDraw(c){
    if(chartHasOwnLabels(c)) return;
    if(c.config.type !== "doughnut") return;
    const o = (c.options.plugins && c.options.plugins.dashCenter) || {};
    if(o.on === false) return;
    const m = c.getDatasetMeta(0);
    if(!m || !m.data || !m.data.length) return;
    let sum = 0, any = false;
    (c.data.datasets[0].data || []).forEach((v, i)=>{
      if(typeof v !== "number") return;
      if(!c.getDataVisibility(i)) return;
      sum += v; any = true;
    });
    if(!any || !sum) return;
    const el = m.data[0], t = chartTone(), f = chartFont();
    const g = c.ctx;
    g.save();
    g.textAlign = "center"; g.textBaseline = "middle";
    g.fillStyle = t.inkFaint;
    g.font = "11px " + f;
    g.fillText(o.label || "مجموع", el.x, el.y - 13);
    g.fillStyle = t.ink;
    g.font = "700 21px " + f;
    g.fillText(chartNum(sum), el.x, el.y + 9);
    g.restore();
  }
};

/* نموداری که هنوز داده‌ای ندارد، یک تورِ خالی با محورِ صفر تا یک
   می‌شد — مثلِ چیزی که خراب است، نه چیزی که هنوز پر نشده. حالا به‌جای
   تور، یک جمله. */
const dashEmpty = {
  id: "dashEmpty",
  afterDraw(c){
    const o = (c.options.plugins && c.options.plugins.dashEmpty) || {};
    if(o.on === false) return;
    let has = false;
    (c.data.datasets || []).forEach((ds, di)=>{
      if(!c.isDatasetVisible(di)) return;
      (ds.data || []).forEach(v=>{
        const n = (v && typeof v === "object") ? (v.y != null ? v.y : v.x) : v;
        if(typeof n === "number" && n) has = true;
      });
    });
    if(has) return;
    const g = c.ctx, t = chartTone();
    g.save();
    /* کلِ بوم پاک می‌شود، نه فقط ناحیهٔ نمودار: وگرنه عددهای محورِ
       «۰ تا ۱» دورِ یک قابِ خالی می‌ماندند. */
    g.clearRect(0, 0, c.width, c.height);
    g.textAlign = "center"; g.textBaseline = "middle";
    g.fillStyle = t.inkFaint;
    g.font = "12.5px " + chartFont();
    g.fillText(o.text || "هنوز داده‌ای برای این نمودار ثبت نشده",
               c.width / (2 * (window.devicePixelRatio || 1)),
               c.height / (2 * (window.devicePixelRatio || 1)));
    g.restore();
  }
};

function tuneChartDefaults(){
  if(typeof Chart === "undefined") return false;
  Chart.defaults.maintainAspectRatio = false;
  /* یک زبانِ بصری برای همهٔ نمودارهای کارتابل: یک قلم، یک شکلِ
     راهنما، یک جعبهٔ راهنمای موشواره. پیش از این هر نمودار قلم و
     اندازهٔ خودش را داشت. */
  Chart.defaults.font.family = chartFont();
  Chart.defaults.font.size = 11.5;
  Chart.defaults.plugins.legend.position = "bottom";
  Object.assign(Chart.defaults.plugins.legend.labels, {
    usePointStyle: true, pointStyle: "rectRounded",
    boxWidth: 11, boxHeight: 11, padding: 13
  });
  Object.assign(Chart.defaults.plugins.tooltip, {
    backgroundColor: "rgba(11,37,69,.93)", padding: 10, cornerRadius: 9,
    displayColors: true, titleFont: { size: 12.5 }, bodyFont: { size: 12.5 }
  });
  Chart.defaults.elements.bar.borderRadius = 6;
  Chart.defaults.elements.bar.borderSkipped = false;
  Chart.defaults.elements.point.radius = 3.5;
  Chart.defaults.elements.point.hoverRadius = 6;
  Chart.defaults.elements.line.tension = .3;
  /* ترتیب مهم است: «خالی» آخر ثبت می‌شود تا آخر هم کشیده شود و روی
     بقیه بیفتد. */
  try{ Chart.register(dashValues, dashCenter, dashEmpty); }
  catch(e){ /* دو بار ثبت اشکالی ندارد */ }
  return true;
}
async function ensureChartLib(){
  if(typeof Chart !== "undefined") return tuneChartDefaults();
  for(const url of CHART_CDN_URLS){
    try{
      await loadScriptOnce(url, timeoutFor(url));
      if(typeof Chart !== "undefined") return tuneChartDefaults();
    }catch(e){ /* try the next mirror */ }
  }
  return false;
}
const chartLibPromise = ensureChartLib();
