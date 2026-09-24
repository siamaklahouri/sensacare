let aiHistory = [];
let aiBusy = false;

function aiLoadHistory(){
  try{ const v = JSON.parse(localStorage.getItem(AI_KEY)); aiHistory = Array.isArray(v) ? v : []; }
  catch(e){ aiHistory = []; }
}
function aiSaveHistory(){
  /* فقط چهل پیامِ آخر می‌ماند، وگرنه حافظهٔ مرورگر بی‌خود پر می‌شود */
  try{ localStorage.setItem(AI_KEY, JSON.stringify(aiHistory.slice(-40))); }catch(e){}
}

/* متنِ جواب با textContent نمی‌رود چون می‌خواهیم **پررنگ** و `کد` را
   نشان بدهیم؛ پس اول کامل escape می‌شود و بعد فقط همین دو تا برمی‌گردند.
   این‌طوری هیچ HTMLی از جوابِ مدل اجرا نمی‌شود. */
function aiFormat(text){
  const safe = String(text)
    .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  return safe
    .replace(/`([^`\n]+)`/g, "<code>$1</code>")
    .replace(/\*\*([^*\n]+)\*\*/g, "<strong>$1</strong>");
}

function aiRenderLog(){
  const log = document.getElementById("aiLog");
  if(!log) return;
  if(!aiHistory.length){
    log.innerHTML = '<div class="ai-empty"><span class="big">🤖</span>' +
      'سلام! هر چه می‌خواهید بپرسید.<br>هم از کارتابل می‌دانم، هم سؤال‌های دیگرتان را جواب می‌دهم.</div>';
    return;
  }
  log.innerHTML = aiHistory.map(m =>
    '<div class="ai-msg ' + (m.role === "user" ? "me" : (m.error ? "err" : "bot")) + '">' +
    aiFormat(m.content) + '</div>').join("");
  log.scrollTop = log.scrollHeight;
}

function aiSetBusy(on){
  aiBusy = on;
  const b = document.getElementById("aiSend");
  const t = document.getElementById("aiInput");
  if(b){ b.disabled = on; b.textContent = on ? "…" : "بفرست"; }
  if(t) t.disabled = on;
}

async function aiAsk(text){
  const q = String(text || "").trim();
  if(!q || aiBusy) return;
  if(window.KARTABL_OFFLINE){
    aiHistory.push({ role:"assistant", content:"این نسخهٔ پشتیبان است و به سرور وصل نیست، پس دستیار کار نمی‌کند.", error:true });
    aiRenderLog(); return;
  }
  aiHistory.push({ role:"user", content:q });
  aiSaveHistory(); aiRenderLog(); aiSetBusy(true);

  const log = document.getElementById("aiLog");
  if(log){
    const wait = document.createElement("div");
    wait.className = "ai-msg bot"; wait.id = "aiWait"; wait.textContent = "در حال فکر کردن…";
    log.appendChild(wait); log.scrollTop = log.scrollHeight;
  }

  try{
    const r = await apiCall("/ai", { method:"POST", body: JSON.stringify({
      messages: aiHistory.filter(m => !m.error).slice(-12).map(m => ({ role:m.role, content:m.content })),
      today: (typeof getTodayJalaliStr === "function") ? getTodayJalaliStr() : ""
    }) });
    if(r.ok && r.data.reply) aiHistory.push({ role:"assistant", content:r.data.reply });
    else aiHistory.push({ role:"assistant", error:true,
      content: r.data.error || "دستیار جواب نداد. کمی بعد دوباره امتحان کنید." });
  }catch(e){
    aiHistory.push({ role:"assistant", error:true, content:"به سرور نرسیدم. اینترنت را بررسی کنید." });
  }
  aiSetBusy(false); aiSaveHistory(); aiRenderLog();
  const t = document.getElementById("aiInput");
  if(t){ try{ t.focus(); }catch(e){} }
}

function setupAssistant(){
  const input = document.getElementById("aiInput");
  const send  = document.getElementById("aiSend");
  const clear = document.getElementById("aiClear");
  const tips  = document.getElementById("aiTips");
  if(!input || !send) return;

  aiLoadHistory(); aiRenderLog();

  if(tips) AI_TIPS.forEach(q => {
    const b = document.createElement("button");
    b.type = "button"; b.className = "ai-tip"; b.textContent = q;
    b.addEventListener("click", ()=>{ input.value = q; aiAsk(q); input.value = ""; });
    tips.appendChild(b);
  });

  const fire = ()=>{ const v = input.value; input.value = ""; input.style.height = "auto"; aiAsk(v); };
  send.addEventListener("click", fire);
  input.addEventListener("keydown", e => {
    if(e.key === "Enter" && !e.shiftKey){ e.preventDefault(); fire(); }
  });
  /* نوارِ نوشتن با متن بلند بزرگ می‌شود، تا سقفی که در CSS هست */
  input.addEventListener("input", ()=>{
    input.style.height = "auto";
    input.style.height = Math.min(input.scrollHeight, 150) + "px";
  });

  if(clear) clear.addEventListener("click", ()=>{
    if(!aiHistory.length || !confirm("کلِ این گفتگو پاک شود؟")) return;
    aiHistory = []; aiSaveHistory(); aiRenderLog();
  });

  const nav = document.querySelector('.navbtn[data-view="assistant"]');
  if(nav) nav.addEventListener("click", ()=> setTimeout(()=>{ try{ input.focus(); }catch(e){} }, 60));
}

/* ---------- موتور دستیار ----------
   کلید روی سرور می‌ماند و هیچ‌وقت به این صفحه برنمی‌گردد؛ فقط چند حرف
   اولش می‌آید تا معلوم باشد کدام کلید نشسته. */
async function refreshAiSettings(){
  const el = document.getElementById("aiProvider");
  if(!el || window.KARTABL_OFFLINE || !signedIn) return;
  try{
    const r = await apiCall("/ai/settings");
    if(!r.ok) return;
    el.textContent = r.data.provider === "claude"
      ? "الان با کلاد کار می‌کند — " + r.data.model + (r.data.hint ? " (کلید " + r.data.hint + ")" : "")
      : "الان با هوش مصنوعیِ رایگانِ کلادفلر کار می‌کند.";
    el.className = "set-state" + (r.data.provider === "claude" ? " ok" : "");
  }catch(e){ /* اینترنت نبود — همان «در حال بررسی» می‌ماند */ }
}

function showLastLogin(){
  const el = document.getElementById("lastLoginRow");
  if(!el || !window.__lastLogin) return;
  el.textContent = "آخرین ورود به این کارتابل: " + faDateTime(window.__lastLogin);
}

function setupAiSettings(){
  const save  = document.getElementById("aiKeySaveBtn");
  const clear = document.getElementById("aiKeyClearBtn");
  const input = document.getElementById("aiKey");
  if(!save || !input) return;

  const send = async (key, btn, busyText)=>{
    btn.disabled = true; setState("aiKeyState", busyText);
    try{
      const r = await apiCall("/ai/settings", { method:"POST", body: JSON.stringify({ key }) });
      if(r.ok){
        input.value = "";
        setState("aiKeyState", key ? "✓ کلید ثبت شد — دستیار حالا با کلاد کار می‌کند" : "✓ برگشت به رایگان", "ok");
        refreshAiSettings();
      }else setState("aiKeyState", r.data.error || "نشد.", "err");
    }catch(e){ setState("aiKeyState", "به سرور نرسیدم.", "err"); }
    btn.disabled = false;
  };

  save.addEventListener("click", ()=>{
    const k = input.value.trim();
    if(!k){ setState("aiKeyState", "کلید را بنویسید.", "err"); return; }
    send(k, save, "در حال امتحان کردن کلید…");
  });
  if(clear) clear.addEventListener("click", ()=>{
    if(!confirm("دستیار برگردد به هوش مصنوعیِ رایگانِ کلادفلر؟")) return;
    send("", clear, "در حال برداشتن کلید…");
  });

  refreshAiSettings();
}
