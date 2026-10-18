
/* =========================================================================
   PERSONAL VAULT — بخش رمزدار «دیتای شخصی»
   داده‌ها همیشه با AES-256-GCM (کلید مشتق‌شده از رمز عبور با PBKDF2) رمزنگاری
   می‌شوند؛ نسخه‌ی رمزگشایی‌شده فقط در حافظه‌ی مرورگر (RAM) نگه‌داری می‌شود و
   هرگز به state، localStorage یا فایل اکسل نوشته نمی‌شود. اگر رمز را فراموش
   کنید، هیچ راه بازیابی‌ای وجود ندارد — این یعنی هیچ درِ پشتی‌ای هم نیست.
   ========================================================================= */
let personalUnlocked = false;
let personalCryptoKey = null;   // CryptoKey — فقط در حافظه، هرگز ذخیره نمی‌شود
let personalVaultPlain = null;  // { credentials:[], installments:[] } — فقط در حافظه
let personalActiveTab = "creds";
let personalShowPw = new Set();
let personalBusy = false;

function b64FromBuf(buf){
  const bytes = new Uint8Array(buf);
  let bin = "";
  for(let i=0;i<bytes.length;i++) bin += String.fromCharCode(bytes[i]);
  return btoa(bin);
}
function bufFromB64(b64){
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for(let i=0;i<bin.length;i++) bytes[i] = bin.charCodeAt(i);
  return bytes.buffer;
}
async function derivePersonalKey(password, saltBytes){
  const enc = new TextEncoder();
  const baseKey = await crypto.subtle.importKey("raw", enc.encode(password), "PBKDF2", false, ["deriveKey"]);
  return crypto.subtle.deriveKey(
    { name:"PBKDF2", salt:saltBytes, iterations:150000, hash:"SHA-256" },
    baseKey, { name:"AES-GCM", length:256 }, false, ["encrypt","decrypt"]
  );
}
async function encryptPersonalVault(){
  if(!personalCryptoKey || !personalVaultPlain) return;
  const enc = new TextEncoder();
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const data = enc.encode(JSON.stringify(personalVaultPlain));
  const cipherBuf = await crypto.subtle.encrypt({ name:"AES-GCM", iv }, personalCryptoKey, data);
  state.personalVault.iv = b64FromBuf(iv);
  state.personalVault.cipher = b64FromBuf(cipherBuf);
  /* تاریخ‌های سررسید بیرونِ صندوق هم همین‌جا تازه می‌شوند: زنگوله
     کلیدِ صندوق را ندارد و تنها راهِ خبر دادنش همین‌هاست. */
  refreshVaultDue();
  scheduleSave();
  savePersonalSheet();
}

/* ---------- کلیدِ اضطراریِ ادمین ----------
   اگر ادمین کلیدی ساخته باشد، رمزِ این صندوق با کلیدِ عمومیِ او پیچیده
   و همان‌جا روی سرور گذاشته می‌شود. با کلیدِ عمومی فقط می‌شود پیچید؛
   باز کردنش رمزِ ادمین را می‌خواهد که برای این کار هیچ‌وقت به سرور نمی‌رسد.

   اگر ادمین کلیدی نساخته باشد یا اینترنت نباشد، بی‌سر و صدا رد می‌شود:
   این یک تورِ اضافه است، نه شرطِ کار کردنِ صندوق. */
async function escrowVaultPassword(password){
  if(window.KARTABL_OFFLINE) return false;
  try{
    const r = await apiCall("/escrow-pub");
    const jwk = r.ok && r.data && r.data.pub;
    if(!jwk) return false;
    const pub = await crypto.subtle.importKey("jwk", jwk,
      { name:"RSA-OAEP", hash:"SHA-256" }, false, ["encrypt"]);
    const buf = await crypto.subtle.encrypt({ name:"RSA-OAEP" }, pub,
      new TextEncoder().encode(password));
    /* نشانهٔ کلید را هم می‌فرستیم تا بعداً معلوم باشد این پاکت با کدام
       کلیدِ ادمین پیچیده شده. */
    const put = await apiCall("/escrow", { method:"POST",
      body: JSON.stringify({ bundle: { cipher: b64FromBuf(buf), at: Date.now(),
                                       fp: (r.data.fp || "") } }) });
    return !!put.ok;
  }catch(e){ return false; }
}

/* اگر ادمین کلیدِ اضطراری را عوض کرده باشد، پاکتِ قبلیِ این کاربر با
   کلیدِ قدیمی پیچیده است و دیگر باز نمی‌شود. همان لحظه‌ای که کاربر
   صندوقش را باز می‌کند رمز در دست است، پس بی‌سر و صدا پاکتِ تازه
   می‌سپاریم — نه پیامی، نه کاری که کاربر باید بکند.

   فقط وقتی پاکت با کلیدِ فعلی نمی‌خواند این کار انجام می‌شود، وگرنه
   هر بار باز کردنِ صندوق یک نوشتنِ بی‌دلیل بود. */
async function reEscrowIfStale(password){
  if(window.KARTABL_OFFLINE) return false;
  try{
    const r = await apiCall("/escrow-pub");
    if(!(r.ok && r.data && r.data.pub)) return false;
    const fp = r.data.fp || "";
    const mine = r.data.mine;
    if(mine && mine.fp && fp && mine.fp === fp) return false;
    return await escrowVaultPassword(password);
  }catch(e){ return false; }
}
async function createPersonalPassword(password){
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const key = await derivePersonalKey(password, salt);
  state.personalVault = { salt: b64FromBuf(salt), iv:"", cipher:"" };
  personalCryptoKey = key;
  personalVaultPlain = { credentials: [], installments: [], sections: {} };
  personalUnlocked = true;
  await encryptPersonalVault();
  escrowVaultPassword(password);
  renderPersonalView();
}
async function tryUnlockPersonal(password){
  if(!state.personalVault || !state.personalVault.cipher){ return createPersonalPassword(password); }
  try{
    const salt = bufFromB64(state.personalVault.salt);
    const key = await derivePersonalKey(password, salt);
    const iv = bufFromB64(state.personalVault.iv);
    const cipher = bufFromB64(state.personalVault.cipher);
    const plainBuf = await crypto.subtle.decrypt({ name:"AES-GCM", iv:new Uint8Array(iv) }, key, cipher);
    const dec = new TextDecoder();
    const parsed = JSON.parse(dec.decode(plainBuf));
    personalCryptoKey = key;
    /* هرچه در صندوق بود برمی‌گردد، نه فقط کلیدهایی که این نسخه می‌شناسد:
       اگر بخشی را ادمین خاموش کرده باشد، محتوایش این‌جا باید سالم بماند
       وگرنه اولین باز و بسته‌کردنِ صندوق پاکش می‌کند. */
    personalVaultPlain = Object.assign({}, parsed);
    if(!Array.isArray(personalVaultPlain.credentials)) personalVaultPlain.credentials = [];
    if(!Array.isArray(personalVaultPlain.installments)) personalVaultPlain.installments = [];
    if(!personalVaultPlain.sections || typeof personalVaultPlain.sections !== "object") personalVaultPlain.sections = {};
    personalUnlocked = true;
    refreshVaultDue();
    renderPersonalView();
    reEscrowIfStale(password);
  }catch(e){
    const err = document.getElementById("personalLockError");
    if(err) err.textContent = "❌ رمز عبور اشتباه است.";
  }
}
function lockPersonal(){
  personalUnlocked = false;
  personalCryptoKey = null;
  personalVaultPlain = null;
  personalShowPw = new Set();
  renderPersonalView();
}
async function resetPersonalVault(){
  if(!confirm("با این کار همه‌ی داده‌های این بخش (شرکت‌ها و اقساط) برای همیشه پاک می‌شود و قابل بازگشت نیست. مطمئنید؟")) return;
  state.personalVault = null;
  state.personalRecovery = null;   /* پاکتِ بازیابی هم با صندوق می‌رود */
  state.personalDue = [];          /* و تاریخ‌های سررسید که بیرون نشسته بودند */
  lockPersonal();
  savePersonalSheet();
}

function savePersonalSheet(){
  /* آینهٔ اکسل اختیاری است و کتابخانه‌اش تنبل بار می‌شود. بدون این محافظ،
     ذخیرهٔ صندوق یک استثنای بی‌صاحب می‌انداخت: خودِ داده سرِ جایش ذخیره
     شده بود (scheduleSave قبلش اجرا می‌شود) و فقط همین آینه عقب می‌ماند،
     ولی هیچ‌کس خبردار نمی‌شد چون هیچ‌کس این promise را نمی‌گرفت. */
  if(typeof XLSX === "undefined") return;
  const blob = state.personalVault ? JSON.stringify(state.personalVault) : "";
  ensureDbWorkbook().Sheets["PersonalVault"] = XLSX.utils.aoa_to_sheet([["EncryptedBlob"],[blob]]);
  scheduleDbWrite();
}
function parsePersonalVaultSheet(wb){
  const rows = sheetToMatrix(wb, "PersonalVault");
  if(!rows || !rows[1] || !rows[1][0]) return null;
  try{ return JSON.parse(rows[1][0]); }catch(e){ return null; }
}

/* ---------- بازیابیِ رمزِ «دیتای شخصی» ----------
   سرور کلیدِ این بخش را ندارد و نمی‌تواند رمزِ تازه بسازد؛ هر رمزِ تازه‌ای
   فقط یک صندوقِ خالی باز می‌کند. پس «فراموشی» این‌جا فقط با چیزی کار
   می‌کند که از قبل خودتان ساخته باشید:

   موقع ساختنِ کد، همین‌جا در مرورگر یک کد تصادفی ساخته می‌شود، رمزِ فعلی
   با آن قفل می‌شود، و پاکتِ قفل‌شده کنار بقیهٔ داده می‌ماند. خودِ کد
   هیچ‌جا ذخیره نمی‌شود و فقط یک بار از سرور رد می‌شود تا به تلگرام برسد.
   یعنی هر کس فقط به دادهٔ سرور برسد، پاکت را دارد و کلیدش را ندارد. */

const VAULT_CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";

function makeVaultRecoveryCode(groups, per){
  groups = groups || 4; per = per || 5;
  const need = groups * per;
  /* باقی‌ماندهٔ ساده شانسِ حرف‌های اول را بیشتر می‌کند؛ بایت‌های اضافه را
     دور می‌ریزیم تا همه برابر باشند. */
  const limit = 256 - (256 % VAULT_CODE_ALPHABET.length);
  const out = [];
  while(out.length < need){
    for(const b of crypto.getRandomValues(new Uint8Array(need))){
      if(b >= limit) continue;
      out.push(VAULT_CODE_ALPHABET[b % VAULT_CODE_ALPHABET.length]);
      if(out.length === need) break;
    }
  }
  const parts = [];
  for(let i=0;i<groups;i++) parts.push(out.slice(i*per,(i+1)*per).join(""));
  return parts.join("-");
}

