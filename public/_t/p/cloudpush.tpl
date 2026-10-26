  async function push(force, confirmed){
    if(window.KARTABL_OFFLINE) return;
    /* وقتی سرور علامت خرابی داده، هیچ چیزی بالا نمی‌رود — حتی با force */
    if(blocked){ setHint("ذخیره متوقف است"); return; }
    if(!online && !force) return;
    /* نسخهٔ سرور را نشناخته‌ایم، پس نمی‌دانیم روی چه چیزی می‌نویسیم */
    if(rev === null && !confirmed){ setHint("هنوز با سرور هماهنگ نشده‌ایم"); return; }
    if(inFlight){ again = true; return; }
    inFlight = true;
    setHint("در حال ذخیره روی سرور...");
    try{
      /* بايگانىِ ماهِ جارى از روى نسخهٔ در دستِ كار تازه شود،
         وگرنه چيزى كه بالا مى‌رود يك نسخهٔ كهنه هم با خود مى‌برد. */
      try{ syncWorkingMonth(); }catch(e){}
      const payload = { state: state, db: dbSnapshot() };
      if(rev !== null) payload.baseRev = rev;
      if(confirmed) payload.force = true;
      const r = await apiCall("/state", { method: "PUT", body: JSON.stringify(payload) });
      if(r.status === 409){
        inFlight = false;
        if(r.data.broken){
          blocked = true;
          setHint("ذخیره متوقف شد");
          setCloudStatus("⚠️ دادهٔ روی سرور خوانا نیست. چیزی را عوض نکنید و خبر بدهید.");
          return;
        }
        if(r.data.loss){ showLoss(r.data.loss); setHint("ذخیره نشد — منتظر تأیید"); return; }
        /* پیش از پرسیدن، ببینیم اصلاً برخوردی هست یا نه: اگر این
           دستگاه ماهِ دیگری را دست زده باشد، هر دو با هم می‌نشینند و
           کاربر چیزی نمی‌بیند. شرحش در پارهٔ mergemonths. */
        if(await tryMerge()) return;
        showConflict(); setHint("ذخیره نشد — تداخل نسخه"); return;
      }
      if(r.status === 401){ inFlight = false; online = false; setHint("وارد نشده‌اید"); return; }
      if(!r.ok) throw new Error(r.data.error || "خطای سرور");
      rev = r.data.rev;
      /* امضای همین چیزی که الان بالا رفت، پایهٔ تشخیصِ دفعهٔ بعد است:
         از رویش معلوم می‌شود کدام ماه را *این* دستگاه عوض کرده. */
      try{ base = Merge.snapshot(state); }catch(e){ base = null; }
      online = true;
      setHint("✓ ذخیره شد");
      /* حجمِ داده که از آستانه گذشت، یک بار گفته می‌شود — نه هر ذخیره.
         جلوی کار گرفته نمی‌شود؛ فقط آدم باید بداند که دارد بزرگ
         می‌شود و ماه‌های خیلی قدیمی را می‌تواند بیرون ببرد (پشتیبان
         بگیرد و پاکشان کند). */
      if(r.data.big && !window.__bigWarned){
        window.__bigWarned = true;
        var mb = Math.round(r.data.big / 1048576 * 10) / 10;
        setCloudStatus("⚠️ دادهٔ این کارتابل حدود " +
          (typeof fa === "function" ? fa(String(mb)) : mb) +
          " مگابایت شده. هنوز کار می‌کند، ولی هر ذخیره همین حجم را بالا می‌برد؛" +
          " اگر کند شد، از «نسخه‌های پیشین» یک پشتیبان بگیرید و ماه‌های خیلی قدیمی را پاک کنید.");
      }
      setCloudStatus("آخرین همگام‌سازی: " + new Date(r.data.updated).toLocaleString("fa-IR"));
    }catch(e){
      /* نسخهٔ محلی از قبل نوشته شده، پس چیزی گم نمی‌شود */
      setHint("✓ ذخیره شد (فقط روی این مرورگر)");
      setCloudStatus("آفلاین — تغییرها با وصل شدن بالا می‌روند.");
    }
    inFlight = false;
    if(again){ again = false; schedule(); }
  }

  /* نسخهٔ سرور را می‌گیرد و اگر ماه‌های دو طرف جدا باشند، هر دو را
     با هم می‌نویسد. true یعنی حل شد و نوارِ تداخل لازم نیست. */
  async function tryMerge(){
    if(typeof Merge === "undefined" || !base) return false;
    let srv;
    try{
      const g = await apiCall("/state");
      if(!g.ok || !g.data || !g.data.state) return false;
      srv = g.data;
    }catch(e){ return false; }

    let p;
    try{ p = Merge.plan(base, state, srv.state); }catch(e){ return false; }
    if(!p.ok){
      /* برخوردِ واقعی. دستِ‌کم بگوییم سرِ چه چیزی. */
      pendingClash = p.names;
      return false;
    }
    if(!p.mine.length && !p.theirs.length) return false;

    let merged;
    try{ merged = Merge.apply(state, srv.state, p); }catch(e){ return false; }

    const w = await apiCall("/state", { method: "PUT", body: JSON.stringify({
      state: merged, db: dbSnapshot(), baseRev: srv.rev }) });
    if(w.status !== 200 || !w.ok) return false;

    /* روی همین صفحه هم بنشیند، وگرنه کاربر کارِ آن یکی دستگاه را
       نمی‌بیند تا وقتی صفحه را تازه کند. */
    try{
      state = Object.assign(deepClone(DEFAULT_STATE), merged);
      if(typeof ensureMonthsMigration === "function") ensureMonthsMigration();
      if(typeof switchToMonth === "function" && state.currentMonthKey)
        switchToMonth(state.currentMonthKey);
      else if(typeof renderAll === "function") renderAll();
      try{ localStorage.setItem(STORE_KEY, JSON.stringify(state)); }catch(e){}
    }catch(e){}

    rev = w.data.rev;
    base = Merge.snapshot(state);
    online = true;
    setHint("✓ ذخیره شد");
    setCloudStatus(p.theirs.length
      ? "تغییرِ دستگاه دیگر هم آمد (" + p.theirs.map(Merge.label).join("، ") + ") و هر دو با هم ذخیره شدند."
      : "آخرین همگام‌سازی: " + new Date(w.data.updated).toLocaleString("fa-IR"));
    return true;
  }

  function schedule(){
    clearTimeout(timer);
    timer = setTimeout(()=> push(false), 900);
  }

  /* برای آزمون و برای وقتی که باید دید چرا ادغام نشد. چیزی از
     دادهٔ کاربر بیرون نمی‌دهد — فقط شمارهٔ نسخه و امضاها. */
  function debug(){ return { rev: rev, base: base, online: online, blocked: blocked }; }

  return { pull, push: schedule, pushNow: push, isOnline: ()=> online, debug: debug };
})();

