/* ==================== کاری که از مهلتش گذشته ====================
   یادآور فقط وقتی می‌آمد که یک یا دو روز به مهلت مانده باشد. از
   روزی که مهلت رد می‌شد، هیچ‌چیز: نه یادآوری، نه رنگی در چک‌لیست،
   نه نشانه‌ای در «مهلت‌های نزدیک». ردیفی که مهلتش پنجم بود و امروز
   بیست‌وسوم است، عینِ ردیفی دیده می‌شد که مهلتش بیست‌وهشتم است.

   برای یک پلنرِ ماهانه این بزرگ‌ترین حفره بود: چیزی که باید به چشم
   بیاید، تنها چیزی بود که هیچ نشانه‌ای نداشت.

   دو مرزِ عمدی:

   ۱) فقط ماهِ جاری. در ماهِ بایگانی‌شده «عقب‌افتاده» معنا ندارد —
      آن ماه تمام شده و قرار نیست کسی امروز کاری برایش بکند. اگر این
      مرز نبود، هر ماهِ قدیمی یک صفحه قرمز می‌شد.

   ۲) کاری که «انجام شد» است هیچ‌وقت عقب‌افتاده نیست، حتی اگر دیر
      انجام شده باشد. گذشته را نمی‌شود درست کرد و قرمزکردنش فقط
      نویز است. */

/* روزِ امروز در ماهِ جاری، یا صفر اگر ماهِ کاری ماهِ دیگری است. */
function odTodayDay() {
  try {
    const p = getTodayJalaliStr().split("/");
    const jy = parseInt(p[0], 10), jm = parseInt(p[1], 10), jd = parseInt(p[2], 10);
    if (!jy || !jm || !jd) return 0;
    const want = jy + "|" + JALALI_MONTH_NAMES[jm - 1];
    const have = String((state && state.currentMonthKey) || "");
    if (have && have !== want) return 0;
    return jd;
  } catch (e) { return 0; }
}

/* چند روز از مهلت گذشته — صفر یعنی نگذشته. */
function odDays(t) {
  try {
    if (!t || t.status === "انجام شد") return 0;
    const today = odTodayDay();
    if (!today) return 0;
    const d = parseInt(faToEn(t.deadline), 10);
    if (!Number.isFinite(d) || d <= 0) return 0;
    return d < today ? today - d : 0;
  } catch (e) { return 0; }
}

function odTitle(n) {
  return n === 1 ? "یک روز از مهلتش گذشته" : faDigits(n) + " روز از مهلتش گذشته";
}
function faDigits(n) {
  try { return fa(n); } catch (e) { return String(n); }
}

/* شمارِ کارهای عقب‌افتاده — برای نوارِ بالای داشبورد. */
function odCount() {
  try { return (state.tasks || []).filter(t => odDays(t) > 0).length; }
  catch (e) { return 0; }
}

/* نوارِ بالای داشبورد. یک خطِ کوتاه با یک دکمه، نه یک هشدارِ
   تمام‌صفحه: چیزی که هر روز باز می‌شود نباید هر روز راه را ببندد. */
function renderOverdueBar() {
  const el = document.getElementById("odBar");
  if (!el) return;
  const n = odCount();
  el.hidden = !n;
  if (!n) return;
  el.innerHTML =
    '<span aria-hidden="true">⏰</span>' +
    '<span><b>' + faDigits(n) + ' کار</b> از مهلتشان گذشته و هنوز انجام نشده‌اند.</span>' +
    '<button type="button" class="od-go">دیدنشان</button>';
  if (!el.dataset.wired) {
    el.dataset.wired = "1";
    el.addEventListener("click", e => {
      if (!e.target.closest(".od-go")) return;
      const nav = document.querySelector('.navbtn[data-view="checklist"]');
      if (nav) nav.click();
    });
  }
}
