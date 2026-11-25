/* ==================== شبکه: کاوش و مصرف ====================
   خواسته این بود: «رنجِ شبکه‌ام را بدهم و خودش کلِ ای‌پی‌ها را بخواند
   و مصرفِ حجمِ اینترنت را بگوید».

   دو کارِ جدا، و عمداً جدا ماندند:

   ۱) کاوش. یک رنج داده می‌شود (۱۹۲.۱۶۸.۱.۰/۲۴ یا یک بازه)، و هر
      نشانی زده می‌شود تا معلوم شود چه چیزی آن‌جاست و چه می‌گوید.
      نتیجه همان‌طور که می‌آید فرستاده می‌شود، نه یکجا در پایان: روی
      یک رنجِ ۲۵۴تایی، «یکجا» یعنی یک دقیقه نگاه کردن به صفحهٔ ساکت.

   ۲) مصرف. از خودِ شمارندهٔ بایتِ دستگاه خوانده می‌شود، با SNMP.
      این زبانِ مشترکِ روتر و سوییچِ مدیریتی است؛ بستن به یک برند
      یعنی فردا که دستگاه عوض شد، این بخش هم دور انداخته شود.

   چرا پینگ کافی نیست: پینگ فقط می‌گوید دستگاه زنده است. حجم عددی
   است که فقط خودِ دستگاه دارد. */
import { tcpProbe, icmpProbe, okHost, okPort } from './ping.js';
import { snmpGet, snmpWalk } from './snmp.js';
import { reverse } from 'node:dns';

/* ---------- شاخه‌های استانداردِ SNMP ---------- */
const O = {
  descr: '1.3.6.1.2.1.1.1.0',
  name:  '1.3.6.1.2.1.1.5.0',
  up:    '1.3.6.1.2.1.1.3.0',
  ifDescr: '1.3.6.1.2.1.2.2.1.2',
  ifName:  '1.3.6.1.2.1.31.1.1.1.1',
  ifAlias: '1.3.6.1.2.1.31.1.1.1.18',
  ifOper:  '1.3.6.1.2.1.2.2.1.8',
  ifSpeed: '1.3.6.1.2.1.31.1.1.1.15',     /* مگابیت، ۶۴بیتی */
  hcIn:  '1.3.6.1.2.1.31.1.1.1.6',
  hcOut: '1.3.6.1.2.1.31.1.1.1.10',
  in32:  '1.3.6.1.2.1.2.2.1.10',
  out32: '1.3.6.1.2.1.2.2.1.16'
};

/* ---------- رنجِ شبکه ----------
   سه شکل پذیرفته می‌شود، چون آدم‌ها هر سه را می‌نویسند:
   «۱۹۲.۱۶۸.۱.۰/۲۴»، «۱۹۲.۱۶۸.۱.۱-۲۵۴»، «۱۹۲.۱۶۸.۱.۱-۱۹۲.۱۶۸.۱.۵۰».

   سقف ۱۰۲۴ نشانی است. رنجِ بزرگ‌تر یعنی ده‌ها هزار بسته از سرور،
   که هم طول می‌کشد و هم از دیدِ فایروالِ آن‌طرف، اسکن است. */
const IP_RE = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
export const MAX_RANGE = 1024;

const toNum = ip => {
  const m = IP_RE.exec(String(ip).trim());
  if (!m) return -1;
  const p = m.slice(1).map(Number);
  if (p.some(x => x > 255)) return -1;
  return ((p[0] * 256 + p[1]) * 256 + p[2]) * 256 + p[3];
};
const toIp = n => [n >>> 24, (n >>> 16) & 255, (n >>> 8) & 255, n & 255].join('.');

/* چند رنج، با ویرگول: «۱۰٫۱۷۰٫۱۰٫۰/۲۴، ۱۰٫۱۷۰٫۲۰٫۰/۲۴». هر کدام جدا
   پالوده می‌شود و فهرستشان پشتِ هم می‌نشیند — سقفِ کل همان است. */
