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