async function wrapVaultPassword(password, code){
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const key = await derivePersonalKey(code, salt);   /* همان PBKDF2 با ۱۵۰٬۰۰۰ دور */
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const cipher = await crypto.subtle.encrypt({ name:"AES-GCM", iv }, key,
    new TextEncoder().encode(password));
  return { salt: b64FromBuf(salt), iv: b64FromBuf(iv), cipher: b64FromBuf(cipher), at: Date.now() };
}

async function unwrapVaultPassword(envelope, code){
  const key = await derivePersonalKey(code, bufFromB64(envelope.salt));
  const buf = await crypto.subtle.decrypt(
    { name:"AES-GCM", iv:new Uint8Array(bufFromB64(envelope.iv)) }, key, bufFromB64(envelope.cipher));
  return new TextDecoder().decode(buf);
}

/* رمز را واقعاً امتحان می‌کنیم، نه اینکه حرفش را باور کنیم */
async function vaultPasswordWorks(password){
  if(!state.personalVault || !state.personalVault.cipher) return false;
  try{
    const key = await derivePersonalKey(password, bufFromB64(state.personalVault.salt));
    await crypto.subtle.decrypt(
      { name:"AES-GCM", iv:new Uint8Array(bufFromB64(state.personalVault.iv)) },
      key, bufFromB64(state.personalVault.cipher));
    return true;
  }catch(e){ return false; }
}

async function sendVaultRecoveryCode(code){
  const r = await apiCall("/vault/recovery", { method:"POST", body: JSON.stringify({ code }) });
  if(!r.ok) throw new Error(r.data.error || "به تلگرام نرسید.");
}

/* ساختنِ کدِ تازه — از داخلِ صندوقِ باز. رمز را دوباره می‌پرسیم چون
   خودمان نگهش نداشته‌ایم و برای قفل کردنش لازم است. */
async function armVaultRecovery(){
  if(window.KARTABL_OFFLINE){ alert("در نسخهٔ پشتیبان به سرور وصل نیستیم، پس کد فرستاده نمی‌شود."); return; }
  const had = !!(state.personalRecovery && state.personalRecovery.cipher);
  if(!confirm(had
    ? "یک کد بازیابیِ تازه ساخته و به تلگرام فرستاده می‌شود.\nکد قبلی از کار می‌افتد.\n\nادامه بدهم؟"
    : "یک کد بازیابی ساخته و به همان گفتگوی تلگرامیِ پشتیبان‌ها فرستاده می‌شود.\nاگر روزی رمز این بخش را فراموش کردید، با همان کد باز می‌شود و داده‌ها سرِ جایشان می‌مانند.\n\nادامه بدهم؟")) return;

  const pw = prompt("برای ساختن کد، رمزِ فعلیِ همین بخش را وارد کنید:");
  if(pw === null) return;
  if(!(await vaultPasswordWorks(pw))){ alert("❌ رمز درست نیست."); return; }

  try{
    const code = makeVaultRecoveryCode();
    const envelope = await wrapVaultPassword(pw, code);
    /* اول فرستادن، بعد ذخیره: اگر تلگرام نرفت، پاکتی که کدش به دستتان
       نرسیده روی داده نمی‌نشیند. */
    await sendVaultRecoveryCode(code);
    state.personalRecovery = envelope;
    scheduleSave();
    renderPersonalView();
    alert("✓ کد بازیابی به تلگرام رفت. آن پیام را نگه دارید.");
  }catch(e){
    alert("نشد — " + (e.message || e));
  }
}

/* بازکردن با کد — از صفحهٔ قفل */
async function recoverVaultWithCode(){
  const env = state.personalRecovery;
  if(!env || !env.cipher){ alert("کد بازیابی‌ای برای این بخش ساخته نشده."); return; }
  const code = prompt("کد بازیابی را از پیام تلگرام این‌جا وارد کنید:");
  if(code === null) return;
  let pw;
  try{
    pw = await unwrapVaultPassword(env, code.trim());
  }catch(e){
    const err = document.getElementById("personalLockError");
    if(err) err.textContent = "❌ این کد باز نکرد. دوباره از روی پیام تلگرام نگاه کنید.";
    return;
  }
  await tryUnlockPersonal(pw);
  if(personalUnlocked){
    alert("✓ باز شد و داده‌ها سرِ جایشان هستند.\nحالا یک رمز تازه بگذارید که یادتان بماند.");
    openChangePersonalPassword();
  }
}

/* ---------------- بنرِ سررسید، داخلِ دیتای شخصی ----------------
   زنگوله بیرون فقط می‌گوید «یک سررسید نزدیک است»؛ این‌جا — که رمز
   خورده و صندوق باز است — می‌گوید کدام، کِی، و چند. از هر ردیفش
   می‌شود پرید سرِ خودِ همان قسط، حتی اگر در بخشِ دیگری باشد. */
function vaultDueBanner(){
  let list = [];
  try{ list = vaultDueSoonList(); }catch(e){ return ""; }
  if(!list.length) return "";
  const when = x => x.late ? "عقب‌افتاده"
    : x.days === 0 ? "همین امروز" : x.days === 1 ? "فردا" : fa(x.days) + " روز مانده";
  return `
    <div class="due-banner${list.some(x=> x.late) ? " has-late" : ""}">
      <div class="db-head">
        <h4>🔔 سررسیدهای نزدیک</h4>
        <span>${fa(list.length)} مورد — تا ${fa(VAULT_DUE_DAYS)} روز آینده و عقب‌افتاده‌ها</span>
      </div>
      <div class="db-list">
        ${list.map(x => `
          <button type="button" class="db-item${x.late ? " late" : ""}"
                  data-due-sec="${escapeHtml(x.secId)}" data-due-plan="${x.pIdx}" data-due-i="${x.i}"
                  title="رفتن به همین مورد">
            <span class="db-k">${PLAN_KINDS[x.kind].icon} ${PLAN_KINDS[x.kind].label}</span>
            <span class="db-t">${escapeHtml(x.title)}</span>
            <span class="db-d">${formatJalaliYMD(x.y, x.m, x.d)}</span>
            <span class="db-a">${planMoney(x.amount)} تومان</span>
            <span class="db-f">${when(x)}</span>
          </button>`).join("")}
      </div>
    </div>`;
}

/* از بنرِ سررسید، پریدن سرِ خودِ آن قسط — حتی اگر در بخشِ دیگری باشد */
function wireDueBanner(root){
  (root || document).querySelectorAll("[data-due-sec]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const sid = btn.getAttribute("data-due-sec");
      const pIdx = btn.getAttribute("data-due-plan"), i = btn.getAttribute("data-due-i");
      if(personalActiveTab !== sid){ personalActiveTab = sid; renderPersonalView(); }
      setTimeout(()=> flashInstRow(pIdx, i), 120);
    });
  });
}

/* بنر را تنها خودش از نو می‌کشد. با هر «پرداخت شد» یا هر چکِ تازه،
   سررسیدها عوض می‌شوند؛ تا دیروز بنر همان‌طور می‌ماند تا کاربر از
   بخش بیرون و دوباره داخل می‌شد. بازسازیِ همهٔ صفحه هم راهش نبود:
   وسطِ کار، سربرگ و جای صفحه می‌پرید. */
function paintDueBanner(){
  const wrap = document.getElementById("personalWrap");
  if(!wrap || !personalUnlocked) return;
  const old = wrap.querySelector(".due-banner");
  if(old) old.remove();
  const html = vaultDueBanner();
  if(!html) return;
  const tmp = document.createElement("div");
  tmp.innerHTML = html;
  const node = tmp.firstElementChild;
  if(!node) return;
  wrap.insertBefore(node, wrap.firstChild);
  wireDueBanner(node);
}

function renderPersonalView(){
  const wrap = document.getElementById("personalWrap");
  if(!wrap) return;

  if(!personalUnlocked){
    const hasVault = !!(state.personalVault && state.personalVault.cipher);
    wrap.innerHTML = `
      <div class="lock-screen">
        <div class="ls-icon">🔒</div>
        <h3>${hasVault ? "ورود به دیتای شخصی" : "تعیین رمز عبور برای دیتای شخصی"}</h3>
        <p>${hasVault
          ? "این بخش رمزنگاری‌شده است. برای مشاهده، رمز عبور را وارد کنید."
          : "این اولین باری است که به این بخش سر می‌زنید. یک رمز عبور انتخاب کنید — این رمز، کلید رمزنگاری داده‌هاست و در هیچ‌جا ذخیره نمی‌شود. بعد از ورود، حتماً از دکمهٔ «ساختن کد بازیابی» یک کد بگیرید؛ وگرنه اگر رمز را فراموش کنید هیچ راهی برای باز کردن این بخش نمی‌ماند."}</p>
        <input type="password" id="personalPwInput" placeholder="رمز عبور" autocomplete="off">
        ${hasVault ? "" : `<input type="password" id="personalPwInput2" placeholder="تکرار رمز عبور" autocomplete="off">`}
        <button type="button" id="personalUnlockBtn">${hasVault ? "🔓 ورود" : "✅ تعیین رمز و ادامه"}</button>
        <div class="ls-error" id="personalLockError"></div>
        ${hasVault && state.personalRecovery && state.personalRecovery.cipher
          ? `<button type="button" class="ls-recover" id="personalRecoverBtn">🔐 رمز را فراموش کرده‌ام — کد بازیابی دارم</button>` : ""}
        ${hasVault ? `<button type="button" class="ls-reset" id="personalResetBtn">${state.personalRecovery && state.personalRecovery.cipher ? "پاک‌سازی کامل این بخش" : "رمز را فراموش کرده‌ام — پاک‌سازی کامل این بخش"}</button>` : ""}
      </div>`;

    const doUnlock = ()=>{
      const pw = document.getElementById("personalPwInput").value;
      if(!pw){ document.getElementById("personalLockError").textContent = "رمز عبور را وارد کنید."; return; }
      if(!hasVault){
        const pw2 = document.getElementById("personalPwInput2").value;
        if(pw.length < 4){ document.getElementById("personalLockError").textContent = "رمز عبور باید حداقل ۴ کاراکتر باشد."; return; }
        if(pw !== pw2){ document.getElementById("personalLockError").textContent = "❌ تکرار رمز عبور مطابقت ندارد."; return; }
      }
      document.getElementById("personalUnlockBtn").disabled = true;
      tryUnlockPersonal(pw);
    };
    document.getElementById("personalUnlockBtn").addEventListener("click", doUnlock);
    wrap.querySelectorAll("#personalPwInput, #personalPwInput2").forEach(inp=>{
      inp.addEventListener("keydown", e=>{ if(e.key==="Enter") doUnlock(); });
    });
    const recoverBtn = document.getElementById("personalRecoverBtn");
    if(recoverBtn) recoverBtn.addEventListener("click", recoverVaultWithCode);
    const resetBtn = document.getElementById("personalResetBtn");
    if(resetBtn) resetBtn.addEventListener("click", resetPersonalVault);
    return;
  }

  // ---- Unlocked content ----
  /* اگر ادمین بخشی را خاموش کرده و همان باز بود، می‌رویم سراغ اولی. */
  const secs = vaultSections();
  if(!secs.some(s=> s.id === personalActiveTab)) personalActiveTab = secs[0].id;
  wrap.innerHTML = vaultDueBanner() + `
    <div class="personal-toolbar">
      <div class="personal-tabs">
        ${vaultSections().map(s=>`<button type="button" data-ptab="${escapeHtml(s.id)}" class="${personalActiveTab===s.id?'active':''}">${VAULT_TYPE_ICON[s.type]||'📋'} ${escapeHtml(s.title||s.id)}</button>`).join("")}
      </div>
      <div style="display:flex; gap:8px;">
        <button type="button" class="btn-lock-now" id="personalRecoveryBtn">${state.personalRecovery && state.personalRecovery.cipher ? "🔐 کد بازیابی تازه" : "🔐 ساختن کد بازیابی"}</button>
        <button type="button" class="btn-lock-now" id="personalChangePwBtn">🔑 تغییر رمز</button>
        <button type="button" class="btn-lock-now" id="personalLockBtn">🔒 قفل کن</button>
      </div>
    </div>
    <div id="personalTabBody"></div>
  `;
  wrap.querySelectorAll("[data-ptab]").forEach(btn=>{
    btn.addEventListener("click", ()=>{ personalActiveTab = btn.getAttribute("data-ptab"); renderPersonalView(); });
  });
  wireDueBanner(wrap);
  document.getElementById("personalLockBtn").addEventListener("click", lockPersonal);
  document.getElementById("personalChangePwBtn").addEventListener("click", openChangePersonalPassword);
  document.getElementById("personalRecoveryBtn").addEventListener("click", armVaultRecovery);

  personalCurrentSection = secs.find(s=> s.id === personalActiveTab) || secs[0];
  const stype = personalCurrentSection.type;
  if(stype === "creds") renderPersonalCreds();
  else if(stype === "inst") renderPersonalInstallments();
  else if(stype === "exp") renderPersonalExpenses(personalCurrentSection);
  else renderPersonalGrid(personalCurrentSection);
}

