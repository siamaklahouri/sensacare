/* ---------- فایلِ پشتیبانِ دستی: نوشتن و خواندن ----------
   «⬇ پشتیبان» و «⬆ بازیابی» در هر دو کارتابل یک کار می‌کنند، ولی
   دو بار نوشته شده بودند. نتیجه‌اش را یک بار دیدیم: فایل فقط «state»
   را داشت و نیمِ کارتابل جا می‌مانْد، و برای درست کردنش باید همان
   اصلاح را در دو فایل می‌زدی — که یعنی روزی یکی‌شان جا می‌مانَد.

   این‌جا فقط «شکلِ فایل» است. آن‌چه در هر کارتابل فرق دارد — یعنی
   «db» چیست و صفحه چطور دوباره رسم می‌شود — از بیرون داده می‌شود:

     dbSnapshot()        هر کارتابل خودش دارد
     applyDbSnapshot(c)  هر کارتابل خودش دارد
     rebuildAllSheets()  هر کارتابل خودش دارد
     KBK_REDRAW()        هر کارتابل تعریفش می‌کند

   شکلِ فایل: { kartabl: 2, stamp, state, db }
   فایل‌های قدیمی خودشان همان stateِ لُخت‌اند و تا همیشه باید باز
   شوند؛ تشخیص از روی وجودِ کلیدِ «state» است. */

/* صداکننده این را پر می‌کند. «var» تا ترتیبِ قرار گرفتنِ بخش‌ها در
   فایل مهم نباشد. */
var KBK_REDRAW = null;

function kbkFileText(){
  return JSON.stringify(
    { kartabl: 2, stamp: Date.now(), state: state, db: dbSnapshot() }, null, 1);
}

function kbkDownload(name){
  const blob = new Blob([kbkFileText()], { type: "application/json" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = name;
  document.body.appendChild(a); a.click(); a.remove();
  setTimeout(()=> URL.revokeObjectURL(a.href), 4000);
}

/* برمی‌گرداند: { ok, wrapped, hadDb } — تا صداکننده بتواند پیامِ
   خودش را بسازد. خطا را خودش بالا می‌دهد. */
function kbkRestore(text){
  const parsed = JSON.parse(text);
  const wrapped = !!(parsed && typeof parsed === "object" &&
                     parsed.state && typeof parsed.state === "object");
  state = Object.assign(deepClone(DEFAULT_STATE), wrapped ? parsed.state : parsed);
  let hadDb = false;
  if(wrapped && parsed.db){
    applyDbSnapshot(parsed.db);
    try{ rebuildAllSheets(); }catch(e){}
    try{ if(typeof persistDbCacheLocal === "function") persistDbCacheLocal(); }catch(e){}
    hadDb = true;
  }
  if(typeof KBK_REDRAW === "function") KBK_REDRAW();
  scheduleSave();
  return { ok: true, wrapped: wrapped, hadDb: hadDb };
}

/* پیامِ یکسان برای هر دو کارتابل. «چه چیزی برگشت» را می‌گوید، نه
   فقط «موفق»: فایلِ قدیمی نیمِ کارتابل را دارد و آدم باید بداند. */
function kbkRestoreNote(r, fullLabel, halfLabel){
  return r.hadDb
    ? "بازیابی انجام شد: " + fullLabel + "."
    : "بازیابی انجام شد: " + halfLabel + ".\n\n⚠️ این فایل از نسخهٔ قدیمیِ " +
      "پشتیبان است و بقیهٔ جدول‌ها داخلش نیست؛ آن‌ها دست‌نخورده ماندند.";
}

/* دکمه‌ها را می‌بندد. هر کارتابل فقط نامِ فایل و دو برچسب را می‌دهد. */
function kbkWireButtons(o){
  const ex = document.getElementById("exportBtn");
  if(ex) ex.addEventListener("click", ()=> kbkDownload(o.fileName));
  const im = document.getElementById("importBtn");
  const file = document.getElementById("importFile");
  if(im && file){
    im.addEventListener("click", ()=> file.click());
    file.addEventListener("change", (e)=>{
      const f = e.target.files[0];
      if(!f) return;
      const reader = new FileReader();
      reader.onload = ()=>{
        try{
          alert(kbkRestoreNote(kbkRestore(reader.result), o.fullLabel, o.halfLabel));
        }catch(err){ alert("فایل پشتیبان معتبر نیست."); }
      };
      reader.readAsText(f);
      e.target.value = "";
    });
  }
}
