/* پینگِ دستگاه‌ها.

   مرورگر نمی‌تواند پینگ بگیرد — ICMP در جاوااسکریپتِ صفحه نیست و
   fetch به یک آی‌پیِ بی‌وب‌سرور فقط «خطای شبکه» می‌دهد که از
   «خاموش است» قابلِ تشخیص نیست. پس سرور این کار را می‌کند، و
   چون نشانی از کاربر می‌آید، دو چیز سنجیده می‌شود:

   • نشانی با الگوی سخت پالوده شود. این رشته به خطِ فرمان می‌رود.
   • پورت که داده شود، بررسی TCP باشد نه ICMP: دستگاهِ حضور و غیاب
     روی ۴۳۷۰ گوش می‌دهد و خیلی از فایروال‌ها ICMP را می‌اندازند،
     یعنی دستگاهِ سالم را مُرده نشان می‌دهند. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';
import { okHost, okPort, probe, telnet } from '../src/ping.js';
import net from 'node:net';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

/* یک دستگاهِ کندگو برای آزمونِ «زنده» بودن: چهار خط، هر ۴۵۰
   میلی‌ثانیه یکی. اگر جریان تکه‌تکه نرسد و سرور تا آخر نگهش دارد،
   همه‌اش یکجا در پایان می‌آید و این آزمون می‌افتد — همان چیزی که
   «زنده» بودن را بی‌معنا می‌کند. */
const chatty = (gap, max) => net.createServer(s => {
  let n = 0;
  const tick = setInterval(() => {
    n++;
    try { s.write('خطِ ' + n + '\n'); } catch (e) { }
    if (max && n >= max) { clearInterval(tick); try { s.end(); } catch (e) { } }
  }, gap);
  s.on('close', () => clearInterval(tick));
  s.on('error', () => clearInterval(tick));
});
const slow = chatty(450, 4);          /* چهار خط و تمام */
const endless = chatty(600, 0);       /* تا خودِ کاربر نبُرد، حرف می‌زند */
await new Promise(r => slow.listen(0, '127.0.0.1', r));
await new Promise(r => endless.listen(0, '127.0.0.1', r));
const SLOW = slow.address().port, ENDLESS = endless.address().port;

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== سیم‌کشی =====');
{
  /* یک آکولادِ جاافتاده در این پرونده، کلِ شیوه‌نامهٔ صفحه را
     می‌شکند — چون همهٔ جزوها در یک <style> کنارِ هم می‌نشینند.
     یک بار همین شد و صفحه کاملاً سفید بالا آمد، بی هیچ خطایی. */
  const css = readFileSync(new URL('../public/_t/p/pingcss.tpl', import.meta.url), 'utf8');
  const open = (css.match(/\{/g) || []).length, close = (css.match(/\}/g) || []).length;
  t(open === close, 'آکولادهای شیوه‌نامه تراز است', open + ' باز، ' + close + ' بسته');
  t(!/<\/?(script|style)\b/i.test(css), 'و تگِ اضافه ندارد');
  const js = readFileSync(new URL('../public/_t/p/ping.tpl', import.meta.url), 'utf8');
  t(!/<\/?(script|style)\b/i.test(js) && !/<!--/.test(js), 'جزوِ موتور هم همین‌طور');
}

console.log('===== پالایشِ نشانی =====');
for (const h of ['8.8.8.8', '192.168.1.201', 'srv-a.local', 'device-1'])
  t(okHost(h), 'پذیرفته می‌شود: ' + h);
for (const h of ['8.8.8.8; rm -rf /', '$(id)', 'a b', '', '../x', 'a'.repeat(200), '`whoami`'])
  t(!okHost(h), 'پذیرفته نمی‌شود: ' + JSON.stringify(h.slice(0, 22)));
t(okPort(4370) && okPort(1) && okPort(65535), 'پورتِ درست پذیرفته می‌شود');
t(!okPort(0) && !okPort(70000) && !okPort('x'), 'و پورتِ نادرست نه');

