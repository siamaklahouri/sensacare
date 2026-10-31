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
  updown.test.mjs seo.test.mjs aria.test.mjs narrow.test.mjs orgroles.test.mjs
  duesoon.test.mjs icons.test.mjs adminnarrow.test.mjs bkhtml.test.mjs bkseen.test.mjs bots.test.mjs"

for f in $LIST; do
  [ -f "$f" ] || continue
  printf '%-24s ' "$f"
  # پیش از هر فایل، نه فقط یک بار سرِ شروع: مجموعه که بزرگ شد، سقفِ
  # ورود وسطِ اجرا پر می‌شد و آزمونِ ششم با ۴۲۹ می‌افتاد — ایرادِ
  # مجموعه، نه ایرادِ کد.
  clear_limits
  # DB_FILE هم می‌رود: چند آزمون باید ردیفی را که از راهِ ربات
  # می‌آید (مثلِ گفتگوی بله) خودشان در جدول بگذارند.
  out=$(VS_BASE="$BASE" DB_FILE="$DB" node "$f" 2>&1); rc=$?
  echo "$out" | tail -1
  # کدِ خروج، نه خطِ آخر. تا امروز این‌جا فقط دنبالِ الگوی «N bad» در
  # خطِ آخر می‌گشت — و خطِ آخرِ آزمونی که کرش کرده «Node.js v22.x»
  # است، که با آن الگو نمی‌خواند. یعنی آزمونی که اصلاً اجرا نشده بود
  # «قبول» حساب می‌شد.
  #
  # یک بار همین شد: سرورِ محلی خوابیده بود، هر آزمونِ مرورگری کرش
  # کرد، و مجموعه «۰ bad» و خروجِ صفر داد. مجموعه‌ای که نتواند
  # نیفتادن را از نرسیدن جدا کند، از نبودنش بدتر است — چون به آن
  # اعتماد می‌شود.
  #
  # هر آزمون با «process.exit(bad ? 1 : 0)» تمام می‌شود، پس کدِ خروج
  # هم شکستِ سنجه‌ها را می‌گوید و هم کرش را.
  if [ "$rc" -ne 0 ]; then
    fail=1
    bads=$(echo "$out" | grep -E '^ +BAD')
    if [ -n "$bads" ]; then
      # خطِ آخر می‌گوید «افتاد»، نه «چرا».
      echo "$bads" | sed 's/^/    /'
    else
      # هیچ سنجه‌ای نیفتاده ولی کد خروجِ غیرصفر داده: یعنی کرش.
      echo "    ⚠️  اجرا نشد (کدِ خروج $rc) — چند خطِ آخر:"
      echo "$out" | tail -8 | sed 's/^/      /'
    fi
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
