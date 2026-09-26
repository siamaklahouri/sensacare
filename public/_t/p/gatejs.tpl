
<script>
/* ---------- قفل ورودی کارتابل ----------
   تا وقتی داده فقط در حافظهٔ همین مرورگر بود، بررسی رمز در خودِ صفحه کافی
   بود: کسی که از قفل رد می‌شد هم چیزی جز کارتابل خالی نمی‌دید.

   حالا داده روی سرور است، پس رمز هم همان‌جا بررسی می‌شود. این صفحه فقط
   رمز را می‌فرستد؛ نه خودش رمز را دارد و نه حاصلش را، و تا کوکی نشست
   نگیرد هیچ مسیری داده نمی‌دهد. کوکی HttpOnly است، یعنی حتی کد همین
   صفحه هم نمی‌تواند بخواندش. */
const KARTABL_API = "{{API}}";

/* ---------- یک کارتابل، یک جا ----------
   هر ورود نشستِ قبلی را کنار می‌گذارد. این‌جا سمتِ مرورگرِ کنارگذاشته
   است: تا خبردار شود، سروری که جوابِ ۴۰۱ با نشانهٔ taken داده همه‌چیز
   را می‌خواباند.

   پرچم داخلِ خودِ apiCall بررسی می‌شود، نه در تک‌تکِ صدازننده‌ها: این
   صفحه چند تایمرِ مستقل دارد (ذخیره، بخش‌های مشترک، خبرها) و پیدا
   کردنِ همه‌شان کاری است که یک روز یکی‌اش جا می‌ماند. از این‌جا هیچ
   درخواستی رد نمی‌شود. */
let KARTABL_TAKEN = false;

async function apiCall(path, opts){
  if(KARTABL_TAKEN) return { ok:false, status:401, data:{ taken:true } };
  const res = await fetch(KARTABL_API + path, Object.assign({
    credentials: "same-origin",
    headers: { "Content-Type": "application/json" }
  }, opts || {}));
  let data = null;
  try{ data = await res.json(); }catch(e){ /* پاسخ بدون بدنه */ }
  if(res.status === 401 && data && data.taken) takenOver(data);
  return { ok: res.ok, status: res.status, data: data || {} };
}

function takenOver(d){
  if(KARTABL_TAKEN) return;
  KARTABL_TAKEN = true;
  stopBeat();
  const dev = (d && d.dev) ? String(d.dev) : "";
  const at  = (d && d.at)  ? Number(d.at)  : 0;
  const el = document.createElement("div");
  el.id = "takenScreen";
  el.setAttribute("style",
    "position:fixed;inset:0;z-index:999;display:flex;align-items:center;justify-content:center;" +
    "padding:22px;background:var(--paper,#EDF1F6);");
  el.innerHTML =
    '<div style="max-width:420px;width:100%;background:var(--white,#fff);' +
      'border:1px solid var(--card-border,#DCE3EA);border-radius:16px;padding:26px 24px;' +
      'box-shadow:0 18px 48px rgba(11,37,69,.18);text-align:center">' +
      '<div style="font-size:34px;line-height:1;margin-bottom:12px">🔒</div>' +
      '<div style="font-family:var(--font-display,inherit);font-size:17px;font-weight:700;' +
        'color:var(--ink,#0B2545);margin-bottom:8px">این کارتابل جای دیگری باز شد</div>' +
      '<div style="font-size:13px;color:var(--ink-soft,#43586D);line-height:2;margin-bottom:6px">' +
        'هر کارتابل هم‌زمان فقط روی یک دستگاه باز می‌ماند' +
        (dev ? '، و همین حالا روی <b>' + escapeGateHtml(dev) + '</b> باز شده' : '') +
        (at ? '<br><span style="font-size:12px;color:var(--ink-faint,#8697A8)">' +
              escapeGateHtml(faDateTime(at)) + '</span>' : '') +
      '</div>' +
      '<div style="font-size:12px;color:var(--ink-faint,#8697A8);line-height:1.9;margin-bottom:18px">' +
        'اگر خودتان بودید، همان‌جا ادامه بدهید. اگر نه، رمزتان را عوض کنید.</div>' +
      '<button type="button" id="takenBack" style="font-family:inherit;font-size:13.5px;' +
        'font-weight:600;padding:10px 20px;border-radius:10px;border:0;cursor:pointer;' +
        'background:var(--brass,#1A4FA3);color:#fff">ورود دوباره روی همین دستگاه</button>' +
    '</div>';
  document.body.appendChild(el);
  el.querySelector("#takenBack").addEventListener("click", ()=> location.reload());
}

