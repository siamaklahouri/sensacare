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
            <option value="bar">نمودار ستونی</option>
            <option value="hbar">ستونیِ افقی</option>
            <option value="line">نمودار خطی</option>
            <option value="doughnut">دایره‌ای</option>
            <option value="table">فقط جدول و کارت‌ها</option>
          </select></div>
        <div class="rp-f"><label for="rpCat">دسته‌بندی بر اساس</label>
          <select id="rpCat"></select></div>
        <div class="rp-f"><label for="rpAgg">محاسبه</label>
          <select id="rpAgg">
            <option value="sum">جمع</option>
            <option value="avg">میانگین</option>
            <option value="count">شمارش ردیف‌ها</option>
            <option value="max">بیشینه</option>
            <option value="min">کمینه</option>
          </select></div>
        <div class="rp-f" id="rpValWrap"><label for="rpVal">روی کدام ستون</label>
          <select id="rpVal"></select></div>
        <div class="rp-f"><label for="rpTop">چند تای اول</label>
          <select id="rpTop">
            <option value="0">همه</option>
            <option value="5">۵ تای اول</option>
            <option value="10" selected>۱۰ تای اول</option>
            <option value="20">۲۰ تای اول</option>
          </select></div>
        <div class="rp-f"><label for="rpSort">ترتیب</label>
          <select id="rpSort">
            <option value="desc">از بیشترین</option>
            <option value="asc">از کمترین</option>
            <option value="cat">بر اساس نامِ دسته</option>
          </select></div>
      </div>
      <div class="rp-note" id="rpWhy"></div>
    </div>

    <div class="panel">
      <div class="rp-head">
        <b id="rpTitle">گزارش</b>
        <span class="rp-acts">
          <button type="button" class="btn btn-sm" id="rpPng">⬇ تصویر</button>
          <button type="button" class="btn btn-sm" id="rpXlsx">⬇ اکسلِ خلاصه</button>
          <button type="button" class="btn btn-sm" id="rpPrint">🖨 چاپ</button>
        </span>
      </div>
      <div class="rp-cards" id="rpCards"></div>
      <div class="chart-box" id="rpChartBox"><canvas id="rpChart"></canvas></div>
      <div class="tbl-wrap"><table class="tbl rp-tab" id="rpTab"></table></div>
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
  .rp-cards{ display:grid; gap:10px; grid-template-columns:repeat(auto-fit, minmax(128px,1fr)); margin-bottom:14px; }
  .rp-card{
    border:1px solid var(--card-border); border-radius:12px; padding:11px 13px;
    background:var(--white); position:relative; overflow:hidden;
  }
  .rp-card::before{ content:""; position:absolute; inset-block:0; inset-inline-start:0;
    width:3px; background:var(--rc, var(--brass)); }
  .rp-card .n{ font-size:19px; font-weight:700; color:var(--ink); line-height:1.35;
    font-variant-numeric:tabular-nums; display:block; }
  .rp-card .t{ font-size:11px; color:var(--ink-faint); line-height:1.7; }
  .rp-tab th, .rp-tab td{ white-space:nowrap; }
  .rp-tab td.num{ font-variant-numeric:tabular-nums; }
  @media print{
    .sidebar, .topbar, .rp-drop, .rp-bar, .rp-acts, .rp-grid, .appfoot{ display:none !important; }
    .view{ display:block !important; }
  }
</style>
