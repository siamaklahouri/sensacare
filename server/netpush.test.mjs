/* کاوشگرِ داخلِ شبکه — اسکریپت و مسیرش.

   «باید روی سیستم کار بکنه.» و حق داشت: سرورِ کارتابل بیرونِ شبکه است
   و به ۱۹۲.۱۶۸.x نمی‌رسد. پس مثلِ گزارشِ Veeam، یک اسکریپتِ کوچک داخلِ
   شبکه می‌دود و نتیجه را می‌فرستد.

   پاورشل در این محیط نصب نمی‌شود، پس خودِ اسکریپت این‌جا اجرا نمی‌شود.
   ولی سخت‌ترین تکه‌اش — ساختِ بستهٔ SNMP با دست — این‌جا بایت‌به‌بایت با
   همان کدی سنجیده می‌شود که روی سرور کار می‌کند: الگوریتم همان است و
   اگر یکی از دو طرف عوض شود، این آزمون می‌افتد.

   بقیه‌اش کامل آزمون می‌شود: قالبِ داده‌ای که اسکریپت می‌فرستد، کلید،
   و اینکه مصرف از تفاضلِ دو گزارش درمی‌آید نه از خودِ شمارنده. */
import { readFileSync } from 'node:fs';
import { openDB } from './d1.js';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { encOid } from '../src/snmp.js';
import { pushScan, ensureNet, listDevs, days, tehranDay, cleanScan } from '../src/netuse.js';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const PS = readFileSync(new URL('./net-push.ps1', import.meta.url), 'utf8');

console.log('===== خودِ اسکریپت =====');
{
  /* پاورشلِ ۵٫۱ پروندهٔ .ps1 را با کدپیجِ ویندوز می‌خواند مگر BOM
     داشته باشد، و BOM با اولین ذخیره در Notepad می‌پرد. پس اسکریپتی
     که روی سرورِ مشتری می‌نشیند نباید نویسهٔ غیرِ اَسکی داشته باشد. */
  const nonAscii = [...PS].filter(c => c.charCodeAt(0) > 126 || (c.charCodeAt(0) < 9));
  t(nonAscii.length === 0, 'فقط اَسکی است — مثلِ veeam-push.ps1',
    nonAscii.slice(0, 5).map(c => c.charCodeAt(0)).join('، ') || 'هیچ');
  t(/x-net-key/.test(PS), 'کلید را در سربرگِ خودش می‌فرستد');
  /* هیچ‌جای اسکریپت رمزی نمی‌خواهد و نمی‌فرستد. (واژهٔ password فقط
     در همان جمله‌ای است که می‌گوید رمزی فرستاده نمی‌شود.) */
  t(!/Get-Credential|PSCredential|ConvertTo-SecureString|-Password/i.test(PS),
    'و هیچ رمزی نمی‌خواهد');
  t(/netuse\/push/.test(PS) || /url/.test(PS), 'و مسیرش از پروندهٔ تنظیمات می‌آید');

  /* شاخه‌هایی که می‌خوانَد باید همان‌هایی باشد که سرور می‌شناسد. */
  for (const oid of ['1.3.6.1.2.1.1.1.0', '1.3.6.1.2.1.1.5.0',
                     '1.3.6.1.2.1.31.1.1.1.6.', '1.3.6.1.2.1.31.1.1.1.10.',
                     '1.3.6.1.2.1.2.2.1.10.', '1.3.6.1.2.1.2.2.1.16.'])
    t(PS.indexOf(oid) >= 0, 'شاخهٔ ' + oid + ' را می‌خواند');
}