/* ---------- ضربانِ نشست ----------
   قفل سمتِ سرور کار می‌کرد، ولی دستگاهِ کنارگذاشته‌شده تا وقتی خودش
   چیزی از سرور نمی‌خواست، خبردار نمی‌شد. کارتابلی که بخشِ مشترک دارد
   هر سی ثانیه خبرها را می‌پرسید و همان‌جا می‌فهمید؛ کارتابلی که
   نداشت، یک تبِ بازِ بی‌کار تا ابد باز می‌ماند و کاربر می‌دید که «قفل
   کار نمی‌کند».

   پس خودِ نشست ضربان دارد: هر بیست ثانیه یک /me، که سبک‌ترین مسیرِ
   سرور است. تبِ پنهان نمی‌پرسد — وقتی برگشت، همان لحظه می‌پرسد. */
const BEAT_MS = 20000;
let beatTimer = null;

async function sessionBeat(){
  if(KARTABL_TAKEN) return stopBeat();
  if(document.hidden) return;
  try{ await apiCall("/me"); }catch(e){ /* شبکه قطع بود؛ دفعهٔ بعد */ }
}
function stopBeat(){
  if(beatTimer){ clearInterval(beatTimer); beatTimer = null; }
}
function startBeat(){
  if(beatTimer || KARTABL_TAKEN) return;
  beatTimer = setInterval(sessionBeat, BEAT_MS);
  document.addEventListener("visibilitychange", ()=>{
    if(!document.hidden) sessionBeat();
  });
}

/* تاریخ و ساعتِ فارسی برای پیامِ «آخرین ورود». این‌جا بالای گیت لازم
   است، پیش از اینکه بقیهٔ کارتابل بار شود. */
function faDateTime(ms){
  try{
    const d = new Date(ms);
    const day = new Intl.DateTimeFormat("fa-IR-u-ca-persian", {year:"numeric", month:"long", day:"numeric"}).format(d);
    const time = new Intl.DateTimeFormat("fa-IR", {hour:"2-digit", minute:"2-digit", hour12:false}).format(d);
    return day + " — ساعت " + time;
  }catch(e){ return new Date(ms).toLocaleString("fa-IR"); }
}
function escapeGateHtml(t){
  return String(t == null ? "" : t)
    .replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");
}

/* ---------- بخش‌هایی که ادمین بسته است ----------
   فهرستش را سرور داخل صفحه می‌گذارد. این‌جا فقط از چشم برداشته می‌شوند؛
   جلوگیریِ واقعی سمتِ سرور است، چون پنهان‌کردنِ یک دکمه کسی را که
   درخواست را دستی بفرستد نگه نمی‌دارد. */
/* بستنِ یک بخش گاهی بخشِ دیگری را هم می‌بندد: وقتی خودِ دستیار نیست،
   تنظیمِ موتورش هم بی‌معنی است. همین قاعده سمتِ سرور هم هست. */
const FEAT_IMPLIES = { ai: ["aikey"] };

function closedFeatures(){
  const off = Array.isArray(window.KARTABL_OFF) ? window.KARTABL_OFF : [];
  const all = new Set(off);
  off.forEach(f => (FEAT_IMPLIES[f] || []).forEach(x => all.add(x)));
  return all;
}
function featClosed(f){ return closedFeatures().has(f); }

/* ---------- هشدارِ پایانِ مهلت ----------
   ادمین می‌تواند برای هر کارتابل مهلت بگذارد. از یک هفته مانده به
   پایان، هر بار که کارتابل باز می‌شود یک بار گفته می‌شود — تا کسی
   یک روز صبح با درِ بسته روبه‌رو نشود. */
