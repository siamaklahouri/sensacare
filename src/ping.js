/* ==================== پینگ ====================
   مرورگر نمی‌تواند پینگ بگیرد: ICMP در جاوااسکریپتِ صفحه وجود ندارد
   و fetch به یک آی‌پیِ بی‌وب‌سرور فقط خطای شبکه می‌دهد که از «خاموش
   است» قابلِ تشخیص نیست. پس سرور این کار را می‌کند.

   دو جور بررسی، و انتخاب خودکار است:

   • اگر پورت داده شده باشد، یک اتصالِ TCP باز می‌شود. برای این
     دستگاه‌ها همین درست‌تر است: دستگاهِ حضور و غیاب روی ۴۳۷۰ گوش
     می‌دهد، و «روشن بودنِ دستگاه» یعنی همان پورت جواب بدهد — نه
     اینکه ICMP برگردد (خیلی از فایروال‌ها ICMP را می‌اندازند و
     دستگاه سالم را مُرده نشان می‌دهند).

   • بی پورت، همان ping سیستم با یک بسته.

   دو قیدِ امنیتی که از اول گذاشته شد:
   یک) نشانی با الگوی سخت سنجیده می‌شود. این رشته به خطِ فرمان
       می‌رود و «8.8.8.8; rm -rf /» نباید حتی به آن‌جا برسد.
   دو) ping با execFile صدا زده می‌شود، نه exec — یعنی بی پوسته.
       حتی اگر الگو روزی سوراخ شود، آرگومان آرگومان می‌ماند. */
import net from 'node:net';
import { execFile } from 'node:child_process';
import { lookup } from 'node:dns';

/* آی‌پیِ نسخهٔ ۴، یا نامِ میزبان. نقطه‌ها و خط تیره مجازند، بس. */
const HOST_RE = /^[A-Za-z0-9](?:[A-Za-z0-9.\-]{0,119})$/;

export function okHost(h) {
  const s = String(h == null ? '' : h).trim();
  if (!s || s.length > 120) return false;
  if (s.indexOf('..') >= 0) return false;
  return HOST_RE.test(s);
}

export function okPort(p) {
  const n = parseInt(p, 10);
  return Number.isFinite(n) && n >= 1 && n <= 65535;
}

/* کدِ خطای شبکه، به زبانی که روی صفحه خوانده شود.

   «ECONNREFUSED» به‌ویژه مهم است و با «نرسیدن» فرق دارد: یعنی خودِ
   دستگاه جواب داده ولی پشتِ آن پورت کسی نیست. برای دستگاهِ حضور و
   غیاب این خبرِ خوبی است — شبکه سالم است، سرویس بالا نیست. */
function why(code) {
  const map = {
    ECONNREFUSED: 'در دسترس است، ولی پورت بسته است',
    EHOSTUNREACH: 'نشانی در دسترس نیست',
    ENETUNREACH: 'شبکه‌اش در دسترس نیست',
    ENOTFOUND: 'نام پیدا نشد',
    ETIMEDOUT: 'پاسخی نداد',
    EACCES: 'اجازهٔ اتصال نبود'
  };
  return map[code] || (code ? String(code) : 'خطا');
}

/* اتصالِ TCP: باز شد یعنی زنده. */
export function tcpProbe(host, port, ms) {
  const wait = Math.min(Math.max(parseInt(ms, 10) || 2500, 300), 5000);
  return new Promise(resolve => {
    const t0 = Date.now();
    let done = false;
    const end = (ok, error) => {
      if (done) return;
      done = true;
      try { sock.destroy(); } catch (e) { }
      resolve({ ok, ms: Date.now() - t0, how: 'tcp', error: error || '' });
    };
    const sock = net.connect({ host, port, family: 4 });
    sock.setTimeout(wait);
    sock.on('connect', () => end(true, ''));
    sock.on('timeout', () => end(false, 'پاسخی نداد'));
    sock.on('error', e => end(false, why((e && e.code) || '')));
  });
}

