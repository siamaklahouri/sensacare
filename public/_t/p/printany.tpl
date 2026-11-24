/* ==================== چاپ از هر بخش ====================

   تا امروز فقط دو جا دکمهٔ چاپ داشت: تقویم و گزارش‌ساز. بقیه — چک‌لیست،
   برنامهٔ روزانه، سرورها، شرکت‌ها، خطوط، ویم — هیچ. و همان دو تا هم
   کاغذی می‌دادند که هیچ نمی‌گفت: شبکهٔ تقویم بی عنوان، بی نامِ کارتابل،
   بی ماه، بی تاریخ. کسی که برگه را روی میز می‌بیند نمی‌داند مالِ چیست.

   این پاره هر دو را با هم حل می‌کند:

   ۱) هر بخشی که «section-title» دارد، خودش دکمهٔ چاپ می‌گیرد. دستی در
      بیست‌وپنج جا دکمه نمی‌گذاریم — عنوان همان لنگرِ مشترک است، و هر
      بخشِ تازه‌ای که اضافه شود دکمه‌اش را رایگان می‌گیرد.

   ۲) سرِ کاغذ یک سربرگ می‌نشیند: نامِ کارتابل، نامِ بخش، توضیحش، و
      تاریخ و ساعتِ چاپ. برای تقویم، ماهِ روی صفحه هم می‌آید — چون
      نوارِ ماه خودش روی کاغذ نمی‌رود.

   ۳) «همه‌ی بخش‌ها» هم هست: یکی‌یکی پشتِ هم، هر کدام با سربرگِ خودش و
      یک شکستِ صفحه در میان.

   چرا کلاس روی خودِ بخش و نه یک گزینشگرِ id: CSS نمی‌تواند id را از
   مقدارِ یک صفت بسازد. پس هنگامِ چاپ، بخشِ مقصد کلاسِ «kb-print»
   می‌گیرد و شیوه‌نامه بقیه را برمی‌دارد. همین یک قاعده برای هر تعداد
   بخش کار می‌کند.                                                   */

