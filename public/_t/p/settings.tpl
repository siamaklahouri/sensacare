    <!-- SETTINGS -->
    <section class="view" id="view-settings">
      <div class="section-title">تنظیمات کارتابل</div>
      <div class="section-sub">رمز ورود، ربات پشتیبان، و وضعیت همگام‌سازی</div>

      <div class="panel">
        <h3 class="set-h">🕘 نسخه‌های پیشین</h3>
        <p class="set-p">کارتابل از خودش عکس نگه می‌دارد — دست‌کم ده دقیقه فاصله، و شصت تای آخر.
          اگر چیزی پاک شد یا اشتباهی از فایل بازنویسی شد، همین‌جا می‌شود برش گرداند.
          کنارِ هر نسخه نوشته شده داخلش چه بوده، تا لازم نباشد حدس بزنید.
          برگرداندن هم خودش یک عکسِ تازه از وضعیت فعلی می‌گیرد، پس برگشتنش هم ممکن است.</p>
        <div class="set-row">
          <button type="button" class="btn btn-ghost" id="histBtn">نشان بده</button>
          <span class="set-state" id="histState"></span>
        </div>
        <div id="histList"></div>
      </div>

      <div class="panel">
        <h3 class="set-h">☁️ همگام‌سازی</h3>
        <p class="set-p">داده‌های کارتابل روی سرور می‌مانند، پس با هر مرورگر و هر دستگاهی که وارد شوید همین‌ها را می‌بینید. اگر اینترنت قطع شود کارتابل با نسخهٔ همین مرورگر کار می‌کند و به‌محض وصل شدن، تغییرها بالا می‌روند.</p>
        <div class="set-row">
          <span class="set-state" id="cloudStatus">در حال بررسی…</span>
        </div>
        <div class="set-row">
          <span class="set-state" id="lastLoginRow"></span>
        </div>
      </div>

      <div class="panel" data-feat="pass">
        <h3 class="set-h">🔑 رمز ورود</h3>
        <p class="set-p">رمز روی سرور و به شکل PBKDF2 با ۱۰۰٬۰۰۰ دور نگه داشته می‌شود؛ نه در این صفحه هست و نه از روی چیزی که ذخیره شده درمی‌آید. با عوض کردنش، همهٔ دستگاه‌های دیگر که وارد مانده‌اند بیرون می‌افتند.</p>
        <form id="passForm" autocomplete="off">
          <div class="set-grid">
            <label>رمز فعلی
              <input type="password" id="passCurrent" autocomplete="current-password" required>
            </label>
            <label>رمز تازه (دست‌کم ۸ کاراکتر)
              <input type="password" id="passNext" autocomplete="new-password" minlength="8" required>
            </label>
            <label>تکرار رمز تازه
              <input type="password" id="passRepeat" autocomplete="new-password" minlength="8" required>
            </label>
          </div>
          <div class="set-row">
            <button type="submit" class="btn btn-brass" id="passBtn">ثبت رمز تازه</button>
            <span class="set-state" id="passState"></span>
          </div>
        </form>
      </div>

      <div class="panel" data-feat="aikey">
        <h3 class="set-h">🤖 موتور دستیار هوشمند</h3>
        <p class="set-p">دستیار به‌طور پیش‌فرض روی هوش مصنوعیِ رایگانِ کلادفلر کار می‌کند — چیزی لازم ندارد، ولی کیفیتش متوسط است و گاهی در فارسی گیج می‌زند. اگر کلید API کلاد داشته باشید، این‌جا بگذاریدش تا دستیار از همان لحظه با کلاد کار کند. کلید را از <code dir="ltr">console.anthropic.com</code> می‌سازید و هزینه‌اش پای مصرف خودتان است.</p>
        <div class="set-row">
          <span class="set-state" id="aiProvider">در حال بررسی…</span>
        </div>
        <div class="set-grid">
          <label>کلید API کلاد (خالی بگذارید تا رایگان بماند)
            <input type="password" id="aiKey" placeholder="sk-ant-..." autocomplete="off" dir="ltr">
          </label>
        </div>
        <div class="set-row">
          <button type="button" class="btn btn-brass" id="aiKeySaveBtn">ثبت کلید</button>
          <button type="button" class="btn btn-ghost" id="aiKeyClearBtn">برگرد به رایگان</button>
          <span class="set-state" id="aiKeyState"></span>
        </div>
      </div>

      <div class="panel" data-feat="backup">
        <h3 class="set-h">🤖 پشتیبان شبانه در تلگرام</h3>
        <p class="set-p">هر شب یک زیپ کامل — فایل داده، فایل اکسل، و خودِ صفحهٔ کارتابل — برای ربات شما فرستاده می‌شود. با همان زیپ، کارتابل بدون سرور و بدون اینترنت هم باز می‌شود.</p>
        <div class="set-grid">
          <label>توکن ربات تلگرام
            <input type="text" id="botToken" placeholder="مثل: 8926574603:AAE..." autocomplete="off" dir="ltr" data-ascii>
          </label>
        </div>
        <div class="set-row">
          <button type="button" class="btn btn-brass" id="botSaveBtn">ثبت توکن</button>
          <span class="set-state" id="botState"></span>
        </div>
        <hr class="set-hr">
        <p class="set-p">بعد از ثبت توکن، در تلگرام ربات را باز کنید و <code>/start</code> بزنید، بعد دکمهٔ زیر را بزنید تا معلوم شود پشتیبان برای چه کسی برود.</p>
        <div class="set-row">
          <button type="button" class="btn btn-ghost" id="botConnectBtn">اتصال به گفتگوی من</button>
          <span class="set-state" id="connectState"></span>
        </div>
        <hr class="set-hr">
        <div class="set-row">
          <button type="button" class="btn btn-ghost" id="backupNowBtn">📤 همین حالا یک پشتیبان بفرست</button>
          <button type="button" class="btn btn-ghost" id="backupDownloadBtn">⬇ دانلود زیپ پشتیبان</button>
          <span class="set-state" id="backupState"></span>
        </div>
        <div class="set-row">
          <span class="set-state" id="lastBackup"></span>
        </div>
      </div>

      <!-- فقط در مرورگرهایی که File System Access دارند دیده می‌شود -->
      <div class="panel" id="folderPanel" data-feat="folder" hidden>
        <h3 class="set-h">🗂️ آینهٔ اکسل روی سیستم (اختیاری)</h3>
        <p class="set-p">اگر بخواهید، کارتابل می‌تواند هم‌زمان یک فایل اکسل را در پوشه‌ای روی سیستم شما به‌روز نگه دارد. برای کار کردن با کارتابل لازم نیست — داده‌ها روی سرور هستند و پشتیبان شبانه هم می‌رود. این فقط برای وقتی است که بخواهید همان فایل اکسل همیشه روی دیسک خودتان تازه باشد. (فقط Chrome و Edge این امکان را دارند.)</p>
        <div class="set-row">
          <button type="button" class="btn btn-brass" id="connectFolderBtn">اتصال به پوشه روی سیستم</button>
          <span class="set-state" id="folderStatus"></span>
        </div>
      </div>
    </section>
