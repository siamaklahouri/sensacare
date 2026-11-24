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

/* ---------- تلنتِ زنده ----------
   همان کار، ولی به‌جای یک جوابِ یک‌جا، هرچه می‌آید همان لحظه
   فرستاده می‌شود. کاربر گفت «کامل نمایش بده وقتی دارد تلنت گرفته
   می‌شود» و حق داشت: دستگاهی که دو ثانیه بعد حرف می‌زند، در حالتِ
   یک‌جا اصلاً دیده نمی‌شد.

   سه مرز:
   • سقفِ متن ۶۴ کیلوبایت است، نه دو. چیزی که زنده می‌آید را آدم
     می‌خوانَد و می‌بندد؛ دو کیلوبایت وسطِ حرف می‌بُرید.
   • بی‌حرفیِ طولانی هم پایان است: اگر دستگاه دوازده ثانیه ساکت
     بماند، بسته می‌شود. نشستِ باز روی سرور نمی‌ماند.
   • قطعِ کاربر هم بسته‌اش می‌کند: وقتی مرورگر خواندن را رها کند،
     cancel صدا می‌خورد و سوکت می‌رود.

   نویسه‌های کنترلی تکه‌به‌تکه برداشته می‌شوند. این تنها جایی است که
   با متنِ تکه‌شده مشکل می‌سازد — یک نویسهٔ چندبایتی ممکن است وسطِ
   دو تکه بیفتد — پس رمزگشایی با TextDecoder و stream:true انجام
   می‌شود که خودش تکه‌ها را به هم می‌چسباند. */
export function telnetStream(host, port, send, opt) {
  const idle = Math.min(Math.max(parseInt((opt || {}).idle, 10) || 12000, 1000), 30000);
  const cap = 64 * 1024;
  const line = String(send == null ? '' : send).slice(0, 200);

  return new ReadableStream({
    start(ctrl) {
      const enc = new TextEncoder();
      const dec = new TextDecoder('utf-8');
      let got = 0, done = false;
      const say = txt => {
        if (done || !txt) return;
        try { ctrl.enqueue(enc.encode(txt)); } catch (e) { }
      };
      const end = msg => {
        if (done) return;
        done = true;
        if (msg) { try { ctrl.enqueue(enc.encode(msg)); } catch (e) { } }
        try { ctrl.close(); } catch (e) { }
        try { sock.destroy(); } catch (e) { }
      };

      const sock = net.connect({ host, port, family: 4 });
      sock.setTimeout(idle);
      sock.on('connect', () => {
        say('• وصل شد\n');
        if (!line) return;
        const tail = /HTTP\/\d/i.test(line) ? '\r\n\r\n' : '\r\n';
        try { sock.write(line + tail); } catch (e) { }
      });
      sock.on('data', d => {
        got += d.length;
        say(dec.decode(d, { stream: true })
          .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, ''));
        if (got >= cap) end('\n• به سقفِ ۶۴ کیلوبایت رسید\n');
      });
      sock.on('timeout', () => end(got ? '\n• دستگاه ساکت شد\n' : '• پاسخی نداد\n'));
      sock.on('error', e => end('• ' + why((e && e.code) || '') + '\n'));
      sock.on('close', () => end(got ? '\n• اتصال بسته شد\n' : ''));

      this._stop = () => end('');
    },
    cancel() { if (this._stop) this._stop(); }
  });
}