function openChangePersonalPassword(){
  const np = prompt("رمز عبور جدید را وارد کنید (حداقل ۴ کاراکتر):");
  if(np===null) return;
  if(np.length < 4){ alert("رمز عبور باید حداقل ۴ کاراکتر باشد."); return; }
  const np2 = prompt("رمز عبور جدید را دوباره وارد کنید:");
  if(np !== np2){ alert("تکرار رمز عبور مطابقت نداشت."); return; }
  (async ()=>{
    const salt = crypto.getRandomValues(new Uint8Array(16));
    personalCryptoKey = await derivePersonalKey(np, salt);
    state.personalVault.salt = b64FromBuf(salt);
    await encryptPersonalVault();
    escrowVaultPassword(np);
    /* پاکتِ بازیابی رمزِ قبلی را قفل کرده بود، پس با عوض شدن رمز دیگر به
       درد نمی‌خورد. یا تازه‌اش می‌کنیم یا صریح می‌گوییم که خاموش شد —
       بدترین حالت این بود که کاربر خیال کند هنوز کد دارد. */
    if(state.personalRecovery && state.personalRecovery.cipher && !window.KARTABL_OFFLINE){
      try{
        const code = makeVaultRecoveryCode();
        const envelope = await wrapVaultPassword(np, code);
        await sendVaultRecoveryCode(code);
        state.personalRecovery = envelope;
        scheduleSave();
        alert("✓ رمز عوض شد. کد بازیابیِ تازه هم به تلگرام رفت؛ کد قبلی دیگر کار نمی‌کند.");
      }catch(e){
        state.personalRecovery = null;
        scheduleSave();
        alert("✓ رمز عوض شد.\n\n⚠️ ولی کد بازیابیِ تازه به تلگرام نرفت (" + (e.message||e) + ")، پس بازیابی خاموش شد. از دکمهٔ «ساختن کد بازیابی» دوباره راهش بیندازید.");
      }
      renderPersonalView();
    } else {
      alert("✓ رمز عبور با موفقیت تغییر کرد.");
    }
  })();
}


/* ---------------- بخش‌های «دیتای شخصی» ----------------
   کدام بخش‌ها برای این کاربر باز باشد را ادمین تعیین می‌کند و سرور
   همان فهرست را داخل صفحه می‌گذارد. خاموش‌کردنِ یک بخش فقط آن را از
   چشم پنهان می‌کند؛ محتوایش دست‌نخورده داخل همان صندوقِ رمزدار می‌ماند
   و با روشن‌کردنِ دوباره برمی‌گردد. */

const VAULT_DEFAULT_SECTIONS = [
  { id:"creds", type:"creds", title:"شرکت‌های من" },
  { id:"inst",  type:"inst",  title:"اقساط" }
];
const VAULT_TYPE_ICON = { creds:"🏢", inst:"💳", contacts:"📞", exp:"🧾", table:"📋" };
const VAULT_CONTACT_COLS = ["نام", "سمت / نسبت", "تلفن", "تلفن دوم", "ایمیل", "یادداشت"];

let personalCurrentSection = null;

function vaultSections(){
  const list = Array.isArray(window.KARTABL_VAULT) ? window.KARTABL_VAULT : [];
  const clean = list.filter(s=> s && s.id && s.type && VAULT_TYPE_ICON[s.type]);
  return clean.length ? clean : VAULT_DEFAULT_SECTIONS;
}

/* آرایهٔ همان بخش، داخلِ نسخهٔ رمزگشایی‌شده. دو بخشِ قدیمی کلیدِ قدیمیِ
   خودشان را نگه می‌دارند تا صندوق‌های موجود بدون دست‌کاری باز شوند. */
function vaultRows(sec){
  if(!personalVaultPlain || !sec) return [];
  if(sec.id === "creds"){ if(!personalVaultPlain.credentials) personalVaultPlain.credentials = []; return personalVaultPlain.credentials; }
  if(sec.id === "inst"){  if(!personalVaultPlain.installments) personalVaultPlain.installments = []; return personalVaultPlain.installments; }
  if(!personalVaultPlain.sections) personalVaultPlain.sections = {};
  return personalVaultPlain.sections[sec.id] || (personalVaultPlain.sections[sec.id] = []);
}
function credRows(){ return vaultRows(personalCurrentSection); }
function instRows(){ return vaultRows(personalCurrentSection); }

function vaultGridCols(sec){
  if(sec.type === "contacts") return VAULT_CONTACT_COLS;
  const cols = Array.isArray(sec.cols) ? sec.cols.filter(c=> String(c||"").trim()) : [];
  return cols.length ? cols : ["عنوان", "توضیح", "یادداشت"];
}

/* جدولِ ساده و ویرایش‌پذیر — هم برای «دفتر تلفن» و هم برای جدول‌هایی
   که ادمین ستون‌هایشان را خودش تعیین کرده. ستون‌ها با شماره ذخیره
   می‌شوند نه با نام، تا عوض‌کردنِ نامِ ستون داده را گم نکند. */
/* ---------------- خواندن از اکسل، داخلِ دیتای شخصی ----------------
   ستون‌ها با جای‌شان می‌نشینند، نه با نامشان: ستونِ اول به ستونِ اول
   این بخش، دومی به دومی و همین‌طور تا آخر. اگر ردیفِ اول سربرگ باشد
   خودش کنار گذاشته می‌شود.

   نکتهٔ امنیتی: این فایل هیچ‌وقت به سرور نمی‌رود. همین‌جا در مرورگر
   خوانده می‌شود و نتیجه‌اش با کلیدِ خودتان رمز می‌شود — همان مسیری که
   بقیهٔ دیتای شخصی می‌رود. */
async function importVaultGridFromXlsx(sec){
  if(xlsxOff() || !sec) return;
  const cols = vaultGridCols(sec);
  const file = await pickFile();
  if(!file) return;
  const wb = await readWorkbook(file);
  if(!wb) return;

  const rows = vaultRows(sec);
  let added = 0, sheets = 0;
  for(const name of wb.SheetNames){
    const list = sheetRows(wb, name);
    if(!list.length) continue;
    sheets++;
    let start = looksLikeHeader(list[0], cols) ? 1 : 0;
    for(let i = start; i < list.length; i++){
      const r = list[i];
      const obj = {};
      for(let ci = 0; ci < cols.length; ci++){
        const v = r[ci];
        obj["c" + ci] = v == null ? "" : String(v).trim();
      }
      /* اگر همهٔ ستون‌های این بخش خالی درآمدند، ردیف را نمی‌سازیم —
         وگرنه یک فایلِ پهن‌تر، ده‌ها ردیفِ خالی اضافه می‌کند. */
      if(Object.values(obj).every(v=> v === "")) continue;
      rows.push(obj);
      added++;
    }
  }
  if(!added){
    alert("چیزی برای افزودن پیدا نشد. ستون‌های فایل باید به ترتیبِ ستون‌های همین بخش باشند.");
    return;
  }
  await encryptPersonalVault();
  renderPersonalView();
  alert("✓ " + toPersianDigits(added) + " ردیف از " + toPersianDigits(sheets) +
        " برگه خوانده شد و رمز شد.\n\nفایل دیگر لازم نیست؛ داده داخلِ کارتابل نشست.");
}

/* ---------- پهنای ستون‌های دیتای شخصی ----------
   ستون‌ها تا حالا همه یک اندازه درمی‌آمدند، چون کادرِ متن پهنای
   پیش‌فرضِ خودش را دارد و به محتوا کاری ندارد: «ردیف» با یک رقم همان‌قدر
   جا می‌گرفت که «توضیح» با یک بند متن.

   دو چیز با هم:
     • ستون خودش به اندازهٔ محتوایش باز می‌شود — با اندازه‌گیریِ واقعیِ
       متن، نه شمردنِ نویسه‌ها: در فارسی عرضِ نویسه‌ها یکی نیست و
       شمردن، «الف» و «ش» را هم‌اندازه حساب می‌کند.
     • و اگر خوشتان نیامد، لبهٔ ستون را بکشید. همان را یادش می‌ماند.

   پهنا راز نیست، پس در localStorage می‌نشیند نه داخلِ بخشِ رمزشده —
   وگرنه هر بار کشیدنِ یک ستون، کلِ دیتای شخصی دوباره رمز می‌شد. */
