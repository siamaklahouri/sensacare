/* ==================== مصرف اینترنت ====================
   «رنجِ شبکه‌ام را بدهم و خودش کلِ ای‌پی‌ها را بخواند و مصرفِ حجم را
   بگوید.»

   دو مرحله، چون ذاتاً دو کارند:

   ۱) کاوش: رنج را می‌زنیم، هر نشانی را می‌پرسیم، و همان‌طور که جواب
      می‌آید روی صفحه می‌نشیند — نه یکجا در پایان. کنارِ هر نشانی
      می‌نویسیم چه چیزی آن‌جاست و از کجا می‌شود مصرفش را خواند.

   ۲) مصرف: دستگاهی که SNMP دارد، شمارندهٔ بایتِ پورت‌هایش را می‌دهد.
      پورتِ اینترنت را خودِ آدم انتخاب می‌کند (ما نام و سرعت و
      بالا/پایین بودنش را می‌آوریم)، و از آن به بعد سرور هر پنج
      دقیقه یک نمونه می‌گیرد و تفاضل‌ها می‌شود مصرفِ آن روز.

   هیچ رمزی لازم نیست: نه رمزِ ویندوز، نه دامین. نامِ سیستم‌ها هم از
   همان DNSِ دامین می‌آید. */
window.NETUSE = (function () {
  var devs = [], dayRows = [], today = '', found = [], scanning = null, chart = null;
  var agent = null, hasKey = false;

  var $ = function (id) { return document.getElementById(id); };

  /* ---------- اندازه‌ها، به زبانِ آدم ---------- */
  function bytes(n) {
    var v = Number(n) || 0;
    if (v >= 1024 * 1024 * 1024 * 1024) return fa((v / 1099511627776).toFixed(2)).replace('.', '٫') + ' ترا';
    if (v >= 1024 * 1024 * 1024) return fa((v / 1073741824).toFixed(2)).replace('.', '٫') + ' گیگ';
    if (v >= 1024 * 1024) return fa((v / 1048576).toFixed(1)).replace('.', '٫') + ' مگ';
    if (v >= 1024) return fa(Math.round(v / 1024)) + ' کیلو';
    return fa(v) + ' بایت';
  }
  function bits(bps) {
    var v = (Number(bps) || 0) * 8;
    if (v >= 1e9) return fa((v / 1e9).toFixed(2)).replace('.', '٫') + ' گیگابیت';
    if (v >= 1e6) return fa((v / 1e6).toFixed(1)).replace('.', '٫') + ' مگابیت';
    if (v >= 1e3) return fa(Math.round(v / 1e3)) + ' کیلوبیت';
    return fa(Math.round(v)) + ' بیت';
  }

  /* روزِ میلادیِ ذخیره‌شده → شمسی، برای نمودار و جمعِ ماه */
  /* تبدیلِ روزِ ذخیره‌شده (میلادی) به شمسی. خودِ تابعِ کارتابل
     {jy,jm,jd} می‌دهد، نه آرایه — یک بار همین اشتباه شد و نمودار با
     برچسبِ «NaN» بالا آمد. */
  function jal(iso) {
    var p = String(iso).split('-').map(Number);
    if (!p[0] || !p[1] || !p[2]) return null;
    try {
      var j = (typeof gregorianToJalali === 'function')
        ? gregorianToJalali(p[0], p[1], p[2]) : null;
      if (j && j.jy) return { y: j.jy, m: j.jm, d: j.jd };
    } catch (e) { }
    return null;
  }

  /* روی نسخهٔ پشتیبانِ آفلاین هیچ سروری نیست: هر درخواستی از این‌جا
     یک فایلِ نرسیده است و صفحه را هم به خطا می‌اندازد. */
  function offline() { return !!window.KARTABL_OFFLINE; }

  function api(path, body, raw) {
    if (offline()) return Promise.reject(new Error('آفلاین'));
    var o = { method: body ? 'POST' : 'GET', headers: { 'Content-Type': 'application/json' } };
    if (body) o.body = JSON.stringify(body);
    return fetch(KARTABL_API + path, o).then(function (r) { return raw ? r : r.json(); });
  }

  /* ---------- کاوشِ رنج ---------- */
  function scan() {
    var inp = $('nuRange');
    var range = inp ? inp.value.trim() : '';
    if (offline()) { var s0 = $('nuSay'); if (s0) { $('nuProg').classList.add('on');
      s0.textContent = 'این نسخهٔ پشتیبان است؛ کاوش فقط روی خودِ کارتابل کار می‌کند.'; } return; }
    if (!range) { if (inp) inp.focus(); return; }
    if (scanning) { stopScan(); return; }

    found = [];
    renderFound();
    var btn = $('nuScanBtn'), prog = $('nuProg'), fill = $('nuFill'), say = $('nuSay');
    btn.textContent = 'بس است';
    prog.classList.add('on');
    fill.style.width = '0%';
    say.textContent = 'شروع…';

    var ac = (typeof AbortController === 'function') ? new AbortController() : null;
    scanning = function () { try { if (ac) ac.abort(); } catch (e) { } };
    var over = function (msg) {
      scanning = null;
      btn.textContent = 'کاوش';
      if (msg) say.textContent = msg;
    };

    fetch(KARTABL_API + '/netuse/scan', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ range: range }), signal: ac ? ac.signal : undefined
    }).then(function (res) {
      if (!res.ok || !res.body || !res.body.getReader) {
        return res.json().then(function (j) {
          over((j && j.error) || 'کاوش انجام نشد');
        }).catch(function () { over('کاوش انجام نشد'); });
      }
      var rd = res.body.getReader(), dec = new TextDecoder('utf-8'), buf = '';
      var pump = function () {
        return rd.read().then(function (r) {
          if (r.done) { over(''); return; }
          buf += dec.decode(r.value, { stream: true });
          var i;
          while ((i = buf.indexOf('\n')) >= 0) {
            var line = buf.slice(0, i); buf = buf.slice(i + 1);
            if (!line) continue;
            var ev = null;
            try { ev = JSON.parse(line); } catch (e) { continue; }
            onScan(ev);
          }
          return pump();
        });
      };
      return pump();
    }).catch(function (e) {
      if (e && e.name === 'AbortError') { over('ایستاد'); return; }
      over('به سرور نرسید');
    });
  }

  function stopScan() { if (scanning) scanning(); }

  function onScan(ev) {
    var say = $('nuSay'), fill = $('nuFill');
    if (ev.k === 'start') { say.textContent = 'کاوشِ ' + fa(ev.n) + ' نشانی…'; return; }
    if (ev.k === 'tick') {
      fill.style.width = Math.round(ev.at / ev.n * 100) + '%';
      say.textContent = fa(ev.at) + ' از ' + fa(ev.n) + ' — ' + fa(ev.found) + ' دستگاه پیدا شد';
      return;
    }
    if (ev.k === 'host') { found.push(ev); renderFound(); return; }
    if (ev.k === 'done') {
      fill.style.width = '100%';
      say.textContent = fa(ev.found) + ' دستگاه از ' + fa(ev.n) + ' نشانی، در ' +
        fa(Math.round(ev.ms / 1000)) + ' ثانیه';
      /* دو جور «خروجی ندارد» هست و توضیحشان یکی نیست:
         هیچ‌کس جواب نداد، یا جواب دادند ولی هیچ‌کدام شمارنده نمی‌دهند.
         بی توضیح، هر دو «خراب است» به نظر می‌رسند. */
      var w = document.getElementById('nuWhy');
      if (w) {
        var withSnmp = found.filter(function (h) { return h.snmp; }).length;
        if (!ev.found) {
          w.hidden = false;
          w.textContent = 'هیچ نشانی‌ای جواب نداد. کاوشِ این کادر از روی سرور است و ' +
            'به شبکهٔ داخلیِ شما نمی‌رسد؛ برای آن، کاوشگر را روی یک سیستمِ همان شبکه بگذارید.';
        } else if (!withSnmp) {
          w.hidden = false;
          w.textContent = fa(ev.found) + ' دستگاه پیدا شد، ولی هیچ‌کدام SNMP نمی‌دهند — ' +
            'مصرف از همان خوانده می‌شود.';
        } else {
          w.hidden = true;
          w.textContent = '';
        }
      }
    }
  }

  /* «۳ دقیقه پیش»، «دیروز» — برای ستونِ آخرین دیده شدن */
  function ago(at) {
    if (!at) return '';
    var m = Math.max(0, Math.round((Date.now() - at) / 60000));
    if (m < 60) return fa(m) + ' دقیقه پیش';
    var h = Math.round(m / 60);
    if (h < 24) return fa(h) + ' ساعت پیش';
    return fa(Math.round(h / 24)) + ' روز پیش';
  }

  function renderFound() {
    var b = $('nuFoundBody');
    if (!b) return;
    if (!found.length) {
      b.innerHTML = '<tr><td colspan="6" class="nu-dim" style="text-align:center;padding:14px;">' +
        'هنوز کاوشی انجام نشده</td></tr>';
      return;
    }
    /* «آخرین بار دیده شد»: دستگاهی که در گزارشِ آخر نبود، خاموش است
       یا از شبکه رفته — هر دو خبرند، پس از فهرست پاک نمی‌شود. */
    var newest = 0;
    found.forEach(function (h) { if (h.last && h.last > newest) newest = h.last; });

    b.innerHTML = found.map(function (h, i) {
      if (!h.alive) {
        /* نشانیِ تنهایی که پرسیده شد و جواب نداد: بگو چه چیزی امتحان شد. */
        return '<tr class="nu-dead"><td>' + fa(i + 1) + '</td>' +
          '<td class="nu-ip">' + escapeHtml(h.ip) + '</td>' +
          '<td colspan="4" class="nu-dim">جواب نداد — نه پینگ، نه SNMP، و نه هیچ‌کدام از ' +
          'پورت‌های ' + fa((h.tried || []).join('، ')) + '</td></tr>';
      }
      var tags = (h.ports || []).map(function (p) {
        return '<span class="nu-tag">' + escapeHtml(p.t) + '</span>';
      }).join('');
      if (h.snmp) tags = '<span class="nu-tag is-good">SNMP</span>' + tags;
      var has = devs.some(function (d) { return d.ip === h.ip; });
      /* یک دقیقه رواداری، چون همهٔ ردیف‌های یک گزارش یک زمان ندارند */
      var gone = newest && h.last && (newest - h.last) > 60000;
      return '<tr' + (gone ? ' class="nu-gone"' : '') + '>' +
        '<td>' + fa(i + 1) + '</td>' +
        '<td class="nu-ip">' + escapeHtml(h.ip) + '</td>' +
        '<td>' + escapeHtml(h.host || '') +
          (gone ? ' <span class="nu-tag">' + ago(h.last) + '</span>' : '') + '</td>' +
        '<td>' + escapeHtml(h.kind || (h.snmp ? h.snmp.name : '') || '') + '</td>' +
        '<td>' + (tags || '<span class="nu-dim">فقط پینگ</span>') + '</td>' +
        '<td>' + (h.snmp
          ? (has ? '<span class="nu-dim">در فهرست هست</span>'
                 : '<button class="btn btn-brass btn-sm" data-nu-add="' + i + '">افزودن</button>')
          : '<span class="nu-dim">' + (h.usable === 'mikrotik'
              ? 'میکروتیک است، ولی SNMP‌اش خاموش است' : 'شمارنده‌ای نمی‌دهد') + '</span>') +
        '</td></tr>';
    }).join('');
  }

  /* ---------- دستگاه‌های ثبت‌شده ---------- */
  function load() {
    return api('/netuse/devs').then(function (j) {
      devs = (j && j.devs) || [];
      dayRows = (j && j.days) || [];
      today = (j && j.today) || '';
      agent = (j && j.scan) || null;
      hasKey = !!(j && j.agent);
      /* گزارشِ کاوشگرِ داخلِ شبکه همان فهرستِ «پیدا شد» را پر می‌کند،
         مگر همین حالا کاوشی از روی سرور زده باشیم. */
      if (agent && agent.hosts && !found.length) found = agent.hosts.slice();
      render();
      renderFound();
      renderAgent();
    }).catch(function () { });
  }

  /* ---------- کاوشگرِ داخلِ شبکه ----------
     سرور بیرونِ شبکهٔ کاربر است و به ۱۹۲.۱۶۸.x نمی‌رسد. این تکه
     می‌گوید آخرین گزارشِ داخلی کِی رسیده، و اگر نرسیده، چه باید کرد. */
  function renderAgent() {
    var box = $('nuAgent');
    if (!box) return;
    if (agent && agent.at) {
      var mins = Math.max(0, Math.round((Date.now() - agent.at) / 60000));
      box.className = 'nu-agent is-on';
      box.innerHTML =
        '<b>کاوشگرِ داخلِ شبکه فعال است.</b> آخرین گزارش ' +
        (mins < 1 ? 'همین الان' : (mins < 60 ? fa(mins) + ' دقیقه پیش'
          : fa(Math.round(mins / 60)) + ' ساعت پیش')) +
        (agent.by ? ' از <b>' + escapeHtml(agent.by) + '</b>' : '') +
        (agent.range ? ' — رنجِ ' + escapeHtml(agent.range) : '') +
        ' · ' + fa((agent.hosts || []).length) + ' دستگاه' +
        (mins > 30 ? '<br><span class="nu-dim">بیش از نیم ساعت است که گزارشی نیامده؛ ' +
          'شاید آن سیستم خاموش است یا کارِ زمان‌بندی‌شده نمی‌دود.</span>' : '');
      return;
    }
    box.className = 'nu-agent';
    box.innerHTML =
      '<span>برای شبکهٔ داخلی، کاوشگر را روی یک سیستمِ همان شبکه بگذارید.</span>' +
      '<span class="nu-get">' +
        '<a class="btn btn-brass btn-sm" href="/net-push.ps1.txt" download="net-push.ps1.txt">' +
          '⬇ اسکریپت</a>' +
        '<a class="btn btn-ghost btn-sm" href="/net-push-readme.txt" target="_blank" ' +
          'rel="noopener">راهنما</a>' +
      '</span>';
  }

  function dayOf(ip, iso) {
    for (var i = 0; i < dayRows.length; i++)
      if (dayRows[i].ip === ip && dayRows[i].day === iso) return dayRows[i];
    return null;
  }

  /* جمعِ ماهِ شمسیِ جاری برای یک دستگاه (یا همه، با ip خالی) */
  function monthSum(ip) {
    var now = jal(today), inb = 0, outb = 0;
    dayRows.forEach(function (r) {
      if (ip && r.ip !== ip) return;
      var j = jal(r.day);
      if (!j || !now || j.y !== now.y || j.m !== now.m) return;
      inb += r.inb; outb += r.outb;
    });
    return { inb: inb, outb: outb };
  }
  function todaySum(ip) {
    var inb = 0, outb = 0;
    dayRows.forEach(function (r) {
      if (ip && r.ip !== ip) return;
      if (r.day !== today) return;
      inb += r.inb; outb += r.outb;
    });
    return { inb: inb, outb: outb };
  }

  function render() {
    renderCards();
    renderDevs();
    renderChart();
  }

  function renderCards() {
    var wrap = $('nuCards');
    if (!wrap) return;
    var t = todaySum(''), mo = monthSum('');
    var top = null;
    devs.forEach(function (d) {
      var s = monthSum(d.ip);
      if (!top || (s.inb + s.outb) > top.v) top = { n: d.name || d.ip, v: s.inb + s.outb };
    });
    wrap.innerHTML =
      '<div class="stat" style="--accent:var(--c1); --tint:var(--t1)"><div class="stat-head">' +
        '<span class="stat-ic">📶</span><span class="stat-lbl">دستگاه‌های زیرِ نظر</span></div>' +
        '<div class="stat-val">' + fa(devs.length) + '</div></div>' +
      '<div class="stat" style="--accent:var(--c2); --tint:var(--t2)"><div class="stat-head">' +
        '<span class="stat-ic">📅</span><span class="stat-lbl">مصرفِ امروز</span></div>' +
        '<div class="stat-val">' + bytes(t.inb + t.outb) + '</div>' +
        '<div class="stat-sub">دریافت ' + bytes(t.inb) + ' · ارسال ' + bytes(t.outb) + '</div></div>' +
      '<div class="stat" style="--accent:var(--c3); --tint:var(--t3)"><div class="stat-head">' +
        '<span class="stat-ic">🗓</span><span class="stat-lbl">این ماه</span></div>' +
        '<div class="stat-val">' + bytes(mo.inb + mo.outb) + '</div>' +
        '<div class="stat-sub">دریافت ' + bytes(mo.inb) + ' · ارسال ' + bytes(mo.outb) + '</div></div>' +
      '<div class="stat"><div class="stat-head"><span class="stat-ic">🔝</span>' +
        '<span class="stat-lbl">پرمصرف‌ترین</span></div>' +
        '<div class="stat-val" style="font-size:15px;">' + (top ? escapeHtml(top.n) : '—') + '</div>' +
        '<div class="stat-sub">' + (top ? bytes(top.v) + ' این ماه' : 'هنوز چیزی ثبت نشده') + '</div></div>';
  }

  function renderDevs() {
    var b = $('nuDevBody');
    if (!b) return;
    if (!devs.length) {
      b.innerHTML = '<tr><td colspan="8" class="nu-dim" style="text-align:center;padding:14px;">' +
        'هنوز دستگاهی اضافه نشده — رنجِ شبکه را بالا بزنید و کاوش کنید</td></tr>';
      return;
    }
    b.innerHTML = devs.map(function (d, i) {
      var t = todaySum(d.ip), mo = monthSum(d.ip);
      return '<tr>' +
        '<td>' + fa(i + 1) + '</td>' +
        '<td>' + escapeHtml(d.name || '') + '</td>' +
        '<td class="nu-ip">' + escapeHtml(d.ip) + '</td>' +
        '<td>' + (d.iface >= 0
          ? escapeHtml(d.ifname || ('پورت ' + d.iface))
          : '<span class="nu-dim">پورتش انتخاب نشده</span>') + '</td>' +
        '<td class="nu-num">' + bytes(t.inb + t.outb) + '</td>' +
        '<td class="nu-num">' + bytes(mo.inb + mo.outb) + '</td>' +
        '<td class="nu-num" data-nu-live="' + escapeHtml(d.ip) + '"><span class="nu-dim">—</span></td>' +
        '<td class="pg-acts">' +
          '<button class="btn btn-ghost btn-sm" data-nu-if="' + escapeHtml(d.ip) + '">پورت</button>' +
          '<button class="btn btn-ghost btn-sm" data-nu-del="' + escapeHtml(d.ip) + '">✕</button>' +
        '</td></tr>';
    }).join('');
  }

  /* نمودارِ روزهای همین ماهِ شمسی */
  function renderChart() {
    var cv = $('nuChart');
    if (!cv || typeof Chart === 'undefined') return;
    var now = jal(today);
    var byDay = {};
    dayRows.forEach(function (r) {
      var j = jal(r.day);
      if (!j || !now || j.y !== now.y || j.m !== now.m) return;
      byDay[j.d] = (byDay[j.d] || 0) + r.inb + r.outb;
    });
    var dd = Object.keys(byDay).map(Number).sort(function (a, b) { return a - b; });
    var box = cv.closest('.panel');
    if (!dd.length) { if (box) box.style.display = 'none'; return; }
    if (box) box.style.display = '';
    try { if (chart) chart.destroy(); } catch (e) { }
    chart = new Chart(cv, {
      type: 'bar',
      data: { labels: dd.map(function (d) { return fa(d); }),
              datasets: [{ data: dd.map(function (d) { return byDay[d]; }),
                           backgroundColor: chartTone().cat[0], borderRadius: 4 }] },
      options: {
        plugins: { legend: { display: false },
          tooltip: { bodyFont: { family: 'Vazirmatn, Tahoma, Arial, sans-serif' },
                     callbacks: { label: function (c) { return ' ' + bytes(c.parsed.y); } } },
          dashValues: { on: false } },
        scales: { y: { ticks: { callback: function (v) { return bytes(v); } } },
                  x: { ticks: { autoSkip: false,
                                font: { family: 'Vazirmatn, Tahoma, Arial, sans-serif' } } } }
      }
    });
  }

  /* ---------- انتخابِ پورتِ اینترنت ---------- */
  var ov = null, ovIp = '';
  function box() {
    if (ov) return ov;
    ov = document.createElement('div');
    ov.className = 'nu-ov';
    ov.hidden = true;
    ov.innerHTML = '<div class="nu-box" role="dialog" aria-modal="true">' +
      '<h4>کدام پورت، اینترنت است؟</h4><div class="nu-sub"></div>' +
      '<div class="nu-list"></div>' +
      '<div class="nu-f"><button type="button" class="btn btn-ghost btn-sm nu-x">بستن</button></div>' +
      '</div>';
    document.body.appendChild(ov);
    ov.addEventListener('click', function (e) {
      if (e.target.closest('.nu-x') || e.target === ov) { ov.hidden = true; return; }
      var row = e.target.closest('[data-nu-pick]');
      if (row) pick(Number(row.getAttribute('data-nu-pick')), row.getAttribute('data-nu-name'));
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && ov && !ov.hidden) ov.hidden = true;
    });
    return ov;
  }

  function drawIfaces(el, rows) {
    el.querySelector('.nu-list').innerHTML = rows.map(function (r) {
      return '<div class="nu-if' + (r.up ? '' : ' is-off') + '" data-nu-pick="' + r.i +
        '" data-nu-name="' + escapeHtml(r.name) + '">' +
        '<div><div class="nu-if-n">' + escapeHtml(r.name) + '</div>' +
        (r.note ? '<div class="nu-if-note">' + escapeHtml(r.note) + '</div>' : '') + '</div>' +
        '<div class="nu-num nu-dim">' + (r.mbps ? fa(r.mbps) + ' مگابیت' : '—') + '</div>' +
        '<div class="nu-num nu-dim">' + bytes((r.in || 0) + (r.out || 0)) + '</div>' +
        '<div><span class="nu-tag' + (r.up ? ' is-good' : '') + '">' +
          (r.up ? 'بالا' : 'پایین') + '</span></div></div>';
    }).join('') || '<div class="nu-dim">پورتی نداشت</div>';
  }

  function openIf(ip) {
    var d = devs.filter(function (x) { return x.ip === ip; })[0];
    if (!d) return;
    ovIp = ip;
    var el = box();
    el.querySelector('.nu-sub').textContent = (d.name ? d.name + ' — ' : '') + ip;
    el.querySelector('.nu-list').innerHTML = '<div class="nu-dim">در حال خواندنِ پورت‌ها…</div>';
    el.hidden = false;

    /* اگر کاوشگرِ داخلِ شبکه پورت‌ها را فرستاده، همان‌ها را نشان
       می‌دهیم: سرور خودش به این دستگاه نمی‌رسد که بپرسد. */
    var seen = (agent && agent.hosts || []).filter(function (h) { return h.ip === ip; })[0];
    if (seen && seen.ifaces && seen.ifaces.length) {
      drawIfaces(el, seen.ifaces);
      return;
    }

    api('/netuse/ifaces', { host: ip, community: d.community }).then(function (j) {
      if (!j || !j.ok) {
        el.querySelector('.nu-list').innerHTML =
          '<div class="nu-dim">' + escapeHtml((j && j.error) || 'پورتی خوانده نشد') + '</div>';
        return;
      }
      drawIfaces(el, j.rows);
    }).catch(function () {
      el.querySelector('.nu-list').innerHTML = '<div class="nu-dim">به سرور نرسید</div>';
    });
  }

  function pick(i, name) {
    var d = devs.filter(function (x) { return x.ip === ovIp; })[0];
    if (!d) return;
    api('/netuse/devs', { ip: d.ip, name: d.name, community: d.community,
                          iface: i, ifname: name, live: true })
      .then(function (j) { if (j && j.devs) { devs = j.devs; render(); } });
    if (ov) ov.hidden = true;
  }

  /* ---------- سرعتِ همین حالا ---------- */
  function live() {
    var btn = $('nuLiveBtn');
    if (btn) { btn.disabled = true; btn.textContent = 'در حال اندازه‌گیری…'; }
    var jobs = devs.filter(function (d) { return d.iface >= 0; }).map(function (d) {
      return api('/netuse/speed', { host: d.ip, community: d.community, iface: d.iface })
        .then(function (j) {
          var td = document.querySelector('[data-nu-live="' + d.ip + '"]');
          if (!td) return;
          td.innerHTML = (j && j.ok)
            ? '↓ ' + bits(j.inBps) + ' · ↑ ' + bits(j.outBps)
            : '<span class="nu-dim">' + escapeHtml((j && j.error) || '—') + '</span>';
        }).catch(function () { });
    });
    Promise.all(jobs).then(function () {
      if (btn) { btn.disabled = false; btn.textContent = '⚡ سرعتِ همین حالا'; }
    });
  }

  function addFound(i) {
    var h = found[i];
    if (!h) return;
    api('/netuse/devs', { ip: h.ip, name: h.host || (h.snmp && h.snmp.name) || h.kind || h.ip,
                          community: (h.snmp && h.snmp.community) || 'public',
                          iface: -1, ifname: '', live: true })
      .then(function (j) {
        if (j && j.devs) { devs = j.devs; render(); renderFound(); openIf(h.ip); }
      });
  }

  function del(ip) {
    var d = devs.filter(function (x) { return x.ip === ip; })[0];
    ASKDEL((d && d.name) || ip, function () {
      api('/netuse/devs/del', { ip: ip }).then(function (j) {
        if (j && j.devs) { devs = j.devs; render(); renderFound(); }
      });
    });
  }

  /* فقط وقتی بخش دیده می‌شود دوباره می‌خوانیم: refreshEverything بعد
     از هر ذخیره صدا می‌خورد و یک درخواستِ بی‌مصرف در هر بار، روی
     موبایل یعنی ترافیکِ الکی. */
  function shown() {
    var s = $('view-netuse');
    if (!s) return false;
    try { return getComputedStyle(s).display !== 'none'; } catch (e) { return false; }
  }

  var wired = false;
  function wire() {
    if (!wired) {
      wired = true;
      var sec = $('view-netuse');
      if (sec) sec.addEventListener('click', function (e) {
        var a = e.target.closest('[data-nu-add]');
        if (a) { addFound(Number(a.getAttribute('data-nu-add'))); return; }
        var f = e.target.closest('[data-nu-if]');
        if (f) { openIf(f.getAttribute('data-nu-if')); return; }
        var d = e.target.closest('[data-nu-del]');
        if (d) { del(d.getAttribute('data-nu-del')); return; }
      });
      var b1 = $('nuScanBtn'); if (b1) b1.addEventListener('click', scan);
      var b2 = $('nuLiveBtn'); if (b2) b2.addEventListener('click', live);
      var inp = $('nuRange');
      if (inp) inp.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); scan(); }
      });
      if (!offline()) load();      /* یک بار، تا جدول از اول خالی نباشد */
      else render();               /* روی پشتیبان، فقط همان جدولِ خالی */
      return;
    }
    if (shown() && !offline()) load();
  }

  return { wire: wire, load: load, scan: scan, render: render,
           shown: shown, bytes: bytes, bits: bits };
})();

/* خودش راه می‌افتد. تکیه کردن به refreshEverything کافی نبود: آن تابع
   بالاتر از این جزو نوشته شده و اولین بار که صدا می‌خورد، هنوز
   window.NETUSE ساخته نشده بود — بخش تا اولین ذخیره خالی می‌ماند. */
try {
  if (document.getElementById('view-netuse')) NETUSE.wire();
} catch (e) { console.error('[مصرف اینترنت]', e); }
