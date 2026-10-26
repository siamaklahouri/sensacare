/* ادغامِ ماه‌به‌ماه هنگامِ تداخل — مشترکِ هر دو کارتابل
   =================================================================
   تداخل از قبل گرفته می‌شد: صفحه baseRev می‌فرستد و سرور ۴۰۹ می‌دهد،
   پس هیچ‌وقت بی‌صدا روی کارِ دستگاهِ دیگر نوشته نمی‌شد. ولی چاره‌اش
   فقط دو دکمه بود: «نسخهٔ سرور را بیاور» یا «نسخهٔ من را بنویس» —
   یعنی در هر حال کارِ یک طرف دور ریخته می‌شد.

   در حالی که بیشترِ این تداخل‌ها اصلاً تداخل نیستند: روی گوشی ماهِ
   آبان را دست زده‌اید و روی لپ‌تاپ ماهِ مهر را. دادهٔ هر ماه جدا در
   monthsData نشسته، پس این دو هیچ برخوردی ندارند.

   این‌جا از روی «امضا»ی هر ماه در لحظهٔ آخرین ذخیره معلوم می‌شود چه
   کسی چه ماهی را عوض کرده. اگر ماه‌های دو طرف جدا بودند، هر دو با هم
   می‌نشینند و کاربر اصلاً نواری نمی‌بیند. فقط اگر هر دو طرف *یک* ماه
   را دست زده باشند، انتخاب لازم است — و آن موقع هم اسمِ همان ماه
   گفته می‌شود، نه یک هشدارِ کلی.

   امضا از خودِ متنِ JSON ساخته می‌شود، نه از محتوای کلِ state: نگه
   داشتنِ یک نسخهٔ کاملِ دیگر از دادهٔ چندمگابایتی در حافظه گران است. */
const Merge = (function(){
  /* هشِ سبک و کوتاه. رمزنگاری نیست و لازم هم نیست: فقط باید بگوید
     «عوض شد یا نه». */
  function sig(v){
    const s = v === undefined ? "\u0000" : JSON.stringify(v);
    let h1 = 0x811c9dc5, h2 = 0x01000193;
    for(let i = 0; i < s.length; i++){
      const c = s.charCodeAt(i);
      h1 = (h1 ^ c) >>> 0; h1 = (h1 * 16777619) >>> 0;
      h2 = (h2 + c * (i + 1)) >>> 0;
    }
    return h1.toString(36) + "." + h2.toString(36) + "." + s.length;
  }

  /* امضای هر ماه، به‌علاوهٔ صندوقِ رمزدار که آن هم یک واحدِ مستقل است */
  function snapshot(st){
    const out = {};
    const md = (st && st.monthsData) || {};
    for(const k of Object.keys(md)) out["m:" + k] = sig(md[k]);
    out["vault"] = sig(st && st.personalVault);
    return out;
  }

  function changedKeys(base, now){
    const keys = new Set([...Object.keys(base || {}), ...Object.keys(now || {})]);
    const out = [];
    for(const k of keys) if((base || {})[k] !== (now || {})[k]) out.push(k);
    return out;
  }

  const label = k => k.indexOf("m:") === 0
    ? k.slice(2).split("|").reverse().join(" ")
    : "دیتای شخصی";

  /* mine و theirs هر دو stateِ کامل‌اند. base امضاهای آخرین ذخیره.
     اگر base نداشته باشیم (صفحه تازه باز شده و هنوز چیزی نفرستاده)
     نمی‌شود فهمید چه کسی چه چیزی را عوض کرده، پس ادغام نمی‌کنیم. */
  function plan(base, mine, theirs){
    if(!base) return { ok: false, why: "no-base" };
    const mineNow = snapshot(mine), theirsNow = snapshot(theirs);
    const a = changedKeys(base, mineNow);
    const b = changedKeys(base, theirsNow);
    const clash = a.filter(k => b.indexOf(k) >= 0);
    return { ok: clash.length === 0, mine: a, theirs: b, clash,
             names: clash.map(label), tookNames: b.map(label) };
  }

  /* نسخهٔ سرور پایه است (هرچه آن‌ها داشته‌اند سرِ جایش می‌ماند) و
     ماه‌هایی که *من* عوض کرده‌ام رویش نوشته می‌شود. */
  function apply(mine, theirs, p){
    const out = JSON.parse(JSON.stringify(theirs || {}));
    if(!out.monthsData || typeof out.monthsData !== "object") out.monthsData = {};
    for(const k of p.mine){
      if(k === "vault"){ out.personalVault = mine ? mine.personalVault : null; continue; }
      const m = k.slice(2);
      if(mine && mine.monthsData && Object.prototype.hasOwnProperty.call(mine.monthsData, m))
        out.monthsData[m] = mine.monthsData[m];
      else delete out.monthsData[m];
    }
    /* ماهی که همین الان جلوی چشمِ کاربر باز است، مالِ همین دستگاه
       است و نباید با انتخابِ دستگاهِ دیگر عوض شود. */
    if(mine && mine.currentMonthKey) out.currentMonthKey = mine.currentMonthKey;
    return out;
  }

  return { snapshot, plan, apply, label };
})();
