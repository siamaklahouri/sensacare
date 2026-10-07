#!/usr/bin/env bash
# همهٔ آزمون‌های مرورگری، پشتِ سر هم.
#
# چرا یک اسکریپت و نه «node *.test.mjs»: سقفِ تعدادِ ورود سمتِ سرور،
# یک اجرای پشتِ سر هم را با ۴۲۹ می‌خواباند. آن سقف برای کاربرِ واقعی
# درست است و دست نمی‌خورد؛ این‌جا فقط پیش از شروع پاک می‌شود.
set -u
DB="${DB_FILE:?DB_FILE را بدهید — همان که سرورِ محلی با آن بالا آمده}"
BASE="${VS_BASE:-http://127.0.0.1:8911}"

node -e "
const {DatabaseSync}=require('node:sqlite');
try{ new DatabaseSync(process.argv[1]).prepare('DELETE FROM rate_limits').run(); }catch(e){}
" "$DB" 2>/dev/null

cd "$(dirname "$0")"
fail=0
for f in theme.test.mjs serversize.test.mjs vshare.test.mjs vshare-ui.test.mjs \
         veeam.test.mjs veeam-ui.test.mjs rowdrag-all.test.mjs donedate.test.mjs; do
  [ -f "$f" ] || continue
  printf '%-24s ' "$f"
  out=$(VS_BASE="$BASE" node "$f" 2>&1)
  echo "$out" | tail -1
  # «۰ bad» شکست نیست — فقط عددِ غیرصفر
  echo "$out" | tail -1 | grep -qE 'BAD [1-9]|[1-9][0-9]* bad' && fail=1
done
exit $fail
