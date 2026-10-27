/* کارتابل به شکلِ برنامهٔ اندروید: مانیفست، سرویس‌ورکر، و نوارِ
   دکمه‌های پایینی که فقط در حالتِ نصب‌شده می‌آید.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';
import http from 'node:http';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const WHO = [
  { slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak', name: 'کارتابلِ فنی' },
  { slug: 'sina', page: '/sina/', api: 'sina', pass: 'sinasinasina', name: 'کارتابلِ مالی' }
];

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const mk = () => { let ck = ''; return async (path, opt) => {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
  const r = await fetch(BASE + path, o);
  for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
    const kv = c.split(';')[0], k = kv.split('=')[0];
    ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
  }
  try { return await r.json(); } catch (e) { return {}; }
}; };
const adm = mk();
await adm('/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
for (const w of WHO)
  await adm('/api/admin.planer/planners/' + w.slug + '/password',
    { method: 'POST', body: JSON.stringify({ password: w.pass }) });

/* ---------- مانیفست و فایل‌هایش ---------- */
console.log('===== مانیفست =====');
for (const w of WHO) {
  const r = await fetch(BASE + w.page + 'app.webmanifest');
  const ct = r.headers.get('content-type') || '';
  let m = {};
  try { m = await r.json(); } catch (e) { }
  t(r.status === 200, w.slug + ': مانیفست سرو می‌شود', 'status=' + r.status);
  t(/manifest\+json/.test(ct), 'و نوعش application/manifest+json است', ct);
  t(m.name === 'SLTech' && m.short_name === 'SLTech',
    'نامِ برنامه SLTech است — همان که خواسته شد', m.name + ' / ' + m.short_name);
  t(m.start_url === w.page && m.scope === w.page,
    'و با همین کارتابل باز می‌شود، نه ریشهٔ سایت', m.start_url + ' | ' + m.scope);
  t(m.display === 'standalone', 'بی‌نوارِ آدرس باز می‌شود', m.display);
  t(m.dir === 'rtl' && m.lang === 'fa', 'راست‌به‌چپ و فارسی');
  const sizes = (m.icons || []).map(i => i.sizes).join(' ');
  t((m.icons || []).length >= 3 && /192x192/.test(sizes) && /512x512/.test(sizes),
    'سه نشانه دارد: ۱۹۲ و ۵۱۲ و maskable', sizes);
  t((m.icons || []).some(i => i.purpose === 'maskable'),
    'و یکی‌شان maskable است — گوشی لبهٔ لوگو را نمی‌بُرد');
  for (const ic of (m.icons || [])) {
    const ir = await fetch(BASE + ic.src);
    t(ir.ok && /image\/png/.test(ir.headers.get('content-type') || ''),
      '  فایلِ نشانه هست: ' + ic.src, 'status=' + ir.status);
  }
  t((m.shortcuts || []).every(s => String(s.url).indexOf(w.page) === 0),
    'میان‌بُرها داخلِ همین کارتابل‌اند', (m.shortcuts || []).map(s => s.url).join(' , '));
}

const sw = await fetch(BASE + '/sw.js');
t(sw.ok && /javascript/.test(sw.headers.get('content-type') || ''),
  'سرویس‌ورکر سرو می‌شود', 'status=' + sw.status);
const swText = await sw.text();
t(!/\/api\//.test(swText.split('\n').filter(l => /cache|put\(/i.test(l)).join('\n')) &&
  /indexOf\("\/api\/"\) === 0\) return/.test(swText),
  'و هیچ درخواستِ /api/ را ذخیره نمی‌کند');
t(/notificationclick/.test(swText) && /openWindow/.test(swText),
  'و زدنِ روی اعلان، کارتابل را جلو می‌آورد');

/* ---------- فایلِ نصبِ اندروید و تأییدِ دامنه ----------
   APK یک TWA است: همان کارتابل، بی‌نوارِ آدرس. اندروید فقط وقتی نوارِ
   آدرس را برمی‌دارد که assetlinks روی دامنه باشد و اثرِ انگشتِ داخلش
   با کلیدی که APK با آن امضا شده یکی باشد. */
