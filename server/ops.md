# نگهداریِ سرور — چه چیزی کجا

همه‌چیزِ این صفحه روی خودِ سرور است، نه در مخزن: هیچ توکنی این‌جا نیست.

## کرون

```cron
# پشتیبانِ ساعتی (از قبل بود)
0  * * * * bash /opt/sltech/app/server/backup.sh      >/dev/null 2>&1
# نگهبان: پشتیبان تازه است؟ دیسک جا دارد؟ سرویس بالاست؟
*/10 * * * * bash /opt/sltech/app/server/ops.sh check   >/dev/null 2>&1
# آزمونِ بازیابی: آخرین پشتیبان واقعاً باز می‌شود؟
17 4 * * *   bash /opt/sltech/app/server/ops.sh restore >/dev/null 2>&1
```

خبرها از همان رباتی می‌روند که پشتیبان‌ها می‌روند
(`node server/index.js --notify "…"`). یک ایراد فقط **یک بار** خبر
می‌دهد و تا درست نشود ساکت می‌ماند — وگرنه یک دیسکِ پر یعنی صد پیام
در روز و بعدش کسی پیام‌ها را نمی‌خواند.

## دستورهایی که لازم می‌شوند

| کار | دستور |
|---|---|
| استقرارِ نسخهٔ تازه | `bash /opt/sltech/app/server/update.sh` |
| برگشت یک قدم عقب | `bash /opt/sltech/app/server/rollback.sh` |
| برگشت به نسخهٔ معین | `bash /opt/sltech/app/server/rollback.sh <sha>` |
| فهرستِ نسخه‌ها | `bash /opt/sltech/app/server/rollback.sh --list` |
| چکِ دستیِ سرور | `bash /opt/sltech/app/server/ops.sh check` |
| آزمونِ بازیابی | `bash /opt/sltech/app/server/ops.sh restore` |
| پشتیبانِ رمزشدهٔ فایلِ کلیدها | `bash /opt/sltech/app/server/ops.sh env` |
| یک نوبت یادآور با دست | `node /opt/sltech/app/server/index.js --remind-now` |
| نبضِ سرویس | `curl -s localhost:8787/healthz` |
| خاموش کردنِ ورودِ دومرحله‌ای (وقتی ربات نرسید) | `node /opt/sltech/app/server/index.js --admin-2fa off` |
| روشن کردنش از سرور | `node /opt/sltech/app/server/index.js --admin-2fa on` |

## فایلِ کلیدها

`/etc/sltech/env` تنها جایی است که توکن‌ها در آن هستند و **پشتیبانِ
دیتابیس شاملش نمی‌شود**. ماهی یک بار:

```sh
bash /opt/sltech/app/server/ops.sh env
```

یک فایلِ `.enc` در `/var/backups/sltech/env/` می‌سازد (AES-256 با رمزی
که خودتان می‌دهید). آن را جایی **بیرونِ همین سرور** نگه دارید؛ وگرنه
با رفتنِ سرور، هم کلیدها می‌روند هم پشتیبانشان.

برگرداندن:

```sh
openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -in env-….enc -out env
```

## وقتی چیزی خراب شد

۱. `bash server/ops.sh check` — کدام تکه خراب است؟
۲. `journalctl -u sltech -n 50 --no-pager` — چرا؟
۳. اگر استقرارِ تازه خرابش کرده: `bash server/rollback.sh`
۴. اگر داده خراب شده: آخرین پشتیبان در `/var/backups/sltech/`،
   و مسیرِ برگرداندنش در `server/CUTOVER.md`.

## ورودِ دومرحله‌ای پنلِ ادمین

پیش‌فرض خاموش است. در پنل: **کلیدها و رمز ادمین ← ورود دومرحله‌ای**.
روشن که باشد، بعد از رمز یک کدِ شش‌رقمی به همان گفتگوی تلگرامیِ
پشتیبان‌ها می‌رود (ده دقیقه، پنج تلاش، یک‌بارمصرف).

اگر روزی ربات از کار افتاد و کد نرسید، از روی سرور خاموشش کنید؛
دستور در جدولِ بالاست. کسی که به سرور دسترسی دارد، این قفل برای او
نبوده.

## کارتابلِ نمایشی

هر کارتابلی که آدرسش `demo` باشد نمایشی است: بی‌رمز باز می‌شود، هرچه
در آن نوشته شود **روی سرور نمی‌نشیند** (فقط در مرورگرِ خودِ بازدیدکننده
می‌ماند) و نوارِ «نسخهٔ نمایشی» پایینش دیده می‌شود.

ساختنش مثل هر کارتابلِ دیگری است — در پنل، «کارتابل تازه» با آدرسِ
`demo`. بعدش یک بار خودتان واردش شوید و چند ردیفِ نمونه بنویسید…
ولی توجه: چون نوشتن در کارتابلِ نمایشی ذخیره نمی‌شود، دادهٔ نمونه را
باید از همین راه بگذارید:

```sh
# نمونه‌ای که در مرورگر ساخته‌اید را به‌شکل JSON ذخیره کنید، بعد:
sqlite3 /var/lib/sltech/sltech.db \
  "INSERT INTO kartabl(k,v,rev,updated) VALUES('demo:state', readfile('demo.json'), 1, strftime('%s','now')*1000)
   ON CONFLICT(k) DO UPDATE SET v=excluded.v;"
```

(کلیدِ دقیقِ `state` هر کارتابل در `cfg.keys.state` همان ردیفِ
`planners` است.)

صفحهٔ اصلیِ سایت از دو جا به `/demo/` لینک دارد: نوارِ بالا و دکمهٔ
سرصفحه.
