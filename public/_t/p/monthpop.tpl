/* ---------- رقمِ سال، فارسی یا انگلیسی، یک ماه است ----------
   کلیدِ هر ماه از نام و سالی ساخته می‌شود که کاربر تایپ کرده، و کادرِ
   «سال» در راهنمایش «مثلاً ۱۴۰۴» را با رقمِ فارسی نشان می‌دهد. پس یکی
   «۱۴۰۵» می‌نویسد و یکی «1405»، و دو کلیدِ متفاوت ساخته می‌شود که روی
   صفحه عینِ هم دیده می‌شوند.

   اثرش بدتر از یک فهرستِ دوتایی است: currentMonthKey به کلیدی اشاره
   می‌کند که در نقشه نیست، و ensureMonthsMigration هر بار که صفحه باز
   می‌شود یک ماهِ تازه می‌سازد. کارتابلِ یکی از کاربرها به همین شکل
   سی‌ودو ماه پیدا کرده بود. */
function faToEn(s){
  return String(s == null ? "" : s)
    .replace(/[۰-۹]/g, d => String(d.charCodeAt(0) - 0x06F0))
    .replace(/[٠-٩]/g, d => String(d.charCodeAt(0) - 0x0660));
}

/* کلیدهایی که از قبل با رقمِ فارسی ساخته شده‌اند یکدست می‌شوند. اگر
   کلیدِ یکدست از قبل پر باشد دست نمی‌خورد و هر دو می‌مانند — جابه‌جا
   کردنِ سطر بینِ دو ماه کارِ این تابع نیست و بی‌صدا انجام نمی‌شود. */
function normalizeMonthKeys(){
  if(!state || !state.monthsData || typeof state.monthsData !== "object") return;
  for(const k of Object.keys(state.monthsData)){
    const parts = String(k).split("|");
    const fixed = faToEn(parts[0]) + "|" + (parts[1] || "");
    if(fixed === k || state.monthsData[fixed]) continue;
    state.monthsData[fixed] = state.monthsData[k];
    delete state.monthsData[k];
    if(state.currentMonthKey === k) state.currentMonthKey = fixed;
  }
  if(state.currentMonthKey){
    const p = String(state.currentMonthKey).split("|");
    state.currentMonthKey = faToEn(p[0]) + "|" + (p[1] || "");
  }
  if(state.meta && state.meta.year) state.meta.year = faToEn(state.meta.year);
}

/* ---------- یک نسخه، نه دو تا ----------
   برنامهٔ روزانه و چک‌لیست دو جا نگه داشته می‌شدند: «state.days» که
   جدول روی آن کار می‌کند، و «monthsData[ماهِ جاری]» که بایگانی است.
   این دو فقط موقعِ عوض کردنِ ماه هم‌تراز می‌شدند.

   کارتابلِ سیامک روی شهریور مانده بود و تا سطرِ ۸۱ جلو رفته بود، ولی
   بایگانیِ شهریور همان ۳۱ سطرِ روزِ اول را داشت. پنجاه سطر فقط یک جا
   بودند، و لحظه‌ای که چیزی بایگانی را روی نسخهٔ در دستِ کار نشاند،
   پنجاه سطر رفت.

   حالا پیش از هر ذخیره، بایگانی از روی نسخهٔ در دستِ کار تازه می‌شود.
   بعد از اولین ذخیره هر دو به یک آرایه اشاره می‌کنند، پس دیگر
   نسخهٔ کهنه‌ای وجود ندارد که روی چیزی بیفتد. */
function syncWorkingMonth(){
  if(typeof state !== "object" || !state || !state.currentMonthKey) return;
  if(!state.monthsData || typeof state.monthsData !== "object") state.monthsData = {};
  state.monthsData[state.currentMonthKey] = { tasks: state.tasks, days: state.days };
}