console.log('===== فایلِ نصب =====');
{
  const al = await fetch(BASE + '/.well-known/assetlinks.json');
  const ct = al.headers.get('content-type') || '';
  let j = [];
  try { j = await al.json(); } catch (e) { }
  t(al.status === 200 && /application\/json/.test(ct),
    'assetlinks.json روی دامنه سرو می‌شود', al.status + ' ' + ct);
  const tgt = (j[0] || {}).target || {};
  t(tgt.package_name === 'ir.sltech.kartabl',
    'و نامِ بستهٔ برنامه را می‌گوید', tgt.package_name);
  t((j[0] || {}).relation && j[0].relation.indexOf('delegate_permission/common.handle_all_urls') >= 0,
    'با همان نسبتی که اندروید می‌خواهد');
  /* فهرست است نه یک عدد، و عمداً: کلیدِ امضا که عوض می‌شود، اثرِ
     انگشتِ تازه کنارِ قدیمی می‌نشیند نه به‌جایش — وگرنه تأییدِ
     برنامه برای هرکسی که نسخهٔ قبلی را نصب دارد می‌شکند. پس این‌جا
     «همهٔ» اعضا سنجیده می‌شوند، نه فقط اولی. */
  const fps = tgt.sha256_cert_fingerprints || [];
  const shape = /^([0-9A-F]{2}:){31}[0-9A-F]{2}$/;
  t(fps.length >= 1, 'دستِ‌کم یک اثرِ انگشت دارد', fps.length + ' تا');
  const malformed = fps.filter(f => !shape.test(f));
  t(malformed.length === 0, 'و هرکدام کامل و با رقمِ بزرگ است',
    malformed.length ? malformed.map(f => String(f).slice(0, 20)).join(' · ')
                     : fps.map(f => f.slice(0, 17) + '…').join(' · '));
  t(new Set(fps).size === fps.length, 'و هیچ‌کدام تکراری نیست');

  const apk = await fetch(BASE + '/sltech.apk');
  const buf = apk.ok ? Buffer.from(await apk.arrayBuffer()) : Buffer.alloc(0);
  t(apk.status === 200, 'فایلِ APK از همین دامنه دانلود می‌شود', 'status=' + apk.status);
  t(/vnd\.android\.package-archive/.test(apk.headers.get('content-type') || ''),
    'و نوعش را درست می‌گوید — وگرنه بعضی گوشی‌ها بازش می‌کنند به‌جای نصب',
    apk.headers.get('content-type'));
  t(buf.length > 1000000 && buf[0] === 0x50 && buf[1] === 0x4B,
    'و یک فایلِ سالمِ اندروید است', (buf.length / 1048576).toFixed(1) + 'MB');
}

/* ---------- دکمهٔ دانلود روی صفحهٔ اصلی ----------
   صفحهٔ اصلیِ sltech.ir فقط روی همان دامنه سرو می‌شود، و fetchِ نود
   سرآیندِ Host را نادیده می‌گیرد؛ پس این یکی با http خام می‌رود. */
const panelGet = path => new Promise((ok2, bad2) => {
  const u = new URL(BASE + path);
  http.get({ hostname: u.hostname, port: u.port, path: u.pathname,
             headers: { Host: 'sltech.ir' } }, r => {
    let d = ''; r.setEncoding('utf8');
    r.on('data', c => { d += c; });
    r.on('end', () => ok2({ status: r.statusCode, body: d }));
  }).on('error', bad2);
});
{
  const home = await panelGet('/');
  t(home.status === 200 && /کارتابل ماهانه SLTech/.test(home.body),
    'صفحهٔ اصلیِ دامنهٔ پنل باز می‌شود', 'status=' + home.status);
  t(/href="\/sltech\.apk"\s+download/.test(home.body),
    'و دکمهٔ دانلودِ برنامهٔ اندروید رویش هست — با download، وگرنه مرورگر بازش می‌کند');
  t((home.body.match(/\/sltech\.apk/g) || []).length >= 2,
    'در سرصفحه و در پرسش‌های پرتکرار، هر دو',
    (home.body.match(/\/sltech\.apk/g) || []).length + ' جا');
}

