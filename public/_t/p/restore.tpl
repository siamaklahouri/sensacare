/* ==================== تستِ ری‌استور ====================
   بکاپی که تا حالا برنگشته، بکاپ نیست — یک فایل است با نامِ امیدوارکننده.

   ستونِ «آخرین ری‌استور» در جدولِ سرورها از قبل بود، ولی کسی هفده
   ردیف را با تقویم مقایسه نمی‌کند. این بخش همان ستون را می‌خواند و
   می‌گوید کدام سرور از موعدش گذشته — و با یک کلیک، تستِ امروز را
   همان‌جا ثبت می‌کند.

   دادهٔ تازه‌ای نمی‌سازد: همان جدولِ سرورها را می‌خواند و در همان
   می‌نویسد. پس هر چه این‌جا ثبت شود، آن‌جا هم هست. */
window.RESTORE = (function () {
  var $ = function (id) { return document.getElementById(id); };

  function rows() {
    return (backupData && Array.isArray(backupData.vm)) ? backupData.vm : [];
  }

  /* دادهٔ کارتابل، اگر تا حالا ساخته شده باشد.

     دو دام پشتِ سرِ هم این‌جا بود: این جزو پیش از دادهٔ صفحه اجرا
     می‌شود، پس خواندنِ مستقیمِ «state» خطا می‌داد؛ و «window.state»
     هم جوابِ آن نیست، چون «state» با let تعریف شده و روی window
     نمی‌نشیند — همیشه undefined می‌داد و موعد همیشه ۹۰ می‌ماند. */
  function kb() {
    try { return (typeof state !== 'undefined' && state) ? state : null; }
    catch (e) { return null; }
  }

  /* موعد: هر چند روز یک بار باید تست شود. در خودِ کارتابل می‌مانَد. */
  function limit() {
    var s = kb();
    var n = parseInt(s ? s.restoreDays : NaN, 10);
    return (Number.isFinite(n) && n >= 7 && n <= 400) ? n : 90;
  }

  var DAY = 86400000;

  /* تاریخِ شمسیِ داخلِ خانه → چند روز پیش. متنی که تاریخ نباشد،
     «هیچ‌وقت» است؛ و تاریخی که از امروز جلوتر باشد هم همان. */
  function daysAgo(txt) {
    if (!window.DatePick || !DatePick.parse) return null;
    var j = DatePick.parse(String(txt || ''));
    if (!j) return null;
    var ms = DatePick.toStamp(j.jy, j.jm, j.jd);
    if (!ms) return null;
    var d = Math.floor((Date.now() - ms) / DAY);
    return d < 0 ? 0 : d;
  }

  function stateOf(d) {
    var lim = limit();
    if (d === null) return { k: 'never', t: 'هیچ‌وقت تست نشده', cls: 'is-bad' };
    if (d > lim) return { k: 'late', t: fa(d - lim) + ' روز از موعد گذشته', cls: 'is-bad' };
    if (d > lim - 15) return { k: 'soon', t: fa(lim - d) + ' روز تا موعد', cls: 'is-warn' };
    return { k: 'ok', t: 'به‌موقع', cls: 'is-ok' };
  }

  /* ترتیب از روی همان ستونِ «آخرین ری‌استور» است، نه از روی وضعیت:
     قدیمی‌ترین تست اول. کلیک روی سرستون، ترتیب را برمی‌گرداند.
     ردیف‌هایی که هیچ‌وقت تست نشده‌اند تاریخ ندارند؛ در حالتِ
     «قدیمی‌ترین اول» بالای همه می‌نشینند، چون بدتر از قدیمی‌ترین‌اند. */
  var dir = 'old';

  function sorted() {
    var older = dir === 'old';
    return rows().map(function (v, i) {
      var d = daysAgo(v.lastRestore);
      return { i: i, v: v, d: d, s: stateOf(d) };
    }).sort(function (a, b) {
      if (a.d === null || b.d === null) {
        if (a.d === b.d) return 0;
        if (a.d === null) return older ? -1 : 1;
        return older ? 1 : -1;
      }
      return older ? b.d - a.d : a.d - b.d;
    });
  }

  /* سرستون: پیکان می‌گوید از کدام سر مرتب شده. */
  function head() {
    var th = $('rsSortWhen');
    if (!th) return;
    var older = dir === 'old';
    th.setAttribute('aria-sort', older ? 'descending' : 'ascending');
    th.title = older ? 'قدیمی‌ترین تست اول — برای برعکس‌کردن کلیک کنید'
                     : 'تازه‌ترین تست اول — برای برعکس‌کردن کلیک کنید';
    var ar = th.querySelector('.rs-arrow');
    if (ar) ar.textContent = older ? '▾' : '▴';
  }

  function cards(list) {
    var box = $('rsCards');
    if (!box) return;
    var late = list.filter(function (x) { return x.s.k === 'late' || x.s.k === 'never'; }).length;
    var soon = list.filter(function (x) { return x.s.k === 'soon'; }).length;
    var oldest = list.filter(function (x) { return x.d !== null; })
      .sort(function (a, b) { return b.d - a.d; })[0];
    box.innerHTML =
      '<div class="stat ' + (late ? 'is-alert' : 'is-clear') + '"><div class="stat-head">' +
        '<span class="stat-ic">' + (late ? '⚠️' : '✅') + '</span>' +
        '<span class="stat-lbl">از موعد گذشته</span></div>' +
        '<div class="stat-val">' + fa(late) + '</div>' +
        '<div class="stat-sub">' + (late ? 'همین‌ها را اول تست کنید' : 'همه به‌موقع‌اند') + '</div></div>' +
      '<div class="stat" style="--accent:var(--c2); --tint:var(--t2)"><div class="stat-head">' +
        '<span class="stat-ic">⏳</span><span class="stat-lbl">نزدیکِ موعد</span></div>' +
        '<div class="stat-val">' + fa(soon) + '</div>' +
        '<div class="stat-sub">کمتر از ۱۵ روز مانده</div></div>' +
      '<div class="stat" style="--accent:var(--c1); --tint:var(--t1)"><div class="stat-head">' +
        '<span class="stat-ic">🖥️</span><span class="stat-lbl">همهٔ سرورها</span></div>' +
        '<div class="stat-val">' + fa(list.length) + '</div></div>' +
      '<div class="stat" style="--accent:var(--c3); --tint:var(--t3)"><div class="stat-head">' +
        '<span class="stat-ic">🕰</span><span class="stat-lbl">قدیمی‌ترین تست</span></div>' +
        '<div class="stat-val" style="font-size:16px;">' +
          (oldest ? escapeHtml(oldest.v.server || '—') : '—') + '</div>' +
        '<div class="stat-sub">' + (oldest ? fa(oldest.d) + ' روز پیش' : 'چیزی ثبت نشده') + '</div></div>';
  }

  function render() {
    var b = $('rsBody');
    if (!b) return;
    var list = sorted();
    cards(list);
    head();

    if (!list.length) {
      b.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:14px;color:var(--ink-faint);">' +
        'هنوز سروری در جدولِ «سرورها و بکاپ» نیست</td></tr>';
      return;
    }
    b.innerHTML = list.map(function (x, n) {
      return '<tr class="rs-' + x.s.k + '">' +
        '<td class="rs-no">' + fa(n + 1) + '</td>' +
        '<td class="rs-srv">' + escapeHtml(x.v.server || '—') + '</td>' +
        '<td class="rs-loc">' + escapeHtml(x.v.location || '—') + '</td>' +
        '<td class="rs-when">' + (x.d === null ? '—' : escapeHtml(x.v.lastRestore)) + '</td>' +
        '<td class="rs-ago">' + (x.d === null ? '—' : fa(x.d) + ' روز') + '</td>' +
        '<td class="rs-st"><span class="rs-chip ' + x.s.cls + '">' + x.s.t + '</span></td>' +
        '<td class="rs-acts"><button class="btn btn-ghost btn-sm rs-go" data-rs-done="' + x.i +
          '" title="تاریخِ امروز در ستونِ آخرین ری‌استور می‌نشیند">✓ تستِ امروز</button></td>' +
      '</tr>';
    }).join('');
  }

  /* ثبتِ تست: تاریخِ امروز در همان ستونِ جدولِ سرورها می‌نشیند. */
  function done(i) {
    var v = rows()[i];
    if (!v || !window.DatePick) return;
    var tj = DatePick.today();
    v.lastRestore = DatePick.fmt(tj.jy, tj.jm, tj.jd);
    try { saveServersSheet(); } catch (e) { console.error('[تست ری‌استور]', e); }
    try { renderServers(); } catch (e) { }
    render();
  }

  var wired = false;
  function wire() {
    if (!wired) {
      var sec = $('view-restore');
      if (sec) sec.addEventListener('click', function (e) {
        var b = e.target.closest('[data-rs-done]');
        if (b) { done(Number(b.getAttribute('data-rs-done'))); return; }
        if (e.target.closest('#rsSortWhen')) {
          dir = dir === 'old' ? 'new' : 'old';
          render();
        }
      });
      var inp = $('rsDays');
      if (inp) {
        inp.value = fa(limit());
        inp.addEventListener('change', function () {
          var n = parseInt(String(inp.value).replace(/[۰-۹]/g,
            function (d) { return '۰۱۲۳۴۵۶۷۸۹'.indexOf(d); }), 10);
          var s = kb();
          if (s) s.restoreDays = (Number.isFinite(n) && n >= 7 && n <= 400) ? n : 90;
          inp.value = fa(limit());
          scheduleSave();
          render();
        });
      }
      /* پرچم آخر زده می‌شود، نه اول: اگر وسطِ کار چیزی خطا بدهد،
         دفعهٔ بعد دوباره تلاش می‌شود. یک بار همین‌جا پرچم اول خورد و
         کلیدِ موعد تا بارگذاریِ بعدی بی‌جان ماند. */
      wired = true;
    }
    render();
  }

  return { wire: wire, render: render };
})();

try {
  if (document.getElementById('view-restore')) RESTORE.wire();
} catch (e) { console.error('[تست ری‌استور]', e); }
