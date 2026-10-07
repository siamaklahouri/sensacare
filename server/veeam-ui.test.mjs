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
  /* رمز را خودمان می‌گذاریم، وگرنه این آزمون به ترتیبِ اجرا بند می‌شود:
     آزمونِ پوسته رمزِ همهٔ کارتابل‌ها را عوض می‌کند. */
  await call('/api/admin.planer/planners/' + SLUG + '/password',
    { method: 'POST', body: JSON.stringify({ password: PASS }) });
  const k = await call('/api/admin.planer/planners/' + SLUG + '/veeam-key', { method: 'POST', body: '{}' });
  await fetch(BASE + '/api/' + API + '/veeam/push', {
    method: 'POST', headers: { 'Content-Type': 'application/json', 'x-veeam-key': k.key },
    body: JSON.stringify({
      host: 'veeam01.ehya.local', agent: 'veeam-push.ps1 / SRV-MGMT',
      jobs: [
        /* جابِ اول: ماشین دارد، پیام ندارد. جابِ دوم: پیام دارد، ماشین
           ندارد (بیلدی که فهرست نمی‌دهد). جابِ سوم: هر دو. جابِ چهارم:
           هیچ‌کدام — و باید کلیک‌پذیر هم نباشد. */
        { name: 'Daily-VMs', type: 'Backup', result: 'Success', state: 'Stopped',
          last: '2026-10-05 02:00', next: '2026-10-06 02:00', objects: '14',
          vms: ['SRV-DC01', 'SRV-FILE02', 'APP-ERP'] },
        { name: 'SQL-Hourly', type: 'Backup', result: 'Warning', state: 'Working',
          last: '2026-10-05 17:00', next: '2026-10-05 18:00', objects: '3',
          message: 'Unable to truncate transaction logs' },
        { name: 'Archive-to-Tape', type: 'BackupCopy', result: 'Failed', state: 'Stopped',
          last: '2026-10-04 23:00', next: '', objects: '58',
          message: 'Error: Tape device is offline.\nRetry in 30 minutes.',
          vms: ['SRV-DC01'] },
        { name: 'Tape-Weekly', type: 'BackupCopy', result: 'Success', state: 'Stopped',
          last: '2026-10-03 23:00', next: '', objects: '' }
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
          start: '2026-10-04 23:00', end: '2026-10-04 23:12', mins: '12',
          message: 'Error: Tape device is offline.' }
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
    /* دکمهٔ بستنِ پنجرهٔ جزئیات حساب نمی‌شود: آن یکی چیزی نمی‌نویسد،
       فقط پنجره‌ای را که خودِ کاربر باز کرده می‌بندد. مقصودِ این سنجه
       این است که در این بخش هیچ راهی برای نوشتن یا افزودن نباشد. */
    inputs: [...sec.querySelectorAll('input, select, button')]
      .filter(el => !el.closest('.vpop')).length
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

console.log('\n===== پنجرهٔ پیام و ماشین‌ها =====');
/* آن‌چه سرور نگه داشته. اگر مسیرِ push این دو کلید را بیندازد، همه‌چیزِ
   بعدی هم می‌افتد — پس اول خودِ داده. */
const kept = await p.evaluate(async a => {
  const r = await fetch('/api/' + a + '/veeam', { credentials: 'same-origin' });
  const d = await r.json();
  const j = (d.report || {}).jobs || [];
  const s = (d.report || {}).sessions || [];
  return { msg: (j[2] || {}).message || '', vms: (j[0] || {}).vms || [],
           smsg: (s[2] || {}).message || '' };
}, API);
t(/Tape device is offline/.test(kept.msg), 'سرور پیامِ جاب را نگه داشت', kept.msg.slice(0, 40));
t(kept.vms.length === 3 && kept.vms[0] === 'SRV-DC01', 'و فهرستِ ماشین‌ها را', kept.vms.join(','));
t(/Tape device is offline/.test(kept.smsg), 'و پیامِ اجرا را هم', kept.smsg.slice(0, 40));

const rows = await p.evaluate(() => [...document.querySelectorAll('#veeamBody tr')].map(tr => ({
  cls: tr.className, vi: tr.getAttribute('data-vi'), vp: tr.getAttribute('data-vp'),
  i: !!tr.querySelector('.vee-i'), cur: getComputedStyle(tr).cursor
})));
t(rows.length === 4 && rows.slice(0, 3).every(r => /vee-click/.test(r.cls)),
  'سه ردیفِ اول کلیک‌پذیرند', rows.map(r => r.cls || '-').join(' | '));
t(!/vee-click/.test(rows[3].cls) && !rows[3].i,
  'ردیفی که نه پیام دارد نه ماشین، کلیک‌پذیر نیست و نشانه هم ندارد — نشانگرِ دست روی ردیفی که ' +
  'هیچ پنجره‌ای باز نمی‌کند، خودش یک دروغِ کوچک است');
t(rows[0].cur === 'pointer', 'و نشانگر روی ردیفِ کلیک‌پذیر دست است', rows[0].cur);

/* زدنِ ردیفِ ناموفق: پنجره باید باز شود، وسطِ صفحه بنشیند، و متنِ
   خودِ Veeam را دست‌نخورده نشان بدهد. */
const popped = await p.evaluate(() => {
  document.querySelectorAll('#veeamBody tr')[2].click();
  const pop = document.getElementById('veeamPop');
  const card = pop.querySelector('.vpop-card');
  const cr = card.getBoundingClientRect();
  const msg = pop.querySelector('.vpop-msg');
  return {
    shown: !pop.hidden,
    name: document.getElementById('veeamPopName').textContent.trim(),
    meta: document.getElementById('veeamPopMeta').textContent.trim(),
    msg: msg ? msg.textContent : '',
    msgCls: msg ? msg.className : '',
    pre: msg ? getComputedStyle(msg).whiteSpace : '',
    vms: [...pop.querySelectorAll('.vpop-vms span')].map(x => x.textContent.trim()),
    subs: [...pop.querySelectorAll('.vpop-sub')].map(x => x.textContent.trim()),
    dx: Math.round((cr.left + cr.width / 2) - innerWidth / 2),
    dy: Math.round((cr.top + cr.height / 2) - innerHeight / 2),
    w: Math.round(cr.width), h: Math.round(cr.height),
    fixed: getComputedStyle(pop).position
  };
});
t(popped.shown && popped.name === 'Archive-to-Tape', 'با زدنِ ردیف، پنجره باز شد', popped.name);
/* وسطِ صفحه بودن، خواستهٔ خودش بود. با چشم نمی‌سنجیم: مرکزِ کارت باید
   روی مرکزِ پنجرهٔ مرورگر بیفتد. */
t(Math.abs(popped.dx) <= 2 && Math.abs(popped.dy) <= 2,
  'و دقیقاً وسطِ صفحه نشسته', 'dx=' + popped.dx + ' dy=' + popped.dy + ' ' + popped.w + '×' + popped.h);
t(popped.fixed === 'fixed' && popped.w > 300 && popped.h > 100, 'و کارتش واقعاً رسم شده',
  popped.fixed + ' ' + popped.w + '×' + popped.h);
t(/Tape device is offline/.test(popped.msg) && /Retry in 30 minutes/.test(popped.msg),
  'هر دو خطِ پیامِ Veeam داخلش است', popped.msg.replace(/\n/g, ' / ').slice(0, 60));
t(/pre-wrap/.test(popped.pre), 'و شکستِ خطِ خودِ Veeam حفظ شده، نه چسبیده به هم', popped.pre);
t(/bad/.test(popped.msgCls), 'پیامِ جابِ ناموفق قرمز است', popped.msgCls);
t(popped.vms.join(',') === 'SRV-DC01', 'ماشین‌های همان جاب را نشان می‌دهد', popped.vms.join(','));
t(popped.subs.length === 2 && /ماشین/.test(popped.subs[1]), 'دو بخش دارد: پیام و ماشین‌ها',
  popped.subs.join(' | '));

/* ردیفِ اول پیام ندارد ولی سه ماشین دارد: باید همان را بگوید و
   فهرست را نشان بدهد — نه پنجرهٔ خالی. */
const first = await p.evaluate(() => {
  document.getElementById('veeamPop').hidden = true;
  document.querySelectorAll('#veeamBody tr')[0].click();
  const pop = document.getElementById('veeamPop');
  return { shown: !pop.hidden,
           msg: !!pop.querySelector('.vpop-msg'),
           empty: (pop.querySelector('.vpop-empty') || {}).textContent || '',
           vms: [...pop.querySelectorAll('.vpop-vms span')].map(x => x.textContent.trim()) };
});
t(first.shown && !first.msg && /پیامی ننوشته/.test(first.empty),
  'جابی که پیام ندارد، همین را می‌گوید', first.empty.slice(0, 40));
t(first.vms.join(',') === 'SRV-DC01,SRV-FILE02,APP-ERP', 'و هر سه ماشینش را می‌شمارد', first.vms.join(','));

/* بستن: هم با Escape، هم با زدنِ زمینهٔ تاریک — ولی زدنِ خودِ کارت
   نباید ببندد، وگرنه کسی که می‌خواهد متن را انتخاب کند پنجره‌اش بسته
   می‌شود. */
await p.keyboard.press('Escape');
await p.waitForTimeout(150);
t(await p.evaluate(() => document.getElementById('veeamPop').hidden), 'Escape می‌بندد');
const back = await p.evaluate(() => {
  document.querySelectorAll('#veeamBody tr')[0].click();
  const pop = document.getElementById('veeamPop');
  pop.querySelector('.vpop-card').click();
  const afterCard = !pop.hidden;
  pop.click();
  return { afterCard, afterBack: pop.hidden };
});
t(back.afterCard, 'زدن روی خودِ کارت نمی‌بندد');
t(back.afterBack, 'زدن روی زمینهٔ تاریک می‌بندد');

/* اجرای اخیر هم همین‌طور — ولی بی‌فهرستِ ماشین: اجرا، اجرایِ همان جاب
   است و فهرستش همان فهرست؛ دو بار نشان دادنش تکرار بود. */
const ss = await p.evaluate(() => {
  document.getElementById('veeamPop').hidden = true;
  const trs = [...document.querySelectorAll('#veeamSessBody tr')];
  const clickable = trs.map(tr => /vee-click/.test(tr.className));
  trs[2].click();
  const pop = document.getElementById('veeamPop');
  return { clickable, shown: !pop.hidden,
           name: document.getElementById('veeamPopName').textContent.trim(),
           msg: (pop.querySelector('.vpop-msg') || {}).textContent || '',
           meta: document.getElementById('veeamPopMeta').textContent,
           subs: [...pop.querySelectorAll('.vpop-sub')].map(x => x.textContent.trim()) };
});
t(ss.clickable.join(',') === 'false,false,true',
  'در اجراهای اخیر فقط همان اجرایی که پیام دارد کلیک‌پذیر است', ss.clickable.join(','));
t(ss.shown && /Tape device is offline/.test(ss.msg), 'و پیامش را نشان می‌دهد', ss.name);
t(ss.subs.length === 1, 'برای اجرا بخشِ ماشین‌ها نمی‌آید', ss.subs.join(' | '));
t(/مدت/.test(ss.meta) && /دقیقه/.test(ss.meta), 'و مدتِ اجرا بالای پیام نوشته شده',
  ss.meta.replace(/\s+/g, ' ').slice(0, 70));

await p.evaluate(() => { document.getElementById('veeamPop').hidden = true; });

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
