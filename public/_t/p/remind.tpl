/* ==================== یادآور، وقتی برنامه بسته است ====================
   تا حالا یادآورها فقط وقتی می‌آمدند که کارتابل باز بود: یک
   setInterval داخلِ همین صفحه هر بیست ثانیه نگاه می‌کرد. یعنی «فردا
   مهلتِ این وظیفه است» اگر آن روز کارتابل را باز نمی‌کردید، اصلاً
   نمی‌آمد — و یادآوری که باید یادش بیندازند، یادآور نیست.

   حالا صف می‌رود روی سرور و سرور هر دقیقه خودش نگاه می‌کند. ولی
   *ساختنِ* صف این‌جا می‌ماند، نه آن‌جا؛ دو دلیل دارد:

   یک) تاریخ‌ها شمسی‌اند و تبدیلشان این‌جا سال‌ها است کار می‌کند
   (DatePick). دوباره‌نویسی‌اش روی سرور یعنی دو جا که باید همیشه یک
   جواب بدهند — و روزی نمی‌دهند.

   دو) سررسیدهای «دیتای شخصی» از صندوقِ رمزشده می‌آیند و کلیدِ آن
   صندوق هیچ‌وقت به سرور نمی‌رسد. پس برای آن‌ها فقط *تاریخ* می‌رود،
   با متنی کلی: «یک سررسید نزدیک است». چه قسطی و چندم و چقدر، همان‌جا
   می‌ماند که باید بماند.

   و هیچ‌کدامِ این‌ها جای زنگوله و یادآورِ داخلِ صفحه را نمی‌گیرد؛
   کنارِ هم‌اند. */