const PG_MIN = 58, PG_MAX = 420;
let pgMeter = null;
function pgTextWidth(t, bold){
  if(!pgMeter) pgMeter = document.createElement("canvas").getContext("2d");
  pgMeter.font = (bold ? "600 " : "") + "12.5px " + getComputedStyle(document.body).fontFamily;
  return pgMeter.measureText(String(t == null ? "" : t)).width;
}
const pgKey = sec => STORE_KEY + ":pgw:" + ((sec && sec.id) || "");
function pgSavedWidths(sec){
  try{
    const r = JSON.parse(localStorage.getItem(pgKey(sec)) || "null");
    return (r && typeof r === "object") ? r : {};
  }catch(e){ return {}; }
}
function pgSaveWidth(sec, ci, w){
  const all = pgSavedWidths(sec);
  all["c" + ci] = Math.round(w);
  try{ localStorage.setItem(pgKey(sec), JSON.stringify(all)); }catch(e){}
}
function pgClearWidths(sec){
  try{ localStorage.removeItem(pgKey(sec)); }catch(e){}
}
/* پهنای هر ستون: بلندترین چیزی که داخلش هست، با سقف و کف. سقف لازم
   است وگرنه یک یادداشتِ بلند، بقیهٔ جدول را از صفحه بیرون می‌اندازد. */
function pgWidths(sec, cols, rows){
  const saved = pgSavedWidths(sec);
  return cols.map((c, ci)=>{
    if(saved["c" + ci]) return Math.min(PG_MAX * 2, Math.max(24, saved["c" + ci]));
    let w = pgTextWidth(c, true);
    for(const r of rows){
      const v = r["c" + ci];
      if(v) w = Math.max(w, pgTextWidth(v));
    }
    return Math.round(Math.min(PG_MAX, Math.max(PG_MIN, w + 26)));
  });
}
/* کشیدنِ لبهٔ ستون. صفحه راست‌به‌چپ است، پس لبهٔ پایانیِ هر ستون سمتِ
   چپش می‌افتد و بردنِ موشواره به چپ یعنی پهن‌تر. */
function pgWireResize(sec, table){
  table.querySelectorAll(".pg-grip").forEach(g=>{
    g.addEventListener("mousedown", e=>{
      e.preventDefault();
      const ci = parseInt(g.getAttribute("data-ci"), 10);
      const col = table.querySelector('col[data-ci="' + ci + '"]');
      if(!col) return;
      const x0 = e.clientX, w0 = col.offsetWidth || parseInt(col.style.width, 10) || PG_MIN;
      document.body.style.cursor = "col-resize";
      const move = ev=>{
        const w = Math.max(24, w0 + (x0 - ev.clientX));
        col.style.width = w + "px";
      };
      const up = ()=>{
        document.removeEventListener("mousemove", move);
        document.removeEventListener("mouseup", up);
        document.body.style.cursor = "";
        pgSaveWidth(sec, ci, parseInt(col.style.width, 10) || w0);
      };
      document.addEventListener("mousemove", move);
      document.addEventListener("mouseup", up);
    });
  });
}

function renderPersonalGrid(sec){
  const body = document.getElementById("personalTabBody");
  if(!body) return;
  const cols = vaultGridCols(sec);
  const rows = vaultRows(sec);

  const widths = pgWidths(sec, cols, rows);
  /* colgroup + table-layout:fixed تنها راهی است که پهنای ستون واقعاً
     اعمال شود؛ بدون آن مرورگر خودش تصمیم می‌گیرد و کادرهای متن همه را
     هم‌اندازه می‌کنند. */
  const colsHtml = cols.map((c, ci)=>`<col data-ci="${ci}" style="width:${widths[ci]}px">`).join("")
    + `<col style="width:34px">`;
  const head = cols.map((c, ci)=>
      `<th><span class="pg-grip" data-ci="${ci}" title="برای تغییر پهنا بکشید"></span>${escapeHtml(c)}</th>`
    ).join("") + `<th></th>`;
  const bodyHtml = rows.map((r, i)=>
    "<tr>" + cols.map((c, ci)=>
      `<td><input type="text" class="pg-cell" data-row="${i}" data-col="c${ci}"
         value="${escapeHtml(r["c"+ci]||"")}" placeholder="${escapeHtml(c)}"></td>`).join("") +
    `<td><button type="button" class="btn-del" data-pg-del="${i}" title="حذف این ردیف">✕</button></td></tr>`
  ).join("");

  body.innerHTML = `
    <div class="panel" style="padding:14px;">
      <div class="tbl-wrap">
        <table class="pg-tab">
          <colgroup>${colsHtml}</colgroup>
          <thead><tr>${head}</tr></thead>
          <tbody>${bodyHtml || `<tr><td colspan="${cols.length+1}" style="color:var(--ink-faint); font-size:12.5px; text-align:center; padding:14px;">هنوز چیزی ثبت نشده.</td></tr>`}</tbody>
        </table>
      </div>
      <div style="display:flex; gap:8px; flex-wrap:wrap; margin-top:10px;">
        <button type="button" class="btn btn-brass btn-sm" id="pgAddRow">＋ افزودن ردیف</button>
        <button type="button" class="btn btn-ghost btn-sm" id="pgAutoW"
                title="پهنای ستون‌ها را دوباره از روی محتوا حساب کن">↔ پهنای خودکار</button>
        ${xlsxOff() ? "" : '<button type="button" class="btn btn-ghost btn-sm" id="pgImportXlsx" title="ستون‌ها به ترتیب می‌نشینند">⬆ خواندن از اکسل</button>'}
      </div>
    </div>`;

  const pgImp = document.getElementById("pgImportXlsx");
  if(pgImp) pgImp.addEventListener("click", ()=> importVaultGridFromXlsx(sec));

  const pgTab = body.querySelector(".pg-tab");
  if(pgTab) pgWireResize(sec, pgTab);
  const pgAuto = document.getElementById("pgAutoW");
  if(pgAuto) pgAuto.addEventListener("click", ()=>{ pgClearWidths(sec); renderPersonalGrid(sec); });

  body.querySelectorAll(".pg-cell").forEach(inp=>{
    inp.addEventListener("change", ()=>{
      const r = rows[parseInt(inp.getAttribute("data-row"))];
      if(!r) return;
      r[inp.getAttribute("data-col")] = inp.value;
      encryptPersonalVault();
    });
  });
  body.querySelectorAll("[data-pg-del]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این ردیف حذف شود؟")) return;
      rows.splice(parseInt(btn.getAttribute("data-pg-del")), 1);
      encryptPersonalVault();
      renderPersonalGrid(sec);
    });
  });
  document.getElementById("pgAddRow").addEventListener("click", ()=>{
    const row = {};
    cols.forEach((c, ci)=> row["c"+ci] = "");
    rows.push(row);
    encryptPersonalVault();
    renderPersonalGrid(sec);
  });
}

