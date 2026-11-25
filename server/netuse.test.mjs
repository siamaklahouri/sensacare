/* مصرفِ اینترنت: کاوشِ رنج، و خواندنِ حجم از خودِ دستگاه.

   خواسته این بود: «رنجِ شبکه‌ام را بدهم، خودش کلِ ای‌پی‌ها را بخواند
   و مصرفِ حجم را بگوید». دو چیز باید ثابت شود:

   • کاوش واقعاً همهٔ نشانی‌های رنج را می‌زند، زنده‌ها را پیدا می‌کند،
     و همان‌طور که پیدا می‌شوند می‌فرستد — نه یکجا در پایان.
   • مصرف از شمارندهٔ خودِ دستگاه می‌آید و «مصرفِ امروز» از تفاضلِ
     نمونه‌ها ساخته می‌شود، نه از خودِ شمارنده که با هر ریستِ روتر صفر
     می‌شود.

   برای هر دو، یک روترِ ساختگی بالا می‌آید: یک عاملِ SNMP که همان
   شاخه‌های استاندارد را جواب می‌دهد و شمارنده‌هایش جلو می‌روند. بدونِ
   آن، این بخش فقط روی دستگاهِ واقعی آزمون می‌شد — یعنی هیچ‌وقت. */
import net from 'node:net';
import { unlinkSync } from 'node:fs';
import { fakeAgent } from './snmpfake.mjs';
import { openDB } from './d1.js';
import { parseRange, probeHost, scanStream, ifaces, sample, speed,
         netTick, saveDev, listDevs, days, tehranDay, ensureNet } from '../src/netuse.js';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== رنجِ شبکه =====');
{
  const a = parseRange('192.168.1.0/24');
  t(a.ok && a.n === 254 && a.from === '192.168.1.1' && a.to === '192.168.1.254',
    'رنجِ /۲۴ می‌شود ۲۵۴ میزبان', a.n + ' تا، از ' + a.from + ' تا ' + a.to);
  const b = parseRange('۱۹۲.۱۶۸.۱.۱۰-۲۰');
  t(b.ok && b.n === 11 && b.from === '192.168.1.10',
    'بازه با رقمِ فارسی هم خوانده می‌شود', b.n + ' تا از ' + b.from);
  const c = parseRange('10.0.0.5-10.0.0.9');
  t(c.ok && c.n === 5, 'و بازهٔ دو نشانیِ کامل', c.n + ' تا');
  const d = parseRange('192.168.1.5');
  t(d.ok && d.n === 1, 'یک نشانیِ تنها هم رنج است');
  const e = parseRange('10.0.0.0/16');
  t(!e.ok && /سقف/.test(e.error), 'ولی رنجِ غول‌پیکر نه — سقف دارد', e.error);
  for (const x of ['', 'سلام', '192.168.1.0/99', '999.1.1.1', '192.168.1.9-192.168.1.1'])
    t(!parseRange(x).ok, 'رد می‌شود: ' + JSON.stringify(x));
}

/* ---------- روترِ ساختگی ---------- */
const MIB = {
  '1.3.6.1.2.1.1.1.0': { t: 'str', v: 'RouterOS 7.14 (MikroTik) CCR2004-1G-12S+2XS' },
  '1.3.6.1.2.1.1.5.0': { t: 'str', v: 'gw-markazi' },
  '1.3.6.1.2.1.31.1.1.1.1.1': { t: 'str', v: 'ether1-wan' },
  '1.3.6.1.2.1.31.1.1.1.1.2': { t: 'str', v: 'ether2-lan' },
  '1.3.6.1.2.1.31.1.1.1.18.1': { t: 'str', v: 'اینترنتِ اصلی' },
  '1.3.6.1.2.1.2.2.1.8.1': { t: 'int', v: 1 },
  '1.3.6.1.2.1.2.2.1.8.2': { t: 'int', v: 2 },
  '1.3.6.1.2.1.31.1.1.1.15.1': { t: 'int', v: 1000 },
  '1.3.6.1.2.1.31.1.1.1.15.2': { t: 'int', v: 100 },
  '1.3.6.1.2.1.31.1.1.1.6.1': { t: 'c64', v: 5_000_000 },
  '1.3.6.1.2.1.31.1.1.1.10.1': { t: 'c64', v: 2_000_000 },
  '1.3.6.1.2.1.31.1.1.1.6.2': { t: 'c64', v: 10 },
  '1.3.6.1.2.1.31.1.1.1.10.2': { t: 'c64', v: 20 }
};
/* شمارنده‌ها جلو می‌روند، مثلِ یک پورتِ واقعی: ثانیه‌ای ۱۲۵ کیلوبایت
   دریافت (یک مگابیت) و ۲۵ کیلوبایت ارسال. */
