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
# نسخه‌ها فشرده می‌شوند و از سی روز که گذشت پاک. هر شب یک بار.

set -u
DB="${DB_FILE:-/var/lib/sltech/sltech.db}"
OUT="${BACKUP_DIR:-/var/backups/sltech}"
KEEP="${BACKUP_KEEP_DAYS:-30}"
STAMP=$(date +%Y-%m-%d_%H%M)
TMP="$OUT/.tmp-$STAMP.db"
FINAL="$OUT/sltech-$STAMP.db.gz"

mkdir -p "$OUT"
chmod 700 "$OUT"

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

# قدیمی‌ها
find "$OUT" -name 'sltech-*.db.gz' -type f -mtime "+$KEEP" -delete 2>/dev/null

SIZE=$(du -h "$FINAL" | cut -f1)
COUNT=$(find "$OUT" -name 'sltech-*.db.gz' -type f | wc -l)
echo "پشتیبان: $FINAL ($SIZE) — $COUNT نسخه روی سرور"
