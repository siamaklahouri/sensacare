/* ==================== گزارشِ سلامتِ ماهانه ====================
   یک صفحه که می‌شود جلوی مدیر گذاشت. چیزی از خودش نمی‌سازد و جایی
   نمی‌نویسد: همهٔ عددها از همین کارتابل درمی‌آیند — چک‌لیستِ ماه،
   بکاپِ روزانه، تستِ ری‌استور، سیستم‌ها، خطوط و بازدیدها.

   دو تصمیم:

   یک) اولِ صفحه «چه چیزی اقدام می‌خواهد» است، نه آمار. گزارشی که با
   هشت عددِ خوب شروع شود، کسی تا تهش را نمی‌خواند و همان چیزی که
   باید دیده شود پایین می‌مانَد.

   دو) هر بخش که داده نداشته باشد اصلاً چاپ نمی‌شود. صفحه‌ای پر از
   «—» یعنی کارتابل نیمه‌کاره است، نه این‌که آن ماه چیزی نبوده. */
window.HEALTH = (function () {
  "use strict";

  function T(v) { return String(v == null ? '' : v).trim(); }

  /* هر منبع ممکن است هنوز نیامده باشد (فایلِ اکسل بار نشده، بخش
     بسته است). هیچ‌کدام نباید کلِ گزارش را بخواباند. */
  function safe(f, d) {
    try { var v = f(); return v == null ? d : v; } catch (e) { return d; }
  }

  function monthName() {
    var k = safe(function () { return String(state.currentMonthKey || ''); }, '');
    if (k && k.indexOf('|') > 0) {
      var p = k.split('|');
      return p[1] + ' ' + fa(p[0]);
    }
    return safe(function () {
      var m = state.meta || {};
      return T(m.month) ? T(m.month) + ' ' + fa(T(m.year)) : '';
    }, '');
  }

  /* ---------- منابع ---------- */

  function tasks() { return safe(function () { return state.tasks || []; }, []); }
  function vms() { return safe(function () { return (backupData && backupData.vm) || []; }, []); }
  function sys() { return safe(function () { return Array.isArray(state.systems) ? state.systems : []; }, []); }

  function taskStat() {
    var all = tasks();
    var done = all.filter(function (t) { return t.status === 'انجام شد'; }).length;
    var late = all.filter(function (t) { return safe(function () { return odDays(t); }, 0) > 0; });
    var crit = all.filter(function (t) { return t.priority === 'بالا' && t.status !== 'انجام شد'; }).length;
    return {
      n: all.length, done: done, crit: crit, late: late,
      pct: all.length ? Math.round(done / all.length * 100) : 0
    };
  }

  function dailyStat() {
    var slots = 0, marks = 0;
    safe(function () {
      Object.keys(dailyLog || {}).forEach(function (g) {
        (dailyLog[g] || []).forEach(function (e) { slots++; if (e.done) marks++; });
      });
      return 1;
    }, 0);
    return { slots: slots, marks: marks, pct: slots ? Math.round(marks / slots * 100) : 0 };
  }

  /* تستِ ری‌استور: همان حسابی که بخشِ خودش می‌کند، تا دو جا دو عدد
     ندهند. اگر آن بخش نبود، این‌جا هم نیست. */
  function restoreStat() {
    var lim = safe(function () {
      var n = parseInt(state.restoreDays, 10);
      return (Number.isFinite(n) && n >= 7 && n <= 400) ? n : 90;
    }, 90);
    var out = { lim: lim, never: [], late: [], soon: 0, ok: 0, oldest: null, has: false };
    if (!window.DatePick || !DatePick.parse) return out;
    vms().forEach(function (v) {
      out.has = true;
      var j = DatePick.parse(T(v.lastRestore));
      if (!j) { out.never.push(v); return; }
      var ms = DatePick.toStamp(j.jy, j.jm, j.jd);
      if (!ms) { out.never.push(v); return; }
      var d = Math.max(0, Math.floor((Date.now() - ms) / 86400000));
      if (!out.oldest || d > out.oldest.d) out.oldest = { v: v, d: d };
      if (d > lim) out.late.push({ v: v, d: d - lim });
      else if (d > lim - 15) out.soon++;
      else out.ok++;
    });
    return out;
  }

  function sysStat() {
    var all = sys(), ip = {}, user = {}, people = {}, ram = 0, half = [];
    all.forEach(function (r) {
      var a = T(r.ip).toLowerCase(); if (a) ip[a] = (ip[a] || 0) + 1;
      var u = T(r.user).toLowerCase(); if (u) user[u] = (user[u] || 0) + 1;
      var p = T(r.person); if (p) people[p] = 1;
      var n = parseFloat(T(r.ram).replace(/[^\d.]/g, ''));
      if (Number.isFinite(n)) ram += n;
      if (!T(r.person) || !T(r.ip) || !T(r.user)) half.push(r);
    });
    var dup = function (c) { return Object.keys(c).filter(function (k) { return c[k] > 1; }); };
    return { n: all.length, people: Object.keys(people).length, ram: Math.round(ram),
             dupIp: dup(ip), dupUser: dup(user), half: half };
  }

  function mvpnStat() {
    var lines = safe(function () { return (mvpnData && mvpnData.lines) || []; }, []);
    var by = {};
    lines.forEach(function (l) {
      var k = T(l.stage) || 'نامشخص';
      by[k] = (by[k] || 0) + 1;
    });
    return { n: lines.length, by: by };
  }

  function visitStat() {
    var c = safe(function () { return (companiesData && companiesData.companies) || {}; }, {});
    var firms = Object.keys(c), n = 0;
    firms.forEach(function (k) { n += (c[k] || []).length; });
    return { firms: firms.length, n: n };
  }

  /* ---------- آنچه اقدام می‌خواهد ---------- */
  function todos() {
    var out = [], t = taskStat(), r = restoreStat(), s = sysStat(), d = dailyStat();

    t.late.slice(0, 8).forEach(function (x) {
      out.push({ lvl: 'bad', what: 'کارِ عقب‌افتاده: ' + T(x.task),
                 who: T(x.owner), why: fa(odDays(x)) + ' روز از مهلتش گذشته' });
    });
    if (t.late.length > 8)
      out.push({ lvl: 'bad', what: 'و ' + fa(t.late.length - 8) + ' کارِ عقب‌افتادهٔ دیگر',
                 who: '', why: 'در چک‌لیستِ ماهانه' });

    r.never.slice(0, 5).forEach(function (v) {
      out.push({ lvl: 'bad', what: 'سرورِ «' + T(v.server) + '» هیچ‌وقت تستِ ری‌استور نشده',
                 who: '', why: 'بکاپی که برنگشته، بکاپ نیست' });
    });
    r.late.sort(function (a, b) { return b.d - a.d; }).slice(0, 5).forEach(function (x) {
      out.push({ lvl: 'bad', what: 'تستِ ری‌استورِ «' + T(x.v.server) + '» از موعد گذشته',
                 who: '', why: fa(x.d) + ' روز گذشته (موعد: هر ' + fa(r.lim) + ' روز)' });
    });

    if (d.slots && d.pct < 95)
      out.push({ lvl: d.pct < 80 ? 'bad' : 'warn',
                 what: 'بکاپِ روزانه در این ماه ' + fa(d.pct) + '٪ موفق بوده',
                 who: '', why: fa(d.slots - d.marks) + ' نوبت بی‌علامت مانده' });

    s.dupIp.slice(0, 4).forEach(function (k) {
      out.push({ lvl: 'bad', what: 'آی‌پیِ تکراری: ' + k, who: '',
                 why: 'دو سیستم با یک نشانی — یکی‌شان بالا نمی‌آید' });
    });
    s.dupUser.slice(0, 4).forEach(function (k) {
      out.push({ lvl: 'warn', what: 'یوزرِ تکراری: ' + k, who: '', why: 'در بخشِ سیستم‌ها' });
    });
    if (s.half.length)
      out.push({ lvl: 'warn', what: fa(s.half.length) + ' سیستم اطلاعاتش ناقص است',
                 who: '', why: 'شخص یا یوزر یا آی‌پی ندارد' });

    if (t.crit)
      out.push({ lvl: 'warn', what: fa(t.crit) + ' کارِ با اولویتِ بالا هنوز تمام نشده',
                 who: '', why: 'در چک‌لیستِ ماهانه' });

    return out;
  }

  /* ---------- نما ---------- */
  function card(ic, lbl, val, sub, cls) {
    return '<div class="stat ' + (cls || '') + '"><div class="stat-head">' +
      '<span class="stat-ic">' + ic + '</span><span class="stat-lbl">' + lbl + '</span></div>' +
      '<div class="stat-val">' + val + '</div>' +
      (sub ? '<div class="stat-sub">' + sub + '</div>' : '') + '</div>';
  }

  function rowsOf(pairs) {
    return pairs.filter(function (p) { return p; }).map(function (p) {
      return '<tr><td class="hr-k">' + p[0] + '</td><td class="hr-v">' + p[1] + '</td></tr>';
    }).join('');
  }

  function block(title, pairs) {
    var body = rowsOf(pairs);
    if (!body) return '';
    return '<div class="hr-box"><h4>' + title + '</h4><table class="hr-t"><tbody>' + body +
           '</tbody></table></div>';
  }

  function render() {
    var box = document.getElementById('hrBody');
    if (!box) return;

    var t = taskStat(), d = dailyStat(), r = restoreStat(), s = sysStat(),
        m = mvpnStat(), v = visitStat(), list = todos();

    var when = safe(function () { return getTodayJalaliStr(); }, '');
    var head = document.getElementById('hrWhen');
    if (head) head.textContent = (monthName() ? 'ماهِ ' + monthName() + ' — ' : '') +
      (when ? 'تهیه‌شده در ' + fa(when) : '');

    var cards = document.getElementById('hrCards');
    if (cards) cards.innerHTML =
      card('✅', 'کارهای ماه', fa(t.pct) + '٪',
           fa(t.done) + ' از ' + fa(t.n) + ' انجام شده',
           t.pct >= 80 ? 'is-clear' : '') +
      card(t.late.length ? '⚠️' : '👍', 'کارِ عقب‌افتاده', fa(t.late.length),
           t.late.length ? 'همین‌ها را اول ببندید' : 'چیزی از مهلتش نگذشته',
           t.late.length ? 'is-alert' : 'is-clear') +
      card('💾', 'بکاپِ روزانه', d.slots ? fa(d.pct) + '٪' : '—',
           d.slots ? fa(d.marks) + ' از ' + fa(d.slots) + ' نوبت' : 'ثبتی نیست',
           d.slots && d.pct < 80 ? 'is-alert' : '') +
      card((r.late.length + r.never.length) ? '♻️' : '✅', 'ری‌استورِ عقب‌افتاده',
           fa(r.late.length + r.never.length),
           r.has ? 'از ' + fa(vms().length) + ' سرور' : 'سروری ثبت نشده',
           (r.late.length + r.never.length) ? 'is-alert' : 'is-clear');

    var act = list.length
      ? '<table class="hr-act"><thead><tr><th style="width:26px;">#</th><th>موضوع</th>' +
        '<th style="width:22%;">چرا</th><th style="width:16%;">با کیست</th></tr></thead><tbody>' +
        list.map(function (x, i) {
          return '<tr class="hr-' + x.lvl + '"><td>' + fa(i + 1) + '</td>' +
            '<td>' + escapeHtml(x.what) + '</td>' +
            '<td class="hr-why">' + escapeHtml(x.why) + '</td>' +
            '<td>' + escapeHtml(x.who || '—') + '</td></tr>';
        }).join('') + '</tbody></table>'
      : '<div class="hr-none">✅ چیزی عقب نمانده — این ماه همه‌چیز سرِ وقت بوده.</div>';

    var size = vms().reduce(function (a, x) {
      return a + (parseFloat(x.sizeUsed) || 0) + (parseFloat(x.sizeVib) || 0);
    }, 0);
    var sched = {};
    vms().forEach(function (x) { var k = T(x.schedule) || 'نامشخص'; sched[k] = (sched[k] || 0) + 1; });

    var stages = Object.keys(m.by).sort(function (a, b) { return m.by[b] - m.by[a]; })
      .slice(0, 4).map(function (k) { return [escapeHtml(k), fa(m.by[k]) + ' خط']; });

    var grid =
      block('💾 بکاپ و سرورها', [
        vms().length ? ['تعداد سرورها', fa(vms().length)] : null,
        size ? ['حجمِ کل', fa(Math.round(size)) + ' گیگابایت'] : null,
        Object.keys(sched).length ? ['گروه‌های زمان‌بندی', fa(Object.keys(sched).length)] : null,
        d.slots ? ['نرخِ موفقیتِ بکاپِ روزانه', fa(d.pct) + '٪'] : null
      ]) +
      block('♻️ تستِ ری‌استور', !r.has ? [] : [
        ['موعد', 'هر ' + fa(r.lim) + ' روز'],
        ['به‌موقع', fa(r.ok)],
        ['نزدیکِ موعد', fa(r.soon)],
        ['از موعد گذشته', fa(r.late.length)],
        ['هیچ‌وقت تست نشده', fa(r.never.length)],
        r.oldest ? ['قدیمی‌ترین تست', escapeHtml(T(r.oldest.v.server)) + ' — ' + fa(r.oldest.d) + ' روز پیش'] : null
      ]) +
      block('💻 سیستم‌ها', !s.n ? [] : [
        ['تعداد سیستم‌ها', fa(s.n)],
        ['افراد', fa(s.people)],
        s.ram ? ['مجموعِ رم', fa(s.ram) + ' گیگابایت'] : null,
        ['آی‌پیِ تکراری', fa(s.dupIp.length)],
        s.half.length ? ['ردیفِ ناقص', fa(s.half.length)] : null
      ]) +
      block('✅ چک‌لیستِ ماهانه', !t.n ? [] : [
        ['کلِ کارها', fa(t.n)],
        ['انجام‌شده', fa(t.done) + '  (' + fa(t.pct) + '٪)'],
        ['عقب‌افتاده', fa(t.late.length)],
        ['اولویتِ بالا و باز', fa(t.crit)]
      ]) +
      block('📱 خطوطِ MVPN', !m.n ? [] : [['کلِ خطوط', fa(m.n)]].concat(stages)) +
      block('🏢 بازدیدها', !v.n ? [] : [
        ['تعدادِ بازدید/پشتیبانی', fa(v.n)],
        ['شرکت‌ها', fa(v.firms)]
      ]);

    box.innerHTML =
      '<div class="panel hr-act-box"><h3>⚠️ آنچه اقدام می‌خواهد</h3>' + act + '</div>' +
      (grid ? '<div class="hr-grid">' + grid + '</div>' : '') +
      '<div class="hr-sign"><span>تهیه‌کننده: ………………………</span>' +
      '<span>امضا: ………………………</span>' +
      '<span>تاریخ: ' + (when ? fa(when) : '…………') + '</span></div>';
  }

  /* دکمهٔ چاپ را موتورِ چاپ خودش کنارِ عنوانِ بخش می‌گذارد — هر
     بخشی که section-title دارد. پس این‌جا فقط کشیدنِ صفحه است. */
  function wire() { render(); }

  return { wire: wire, render: render };
})();

try {
  if (document.getElementById('view-health')) HEALTH.wire();
} catch (e) { console.error('[گزارش سلامت]', e); }
