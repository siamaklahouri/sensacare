/* مهلتِ کارتابل با تاریخ، نه با عددِ روز — در پنلِ ادمین.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const SLUG = 'mohlat';

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

const A = '/api/admin.planer';
const adm = mk();
/* حذف، آدرسِ کارتابل را به‌عنوانِ تأیید می‌خواهد */
const del = () => adm(A + '/planners/' + SLUG,
  { method: 'DELETE', body: JSON.stringify({ confirm: SLUG }) });
await adm(A + '/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
await del();

const DAY = 86400000;
const rowOf = async () => ((await adm(A + '/planners')).items || []).find(x => x.slug === SLUG) || {};

console.log('===== سمتِ سرور =====');
const soon = Date.now() + 10 * DAY;
const made = await adm(A + '/planners', { method: 'POST', body: JSON.stringify({
  name: 'آزمونِ مهلت', slug: SLUG, kind: 'gen', until: soon }) });
t(!!made.ok, 'کارتابل با تاریخِ پایان ساخته شد', made.error || made.url);
const r1 = await rowOf();
t(Math.abs(Number(r1.until) - soon) < 2000, 'و همان لحظه روی کارتابل نشست',
  new Date(Number(r1.until)).toISOString());

/* عددِ روز هم باید کار کند: سفارش‌های فروشگاه با همان می‌آیند */
await adm(A + '/planners/' + SLUG, { method: 'PUT', body: JSON.stringify({ days: 5 }) });
const r2 = await rowOf();
t(Math.abs(Number(r2.until) - (Date.now() + 5 * DAY)) < 5000,
  'عددِ روز هم مثلِ قبل پذیرفته می‌شود — سفارش‌ها با همان می‌آیند',
  String(Math.round((Number(r2.until) - Date.now()) / DAY)) + ' روز');

const far = await adm(A + '/planners/' + SLUG,
  { method: 'PUT', body: JSON.stringify({ until: Date.now() + 4000 * DAY }) });
t(!!far.error && /دور/.test(far.error), 'تاریخِ خیلی دور رد می‌شود', far.error);
const past = await adm(A + '/planners/' + SLUG,
  { method: 'PUT', body: JSON.stringify({ until: Date.now() - 10 * DAY }) });
t(!!past.error && /جلوتر/.test(past.error), 'و تاریخِ گذشته هم', past.error);
const junk = await adm(A + '/planners/' + SLUG,
  { method: 'PUT', body: JSON.stringify({ until: 'فردا' }) });
t(!!junk.error, 'و چیزی که تاریخ نیست', junk.error);
const r3 = await rowOf();
t(Math.abs(Number(r3.until) - Number(r2.until)) < 2,
  'و هیچ‌کدام مهلتِ قبلی را خراب نکردند',
  new Date(Number(r3.until)).toISOString());

const none = await adm(A + '/planners/' + SLUG, { method: 'PUT', body: JSON.stringify({ until: 0 }) });
t(!none.error && !Number((await rowOf()).until), 'صفر یعنی بی‌مهلت', String((await rowOf()).until));

console.log('\n===== صفحهٔ پنل =====');
const b = await launch();
const errs = [];
const p = await b.newPage({ viewport: { width: 1360, height: 960 } });
p.on('pageerror', e => errs.push(String(e).slice(0, 170)));
p.on('dialog', d => d.accept());
await p.goto(BASE + '/login', { waitUntil: 'domcontentloaded' });
await p.evaluate(async x => {
  await fetch('/api/admin.planer/signin', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ user: x.u, password: x.p }) });
}, { u: AUSER, p: APASS });
await p.goto(BASE + '/login', { waitUntil: 'networkidle' });
await p.waitForTimeout(2300);

/* فرمِ کارتابلِ تازه */
await p.evaluate(() => document.querySelector('.tabs button[data-tab="new"]').click());
await p.waitForTimeout(400);
const nf = await p.evaluate(() => {
  const el = document.getElementById('nUntil');
  const old = document.getElementById('nDays');
  return { has: !!el, date: !!(el && el.hasAttribute('data-date')),
           type: el ? el.type : '', old: !!old,
           label: el ? (el.closest('.fld').querySelector('label').textContent || '').trim() : '' };
});
t(nf.has && nf.date && nf.type === 'text', 'در فرمِ کارتابلِ تازه، خانهٔ مهلت تاریخ می‌گیرد');
t(!nf.old, 'و خانهٔ عددِ روز دیگر نیست');
t(/تاریخ/.test(nf.label), 'برچسبش هم همین را می‌گوید', nf.label);