console.log('===== بررسیِ واقعی =====');
{
  const up = await probe('127.0.0.1', PORT, 2500);
  t(up.ok === true && up.how === 'tcp', 'پورتِ باز «زنده» می‌دهد',
    JSON.stringify(up));
  const down = await probe('127.0.0.1', 9, 1200);
  t(down.ok === false, 'و پورتِ بسته نه', JSON.stringify(down));
  t(/پورت بسته/.test(down.error), 'با پیامی که فرقِ «نرسیدن» و «بسته بودن» را می‌گوید',
    down.error);
  const nope = await probe('8.8.8.8; rm -rf /', 80, 500);
  t(nope.ok === false && /نشانی/.test(nope.error), 'و نشانیِ آلوده اصلاً اجرا نمی‌شود',
    nope.error);
}

console.log('===== تلنت =====');
{
  /* «telnet IP PORT» یعنی وصل شو و ببین آن‌طرف چه می‌گوید. */
  const r = await telnet('127.0.0.1', Number(PORT), 'GET / HTTP/1.0', 2500);
  t(r.ok && /^HTTP\/1/.test(r.text), 'جوابِ دستگاه را برمی‌گرداند',
    (r.text || '').split('\n')[0].trim());
  t(r.bytes > 0 && r.text.length <= 2000, 'و سقفِ متن را نگه می‌دارد',
    r.bytes + ' بایت، ' + r.text.length + ' نویسه');
  const shut = await telnet('127.0.0.1', 9, '', 1200);
  t(!shut.ok && /پورت بسته/.test(shut.error), 'و پورتِ بسته را می‌گوید', shut.error);
}

console.log('===== مسیرِ سرور =====');
{
  const r = await fetch(BASE + '/api/kartabl/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ password: process.env.VS_IT_PASS || 'siamaksiamak' }) });
  const cookie = (r.headers.getSetCookie ? r.headers.getSetCookie() : [])
    .map(c => c.split(';')[0]).join('; ');
  const call = (b) => fetch(BASE + '/api/kartabl/ping', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST, cookie }, body: JSON.stringify(b) });

  const good = await call({ host: '127.0.0.1', port: Number(PORT) });
  const gj = await good.json();
  t(good.status === 200 && gj.ok === true, 'سرور پورتِ باز را زنده می‌بیند', JSON.stringify(gj));
  const evil = await call({ host: '127.0.0.1; id', port: 80 });
  t(evil.status === 400, 'و نشانیِ آلوده را رد می‌کند', evil.status + '');
  const badPort = await call({ host: '127.0.0.1', port: 999999 });
  t(badPort.status === 400, 'و پورتِ نادرست را هم', badPort.status + '');

  const tel = await fetch(BASE + '/api/kartabl/telnet', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST, cookie },
    body: JSON.stringify({ host: '127.0.0.1', port: Number(PORT), send: 'GET / HTTP/1.0' }) });
  const tj = await tel.json();
  t(tel.status === 200 && tj.ok && /HTTP/.test(tj.text || ''),
    'مسیرِ تلنت هم جواب می‌دهد', (tj.text || '').split('\n')[0].trim());
  const telBad = await fetch(BASE + '/api/kartabl/telnet', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST, cookie },
    body: JSON.stringify({ host: '127.0.0.1; id', port: 80 }) });
  t(telBad.status === 400, 'و نشانیِ آلوده را رد می‌کند', telBad.status + '');
  const telNoPort = await fetch(BASE + '/api/kartabl/telnet', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST, cookie },
    body: JSON.stringify({ host: '127.0.0.1' }) });
  t(telNoPort.status === 400, 'و بی پورت هم کاری نمی‌کند — تلنت بی پورت معنا ندارد',
    telNoPort.status + '');

  /* ---- جریانِ زنده ---- */
  const live = await fetch(BASE + '/api/kartabl/telnet/live', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST, cookie },
    body: JSON.stringify({ host: '127.0.0.1', port: SLOW, send: '' }) });
  t(live.status === 200 && /text\/plain/.test(live.headers.get('content-type') || ''),
    'مسیرِ تلنتِ زنده متنِ خام می‌دهد',
    live.status + ' ' + live.headers.get('content-type'));
  const at0 = Date.now(), parts = [];
  {
    const rd = live.body.getReader(), dec = new TextDecoder('utf-8');
    for (;;) {
      const r = await rd.read();
      if (r.done) break;
      parts.push({ at: Date.now() - at0, txt: dec.decode(r.value, { stream: true }) });
    }
  }
  const whole = parts.map(c => c.txt).join('');
  t(/وصل شد/.test((parts[0] || {}).txt || ''), 'اولین چیزی که می‌رسد «وصل شد» است',
    JSON.stringify((parts[0] || {}).txt || ''));
  t(parts.length >= 3, 'و متن تکه‌تکه می‌رسد، نه یکجا در پایان', parts.length + ' تکه');
  t(parts.length > 1 && parts[parts.length - 1].at - parts[0].at > 700,
    'یعنی واقعاً زنده است',
    'فاصلهٔ اولین و آخرین تکه ' +
      ((parts[parts.length - 1] || {}).at - (parts[0] || {}).at) + ' میلی‌ثانیه');
  t(/خطِ 1/.test(whole) && /خطِ 4/.test(whole) && /اتصال بسته شد/.test(whole),
    'و تا بسته شدنِ اتصال ادامه می‌دهد', whole.replace(/\s+/g, ' ').trim());
  const liveBad = await fetch(BASE + '/api/kartabl/telnet/live', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST, cookie },
    body: JSON.stringify({ host: '127.0.0.1; id', port: 80 }) });
  t(liveBad.status === 400, 'و نشانیِ آلوده اینجا هم رد می‌شود', liveBad.status + '');

  const anon = await fetch(BASE + '/api/kartabl/ping', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ host: '127.0.0.1', port: 80 }) });
  t(anon.status === 401 || anon.status === 403,
    'و بی ورود به کارتابل، اصلاً جواب نمی‌دهد', anon.status + '');
}

