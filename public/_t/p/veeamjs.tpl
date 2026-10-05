/* ---------------- گزارشِ Veeam ----------------
   فقط می‌خواند. نوشتنش از راهِ «/veeam/push» است و با کلیدِ جدا — از
   این صفحه هیچ راهی به آن نیست.

   عددِ «کهنگی» این‌جا سخت‌گیرانه است: اگر گزارش بیش از ۹۰ دقیقه پیش
   آمده باشد هشدار می‌دهد. اسکریپت ساعتی یک بار می‌فرستد، پس نیم ساعت
   تحمل دارد و بعدش یعنی یک چیزی آن طرف ایستاده — و گزارشِ کهنه بدتر
   از گزارشِ نداشته است: آدم سبزِ سه روز پیش را می‌بیند و خیالش راحت
   می‌شود. */
var VEEAM = null;
var VEEAM_STALE_MIN = 90;

function veeamTone(result){
  var r = String(result || "").trim().toLowerCase();
  if(!r) return "none";
  if(r === "success" || r === "موفق") return "ok";
  if(r === "warning" || r === "هشدار") return "warn";
  return "bad";
}
function veeamWord(result){
  var m = { success:"موفق", warning:"هشدار", failed:"ناموفق", none:"—" };
  var r = String(result || "").trim();
  return m[r.toLowerCase()] || r || "—";
}

/* وضعیتِ جاب هم ترجمه می‌شود. نامِ خودِ جاب و نوعش (Backup، Replica)
   دست نمی‌خورند: آن‌ها همان چیزی‌اند که در کنسولِ Veeam نوشته شده و
   ترجمه‌شان یعنی کاربر باید دو نام را به هم وصل کند. ولی «Stopped»
   نامِ چیزی نیست، یک کلمهٔ معمولی است. */
function veeamState(state){
  var m = {
    stopped:"متوقف", working:"در حال اجرا", starting:"در حال شروع",
    stopping:"در حال توقف", pausing:"در حال مکث", resuming:"از سر گرفتن",
    postprocessing:"پردازشِ پایانی", idle:"بیکار", inactive:"غیرفعال",
    disabled:"غیرفعال", waitingtape:"منتظر نوار", waitingrepository:"منتظر مخزن"
  };
  var r = String(state || "").trim();
  return m[r.toLowerCase()] || r;
}

/* زمانِ آخرین گزارش به فارسی. تاریخ‌های داخلِ جدول را خودِ اسکریپت
   می‌فرستد و دست نمی‌خورند: هر شکلی که Veeam داده، همان نشان داده
   می‌شود — بازخوانیِ تاریخِ یک سیستمِ دیگر، جایی است که عدد اشتباه
   می‌شود. */
function veeamWhen(at){
  if(!at) return "";
  var d = new Date(Number(at));
  try{
    var s = new Intl.DateTimeFormat("fa-IR", { dateStyle:"full", timeStyle:"short" }).format(d);
    return s;
  }catch(e){ return d.toLocaleString(); }
}