export function parseRanges(txt) {
  const parts = String(txt == null ? '' : txt).split(/[,،]/)
    .map(x => x.trim()).filter(Boolean);
  if (parts.length <= 1) return parseRange(txt);
  const list = [];
  const labels = [];
  for (const one of parts) {
    const r = parseRange(one);
    if (!r.ok) return r;
    for (const ip of r.list) if (list.indexOf(ip) < 0) list.push(ip);
    labels.push(one);
    if (list.length > MAX_RANGE)
      return { ok: false, error: 'روی هم ' + list.length + ' نشانی می‌شود؛ سقف ' +
                                 MAX_RANGE + ' است. رنج‌ها را جدا کاوش کنید.' };
  }
  return { ok: true, list, from: list[0], to: list[list.length - 1],
           n: list.length, parts: labels };
}

export function parseRange(txt) {
  const s = String(txt == null ? '' : txt).trim()
    .replace(/[۰-۹]/g, d => '۰۱۲۳۴۵۶۷۸۹'.indexOf(d))
    .replace(/[٠-٩]/g, d => '٠١٢٣٤٥٦٧٨٩'.indexOf(d))
    .replace(/\s+/g, '');
  if (!s) return { ok: false, error: 'رنج را بنویسید' };

  let a = -1, b = -1;
  const slash = s.split('/');
  if (slash.length === 2) {
    const base = toNum(slash[0]), bits = parseInt(slash[1], 10);
    if (base < 0 || !Number.isFinite(bits) || bits < 8 || bits > 32)
      return { ok: false, error: 'رنج درست نیست' };
    const size = Math.pow(2, 32 - bits);
    const net = Math.floor(base / size) * size;
    a = size > 2 ? net + 1 : net;                 /* نشانیِ خودِ شبکه و پخش، میزبان نیستند */
    b = size > 2 ? net + size - 2 : net + size - 1;
  } else if (s.indexOf('-') > 0) {
    const [x, y] = s.split('-');
    a = toNum(x);
    b = IP_RE.test(y) ? toNum(y) : (a >= 0 && /^\d{1,3}$/.test(y)
      ? (a - (a & 255) + Number(y)) : -1);
  } else {
    a = b = toNum(s);
  }
  if (a < 0 || b < 0 || b < a) return { ok: false, error: 'رنج درست نیست' };
  const n = b - a + 1;
  if (n > MAX_RANGE)
    return { ok: false, error: 'این رنج ' + n + ' نشانی دارد؛ سقف ' + MAX_RANGE + ' است' };
  const list = [];
  for (let i = a; i <= b; i++) list.push(toIp(i));
  return { ok: true, list, from: toIp(a), to: toIp(b), n };
}

/* ---------- یک نشانی، و هرچه می‌شود از آن فهمید ----------
   اول زنده بودن، بعد شناسایی. پورت‌ها را کوتاه می‌زنیم چون در یک
   شبکهٔ محلی جوابِ TCP زیرِ ۱۰۰ میلی‌ثانیه می‌آید؛ آنچه دیر جواب
   می‌دهد عملاً بسته است. */
const PORTS = [
  { p: 80,   t: 'وب' },
  { p: 443,  t: 'وبِ امن' },
  { p: 22,   t: 'SSH' },
  { p: 23,   t: 'تلنت' },
  { p: 8291, t: 'وین‌باکس (میکروتیک)' },
  { p: 8728, t: 'API میکروتیک' },
  { p: 4370, t: 'حضور و غیاب' },
  { p: 445,  t: 'ویندوز' },
  { p: 3389, t: 'ریموت دسکتاپ' },
  { p: 9100, t: 'چاپگر' }
];

/* جامعه‌های پیش‌فرض. «public» تقریباً همیشه همین است و اگر عوض شده
   باشد، کاربر خودش در همان جدول می‌نویسد. */
export const COMMUNITIES = ['public'];

