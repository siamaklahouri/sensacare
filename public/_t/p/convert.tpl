/* ==================== تبدیل‌ها ====================
   یک بخش، همهٔ تبدیل‌هایی که وسطِ کار لازم می‌شود: وزن، طول، مساحت،
   حجم، دما، داده، زمان و واحدِ پولی — کنارِ تبدیلِ تاریخ که از قبل بود.

   دو تصمیم که شکلش را تعیین کرد:

   یک) همه‌چیز از یک جدولِ ضریب می‌آید، نه از کدِ جدا برای هر دسته.
   پس اضافه‌کردنِ یک واحدِ تازه یک خط است، و هیچ دسته‌ای از قلم
   نمی‌افتد. دما استثناست چون رابطه‌اش ضرب نیست، و جداگانه حساب
   می‌شود.

   دو) نرخِ ارز را خودِ کاربر می‌نویسد. نرخِ زنده لازم بود به جایی
   وصل شویم که هر روز عوض می‌شود و روزی که نرسد، عددِ غلط نشان
   می‌دهیم. این‌طوری عدد همیشه مالِ خودِ اوست و می‌داند از کجا آمده.
   تومان و ریال استثنا هستند چون نسبتشان ثابت است. */

var CONV = {
  weight: { t: "وزن", u: [
    ["kg", "کیلوگرم", 1], ["g", "گرم", 0.001], ["mg", "میلی‌گرم", 1e-6],
    ["ton", "تن", 1000], ["lb", "پوند", 0.45359237], ["oz", "اونس", 0.028349523125]
  ]},
  length: { t: "طول و اندازه", u: [
    ["m", "متر", 1], ["cm", "سانتی‌متر", 0.01], ["mm", "میلی‌متر", 0.001],
    ["km", "کیلومتر", 1000], ["in", "اینچ", 0.0254], ["ft", "فوت", 0.3048],
    ["yd", "یارد", 0.9144], ["mi", "مایل", 1609.344]
  ]},
  area: { t: "مساحت", u: [
    ["m2", "مترمربع", 1], ["cm2", "سانتی‌مترمربع", 0.0001],
    ["km2", "کیلومترمربع", 1e6], ["ha", "هکتار", 10000],
    ["jarib", "جریب", 1000], ["acre", "acre", 4046.8564224]
  ]},
  volume: { t: "حجم", u: [
    ["l", "لیتر", 1], ["ml", "میلی‌لیتر", 0.001], ["m3", "مترمکعب", 1000],
    ["gal", "گالن", 3.785411784], ["cup", "پیمانه", 0.24]
  ]},
  time: { t: "زمان", u: [
    ["s", "ثانیه", 1], ["min", "دقیقه", 60], ["h", "ساعت", 3600],
    ["d", "روز", 86400], ["wk", "هفته", 604800]
  ]},
  data: { t: "داده", u: [
    ["B", "بایت", 1], ["KB", "کیلوبایت", 1024], ["MB", "مگابایت", 1048576],
    ["GB", "گیگابایت", 1073741824], ["TB", "ترابایت", 1099511627776]
  ]},
  temp: { t: "دما", u: [["C", "سانتی‌گراد", 1], ["F", "فارنهایت", 1], ["K", "کلوین", 1]] },
  money: { t: "واحد پولی", u: [
    ["toman", "تومان", 1], ["rial", "ریال", 0.1],
    ["usd", "دلار", 0], ["eur", "یورو", 0], ["aed", "درهم", 0]
  ]}
};

/* دما با ضریب در نمی‌آید: اول به سانتی‌گراد، بعد از آن به مقصد. */
function tempTo(v, from, to) {
  var c = from === "C" ? v : from === "F" ? (v - 32) * 5 / 9 : v - 273.15;
  return to === "C" ? c : to === "F" ? c * 9 / 5 + 32 : c + 273.15;
}

function convUnits(cat) { return (CONV[cat] || CONV.weight).u; }
function convFactor(cat, code) {
  var u = convUnits(cat).find(function (x) { return x[0] === code; });
  return u ? u[2] : 1;
}
/* واحدی که ضریبش صفر است نرخ می‌خواهد (ارزهای خارجی). */
function convNeedsRate(cat, code) { return cat === "money" && !convFactor(cat, code); }

