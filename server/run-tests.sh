#!/usr/bin/env bash
# همهٔ آزمون‌های مرورگری، پشتِ سر هم.
#
# چرا یک اسکریپت و نه «node *.test.mjs»: سقفِ تعدادِ ورود سمتِ سرور،
# یک اجرای پشتِ سر هم را با ۴۲۹ می‌خواباند. آن سقف برای کاربرِ واقعی
# درست است و دست نمی‌خورد؛ این‌جا فقط پیش از شروع پاک می‌شود.
set -u
DB="${DB_FILE:?DB_FILE را بدهید — همان که سرورِ محلی با آن بالا آمده}"
BASE="${VS_BASE:-http://127.0.0.1:8911}"

clear_limits(){
  node -e "
const {DatabaseSync}=require('node:sqlite');
try{ new DatabaseSync(process.argv[1]).prepare('DELETE FROM rate_limits').run(); }catch(e){}
" "$DB" 2>/dev/null
}
clear_limits

cd "$(dirname "$0")"
fail=0
for f in theme.test.mjs serversize.test.mjs vshare.test.mjs vshare-ui.test.mjs \
         veeam.test.mjs veeam-ui.test.mjs rowdrag-all.test.mjs donedate.test.mjs \
         mobile-shared.test.mjs chat.test.mjs views.test.mjs \
         veeam-match.test.mjs sendcreds.test.mjs sendcreds-ui.test.mjs \
         dayjump.test.mjs vaultexp.test.mjs lastseen.test.mjs \
         daydone.test.mjs bell.test.mjs badpass.test.mjs instplus.test.mjs bellgo.test.mjs until.test.mjs noscroll.test.mjs vivid.test.mjs; do
  [ -f "$f" ] || continue
  printf '%-24s ' "$f"
  # پیش از هر فایل، نه فقط یک بار سرِ شروع: مجموعه که بزرگ شد، سقفِ
  # ورود وسطِ اجرا پر می‌شد و آزمونِ ششم با ۴۲۹ می‌افتاد — ایرادِ
  # مجموعه، نه ایرادِ کد.
  clear_limits
  # DB_FILE هم می‌رود: چند آزمون باید ردیفی را که از راهِ ربات
  # می‌آید (مثلِ گفتگوی بله) خودشان در جدول بگذارند.
  out=$(VS_BASE="$BASE" DB_FILE="$DB" node "$f" 2>&1)
  echo "$out" | tail -1
  # «۰ bad» شکست نیست — فقط عددِ غیرصفر
  if echo "$out" | tail -1 | grep -qE 'BAD [1-9]|[1-9][0-9]* bad'; then
    fail=1
    # خطِ آخر می‌گوید «افتاد»، نه «چرا». بی این، هر بار باید همان
    # فایل را دستی دوباره اجرا کرد — و دستی معمولاً پاس می‌شود.
    echo "$out" | grep -E '^ +BAD' | sed 's/^/    /'
  fi
done
exit $fail
