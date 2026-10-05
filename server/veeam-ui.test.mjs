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

/* گزارشِ نمونه را خودِ این آزمون می‌فرستد. تا دیروز به گزارشی تکیه
   می‌کرد که آزمونِ دیگری جا گذاشته بود، و هر بار که آن یکی اول اجرا
   می‌شد این یکی می‌افتاد — ایرادِ آزمون، نه ایرادِ کد. */
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const SLUG  = process.env.VS_SLUG || 'siamak';
{
  let ck = '';
  const call = async (path, opt) => {
    const o = Object.assign({ headers: {} }, opt || {});
    o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
    const r = await fetch(BASE + path, o);
    const sc = r.headers.getSetCookie ? r.headers.getSetCookie() : [];
    for (const c of sc) {
      const kv = c.split(';')[0], k = kv.split('=')[0];
      ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
    }
    try { return await r.json(); } catch (e) { return {}; }
  };
  await call('/api/admin.planer/signin',
    { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
  const k = await call('/api/admin.planer/planners/' + SLUG + '/veeam-key', { method: 'POST', body: '{}' });
  await fetch(BASE + '/api/' + API + '/veeam/push', {
    method: 'POST', headers: { 'Content-Type': 'application/json', 'x-veeam-key': k.key },
    body: JSON.stringify({
      host: 'veeam01.ehya.local', agent: 'veeam-push.ps1 / SRV-MGMT',
      jobs: [
        { name: 'Daily-VMs', type: 'Backup', result: 'Success', state: 'Stopped',
          last: '2026-10-05 02:00', next: '2026-10-06 02:00', objects: '14' },
        { name: 'SQL-Hourly', type: 'Backup', result: 'Warning', state: 'Working',
          last: '2026-10-05 17:00', next: '2026-10-05 18:00', objects: '3' },
        { name: 'Archive-to-Tape', type: 'BackupCopy', result: 'Failed', state: 'Stopped',
          last: '2026-10-04 23:00', next: '', objects: '58' }
      ],
      repos: [
        { name: 'Main-NAS', type: 'WinLocal', capacity: '20480', free: '6150', used: '14330', pct: '70' },
        { name: 'Archive-SAN', type: 'LinuxLocal', capacity: '51200', free: '2600', used: '48600', pct: '95' },
        { name: 'Cloud-Tier', type: 'ObjectStorage', capacity: '10240', free: '8900', used: '1340', pct: '13' }
      ],
      sessions: [
        { name: 'Daily-VMs', type: 'Backup', result: 'Success', state: 'Stopped',
          start: '2026-10-05 02:00', end: '2026-10-05 02:47', mins: '47' },
        { name: 'SQL-Hourly', type: 'Backup', result: 'Warning', state: 'Stopped',
          start: '2026-10-05 17:00', end: '2026-10-05 17:06', mins: '6' },
        { name: 'Archive-to-Tape', type: 'BackupCopy', result: 'Failed', state: 'Stopped',
          start: '2026-10-04 23:00', end: '2026-10-04 23:12', mins: '12' }
      ]
    })
  });
}

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
t(v.cards && v.cards.length >= 4, 'کارت‌های خلاصه آمدند', (v.cards || []).join(' | '));
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

console.log('\n===== مخزن‌ها و اجراهای اخیر =====');
const extra = await p.evaluate(() => {
  const sec = document.getElementById('view-veeam');
  const repoRows = [...sec.querySelectorAll('#veeamRepoBody tr')].map(tr =>
    [...tr.children].map(td => td.textContent.trim()));
  return {
    cards: [...sec.querySelectorAll('#veeamCards .stat')].map(c =>
      c.querySelector('.lbl').textContent.trim() + '=' + c.querySelector('.val').textContent.trim()),
    repoShown: !document.getElementById('veeamRepoPanel').hidden,
    repoRows,
    bars: [...sec.querySelectorAll('#veeamRepoBody .vee-bar')].map(x => x.className.replace('vee-bar', '').trim() || 'ok'),
    widths: [...sec.querySelectorAll('#veeamRepoBody .fil')].map(x => x.style.width),
    repoHint: (document.getElementById('veeamRepoHint') || {}).textContent || '',
    sessShown: !document.getElementById('veeamSessPanel').hidden,
    sessRows: document.querySelectorAll('#veeamSessBody tr').length,
    sessHint: (document.getElementById('veeamSessHint') || {}).textContent || '',
    sessTones: [...sec.querySelectorAll('#veeamSessBody .vee-b')].map(x => x.className.replace('vee-b ', ''))
  };
});
t(extra.repoShown && extra.repoRows.length === 3, 'جدولِ مخزن‌ها آمد', String(extra.repoRows.length));
t(extra.bars.join(',') === 'ok,bad,ok', 'مخزنِ ۹۵٪ قرمز شد و بقیه نه', extra.bars.join(','));
t(extra.widths.join(',') === '70%,95%,13%', 'نوارِ پُری به اندازهٔ درصدِ واقعی است', extra.widths.join(','));
t(/۹۰/.test(extra.repoHint), 'و بالای جدول هشدار می‌دهد', extra.repoHint);
/* نوار باید واقعاً دیده شود. عرضِ درست در style کافی نیست: span به‌طور
   پیش‌فرض inline است و روی inline نه عرض اثر دارد نه ارتفاع. */
const bar = await p.evaluate(() => {
  const f = document.querySelector('#veeamRepoBody .fil');
  const r = f.getBoundingClientRect();
  return { w: Math.round(r.width), h: Math.round(r.height), bg: getComputedStyle(f).backgroundColor };
});
t(bar.w > 10 && bar.h > 0, 'و روی صفحه هم واقعاً رسم شده، نه فقط در style',
  bar.w + '×' + bar.h + ' ' + bar.bg);
t(extra.cards.some(c => /فضای کل/.test(c)) && extra.cards.some(c => /پرترین مخزن/.test(c)),
  'کارت‌های فضا هم آمدند', extra.cards.join(' | '));
t(extra.sessShown && extra.sessRows === 3, 'جدولِ اجراهای اخیر آمد', String(extra.sessRows));
t(extra.sessTones.join(',') === 'ok,warn,bad', 'نتیجهٔ هر اجرا نشانِ خودش را گرفت', extra.sessTones.join(','));
t(/ناموفق/.test(extra.sessHint), 'و شمارِ اجراهای ناموفق بالای جدول است', extra.sessHint);

/* گزارشی که مخزن ندارد (بیلدِ قدیمی‌تر) نباید جدولِ خالی نشان بدهد */
const bare = await p.evaluate(() => {
  const keepR = VEEAM.repos, keepS = VEEAM.sessions;
  VEEAM.repos = []; VEEAM.sessions = [];
  renderVeeam();
  const out = { r: document.getElementById('veeamRepoPanel').hidden,
                s: document.getElementById('veeamSessPanel').hidden };
  VEEAM.repos = keepR; VEEAM.sessions = keepS; renderVeeam();
  return out;
});
t(bare.r && bare.s, 'بی‌داده، پانل‌ها اصلاً نشان داده نمی‌شوند — نه خالی');

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
