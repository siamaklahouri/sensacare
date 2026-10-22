/* ==================== تقویم ====================
   تا حالا تاریخ در کارتابل همه‌جا بود جز جایی که آدم تاریخ را در آن
   می‌بیند: یک تقویم. برنامهٔ روزانه جدول بود، چک‌لیست مهلت داشت، و
   اینکه «این هفته چه خبر است» را باید از روی ردیف‌ها درمی‌آوردی.

   این بخش همان را یک‌جا نشان می‌دهد: هر روز با کارهای خودش، تعطیلی‌ها
   به‌رنگ، و جایی برای یادداشتِ خودِ آن روز.

   سه تصمیم که شکلش را تعیین کرد:

   یک) تقویم از «ماهِ باز» مستقل است. ماهِ کارِ کارتابل یکی است و
   تقویم هر ماهی را که بخواهی نشان می‌دهد — از allMonthsSnapshot
   می‌خواند، پس کارهای ماه‌های دیگر هم سرِ جای خودشان دیده می‌شوند.

   دو) تعطیلی‌های قمری «تقریبی»اند و این‌جا هم همین نوشته شده. روزِ
   رسمیِ آن‌ها را هلالِ همان ماه تعیین می‌کند و هیچ فرمولی قطعی
   نمی‌گویدش؛ یک روز اختلاف عادی است. پس دو چیز هست: یک تنظیمِ
   «یک روز جلو/عقب» برای کلِ قمری‌ها، و امکانِ تعطیل/کاری کردنِ دستیِ
   هر روز که بر همه‌چیز می‌چربد. تقویمی که اشتباهش را نشود درست کرد،
   بدتر از نداشتنش است.

   سه) هر ماه رنگِ خودش را دارد — از سبزِ فروردین تا نیلیِ بهمن. نه
   برای تزیین: وقتی ماه را عوض می‌کنی باید بی‌خواندنِ عنوان بفهمی
   جابه‌جا شده‌ای. رنگ فقط روی همین بخش می‌نشیند و به تمِ کارتابل
   دست نمی‌زند. */