export async function probeHost(ip, opt) {
  const o = opt || {};
  const ms = Math.min(Math.max(parseInt(o.ms, 10) || 700, 150), 3000);
  const comms = (o.communities && o.communities.length ? o.communities : COMMUNITIES)
    .map(String).filter(c => /^[\x21-\x7e]{1,32}$/.test(c)).slice(0, 4);

  const t0 = Date.now();
  const ports = await Promise.all(PORTS.map(async x => {
    const r = await tcpProbe(ip, x.p, ms);
    return r.ok ? { ...x, ms: r.ms } : null;
  }));
  const open = ports.filter(Boolean);

  /* SNMP روی UDP است و «پورتِ باز» ندارد: یا جواب می‌دهد یا نه. */
  let snmp = null;
  for (const c of comms) {
    const r = await snmpGet(ip, c, [O.descr, O.name], { ms: Math.max(ms, 900) });
    if (r.ok && r.binds && r.binds.length) {
      snmp = {
        community: c,
        descr: String((r.binds[0] || {}).value || '').slice(0, 160),
        name: String((r.binds[1] || {}).value || '').slice(0, 60)
      };
      break;
    }
  }

  /* زنده بودن: اگر چیزی جواب داده، زنده است. وگرنه یک پینگِ ساده —
     دستگاهی که همهٔ پورت‌هایش بسته است هم ممکن است روشن باشد. */
  let how = open.length ? 'tcp' : (snmp ? 'snmp' : '');
  let alive = !!how;
  if (!alive) {
    const p = await icmpProbe(ip, Math.max(ms, 900));
    if (p.ok) { alive = true; how = 'ping'; }
  }

  /* نامِ سیستم از DNSِ خودِ دامین. این هیچ رمزی نمی‌خواهد — همان
     چیزی است که هر عضوِ دامین می‌پرسد — و فهرست را از یک ستون
     عددِ خشک به اسمِ آدم‌ها و اتاق‌ها تبدیل می‌کند. */
  const host = alive ? await rdns(ip, 900) : '';

  return {
    ip, host, alive, how, ms: Date.now() - t0,
    ports: open.map(x => ({ port: x.p, t: x.t, ms: x.ms })),
    /* چه چیزی امتحان شد — برای وقتی که هیچ‌کدام جواب نمی‌دهند */
    tried: PORTS.map(x => x.p),
    snmp,
    kind: guessKind(open, snmp),
    usable: snmp ? 'snmp' : (open.some(x => x.p === 8728 || x.p === 8291) ? 'mikrotik' : '')
  };
}

/* نامِ معکوس، با مهلتِ خودش: DNSِ کند نباید کلِ کاوش را نگه دارد. */
function rdns(ip, ms) {
  return new Promise(resolve => {
    let done = false;
    const t = setTimeout(() => { if (!done) { done = true; resolve(''); } }, ms);
    try {
      reverse(ip, (err, names) => {
        if (done) return;
        done = true;
        clearTimeout(t);
        resolve(err || !names || !names.length ? '' : String(names[0]).slice(0, 60));
      });
    } catch (e) { if (!done) { done = true; clearTimeout(t); resolve(''); } }
  });
}

/* یک حدسِ محترمانه، نه بیشتر: اسمِ دستگاه از خودش بهتر می‌آید. */
function guessKind(open, snmp) {
  const d = ((snmp && snmp.descr) || '').toLowerCase();
  if (/mikrotik|routeros/.test(d)) return 'میکروتیک';
  if (/cisco/.test(d)) return 'سیسکو';
  if (/ubnt|ubiquiti/.test(d)) return 'یوبیکیوتی';
  if (/windows/.test(d)) return 'ویندوز';
  if (/linux/.test(d)) return 'لینوکس';
  if (/printer|jetdirect/.test(d)) return 'چاپگر';
  const has = p => open.some(x => x.p === p);
  if (has(8291) || has(8728)) return 'میکروتیک';
  if (has(4370)) return 'حضور و غیاب';
  if (has(9100)) return 'چاپگر';
  if (has(3389) || has(445)) return 'ویندوز';
  return '';
}

/* ---------- کاوشِ رنج، زنده ----------
   هر نشانی که تمام شد، همان لحظه فرستاده می‌شود. ساختارِ خطوط مثلِ
   تلنتِ زنده است: هر خط یک JSON. */