function showExpiryWarning(){
  const until = Number(window.KARTABL_UNTIL || 0);
  if(!until || window.KARTABL_OFFLINE) return;
  /* گرد می‌کنیم، نه بالا و نه پایین: «۳ روز و یک ساعت» برای آدم
     «۳ روز» است، نه چهار. تاریخِ دقیق هم پایینش می‌آید. */
  const left = Math.round((until - Date.now()) / 86400000);
  if(left > 7 || until < Date.now()) return;
  const ov = document.getElementById("expOverlay");
  if(!ov) return;
  document.getElementById("expDays").textContent =
    left <= 0 ? "امروز آخرین روز است" : fa(left) + " روز مانده";
  document.getElementById("expNote").innerHTML =
    "تا <b>" + escapeHtml(faDateTime(until)) + "</b> باز است.<br>"
    + "بعد از آن بسته می‌شود و تا وقتی مدیر سیستم دوباره بازش نکند باز "
    + "نمی‌شود. داده‌هایتان سرِ جایشان می‌مانند و چیزی پاک نمی‌شود.";
  ov.hidden = false;
  const ok = document.getElementById("expOk");
  ok.addEventListener("click", ()=>{ ov.hidden = true; });
  setTimeout(()=>{ try{ ok.focus(); }catch(e){} }, 80);
}

function hideClosedFeatures(){
  const off = closedFeatures();
  if(!off.size) return;
  off.forEach(f=>{
    document.querySelectorAll('[data-feat="' + f + '"]').forEach(el=> el.remove());
  });
}
hideClosedFeatures();

let gateReady = null;   /* وعده‌ای که وقتی تکلیف ورود روشن شد باز می‌شود */
let signedIn = false;   /* نتیجه‌اش: وارد شده‌ایم یا نه */