/* ---------- بخش تنظیمات ----------
   رمز ورود و ربات پشتیبان، هر دو از داخل خودِ کارتابل. هیچ‌کدام از این‌ها
   در فایل صفحه ننشسته‌اند؛ همه روی سرور تنظیم می‌شوند. */

function setState(id, text, kind){
  const el = document.getElementById(id);
  if(!el) return;
  el.textContent = text;
  el.className = "set-state" + (kind ? " " + kind : "");
}

function faTime(ms){
  try{ return new Date(ms).toLocaleString("fa-IR"); }catch(e){ return ""; }
}

async function refreshBackupSettings(){
  /* روی نسخهٔ پشتیبان یا بدون اینترنت، این درخواست می‌افتد. بدون این
     try، همان افتادن یک unhandled rejection می‌شد. */
  if(window.KARTABL_OFFLINE || !signedIn) return;
  let r;
  try{ r = await apiCall("/backup/settings"); }
  catch(e){ setState("botState", "به سرور نرسیدم.", "err"); return; }
  if(!r.ok) return;
  const d = r.data;
  setState("botState", d.hasToken
    ? ("ربات ثبت شده" + (d.botName ? ": @" + d.botName : ""))
    : "هنوز توکنی ثبت نشده.", d.hasToken ? "ok" : "");
  setState("connectState", d.chat ? "وصل است (گفتگوی " + d.chat + ")" : "هنوز وصل نشده.",
    d.chat ? "ok" : "");
  if(d.last){
    setState("lastBackup", d.last.ok
      ? "آخرین پشتیبان: " + faTime(d.last.at) + " — " + Math.round((d.last.size||0)/1024) + " کیلوبایت"
      : "آخرین تلاش ناموفق بود (" + faTime(d.last.at) + "): " + (d.last.error||""),
      d.last.ok ? "ok" : "err");
  } else {
    setState("lastBackup", "هنوز پشتیبانی فرستاده نشده.");
  }
}

