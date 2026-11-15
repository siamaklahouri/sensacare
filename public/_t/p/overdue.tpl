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

/* چند روز از یک تاریخِ کاملِ شمسی گذشته — سررسیدِ مالی تاریخ است،
   نه روزِ ماه، پس حسابش جداست. */
function odPastDate(txt) {
  try {
    if (!window.DatePick || !DatePick.parse) return 0;
    const d = DatePick.parse(txt);
    if (!d) return 0;
    const t = DatePick.today();
    const A = d.jy * 10000 + d.jm * 100 + d.jd;
    const B = t.jy * 10000 + t.jm * 100 + t.jd;
    if (A >= B) return 0;
    const ms = DatePick.toStamp(t.jy, t.jm, t.jd) - DatePick.toStamp(d.jy, d.jm, d.jd);
    return Math.max(1, Math.round(ms / 86400000));
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

/* ---------- نوارِ خبرِ بالای داشبورد ----------
   یک خطِ کوتاه برای هر خبر، نه یک هشدارِ تمام‌صفحه: چیزی که هر روز
   باز می‌شود نباید هر روز راه را ببندد.

   خطِ اولش همه‌جا یکی است (کارِ عقب‌افتاده). کارتابل می‌تواند
   خط‌های خودش را هم اضافه کند — کارتابلِ مالی سررسیدِ گذشته را
   این‌طور می‌گوید. */
let odMovedFrom = "";

function odLines() {
  const out = [];
  if (odMovedFrom)
    out.push({ icon: "📅", html: "ماهِ کاری خودش از <b>" + escapeHtml(odMovedFrom) +
               "</b> آمد روی <b>" + escapeHtml(monthLabelOf(state.currentMonthKey)) + "</b>." });
  const n = odCount();
  if (n) out.push({ icon: "⏰", html: "<b>" + faDigits(n) + " کار</b> از مهلتشان گذشته و هنوز انجام نشده‌اند.",
                    btn: "دیدنشان", view: "checklist" });
  try {
    if (typeof odMoreLines === "function") odMoreLines().forEach(x => out.push(x));
  } catch (e) { console.error('[خطوطِ نوار]', e); }
  try {
    const left = odLeftovers();
    if (left.list.length)
      out.push({ icon: "📦", html: "<b>" + faDigits(left.list.length) + " کارِ ناتمام</b> از " +
                 escapeHtml(left.from) + " مانده و به این ماه نیامده.",
                 btn: "آوردنشان", act: "carry" });
  } catch (e) { console.error('[کارِ جامانده]', e); }
  return out;
}

function renderOverdueBar() {
  const el = document.getElementById("odBar");
  if (!el) return;
  const lines = odLines();
  el.hidden = !lines.length;
  if (!lines.length) { el.innerHTML = ""; return; }
  el.innerHTML = lines.map(l =>
    '<div class="od-line">' +
      '<span aria-hidden="true">' + l.icon + '</span>' +
      '<span>' + l.html + '</span>' +
      (l.btn ? '<button type="button" class="od-go"' +
        (l.act ? ' data-od-act="' + l.act + '"' : ' data-od-view="' + l.view + '"') +
        '>' + l.btn + '</button>' : '') +
    '</div>').join("");
  if (!el.dataset.wired) {
    el.dataset.wired = "1";
    el.addEventListener("click", e => {
      const b = e.target.closest(".od-go");
      if (!b) return;
      const act = b.getAttribute("data-od-act");
      if (act === "carry") { carryLeftovers(); return; }
      const nav = document.querySelector('.navbtn[data-view="' + b.getAttribute("data-od-view") + '"]');
      if (nav) nav.click();
    });
  }
}

/* ---------- کارِ ناتمامی که از ماهِ قبل جا ماند ----------
   ماهِ تازه فقط کارهای تکرارشونده را می‌آورد. کارِ یک‌باره‌ای که
   انجام نشده، در بایگانیِ ماهِ قبل می‌ماند و هیچ‌کس خبردار نمی‌شود:
   تا دیروز روی صفحه «عقب‌افتاده» بود، و سرِ ماه بی‌صدا از جلوی چشم
   می‌رفت.

   خودکار نمی‌آید — بعضی‌شان دیگر موضوعیت ندارند و فهرستِ ماهِ تازه
   را شلوغ می‌کنند. فقط گفته می‌شود که هست، و با یک دکمه می‌آید. */
function odLeftovers() {
  const empty = { list: [], from: "", key: "" };
  try {
    if (!state || !state.monthsData || !state.currentMonthKey) return empty;
    const cur = monthIdxOf(state.currentMonthKey);
    if (!cur) return empty;
    let best = 0, bestKey = "";
    Object.keys(state.monthsData).forEach(k => {
      const i = monthIdxOf(k);
      if (i && i < cur && i > best) { best = i; bestKey = k; }
    });
    if (!bestKey) return empty;
    const have = {};
    (state.tasks || []).forEach(t => { if (t) have[taskKeyOf(t)] = 1; });
    const list = ((state.monthsData[bestKey] || {}).tasks || []).filter(t =>
      t && t.status !== "انجام شد" && !repeatEvery(t) && !have[taskKeyOf(t)]);
    return { list, from: monthLabelOf(bestKey), key: bestKey };
  } catch (e) { return empty; }
}

function carryLeftovers() {
  const left = odLeftovers();
  if (!left.list.length) return;
  left.list.forEach(t => {
    const c = Object.assign({}, t);
    c.since = state.currentMonthKey;
    delete c.reminder;
    delete c.doneDate;
    state.tasks.push(c);
  });
  if (typeof scheduleSave === "function") scheduleSave();
  if (typeof renderAll === "function") renderAll();
  renderOverdueBar();
  const nav = document.querySelector('.navbtn[data-view="checklist"]');
  if (nav) nav.click();
}

/* ---------- خودش می‌آید روی ماهِ جاری ----------
   ماهِ کاری تا امروز فقط دستی عوض می‌شد. اگر کاربر یادش می‌رفت،
   اولِ آذر هم هنوز در آبان کار می‌کرد و همهٔ کارهایش «عقب‌افتاده»
   دیده می‌شد.

   فقط به جلو: اگر کسی عمداً به ماهی در گذشته رفته باشد، کشیدنش به
   جلو یعنی جنگیدن با کاری که خودش کرده. و فقط یک بار برای هر ماه —
   «autoMonth» نگه می‌دارد که این ماه را گفته‌ایم، پس اگر بعدش خودش
   به عقب برگشت، دوباره بیرونش نمی‌کشیم. */
function odAutoMonth() {
  try {
    if (!state || !state.currentMonthKey) return "";
    const p = getTodayJalaliStr().split("/");
    const name = JALALI_MONTH_NAMES[parseInt(p[1], 10) - 1];
    const key = monthKeyOf(name, p[0]);
    if (key === state.currentMonthKey) return "";
    if (state.autoMonth === key) return "";
    const now = monthIdxOf(key), cur = monthIdxOf(state.currentMonthKey);
    if (!now || !cur || now <= cur) return "";
    const from = monthLabelOf(state.currentMonthKey);
    state.autoMonth = key;
    switchToMonth(name, p[0], {});
    odMovedFrom = from;
    if (typeof scheduleSave === "function") scheduleSave();
    return from;
  } catch (e) { console.error('[ماهِ خودکار]', e); return ""; }
}