console.log('\n===== بستهٔ SNMP، بایت‌به‌بایت =====');
{
  /* همان توابعِ اسکریپت، خط‌به‌خط به جاوااسکریپت. اگر پاورشل عوض شود و
     این‌جا نه، عددها از هم فاصله می‌گیرند و همین‌جا معلوم می‌شود. */
  const berLen = n => {
    if (n < 128) return [n];
    const b = [];
    let x = n;
    while (x > 0) { b.unshift(x & 255); x = Math.floor(x / 256); }
    return [128 + b.length, ...b];
  };
  const berTlv = (type, body) => [type, ...berLen(body.length), ...body];
  const berOid = oid => {
    const p = oid.split('.');
    const b = [40 * Number(p[0]) + Number(p[1])];
    for (let i = 2; i < p.length; i++) {
      let v = Number(p[i]);
      const chunk = [v & 127];
      v = Math.floor(v / 128);
      while (v > 0) { chunk.unshift((v & 127) | 128); v = Math.floor(v / 128); }
      b.push(...chunk);
    }
    return berTlv(6, b);
  };

  const same = o => {
    const mine = Buffer.from(berOid(o));
    const theirs = encOid(o);
    return mine.equals(theirs);
  };
  const oids = ['1.3.6.1.2.1.1.1.0', '1.3.6.1.2.1.31.1.1.1.6.1',
                '1.3.6.1.2.1.31.1.1.1.10.999', '1.3.6.1.4.1.14988.1.1.2.1.1.2.1',
                '1.3.6.1.2.1.2.2.1.16.128', '1.3.6.1.2.1.2.2.1.16.16384'];
  const wrong = oids.filter(o => !same(o));
  t(wrong.length === 0, 'شاخه‌ها را دقیقاً مثلِ سرور کد می‌کند',
    wrong.join('، ') || oids.length + ' شاخه، همه یکی');

  /* و درازای بلند (بیش از ۱۲۷ بایت) هم همان‌طور */
  t(JSON.stringify(berLen(200)) === JSON.stringify([129, 200]) &&
    JSON.stringify(berLen(300)) === JSON.stringify([130, 1, 44]) &&
    JSON.stringify(berLen(5)) === JSON.stringify([5]),
    'و درازا را هم به همان شکلِ BER می‌نویسد');
}

