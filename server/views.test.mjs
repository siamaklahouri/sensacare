/* بخش‌های هر کارتابل: بسته شدنشان باید عمدی باشد، و بستن نباید
   داده‌ای ببرد.

   این آزمون از یک اتفاقِ واقعی درآمده: «سرویس MVPN»ِ کارتابل سیامک
   یک روز صبح نبود. چیزی پاک نشده بود — فرمِ پنل بلوکِ تیک‌ها را شرطی
   می‌سازد و وقتی رندر نشده بود، «صفرتا تیک» را به‌عنوان «همه را ببند»
   می‌فرستاد. */
const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const SLUG = 'siamak';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

let ck = '';
const api = async (path, opt) => {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
  const r = await fetch(BASE + path, o);
  for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
    const kv = c.split(';')[0], k = kv.split('=')[0];
    ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
  }
  let d = {}; try { d = await r.json(); } catch (e) { }
  return { status: r.status, d };
};
const one = async () => (await api('/api/admin.planer/planners')).d.items
  .find(x => x.slug === SLUG);

await api('/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });

const p0 = await one();
t(!!p0, 'کارتابل پیدا شد', p0 && p0.kind);
const keep = { name: p0.name, user: p0.user, job: p0.job, views: p0.views.slice(), off: p0.off.slice() };
t(p0.views.includes('mvpn'), 'و «سرویس MVPN» الان باز است', p0.views.join(','));

const put = body => api('/api/admin.planer/planners/' + SLUG,
  { method: 'PUT', body: JSON.stringify(Object.assign({ name: keep.name, user: keep.user }, body)) });

console.log('\n===== فهرستِ خالی =====');
const empty = await put({ views: [] });
t(empty.status === 400 && /دست‌کم یک بخش/.test(empty.d.error || ''),
  'فهرستِ خالی رد می‌شود — یک ذخیرهٔ ساده نباید همهٔ بخش‌ها را ببندد',
  empty.d.error || String(empty.status));
t((await one()).views.includes('mvpn'), 'و چیزی هم عوض نشده');

console.log('\n===== نفرستادنِ فهرست =====');
/* فرم وقتی بلوکِ تیک‌ها را نساخته، اصلاً این کلید را نمی‌فرستد. */
const quiet = await put({ name: keep.name });
t(quiet.status === 200, 'ذخیره بدونِ فهرستِ بخش‌ها می‌پذیرد', String(quiet.status));
const after = await one();
t(after.views.join(',') === keep.views.join(','),
  'و فهرست دست‌نخورده می‌ماند — «نفرستادم» یعنی «کاری نداشته باش»',
  after.views.join(','));

console.log('\n===== بستنِ عمدی، و دادهٔ پشتش =====');
const dataOf = async () => {
  const r = await api('/api/admin.planer/planners/' + SLUG + '/peek');
  return r.status === 404 ? null : r.d;
};
const shut = keep.views.filter(v => v !== 'mvpn');
const r1 = await put({ views: shut });
t(r1.status === 200 && !(await one()).views.includes('mvpn'),
  'ادمین می‌تواند عمداً ببنددش — این همان کاری است که فرم می‌کرد');
const r2 = await put({ views: keep.views });
const back = await one();
t(r2.status === 200 && back.views.includes('mvpn'),
  'و باز کردنش همان یک کلیک است', back.views.join(','));
t(back.views.join(',') === keep.views.join(','), 'فهرست دقیقاً همان شد که بود');

console.log('\n===== قفلِ دوم =====');
/* دو قفلِ جدا هستند و هر کدام به‌تنهایی بخش را پنهان می‌کند: نبودن در
   فهرستِ «views»، و بودن در فهرستِ «off» به شکلِ «view:<نام>».
   دفعهٔ پیش فقط اولی را باز کردم و بخش همچنان پیدا نشد. */
const page = async () => (await fetch(BASE + '/siamak/', { headers: { Host: 'sltech.ir' } })).text();
const offList = h => {
  const m = h.match(/KARTABL_OFF = (\[[^\]]*\])/);
  try { return m ? JSON.parse(m[1]) : null; } catch (e) { return null; }
};
t(!(offList(await page()) || []).includes('view:mvpn'), 'الان بسته نیست');

/* یک بخشِ کارتابل فقط از راهِ فهرستِ «views» بسته می‌شود. فهرستِ
   «بسته‌ها» مالِ قابلیت‌های عمومی است (پشتیبان، هوش مصنوعی، …) و
   مسیر، «view:*» را داخلش نمی‌پذیرد — پس دو راهِ موازی برای یک کار
   وجود ندارد. */
const r3 = await put({ off: keep.off.concat(['view:mvpn']) });
t(r3.status === 400 && /ناشناخته/.test(r3.d.error || ''),
  'بستنِ یک بخش از راهِ فهرستِ «بسته‌ها» پذیرفته نمی‌شود — یک کار، یک راه',
  r3.d.error || String(r3.status));
t(!(offList(await page()) || []).includes('view:mvpn'),
  'و صفحه هم دست‌نخورده ماند');

/* ولی صفحه، «view:*»ی را که در دادهٔ قدیمی مانده باشد محترم می‌شمارد.
   برای همین server/views.sh هر دو جا را پاک می‌کند، نه فقط فهرستِ
   بخش‌ها — همان چیزی که بارِ اول از قلم افتاد و بخش باز نشد. */
const r4 = await put({ views: keep.views.filter(v => v !== 'mvpn') });
t(r4.status === 200 && (offList(await page()) || []).includes('view:mvpn'),
  'بستن از راهِ درست، در خودِ صفحه هم دیده می‌شود',
  JSON.stringify(offList(await page())));
await put({ views: keep.views });
t(!(offList(await page()) || []).includes('view:mvpn'), 'و باز کردنش همان‌جا برمی‌گردد');

console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