/* sltech.ir به همین سرورِ محلی نگاشته می‌شود تا صفحهٔ اصلیِ دامنهٔ
   پنل را هم بشود در مرورگر باز کرد؛ آدرسِ ۱۲۷.۰.۰.۱ خودش دستِ‌نخورده
   می‌ماند و بقیهٔ آزمون‌ها با همان کار می‌کنند. */
const b = await launch({ args: ['--host-resolver-rules=MAP sltech.ir 127.0.0.1'] });
const errs = [];

/* ---------- بخشِ «روی گوشی» در صفحهٔ اصلی ---------- */
{
  const port = new URL(BASE).port;
  const ctx = await b.newContext({ viewport: { width: 412, height: 880 }, isMobile: true, hasTouch: true });
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 140)));
  await p.goto('http://sltech.ir:' + port + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1200);
  const sec = await p.evaluate(() => {
    const s = document.getElementById('app');
    if (!s) return null;
    const txt = s.textContent.replace(/\s+/g, ' ');
    return {
      cards: s.querySelectorAll('.card').length,
      apk: !!s.querySelector('a[href$=".apk"][download]'),
      ios: /Add to Home Screen/.test(txt) && /Safari/.test(txt),
      chrome: /Install app/.test(txt),
      steps: s.querySelectorAll('.howto li').length,
      nav: !!document.querySelector('.topnav a[href="#app"]'),
      /* نوارِ بالا روی صفحهٔ باریک دو ردیف است؛ پرشِ لنگر باید از
         زیرش رد شود، وگرنه عنوانِ بخش پنهان می‌ماند. */
      bar: Math.round(document.querySelector('.top').getBoundingClientRect().height),
      sm: parseFloat(getComputedStyle(s).scrollMarginTop) || 0
    };
  });
  t(!!sec && sec.cards === 3, 'صفحهٔ اصلی بخشِ «روی گوشی» دارد، با سه راه',
    sec && sec.cards);
  t(sec && sec.apk, 'راهِ اول: فایلِ نصبِ اندروید');
  t(sec && sec.chrome, 'راهِ دوم: افزودن از خودِ کروم');
  t(sec && sec.ios, 'راهِ سوم: آیفون و سافاری — بی‌دانلود');
  t(sec && sec.steps >= 10, 'و هر کدام گام‌به‌گام نوشته شده', sec && sec.steps + ' گام');
  t(sec && sec.nav, 'از منوی بالای صفحه هم به آن می‌شود رسید');
  t(sec && sec.sm >= sec.bar, 'پرشِ لنگر از زیرِ نوارِ بالا رد می‌شود',
    sec && ('نوار ' + sec.bar + ' / حاشیه ' + sec.sm));
  t(errs.length === 0, 'و صفحهٔ اصلی خطای جاوااسکریپتی ندارد', errs.join(' | ') || 'نداشت');
  await ctx.close();
}