const RATE_IN = 125000, RATE_OUT = 25000;
const tick = setInterval(() => {
  MIB['1.3.6.1.2.1.31.1.1.1.6.1'].v += RATE_IN / 10;
  MIB['1.3.6.1.2.1.31.1.1.1.10.1'].v += RATE_OUT / 10;
}, 100);
tick.unref();

const agent = await fakeAgent(MIB, { port: 161 });
const web = net.createServer(s => s.end());
await new Promise(r => web.listen(80, '127.0.0.1', r));

console.log('===== کاوش =====');
{
  const h = await probeHost('127.0.0.1', { ms: 600 });
  t(h.alive, 'نشانیِ زنده پیدا می‌شود', h.how);
  t(h.ports.some(p => p.port === 80), 'و پورتِ بازش گفته می‌شود',
    h.ports.map(p => p.t).join('، '));
  t(!!h.snmp && /RouterOS/.test(h.snmp.descr), 'و اینکه SNMP دارد و چه دستگاهی است',
    (h.snmp || {}).descr || '—');
  t(h.kind === 'میکروتیک', 'نوعش از خودِ دستگاه حدس زده می‌شود', h.kind);
  t(h.usable === 'snmp', 'و همین یعنی مصرفش خواندنی است', h.usable);

  const dead = await probeHost('127.0.0.9', { ms: 400 });
  t(!dead.alive || !dead.snmp, 'نشانیِ خالی، دستگاه نیست', JSON.stringify(dead.alive));
}

console.log('===== جریانِ کاوش =====');
{
  const list = ['127.0.0.1', '127.0.0.9', '127.0.0.8'];
  const rd = scanStream(list, { ms: 400, wide: 1 }).getReader();
  const dec = new TextDecoder('utf-8');
  let buf = '';
  const evs = [];
  const at0 = Date.now();
  for (;;) {
    const r = await rd.read();
    if (r.done) break;
    buf += dec.decode(r.value, { stream: true });
    let i;
    while ((i = buf.indexOf('\n')) >= 0) {
      const line = buf.slice(0, i); buf = buf.slice(i + 1);
      if (line) evs.push({ at: Date.now() - at0, ...JSON.parse(line) });
    }
  }
  t(evs[0] && evs[0].k === 'start' && evs[0].n === 3, 'اول می‌گوید چند نشانی',
    JSON.stringify(evs[0]));
  const hosts = evs.filter(e => e.k === 'host');
  t(hosts.length === 1 && hosts[0].ip === '127.0.0.1', 'فقط زنده‌ها را می‌فرستد',
    hosts.map(h => h.ip).join('، '));
  const ticks = evs.filter(e => e.k === 'tick');
  t(ticks.length === 3, 'و پیشرفتش را هم می‌گوید', ticks.length + ' قدم');
  const done = evs[evs.length - 1];
  t(done.k === 'done' && done.found === 1, 'و در پایان جمع‌بندی', JSON.stringify(done));
  t(hosts[0].at < done.at, 'دستگاهِ پیداشده پیش از پایان می‌رسد، نه یکجا در آخر',
    hosts[0].at + ' در برابر ' + done.at + ' میلی‌ثانیه');
}

console.log('===== پورت‌ها و شمارنده‌ها =====');
{
  const r = await ifaces('127.0.0.1', 'public');
  t(r.ok && r.rows.length === 2, 'پورت‌های دستگاه خوانده می‌شوند',
    (r.rows || []).map(x => x.name).join('، '));
  const wan = (r.rows || []).find(x => x.i === 1) || {};
  t(wan.name === 'ether1-wan' && wan.up === true, 'با نام و بالا/پایین بودن',
    wan.name + ' — ' + (wan.up ? 'بالا' : 'پایین'));
  t(wan.note === 'اینترنتِ اصلی', 'و توضیحی که روی خودِ دستگاه نوشته شده', wan.note);
  t(wan.mbps === 1000, 'و سرعتِ پورت', wan.mbps + ' مگابیت');
  t(wan.in > 0 && wan.out > 0 && wan.wide, 'و شمارندهٔ ۶۴بیتی‌اش',
    wan.in + ' / ' + wan.out);

  const badComm = await ifaces('127.0.0.1', 'wrong-one', { ms: 500 });
  t(!badComm.ok, 'با جامعهٔ غلط چیزی خوانده نمی‌شود', badComm.error);

  const sp = await speed('127.0.0.1', 'public', 1, { gap: 1200 });
  const mb = sp.ok ? sp.inBps * 8 / 1e6 : 0;
  t(sp.ok && mb > 0.6 && mb < 1.6, 'سرعتِ همین حالا درست درمی‌آید',
    mb.toFixed(2) + ' مگابیت بر ثانیه');
}