export function scanStream(list, opt) {
  const o = opt || {};
  const wide = Math.min(Math.max(parseInt(o.wide, 10) || 32, 1), 64);
  return new ReadableStream({
    start(ctrl) {
      const enc = new TextEncoder();
      let done = false, i = 0, found = 0;
      const t0 = Date.now();
      const put = x => {
        if (done) return;
        try { ctrl.enqueue(enc.encode(JSON.stringify(x) + '\n')); } catch (e) { }
      };
      const stop = () => {
        if (done) return;
        done = true;
        try { ctrl.close(); } catch (e) { }
      };

      put({ k: 'start', n: list.length, from: list[0], to: list[list.length - 1] });

      const next = async () => {
        while (!done) {
          const idx = i++;
          if (idx >= list.length) return;
          let r = null;
          try { r = await probeHost(list[idx], o); } catch (e) { }
          if (done) return;
          if (r && r.alive) found++;
          /* نشانیِ خاموش معمولاً خبر نیست و فهرست را شلوغ می‌کند. ولی
             وقتی کاربر یک نشانیِ تنها را پرسیده، «هیچ» جواب نیست:
             باید ببیند چه چیزی امتحان شد و هیچ‌کدام جواب نداد. */
          if (r && (r.alive || list.length === 1)) put({ k: 'host', ...r });
          put({ k: 'tick', at: idx + 1, n: list.length, found });
        }
      };
      Promise.all(Array.from({ length: Math.min(wide, list.length) }, next))
        .then(() => {
          put({ k: 'done', n: list.length, found, ms: Date.now() - t0 });
          stop();
        })
        .catch(() => stop());

      this._stop = stop;
    },
    cancel() { if (this._stop) this._stop(); }
  });
}

/* ---------- پورت‌های یک دستگاه، با شمارنده‌هایشان ----------
   «کدام پورت اینترنت است» را خودِ آدم باید بگوید؛ ما نامش و سرعتش و
   بالا/پایین بودنش را می‌آوریم تا انتخاب آسان باشد. */
export async function ifaces(host, community, opt) {
  if (!okHost(host)) return { ok: false, error: 'نشانی درست نیست' };
  const o = { ms: 1500, max: 200, ...(opt || {}) };
  const names = await snmpWalk(host, community, O.ifName, o);
  const rows = names.ok && names.rows.length ? names.rows
    : (await snmpWalk(host, community, O.ifDescr, o)).rows || [];
  if (!rows.length) return { ok: false, error: 'پورتی خوانده نشد' };

  const idx = rows.map(r => r.oid.slice(r.oid.lastIndexOf('.') + 1));
  const grab = async (root, want) => {
    const w = await snmpWalk(host, community, root, o);
    const m = {};
    (w.rows || []).forEach(r => { m[r.oid.slice(r.oid.lastIndexOf('.') + 1)] = r.value; });
    return want ? m : m;
  };
  const [alias, oper, speed, hin, hout, in32, out32] = await Promise.all([
    grab(O.ifAlias), grab(O.ifOper), grab(O.ifSpeed),
    grab(O.hcIn), grab(O.hcOut), grab(O.in32), grab(O.out32)
  ]);

  return {
    ok: true,
    rows: idx.map((i, k) => ({
      i: Number(i),
      name: String(rows[k].value || '').slice(0, 40),
      note: String(alias[i] || '').slice(0, 60),
      up: oper[i] === 1,
      mbps: Number(speed[i] || 0),
      in: Number(hin[i] != null ? hin[i] : (in32[i] || 0)),
      out: Number(hout[i] != null ? hout[i] : (out32[i] || 0)),
      wide: hin[i] != null                       /* شمارندهٔ ۶۴بیتی دارد یا نه */
    }))
  };
}

/* یک نمونهٔ خام از یک پورت: همان دو عددِ شمارنده، با زمانش. */
export async function sample(host, community, i, opt) {
  const o = { ms: 1500, ...(opt || {}) };
  const n = parseInt(i, 10);
  if (!okHost(host) || !Number.isFinite(n) || n < 0) return { ok: false, error: 'ورودی درست نیست' };
  const r = await snmpGet(host, community,
    [O.hcIn + '.' + n, O.hcOut + '.' + n, O.in32 + '.' + n, O.out32 + '.' + n], o);
  if (!r.ok) return r;
  const v = r.binds.map(b => (b && b.value != null ? Number(b.value) : null));
  const inb = v[0] != null ? v[0] : v[2];
  const outb = v[1] != null ? v[1] : v[3];
  if (inb == null || outb == null) return { ok: false, error: 'شمارنده خوانده نشد' };
  return { ok: true, at: Date.now(), in: inb, out: outb, wide: v[0] != null };
}