/* ---------- وظیفه‌های تکرارشونده ----------
   چک‌لیستِ ماهانه تا حالا با ساختنِ هر ماه از صفر شروع می‌شد: نه قالبِ
   شغل می‌آمد و نه فهرستِ ماهِ قبل. ولی نامِ خودِ بخش «وظایفِ
   تکرارشونده» است و کاربر هر اولِ ماه باید همان پانزده‌شانزده ردیف را
   دوباره تایپ می‌کرد.

   حالا هر وظیفه یک تیکِ «تکرار» دارد. آن‌هایی که تیک دارند به ماهِ
   تازه می‌آیند و وضعیتشان صفر می‌شود؛ کارِ یک‌بارهٔ این ماه نمی‌آید.

   «repeat !== false» و نه «repeat === true»: دادهٔ قدیمی این کلید را
   ندارد، و وظیفه‌ای که کاربر خودش تیکش را برنداشته باید تکرار شود —
   وگرنه همان ایرادِ قبلی برای همهٔ کارتابل‌های موجود سرِ جایش می‌ماند. */
function monthlyCarry(prevTasks, want){
  if(want === false) return [];
  return (prevTasks || [])
    .filter(function(t){ return t && t.repeat !== false; })
    .map(function(t){
      var c = Object.assign({}, t);
      c.status = "انجام نشده";
      /* یادآور و تاریخِ انجام مالِ همان ماهِ گذشته بودند */
      delete c.reminder;
      delete c.doneDate;
      return c;
    });
}

/* نامِ یک ماه را درست می‌کند. کلیدِ ماه خودش از نام و سال ساخته می‌شود،
   پس «تغییر نام» یعنی جابه‌جایی همان داده زیرِ کلیدِ تازه — نه ساختنِ
   ماهی دیگر. اگر ماهی با نامِ تازه از قبل باشد، جلویش گرفته می‌شود:
   وگرنه دادهٔ یکی‌شان بی‌صدا روی آن یکی می‌افتاد. */
function renameMonth(oldKey, monthName, year){
  monthName = String(monthName||"").trim();
  year = String(year||"").trim();
  if(!monthName || !year){ alert("نام ماه و سال را کامل وارد کنید."); return false; }
  if(!oldKey || !state.monthsData[oldKey]){ alert("ماهی برای تغییر نام پیدا نشد."); return false; }
  const key = monthKeyOf(monthName, year);
  if(key === oldKey) return true;
  if(state.monthsData[key]){ alert("ماهی با همین نام و سال از قبل هست."); return false; }
  /* نسخهٔ در دستِ کار اول برمی‌گردد داخلِ نقشه، وگرنه تغییرهای همین
     ماه که هنوز ننشسته‌اند گم می‌شوند. */
  if(state.currentMonthKey) state.monthsData[state.currentMonthKey] = { tasks: state.tasks, days: state.days };
  state.monthsData[key] = state.monthsData[oldKey];
  delete state.monthsData[oldKey];
  if(state.currentMonthKey === oldKey){
    state.currentMonthKey = key;
    state.meta.month = monthName;
    state.meta.year = year;
  }
  /* کلیدِ یادآوری‌های بسته‌شده نامِ ماه را دارد، پس یکی‌دو یادآوری که
     امروز بسته شده بود ممکن است دوباره پیدا شود. چون آن فهرست فقط تا
     بسته شدنِ صفحه زنده است، مهاجرتش ارزشِ کد نداشت. */
  afterMonthChange();
  return true;
}
/* پنجرهٔ ماه‌ها جای سه کنترلِ پیشینِ نوارِ بالا را گرفته: نامِ ماهِ جاری
   روی دکمه می‌نشیند، و رفتن به ماهی دیگر، تغییرِ نامش و ساختنِ ماهِ تازه
   همه داخلِ پنجره‌اند. MP_EDIT کلیدِ ماهی است که همین حالا دارد نامش عوض
   می‌شود — تغییرِ نام در ردیفِ خودش انجام می‌شود، نه در پنجره‌ای دیگر. */
