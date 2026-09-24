
const Cloud = (function(){
  let rev = null;          /* نسخه‌ای که این مرورگر از آن شروع کرده */
  let online = false;      /* آخرین بار توانستیم با سرور حرف بزنیم؟ */
  let blocked = false;     /* سرور علامت خرابی داده — تا روشن نشدن ننویس */
  let timer = null;
  let inFlight = false;
  let again = false;       /* وسط ارسال، تغییر تازه‌ای رسید */

  function setHint(text){
    const h = document.getElementById("saveHint");
    if(h) h.textContent = text;
  }
  function setCloudStatus(text){
    const el = document.getElementById("cloudStatus");
    if(el) el.textContent = text;
  }

  /* وقتی دو دستگاه هم‌زمان کار کرده‌اند، بی‌صدا روی کار دیگری نمی‌نویسیم */
  function showConflict(){
    if(document.getElementById("syncConflict")) return;
    const bar = document.createElement("div");
    bar.id = "syncConflict";
    bar.innerHTML =
      '<span>این کارتابل از دستگاه دیگری هم تغییر کرده است. کدام نسخه بماند؟</span>' +
      '<button type="button" id="conflictTake">نسخهٔ سرور را بیاور</button>' +
      '<button type="button" id="conflictKeep">نسخهٔ من را بنویس</button>';
    document.body.appendChild(bar);
    document.getElementById("conflictTake").addEventListener("click", ()=> location.reload());
    document.getElementById("conflictKeep").addEventListener("click", async ()=>{
      /* این دکمه کارِ دستگاه دیگر را دور می‌ریزد. قبلاً بی‌هشدار بود. */
      if(!confirm("هر تغییری که از دستگاه دیگر ذخیره شده برای همیشه با نسخهٔ همین صفحه جایگزین می‌شود.\n\nمطمئنید؟")) return;
      bar.remove();
      rev = null;                 /* بدون baseRev یعنی «همین را بنویس» */
      await push(true, true);
    });
  }

  /* سرور جلوی نوشتنی را گرفته که بخش بزرگی از داده را می‌برد */
  function showLoss(why){
    if(document.getElementById("syncLoss")) return;
    const bar = document.createElement("div");
    bar.id = "syncLoss"; bar.className = "sync-warn";
    bar.innerHTML =
      '<span>این ذخیره ' + escapeHtml(why) + '. عمدی بود؟</span>' +
      '<button type="button" id="lossKeep">بله، همین را بنویس</button>' +
      '<button type="button" id="lossTake">نه، نسخهٔ سرور را بیاور</button>';
    document.body.appendChild(bar);
    document.getElementById("lossTake").addEventListener("click", ()=> location.reload());
    document.getElementById("lossKeep").addEventListener("click", async ()=>{
      bar.remove();
      await push(true, true);
    });
  }

  async function pull(){
    if(window.KARTABL_OFFLINE){ setCloudStatus("نسخهٔ پشتیبان — روی سرور نیست."); return false; }
    try{
      const r = await apiCall("/state");
      if(r.status === 401){ online = false; setCloudStatus("وارد نشده‌اید."); return false; }
      if(!r.ok) throw new Error(r.data.error || "خطای سرور");
      /* تلهٔ اصلی این‌جا بود: اگر سرور چیزی برنمی‌گرداند، کدِ قبلی نسخهٔ
         کهنهٔ همین مرورگر را نگه می‌داشت، خودش را «آنلاین» اعلام می‌کرد و
         با اولین ویرایش همان کهنه را روی سرور می‌نوشت. حالا فرق می‌گذاریم
         بین «سرور تازه است و هنوز چیزی ندارد» (rev صفر) و «سرور داده دارد
         ولی نیامد» (rev بزرگ‌تر از صفر) — دومی یعنی یک جای کار خراب است و
         تا روشن نشده هیچ نوشتنی نباید انجام شود. */
      const srvRev = r.data.rev || 0;
      if(!r.data.state && srvRev > 0){
        online = false; blocked = true; rev = null;
        setCloudStatus("⚠️ سرور دادهٔ این کارتابل را برنگرداند. تا روشن نشدن، ذخیره متوقف است — چیزی را عوض نکنید.");
        return false;
      }