/* سرعتِ همین حالا: دو نمونه با فاصله، و تفاضلشان. شمارنده که برگردد
   (ریست یا سرریزِ ۳۲بیتی) منفی می‌شود؛ آن نمونه دور انداخته می‌شود،
   نه اینکه عددِ بی‌معنی نشان داده شود. */
export async function speed(host, community, i, opt) {
  const o = opt || {};
  const gap = Math.min(Math.max(parseInt(o.gap, 10) || 2000, 500), 10000);
  const a = await sample(host, community, i, o);
  if (!a.ok) return a;
  await new Promise(r => setTimeout(r, gap));
  const b = await sample(host, community, i, o);
  if (!b.ok) return b;
  const dt = (b.at - a.at) / 1000;
  const di = b.in - a.in, dou = b.out - a.out;
  if (dt <= 0 || di < 0 || dou < 0) return { ok: false, error: 'شمارنده از نو شروع شد' };
  return { ok: true, sec: dt, inBps: di / dt, outBps: dou / dt, in: b.in, out: b.out };
}

/* ==================== نگه‌داشتنِ مصرف ====================
   شمارندهٔ دستگاه «از ابتدا تا حالا» است و با هر ریستِ روتر صفر
   می‌شود. پس خودِ شمارنده به درد «مصرفِ امروز» نمی‌خورد؛ باید
   هر چند دقیقه یک نمونه گرفت و تفاضل‌ها را جمع زد.

   سه جدول، و هیچ‌کدام بزرگ نمی‌شوند:
   • net_dev  — دستگاه‌هایی که خوانده می‌شوند و تنظیماتشان.
   • net_last — آخرین نمونهٔ هر دستگاه (یک ردیف برای هرکدام).
   • net_day  — جمعِ هر روز (یک ردیف برای هر دستگاه در هر روز).

   نمونه‌های خام نگه داشته نمی‌شوند: پنج دقیقه یک بار یعنی سالی صد
   هزار ردیف برای هر دستگاه، و هیچ‌کس نمونهٔ ساعتِ سه بامدادِ خرداد
   را نمی‌خواهد. */
let netReady = false;
export async function ensureNet(env) {
  if (netReady) return;
  await env.DB.batch([
    env.DB.prepare(`CREATE TABLE IF NOT EXISTS net_dev (
      owner     TEXT    NOT NULL DEFAULT '',
      ip        TEXT    NOT NULL DEFAULT '',
      name      TEXT    NOT NULL DEFAULT '',
      community TEXT    NOT NULL DEFAULT 'public',
      iface     INTEGER NOT NULL DEFAULT -1,
      ifname    TEXT    NOT NULL DEFAULT '',
      live      INTEGER NOT NULL DEFAULT 1,
      added     INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (owner, ip)
    )`),
    env.DB.prepare(`CREATE TABLE IF NOT EXISTS net_last (
      owner TEXT NOT NULL DEFAULT '', ip TEXT NOT NULL DEFAULT '',
      ts INTEGER NOT NULL DEFAULT 0,
      inb INTEGER NOT NULL DEFAULT 0, outb INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (owner, ip)
    )`),
    env.DB.prepare(`CREATE TABLE IF NOT EXISTS net_day (
      owner TEXT NOT NULL DEFAULT '', ip TEXT NOT NULL DEFAULT '',
      day TEXT NOT NULL DEFAULT '',
      inb INTEGER NOT NULL DEFAULT 0, outb INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (owner, ip, day)
    )`),
    env.DB.prepare('CREATE INDEX IF NOT EXISTS net_day_d ON net_day(owner, day)')
  ]);
  netReady = true;
}

/* روزِ تهران، نه روزِ گرینویچ: مصرفِ یازدهِ شبِ تهران مالِ همان روز
   است، نه فردا. */
export function tehranDay(at) {
  const d = new Date(at == null ? Date.now() : at);
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Tehran', year: 'numeric', month: '2-digit', day: '2-digit'
  }).format(d);
}