console.log('===== خودِ بخش =====');
{
  const r = await fetch(BASE + '/api/kartabl/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ password: process.env.VS_IT_PASS || 'siamaksiamak' }) });
  const ck = (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
  const b = await launch();
  const ctx = await b.newContext({ viewport: { width: 1400, height: 950 } });
  await ctx.addCookies(ck);
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + '/siamak/', { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);

  t(await p.evaluate(() => !!document.querySelector('.navbtn[data-view="ping"]')),
    'بخش در فهرستِ کناری هست');
  /* و صفحه سالم است: اگر شیوه‌نامه بشکند، همهٔ بخش‌ها هم‌زمان دیده
     می‌شوند و صفحه عملاً از کار می‌افتد — همان حالتی که یک بار با
     یک آکولادِ جاافتاده پیش آمد. */
  t(await p.evaluate(() => [...document.querySelectorAll('.content > .view')]
      .filter(v => getComputedStyle(v).display !== 'none').length) === 1,
    'و در هر لحظه فقط یک بخش دیده می‌شود');
  await p.evaluate(() => { const n = document.querySelector('.navbtn[data-view="ping"]'); if (n) n.click(); });
  await p.waitForTimeout(900);

  /* فرمِ افزودن باید زیرِ نگهبانِ پُرشدنِ خودکار باشد: کرومی که برای
     این دامنه رمز ذخیره دارد، autocomplete=off را روی کادرهایی که
     خودش «نام کاربری» حدس می‌زند نادیده می‌گیرد — و کادرِ پورت را
     «admin» می‌کرد. نشانه پیش از پُر شدنِ فرم سنجیده می‌شود، چون
     نگهبان به‌محضِ اینکه کاربر چیزی بنویسد کنار می‌رود. */
  t(await p.evaluate(() => ['pgNewName', 'pgNewHost', 'pgNewPort']
      .every(id => (document.getElementById(id) || {}).dataset.mtEmpty === '1')),
    'فرمِ افزودن زیرِ نگهبانِ پُرشدنِ خودکار است');

  const seeded = await p.evaluate(() => (state.pingHosts || []).map(x => x.host));
  t(seeded.length >= 4, 'و بارِ اول با چهار نشانی پُر می‌شود', seeded.join('، '));

  /* یکی را به خودِ همین سرور می‌بندیم تا جوابِ واقعی بگیریم */
  await p.evaluate(port => {
    state.pingHosts[0] = { name: 'سرورِ آزمون', host: '127.0.0.1', port: Number(port) };
    state.pingHosts[1] = { name: 'پورتِ بسته', host: '127.0.0.1', port: 9 };
    PING.render();
  }, PORT);
  await p.waitForTimeout(300);

  await p.evaluate(() => document.querySelectorAll('.pg-one')[0].click());
  await p.waitForTimeout(1800);
  const one = await p.evaluate(() => ({
    txt: document.querySelectorAll('#pingBody tr')[0].querySelector('.pg-state').innerText.trim(),
    dot: !!document.querySelectorAll('#pingBody tr')[0].querySelector('.pg-up'),
    when: document.querySelectorAll('#pingBody tr')[0].querySelector('.pg-when').textContent.trim()
  }));
  t(/زنده/.test(one.txt) && one.dot, 'پینگِ تکی جواب می‌دهد', one.txt);
  /* ساعت باید واقعاً ساعت باشد. یک بار تابعِ ساعت حذف شد و چون در
     صفحه گلوبالی به همان نام بود، خطایی نداد — ستون
     «[object Observable]» نشان می‌داد. */
  t(/^[۰-۹]{2}:[۰-۹]{2}:[۰-۹]{2}$/.test(one.when), 'و ساعتِ بررسی را می‌نویسد', one.when);

  await p.evaluate(() => document.getElementById('pingAllBtn').click());
  await p.waitForTimeout(6000);
  const many = await p.evaluate(() => [...document.querySelectorAll('#pingBody tr')]
    .map(tr => (tr.querySelector('.pg-state') || {}).innerText || '')
    .map(s => s.replace(/\s+/g, ' ').trim()));
  t(many.length >= 4 && many.every(s => s && !/بررسی نشده/.test(s)),
    'پینگِ گروهی همه را بررسی می‌کند', many.slice(0, 2).join(' | '));
  t(/زنده/.test(many[0]) && /پورت بسته/.test(many[1]),
    'و هر ردیف جوابِ خودش را می‌گیرد، نه یکی برای همه',
    many[0] + ' / ' + many[1]);

  /* ---- پنجرهٔ تلنت ---- */
  await p.evaluate(() => document.querySelectorAll('.pg-tel')[0].click());
  await p.waitForTimeout(400);
  const telOpen = await p.evaluate(() => {
    const e = document.querySelector('.tl-ov');
    return e && !e.hidden ? (document.querySelector('.tl-sub') || {}).textContent : '';
  });
  t(/127\.0\.0\.1:/.test(telOpen || ''), 'دکمهٔ تلنت پنجره را با همان نشانی باز می‌کند', telOpen);
  await p.fill('#tlSend', 'GET / HTTP/1.0');
  await p.evaluate(() => document.querySelector('.tl-go').click());
  await p.waitForTimeout(3000);
  const telOut = await p.evaluate(() => (document.querySelector('.tl-out') || {}).textContent || '');
  t(/HTTP\/1/.test(telOut), 'و جوابِ خامِ دستگاه را نشان می‌دهد',
    telOut.split('\n')[0].trim());
  await p.evaluate(() => document.querySelector('.tl-x').click());
  await p.waitForTimeout(300);
  t(await p.evaluate(() => !!document.querySelector('.tl-ov[hidden]')), 'و بسته می‌شود');

  /* ---- و زنده بودنش، روی صفحه ---- */
  await p.evaluate(port => {
    state.pingHosts[2] = { name: 'کندگو', host: '127.0.0.1', port: Number(port) };
    PING.render();
  }, ENDLESS);
  await p.waitForTimeout(300);
  await p.evaluate(() => document.querySelectorAll('.pg-tel')[2].click());
  await p.waitForTimeout(250);
  await p.evaluate(() => {
    document.querySelector('#tlSend').value = '';
    document.querySelector('.tl-go').click();
  });
  await p.waitForTimeout(800);
  const liveA = await p.evaluate(() => ({
    n: ((document.querySelector('.tl-out') || {}).textContent || '').length,
    btn: ((document.querySelector('.tl-go') || {}).textContent || '').trim()
  }));
  await p.waitForTimeout(1300);
  const liveB = await p.evaluate(() =>
    ((document.querySelector('.tl-out') || {}).textContent || '').length);
  t(liveA.n > 0 && liveB > liveA.n, 'متن همان‌طور که می‌رسد روی صفحه زیاد می‌شود',
    liveA.n + ' ← ' + liveB + ' نویسه');
  t(liveA.btn === 'قطع', 'و تا وصل است، دکمه «قطع» می‌شود', liveA.btn);

  await p.evaluate(() => document.querySelector('.tl-go').click());
  await p.waitForTimeout(400);
  const cut = await p.evaluate(() => ({
    txt: (document.querySelector('.tl-out') || {}).textContent || '',
    btn: ((document.querySelector('.tl-go') || {}).textContent || '').trim()
  }));
  t(/قطع شد/.test(cut.txt) && cut.btn === 'اتصال', 'و «قطع» همان‌جا می‌بُرد', cut.btn);
  const frozen = cut.txt.length;
  await p.waitForTimeout(1000);
  t(await p.evaluate(() =>
      ((document.querySelector('.tl-out') || {}).textContent || '').length) === frozen,
    'و بعدش دیگر چیزی اضافه نمی‌شود', frozen + ' نویسه');
  await p.evaluate(() => document.querySelector('.tl-x').click());
  await p.waitForTimeout(250);

  /* افزودن و حذف */
  const n0 = await p.evaluate(() => state.pingHosts.length);
  await p.fill('#pgNewName', 'دستگاهِ تازه');
  await p.fill('#pgNewHost', '10.0.0.9');
  await p.fill('#pgNewPort', '4370');
  await p.evaluate(() => document.getElementById('pgAddBtn').click());
  await p.waitForTimeout(500);
  const added = await p.evaluate(() => state.pingHosts[state.pingHosts.length - 1]);
  t(added && added.host === '10.0.0.9' && added.port === 4370,
    'نشانیِ تازه اضافه می‌شود', JSON.stringify(added));
  t(await p.evaluate(() => state.pingHosts.length) === n0 + 1, 'و به فهرست می‌نشیند');

  await p.evaluate(() => {
    const b = [...document.querySelectorAll('#pingBody [data-pg-del]')].pop();
    if (b) b.click();
  });
  await p.waitForTimeout(400);
  await p.evaluate(() => { const y = document.querySelector('.dq-yes'); if (y) y.click(); });
  await p.waitForTimeout(500);
  t(await p.evaluate(() => state.pingHosts.length) === n0,
    'و حذفش هم از همان کادرِ پرسش می‌گذرد');
  t(await p.evaluate(() => !!document.querySelector('.undo-bar:not([hidden])')),
    'و برگشتش هست');

  /* و کارت‌های بالای بخش */
  const sum = await p.evaluate(() => (document.getElementById('pingCards') || {}).innerText || '');
  t(/زنده/.test(sum) && /خاموش/.test(sum), 'کارت‌های بالای بخش شمار را می‌گویند',
    sum.replace(/\s+/g, ' ').trim());
  t(await p.evaluate(() => !!document.querySelector('#pingBody .pg-chip')),
    'و وضعیت به شکلِ قرص است، نه یک جملهٔ خاکستری');
  const look = await p.evaluate(() => ({
    cards: document.querySelectorAll('#pingCards .stat').length,
    rowTone: [...document.querySelectorAll('#pingBody tr')]
      .filter(tr => /is-(up|down|wait)/.test(tr.className)).length
  }));
  t(look.cards === 4, 'چهار کارتِ خلاصه بالای بخش', look.cards + '');
  t(look.rowTone >= 2, 'و حالِ هر ردیف روی خودش نشسته', look.rowTone + ' ردیفِ رنگ‌دار');
  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await b.close();
}

slow.close(); endless.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
