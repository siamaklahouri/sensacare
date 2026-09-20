<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex, nofollow">
<link rel="icon" type="image/png" href="/icon-siamak.2.png">
<script>
try{ if(localStorage.getItem("admin-planer:theme") === "dark")
  document.documentElement.setAttribute("data-theme","dark"); }catch(e){}
</script>
<title>پنل کارتابل‌ها</title>
<style>
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:400;font-display:swap;
  src:url(/f/Vazirmatn-Regular.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:500;font-display:swap;
  src:url(/f/Vazirmatn-Medium.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:600;font-display:swap;
  src:url(/f/Vazirmatn-SemiBold.2.woff2) format("woff2")}
@font-face{font-family:Vazirmatn;font-style:normal;font-weight:700;font-display:swap;
  src:url(/f/Vazirmatn-Bold.2.woff2) format("woff2")}
</style>
<style>
:root{
  --paper:#EEF2F6; --ink:#0B2545; --ink-soft:#3E5164; --ink-faint:#8592A0;
  --brass:#0E8B8B; --brass-deep:#0B6E6E; --brass-bg:#E3F4F3;
  --green:#2F6B4F; --green-bg:#E3EFE7;
  --amber:#C98A2C; --amber-bg:#FBF1DF;
  --red:#A6222B; --red-bg:#F6E1E2;
  --purple:#5B3E8C; --purple-bg:#EAE4F2;
  --line:#DCE3E9; --white:#FFFFFF; --deep:#0B2545;
  --font:'Vazirmatn', Tahoma, 'Segoe UI', Arial, sans-serif;
  --radius:14px; --radius-sm:10px;
  --shadow: 0 1px 2px rgba(11,37,69,.05), 0 6px 18px rgba(11,37,69,.06);
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --paper:#0D1620; --ink:#E6EDF3; --ink-soft:#A9B7C6; --ink-faint:#7C8B9B;
    --brass:#3FB6AE; --brass-deep:#2A8F89; --brass-bg:#12312F;
    --green:#5FB07E; --green-bg:#16301F;
    --amber:#E0AC55; --amber-bg:#3A2D12;
    --red:#E8737C; --red-bg:#3A1A1D;
    --purple:#A88FD8; --purple-bg:#241B36;
    --line:#22303E; --white:#131F2B; --deep:#E6EDF3;
    --shadow: 0 1px 2px rgba(0,0,0,.35), 0 6px 18px rgba(0,0,0,.30);
  }
}
:root[data-theme="dark"]{
  --paper:#0D1620; --ink:#E6EDF3; --ink-soft:#A9B7C6; --ink-faint:#7C8B9B;
  --brass:#3FB6AE; --brass-deep:#2A8F89; --brass-bg:#12312F;
  --green:#5FB07E; --green-bg:#16301F;
  --amber:#E0AC55; --amber-bg:#3A2D12;
  --red:#E8737C; --red-bg:#3A1A1D;
  --purple:#A88FD8; --purple-bg:#241B36;
  --line:#22303E; --white:#131F2B; --deep:#E6EDF3;
  --shadow: 0 1px 2px rgba(0,0,0,.35), 0 6px 18px rgba(0,0,0,.30);
}
*{box-sizing:border-box;}
html,body{margin:0;padding:0;}
body{ font-family:var(--font); background:var(--paper); color:var(--ink);
  min-height:100vh; -webkit-font-smoothing:antialiased; font-size:13.5px; }

/* ---------- قفل ورود ---------- */
#gate{ position:fixed; inset:0; z-index:90; background:var(--paper);
  display:flex; align-items:center; justify-content:center; padding:20px; }
#gate[hidden]{ display:none; }
.gate-card{ background:var(--white); border:1px solid var(--line); border-radius:var(--radius);
  box-shadow:var(--shadow); padding:26px 22px; width:100%; max-width:380px; text-align:center; }
.gate-card h1{ font-size:17px; margin:0 0 6px; }
.gate-card p{ font-size:12.5px; color:var(--ink-soft); line-height:2; margin:0 0 16px; }
.gate-card input{ width:100%; padding:11px 12px; margin-bottom:10px; border:1px solid var(--line);
  border-radius:var(--radius-sm); font-family:var(--font); font-size:13.5px;
  background:var(--paper); color:var(--ink); }
.gate-card input:focus{ outline:none; border-color:var(--brass); background:var(--white); }
.gate-card button{ width:100%; padding:11px; border:0; border-radius:var(--radius-sm);
  background:var(--brass); color:#fff; font-family:var(--font); font-size:14px;
  font-weight:600; cursor:pointer; }
.gate-card button:disabled{ opacity:.6; cursor:default; }
.gate-err{ color:var(--red); font-size:12.5px; min-height:19px; margin-top:8px; }
.gate-note{ color:var(--ink-soft); font-size:12.5px; margin-top:10px; line-height:2; }

/* ---------- چارچوب ---------- */
.wrap{ max-width:1100px; margin:0 auto; padding:18px 16px 60px; }
.top{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; margin-bottom:18px; }
.top h1{ font-size:18px; margin:0; flex:1; }
.tabs{ display:flex; gap:6px; flex-wrap:wrap; margin-bottom:16px; }
.tabs button{ padding:8px 14px; border:1px solid var(--line); background:var(--white);
  color:var(--ink-soft); border-radius:999px; font-family:var(--font); font-size:12.5px;
  cursor:pointer; }
