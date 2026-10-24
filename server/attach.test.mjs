/* پیوستِ فایل: مسیرِ سرور، سهمیه، نوعِ مجاز، و خودِ کشو در صفحه.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const WHO = [
  { slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak', name: 'کارتابلِ فنی' },
  { slug: 'sina', page: '/sina/', api: 'sina', pass: 'sinasinasina', name: 'کارتابلِ مالی' }
];
const PNG = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

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
const adm = mk();
await adm('/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
for (const w of WHO)
  await adm('/api/admin.planer/planners/' + w.slug + '/password',
    { method: 'POST', body: JSON.stringify({ password: w.pass }) });

/* ---------- سمتِ سرور ---------- */
console.log('===== مسیرِ فایل =====');
{
  const api = mk();
  await api('/api/kartabl/login', { method: 'POST', body: JSON.stringify({ password: 'siamaksiamak' }) });

  const up = await api('/api/kartabl/files', { method: 'POST', body: JSON.stringify({
    ref: 'test-row-1', name: 'رسیدِ برق.png', type: 'image/png', data: PNG }) });
  t(up.status === 200 && up.data.file && up.data.file.id, 'فایل بالا می‌رود', 'status=' + up.status);
  const id = up.data.file && up.data.file.id;
  t(up.data.file && up.data.file.name === 'رسیدِ برق.png', 'نامِ فارسی سالم می‌ماند', up.data.file.name);

  const ls = await api('/api/kartabl/files?ref=test-row-1');
  t(ls.data.files && ls.data.files.length === 1, 'و در فهرستِ همان ردیف دیده می‌شود');

  const cnt = await api('/api/kartabl/files');
  t(cnt.data.counts && cnt.data.counts['test-row-1'] === 1,
    'شمارشِ ردیف‌ها یک‌جا می‌آید — نه یک درخواست به ازای هر ردیف');
  t(cnt.data.limits && cnt.data.limits.file > 0 && cnt.data.used >= 70,
    'و سهمیه و جای مصرف‌شده هم', JSON.stringify(cnt.data.limits));

  const dl = await fetch(BASE + '/api/kartabl/files/' + id, { headers: { cookie: '' } });
  t(dl.status === 401, 'بی‌نشست، فایل دانلود نمی‌شود', 'status=' + dl.status);

  const svg = await api('/api/kartabl/files', { method: 'POST', body: JSON.stringify({
    ref: 'test-row-1', name: 'bad.svg', type: 'image/svg+xml', data: PNG }) });
  t(svg.status === 400, 'SVG پذیرفته نمی‌شود — روی همین دامنه اسکریپتش اجرا می‌شد', svg.data.error);

  const html = await api('/api/kartabl/files', { method: 'POST', body: JSON.stringify({
    ref: 'test-row-1', name: 'x.html', type: 'text/html', data: PNG }) });
  t(html.status === 400, 'و HTML هم همین‌طور');

  const big = await api('/api/kartabl/files', { method: 'POST', body: JSON.stringify({
    ref: 'test-row-1', name: 'big.png', type: 'image/png', data: 'A'.repeat(7 * 1024 * 1024) }) });
  t(big.status === 400 && /مگابایت/.test(big.data.error || ''), 'فایلِ بزرگ رد می‌شود', big.data.error);

  /* کارتابلِ دیگر نباید فایلِ این یکی را ببیند */
  const other = mk();
  await other('/api/sina/login', { method: 'POST', body: JSON.stringify({ password: 'sinasinasina' }) });
  const steal = await other('/api/sina/files/' + id);
  t(steal.status === 404, 'کارتابلِ دیگر فایلِ این یکی را نمی‌بیند', 'status=' + steal.status);

  const del = await api('/api/kartabl/files/' + id, { method: 'DELETE' });
  t(del.status === 200, 'و پاک کردنش کار می‌کند');
  const gone = await api('/api/kartabl/files?ref=test-row-1');
  t((gone.data.files || []).length === 0, 'بعدش دیگر در فهرست نیست');
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

  await p.evaluate(() => {
    state.tasks = [{ category: 'سایر', task: 'کارِ پیوست‌دار', owner: '', deadline: 1,
                     status: 'انجام نشده', priority: 'بالا', note: '' }];
    const nb = document.querySelector('.navbtn[data-view="checklist"]');
    if (nb) nb.click();
    renderChecklist();
  });
  await p.waitForTimeout(500);

  const cell = await p.evaluate(() => {
    const td = document.querySelector('#checklistBody .clip-cell');
    return { there: !!td, kind: td && td.getAttribute('data-kind'),
             btn: !!(td && td.querySelector('.clip-btn')) };
  });
  t(cell.there && cell.kind === 'task' && cell.btn, 'هر ردیف خانهٔ 📎 دارد');

  const opened = await p.evaluate(async () => {
    document.querySelector('#checklistBody .clip-btn').click();
    await new Promise(r => setTimeout(r, 600));
    const bx = document.getElementById('attachBox');
    return { open: bx && !bx.hidden, fid: state.tasks[0].fid || '',
             title: (document.getElementById('atTitle') || {}).textContent || '',
             note: (document.getElementById('atNote') || {}).textContent || '' };
  });
  t(opened.open, 'زدنش کشوی پیوست را باز می‌کند');
  t(/^t-[0-9a-f]{16}$/.test(opened.fid),
    'و ردیف همان‌جا شناسهٔ خودش را می‌گیرد — نه شمارهٔ ردیف که جابه‌جا می‌شود', opened.fid);
  t(/پیوست‌های/.test(opened.title), 'عنوانِ کشو نامِ همان کار را می‌گوید', opened.title.trim());
  t(/مگابایت|بایت/.test(opened.note), 'و جای مصرف‌شده را می‌گوید', opened.note.trim());

  /* بالا بردنِ فایل از داخلِ خودِ صفحه */
  const put = await p.evaluate(async png => {
    const r = await apiCall('/files', { method: 'POST', body: JSON.stringify({
      ref: state.tasks[0].fid, name: 'نمونه.png', type: 'image/png', data: png }) });
    await ATTACH.refresh();
    await new Promise(r2 => setTimeout(r2, 400));
    const btn = document.querySelector('#checklistBody .clip-btn');
    return { ok: r.ok, label: btn.textContent.trim(), has: btn.classList.contains('has') };
  }, PNG);
  t(put.ok, 'فایل از داخلِ صفحه هم بالا می‌رود');
  t(put.has && /۱/.test(put.label), 'و خانهٔ 📎 شمارهٔ پیوست را نشان می‌دهد', put.label);

  const listed = await p.evaluate(async () => {
    document.querySelector('#checklistBody .clip-btn').click();
    await new Promise(r => setTimeout(r, 700));
    const rows = [...document.querySelectorAll('#atList .at-row')];
    return { n: rows.length, name: rows[0] ? rows[0].querySelector('.at-name').textContent.trim() : '',
             href: rows[0] ? rows[0].querySelector('.at-name').getAttribute('href') : '' };
  });
  t(listed.n === 1 && listed.name === 'نمونه.png', 'کشو فایل را با نامش نشان می‌دهد', listed.name);
  t(/\/files\//.test(listed.href), 'و لینکِ دانلودش درست است', listed.href);

  await p.evaluate(async () => {
    const f = await apiCall('/files?ref=' + encodeURIComponent(state.tasks[0].fid));
    for (const x of (f.data.files || [])) await apiCall('/files/' + x.id, { method: 'DELETE' });
    ATTACH.close();
  });
  await p.close();
}

await b.close();
console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