/* ---------- نسخه‌های پیشین ----------
   سرور از هر نوشتن عکس نگه می‌دارد، ولی تا امروز راهی برای دیدنشان در
   خودِ کارتابل نبود و برگرداندن فقط از راهِ دستور ممکن بود. */
function histFa(ms){
  try{ return new Intl.DateTimeFormat("fa-IR",{ dateStyle:"short", timeStyle:"short" }).format(new Date(ms)); }
  catch(e){ return String(ms); }
}
function histSum(s){
  if(!s) return "—";
  const parts = Object.keys(s).map(k=> escapeHtml(k) + " " + toPersianDigits(s[k]));
  return parts.length ? parts.join(" · ") : "خالی";
}
async function loadHistory(){
  const box = document.getElementById("histList");
  const st  = document.getElementById("histState");
  if(!box) return;
  st.textContent = "در حال خواندن…";
  const r = await apiCall("/state/history");
  if(!r.ok){ st.textContent = "نشد: " + ((r.data&&r.data.error)||"خطا"); return; }
  const items = (r.data.items||[]);
  st.textContent = items.length ? toPersianDigits(items.length) + " نسخه" : "هنوز نسخه‌ای ثبت نشده.";
  box.innerHTML = items.map(it=>
    '<div class="hist-row">' +
      '<span class="hw">' + (it.which === "db" ? "دیتابیس" : "کارها و ماه‌ها") + '</span>' +
      '<span class="ht">' + escapeHtml(histFa(it.at)) + '</span>' +
      '<span class="hs">' + histSum(it.sum) + '</span>' +
      /* برگرداندنِ یک ماه: آدم معمولاً یک ماه را خراب می‌کند نه یک سال
         را، و تا امروز برای همان یک ماه مجبور بود کلِ کارِ بعدش را هم
         قربانی کند. */
      ((it.months && it.months.length)
        ? '<select class="hm" data-hmonth="' + it.id + '">' +
            '<option value="">همهٔ کارتابل</option>' +
            it.months.map(function(k){
              return '<option value="' + escapeHtml(k) + '">فقط ' +
                escapeHtml(toPersianDigits(String(k).split("|").reverse().join(" "))) +
                '</option>'; }).join("") +
          '</select>'
        : "") +
      '<button type="button" class="btn btn-ghost btn-sm" data-hist="' + it.id + '">برگردان</button>' +
    '</div>').join("");
  box.querySelectorAll("[data-hist]").forEach(btn=>{
    btn.addEventListener("click", async ()=>{
      const id = Number(btn.getAttribute("data-hist"));
      const sel = box.querySelector('[data-hmonth="' + id + '"]');
      const month = sel ? sel.value : "";
      const what = month
        ? "فقط ماهِ «" + toPersianDigits(String(month).split("|").reverse().join(" ")) + "»"
        : "کلِ کارتابل";
      if(!confirm(what + " از این نسخه برگردد؟\n\nاز وضعیت فعلی هم عکس گرفته می‌شود، پس اگر پشیمان شدید برمی‌گردد.")) return;
      btn.disabled = true;
      const rr = await apiCall("/state/restore", { method:"POST",
        body: JSON.stringify({ id: id, month: month }) });
      if(!rr.ok){ btn.disabled = false; st.textContent = "نشد: " + ((rr.data&&rr.data.error)||"خطا"); return; }
      st.textContent = "✓ برگشت. صفحه دوباره باز می‌شود…";
      setTimeout(()=> location.reload(), 900);
    });
  });
}

