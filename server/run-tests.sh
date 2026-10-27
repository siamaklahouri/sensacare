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
# ترتیب مهم است: چند آزمون روی کارتابلِ نمونه‌ای که قبلی ساخته
# حساب می‌کنند. فهرست یک‌جاست تا نگهبانِ پایینِ فایل هم از همین
# بخواند و بتواند بگوید چه فایلی جا افتاده.
LIST="
  theme.test.mjs serversize.test.mjs vshare.test.mjs vshare-ui.test.mjs
  veeam.test.mjs veeam-ui.test.mjs rowdrag-all.test.mjs donedate.test.mjs
  mobile-shared.test.mjs chat.test.mjs views.test.mjs veeam-match.test.mjs
  sendcreds.test.mjs sendcreds-ui.test.mjs dayjump.test.mjs
  vaultexp.test.mjs lastseen.test.mjs daydone.test.mjs bell.test.mjs
  badpass.test.mjs instplus.test.mjs bellgo.test.mjs until.test.mjs
  noscroll.test.mjs daycal.test.mjs ktheme.test.mjs datefill.test.mjs
  pwa.test.mjs repeat.test.mjs find.test.mjs rowsheet.test.mjs
  attach.test.mjs push.test.mjs cal.test.mjs news.test.mjs pickcal.test.mjs
  notes.test.mjs guard.test.mjs split.test.mjs addbelow.test.mjs
  addrow-chip.test.mjs admin-autofill.test.mjs backup-partial.test.mjs
  date-lands.test.mjs datepick.test.mjs dayexport.test.mjs
  editmode-kept.test.mjs longcell.test.mjs nav-nomove.test.mjs
  notes-persist.test.mjs row-appears.test.mjs rowdrag.test.mjs
  site-anim.test.mjs site-anim2.test.mjs win-icons.test.mjs
  xlsx-import.test.mjs xlsx-import-fin.test.mjs xlsx-sample.test.mjs
  merge.test.mjs apperr.test.mjs maghale.test.mjs rownote.test.mjs
  updown.test.mjs seo.test.mjs aria.test.mjs narrow.test.mjs orgroles.test.mjs"

for f in $LIST; do
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
# فایلی که در این فهرست نیست، اجرا نمی‌شود — و چون اجرا نمی‌شود،
# خراب‌شدنش هم دیده نمی‌شود. یک بار نوزده آزمون همین‌طور خاموش ماندند
# و کسی خبر نداشت. این‌جا هر فایلی که جا افتاده باشد نام برده می‌شود.
missing=""
# بی‌نقل‌قول، تا خطِ تازه هم فاصله حساب شود — وگرنه نامِ اول و آخرِ هر
# خط هیچ‌وقت پیدا نمی‌شد و نگهبان بی‌صدا رد می‌شد.
flat=" $(echo $LIST) "
for f in *.test.mjs; do
  case "$flat" in *" $f "*) ;; *) missing="$missing $f";; esac
done
if [ -n "$missing" ]; then
  echo
  echo "⚠️  این آزمون‌ها در فهرست نیستند و اجرا نشدند:$missing"
  echo "    یا به فهرستِ بالا اضافه‌شان کن، یا پاکشان کن."
  fail=1
fi

exit $fail
