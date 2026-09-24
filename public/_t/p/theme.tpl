
function applyTheme(mode){
  const dark = mode === "dark";
  document.documentElement.setAttribute("data-theme", dark ? "dark" : "light");
  const btn = document.getElementById("themeBtn");
  if(btn){
    btn.textContent = dark ? "\u2600\ufe0f" : "\ud83c\udf19";
    btn.title = dark ? "تم روز" : "تم شب";
    btn.setAttribute("aria-label", btn.title);
  }
  /* نمودارها رنگ متن و خطوطشان را موقع ساخته شدن می‌گیرند، پس باید
     دوباره کشیده شوند وگرنه در شب سیاه روی سیاه می‌مانند. */
  try{
    if(typeof Chart !== "undefined"){
      Chart.defaults.color = dark ? "#AFBDCB" : "#3E5164";
      Chart.defaults.borderColor = dark ? "rgba(255,255,255,.10)" : "rgba(11,37,69,.10)";
    }
  }catch(e){}
  try{ localStorage.setItem(THEME_KEY, mode); }catch(e){}
}

function setupTheme(){
  let saved = null;
  try{ saved = localStorage.getItem(THEME_KEY); }catch(e){}
  applyTheme(saved === "dark" ? "dark" : "light");
  const btn = document.getElementById("themeBtn");
  if(btn) btn.addEventListener("click", ()=>{
    applyTheme(currentTheme() === "dark" ? "light" : "dark");
    try{ redrawAfterTheme(); }catch(e){}
  });
}