/* ---------------- Personal: Companies (credentials) ---------------- */
let personalCredSelectedCompany = ""; // "" یعنی «همه»
function renderPersonalCreds(){
  const body = document.getElementById("personalTabBody");
  if(!body) return;
  const allCompanyNames = [...new Set(credRows().map(c=>String(c.company||"").trim()).filter(Boolean))]
    .sort((a,b)=> a.localeCompare(b,"fa"));
  // اگر شرکت انتخاب‌شده دیگر وجود ندارد (مثلاً حذف شده)، یا هنوز چیزی انتخاب نشده، برو روی اولین شرکت
  if((!personalCredSelectedCompany || !allCompanyNames.includes(personalCredSelectedCompany)) && allCompanyNames.length){
    personalCredSelectedCompany = allCompanyNames[0];
  }
  if(!allCompanyNames.length) personalCredSelectedCompany = "";
  const sel = personalCredSelectedCompany;
  const visibleIdx = credRows()
    .map((c,idx)=>idx)
    .filter(idx=> !sel || String(credRows()[idx].company||"").trim() === sel);

  const rows = visibleIdx.map(idx=>{
    const c = credRows()[idx];
    const shown = personalShowPw.has(idx);
    return `<tr>
      <td><input type="text" data-cred-idx="${idx}" data-cred-field="company" value="${escapeHtml(c.company||'')}" placeholder="نام شرکت"></td>
      <td><input type="text" data-cred-idx="${idx}" data-cred-field="username" value="${escapeHtml(c.username||'')}" placeholder="یوزرنیم"></td>
      <td>
        <div class="pw-cell">
          <input type="${shown?'text':'password'}" data-cred-idx="${idx}" data-cred-field="password" value="${escapeHtml(c.password||'')}" placeholder="پسورد">
          <button type="button" class="pw-toggle-btn" data-toggle-pw="${idx}" title="نمایش/مخفی‌کردن">${shown?'🙈':'👁'}</button>
        </div>
      </td>
      <td><input type="text" data-cred-idx="${idx}" data-cred-field="ip" value="${escapeHtml(c.ip||'')}" placeholder="IP / آدرس"></td>
      <td><input type="text" data-cred-idx="${idx}" data-cred-field="note" value="${escapeHtml(c.note||'')}" placeholder="توضیحات"></td>
      <td><button class="btn-del" data-remove-cred="${idx}" title="حذف">✕</button></td>
    </tr>`;
  }).join("");

  body.innerHTML = `
    ${xlsxOff() ? "" : `<div class="cred-import-bar">
      <p>📥 یک فایل اکسل بارگذاری کنید که هر برگه (Sheet) آن نام یک شرکت، و ردیف‌هایش به‌ترتیب عنوان/IP/یوزرنیم/پسورد باشد — همه‌چیز فقط در همین مرورگر پردازش و بلافاصله رمزنگاری می‌شود.</p>
      <button type="button" class="btn btn-brass btn-sm" id="importCredBtn">📥 انتخاب فایل اکسل/CSV</button>
      <input type="file" id="importCredFile" accept=".xlsx,.xls,.csv" style="display:none;">
      <span class="cred-import-status" id="importCredStatus"></span>
    </div>`}
    <div class="cred-toolbar" style="flex-direction:column; align-items:stretch;">
      <label style="font-size:12px; color:var(--ink-soft); white-space:nowrap; margin-bottom:8px;">🏢 شرکت‌ها:</label>
      <div class="company-tabs" id="companyTabs">
        ${allCompanyNames.map(name=>{
          const cnt = credRows().filter(c=>String(c.company||"").trim()===name).length;
          return `<button type="button" class="company-tab-btn ${name===sel?'active':''}" data-company-tab="${escapeHtml(name)}">
            ${escapeHtml(name)} <span class="cnt">${fa(cnt)}</span>
          </button>`;
        }).join("") || `<span style="font-size:11.5px; color:var(--ink-faint);">هنوز شرکتی اضافه نشده.</span>`}
      </div>
    </div>
    <div class="tbl-wrap">
      <table class="cred-table">
        <colgroup>
          <col style="width:14%;"><col style="width:15%;"><col style="width:30%;">
          <col style="width:18%;"><col style="width:23%;"><col style="width:36px;">
        </colgroup>
        <thead><tr><th>شرکت</th><th>یوزرنیم</th><th>پسورد</th><th>IP / آدرس</th><th>توضیحات</th><th></th></tr></thead>
        <tbody>${rows || `<tr><td colspan="6" style="color:var(--ink-faint);">${sel ? "موردی برای این شرکت پیدا نشد." : "هنوز موردی اضافه نشده."}</td></tr>`}</tbody>
      </table>
    </div>
    <div class="visit-add-bar" style="margin-top:12px;">
      <button class="btn btn-brass btn-sm" id="addCredBtn">＋ افزودن شرکت جدید</button>
    </div>
  `;
  body.querySelectorAll("[data-cred-idx]").forEach(inp=>{
    inp.addEventListener("change", onCredFieldChange);
    inp.addEventListener("input", onCredFieldChange);
  });
  body.querySelectorAll("[data-toggle-pw]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const idx = parseInt(btn.getAttribute("data-toggle-pw"));
      if(personalShowPw.has(idx)) personalShowPw.delete(idx); else personalShowPw.add(idx);
      renderPersonalCreds();
    });
  });
  body.querySelectorAll("[data-remove-cred]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این مورد حذف شود؟")) return;
      credRows().splice(parseInt(btn.getAttribute("data-remove-cred")),1);
      encryptPersonalVault();
      renderPersonalCreds();
    });
  });
  document.getElementById("addCredBtn").addEventListener("click", ()=>{
    const name = (prompt("نام شرکت جدید را وارد کنید:") || "").trim();
    if(!name){ return; }
    credRows().push({ company:name, username:"", password:"", ip:"", note:"" });
    personalCredSelectedCompany = name;
    encryptPersonalVault();
    renderPersonalCreds();
  });

  body.querySelectorAll("[data-company-tab]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      personalCredSelectedCompany = btn.getAttribute("data-company-tab");
      renderPersonalCreds();
    });
  });

  /* وقتی ادمین «خواندن از اکسل» را بسته، این نوار اصلاً ساخته نشده */
  if(document.getElementById("importCredBtn")){
  document.getElementById("importCredBtn").addEventListener("click", ()=>{
    document.getElementById("importCredFile").click();
  });
  document.getElementById("importCredFile").addEventListener("change", async (e)=>{
    const file = e.target.files[0];
    if(!file) return;
    const status = document.getElementById("importCredStatus");
    status.textContent = "در حال خواندن فایل...";
    try{
      if(typeof ensureXlsxLib === "function"){
        const ok = await ensureXlsxLib();
        if(!ok){ status.textContent = "⚠️ کتابخانه‌ی خواندن فایل بارگذاری نشد."; return; }
      }
      const buf = await file.arrayBuffer();
      const wb = XLSX.read(buf, {type:"array", raw:true, cellDates:false});
      let added = 0;
      wb.SheetNames.forEach(sheetName=>{
        const rows2 = XLSX.utils.sheet_to_json(wb.Sheets[sheetName], {header:1, raw:true, defval:null});
        if(!rows2 || !rows2.length) return;
        rows2.forEach(row=>{
          if(!row || row.every(c=>c==null || String(c).trim()==="")) return;
          const c1 = row[1]!=null ? String(row[1]).trim().toLowerCase() : "";
          const c2 = row[2]!=null ? String(row[2]).trim().toLowerCase() : "";
          const c3 = row[3]!=null ? String(row[3]).trim().toLowerCase() : "";
          if(c1==="ip" || c2==="user" || c2==="username" || c3==="pass" || c3==="password") return; // ردیف سربرگ
          const label = row[0]!=null ? String(row[0]).trim() : "";
          const ip = row[1]!=null ? String(row[1]).trim() : "";
          const username = row[2]!=null ? String(row[2]).trim() : "";
          const password = row[3]!=null ? String(row[3]).trim() : "";
          const extra = row.slice(4).filter(v=>v!=null && String(v).trim()!=="").map(v=>String(v).trim());
          const noteParts = [];
          if(label) noteParts.push(label);
          if(extra.length) noteParts.push(extra.join(" | "));
          credRows().push({
            company: sheetName, username, password, ip, note: noteParts.join(" — ")
          });
          added++;
        });
      });
      encryptPersonalVault();
      renderPersonalCreds();
      status.textContent = `✓ ${toPersianDigits(added)} ردیف بارگذاری و رمزنگاری شد.`;
    }catch(err){
      console.error(err);
      status.textContent = "⚠️ خطا در خواندن فایل.";
    }
    e.target.value = "";
  });
  }
}
function onCredFieldChange(e){
  const idx = parseInt(e.target.getAttribute("data-cred-idx"));
  const field = e.target.getAttribute("data-cred-field");
  credRows()[idx][field] = e.target.value;
  encryptPersonalVault();
}

/* ---------------- Personal: Installments ---------------- */
function addJalaliMonths(y, m, d, n){
  let totalM = (m-1) + n;
  let ny = y + Math.floor(totalM/12);
  let nm = (totalM%12) + 1;
  if(nm<1){ nm+=12; ny-=1; }
  const maxD = daysInJalaliMonth(ny, nm);
  return { y:ny, m:nm, d:Math.min(d, maxD) };
}
/* مقایسهٔ دو تاریخِ شمسی. هر دو طرف {y,m,d} دارند — «today» هم با
   همان شکل ساخته می‌شود — پس یک تابع برای هر دو بس است. */
function cmpJalali(a, b){
  const A = (a.y||a.year)*10000 + (a.m||a.month)*100 + (a.d||a.day);
  const B = (b.y||b.year)*10000 + (b.m||b.month)*100 + (b.d||b.day);
  return A - B;
}
function formatJalaliYMD(y,m,d){
  return fa(y)+"/"+fa(String(m).padStart(2,"0"))+"/"+fa(String(d).padStart(2,"0"));
}
function calcInstallment(principal, count, annualPercent){
  const r = (parseFloat(annualPercent)||0)/100/12; // نرخ سود ماهانه
  let per;
  if(r > 0){
    per = principal * r * Math.pow(1+r, count) / (Math.pow(1+r, count) - 1);
  } else {
    per = principal / count;
  }
  return { per, total: per * count };
}
function formatThousandsInput(input){
  const raw = input.value.replace(/[^\d]/g,"");
  input.value = raw ? Number(raw).toLocaleString("en-US") : "";
}
function numFromFormatted(id){
  const v = document.getElementById(id).value.replace(/,/g,"");
  return v ? parseFloat(v) : NaN;
}
/* ---------------- سه‌گونهٔ «اقساط» ----------------
   یک آرایه و سه شکل، نه سه آرایه:

   - وام (بی‌kind یا kind:"loan") — اصلِ وام و نرخِ سود دارد و قسطش
     محاسبه می‌شود. همان چیزی که از اول بود، پس دادهٔ قدیمی دست‌نخورده
     باز می‌شود.
   - متفرقه (kind:"misc") — خریدِ اقساطی مثلِ دیجی‌کالا یا اسنپ. این‌جا
     نرخِ سودی در کار نیست: مبلغِ هر قسط را خودِ فروشنده گفته، پس همان
     نوشته می‌شود و حساب نمی‌کنیم.
   - چک (kind:"cheque") — یک سررسید و یک مبلغ، تمام.

   هر سه با یک شکل نگه داشته می‌شوند — per/count/startY,M,D/paid[] — تا
   خلاصه و یادآور و «پرداخت شد» یک کد داشته باشند، نه سه تا. چک هم
   «قسطی با تعدادِ یک» است؛ همین یک تصمیم، نصفِ این فایل را کم کرد. */
const PLAN_KINDS = {
  loan:   { label: "وام",     icon: "💳" },
  misc:   { label: "متفرقه",  icon: "🛒" },
  cheque: { label: "چک",      icon: "🧾" }
};
const planKind = p => (p && PLAN_KINDS[p.kind]) ? p.kind : "loan";
const planTitle = p => String((p && p.title) || "").trim() || "بی‌عنوان";
const planMoney = n => fa(Math.round(Number(n) || 0).toLocaleString("en-US"));
function planPaidArr(plan){
  if(!Array.isArray(plan.paid)) plan.paid = [];
  return plan.paid;
}
function planCalc(plan){
  const count = Math.max(1, parseInt(plan && plan.count, 10) || 1);
  if(planKind(plan) === "loan"){
    const c = calcInstallment(Number(plan.principal) || 0, count, plan.percent);
    return { per: c.per, total: c.total, count };
  }
  const per = Number(plan && plan.per) || 0;
  return { per, total: per * count, count };
}

/* ---------------- یادآورِ سررسید ----------------
   دو روز پیش از هر قسط و هر چک باید خبر بیاید. ولی زنگوله بیرونِ
   صندوق کار می‌کند و کلیدِ صندوق هیچ‌وقت به آن نمی‌رسد — پس یا باید
   چیزی بیرون بنشیند، یا خبری در کار نیست.

   آن‌چه بیرون می‌نشیند فقط «تاریخ»هاست: نه عنوان، نه مبلغ، نه اینکه
   قسط است یا چک. زنگوله با همین‌ها می‌گوید «یک سررسید نزدیک است» و
   جزئیات را فقط بعد از زدنِ رمزِ دیتای شخصی نشان می‌دهد. */
const VAULT_DUE_DAYS = 2;
const VAULT_DUE_MAX = 400;

function jalaliPlusDays(y, m, d, n){
  let Y = y, M = m, D = d + n;
  while(D > daysInJalaliMonth(Y, M)){
    D -= daysInJalaliMonth(Y, M);
    M++;
    if(M > 12){ M = 1; Y++; }
  }
  return { y: Y, m: M, d: D };
}
/* کلیدِ تاریخ با رقمِ لاتین و دو رقمیِ ماه و روز: این‌طور مقایسهٔ
   رشته‌ای همان مقایسهٔ تاریخ است و به تابع نیازی نیست. */
const dueKey = (y, m, d) =>
  String(y) + "/" + String(m).padStart(2, "0") + "/" + String(d).padStart(2, "0");
function todayJalali(){
  const p = getTodayJalaliParts();
  return { y: parseInt(p.year, 10) || 1405, m: p.monthNum || 1, d: p.day || 1 };
}

/* هر سررسیدِ پرداخت‌نشده، از همهٔ بخش‌هایی که نوعشان «اقساط» است —
   ادمین می‌تواند بیشتر از یکی باز کند. */
