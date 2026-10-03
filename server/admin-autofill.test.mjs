/* اصلاحِ قبلی را نمی‌شد سنجید چون آزمون هیچ‌وقت «پر کردنِ خودکار» را
   بازنمی‌ساخت. این‌جا دقیقاً همان کار را می‌کنیم: بعد از باز شدنِ پنل،
   یک مقدار از بیرون داخلِ کادرِ جستجو می‌ریزیم و همان رویدادهایی را
   می‌فرستیم که کروم می‌فرستد — focus و input، هر دو «معتبر». */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 180)));
p.on('dialog', d => d.accept());
await p.goto('http://127.0.0.1:8892/', { waitUntil: 'networkidle' });
await p.waitForTimeout(1200);
await p.evaluate(() => { const g = document.getElementById('gate'); if (g) { g.hidden = true; g.innerHTML = ''; }
  const a = document.getElementById('app'); if (a) a.hidden = false;
  if (typeof scrubFind === 'function') scrubFind(); });
await p.waitForTimeout(400);
t(await p.evaluate(() => !!document.getElementById('find')), 'کادرِ جستجو هست');

/* --- شبیه‌سازیِ پر کردنِ خودکار: کروم فوکوس می‌کند، مقدار می‌گذارد،
       و input معتبر می‌فرستد --- */
const fill = async (val) => p.evaluate(v => {
  const el = document.getElementById('find');
  el.focus();                                   /* کروم خودش فوکوس می‌کند */
  el.dispatchEvent(new FocusEvent('focus'));
  el.value = v;
  el.dispatchEvent(new Event('input', { bubbles: true }));   /* کروم input می‌فرستد */
  return el.value;
}, val);

await fill('ادمین');
await p.waitForTimeout(500);
t(await p.evaluate(() => document.getElementById('find').value) === '',
  'مقداری که مرورگر ریخت برداشته شد', JSON.stringify(await p.evaluate(() => document.getElementById('find').value)));

/* باز هم، چند ثانیه بعد — کروم گاهی دیرتر پر می‌کند */
await fill('ادمین');
await p.waitForTimeout(1200);
t(await p.evaluate(() => document.getElementById('find').value) === '',
  'بارِ دوم هم، چند ثانیه بعد از باز شدنِ پنل', JSON.stringify(await p.evaluate(() => document.getElementById('find').value)));

/* فهرست نباید با فیلترِ جعلی خالی مانده باشد */
t(await p.evaluate(() => typeof findText === 'undefined' || findText === ''), 'فیلترِ فهرست هم پاک شد');

/* --- ولی تایپِ خودِ کاربر باید دست‌نخورده بماند --- */
const h = await p.$('#find');
await h.click();
await h.type('سیامک', { delay: 40 });
await p.waitForTimeout(1400);
t(await p.evaluate(() => document.getElementById('find').value) === 'سیامک',
  'تایپِ خودِ کاربر دست نمی‌خورد', JSON.stringify(await p.evaluate(() => document.getElementById('find').value)));

/* و بعد از آن، نگهبان دیگر دخالت نمی‌کند */
await p.waitForTimeout(1200);
t(await p.evaluate(() => document.getElementById('find').value) === 'سیامک', 'و چند ثانیه بعد هم هنوز هست');

/* پاک کردنِ دستیِ کاربر هم نباید چیزی را خراب کند */
await h.fill('');
await h.type('رضا', { delay: 40 });
await p.waitForTimeout(800);
t(await p.evaluate(() => document.getElementById('find').value) === 'رضا', 'جستجوی دوم هم کار می‌کند');

