/* ==================== کجای ماهی ====================
   توضیحِ کامل در pacecss. این‌جا فقط حساب است.

   دو درصد: چقدر از کار انجام شده، و چقدر از ماه گذشته. فاصلهٔ این دو
   همان چیزی است که آدم می‌خواهد بداند.

   قضاوت عمداً نرم است. «عقب» وقتی گفته می‌شود که فاصله از پانزده
   درصد بگذرد، نه یک درصد — کارِ ماهانه یکنواخت پیش نمی‌رود و
   هشداری که هر روز روشن باشد، هشدار نیست. */

function paceHtml(done, total, jy, jm, jd, opt) {
  if (!total) return '';
  opt = opt || {};

  /* طولِ ماه را از همان‌جایی می‌گیریم که تقویم می‌گیرد — اسفندِ
     کبیسه سی روز است و حدس زدنش یک روز خطا می‌دهد. */
  var days = 0;
  try {
    days = window.DatePick && window.DatePick.monthLen
      ? window.DatePick.monthLen(jy, jm) : 0;
  }
  catch (e) { days = 0; }
  if (!days) days = jm <= 6 ? 31 : (jm <= 11 ? 30 : 29);
  if (!(days > 0)) days = 30;
  if (!(jd > 0)) jd = 1;
  if (jd > days) jd = days;

  var workPct = Math.round((done / total) * 100);
  var timePct = Math.round((jd / days) * 100);
  var left = days - jd;
  var gap = timePct - workPct;

  var cls, say;
  if (workPct >= 100) { cls = 'done'; say = opt.full || 'ماه تمام شد'; }
  else if (gap <= 0)  { cls = 'ok';   say = 'جلوتر از تقویم'; }
  else if (gap <= 15) { cls = 'ok';   say = 'روی برنامه'; }
  else if (gap <= 35) { cls = 'warn'; say = 'کمی عقب'; }
  else                { cls = 'late'; say = 'عقب از برنامه'; }

  /* جملهٔ پایین عدد می‌دهد، نه صفت: «۱ از ۱۶ کار» و «۷ روز مانده»
     دو چیزی‌اند که آدم بعدش دنبالشان می‌گردد. */
  var foot = (opt.foot || faN(done) + ' از ' + faN(total) + ' کار') +
    (left > 0 ? ' · ' + faN(left) + ' روز تا پایان ماه' : ' · آخرین روزِ ماه');

  return '' +
    '<div class="dh-pace ' + cls + '">' +
      '<div class="dh-pace-top">' +
        '<span class="dh-pace-num">' + faN(workPct) + '<small>٪</small></span>' +
        '<span class="dh-pace-say">' + say + '</span>' +
      '</div>' +
      '<div class="dh-rail">' +
        '<div class="dh-rail-fill" style="width:' + workPct + '%"></div>' +
        '<div class="dh-rail-now" style="inset-inline-start:' + timePct + '%" ' +
          'data-day="امروز"></div>' +
      '</div>' +
      '<div class="dh-pace-foot"><span>' + foot + '</span>' +
        '<span>' + faN(timePct) + '٪ از ماه</span></div>' +
    '</div>';
}

/* رقمِ فارسی، بی وابستگی به تابعِ هر کارتابل */
function faN(n) {
  return String(n).replace(/[0-9]/g, function (d) { return '۰۱۲۳۴۵۶۷۸۹'[d]; });
}
