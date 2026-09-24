
/* ---------------- جلوی تکمیلِ خودکارِ مرورگر ----------------
   کادرِ رمزِ صفحهٔ ورود که برداشته شد، ریشهٔ ماجرا خشکید. این لایهٔ دوم
   است برای مرورگرها و افزونه‌های مدیریتِ رمز که با حدس‌های خودشان کار
   می‌کنند: هیچ خانهٔ جدولی نباید پیشنهادِ «نام کاربری» بگیرد.

   جدول‌ها مدام با innerHTML از نو ساخته می‌شوند، پس یک بار نشانه‌گذاری
   کافی نیست و یک ناظر هم لازم است. */
function markNoAutofill(root){
  const sel = 'input[type="text"], input[type="search"], input:not([type]), textarea';
  (root || document).querySelectorAll(sel).forEach(el=>{
    if(el.dataset.naf) return;
    el.dataset.naf = "1";
    /* ردیفِ «＋» و ردیفِ جست‌وجو همیشه باید خالی شروع شوند. این‌ها را
       علامت می‌زنیم تا اگر مرورگر چیزی داخلشان ریخت، برداشته شود.

       چرا این لایه لازم است؟ چون کروم وقتی برای این دامنه رمزِ
       ذخیره‌شده دارد، autocomplete=off را روی کادرهایی که خودش «نام
       کاربری» تشخیص می‌دهد نادیده می‌گیرد — و همین ستونِ «داخلی» در
       جدول MVPN را «admin» می‌کرد.

       عمداً فقط همین‌ها: سه ورودیِ دیگر در صفحه هست (یادآور و ابزار
       تاریخ) که خودِ کد مقدارشان را می‌گذارد، و پاک کردنِ کورکورانه
       آن‌ها را خراب می‌کرد. */
    if(el.tagName === "INPUT" && el.closest(".add-row, .filter-row, .visit-add-bar")){
      el.dataset.mtEmpty = "1";
      el.value = "";
    }
    el.setAttribute("autocomplete", "off");
    el.setAttribute("autocorrect", "off");
    el.setAttribute("autocapitalize", "off");
    el.setAttribute("spellcheck", "false");
    el.setAttribute("data-lpignore", "true");   /* LastPass */
    el.setAttribute("data-1p-ignore", "");      /* 1Password */
    el.setAttribute("data-form-type", "other"); /* Dashlane */
  });
}

/* کروم معمولاً بعد از ساخته‌شدنِ ورودی پُرش می‌کند، پس یک بار پاک
   کردن کافی نیست. چند بار سر می‌زنیم — ولی هیچ‌وقت به کادری که همین
   حالا زیرِ دستِ کاربر است دست نمی‌زنیم. */
function scrubAutofilled(){
  document.querySelectorAll('[data-mt-empty="1"]').forEach(el=>{
    if(el === document.activeElement) return;
    if(el.value !== "") el.value = "";
  });
}
function scrubSoon(){
  requestAnimationFrame(scrubAutofilled);
  setTimeout(scrubAutofilled, 400);
  setTimeout(scrubAutofilled, 1200);
}

function setupNoAutofill(){
  const host = document.querySelector(".content") || document.body;
  markNoAutofill(host);
  scrubSoon();
  /* وقتی کاربر خودش چیزی تایپ کرد، دیگر نگهبانی لازم نیست */
  host.addEventListener("input", e=>{
    const t = e.target;
    if(t && t.dataset && t.dataset.mtEmpty && e.isTrusted && t === document.activeElement)
      delete t.dataset.mtEmpty;
  }, true);
  try{
    new MutationObserver(muts=>{
      for(const m of muts){
        for(const n of m.addedNodes){
          if(n.nodeType !== 1) continue;
          markNoAutofill(n);
          if(n.matches && n.matches("input, textarea")) markNoAutofill(n.parentNode || host);
          scrubSoon();
        }
      }
    }).observe(host, { childList:true, subtree:true });
  }catch(e){ /* ناظر نشد؟ همان یک بارِ اول هم بهتر از هیچ است */ }
}

/* ---------------- خواندن از اکسل ----------------
   یک‌بار فایل را می‌خواند و داخل کارتابل می‌نشاند. بعد از آن به فایل
   کاری ندارد — دادهٔ کارتابل روی سرور است، نه در آن فایل. این با
   «آینهٔ اکسل روی سیستم» فرق دارد: آن یکی به یک پوشه بند می‌ماند و
   هر تغییری را همان‌جا هم می‌نویسد.

   ادمین می‌تواند این را ببندد؛ آن‌وقت نه دکمه‌ای هست نه راهی. */
function xlsxOff(){ return featClosed("xlsx"); }

