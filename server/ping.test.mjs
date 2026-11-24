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
import { okHost, okPort, probe } from '../src/ping.js';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

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
  await p.evaluate(() => { const n = document.querySelector('.navbtn[data-view="ping"]'); if (n) n.click(); });
  await p.waitForTimeout(900);

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
  t(/[۰-۹]/.test(one.when), 'و ساعتِ بررسی را می‌نویسد', one.when);

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

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await b.close();
}

console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
