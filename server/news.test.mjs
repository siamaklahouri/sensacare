/* خبرِ تغییرها: پیش‌نویس در پنلِ ادمین، ارسال، و دیده شدنش در
   کارتابل. سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';

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
  return { status: r.status, data: data || {} };
}; };

const adm = mk();
await adm('/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
await adm('/api/admin.planer/planners/siamak/password',
  { method: 'POST', body: JSON.stringify({ password: 'siamaksiamak' }) });
const api = mk();
await api('/api/kartabl/login', { method: 'POST', body: JSON.stringify({ password: 'siamaksiamak' }) });

/* ---------- پیش‌نویس‌ها ---------- */
console.log('===== پیش‌نویس =====');
const TAG = 'آزمونِ خبر ' + Date.now();
let id = '';
{
  const ls = await adm('/api/admin.planer/news');
  const items = ls.data.items || [];
  t(ls.status === 200 && items.length > 0,
    'تغییرهای کارتابل خودشان در پنلِ ادمین نشسته‌اند', 'n=' + items.length);
  t(items.every(x => x.status === 'draft' || x.status === 'sent'), 'هر کدام وضعیتی دارند');

  const mine = await adm('/api/admin.planer/news',
    { method: 'POST', body: JSON.stringify({ title: TAG, body: 'متنِ آزمون', icon: '🧪' }) });
  id = mine.data.id || '';
  t(mine.status === 200 && mine.data.created && id,
    'ادمین می‌تواند خبرِ از خودش بنویسد', id);

  const seen = await api('/api/kartabl/news');
  const got = (seen.data.news || []).some(x => x.title === TAG);
  t(seen.status === 200 && !got,
    'ولی تا فرستاده نشود، کارتابل نمی‌بیندش — همین نکتهٔ اصلیِ کار است');

  const ed = await adm('/api/admin.planer/news',
    { method: 'POST', body: JSON.stringify({ id, title: TAG + ' (ویراسته)', body: 'متنِ تازه', icon: '🧪' }) });
  t(ed.status === 200, 'متنش هم پیش از ارسال عوض می‌شود');
  const after = (await adm('/api/admin.planer/news')).data.items.find(x => x.id === id);
  t(after && after.title === TAG + ' (ویراسته)' && after.body === 'متنِ تازه',
    'و همان می‌ماند', after && after.title);

  const noPass = await fetch(BASE + '/api/admin.planer/news', { headers: { cookie: '' } });
  t(noPass.status === 401 || noPass.status === 403,
    'و بی‌ادمین، فهرستِ خبرها خوانده نمی‌شود', 'status=' + noPass.status);
}

/* ---------- ارسال ---------- */
console.log('===== ارسال =====');
{
  const snd = await adm('/api/admin.planer/news/' + encodeURIComponent(id) + '/send',
    { method: 'POST', body: JSON.stringify({ push: false }) });
  t(snd.status === 200, 'ارسال به همه');

  const seen = await api('/api/kartabl/news');
  const row = (seen.data.news || []).find(x => x.id === id);
  t(!!row, 'حالا کارتابل می‌بیندش');
  t(row && row.title === TAG + ' (ویراسته)' && row.icon === '🧪',
    'با همان متنی که ادمین پسندیده', row && row.title);
  t(row && row.sent_at > 0, 'و زمانِ ارسالش ثبت شده');

  const back = await adm('/api/admin.planer/news/' + encodeURIComponent(id) + '/unsend',
    { method: 'POST', body: JSON.stringify({}) });
  t(back.status === 200, 'و پس گرفتنش هم هست');
  const after = await api('/api/kartabl/news');
  t(!(after.data.news || []).some(x => x.id === id),
    'که از کارتابل‌ها برمی‌گردد — اگر اشتباهی رفته باشد');

  await adm('/api/admin.planer/news/' + encodeURIComponent(id) + '/send',
    { method: 'POST', body: JSON.stringify({ push: false }) });
}

/* ---------- داخلِ کارتابل ---------- */
console.log('===== داخلِ کارتابل =====');
const b = await launch();
const errs = [];
{
  const p = await b.newPage({ viewport: { width: 1340, height: 900 } });
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  p.on('dialog', d => d.accept());
  await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
  await p.evaluate(async () => {
    await fetch('/api/kartabl/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: 'siamaksiamak', remember: false }) });
  });
  await p.evaluate(() => { try { localStorage.clear(); } catch (e) { } });
  await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(3000);
  /* خوانده‌شده‌ها پاک می‌شوند تا خبر «تازه» باشد */
  await p.evaluate(() => { state.bellSeen = []; NEWS.reload(); });
  await p.waitForTimeout(2200);

  const win = await p.evaluate(tag => {
    const box = document.getElementById('nwBox');
    return { open: !!(box && !box.hidden),
             txt: box ? box.textContent : '',
             has: box ? box.textContent.indexOf(tag) >= 0 : false,
             unread: NEWS.unread().length };
  }, TAG);
  t(win.open, 'پنجرهٔ «تازه چه خبر؟» خودش باز می‌شود');
  t(win.has, 'و خبرِ تازه داخلش است');
  t(/تازه چه خبر/.test(win.txt), 'با عنوانِ خودش');

  const bell = await p.evaluate(tag => {
    const btn = document.getElementById('bellBtnK');
    if (btn) btn.click();
    const pop = document.getElementById('bellPopK');
    return { n: NEWS.unread().length,
             inBell: pop ? pop.textContent.indexOf(tag) >= 0 : false };
  }, TAG);
  t(bell.inBell, 'و در زنگوله هم هست — همان‌جا که بقیهٔ خبرها هستند');

  const read = await p.evaluate(() => {
    const ok2 = document.querySelector('#nwBox .nw-ok');
    if (ok2) ok2.click();
    return { open: !document.getElementById('nwBox').hidden,
             unread: NEWS.unread().length,
             seen: (state.bellSeen || []).filter(k => k.indexOf('news|') === 0).length };
  });
  t(read.open === false, '«فهمیدم» می‌بنددش');
  t(read.unread === 0 && read.seen > 0,
    'و خوانده‌شده در خودِ دادهٔ کارتابل می‌نشیند — نه در مرورگر، وگرنه از دستگاهِ دوم دوباره باز می‌شد',
    'seen=' + read.seen);

  /* بارِ دوم دیگر خودش باز نمی‌شود. مکث لازم است: «فهمیدم» همان
     لحظه بالا می‌رود ولی رفتنش یک رفت‌وبرگشتِ شبکه است، و رفتن به
     صفحهٔ بعد در همان میلی‌ثانیه نیمه‌کاره قطعش می‌کند. */
  await p.waitForTimeout(1800);
  await p.goto(BASE + '/siamak/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(3200);
  const again = await p.evaluate(() => {
    const box = document.getElementById('nwBox');
    return { open: !!(box && !box.hidden), list: NEWS.list().length };
  });
  t(again.open === false, 'و دفعهٔ بعد دیگر جلوی آدم نمی‌پرد');
  t(again.list > 0, 'ولی خبر سرِ جایش هست — در زنگوله، هر وقت خواست', 'n=' + again.list);
  await p.close();
}
await b.close();

/* ---------- پاک کردن ---------- */
{
  const del = await adm('/api/admin.planer/news/' + encodeURIComponent(id), { method: 'DELETE' });
  t(del.status === 200, 'خبرِ آزمون پاک شد');
  const gone = await api('/api/kartabl/news');
  t(!(gone.data.news || []).some(x => x.id === id), 'و از کارتابل هم رفت');
}

console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