/* یک انتخابگرِ فایل که خودش را جمع می‌کند. input را در صفحه نگه
   نمی‌داریم چون یک بار مصرف است و اگر بماند، دفعهٔ بعد همان فایلِ قبلی
   را به یاد دارد و «change» شلیک نمی‌شود. */
function pickFile(accept){
  return new Promise(resolve=>{
    const el = document.createElement("input");
    el.type = "file";
    el.accept = accept || ".xlsx,.xls,.csv";
    el.style.display = "none";
    el.addEventListener("change", ()=>{
      const f = el.files && el.files[0] ? el.files[0] : null;
      el.remove();
      resolve(f);
    });
    /* اگر کاربر پنجره را ببندد، «change» هیچ‌وقت نمی‌آید. این نگهبان
       بعد از برگشتنِ فوکوس به صفحه، input را برمی‌دارد. */
    window.addEventListener("focus", ()=> setTimeout(()=>{
      if(document.body.contains(el) && !(el.files && el.files.length)){ el.remove(); resolve(null); }
    }, 400), { once:true });
    document.body.appendChild(el);
    el.click();
  });
}

/* فایل را می‌خواند و کتابِ اکسل را برمی‌گرداند. اگر کتابخانه نیامد یا
   فایل خراب بود، پیامِ روشن می‌دهد و null برمی‌گرداند. */
async function readWorkbook(file){
  if(!file) return null;
  if(typeof ensureXlsxLib === "function"){
    const ok = await ensureXlsxLib();
    if(!ok){ alert("کتابخانهٔ خواندن اکسل بارگذاری نشد. اینترنت را بررسی کنید."); return null; }
  }
  try{
    /* CSV و xlsx دو جورند و این تفاوت یک بار ما را زمین زد:
       xlsx یک زیپ است و متنش داخلش UTF-8 است، پس بایتِ خام درست خوانده
       می‌شود. ولی CSV خودش یک فایلِ متنی است و اگر بایت‌بایت بدهیمش،
       کتابخانه هر بایت را یک نویسه حساب می‌کند و «نام» می‌شود «ÙØ§Ù».
       پس CSV را با متنِ رمزگشایی‌شده می‌دهیم، نه با بایت. */
    const isCsv = /\.csv$/i.test(file.name || "") || /csv|text\/plain/i.test(file.type || "");
    if(isCsv){
      let txt = await file.text();
      if(txt.charCodeAt(0) === 0xFEFF) txt = txt.slice(1);   /* BOM ویندوز */
      return XLSX.read(txt, { type:"string", raw:true });
    }
    const buf = await file.arrayBuffer();
    return XLSX.read(buf, { type:"array", raw:true, cellDates:false });
  }catch(e){
    console.error(e);
    alert("این فایل خوانده نشد. مطمئن شوید یک فایل اکسل یا CSV سالم است.");
    return null;
  }
}

/* ردیف‌های یک برگه، به شکلِ آرایه‌ای از آرایه‌ها و بدونِ ردیف‌های خالی */
function sheetRows(wb, name){
  const sh = wb.Sheets[name];
  if(!sh) return [];
  const rows = XLSX.utils.sheet_to_json(sh, { header:1, raw:true, defval:null }) || [];
  return rows.filter(r=> r && r.some(c=> c != null && String(c).trim() !== ""));
}

/* آیا این ردیف سربرگ است؟ وقتی هیچ خانه‌ای عدد نیست و دست‌کم یکی از
   خانه‌ها با نامِ ستونی که انتظار داریم می‌خواند. */
function looksLikeHeader(row, cols){
  if(!row) return false;
  const anyNumber = row.some(c=> c != null && String(c).trim() !== "" && !isNaN(Number(c)));
  if(anyNumber) return false;
  const norm = s => String(s == null ? "" : s).trim().toLowerCase();
  const want = (cols || []).map(norm);
  return row.some(c=> c != null && want.includes(norm(c)));
}

/* ---------------- بخش‌های مشترک ----------------
   جدول‌هایی که ادمین بین چند کارتابل مشترک کرده. کدش در یک فایلِ
   جداست (/shared.js) چون هر دو کارتابل همان را بار می‌کنند؛ اگر دو
   نسخه می‌شد، فردا یکی‌شان عوض می‌شد و آن یکی نه.
   فقط بعد از ورود بار می‌شود: پیش از آن هر درخواستی یک ۴۰۱ است. */
function setupShared(){
  if(!signedIn) return;
  if(document.getElementById("sharedJs")) { if(window.initSharedBoxes) window.initSharedBoxes(); return; }
  const el = document.createElement("script");
  el.id = "sharedJs";
  el.src = "/shared.js";
  el.onload = ()=>{ if(window.initSharedBoxes) window.initSharedBoxes(); };
  el.onerror = ()=>{ console.warn("بخش‌های مشترک بار نشد."); };
  document.head.appendChild(el);
}