const nAll = async (env, sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results || [];
const nOne = async (env, sql, ...b) => await env.DB.prepare(sql).bind(...b).first();

export async function listDevs(env, owner) {
  await ensureNet(env);
  return await nAll(env, 'SELECT * FROM net_dev WHERE owner=? ORDER BY ip', owner);
}

export async function saveDev(env, owner, d) {
  await ensureNet(env);
  const ip = String(d.ip || '').trim();
  if (!okHost(ip)) return { ok: false, error: 'نشانی درست نیست' };
  const comm = String(d.community || 'public').slice(0, 32);
  if (!/^[\x21-\x7e]{1,32}$/.test(comm)) return { ok: false, error: 'جامعه درست نیست' };
  const iface = Number.isFinite(parseInt(d.iface, 10)) ? parseInt(d.iface, 10) : -1;
  await env.DB.prepare(
    `INSERT INTO net_dev (owner, ip, name, community, iface, ifname, live, added)
     VALUES (?1,?2,?3,?4,?5,?6,?7,?8)
     ON CONFLICT(owner, ip) DO UPDATE SET
       name=?3, community=?4, iface=?5, ifname=?6, live=?7`
  ).bind(owner, ip, String(d.name || '').slice(0, 60), comm, iface,
         String(d.ifname || '').slice(0, 40), d.live === false ? 0 : 1, Date.now()).run();
  return { ok: true };
}

export async function dropDev(env, owner, ip) {
  await ensureNet(env);
  await env.DB.batch([
    env.DB.prepare('DELETE FROM net_dev WHERE owner=? AND ip=?').bind(owner, ip),
    env.DB.prepare('DELETE FROM net_last WHERE owner=? AND ip=?').bind(owner, ip)
  ]);
  return { ok: true };
}

/* جمعِ روزها، از روزِ داده‌شده تا امروز. */
export async function days(env, owner, from) {
  await ensureNet(env);
  return await nAll(env,
    'SELECT ip, day, inb, outb FROM net_day WHERE owner=? AND day>=? ORDER BY day',
    owner, String(from || '').slice(0, 10) || tehranDay(Date.now() - 40 * 86400000));
}

/* ---------- گزارشِ کاوشگرِ داخلِ شبکه ----------
   سرورِ ما بیرونِ شبکهٔ شماست و به ۱۹۲.۱۶۸.x نمی‌رسد؛ همان مسئله‌ای
   که برای گزارشِ Veeam هم بود و همان‌طور حل می‌شود: یک اسکریپتِ کوچک
   داخلِ شبکه می‌دود و نتیجه را به این‌جا می‌فرستد. هیچ پورتی باز
   نمی‌شود — اتصال همیشه از داخل به بیرون است.

   دو چیز می‌آید: فهرستِ آنچه در رنج پیدا شده، و شمارندهٔ بایتِ
   پورت‌هایی که باید شمرده شوند. */
const portName = pn => {
  const k = PORTS.find(x => x.p === pn);
  return k ? k.t : ('پورت ' + pn);
};

export function cleanScan(body) {
  const arr = Array.isArray(body && body.hosts) ? body.hosts : [];
  const hosts = arr.slice(0, 1024).map(h => ({
    ip: String((h && h.ip) || '').slice(0, 45),
    host: String((h && h.host) || '').slice(0, 60),
    kind: String((h && h.kind) || '').slice(0, 40),
    mac: String((h && h.mac) || '').slice(0, 24),
    /* نامِ پورت را خودمان می‌گذاریم، نه آن‌طور که اسکریپت نوشته:
       اسکریپت اَسکی است («winbox»)، صفحه فارسی. */
    ports: (Array.isArray(h && h.ports) ? h.ports : []).slice(0, 16)
      .map(x => parseInt((x && x.port) != null ? x.port : x, 10) || 0)
      .filter(okPort)
      .map(pn => ({ port: pn, t: portName(pn) })),
    snmp: (h && h.snmp && (h.snmp.descr || h.snmp.name)) ? {
      community: String(h.snmp.community || 'public').slice(0, 32),
      descr: String(h.snmp.descr || '').slice(0, 160),
      name: String(h.snmp.name || '').slice(0, 60)
    } : null,
    /* پورت‌های دستگاه، همان‌طور که کاوشگر خواندشان. این‌جا می‌مانند تا
       صفحه بتواند فهرستشان را نشان بدهد: سرور خودش به این دستگاه
       نمی‌رسد که از خودش بپرسد. */
    ifaces: (Array.isArray(h && h.ifaces) ? h.ifaces : []).slice(0, 48)
      .map(f => ({ i: parseInt(f && f.i, 10) || 0,
                   name: String((f && f.name) || '').slice(0, 40),
                   up: !!(f && f.up),
                   in: Math.max(0, Number((f && f.in) || 0)),
                   out: Math.max(0, Number((f && f.out) || 0)) }))
      .filter(f => f.i > 0 && f.name)
  })).filter(h => okHost(h.ip));
  hosts.forEach(h => {
    h.alive = true;
    h.usable = h.snmp ? 'snmp' : '';
    h.how = 'agent';
  });
  return hosts;
}

export async function pushScan(env, owner, body, prev) {
  await ensureNet(env);
  const hosts = cleanScan(body);
  const at = Date.now();

  /* نمونه‌ها: هر کدام یک پورتِ یک دستگاه، با دو شمارنده‌اش. */
  const raw = Array.isArray(body && body.samples) ? body.samples : [];
  let counted = 0, seen = 0;
  for (const x of raw.slice(0, 200)) {
    const ip = String((x && x.ip) || '').trim();
    const inb = Number(x && x.in), outb = Number(x && x.out);
    if (!okHost(ip) || !Number.isFinite(inb) || !Number.isFinite(outb)) continue;
    if (inb < 0 || outb < 0) continue;
    seen++;
    /* دستگاهی که در فهرست نیست، با همین گزارش ثبت می‌شود: کاربر
       نباید دو جا یک کار را بکند. */
    const known = await nOne(env, 'SELECT ip FROM net_dev WHERE owner=? AND ip=?', owner, ip);
    /* نامش را از همان کاوش برمی‌داریم: دستگاهی که در فهرست «۱۹۲٫۱۶۸٫۱٫۱»
       نوشته شود، فردا کسی نمی‌داند کدام است. */
    const seenHost = hosts.find(h => h.ip === ip);
    const nice = (x && x.name) || (seenHost && (seenHost.host ||
                  (seenHost.snmp && seenHost.snmp.name))) || ip;
    if (!known) await saveDev(env, owner, {
      ip, name: String(nice).slice(0, 60),
      community: 'public',
      iface: parseInt(x && x.iface, 10) >= 0 ? parseInt(x.iface, 10) : 0,
      ifname: String((x && x.ifname) || '').slice(0, 40),
      /* کاوشگر خودش می‌فرستد، پس سرور لازم نیست سراغش برود. */
      live: false
    });
    const r = await applySample(env, owner, ip, at, inb, outb);
    if (r.counted) counted++;
  }

  /* فهرست جایگزین نمی‌شود، روی هم می‌نشیند.

     دستگاهی که همین حالا خاموش است در گزارشِ بعدی نیست؛ اگر فهرست
     هر بار از نو ساخته شود، آن دستگاه کلاً غیب می‌شود — و برای
     کارتابلِ فنی «فلان دستگاه دیگر دیده نمی‌شود» خودش خبر است، نه
     چیزی که باید پاک شود. پس هرکدام تاریخِ اولین و آخرین دیده شدن
     را با خود دارد.

     و بی‌پایان هم رشد نمی‌کند: چیزی که سی روز دیده نشده می‌رود، و
     سقفِ کل پانصد است. */
  const old = (prev && Array.isArray(prev.hosts)) ? prev.hosts : [];
  const keep = new Map();
  for (const h of old) {
    if (!h || !okHost(h.ip)) continue;
    keep.set(h.ip, { ...h, first: h.first || h.last || prev.at || at,
                           last: h.last || prev.at || at });
  }
  for (const h of hosts) {
    const was = keep.get(h.ip);
    keep.set(h.ip, { ...h, first: (was && was.first) || at, last: at });
  }
  const DROP = 30 * 86400000;
  const merged = [...keep.values()]
    .filter(h => at - (h.last || 0) < DROP)
    .sort((a, b) => (b.last || 0) - (a.last || 0) || String(a.ip).localeCompare(b.ip))
    .slice(0, 500);

  /* خودِ عکسِ کاوش در تنظیمات می‌نشیند و نوشتنش کارِ مسیر است:
     netuse.js از kartabl.js چیزی وارد نمی‌کند، وگرنه دو پرونده
     دایره‌وار به هم وصل می‌شدند. */
  return { ok: true, hosts: hosts.length, kept: merged.length, samples: seen, counted,
           snapshot: { at, range: String((body && body.range) || '').slice(0, 64),
                       by: String((body && body.by) || '').slice(0, 60), hosts: merged } };
}

/* ---------- یک نوبتِ نمونه‌گیری ----------
   هر دستگاهِ روشن، یک نمونه. تفاضل با نمونهٔ قبلی به حسابِ همان روز
   می‌نشیند.

   سه چیز را رد می‌کنیم: نمونهٔ اول (قبلی‌ای نیست)، شمارندهٔ کم‌شده
   (روتر ریست شده یا شمارندهٔ ۳۲بیتی سرریز کرده)، و فاصلهٔ خیلی
   طولانی (سرور خاموش بوده و تفاضل مالِ یک روز نیست). در هر سه،
   نمونه ثبت می‌شود تا نوبتِ بعد مبنا داشته باشد، ولی چیزی به مصرف
   اضافه نمی‌شود — عددِ ساختگی بدتر از عددِ نداشته است. */
const MAX_GAP = 3 * 3600 * 1000;

/* یک نمونه را روی حسابِ روز می‌نشاند. هم نوبتِ خودِ سرور از این
   می‌گذرد، هم نمونه‌ای که کاوشگرِ داخلِ شبکه می‌فرستد — قاعده یکی
   است، پس در یک جا نوشته شده. */
export async function applySample(env, owner, ip, at, inb, outb) {
  const prev = await nOne(env, 'SELECT * FROM net_last WHERE owner=? AND ip=?', owner, ip);
  /* فاصلهٔ زمانی فقط برای «زیادی دور نباشد» سنجیده می‌شود، نه برای
     نرخ: جمعِ روز از تفاضلِ خودِ شمارنده‌ها می‌آید. دو گزارش در یک
     میلی‌ثانیه هم تفاضلِ واقعی دارند. */
  const good = prev && inb >= prev.inb && outb >= prev.outb &&
               (at - prev.ts) >= 0 && (at - prev.ts) <= MAX_GAP;
  if (good) {
    await env.DB.prepare(
      `INSERT INTO net_day (owner, ip, day, inb, outb) VALUES (?1,?2,?3,?4,?5)
       ON CONFLICT(owner, ip, day) DO UPDATE SET inb=inb+?4, outb=outb+?5`
    ).bind(owner, ip, tehranDay(at), inb - prev.inb, outb - prev.outb).run();
  }
  await env.DB.prepare(
    `INSERT INTO net_last (owner, ip, ts, inb, outb) VALUES (?1,?2,?3,?4,?5)
     ON CONFLICT(owner, ip) DO UPDATE SET ts=?3, inb=?4, outb=?5`
  ).bind(owner, ip, at, inb, outb).run();
  return { ok: true, counted: !!good };
}

/* برنامه‌ای که کاوشگر می‌خواند: برای هر دستگاه، کدام پورت. خالی یعنی
   خودش بهترین را انتخاب کند. */
export async function netPlan(env, owner) {
  await ensureNet(env);
  const rows = await nAll(env,
    'SELECT ip, iface FROM net_dev WHERE owner=? AND iface>=0', owner);
  const plan = {};
  for (const r of rows) plan[r.ip] = r.iface;
  return plan;
}

export async function netTick(env, opt) {
  await ensureNet(env);
  const rows = await nAll(env,
    'SELECT * FROM net_dev WHERE live=1 AND iface>=0');
  let done = 0, skipped = 0;
  for (const d of rows) {
    let s = null;
    try { s = await sample(d.ip, d.community, d.iface, opt); } catch (e) { }
    if (!s || !s.ok) { skipped++; continue; }
    await applySample(env, d.owner, d.ip, s.at, s.in, s.out);
    done++;
  }
  return { ok: true, done, skipped, devs: rows.length };
}