function vaultDueAll(){
  const out = [];
  if(!personalVaultPlain) return out;
  vaultSections().filter(s => s.type === "inst").forEach(sec => {
    (vaultRows(sec) || []).forEach((plan, pIdx) => {
      if(!plan) return;
      const { per, count } = planCalc(plan);
      const paid = planPaidArr(plan);
      for(let i = 0; i < count; i++){
        if(paid[i]) continue;
        const due = addJalaliMonths(plan.startY, plan.startM, plan.startD, i);
        out.push({ secId: sec.id, secTitle: sec.title || sec.id, pIdx, i,
                   kind: planKind(plan), title: planTitle(plan),
                   y: due.y, m: due.m, d: due.d, amount: per,
                   key: dueKey(due.y, due.m, due.d) });
      }
    });
  });
  return out;
}

/* همان تاریخ‌ها، بیرونِ صندوق. فقط وقتی عوض شده باشند نوشته می‌شود:
   وگرنه هر بار باز کردنِ صندوق یک ذخیرهٔ بی‌دلیل بود. */
function refreshVaultDue(){
  try{
    if(!personalVaultPlain) return;
    let keys = vaultDueAll().map(x => x.key).sort();
    if(keys.length > VAULT_DUE_MAX) keys = keys.slice(0, VAULT_DUE_MAX);
    if(JSON.stringify(state.personalDue || []) === JSON.stringify(keys)) return;
    state.personalDue = keys;
    scheduleSave();
    /* زنگوله همین تاریخ‌ها را می‌خواند، پس همان لحظه خبردارش می‌کنیم */
    if(window.BELL) window.BELL.refresh();
  }catch(e){ }
}

/* پنجرهٔ «نزدیک»: از امروز تا دو روز بعد. عقب‌افتاده‌ها هم می‌آیند —
   قسطی که سررسیدش گذشته و پرداخت نشده، خبرِ مهم‌تری است. */
function vaultDueWindow(){
  const t = todayJalali();
  const win = {};
  for(let n = 0; n <= VAULT_DUE_DAYS; n++){
    const x = jalaliPlusDays(t.y, t.m, t.d, n);
    win[dueKey(x.y, x.m, x.d)] = n;
  }
  return { todayKey: dueKey(t.y, t.m, t.d), win };
}

/* فهرستِ کاملِ سررسیدهای نزدیک — فقط وقتی صندوق باز است */
function vaultDueSoonList(){
  const { todayKey, win } = vaultDueWindow();
  return vaultDueAll().map(x => {
    if(x.key < todayKey) return Object.assign({ late: true, days: 0 }, x);
    if(x.key in win) return Object.assign({ late: false, days: win[x.key] }, x);
    return null;
  }).filter(Boolean).sort((a, b) => a.key < b.key ? -1 : a.key > b.key ? 1 : 0);
}

/* همین را زنگوله می‌خواند، بی‌آنکه صندوق باز باشد: چند مورد، و
   نزدیک‌ترینشان کِی — و بس. */
window.vaultDueDigest = function(){
  let dates = [];
  try{ dates = Array.isArray(state.personalDue) ? state.personalDue : []; }
  catch(e){ return null; }
  if(!dates.length) return null;
  const { todayKey, win } = vaultDueWindow();
  let soon = 0, late = 0, nearest = "";
  dates.forEach(k => {
    const isLate = k < todayKey, isSoon = (k in win);
    if(!isLate && !isSoon) return;
    if(isLate) late++; else soon++;
    if(!nearest || k < nearest) nearest = k;
  });
  if(!soon && !late) return null;
  return { soon, late, n: soon + late, nearest, days: VAULT_DUE_DAYS };
};

let instAddTab = "loan";       /* کدام فرمِ افزودن باز است */

