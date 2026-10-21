/* کارتابل به شکلِ برنامهٔ اندروید: مانیفست، سرویس‌ورکر، و نوارِ
   دکمه‌های پایینی که فقط در حالتِ نصب‌شده می‌آید.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

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

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];

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
    return { box: !!box,
             state: (document.getElementById('pwaState') || {}).textContent || '',
             how: !!(document.getElementById('pwaHow') && !document.getElementById('pwaHow').hidden) };
  });
  t(inst.box, 'تنظیمات کارتِ «برنامهٔ گوشی» دارد');
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
      navHidden: getComputedStyle(document.querySelector('.nav-list')).display === 'none',
      footShown: getComputedStyle(document.querySelector('.sidebar-foot')).display !== 'none'
    };
  });
  t(barred.app === '1', 'در حالتِ نصب‌شده، data-app روشن می‌شود', barred.app);
  t(barred.n === 5 && barred.more, 'نوارِ پایینی پنج دکمه دارد، آخری «بخش‌ها»', 'n=' + barred.n);
  t(barred.vis === 'flex' && barred.pos === 'fixed', 'و پایینِ صفحه قفل است', barred.vis + '/' + barred.pos);
  t(barred.labels.every(x => x.length > 0), 'هر دکمه نامِ بخشِ خودش را دارد', barred.labels.join(' | '));
  t(barred.navHidden, 'منوی قدیمی در حالتِ برنامه کنار می‌رود');
  t(barred.footShown, 'ولی ذخیره و پشتیبان و قفل سرِ جایشان می‌مانند');

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
