<!-- بخشِ تبدیلِ واحد و تاریخ — مشترکِ هر دو کارتابل -->
    <!-- DATE TOOLS -->
    <section class="view" id="view-datetools" data-feat="view:datetools">
      <div class="section-title">🧮 تبدیل</div>
      <div class="section-sub">واحدها و تاریخ — وزن، طول، مساحت، حجم، دما، داده، زمان، واحد پولی، و تبدیل تاریخ</div>

      <!-- تبدیلِ واحدها و ماه؛ محتوایش را پارهٔ convert می‌سازد تا یک
           نسخه باشد نه دو تا. -->
      <div id="convBox"></div>

      <div class="grid2">
        <div class="panel">
          <h3>📅 شمسی ← میلادی</h3>
          <div class="dt-row">
            <select id="dtJY" aria-label="سالِ شمسی"></select>
            <select id="dtJM" aria-label="ماهِ شمسی"></select>
            <select id="dtJD" aria-label="روزِ شمسی"></select>
          </div>
          <div class="dt-result" id="dtJ2GResult">—</div>
        </div>
        <div class="panel">
          <h3>📅 میلادی ← شمسی</h3>
          <div class="dt-row">
            <input type="date" id="dtGDate" aria-label="تاریخ میلادی">
          </div>
          <div class="dt-result" id="dtG2JResult">—</div>
        </div>
      </div>

      <div class="panel" style="margin-top:16px;">
        <h3>⏳ محاسبه‌ی فاصله‌ی بین دو تاریخ (شمسی)</h3>
        <div class="dt-diff-grid">
          <div>
            <label>تاریخ شروع</label>
            <div class="dt-row">
              <select id="dtStartY" aria-label="سالِ شروع"></select>
              <select id="dtStartM" aria-label="ماهِ شروع"></select>
              <select id="dtStartD" aria-label="روزِ شروع"></select>
            </div>
          </div>
          <div>
            <label>تاریخ پایان</label>
            <div class="dt-row">
              <select id="dtEndY" aria-label="سالِ پایان"></select>
              <select id="dtEndM" aria-label="ماهِ پایان"></select>
              <select id="dtEndD" aria-label="روزِ پایان"></select>
            </div>
          </div>
        </div>
        <button type="button" class="btn btn-brass btn-sm" id="dtDiffBtn" style="margin-top:10px;">محاسبه‌ی فاصله</button>
        <div class="dt-result dt-diff-result" id="dtDiffResult"></div>
      </div>
    </section>

    <!-- GUIDE -->
