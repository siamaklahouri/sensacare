/* نشانه‌های «برنامه بودن»: مانیفست، رنگِ نوار، و /favicon.ico

   این‌ها هر کدام یک خطند و همین باعث می‌شود کسی متوجهِ نبودنشان نشود.
   مانیفستِ سایت از اول «start_url: /login» داشت — یعنی برای پنل ساخته
   شده بود — ولی هیچ صفحه‌ای لینکش نمی‌کرد و پنل روی گوشی نصب نمی‌شد.
   هر دو کارتابل این خط را داشتند؛ فقط پنل جا مانده بود. */
import http from 'node:http';
import { readFileSync } from 'node:fs';

const PORT = new URL(process.env.VS_BASE || 'http://127.0.0.1:8911').port || '80';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const get = (path, host = 'sltech.ir') => new Promise(r => {
  http.get({ host: '127.0.0.1', port: PORT, path, headers: { Host: host } }, res => {
    let b = ''; res.on('data', c => b += c);
    res.on('end', () => r({ code: res.statusCode, h: res.headers, body: b }));
  }).on('error', e => r({ code: 0, err: e.message, body: '' }));
});

console.log('===== /favicon.ico =====');
{
  const r = await get('/favicon.ico');
  t(r.code === 301 || r.code === 200, 'دیگر ۴۰۴ نیست', 'کد ' + r.code);
  if (r.code === 301) {
    t(/^\/[\w.-]+\.(png|ico|svg)$/.test(r.h.location || ''),
      'و به یک نشانهٔ واقعی می‌رود', r.h.location);
    /* نشانی به فایلی که نیست، از ۴۰۴ هم بدتر است */
    const f = await get(r.h.location);
    t(f.code === 200, 'و آن فایل واقعاً هست', 'کد ' + f.code);
  }
  /* فروشگاه نشانهٔ فایلی ندارد؛ آن‌جا نباید تغییرِ مسیرِ شکسته بدهیم */
  const shop = await get('/favicon.ico', 'sensacare.ir');
  t(shop.code !== 301 || /^\/[\w.-]+\.(png|ico|svg)$/.test(shop.h.location || ''),
    'و فروشگاه به جای شکسته فرستاده نمی‌شود', 'کد ' + shop.code);
}

console.log('===== پنلِ مدیر =====');
{
  const h = (await get('/login')).body;
  t(/<link rel="manifest" href="\/app\.webmanifest">/.test(h),
    'مانیفست را لینک می‌کند — پس نصب می‌شود');
  t(/name="theme-color"[^>]*media="\(prefers-color-scheme: light\)"/.test(h),
    'رنگِ نوار برای روز دارد');
  t(/name="theme-color"[^>]*media="\(prefers-color-scheme: dark\)"/.test(h),
    'و برای شب هم — یک رنگِ ثابت در تمِ شب نوارِ روشن می‌گذاشت');
}

console.log('===== صفحهٔ اصلی =====');
{
  const h = (await get('/')).body;
  t(/name="theme-color"/.test(h), 'رنگِ نوار دارد');
  t((h.match(/name="theme-color"/g) || []).length === 2, 'برای هر دو تم', 
    (h.match(/name="theme-color"/g) || []).length + ' تا');
}

console.log('===== مانیفستِ سایت =====');
{
  const r = await get('/app.webmanifest');
  t(r.code === 200, 'سرو می‌شود', 'کد ' + r.code);
  const j = JSON.parse(r.body);
  t(j.start_url === '/login', 'و هدفش پنل است', j.start_url);
  t(Array.isArray(j.shortcuts) && j.shortcuts.length >= 3,
    'میان‌بُر دارد — فشارِ طولانی روی نشانهٔ برنامه',
    (j.shortcuts || []).length + ' تا');
  for (const s of (j.shortcuts || [])) {
    t(!!s.name && /^\//.test(s.url || ''), 'میان‌بُر «' + (s.name || '؟') + '» نام و نشانی دارد', s.url);
    t(Array.isArray(s.icons) && s.icons.length > 0, '  و نشانه دارد');
  }
  /* نشانه‌های مانیفست باید واقعاً سرو شوند */
  for (const ic of (j.icons || [])) {
    const f = await get(ic.src);
    t(f.code === 200, 'نشانهٔ ' + ic.sizes + (ic.purpose ? '/' + ic.purpose : '') + ' هست', 'کد ' + f.code);
  }
}

console.log('===== کارتابل‌ها دست‌نخورده ماندند =====');
for (const f of ['it.tpl', 'fin.tpl']) {
  const src = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
  t(/rel="manifest"/.test(src), f + ': هنوز مانیفست دارد');
  t(/name="theme-color"/.test(src), f + ': هنوز رنگِ نوار دارد');
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