console.log('===== مصرفِ روزانه =====');
{
  /* همان دیتابیسِ واقعی، فقط روی یک پروندهٔ موقت. */
  const file = (process.env.TMPDIR || '/tmp') + '/netuse-test-' + process.pid + '.db';
  const env = { DB: openDB(file) };
  await ensureNet(env);
  await saveDev(env, 'siamak', { ip: '127.0.0.1', name: 'روترِ مرکزی',
                                 community: 'public', iface: 1, ifname: 'ether1-wan' });
  const devs = await listDevs(env, 'siamak');
  t(devs.length === 1 && devs[0].iface === 1, 'دستگاه ثبت می‌شود', JSON.stringify(devs[0].name));

  const first = await netTick(env, { ms: 900 });
  t(first.done === 1, 'نوبتِ اول نمونه می‌گیرد', JSON.stringify(first));
  const d0 = await days(env, 'siamak', '2000-01-01');
  t(d0.length === 0, 'ولی هنوز مصرفی ثبت نمی‌کند — مبنایی نبوده که از آن کم شود');

  await new Promise(r => setTimeout(r, 1400));
  await netTick(env, { ms: 900 });
  const d1 = await days(env, 'siamak', '2000-01-01');
  const row = d1[0] || {};
  t(d1.length === 1 && row.day === tehranDay(), 'نوبتِ دوم، مصرفِ همین روز را می‌نویسد',
    row.day + ' — ' + row.inb + ' بایت');
  t(row.inb > 100000 && row.inb < 300000, 'و عددش همان تفاضلِ شمارنده است، نه خودِ شمارنده',
    row.inb + ' بایت در حدودِ ۱٫۴ ثانیه');

  /* و اگر روتر ریست شود، شمارنده برمی‌گردد عقب. آن تفاضل منفی است و
     نباید به حساب بیاید — وگرنه مصرفِ روز قاطی می‌شود. */
  const before = (await days(env, 'siamak', '2000-01-01'))[0].inb;
  MIB['1.3.6.1.2.1.31.1.1.1.6.1'].v = 1000;
  MIB['1.3.6.1.2.1.31.1.1.1.10.1'].v = 500;
  await netTick(env, { ms: 900 });
  const afterReset = (await days(env, 'siamak', '2000-01-01'))[0].inb;
  t(afterReset === before, 'ریستِ روتر چیزی به مصرف اضافه نمی‌کند',
    before + ' → ' + afterReset);

  /* و از همان‌جا دوباره می‌شمارد */
  await new Promise(r => setTimeout(r, 900));
  await netTick(env, { ms: 900 });
  const resumed = (await days(env, 'siamak', '2000-01-01'))[0].inb;
  t(resumed > afterReset, 'ولی از نو که شروع شد، باز می‌شمارد',
    afterReset + ' → ' + resumed);

  try { env.DB.close && env.DB.close(); } catch (e) { }
  try { unlinkSync(file); } catch (e) { }
}

console.log('===== مسیرهای سرور =====');
{
  const r = await fetch(BASE + '/api/kartabl/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ password: process.env.VS_IT_PASS || 'siamaksiamak' }) });
  const cookie = (r.headers.getSetCookie ? r.headers.getSetCookie() : [])
    .map(c => c.split(';')[0]).join('; ');
  const call = (path, body) => fetch(BASE + '/api/kartabl' + path, {
    method: body ? 'POST' : 'GET',
    headers: { 'Content-Type': 'application/json', Host: HOST, cookie },
    body: body ? JSON.stringify(body) : undefined });

  const devs = await (await call('/netuse/devs')).json();
  t(Array.isArray(devs.devs) && devs.today === tehranDay(), 'فهرستِ دستگاه‌ها می‌آید',
    JSON.stringify(devs.today));

  const badRange = await call('/netuse/scan', { range: '10.0.0.0/8' });
  t(badRange.status === 400, 'رنجِ غول‌پیکر رد می‌شود', badRange.status + '');

  const add = await (await call('/netuse/devs', { ip: '127.0.0.1', name: 'روترِ آزمون',
    community: 'public', iface: 1, ifname: 'ether1-wan' })).json();
  t(add.ok && add.devs.length === 1, 'دستگاه از راهِ مسیرِ سرور هم ثبت می‌شود');

  const ifs = await (await call('/netuse/ifaces', { host: '127.0.0.1', community: 'public' })).json();
  t(ifs.ok && ifs.rows.length === 2, 'و پورت‌هایش از همان‌جا خوانده می‌شود');

  const evil = await call('/netuse/ifaces', { host: '127.0.0.1; id', community: 'public' });
  t(evil.status === 400, 'و نشانیِ آلوده این‌جا هم رد می‌شود', evil.status + '');

  const anon = await fetch(BASE + '/api/kartabl/netuse/devs', { headers: { Host: HOST } });
  t(anon.status === 401 || anon.status === 403, 'و بی ورود، هیچ', anon.status + '');

  const del = await (await call('/netuse/devs/del', { ip: '127.0.0.1' })).json();
  t(del.ok && del.devs.length === 0, 'و حذفش هم کار می‌کند');
}

clearInterval(tick);
agent.close();
web.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