function renderPersonalInstallments(){
  const body = document.getElementById("personalTabBody");
  if(!body) return;
  const tj = todayJalali();
  const today = { year: tj.y, month: tj.m, day: tj.d };
  const rows = instRows();

  const nextUp = [], cheques = [], cards = [];
  let sumRemaining = 0, sumLeftCount = 0;

  rows.forEach((plan, pIdx) => {
    if(!plan) return;
    const kind = planKind(plan);
    const { per, total, count } = planCalc(plan);
    const paid = planPaidArr(plan);
    const paidCount = paid.filter(Boolean).length;
    sumRemaining += total - (per * paidCount);
    sumLeftCount += (count - paidCount);

    /* قسطِ پیشِ رو = اولین قسطِ پرداخت‌نشده. همین یکی است که آدم
       دنبالش می‌گردد، پس بالای صفحه می‌آید و از آن‌جا می‌شود پرید
       سرِ خودش. */
    let nextIdx = -1;
    for(let i = 0; i < count; i++) if(!paid[i]){ nextIdx = i; break; }
    if(nextIdx >= 0){
      const d = addJalaliMonths(plan.startY, plan.startM, plan.startD, nextIdx);
      nextUp.push({ pIdx, i: nextIdx, kind, title: planTitle(plan),
                    y: d.y, m: d.m, d: d.d, amount: per,
                    late: cmpJalali(d, today) < 0 });
    }

    /* چک‌ها همه در یک کادر جمع می‌شوند، نه هر کدام یک کارت: چکِ تنها
       سه خانه دارد و یک کارتِ کامل برایش زیادی است. */
    if(kind === "cheque"){
      const d = addJalaliMonths(plan.startY, plan.startM, plan.startD, 0);
      cheques.push({ pIdx, per, paid: !!paid[0], title: planTitle(plan),
                     y: d.y, m: d.m, d: d.d, late: !paid[0] && cmpJalali(d, today) < 0 });
      return;
    }

    const scheduleRows = Array.from({ length: count }, (_, i) => {
      const due = addJalaliMonths(plan.startY, plan.startM, plan.startD, i);
      const isPaid = !!paid[i];
      return `<tr id="inst-${pIdx}-${i}" class="${isPaid?'paid':''}${i===nextIdx?' inst-next':''}">
        <td>${fa(i+1)}</td>
        <td>${formatJalaliYMD(due.y,due.m,due.d)}</td>
        <td>${planMoney(per)}</td>
        <td><button type="button" class="inst-pay-toggle ${isPaid?'paid':''}" data-pay-plan="${pIdx}" data-pay-inst="${i}">${isPaid?'✓ پرداخت‌شده':'پرداخت‌نشده'}</button></td>
      </tr>`;
    }).join("");

    const sumLine = kind === "misc"
      ? `مبلغ هر قسط: <b>${planMoney(per)}</b> تومان — تعداد اقساط: <b>${fa(count)}</b><br>
         مبلغ کل: <b>${planMoney(total)}</b> تومان`
      : `مبلغ اصل وام: <b>${planMoney(plan.principal)}</b> تومان — نرخ سود سالانه: <b>${fa(plan.percent||0)}٪</b> — تعداد اقساط: <b>${fa(count)}</b><br>
         مبلغ کل قابل‌پرداخت: <b>${planMoney(total)}</b> تومان — مبلغ هر قسط: <b>${planMoney(per)}</b> تومان`;

    cards.push(`
      <div class="inst-card">
        <div class="inst-card-head">
          <h4><span class="inst-kind-badge k-${kind}">${PLAN_KINDS[kind].icon} ${PLAN_KINDS[kind].label}</span> ${escapeHtml(planTitle(plan))}</h4>
          <button class="btn-del" data-remove-inst="${pIdx}" title="حذف این مورد">✕</button>
        </div>
        <div class="inst-summary">
          ${sumLine}<br>
          پرداخت‌شده: <b>${fa(paidCount)}/${fa(count)}</b> قسط — مانده: <b>${planMoney(total - per*paidCount)}</b> تومان
        </div>
        <table class="inst-schedule">
          <thead><tr><th>#</th><th>تاریخ سررسید</th><th>مبلغ (تومان)</th><th>وضعیت</th></tr></thead>
          <tbody>${scheduleRows}</tbody>
        </table>
      </div>`);
  });

  /* کادرِ چک‌ها */
  const chqLeft = cheques.filter(c => !c.paid).reduce((s, c) => s + c.per, 0);
  const chqHtml = cheques.length ? `
    <div class="inst-card chq-card">
      <div class="inst-card-head">
        <h4>🧾 چک‌ها</h4>
        <span class="chq-sum">${fa(cheques.length)} چک · پاس‌نشده: <b>${planMoney(chqLeft)}</b> تومان</span>
      </div>
      <table class="inst-schedule chq-table">
        <thead><tr><th>چک / بابتِ</th><th>تاریخ سررسید</th><th>مبلغ (تومان)</th><th>وضعیت</th><th></th></tr></thead>
        <tbody>
          ${cheques.map(c => `
            <tr id="inst-${c.pIdx}-0" class="${c.paid?'paid':''}${c.late?' chq-late':''}">
              <td>${escapeHtml(c.title)}</td>
              <td>${formatJalaliYMD(c.y,c.m,c.d)}${c.late?' <span class="chq-flag">عقب‌افتاده</span>':''}</td>
              <td>${planMoney(c.per)}</td>
              <td><button type="button" class="inst-pay-toggle ${c.paid?'paid':''}" data-pay-plan="${c.pIdx}" data-pay-inst="0">${c.paid?'✓ پاس شده':'پاس نشده'}</button></td>
              <td><button type="button" class="btn-del" data-remove-inst="${c.pIdx}" title="حذف این چک">✕</button></td>
            </tr>`).join("")}
        </tbody>
      </table>
    </div>` : "";

  /* خلاصهٔ بالای صفحه. وقتی هیچ چیزی نیست، اصلاً نمی‌آید — یک کادرِ
     خالیِ صفر تومانی به کسی چیزی نمی‌گوید. */
  const lateCount = nextUp.filter(x => x.late).length;
  nextUp.sort((a, b) => cmpJalali(a, b));
  const boxHtml = nextUp.length ? `
    <div class="inst-box">
      <div class="inst-box-head">
        <h4>📋 خلاصهٔ اقساط</h4>
        <span class="inst-box-sum">
          <b>${fa(nextUp.length)}</b> مورد ·
          <b>${fa(sumLeftCount)}</b> قسط/چکِ مانده ·
          <b>${planMoney(sumRemaining)}</b> تومان
          ${lateCount ? `· <span class="inst-late-n">${fa(lateCount)} موردِ عقب‌افتاده</span>` : ""}
        </span>
      </div>
      <div class="inst-box-grid">
        ${nextUp.map(x => `
          <button type="button" class="inst-next-chip${x.late?' late':''}"
                  data-goto-plan="${x.pIdx}" data-goto-inst="${x.i}"
                  title="رفتن به همین مورد در فهرست">
            <span class="inb-title">${PLAN_KINDS[x.kind].icon} ${escapeHtml(x.title)}</span>
            <span class="inb-date">${formatJalaliYMD(x.y,x.m,x.d)}</span>
            <span class="inb-meta">${x.kind === "cheque" ? "چک" : "قسط " + fa(x.i+1)} · ${planMoney(x.amount)} تومان</span>
            ${x.late ? `<span class="inb-flag">عقب‌افتاده</span>` : ""}
          </button>`).join("")}
      </div>
    </div>` : "";

  /* سه فرمِ افزودن، پشتِ سه سربرگ: وام، چک، متفرقه. یک‌جا نشانشان
     دادن صفحه را شلوغ می‌کرد و آدم نمی‌فهمید کدام خانه مالِ کدام. */
  const addForms = {
    loan: `
      <div class="inst-form">
        <input type="text" id="instTitle" placeholder="عنوان — مثلاً: وام خرید تجهیزات">
        <input type="text" inputmode="numeric" id="instPrincipal" placeholder="مبلغ اصل وام (تومان)">
        <input type="number" id="instCount" placeholder="تعداد اقساط" min="1">
        <input type="number" id="instPercent" placeholder="نرخ سود سالانه (٪)" step="0.1" min="0">
      </div>
      <div class="inst-date-row">
        <label>تاریخ شروع اقساط (شمسی):</label>
        <select id="instDay"></select>
        <select id="instMonth"></select>
        <select id="instYear"></select>
      </div>
      <p class="inst-note">📌 محاسبه به روش استاندارد «اقساط مساوی» (فرمول تنزیل / همان روشی که وام‌های بانکی و اکثر سایت‌های محاسبه‌ی اقساط استفاده می‌کنند) انجام می‌شود: نرخ سود سالانه به نرخ ماهانه تبدیل شده و قسط ثابت ماهانه از روی آن محاسبه می‌شود. سررسید هر قسط، یک ماه شمسی بعد از قسط قبلی است.</p>
      <button type="button" class="btn btn-brass btn-sm" id="addInstallmentBtn">محاسبه و افزودن</button>`,
    cheque: `
      <div class="inst-form inst-form-3">
        <input type="text" id="chqTitle" placeholder="چک / بابتِ — مثلاً: چک ۱۲۳۴۵۶ بانک ملت">
        <input type="text" inputmode="numeric" id="chqAmount" placeholder="مبلغ چک (تومان)">
        <input type="text" id="chqDate" data-date placeholder="تاریخ سررسید را انتخاب کنید" autocomplete="off">
      </div>
      <p class="inst-note">📌 چک هم مثلِ قسط در «خلاصهٔ اقساط» می‌آید و دو روز پیش از سررسیدش در زنگولهٔ خبرها خبر می‌دهد. تاریخ را از تقویم انتخاب کنید.</p>
      <button type="button" class="btn btn-brass btn-sm" id="addChequeBtn">افزودن چک</button>`,
    misc: `
      <div class="inst-form inst-form-4">
        <input type="text" id="mscTitle" placeholder="عنوان — مثلاً: دیجی‌کالا / اسنپ">
        <input type="text" inputmode="numeric" id="mscPer" placeholder="مبلغ هر قسط (تومان)">
        <input type="number" id="mscCount" placeholder="تعداد اقساط" min="1">
        <input type="text" id="mscDate" data-date placeholder="تاریخ اولین قسط" autocomplete="off">
      </div>
      <p class="inst-note">📌 برای خریدهای اقساطی که خودشان مبلغِ قسط را گفته‌اند (دیجی‌کالا، اسنپ و مانندشان): نرخ سودی حساب نمی‌شود، همان مبلغی که نوشتید هر ماه تکرار می‌شود. روزِ همین تاریخ، سررسیدِ ماه‌های بعد هم هست.</p>
      <button type="button" class="btn btn-brass btn-sm" id="addMiscBtn">افزودن</button>`
  };

  body.innerHTML = boxHtml + `
    <div class="panel inst-add" style="padding:16px; margin-bottom:16px;">
      <div class="inst-add-tabs">
        ${["loan","cheque","misc"].map(k => `
          <button type="button" data-iadd="${k}" class="${instAddTab===k?'active':''}">
            ${PLAN_KINDS[k].icon} ${k==="loan" ? "افزودن وام/قسط" : k==="cheque" ? "افزودن چک" : "متفرقه (دیجی‌کالا / اسنپ)"}
          </button>`).join("")}
      </div>
      ${addForms[instAddTab] || addForms.loan}
    </div>
    ${chqHtml}
    ${cards.join("") || (cheques.length ? "" : `<p style="color:var(--ink-faint); font-size:12.5px;">هنوز وام، چک یا قسطی ثبت نشده.</p>`)}
  `;

  /* تقویمِ خانه‌های تازه */
  if(window.datePickScan) window.datePickScan(body);

  body.querySelectorAll("[data-iadd]").forEach(btn => {
    btn.addEventListener("click", () => {
      instAddTab = btn.getAttribute("data-iadd");
      renderPersonalInstallments();
    });
  });

  /* ---- فرمِ وام ---- */
  const daySel = document.getElementById("instDay");
  const monthSel = document.getElementById("instMonth");
  const yearSel = document.getElementById("instYear");
  if(daySel && monthSel && yearSel){
    monthSel.innerHTML = JALALI_MONTH_NAMES.map((m,i)=>`<option value="${i+1}" ${i+1===today.month?"selected":""}>${m}</option>`).join("");
    for(let y=1400; y<=today.year+5; y++) yearSel.innerHTML += `<option value="${y}" ${y===today.year?"selected":""}>${fa(y)}</option>`;
    const refreshInstDays = ()=>{
      const y = parseInt(yearSel.value), m = parseInt(monthSel.value);
      const keep = parseInt(daySel.value) || today.day;
      daySel.innerHTML = jalaliMonthDayOptions(y, m, Math.min(keep, daysInJalaliMonth(y,m)));
    };
    daySel.innerHTML = jalaliMonthDayOptions(today.year, today.month, today.day);
    yearSel.addEventListener("change", refreshInstDays);
    monthSel.addEventListener("change", refreshInstDays);
  }
  /* جداکنندهٔ هزارگان، در هر سه فرم */
  ["instPrincipal", "chqAmount", "mscPer"].forEach(id => {
    const inp = document.getElementById(id);
    if(inp) inp.addEventListener("input", ()=> formatThousandsInput(inp));
  });

  const addBtn = document.getElementById("addInstallmentBtn");
  if(addBtn) addBtn.addEventListener("click", ()=>{
    const title = document.getElementById("instTitle").value.trim();
    const principal = numFromFormatted("instPrincipal");
    const count = parseInt(document.getElementById("instCount").value);
    const percent = parseFloat(document.getElementById("instPercent").value) || 0;
    if(!principal || principal<=0){ alert("مبلغ اصل وام را درست وارد کنید."); return; }
    if(!count || count<=0){ alert("تعداد اقساط را درست وارد کنید."); return; }
    rows.push({ kind:"loan", title, principal, count, percent,
                startY: parseInt(yearSel.value), startM: parseInt(monthSel.value),
                startD: parseInt(daySel.value),
                paid: Array.from({length:count}, ()=>false) });
    encryptPersonalVault();
    renderPersonalInstallments();
  });

  /* ---- فرمِ چک ---- */
  const chqBtn = document.getElementById("addChequeBtn");
  if(chqBtn) chqBtn.addEventListener("click", ()=>{
    const title = document.getElementById("chqTitle").value.trim();
    const amount = numFromFormatted("chqAmount");
    const d = pickedJalali("chqDate");
    if(!title){ alert("چک را بنویسید — مثلاً شمارهٔ چک یا بابتِ چه چیزی است."); return; }
    if(!amount || amount<=0){ alert("مبلغ چک را درست وارد کنید."); return; }
    if(!d){ alert("تاریخ سررسید چک را از تقویم انتخاب کنید."); return; }
    rows.push({ kind:"cheque", title, per: amount, count: 1,
                startY: d.jy, startM: d.jm, startD: d.jd, paid: [false] });
    encryptPersonalVault();
    renderPersonalInstallments();
  });

  /* ---- فرمِ متفرقه ---- */
  const mscBtn = document.getElementById("addMiscBtn");
  if(mscBtn) mscBtn.addEventListener("click", ()=>{
    const title = document.getElementById("mscTitle").value.trim();
    const per = numFromFormatted("mscPer");
    const count = parseInt(document.getElementById("mscCount").value);
    const d = pickedJalali("mscDate");
    if(!per || per<=0){ alert("مبلغ هر قسط را درست وارد کنید."); return; }
    if(!count || count<=0){ alert("تعداد اقساط را درست وارد کنید."); return; }
    if(!d){ alert("تاریخ اولین قسط را از تقویم انتخاب کنید."); return; }
    rows.push({ kind:"misc", title, per, count,
                startY: d.jy, startM: d.jm, startD: d.jd,
                paid: Array.from({length:count}, ()=>false) });
    encryptPersonalVault();
    renderPersonalInstallments();
  });

  body.querySelectorAll("[data-remove-inst]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این مورد حذف شود؟")) return;
      rows.splice(parseInt(btn.getAttribute("data-remove-inst")),1);
      encryptPersonalVault();
      renderPersonalInstallments();
    });
  });
  /* از کادرِ بالا، پریدن سرِ خودِ قسط در فهرست — و یک چشمک، وگرنه
     در فهرستی با بیست ردیف معلوم نیست کجا رفتیم. */
  body.querySelectorAll("[data-goto-plan]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      flashInstRow(btn.getAttribute("data-goto-plan"), btn.getAttribute("data-goto-inst"));
    });
  });

  body.querySelectorAll("[data-pay-plan]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      const pIdx = parseInt(btn.getAttribute("data-pay-plan"));
      const iIdx = parseInt(btn.getAttribute("data-pay-inst"));
      const plan = rows[pIdx];
      if(!plan) return;
      const paid = planPaidArr(plan);
      paid[iIdx] = !paid[iIdx];
      encryptPersonalVault();
      renderPersonalInstallments();
    });
  });

  /* بنرِ بالای صفحه با همین فهرست عوض می‌شود، پس همین‌جا تازه‌اش
     می‌کنیم — نه با بازسازیِ همهٔ صفحه. */
  paintDueBanner();
}

/* تاریخی که از تقویم انتخاب شده — یا null اگر خانه خالی یا بی‌معنا باشد */
function pickedJalali(id){
  const el = document.getElementById(id);
  if(!el) return null;
  try{ return window.DatePick.parse(el.value); }catch(e){ return null; }
}
function flashInstRow(pIdx, i){
  const row = document.getElementById("inst-" + pIdx + "-" + i);
  if(!row) return;
  row.scrollIntoView({ behavior:"smooth", block:"center" });
  row.classList.remove("inst-flash");
  void row.offsetWidth;          /* تا انیمیشن دوباره از اول بیفتد */
  row.classList.add("inst-flash");
  setTimeout(()=> row.classList.remove("inst-flash"), 2400);
}

