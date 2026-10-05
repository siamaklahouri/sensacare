/* کادرِ جستجوی پنل ادمین برداشته شد.

   سه بار برای نگه‌داشتنش جنگیدیم و هر بار کروم از راهِ دیگری رمزِ
   ذخیره‌شدهٔ دامنه را داخلش ریخت: اول چون فرمِ ورود در صفحه می‌ماند،
   بعد چون نگهبان با رویدادهای «معتبر» خودش را خاموش می‌کرد، و آخر
   چون کروم مقدارِ پرشده را تا پیش از دستِ کاربر به اسکریپت نشان
   نمی‌دهد. راهِ چهارم نرفتیم: کاربر گفت کادر را بردار.

   این آزمون همان را نگه می‌دارد — نه خودِ کادر برگردد، نه بقایای
   سازوکارش، و فهرست بی‌آن درست کار کند. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 180)));
p.on('dialog', d => d.accept());
await p.goto('http://127.0.0.1:8892/', { waitUntil: 'networkidle' });
await p.waitForTimeout(1200);
await p.evaluate(() => {
  const g = document.getElementById('gate'); if (g) { g.hidden = true; g.innerHTML = ''; }
  document.getElementById('app').hidden = false;
  DATA = { items: [
      { slug:'siamak', name:'سیامک', closed:false, hasEscrow:true,  job:'it', user:'s.lahouri', until:Date.now()+9e9 },
      { slug:'reza',   name:'رضا',   closed:true,  hasEscrow:false, job:'it', user:'reza',      until:Date.now()-9e8 }],
    jobs: [{ id:'it', label:'مدیر IT' }], kinds: [], escrowReady: true, features: [], views: {} };
  renderPlanners();
});
await p.waitForTimeout(600);

t(await p.evaluate(() => !document.getElementById('find')), 'کادرِ جستجو در صفحه نیست');
t(await p.evaluate(() => document.querySelectorAll('.u-anchor').length === 0),
  'لنگرهای نام کاربری هم رفتند (فقط برای همان کادر بودند)');
t(await p.evaluate(() => typeof scrubFind === 'undefined' && typeof findText === 'undefined'),
  'سازوکارِ نگهبان هم باقی نمانده');

/* هیچ کادرِ متنیِ بی‌دفاعی نماند که کروم نامِ کاربری را داخلش بریزد:
   هر کادرِ متنیِ دیده‌شده یا عدد است یا نقشِ روشنی دارد. */
const loose = await p.evaluate(() => [...document.querySelectorAll('#app input')]
  .filter(i => i.offsetParent !== null && /^(text|search|email)$/i.test(i.type))
  .map(i => i.id || i.className || '?'));
t(true, 'کادرهای متنیِ باز در پنل', loose.length ? loose.join('، ') : 'هیچ');

/* و فهرست بی‌کادرِ جستجو درست کار می‌کند */
const st = await p.evaluate(() => ({
  cards: document.querySelectorAll('#plist .pcard').length,
  count: (document.getElementById('plistCount') || {}).textContent || '',
  tiles: document.querySelectorAll('#stats .stat').length }));
t(st.cards === 2, 'هر دو کارتابل در فهرست آمدند', st.cards + ' کارت');
t(/۲/.test(st.count), 'شمارنده شمارِ درست را نشان می‌دهد', JSON.stringify(st.count));
t(st.tiles === 4, 'چهار کاشیِ بالا سرِ جایشان‌اند', st.tiles + ' کاشی');

/* فهرستِ خالی هم باید پیامِ درست بدهد، نه پیامِ «چیزی پیدا نشد» */
await p.evaluate(() => { DATA.items = []; renderPlanners(); });
await p.waitForTimeout(300);
const empty = await p.evaluate(() => (document.getElementById('plist').textContent || '').trim());
t(empty.includes('هنوز کارتابلی نیست'), 'فهرستِ خالی پیامِ درست می‌دهد', empty.slice(0, 50));
t(!empty.includes('پیدا نشد'), 'و پیامِ جست‌وجو دیگر جایی نمانده');

t(errs.length === 0, 'بی‌خطا', errs[0] || 'بی‌خطا');
console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
