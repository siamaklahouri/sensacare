/* ==================== پینگِ دستگاه‌ها ====================
   فهرستی از نشانی‌ها با یک دکمه: زنده است یا نه.

   سه تصمیم:

   یک) پورت اختیاری است و اگر باشد، بررسی از روی همان پورت انجام
   می‌شود نه ICMP. دستگاهِ حضور و غیاب روی ۴۳۷۰ گوش می‌دهد؛ «روشن
   بودن» یعنی همان پورت جواب بدهد. خیلی از فایروال‌ها ICMP را
   می‌اندازند و دستگاهِ سالم را مُرده نشان می‌دهند.

   دو) پینگِ گروهی در صفحه انجام می‌شود، نه در یک درخواستِ بزرگ:
   هر ردیف به محضِ رسیدنِ جوابِ خودش تازه می‌شود. با یک درخواستِ
   جمعی باید تا کُندترین دستگاه صبر می‌کردی و تا آن لحظه هیچ‌چیز
   نمی‌دیدی.

   سه) نتیجه‌ها ذخیره نمی‌شوند. «زنده بود» یک خبرِ لحظه‌ای است و
   نوشتنش در داده یعنی دفعهٔ بعد که صفحه باز شود، وضعیتی از دیروز
   را به‌جای امروز نشان می‌دهد. */