/* تقویم با یک کلیک باز می‌شود */
await p.click('#nUntil');
await p.waitForTimeout(500);
const cal = await p.evaluate(() => {
  const pop = document.querySelector('.dp-pop');
  return { open: !!(pop && !pop.hidden),
           days: pop ? pop.querySelectorAll('.dp-d').length : 0,
           ttl: pop ? (pop.querySelector('.dp-ttl') || {}).textContent : '' };
});
t(cal.open && cal.days > 27, 'با زدنِ خانه، تقویمِ شمسی باز می‌شود', cal.ttl + ' — ' + cal.days + ' روز');

/* یک روز را انتخاب می‌کنیم و می‌سازیم */
const picked = await p.evaluate(() => {
  const ds = [...document.querySelectorAll('.dp-pop .dp-d')];
  const now = ds.findIndex(x => x.classList.contains('now'));
  const d = ds[Math.min(ds.length - 1, (now >= 0 ? now : 0) + 6)];   /* شش روز بعد */
  d.click();
  return document.getElementById('nUntil').value;
});
t(/^[۰-۹]{4}\/[۰-۹]{2}\/[۰-۹]{2}$/.test(picked),
  'تاریخِ انتخاب‌شده با رقمِ فارسی داخلِ خانه می‌نشیند', picked);

await del();
await p.evaluate(() => {
  document.getElementById('nName').value = 'آزمونِ مهلت';
  document.getElementById('nSlug').value = 'mohlat';
  /* بی هیچ بخشی، خودِ پنجرهٔ ویرایش بعداً ایراد می‌گیرد — و این
     آزمون دربارهٔ مهلت است، نه آن. */
  document.querySelectorAll('#nViews input').forEach(i => { i.checked = true; });
});
await p.waitForTimeout(200);
await p.evaluate(() => document.getElementById('nCreate').click());
await p.waitForTimeout(1600);
const after = await rowOf();
const want = await p.evaluate(v => {
  const d = DatePick.parse(v);
  return DatePick.toStamp(d.jy, d.jm, d.jd);
}, picked);
t(Math.abs(Number(after.until) - want) < 2000,
  'و کارتابل با همان تاریخ ساخته می‌شود — تا پایانِ همان روز',
  new Date(Number(after.until)).toISOString());

/* پنجرهٔ ویرایش: تاریخِ همین حالا پر است */
await p.evaluate(() => document.querySelector('.tabs button[data-tab="list"]').click());
await p.waitForTimeout(900);
await p.evaluate(s => {
  const card = [...document.querySelectorAll('#tab-list .pcard')]
    .find(c => c.getAttribute('data-slug') === s);
  const btn = [...card.querySelectorAll('button')].find(x => /ویرایش/.test(x.textContent));
  btn.click();
}, SLUG);
await p.waitForTimeout(800);
const ed = await p.evaluate(() => {
  const el = document.getElementById('eUntil');
  return { has: !!el, val: el ? el.value : '', old: !!document.getElementById('eDays') };
});
t(ed.has && !ed.old, 'در پنجرهٔ ویرایش هم خانهٔ تاریخ است، نه عددِ روز');
t(ed.val === picked, 'و تاریخِ کنونیِ مهلت داخلش نوشته شده', ed.val + ' / ' + picked);

/* خالی کردنش یعنی بی‌مهلت */
await p.evaluate(() => { document.getElementById('eUntil').value = ''; });
await p.evaluate(() => document.getElementById('eSave').click());
await p.waitForTimeout(1500);
t(!Number((await rowOf()).until), 'خالی کردنِ خانه یعنی بی‌مهلت', String((await rowOf()).until));

/* چیزی که تاریخ نیست، جلوی ذخیره را می‌گیرد */
await p.evaluate(s => {
  const card = [...document.querySelectorAll('#tab-list .pcard')]
    .find(c => c.getAttribute('data-slug') === s);
  const btn = [...card.querySelectorAll('button')].find(x => /ویرایش/.test(x.textContent));
  btn.click();
}, SLUG);
await p.waitForTimeout(700);
await p.evaluate(() => { document.getElementById('eUntil').value = 'فردا'; });
await p.evaluate(() => document.getElementById('eSave').click());
await p.waitForTimeout(900);
const err = await p.evaluate(() => ({
  err: (document.getElementById('eErr') || {}).textContent || '',
  open: !document.getElementById('ov').hidden
}));
t(/تقویم/.test(err.err) && err.open, 'نوشتهٔ بی‌معنا جلوی ذخیره را می‌گیرد و می‌گوید چه کند',
  err.err);
await p.evaluate(() => document.getElementById('eCancel').click());

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نبود', errs.join(' | ') || '—');
await del();
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
