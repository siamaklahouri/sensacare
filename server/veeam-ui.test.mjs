/* بخشِ VeeamBackup در خودِ صفحه: کارت‌ها، جدول، نشانِ رنگیِ نتیجه، و
   هشدارِ گزارشِ کهنه. سرورِ محلی را مثل server/vshare.setup.md بالا
   بیاورید و veeam.test.mjs را یک بار اجرا کنید تا کلید ساخته شود. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const PAGE = process.env.VS_PAGE || '/siamak/';
const API  = process.env.VS_API  || 'kartabl';
const USER = process.env.VS_USER || 'siamak';
const PASS = process.env.VS_PASS || 'siamaksiamak';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1440, height: 1000 } });
const errs = [];
p.on('pageerror', e => errs.push(String(e).slice(0, 200)));

await p.goto(BASE + PAGE, { waitUntil: 'networkidle' });
const login = await p.evaluate(async ({ a, w }) => {
  const r = await fetch('/api/' + a + '/login', {
    method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password: w, remember: false })
  });
  return r.status;
}, { a: API, w: PASS });
t(login === 200, 'وارد شد', String(login));
await p.goto(BASE + PAGE, { waitUntil: 'networkidle' });
await p.waitForTimeout(3000);

console.log('===== نوار کنار =====');
const btn = await p.evaluate(() => {
  const x = document.querySelector('.navbtn[data-view="veeam"]');
  return x ? { text: x.textContent.trim(), shown: !!x.offsetParent } : null;
});
t(btn && btn.shown, 'دکمهٔ VeeamBackup در نوار هست و دیده می‌شود', btn && btn.text);

await p.evaluate(() => document.querySelector('.navbtn[data-view="veeam"]').click());
await p.waitForTimeout(1500);

console.log('\n===== جدول و کارت‌ها =====');
const v = await p.evaluate(() => {
  const sec = document.getElementById('view-veeam');
  if (!sec) return { no: 'section' };
  return {
    active: sec.classList.contains('active'),
    cards: [...sec.querySelectorAll('#veeamCards .stat')].map(c =>
      c.querySelector('.lbl').textContent.trim() + '=' + c.querySelector('.val').textContent.trim()),
    rows: [...sec.querySelectorAll('#veeamBody tr')].map(tr =>
      [...tr.children].map(td => td.textContent.trim())),
    tones: [...sec.querySelectorAll('#veeamBody .vee-b')].map(x => x.className.replace('vee-b ', '')),
    when: (sec.querySelector('#veeamWhen') || {}).textContent || '',
    note: (sec.querySelector('#veeamNote') || {}).textContent || '',
    warn: { hidden: (sec.querySelector('#veeamWarn') || {}).hidden,
            text: (sec.querySelector('#veeamWarn') || {}).textContent || '' },
    editable: sec.querySelectorAll('[contenteditable="true"]').length,
    inputs: sec.querySelectorAll('input, select, button').length
  };
});
t(v.active, 'نما باز شد');
t(v.cards && v.cards.length === 4, 'چهار کارتِ خلاصه آمدند', (v.cards || []).join(' | '));
/* تعداد را از خودِ سرور می‌پرسیم، نه از عددی که این‌جا سفت شده باشد:
   این آزمون روی هر دیتابیسی باید اجرا شود. */
const srvJobs = await p.evaluate(async a => {
  const r = await fetch('/api/' + a + '/veeam', { credentials: 'same-origin' });
  const d = await r.json();
  return ((d.report || {}).jobs || []).length;
}, API);
t(srvJobs > 0 && v.rows && v.rows.length === srvJobs,
  'جدول دقیقاً همان جاب‌های آخرین گزارش را دارد', v.rows.length + ' از ' + srvJobs);
t(v.tones && v.tones[0] === 'ok', 'نتیجهٔ موفق، نشانِ سبز گرفت', (v.tones || []).join(','));
t(/آخرین گزارش/.test(v.when), 'زمانِ آخرین گزارش نوشته شده', v.when);
t(v.rows && v.rows[0] && v.rows[0].includes('متوقف'),
  'وضعیتِ جاب فارسی شد، ولی نامِ جاب و نوعش دست نخوردند — آن‌ها نامِ خودِ Veeam‌اند',
  v.rows && v.rows[0] ? v.rows[0].join(' | ') : '');
t(v.editable === 0 && v.inputs === 0,
  'هیچ خانه‌ای نوشتنی نیست و هیچ دکمه‌ای ندارد — این بخش آینه است، نه دفتر',
  'editable=' + v.editable + ' inputs=' + v.inputs);

console.log('\n===== گزارشِ کهنه =====');
/* زمانِ گزارش را دو ساعت عقب می‌بریم و از نو می‌کشیم: باید هشدار بدهد،
   چون سبزِ دو ساعت پیش، سبزِ الان نیست. */
const stale = await p.evaluate(() => {
  VEEAM.at = Date.now() - 2 * 3600 * 1000;
  renderVeeam();
  const w = document.getElementById('veeamWarn');
  return { hidden: w.hidden, text: w.textContent.trim().slice(0, 60), cls: w.className };
});
t(!stale.hidden && /دقیقه پیش آمده/.test(stale.text), 'هشدارِ کهنگی آمد', stale.text);

console.log('\n===== خطای اسکریپت =====');
const werr = await p.evaluate(() => {
  VEEAM.at = Date.now();
  VEEAM.error = 'The remote server returned an error: (401) Unauthorized.';
  renderVeeam();
  const w = document.getElementById('veeamWarn');
  return { hidden: w.hidden, cls: w.className, text: w.textContent.trim().slice(0, 80) };
});
t(!werr.hidden && /bad/.test(werr.cls) && /نرسید/.test(werr.text),
  'وقتی اسکریپت به Veeam نرسیده، قرمز می‌گوید', werr.text);

console.log('\n===== بی‌گزارش =====');
const none = await p.evaluate(() => {
  VEEAM = null; renderVeeam();
  const w = document.getElementById('veeamWarn');
  return { rows: document.querySelectorAll('#veeamBody tr').length,
           warn: w.textContent.trim().slice(0, 50), hidden: w.hidden };
});
t(!none.hidden && /هنوز هیچ گزارشی/.test(none.warn), 'وقتی هیچ گزارشی نیست، همین را می‌گوید', none.warn);

console.log('\n===== خطای صفحه =====');
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' // ') || '—');

await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
