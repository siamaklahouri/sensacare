let dayPickerEl = null;

/* ---------------- انتخابِ روزِ مهلت ----------------
   این پنجره یک شبکهٔ ۱ تا ۳۱ بود، بی‌روزهای هفته. یعنی برای اینکه
   بفهمی مهلتی که می‌گذاری جمعه است یا نه، باید جای دیگری نگاه
   می‌کردی — و معمولاً کسی نگاه نمی‌کرد.

   حالا تقویمِ همان ماهِ باز است: ستون‌ها روزهای هفته‌اند، ماهِ
   بیست‌ونه‌روزه بیست‌ونه خانه دارد، جمعه و تعطیلِ رسمی قرمزند و
   امروز حلقه دارد. تعطیلی‌ها از همان جدولی می‌آیند که بخشِ تقویم
   به‌کار می‌برد، پس دو جا دو حرف نمی‌زنند. */
function pickerMonth(){
  var p = String(state.currentMonthKey || "").split("|");
  var y = parseInt(faToEn(p[0]), 10);
  var m = JALALI_MONTH_NAMES.indexOf(String(p[1] || "").trim()) + 1;
  if(!y || !m){
    var t = getTodayJalaliParts();
    y = parseInt(t.year, 10); m = t.monthNum;
  }
  return { jy: y, jm: m };
}

function buildDayGrid(grid, head, ttl){
  var mo = pickerMonth();
  var n = 31, lead = 0;
  try{ n = daysInJalaliMonth(mo.jy, mo.jm); }catch(e){}
  try{
    var g = DatePick.toG(mo.jy, mo.jm, 1);
    lead = (new Date(g.gy, g.gm - 1, g.gd).getDay() + 1) % 7;
  }catch(e){ lead = 0; }
  var t = getTodayJalaliParts();
  var isNow = (parseInt(t.year, 10) === mo.jy && t.monthNum === mo.jm);
  if(ttl) ttl.textContent = JALALI_MONTH_NAMES[mo.jm - 1] + " " + fa(mo.jy);
  if(head && !head.childElementCount)
    head.innerHTML = ["ش","ی","د","س","چ","پ","ج"]
      .map(function(d){ return "<span>" + d + "</span>"; }).join("");
  var html = "";
  for(var i = 0; i < lead; i++) html += '<span class="dp2-pad"></span>';
  for(var d = 1; d <= n; d++){
    var off = false, name = "";
    try{
      var h = window.CAL ? CAL.holiday(mo.jy, mo.jm, d) : null;
      if(h){ off = h.off; name = h.name || ""; }
    }catch(e){}
    html += '<button type="button" data-day="' + d + '"' +
      ' class="' + (off ? "off" : "") + (isNow && t.day === d ? " now" : "") + '"' +
      (name ? ' title="' + escapeHtml(name) + '"' : "") + '>' + fa(d) + '</button>';
  }
  grid.innerHTML = html;
}

var dayPickOn = null;      /* چه کاری با روزِ انتخاب‌شده بشود */

function ensureDayPicker(){
  if(dayPickerEl) return dayPickerEl;
  dayPickerEl = document.createElement("div");
  dayPickerEl.className = "day-picker-popup";
  dayPickerEl.innerHTML =
    '<div class="dp2-ttl"></div>' +
    '<div class="dp2-wd"></div>' +
    '<div class="dp-grid"></div>' +
    '<button type="button" class="dp-clear">پاک کردن</button>';
  document.body.appendChild(dayPickerEl);
  var grid = dayPickerEl.querySelector(".dp-grid");

  grid.addEventListener("click", (e)=>{
    const btn = e.target.closest("button[data-day]");
    if(!btn) return;
    const day = parseInt(btn.getAttribute("data-day"));
    if(dayPickOn) dayPickOn(day);
    closeDayPicker();
  });
  dayPickerEl.querySelector(".dp-clear").addEventListener("click", ()=>{
    if(dayPickOn) dayPickOn("");
    closeDayPicker();
  });
  document.addEventListener("click", (e)=>{
    if(!dayPickerEl.classList.contains("open")) return;
    if(dayPickerEl.contains(e.target) || e.target.closest(".date-box")) return;
    closeDayPicker();
  });
  return dayPickerEl;
}

function closeDayPicker(){
  if(dayPickerEl) dayPickerEl.classList.remove("open");
}

/* anchorEl: چه چیزی زده شده؛ current: روزِ فعلی؛ onPick: چه بنویسد.
   کارِ نوشتن دستِ خودِ صفحه است، چون چک‌لیستِ فنی و مالی دو جور
   تازه می‌شوند. */
function openDayPicker(anchorEl, current, onPick){
  const popup = ensureDayPicker();
  dayPickOn = onPick;
  /* هر بار از نو: ماهِ باز ممکن است از دفعهٔ قبل عوض شده باشد و
     شبکه‌ای که با ماهِ قبلی چیده شده باشد، روزهای هفته‌اش دروغ است. */
  buildDayGrid(popup.querySelector(".dp-grid"),
               popup.querySelector(".dp2-wd"),
               popup.querySelector(".dp2-ttl"));
  popup.querySelectorAll("button[data-day]").forEach(b=>{
    b.classList.toggle("selected", current && parseInt(b.getAttribute("data-day"))===parseInt(current));
  });
  const rect = anchorEl.getBoundingClientRect();
  popup.style.top = (rect.bottom + 4) + "px";
  popup.style.left = Math.max(8, Math.min(rect.left - 150,
    window.innerWidth - popup.offsetWidth - 8)) + "px";
  popup.classList.add("open");
}

