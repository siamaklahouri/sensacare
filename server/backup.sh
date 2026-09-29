#!/bin/bash
# ==================== پشتیبانِ دیتابیس ====================
# روی کلادفلر دیتابیس مدیریت‌شده بود و پشتیبانش کارِ ما نبود. روی
# سرورِ خودمان هست، و این همان چیزی است که از اول گفتم یکی از سه
# هزینهٔ واقعیِ این جابه‌جایی است.
#
# «cp» کافی نیست: دیتابیس ممکن است وسطِ نوشتن باشد و کپی نیمه‌کاره
# دربیاید. «‎.backup‎» از خودِ SQLite نسخه‌ای می‌گیرد که همیشه سالم
# است، حتی وقتی سرویس در حالِ نوشتن است.
#
# هر ساعت یک نسخه. روزی یک بار هم همان نسخه در پوشهٔ «daily» کپی
# می‌شود.
#
# دو دورهٔ نگه‌داری، چون دو جور از دست دادن هست: یکی که همان ساعت
# می‌فهمی و یکی که یک هفته بعد. نسخه‌های ساعتی هفت روز می‌مانند و
# روزانه‌ها سی روز — وگرنه یا دیسک پر می‌شد یا تاریخچه کوتاه.

set -u
DB="${DB_FILE:-/var/lib/sltech/sltech.db}"
OUT="${BACKUP_DIR:-/var/backups/sltech}"
KEEP="${BACKUP_KEEP_HOURLY_DAYS:-7}"
KEEPD="${BACKUP_KEEP_DAYS:-30}"
STAMP=$(date +%Y-%m-%d_%H%M)
DAY=$(date +%Y-%m-%d)
# شمارهٔ پروسه در نامِ فایلِ موقت: اگر کسی دستی اجرا کند درست وقتی
# زمان‌سنج هم می‌رود، دو نسخه روی یک فایلِ موقت نمی‌نویسند.
TMP="$OUT/.tmp-$STAMP-$$.db"
FINAL="$OUT/sltech-$STAMP.db.gz"
DAILY="$OUT/daily/sltech-$DAY.db.gz"

mkdir -p "$OUT/daily"
chmod 700 "$OUT" "$OUT/daily"

if [ ! -f "$DB" ]; then
  echo "دیتابیس پیدا نشد: $DB" >&2
  exit 1
fi

# نسخهٔ سالم، بدونِ خواباندنِ سرویس
if ! sqlite3 "$DB" ".backup '$TMP'" 2>/dev/null; then
  echo "گرفتنِ نسخه نشد" >&2
  rm -f "$TMP"
  exit 1
fi

# سالم است؟ نسخهٔ خرابی که کنار گذاشته شود، از نبودنش بدتر است،
# چون آدم خیال می‌کند پشتیبان دارد.
if ! sqlite3 "$TMP" "PRAGMA integrity_check;" 2>/dev/null | grep -q '^ok$'; then
  echo "نسخه سالم نیست، دور ریخته شد" >&2
  rm -f "$TMP"
  exit 1
fi

gzip -9 -c "$TMP" > "$FINAL"
rm -f "$TMP"
chmod 600 "$FINAL"

# نسخهٔ روزانه: اولین نسخهٔ هر روز کپی می‌شود و بس. «-f» یعنی اگر
# امروز از قبل هست، دست نمی‌خورد.
[ -f "$DAILY" ] || cp -f "$FINAL" "$DAILY"

# قدیمی‌ها — هر کدام با دورهٔ خودش
find "$OUT" -maxdepth 1 -name 'sltech-*.db.gz' -type f -mtime "+$KEEP" -delete 2>/dev/null
find "$OUT/daily" -name 'sltech-*.db.gz' -type f -mtime "+$KEEPD" -delete 2>/dev/null

SIZE=$(du -h "$FINAL" | cut -f1)
NH=$(find "$OUT" -maxdepth 1 -name 'sltech-*.db.gz' -type f | wc -l)
ND=$(find "$OUT/daily" -name 'sltech-*.db.gz' -type f | wc -l)
echo "پشتیبان: $FINAL ($SIZE) — $NH نسخهٔ ساعتی، $ND نسخهٔ روزانه"