(function () {
  "use strict";

  var FA = "۰۱۲۳۴۵۶۷۸۹";
  var WD = ["شنبه", "یک‌شنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنج‌شنبه", "جمعه"];
  var view = null;         /* ماهی که دیده می‌شود: {jy, jm} */
  var sel = "";            /* روزِ انتخاب‌شده، به‌شکلِ کلید */
  var noteTimer = null;

  /* ---------- رنگِ هر ماه ----------
     از بهار تا زمستان. فقط یک رنگ گرفته می‌شود و بقیه (پس‌زمینهٔ کم‌رنگ
     و خطِ کناری) با شفافیت از خودش درمی‌آید — این‌طوری هم در حالتِ روز
     درست است هم در شب، بی‌آنکه برای هرکدام جدا تعریف شود. */
  var TONE = ["#2E9E6B", "#3FA37A", "#2E9AA8", "#D9A32E", "#E08A2E", "#C9942A",
              "#C4622E", "#A8452E", "#7A5AA8", "#2E6FA8", "#3A5A9E", "#2E9A8C"];
  var SEASON = ["🌱", "🌸", "🍃", "☀️", "🌞", "🌾", "🍂", "🍁", "🌧", "❄️", "⛄", "🌱"];

  function rgba(hex, a) {
    var h = String(hex).replace("#", "");
    return "rgba(" + parseInt(h.slice(0, 2), 16) + "," + parseInt(h.slice(2, 4), 16) +
           "," + parseInt(h.slice(4, 6), 16) + "," + a + ")";
  }

  function faN(n, w) {
    var s = String(n);
    while (w && s.length < w) s = "0" + s;
    return s.replace(/[0-9]/g, function (d) { return FA[+d]; });
  }
  function latin(s) {
    return String(s == null ? "" : s).replace(/[۰-۹]/g, function (d) { return String(FA.indexOf(d)); });
  }
  function key(v) {
    var m = latin(v).match(/(\d{3,4})\s*[\/\-.]\s*(\d{1,2})\s*[\/\-.]\s*(\d{1,2})/);
    return m ? m[1] + "/" + ("0" + m[2]).slice(-2) + "/" + ("0" + m[3]).slice(-2) : "";
  }
  function keyOf(jy, jm, jd) {
    return String(jy) + "/" + ("0" + jm).slice(-2) + "/" + ("0" + jd).slice(-2);
  }
  function faKey(k) {
    var p = String(k || "").split("/");
    return p.length === 3 ? faN(p[0]) + "/" + faN(p[1]) + "/" + faN(p[2]) : "";
  }
  function esc(s) {
    try { return escapeHtml(String(s == null ? "" : s)); }
    catch (e) { return String(s == null ? "" : s).replace(/[&<>"]/g, ""); }
  }
  function mName(jm) {
    try { return JALALI_MONTH_NAMES[jm - 1] || ""; } catch (e) { return String(jm); }
  }
  function mLen(jy, jm) {
    try { return daysInJalaliMonth(jy, jm); }
    catch (e) { return jm <= 6 ? 31 : (jm <= 11 ? 30 : 29); }
  }
  function today() {
    try { var t = DatePick.today(); return { jy: t.jy, jm: t.jm, jd: t.jd }; }
    catch (e) { return { jy: 1405, jm: 1, jd: 1 }; }
  }
  /* شنبه صفر */
  function wdOf(jy, jm, jd) {
    try {
      var g = DatePick.toG(jy, jm, jd);
      return (new Date(g.gy, g.gm - 1, g.gd).getDay() + 1) % 7;
    } catch (e) { return 0; }
  }

  /* ---------- تعطیلی‌ها ----------
     شمسی‌ها سرِ جای ثابتِ خودشان‌اند و دقیق. قمری‌ها از تقویمِ هجریِ
     خودِ مرورگر درمی‌آیند و تقریبی‌اند. */
  /* ---------- تعطیلی‌های رسمی ----------
     اول این‌ها را حساب می‌کردم: جدولِ ثابتِ شمسی، به‌اضافهٔ قمری‌ها از
     تقویمِ هجریِ خودِ مرورگر (اُم‌القری). شمسی‌ها درست درمی‌آمدند و
     قمری‌ها نه — تقویمِ رسمیِ ایران هلالِ خودش را دارد و معمولاً یک روز
     با اُم‌القری فرق می‌کند. یعنی تقویمی که نصفش غلط بود.

     حالا تاریخ‌ها جدولی‌اند: برای هر سال، همان چیزی که در تقویمِ رسمی
     آمده. سالِ داخلِ جدول هیچ حدسی در آن نیست.

     بیرونِ این سال‌ها همان حسابِ قبلی می‌ماند، ولی هر چه از آن درآید
     با * علامت می‌خورد و کنارِ تقویم هم نوشته می‌شود که تقریبی است.
     جدول که هر سال تازه شد، آن سال هم دقیق می‌شود. */
  var OFFICIAL = {
    1403: { "1/1":"نوروز", "1/2":"نوروز", "1/3":"نوروز", "1/4":"نوروز",
      "1/12":"روز جمهوری اسلامی · شهادت امام علی", "1/13":"روز طبیعت", "1/22":"عید فطر",
      "1/23":"تعطیلِ عید فطر", "2/15":"شهادت امام صادق", "3/14":"رحلت امام خمینی",
      "3/15":"قیام ۱۵ خرداد", "3/28":"عید قربان", "4/5":"عید غدیر", "4/26":"تاسوعا",
      "4/27":"عاشورا", "6/5":"اربعین حسینی", "6/13":"رحلت پیامبر و شهادت امام حسن",
      "6/14":"شهادت امام رضا", "6/22":"شهادت امام حسن عسکری",
      "6/31":"ولادت پیامبر و امام صادق", "9/15":"شهادت حضرت فاطمه", "10/24":"ولادت امام علی",
      "11/8":"مبعث", "11/22":"پیروزی انقلاب اسلامی", "11/26":"ولادت امام زمان",
      "12/29":"ملی شدن صنعت نفت" },
    1404: { "1/1":"نوروز · شهادت امام علی", "1/2":"نوروز", "1/3":"نوروز", "1/4":"نوروز",
      "1/11":"عید فطر", "1/12":"روز جمهوری اسلامی · تعطیلِ عید فطر", "1/13":"روز طبیعت",
      "2/4":"شهادت امام صادق", "3/14":"رحلت امام خمینی", "3/15":"قیام ۱۵ خرداد",
      "3/17":"عید قربان", "3/25":"عید غدیر", "4/14":"تاسوعا", "4/15":"عاشورا",
      "5/24":"اربعین حسینی", "6/1":"رحلت پیامبر و شهادت امام حسن", "6/2":"شهادت امام رضا",
      "6/10":"شهادت امام حسن عسکری", "6/19":"ولادت پیامبر و امام صادق",
      "9/3":"شهادت حضرت فاطمه", "10/12":"ولادت امام علی", "10/26":"مبعث",
      "11/14":"ولادت امام زمان", "11/22":"پیروزی انقلاب اسلامی", "12/19":"شهادت امام علی",
      "12/29":"ملی شدن صنعت نفت · عید فطر" },
    1405: { "1/1":"نوروز · تعطیلِ عید فطر", "1/2":"نوروز", "1/3":"نوروز", "1/4":"نوروز",
      "1/12":"روز جمهوری اسلامی", "1/13":"روز طبیعت", "1/24":"شهادت امام صادق",
      "3/6":"عید قربان", "3/14":"رحلت امام خمینی · عید غدیر", "3/15":"قیام ۱۵ خرداد",
      "4/3":"تاسوعا", "4/4":"عاشورا", "5/13":"اربعین حسینی",
      "5/21":"رحلت پیامبر و شهادت امام حسن", "5/22":"شهادت امام رضا",
      "5/30":"شهادت امام حسن عسکری", "6/8":"ولادت پیامبر و امام صادق",
      "7/22":"شهادت حضرت فاطمه", "10/2":"ولادت امام علی", "10/16":"مبعث",
      "11/4":"ولادت امام زمان", "11/22":"پیروزی انقلاب اسلامی", "12/9":"شهادت امام علی",
      "12/19":"عید فطر", "12/20":"تعطیلِ عید فطر", "12/29":"ملی شدن صنعت نفت" },
    1406: { "1/1":"نوروز", "1/2":"نوروز", "1/3":"نوروز", "1/4":"نوروز",
      "1/12":"روز جمهوری اسلامی", "1/13":"روز طبیعت", "1/14":"شهادت امام صادق",
      "2/27":"عید قربان", "3/4":"عید غدیر", "3/14":"رحلت امام خمینی", "3/15":"قیام ۱۵ خرداد",
      "3/24":"تاسوعا", "3/25":"عاشورا", "5/3":"اربعین حسینی",
      "5/11":"رحلت پیامبر و شهادت امام حسن", "5/12":"شهادت امام رضا",
      "5/20":"شهادت امام حسن عسکری", "5/29":"ولادت پیامبر و امام صادق",
      "8/12":"شهادت حضرت فاطمه", "9/21":"ولادت امام علی", "10/5":"مبعث",
      "10/23":"ولادت امام زمان", "11/22":"پیروزی انقلاب اسلامی", "11/28":"شهادت امام علی",
      "12/8":"عید فطر", "12/9":"تعطیلِ عید فطر", "12/29":"ملی شدن صنعت نفت" },
    1407: { "1/1":"نوروز", "1/2":"نوروز", "1/3":"نوروز · شهادت امام صادق", "1/4":"نوروز",
      "1/12":"روز جمهوری اسلامی", "1/13":"روز طبیعت", "2/16":"عید قربان", "2/24":"عید غدیر",
      "3/13":"تاسوعا", "3/14":"رحلت امام خمینی · عاشورا", "3/15":"قیام ۱۵ خرداد",
      "4/23":"اربعین حسینی", "4/31":"رحلت پیامبر و شهادت امام حسن", "5/1":"شهادت امام رضا",
      "5/9":"شهادت امام حسن عسکری", "5/18":"ولادت پیامبر و امام صادق",
      "8/1":"شهادت حضرت فاطمه", "9/10":"ولادت امام علی", "9/24":"مبعث",
      "10/12":"ولادت امام زمان", "11/17":"شهادت امام علی", "11/22":"پیروزی انقلاب اسلامی",
      "11/27":"عید فطر", "11/28":"تعطیلِ عید فطر", "12/21":"شهادت امام صادق",
      "12/29":"ملی شدن صنعت نفت" }
  };

  /* و این‌ها قانونی‌اند و سرِ جای ثابتِ خودشان، پس برای سالِ بیرونِ
     جدول هم درست‌اند. */
  var SOLAR = {
    "1/1": "نوروز", "1/2": "نوروز", "1/3": "نوروز", "1/4": "نوروز",
    "1/12": "روز جمهوری اسلامی", "1/13": "روز طبیعت",
    "3/14": "رحلت امام خمینی", "3/15": "قیام ۱۵ خرداد",
    "11/22": "پیروزی انقلاب اسلامی", "12/29": "ملی شدن صنعت نفت"
  };
  var LUNAR = {
    "1/9": "تاسوعا", "1/10": "عاشورا",
    "2/20": "اربعین حسینی", "2/28": "رحلت پیامبر و شهادت امام حسن",
    "2/30": "شهادت امام رضا",
    "3/8": "شهادت امام حسن عسکری", "3/17": "ولادت پیامبر و امام صادق",
    "6/3": "شهادت حضرت فاطمه",
    "7/13": "ولادت امام علی", "7/27": "مبعث",
    "8/15": "ولادت امام زمان",
    "9/21": "شهادت امام علی",
    "10/1": "عید فطر", "10/2": "تعطیلِ عید فطر",
    "10/25": "شهادت امام صادق",
    "12/10": "عید قربان", "12/18": "عید غدیر"
  };
  function exact(jy) { return !!OFFICIAL[jy]; }

  var hFmt, hCache = {};
  function hijriAt(ms) {
    try {
      if (!hFmt) hFmt = new Intl.DateTimeFormat("en-u-ca-islamic-umalqura-nu-latn",
        { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" });
      var o = {};
      hFmt.formatToParts(new Date(ms)).forEach(function (p) { o[p.type] = p.value; });
      return { hm: +o.month, hd: +o.day, hy: +o.year };
    } catch (e) { return null; }
  }
  /* لحظهٔ همان روز به وقتِ گرینویچ — پایهٔ همهٔ حساب‌های قمری */
  function utcOf(jy, jm, jd) {
    try {
      var g = DatePick.toG(jy, jm, jd);
      return g ? Date.UTC(g.gy, g.gm - 1, g.gd) : 0;
    } catch (e) { return 0; }
  }
  function hijri(jy, jm, jd) {
    var ck = jy + "-" + jm + "-" + jd + "@" + shift();
    if (ck in hCache) return hCache[ck];
    var ms = utcOf(jy, jm, jd);
    /* جابه‌جاییِ کاربر: هلال را فرمول تعیین نمی‌کند و یک روز اختلاف
       با اعلامِ رسمی عادی است. */
    var out = ms ? hijriAt(ms - shift() * 86400000) : null;
    hCache[ck] = out;
    return out;
  }
  /* ماهِ صفر که ۲۹ روزه باشد، «۳۰ صفر» آن سال روی ۲۹ می‌افتد. همین
     یک استثنا را دستی می‌گیریم، چون شهادتِ امام رضا تعطیلِ رسمی است
     و سالی که صفر کوتاه است از تقویم می‌افتاد. */
  function lunarName(jy, jm, jd) {
    var h = hijri(jy, jm, jd);
    if (!h) return null;
    var n = LUNAR[h.hm + "/" + h.hd];
    if (n) return n;
    if (h.hm === 2 && h.hd === 29) {
      var nx = hijriAt(utcOf(jy, jm, jd) - shift() * 86400000 + 86400000);
      if (nx && nx.hm === 3 && nx.hd === 1) return LUNAR["2/30"];
    }
    return null;
  }

  function shift() {
    try { return Number(state.calLunarShift) || 0; } catch (e) { return 0; }
  }
  function notes() {
    try {
      if (!state.calNotes || typeof state.calNotes !== "object") state.calNotes = {};
      return state.calNotes;
    } catch (e) { return {}; }
  }
  function offs() {
    try {
      if (!state.calOff || typeof state.calOff !== "object") state.calOff = {};
      return state.calOff;
    } catch (e) { return {}; }
  }

  /* تعطیلیِ یک روز: جمعه، جدولِ شمسی، جدولِ قمری — و بعد از همه،
     حرفِ خودِ کاربر که بر همه می‌چربد. */
  function holiday(jy, jm, jd) {
    var k = keyOf(jy, jm, jd), own = offs();
    var names = [], approx = false, off = false;
    if (wdOf(jy, jm, jd) === 6) { off = true; names.push("جمعه"); }
    var tbl = OFFICIAL[jy];
    if (tbl) {
      /* سالِ داخلِ جدول: همین و بس. هیچ حدسی رویش سوار نمی‌شود. */
      var n = tbl[jm + "/" + jd];
      if (n) { off = true; names.push(n); }
    } else {
      var sName = SOLAR[jm + "/" + jd];
      if (sName) { off = true; names.push(sName); }
      var l = lunarName(jy, jm, jd);
      if (l) { off = true; approx = true; names.push(l); }
    }
    if (k in own) { off = own[k] === 1; if (!off) approx = false; }
    var hj = hijri(jy, jm, jd);
    return { off: off, approx: approx, exact: !!tbl,
             name: names.join(" · "), hijri: hj };
  }

  /* ---------- کارهای هر روز ---------- */
  function monthData(jy, jm) {
    var snap = {};
    try { snap = allMonthsSnapshot() || {}; } catch (e) { snap = {}; }
    var want = String(jy) + "|" + mName(jm);
    var md = snap[want] || null;
    /* کلیدِ ماه با نامِ ماه ساخته می‌شود؛ اگر سالِ کلید رقمِ فارسی
       داشته باشد همان‌جا هم بگرد. */
    if (!md) {
      Object.keys(snap).forEach(function (k) {
        var p = k.split("|");
        if (+latin(p[0]) === jy && String(p[1] || "").trim() === mName(jm)) md = snap[k];
      });
    }
    return md || { tasks: [], days: [] };
  }

  function dayItems(jy, jm, jd) {
    var md = monthData(jy, jm), k = keyOf(jy, jm, jd), out = [];
    (md.days || []).forEach(function (d, i) {
      if (key(d && d.createdDate) !== k) return;
      out.push({ t: "day", i: i, text: d.main || d.meet || "بی‌عنوان",
                 sub: d.company || "", status: d.status || "" });
    });
    (md.tasks || []).forEach(function (t, i) {
      if ((parseInt(latin(t && t.deadline), 10) || 0) !== jd) return;
      out.push({ t: "task", i: i, text: t.task || "بی‌عنوان",
                 sub: t.category || "", status: t.status || "" });
    });
    return out;
  }

  /* ---------- کشیدنِ تقویم ---------- */
  function host() { return document.getElementById("view-cal"); }

  function paintTone() {
    var h = host();
    if (!h || !view) return;
    var c = TONE[(view.jm - 1) % 12];
    h.style.setProperty("--c2", c);
    h.style.setProperty("--c2-bg", rgba(c, 0.10));
    h.style.setProperty("--c2-soft", rgba(c, 0.18));
    h.style.setProperty("--c2-line", rgba(c, 0.34));
  }

  /* روی خانهٔ تقویم فقط یک سطر جا می‌شود: مناسبت مهم‌تر از «جمعه»
     است، پس اگر هر دو بودند آن یکی نوشته می‌شود. */
  function label(name) {
    var parts = String(name || "").split(" · ");
    for (var i = 0; i < parts.length; i++) if (parts[i] !== "جمعه") return parts[i];
    return parts[0] || "";
  }

  function render() {
    var h = host();
    if (!h) return;
    if (!view) { var t = today(); view = { jy: t.jy, jm: t.jm }; }
    paintTone();
    /* سالِ داخلِ جدول با سالِ بیرونِ جدول دو چیزِ متفاوت‌اند و صفحه
       باید همین را بگوید، نه اینکه هر دو را یک‌جور نشان بدهد. */
    h.setAttribute("data-exact", exact(view.jy) ? "1" : "0");
    var t2 = today();
    var ttl = document.getElementById("calTtl");
    if (ttl) ttl.innerHTML = SEASON[(view.jm - 1) % 12] + " " + mName(view.jm) + " " + faN(view.jy);

    var n = mLen(view.jy, view.jm), lead = wdOf(view.jy, view.jm, 1), html = "";
    for (var i = 0; i < lead; i++) html += '<div class="c2-cell c2-blank"></div>';
    for (var d = 1; d <= n; d++) {
      var k = keyOf(view.jy, view.jm, d);
      var hol = holiday(view.jy, view.jm, d);
      var it = dayItems(view.jy, view.jm, d);
      var note = notes()[k] || "";
      var isToday = (t2.jy === view.jy && t2.jm === view.jm && t2.jd === d);
      html += '<div class="c2-cell' + (hol.off ? " off" : "") + (isToday ? " today" : "") +
        (sel === k ? " sel" : "") + '" data-cal-day="' + d + '" role="button" tabindex="0"' +
        (hol.name ? ' title="' + esc(hol.name) + (hol.approx ? " (تقریبی)" : "") + '"' : "") + '>' +
        '<div class="c2-top"><span class="c2-num">' + faN(d) + '</span>' +
          (note ? '<span class="c2-note" title="یادداشت دارد">📝</span>' : "") + '</div>' +
        (hol.name ? '<div class="c2-hol">' + esc(label(hol.name)) +
           (hol.approx ? "<i>*</i>" : "") + '</div>' : "") +
        (it.length ? '<div class="c2-items">' + it.slice(0, 3).map(function (x) {
            return '<span class="c2-it' + (x.t === "task" ? " tsk" : "") + '">' + esc(x.text) + '</span>';
          }).join("") + (it.length > 3 ? '<span class="c2-more">+' + faN(it.length - 3) + '</span>' : "") +
          '</div>' : "") +
        '</div>';
    }
    var grid = document.getElementById("calGrid");
    if (grid) grid.innerHTML = html;
    paintSide();
  }

  /* ---------- کنارهٔ روزِ انتخاب‌شده ---------- */
  function paintSide() {
    var box = document.getElementById("calSide");
    if (!box) return;
    if (!sel) {
      box.innerHTML = '<div class="c2-empty">یک روز را انتخاب کنید تا کارها و یادداشتش این‌جا بیاید.</div>';
      return;
    }
    var p = sel.split("/"), jy = +p[0], jm = +p[1], jd = +p[2];
    var hol = holiday(jy, jm, jd), it = dayItems(jy, jm, jd);
    var hj = hol.hijri;
    var g = null;
    try { g = DatePick.toG(jy, jm, jd); } catch (e) { }
    box.innerHTML =
      '<div class="c2-sh">' +
        '<div class="c2-sh-d">' + faN(jd) + " " + mName(jm) + "</div>" +
        '<div class="c2-sh-w">' + WD[wdOf(jy, jm, jd)] + " · " + faKey(sel) + "</div>" +
        '<div class="c2-sh-x">' +
          (g ? faN(g.gy) + "/" + faN(g.gm, 2) + "/" + faN(g.gd, 2) + " میلادی" : "") +
          (hj ? " · " + faN(hj.hd) + "/" + faN(hj.hm, 2) + "/" + faN(hj.hy) + " قمری" : "") +
        "</div>" +
        (hol.name ? '<div class="c2-sh-h">' + esc(hol.name) +
           (hol.approx ? ' <span class="c2-ap">تقریبی</span>' : "") + "</div>" : "") +
      "</div>" +
      '<div class="c2-sw">' +
        '<button type="button" class="c2-btn" id="calOffBtn">' +
          (hol.off ? "✓ تعطیل — کاری‌اش کن" : "این روز تعطیل است") + "</button>" +
        '<button type="button" class="c2-btn" id="calGoBtn">رفتن به برنامهٔ روزانه</button>' +
      "</div>" +
      '<div class="c2-list">' + (it.length ? it.map(function (x) {
        return '<div class="c2-row"><span class="c2-tag' + (x.t === "task" ? " tsk" : "") + '">' +
          (x.t === "task" ? "چک‌لیست" : "روزانه") + "</span>" +
          '<span class="c2-txt">' + esc(x.text) + "</span>" +
          (x.sub ? '<span class="c2-sub">' + esc(x.sub) + "</span>" : "") +
          (x.status ? '<span class="c2-st">' + esc(x.status) + "</span>" : "") + "</div>";
      }).join("") : '<div class="c2-empty">کاری برای این روز ثبت نشده.</div>') + "</div>" +
      '<label class="c2-nl" for="calNote">یادداشتِ این روز</label>' +
      '<textarea id="calNote" class="c2-note-in" rows="4" placeholder="هرچه برای این روز باید یادت بماند…"></textarea>' +
      '<div class="c2-hint" id="calNoteHint"></div>';

    var ta = document.getElementById("calNote");
    if (ta) {
      ta.value = notes()[sel] || "";
      ta.addEventListener("input", function () {
        var v = ta.value;
        var n2 = notes();
        if (v.trim()) n2[sel] = v; else delete n2[sel];
        var hint = document.getElementById("calNoteHint");
        if (hint) hint.textContent = "ذخیره می‌شود…";
        clearTimeout(noteTimer);
        noteTimer = setTimeout(function () {
          try { scheduleSave(); } catch (e) { }
          if (hint) hint.textContent = "ذخیره شد";
          /* نشانهٔ 📝 روی خانهٔ همان روز */
          var cell = document.querySelector('[data-cal-day="' + (+sel.split("/")[2]) + '"]');
          if (cell) {
            var top = cell.querySelector(".c2-top");
            var has = top && top.querySelector(".c2-note");
            if (v.trim() && top && !has) {
              var s = document.createElement("span");
              s.className = "c2-note"; s.textContent = "📝"; top.appendChild(s);
            } else if (!v.trim() && has) has.remove();
          }
        }, 700);
      });
    }
    var off = document.getElementById("calOffBtn");
    if (off) off.addEventListener("click", function () {
      var o = offs();
      o[sel] = hol.off ? 0 : 1;
      try { scheduleSave(); } catch (e) { }
      render();
    });
    var go = document.getElementById("calGoBtn");
    if (go) go.addEventListener("click", function () { goDaily(sel); });
  }

  /* بردن به برنامهٔ روزانه، روی همان روز. اگر ماهِ باز ماهِ دیگری
     باشد اول ماه عوض می‌شود — وگرنه فیلتر روی ماهی می‌نشست که آن
     تاریخ اصلاً در آن نیست و جدول خالی می‌شد. */
  function goDaily(k) {
    var p = k.split("/"), jy = +p[0], jm = +p[1];
    try {
      var cur = String(state.currentMonthKey || "");
      var want = String(jy) + "|" + mName(jm);
      if (cur !== want && typeof switchToMonth === "function")
        switchToMonth(mName(jm), String(jy), { carryTasks: false });
    } catch (e) { }
    try { if (window.DAY_DATE) DAY_DATE.set([faKey(k)]); } catch (e) { }
    var nb = document.querySelector('.navbtn[data-view="daily"]');
    if (nb) nb.click();
    try { renderDaily(); } catch (e) { }
    try { if (window.DAYCAL) DAYCAL.refresh(); } catch (e) { }
  }

  function step(n) {
    view.jm += n;
    if (view.jm > 12) { view.jm = 1; view.jy++; }
    if (view.jm < 1) { view.jm = 12; view.jy--; }
    render();
  }

  function init() {
    var h = host();
    if (!h || h.dataset.wired) return;
    h.dataset.wired = "1";
    var t = today();
    view = { jy: t.jy, jm: t.jm };
    /* ماهِ باز را ترجیح می‌دهد: آدم معمولاً همان را می‌خواهد ببیند */
    try {
      var p = String(state.currentMonthKey || "").split("|");
      var y = parseInt(latin(p[0]), 10);
      var m = JALALI_MONTH_NAMES.indexOf(String(p[1] || "").trim()) + 1;
      if (y && m) view = { jy: y, jm: m };
    } catch (e) { }

    h.addEventListener("click", function (e) {
      var s = e.target.closest ? e.target.closest("[data-cal-step]") : null;
      if (s) { step(Number(s.getAttribute("data-cal-step"))); return; }
      if (e.target.closest && e.target.closest("#calToday")) {
        var t2 = today();
        view = { jy: t2.jy, jm: t2.jm };
        sel = keyOf(t2.jy, t2.jm, t2.jd);
        render();
        return;
      }
      var c = e.target.closest ? e.target.closest("[data-cal-day]") : null;
      if (c) {
        sel = keyOf(view.jy, view.jm, Number(c.getAttribute("data-cal-day")));
        render();
      }
    });
    h.addEventListener("keydown", function (e) {
      if (e.key !== "Enter" && e.key !== " ") return;
      var c = e.target.closest ? e.target.closest("[data-cal-day]") : null;
      if (!c) return;
      e.preventDefault();
      sel = keyOf(view.jy, view.jm, Number(c.getAttribute("data-cal-day")));
      render();
    });
    var sh = document.getElementById("calShift");
    if (sh) {
      sh.value = String(shift());
      sh.addEventListener("change", function () {
        try { state.calLunarShift = Number(sh.value) || 0; scheduleSave(); } catch (e) { }
        hCache = {};
        render();
      });
    }
    render();
  }

  window.CAL = { init: init, render: render, go: goDaily,
                 holiday: holiday, items: dayItems };
})();