/* و بی پورت، همان ping سیستم — یک بسته، دو ثانیه صبر. */
export function icmpProbe(host, ms) {
  const wait = Math.min(Math.max(parseInt(ms, 10) || 2500, 300), 5000);
  const sec = Math.max(1, Math.round(wait / 1000));
  return new Promise(resolve => {
    const t0 = Date.now();
    execFile('ping', ['-n', '-c', '1', '-W', String(sec), host],
      { timeout: wait + 800 }, (err, out) => {
        const took = Date.now() - t0;
        if (!err) {
          /* زمانِ خودِ ping دقیق‌تر از زمانِ ماست */
          const m = String(out || '').match(/time[=<]\s*([\d.]+)\s*ms/i);
          return resolve({ ok: true, ms: m ? Math.round(parseFloat(m[1])) : took,
                           how: 'icmp', error: '' });
        }
        resolve({ ok: false, ms: took, how: 'icmp', error: 'پاسخی نداد' });
      });
  });
}

export async function probe(host, port, ms) {
  if (!okHost(host)) return { ok: false, ms: 0, how: '', error: 'نشانی درست نیست' };
  if (port === 0 || port === '' || port === null || port === undefined)
    return icmpProbe(host, ms);
  if (!okPort(port)) return { ok: false, ms: 0, how: '', error: 'پورت درست نیست' };
  return tcpProbe(host, parseInt(port, 10), ms);
}

/* ==================== تلنت ====================
   «telnet IP PORT» در عمل یعنی: وصل شو، شاید یک خط بفرست، و ببین
   آن‌طرف چه می‌گوید. برای عیب‌یابیِ دستگاه همین کافی است — بنرِ
   SSH، جوابِ HTTP، یا سکوتِ یک پورتِ باز.

   این یک پایانهٔ واقعی نیست و عمداً هم نیست: پایانهٔ زنده یعنی
   نشستِ باز روی سرور، و برای «ببینم این پورت چه می‌گوید» گران و
   خطرناک است. یک رفت‌وبرگشت، سقفِ دو کیلوبایت، و قطع.

   پاسخ متنی است و ممکن است هر بایتی داشته باشد؛ نویسه‌های کنترلی
   برداشته می‌شوند تا صفحه را به هم نریزند. */
export function telnet(host, port, send, ms) {
  const wait = Math.min(Math.max(parseInt(ms, 10) || 2500, 500), 6000);
  const line = String(send == null ? '' : send).slice(0, 200);
  return new Promise(resolve => {
    const t0 = Date.now();
    let out = Buffer.alloc(0);
    let done = false;
    const end = (ok, error) => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      try { sock.destroy(); } catch (e) { }
      /* بایت‌ها را به متن می‌آوریم و نویسه‌های کنترلی را برمی‌داریم،
         جز خطِ تازه و تب که خودِ متن‌اند. */
      const text = out.toString('utf8')
        .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, '')
        .slice(0, 2000);
      resolve({ ok, ms: Date.now() - t0, text, bytes: out.length, error: error || '' });
    };
    const sock = net.connect({ host, port, family: 4 });
    sock.setTimeout(wait);
    /* حتی اگر دستگاه ساکت بماند، «وصل شد» خودش یک خبر است. */
    const timer = setTimeout(() => end(true, ''), wait);
    sock.on('connect', () => {
      if (!line) return;
      /* درخواستِ HTTP با یک خطِ خالی تمام می‌شود، وگرنه وب‌سرور تا
         ابد منتظرِ بقیهٔ سرآیندها می‌ماند و هیچ نمی‌گوید. برای
         پروتکل‌های خطی یک خطِ خالیِ اضافه بی‌ضرر است، ولی بی‌دلیل
         هم نمی‌فرستیمش. */
      var tail = /HTTP\/\d/i.test(line) ? '\r\n\r\n' : '\r\n';
      try { sock.write(line + tail); } catch (e) { }
    });
    sock.on('data', d => {
      out = Buffer.concat([out, d]).subarray(0, 2048);
      if (out.length >= 2048) end(true, '');
    });
    sock.on('timeout', () => end(out.length > 0, out.length ? '' : 'پاسخی نداد'));
    sock.on('error', e => end(false, why((e && e.code) || '')));
    sock.on('close', () => end(out.length > 0, out.length ? '' : ''));
  });
}

