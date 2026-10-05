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
    return;
  }

  var jobs = VEEAM.jobs || [];
  var n = { ok:0, warn:0, bad:0, none:0 };
  jobs.forEach(function(j){ n[veeamTone(j.result)]++; });

  if(cards) cards.innerHTML =
    '<div class="stat blue"><div class="lbl">🛡️ تعداد جاب</div><div class="val">' + fa(jobs.length) + '</div></div>' +
    '<div class="stat green"><div class="lbl">✅ موفق</div><div class="val">' + fa(n.ok) + '</div></div>' +
    '<div class="stat amber"><div class="lbl">⚠️ هشدار</div><div class="val">' + fa(n.warn) + '</div></div>' +
    '<div class="stat red"><div class="lbl">⛔ ناموفق</div><div class="val">' + fa(n.bad) + '</div></div>';

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

  if(window.tableSizeSweep) try{ window.tableSizeSweep(); }catch(e){}
  if(window.cellPopScan) try{ window.cellPopScan(); }catch(e){}
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