(function(){
  const screenEl = document.getElementById("gateScreen");
  const form     = document.getElementById("gateForm");
  const input    = document.getElementById("gatePass");
  const btn      = document.getElementById("gateBtn");
  const errEl    = document.getElementById("gateErr");
  const remember = document.getElementById("gateRemember");
  const noteEl    = document.getElementById("gateNote");

  let letMeIn;
  gateReady = new Promise(r => { letMeIn = r; });

  function openGate(){
    screenEl.hidden = false;
    setTimeout(()=>{ try{ input.focus(); }catch(e){} }, 60);
    /* حتی وقتی وارد نشده‌ایم، بقیهٔ صفحه باید راه بیفتد. یک بار همین‌جا
       معلق ماند و صفحه پشتِ قفل برای همیشه روی «در حال بارگذاری» ماند. */
    letMeIn(false);
  }
  /* بستن یعنی برداشتن از صفحه، نه فقط پنهان کردن.
     دلیلش یک ایرادِ واقعی بود: تا وقتی این فرم در صفحه می‌ماند، مرورگر
     یک «کادرِ رمز» می‌بیند و دنبالِ کادرِ نام کاربری کنارش می‌گردد؛
     نزدیک‌ترین ورودیِ متنیِ صفحه را برمی‌دارد و نام کاربریِ ذخیره‌شده
     («admin») را داخلش می‌ریزد. نتیجه این شد که ستونِ «داخلی» در
     جدولِ MVPN خودبه‌خود «admin» می‌گرفت.
     بعد از ورودِ موفق صفحه همیشه reload می‌شود، پس این فرم دیگر لازم
     نیست و برداشتنش چیزی را خراب نمی‌کند. */
  function closeGate(){
    screenEl.hidden = true;
    /* خودِ گره می‌ماند (جاهایی به وجودش تکیه شده) ولی محتوایش می‌رود:
       کادرِ رمز باید از صفحه برود، نه فقط پنهان شود. */
    try{ screenEl.innerHTML = ""; }catch(e){}
    /* از همین‌جا نشست ضربان می‌گیرد. نسخهٔ آفلاینِ پشتیبان سروری ندارد،
       پس آن‌جا خاموش می‌ماند. */
    if(!window.KARTABL_OFFLINE) startBeat();
  }

  if(window.KARTABL_OFFLINE){
    /* نسخهٔ داخل فایل پشتیبان: سروری در کار نیست، پس نه قفل معنا دارد
       نه همگام‌سازی. باز می‌شود و با «⬆ بازیابی» پر می‌شود. */
    closeGate(); letMeIn(false);
  } else {
    /* آیا کوکی نشست هنوز معتبر است؟ */
    apiCall("/me").then(r=>{
      if(r.ok && r.data.in){
        signedIn = true;
        /* همان عدد در تنظیمات هم نشان داده می‌شود تا بعداً هم در دسترس باشد */
        if(r.data.lastLogin) window.__lastLogin = Number(r.data.lastLogin);
        closeGate(); letMeIn(true);
      }
      else openGate();
    }).catch(()=>{
      /* سرور در دسترس نیست — با همان نسخهٔ محلی ادامه می‌دهیم، وگرنه
         کارتابل در قطعی اینترنت اصلاً باز نمی‌شود. */
      closeGate(); letMeIn(false);
    });
  }

  form.addEventListener("submit", async (e)=>{
    e.preventDefault();
    const pass = input.value;
    if(!pass) return;
    btn.disabled = true; btn.textContent = "در حال بررسی..."; errEl.textContent = "";
    try{
      const r = await apiCall("/login", { method: "POST",
        body: JSON.stringify({ password: pass, remember: remember.checked }) });
      if(r.ok){
        input.value = "";
        /* «آخرین ورود» را همین‌جا نشان می‌دهیم، بعد از ورودِ موفق — نه
           قبلش. اگر قبل از ورود نشان داده می‌شد، هر کسی که آدرس را دارد
           می‌فهمید این کارتابل کِی استفاده شده. */
        const prev = Number(r.data.lastLogin || 0);
        if(prev > 0 && noteEl){
          noteEl.innerHTML = "آخرین ورودِ شما به این کارتابل:<br><b>" +
            escapeGateHtml(faDateTime(prev)) + "</b>";
          btn.textContent = "در حال باز کردن…";
          setTimeout(()=> location.reload(), 2200);
        } else {
          location.reload();
        }
        return;
      }
      errEl.textContent = r.data.error || "رمز عبور اشتباه است.";
      input.select();
    }catch(err){
      errEl.textContent = "به سرور نرسیدم. اینترنت را بررسی کنید.";
    }
    btn.disabled = false; btn.textContent = "ورود";
  });

  /* ---------- رمز را فراموش کرده‌ام ----------
     رمزِ تازه را سرور می‌سازد و فقط به همان گفتگوی تلگرامی می‌فرستد که
     پشتیبان‌ها می‌روند. اینجا هیچ‌وقت دیده نمی‌شود، حتی در پاسخِ درخواست؛
     یعنی زدنِ این دکمه به‌تنهایی به کسی رمز نمی‌دهد. */
  const forgotBtn = document.getElementById("gateForgot");
  if(forgotBtn && window.KARTABL_OFFLINE) forgotBtn.style.display = "none";
  if(forgotBtn) forgotBtn.addEventListener("click", async ()=>{
    const go = confirm(
      "رمز تازه به همان گفتگوی تلگرامی فرستاده می‌شود که پشتیبان‌ها می‌روند.\n" +
      "از همان لحظه رمز فعلی از کار می‌افتد و هر دستگاهی که وارد مانده بیرون می‌افتد.\n\n" +
      "ادامه بدهم؟");
    if(!go) return;
    forgotBtn.disabled = true; errEl.textContent = "";
    noteEl.textContent = "در حال فرستادن به تلگرام...";
    try{
      const r = await apiCall("/forgot", { method: "POST" });
      if(r.ok){
        noteEl.textContent = "رمز تازه به تلگرام رفت. پیام ربات را ببینید و همان را این‌جا وارد کنید.";
        input.value = "";
        try{ input.focus(); }catch(e){}
      }else{
        noteEl.textContent = "";
        errEl.textContent = r.data.error || "نشد.";
      }
    }catch(e){
      noteEl.textContent = "";
      errEl.textContent = "به سرور نرسیدم. اینترنت را بررسی کنید.";
    }
    forgotBtn.disabled = false;
  });

  document.addEventListener("DOMContentLoaded", ()=>{
    const lock = document.getElementById("lockBtn");
    if(!lock) return;
    if(window.KARTABL_OFFLINE){ lock.style.display = "none"; return; }
    lock.addEventListener("click", async ()=>{
      try{ await apiCall("/logout", { method: "POST" }); }catch(e){}
      /* نسخهٔ محلی هم پاک می‌شود، وگرنه روی یک دستگاه مشترک داده‌ها
         بعد از «خروج» هنوز روی صفحه می‌ماند. */
      try{ localStorage.removeItem(STORE_KEY); }catch(e){}
      try{ localStorage.removeItem(DB_CACHE_KEY); }catch(e){}
      location.reload();
    });
  });
})();
</script>