function setupSettings(){
  if(window.KARTABL_OFFLINE){
    /* در نسخهٔ پشتیبان نه رمزی هست که عوض شود نه رباتی که تنظیم شود */
    const nav = document.querySelector('.navbtn[data-view="settings"]');
    if(nav) nav.style.display = "none";
    return;
  }
  const histBtn = document.getElementById("histBtn");
  if(histBtn) histBtn.addEventListener("click", loadHistory);

  /* --- عوض کردن رمز --- */
  const form = document.getElementById("passForm");
  if(form) form.addEventListener("submit", async (e)=>{
    e.preventDefault();
    const cur = document.getElementById("passCurrent").value;
    const next = document.getElementById("passNext").value;
    const rep = document.getElementById("passRepeat").value;
    if(next !== rep){ setState("passState", "دو رمز تازه یکی نیستند.", "err"); return; }
    if(next.length < 8){ setState("passState", "رمز تازه باید دست‌کم ۸ کاراکتر باشد.", "err"); return; }
    const btn = document.getElementById("passBtn");
    btn.disabled = true; setState("passState", "در حال ثبت…");
    const r = await apiCall("/password", { method:"POST", body: JSON.stringify({ current: cur, next: next }) });
    btn.disabled = false;
    if(r.ok){
      form.reset();
      setState("passState", "✓ رمز عوض شد. دستگاه‌های دیگر باید دوباره وارد شوند.", "ok");
    } else {
      setState("passState", r.data.error || "ثبت نشد.", "err");
    }
  });

  /* --- ثبت توکن ربات --- */
  const saveBtn = document.getElementById("botSaveBtn");
  if(saveBtn) saveBtn.addEventListener("click", async ()=>{
    const token = document.getElementById("botToken").value.trim();
    if(!token){ setState("botState", "توکن را بنویسید.", "err"); return; }
    saveBtn.disabled = true; setState("botState", "در حال بررسی توکن…");
    const r = await apiCall("/backup/settings", { method:"POST", body: JSON.stringify({ token }) });
    saveBtn.disabled = false;
    if(r.ok){
      document.getElementById("botToken").value = "";
      setState("botState", "✓ ثبت شد: @" + r.data.botName, "ok");
    } else {
      setState("botState", r.data.error || "ثبت نشد.", "err");
    }
  });

  /* --- پیدا کردن گفتگو --- */
  const connectBtn = document.getElementById("botConnectBtn");
  if(connectBtn) connectBtn.addEventListener("click", async ()=>{
    connectBtn.disabled = true; setState("connectState", "دنبال پیام شما در ربات می‌گردم…");
    const r = await apiCall("/backup/connect", { method:"POST", body: "{}" });
    connectBtn.disabled = false;
    if(r.ok) setState("connectState", "✓ وصل شد به «" + (r.data.name||r.data.chat) + "»", "ok");
    else setState("connectState", r.data.error || "وصل نشد.", "err");
  });

  /* --- پشتیبان دستی --- */
  const nowBtn = document.getElementById("backupNowBtn");
  if(nowBtn) nowBtn.addEventListener("click", async ()=>{
    nowBtn.disabled = true; setState("backupState", "در حال ساختن و فرستادن پشتیبان…");
    const r = await apiCall("/backup/now", { method:"POST", body: "{}" });
    nowBtn.disabled = false;
    if(r.ok){
      setState("backupState", "✓ فرستاده شد — " + Math.round(r.data.size/1024) + " کیلوبایت", "ok");
      refreshBackupSettings();
    } else {
      setState("backupState", r.data.error || "فرستاده نشد.", "err");
    }
  });

  const dlBtn = document.getElementById("backupDownloadBtn");
  if(dlBtn) dlBtn.addEventListener("click", ()=>{
    setState("backupState", "در حال آماده کردن فایل…");
    location.href = KARTABL_API + "/backup/download";
    setTimeout(()=> setState("backupState", ""), 3000);
  });

  refreshBackupSettings();
}