(function(){
  var MONTHS = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور",
                "مهر","آبان","آذر","دی","بهمن","اسفند"];
  var DAY = 86400000;
  var LS = "sltechPushOn";
  var LSD = "sltechDigest";       /* خلاصهٔ صبحگاهی */
  /* ---------- چند روز قبل خبر برود ----------
     تا امروز هر سررسید یک خبر داشت: چک‌لیست «فردا» و دیتای شخصی «دو
     روز قبل». یک خبر برای کاری که دو روز دیگر است یعنی اگر همان یک
     بار را ندیدی، دیگر خبری نیست.

     حالا هر دو، دو بار خبر می‌دهند: دو روز مانده و یک روز مانده.
     ترتیبش از دور به نزدیک است تا متنِ هرکدام با فاصله‌اش بخواند. */
  var AHEAD = [2, 1];
  /* متنِ فاصله. «فردا» از «۱ روز مانده» طبیعی‌تر است. */
  function leftWord(d){ return d === 1 ? "فردا" : faNum(d) + " روز دیگر"; }
  var HOUR = 9;             /* ساعتِ یادآورهای روزانه‌نشده */

  function faNum(n){
    try{ return fa(String(n)); }catch(e){ return String(n); }
  }

  function toEn(s){
    return String(s == null ? "" : s).replace(/[۰-۹]/g,
      function(c){ return String("۰۱۲۳۴۵۶۷۸۹".indexOf(c)); });
  }

  function on(){ try{ return localStorage.getItem(LS) === "1"; }catch(e){ return false; } }
  /* پیش‌فرض روشن است: کسی که یادآور را خواسته، معمولاً خلاصهٔ صبح را
     هم می‌خواهد — و خاموش کردنش یک تیک است. */
  function digestOn(){ try{ return localStorage.getItem(LSD) !== "0"; }catch(e){ return true; } }
  function setDigest(v){ try{ localStorage.setItem(LSD, v ? "1" : "0"); }catch(e){} }
  function setOn(v){ try{ localStorage.setItem(LS, v ? "1" : "0"); }catch(e){} }

  function can(){
    return typeof Notification !== "undefined" &&
      "serviceWorker" in navigator && "PushManager" in window;
  }

  /* شمسی → لحظه، سرِ ساعتِ معین. کلِ حساب این‌جا با وقتِ همین دستگاه
     است و آن‌چه بالا می‌رود یک عددِ مطلق است، پس سرور لازم نیست چیزی
     از منطقهٔ زمانی بداند. */
  function stampAt(jy, jm, jd, hh){
    try{
      if(!window.DatePick || !DatePick.toG) return 0;
      var g = DatePick.toG(jy, jm, jd);
      if(!g || !g.gy) return 0;
      return new Date(g.gy, g.gm - 1, g.gd, hh, 0, 0, 0).getTime();
    }catch(e){ return 0; }
  }

  function keyParts(key){
    var p = String(key).split("|");
    var y = parseInt(toEn(p[0]), 10);
    var m = MONTHS.indexOf(String(p[1] || "").trim()) + 1;
    return (y && m) ? { y: y, m: m } : null;
  }

  function cut(s, n){
    s = String(s == null ? "" : s).replace(/\s+/g, " ").trim();
    return s.length > n ? s.slice(0, n - 1) + "…" : s;
  }

  /* ---------- خودِ صف ----------
     از همهٔ ماه‌ها، نه فقط ماهِ جاری: یادآورِ ماهِ بعد هم باید از حالا
     در صف باشد، وگرنه تا وقتی کاربر آن ماه را باز نکند خبری نیست —
     که همان ایرادِ اول بود. */
  function build(){
    var out = [], now = Date.now(), cap = now + 370 * DAY;
    var months = {};
    try{ months = allMonthsSnapshot() || {}; }catch(e){ months = {}; }

    Object.keys(months).forEach(function(key){
      var mk = keyParts(key);
      var md = months[key] || {};

      /* چک‌لیست: «فردا مهلت است» — همان قاعدهٔ یادآورِ داخلِ صفحه */
      if(mk) (md.tasks || []).forEach(function(t, i){
        if(!t || t.status === "انجام شد") return;
        var dd = parseInt(toEn(t.deadline), 10);
        if(!(dd >= 1 && dd <= 31)) return;
        var due = stampAt(mk.y, mk.m, dd, HOUR);
        if(!due) return;
        /* یک خبر برای هر فاصله. شناسه و برچسب هم باید فرق کنند،
           وگرنه دومی جای اولی را می‌گیرد و باز یک خبر می‌ماند. */
        AHEAD.forEach(function(d){
          var at = due - d * DAY;
          if(at <= now || at > cap) return;
          out.push({ id: "c|" + key + "|" + i + "|" + dd + "|" + d,
                     at: at, tag: "chk-" + key + "-" + i + "-d" + d,
                     title: "🕒 مهلت نزدیک",
                     body: leftWord(d) + " مهلتِ «" + cut(t.task, 70) + "»" +
                           (t.category ? " (" + cut(t.category, 30) + ")" : "") + " است." });
        });
      });

      /* برنامهٔ روزانه: ردیفِ مهم با ساعتِ یادآورِ دستی */
      (md.days || []).forEach(function(d, i){
        if(!d || !d.important || !d.reminderAt) return;
        var at = Date.parse(d.reminderAt);
        if(!at || at <= now || at > cap) return;
        out.push({ id: "d|" + key + "|" + i + "|" + at,
                   at: at, tag: "day-" + key + "-" + i,
                   title: "⭐ یادآوری برنامهٔ روزانه",
                   body: cut(d.main || ("روز " + (d.day == null ? "" : d.day)), 90) });
      });
    });

    /* دیتای شخصی: فقط تاریخ، با متنِ کلی. این فهرست از قبل بیرونِ
       رمز است (زنگوله بی‌باز کردنِ صندوق می‌خواندش) پس چیزِ تازه‌ای
       از صندوق بیرون نمی‌آید. */
    var due = [];
    try{ due = Array.isArray(state.personalDue) ? state.personalDue : []; }catch(e){ due = []; }
    due.forEach(function(k){
      var p = String(k).split("/");
      var at0 = stampAt(parseInt(toEn(p[0]), 10), parseInt(toEn(p[1]), 10),
                        parseInt(toEn(p[2]), 10), HOUR);
      if(!at0) return;
      AHEAD.forEach(function(d){
        var at = at0 - d * DAY;
        if(at <= now || at > cap) return;
        out.push({ id: "v|" + k + "|" + d, at: at, tag: "due-" + k + "-d" + d,
                   title: "🔔 سررسیدِ نزدیک",
                   body: leftWord(d) + " یک سررسید در دیتای شخصی است." +
                         " برای دیدنش کارتابل را باز کنید." });
      });
    });

    /* ---------- خلاصهٔ صبحگاهی ----------
       یک اعلان سرِ صبح: «امروز سه کار داری». تک‌تکِ کارها اعلان
       نمی‌خواهند — چیزی که آدم صبح می‌خواهد بداند، حجمِ روز است.
       شمارش از همان جایی می‌آید که بخشِ تقویم به‌کار می‌برد، پس با
       آنچه روی صفحه می‌بیند یکی است. */
    if(digestOn()){
      for(var n = 0; n <= 7; n++){
        var ms = Date.now() + n * DAY;
        var j = null;
        try{ j = DatePick.parse(DatePick.fromStamp(ms)); }catch(e){ j = null; }
        if(!j) continue;
        var at2 = stampAt(j.jy, j.jm, j.jd, 8);
        if(!at2 || at2 <= now || at2 > cap) continue;
        var list = [];
        try{ list = window.CAL ? CAL.items(j.jy, j.jm, j.jd) : []; }catch(e){ list = []; }
        var nDay = list.filter(function(x){ return x.t === "day"; }).length;
        var nTask = list.filter(function(x){ return x.t === "task"; }).length;
        var key = String(j.jy) + "/" + ("0" + j.jm).slice(-2) + "/" + ("0" + j.jd).slice(-2);
        var nDue = 0;
        try{
          nDue = (Array.isArray(state.personalDue) ? state.personalDue : [])
            .filter(function(k){ return k === key; }).length;
        }catch(e){}
        if(!nDay && !nTask && !nDue) continue;
        var say = [];
        if(nDay) say.push(faNum(nDay) + " کار");
        if(nTask) say.push(faNum(nTask) + " مهلت");
        if(nDue) say.push(faNum(nDue) + " سررسیدِ شخصی");
        out.push({ id: "m|" + key, at: at2, tag: "digest",
                   title: "☀️ برنامهٔ امروز",
                   body: say.join(" و ") + " برای امروز." });
      }
    }

    out.sort(function(a, b){ return a.at - b.at; });
    return out.slice(0, 200);
  }

  /* ---------- بالا فرستادنِ صف ----------
     کلِ صف می‌رود، نه تکه‌تکه: حساب کردنِ «کدام عوض شد» این‌جا از
     فرستادنِ دوبارهٔ یک فهرستِ کوچک گران‌تر است، و این‌طوری یادآورِ
     پاک‌شده هم خودبه‌خود از صف می‌افتد. امضا نگه داشته می‌شود تا هر
     ذخیره یک درخواستِ بی‌فایده نشود. */
  var lastSig = "", busy = false;
  async function sync(force){
    if(!on() || busy) return;
    var items = build();
    var sig = JSON.stringify(items);
    if(!force && sig === lastSig) return;
    busy = true;
    try{
      var r = await apiCall("/reminders", { method: "PUT", body: JSON.stringify({ items: items }) });
      if(r.ok) lastSig = sig;
    }catch(e){ /* شبکه نبود: دفعهٔ بعد */ }
    finally{ busy = false; }
  }

  /* سرویس‌ورکر آدرسِ api را از جایی درنمی‌آورد: دامنهٔ صفحه «/siamak/»
     است و api شاید «/api/kartabl» — اسمِ یکی از دیگری درنمی‌آید. */
  function tellWorker(){
    try{
      if(!navigator.serviceWorker) return;
      /* «ready» و نه «controller»: بارِ اولی که سرویس‌ورکر تازه نصب
         شده، کنترلری هنوز نیست و پیام بی‌صدا گم می‌شد — یعنی اولین
         اعلان بی‌متن می‌آمد. */
      navigator.serviceWorker.ready.then(function(reg){
        var w = reg.active || navigator.serviceWorker.controller;
        if(w) w.postMessage({ t: "api", base: KARTABL_API });
      }).catch(function(){});
    }catch(e){}
  }

  function u8(b64){
    var s = (b64 + "=".repeat((4 - b64.length % 4) % 4)).replace(/-/g, "+").replace(/_/g, "/");
    var raw = atob(s), out = new Uint8Array(raw.length);
    for(var i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
    return out;
  }

  async function subscribe(){
    var reg = await navigator.serviceWorker.ready;
    var cur = await reg.pushManager.getSubscription();
    var r = await apiCall("/push/key");
    if(!r.ok || !r.data.key) throw new Error("کلید نیامد");
    if(cur) {
      /* کلیدِ سرور که عوض شده باشد، اشتراکِ قبلی بی‌فایده است */
      try{ await cur.unsubscribe(); }catch(e){}
    }
    var sub = await reg.pushManager.subscribe({
      userVisibleOnly: true, applicationServerKey: u8(r.data.key) });
    var s = await apiCall("/push/subscribe", { method: "POST",
      body: JSON.stringify({ sub: { endpoint: sub.endpoint } }) });
    if(!s.ok) throw new Error((s.data && s.data.error) || "ثبت نشد");
    return sub;
  }

  async function enable(){
    if(!can()) throw new Error("مرورگرِ این دستگاه اعلانِ پس‌زمینه ندارد.");
    var perm = Notification.permission;
    if(perm !== "granted") perm = await Notification.requestPermission();
    if(perm !== "granted")
      throw new Error("اجازهٔ اعلان داده نشد. از تنظیماتِ مرورگر برای این سایت می‌شود روشنش کرد.");
    await subscribe();
    setOn(true);
    tellWorker();
    await sync(true);
  }

  async function disable(){
    setOn(false);
    try{
      var reg = await navigator.serviceWorker.ready;
      var sub = await reg.pushManager.getSubscription();
      if(sub){
        await apiCall("/push/unsubscribe", { method: "POST",
          body: JSON.stringify({ endpoint: sub.endpoint }) });
        await sub.unsubscribe();
      }
    }catch(e){}
    try{ await apiCall("/reminders", { method: "PUT", body: JSON.stringify({ items: [] }) }); }catch(e){}
    lastSig = "";
  }

  /* ---------- دکمهٔ تنظیمات ---------- */
  function paint(msg){
    var box = document.getElementById("remindBox");
    if(!box) return;
    var btn = document.getElementById("remindBtn");
    var st  = document.getElementById("remindState");
    if(!can()){
      if(btn){ btn.disabled = true; btn.textContent = "در این مرورگر نیست"; }
      if(st) st.textContent = "این دستگاه اعلانِ پس‌زمینه ندارد (روی آیفون فقط وقتی برنامه نصب شده باشد).";
      return;
    }
    var is = on();
    var dg = document.getElementById("remindDigest");
    if(dg){ dg.checked = digestOn(); dg.disabled = !is; }
    if(btn){ btn.disabled = false; btn.textContent = is ? "خاموش کن" : "روشن کن"; }
    if(st) st.textContent = msg || (is
      ? "روشن است — یادآورها حتی وقتی کارتابل بسته است می‌آیند."
      : (Notification.permission === "denied"
        ? "اعلانِ این سایت در مرورگر بسته است؛ اول از تنظیماتِ مرورگر بازش کنید."
        : "خاموش است."));
  }

  function wire(){
    var btn = document.getElementById("remindBtn");
    if(!btn || btn.dataset.wired) return;
    btn.dataset.wired = "1";
    var dg = document.getElementById("remindDigest");
    if(dg) dg.addEventListener("change", function(){
      setDigest(dg.checked);
      lastSig = "";          /* صف باید از نو ساخته شود */
      sync(true);
    });
    btn.addEventListener("click", async function(){
      btn.disabled = true;
      paint("…");
      try{
        if(on()) { await disable(); paint("خاموش شد."); }
        else { await enable(); paint("روشن شد."); }
      }catch(e){ paint(e && e.message ? e.message : "نشد."); }
      setTimeout(function(){ paint(); }, 2500);
      btn.disabled = false;
    });
    paint();
  }

  function init(){
    wire();
    if(!on()) return;
    tellWorker();
    /* اجازه که پس گرفته شده باشد، صف بی‌معنی است */
    if(can() && Notification.permission !== "granted"){ setOn(false); paint(); return; }
    sync(true);
    setInterval(function(){ sync(); }, 5 * 60 * 1000);
    /* لحظهٔ بسته شدنِ برنامه مهم‌ترین لحظه است: هر چه الان در صف
       نباشد، تا باز شدنِ بعدی هم نخواهد بود. */
    document.addEventListener("visibilitychange", function(){ if(document.hidden) sync(); });
    try{
      navigator.serviceWorker.addEventListener("message", function(e){
        if(e.data && e.data.t === "resubscribe")
          subscribe().then(function(){ sync(true); }).catch(function(){});
      });
    }catch(e){}
  }

  window.REMIND = { init: init, sync: sync, build: build, paint: paint,
                    on: on, enable: enable, disable: disable };
})();
