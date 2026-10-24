/* یادآور وقتی برنامه بسته است: صفِ سمتِ سرور، یک نوبتِ فرستادن، و
   صف‌ساختنِ سمتِ صفحه. سرورِ محلی را مثل server/vshare.setup.md بالا
   بیاورید. */
import { launch } from './pw.mjs';
import { spawnSync } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const DB = process.env.DB_FILE || '';
const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
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
  let data = null; try { data = await r.json(); } catch (e) { }
  return { status: r.status, headers: r.headers, data: data || {} };
}; };

/* یک نوبتِ فرستادن، با دست. همان راهی که روی سرورِ واقعی هم برای
   دیدنِ کار به‌کار می‌آید: node server/index.js --remind-now */
function tickNow() {
  const r = spawnSync(process.execPath, ['server/index.js', '--remind-now'], {
    cwd: ROOT, encoding: 'utf8',
    env: { ...process.env, SLTECH_ENV: '/dev/null', DB_FILE: DB, PUSH_OFF: '0' }
  });
  return String(r.stdout || '') + String(r.stderr || '');
}

const adm = mk();
await adm('/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
for (const w of WHO)
  await adm('/api/admin.planer/planners/' + w.slug + '/password',
    { method: 'POST', body: JSON.stringify({ password: w.pass }) });

/* ---------- کلیدِ VAPID ---------- */
console.log('===== کلید و اشتراک =====');
const api = mk();
await api('/api/kartabl/login', { method: 'POST', body: JSON.stringify({ password: 'siamaksiamak' }) });
{
  const k1 = await api('/api/kartabl/push/key');
  t(k1.status === 200 && typeof k1.data.key === 'string' && k1.data.key.length > 80,
    'کلید عمومی می‌آید', 'len=' + ((k1.data.key || '').length));
  t(/^[A-Za-z0-9_-]+$/.test(k1.data.key || 'x!'),
    'و base64url است — همان چیزی که pushManager می‌خواهد');
  const k2 = await api('/api/kartabl/push/key');
  t(k2.data.key === k1.data.key,
    'و دفعهٔ بعد همان است: کلیدِ تازه یعنی همهٔ اشتراک‌های موجود باطل');

  const nope = await api('/api/kartabl/push/subscribe',
    { method: 'POST', body: JSON.stringify({ sub: { endpoint: 'http://x.test/a' } }) });
  t(nope.status === 400, 'اشتراکِ غیرِ https رد می‌شود', nope.data.error);

  const ep = 'https://push.invalid/ep/siamak-1';
  const s1 = await api('/api/kartabl/push/subscribe',
    { method: 'POST', body: JSON.stringify({ sub: { endpoint: ep } }) });
  t(s1.status === 200 && s1.data.ok, 'اشتراک ثبت می‌شود');
  const c1 = await api('/api/kartabl/push/key');
  t(c1.data.subs === 1, 'و شمرده می‌شود', 'subs=' + c1.data.subs);
  await api('/api/kartabl/push/subscribe',
    { method: 'POST', body: JSON.stringify({ sub: { endpoint: ep } }) });
  const c2 = await api('/api/kartabl/push/key');
  t(c2.data.subs === 1,
    'همان دستگاه دوبار ثبت نمی‌شود — وگرنه هر باز شدنِ برنامه یک ردیفِ تازه بود',
    'subs=' + c2.data.subs);
}

/* ---------- صف ---------- */
console.log('===== صفِ یادآورها =====');
const NOW = Date.now();
/* شناسه‌ها هر اجرا تازه‌اند: یادآورِ فرستاده‌شده عمداً دوباره در صف
   نمی‌نشیند، پس با شناسهٔ ثابت، اجرای دومِ همین آزمون می‌افتاد. */
const R = 'r' + NOW + '-';
{
  const items = [
    { id: R + 'past-1', at: NOW - 60000, title: 'سررسیدِ گذشته', body: 'باید همین حالا برود' },
    { id: R + 'soon-1', at: NOW + 10 * 86400000, title: 'ده روز بعد', body: 'نوبتش نرسیده' }
  ];
  const put = await api('/api/kartabl/reminders',
    { method: 'PUT', body: JSON.stringify({ items }) });
  t(put.status === 200 && put.data.n === 2, 'صف نوشته می‌شود', 'n=' + put.data.n);

  const d0 = await api('/api/kartabl/reminders/due');
  t((d0.data.due || []).length === 0,
    'پیش از نوبت هیچ‌چیز «برای نشان دادن» نیست', 'n=' + (d0.data.due || []).length);

  const log = tickNow();
  t(/کارتابل‌های سررسیده: [1-9]/.test(log), 'یک نوبتِ فرستادن، سررسیده را پیدا می‌کند',
    (log.split('\n').find(l => /سررسیده/.test(l)) || '').trim());

  const d1 = await api('/api/kartabl/reminders/due');
  const due = d1.data.due || [];
  t(due.length === 1 && due[0].id === 'siamak:' + R + 'past-1',
    'و فقط همان یکی سررسیده را می‌دهد، نه آنِ ده روز بعد را',
    due.map(x => x.id).join(','));
  t(due[0] && due[0].title === 'سررسیدِ گذشته' && /همین حالا/.test(due[0].body || ''),
    'با متنِ خودش');

  const d2 = await api('/api/kartabl/reminders/due');
  t((d2.data.due || []).length === 0,
    'بارِ دوم خالی است: یک یادآور دوبار نشان داده نمی‌شود');

  /* صفِ تازه، با همان ردیف‌ها: آن‌که رفته نباید دوباره برود */
  await api('/api/kartabl/reminders', { method: 'PUT', body: JSON.stringify({ items }) });
  tickNow();
  const d3 = await api('/api/kartabl/reminders/due');
  t((d3.data.due || []).length === 0,
    'نوشتنِ دوبارهٔ صف، یادآورِ فرستاده‌شده را زنده نمی‌کند — وگرنه هر ذخیره یک اعلانِ تکراری بود');

  /* ورودیِ بی‌ریخت نباید چیزی بشکند */
  const junk = await api('/api/kartabl/reminders',
    { method: 'PUT', body: JSON.stringify({ items: 'nope' }) });
  t(junk.status === 200 && junk.data.n === 0, 'ورودیِ بی‌ریخت فقط صف را خالی می‌کند', 'n=' + junk.data.n);

  const far = await api('/api/kartabl/reminders', { method: 'PUT', body: JSON.stringify({
    items: [{ id: R + 'far', at: NOW + 900 * 86400000, title: 'سالِ بعدِ بعد', body: '' },
            { id: R + 'zero', at: 0, title: 'بی‌تاریخ', body: '' }] }) });
  t(far.data.n === 0, 'تاریخِ بی‌معنی و خیلی‌دور در صف نمی‌نشیند', 'n=' + far.data.n);

  const cap = await api('/api/kartabl/reminders', { method: 'PUT', body: JSON.stringify({
    items: Array.from({ length: 260 }, (_, i) =>
      ({ id: R + 'm' + i, at: NOW + (i + 1) * 3600000, title: 'x', body: '' })) }) });
  t(cap.data.n === 200, 'و صف سقف دارد: ۲۰۰ ردیف', 'n=' + cap.data.n);
  await api('/api/kartabl/reminders', { method: 'PUT', body: JSON.stringify({ items: [] }) });
}

/* ---------- هر کارتابل، صفِ خودش ---------- */
console.log('===== مرزِ کارتابل‌ها =====');
{
  const sina = mk();
  await sina('/api/sina/login', { method: 'POST', body: JSON.stringify({ password: 'sinasinasina' }) });
  await sina('/api/sina/reminders', { method: 'PUT', body: JSON.stringify({
    items: [{ id: R + 'shared-1', at: NOW - 60000, title: 'مالی', body: 'مالِ سینا' }] }) });
  await api('/api/kartabl/reminders', { method: 'PUT', body: JSON.stringify({
    items: [{ id: R + 'shared-1', at: NOW - 60000, title: 'فنی', body: 'مالِ سیامک' }] }) });
  tickNow();
  const a = await sina('/api/sina/reminders/due');
  const b2 = await api('/api/kartabl/reminders/due');
  t((a.data.due || []).length === 1 && a.data.due[0].title === 'مالی',
    'دو کارتابل می‌توانند یک شناسه داشته باشند و قاطی نمی‌شود',
    JSON.stringify((a.data.due || []).map(x => x.title)));
  t((b2.data.due || []).length === 1 && b2.data.due[0].title === 'فنی',
    'و هر کدام فقط مالِ خودش را می‌گیرد');

  const open = await fetch(BASE + '/api/kartabl/reminders/due', { headers: { cookie: '' } });
  t(open.status === 401, 'بی‌نشست، صف خوانده نمی‌شود', 'status=' + open.status);
  await sina('/api/sina/reminders', { method: 'PUT', body: JSON.stringify({ items: [] }) });
  await api('/api/kartabl/reminders', { method: 'PUT', body: JSON.stringify({ items: [] }) });
}

/* ---------- سرویس‌ورکر ---------- */
console.log('===== sw.js =====');
{
  const sw = await (await fetch(BASE + '/sw.js')).text();
  t(/addEventListener\("push"/.test(sw), 'سرویس‌ورکر دستِ «push» را دارد');
  t(/reminders\/due/.test(sw) && /credentials: "include"/.test(sw),
    'و متنِ یادآور را خودش از سرور می‌گیرد — پس بستهٔ فرستاده‌شده خالی می‌ماند');
  t(/genericNote/.test(sw),
    'اگر شبکه نرسید هم یک اعلان می‌آید: کروم بعد از هر بسته انتظارِ اعلان دارد');
  t(/pushsubscriptionchange/.test(sw), 'و عوض شدنِ اشتراک را به صفحه خبر می‌دهد');
  t(/API_SLOT/.test(sw) && /if \(url\.pathname === API_SLOT\) return false/.test(sw),
    'آدرسِ api در حافظه می‌نشیند و خودش از حافظه سرو نمی‌شود');
}

/* ---------- داخلِ صفحه ---------- */
const b = await launch();
const errs = [];
for (const w of WHO) {
  console.log('===== ' + w.name + ' =====');
  const p = await b.newPage({ viewport: { width: 1340, height: 920 } });
  p.on('pageerror', e => errs.push(w.slug + ': ' + String(e).slice(0, 160)));
  p.on('dialog', d => d.accept());
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: w.api, pass: w.pass });
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(3000);

  const box = await p.evaluate(() => {
    const nb = document.querySelector('.navbtn[data-view="settings"]');
    if (nb) nb.click();
    const bx = document.getElementById('remindBox');
    return { there: !!bx, btn: (document.getElementById('remindBtn') || {}).textContent || '',
             state: (document.getElementById('remindState') || {}).textContent || '',
             word: bx ? /دیتای شخصی/.test(bx.textContent) : false };
  });
  t(box.there, 'تنظیمات دکمهٔ یادآورِ پس‌زمینه را دارد');
  t(/روشن کن/.test(box.btn) || /مرورگر/.test(box.btn), 'و خاموش شروع می‌شود', box.btn.trim());
  t(box.word, 'و همان‌جا می‌گوید از دیتای شخصی فقط تاریخ بالا می‌رود');

  /* صف از دادهٔ واقعیِ چند ماه ساخته می‌شود، نه فقط ماهِ جاری */
  const built = await p.evaluate(() => {
    const MONTHS = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور",
                    "مهر","آبان","آذر","دی","بهمن","اسفند"];
    const tp = getTodayJalaliParts();
    const ahead = ((tp.monthNum - 1 + 2) % 12);
    const y = ahead < tp.monthNum - 1 ? String(parseInt(tp.year, 10) + 1) : String(tp.year);
    const key = y + '|' + MONTHS[ahead];
    const iso = ms => { const d = new Date(ms);
      const z = n => String(n).padStart(2, '0');
      return d.getFullYear() + '-' + z(d.getMonth() + 1) + '-' + z(d.getDate()) +
             'T' + z(d.getHours()) + ':' + z(d.getMinutes()); };
    state.monthsData[key] = {
      tasks: [{ category: 'شبکه', task: 'تمدیدِ گواهی', deadline: 15,
                status: 'انجام نشده', priority: 'بالا' },
              { category: 'شبکه', task: 'کارِ انجام‌شده', deadline: 16, status: 'انجام شد' }],
      days: [{ day: 1, important: true, reminderAt: iso(Date.now() + 3 * 86400000),
               main: 'جلسهٔ مهم' },
             { day: 2, important: true, reminderAt: iso(Date.now() - 3 * 86400000),
               main: 'جلسهٔ گذشته' },
             { day: 3, important: false, reminderAt: iso(Date.now() + 4 * 86400000),
               main: 'ردیفِ غیرِ مهم' }]
    };
    const fa2en = s => String(s).replace(/[۰-۹]/g, c => '۰۱۲۳۴۵۶۷۸۹'.indexOf(c));
    state.personalDue = [fa2en(DatePick.fromStamp(Date.now() + 20 * 86400000))];
    const items = REMIND.build();
    return { items, key, due: state.personalDue[0] };
  });
  const ids = built.items.map(x => x.id);
  t(ids.some(i => i.indexOf('c|' + built.key + '|0|15') === 0),
    'مهلتِ چک‌لیستِ ماهِ آینده در صف می‌نشیند — نه فقط ماهِ جاری که باز است',
    ids.join(' , '));
  t(!ids.some(i => i.indexOf('c|' + built.key + '|1') === 0),
    'کارِ انجام‌شده یادآور ندارد');
  t(ids.some(i => i.indexOf('d|' + built.key + '|0|') === 0),
    'ردیفِ مهمِ برنامهٔ روزانه با ساعتِ خودش می‌آید');
  t(!ids.some(i => i.indexOf('d|' + built.key + '|1|') === 0),
    'یادآورِ گذشته دوباره در صف نمی‌رود');
  t(!ids.some(i => i.indexOf('d|' + built.key + '|2|') === 0),
    'و ردیفی که «مهم» نیست یادآور ندارد');
  const v = built.items.find(x => x.id.indexOf('v|') === 0);
  t(!!v, 'سررسیدِ دیتای شخصی هم می‌آید', v && v.id);
  t(v && /دیتای شخصی/.test(v.body) && !/قسط|وام|بانک|مبلغ|\d{4,}/.test(v.body),
    'ولی با متنِ کلی: نه نامِ قسط، نه مبلغ، نه چیزی از صندوق', v && v.body);
  const chk = built.items.find(x => x.id.indexOf('c|') === 0);
  t(chk && chk.at < Date.now() + 400 * 86400000 && chk.at > Date.now(),
    'هر یادآور لحظهٔ مطلق دارد، پس سرور لازم نیست تاریخِ شمسی بفهمد');
  t(built.items.every((x, i, a) => i === 0 || a[i - 1].at <= x.at), 'و صف مرتب است');

  /* خاموش که باشد، چیزی بالا نمی‌رود */
  const quiet = await p.evaluate(async () => {
    const was = REMIND.on();
    await REMIND.sync(true);
    const r = await apiCall('/reminders/due');
    return { was, n: ((r.data || {}).due || []).length };
  });
  t(quiet.was === false && quiet.n === 0,
    'تا کاربر روشنش نکند، صفی بالا نمی‌رود و اعلانی ثبت نمی‌شود');
  await p.close();
}

await b.close();
console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
