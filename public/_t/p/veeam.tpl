<!-- گزارشِ Veeam Backup & Replication
     ================================================================
     این بخش برعکسِ بقیهٔ بخش‌های کارتابل است: داده‌اش را کاربر وارد
     نمی‌کند و اصلاً از این صفحه نمی‌آید. سرورِ sltech به شبکهٔ داخلیِ
     شرکت دسترسی ندارد، پس نمی‌تواند خودش سراغِ Veeam برود؛ یک اسکریپتِ
     کوچک آن طرف می‌نشیند، از REST APIِ خودِ Veeam می‌پرسد و نتیجه را
     با کلیدِ مخصوصِ خودش می‌فرستد.

     پس این‌جا هیچ خانه‌ای نوشتنی نیست و هیچ دکمهٔ «افزودن» ندارد —
     آینه است، نه دفتر. -->
<section class="view" id="view-veeam">
  <div class="section-title">🛡️ VeeamBackup</div>
  <div class="section-sub">وضعیتِ جاب‌های Veeam Backup &amp; Replication —
    گزارش را اسکریپتِ روی شبکهٔ شرکت می‌فرستد و این‌جا فقط دیده می‌شود.</div>

  <div class="cards" id="veeamCards"></div>

  <div class="panel">
    <div class="vm-head">
      <h3>🛡️ جاب‌های بکاپ</h3>
      <span class="save-hint" id="veeamWhen"></span>
    </div>
    <div id="veeamWarn" class="veeam-warn" hidden></div>
    <div class="tbl-wrap">
      <table>
        <thead><tr>
          <th style="width:26px;">#</th>
          <th>نام جاب</th>
          <th style="width:110px;">نوع</th>
          <th style="width:120px;">نتیجهٔ آخر</th>
          <th style="width:110px;">وضعیت</th>
          <th style="width:150px;">آخرین اجرا</th>
          <th style="width:150px;">اجرای بعدی</th>
          <th style="width:100px;">تعداد آبجکت</th>
        </tr></thead>
        <tbody id="veeamBody"></tbody>
      </table>
    </div>
    <div class="hint2" id="veeamNote" style="margin-top:10px;"></div>
  </div>
</section>