function renderVeeam(){
  var body = document.getElementById("veeamBody");
  if(!body) return;
  var cards = document.getElementById("veeamCards");
  var when  = document.getElementById("veeamWhen");
  var warn  = document.getElementById("veeamWarn");
  var note  = document.getElementById("veeamNote");

  if(!VEEAM){
    body.innerHTML = '<tr><td colspan="8" style="color:var(--ink-faint);">هنوز گزارشی نرسیده.</td></tr>';
    if(cards) cards.innerHTML = "";
    if(when) when.textContent = "";
    if(warn){
      warn.hidden = false;
      warn.className = "veeam-warn";
      warn.innerHTML = "هنوز هیچ گزارشی از Veeam نرسیده. اسکریپتِ فرستنده باید روی شبکهٔ شرکت نصب و " +
        "کلیدش در پنل ساخته شده باشد.";
    }
    if(note) note.textContent = "";
    renderVeeamRepos([]);
    renderVeeamSessions([]);
    return;
  }

  var jobs = VEEAM.jobs || [];
  var n = { ok:0, warn:0, bad:0, none:0 };
  jobs.forEach(function(j){ n[veeamTone(j.result)]++; });

  /* فضای مخزن‌ها هم روی همان کارت‌ها می‌آید. «چند جاب موفق بود» بدونِ
     «چقدر جا مانده» نصفِ جواب است: بکاپی که جا ندارد، فردا ناموفق
     می‌شود و امروز هنوز سبز است. */
  var repos = VEEAM.repos || [];
  var cap = 0, free = 0, fullest = null;
  repos.forEach(function(r){
    var c = parseFloat(r.capacity) || 0, f = parseFloat(r.free) || 0;
    cap += c; free += f;
    var pct = parseFloat(r.pct);
    if(!isNaN(pct) && (!fullest || pct > fullest.pct)) fullest = { name: r.name, pct: pct };
  });

  var gb = function(v){ return fa(Math.round(v).toLocaleString("en-US")); };
  if(cards) cards.innerHTML =
    '<div class="stat blue"><div class="lbl">🛡️ تعداد جاب</div><div class="val">' + fa(jobs.length) + '</div></div>' +
    '<div class="stat green"><div class="lbl">✅ موفق</div><div class="val">' + fa(n.ok) + '</div></div>' +
    '<div class="stat amber"><div class="lbl">⚠️ هشدار</div><div class="val">' + fa(n.warn) + '</div></div>' +
    '<div class="stat red"><div class="lbl">⛔ ناموفق</div><div class="val">' + fa(n.bad) + '</div></div>' +
    (repos.length
      ? '<div class="stat teal"><div class="lbl">💽 فضای کل (GB)</div><div class="val">' + gb(cap) + '</div></div>' +
        '<div class="stat ' + (cap > 0 && free / cap < 0.1 ? 'red' : 'blue') +
          '"><div class="lbl">🆓 فضای آزاد (GB)</div><div class="val">' + gb(free) + '</div></div>' +
        (fullest
          ? '<div class="stat ' + (fullest.pct >= 90 ? 'red' : fullest.pct >= 75 ? 'amber' : 'green') +
            '"><div class="lbl">📈 پرترین مخزن</div><div class="val">' + fa(Math.round(fullest.pct)) + '٪</div></div>'
          : '')
      : '');

  if(when) when.textContent = VEEAM.at ? ("آخرین گزارش: " + veeamWhen(VEEAM.at)) : "";

  if(warn){
    var mins = VEEAM.at ? Math.round((Date.now() - Number(VEEAM.at)) / 60000) : 1e9;
    if(VEEAM.error){
      warn.hidden = false; warn.className = "veeam-warn bad";
      warn.innerHTML = "اسکریپتِ فرستنده به Veeam نرسید: " + escapeHtml(VEEAM.error) +
        "<br>عددهای زیر مالِ آخرین گزارشِ سالم‌اند و ممکن است کهنه باشند.";
    } else if(mins > VEEAM_STALE_MIN){
      warn.hidden = false; warn.className = "veeam-warn";
      warn.innerHTML = "این گزارش " + fa(mins) + " دقیقه پیش آمده. اسکریپت ساعتی یک بار می‌فرستد، " +
        "پس یعنی یک چیزی آن طرف ایستاده — به عددهای زیر به‌عنوانِ «وضعیتِ الان» تکیه نکنید.";
    } else warn.hidden = true;
  }

  body.innerHTML = jobs.map(function(j, i){
    var tone = veeamTone(j.result);
    return '<tr>' +
      '<td>' + fa(i + 1) + '</td>' +
      '<td class="editable-cell">' + escapeHtml(j.name || "") + '</td>' +
      '<td>' + escapeHtml(j.type || "") + '</td>' +
      '<td><span class="vee-b ' + tone + '">' + escapeHtml(veeamWord(j.result)) + '</span></td>' +
      '<td>' + escapeHtml(veeamState(j.state)) + '</td>' +
      '<td>' + escapeHtml(j.last || "—") + '</td>' +
      '<td>' + escapeHtml(j.next || "—") + '</td>' +
      '<td>' + (j.objects ? fa(escapeHtml(j.objects)) : "") + '</td>' +
      '</tr>';
  }).join("") || '<tr><td colspan="8" style="color:var(--ink-faint);">گزارش رسید ولی هیچ جابی داخلش نبود.</td></tr>';

  if(note) note.textContent = (VEEAM.host ? "سرورِ Veeam: " + VEEAM.host : "") +
    (VEEAM.agent ? "  •  فرستنده: " + VEEAM.agent : "");

  renderVeeamRepos(repos);
  renderVeeamSessions(VEEAM.sessions || []);

  if(window.tableSizeSweep) try{ window.tableSizeSweep(); }catch(e){}
  if(window.cellPopScan) try{ window.cellPopScan(); }catch(e){}
}

