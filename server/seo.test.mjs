/* دو چیز که هیچ‌کدام در صفحه دیده نمی‌شوند و هر دو بی‌صدا خراب می‌شوند:
   جوابِ HEAD، و دادهٔ ساختاریافته.

   HEAD: مسیرهای صفحه فقط GET را می‌گرفتند، پس `HEAD /` چهارصدوچهار
   می‌داد در حالی که `GET /` دویست بود — هر پایشِ آپ‌تایمی که با HEAD
   چک می‌کند سایت را «پایین» می‌دید.

   دادهٔ ساختاریافته: صفحهٔ اصلی و فهرستِ مقاله‌ها هیچ نداشتند. و یک
   تلهٔ ظریف هم هست — liftAssets هر <script> بی‌src را از صفحه بیرون
   می‌کشد و در یک فایلِ .js می‌گذارد. «application/ld+json» اسکریپت
   نیست، داده است؛ اگر بیرون کشیده شود از صفحه غیب می‌شود و گوگل
   چیزی نمی‌بیند. پس این‌جا سنجیده می‌شود که در خودِ HTML مانده باشد.

   و چون همین استثنا یک بار از آن طرف خراب شد — الگویش کلِ متنِ
   اسکریپت را می‌گشت نه فقط تگِ بازش، و چون در جاوااسکریپتِ کارتابل
   جایی «type="text"» نوشته شده بود هیچ‌چیز بیرون کشیده نشد و صفحه از
   ۶۰ کیلوبایت به ۷۴۱ پرید — وزنِ خودِ صفحه‌ها هم این‌جا سنجیده می‌شود.
   هیچ آزمونی آن را نمی‌دید. */
import { panelHtml } from './where.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* fetch اجازهٔ دست زدن به Host را نمی‌دهد؛ برای HEAD هم از خودِ نود */
function head(path, host = 'sltech.ir') {
  const u = new URL(BASE);
  return new Promise((res, rej) => {
    import('node:http').then(({ default: http }) => {
      const r = http.request({ host: u.hostname, port: u.port, path, method: 'HEAD',
        headers: { Host: host } }, r2 => {
        let n = 0;
        r2.on('data', c => { n += c.length; });
        r2.on('end', () => res({ code: r2.statusCode, bytes: n, h: r2.headers }));
      });
      r.on('error', rej);
      r.end();
    });
  });
}

/* ---------------- HEAD ---------------- */
console.log('— HEAD همان GET است —');
{
  const paths = ['/', '/maghale/', '/kar/hr/', '/sitemap.xml', '/robots.txt'];
  const wrong = [];
  for (const p of paths) {
    const h = await head(p);
    const g = await panelHtml(p);
    const gCode = g && g.length ? 200 : 0;
    if (h.code !== 200) wrong.push(p + ' → ' + h.code);
    if (h.bytes !== 0) wrong.push(p + ' بدنه دارد (' + h.bytes + ' بایت)');
    if (!gCode) wrong.push(p + ' با GET هم نیامد');
  }
  t(wrong.length === 0, 'صفحه‌های اصلی با HEAD هم ۲۰۰ می‌دهند و بدنه ندارند',
    wrong.length ? wrong.join(' · ') : paths.length + ' مسیر');

  const miss = await head('/aslan-nist-' + Date.now());
  t(miss.code === 404, 'و مسیرِ نبوده هنوز ۴۰۴ است، نه ۲۰۰', String(miss.code));

  /* نکتهٔ HEAD همین است: سربرگ‌ها باید همان‌هایی باشند که GET می‌دهد */
  const h = await head('/');
  t(/text\/html/.test(h.h['content-type'] || ''), 'سربرگِ نوع هم سرِ جایش است', h.h['content-type']);
  t(/script-src/.test(h.h['content-security-policy'] || ''), 'و CSP هم', 'هست');
}