var PING = (function () {
  "use strict";

  /* نتیجهٔ همین لحظه، به ازای هر نشانی. در داده نمی‌نشیند. */
  var seen = {};
  var busy = false;

  /* کارتابل‌هایی که از قبل ساخته شده‌اند این کلید را ندارند، و
     DEFAULT_STATE فقط به کارتابلِ نوساز می‌رسد. پس بارِ اول همین‌جا
     پُر می‌شود — ولی فقط وقتی کلید اصلاً نبوده باشد. فهرستِ خالی
     یعنی کاربر خودش پاکشان کرده و نباید دوباره برگردند. */
  var FIRST = [
    { name: 'شهرک نفت', host: '93.114.110.74', port: 4370 },
    { name: 'دفتر اصفهان', host: '37.255.220.75', port: 4370 },
    { name: 'ولنجک', host: '46.100.46.231', port: 4370 },
    { name: 'دفتر مرکزی', host: '192.168.1.201', port: 4370 }
  ];

  function rows() {
    if (!Array.isArray(state.pingHosts)) {
      state.pingHosts = JSON.parse(JSON.stringify(FIRST));
      try { scheduleSave(); } catch (e) { }
    }
    return state.pingHosts;
  }

  function key(r) { return String(r.host || '') + ':' + String(r.port || ''); }

  function fmtMs(n) {
    var v = Math.round(Number(n) || 0);
    return fa(v) + ' میلی‌ثانیه';
  }

  function cell(r) {
    var s = seen[key(r)];
    if (!s) return '<span class="pg-dot pg-idle"></span><span class="pg-txt">بررسی نشده</span>';
    if (s.wait) return '<span class="pg-dot pg-wait"></span><span class="pg-txt">در حال بررسی…</span>';
    if (s.ok)
      return '<span class="pg-dot pg-up"></span><span class="pg-txt">زنده — ' + fmtMs(s.ms) + '</span>';
    return '<span class="pg-dot pg-down"></span><span class="pg-txt">' +
           escapeHtml(s.error || 'پاسخی نداد') + '</span>';
  }

  function when(r) {
    var s = seen[key(r)];
    return (s && s.at) ? s.at : '';
  }

  function render() {
    var body = document.getElementById('pingBody');
    if (!body) return;
    var list = rows();
    var html = list.map(function (r, i) {
      return '<tr>' +
        '<td>' + fa(i + 1) + '</td>' +
        '<td class="editable-text"><input type="text" data-pg="name" data-i="' + i +
          '" value="' + escapeHtml(r.name || '') + '" aria-label="نام"></td>' +
        '<td class="editable-text"><input type="text" data-pg="host" data-i="' + i +
          '" value="' + escapeHtml(r.host || '') + '" aria-label="نشانی" data-ascii></td>' +
        '<td class="editable-text"><input type="text" data-pg="port" data-i="' + i +
          '" value="' + escapeHtml(r.port == null ? '' : String(r.port)) +
          '" aria-label="پورت" data-ascii placeholder="—"></td>' +
        '<td class="pg-state">' + cell(r) + '</td>' +
        '<td class="pg-when">' + escapeHtml(when(r)) + '</td>' +
        '<td><button type="button" class="btn btn-ghost btn-sm pg-one" data-i="' + i +
          '">پینگ</button></td>' +
        '<td><button class="btn-del" data-pg-del="' + i + '" title="حذف این ردیف">✕</button></td>' +
      '</tr>';
    }).join('');

    body.innerHTML = (html || '<tr class="tbl-empty"><td colspan="8">' +
      '<span class="te-ic">📡</span>' +
      '<div class="te-h">هنوز نشانی‌ای ثبت نشده</div>' +
      '<div class="te-p">با فرمِ پایین یک دستگاه اضافه کنید.</div>' +
      '</td></tr>');

    body.querySelectorAll('input[data-pg]').forEach(function (el) {
      el.addEventListener('change', function () {
        var i = parseInt(el.getAttribute('data-i'), 10);
        var f = el.getAttribute('data-pg');
        var row = rows()[i];
        if (!row) return;
        row[f] = f === 'port'
          ? (String(el.value).trim() === '' ? '' : (parseInt(el.value, 10) || ''))
          : el.value.trim();
        scheduleSave();
      });
    });
    body.querySelectorAll('.pg-one').forEach(function (b) {
      b.addEventListener('click', function () {
        one(parseInt(b.getAttribute('data-i'), 10));
      });
    });
    body.querySelectorAll('[data-pg-del]').forEach(function (b) {
      b.addEventListener('click', function () {
        var i = parseInt(b.getAttribute('data-pg-del'), 10);
        var nm = ((rows()[i] || {}).name || (rows()[i] || {}).host || '').trim();
        delRow(rows(), i, nm ? 'نشانیِ «' + nm + '»' : 'این نشانی',
          function () { render(); scheduleSave(); });
      });
    });

    var all = document.getElementById('pingAllBtn');
    if (all) all.disabled = !list.length || busy;
  }

  /* یک نشانی. وعده برمی‌گرداند تا پینگِ گروهی بتواند منتظرِ همه بماند. */
  function one(i) {
    var r = rows()[i];
    if (!r || !String(r.host || '').trim()) return Promise.resolve();
    var k = key(r);
    seen[k] = { wait: true };
    render();
    return fetch(KARTABL_API + '/ping', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ host: r.host, port: r.port === '' ? null : r.port })
    }).then(function (res) { return res.json().catch(function () { return {}; }); })
      .then(function (j) {
        seen[k] = { ok: !!j.ok, ms: j.ms || 0, error: j.error || '', at: nowClock() };
      })
      .catch(function () {
        seen[k] = { ok: false, ms: 0, error: 'به سرور نرسید', at: nowClock() };
      })
      .then(function () { render(); });
  }

  function nowClock() {
    var d = new Date();
    var p = function (n) { return (n < 10 ? '0' : '') + n; };
    return fa(p(d.getHours()) + ':' + p(d.getMinutes()) + ':' + p(d.getSeconds()));
  }

  /* همه با هم. هر ردیف جوابِ خودش را که گرفت تازه می‌شود. */
  function all() {
    if (busy) return Promise.resolve();
    busy = true;
    render();
    var list = rows();
    var jobs = [];
    for (var i = 0; i < list.length; i++) jobs.push(one(i));
    return Promise.all(jobs).then(function () { busy = false; render(); });
  }

  function add() {
    var n = document.getElementById('pgNewName');
    var h = document.getElementById('pgNewHost');
    var o = document.getElementById('pgNewPort');
    if (!h || !String(h.value).trim()) { if (h) h.focus(); return; }
    rows().push({
      name: n ? n.value.trim() : '',
      host: h.value.trim(),
      port: (o && String(o.value).trim() !== '') ? (parseInt(o.value, 10) || '') : ''
    });
    if (n) n.value = '';
    h.value = '';
    if (o) o.value = '';
    render();
    scheduleSave();
    if (n) n.focus();
  }

  function wire() {
    var a = document.getElementById('pingAllBtn');
    if (a && !a.__pg) { a.__pg = 1; a.addEventListener('click', all); }
    var b = document.getElementById('pgAddBtn');
    if (b && !b.__pg) { b.__pg = 1; b.addEventListener('click', add); }
    ['pgNewName', 'pgNewHost', 'pgNewPort'].forEach(function (id) {
      var el = document.getElementById(id);
      if (el && !el.__pg) {
        el.__pg = 1;
        el.addEventListener('keydown', function (e) { if (e.key === 'Enter') add(); });
      }
    });
    render();
  }

  /* اگر کاربر پیش از نخستین تازه‌سازی روی همین بخش برود، جدول
     خالی می‌مانْد. یک شنوندهٔ واحد روی document، نه یکی به ازای
     هر دکمه: دکمه‌ها با بازسازیِ صفحه عوض می‌شوند. */
  document.addEventListener('click', function (e) {
    var n = e.target.closest ? e.target.closest('.navbtn[data-view="ping"]') : null;
    if (n) setTimeout(wire, 0);
  });

  return { render: render, wire: wire, all: all, one: one, rows: rows };
})();
