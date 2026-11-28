/* ==================== گزارشِ سلامتِ ماهانه ====================
   یک صفحه که می‌شود جلوی مدیر گذاشت. چیزی از خودش نمی‌سازد: همهٔ
   عددها از همین کارتابل درمی‌آیند — چک‌لیستِ ماه، بکاپِ روزانه،
   چک‌لیستِ ریموت، تستِ ری‌استور، سیستم‌ها، خطوط و بازدیدها.

   چهار تصمیم:

   یک) اولِ صفحه «چه چیزی اقدام می‌خواهد» است، نه آمار. گزارشی که با
   هشت عددِ خوب شروع شود، کسی تا تهش را نمی‌خواند و همان چیزی که
   باید دیده شود پایین می‌مانَد.

   دو) یک نمرهٔ ۰ تا ۱۰۰، از پنج جزء. نمره جای جدول‌ها را نمی‌گیرد —
   کنارش می‌نشیند تا ماه‌به‌ماه بشود مقایسه کرد. جزئی که داده نداشته
   باشد (مثلاً کارتابلی که سرور ندارد) در نمره نمی‌آید و وزنش بین
   بقیه پخش می‌شود؛ وگرنه نبودنِ یک بخش، نمرهٔ کسی را می‌خورد.

   سه) ماهِ گزارش انتخابی است. کارهای ماه و برنامهٔ روزانه از همان
   ماه خوانده می‌شود، ولی سرور و سیستم و بکاپ همیشه «وضعیتِ امروز»
   است — این را خودِ گزارش می‌گوید تا کسی عددِ امروز را به پای آن
   ماه ننویسد.

   چهار) هر بخش که داده نداشته باشد اصلاً چاپ نمی‌شود. صفحه‌ای پر از
   «—» یعنی کارتابل نیمه‌کاره است، نه این‌که آن ماه چیزی نبوده. */
