/* نتیجهٔ هر جابِ Veeam، از روی اجراهایش
   =================================================================
   این کار تا امروز روی خودِ ویندوزِ کنارِ Veeam انجام می‌شد، داخلِ
   veeam-push.ps1. و همان‌جا بود که دو بار اشتباه درآمد — چون هر
   اصلاح، یعنی کسی باید می‌رفت سرِ آن ویندوز، فایل را عوض می‌کرد و
   دستی اجرا می‌کرد. تا آن لحظه، کارتابل عددِ غلط را نشان می‌داد.

   پس منطق آمد این‌جا. اسکریپت فقط آن‌چه Veeam می‌گوید را خام
   می‌فرستد — جاب‌ها و اجراها — و تصمیم با سرور است. از این به بعد هر
   اصلاحی با یک `update.sh` روی خودِ سرور پخش می‌شود و دستِ هیچ‌کس به
   آن ویندوز نمی‌خورد.

   قاعده، در یک جمله: نتیجهٔ یک جاب، نتیجهٔ همان اجرایی است که آخر از
   همه تمام شده. سه تله در همین یک جمله هست و هر سه را یک بار خورده‌ایم:

   یک) Veeam اجرای معمولی را با پسوندِ نوعِ بکاپ می‌نامد — «Once a Day
   (Incremental)» — ولی «تلاشِ دوباره» را با نامِ خالیِ جاب. اگر اول
   نامِ دقیق را امتحان کنی و همان‌جا بایستی، تلاشِ دوبارهٔ دو روزِ پیش
   اجرای موفقِ دیشب را کنار می‌زند.

   دو) اجرایی که هنوز تمام نشده نتیجه ندارد. اگر «تازه‌تر» را با زمانِ
   شروع بسنجی، همان اجرای در حالِ انجام برنده می‌شود و ستونِ نتیجه
   خالی (یا بدتر، قرمز) می‌شود.

   سه) پسوند باید پرانتزِ خودِ Veeam باشد، نه هر چیزی. وگرنه جابِ
   «Backup» اجرای جابِ «Backup Copy» را به تن می‌کند. */

/* آیا این اجرا، اجرای این جاب است؟ */
export function sessionOfJob(session, jobName) {
  const sn = String((session && session.name) || '');
  const jn = String(jobName || '');
  if (!sn || !jn) return false;
  if (sn === jn) return true;
  if (sn.length <= jn.length) return false;
  if (sn.slice(0, jn.length).toLowerCase() !== jn.toLowerCase()) return false;
  return /^\s*\(.+\)\s*$/.test(sn.slice(jn.length));
}

/* «None» نتیجه نیست، نبودنِ نتیجه است: Veeam تا پایانِ اجرا همین را
   می‌نویسد. */
const verdict = s => {
  const r = String((s && s.result) || '').trim();
  return r.toLowerCase() === 'none' ? '' : r;
};
const finished = s => !!(s && String(s.end || '').trim() && verdict(s));
const stamp = s => String((s && (s.end || s.start)) || '');

/* تمام‌شده همیشه بر نیمه‌کاره مقدم است؛ بینِ دو تمام‌شده، آن‌که دیرتر
   تمام شده. زمان‌ها «yyyy-MM-dd HH:mm» هستند، پس مقایسهٔ رشته‌ای همان
   مقایسهٔ زمانی است. */
function newer(a, b) {
  if (!a) return true;
  const fa = finished(a), fb = finished(b);
  if (fa !== fb) return fb;
  return stamp(b) > stamp(a);
}

export function bestSession(sessions, job) {
  let best = null;
  const jid = String((job && job.id) || '');
  if (jid) {
    for (const s of sessions)
      if (String(s.jobId || '') === jid && newer(best, s)) best = s;
    if (best) return best;
  }
  const jn = String((job && job.name) || '');
  for (const s of sessions) if (sessionOfJob(s, jn) && newer(best, s)) best = s;
  return best;
}

/* جاب‌ها با نتیجه‌ای که از اجراهایشان درمی‌آید. آن‌چه اسکریپت خودش
   حساب کرده بود دور ریخته می‌شود — نه از بی‌اعتمادی، بلکه چون آن
   نسخه روی ویندوزِ مشتری قفل است و این یکی با هر استقرار تازه می‌شود.
   اگر هیچ اجرایی پیدا نشد، هرچه اسکریپت گفته بود می‌ماند. */
export function withSessionResults(jobs, sessions) {
  if (!Array.isArray(jobs) || !Array.isArray(sessions) || !sessions.length) return jobs;
  return jobs.map(j => {
    const s = bestSession(sessions, j);
    if (!s) return j;
    /* پیامِ همان اجرا مقدم است — چون نتیجه هم از همان اجرا آمده. ولی
       اگر آن اجرا پیامی نداشت، پیامی که اسکریپت برای خودِ جاب فرستاده
       دور ریخته نمی‌شود: نداشتنِ پیام دلیلِ پاک کردنِ پیامِ موجود
       نیست. */
    const msg = String(s.message || '').trim() || String(j.message || '').trim();
    return Object.assign({}, j, {
      result: verdict(s) || j.result || '',
      state: String(s.state || j.state || ''),
      last: String(s.start || j.last || ''),
      /* پیامی که فقط خودِ نتیجه را تکرار می‌کند حرفی ندارد */
      message: (msg && msg.toLowerCase() !== verdict(s).toLowerCase()) ? msg : '',
      /* نتیجه از کدام اجرا آمده. وقتی کنسولِ Veeam چیزی می‌گوید و این
         ستون چیزِ دیگری، اولین پرسش همیشه همین است. */
      via: String(s.name || '')
    });
  });
}
