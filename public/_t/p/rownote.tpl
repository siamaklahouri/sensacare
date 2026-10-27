/* ==================== یادداشتِ هر ردیف ====================
   جدول‌ها جای عدد و وضعیت‌اند. ولی هر ردیف معمولاً یک «چرا» هم دارد:
   این بازدید چرا سه ساعت طول کشید، با چه کسی هماهنگ شد، چه چیزی
   قرار است دفعهٔ بعد پیگیری شود. این‌ها ستون ندارند و اگر ستون هم
   داشته باشند، جدول را از ریخت می‌اندازند.

   پس یک مدادِ کوچک کنارِ هر ردیف: زدنش پنجره‌ای باز می‌کند که متن را
   نشان می‌دهد و همان‌جا هم ویرایش می‌شود.

   سه تصمیم:

   یک) مداد وقتی یادداشت دارد پررنگ و پُر است، وقتی ندارد کم‌رنگ. پس
   بی آنکه چیزی باز شود، از روی جدول معلوم است کدام ردیف توضیح دارد —
   وگرنه یادداشتی که کسی نمی‌داند هست، نوشته نشده حساب می‌شود.

   دو) این‌جا هیچ‌چیز دربارهٔ شرکت‌ها یا سرورها نمی‌داند. صدا زننده
   می‌گوید متن را از کجا بخواند و کجا بنویسد. پس جدولِ بعدی هم بدونِ
   کارِ اضافه همین را دارد.

   سه) ذخیره با «ثبت» است نه با هر کلید: متنِ چندخطی را آدم وسطِ
   نوشتن رها می‌کند و می‌رود سرِ خط، و ذخیرهٔ خودکار یعنی نیمه‌کاره‌ها
   هم می‌نشینند. ولی Esc و کلیکِ بیرون هم بی‌هشدار نمی‌بندند اگر چیزی
   عوض شده باشد. */
const ROWNOTE = (function(){
  "use strict";
  let box = null, ta = null, titleEl = null, cur = null, startVal = "";

  function build(){
    if(box) return;
    box = document.createElement("div");
    box.id = "rowNoteBack";
    box.innerHTML =
      '<div class="rn-win" role="dialog" aria-modal="true" aria-labelledby="rowNoteTitle">' +
        '<div class="rn-head"><b id="rowNoteTitle"></b>' +
          '<button type="button" class="rn-x" title="بستن" aria-label="بستن">✕</button></div>' +
        '<textarea id="rowNoteText" rows="7" placeholder="هرچه لازم است این‌جا بنویسید…"></textarea>' +
        '<div class="rn-acts">' +
          /* «ثبت» کارِ اصلیِ این پنجره است و باید از «انصراف» جدا دیده
             شود. btn-brass همان دکمهٔ اصلیِ خودِ کارتابل است. */
          '<button type="button" class="btn btn-sm btn-brass rn-ok">ثبت</button>' +
          '<button type="button" class="btn btn-sm btn-ghost rn-cancel">انصراف</button>' +
          '<span class="rn-hint">Ctrl+Enter ثبت · Esc بستن</span>' +
        '</div>' +
      '</div>';
    document.body.appendChild(box);
    ta = box.querySelector("#rowNoteText");
    titleEl = box.querySelector("#rowNoteTitle");

    box.querySelector(".rn-ok").addEventListener("click", save);
    box.querySelector(".rn-cancel").addEventListener("click", ()=> close(true));
    box.querySelector(".rn-x").addEventListener("click", ()=> close(true));
    box.addEventListener("mousedown", e=>{ if(e.target === box) close(true); });
    document.addEventListener("keydown", e=>{
      if(!box.classList.contains("on")) return;
      if(e.key === "Escape"){ e.preventDefault(); close(true); }
      /* Ctrl+Enter همان «ثبت» — دستِ کسی که تایپ می‌کند از صفحه‌کلید
         در نمی‌آید. */
      if(e.key === "Enter" && (e.ctrlKey || e.metaKey)){ e.preventDefault(); save(); }
    });
  }

  function close(ask){
    if(!box) return;
    if(ask && ta.value !== startVal &&
       !confirm("یادداشت ذخیره نشده. بسته شود؟")) return;
    box.classList.remove("on");
    cur = null;
  }

  function save(){
    if(!cur) return;
    try{ cur.onSave(ta.value); }catch(e){ console.error("rownote:", e); }
    startVal = ta.value;
    close(false);
  }

  /* opt: { title, text, onSave(text) } */
  function open(opt){
    build();
    cur = opt || {};
    startVal = String(cur.text || "");
    titleEl.textContent = cur.title || "توضیحات";
    ta.value = startVal;
    box.classList.add("on");
    setTimeout(()=>{ try{ ta.focus(); }catch(e){} }, 40);
  }

  /* دکمهٔ مداد. «has» یعنی یادداشت دارد. data-* ها را خودِ صدا زننده
     می‌گذارد تا در شنوندهٔ خودش بشناسدشان. */
  function btn(has, attrs, title){
    const a = Object.keys(attrs || {})
      .map(k => ` ${k}="${String(attrs[k]).replace(/"/g, "&quot;")}"`).join("");
    return `<button type="button" class="rn-btn${has ? " has" : ""}"${a} ` +
      `title="${has ? "توضیحات دارد — برای دیدن یا تغییر بزنید" : (title || "افزودن توضیحات")}" ` +
      `aria-label="توضیحات">${has ? "📝" : "✏️"}</button>`;
  }

  return { open, btn, close };
})();