window.HEALTH = (function () {
  "use strict";

  var pick = '';        /* کلیدِ ماهِ انتخابی — خالی یعنی ماهِ جاری */

  function T(v) { return String(v == null ? '' : v).trim(); }

  /* هر منبع ممکن است هنوز نیامده باشد (فایلِ اکسل بار نشده، بخش
     بسته است). هیچ‌کدام نباید کلِ گزارش را بخواباند. */
  function safe(f, d) {
    try { var v = f(); return v == null ? d : v; } catch (e) { return d; }
  }

  function curKey() { return safe(function () { return String(state.currentMonthKey || ''); }, ''); }
  function key() { return pick || curKey(); }
  function isNow() { return !pick || pick === curKey(); }

  function nameOf(k) {
    if (k && k.indexOf('|') > 0) {
      var p = k.split('|');
      return p[1] + ' ' + fa(p[0]);
    }
    return safe(function () {
      var m = state.meta || {};
      return T(m.month) ? T(m.month) + ' ' + fa(T(m.year)) : '';
    }, '');
  }

  /* ماه‌ها، تازه‌ترین اول. کلید «سال|نامِ ماه» است، پس برای ترتیب
     باید نامِ ماه به شماره برگردد. */
  function months() {
    var all = safe(function () { return Object.keys(state.monthsData || {}); }, []);
    var cur = curKey();
    if (cur && all.indexOf(cur) < 0) all.push(cur);
    return all.filter(function (k) { return k && k.indexOf('|') > 0; })
      .sort(function (a, b) {
        var A = a.split('|'), B = b.split('|');
        var ay = parseInt(faToEn(A[0]), 10) || 0, by = parseInt(faToEn(B[0]), 10) || 0;
        if (ay !== by) return by - ay;
        return JALALI_MONTH_NAMES.indexOf(B[1]) - JALALI_MONTH_NAMES.indexOf(A[1]);
      });
  }

  function prevKey() {
    var all = months(), i = all.indexOf(key());
    return (i >= 0 && i + 1 < all.length) ? all[i + 1] : '';
  }

  /* کارها و روزهای یک ماه: ماهِ جاری زنده است، بقیه در بایگانی. */
  function monthData(k) {
    if (!k || k === curKey())
      return { tasks: safe(function () { return state.tasks || []; }, []),
               days: safe(function () { return state.days || []; }, []) };
    var m = safe(function () { return (state.monthsData || {})[k]; }, null) || {};
    return { tasks: m.tasks || [], days: m.days || [] };
  }

  function vms() { return safe(function () { return (backupData && backupData.vm) || []; }, []); }
  function sys() { return safe(function () { return Array.isArray(state.systems) ? state.systems : []; }, []); }

  /* ---------- سنجه‌ها ---------- */

  function taskStat(k) {
    var all = monthData(k).tasks;
    var done = all.filter(function (t) { return t.status === 'انجام شد'; }).length;
    var doing = all.filter(function (t) { return t.status === 'در حال انجام'; }).length;
    var crit = all.filter(function (t) { return t.priority === 'بالا' && t.status !== 'انجام شد'; }).length;
    /* «عقب‌افتاده» فقط در ماهِ جاری معنا دارد: ماهِ تمام‌شده را
       نمی‌شود امروز جبران کرد. */
    var late = (k === curKey() || !k)
      ? all.filter(function (t) { return safe(function () { return odDays(t); }, 0) > 0; })
      : [];
    return { n: all.length, done: done, doing: doing, crit: crit, late: late,
             open: all.length - done,
             pct: all.length ? Math.round(done / all.length * 100) : null };
  }

  function dayStat(k) {
    var all = monthData(k).days.filter(function (d) {
      return T(d.main) || T(d.meet) || T(d.company) || T(d.status);
    });
    var done = all.filter(function (d) { return d.status === 'انجام شد'; }).length;
    var imp = all.filter(function (d) { return d.important; }).length;
    return { n: all.length, done: done, imp: imp,
             pct: all.length ? Math.round(done / all.length * 100) : null };
  }

  function dailyStat() {
    var slots = 0, marks = 0;
    safe(function () {
      Object.keys(dailyLog || {}).forEach(function (g) {
        (dailyLog[g] || []).forEach(function (e) { slots++; if (e.done) marks++; });
      });
      return 1;
    }, 0);
    return { slots: slots, marks: marks, pct: slots ? Math.round(marks / slots * 100) : null };
  }

  /* چک‌لیستِ ریموت: ستون‌هایی که تاریخ خورده‌اند روزِ واقعی‌اند؛
     ستونِ بی‌تاریخ هنوز پُر نشده و نباید نمره را پایین بکشد. */
  function remoteStat() {
    var roster = safe(function () { return (remoteBackupData && remoteBackupData.roster) || []; }, []);
    var dates = safe(function () { return state.remoteCheckDates || []; }, []);
    var live = [];
    dates.forEach(function (d, i) { if (T(d)) live.push(i + 1); });
    if (!roster.length || !live.length) return { n: roster.length, days: live.length, pct: null, slots: 0, marks: 0 };
    var marks = 0;
    roster.forEach(function (m) {
      var c = safe(function () { return state.remoteChecks[m.server] || {}; }, {});
      live.forEach(function (d) { if (c[d]) marks++; });
    });
    var slots = roster.length * live.length;
    return { n: roster.length, days: live.length, slots: slots, marks: marks,
             pct: slots ? Math.round(marks / slots * 100) : null };
  }

  function restoreStat() {
    var lim = safe(function () {
      var n = parseInt(state.restoreDays, 10);
      return (Number.isFinite(n) && n >= 7 && n <= 400) ? n : 90;
    }, 90);
    var out = { lim: lim, never: [], late: [], soon: 0, ok: 0, oldest: null, has: false, pct: null };
    if (!window.DatePick || !DatePick.parse) return out;
    vms().forEach(function (v) {
      out.has = true;
      var j = DatePick.parse(T(v.lastRestore));
      var ms = j ? DatePick.toStamp(j.jy, j.jm, j.jd) : 0;
      if (!ms) { out.never.push(v); return; }
      var d = Math.max(0, Math.floor((Date.now() - ms) / 86400000));
      if (!out.oldest || d > out.oldest.d) out.oldest = { v: v, d: d };
      if (d > lim) out.late.push({ v: v, d: d - lim });
      else if (d > lim - 15) out.soon++;
      else out.ok++;
    });
    var n = vms().length;
    if (n) out.pct = Math.round((out.ok + out.soon) / n * 100);
    return out;
  }

  /* بکاپِ کامل: سروری که تاریخِ آخرین بکاپِ کاملش نیست یا از یک ماه
     گذشته، خودش یک خبر است. */
  function fullStat() {
    var out = { none: [], old: [], ok: 0, has: false };
    if (!window.DatePick || !DatePick.parse) return out;
    vms().forEach(function (v) {
      out.has = true;
      var j = DatePick.parse(T(v.lastFullBackup));
      var ms = j ? DatePick.toStamp(j.jy, j.jm, j.jd) : 0;
      if (!ms) { out.none.push(v); return; }
      var d = Math.max(0, Math.floor((Date.now() - ms) / 86400000));
      if (d > 31) out.old.push({ v: v, d: d }); else out.ok++;
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
    var d1 = dup(ip), d2 = dup(user);
    var clean = all.length ? Math.round((all.length - half.length - d1.length - d2.length) / all.length * 100) : null;
    return { n: all.length, people: Object.keys(people).length, ram: Math.round(ram),
             dupIp: d1, dupUser: d2, half: half,
             pct: clean == null ? null : Math.max(0, Math.min(100, clean)) };
  }

  function mvpnStat() {
    var lines = safe(function () { return (mvpnData && mvpnData.lines) || []; }, []);
    var by = {};
    lines.forEach(function (l) { var k = T(l.stage) || 'نامشخص'; by[k] = (by[k] || 0) + 1; });
    return { n: lines.length, by: by };
  }

  function visitStat() {
    var c = safe(function () { return (companiesData && companiesData.companies) || {}; }, {});
    var firms = Object.keys(c), n = 0;
    firms.forEach(function (k) { n += (c[k] || []).length; });
    return { firms: firms.length, n: n };
  }

  function pingStat() {
    var h = safe(function () { return Array.isArray(state.pingHosts) ? state.pingHosts : []; }, []);
    return { n: h.length };
  }

  /* ---------- نمرهٔ سلامت ----------
     پنج جزء با وزنِ ثابت. جزئی که دادهٔ آن نیست (pct === null) کنار
     گذاشته می‌شود و وزنش بین بقیه پخش می‌شود. */
  function score(k) {
    var t = taskStat(k), d = dailyStat(), r = restoreStat(), s = sysStat(), rm = remoteStat();
    var parts = [
      { t: 'چک‌لیستِ ماهانه', w: 25, v: t.pct },
      { t: 'بکاپِ روزانه', w: 25, v: d.pct },
      { t: 'تستِ ری‌استور', w: 25, v: r.pct },
      { t: 'چک‌لیستِ ریموت', w: 15, v: rm.pct },
      { t: 'نظمِ دادهٔ سیستم‌ها', w: 10, v: s.pct }
    ].filter(function (p) { return p.v != null; });
    if (!parts.length) return { n: null, parts: [] };
    var sum = parts.reduce(function (a, p) { return a + p.w; }, 0);
    var got = parts.reduce(function (a, p) { return a + p.w * p.v; }, 0);
    parts.forEach(function (p) { p.share = Math.round(p.w / sum * 100); });
    return { n: Math.round(got / sum), parts: parts };
  }

  function grade(n) {
    if (n == null) return { t: 'هنوز دادهٔ کافی نیست', c: 'is-none' };
    if (n >= 85) return { t: 'خوب', c: 'is-ok' };
    if (n >= 65) return { t: 'قابلِ قبول', c: 'is-warn' };
    return { t: 'نیازمندِ توجه', c: 'is-bad' };
  }

  /* ---------- آنچه اقدام می‌خواهد ---------- */
  function todos(k) {
    var out = [], t = taskStat(k), r = restoreStat(), s = sysStat(),
        d = dailyStat(), f = fullStat(), rm = remoteStat();

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

    f.none.slice(0, 4).forEach(function (v) {
      out.push({ lvl: 'warn', what: 'سرورِ «' + T(v.server) + '» تاریخِ بکاپِ کامل ندارد',
                 who: '', why: 'در جدولِ سرورها خالی است' });
    });
    f.old.sort(function (a, b) { return b.d - a.d; }).slice(0, 4).forEach(function (x) {
      out.push({ lvl: 'warn', what: 'بکاپِ کاملِ «' + T(x.v.server) + '» کهنه شده',
                 who: '', why: fa(x.d) + ' روز از آخرین بکاپِ کامل گذشته' });
    });

    if (d.slots && d.pct < 95)
      out.push({ lvl: d.pct < 80 ? 'bad' : 'warn',
                 what: 'بکاپِ روزانه در این ماه ' + fa(d.pct) + '٪ موفق بوده',
                 who: '', why: fa(d.slots - d.marks) + ' نوبت بی‌علامت مانده' });

    if (rm.pct != null && rm.pct < 90)
      out.push({ lvl: rm.pct < 70 ? 'bad' : 'warn',
                 what: 'چک‌لیستِ ریموت ' + fa(rm.pct) + '٪ پُر شده',
                 who: '', why: fa(rm.slots - rm.marks) + ' خانه از ' + fa(rm.slots) + ' خالی است' });

    s.dupIp.slice(0, 4).forEach(function (x) {
      out.push({ lvl: 'bad', what: 'آی‌پیِ تکراری: ' + x, who: '',
                 why: 'دو سیستم با یک نشانی — یکی‌شان بالا نمی‌آید' });
    });
    s.dupUser.slice(0, 4).forEach(function (x) {
      out.push({ lvl: 'warn', what: 'یوزرِ تکراری: ' + x, who: '', why: 'در بخشِ سیستم‌ها' });
    });
    if (s.half.length)
      out.push({ lvl: 'warn', what: fa(s.half.length) + ' سیستم اطلاعاتش ناقص است',
                 who: '', why: 'شخص یا یوزر یا آی‌پی ندارد' });

    if (t.crit)
      out.push({ lvl: 'warn', what: fa(t.crit) + ' کارِ با اولویتِ بالا هنوز تمام نشده',
                 who: '', why: 'در چک‌لیستِ ماهانه' });

    return out;
  }

  /* ---------- اجزای نما ---------- */
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

  function pctTxt(v) { return v == null ? '—' : fa(v) + '٪'; }

  /* نمره، با نوارِ اجزا */
  function scoreBox(sc, prev) {
    var g = grade(sc.n);
    var trend = '';
    if (sc.n != null && prev && prev.n != null) {
      var dlt = sc.n - prev.n;
      trend = '<div class="hr-trend ' + (dlt > 0 ? 'up' : (dlt < 0 ? 'down' : '')) + '">' +
        (dlt > 0 ? '▲ ' : (dlt < 0 ? '▼ ' : '= ')) +
        (dlt === 0 ? 'مثلِ ماهِ قبل' : fa(Math.abs(dlt)) + ' نمره نسبت به ماهِ قبل') + '</div>';
    }
    var bars = sc.parts.map(function (p) {
      var c = p.v >= 85 ? 'is-ok' : (p.v >= 65 ? 'is-warn' : 'is-bad');
      return '<div class="hr-bar"><span class="hr-bl">' + p.t + '</span>' +
        '<span class="hr-bt"><i class="' + c + '" style="width:' + Math.max(2, p.v) + '%"></i></span>' +
        '<span class="hr-bv">' + fa(p.v) + '٪</span>' +
        '<span class="hr-bw">وزن ' + fa(p.share) + '٪</span></div>';
    }).join('');
    return '<div class="panel hr-score ' + g.c + '">' +
      '<div class="hr-sc-n"><div class="hr-sc-v">' + (sc.n == null ? '—' : fa(sc.n)) + '</div>' +
      '<div class="hr-sc-l">نمرهٔ سلامت</div><div class="hr-sc-g">' + g.t + '</div>' + trend + '</div>' +
      '<div class="hr-sc-b">' + (bars || '<div class="hr-dim">برای نمره‌دادن هنوز داده‌ای نیست.</div>') + '</div>' +
      '</div>';
  }

  /* جدولِ کارهای بازِ همین ماه — گزارش باید خودش کامل باشد، نه
     ارجاع به بخشِ دیگر. */
  function openTasks(k) {
    var all = monthData(k).tasks.filter(function (t) { return t.status !== 'انجام شد'; });
    if (!all.length) return '';
    var now = (k === curKey() || !k);
    all = all.slice().sort(function (a, b) {
      var A = now ? safe(function () { return odDays(a); }, 0) : 0;
      var B = now ? safe(function () { return odDays(b); }, 0) : 0;
      if (A !== B) return B - A;
      var pa = a.priority === 'بالا' ? 0 : (a.priority === 'متوسط' ? 1 : 2);
      var pb = b.priority === 'بالا' ? 0 : (b.priority === 'متوسط' ? 1 : 2);
      if (pa !== pb) return pa - pb;
      return (parseInt(faToEn(a.deadline), 10) || 99) - (parseInt(faToEn(b.deadline), 10) || 99);
    }).slice(0, 15);
    return '<div class="panel"><h3>📋 کارهای بازِ این ماه</h3>' +
      '<table class="hr-act"><thead><tr><th style="width:26px;">#</th><th>کار</th>' +
      '<th style="width:16%;">دسته</th><th style="width:16%;">مسئول</th>' +
      '<th style="width:70px;">مهلت</th><th style="width:15%;">وضعیت</th></tr></thead><tbody>' +
      all.map(function (t, i) {
        var late = now ? safe(function () { return odDays(t); }, 0) : 0;
        return '<tr class="' + (late ? 'hr-bad' : (t.priority === 'بالا' ? 'hr-warn' : '')) + '">' +
          '<td>' + fa(i + 1) + '</td>' +
          '<td>' + escapeHtml(T(t.task)) + '</td>' +
          '<td>' + escapeHtml(T(t.category)) + '</td>' +
          '<td>' + escapeHtml(T(t.owner) || '—') + '</td>' +
          '<td>' + (T(t.deadline) ? fa(T(t.deadline)) : '—') + '</td>' +
          '<td class="hr-why">' + (late ? fa(late) + ' روز گذشته' : escapeHtml(T(t.status) || '—')) + '</td>' +
        '</tr>';
      }).join('') + '</tbody></table></div>';
  }

  /* ---------- نمودارِ کارهای باقی‌مانده به تفکیک دسته ----------
     کادرش جزوِ همان HTML ی است که این‌جا ساخته می‌شود، نه یک کادرِ
     ثابت در قالب: وگرنه هر جایی که بگذاریمش، یک‌جای ثابت می‌مانَد —
     یک بار همین‌طور زیرِ خطِ امضا افتاد. */
  function openByCat(k) {
    var by = {};
    monthData(k).tasks.forEach(function (t) {
      if (t.status === 'انجام شد') return;
      var c = T(t.category) || 'سایر';
      by[c] = (by[c] || 0) + 1;
    });
    return by;
  }

  function chartBox(k) {
    var by = openByCat(k);
    if (!Object.keys(by).length || !safe(chartsReady, false)) return '';
    return '<div class="panel" id="hrChartWrap"><h3>📊 کارهای باز، به تفکیکِ دسته</h3>' +
      '<div class="hr-chart"><canvas id="hrChart"></canvas></div></div>';
  }

  function chart(k) {
    safe(function () { destroyChart('health'); return 1; }, 0);
    var by = openByCat(k);
    var keys = Object.keys(by).sort(function (a, b) { return by[b] - by[a]; }).slice(0, 8);
    if (!keys.length || !safe(chartsReady, false)) return;
    var cv = document.getElementById('hrChart');
    if (!cv || cv.tagName !== 'CANVAS') return;
    safe(function () {
      charts.health = new Chart(cv, {
        type: 'bar',
        data: { labels: keys, datasets: [{ data: keys.map(function (x) { return by[x]; }),
          backgroundColor: chartTone().cat[0],
          hoverBackgroundColor: chartHover([chartTone().cat[0]])[0], borderRadius: 4 }] },
        options: { indexAxis: 'y', maintainAspectRatio: false,
          plugins: { legend: { display: false },
            tooltip: { bodyFont: { family: 'Vazirmatn, Tahoma, Arial, sans-serif' },
              callbacks: { label: function (c) { return ' ' + fa(c.parsed.x) + ' کارِ باز'; } } } },
          scales: { x: { ticks: { callback: function (v) { return fa(v); }, precision: 0 } },
            y: { ticks: { font: { family: 'Vazirmatn, Tahoma, Arial, sans-serif', size: 11 } } } } }
      });
      return 1;
    }, 0);
  }

  /* ---------- یادداشتِ گزارش ----------
     یک جعبه برای حرفِ خودِ آدم. در کارتابل می‌مانَد و روی کاغذ هم
     می‌آید — وگرنه هر ماه باید زیرِ چاپ دستی نوشته شود. */
  function note() {
    return safe(function () { return String(state.healthNote || ''); }, '');
  }

  function render() {
    var box = document.getElementById('hrBody');
    if (!box) return;
    var k = key();

    var t = taskStat(k), dy = dayStat(k), d = dailyStat(), r = restoreStat(),
        f = fullStat(), s = sysStat(), m = mvpnStat(), v = visitStat(),
        rm = remoteStat(), pg = pingStat(), list = todos(k);
    var sc = score(k);
    var pv = prevKey();
    var prev = pv ? { n: score(pv).n, t: taskStat(pv) } : null;

    /* سربرگ */
    var when = safe(function () { return getTodayJalaliStr(); }, '');
    var head = document.getElementById('hrWhen');
    if (head) head.innerHTML =
      '<span>ماهِ <b>' + escapeHtml(nameOf(k)) + '</b></span>' +
      (when ? '<span>تهیه‌شده در ' + fa(when) + '</span>' : '') +
      (isNow() ? '' : '<span class="hr-warnline">کارهای ماه از همین ماه است؛ سرور و سیستم و بکاپ، وضعیتِ امروز.</span>');

    /* فهرستِ ماه‌ها. هر بار ساخته می‌شود، نه یک‌بار: اولین کشیدنِ
       صفحه پیش از آمدنِ دادهٔ کارتابل اتفاق می‌افتد و آن لحظه هنوز
       هیچ ماهی نیست. یک‌بارِ اول، فهرست برای همیشه خالی می‌ماند. */
    var sel = document.getElementById('hrMonth');
    if (sel) {
      var all = months(), sig = all.join(',');
      if (sel.dataset.sig !== sig) {
        sel.innerHTML = all.map(function (x) {
          return '<option value="' + escapeHtml(x) + '">' + escapeHtml(nameOf(x)) + '</option>';
        }).join('');
        sel.dataset.sig = sig;
      }
      if (sel.value !== k) sel.value = k;
      /* یک ماه که بیشتر نیست، انتخابی هم نیست. */
      var bar = sel.closest('.hr-bar-top');
      if (bar) bar.hidden = all.length < 2;
    }

    /* کارت‌ها */
    var cards = document.getElementById('hrCards');
    if (cards) cards.innerHTML =
      card('✅', 'کارهای ماه', pctTxt(t.pct),
           fa(t.done) + ' از ' + fa(t.n) + ' انجام شده' +
           (prev && prev.t.pct != null && t.pct != null
             ? '  ·  ماهِ قبل ' + fa(prev.t.pct) + '٪' : ''),
           t.pct != null && t.pct >= 80 ? 'is-clear' : '') +
      card(t.late.length ? '⚠️' : '👍', isNow() ? 'کارِ عقب‌افتاده' : 'کارِ ناتمام',
           fa(isNow() ? t.late.length : t.open),
           isNow() ? (t.late.length ? 'همین‌ها را اول ببندید' : 'چیزی از مهلتش نگذشته')
                   : 'در پایانِ آن ماه',
           (isNow() ? t.late.length : t.open) ? 'is-alert' : 'is-clear') +
      card('💾', 'بکاپِ روزانه', pctTxt(d.pct),
           d.slots ? fa(d.marks) + ' از ' + fa(d.slots) + ' نوبت' : 'ثبتی نیست',
           d.pct != null && d.pct < 80 ? 'is-alert' : '') +
      card((r.late.length + r.never.length) ? '♻️' : '✅', 'ری‌استورِ عقب‌افتاده',
           fa(r.late.length + r.never.length),
           r.has ? 'از ' + fa(vms().length) + ' سرور' : 'سروری ثبت نشده',
           (r.late.length + r.never.length) ? 'is-alert' : 'is-clear');

    /* آنچه اقدام می‌خواهد */
    var bad = list.filter(function (x) { return x.lvl === 'bad'; }).length;
    var act = list.length
      ? '<div class="hr-dim">' + fa(list.length) + ' مورد' +
        (bad ? '، ' + fa(bad) + ' تای آن جدی' : '') + '</div>' +
        '<table class="hr-act"><thead><tr><th style="width:26px;">#</th><th>موضوع</th>' +
        '<th style="width:24%;">چرا</th><th style="width:16%;">با کیست</th></tr></thead><tbody>' +
        list.map(function (x, i) {
          return '<tr class="hr-' + x.lvl + '"><td>' + fa(i + 1) + '</td>' +
            '<td>' + escapeHtml(x.what) + '</td>' +
            '<td class="hr-why">' + escapeHtml(x.why) + '</td>' +
            '<td>' + escapeHtml(x.who || '—') + '</td></tr>';
        }).join('') + '</tbody></table>'
      : '<div class="hr-none">✅ چیزی عقب نمانده — این ماه همه‌چیز سرِ وقت بوده.</div>';

    /* جعبه‌های خلاصه */
    var size = vms().reduce(function (a, x) {
      return a + (parseFloat(x.sizeUsed) || 0) + (parseFloat(x.sizeVib) || 0);
    }, 0);
    var sched = {};
    vms().forEach(function (x) { var k2 = T(x.schedule) || 'نامشخص'; sched[k2] = (sched[k2] || 0) + 1; });
    var stages = Object.keys(m.by).sort(function (a, b) { return m.by[b] - m.by[a]; })
      .slice(0, 4).map(function (x) { return [escapeHtml(x), fa(m.by[x]) + ' خط']; });

    var grid =
      block('💾 بکاپ و سرورها', !vms().length ? [] : [
        ['تعداد سرورها', fa(vms().length)],
        size ? ['حجمِ کل', fa(Math.round(size)) + ' گیگابایت'] : null,
        Object.keys(sched).length ? ['گروه‌های زمان‌بندی', fa(Object.keys(sched).length)] : null,
        d.slots ? ['نرخِ موفقیتِ بکاپِ روزانه', pctTxt(d.pct)] : null,
        f.has ? ['بکاپِ کاملِ به‌روز', fa(f.ok) + ' از ' + fa(vms().length)] : null,
        f.none.length ? ['بی‌تاریخِ بکاپِ کامل', fa(f.none.length)] : null,
        f.old.length ? ['بکاپِ کاملِ کهنه (بیش از یک ماه)', fa(f.old.length)] : null
      ]) +
      block('♻️ تستِ ری‌استور', !r.has ? [] : [
        ['موعد', 'هر ' + fa(r.lim) + ' روز'],
        ['به‌موقع', fa(r.ok)],
        ['نزدیکِ موعد', fa(r.soon)],
        ['از موعد گذشته', fa(r.late.length)],
        ['هیچ‌وقت تست نشده', fa(r.never.length)],
        r.oldest ? ['قدیمی‌ترین تست', escapeHtml(T(r.oldest.v.server)) + ' — ' + fa(r.oldest.d) + ' روز پیش'] : null
      ]) +
      block('🖥️ چک‌لیستِ ریموت', !rm.n ? [] : [
        ['سرورهای زیرِ بررسی', fa(rm.n)],
        rm.days ? ['روزهای ثبت‌شده', fa(rm.days)] : null,
        rm.pct != null ? ['خانه‌های پُرشده', fa(rm.marks) + ' از ' + fa(rm.slots) + '  (' + fa(rm.pct) + '٪)'] : null
      ]) +
      block('💻 سیستم‌ها', !s.n ? [] : [
        ['تعداد سیستم‌ها', fa(s.n)],
        ['افراد', fa(s.people)],
        s.ram ? ['مجموعِ رم', fa(s.ram) + ' گیگابایت'] : null,
        ['آی‌پیِ تکراری', fa(s.dupIp.length)],
        s.dupUser.length ? ['یوزرِ تکراری', fa(s.dupUser.length)] : null,
        s.half.length ? ['ردیفِ ناقص', fa(s.half.length)] : null
      ]) +
      block('✅ چک‌لیستِ ماهانه', !t.n ? [] : [
        ['کلِ کارها', fa(t.n)],
        ['انجام‌شده', fa(t.done) + '  (' + pctTxt(t.pct) + ')'],
        t.doing ? ['در حالِ انجام', fa(t.doing)] : null,
        isNow() ? ['عقب‌افتاده', fa(t.late.length)] : ['ناتمام', fa(t.open)],
        ['اولویتِ بالا و باز', fa(t.crit)],
        prev && prev.t.pct != null ? ['ماهِ قبل', fa(prev.t.pct) + '٪ انجام'] : null
      ]) +
      block('🗓️ برنامهٔ روزانه', !dy.n ? [] : [
        ['روزهای پُرشده', fa(dy.n)],
        ['انجام‌شده', fa(dy.done) + '  (' + pctTxt(dy.pct) + ')'],
        dy.imp ? ['روزهای مهم', fa(dy.imp)] : null
      ]) +
      block('📱 خطوطِ MVPN', !m.n ? [] : [['کلِ خطوط', fa(m.n)]].concat(stages)) +
      block('🏢 بازدیدها', !v.n ? [] : [
        ['تعدادِ بازدید/پشتیبانی', fa(v.n)],
        ['شرکت‌ها', fa(v.firms)]
      ]) +
      block('📡 دستگاه‌های زیرِ پینگ', !pg.n ? [] : [['نشانی‌های ثبت‌شده', fa(pg.n)]]);

    var nt = note();
    box.innerHTML =
      scoreBox(sc, prev ? { n: prev.n } : null) +
      '<div class="panel hr-act-box"><h3>⚠️ آنچه اقدام می‌خواهد</h3>' + act + '</div>' +
      openTasks(k) +
      (grid ? '<div class="hr-grid">' + grid + '</div>' : '') +
      chartBox(k) +
      '<div class="panel hr-note-box"><h3>📝 توضیحِ تهیه‌کننده</h3>' +
      '<textarea id="hrNote" class="hr-note" rows="3" placeholder="هر چه باید کنارِ این عددها خوانده شود — کاری که در راه است، قطعیِ برق، خریدی که عقب افتاده…">' +
      escapeHtml(nt) + '</textarea>' +
      '<div class="hr-note-print">' + (escapeHtml(nt).replace(/\n/g, '<br>') || '—') + '</div></div>' +
      '<div class="hr-sign"><span>تهیه‌کننده: ………………………</span>' +
      '<span>امضا: ………………………</span>' +
      '<span>تاریخ: ' + (when ? fa(when) : '…………') + '</span></div>';

    var nb = document.getElementById('hrNote');
    if (nb) nb.addEventListener('change', function () {
      safe(function () { state.healthNote = nb.value; scheduleSave(); return 1; }, 0);
      var pr = document.querySelector('.hr-note-print');
      if (pr) pr.innerHTML = escapeHtml(nb.value).replace(/\n/g, '<br>') || '—';
    });

    chart(k);
  }

  /* دکمهٔ چاپ را موتورِ چاپ خودش کنارِ عنوانِ بخش می‌گذارد — هر
     بخشی که section-title دارد. پس این‌جا فقط کشیدنِ صفحه است. */
  var wired = false;
  function wire() {
    if (!wired) {
      var sel = document.getElementById('hrMonth');
      if (sel) sel.addEventListener('change', function () {
        pick = sel.value || '';
        render();
      });
      wired = true;
    }
    render();
  }

  return { wire: wire, render: render, score: score };
})();

try {
  if (document.getElementById('view-health')) HEALTH.wire();
} catch (e) { console.error('[گزارش سلامت]', e); }