console.log('\n===== گزارشی که می‌رسد =====');
{
  const dir = mkdtempSync(join(tmpdir(), 'netpush-'));
  const env = { DB: openDB(join(dir, 't.db')) };
  await ensureNet(env);

  /* دقیقاً همان شکلی که اسکریپت می‌فرستد */
  const report = (inb, outb) => ({
    range: '192.168.1.0/24', by: 'PC-SIAMAK',
    hosts: [
      { ip: '192.168.1.1', host: 'gw.sltech.local',
        ports: [{ port: 80, t: 'web' }, { port: 8291, t: 'winbox' }],
        snmp: { community: 'public', descr: 'RouterOS 7.14 CCR2004', name: 'gw-markazi' } },
      { ip: '192.168.1.50', host: 'pc-ali.sltech.local',
        ports: [{ port: 445, t: 'windows' }, { port: 3389, t: 'rdp' }], snmp: null },
      { ip: 'بد;رم -rf', host: 'x', ports: [], snmp: null }
    ],
    samples: [{ ip: '192.168.1.1', iface: 1, ifname: 'ether1-wan', in: inb, out: outb }]
  });

  const one = await pushScan(env, 'siamak', report(5_000_000, 1_000_000));
  t(one.hosts === 2, 'نشانیِ آلوده دور انداخته می‌شود', one.hosts + ' از ۳');
  t(one.samples === 1 && one.counted === 0,
    'نمونهٔ اول ثبت می‌شود ولی مصرفی نمی‌سازد — مبنایی نبوده',
    JSON.stringify({ s: one.samples, c: one.counted }));
  t(!!one.snapshot && one.snapshot.by === 'PC-SIAMAK' && one.snapshot.range === '192.168.1.0/24',
    'و خودِ کاوش با نامِ سیستمی که فرستاده نگه داشته می‌شود',
    (one.snapshot || {}).by);

  const devs = await listDevs(env, 'siamak');
  t(devs.length === 1 && devs[0].ip === '192.168.1.1' && devs[0].iface === 1,
    'دستگاهِ تازه خودش در فهرست می‌نشیند — کاربر دو جا یک کار نمی‌کند',
    JSON.stringify({ ip: devs[0] && devs[0].ip, i: devs[0] && devs[0].iface }));
  t(devs[0] && devs[0].live === 0,
    'و سرور دیگر خودش سراغش نمی‌رود: کاوشگر می‌فرستد', String(devs[0] && devs[0].live));

  const two = await pushScan(env, 'siamak', report(5_300_000, 1_120_000));
  t(two.counted === 1, 'گزارشِ دوم، تفاضل را به حسابِ امروز می‌نشاند');
  const d = await days(env, 'siamak', '2000-01-01');
  t(d.length === 1 && d[0].day === tehranDay() && d[0].inb === 300000 && d[0].outb === 120000,
    'و عدد همان تفاضل است، نه خودِ شمارنده',
    JSON.stringify(d[0] || {}));

  /* روتر ریست شد: شمارنده برگشت عقب */
  const three = await pushScan(env, 'siamak', report(900, 100));
  const d2 = await days(env, 'siamak', '2000-01-01');
  t(three.counted === 0 && d2[0].inb === 300000,
    'ریستِ روتر چیزی اضافه نمی‌کند', JSON.stringify(d2[0] || {}));

  /* و پالایشِ ورودی */
  t(cleanScan({ hosts: [{ ip: '10.0.0.1', ports: [{ port: 99999 }] }] })[0].ports.length === 0,
    'پورتِ نامعتبر در گزارش دور انداخته می‌شود');
  t(cleanScan({ hosts: null }).length === 0, 'و گزارشِ بی‌فهرست هم چیزی نمی‌شکند');

  try { env.DB.close && env.DB.close(); } catch (e) { }
  try { rmSync(dir, { recursive: true, force: true }); } catch (e) { }
}

console.log('\n===== مسیرِ سرور =====');
{
  const call = (body, key) => fetch(BASE + '/api/kartabl/netuse/push', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST,
               ...(key ? { 'x-net-key': key } : {}) },
    body: JSON.stringify(body) });

  const noKey = await call({ hosts: [] });
  t(noKey.status === 403, 'بی کلید، هیچ', noKey.status + '');
  const wrong = await call({ hosts: [] }, 'kelid-e-eshtebah');
  t(wrong.status === 403, 'و با کلیدِ غلط هم', wrong.status + '');
  /* کلیدِ درست را پنل می‌سازد و فقط یک بار نشان می‌دهد؛ آزمونِ پنل
     جداست. این‌جا همین بس است که بی کلیدِ درست هیچ گزارشی ننشیند. */
}

