/* محافظ‌ها: نبضِ سرویس، ورودِ دومرحله‌ای ادمین، و کارتابلِ نمایشی.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید (یا با
   server/ci-setup.sh). */
import { createServer } from 'node:http';
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const PORT = Number(process.env.VS_BALE_PORT || 8913);
const TOKEN = 'fake-token-for-tests';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* رباتِ قلابی: کد باید جایی برود، و آزمون باید همان را بخواند. */
let seen = [];
const stub = createServer((req, res) => {
  let b = '';
  req.on('data', c => { b += c; });
  req.on('end', () => {
    let j = {}; try { j = JSON.parse(b); } catch (e) { }
    seen.push(j);
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true, result: { message_id: 1 } }));
  });
});
await new Promise(r => stub.listen(PORT, '127.0.0.1', r));

const mk = () => { let ck = ''; return async (path, opt) => {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
  const r = await fetch(BASE + path, o);
  for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
    const kv = c.split(';')[0], k = kv.split('=')[0];
    ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
  }
  let data = null; try { data = await r.json(); } catch (e) { }
  return { status: r.status, data: data || {}, cookie: ck };
}; };

const A = '/api/admin.planer';

/* ---------- نبض ---------- */
console.log('===== نبضِ سرویس =====');
{
  const r = await fetch(BASE + '/healthz');
  const d = await r.json().catch(() => ({}));
  t(r.status === 200 && d.ok === true, 'healthz جواب می‌دهد', 'status=' + r.status);
  const txt = JSON.stringify(d);
  t(!/slug|panel|user|version|token/i.test(txt),
    'و چیزی جز «آره» در آن نیست — یک آدرسِ باز نباید چیزی بگوید', txt);
}

