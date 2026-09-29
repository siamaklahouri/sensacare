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
  if(lab) lab.textContent = state.currentMonthKey ? monthLabelOf(state.currentMonthKey) : "—";
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