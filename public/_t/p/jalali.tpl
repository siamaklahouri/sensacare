
/* دو کارتابل دو پیادهٔ متفاوت از تبدیل تاریخ دارند: یکی شیء برمی‌گرداند
   و آن یکی آرایه. این‌جا هر دو را یک‌شکل می‌کنیم تا ابزار تبدیل تاریخ
   در هر دو یکسان کار کند. */
function asGreg(g){
  return Array.isArray(g) ? { gy:g[0], gm:g[1], gd:g[2] } : g;
}

function setupDateTools(){
  /* در کارتابلِ عمومی این نما وجود ندارد */
  if(!document.getElementById("dtDiffBtn")) return;
  const today = getTodayJalaliParts();
  const ty = parseInt(today.year)||1405, tm = today.monthNum||1, td = today.day||1;

  // ---- شمسی → میلادی ----
  const jy = document.getElementById("dtJY"), jm = document.getElementById("dtJM"), jd = document.getElementById("dtJD");
  fillJalaliYearSelect(jy, ty);
  fillJalaliMonthSelect(jm, tm);
  jd.innerHTML = jalaliMonthDayOptions(ty, tm, td);
  function recomputeJ2G(){
    const y=parseInt(jy.value), m=parseInt(jm.value), keepD=parseInt(jd.value)||1;
    jd.innerHTML = jalaliMonthDayOptions(y, m, Math.min(keepD, daysInJalaliMonth(y,m)));
    const d = parseInt(jd.value);
    const g = asGreg(jalaliToGregorian(y,m,d));
    document.getElementById("dtJ2GResult").textContent = formatGregorianLong(g.gy, g.gm, g.gd);
  }
  [jy,jm,jd].forEach(el=> el.addEventListener("change", recomputeJ2G));
  recomputeJ2G();

  // ---- میلادی → شمسی ----
  const gInput = document.getElementById("dtGDate");
  const now = new Date();
  gInput.value = `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,"0")}-${String(now.getDate()).padStart(2,"0")}`;
  function recomputeG2J(){
    if(!gInput.value){ document.getElementById("dtG2JResult").textContent = "—"; return; }
    const [gy,gm,gd] = gInput.value.split("-").map(Number);
    const j = gregorianToJalali(gy,gm,gd);
    document.getElementById("dtG2JResult").textContent = formatJalaliLong(j.jy, j.jm, j.jd);
  }
  gInput.addEventListener("change", recomputeG2J);
  recomputeG2J();

  // ---- محاسبه‌ی فاصله‌ی بین دو تاریخ شمسی ----
  const sy=document.getElementById("dtStartY"), sm=document.getElementById("dtStartM"), sd=document.getElementById("dtStartD");
  const ey=document.getElementById("dtEndY"), em=document.getElementById("dtEndM"), ed=document.getElementById("dtEndD");
  fillJalaliYearSelect(sy, ty); fillJalaliMonthSelect(sm, tm); sd.innerHTML = jalaliMonthDayOptions(ty, tm, td);
  fillJalaliYearSelect(ey, ty); fillJalaliMonthSelect(em, tm); ed.innerHTML = jalaliMonthDayOptions(ty, tm, td);
  function refreshDayOptions(ySel,mSel,dSel){
    const y=parseInt(ySel.value), m=parseInt(mSel.value), keepD=parseInt(dSel.value)||1;
    dSel.innerHTML = jalaliMonthDayOptions(y, m, Math.min(keepD, daysInJalaliMonth(y,m)));
  }
  sy.addEventListener("change", ()=>refreshDayOptions(sy,sm,sd));
  sm.addEventListener("change", ()=>refreshDayOptions(sy,sm,sd));
  ey.addEventListener("change", ()=>refreshDayOptions(ey,em,ed));
  em.addEventListener("change", ()=>refreshDayOptions(ey,em,ed));

  document.getElementById("dtDiffBtn").addEventListener("click", ()=>{
    const y1=parseInt(sy.value), m1=parseInt(sm.value), d1=parseInt(sd.value);
    const y2=parseInt(ey.value), m2=parseInt(em.value), d2=parseInt(ed.value);
    const jdn1 = j2d(y1,m1,d1), jdn2 = j2d(y2,m2,d2);
    const totalDays = Math.abs(jdn2 - jdn1);
    // شکست تقویمی فاصله به سال/ماه/روز (مستقل از جهت، همیشه تاریخ کوچک‌تر را به‌عنوان مبدا در نظر می‌گیرد)
    let [ay1,am1,ad1,ay2,am2,ad2] = jdn1<=jdn2 ? [y1,m1,d1,y2,m2,d2] : [y2,m2,d2,y1,m1,d1];
    let dd = ad2-ad1, mm = am2-am1, yy = ay2-ay1;
    if(dd<0){
      mm -= 1;
      let bm = am2-1, by = ay2;
      if(bm<1){ bm = 12; by -= 1; }
      dd += daysInJalaliMonth(by, bm);
    }
    if(mm<0){ mm += 12; yy -= 1; }
    const resultEl = document.getElementById("dtDiffResult");
    resultEl.innerHTML = `
      مجموع فاصله: <b>${fa(totalDays)}</b> روز (تقریباً <b>${fa(Math.round(totalDays/7))}</b> هفته)<br>
      به‌صورت تقویمی: <b>${fa(yy)}</b> سال، <b>${fa(mm)}</b> ماه و <b>${fa(dd)}</b> روز
    `;
  });
}

/* ---------- همگام‌سازی با سرور ----------
   کارتابل تا دیروز فقط در حافظهٔ همین مرورگر زندگی می‌کرد: با عوض کردن
   دستگاه یا پاک شدن حافظهٔ مرورگر همه‌چیز می‌رفت. حالا سرور مرجع است و
   حافظهٔ مرورگر فقط نسخهٔ آفلاین می‌ماند — اگر اینترنت نبود کارتابل باز
   می‌شود و کار می‌کند، و به‌محض وصل شدن، تغییرها بالا می‌روند.

   دو تکه بالا و پایین می‌رود: «state» (وظایف، برنامهٔ روزانه، ماه‌ها،
   بخش شخصیِ رمزشده) و «db» (سرورها، شرکت‌ها، MVPN، لاگ بکاپ، ریموت). */
