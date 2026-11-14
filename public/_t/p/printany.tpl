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
  function dropActionCols(root) {
    [].forEach.call(root.querySelectorAll('table'), function (tb) {
      var head = tb.querySelector('tr');
      if (!head) return;
      var cells = [].slice.call(head.children);
      cells.forEach(function (th, i) {
        if (!th.classList.contains('col-del')) return;
        [].forEach.call(tb.querySelectorAll('tr'), function (tr) {
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

  function cleanup() {
    rebox(document);
    HTML.classList.remove('kb-printing');
    [].forEach.call(document.querySelectorAll('.kb-print'), function (v) {
      v.classList.remove('kb-print', 'kb-print-last');
    });
    [].forEach.call(document.querySelectorAll('.kb-phead'), function (d) { d.remove(); });
    var ps = document.getElementById('kbPageStyle');
    if (ps) ps.remove();
  }

  function setup(list) {
    cleanup();
    if (!list.length) return false;
    var wide = list.some(function (v) { return WIDE[v.id]; });
    pageStyle(wide ? 'landscape' : 'portrait');
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

  function activeView() {
    return document.querySelector('.content > .view.active');
  }

  /* چاپ. «all» یعنی همهٔ بخش‌ها پشتِ سرِ هم. */
  function kbPrint(which) {
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
    try { if (typeof redrawAfterTheme === 'function') redrawAfterTheme(); } catch (e) { }
    setTimeout(function () {
      if (!setup(list)) return;
      setTimeout(function () { window.print(); }, 140);
    }, 140);
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