/* ---------- تلنتِ زنده، مرحله‌به‌مرحله ----------
   کاربر گفت «می‌خواهم مراحلش را ببینم؛ ببینم تا کجا می‌رود یا کجا
   گیر می‌کند». پس این جریان دو چیز می‌فرستد:

   • خطِ خامِ خودِ دستگاه، همان لحظه که می‌آید.
   • و کنارش مرحله‌ها: نام پیدا شد، در حال اتصال، وصل شد، این خط
     رفت، در انتظارِ پاسخ، اولین پاسخ رسید، ... هرکدام با زمانِ
     خودش از لحظهٔ صفر.

   مرحله‌ها با نویسهٔ ۰x1E شروع می‌شوند و بدنه‌شان JSON است. این
   نویسه هرگز از خودِ دستگاه رد نمی‌شود، چون نویسه‌های کنترلی از
   دادهٔ دستگاه برداشته می‌شوند — پس مرز قاطع است و قاطی نمی‌شود.

   سه مرز مثلِ قبل: سقفِ ۶۴ کیلوبایت، دوازده ثانیه سکوت، و قطعِ
   کاربر. یکی هم تازه است: اگر اتصال خودش باز نشود، هشت ثانیه
   بیشتر منتظر نمی‌مانیم و همان‌جا می‌گوییم کجا ماند — وگرنه
   «گیر کردن» از «دیر جواب دادن» پیدا نبود. */
const IP4_RE = /^\d{1,3}(?:\.\d{1,3}){3}$/;

/* شمارِ بایت و ثانیه با رقمِ فارسی می‌رود، مثلِ بقیهٔ صفحه. نشانی و
   کدِ خطا نه: «۱۲۷.۰.۰.۱» نشانی نیست. */
const faN = n => String(n).replace(/[0-9]/g, d => '۰۱۲۳۴۵۶۷۸۹'[+d]);

