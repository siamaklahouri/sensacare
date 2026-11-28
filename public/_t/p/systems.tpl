/* ==================== سیستم‌ها ====================
   فهرستِ کامپیوترهای شرکت: پشتِ هر سیستم چه کسی می‌نشیند، با چه
   یوزری، با چه ایمیلی، و زیرش چه سخت‌افزاری هست.

   دو چیز این‌جا بیش از بقیه به کار می‌آید و برای همین حساب می‌شود:
   آی‌پیِ تکراری (دو سیستم با یک نشانی یعنی یکی‌شان امروز یا فردا
   بالا نمی‌آید) و یوزرِ تکراری. هر دو با نشانهٔ قرمز روی خودِ خانه
   گفته می‌شود، نه در یک گزارشِ جدا.

   داده در خودِ کارتابل می‌نشیند (state.systems)، پس مثلِ بقیهٔ
   بخش‌ها هم پشتیبان می‌گیرد، هم می‌شود به اشتراک گذاشت. */
window.SYSTEMS = (function () {
  "use strict";

  var COLS = [
    { k: 'person', t: 'شخص',          ph: 'نامِ کاربر' },
    { k: 'user',   t: 'یوزر',         ph: 'username', ascii: true },
    { k: 'name',   t: 'اسمِ سیستم',   ph: 'PC-001',   ascii: true },
    { k: 'email',  t: 'ایمیل',        ph: 'name@company.ir', ascii: true },
    { k: 'ip',     t: 'آی‌پی',        ph: '192.168.1.10',    ascii: true },
    { k: 'cpu',    t: 'مدلِ پردازنده', ph: 'Core i5-10400', ascii: true },
    { k: 'ram',    t: 'رم (GB)',      ph: '8', ascii: true, num: true }
  ];

  var q = '';

  /* سرستون‌های فایلِ اکسل. هر ستون چند نامِ شناخته‌شده دارد، چون
     فهرستِ سیستم‌ها را هر کسی به سلیقهٔ خودش نوشته: یکی «نام
     کامپیوتر»، یکی «Hostname»، یکی «PC». XMap سرستون را از روی
     نامش پیدا می‌کند، پس ترتیبِ ستون‌ها در فایل هیچ فرقی نمی‌کند. */
  var SCHEMA = [
    { k: 'person', as: ['شخص', 'نام و نام خانوادگی', 'نامِ شخص', 'نام شخص', 'کارمند', 'نام',
                        'Person', 'Owner', 'Employee', 'Full Name'] },
    { k: 'user',   as: ['یوزر', 'نام کاربری', 'یوزرنیم', 'Username', 'User', 'Login', 'Account'] },
    { k: 'name',   as: ['اسمِ سیستم', 'اسم سیستم', 'نام سیستم', 'نام کامپیوتر',
                        'Computer Name', 'System Name', 'Hostname', 'PC'] },
    { k: 'email',  as: ['ایمیل', 'پست الکترونیک', 'Email', 'E-Mail', 'Mail'] },
    { k: 'ip',     as: ['آی‌پی', 'ای پی', 'آدرس آی پی', 'IP', 'IP Address'] },
    { k: 'cpu',    as: ['مدلِ پردازنده', 'مدل پردازنده', 'پردازنده', 'سی پی یو',
                        'CPU', 'Processor', 'CPU Model'] },
    { k: 'ram',    as: ['رم', 'رم (GB)', 'حافظه', 'RAM', 'Memory'] }
  ];

  function rows() {
    if (!Array.isArray(state.systems)) {
      state.systems = [];
      try { scheduleSave(); } catch (e) { }
    }
    return state.systems;
  }

  function txt(v) { return String(v == null ? '' : v).trim(); }

  /* جست‌وجو نباید به رقمِ فارسی یا لاتین حساس باشد: کسی که «۱۹۲»
     می‌نویسد همان «192» را می‌خواهد. */
  function norm(v) {
    return txt(v).toLowerCase()
      .replace(/[۰-۹]/g, function (d) { return String('۰۱۲۳۴۵۶۷۸۹'.indexOf(d)); })
      .replace(/[٠-٩]/g, function (d) { return String('٠١٢٣٤٥٦٧٨٩'.indexOf(d)); });
  }

  /* چند بار این مقدار در ستون آمده. مقدارِ خالی هیچ‌وقت تکراری
     نیست — نیمی از ردیف‌ها تا پُر شدن خالی‌اند. */
  function counts(field) {
    var c = {};
    rows().forEach(function (r) {
      var v = txt(r[field]).toLowerCase();
      if (v) c[v] = (c[v] || 0) + 1;
    });
    return c;
  }

  function hit(r) {
    if (!q) return true;
    return COLS.some(function (c) {
      return norm(r[c.k]).indexOf(q) >= 0;
    });
  }

  function cards() {
    var box = document.getElementById('syCards');
    if (!box) return;
    var all = rows();
    var people = {}, ram = 0, cpu = {};
    all.forEach(function (r) {
      var p = txt(r.person); if (p) people[p] = 1;
      var n = parseFloat(String(r.ram).replace(/[^\d.]/g, ''));
      if (Number.isFinite(n)) ram += n;
      var c = txt(r.cpu); if (c) cpu[c] = (cpu[c] || 0) + 1;
    });
    var top = Object.keys(cpu).sort(function (a, b) { return cpu[b] - cpu[a]; })[0];
    var dupIp = counts('ip');
    var bad = Object.keys(dupIp).filter(function (k) { return dupIp[k] > 1; }).length;

    box.innerHTML =
      '<div class="stat" style="--accent:var(--c1); --tint:var(--t1)"><div class="stat-head">' +
        '<span class="stat-ic">💻</span><span class="stat-lbl">سیستم‌ها</span></div>' +
        '<div class="stat-val">' + fa(all.length) + '</div></div>' +
      '<div class="stat" style="--accent:var(--c2); --tint:var(--t2)"><div class="stat-head">' +
        '<span class="stat-ic">👥</span><span class="stat-lbl">افراد</span></div>' +
        '<div class="stat-val">' + fa(Object.keys(people).length) + '</div></div>' +
      '<div class="stat" style="--accent:var(--c3); --tint:var(--t3)"><div class="stat-head">' +
        '<span class="stat-ic">🧠</span><span class="stat-lbl">مجموعِ رم</span></div>' +
        '<div class="stat-val">' + fa(Math.round(ram)) + '</div>' +
        '<div class="stat-sub">گیگابایت</div></div>' +
      '<div class="stat ' + (bad ? 'is-alert' : 'is-clear') + '"><div class="stat-head">' +
        '<span class="stat-ic">' + (bad ? '⚠️' : '✅') + '</span>' +
        '<span class="stat-lbl">آی‌پیِ تکراری</span></div>' +
        '<div class="stat-val">' + fa(bad) + '</div>' +
        '<div class="stat-sub">' + (bad ? 'در جدول قرمز شده‌اند' : (top ? 'پرتکرارترین پردازنده: ' + escapeHtml(top) : 'همه یکتا')) + '</div></div>';
  }

  function cell(r, i, c, dupIp, dupUser) {
    var v = txt(r[c.k]);
    var warn = '';
    if (c.k === 'ip' && v && dupIp[v.toLowerCase()] > 1) warn = ' is-dup';
    if (c.k === 'user' && v && dupUser[v.toLowerCase()] > 1) warn = ' is-dup';
    return '<td><input type="text" class="sy-in' + warn + '" data-sy="' + c.k + '" data-i="' + i + '"' +
      (c.ascii ? ' data-ascii' : '') +
      (warn ? ' title="این مقدار در ردیفِ دیگری هم هست"' : '') +
      ' value="' + escapeHtml(v) + '" placeholder="' + escapeHtml(c.ph) + '"' +
      ' autocomplete="off" data-lpignore="true" data-1p-ignore data-form-type="other"></td>';
  }

  function render() {
    var body = document.getElementById('syBody');
    if (!body) return;
    cards();

    var all = rows();
    var dupIp = counts('ip'), dupUser = counts('user');
    var list = all.map(function (r, i) { return { r: r, i: i }; }).filter(function (x) { return hit(x.r); });

    body.innerHTML = list.map(function (x, n) {
      return '<tr>' +
        '<td class="sy-no">' + fa(n + 1) + '</td>' +
        COLS.map(function (c) { return cell(x.r, x.i, c, dupIp, dupUser); }).join('') +
        '<td><button class="btn-del" data-sy-del="' + x.i + '" title="حذف این ردیف">✕</button></td>' +
      '</tr>';
    }).join('') || ('<tr class="tbl-empty"><td colspan="' + (COLS.length + 2) + '">' +
      '<span class="te-ic">💻</span>' +
      '<div class="te-h">' + (all.length ? 'با این جست‌وجو چیزی پیدا نشد' : 'هنوز سیستمی ثبت نشده') + '</div>' +
      '<div class="te-p">' + (all.length ? 'عبارتِ دیگری را امتحان کنید.' : 'با فرمِ پایین اولین سیستم را اضافه کنید.') + '</div>' +
      '</td></tr>');

    var cnt = document.getElementById('syCount');
    if (cnt) cnt.textContent = all.length
      ? (q ? fa(list.length) + ' از ' + fa(all.length) + ' سیستم' : fa(all.length) + ' سیستم')
      : '';

    body.querySelectorAll('input[data-sy]').forEach(function (el) {
      el.addEventListener('change', function () {
        var i = parseInt(el.getAttribute('data-i'), 10);
        var row = rows()[i];
        if (!row) return;
        row[el.getAttribute('data-sy')] = el.value.trim();
        scheduleSave();
        render();
      });
    });
    body.querySelectorAll('[data-sy-del]').forEach(function (b) {
      b.addEventListener('click', function () {
        var i = parseInt(b.getAttribute('data-sy-del'), 10);
        var r = rows()[i] || {};
        var nm = txt(r.name) || txt(r.person);
        delRow(rows(), i, nm ? 'سیستمِ «' + nm + '»' : 'این سیستم',
          function () { render(); scheduleSave(); });
      });
    });
  }

  function add() {
    var got = {}, any = false;
    COLS.forEach(function (c) {
      var el = document.getElementById('syNew_' + c.k);
      var v = el ? el.value.trim() : '';
      got[c.k] = v;
      if (v) any = true;
    });
    if (!any) { alert('دستِ کم یکی از خانه‌ها را پُر کنید.'); return; }
    rows().push(got);
    COLS.forEach(function (c) {
      var el = document.getElementById('syNew_' + c.k);
      if (el) el.value = '';
    });
    q = '';
    var f = document.getElementById('syFind');
    if (f) f.value = '';
    scheduleSave();
    render();
    var first = document.getElementById('syNew_person');
    if (first) first.focus();
  }

  /* ---------- خواندن از اکسل ----------
     بی‌آن‌که چیزی را پاک کند: ردیف‌های فایل به فهرست اضافه می‌شوند و
     آن‌هایی که از قبل هستند (همان یوزر و همان نامِ سیستم و همان
     آی‌پی) رد می‌شوند. یک فایل را دو بار بخوانی، فهرست دو برابر
     نمی‌شود. */
  function say(t) {
    var el = document.getElementById('syXStatus');
    if (el) el.textContent = t || '';
  }

  function sig(r) {
    return norm(r.user) + '|' + norm(r.name) + '|' + norm(r.ip) + '|' + norm(r.person);
  }

  function take(list) {
    var have = {};
    rows().forEach(function (r) { have[sig(r)] = 1; });
    var add = 0, skip = 0, empty = 0;
    list.forEach(function (raw) {
      var r = {}, any = false;
      COLS.forEach(function (c) {
        var v = txt(raw[c.k]);
        r[c.k] = v;
        if (v) any = true;
      });
      if (!any) { empty++; return; }
      var k = sig(r);
      if (have[k]) { skip++; return; }
      have[k] = 1;
      rows().push(r);
      add++;
    });
    return { add: add, skip: skip, empty: empty };
  }

  async function fromFile(file) {
    if (!file) return;
    say('در حال بارگذاریِ کتابخانهٔ اکسل…');
    var ready = false;
    try { ready = await ensureXlsxLib(); } catch (e) { ready = false; }
    if (!ready) { say('⚠️ کتابخانهٔ اکسل بار نشد (اینترنت را بررسی کنید).'); return; }
    try {
      say('در حال خواندنِ «' + file.name + '»…');
      var buf = await file.arrayBuffer();
      var wb = XLSX.read(buf, { type: 'array', raw: true, cellDates: false });
      var r = XMap.read(wb, 'Systems', SCHEMA);
      if (!r.found || !r.rows.length) {
        say('⚠️ در این فایل ردیفی پیدا نشد. سطرِ اول باید نامِ ستون‌ها باشد.');
        return;
      }
      /* یک ستونِ شناخته‌شده کافی نیست: نامِ یک‌حرفی یا بی‌ربط هم
         گاهی تصادفی می‌خورد. دو ستون یعنی این واقعاً فهرستِ
         سیستم‌هاست. */
      if (r.matched < 2) {
        say('⚠️ سرستون‌های «' + r.sheet + '» شناخته نشد. با «⬇ نمونهٔ اکسل» ' +
            'یک فایلِ آماده بگیرید و دادهٔ خودتان را در همان بنویسید.');
        return;
      }
      var n = take(r.rows);
      scheduleSave();
      render();
      say('✓ از برگهٔ «' + r.sheet + '»: ' + fa(n.add) + ' سیستم اضافه شد' +
          (n.skip ? '، ' + fa(n.skip) + ' ردیفِ تکراری رد شد' : '') +
          (r.extras && r.extras.length ? ' — ستون‌های ناشناخته نادیده گرفته شد: ' +
            r.extras.join('، ') : '') + '.');
    } catch (e) {
      console.error('[سیستم‌ها]', e);
      say('⚠️ خواندنِ فایل نشد. فایلِ اکسل (xlsx) یا csv بدهید.');
    }
  }

  async function sample() {
    say('در حال ساختنِ فایلِ نمونه…');
    var ready = false;
    try { ready = await ensureXlsxLib(); } catch (e) { ready = false; }
    if (!ready) { say('⚠️ کتابخانهٔ اکسل بار نشد (اینترنت را بررسی کنید).'); return; }
    try {
      XMap.sample('Systems', SCHEMA, [
        { person: 'نام و نام خانوادگی', user: 'username', name: 'PC-001',
          email: 'name@company.ir', ip: '192.168.1.10', cpu: 'Core i5-10400', ram: 8 },
        { person: 'نام و نام خانوادگی', user: 'username2', name: 'PC-002',
          email: 'name2@company.ir', ip: '192.168.1.11', cpu: 'Core i7-11700', ram: 16 }
      ], 'نمونه-سیستم‌ها.xlsx');
      say('✓ «نمونه-سیستم‌ها.xlsx» دانلود شد. ردیف‌های نمونه را پاک کنید، ' +
          'دادهٔ خودتان را بنویسید و با «⬆ خواندن از فایل اکسل» برگردانید.');
    } catch (e) {
      console.error('[سیستم‌ها]', e);
      say('⚠️ ساختنِ فایلِ نمونه نشد.');
    }
  }

  var wired = false;
  function wire() {
    if (!wired) {
      var b = document.getElementById('syAddBtn');
      if (b) b.addEventListener('click', add);

      /* اینتر در فرمِ افزودن، همان دکمهٔ افزودن است: هفت خانه را پُر
         کرده‌ای و دستت روی کیبورد است. */
      var form = document.getElementById('syAdd');
      if (form) form.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); add(); }
      });

      var pick = document.getElementById('syFile');
      var xb = document.getElementById('syXlsxBtn');
      if (xb && pick) xb.addEventListener('click', function () { pick.click(); });
      if (pick) pick.addEventListener('change', function () {
        var file = pick.files && pick.files[0];
        pick.value = '';
        fromFile(file);
      });
      var sb = document.getElementById('sySampleBtn');
      if (sb) sb.addEventListener('click', sample);

      var f = document.getElementById('syFind');
      if (f) f.addEventListener('input', function () {
        q = norm(f.value);
        render();
      });
      wired = true;
    }
    render();
  }

  return { wire: wire, render: render, cols: COLS, schema: SCHEMA };
})();

try {
  if (document.getElementById('view-systems')) SYSTEMS.wire();
} catch (e) { console.error('[سیستم‌ها]', e); }
