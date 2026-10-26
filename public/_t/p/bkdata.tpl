/* دادهٔ داخلِ فایلِ پشتیبان — مشترکِ هر دو کارتابل */

/* ---------- دادهٔ داخلِ فایلِ پشتیبان ----------
   فایلِ پشتیبان تا حالا خالی باز می‌شد و آدم باید می‌فهمید که باید
   «⬆ بازیابی» بزند و کدام فایل را بدهد. حالا داده داخلِ خودِ صفحه
   نشسته و همان بار اول پُر باز می‌شود.

   مهرِ زمانِ پشتیبان نگه داشته می‌شود تا اگر همان فایل را دوباره باز
   کردید، چیزی که این وسط عوض کرده‌اید پاک نشود — ولی پشتیبانِ تازه‌تر
   جای قبلی را بگیرد. اگر localStorage در دسترس نباشد (روی file:// گاهی
   نیست) هر بار از خودِ فایل خوانده می‌شود، که همان رفتارِ درست است. */
let BK_SEED_READ = false, BK_SEED = null;
function bkSeed(){
  if(BK_SEED_READ) return BK_SEED;
  BK_SEED_READ = true;
  const s = (window.KARTABL_OFFLINE && window.KARTABL_SEED) ? window.KARTABL_SEED : null;
  if(s){
    try{
      if(localStorage.getItem(STORE_KEY + ":seed") === String(s.stamp)){ BK_SEED = null; return null; }
    }catch(e){ /* بدون حافظهٔ محلی هم باید باز شود */ }
  }
  BK_SEED = s;
  return BK_SEED;
}
function bkSeedDone(){
  const s = window.KARTABL_SEED;
  if(!s) return;
  try{ localStorage.setItem(STORE_KEY + ":seed", String(s.stamp)); }catch(e){}
}

async function loadState(){
  /* دادهٔ پشتیبان یک شاخهٔ جدا نیست، فقط یک سرچشمهٔ دیگر برای همان
