/* بدنهٔ فایلِ پشتیبان.

   پشتیبان به بله می‌رسید و به تلگرام نه: «fetch failed». همان فایل با
   curl از همان رله و همان توکن در دو ثانیه می‌رفت — پس رله و لینک
   سالم بودند و تفاوت در خودِ درخواستِ ما بود.

   بدنه حالا دستی ساخته می‌شود: یک Buffer با مرزِ مشخص و Content-Length،
   همان چیزی که curl می‌فرستد. این آزمون یک سرورِ قلابی بالا می‌آورد و
   می‌بیند آن‌طرف دقیقاً چه چیزی تحویل می‌گیرد — چون بدنه‌ای که خودمان
   می‌سازیم، اگر یک بایت در مرزش جابه‌جا باشد، فایلِ پشتیبان خراب
   می‌رسد و کسی تا روزِ بازیابی نمی‌فهمد. */
import { createServer } from 'node:http';
import { multipart } from '../src/multipart.js';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const seen = [];
const srv = createServer((req, res) => {
  const chunks = [];
  req.on('data', c => chunks.push(c));
  req.on('end', () => {
    seen.push({ headers: req.headers, body: Buffer.concat(chunks) });
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true, result: { message_id: seen.length } }));
  });
});
await new Promise(r => srv.listen(0, '127.0.0.1', r));
const url = 'http://127.0.0.1:' + srv.address().port + '/botX/sendDocument';

/* بخشِ فایل را از بدنهٔ رسیده در می‌آورد، همان‌طور که یک سرورِ واقعی
   می‌کند: با مرزی که در هدر آمده. */
function filePart(hit) {
  const bnd = (hit.headers['content-type'] || '').split('boundary=')[1];
  if (!bnd) return null;
  const b = hit.body;
  const at = b.indexOf(Buffer.from('name="document"'));
  if (at < 0) return null;
  const start = b.indexOf(Buffer.from('\r\n\r\n'), at) + 4;
  const end = b.lastIndexOf(Buffer.from('\r\n--' + bnd + '--'));
  return b.slice(start, end);
}

console.log('===== بدنه =====');
for (const mb of [0.001, 2, 6]) {
  const zip = Buffer.alloc(Math.round(mb * 1000000), 0);
  /* دادهٔ یکنواخت ایرادِ جابه‌جاییِ بایت را پنهان می‌کند، پس الگو
     می‌گذاریم: اگر یک بایت کم یا زیاد شود، مقایسه می‌فهمد. */
  for (let i = 0; i < zip.length; i++) zip[i] = (i * 31) & 0xff;

  const m = multipart({ chat_id: '97532067', caption: 'سلام <b>تست</b>', parse_mode: 'HTML' },
    { field: 'document', name: 'sltech-backup.zip', type: 'application/zip', data: zip });
  const r = await fetch(url, { method: 'POST', body: m.body, headers: m.headers });
  const d = await r.json();
  const hit = seen.pop();
  const got = filePart(hit);

  const label = Math.round(zip.length / 1000) + ' کیلوبایت';
  t(d.ok, label + ': سرور پذیرفت');
  t(hit.headers['content-length'] === String(m.body.length),
    label + ': طولِ معلوم فرستاده شد — نه بدنهٔ تکه‌تکه',
    hit.headers['content-length'] + ' · transfer-encoding: ' +
      (hit.headers['transfer-encoding'] || 'ندارد'));
  t(!hit.headers['transfer-encoding'], label + ': و chunked نیست');
  t(got && got.length === zip.length, label + ': فایل با همان اندازه رسید',
    got ? got.length + ' از ' + zip.length : 'بخشِ فایل پیدا نشد');
  t(got && got.equals(zip), label + ': و بایت‌به‌بایت همان است');
}

console.log('===== میدان‌های متنی =====');
{
  const m = multipart({ chat_id: '123', caption: 'خطِ اول', parse_mode: 'HTML', nothing: null },
    { field: 'document', name: 'b.zip', type: 'application/zip', data: Buffer.from('xy') });
  await fetch(url, { method: 'POST', body: m.body, headers: m.headers });
  const s = seen.pop().body.toString('utf8');
  t(/name="chat_id"[\s\S]*?\r\n\r\n123\r\n/.test(s), 'شناسهٔ گفتگو رفت');
  t(/name="caption"[\s\S]*?\r\n\r\nخطِ اول\r\n/.test(s), 'و توضیحِ فارسی سالم رفت');
  t(/name="parse_mode"/.test(s), 'و parse_mode');
  t(!/name="nothing"/.test(s), 'و میدانِ خالی اصلاً نرفت — null یعنی نبودن');
}

console.log('===== نامِ فایل =====');
{
  /* نامِ غیرلاتین در هدر دردسر است و بعضی سرورها پسش می‌زنند. نامِ
     زیپ‌های ما لاتین است، ولی محافظ باید باشد. */
  const m = multipart({ chat_id: '1' },
    { field: 'document', name: 'پشتیبانِ "من".zip', type: 'application/zip', data: Buffer.from('z') });
  const s = m.body.toString('latin1');
  const fn = (s.match(/filename="([^"]*)"/) || [])[1];
  t(fn && /^[\x20-\x7E]+$/.test(fn), 'نامِ غیرلاتین به ASCII تبدیل شد', fn);
  t(fn && fn.endsWith('.zip'), 'و پسوندش ماند', fn);
  const m2 = multipart({ chat_id: '1' },
    { field: 'document', name: 'a"b\r\nc.zip', type: 'application/zip', data: Buffer.from('z') });
  const fn2 = (m2.body.toString('latin1').match(/filename="([^"]*)"/) || [])[1];
  t(fn2 === 'ab_c.zip' || !/["\r\n]/.test(fn2),
    'و نامِ مخرب نمی‌تواند هدر را بشکند', JSON.stringify(fn2));
}

console.log('===== مرز تکراری نیست =====');
{
  const a = multipart({ x: '1' }, { field: 'd', name: 'a', type: 't', data: Buffer.from('1') });
  const bb = multipart({ x: '1' }, { field: 'd', name: 'a', type: 't', data: Buffer.from('1') });
  t(a.headers['Content-Type'] !== bb.headers['Content-Type'],
    'هر درخواست مرزِ خودش را دارد');
}

srv.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