(function () {
  var HTML = document.documentElement;

  /* چاپگر، با همان خط‌های قلمِ صفحه. «stroke-width» کمی بیشتر از یک
     است تا روی صفحه‌نمایشِ معمولی هم محو نشود. */
  var PRINTER_SVG =
    '<svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true" focusable="false" ' +
    'fill="none" stroke="currentColor" stroke-width="1.8" ' +
    'stroke-linecap="round" stroke-linejoin="round">' +
    '<path d="M7 9V4h10v5"/>' +
    '<path d="M7 18H5a2 2 0 0 1-2-2v-4a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v4a2 2 0 0 1-2 2h-2"/>' +
    '<rect x="7" y="14" width="10" height="7" rx="1"/>' +
    '</svg>';

  /* بخش‌هایی که جدولِ پهن دارند، روی کاغذِ خوابیده جا می‌شوند. بقیه
     ایستاده بهترند — متنِ یک ستونه روی کاغذِ خوابیده کشیده و بدریخت
     می‌شود. */
  var WIDE = { 'view-cal': 1, 'view-daily': 1, 'view-checklist': 1,
               'view-servers': 1, 'view-companies': 1, 'view-mvpn': 1,
               'view-veeam': 1, 'view-shared-rowtone': 1 };

  function views() {
    return [].slice.call(document.querySelectorAll('.content > .view'))
      .filter(function (v) { return v.querySelector('.section-title'); });
  }

  /* عنوان را پیش از چسباندنِ دکمه برمی‌داریم و کنارِ خودِ عنصر نگه
     می‌داریم. بی این، سربرگِ کاغذ «سرورها و بکاپ🖨» می‌شد — شکلکِ
     دکمه‌ای که خودمان همان‌جا گذاشته بودیم. */
  /* شکلک روی کاغذ، به‌ویژه در ویندوز، بد در می‌آید: قلمِ شکلکِ رنگی
     موقعِ چاپ یا تخت و مات می‌شود یا یک مربعِ خالی. سربرگِ کاغذ مالِ
     ماست و باید متنِ خالص باشد — عنوانِ تقویم شکلکِ فصل را با خودش
     می‌آورد («🍂 آبان ۱۴۰۴») و همان روی برگهٔ کاربر زشت افتاده بود.
     داخلِ خودِ بخش‌ها دست نمی‌زنیم؛ آن‌جا شکلک بخشی از محتواست. */
  function noEmoji(t) {
    return String(t == null ? '' : t)
      .replace(/[\u{1F000}-\u{1FAFF}\u{2190}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}\u{200D}]/gu, '')
      .replace(/\s+/g, ' ').trim();
  }

  function titleOf(v) {
    var el = v.querySelector('.section-title');
    if (!el) return '';
    if (el.dataset.kbTtl) return el.dataset.kbTtl;
    return el.textContent.replace(/\s+/g, ' ').trim();
  }
  function subOf(v) {
    var el = v.querySelector('.section-sub');
    return el ? el.textContent.replace(/\s+/g, ' ').trim() : '';
  }

  /* نامِ کارتابل از عنوانِ صفحه. پسوندهای تزئینی را برمی‌داریم تا
     سرِ کاغذ یک اسمِ کوتاه بنشیند، نه یک جملهٔ SEO. */
  function kartablName() {
    var t = (document.title || '').split('|')[0].split('—')[0];
    return t.replace(/\s+/g, ' ').trim() || 'کارتابل';
  }

  /* «dateStyle:full» رشته‌ای می‌داد که ماه و سال را دوباره می‌گفت و
     کنارِ ماهِ تقویم تکراری می‌شد. این‌طور کوتاه‌تر و خواناتر است. */
  function now() {
    var d = new Date();
    try {
      var day = d.toLocaleDateString('fa-IR', { weekday: 'long', day: 'numeric', month: 'long' });
      var hm = d.toLocaleTimeString('fa-IR', { hour: '2-digit', minute: '2-digit' });
      return day + ' — ساعت ' + hm;
    } catch (e) { return d.toLocaleString('fa-IR'); }
  }

  /* چیزی که روی صفحه هست ولی روی کاغذ نمی‌رود و نبودش برگه را گنگ
     می‌کند. تا امروز فقط یک مورد: ماهِ تقویم، که داخلِ نوارِ دکمه‌هاست
     و آن نوار چاپ نمی‌شود. */
  function noteOf(v) {
    var bits = [];
    var cal = v.querySelector('#calTtl');
    if (cal && noEmoji(cal.textContent)) bits.push(noEmoji(cal.textContent));
    var rows = v.querySelectorAll('tbody tr');
    if (rows.length) bits.push(faNum(rows.length) + ' ردیف');
    return bits.join(' · ');
  }

  function faNum(n) {
    try { return typeof fa === 'function' ? fa(n) : String(n); }
    catch (e) { return String(n); }
  }

  function makeHead(v, i, total) {
    var d = document.createElement('div');
    d.className = 'kb-phead';
    var who = document.createElement('div');
    who.className = 'kb-phead-who';
    who.textContent = noEmoji(kartablName());
    var h = document.createElement('div');
    h.className = 'kb-phead-ttl';
    h.textContent = noEmoji(titleOf(v));
    d.appendChild(who);
    d.appendChild(h);
    var sub = subOf(v), note = noteOf(v);
    if (sub) {
      var s = document.createElement('div');
      s.className = 'kb-phead-sub';
      s.textContent = noEmoji(sub);
      d.appendChild(s);
    }
    var foot = document.createElement('div');
    foot.className = 'kb-phead-foot';
    foot.textContent = (note ? note + ' — ' : '') + now() +
      (total > 1 ? ' — بخشِ ' + faNum(i + 1) + ' از ' + faNum(total) : '');
    d.appendChild(foot);
    return d;
  }

  /* کاغذِ خوابیده یا ایستاده را فقط «@page» تعیین می‌کند و @page شرطی
     نمی‌شود — پس همان لحظه یک شیوه‌نامهٔ کوچک می‌سازیم و بعدِ چاپ
     برش می‌داریم. */
  function pageStyle(orient) {
    var el = document.getElementById('kbPageStyle');
    if (!el) {
      el = document.createElement('style');
      el.id = 'kbPageStyle';
      document.head.appendChild(el);
    }
    el.textContent = '@page{ size:A4 ' + orient + '; margin:10mm }';
    /* شیوه‌نامه هم باید بداند کاغذ ایستاده است یا خوابیده: شبکه‌های
       داشبورد با عرضِ رسانه تصمیم می‌گیرند و عرضِ رسانه در چاپ عرضِ
       کاغذ است — نتیجه‌اش این شد که سه کارت دو ستونه می‌شدند و
       سومی تنها می‌افتاد صفحهٔ بعد. */
    HTML.classList.toggle('kb-land', orient === 'landscape');
    HTML.classList.toggle('kb-port', orient !== 'landscape');
  }

  /* ---------- خانه‌های جدول روی کاغذ ----------
     خانه‌ها <input> اند. input نه می‌شکند نه بلند می‌شود، پس هر متنی
     که از عرضِ ستون بیشتر باشد روی کاغذ بریده می‌رود — «بررسی صحت
     بکاپ شبانه‌ی سرور…» و تمام. روی صفحه اشکالی ندارد چون می‌شود
     داخلش لغزاند؛ روی کاغذ چیزی نمی‌لغزد.

     پس هنگامِ چاپ کنارِ هر کادر یک <span> با همان متن می‌گذاریم و
     خودِ کادر را پنهان می‌کنیم. span می‌شکند، بلند می‌شود، و جایش را
     هم به ردیف می‌دهد. بعدِ چاپ همه‌شان برداشته می‌شوند. */
  function unbox(root) {
    [].forEach.call(root.querySelectorAll('input, textarea'), function (el) {
      var t = (el.type || '').toLowerCase();
      if (t === 'checkbox' || t === 'radio' || t === 'file' || t === 'hidden') return;
      if (el.dataset.kbVal) return;
      var sp = document.createElement('span');
      sp.className = 'kb-pval';
      sp.textContent = el.value || '';
      el.dataset.kbVal = '1';
      el.insertAdjacentElement('afterend', sp);
    });
  }

  /* ستونِ «حذف» روی کاغذ فقط یک ستونِ خالی است — دکمه‌اش که چاپ
     نمی‌شود. ولی نمی‌شود همان‌جا در CSS پنهانش کرد: اگر فقط <th> برود
     ستون‌ها یکی جابه‌جا می‌شوند. پس جایش را از روی سرِ جدول پیدا
     می‌کنیم و هر دو — سر و خانه‌ها — را با هم برمی‌داریم. */
  /* ستونی که روی کاغذ حرفی برای گفتن ندارد.

     اولش فقط «col-del» بود. ولی ستونِ پیوست (📎)، ستاره (⭐)،
     یادآور (⏰) و مانندشان هم روی کاغذ خالی‌اند — خودِ دکمه‌هایشان
     برداشته می‌شوند و یک ستونِ باریکِ خالی می‌ماند با یک شکلک بالای
     سرش. چند تا از این‌ها کنارِ هم، لبهٔ برگه را به یک ردیفِ شکلک
     تبدیل کرده بود.

     قاعده: ستونی می‌رود که یا ستونِ حذف باشد، یا سرش اسم نداشته
     باشد (فقط شکلک) و هیچ خانه‌اش هم چیزی برای چاپ نداشته باشد.
     «اسم نداشتن» با حرف سنجیده می‌شود، نه با طول — ستونِ «🔁 تکرار»
     که «هر ماه» در خانه‌هایش است می‌ماند، چون داده دارد. */
  var NAMED_TH = /[A-Za-z\u0621-\u06CC]/;

  function printableText(td) {
    if (!td) return '';
    var f = td.querySelector('input:not([type=checkbox]):not([type=radio]),select,textarea');
    if (f) return String(f.value || '').trim();
    return String(td.textContent || '').replace(/\s+/g, ' ').trim();
  }

  function dropActionCols(root) {
    [].forEach.call(root.querySelectorAll('table'), function (tb) {
      var head = tb.querySelector('tr');
      if (!head) return;
      var rows = [].slice.call(tb.querySelectorAll('tr'));
      var cells = [].slice.call(head.children);
      cells.forEach(function (th, i) {
        var drop = th.classList.contains('col-del') ||
                   !!th.querySelector('.edit-toggle-wrap, .del-toggle-wrap');
        if (!drop) {
          var name = String(th.textContent || '').replace(/\s+/g, '');
          if (name && NAMED_TH.test(name)) return;      /* ستونِ اسم‌دار می‌ماند */
          /* بی‌اسم: فقط اگر هیچ خانه‌اش چیزی ندارد */
          drop = rows.every(function (tr) {
            return tr === head || !printableText(tr.children[i]);
          });
        }
        if (!drop) return;
        rows.forEach(function (tr) {
          var c = tr.children[i];
          if (c) c.classList.add('kb-pskip');
        });
      });
    });
  }

  /* ---------- گروهی که چیزی برایش نمانده ----------
     نمودارِ بی‌داده روی کاغذ چاپ نمی‌شود. ولی عنوانِ گروهش —
     «زیرساخت و ارتباطات» — می‌ماند و بالای یک جای خالی می‌نشیند.

     در CSS نمی‌شود نوشت: شرطش «عنوانی که گروهِ بعدش هیچ کارتِ
     چاپ‌شدنی ندارد» است و این یعنی :has داخلِ :has، که مجاز نیست.
     پس همین‌جا، با همان منطقی که شیوه‌نامه دارد. */
  function hideEmptyGroups(root) {
    [].forEach.call(root.querySelectorAll('.dash-group-label'), function (lab) {
      var next = lab.nextElementSibling;
      if (!next) return;
      var panels = next.querySelectorAll('.panel');
      if (!panels.length) return;
      var any = [].some.call(panels, function (pn) {
        return !pn.querySelector('canvas[data-empty="1"]');
      });
      if (!any) lab.classList.add('kb-pskip');
    });
  }

  function rebox(root) {
    [].forEach.call((root || document).querySelectorAll('.kb-pskip'),
      function (c) { c.classList.remove('kb-pskip'); });
    [].forEach.call((root || document).querySelectorAll('.kb-pval'),
      function (sp) { sp.remove(); });
    [].forEach.call((root || document).querySelectorAll('[data-kb-val]'),
      function (el) { delete el.dataset.kbVal; });
  }

  /* پیش‌فرضِ انیمیشنِ نمودارها، همان‌طور که پیش از چاپ بود */
  var animWas = null;

  function cleanup() {
    /* وگرنه بعد از اولین چاپ، نمودارهای صفحه تا پایانِ همان نشست
       بی‌حرکت می‌ماندند. */
    try {
      if (animWas !== null && window.Chart && Chart.defaults) {
        Chart.defaults.animation = animWas;
        animWas = null;
      }
    } catch (e) { }
    rebox(document);
    HTML.classList.remove('kb-printing', 'kb-land', 'kb-port');
    [].forEach.call(document.querySelectorAll('.kb-print'), function (v) {
      v.classList.remove('kb-print', 'kb-print-last');
    });
    [].forEach.call(document.querySelectorAll('.kb-phead'), function (d) { d.remove(); });
    var ps = document.getElementById('kbPageStyle');
    if (ps) ps.remove();
  }

  /* ---------- ایستاده یا خوابیده ----------
     تا امروز خودِ کارتابل تصمیم می‌گرفت: جدول‌های پهن خوابیده،
     بقیه ایستاده. و چون «@page{size:…}» در مرورگر بر انتخابِ کاربر
     در پنجرهٔ چاپ می‌چربد، کاربر عملاً هیچ راهی نداشت — گزارش هم
     همین بود.

     پس انتخاب می‌آید این‌جا، پیش از بازشدنِ پنجرهٔ چاپ. حدسِ قبلی
     حذف نشد؛ همان از پیش انتخاب‌شده است، و اگر کسی عوضش کند برای
     همان بخش یادمان می‌ماند. */
  var ORIENT_KEY = 'kb-print-orient-v1';

  /* فهرستِ WIDE دستی بود و از خودش عقب ماند: هیچ‌کدام از جدول‌های
     مالی در آن نبودند، پس فاکتورها با ده ستون روی کاغذِ ایستاده
     می‌رفتند و در دو سومِ عرضِ برگه له می‌شدند.

     حالا خودِ جدول را می‌شماریم. ستونی که روی کاغذ برداشته می‌شود
     (ستونِ حذف، ستون‌های بی‌اسم و خالی) حساب نمی‌شود، چون عرضی هم
     نمی‌گیرد. فهرستِ WIDE می‌ماند برای بخش‌هایی که جدول ندارند و
     خودمان می‌دانیم پهن‌اند — مثلِ تقویم. */
  var WIDE_COLS = 7;

  function colCount(v) {
    var most = 0;
    [].forEach.call(v.querySelectorAll('table'), function (tb) {
      var head = tb.querySelector('tr');
      if (!head) return;
      var rows = [].slice.call(tb.querySelectorAll('tr'));
      var n = 0;
      [].forEach.call(head.children, function (th, i) {
        if (th.classList.contains('col-del')) return;
        if (th.querySelector('.edit-toggle-wrap, .del-toggle-wrap')) return;
        var name = String(th.textContent || '').replace(/\s+/g, '');
        if ((!name || !NAMED_TH.test(name)) && rows.every(function (tr) {
          return tr === head || !printableText(tr.children[i]);
        })) return;
        n++;
      });
      if (n > most) most = n;
    });
    return most;
  }

  function orientGuess(list) {
    return list.some(function (v) {
      return WIDE[v.id] || colCount(v) >= WIDE_COLS;
    }) ? 'landscape' : 'portrait';
  }
  function orientKeyOf(list) {
    return list.map(function (v) { return v.id; }).join(',') || 'all';
  }
  function orientSaved(list) {
    try {
      var all = JSON.parse(localStorage.getItem(ORIENT_KEY) || '{}');
      var v = all[orientKeyOf(list)];
      return v === 'landscape' || v === 'portrait' ? v : '';
    } catch (e) { return ''; }
  }
  function orientRemember(list, orient) {
    try {
      var all = JSON.parse(localStorage.getItem(ORIENT_KEY) || '{}');
      all[orientKeyOf(list)] = orient;
      localStorage.setItem(ORIENT_KEY, JSON.stringify(all));
    } catch (e) { }
  }

  function askOrient(list, done) {
    var pick = orientSaved(list) || orientGuess(list);
    var ov = document.createElement('div');
    ov.className = 'kb-orient-ov';
    ov.innerHTML =
      '<div class="kb-orient" role="dialog" aria-modal="true" aria-label="جهتِ کاغذ">' +
        '<div class="ko-h">چاپِ «' + esc(list.length === 1 ? titleOf(list[0]) : 'همهٔ بخش‌ها') + '»</div>' +
        '<div class="ko-p">کاغذ را چطور می‌خواهید؟</div>' +
        '<div class="ko-opts">' +
          '<button type="button" class="ko-opt" data-o="portrait" aria-pressed="false">' +
            '<span class="ko-ic ko-p-ic"></span><span>ایستاده</span></button>' +
          '<button type="button" class="ko-opt" data-o="landscape" aria-pressed="false">' +
            '<span class="ko-ic ko-l-ic"></span><span>خوابیده</span></button>' +
        '</div>' +
        '<div class="ko-f">' +
          '<button type="button" class="ko-cancel">بی‌خیال</button>' +
          '<button type="button" class="ko-go">چاپ</button>' +
        '</div>' +
      '</div>';
    document.body.appendChild(ov);

    function paint() {
      [].forEach.call(ov.querySelectorAll('.ko-opt'), function (b) {
        var on = b.getAttribute('data-o') === pick;
        b.classList.toggle('on', on);
        b.setAttribute('aria-pressed', on ? 'true' : 'false');
      });
    }
    paint();

    function close() {
      document.removeEventListener('keydown', onKey, true);
      ov.remove();
    }
    function onKey(e) {
      if (e.key === 'Escape') { e.preventDefault(); close(); }
      else if (e.key === 'Enter') { e.preventDefault(); go(); }
    }
    function go() {
      orientRemember(list, pick);
      close();
      done(pick);
    }
    ov.addEventListener('click', function (e) {
      var opt = e.target.closest('.ko-opt');
      if (opt) { pick = opt.getAttribute('data-o'); paint(); return; }
      if (e.target.closest('.ko-go')) { go(); return; }
      if (e.target.closest('.ko-cancel') || e.target === ov) close();
    });
    document.addEventListener('keydown', onKey, true);
    setTimeout(function () {
      try { ov.querySelector('.ko-go').focus(); } catch (e) { }
    }, 30);
  }

  function esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function setup(list, orient) {
    cleanup();
    if (!list.length) return false;
    pageStyle(orient === 'landscape' || orient === 'portrait'
      ? orient : orientGuess(list));
    list.forEach(function (v, i) {
      v.classList.add('kb-print');
      if (i === list.length - 1) v.classList.add('kb-print-last');
      unbox(v);
      dropActionCols(v);
      hideEmptyGroups(v);
      v.insertBefore(makeHead(v, i, list.length), v.firstChild);
    });
    HTML.classList.add('kb-printing');
    return true;
  }

  /* نمودارها را از حرکت می‌اندازد و فوری می‌کشد.

     با دست‌کاریِ options هر نمودار شروع کردم و Chart.js با
     «Recursion detected: _scriptable» ترکید: options یک پراکسیِ
     حل‌شونده است و نوشتن روی کلیدهای انیمیشن، حل‌کننده را به حلقه
     می‌انداخت. راهِ درست همان چیزی است که خودِ کتابخانه می‌گوید:
     پیش‌فرضِ سراسری را خاموش کن، هر نمودار را stop کن، و یک
     به‌روزرسانیِ بی‌انیمیشن بخواه.

     responsive را دست نمی‌زنیم: می‌خواهیم نمودار خودش را با عرضِ
     کاغذ جور کند — فقط بی‌حرکت. */
  function freezeCharts(list) {
    var n = 0;
    try {
      if (window.Chart && Chart.defaults) {
        if (animWas === null) animWas = Chart.defaults.animation;
        Chart.defaults.animation = false;
      }
    } catch (e) { }
    list.forEach(function (v) {
      [].forEach.call(v.querySelectorAll('canvas'), function (cv) {
        var c = null;
        try { c = (window.Chart && Chart.getChart) ? Chart.getChart(cv) : null; } catch (e) { }
        if (!c) return;
        /* و مهم‌تر از همه: بوم روی کاغذ دوباره اندازه نگیرد.

           Chart.js «responsive» است و با عوض شدنِ عرضِ قاب، بوم را
           از نو می‌کشد — و عرضِ قاب دقیقاً وقتی عوض می‌شود که
           مرورگر چیدمانِ کاغذ را می‌سازد، یعنی بعد از کدِ ما و
           پیش از عکسِ چاپ. آن کشیدنِ دوباره به‌موقع تمام نمی‌شد و
           بوم نیمه‌کاره روی برگه می‌رفت.

           با خاموش‌کردنِ responsive، همان تصویری که روی صفحه کامل
           کشیده شده روی کاغذ می‌رود و فقط با CSS کوچک می‌شود.

           «animations» (جمع) را دست نمی‌زنیم: Chart.js با
           «Recursion detected: _scriptable» می‌ترکد. */
        try { c.options.responsive = false; } catch (e) { }
        try { c.stop(); } catch (e) { }
        try { c.resize(); } catch (e) { }
        try { c.update('none'); n++; } catch (e) { }
      });
    });
    return n;
  }

  /* دو فریمِ واقعیِ نقاشی، نه یک تایمرِ حدسی. */
  function afterPaint(fn) {
    var raf = window.requestAnimationFrame;
    if (!raf) { setTimeout(fn, 260); return; }
    raf(function () { raf(function () { setTimeout(fn, 60); }); });
  }

  function activeView() {
    return document.querySelector('.content > .view.active');
  }

  /* چاپ. «all» یعنی همهٔ بخش‌ها پشتِ سرِ هم. */
  function kbPrint(which, orient) {
    var list;
    if (which === 'all') list = views();
    else if (which && which.nodeType === 1) list = [which];
    else if (typeof which === 'string') {
      var v = document.getElementById(which);
      list = v ? [v] : [];
    } else list = [activeView()].filter(Boolean);
    if (!list.length) return;
    /* ترتیبِ این دو خط گران تمام شد و درسش این است: کشیدنِ دوباره
       جدول‌ها را از نو می‌سازد، پس هر چیزی که ما به DOM اضافه کرده
       باشیم پاک می‌شود. بارِ اول setup جلوتر بود و روی کاغذ سه ستون —
       وظیفه، مسئول، یادداشت — کاملاً خالی درآمدند: span‌ها ساخته شده
       بودند و بلافاصله دور ریخته شده بودند.

       پس اول می‌کشیم (تا نمودارها در اندازهٔ کاغذ تار نباشند)، بعد
       آماده می‌کنیم. */
    /* جهت اگر صریح داده شده باشد، بی‌پرسش. وگرنه یک بار می‌پرسیم. */
    var run = function (o) {
      try { if (typeof redrawAfterTheme === 'function') redrawAfterTheme(); } catch (e) { }
      setTimeout(function () {
        if (!setup(list, o)) return;
        /* نمودارها جانِ کلام‌اند و نیمه‌کشیده روی کاغذ می‌افتادند.

           دو چیز هم‌زمان اتفاق می‌افتد: Chart.js هر بار با انیمیشن
           می‌کشد (حدودِ یک ثانیه)، و کلاسِ چاپ که می‌نشیند عرضِ
           بوم عوض می‌شود و یک کشیدنِ دیگر شروع می‌شود. ما ۱۴۰
           میلی‌ثانیه بعد window.print را صدا می‌زدیم — درست وسطِ
           همان کشیدن. نتیجه‌اش نمودارِ نصفه بود؛ گاهی یک چارکِ
           دایره، گاهی میله‌های نیم‌قد.

           پس اول انیمیشن را خاموش می‌کنیم و یک کشیدنِ فوری
           می‌خواهیم، بعد دو فریم صبر می‌کنیم تا مرورگر واقعاً
           نقاشی‌اش کند، و تازه بعد چاپ. */
        freezeCharts(list);
        afterPaint(function () { window.print(); });
      }, 140);
    };
    if (orient === 'landscape' || orient === 'portrait') run(orient);
    else askOrient(list, run);
  }

  /* دکمه‌ها، یکی سرِ هر بخش. کنارِ عنوان می‌نشینند، نه داخلِ نوارهای
     موجود: هر بخش نوارِ خودش را دارد و بعضی اصلاً ندارند. */
  function wire() {
    views().forEach(function (v) {
      var ttl = v.querySelector('.section-title');
      if (!ttl || ttl.querySelector('.kb-print-btn')) return;
      ttl.dataset.kbTtl = ttl.textContent.replace(/\s+/g, ' ').trim();
      var b = document.createElement('button');
      b.type = 'button';
      b.className = 'kb-print-btn';
      b.title = 'چاپ یا ذخیرهٔ PDF از همین بخش';
      b.setAttribute('aria-label', 'چاپ بخشِ ' + titleOf(v));
      /* آیکن برداری است، نه شکلک. «🖨» روی ویندوز در قلمِ شکلکِ
         سیستم نیست و یک مربعِ خالی می‌شد — کاربر عکسش را فرستاد.
         شکلکِ متنی هیچ تضمینی ندارد؛ SVG همه‌جا یک شکل است و رنگش
         را هم از «currentColor» می‌گیرد، پس با تم می‌چرخد. */
      b.innerHTML = PRINTER_SVG;
      b.addEventListener('click', function () { kbPrint(v); });
      ttl.appendChild(b);
    });
    /* «همه‌ی بخش‌ها» در تنظیمات می‌نشیند، نه کنارِ عنوان‌ها: کارِ
       روزمره چاپِ یک بخش است و دکمهٔ دومِ کنارِ هر عنوان فقط شلوغی
       بود. */
    /* دکمه‌های چاپِ قدیمی — تقویم و گزارش‌ساز — هم شکلکِ «🖨» داشتند
       و روی ویندوز همان مربعِ خالی می‌شدند. حالا همه یک آیکن دارند،
       از یک جا. */
    [].forEach.call(document.querySelectorAll('[data-print-ic]'), function (btn) {
      if (btn.dataset.kbIc) return;
      btn.dataset.kbIc = '1';
      btn.classList.add('kb-print-all');
      btn.insertAdjacentHTML('afterbegin', PRINTER_SVG + ' ');
    });

    var all = document.getElementById('printAllBtn');
    if (all && !all.dataset.kbWired) {
      all.dataset.kbWired = '1';
      /* همان آیکنِ برداری، نه شکلک: در قالب هم نوشته نمی‌شود تا دو
         جا دو جور نباشد. */
      all.insertAdjacentHTML('afterbegin', PRINTER_SVG + ' ');
      all.classList.add('kb-print-all');
      all.addEventListener('click', function () { kbPrint('all'); });
    }
  }

  /* Ctrl+P هم باید همان کاغذ را بدهد، نه صفحهٔ خام. اگر خودمان چاپ را
     شروع نکرده باشیم، بخشِ باز را آماده می‌کنیم. */
  window.addEventListener('beforeprint', function () {
    if (!HTML.classList.contains('kb-printing')) setup([activeView()].filter(Boolean));
  });
  window.addEventListener('afterprint', cleanup);

  window.KBPRINT = { print: kbPrint, all: function () { kbPrint('all'); }, wire: wire };
  window.kbPrint = kbPrint;

  if (document.readyState === 'loading')
    document.addEventListener('DOMContentLoaded', wire);
  else wire();
  setTimeout(wire, 1800);
})();