for (const w of WHO) {
  console.log('===== ' + w.name + ' =====');
  const ctx = await b.newContext({ viewport: { width: 412, height: 880 }, isMobile: true, hasTouch: true });
  const p = await ctx.newPage();
  p.on('pageerror', e => errs.push(w.slug + ': ' + String(e).slice(0, 160)));
  p.on('dialog', d => d.accept());
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: w.api, pass: w.pass });

  /* ---------- حالتِ مرورگر ---------- */
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2500);
  const head = await p.evaluate(() => ({
    man: (document.querySelector('link[rel="manifest"]') || {}).getAttribute
      ? document.querySelector('link[rel="manifest"]').getAttribute('href') : '',
    apple: (document.querySelector('link[rel="apple-touch-icon"]') || {}).getAttribute
      ? document.querySelector('link[rel="apple-touch-icon"]').getAttribute('href') : '',
    tint: (document.querySelector('meta[name="theme-color"]') || {}).content || '',
    app: document.documentElement.getAttribute('data-app')
  }));
  t(head.man === 'app.webmanifest', 'صفحه مانیفستِ خودش را معرفی می‌کند', head.man);
  t(/app-icon-apple/.test(head.apple), 'نشانهٔ آیفون هم نشانیِ درست دارد', head.apple);
  t(/^rgb/.test(head.tint), 'رنگِ نوارِ وضعیت از خودِ کاغذِ کارتابل خوانده شده', head.tint);
  t(head.app === null, 'در مرورگر، حالتِ برنامه روشن نیست');
  t(await p.evaluate(() => !document.getElementById('appBar')),
    'و نوارِ پایینی نمی‌آید — مرورگر همان منوی همیشگی را دارد');

  const reg = await p.evaluate(async () => {
    if (!('serviceWorker' in navigator)) return 'بدونِ پشتیبانی';
    const r = await navigator.serviceWorker.getRegistration();
    return r ? r.scope : '';
  });
  t(String(reg).indexOf(BASE + w.page) === 0, 'سرویس‌ورکر روی همین کارتابل ثبت شده', reg);

  /* کارتِ نصب در تنظیمات */
  const inst = await p.evaluate(() => {
    const nb = document.querySelector('.navbtn[data-view="settings"]');
    if (nb) nb.click();
    const box = document.getElementById('pwaBox');
    const a = box ? box.querySelector('a[href$=".apk"]') : null;
    return { box: !!box,
             apk: a ? a.getAttribute('href') : '',
             state: (document.getElementById('pwaState') || {}).textContent || '',
             how: !!(document.getElementById('pwaHow') && !document.getElementById('pwaHow').hidden) };
  });
  t(inst.box, 'تنظیمات کارتِ «برنامهٔ گوشی» دارد');
  t(inst.apk, 'و لینکِ دانلودِ فایلِ نصب هم کنارش هست', inst.apk);
  t(/نصب/.test(inst.state) && inst.how,
    'و چون کروم پیشنهادِ نصب نداده، راهِ دستی را می‌گوید', inst.state.trim());

  /* ---------- اعلان از راهِ سرویس‌ورکر ----------
     روی اندروید «new Notification(...)» خطا می‌دهد؛ اعلان باید از
     رجیستریشن برود. (فقط قالبِ فنی اعلانِ سیستمی دارد.) */
  if (await p.evaluate(() => typeof fireBrowserNotification === 'function')) {
    const nf = await p.evaluate(async () => {
      const reg = await navigator.serviceWorker.ready;
      let viaSw = 0, viaNew = 0, got = null;
      const origShow = reg.showNotification;
      reg.showNotification = function (t, o) { viaSw++; got = { t: t, o: o }; return Promise.resolve(); };
      const ON = window.Notification;
      window.Notification = function () { viaNew++; };
      window.Notification.permission = 'granted';
      try { fireBrowserNotification('🕒 آزمون', 'متنِ اعلان'); }
      finally {
        await new Promise(r => setTimeout(r, 400));
        window.Notification = ON;
        reg.showNotification = origShow;
      }
      return { viaSw, viaNew, got };
    });
    t(nf.viaSw === 1 && nf.viaNew === 0,
      'اعلان از راهِ سرویس‌ورکر می‌رود، نه new Notification',
      'sw=' + nf.viaSw + ' new=' + nf.viaNew);
    t(nf.got && nf.got.o && /app-icon/.test(nf.got.o.icon) && nf.got.o.dir === 'rtl',
      'و نشانه و راست‌به‌چپ بودنش را با خود می‌برد',
      nf.got && nf.got.o ? nf.got.o.icon : '');
  }

  /* ---------- حالتِ نصب‌شده ----------
     اندروید وقتی برنامه از روی نشانهٔ صفحهٔ خانه باز شود،
     «(display-mode: standalone)» را درست می‌کند. این‌جا همان یک پرسش
     جواب دیگری می‌دهد و بقیهٔ راه، همان راهِ واقعیِ خودِ صفحه است. */
  await ctx.addInitScript(() => {
    const orig = window.matchMedia.bind(window);
    window.matchMedia = q => /display-mode:\s*standalone/.test(String(q))
      ? { matches: true, media: String(q), onchange: null,
          addListener() {}, removeListener() {},
          addEventListener() {}, removeEventListener() {}, dispatchEvent() { return false; } }
      : orig(q);
  });
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2500);

  const barred = await p.evaluate(() => {
    const bar = document.getElementById('appBar');
    return {
      app: document.documentElement.getAttribute('data-app'),
      n: bar ? bar.querySelectorAll('.ab').length : 0,
      labels: bar ? [...bar.querySelectorAll('.ab .l')].map(x => x.textContent.trim()) : [],
      more: !!document.getElementById('abMore'),
      vis: bar ? getComputedStyle(bar).display : '',
      pos: bar ? getComputedStyle(bar).position : '',
      navHidden: getComputedStyle(document.querySelector('.sidebar')).display === 'none',
      /* ذخیره و پشتیبان و قفل گم نشده‌اند: اولی زیرِ نامِ کارتابل در
         نوارِ بالا، آن دوتا ته کشو. */
      hintInBar: !!document.querySelector('.topbar .brand .titles #saveHint'),
      footInSheet: !!document.querySelector('#appSheet .as-foot #lockBtn'),
      sticky: getComputedStyle(document.querySelector('.topbar')).position
    };
  });
  t(barred.app === '1', 'در حالتِ نصب‌شده، data-app روشن می‌شود', barred.app);
  t(barred.n === 5 && barred.more, 'نوارِ پایینی پنج دکمه دارد، آخری «بخش‌ها»', 'n=' + barred.n);
  t(barred.vis === 'flex' && barred.pos === 'fixed', 'و پایینِ صفحه قفل است', barred.vis + '/' + barred.pos);
  t(barred.labels.every(x => x.length > 0), 'هر دکمه نامِ بخشِ خودش را دارد', barred.labels.join(' | '));
  const ic = await p.evaluate(() => ({
    bar: document.querySelectorAll('#appBar .ab .i svg').length,
    emoji: /[\u{1F300}-\u{1FAFF}]/u.test(document.getElementById('appBar').textContent)
  }));
  t(ic.bar === 5 && !ic.emoji,
    'نشانه‌ها یک خانواده‌اند (خطی، نه ایموجیِ سیستم)', 'svg=' + ic.bar);
  t(barred.navHidden, 'ستونِ کناری در حالتِ برنامه کنار می‌رود');
  t(barred.hintInBar, '«ذخیره شد» زیرِ نامِ کارتابل می‌نشیند، نه در یک ردیفِ جدا');
  t(barred.footInSheet, 'و پشتیبان و بازیابی و خروج می‌روند ته کشو');
  t(barred.sticky === 'sticky', 'نوارِ بالا با صفحه بالا نمی‌رود', barred.sticky);

  const pad = await p.evaluate(() => parseFloat(getComputedStyle(document.body).paddingBottom) || 0);
  t(pad >= 70, 'ردیفِ آخرِ جدول زیرِ نوار نمی‌ماند', 'padding-bottom=' + pad);

  /* زدنِ یک دکمه، همان بخش را باز می‌کند */
  const go = await p.evaluate(async () => {
    const b = [...document.querySelectorAll('#appBar .ab')].find(x => x.getAttribute('data-go') === 'daily');
    if (!b) return null;
    b.click();
    await new Promise(r => setTimeout(r, 400));
    return {
      view: (document.querySelector('.view.active') || {}).id,
      on: b.classList.contains('on'),
      others: [...document.querySelectorAll('#appBar .ab.on')].length
    };
  });
  t(go && go.view === 'view-daily', 'زدنِ «برنامه روزانه» همان بخش را باز می‌کند', go && go.view);
  t(go && go.on && go.others === 1, 'و خودش روشن می‌شود، فقط خودش');

  /* کشویِ بخش‌ها */
  const sheet = await p.evaluate(async () => {
    document.getElementById('abMore').click();
    await new Promise(r => setTimeout(r, 300));
    const sh = document.getElementById('appSheet');
    const tiles = [...sh.querySelectorAll('.as-t')];
    return {
      open: !sh.hidden && getComputedStyle(sh).display !== 'none',
      tiles: tiles.length,
      navs: document.querySelectorAll('.nav-list .navbtn').length,
      on: tiles.filter(x => x.classList.contains('on')).length,
      cols: getComputedStyle(sh.querySelector('.as-grid')).gridTemplateColumns.split(' ').length,
      locked: getComputedStyle(document.body).overflow
    };
  });
  t(sheet.open, 'دکمهٔ «بخش‌ها» کشوی پایینی را باز می‌کند');
  t(sheet.tiles === sheet.navs && sheet.tiles > 5,
    'و همهٔ بخش‌ها داخلش هستند — نه یکی کمتر', sheet.tiles + ' از ' + sheet.navs);
  t(sheet.on === 1, 'بخشی که بازید، در کشو هم روشن است');
  t(sheet.cols === 3, 'خانه‌ها سه‌ستونه‌اند', 'cols=' + sheet.cols);
  t(sheet.locked === 'hidden', 'و پشتِ کشو نمی‌لغزد');

  const tile = await p.evaluate(async () => {
    const tl = [...document.querySelectorAll('#appSheet .as-t')]
      .find(x => x.getAttribute('data-go') === 'settings');
    tl.click();
    await new Promise(r => setTimeout(r, 400));
    return { view: (document.querySelector('.view.active') || {}).id,
             closed: document.getElementById('appSheet').hidden,
             free: getComputedStyle(document.body).overflow };
  });
  t(tile.view === 'view-settings', 'زدنِ یک خانه همان بخش را باز می‌کند', tile.view);
  t(tile.closed && tile.free !== 'hidden', 'و کشو بسته می‌شود');

  /* ---------- دکمهٔ «بازگشت»ِ اندروید ---------- */
  const hist = await p.evaluate(async () => {
    const wait = () => new Promise(r => setTimeout(r, 450));
    const view = () => (document.querySelector('.view.active') || {}).id;
    document.querySelector('#appBar .ab[data-go="dashboard"]').click(); await wait();
    const a = view();
    document.querySelector('#appBar .ab[data-go="daily"]').click(); await wait();
    const bq = view();
    history.back(); await wait();
    const c = view();
    /* کشو: «بازگشت» باید اول آن را ببندد، نه اینکه بخش را عوض کند */
    document.getElementById('abMore').click(); await wait();
    const openSheet = !document.getElementById('appSheet').hidden;
    history.back(); await wait();
    const afterSheetBack = view();
    /* خانهٔ کشو: بخش باز می‌شود و «بازگشت» یک پله، به همان بخشِ قبلی */
    document.getElementById('abMore').click(); await wait();
    [...document.querySelectorAll('#appSheet .as-t')]
      .find(x => x.getAttribute('data-go') === 'settings').click();
    await wait();
    const viaTile = view();
    history.back(); await wait();
    return { a, b: bq, c, openSheet,
             sheetClosed: document.getElementById('appSheet').hidden,
             after: afterSheetBack, viaTile, backFromTile: view() };
  });
  t(hist.a === 'view-dashboard' && hist.b === 'view-daily',
    'دو بخش پشتِ سر هم باز می‌شوند', hist.a + ' ← ' + hist.b);
  t(hist.c === 'view-dashboard',
    '«بازگشت» به بخشِ قبلی برمی‌گردد، نه بیرونِ برنامه', hist.c);
  t(hist.openSheet && hist.sheetClosed && hist.after === 'view-dashboard',
    'و وقتی کشو باز است، «بازگشت» اول کشو را می‌بندد',
    hist.sheetClosed + ' / ' + hist.after);
  t(hist.viaTile === 'view-settings' && hist.backFromTile === 'view-dashboard',
    'بخشی که از کشو باز شده هم با یک «بازگشت» برمی‌گردد — نه دو تا',
    hist.viaTile + ' ← ' + hist.backFromTile);

  /* میان‌بُرِ نشانهٔ برنامه: #daily */
  await p.goto(BASE + w.page + '#daily', { waitUntil: 'networkidle' });
  await p.waitForTimeout(2500);
  const hash = await p.evaluate(() => (document.querySelector('.view.active') || {}).id);
  t(hash === 'view-daily', 'میان‌بُرِ «برنامهٔ روزانه» همان‌جا را باز می‌کند', hash);

  await ctx.close();
}

await b.close();
console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