function convCalc(cat, from, to, val, rate) {
  if (!isFinite(val)) return null;
  if (cat === "temp") return tempTo(val, from, to);
  var f = convFactor(cat, from), t = convFactor(cat, to);
  if (cat === "money") {
    /* نرخ یعنی «هر واحدِ خارجی چند تومان». پس ارز → تومان ضرب است و
       تومان → ارز تقسیم. */
    if (!f) f = Number(rate) || 0;
    if (!t) t = Number(rate) || 0;
    if (!f || !t) return null;
  }
  if (!t) return null;
  return val * f / t;
}

/* عددِ خروجی: نه چهارده رقمِ اعشار، نه گردکردنی که عددِ کوچک را صفر
   کند. تا شش رقمِ معنادار، بعد صفرهای آخر برداشته می‌شوند. */
function convFmt(n) {
  if (!isFinite(n)) return "—";
  var a = Math.abs(n);
  var s = a === 0 ? "0"
        : a < 0.000001 ? n.toExponential(4)
        : a < 1 ? String(Number(n.toPrecision(6)))
        : Number(n.toFixed(a >= 1000 ? 2 : 4)).toLocaleString("en-US");
  return fa(s);
}

function convFill(sel, cat, keep) {
  sel.innerHTML = convUnits(cat).map(function (u) {
    return '<option value="' + u[0] + '">' + escapeHtml(u[1]) + "</option>";
  }).join("");
  if (keep && convUnits(cat).some(function (u) { return u[0] === keep; })) sel.value = keep;
}

function convRun() {
  var cat = document.getElementById("cvCat").value;
  var from = document.getElementById("cvFrom").value;
  var to = document.getElementById("cvTo").value;
  var raw = String(document.getElementById("cvVal").value || "").trim();
  var val = parseFloat(toLatinNumerals ? toLatinNumerals(raw) : raw);
  var rateBox = document.getElementById("cvRateBox");
  var need = convNeedsRate(cat, from) || convNeedsRate(cat, to);
  rateBox.hidden = !need;
  var rate = parseFloat(String(document.getElementById("cvRate").value || "").replace(/,/g, ""));
  var out = document.getElementById("cvOut");
  var note = document.getElementById("cvNote");
  note.textContent = "";
  if (!raw) { out.textContent = "—"; return; }
  if (!isFinite(val)) { out.textContent = "—"; note.textContent = "عدد را درست بنویسید."; return; }
  if (need && !(rate > 0)) {
    out.textContent = "—";
    note.textContent = "نرخ را بنویسید — هر واحد چند تومان.";
    return;
  }
  var r = convCalc(cat, from, to, val, rate);
  if (r === null) { out.textContent = "—"; return; }
  var nm = function (c) {
    var u = convUnits(cat).find(function (x) { return x[0] === c; });
    return u ? u[1] : c;
  };
  out.textContent = convFmt(val) + " " + nm(from) + "  =  " + convFmt(r) + " " + nm(to);
}

/* ---------- ماه ----------
   «مهر» روی تقویمِ میلادی روی دو ماه می‌افتد، و آدم معمولاً همین را
   می‌خواهد بداند: این ماهِ شمسی کِی شروع و کِی تمام می‌شود. */
var CONV_JM = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور",
               "مهر","آبان","آذر","دی","بهمن","اسفند"];