.tabs button.active{ background:var(--brass); border-color:var(--brass); color:#fff; font-weight:600; }
.panel{ background:var(--white); border:1px solid var(--line); border-radius:var(--radius);
  box-shadow:var(--shadow); padding:16px; margin-bottom:14px; }
.panel h2{ font-size:14.5px; margin:0 0 4px; }
.panel .sub{ font-size:12px; color:var(--ink-soft); line-height:1.9; margin:0 0 14px; }
.btn{ padding:8px 13px; border:1px solid var(--line); background:var(--white); color:var(--ink);
  border-radius:var(--radius-sm); font-family:var(--font); font-size:12.5px; cursor:pointer; }
.btn:hover{ border-color:var(--brass); color:var(--brass); }
.btn-main{ background:var(--brass); border-color:var(--brass); color:#fff; font-weight:600; }
.btn-main:hover{ background:var(--brass-deep); border-color:var(--brass-deep); color:#fff; }
.btn-danger{ color:var(--red); border-color:var(--red); }
.btn-danger:hover{ background:var(--red); color:#fff; border-color:var(--red); }
.btn:disabled{ opacity:.5; cursor:default; }
.row{ display:flex; gap:10px; flex-wrap:wrap; align-items:flex-end; }
.fld{ display:flex; flex-direction:column; gap:5px; min-width:150px; flex:1; }
.fld label{ font-size:11.5px; color:var(--ink-soft); }
.fld input, .fld select{ padding:9px 10px; border:1px solid var(--line); border-radius:var(--radius-sm);
  font-family:var(--font); font-size:13px; background:var(--paper); color:var(--ink); }
.fld input:focus, .fld select:focus{ outline:none; border-color:var(--brass); background:var(--white); }
.hint{ font-size:11.5px; color:var(--ink-faint); line-height:1.9; margin-top:6px; }

/* ---------- کارت کارتابل ---------- */
.plist{ display:grid; grid-template-columns:repeat(auto-fill, minmax(320px,1fr)); gap:12px; }
.pcard{ background:var(--white); border:1px solid var(--line); border-radius:var(--radius);
  box-shadow:var(--shadow); padding:14px; }
.pcard h3{ margin:0 0 3px; font-size:14.5px; display:flex; align-items:center; gap:7px; }
.pill{ font-size:10.5px; padding:2px 8px; border-radius:999px; font-weight:600; }
.pill-it{ background:var(--brass-bg); color:var(--brass-deep); }
.pill-fin{ background:var(--green-bg); color:var(--green); }
.pill-gen{ background:var(--purple-bg); color:var(--purple); }
.pill-builtin{ background:var(--amber-bg); color:var(--amber); }
.pcard .url{ font-size:12px; color:var(--brass); text-decoration:none; direction:ltr;
  display:inline-block; margin-bottom:8px; }
.pcard .meta{ font-size:11.5px; color:var(--ink-faint); line-height:2; margin-bottom:10px; }
.pcard .acts{ display:flex; gap:6px; flex-wrap:wrap; }
.pcard .acts .btn{ padding:6px 10px; font-size:11.5px; }

/* ---------- بخش‌های شخصی ---------- */
.secrow{ display:flex; gap:8px; align-items:center; margin-bottom:8px; flex-wrap:wrap; }
.secrow input, .secrow select{ padding:7px 9px; border:1px solid var(--line);
  border-radius:8px; font-family:var(--font); font-size:12.5px;
  background:var(--paper); color:var(--ink); }
.secrow .stitle{ flex:1; min-width:130px; }
.secrow .scols{ flex:1.4; min-width:160px; }
.x{ border:0; background:transparent; color:var(--red); font-size:15px; cursor:pointer; padding:2px 6px; }

/* ---------- پیام ---------- */
.msg{ padding:10px 12px; border-radius:var(--radius-sm); font-size:12.5px; line-height:2;
  margin-bottom:12px; white-space:pre-wrap; word-break:break-word; }
.msg-ok{ background:var(--green-bg); color:var(--green); border:1px solid var(--green); }
.msg-bad{ background:var(--red-bg); color:var(--red); border:1px solid var(--red); }
.msg code{ font-family:ui-monospace, Menlo, Consolas, monospace; direction:ltr;
  display:inline-block; background:rgba(0,0,0,.06); padding:2px 7px; border-radius:6px;
  font-size:13px; letter-spacing:.5px; }
:root[data-theme="dark"] .msg code{ background:rgba(255,255,255,.08); }

/* ---------- سیاهه ---------- */
table{ width:100%; border-collapse:collapse; font-size:12px; }
th,td{ padding:7px 9px; border-bottom:1px solid var(--line); text-align:right; }
th{ color:var(--ink-soft); font-weight:600; font-size:11.5px; }
td.ltr{ direction:ltr; text-align:left; }

/* ---------- پنجره ---------- */
.ov{ position:fixed; inset:0; background:rgba(11,37,69,.55); z-index:80;
  display:flex; align-items:center; justify-content:center; padding:18px; }
.ov[hidden]{ display:none; }
.ov-box{ background:var(--white); border-radius:var(--radius); box-shadow:var(--shadow);
  padding:20px; width:100%; max-width:520px; max-height:88vh; overflow:auto; }
.ov-box h2{ margin:0 0 4px; font-size:15px; }
.ov-acts{ display:flex; gap:8px; justify-content:flex-start; margin-top:16px; }
#loading{ position:fixed; inset:0; background:var(--paper); z-index:95;
  display:flex; align-items:center; justify-content:center; color:var(--ink-faint); }
</style>
</head>
<body>

<div id="loading">در حال بارگذاری…</div>

<div id="gate" hidden>
  <form class="gate-card" id="gateForm">
    <h1 id="gateTitle">پنل کارتابل‌ها</h1>
    <p id="gateSub">برای ادامه رمز ادمین را وارد کنید.</p>
    <input type="text" id="gateCode" placeholder="کد تلگرام" autocomplete="off" dir="ltr" hidden>
    <input type="password" id="gatePass" placeholder="رمز ادمین" autocomplete="current-password">
    <input type="password" id="gatePass2" placeholder="تکرار رمز" autocomplete="new-password" hidden>
    <button type="submit" id="gateBtn">ورود</button>
    <button type="button" class="btn" id="gateCodeBtn" style="width:100%; margin-top:8px;" hidden>
      فرستادن کد به تلگرام</button>
    <div class="gate-err" id="gateErr"></div>
    <div class="gate-note" id="gateNote"></div>
  </form>
</div>

<div class="wrap" id="app" hidden>
  <div class="top">
    <h1>پنل کارتابل‌ها</h1>
    <button class="btn" id="themeBtn" title="تم روز و شب">🌙</button>
    <button class="btn" id="logoutBtn">خروج</button>
  </div>

  <div class="tabs">
    <button data-tab="list" class="active">کارتابل‌ها</button>
    <button data-tab="new">کارتابل تازه</button>
    <button data-tab="keys">کلیدها و رمز ادمین</button>
    <button data-tab="log">سیاههٔ کارها</button>
  </div>

  <div id="msg"></div>

  <section id="tab-list">
    <div class="plist" id="plist"></div>
  </section>

  <section id="tab-new" hidden>
    <div class="panel">
      <h2>ساختن کارتابل تازه</h2>
      <p class="sub">نامِ شخص و آدرسی که کارتابلش روی آن باز می‌شود. رمزِ ورود همین‌جا
        یک‌بار نشان داده می‌شود و بعد دیگر هیچ‌جا نیست — همان لحظه جایی یادداشتش کنید.</p>
      <div class="row">
        <div class="fld"><label>نام شخص</label><input type="text" id="nName" placeholder="مثلاً: نسرین"></div>
        <div class="fld"><label>آدرس کارتابل</label><input type="text" id="nSlug" placeholder="nasrin" dir="ltr"></div>
        <div class="fld"><label>نوع کارتابل</label><select id="nKind"></select></div>
        <div class="fld" id="nJobWrap"><label>شغل (چک‌لیست آماده)</label><select id="nJob"></select></div>
      </div>
      <div class="row" style="margin-top:10px;">
        <div class="fld"><label>رمز ورود (خالی بگذارید تا خودش بسازد)</label>
          <input type="text" id="nPass" placeholder="خودکار" dir="ltr"></div>
      </div>
      <div class="hint" id="nPreview"></div>
      <div style="margin-top:12px;"><button class="btn btn-main" id="nCreate">ساختن کارتابل</button></div>
    </div>
  </section>

  <section id="tab-keys" hidden>
    <div class="panel">
      <h2>رمز ادمین</h2>
      <p class="sub">با عوض شدنش همهٔ نشست‌های باز — روی هر دستگاهی — بسته می‌شوند.</p>
      <div class="row">
        <div class="fld"><label>رمز فعلی</label><input type="password" id="apCur"></div>
        <div class="fld"><label>رمز تازه (دست‌کم ۱۰ حرف)</label><input type="password" id="apNew"></div>
        <div class="fld"><label>تکرار</label><input type="password" id="apNew2"></div>
        <div><button class="btn btn-main" id="apGo">عوض کن</button></div>
      </div>
    </div>

    <div class="panel">
      <h2>کلید اضطراری دیتای شخصی</h2>
      <p class="sub">دیتای شخصیِ هر کاربر با رمزِ خودش قفل است و سرور کلیدش را ندارد.
        این کلید همان تورِ اضطراری است: مرورگرِ کاربر رمزش را با «کلید عمومی» می‌پیچد،
        و باز کردنش عبارتِ عبورِ شما را می‌خواهد — عبارتی که فقط در همین مرورگر
        تایپ می‌شود و هیچ‌وقت به سرور نمی‌رسد.</p>
      <div id="escrowState" class="hint"></div>
      <div class="row" style="margin-top:10px;">
        <div class="fld"><label>عبارت عبور ادمین (دست‌کم ۱۲ حرف)</label>
          <input type="password" id="ekPass" autocomplete="new-password"></div>
        <div class="fld"><label>تکرار</label><input type="password" id="ekPass2" autocomplete="new-password"></div>
        <div><button class="btn btn-main" id="ekGo">ساختن کلید</button></div>
      </div>
      <div class="hint">⚠️ اگر این عبارت را فراموش کنید هیچ‌کس — نه شما نه سرور — نمی‌تواند
        بازش کند. ساختنِ کلیدِ تازه هم بسته‌های قدیمی را باز نمی‌کند.</div>
    </div>
  </section>

  <section id="tab-log" hidden>
    <div class="panel">
      <h2>سیاههٔ کارها</h2>
      <p class="sub">صد کارِ آخر.</p>
      <div id="logBody"></div>
    </div>
  </section>
</div>

<div class="ov" id="ov" hidden><div class="ov-box" id="ovBox"></div></div>

<script>
/* ==========================================================================
   پنل ادمینِ کارتابل‌ها
   ========================================================================== */

const API = "/api/admin.planer";
let DATA = { items: [], kinds: [], jobs: [], vaultTypes: [], escrowReady: false };

async function api(path, opt = {}){
  const res = await fetch(API + path, Object.assign({
    credentials: "same-origin",
    headers: { "Content-Type": "application/json" }
  }, opt));
  let data = null;
  try{ data = await res.json(); }catch(e){}
  return { ok: res.ok, status: res.status, data: data || {} };
}

const esc = t => String(t == null ? "" : t)
  .replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")
  .replace(/"/g,"&quot;").replace(/'/g,"&#39;");

function faDateTime(ms){
  if(!ms) return "—";
  try{
    const d = new Date(Number(ms));
    return new Intl.DateTimeFormat("fa-IR-u-ca-persian",{year:"numeric",month:"long",day:"numeric"}).format(d)
      + " — " + new Intl.DateTimeFormat("fa-IR",{hour:"2-digit",minute:"2-digit",hour12:false}).format(d);
  }catch(e){ return "—"; }
}

function say(text, bad){
  const el = document.getElementById("msg");
  el.innerHTML = `<div class="msg ${bad?'msg-bad':'msg-ok'}">${text}</div>`;
  if(!bad) setTimeout(()=>{ if(el.firstChild && el.firstChild.classList.contains("msg-ok")) el.innerHTML=""; }, 12000);
  window.scrollTo({top:0, behavior:"smooth"});
}

/* ---------- ابزارِ رمزنگاری ---------- */
const b64 = buf => btoa(String.fromCharCode(...new Uint8Array(buf)));
const unb64 = s => Uint8Array.from(atob(s), c => c.charCodeAt(0));

async function keyFrom(pass, salt, uses){
  const base = await crypto.subtle.importKey("raw", new TextEncoder().encode(pass),
    "PBKDF2", false, ["deriveKey"]);
  return crypto.subtle.deriveKey({ name:"PBKDF2", salt, iterations:150000, hash:"SHA-256" },
    base, { name:"AES-GCM", length:256 }, false, uses);
}

/* ---------- قفل ورود ---------- */
let needsSetup = false;

(async function gate(){
  const me = await api("/me");
  document.getElementById("loading").style.display = "none";
  if(me.ok && me.data.in){ openApp(me.data.lastLogin); return; }
  needsSetup = !!(me.data && me.data.needsSetup);
  if(needsSetup){
    document.getElementById("gateTitle").textContent = "اولین بار: رمز ادمین را بگذارید";
    document.getElementById("gateSub").innerHTML =
      "تا وقتی رمزی نیست این پنل بی‌صاحب است، پس رمزِ اول با کدی گذاشته می‌شود " +
      "که فقط به همان گفتگوی تلگرامیِ پشتیبان‌ها می‌رود.<br>" +
      "اول کد را بگیرید، بعد کد و رمزِ تازه را این‌جا بزنید.";
    document.getElementById("gatePass").placeholder = "رمز تازه (دست‌کم ۱۰ حرف)";
    document.getElementById("gatePass").setAttribute("autocomplete","new-password");
    document.getElementById("gatePass2").hidden = false;
    document.getElementById("gateCode").hidden = false;
    document.getElementById("gateCodeBtn").hidden = false;
    document.getElementById("gateBtn").textContent = "بگذار و وارد شو";
    document.getElementById("gateCodeBtn").addEventListener("click", async ()=>{
      const b = document.getElementById("gateCodeBtn");
      const note = document.getElementById("gateNote");
      b.disabled = true; note.textContent = "در حال فرستادن…";
      const r = await api("/setup-code", { method:"POST", body:"{}" });
      note.textContent = r.ok
        ? "کد به تلگرام رفت. تا ۱۵ دقیقه معتبر است."
        : (r.data.error || "نشد.");
      b.disabled = false;
    });
  }
  document.getElementById("gate").hidden = false;
  setTimeout(()=>{ try{ document.getElementById("gatePass").focus(); }catch(e){} }, 60);
})();

document.getElementById("gateForm").addEventListener("submit", async (e)=>{
  e.preventDefault();
  const pass = document.getElementById("gatePass").value;
  const btn = document.getElementById("gateBtn");
  const err = document.getElementById("gateErr");
  err.textContent = "";
  if(!pass) return;
  if(needsSetup){
    if(pass.length < 10){ err.textContent = "رمز ادمین دست‌کم ۱۰ حرف باشد."; return; }
    if(pass !== document.getElementById("gatePass2").value){ err.textContent = "تکرار رمز نمی‌خواند."; return; }
    if(!document.getElementById("gateCode").value.trim()){
      err.textContent = "اول کد را از تلگرام بگیرید و این‌جا بزنید."; return; }
  }
  btn.disabled = true; btn.textContent = "…";
  const r = await api(needsSetup ? "/setup" : "/login",
    { method:"POST", body: JSON.stringify({ password: pass, remember: true,
      code: document.getElementById("gateCode").value.trim() }) });
  if(r.ok){
    const prev = Number(r.data.lastLogin || 0);
    if(prev > 0){
      document.getElementById("gateNote").innerHTML =
        "آخرین ورودِ شما به این پنل:<br><b>" + esc(faDateTime(prev)) + "</b>";
      btn.textContent = "در حال باز کردن…";
      setTimeout(()=> location.reload(), 2000);
    } else location.reload();
    return;
  }
  err.textContent = r.data.error || "نشد.";
  btn.disabled = false; btn.textContent = needsSetup ? "بگذار و وارد شو" : "ورود";
});

/* ---------- برنامه ---------- */
function openApp(lastLogin){
  document.getElementById("gate").hidden = true;
  document.getElementById("app").hidden = false;
  if(lastLogin) say("آخرین ورودِ قبلی شما: <b>" + esc(faDateTime(lastLogin)) + "</b>");
  setupTheme();
  setupTabs();
  setupNew();
  setupKeys();
  loadPlanners();
}

function setupTheme(){
  const btn = document.getElementById("themeBtn");
  const cur = ()=> document.documentElement.getAttribute("data-theme")
    || (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
  const paint = ()=> btn.textContent = cur()==="dark" ? "☀️" : "🌙";
  paint();
  btn.addEventListener("click", ()=>{
    const next = cur()==="dark" ? "light" : "dark";
    document.documentElement.setAttribute("data-theme", next);
    try{ localStorage.setItem("admin-planer:theme", next); }catch(e){}
    paint();
  });
}

function setupTabs(){
  document.querySelectorAll(".tabs button").forEach(b=>{
    b.addEventListener("click", ()=>{
      document.querySelectorAll(".tabs button").forEach(x=> x.classList.toggle("active", x===b));
      ["list","new","keys","log"].forEach(t=>
        document.getElementById("tab-"+t).hidden = (t !== b.dataset.tab));
      if(b.dataset.tab === "log") loadLog();
    });
  });
  document.getElementById("logoutBtn").addEventListener("click", async ()=>{
    await api("/logout", { method:"POST" });
    location.reload();
  });
}

/* ---------- فهرست ---------- */
async function loadPlanners(){
  const r = await api("/planners");
  if(!r.ok){ say(r.data.error || "فهرست نیامد.", true); return; }
  DATA = r.data;
  fillSelect("nKind", DATA.kinds);
  fillSelect("nJob", [{id:"",label:"— بدون چک‌لیست آماده —"}].concat(DATA.jobs));
  renderPlanners();
  renderEscrowState();
}

function fillSelect(id, items){
  const el = document.getElementById(id);
  if(!el || el.options.length) return;
  el.innerHTML = items.map(i=>`<option value="${esc(i.id)}">${esc(i.label)}</option>`).join("");
}

function kindLabel(k){ const f = DATA.kinds.find(x=>x.id===k); return f ? f.label : k; }
function jobLabel(j){ const f = DATA.jobs.find(x=>x.id===j); return f ? f.label : ""; }

function renderPlanners(){
  const wrap = document.getElementById("plist");
  wrap.innerHTML = DATA.items.map(p=>`
    <div class="pcard">
      <h3>${esc(p.name)}
        <span class="pill pill-${esc(p.kind)}">${esc(kindLabel(p.kind))}</span>
        ${p.builtin ? `<span class="pill pill-builtin">اصلی</span>` : ``}</h3>
      <a class="url" href="${esc(p.url)}" target="_blank" rel="noopener">sensacare.ir${esc(p.url)}</a>
      <div class="meta">
        ${p.job ? "چک‌لیست: " + esc(jobLabel(p.job)) + "<br>" : ""}
        بخش‌های شخصی: ${esc((p.vault||[]).map(v=>v.title).join("، ") || "—")}<br>
        آخرین ورود: ${esc(faDateTime(p.lastLogin))}<br>
        رمز دیتای شخصی نزد ادمین: ${p.hasEscrow ? "بله" : "نه"}
      </div>
      <div class="acts">
        <button class="btn" data-edit="${esc(p.slug)}">ویرایش</button>
        <button class="btn" data-pw="${esc(p.slug)}">رمز ورود</button>
        <button class="btn" data-vpw="${esc(p.slug)}">رمز دیتای شخصی</button>
        ${p.builtin ? `` : `<button class="btn btn-danger" data-del="${esc(p.slug)}">حذف</button>`}
      </div>
    </div>`).join("") || `<p class="hint">هنوز کارتابلی نیست.</p>`;

  wrap.querySelectorAll("[data-edit]").forEach(b=> b.onclick = ()=> openEdit(b.dataset.edit));
  wrap.querySelectorAll("[data-pw]").forEach(b=> b.onclick = ()=> resetLoginPassword(b.dataset.pw));
  wrap.querySelectorAll("[data-vpw]").forEach(b=> b.onclick = ()=> openVaultReset(b.dataset.vpw));
  wrap.querySelectorAll("[data-del]").forEach(b=> b.onclick = ()=> openDelete(b.dataset.del));
}

const find = slug => DATA.items.find(p=>p.slug===slug);

/* ---------- پنجره ---------- */
function openOverlay(html){
  document.getElementById("ovBox").innerHTML = html;
  document.getElementById("ov").hidden = false;
}
function closeOverlay(){ document.getElementById("ov").hidden = true; }
document.getElementById("ov").addEventListener("click", e=>{
  if(e.target.id === "ov") closeOverlay();
});

/* ---------- ویرایش ---------- */
function sectionRow(sec){
  const types = DATA.vaultTypes.map(t=>
    `<option value="${esc(t.id)}" ${sec.type===t.id?"selected":""}>${esc(t.label)}</option>`).join("");
  return `<div class="secrow" data-sec>
    <select class="stype">${types}</select>
    <input class="stitle" type="text" value="${esc(sec.title||"")}" placeholder="عنوان بخش">
    <input class="scols" type="text" value="${esc((sec.cols||[]).join("، "))}"
      placeholder="ستون‌ها با ، جدا شوند (فقط جدول دل‌خواه)">
    <input class="sid" type="hidden" value="${esc(sec.id||"")}">
    <button type="button" class="x" title="بردار">✕</button>
  </div>`;
}

function openEdit(slug){
  const p = find(slug);
  if(!p) return;
  const jobs = [{id:"",label:"— بدون چک‌لیست آماده —"}].concat(DATA.jobs);
  openOverlay(`
    <h2>ویرایش «${esc(p.name)}»</h2>
    <p class="sub">${p.builtin ? "این کارتابل هنوز در جدول نیست، پس فقط دیده می‌شود." : "sensacare.ir"+esc(p.url)}</p>
    <div class="row">
      <div class="fld"><label>نام</label><input type="text" id="eName" value="${esc(p.name)}"></div>
      <div class="fld"><label>شغل (چک‌لیست آماده)</label><select id="eJob">${
        jobs.map(j=>`<option value="${esc(j.id)}" ${p.job===j.id?"selected":""}>${esc(j.label)}</option>`).join("")
      }</select></div>
    </div>
    <p class="sub" style="margin-top:16px;">بخش‌های «دیتای شخصی» — برداشتنِ یک بخش
      محتوایش را پاک نمی‌کند؛ فقط از چشمِ کاربر پنهان می‌شود و با برگرداندنش
      دوباره پیدا می‌شود.</p>
    <div id="eSecs">${(p.vault||[]).map(sectionRow).join("")}</div>
    <button type="button" class="btn" id="eAddSec">＋ بخش تازه</button>
    <div class="ov-acts">
      ${p.builtin ? "" : `<button class="btn btn-main" id="eSave">ذخیره</button>`}
      <button class="btn" id="eCancel">بستن</button>
    </div>
    <div class="gate-err" id="eErr"></div>`);

  const wire = ()=> document.querySelectorAll("#eSecs .x").forEach(x=>
    x.onclick = ()=> { x.closest("[data-sec]").remove(); });
  wire();
  document.getElementById("eAddSec").onclick = ()=>{
    document.getElementById("eSecs").insertAdjacentHTML("beforeend",
      sectionRow({ id:"", type:"table", title:"", cols:[] }));
    wire();
  };
  document.getElementById("eCancel").onclick = closeOverlay;
  const save = document.getElementById("eSave");
  if(save) save.onclick = async ()=>{
    const secs = [];
    const used = new Set();
    for(const row of document.querySelectorAll("#eSecs [data-sec]")){
      const title = row.querySelector(".stitle").value.trim();
      if(!title) continue;
      const type = row.querySelector(".stype").value;
      let id = row.querySelector(".sid").value.trim();
      if(!id){
        /* شناسه فقط یک‌بار ساخته می‌شود و بعد دست نمی‌خورد: داده‌ی هر بخش
           زیر همین شناسه نشسته، پس عوض کردنش یعنی گم کردنِ محتوا. */
        id = "s" + Date.now().toString(36) + Math.random().toString(36).slice(2,6);
      }
      if(used.has(id)) continue;
      used.add(id);
      const cols = row.querySelector(".scols").value.split(/[،,]/).map(c=>c.trim()).filter(Boolean);
      secs.push(Object.assign({ id, type, title }, type==="table" && cols.length ? { cols } : {}));
    }
    if(!secs.length){ document.getElementById("eErr").textContent = "دست‌کم یک بخش باید بماند."; return; }
    save.disabled = true;
    const r = await api("/planners/" + slug, { method:"PUT", body: JSON.stringify({
      name: document.getElementById("eName").value.trim(),
      job: document.getElementById("eJob").value,
      vault: secs
    })});
    save.disabled = false;
    if(!r.ok){ document.getElementById("eErr").textContent = r.data.error || "نشد."; return; }
    closeOverlay();
    say("ذخیره شد.");
    loadPlanners();
  };
}

/* ---------- رمز ورود ---------- */
async function resetLoginPassword(slug){
  const p = find(slug);
  if(!p) return;
  const typed = prompt(
    "رمز تازهٔ ورود برای «" + p.name + "».\n" +
    "خالی بگذارید تا خودش یک رمزِ قوی بسازد.\n\n" +
    "⚠️ با این کار هر دستگاهی که وارد مانده بیرون می‌افتد. " +
    "دیتای کارتابل و دیتای شخصی دست نمی‌خورند.");
  if(typed === null) return;
  const r = await api("/planners/" + slug + "/password",
    { method:"POST", body: JSON.stringify({ password: typed.trim() }) });
  if(!r.ok){ say(r.data.error || "نشد.", true); return; }
  say("رمزِ ورودِ «" + esc(p.name) + "» عوض شد:<br><code>" + esc(r.data.password) + "</code><br>" +
      "همین حالا جایی یادداشتش کنید — بعد از بستنِ این پیام دیگر هیچ‌جا نیست.");
  loadPlanners();
}

/* ---------- رمز دیتای شخصی ---------- */
function openVaultReset(slug){
  const p = find(slug);
  if(!p) return;
  if(!DATA.escrowReady){
    say("اول باید از بخش «کلیدها» کلیدِ اضطراری را بسازید. بدونش رمزِ دیتای شخصی " +
        "هیچ راهِ بازگشتی ندارد — و این عمدی است.", true);
    return;
  }
  if(!p.hasEscrow){
    say("«" + esc(p.name) + "» هنوز رمزِ دیتای شخصی‌اش را به کلیدِ ادمین نسپرده. " +
        "این کار خودکار انجام می‌شود، ولی فقط دفعهٔ بعد که خودش رمزش را بگذارد یا عوض کند.", true);
    return;
  }
  openOverlay(`
    <h2>رمز دیتای شخصی — ${esc(p.name)}</h2>
    <p class="sub">عبارتِ عبورِ خودتان را بزنید تا بستهٔ رمزِ او باز شود. همه‌چیز
      داخل همین مرورگر انجام می‌شود؛ نه عبارتِ شما به سرور می‌رود نه رمزِ او.
      <b>محتوای صندوق دست نمی‌خورد</b> — فقط با رمزِ تازه دوباره قفل می‌شود.</p>
    <div class="row">
      <div class="fld"><label>عبارت عبور ادمین</label><input type="password" id="vAdmin"></div>
    </div>
    <div class="row" style="margin-top:10px;">
      <div class="fld"><label>رمز تازهٔ کاربر (خالی = فقط رمز فعلی را نشانم بده)</label>
        <input type="text" id="vNew" dir="ltr"></div>
    </div>
    <div class="ov-acts">
      <button class="btn btn-main" id="vGo">ادامه</button>
      <button class="btn" id="vCancel">بستن</button>
    </div>
    <div class="gate-err" id="vErr"></div>
    <div id="vOut"></div>`);

  document.getElementById("vCancel").onclick = closeOverlay;
  document.getElementById("vGo").onclick = ()=> runVaultReset(slug);
}

async function unwrapEscrowKey(adminPass){
  const k = await api("/escrow-key");
  if(!k.ok || !k.data.priv) throw new Error("کلیدِ ادمین روی سرور نیست.");
  const { salt, iv, cipher } = k.data.priv;
  const key = await keyFrom(adminPass, unb64(salt), ["decrypt"]);
  let pkcs8;
  try{
    pkcs8 = await crypto.subtle.decrypt({ name:"AES-GCM", iv: unb64(iv) }, key, unb64(cipher));
  }catch(e){ throw new Error("عبارتِ عبور درست نیست."); }
  return crypto.subtle.importKey("pkcs8", pkcs8,
    { name:"RSA-OAEP", hash:"SHA-256" }, false, ["decrypt"]);
}

async function runVaultReset(slug){
  const p = find(slug);
  const err = document.getElementById("vErr");
  const out = document.getElementById("vOut");
  const go = document.getElementById("vGo");
  err.textContent = ""; out.innerHTML = "";
  const adminPass = document.getElementById("vAdmin").value;
  const newPass = document.getElementById("vNew").value.trim();
  if(!adminPass){ err.textContent = "عبارت عبور را بزنید."; return; }
  if(newPass && newPass.length < 4){ err.textContent = "رمزِ تازه دست‌کم ۴ حرف."; return; }
  go.disabled = true; go.textContent = "…";
  try{
    const priv = await unwrapEscrowKey(adminPass);

    const e = await api("/planners/" + slug + "/escrow");
    if(!e.ok) throw new Error(e.data.error || "بستهٔ رمزِ این کاربر نیامد.");
    const oldPassBuf = await crypto.subtle.decrypt({ name:"RSA-OAEP" }, priv, unb64(e.data.escrow.cipher));
    const oldPass = new TextDecoder().decode(oldPassBuf);

    if(!newPass){
      out.innerHTML = `<div class="msg msg-ok">رمزِ فعلیِ دیتای شخصیِ «${esc(p.name)}»:
        <br><code>${esc(oldPass)}</code><br>
        چیزی عوض نشد. اگر می‌خواهید رمزِ تازه بگذارید، آن را در کادرِ بالا بنویسید.</div>`;
      go.disabled = false; go.textContent = "ادامه";
      return;
    }

    /* صندوق را با رمزِ فعلی باز و با رمزِ تازه دوباره می‌بندیم. محتوا
       همان است که بود — فقط قفلش عوض می‌شود. */
    const v = await api("/planners/" + slug + "/vault");
    if(!v.ok) throw new Error(v.data.error || "صندوقِ این کاربر نیامد.");
    const vault = v.data.vault;
    if(!vault || !vault.cipher) throw new Error("این کاربر هنوز دیتای شخصی نگذاشته.");
    const oldKey = await keyFrom(oldPass, unb64(vault.salt), ["decrypt"]);
    let plain;
    try{
      plain = await crypto.subtle.decrypt({ name:"AES-GCM", iv: unb64(vault.iv) }, oldKey, unb64(vault.cipher));
    }catch(ex){ throw new Error("بستهٔ رمز با صندوق نمی‌خواند. شاید کاربر بعداً رمزش را بی‌کلیدِ ادمین عوض کرده."); }

    const salt = crypto.getRandomValues(new Uint8Array(16));
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const newKey = await keyFrom(newPass, salt, ["encrypt"]);
    const cipher = await crypto.subtle.encrypt({ name:"AES-GCM", iv }, newKey, plain);

    /* رمزِ تازه را هم دوباره با کلیدِ عمومی می‌پیچیم تا دفعهٔ بعد هم
       همین راه باز باشد. */
    const k = await api("/escrow-key");
    const pub = await crypto.subtle.importKey("jwk", k.data.pub,
      { name:"RSA-OAEP", hash:"SHA-256" }, false, ["encrypt"]);
    const wrapped = await crypto.subtle.encrypt({ name:"RSA-OAEP" }, pub,
      new TextEncoder().encode(newPass));

    const put = await api("/planners/" + slug + "/vault", { method:"PUT", body: JSON.stringify({
      vault: { salt: b64(salt), iv: b64(iv), cipher: b64(cipher) },
      recovery: null,
      escrow: { cipher: b64(wrapped), at: Date.now() }
    })});
    if(!put.ok) throw new Error(put.data.error || "ذخیره نشد.");

    out.innerHTML = `<div class="msg msg-ok">رمزِ دیتای شخصیِ «${esc(p.name)}» عوض شد و
      <b>محتوایش دست‌نخورده ماند</b>. رمزِ تازه:<br><code>${esc(newPass)}</code><br>
      کدِ بازیابیِ قبلی‌اش دیگر کار نمی‌کند؛ به او بگویید یک کدِ تازه بسازد.</div>`;
    go.textContent = "انجام شد";
    loadPlanners();
  }catch(ex){
    err.textContent = ex.message || String(ex);
    go.disabled = false; go.textContent = "ادامه";
  }
}

/* ---------- حذف ---------- */
function openDelete(slug){
  const p = find(slug);
  if(!p) return;
  openOverlay(`
    <h2>حذف «${esc(p.name)}»</h2>
    <p class="sub">این کار برگشت ندارد: خودِ کارتابل، همهٔ داده‌هایش، تاریخچه‌اش و
      دیتای شخصی‌اش پاک می‌شوند. پشتیبان‌های تلگرام سرِ جایشان می‌مانند.</p>
    <div class="row">
      <div class="fld"><label>برای تأیید، <code>${esc(slug)}</code> را تایپ کنید</label>
        <input type="text" id="dSlug" dir="ltr"></div>
    </div>
    <div class="ov-acts">
      <button class="btn btn-danger" id="dGo">حذف کن</button>
      <button class="btn" id="dCancel">بی‌خیال</button>
    </div>
    <div class="gate-err" id="dErr"></div>`);
  document.getElementById("dCancel").onclick = closeOverlay;
  document.getElementById("dGo").onclick = async ()=>{
    const r = await api("/planners/" + slug, { method:"DELETE",
      body: JSON.stringify({ confirm: document.getElementById("dSlug").value.trim() }) });
    if(!r.ok){ document.getElementById("dErr").textContent = r.data.error || "نشد."; return; }
    closeOverlay();
    say("«" + esc(p.name) + "» حذف شد.");
    loadPlanners();
  };
}

/* ---------- کارتابل تازه ---------- */
function setupNew(){
  const name = document.getElementById("nName");
  const slug = document.getElementById("nSlug");
  const kind = document.getElementById("nKind");
  const prev = document.getElementById("nPreview");
  const paint = ()=>{
    document.getElementById("nJobWrap").style.display = kind.value === "gen" ? "" : "none";
    prev.textContent = slug.value.trim()
      ? "آدرسش می‌شود: sensacare.ir/" + slug.value.trim().toLowerCase() : "";
  };
  slug.addEventListener("input", paint);
  kind.addEventListener("change", paint);
  name.addEventListener("input", ()=>{ if(!slug.value.trim()) paint(); });
  setTimeout(paint, 0);

  document.getElementById("nCreate").onclick = async ()=>{
    const btn = document.getElementById("nCreate");
    btn.disabled = true;
    const r = await api("/planners", { method:"POST", body: JSON.stringify({
      name: name.value.trim(),
      slug: slug.value.trim().toLowerCase(),
      kind: kind.value,
      job: kind.value === "gen" ? document.getElementById("nJob").value : "",
      password: document.getElementById("nPass").value.trim()
    })});
    btn.disabled = false;
    if(!r.ok){ say(r.data.error || "نشد.", true); return; }
    name.value = ""; slug.value = ""; document.getElementById("nPass").value = "";
    paint();
    say("کارتابل ساخته شد: <b>sensacare.ir" + esc(r.data.url) + "</b><br>" +
        "رمزِ ورودش:<br><code>" + esc(r.data.password) + "</code><br>" +
        "همین حالا جایی یادداشتش کنید — بعد از بستنِ این پیام دیگر هیچ‌جا نیست.");
    loadPlanners();
    document.querySelector('.tabs button[data-tab="list"]').click();
  };
}

/* ---------- کلیدها ---------- */
function renderEscrowState(){
  document.getElementById("escrowState").innerHTML = DATA.escrowReady
    ? "✅ کلید ساخته شده. کارتابل‌هایی که رمزِ دیتای شخصی‌شان نزد شماست: <b>" +
      DATA.items.filter(p=>p.hasEscrow).length + "</b> از " + DATA.items.length + "."
    : "⚠️ هنوز کلیدی نیست. تا وقتی نباشد، رمزِ فراموش‌شدهٔ دیتای شخصی هیچ راهِ بازگشتی ندارد.";
  document.getElementById("ekGo").textContent = DATA.escrowReady ? "ساختن کلید تازه" : "ساختن کلید";
}

function setupKeys(){
  document.getElementById("apGo").onclick = async ()=>{
    const cur = document.getElementById("apCur").value;
    const np = document.getElementById("apNew").value;
    if(np !== document.getElementById("apNew2").value){ say("تکرار رمز نمی‌خواند.", true); return; }
    if(np.length < 10){ say("رمزِ ادمین دست‌کم ۱۰ حرف باشد.", true); return; }
    const r = await api("/password", { method:"POST", body: JSON.stringify({ current: cur, password: np }) });
    if(!r.ok){ say(r.data.error || "نشد.", true); return; }
    ["apCur","apNew","apNew2"].forEach(i=> document.getElementById(i).value = "");
    say("رمز ادمین عوض شد. بقیهٔ نشست‌ها بسته شدند.");
  };

  document.getElementById("ekGo").onclick = async ()=>{
    const pass = document.getElementById("ekPass").value;
    if(pass.length < 12){ say("عبارتِ عبور دست‌کم ۱۲ حرف باشد.", true); return; }
    if(pass !== document.getElementById("ekPass2").value){ say("تکرار نمی‌خواند.", true); return; }
    if(DATA.escrowReady && !confirm(
        "کلیدِ تازه جایگزینِ کلیدِ فعلی می‌شود.\n\n" +
        "بسته‌هایی که با کلیدِ قبلی پیچیده شده‌اند دیگر باز نمی‌شوند — " +
        "یعنی رمزِ دیتای شخصیِ کاربرهای فعلی از دسترس‌تان خارج می‌شود تا " +
        "وقتی خودشان رمزشان را دوباره بگذارند.\n\nادامه بدهم؟")) return;

    const btn = document.getElementById("ekGo");
    btn.disabled = true; btn.textContent = "در حال ساختن…";
    try{
      const pair = await crypto.subtle.generateKey(
        { name:"RSA-OAEP", modulusLength:2048, publicExponent:new Uint8Array([1,0,1]), hash:"SHA-256" },
        true, ["encrypt","decrypt"]);
      const pub = await crypto.subtle.exportKey("jwk", pair.publicKey);
      const pkcs8 = await crypto.subtle.exportKey("pkcs8", pair.privateKey);
      const salt = crypto.getRandomValues(new Uint8Array(16));
      const iv = crypto.getRandomValues(new Uint8Array(12));
      const key = await keyFrom(pass, salt, ["encrypt"]);
      const cipher = await crypto.subtle.encrypt({ name:"AES-GCM", iv }, key, pkcs8);
      const r = await api("/escrow-key", { method:"POST", body: JSON.stringify({
        pub, priv: { salt: b64(salt), iv: b64(iv), cipher: b64(cipher) },
        replace: !!DATA.escrowReady
      })});
      if(!r.ok) throw new Error(r.data.error || "ذخیره نشد.");
      document.getElementById("ekPass").value = "";
      document.getElementById("ekPass2").value = "";
      say("کلید ساخته و ذخیره شد. عبارتِ عبور را جایی امن نگه دارید — " +
          "بدون آن این کلید هیچ‌وقت باز نمی‌شود.");
      loadPlanners();
    }catch(ex){ say(ex.message || String(ex), true); }
    btn.disabled = false;
    renderEscrowState();
  };
}

/* ---------- سیاهه ---------- */
async function loadLog(){
  const r = await api("/log");
  const items = (r.data && r.data.items) || [];
  const WHAT = { login:"ورود ادمین", create:"ساختن کارتابل", update:"ویرایش",
    delete:"حذف", password:"رمز ورود", "vault-password":"رمز دیتای شخصی",
    "admin-password":"رمز ادمین", "escrow-key":"کلید اضطراری" };
  document.getElementById("logBody").innerHTML = items.length
    ? `<table><thead><tr><th>زمان</th><th>کار</th><th>کارتابل</th><th>توضیح</th></tr></thead>
       <tbody>${items.map(i=>`<tr>
         <td>${esc(faDateTime(i.at))}</td>
         <td>${esc(WHAT[i.what] || i.what)}</td>
         <td class="ltr">${esc(i.slug || "—")}</td>
         <td class="ltr">${esc(i.note || "")}</td></tr>`).join("")}</tbody></table>`
    : `<p class="hint">هنوز چیزی ثبت نشده.</p>`;
}
</script>
</body>
</html>
