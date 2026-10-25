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
            <select id="dtJY"></select>
            <select id="dtJM"></select>
            <select id="dtJD"></select>
          </div>
          <div class="dt-result" id="dtJ2GResult">—</div>
        </div>
        <div class="panel">
          <h3>📅 میلادی ← شمسی</h3>
          <div class="dt-row">
            <input type="date" id="dtGDate">
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
              <select id="dtStartY"></select>
              <select id="dtStartM"></select>
              <select id="dtStartD"></select>
            </div>
          </div>
          <div>
            <label>تاریخ پایان</label>
            <div class="dt-row">
              <select id="dtEndY"></select>
              <select id="dtEndM"></select>
              <select id="dtEndD"></select>
            </div>
          </div>
        </div>
        <button type="button" class="btn btn-brass btn-sm" id="dtDiffBtn" style="margin-top:10px;">محاسبه‌ی فاصله</button>
        <div class="dt-result dt-diff-result" id="dtDiffResult"></div>
      </div>
    </section>

    <!-- GUIDE -->