/* ---------- ورودِ دومرحله‌ای ---------- */
console.log('===== ورودِ دومرحله‌ای ادمین =====');
{
  const adm = mk();
  await adm(A + '/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
  await adm(A + '/site', { method: 'PUT', body: JSON.stringify({ baleToken: TOKEN, baleChat: '551100' }) });

  const on = await adm(A + '/admin2fa', { method: 'POST', body: JSON.stringify({ on: true }) });
  t(on.status === 200 && on.data.on === true, 'از داخلِ پنل روشن می‌شود');

  /* حالا یک ورودِ تازه: رمزِ درست باید کد بخواهد، نه نشست */
  seen = [];
  const fresh = mk();
  const step1 = await fresh(A + '/signin',
    { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
  t(step1.data.needCode === true && !step1.data.ok,
    'رمزِ درست دیگر به‌تنهایی وارد نمی‌کند', JSON.stringify(step1.data).slice(0, 80));
  t(!/kartabl_|session/i.test(step1.cookie || ''), 'و هنوز نشستی داده نشده');
  const msg = (seen[0] && String(seen[0].text || '')) || '';
  const code = (msg.match(/(\d{6})/) || [])[1];
  t(!!code, 'کد به ربات رفت', msg.replace(/\s+/g, ' ').slice(0, 50));

  const wrong = await fresh(A + '/signin/code',
    { method: 'POST', body: JSON.stringify({ code: String((Number(code) + 1) % 1000000).padStart(6, '0') }) });
  t(wrong.status === 401, 'کدِ غلط رد می‌شود', 'status=' + wrong.status);

  const good = await fresh(A + '/signin/code', { method: 'POST', body: JSON.stringify({ code }) });
  t(good.status === 200 && good.data.ok === true, 'و کدِ درست وارد می‌کند');
  const who = await fresh(A + '/me');
  t(who.data && who.data.in === true, 'نشست واقعاً برقرار شد', JSON.stringify(who.data).slice(0, 60));

  /* همان کد دوبار به‌کار نمی‌آید */
  const again = await fresh(A + '/signin/code', { method: 'POST', body: JSON.stringify({ code }) });
  t(again.status === 409, 'و همان کد بارِ دوم نمی‌گیرد — یک‌بارمصرف است', 'status=' + again.status);

  const off = await adm(A + '/admin2fa', { method: 'POST', body: JSON.stringify({ on: false }) });
  t(off.status === 200 && off.data.on === false, 'و خاموش کردنش هم از همان‌جاست');
  const back = await mk()(A + '/signin',
    { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
  t(back.data.ok === true, 'بعد از خاموش کردن، ورود مثلِ قبل است');
}

/* ---------- کارتابلِ نمایشی ---------- */
console.log('===== کارتابلِ نمایشی =====');
{
  const adm = mk();
  await adm(A + '/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
  /* اگر از قبل هست، خطا نیست */
  await adm(A + '/planners',
    { method: 'POST', body: JSON.stringify({ slug: 'demo', name: 'نمایشی', kind: 'it', user: 'demo' }) });

  const api = mk();
  const login = await api('/api/demo/login', { method: 'POST', body: JSON.stringify({ password: '' }) });
  t(login.status === 200 && login.data.demo === true,
    'کارتابلِ نمایشی بی‌رمز باز می‌شود — کسی که آمده ببیند، رمزی ندارد');

  const put = await api('/api/demo/state',
    { method: 'PUT', body: JSON.stringify({ state: { tasks: [{ task: 'نمایشی' }] }, force: true }) });
  t(put.status === 200 && put.data.demo === true,
    'نوشتن «موفق» است — رد کردنش دمو را شکسته نشان می‌داد');
  const got = await api('/api/demo/state');
  const tasks = ((got.data.state || {}).tasks || []).map(x => x.task).join(',');
  t(!/نمایشی/.test(tasks), 'ولی روی سرور چیزی ننشست', tasks || 'خالی');

  /* و کارتابلِ معمولی همچنان رمز می‌خواهد */
  const other = await mk()('/api/kartabl/login', { method: 'POST', body: JSON.stringify({ password: '' }) });
  t(other.status === 401 || other.status === 400,
    'کارتابلِ معمولی بی‌رمز باز نمی‌شود', 'status=' + other.status);
}

/* ---------- در خودِ صفحه ---------- */
console.log('===== صفحهٔ نمایشی =====');
{
  const b = await launch();
  const p = await b.newPage({ viewport: { width: 1200, height: 800 } });
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto(BASE + '/demo/', { waitUntil: 'domcontentloaded' });
  await p.waitForTimeout(6000);
  const r = await p.evaluate(() => ({
    demo: !!window.KARTABL_DEMO,
    bar: !!document.getElementById('demoBar'),
    txt: (document.getElementById('demoBar') || {}).textContent || '',
    pad: document.documentElement.getAttribute('data-demo')
  }));
  t(r.demo && r.bar, 'صفحه خودش را نمایشی می‌داند و نوارش را نشان می‌دهد');
  t(/روی سرور ذخیره نمی‌شود/.test(r.txt),
    'و صریح می‌گوید که نوشته‌ها نمی‌مانند — دموی بی‌برچسب بدتر از نبودنش است');
  t(r.pad === '1', 'و جای نوار در صفحه باز شده');
  t(errs.length === 0, 'بی‌خطای جاوااسکریپت', errs.join(' | ') || '—');
  await p.close();
  await b.close();
}

/* ---------- گشتِ اولِ کار ---------- */
console.log('===== گشتِ اول =====');
{
  const b = await launch();
  const p = await b.newPage({ viewport: { width: 1340, height: 900 } });
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
  await p.evaluate(async () => {
    await fetch('/api/kartabl/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: 'siamaksiamak', remember: false }) });
  });
  await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(2800);

  const r = await p.evaluate(async () => {
    state.tourDone = false;
    TOUR.start(true);
    await new Promise(x => setTimeout(x, 300));
    const box = document.querySelector('.tourbox');
    return { open: !!(box && !box.hidden),
             n: box.querySelector('.tr-n').textContent,
             title: box.querySelector('h4').textContent,
             marked: !!document.querySelector('.tour-on') };
  });
  t(r.open && /۱ از/.test(r.n), 'گشت با قدمِ اول باز می‌شود', r.n);
  t(!!r.title && r.marked,
    'و همان بخشی را که دربارهٔ آن حرف می‌زند، روی صفحه نشان می‌دهد', r.title);

  const done = await p.evaluate(async () => {
    for (let k = 0; k < 8; k++) {
      const nx = document.querySelector('.tr-next');
      if (!nx || document.querySelector('.tourbox').hidden) break;
      nx.click();
      await new Promise(x => setTimeout(x, 100));
    }
    return { closed: document.querySelector('.tourbox').hidden,
             flag: state.tourDone === true,
             marks: document.querySelectorAll('.tour-on').length };
  });
  t(done.closed && done.flag,
    'تا آخر که رفت، بسته می‌شود و دیگر برنمی‌گردد — «دیده شد» در خودِ داده می‌نشیند');
  t(done.marks === 0, 'و نشانه‌هایش از صفحه پاک می‌شوند');

  const again = await p.evaluate(async () => {
    TOUR.init();
    await new Promise(x => setTimeout(x, 2200));
    return document.querySelector('.tourbox').hidden;
  });
  t(again === true, 'و دفعهٔ بعد خودش باز نمی‌شود');
  t(errs.length === 0, 'بی‌خطای جاوااسکریپت', errs.join(' | ') || '—');
  await p.close();
  await b.close();
}

stub.close();
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