let MP_EDIT = null;
function renderMonthSelector(){
  const lab = document.getElementById("monthBtnLabel");
  /* سالِ کلید با رقمِ لاتین ذخیره می‌شود (برای مرتب‌سازی)، ولی روی
     دکمه باید فارسی دیده شود — بقیهٔ عددهای صفحه همه فارسی‌اند. */
  if(lab){
    const txt = state.currentMonthKey ? monthLabelOf(state.currentMonthKey) : "—";
    lab.textContent = (typeof fa === "function") ? fa(txt) : txt;
  }
  const list = document.getElementById("monthPopList");
  if(!list) return;
  const keys = Object.keys(state.monthsData||{});
  if(MP_EDIT && !state.monthsData[MP_EDIT]) MP_EDIT = null;
  list.innerHTML = keys.length ? keys.map(k=>{
    const p = String(k).split("|");
    if(k === MP_EDIT){
      return `<div class="mrow on">`+
        `<input class="me-n" value="${escapeHtml(p[1]||"")}" placeholder="نام ماه">`+
        `<input class="me-y" value="${escapeHtml(p[0]||"")}" placeholder="سال">`+
        `<button type="button" class="ed ok" data-ok="${escapeHtml(k)}" title="ثبت">✓</button>`+
        `<button type="button" class="ed" data-cancel="1" title="بی‌خیال">✕</button>`+
      `</div>`;
    }
    return `<div class="mrow${k===state.currentMonthKey?" on":""}">`+
      `<button type="button" class="nm" data-go="${escapeHtml(k)}">${escapeHtml(monthLabelOf(k))}</button>`+
      `<button type="button" class="ed" data-ren="${escapeHtml(k)}" title="تغییر نام">✎</button>`+
    `</div>`;
  }).join("") : `<div class="mpop-empty">هنوز ماهی ساخته نشده. از همین پایین یکی بساز.</div>`;
}

/* ---------- ردیف‌های قدیمیِ بی‌تاریخ ----------
   «تاریخِ ایجاد» دیرتر از خودِ برنامهٔ روزانه به جدول اضافه شد، و هر
   سطری که پیش از آن ساخته شده بود بی‌تاریخ ماند. همان سطرها در پالایهٔ
   تاریخ و در تقویمِ روز هیچ‌جا دیده نمی‌شوند — جدول نشانشان می‌دهد، ولی
   هیچ روزی مالِ خودش حسابشان نمی‌کند.

   تاریخِ واقعیِ آن سطرها هیچ‌جا ذخیره نشده، ولی ماهشان را می‌دانیم: هر
   ماه آرایهٔ خودش را دارد و کلیدش نام و سال را با خود می‌برد. پس روزِ
   اولِ همان ماه می‌نشیند — حدسی که از خالی بودن راست‌تر است و کاربر
   خودش خواسته.

   دو قیدِ عمدی: فقط سطری مُهر می‌خورد که چیزی داخلش نوشته شده (سطرهای
   خالیِ نمونه باید خالی بمانند، وگرنه پالایهٔ تاریخ پر از «روزِ اولِ
   ماه» می‌شود)، و هر ماه فقط یک بار (اگر کسی بعداً تاریخی را پاک کرد،
   دفعهٔ بعد دوباره برنمی‌گردد). */
function monthFirstDay(key){
  const p = String(key||"").split("|");
  const y = faToEn(p[0]||"").trim();
  const name = String(p[1]||"").trim();
  if(!/^\d{4}$/.test(y)) return "";
  let m = -1;
  try{ m = JALALI_MONTH_NAMES.indexOf(name); }catch(e){ return ""; }
  if(m < 0) return "";
  return y + "/" + String(m+1).padStart(2,"0") + "/01";
}

function dayRowHasContent(d){
  if(!d || typeof d !== "object") return false;
  return !!(String(d.main||"").trim() || String(d.meet||"").trim()
    || String(d.company||"").trim() || String(d.status||"").trim()
    || String(d.doneDate||"").trim());
}

function backfillCreatedDates(){
  if(typeof state !== "object" || !state) return 0;
  if(!state.datesFilled || typeof state.datesFilled !== "object") state.datesFilled = {};
  /* نسخهٔ در دستِ کار اول برمی‌گردد داخلِ نقشه، تا ماهِ جاری هم از
     همین‌جا دیده شود و هر دو به یک آرایه اشاره کنند. */
  try{ syncWorkingMonth(); }catch(e){}
  const map = state.monthsData || {};
  let n = 0;
  for(const key of Object.keys(map)){
    if(state.datesFilled[key]) continue;
    const stamp = monthFirstDay(key);
    if(!stamp) continue;            /* ماهی که نام یا سالش خوانا نیست، دست نمی‌خورد */
    const days = (map[key] && map[key].days) || [];
    if(!Array.isArray(days)) continue;
    for(const d of days){
      if(!dayRowHasContent(d)) continue;
      if(String(d.createdDate||"").trim()) continue;
      d.createdDate = stamp;        /* رقمِ انگلیسی، عینِ getTodayJalaliStr */
      n++;
    }
    state.datesFilled[key] = true;
  }
  return n;
}
