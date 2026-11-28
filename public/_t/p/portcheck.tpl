/* ==================== پورت‌چکر ====================
   «این پورت از بیرون باز است یا نه؟»

   جوابش را سرورِ کارتابل می‌دهد، نه مرورگر: مرورگر اجازهٔ باز کردنِ
   یک اتصالِ خام به یک پورت را ندارد. و چون سرورِ ما بیرونِ شبکهٔ
   شماست، همان چیزی را می‌بیند که دنیا می‌بیند — که دقیقاً همان
   سؤال است.

   فقط با کلیکِ آدم کار می‌کند. هیچ بررسیِ دوره‌ای و هیچ جاروکردنِ
   شبکه‌ای این‌جا نیست: سقفِ هر بار سی‌ودو پورت است. */
window.PORTCHECK = (function () {
  var busy = false, myIp = '';

  var $ = function (id) { return document.getElementById(id); };

  var SETS = [
    { t: 'وب',            p: '80, 443, 8080, 8443' },
    { t: 'ریموت و مدیریت', p: '22, 23, 3389, 5900, 8291, 8728' },
    { t: 'ایمیل',          p: '25, 110, 143, 465, 587, 993, 995' },
    { t: 'دیتابیس',        p: '1433, 3306, 5432, 27017' },
    { t: 'دستگاه‌ها',      p: '161, 4370, 9100, 5060' },
    { t: 'پرکاربردها',     p: '21, 22, 25, 53, 80, 110, 143, 443, 3389, 8291' }
  ];

  function render(j) {
    var b = $('pcBody');
    if (!b) return;
    if (!j || !j.rows || !j.rows.length) {
      b.innerHTML = '<tr><td colspan="5" class="nu-dim" ' +
        'style="text-align:center;padding:14px;color:var(--ink-faint);">' +
        'هنوز چیزی بررسی نشده</td></tr>';
      return;
    }
    b.innerHTML = j.rows.map(function (r, i) {
      return '<tr' + (r.open ? ' class="pc-open"' : '') + '>' +
        '<td>' + fa(i + 1) + '</td>' +
        '<td class="pc-port">' + fa(r.port) + '</td>' +
        '<td>' + escapeHtml(r.name || '—') + '</td>' +
        '<td><span class="pc-chip ' + (r.open ? 'is-open' : 'is-shut') + '">' +
          (r.open ? 'باز' : 'بسته') + '</span>' +
          (r.open ? '' : ' <span class="pc-why">' + escapeHtml(r.why || '') + '</span>') +
        '</td>' +
        '<td class="pc-ms">' + (r.open ? fa(r.ms) + ' م‌ث' : '—') + '</td>' +
      '</tr>';
    }).join('');
  }

  function say(t) {
    var el = $('pcSay');
    if (el) el.innerHTML = t || '';
  }

  function run() {
    if (busy) return;
    var h = $('pcHost'), pz = $('pcPorts'), btn = $('pcGo');
    var host = h ? h.value.trim() : '', ports = pz ? pz.value.trim() : '';
    if (!host) { if (h) h.focus(); return; }
    if (!ports) { if (pz) pz.focus(); return; }

    busy = true;
    if (btn) { btn.disabled = true; btn.textContent = 'در حال بررسی…'; }
    say('در حال زدنِ پورت‌ها…');

    fetch(KARTABL_API + '/portcheck', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ host: host, ports: ports })
    }).then(function (r) { return r.json(); }).then(function (j) {
      if (!j || j.error) { say('<span style="color:var(--red-ink)">' +
        escapeHtml((j && j.error) || 'نشد') + '</span>'); render(null); return; }
      render(j);
      say('<b>' + escapeHtml(j.host) + '</b> — ' + fa(j.open) + ' پورت از ' +
          fa(j.rows.length) + ' تا باز است.' +
          (j.rows.length >= (j.max || 32)
            ? ' <span class="pc-why">(سقفِ هر بار ' + fa(j.max || 32) + ' پورت است)</span>' : ''));
    }).catch(function () {
      say('<span style="color:var(--red-ink)">به سرور نرسید</span>');
    }).then(function () {
      busy = false;
      if (btn) { btn.disabled = false; btn.textContent = 'بررسی'; }
    });
  }

  function wire() {
    if (wire.done) return;
    wire.done = true;

    var sets = $('pcSets');
    if (sets) {
      sets.innerHTML = SETS.map(function (s, i) {
        return '<button type="button" class="pc-set" data-pc-set="' + i + '">' +
          escapeHtml(s.t) + '</button>';
      }).join('');
      sets.addEventListener('click', function (e) {
        var b = e.target.closest('[data-pc-set]');
        if (!b) return;
        var s = SETS[Number(b.getAttribute('data-pc-set'))];
        if (s && $('pcPorts')) { $('pcPorts').value = s.p; run(); }
      });
    }

    var go = $('pcGo');
    if (go) go.addEventListener('click', run);
    ['pcHost', 'pcPorts'].forEach(function (id) {
      var el = $(id);
      if (el) el.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); run(); }
      });
    });

    /* نشانیِ خودِ کاربر، همان‌طور که سرور می‌بیندش: بیشترِ وقت‌ها
       آدم می‌خواهد پورت‌های خودش را ببیند. */
    fetch(KARTABL_API + '/myip').then(function (r) { return r.json(); })
      .then(function (j) {
        myIp = (j && j.ip) || '';
        /* پشتِ بعضی چیدمان‌ها سرور نشانیِ واقعی را نمی‌بیند و
           «unknown» می‌دهد. آن‌وقت نوشتنش بدتر از ننوشتنش است. */
        if (!myIp || myIp === 'unknown') return;
        var el = $('pcMine');
        if (el) {
          el.innerHTML = 'نشانیِ اینترنتیِ شما: <b dir="ltr">' + escapeHtml(myIp) + '</b> ' +
            '<button type="button" class="pc-set" id="pcUseMine">همین را بگذار</button>';
          var u = $('pcUseMine');
          if (u) u.addEventListener('click', function () {
            if ($('pcHost')) $('pcHost').value = myIp;
          });
        }
      }).catch(function () { });

    render(null);
  }

  return { wire: wire, run: run };
})();

try {
  if (document.getElementById('view-portcheck')) PORTCHECK.wire();
} catch (e) { console.error('[پورت‌چکر]', e); }