/* ---------------- هزینه‌ها ----------------
   چهار ستون و بس: موضوع، تاریخِ هزینه، مبلغ، و نوع — «ورودی» یا
   «خروجی». بخشی است که ادمین باز می‌کند، مثلِ بقیهٔ بخش‌های دیتای
   شخصی، و محتوایش هم مثلِ آن‌ها داخلِ همان صندوقِ رمزدار می‌نشیند.

   سه تصمیم:

   یک) تاریخ با تقویم انتخاب می‌شود، نه با تایپ. کافی است خانه
       data-date داشته باشد؛ خودِ تقویم (پارهٔ datepick) پیدایش
       می‌کند، و بعد از انتخاب همان رویدادی را می‌فرستد که دستْ‌نوشتن
       می‌فرستد. پس این‌جا چیزی دربارهٔ تقویم نوشته نشده.

   دو) فیلترِ نوع بالای جدول است و جمع‌ها هم با آن جابه‌جا می‌شوند:
       اگر «خروجی» را زده‌ای، عددی که می‌بینی جمعِ همان چیزی است که
       روی صفحه است — وگرنه فیلتر آدم را گمراه می‌کرد.

   سه) جمع‌ها با تایپ به‌روز می‌شوند ولی جدول بازسازی نمی‌شود:
       بازسازی وسطِ تایپ، نشانه‌گر را می‌پراند. فقط عوض‌کردنِ «نوع»
       بازسازی می‌کند، چون ممکن است ردیف از فیلتر بیرون بیفتد. */

const EXP_KINDS = [{ id:"out", label:"خروجی" }, { id:"in", label:"ورودی" }];
let personalExpFilter = "";      /* "" یعنی همه */

const expKindOf = r => String(r && r.kind) === "in" ? "in" : "out";
/* مبلغ همیشه عدد ذخیره می‌شود، ولی دادهٔ قدیمی یا دست‌کاری‌شده هم
   نباید NaN روی صفحه بیاورد. */
function expAmount(r){
  const n = Number(String((r && r.amount) != null ? r.amount : "").replace(/[^\d.-]/g, ""));
  return Number.isFinite(n) ? n : 0;
}
const expMoney = n => fa(Math.round(n).toLocaleString("en-US"));
/* تاریخِ امروز به همان شکلی که تقویم می‌نویسد — تا ردیفِ تازه از
   اول پر باشد و کسی لازم نباشد تاریخِ همین امروز را دستی بزند. */
function expToday(){
  try{
    const t = window.DatePick.today();
    return window.DatePick.fmt(t.jy, t.jm, t.jd);
  }catch(e){ return ""; }
}

function expSums(rows){
  let inn = 0, out = 0;
  for(const r of rows){
    if(expKindOf(r) === "in") inn += expAmount(r); else out += expAmount(r);
  }
  return { inn, out, net: inn - out };
}

function renderPersonalExpenses(sec){
  const body = document.getElementById("personalTabBody");
  if(!body) return;
  const rows = vaultRows(sec);
  const nIn = rows.filter(r=> expKindOf(r) === "in").length;
  const nOut = rows.length - nIn;

  /* شمارهٔ واقعیِ ردیف با خودش می‌آید: با فیلتر، جای ردیف روی صفحه
     دیگر جای آن در آرایه نیست — و همین یک جا بود که حذفِ یک ردیف
     می‌توانست ردیفِ دیگری را ببرد. */
  const shown = rows.map((r, i)=> ({ r, i }))
    .filter(x=> !personalExpFilter || expKindOf(x.r) === personalExpFilter);

  const kindOpts = r => EXP_KINDS.map(k=>
    `<option value="${k.id}" ${expKindOf(r) === k.id ? "selected" : ""}>${k.label}</option>`).join("");

  const bodyHtml = shown.map(({ r, i })=> `
    <tr class="exp-row exp-${expKindOf(r)}" data-exp-row="${i}">
      <td><input type="text" class="exp-cell" data-row="${i}" data-k="subj"
           value="${escapeHtml(r.subj || "")}" placeholder="موضوع"></td>
      <td><input type="text" class="exp-cell exp-date" data-row="${i}" data-k="date" data-date
           value="${escapeHtml(r.date || "")}" placeholder="تاریخ را انتخاب کنید"></td>
      <td><input type="text" inputmode="numeric" class="exp-cell exp-amt" data-row="${i}" data-k="amount"
           value="${expAmount(r) ? expAmount(r).toLocaleString("en-US") : ""}" placeholder="مبلغ"></td>
      <td><select class="exp-kind" data-row="${i}">${kindOpts(r)}</select></td>
      <td><button type="button" class="btn-del" data-exp-del="${i}" title="حذف این ردیف">✕</button></td>
    </tr>`).join("");

  const empty = rows.length
    ? "با این فیلتر چیزی نیست."
    : "هنوز چیزی ثبت نشده. از دکمهٔ پایین شروع کنید.";

  body.innerHTML = `
    <div class="cred-toolbar">
      <div class="company-tabs">
        <button type="button" class="company-tab-btn ${personalExpFilter === "" ? "active" : ""}"
          data-expf="">همه <span class="cnt">${fa(rows.length)}</span></button>
        <button type="button" class="company-tab-btn ${personalExpFilter === "in" ? "active" : ""}"
          data-expf="in">ورودی <span class="cnt">${fa(nIn)}</span></button>
        <button type="button" class="company-tab-btn ${personalExpFilter === "out" ? "active" : ""}"
          data-expf="out">خروجی <span class="cnt">${fa(nOut)}</span></button>
      </div>
    </div>
    <div class="inst-box">
      <div class="inst-box-head">
        <h4>🧾 جمع${personalExpFilter ? "ِ همین فیلتر" : ""}</h4>
        <span class="inst-box-sum" id="expSums"></span>
      </div>
    </div>
    <div class="panel" style="padding:14px;">
      <div class="tbl-wrap">
        <table class="cred-table exp-tab">
          <colgroup><col><col style="width:160px"><col style="width:150px">
            <col style="width:110px"><col style="width:34px"></colgroup>
          <thead><tr>
            <th>موضوع</th><th>تاریخ</th><th>مبلغ (تومان)</th><th>نوع</th><th></th>
          </tr></thead>
          <tbody>${bodyHtml || `<tr><td colspan="5" style="color:var(--ink-faint);
            font-size:12.5px; text-align:center; padding:14px;">${empty}</td></tr>`}</tbody>
        </table>
      </div>
      <div style="display:flex; gap:8px; flex-wrap:wrap; margin-top:10px;">
        <button type="button" class="btn btn-brass btn-sm" id="expAdd">＋ افزودن هزینه</button>
      </div>
    </div>`;

  paintExpSums(sec);
  /* تقویم خانه‌های تازه را خودش پیدا می‌کند، ولی یک تکان دستی هم
     بزنیم تا همان لحظه آماده باشد، نه یک تیک بعد. */
  if(window.datePickScan) window.datePickScan(body);

  body.querySelectorAll("[data-expf]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      personalExpFilter = btn.getAttribute("data-expf");
      renderPersonalExpenses(sec);
    });
  });

  body.querySelectorAll(".exp-amt").forEach(inp=>{
    /* جداکنندهٔ هزارگان همان‌جا که تایپ می‌شود */
    inp.addEventListener("input", ()=>{ formatThousandsInput(inp); });
  });

  body.querySelectorAll(".exp-cell").forEach(inp=>{
    const save = ()=>{
      const r = rows[parseInt(inp.getAttribute("data-row"), 10)];
      if(!r) return;
      const k = inp.getAttribute("data-k");
      if(k === "amount"){
        const raw = inp.value.replace(/[^\d]/g, "");
        r.amount = raw ? Number(raw) : 0;
      } else {
        r[k] = inp.value.trim();
      }
      encryptPersonalVault();
      paintExpSums(sec);
    };
    inp.addEventListener("change", save);
    /* تقویم input می‌فرستد نه فقط change؛ و مبلغ هم بهتر است جمع را
       همان لحظه عوض کند، نه وقتی خانه را ترک کردی. */
    if(inp.getAttribute("data-k") !== "subj") inp.addEventListener("input", save);
  });

  body.querySelectorAll(".exp-kind").forEach(sel=>{
    sel.addEventListener("change", ()=>{
      const r = rows[parseInt(sel.getAttribute("data-row"), 10)];
      if(!r) return;
      r.kind = sel.value === "in" ? "in" : "out";
      encryptPersonalVault();
      /* با فیلترِ روشن، این ردیف ممکن است همین حالا نباید دیده شود */
      renderPersonalExpenses(sec);
    });
  });

  body.querySelectorAll("[data-exp-del]").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      if(!confirm("این ردیف حذف شود؟")) return;
      rows.splice(parseInt(btn.getAttribute("data-exp-del"), 10), 1);
      encryptPersonalVault();
      renderPersonalExpenses(sec);
    });
  });

  document.getElementById("expAdd").addEventListener("click", ()=>{
    /* ردیفِ تازه از نوعِ همان فیلتری است که باز است — وگرنه با فیلترِ
       «ورودی» یک ردیفِ خروجی ساخته می‌شد و همان لحظه غیب. */
    rows.push({ subj: "", date: expToday(), amount: 0,
                kind: personalExpFilter === "in" ? "in" : "out" });
    encryptPersonalVault();
    renderPersonalExpenses(sec);
    /* مکان‌نما می‌رود داخلِ موضوعِ همان ردیفِ تازه */
    const all = document.querySelectorAll('#personalTabBody .exp-cell[data-k="subj"]');
    const last = all[all.length - 1];
    if(last){ last.focus(); last.scrollIntoView({ block:"nearest" }); }
  });
}

/* جمع‌ها جدا نوشته می‌شوند تا با هر تایپ، جدول بازسازی نشود */
function paintExpSums(sec){
  const el = document.getElementById("expSums");
  if(!el) return;
  const rows = vaultRows(sec)
    .filter(r=> !personalExpFilter || expKindOf(r) === personalExpFilter);
  const s = expSums(rows);
  el.innerHTML =
    'ورودی <b class="exp-sum-in">' + expMoney(s.inn) + '</b> · ' +
    'خروجی <b class="exp-sum-out">' + expMoney(s.out) + '</b> · ' +
    'مانده <b class="' + (s.net < 0 ? "exp-sum-out" : "exp-sum-in") + '">' +
    expMoney(s.net) + '</b> تومان';
}