export function telnetStream(host, port, send, opt) {
  const o = opt || {};
  const idle = Math.min(Math.max(parseInt(o.idle, 10) || 12000, 1000), 30000);
  const connMs = Math.min(Math.max(parseInt(o.connect, 10) || 8000, 500), 20000);
  const cap = 64 * 1024;
  const line = String(send == null ? '' : send).slice(0, 200);

  return new ReadableStream({
    start(ctrl) {
      const enc = new TextEncoder();
      const dec = new TextDecoder('utf-8');
      const t0 = Date.now();
      let got = 0, done = false, sock = null, tConn = null, lastRecv = 0;

      const put = txt => {
        try { ctrl.enqueue(enc.encode(txt)); } catch (e) { }
      };
      /* یک مرحله: کدام مرحله، در چه حالی، با چه متنی، در چندم. */
      const step = (id, st, t, note) => {
        if (done) return;
        put('\u001e' + JSON.stringify({ id, st, t, ms: Date.now() - t0,
                                        note: note == null ? '' : String(note) }) + '\n');
      };
      const say = txt => { if (!done && txt) put(txt); };
      const fin = (st, id, t, note) => {
        if (done) return;
        clearTimeout(tConn);
        step(id, st, t, note);
        done = true;
        try { ctrl.close(); } catch (e) { }
        try { if (sock) sock.destroy(); } catch (e) { }
      };

      step('addr', 'ok', 'نشانی پذیرفته شد', host + ':' + port);

      const connect = ip => {
        step('conn', 'run', 'در حال اتصال به ' + ip + ':' + port);
        tConn = setTimeout(function () {
          fin('bad', 'conn', 'اتصال باز نشد',
            'هشت ثانیه هیچ جوابی نیامد — یا فایروال وسط است یا دستگاه خاموش');
        }, connMs);

        sock = net.connect({ host: ip, port, family: 4 });
        sock.setTimeout(idle);

        sock.on('connect', () => {
          clearTimeout(tConn);
          step('conn', 'ok', 'وصل شد');
          if (line) {
            const tail = /HTTP\/\d/i.test(line) ? '\r\n\r\n' : '\r\n';
            try { sock.write(line + tail); } catch (e) { }
            step('send', 'ok', 'این خط فرستاده شد', line);
          } else {
            step('send', 'skip', 'چیزی فرستاده نشد', 'فقط گوش می‌دهیم که دستگاه خودش چه می‌گوید');
          }
          step('wait', 'run', 'در انتظارِ پاسخِ دستگاه…');
        });

        sock.on('data', d => {
          const first = got === 0;
          got += d.length;
          if (first) step('wait', 'ok', 'اولین پاسخ رسید', faN(d.length) + ' بایت');
          say(dec.decode(d, { stream: true })
            .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, ''));
          /* هر تکه یک مرحله نشود؛ ده بار در ثانیه بس است. */
          const now = Date.now();
          if (!first && now - lastRecv > 100) {
            lastRecv = now;
            step('recv', 'run', 'در حال دریافت', faN(got) + ' بایت');
          }
          if (got >= cap) fin('ok', 'recv', 'به سقفِ ۶۴ کیلوبایت رسید', faN(got) + ' بایت');
        });

        sock.on('timeout', () => {
          if (got) fin('ok', 'recv', 'دستگاه ساکت شد',
            faN(got) + ' بایت گرفته شد، بعد ' + faN(Math.round(idle / 1000)) + ' ثانیه حرفی نزد');
          else fin('bad', 'wait', 'وصل شد، ولی دستگاه چیزی نگفت',
            faN(Math.round(idle / 1000)) + ' ثانیه سکوت — شاید منتظرِ فرمان است');
        });

        sock.on('error', e => {
          const code = (e && e.code) || '';
          fin('bad', got ? 'recv' : 'conn', why(code), code);
        });

        sock.on('close', () => {
          if (got) fin('ok', 'recv', 'اتصال از آن‌طرف بسته شد', faN(got) + ' بایت');
          else fin('bad', 'conn', 'اتصال بسته شد', 'بی آنکه چیزی بیاید');
        });
      };

      /* نامِ میزبان جدا از اتصال حل می‌شود، تا اگر همین‌جا بماند
         معلوم باشد که گیرِ کار DNS است، نه دستگاه. */
      if (IP4_RE.test(host)) {
        connect(host);
      } else {
        step('dns', 'run', 'در حال یافتنِ نشانیِ ' + host);
        lookup(host, { family: 4 }, (err, addr) => {
          if (done) return;
          if (err || !addr) {
            fin('bad', 'dns', 'نام پیدا نشد', (err && err.code) || '');
            return;
          }
          step('dns', 'ok', 'نام پیدا شد', addr);
          connect(addr);
        });
      }

      this._stop = () => {
        if (done) return;
        clearTimeout(tConn);
        done = true;
        try { ctrl.close(); } catch (e) { }
        try { if (sock) sock.destroy(); } catch (e) { }
      };
    },
    cancel() { if (this._stop) this._stop(); }
  });
}

/* ---------- چند پورت، یک نشانی ----------
   «این پورت از بیرون باز است یا نه؟» — همان کاری که سایت‌های
   port checker می‌کنند، از روی سرورِ خودمان.

   دو مرز عمدی: سقفِ شمارِ پورت‌ها، و موازیِ محدود. این ابزار برای
   دیدنِ چند پورتِ مشخص است، نه برای جاروکردنِ یک شبکه — و همان
   جاروکردن بود که یک بار شبکهٔ شرکت را خواباند. */
