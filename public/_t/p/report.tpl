<!-- ==================== گزارش‌ساز ====================
     یک فایل اکسل، چند کلیک، یک نمودار.

     فایل روی همین دستگاه خوانده می‌شود و هیچ‌جا فرستاده نمی‌شود: نه
     سروری لازم است، نه محدودیتِ حجم، نه جایی که فردا باید پاکش کرد.
     کارتابل هم به محتوایش کاری ندارد — هر اکسلی با هر ستونی. -->
<section class="view" id="view-report" data-feat="view:report">
  <div class="section-title">📊 گزارش‌ساز</div>
  <div class="section-sub">فایل اکسل را بدهید، ستون‌ها را انتخاب کنید، نمودار و خلاصه بگیرید.
    فایل روی همین دستگاه خوانده می‌شود و جایی فرستاده نمی‌شود.</div>

  <div class="panel rp-drop" id="rpDrop">
    <input type="file" id="rpFile" accept=".xlsx,.xls,.xlsm,.csv" hidden>
    <div class="rp-ic">📄</div>
    <button type="button" class="btn btn-brass" id="rpPick">⬆ انتخاب فایل اکسل</button>
    <div class="rp-hint">یا فایل را همین‌جا رها کنید — xlsx، xls یا csv</div>
    <div class="rp-note" id="rpNote"></div>
  </div>

  <div id="rpBody" hidden>
    <div class="panel rp-bar">
      <span class="rp-file" id="rpName"></span>
      <label for="rpSheet">برگه</label>
      <select id="rpSheet"></select>
      <span class="rp-meta" id="rpMeta"></span>
      <button type="button" class="btn btn-sm" id="rpReset">فایل دیگر</button>
    </div>

    <div class="panel">
      <div class="rp-grid">
        <div class="rp-f"><label for="rpKind">نوع گزارش</label>
          <select id="rpKind">
            <option value="bar">📊 نمودار ستونی</option>
            <option value="hbar">📶 ستونیِ افقی</option>
            <option value="stack">🧱 ستونیِ انباشته</option>
            <option value="line">📈 نمودار خطی</option>
            <option value="area">🏔 نمودار سطحی</option>
            <option value="doughnut">🍩 دایره‌ای</option>
            <option value="pie">🥧 دایره‌ایِ پُر</option>
            <option value="polarArea">🎯 گلبرگی</option>
            <option value="radar">🕸 راداری</option>
            <option value="scatter">✳️ پراکندگی</option>
            <option value="table">📋 فقط جدول</option>
          </select></div>
        <div class="rp-f"><label for="rpCat">دسته‌بندی بر اساس</label>
          <select id="rpCat"></select></div>
        <!-- ستونِ دوم برای انباشته و خطیِ چندسری. خالی یعنی یک سری. -->
        <div class="rp-f" id="rpSerWrap"><label for="rpSer">شکستن به سری‌ها (اختیاری)</label>
          <select id="rpSer"></select></div>
        <div class="rp-f"><label for="rpAgg">محاسبه</label>
          <select id="rpAgg">
            <option value="">— بدونِ محاسبه، خودِ مقدارها —</option>
            <option value="sum" selected>جمع</option>
            <option value="avg">میانگین</option>
            <option value="count">شمارش ردیف‌ها</option>
            <option value="max">بیشینه</option>
            <option value="min">کمینه</option>
            <option value="uniq">تعدادِ مقدارهای یکتا</option>
          </select></div>
        <div class="rp-f" id="rpValWrap"><label for="rpVal">روی کدام ستون</label>
          <select id="rpVal"></select></div>
        <div class="rp-f"><label for="rpTop">چند تای اول</label>
          <select id="rpTop">
            <option value="">— همه —</option>
            <option value="5">۵ تای اول</option>
            <option value="10">۱۰ تای اول</option>
            <option value="20">۲۰ تای اول</option>
            <option value="50">۵۰ تای اول</option>
          </select></div>
        <div class="rp-f"><label for="rpSort">ترتیب</label>
          <select id="rpSort">
            <option value="">— به ترتیبِ خودِ فایل —</option>
            <option value="desc" selected>از بیشترین</option>
            <option value="asc">از کمترین</option>
            <option value="cat">بر اساس نامِ دسته</option>
          </select></div>
        <div class="rp-f"><label for="rpFilCol">فقط ردیف‌هایی که… (اختیاری)</label>
          <select id="rpFilCol"></select></div>
        <div class="rp-f"><label for="rpFilVal">برابرِ این باشند</label>
          <select id="rpFilVal"><option value="">— همه —</option></select></div>
      </div>
      <div class="rp-note" id="rpWhy"></div>
    </div>

    <div class="panel" id="rpOut">
      <div class="rp-head">
        <b id="rpTitle">گزارش</b>
        <span class="rp-acts">
          <button type="button" class="btn btn-sm" id="rpPng">⬇ تصویر</button>
          <button type="button" class="btn btn-sm" id="rpXlsx">⬇ اکسلِ خلاصه</button>
          <button type="button" class="btn btn-sm" id="rpPrint">🖨 چاپ</button>
        </span>
      </div>
      <!-- فقط همین تکه چاپ می‌شود. سرصفحه‌اش در حالتِ عادی پنهان است
           و سرِ چاپ می‌آید، چون کاغذ نه نوارِ بالا دارد نه نوارِ کنار. -->
      <div id="rpPaper">
        <div class="rp-print-head">
          <b id="rpPrintTitle"></b>
          <span id="rpPrintMeta"></span>
        </div>
        <div class="rp-cards" id="rpCards"></div>
        <div class="chart-box" id="rpChartBox"><canvas id="rpChart"></canvas></div>
        <div class="tbl-wrap"><table class="tbl rp-tab" id="rpTab"></table></div>
      </div>
    </div>
  </div>