console.log('\n===== روی خودِ صفحه =====');
{
  /* ادمین کلید می‌سازد، کاوشگر دو گزارش می‌دهد، و صفحه باید همان را
     نشان بدهد: حالِ کاوشگر، نامِ دستگاه از روی DNS، مصرفِ امروز، و
     نموداری که برچسبش روزِ شمسی باشد. */
  const a = await fetch(BASE + '/api/admin.planer/signin', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ user: process.env.VS_ADMIN || 'admin',
                           password: process.env.VS_ADMIN_PASS || 'adminadminadmin' }) });
  const ack = (a.headers.getSetCookie ? a.headers.getSetCookie() : [])
    .map(c => c.split(';')[0]).join('; ');
  const kj = await (await fetch(BASE + '/api/admin.planer/planners/siamak/net-key',
    { method: 'POST', headers: { Host: HOST, cookie: ack } })).json();
  t(!!kj.key && kj.key.length >= 24, 'پنل کلیدِ کاوشگر می‌سازد',
    (kj.key || '').slice(0, 6) + '…');

  const rep = (i, o) => ({ range: '192.168.1.0/24', by: 'PC-SIAMAK',
    hosts: [{ ip: '192.168.1.1', host: 'gw.sltech.local',
              ports: [{ port: 80 }, { port: 8291 }],
              snmp: { community: 'public', descr: 'RouterOS 7.14', name: 'gw-markazi' } },
            { ip: '192.168.1.50', host: 'pc-ali.sltech.local', ports: [{ port: 445 }], snmp: null }],
    samples: [{ ip: '192.168.1.1', iface: 1, ifname: 'ether1-wan', in: i, out: o }] });
  const send = b2 => fetch(BASE + '/api/kartabl/netuse/push', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST, 'x-net-key': kj.key },
    body: JSON.stringify(b2) });
  t((await send(rep(8e9, 9e8))).status === 200, 'گزارشِ اول می‌نشیند');
  const two = await (await send(rep(8e9 + 2400000, 9e8 + 350000))).json();
  t(two.counted === 1, 'و گزارشِ دوم مصرف می‌سازد', JSON.stringify(two));

  const { launch, calm } = await import('./pw.mjs');
  const PORT = new URL(BASE).port || '80';
  const r2 = await fetch(BASE + '/api/kartabl/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ password: process.env.VS_IT_PASS || 'siamaksiamak' }) });
  const ck = (r2.headers.getSetCookie ? r2.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
  const br = await launch();
  const ctx = await br.newContext({ viewport: { width: 1400, height: 1000 } });
  await ctx.addCookies(ck);
  const p2 = await ctx.newPage();
  const errs = [];
  p2.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p2.goto('http://' + HOST + ':' + PORT + '/siamak/', { waitUntil: 'load' });
  await p2.waitForTimeout(3600); await calm(p2);
  await p2.evaluate(() => document.querySelector('.navbtn[data-view="netuse"]').click());
  await p2.waitForTimeout(1600);

  const box = await p2.evaluate(() => (document.getElementById('nuAgent') || {}).innerText || '');
  t(/کاوشگرِ داخلِ شبکه فعال است/.test(box) && /PC-SIAMAK/.test(box),
    'صفحه می‌گوید کاوشگر فعال است و آخرین گزارش از کجاست',
    box.replace(/\s+/g, ' ').slice(0, 80));

  const devs = await p2.evaluate(() => (document.getElementById('nuDevBody') || {}).innerText || '');
  t(/gw\.sltech\.local/.test(devs),
    'و دستگاه با نامِ DNS‌اش در فهرست است، نه با عددِ خشکِ ای‌پی',
    devs.replace(/\s+/g, ' ').slice(0, 70));

  const cards = await p2.evaluate(() => (document.getElementById('nuCards') || {}).innerText || '');
  t(/مصرفِ امروز/.test(cards) && !/۰ بایت\s*دریافت/.test(cards),
    'و مصرفِ امروز روی کارت نشسته', cards.replace(/\s+/g, ' ').slice(0, 90));

  const ch = await p2.evaluate(() => {
    const cv = document.getElementById('nuChart');
    const c = (window.Chart && Chart.getChart) ? Chart.getChart(cv) : null;
    return c ? { labels: c.data.labels, data: c.data.datasets[0].data } : null;
  });
  t(ch && ch.labels.length === 1 && !/NaN/.test(String(ch.labels[0])) && ch.data[0] > 0,
    'و نمودارِ روزهای ماه برچسبِ شمسی و عددِ درست دارد', JSON.stringify(ch));

  const found = await p2.evaluate(() =>
    (document.getElementById('nuFoundBody') || {}).innerText || '');
  t(/از داخلِ شبکه/.test(found) && /وین‌باکس|ویندوز/.test(found),
    'و فهرستِ پیداشده‌ها با نامِ فارسیِ پورت‌ها می‌آید',
    found.replace(/\s+/g, ' ').slice(0, 90));
  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await br.close();
}

console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