export const PORT_NAMES = {
  20: 'FTP (داده)', 21: 'FTP', 22: 'SSH', 23: 'تلنت', 25: 'ایمیل (SMTP)',
  53: 'DNS', 80: 'وب', 110: 'ایمیل (POP3)', 143: 'ایمیل (IMAP)',
  161: 'SNMP', 389: 'LDAP', 443: 'وبِ امن', 445: 'اشتراکِ ویندوز',
  465: 'ایمیل امن (SMTPS)', 587: 'ایمیل (ارسال)', 993: 'IMAP امن',
  995: 'POP3 امن', 1194: 'OpenVPN', 1433: 'SQL Server', 1723: 'PPTP',
  3306: 'MySQL', 3389: 'ریموت دسکتاپ', 4370: 'حضور و غیاب',
  5060: 'تلفنِ تحتِ شبکه (SIP)', 5432: 'PostgreSQL', 5900: 'VNC',
  8080: 'وب (جایگزین)', 8291: 'وین‌باکس (میکروتیک)', 8443: 'وبِ امن (جایگزین)',
  8728: 'API میکروتیک', 9100: 'چاپگر', 27017: 'MongoDB'
};

export const MAX_PORTS = 32;

export async function manyPorts(host, ports, opt) {
  const o = opt || {};
  const ms = Math.min(Math.max(parseInt(o.ms, 10) || 1800, 300), 5000);
  const wide = Math.min(Math.max(parseInt(o.wide, 10) || 12, 1), 24);
  if (!okHost(host)) return { ok: false, error: 'نشانی درست نیست' };

  const list = [];
  for (const p of (Array.isArray(ports) ? ports : [])) {
    const n = parseInt(p, 10);
    if (okPort(n) && list.indexOf(n) < 0) list.push(n);
    if (list.length >= MAX_PORTS) break;
  }
  if (!list.length) return { ok: false, error: 'پورتی برای بررسی نیست' };

  const out = [];
  let i = 0;
  const one = async () => {
    for (;;) {
      const ix = i++;
      if (ix >= list.length) return;
      const p = list[ix];
      let r = null;
      try { r = await tcpProbe(host, p, ms); } catch (e) { }
      out.push({ port: p, name: PORT_NAMES[p] || '',
                 open: !!(r && r.ok), ms: (r && r.ms) || 0,
                 why: (r && r.error) || '' });
    }
  };
  await Promise.all(Array.from({ length: Math.min(wide, list.length) }, one));
  out.sort((a, b) => a.port - b.port);
  return { ok: true, host, rows: out, open: out.filter(x => x.open).length };
}

/* «۸۰، ۴۴۳، ۸۰۰۰-۸۰۱۰» → فهرستِ عددها. رقمِ فارسی هم می‌فهمد. */
export function parsePorts(txt) {
  const s = String(txt == null ? '' : txt)
    .replace(/[۰-۹]/g, d => '۰۱۲۳۴۵۶۷۸۹'.indexOf(d))
    .replace(/[٠-٩]/g, d => '٠١٢٣٤٥٦٧٨٩'.indexOf(d));
  const out = [];
  for (const part of s.split(/[,،\s]+/)) {
    if (!part) continue;
    const m = /^(\d{1,5})-(\d{1,5})$/.exec(part);
    if (m) {
      const a = parseInt(m[1], 10), b = parseInt(m[2], 10);
      if (!okPort(a) || !okPort(b) || b < a) continue;
      /* بازهٔ بلند به سقف بریده می‌شود، نه اینکه رد شود */
      for (let p = a; p <= b && out.length < MAX_PORTS; p++)
        if (out.indexOf(p) < 0) out.push(p);
      continue;
    }
    const n = parseInt(part, 10);
    if (okPort(n) && out.indexOf(n) < 0 && out.length < MAX_PORTS) out.push(n);
  }
  return out;
}
