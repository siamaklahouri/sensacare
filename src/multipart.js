/* ==================== بدنهٔ multipart، دستی ====================

   چرا دستی و نه FormData؟

   پشتیبانِ تلگرام با «fetch failed» می‌افتاد در حالی که همان فایل با
   curl از همان رله و همان توکن در دو ثانیه می‌رفت. تفاوت در خودِ
   بدنه بود: fetch وقتی FormData می‌گیرد، بدنه را به‌صورت جریانِ
   تکه‌تکه (Transfer-Encoding: chunked) می‌فرستد و طولش را از پیش
   نمی‌گوید. curl بدنه را یک‌جا با Content-Length می‌فرستد.

   بعضی واسطه‌ها — و رلهٔ ما یکی‌شان است — با بدنهٔ تکه‌تکهٔ چندمگابایتی
   کنار نمی‌آیند و وسطِ کار ارتباط را می‌بندند. سمتِ ما این‌طور دیده
   می‌شود: «fetch failed» و هیچ توضیحِ دیگری.

   این‌جا بدنه را خودمان می‌سازیم: یک Buffer کامل، با مرزِ مشخص و
   طولِ معلوم. برای فایلِ چند مگابایتی که از قبل در حافظه است، هیچ
   چیزی از دست نمی‌رود — زیپ همین حالا هم یک Uint8Array در حافظه است.

   اگر روزی فایل‌ها آن‌قدر بزرگ شدند که یک‌جا در حافظه جا نشوند، آن
   وقت راهِ درست جریانِ واقعی است، نه برگشتن به FormData. */

const CRLF = '\r\n';

/* نامِ فایل در هدر: فقط ASCII. نامِ غیرلاتین را بعضی سرورها نمی‌پذیرند
   و بعضی به‌هم‌ریخته ثبت می‌کنند. نامِ زیپ‌های ما لاتین است، ولی این
   محافظ می‌ماند چون هزینه‌ای ندارد. */
const safeName = n => String(n || 'file')
  .replace(/[\r\n"\\]/g, '')
  .replace(/[^\x20-\x7E]/g, '_') || 'file';

/* fields: شیء از نام→مقدارِ متنی.
   file:   { field, name, type, data }  — data یک Uint8Array/Buffer.
   خروجی:  { body, headers } آمادهٔ fetch. */
export function multipart(fields, file) {
  const boundary = '----sltech' + Date.now().toString(36) +
    Math.random().toString(36).slice(2, 10);
  const head = [];

  for (const [k, v] of Object.entries(fields || {})) {
    if (v == null) continue;
    head.push(
      '--' + boundary + CRLF +
      'Content-Disposition: form-data; name="' + k + '"' + CRLF + CRLF +
      String(v) + CRLF
    );
  }

  const pre = Buffer.from(head.join('') +
    '--' + boundary + CRLF +
    'Content-Disposition: form-data; name="' + file.field + '"; ' +
      'filename="' + safeName(file.name) + '"' + CRLF +
    'Content-Type: ' + (file.type || 'application/octet-stream') + CRLF + CRLF,
    'utf8');
  const post = Buffer.from(CRLF + '--' + boundary + '--' + CRLF, 'utf8');
  const body = Buffer.concat([pre, Buffer.from(file.data), post]);

  return {
    body,
    headers: {
      'Content-Type': 'multipart/form-data; boundary=' + boundary,
      /* همین سطر تمامِ ماجراست: طولِ معلوم، نه بدنهٔ تکه‌تکه. */
      'Content-Length': String(body.length)
    }
  };
}