function convMonth() {
  var y = parseInt(document.getElementById("cvMY").value, 10);
  var m = parseInt(document.getElementById("cvMM").value, 10);
  var out = document.getElementById("cvMOut");
  if (!y || !m) { out.textContent = "—"; return; }
  var last = daysInJalaliMonth(y, m);
  var a = jalaliToGregorian(y, m, 1), b = jalaliToGregorian(y, m, last);
  var g = ["ژانویه","فوریه","مارس","آوریل","مه","ژوئن","ژوئیه",
           "اوت","سپتامبر","اکتبر","نوامبر","دسامبر"];
  /* دو قالب، دو شکلِ متفاوت از یک تابعِ هم‌نام: it یک شیء
     {gy,gm,gd} می‌دهد و fin یک آرایهٔ [gy,gm,gd]. این پاره مشترک است،
     پس هر دو را می‌پذیرد — وگرنه روی یکی‌شان «undefined» می‌نوشت،
     که همین اتفاق افتاد. */
  var one = function (d) {
    if (!d) return "—";
    var y = Array.isArray(d) ? d[0] : d.gy;
    var m = Array.isArray(d) ? d[1] : d.gm;
    var dd = Array.isArray(d) ? d[2] : d.gd;
    if (!y || !m || !dd) return "—";
    return fa(dd) + " " + g[m - 1] + " " + fa(y);
  };
  out.innerHTML =
    "<b>" + CONV_JM[m - 1] + " " + fa(y) + "</b> — " + fa(last) + " روز<br>" +
    "از " + one(a) + " تا " + one(b);
}

function setupConvert() {
  var box = document.getElementById("convBox");
  if (!box || box.dataset.ready) return;
  box.dataset.ready = "1";
  var today = getTodayJalaliParts();
  var ty = parseInt(today.year, 10) || 1405;
  box.innerHTML =
    '<div class="panel">' +
      "<h3>🔄 تبدیل واحد</h3>" +
      '<div class="cv-row">' +
        '<select id="cvCat">' + Object.keys(CONV).map(function (k) {
          return '<option value="' + k + '">' + escapeHtml(CONV[k].t) + "</option>";
        }).join("") + "</select>" +
        '<input type="text" id="cvVal" inputmode="decimal" placeholder="عدد" dir="ltr">' +
        '<select id="cvFrom"></select>' +
        '<button type="button" class="btn btn-sm" id="cvSwap" title="جابه‌جا">⇄</button>' +
        '<select id="cvTo"></select>' +
      "</div>" +
      '<div class="cv-row" id="cvRateBox" hidden>' +
        '<label class="cv-lb">نرخ (هر واحد چند تومان)</label>' +
        '<input type="text" id="cvRate" inputmode="decimal" placeholder="مثلاً ۹۰۰۰۰" dir="ltr">' +
      "</div>" +
      '<div class="cv-out" id="cvOut">—</div>' +
      '<div class="cv-note" id="cvNote"></div>' +
    "</div>" +
    '<div class="panel" style="margin-top:16px;">' +
      "<h3>🗓 ماهِ شمسی روی تقویمِ میلادی</h3>" +
      '<div class="cv-row">' +
        '<select id="cvMY"></select>' +
        '<select id="cvMM">' + CONV_JM.map(function (n, i) {
          return '<option value="' + (i + 1) + '">' + n + "</option>";
        }).join("") + "</select>" +
      "</div>" +
      '<div class="cv-out" id="cvMOut">—</div>' +
    "</div>";

  var cat = document.getElementById("cvCat");
  var from = document.getElementById("cvFrom"), to = document.getElementById("cvTo");
  var fill = function () {
    convFill(from, cat.value);
    convFill(to, cat.value);
    if (to.options.length > 1) to.selectedIndex = 1;
    convRun();
  };
  cat.addEventListener("change", fill);
  [from, to, document.getElementById("cvVal"), document.getElementById("cvRate")]
    .forEach(function (el) {
      el.addEventListener("input", convRun);
      el.addEventListener("change", convRun);
    });
  document.getElementById("cvSwap").addEventListener("click", function () {
    var a = from.value; from.value = to.value; to.value = a; convRun();
  });
  fill();

  var my = document.getElementById("cvMY");
  for (var y = ty - 3; y <= ty + 3; y++)
    my.innerHTML += '<option value="' + y + '"' + (y === ty ? " selected" : "") + ">" + fa(y) + "</option>";
  document.getElementById("cvMM").value = String(today.monthNum || 1);
  my.addEventListener("change", convMonth);
  document.getElementById("cvMM").addEventListener("change", convMonth);
  convMonth();
}
