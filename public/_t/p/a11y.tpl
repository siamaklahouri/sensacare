/* ==================== دسترس‌پذیریِ پنجره‌ها ====================
   پنجره‌های این کارتابل — کشوی بخش‌ها، جست‌وجو، خبرها، پیوست، ماه‌ها،
   تقویم — همه با موش درست کار می‌کردند و با کیبورد نه: Tab از داخلِ
   پنجره بیرون می‌رفت و پشتِ پرده روی دکمه‌های صفحه می‌چرخید. کسی که
   با صفحه‌خوان یا فقط با کیبورد کار می‌کند، عملاً داخلِ پنجره گم
   می‌شد.

   این یک لایهٔ مشترک است، نه وصله‌ای روی هر پنجره:

   یک) Tab داخلِ پنجره می‌چرخد و بیرون نمی‌رود.
   دو) پنجره که باز شد، فوکوس می‌رود داخلش؛ که بسته شد، برمی‌گردد
       همان‌جایی که بود — وگرنه آدم بعد از بستن، سرِ اولِ صفحه پیدا
       می‌شود.
   سه) نقشِ dialog و aria-modal سرِ جایشان می‌نشیند تا صفحه‌خوان
       بفهمد چیزی باز شده.

   هیچ پنجره‌ای این‌جا نام برده نشده مگر با همان کلاسی که از قبل
   داشته: اضافه شدنِ پنجرهٔ تازه یک خط در همین فهرست است. */
(function () {
  "use strict";

  var SEL = [
    ".appsheet:not([hidden])",
    ".findbox:not([hidden])",
    ".nwbox:not([hidden])",
    ".at-light:not([hidden])",
    ".mpop:not([hidden])",
    ".dp-pop:not([hidden])",
    ".day-picker-popup.open",
    ".attachbox:not([hidden])",
    ".rowsheet:not([hidden])"
  ].join(", ");

  var FOCUS = 'a[href], button:not([disabled]), input:not([disabled]):not([type=hidden]), ' +
              'select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])';

  var opener = null;      /* کجا بودیم، پیش از باز شدن */
  var last = null;        /* کدام پنجره باز بود */

  function openDialogs() {
    return [].slice.call(document.querySelectorAll(SEL))
      .filter(function (el) { return el.offsetParent !== null || el.getClientRects().length; });
  }
  function topDialog() {
    var all = openDialogs();
    return all.length ? all[all.length - 1] : null;
  }
  function inside(el) {
    var f = [].slice.call(el.querySelectorAll(FOCUS));
    return f.filter(function (x) {
      return !x.hasAttribute("hidden") && x.offsetParent !== null &&
             getComputedStyle(x).visibility !== "hidden";
    });
  }

  /* Tab داخلِ پنجره می‌چرخد. «capture» لازم است: بعضی پنجره‌ها خودشان
     روی keydown نشسته‌اند و اگر بعد از آن‌ها بیاییم، دیر است. */
  document.addEventListener("keydown", function (e) {
    if (e.key !== "Tab") return;
    var d = topDialog();
    if (!d) return;
    var f = inside(d);
    if (!f.length) return;
    var first = f[0], lastEl = f[f.length - 1];
    /* فوکوس بیرون از پنجره بود؟ برگردانش داخل. */
    if (!d.contains(document.activeElement)) {
      e.preventDefault();
      (e.shiftKey ? lastEl : first).focus();
      return;
    }
    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault(); lastEl.focus();
    } else if (!e.shiftKey && document.activeElement === lastEl) {
      e.preventDefault(); first.focus();
    }
  }, true);

  function watch() {
    var d = topDialog();
    if (d === last) return;
    if (d) {
      /* تازه باز شد */
      if (!last) opener = document.activeElement;
      if (!d.getAttribute("role")) d.setAttribute("role", "dialog");
      d.setAttribute("aria-modal", "true");
      var f = inside(d);
      /* کادرِ متن یا جست‌وجو اولویت دارد — همان چیزی که آدم آمده
         بنویسد. وگرنه اولین چیزِ فوکوس‌پذیر. */
      var pref = d.querySelector("input:not([type=hidden]):not([disabled]), textarea");
      var go = pref || f[0];
      if (go && !d.contains(document.activeElement)) {
        try { go.focus({ preventScroll: true }); } catch (e2) { try { go.focus(); } catch (e3) { } }
      }
    } else if (last) {
      /* بسته شد — برگرد همان‌جا که بودی */
      last.removeAttribute("aria-modal");
      if (opener && document.contains(opener)) {
        try { opener.focus({ preventScroll: true }); } catch (e2) { }
      }
      opener = null;
    }
    last = d;
  }

  /* پنجره‌ها با hidden یا class باز و بسته می‌شوند، و بعضی‌شان همان
     لحظه ساخته می‌شوند. پس هم تغییرِ صفت را می‌پاییم هم اضافه شدنِ
     گره را — با یک مکثِ کوتاه تا صد تغییرِ پشتِ سرِ هم صد بار حساب
     نشود. */
  var t = null;
  var later = function () { clearTimeout(t); t = setTimeout(watch, 60); };
  try {
    new MutationObserver(later).observe(document.body, {
      attributes: true, attributeFilter: ["hidden", "class"],
      childList: true, subtree: true
    });
  } catch (e) { }
  document.addEventListener("click", later, true);
  document.addEventListener("keyup", later, true);

  window.A11Y = { top: topDialog, refresh: watch };
})();
