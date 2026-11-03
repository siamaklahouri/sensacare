/* ---------- «پایین‌تر هم چیزی هست» ----------
   نوارِ بخش‌ها وقتی در ارتفاع جا نشود اسکرول می‌شود — و می‌شد، ولی
   هیچ نشانه‌ای نداشت. روی لپ‌تاپِ ۱۳ اینچ (ارتفاعِ دیدِ ۸۲۰) چهار بخش
   زیرِ خط می‌مانَد و تنها سرنخش یک ردیفِ نصفه‌بریده است که بیشتر شبیهِ
   ایرادِ رسم است تا «بکش پایین». نوارِ اسکرول هم نازک است و هم‌رنگِ
   خطوط، پس تا موش رویش نرود دیده نمی‌شود.

   این یک محوشدگیِ نرم در همان لبه‌ای می‌گذارد که چیزی پشتش مانده —
   و فقط وقتی که واقعاً مانده باشد. با CSSِ تنها نمی‌شد: سرریز را
   باید اندازه گرفت. */
(function () {
  "use strict";
  var list = null;

  function sync() {
    if (!list) list = document.querySelector(".nav-list");
    if (!list) return;
    var over = list.scrollHeight - list.clientHeight;
    /* دو پیکسل چشم‌پوشی: گردکردنِ مرورگر گاهی یک پیکسل سرریزِ قلابی
       می‌سازد و آن وقت محوشدگی روی فهرستی می‌افتد که کامل دیده
       می‌شود. */
    if (over <= 2) {
      list.classList.remove("more-top", "more-bottom");
      return;
    }
    list.classList.toggle("more-top", list.scrollTop > 2);
    list.classList.toggle("more-bottom", list.scrollTop < over - 2);
  }

  function start() {
    list = document.querySelector(".nav-list");
    if (!list) return;
    sync();
    list.addEventListener("scroll", sync, { passive: true });
    addEventListener("resize", sync);
    /* بخش‌ها با تنظیماتِ کارتابل کم و زیاد می‌شوند و بعضی‌شان بعدِ
       اولین رسم اضافه می‌شوند (بخش‌های مشترک). پس خودِ فهرست هم
       تماشا می‌شود، نه فقط پنجره. */
    try { new ResizeObserver(sync).observe(list); } catch (e) { }
    try {
      new MutationObserver(sync).observe(list, { childList: true, subtree: false });
    } catch (e) { }
  }

  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", start);
  else start();
})();
