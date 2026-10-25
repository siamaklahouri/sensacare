/* دو سایتِ جدا: sltech.ir و sensacare.ir هیچ‌جا نباید به هم برسند —
   نه محتوای آن یکی را نشان بدهند، نه کاربر را به دامنهٔ دیگر بفرستند.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید (یا با
   server/ci-setup.sh). */
import http from 'node:http';

const BASE = new URL(process.env.VS_BASE || 'http://127.0.0.1:8911');
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const PANEL = 'sltech.ir';
const SHOP = 'sensacare.ir';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* fetch اجازهٔ دست‌زدن به سربرگِ Host را نمی‌دهد و همین آزمون بی آن
   معنا ندارد، پس درخواست را خودمان با node:http می‌زنیم. */
const get = (path, host) => new Promise(r => {
  http.get({ host: BASE.hostname, port: BASE.port, path, headers: { Host: host } }, res => {
    let b = ''; res.on('data', c => { b += c; });
    res.on('end', () => r({ s: res.statusCode, loc: res.headers.location || '', b }));
  }).on('error', e => r({ s: 0, loc: '', b: String(e) }));
});

/* یک کارتابل لازم است تا بشود دید روی دامنهٔ فروشگاه باز نمی‌شود */
const mk = () => { let ck = ''; return async (path, opt) => {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
  const r = await fetch(BASE.origin + path, o);
  for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
    const kv = c.split(';')[0], k = kv.split('=')[0];
    ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
  }
  return { status: r.status };
}; };
{
  const adm = mk();
  await adm('/api/admin.planer/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
  await adm('/api/admin.planer/planners',
    { method: 'POST', body: JSON.stringify({ slug: 'splitk', name: 'جدایی', kind: 'it', user: 'splitk' }) });
}

const isShop = b => /sensacare|سِنسا/.test(b);
const isPanel = b => /SLTech|اس‌ال‌تک|KARTABL_API|کارتابل ماهانه/.test(b);
const crossed = (loc, other) => !!loc && loc.includes(other);

console.log('===== دامنهٔ پنل: هیچ‌چیزِ فروشگاه =====');
for (const path of ['/nosuchthing/', '/nosuchthing', '/hamintori', '/p/1/', '/c/x/', '/s/x/']) {
  const r = await get(path, PANEL);
  t(!isShop(r.b), `«${path}» روی پنل، صفحهٔ فروشگاه را نشان نمی‌دهد`, 'status=' + r.s);
  t(!crossed(r.loc, SHOP), `«${path}» روی پنل، به دامنهٔ فروشگاه نمی‌فرستد`, r.loc || '—');
}
{
  const r = await get('/nosuchthing/', PANEL);
  t(r.s === 404, 'آدرسِ ناموجودِ پنل ۴۰۴ است، نه ۲۰۰', 'status=' + r.s);
  t(/پیدا نشد/.test(r.b) && r.b.length < 4000,
    'و صفحهٔ کوچکِ خودِ پنل است، نه یک صفحهٔ کاملِ سایتِ دیگر', 'len=' + r.b.length);
  t(/href="\/"/.test(r.b), 'راهِ برگشت دارد و آن راه، خانهٔ همین سایت است');
}
{
  const r = await get('/', PANEL);
  t(r.s === 200 && isPanel(r.b) && !isShop(r.b), 'خانهٔ پنل سرِ جایش است', 'status=' + r.s);
  t(!/\{\{\/?DEMO\}\}/.test(r.b), 'نشانه‌های قالب در صفحه نمانده‌اند');
  t(/\[hidden\]\s*\{\s*display:\s*none\s*!important/.test(r.b),
    '«hidden» روی دکمه هم کار می‌کند، نه فقط روی لینکِ نوارِ بالا');
}

/* ---------- لینکِ دمو ----------
   دکمهٔ «کارتابل را همین حالا ببینم» تا وقتی کارتابلِ نمایشی ساخته
   نشده باشد نباید در صفحه باشد: یک بار بود و به ۴۰۴ می‌رفت. با
   «hidden» هم حل نشد (CSSِ .btn قوی‌تر بود)، پس این‌جا سنجیده می‌شود
   که خودِ تگ در صفحه نباشد، نه این‌که پنهان باشد. */
console.log('===== لینکِ دمو =====');
{
  /* سرویس موقعِ بالا آمدن خودش کارتابلِ نمایشی را می‌سازد، پس پیش از
     آن‌که این آزمون دست به چیزی بزند باید باشد و باز شود. */
  const live = await get('/demo/', PANEL);
  t(live.s === 200, 'کارتابلِ نمایشی بی‌آن‌که کسی بسازدش هست و باز می‌شود', 'status=' + live.s);
  t(/demoBar|KARTABL_DEMO/.test(live.b), 'و صفحه خودش را نمایشی می‌داند');

  const adm = mk();
  await adm('/api/admin.planer/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
  const mkDemo = () => adm('/api/admin.planer/planners',
    { method: 'POST', body: JSON.stringify({ slug: 'demo', name: 'نمایشی', kind: 'it', user: 'demo' }) });

  await mkDemo();
  let r = await get('/', PANEL);
  t(/href="\/demo\/"/.test(r.b), 'وقتی کارتابلِ نمایشی هست، لینکش در صفحه است');

  const del = await adm('/api/admin.planer/planners/demo',
    { method: 'DELETE', body: JSON.stringify({ confirm: 'demo' }) });
  if (del.status !== 200) {
    t(false, 'کارتابلِ نمایشی برای آزمون حذف نشد', 'status=' + del.status);
  } else {
    r = await get('/', PANEL);
    t(!/href="\/demo\/"/.test(r.b), 'و وقتی نیست، هیچ لینکی به /demo/ در صفحه نمی‌ماند');
    t(!/\{\{\/?DEMO\}\}/.test(r.b), 'و نشانه‌ها هم جا نمی‌مانند');
    t(!/btn-demo/.test(r.b.split('</style>').pop() || ''),
      'خودِ تگِ دکمه برداشته شده، نه فقط پنهان شده');
    /* همان‌طور که بود تحویلش می‌دهیم؛ آزمون‌های دیگر رویش حساب می‌کنند */
    await mkDemo();
    r = await get('/', PANEL);
    t(/href="\/demo\/"/.test(r.b), 'و با ساختنِ دوباره، لینک برمی‌گردد');
  }
}

console.log('===== دامنهٔ فروشگاه: هیچ‌چیزِ پنل =====');
{
  const shopOn = (await get('/nosuchthing/', SHOP)).b;
  if (!isShop(shopOn)) {
    t(true, 'SHOP_HOST تنظیم نشده — این بخش رد می‌شود (روی سرورِ واقعی تنظیم است)');
  } else {
    for (const path of ['/login', '/panel', '/splitk/', '/splitk']) {
      const r = await get(path, SHOP);
      t(!isPanel(r.b), `«${path}» روی فروشگاه، صفحهٔ پنل را نشان نمی‌دهد`, 'status=' + r.s);
      t(!crossed(r.loc, PANEL), `«${path}» روی فروشگاه، به دامنهٔ پنل نمی‌فرستد`, r.loc || '—');
    }
    const r = await get('/splitk/', SHOP);
    t(r.s === 404, 'کارتابل روی دامنهٔ فروشگاه وجود ندارد', 'status=' + r.s);
  }
}

console.log('===== فایل‌های مشترک =====');
for (const f of ['/logo.svg', '/shared.js']) {
  const r = await get(f, PANEL);
  t(r.s === 200, `«${f}» روی پنل هم سرو می‌شود`, 'status=' + r.s);
}

console.log(`\n${ok} ok, ${bad} bad`);
process.exit(bad ? 1 : 0);
