/* بازشوی ماه‌ها — مشترکِ هر دو کارتابل */
function setupMeta(){
  const btn = document.getElementById("monthBtn");
  const pop = document.getElementById("monthPop");
  if(!btn || !pop) return;
  const list = document.getElementById("monthPopList");
  const nameEl = document.getElementById("newMonthName");
  const yearEl = document.getElementById("newMonthYear");
  const okEl = document.getElementById("confirmNewMonthBtn");
  const noteEl = document.getElementById("monthPopNote");
  const xEl = document.getElementById("monthPopX");

  const note = t=>{ if(noteEl) noteEl.textContent = t||""; };
  const open = ()=>{
    MP_EDIT = null;
    renderMonthSelector();
    pop.hidden = false; btn.classList.add("on"); note("");
    if(nameEl) nameEl.value = "";
    /* سالِ ماهِ جاری از قبل پُر است، چون ماهِ تازه تقریباً همیشه در
       همان سال است و دوباره تایپ کردنش کارِ اضافه است. */
    if(yearEl) yearEl.value = (state.meta && state.meta.year) || "";
  };
  const close = ()=>{ pop.hidden = true; btn.classList.remove("on"); MP_EDIT = null; note(""); };

  btn.addEventListener("click", ()=>{ if(pop.hidden) open(); else close(); });
  if(xEl) xEl.addEventListener("click", close);
  /* زدن روی زمینهٔ تاریک یعنی «بستن» — ولی فقط خودِ زمینه، نه کارت */
  pop.addEventListener("click", e=>{ if(e.target === pop) close(); });
  document.addEventListener("keydown", e=>{ if(e.key === "Escape" && !pop.hidden) close(); });

  const commitRename = (key, row)=>{
    const n = row.querySelector(".me-n"), y = row.querySelector(".me-y");
    if(!n || !y) return;
    MP_EDIT = null;
    if(!renameMonth(key, n.value, y.value)) MP_EDIT = key;
    renderMonthSelector();
  };

  if(list){
    list.addEventListener("click", e=>{
      const go = e.target.closest("[data-go]");
      if(go){
        const parts = go.getAttribute("data-go").split("|");
        switchToMonth(parts[1], parts[0]);
        close();
        return;
      }
      const ren = e.target.closest("[data-ren]");
      if(ren){
        MP_EDIT = ren.getAttribute("data-ren");
        renderMonthSelector();
        const el = list.querySelector(".me-n");
        if(el){ el.focus(); el.select(); }
        return;
      }
      if(e.target.closest("[data-cancel]")){ MP_EDIT = null; renderMonthSelector(); return; }
      const ok = e.target.closest("[data-ok]");
      if(ok) commitRename(ok.getAttribute("data-ok"), ok.closest(".mrow"));
    });
    /* Enter ثبت می‌کند و Escape بی‌خیال می‌شود — بدون اینکه Escape تا
       خودِ پنجره بالا برود و ببنددش. */
    list.addEventListener("keydown", e=>{
      const row = e.target.closest(".mrow");
      if(!row || !MP_EDIT) return;
      if(e.key === "Enter"){ e.preventDefault(); commitRename(MP_EDIT, row); }
      else if(e.key === "Escape"){ e.stopPropagation(); MP_EDIT = null; renderMonthSelector(); }
    });
  }

  if(okEl) okEl.addEventListener("click", ()=>{
    const name = (nameEl.value||"").trim(), year = (yearEl.value||"").trim();
    if(!name || !year){ note("نام ماه و سال را کامل وارد کنید."); return; }
    /* ماهی که از قبل هست دوباره ساخته نمی‌شود؛ فقط می‌رویم سراغش */
    const carryEl = document.getElementById("newMonthCarry");
    switchToMonth(name, year, { carryTasks: !carryEl || carryEl.checked });
    close();
  });
  [nameEl, yearEl].forEach(el=> el && el.addEventListener("keydown", e=>{
    if(e.key === "Enter"){ e.preventDefault(); okEl.click(); }
  }));
}

