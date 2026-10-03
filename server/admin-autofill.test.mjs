/* باگِ کاربر: بارِ اولِ ورود به پنل، نامِ ادمین توی کادرِ جستجو می‌افتاد.
   ریشه‌اش این بود که فرمِ ورود بعد از ورود فقط پنهان می‌شد و در صفحه
   می‌ماند؛ کروم آن را یک «فرمِ ورود» می‌دید و نامِ کاربری را توی
   نزدیک‌ترین کادرِ دیده‌شده — یعنی جستجو — می‌ریخت. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 180)));
p.on('dialog', d => d.accept());
await p.goto('http://127.0.0.1:8892/', { waitUntil: 'networkidle' });
await p.waitForTimeout(1400);

const st = await p.evaluate(() => ({
  appOpen: !document.getElementById('app').hidden,
  gateHidden: document.getElementById('gate').hidden,
  gateHtml: document.getElementById('gate').innerHTML.trim().length,
  pwInputs: document.querySelectorAll('input[type="password"]').length,
  pwArmed: document.querySelectorAll('input[type="password"][data-lpignore]').length,
  gatePw: document.querySelectorAll('#gate input[type="password"]').length,
  userInput: !!document.getElementById('gateUser'),
  findVal: document.getElementById('find').value,
  findAttrs: ['autocomplete','data-lpignore','data-1p-ignore','data-form-type']
    .map(a => a + '=' + (document.getElementById('find').getAttribute(a) ?? '—')).join(' ')
}));
t(st.appOpen && st.gateHidden, 'پنل باز شد و فرمِ ورود رفت');
t(st.gateHtml === 0, 'فرمِ ورود از صفحه برداشته شد، نه فقط پنهان', st.gateHtml + ' نویسه مانده');
t(st.gatePw === 0, 'کادرِ رمزِ فرمِ ورود رفته', st.gatePw + ' کادر');
t(st.pwArmed === st.pwInputs, 'و کادرهای رمزِ دیگر همه زره دارند',
  st.pwArmed + '/' + st.pwInputs);
t(!st.userInput, 'و کادرِ نام کاربری هم نیست');
t(st.findVal === '', 'کادرِ جستجو خالی است', JSON.stringify(st.findVal));
console.log('     زرهِ جستجو: ' + st.findAttrs);

/* حالا تکمیلِ خودکارِ مرورگر را شبیه‌سازی می‌کنیم: مقدار از بیرون
   گذاشته می‌شود، بی‌آنکه کاربر تایپ کرده باشد. */
await p.evaluate(() => {
  const el = document.getElementById('find');
  el.value = 'admin';
  el.dispatchEvent(new Event('input', { bubbles: true }));   /* isTrusted=false */
});
await p.waitForTimeout(1400);
const after = await p.evaluate(() => ({
  v: document.getElementById('find').value,
  rows: document.querySelectorAll('#plannerList .pl, #plannerList > *').length
}));
t(after.v === '', 'مقداری که مرورگر ریخته باشد برداشته می‌شود', JSON.stringify(after.v));

/* دیرتر هم — مثلاً وقتی کاربر سربرگِ تنظیمات را باز کرد */
await p.waitForTimeout(2600);
await p.evaluate(() => {
  const el = document.getElementById('find');
  el.value = 'admin';
  el.dispatchEvent(new Event('input', { bubbles: true }));
});
await p.waitForTimeout(900);
t(await p.evaluate(() => document.getElementById('find').value) === '',
  'و چند ثانیه بعد هم نگهبان بیدار است',
  await p.evaluate(() => JSON.stringify(document.getElementById('find').value)));

/* ولی چیزی که خودِ کاربر تایپ کند باید بماند */
await p.click('#find');
await p.type('#find', 'رضا', { delay: 40 });
await p.waitForTimeout(1600);
t(await p.evaluate(() => document.getElementById('find').value) === 'رضا',
  'ولی تایپِ خودِ کاربر دست نمی‌خورد',
  await p.evaluate(() => JSON.stringify(document.getElementById('find').value)));

/* و بعد از آن، نگهبان دیگر دخالت نمی‌کند */
await p.evaluate(() => { const el = document.getElementById('find'); el.blur(); });
await p.waitForTimeout(1200);
t(await p.evaluate(() => document.getElementById('find').value) === 'رضا',
  'حتی وقتی فوکوس برود');

t(errs.length === 0, 'بی‌خطا', errs[0] || 'بی‌خطا');
console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
