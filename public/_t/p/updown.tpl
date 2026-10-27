/* ==================== برو بالا / برو پایین ====================
   جدول‌های کارتابل بلندند: چک‌لیستِ ماه، سرورها، اقساط. رسیدن به ته
   یک جدولِ چهل‌ردیفی با چرخِ موس چند ثانیه طول می‌کشد و برگشتن هم
   همان‌قدر. Home و End این کار را می‌کنند، ولی روی گوشی صفحه‌کلیدی
   نیست و روی لپ‌تاپ هم کسی که دستش روی ترک‌پد است آن‌ها را نمی‌زند.

   پس یک دکمه، نه دوتا: همان چیزی که آدم می‌خواهد یکی بیشتر نیست —
   «آن سرِ دیگر». دکمه خودش می‌داند کدام سر نزدیک‌تر است:

   یک) تا نیمهٔ بالاییِ صفحه، پیکان به پایین است و زدنش می‌برد ته
   صفحه. از نیمه که گذشتی، برمی‌گردد به بالا و زدنش می‌برد سرِ صفحه.
   این‌طور هر زدنی یک پرشِ کامل است و هیچ‌وقت دکمه‌ای نمی‌مانَد که
   کاری نکند.

   دو) صفحه‌ای که اسکرول ندارد دکمه هم ندارد. ارتفاعِ صفحه این‌جا
   مدام عوض می‌شود — هر تبِ کارتابل یک «view» است و با هم اندازه
   نیستند — پس یک بار اندازه گرفتن سرِ بارِ صفحه کافی نیست.

   ResizeObserver هم کافی نیست و امتحان شد: قابِ خودِ body در این
   چیدمان همیشه قدِ پنجره است و محتوا از آن می‌زند بیرون، پس عوض
   شدنِ تب هیچ تغییری در اندازهٔ body نمی‌دهد و ناظر هیچ‌وقت صدا
   نمی‌خورد — در حالی که scrollHeight از ۲۰۷۹ به ۹۵۰ رفته. پس خودِ
   scrollHeight پاییده می‌شود: با هر کلیک (تبِ تازه، جدولی که باز
   می‌شود) فوری، و هر شش‌دهمِ ثانیه یک بار برای بقیه — داده‌ای که از
   سرور می‌رسد رویدادِ خودش را ندارد.

   سه) وسطِ پرش جهتِ پیکان عوض نمی‌شود. بی این، وقتی از نیمهٔ صفحه
   رد می‌شد پیکان همان‌جا می‌چرخید و دکمه وسطِ حرکت به نظر می‌رسید
   دارد تصمیمش را عوض می‌کند. */
const UPDOWN = (function(){
  "use strict";

  /* کمتر از این فاصله، «پریدن» معنی ندارد: یک چرخِ موس همان کار را
     می‌کند و دکمه فقط گوشهٔ صفحه را شلوغ کرده. */
  const MIN = 220;

  let btn = null, isUp = false, waiting = false, locked = false, unlockT = 0;

  const maxY = () => Math.max(0,
    (document.documentElement.scrollHeight || 0) - (window.innerHeight || 0));

  function build(){
    btn = document.createElement("button");
    btn.type = "button";
    btn.className = "updown off";
    /* پیکانی که به یک خط می‌رسد، نه پیکانِ تنها: «تا آخر» را می‌گوید،
       نه «یک صفحه پایین‌تر». چرخشِ ۱۸۰ درجه همان را برای بالا می‌گوید. */
    btn.innerHTML =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" ' +
      'stroke-width="2" stroke-linecap="round" stroke-linejoin="round" ' +
      'aria-hidden="true" focusable="false">' +
        '<path d="M12 4v11"/><path d="M7.5 10.5 12 15l4.5-4.5"/>' +
        '<path d="M6 19.5h12"/>' +
      '</svg>';
    btn.addEventListener("click", go);
    document.body.appendChild(btn);
    /* سمتِ راستِ صفحه در کارتابل مالِ ستونِ بخش‌هاست و دکمه نباید روی
       تهِ آن بیفتد. این‌جا فقط خبر می‌دهیم که ستون هست؛ اینکه چقدر
       تو بیاید و از چه عرضی به بعد، کارِ CSS است. */
    if(document.querySelector(".sidebar")) document.body.classList.add("ud-side");
    face(false);
  }

  function face(up){
    isUp = !!up;
    btn.classList.toggle("up", isUp);
    const t = isUp ? "به بالای صفحه" : "به پایین صفحه";
    btn.title = t;
    btn.setAttribute("aria-label", t);
  }

  function sync(){
    waiting = false;
    if(!btn) return;
    const max = maxY();
    btn.classList.toggle("off", max < MIN);
    if(max < MIN || locked) return;
    face((window.scrollY || window.pageYOffset || 0) > max / 2);
  }

  /* اسکرول در هر ثانیه ده‌ها بار خبر می‌دهد؛ یک بار در هر فریم کافی
     است و بیشترش فقط کار اضافه است. */
  function soon(){
    if(waiting) return;
    waiting = true;
    requestAnimationFrame(sync);
  }

  function go(){
    const to = isUp ? 0 : (document.documentElement.scrollHeight || 0);
    /* جهت را همان لحظه برمی‌گردانیم و تا نشستنِ صفحه قفلش می‌کنیم */
    face(!isUp);
    locked = true;
    clearTimeout(unlockT);
    unlockT = setTimeout(()=>{ locked = false; sync(); }, 900);
    const soft = !window.matchMedia ||
      !window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    try{ window.scrollTo({ top: to, behavior: soft ? "smooth" : "auto" }); }
    catch(e){ window.scrollTo(0, to); }
  }

  /* ارتفاع که عوض شد، یک بار بسنج. مقایسه برای این است که تایمر
     بی‌کار، کارِ بی‌خود نکند. */
  let lastH = -1;
  function watch(){
    const h = document.documentElement.scrollHeight || 0;
    if(h === lastH) return;
    lastH = h;
    soon();
  }

  function init(){
    if(btn || !document.body) return;
    build();
    window.addEventListener("scroll", soon, { passive:true });
    window.addEventListener("resize", soon);
    /* مرحلهٔ گرفتن، نه حباب: شنونده پیش از خودِ کارِ دکمه اجرا می‌شود
       و قابِ بعدی را می‌بیند، یعنی تبِ تازه را. */
    document.addEventListener("click", soon, true);
    setInterval(watch, 600);
    lastH = document.documentElement.scrollHeight || 0;
    sync();
  }

  if(document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", init);
  else init();

  return { init, sync };
})();
