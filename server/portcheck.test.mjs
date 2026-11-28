/* پورت‌چکر: «این پورت از بیرون باز است یا نه؟»

   جوابش را سرورِ کارتابل می‌دهد، چون مرورگر نمی‌تواند یک اتصالِ خام
   به یک پورت باز کند. و چون سرور بیرونِ شبکهٔ کاربر است، همان چیزی
   را می‌بیند که دنیا می‌بیند — که دقیقاً پرسشِ کاربر است.

   مرزهایش هم آزمون می‌شوند، و این‌جا جدی‌اند: پیش از این یک بخشِ
   دیگر هر پنج دقیقه هشت رنج را می‌گشت و شبکهٔ شرکت را خواباند. این
   یکی فقط با کلیکِ آدم کار می‌کند و سقفِ هر بار سی‌ودو پورت است. */
import net from 'node:net';
import { launch, calm } from './pw.mjs';
import { parsePorts, manyPorts, MAX_PORTS, PORT_NAMES } from '../src/ping.js';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== خواندنِ فهرستِ پورت‌ها =====');
{
  t(JSON.stringify(parsePorts('80, 443')) === JSON.stringify([80, 443]),
    'با ویرگول', JSON.stringify(parsePorts('80, 443')));
  t(JSON.stringify(parsePorts('۸۰ ۴۴۳')) === JSON.stringify([80, 443]),
    'با رقمِ فارسی و فاصله');
  t(JSON.stringify(parsePorts('8000-8003')) === JSON.stringify([8000, 8001, 8002, 8003]),
    'و بازه');
  t(parsePorts('1-5000').length === MAX_PORTS,
    'بازهٔ بلند به سقف بریده می‌شود، نه اینکه رد شود',
    parsePorts('1-5000').length + ' تا');
  t(JSON.stringify(parsePorts('80, 80, 80')) === JSON.stringify([80]), 'و تکراری یکی می‌شود');
  t(parsePorts('سلام; rm -rf /').length === 0, 'و چیزی که پورت نیست، پورت نمی‌شود');
  t(parsePorts('0, 70000, -5').length === 0, 'و پورتِ بیرون از بازه هم');
  t(PORT_NAMES[3389] === 'ریموت دسکتاپ' && PORT_NAMES[8291].indexOf('میکروتیک') >= 0,
    'و پورت‌های شناخته‌شده نام دارند');
}

console.log('\n===== بررسیِ واقعی =====');
const up1 = net.createServer(s => s.end());
const up2 = net.createServer(s => s.end());
await new Promise(r => up1.listen(0, '127.0.0.1', r));
await new Promise(r => up2.listen(0, '127.0.0.1', r));
const P1 = up1.address().port, P2 = up2.address().port;
{
  const r = await manyPorts('127.0.0.1', [P1, P2, 9], { ms: 900 });
  t(r.ok && r.rows.length === 3, 'هر سه پورت بررسی می‌شوند', (r.rows || []).length + '');
  const by = {};
  (r.rows || []).forEach(x => { by[x.port] = x; });
  t(by[P1].open && by[P2].open, 'پورتِ باز، باز دیده می‌شود');
  t(!by[9].open && /بسته/.test(by[9].why || ''), 'و بسته، بسته — با دلیلش', by[9].why);
  t(r.open === 2, 'و شمارشش درست است', r.open + ' از ۳');
  t(r.rows[0].port < r.rows[1].port, 'نتیجه به ترتیبِ پورت می‌آید، نه به ترتیبِ رسیدن');

  const many = await manyPorts('127.0.0.1', Array.from({ length: 80 }, (_, i) => 9000 + i), { ms: 300 });
  t(many.ok && many.rows.length === MAX_PORTS, 'و سقفِ سی‌ودو پورت نگه داشته می‌شود',
    many.rows.length + ' تا');

  const evil = await manyPorts('127.0.0.1; id', [80], { ms: 300 });
  t(!evil.ok && /نشانی/.test(evil.error), 'نشانیِ آلوده اصلاً اجرا نمی‌شود', evil.error);
  const none = await manyPorts('127.0.0.1', [], { ms: 300 });
  t(!none.ok, 'و بی پورت هم کاری نمی‌کند', none.error);
}