/* مخزن‌ها. پانل فقط وقتی دیده می‌شود که چیزی برای نشان دادن باشد —
   یک جدولِ خالی با سرستون‌هایش، آدم را می‌فرستد دنبالِ داده‌ای که
   اصلاً نیامده. */
function renderVeeamRepos(repos){
  var panel = document.getElementById("veeamRepoPanel");
  var body  = document.getElementById("veeamRepoBody");
  var hint  = document.getElementById("veeamRepoHint");
  if(!panel || !body) return;
  if(!repos || !repos.length){ panel.hidden = true; return; }
  panel.hidden = false;

  var low = repos.filter(function(r){ return (parseFloat(r.pct) || 0) >= 90; }).length;
  if(hint) hint.textContent = low
    ? fa(low) + " مخزن بالای ۹۰٪ پر شده"
    : fa(repos.length) + " مخزن";

  body.innerHTML = repos.map(function(r, i){
    var pct = parseFloat(r.pct);
    var has = !isNaN(pct);
    var tone = !has ? "" : pct >= 90 ? " bad" : pct >= 75 ? " warn" : "";
    var w = has ? Math.max(0, Math.min(100, pct)) : 0;
    return '<tr>' +
      '<td>' + fa(i + 1) + '</td>' +
      '<td class="editable-cell">' + escapeHtml(r.name || "") + '</td>' +
      '<td>' + escapeHtml(r.type || "") + '</td>' +
      '<td>' + (r.capacity ? fa(r.capacity) : "—") + '</td>' +
      '<td>' + (r.free ? fa(r.free) : "—") + '</td>' +
      '<td>' + (has
        ? '<div class="vee-bar' + tone + '"><span class="num">' + fa(Math.round(pct)) + '٪</span>' +
          '<span class="trk"><span class="fil" style="width:' + w + '%"></span></span></div>'
        : "—") + '</td>' +
      '</tr>';
  }).join("");
}

/* اجراهای اخیر — این همان چیزی است که وقتی یک جاب قرمز شد، آدم دنبالش
   می‌گردد: کِی اجرا شد، چقدر طول کشید، و چه شد. */
function renderVeeamSessions(sess){
  var panel = document.getElementById("veeamSessPanel");
  var body  = document.getElementById("veeamSessBody");
  var hint  = document.getElementById("veeamSessHint");
  if(!panel || !body) return;
  if(!sess || !sess.length){ panel.hidden = true; return; }
  panel.hidden = false;

  var failed = sess.filter(function(x){ return veeamTone(x.result) === "bad"; }).length;
  if(hint) hint.textContent = failed
    ? fa(failed) + " اجرای ناموفق در این فهرست"
    : fa(sess.length) + " اجرای اخیر";

  body.innerHTML = sess.slice(0, 40).map(function(x, i){
    return '<tr>' +
      '<td>' + fa(i + 1) + '</td>' +
      '<td class="editable-cell">' + escapeHtml(x.name || "") + '</td>' +
      '<td>' + escapeHtml(x.type || "") + '</td>' +
      '<td><span class="vee-b ' + veeamTone(x.result) + '">' + escapeHtml(veeamWord(x.result)) + '</span></td>' +
      '<td>' + escapeHtml(x.start || "—") + '</td>' +
      '<td>' + escapeHtml(x.end || "—") + '</td>' +
      '<td>' + (x.mins ? fa(x.mins) + " دقیقه" : "—") + '</td>' +
      '</tr>';
  }).join("");
}

async function loadVeeam(){
  if(!signedIn) return;
  try{
    var r = await apiCall("/veeam");
    /* ۴۰۳ یعنی ادمین این بخش را بسته — دکمه‌اش هم نیست، پس چیزی برای
       گفتن نداریم. */
    if(!r.ok) return;
    VEEAM = r.data.report || null;
    renderVeeam();
  }catch(e){ /* بدونِ این هم بقیهٔ کارتابل کار می‌کند */ }
}
