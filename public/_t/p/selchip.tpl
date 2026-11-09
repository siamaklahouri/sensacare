/* رنگِ چیپ‌های «وضعیت» و «اولویت» از روی مقدارشان می‌آید، و CSS
   مقدارِ یک select را نمی‌بیند — پس همان مقدار روی data- می‌نشیند.
   یک شنونده روی document، نه یکی به‌ازای هر ردیف: جدول‌ها از نو ساخته
   می‌شوند و شنوندهٔ ردیفی هر بار باید دوباره بسته می‌شد.
   شیوه‌نامه‌اش در selchipcss. */
document.addEventListener("change", function (e) {
  var el = e.target;
  if (!el || !el.classList) return;
  if (el.classList.contains("st-select")) el.setAttribute("data-st", el.value || "");
  if (el.classList.contains("pr-select")) el.setAttribute("data-pr", el.value || "");
});