console.log('\n===== مسیرِ سرور =====');
{
  const r = await fetch(BASE + '/api/kartabl/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ password: process.env.VS_IT_PASS || 'siamaksiamak' }) });
  const cookie = (r.headers.getSetCookie ? r.headers.getSetCookie() : [])
    .map(c => c.split(';')[0]).join('; ');
  const call = b => fetch(BASE + '/api/kartabl/portcheck', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST, cookie },
    body: JSON.stringify(b) });

  const good = await (await call({ host: '127.0.0.1', ports: P1 + ', 9' })).json();
  t(good.ok && good.open === 1, 'مسیرِ سرور جواب می‌دهد و رشتهٔ پورت‌ها را می‌فهمد',
    JSON.stringify(good.rows.map(x => x.port + ':' + (x.open ? 'باز' : 'بسته'))));
  const evil = await call({ host: '127.0.0.1; id', ports: '80' });
  t(evil.status === 400, 'و نشانیِ آلوده را رد می‌کند', evil.status + '');
  const empty = await call({ host: '127.0.0.1', ports: 'سلام' });
  t(empty.status === 400, 'و بی پورتِ درست هم', empty.status + '');

  const anon = await fetch(BASE + '/api/kartabl/portcheck', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ host: '127.0.0.1', ports: '80' }) });
  t(anon.status === 401 || anon.status === 403, 'و بی ورود به کارتابل، هیچ', anon.status + '');
}

console.log('\n===== خودِ بخش =====');
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
  await p.waitForTimeout(3600); await calm(p);

  t(await p.evaluate(() => !!document.querySelector('.navbtn[data-view="portcheck"]')),
    'بخش در فهرستِ کناری هست');
  await p.evaluate(() => document.querySelector('.navbtn[data-view="portcheck"]').click());
  await p.waitForTimeout(900);
  t(await p.evaluate(() => [...document.querySelectorAll('.content > .view')]
      .filter(v => getComputedStyle(v).display !== 'none').length) === 1,
    'و در هر لحظه فقط یک بخش دیده می‌شود');

  const sets = await p.evaluate(() =>
    [...document.querySelectorAll('.pc-set')].map(x => x.textContent));
  t(sets.length >= 5 && sets.indexOf('وب') >= 0, 'دسته‌های آماده هستند', sets.join('، '));

  await p.fill('#pcHost', '127.0.0.1');
  await p.fill('#pcPorts', P1 + ', ' + P2 + ', 9');
  await p.evaluate(() => document.getElementById('pcGo').click());
  await p.waitForTimeout(3200);
  const out = await p.evaluate(() => ({
    say: (document.getElementById('pcSay') || {}).innerText || '',
    rows: document.querySelectorAll('#pcBody tr').length,
    open: document.querySelectorAll('#pcBody tr.pc-open').length,
    chips: [...document.querySelectorAll('.pc-chip')].map(x => x.textContent).join('،')
  }));
  t(out.rows === 3 && out.open === 2, 'سه پورت بررسی شد و دوتایش باز است',
    out.rows + ' ردیف، ' + out.open + ' باز');
  t(/۲ پورت از ۳/.test(out.say), 'و خلاصه‌اش هم همین را می‌گوید',
    out.say.replace(/\s+/g, ' ').trim());
  t(/باز/.test(out.chips) && /بسته/.test(out.chips), 'وضعیت به شکلِ قرص است', out.chips);

  /* دستهٔ آماده هم خودش بررسی را می‌زند */
  await p.evaluate(() => [...document.querySelectorAll('.pc-set')]
    .find(x => x.textContent === 'وب').click());
  await p.waitForTimeout(3200);
  t(await p.evaluate(() => document.getElementById('pcPorts').value).then(v => /443/.test(v)),
    'زدنِ یک دسته، پورت‌هایش را می‌گذارد');
  t(await p.evaluate(() => document.querySelectorAll('#pcBody tr').length) === 4,
    'و همان‌جا بررسی‌شان می‌کند');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await b.close();
}

up1.close(); up2.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