</section>

<style>
  .rp-drop{
    text-align:center; padding:34px 20px; border:2px dashed var(--card-border);
    background:var(--paper-2, transparent); transition:border-color .15s, background .15s;
  }
  .rp-drop.on{ border-color:var(--brass); background:var(--brass-bg); }
  .rp-drop .rp-ic{ font-size:34px; line-height:1; margin-bottom:10px; }
  .rp-hint{ font-size:12px; color:var(--ink-faint); margin-top:10px; line-height:1.9; }
  .rp-note{ font-size:12.5px; line-height:1.9; margin-top:8px; min-height:20px; color:var(--ink-soft); }
  .rp-note.bad{ color:var(--red-ink,#A6222B); }
  .rp-bar{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  .rp-bar label{ font-size:12px; color:var(--ink-faint); }
  .rp-file{ font-weight:700; font-size:13px; color:var(--ink); margin-inline-end:auto; }
  .rp-meta{ font-size:11.5px; color:var(--ink-faint); font-variant-numeric:tabular-nums; }
  .rp-grid{ display:grid; gap:12px; grid-template-columns:repeat(auto-fit, minmax(170px, 1fr)); }
  .rp-f{ display:flex; flex-direction:column; gap:5px; min-width:0; }
  .rp-f label{ font-size:11.5px; color:var(--ink-faint); }
  .rp-f select{
    font-family:var(--font-body); font-size:12.5px; padding:7px 9px; border-radius:8px;
    border:1px solid var(--card-border); background:var(--white); color:var(--ink); width:100%;
    box-sizing:border-box;
  }
  .rp-f[hidden]{ display:none; }
  .rp-head{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; margin-bottom:12px; }
  .rp-head b{ font-size:13.5px; color:var(--ink); }
  .rp-acts{ display:flex; gap:7px; margin-inline-start:auto; flex-wrap:wrap; }
  .rp-cards{ display:grid; gap:10px; grid-template-columns:repeat(auto-fit, minmax(146px,1fr)); margin-bottom:16px; }
  .rp-card{
    border:1px solid var(--card-border); border-radius:14px; padding:12px 14px;
    background:var(--white); position:relative; overflow:hidden; min-width:0;
  }
  .rp-card::before{ content:""; position:absolute; inset-block:0; inset-inline-start:0;
    width:3px; background:var(--rc, var(--brass)); }
  .rp-card .t{
    font-size:11px; color:var(--ink-faint); line-height:1.7;
    display:flex; align-items:center; gap:6px; margin-bottom:3px;
  }
  .rp-card .t i{
    font-style:normal; font-size:11px; width:17px; height:17px; flex:none;
    display:inline-flex; align-items:center; justify-content:center;
    border-radius:6px; background:var(--rc, var(--brass)); color:#fff; opacity:.92;
  }
  .rp-card .n{
    font-size:18px; font-weight:700; color:var(--ink); line-height:1.4;
    font-variant-numeric:tabular-nums; display:block;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
  }
  .rp-card .s{ font-size:11.5px; color:var(--rc, var(--brass)); font-weight:600;
    font-variant-numeric:tabular-nums; }
  .rp-tab th, .rp-tab td{ white-space:nowrap; }
  .rp-tab td.num{ font-variant-numeric:tabular-nums; }
  .rp-tab tr.rest td{ color:var(--ink-faint); font-style:italic; }
  /* نوارِ سهم: عدد می‌گوید چقدر، نوار می‌گوید نسبت به بقیه چقدر */
  .rp-share{
    display:inline-block; width:46px; height:6px; border-radius:3px;
    background:var(--paper-2, rgba(128,128,128,.16)); margin-inline-end:7px;
    vertical-align:middle; overflow:hidden;
  }
  .rp-share i{ display:block; height:100%; background:var(--brass); border-radius:3px; }
  .rp-head b{ font-size:14px; }
  .rp-print-head{ display:none; }
  /* چاپ: هر چیزی جز خودِ گزارش از کاغذ برداشته می‌شود. به‌جای
     پنهان‌کردنِ تک‌تکِ بخش‌ها (که با هر بخشِ تازه‌ای عقب می‌افتاد)،
     همه‌چیز پنهان می‌شود و فقط زنجیرهٔ والدهای گزارش برمی‌گردد. */
  @media print{
    body *{ visibility:hidden !important; }
    #rpPaper, #rpPaper *{ visibility:visible !important; }
    #rpPaper{
      position:absolute; inset-block-start:0; inset-inline-start:0;
      width:100%; padding:0; margin:0;
    }
    .rp-print-head{
      display:block; margin-bottom:14px; padding-bottom:10px;
      border-bottom:1px solid #999;
    }
    .rp-print-head b{ display:block; font-size:15px; }
    .rp-print-head span{ font-size:11px; color:#555; }
    .chart-box{ height:330px; page-break-inside:avoid; }
    .rp-cards{ page-break-inside:avoid; }
    .rp-tab{ page-break-inside:auto; }
    .rp-tab tr{ page-break-inside:avoid; }
    .tbl-wrap{ overflow:visible !important; }
    @page{ margin:14mm; }
  }
</style>