/* ---------------- دادهٔ ساختاریافته ---------------- */
const lds = html => [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)]
  .map(m => { try { return JSON.parse(m[1].replace(/\\u003c/g, '<').replace(/\\u003e/g, '>')
    .replace(/\\u0026/g, '&')); } catch (e) { return { '@type': 'JSONخراب:' + e.message }; } });
const types = arr => arr.flatMap(o => o['@graph'] ? o['@graph'].map(n => n['@type']) : [o['@type']]);

console.log('— صفحهٔ اصلی —');
const home = await panelHtml('/');
{
  const j = lds(home);
  const ty = types(j);
  t(j.length > 0, 'دادهٔ ساختاریافته دارد', j.length + ' بلوک');
  for (const want of ['Organization', 'WebSite', 'WebApplication'])
    t(ty.includes(want), want + ' هست', ty.join(', '));
  const g = (j[0] || {})['@graph'] || [];
  const org = g.find(n => n['@type'] === 'Organization') || {};
  const app = g.find(n => n['@type'] === 'WebApplication') || {};
  t(/^https:\/\//.test(org.url || ''), 'نشانیِ سازمان مطلق است', org.url);
  t(!!org.logo && /icon-sl/.test(org.logo.url || ''), 'و نشانش هم');
  /* قیمت و امتیاز عمداً نیست: پلن‌ها از تنظیمات می‌آیند و هیچ عددِ
     واحدی نیست که بشود نوشت؛ دادهٔ قیمتی که با صفحه نخواند، تخلف است. */
  t(!app.offers && !app.aggregateRating, 'قیمت و امتیازِ ساختگی ندارد');
  t(Array.isArray(app.screenshot) && app.screenshot.length === 3, 'سه تصویرِ صفحه دارد',
    String((app.screenshot || []).length));
}

console.log('— در خودِ صفحه مانده، نه در فایلِ جدا —');
{
  /* همان تله: اگر liftAssets بیرونش بکشد، این شرط می‌افتد */
  t(/<script type="application\/ld\+json">/.test(home),
    'بلوکِ ld+json درونِ HTMLِ صفحهٔ اصلی است');
  const js = [...home.matchAll(/src="(\/_a\/[^"]+\.js)"/g)].map(m => m[1]);
  t(js.length > 0, 'صفحهٔ اصلی فایلِ جاوااسکریپتِ بیرونی دارد (یعنی lift کار کرده)', js.join(' '));
  let leaked = '';
  for (const u of js) {
    const r = await fetch(BASE + u, { headers: { Host: 'sltech.ir' } });
    const txt = await r.text();
    if (/"@context"|schema\.org/.test(txt)) leaked = u;
  }
  t(!leaked, 'و هیچ دادهٔ ساختاریافته‌ای داخلِ آن فایل‌ها نرفته', leaked || 'پاک');
}

/* ---------------- وزنِ صفحه ----------------
   سقف‌ها دست‌ودل‌بازند: کارِ این آزمون گرفتنِ چند کیلوبایتِ اضافه نیست،
   گرفتنِ لحظه‌ای است که بیرون‌کشیدن از کار بیفتد و همه‌چیز دوباره توی
   خودِ صفحه برگردد. */
console.log('— صفحه‌ها سبک مانده‌اند —');
{
  const want = [
    ['/siamak/', 'it', 120],
    ['/login', 'admin', 80],
    ['/', 'home', 80]
  ];
  for (const [path, kind, maxKb] of want) {
    const html = await panelHtml(path);
    const kb = Math.round(Buffer.byteLength(html, 'utf8') / 1024);
    const css = new RegExp('/_a/k-' + kind + '-[0-9a-f]+\\.css').test(html);
    const js = new RegExp('/_a/k-' + kind + '-[0-9a-f]+\\.js').test(html);
    t(kb <= maxKb, path + ' زیرِ ' + maxKb + ' کیلوبایت است', kb + ' کیلوبایت');
    t(css && js, path + ' هم CSS و هم JSش بیرون کشیده شده',
      (css ? 'css ✓ ' : 'css ✗ ') + (js ? 'js ✓' : 'js ✗'));
  }
}

/* ---------------- کارتِ هم‌رسانی ----------------
   این یکی نگهبانِ مرزِ دو سایت است، نه یک سنجهٔ سئو. «/og.png» کارتِ
   فروشگاه سنساست و هر ۲۸ صفحهٔ sltech به همان اشاره می‌کرد: هر لینکی
   که در تلگرام یا بله فرستاده می‌شد، پیش‌نمایشش آگهیِ محصولاتِ بهداشتیِ
   یک سایتِ دیگر را نشان می‌داد. هر دو سایت از یک پوشهٔ public سرو
   می‌شوند، پس نامِ یکسان یعنی فایلِ یکسان — و همین باعث می‌شود این
   اشتباه بی‌صدا برگردد. */
console.log('— کارتِ هم‌رسانی —');
{
  const paths = ['/', '/maghale/', '/kar/hr/'];
  const arts = (await panelHtml('/maghale/')).match(/\/maghale\/([a-z0-9-]+)\//);
  if (arts) paths.push('/maghale/' + arts[1] + '/');
  const shop = [], imgs = new Set();
  for (const u of paths) {
    const h = await panelHtml(u);
    if (/\/og\.png/.test(h)) shop.push(u);
    const m = h.match(/<meta property="og:image" content="([^"]+)"/);
    if (m) imgs.add(m[1].replace(/^https?:\/\/[^/]+/, ''));
  }
  t(shop.length === 0, 'هیچ صفحهٔ پنلی به کارتِ فروشگاه («/og.png») اشاره نمی‌کند',
    shop.length ? 'هنوز در ' + shop.join(' و ') : paths.length + ' صفحه پاک');
  t(imgs.size === 1 && [...imgs][0] === '/og-sl.2.jpg',
    'و همه به کارتِ خودِ SLTech اشاره می‌کنند', [...imgs].join(' '));

  const r = await fetch(BASE + '/og-sl.2.jpg', { headers: { Host: 'sltech.ir' } });
  t(r.status === 200, 'خودِ کارت روی سرور هست', String(r.status));
  t(/^image\//.test(r.headers.get('content-type') || ''), 'و نوعش تصویر است',
    r.headers.get('content-type'));
  const buf = Buffer.from(await r.arrayBuffer());
  /* ۱۲۰۰×۶۳۰ شرطِ خودِ تلگرام و واتساپ است؛ با ابعادِ دیگر کارت
     نمی‌شود و به یک مربعِ کوچک کنارِ متن تبدیل می‌شود. */
  let w = 0, hgt = 0, i = 2;
  while (i < buf.length - 9) {
    if (buf[i] !== 0xFF) { i++; continue; }
    const mk = buf[i + 1];
    if (mk >= 0xC0 && mk <= 0xCF && mk !== 0xC4 && mk !== 0xC8 && mk !== 0xCC) {
      hgt = buf.readUInt16BE(i + 5); w = buf.readUInt16BE(i + 7); break;
    }
    i += 2 + buf.readUInt16BE(i + 2);
  }
  t(w === 1200 && hgt === 630, 'ابعادش ۱۲۰۰×۶۳۰ است', w + '×' + hgt);
  t(buf.length < 300 * 1024, 'و سبک است', Math.round(buf.length / 1024) + ' کیلوبایت');
}

/* ---------------- فید ---------------- */
console.log('— فیدِ مقاله‌ها —');
{
  const r = await fetch(BASE + '/maghale/feed.xml', { headers: { Host: 'sltech.ir' } });
  t(r.status === 200, 'فید جواب می‌دهد', String(r.status));
  t(/rss\+xml/.test(r.headers.get('content-type') || ''), 'با نوعِ درست',
    r.headers.get('content-type'));
  const xml = await r.text();
  const items = (xml.match(/<item>/g) || []).length;
  const list = await panelHtml('/maghale/');
  const cards = (list.match(/class="card[^"]*" href="\/maghale\//g) || []).length;
  t(items === cards, 'همان‌قدر نوشته دارد که فهرست', items + ' در برابر ' + cards);
  t(/<atom:link[^>]+rel="self"/.test(xml), 'و نشانیِ خودش را معرفی می‌کند');
  t(/<link rel="alternate" type="application\/rss\+xml"/.test(list),
    'از خودِ صفحه هم پیدا می‌شود');
}

/* ---------------- پیوندهای داخلی ----------------
   بیست‌ودو صفحهٔ شغلی و چند مقاله بودند که هیچ‌کدام دیگری را
   نمی‌شناخت — صفر پیوند در هر دو جهت. */
console.log('— پیوندِ مقاله و شغل —');
{
  const slug = ((await panelHtml('/maghale/')).match(/\/maghale\/([a-z0-9-]+)\//) || [])[1];
  if (!slug) t(false, 'مقاله‌ای برای آزمودن نبود');
  else {
    const art = await panelHtml('/maghale/' + slug + '/');
    const toJobs = new Set([...art.matchAll(/href="(\/kar\/[a-z]+\/)"/g)].map(m => m[1]));
    t(toJobs.size >= 5, 'از مقاله راهی به صفحه‌های شغلی هست', toJobs.size + ' شغل');
  }
  const job = await panelHtml('/kar/hr/');
  const toArts = new Set([...job.matchAll(/href="(\/maghale\/[a-z0-9-]+\/)"/g)].map(m => m[1]));
  t(toArts.size >= 1, 'و از صفحهٔ شغلی هم راهی به مقاله‌ها', toArts.size + ' مقاله');
}

console.log('— فهرستِ مقاله‌ها —');
{
  const html = await panelHtml('/maghale/');
  const j = lds(html);
  const ty = types(j);
  t(ty.includes('Blog'), 'Blog هست', ty.join(', '));
  t(ty.includes('BreadcrumbList'), 'خرده‌نان هم');
  const list = j.find(o => o['@type'] === 'ItemList');
  const cards = (html.match(/class="card[^"]*" href="\/maghale\//g) || []).length;
  t(!!list && list.itemListElement.length === cards,
    'ItemList دقیقاً همان‌قدر مورد دارد که در صفحه کارت هست',
    (list ? list.itemListElement.length : '—') + ' در برابر ' + cards);
  t(/<meta property="og:type" content="website">/.test(html),
    'og:type این صفحه «website» است، نه «article»');
}

console.log('— یک مقاله —');
{
  const slug = (home.match(/\/maghale\/([a-z0-9-]+)\//) || [])[1] ||
    ((await panelHtml('/maghale/')).match(/\/maghale\/([a-z0-9-]+)\//) || [])[1];
  if (!slug) { t(false, 'مقاله‌ای برای آزمودن پیدا نشد'); }
  else {
    const html = await panelHtml('/maghale/' + slug + '/');
    const j = lds(html);
    t(types(j).includes('Article'), 'Article هست');
    const bc = j.find(o => o['@type'] === 'BreadcrumbList');
    t(!!bc && bc.itemListElement.length === 3, 'خرده‌نانش سه پله است: خانه ← مقاله‌ها ← خودش',
      bc ? bc.itemListElement.map(x => x.name).join(' / ') : '—');
    t(!!bc && bc.itemListElement.every(x => /^https?:\/\//.test(x.item || '')),
      'و هر پله نشانیِ واقعی دارد');
  }
}

console.log('— یک صفحهٔ شغلی —');
{
  const html = await panelHtml('/kar/hr/');
  const ty = types(lds(html));
  for (const want of ['HowTo', 'FAQPage', 'BreadcrumbList'])
    t(ty.includes(want), want + ' هست', ty.join(', '));
}

console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