/* --- لنگرِ نام کاربری کنارِ کادرهای رمزِ داخلِ پنل --- */
const anc = await p.evaluate(() => {
  const pw = [...document.querySelectorAll('#app input[type=password]')];
  const withAnchor = pw.filter(x => { const prev = x.previousElementSibling;
    return prev && prev.classList.contains('u-anchor'); });
  return { pw: pw.length, anchored: withAnchor.length,
           hidden: [...document.querySelectorAll('.u-anchor')].every(a => a.getBoundingClientRect().width <= 2) };
});
t(anc.anchored === anc.pw, 'هر کادرِ رمزِ پنل لنگرِ نام کاربری دارد', anc.anchored + ' از ' + anc.pw);
t(anc.hidden, 'و لنگرها دیده نمی‌شوند');

/* صفحه را از نو باز می‌کنیم: بالاتر کاربر تایپ کرد و نگهبان — درست —
   برای همیشه کنار رفت. حالتِ زیر باید روی صفحهٔ دست‌نخورده سنجیده شود. */
await p.reload({ waitUntil: 'networkidle' });
await p.waitForTimeout(1000);
await p.evaluate(() => { const g = document.getElementById('gate'); if (g) { g.hidden = true; g.innerHTML = ''; }
  document.getElementById('app').hidden = false;
  if (typeof scrubFind === 'function') scrubFind(); });
await p.waitForTimeout(300);

/* --- حالتی که دو اصلاحِ قبلی را شکست داد ---
   کروم مقداری را که خودش پر کرده تا پیش از دخالتِ کاربر به اسکریپت
   نشان نمی‌دهد: روی صفحه دیده می‌شود، ولی el.value برای کد "" است.
   اینجا همان را می‌سازیم — مقدار را طوری می‌گذاریم که getter اش "" بدهد
   ولی کادر :-webkit-autofill به حساب بیاید. */
await p.evaluate(() => {
  const el = document.getElementById('find');
  window.__shown = 'ادمین';
  /* getter را موقتاً عوض می‌کنیم تا دقیقاً مثل کروم رفتار کند */
  const proto = Object.getPrototypeOf(el);
  const d = Object.getOwnPropertyDescriptor(proto, 'value');
  let hidden = true;
  Object.defineProperty(el, 'value', {
    configurable: true,
    get(){ return hidden ? '' : d.get.call(this); },
    set(v){ hidden = false; d.set.call(this, v); }
  });
  /* و کادر را «پرشده با مرورگر» اعلام می‌کنیم */
  el.matches = (sel => function(q){
    if(q === ':autofill' || q === ':-webkit-autofill') return hidden;
    return sel.call(this, q);
  })(el.matches);
});
await p.waitForTimeout(900);
t(await p.evaluate(() => { const el = document.getElementById('find');
  return el.value === '' && !el.matches(':-webkit-autofill'); }),
  'مقداری که مرورگر پنهان نگه داشته هم پاک شد');

/* کادر تا پیش از دستِ کاربر readonly است، پس کروم اصلاً پُرش نمی‌کند */
await p.reload({ waitUntil: 'networkidle' });
await p.waitForTimeout(1000);
await p.evaluate(() => { const g = document.getElementById('gate'); if (g) { g.hidden = true; g.innerHTML = ''; }
  document.getElementById('app').hidden = false;
  if (typeof scrubFind === 'function') scrubFind(); });
await p.waitForTimeout(400);
t(await p.evaluate(() => document.getElementById('find').readOnly),
  'تا پیش از دستِ کاربر کادر readonly است (کروم readonly را پر نمی‌کند)');
const fh = await p.$('#find');
await fh.click();
await p.waitForTimeout(200);
t(!await p.evaluate(() => document.getElementById('find').readOnly),
  'و با اولین کلیکِ کاربر آزاد می‌شود');
await fh.type('مهدی', { delay: 40 });
await p.waitForTimeout(900);
t(await p.evaluate(() => document.getElementById('find').value) === 'مهدی',
  'و کاربر بی‌دردسر تایپ می‌کند', JSON.stringify(await p.evaluate(() => document.getElementById('find').value)));

t(errs.length === 0, 'بی‌خطا', errs[0] || 'بی‌خطا');
console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
