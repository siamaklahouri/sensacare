#!/usr/bin/env bash
# ==================== نگهبانِ سرور ====================
# پشتیبان گرفتن یک کار است؛ مطمئن شدن از اینکه گرفته شده، کارِ دیگر.
# تا امروز backup.sh هر ساعت کارش را می‌کرد و یک خط چاپ می‌کرد — و اگر
# کرون می‌خوابید، دیسک پر می‌شد یا مجوزی عوض می‌شد، هیچ‌کس خبردار
# نمی‌شد تا روزی که به پشتیبان احتیاج شود. همان روز بدترین روز برای
# فهمیدن است.
#
# این اسکریپت چند چکِ ساده است که هر کدام یا «آره» است یا «نه»، و اگر
# «نه» بود خبر می‌دهد. خبر از همان راهی می‌رود که بقیهٔ پیام‌های سایت
# می‌روند (node server/index.js --notify)، پس هیچ توکنی این‌جا نیست.
#
#   bash server/ops.sh check     پشتیبان تازه است؟ دیسک جا دارد؟ سرویس بالاست؟
#   bash server/ops.sh restore   آخرین پشتیبان واقعاً باز می‌شود؟
#   bash server/ops.sh env       نسخهٔ رمزشده از فایلِ کلیدها
#   bash server/ops.sh all       هر سه
#
# در کرون:
#   */10 * * * * bash /opt/sltech/app/server/ops.sh check  >/dev/null 2>&1
#   17 4 * * *   bash /opt/sltech/app/server/ops.sh restore >/dev/null 2>&1

set -u
APP="${APP:-/opt/sltech/app}"
ENVF="${SLTECH_ENV:-/etc/sltech/env}"
DB="${DB_FILE:-/var/lib/sltech/sltech.db}"
# کلیدِ امضای اندروید. در مخزن نیست و نباید باشد.
KEYSTORE="${KEYSTORE:-/root/android.keystore}"
OUT="${BACKUP_DIR:-/var/backups/sltech}"
PORT="${PORT:-8787}"
STATE="${OPS_STATE:-/var/lib/sltech/ops}"
# ۳ ساعت و خرده‌ای: کرونِ ساعتی یک نوبت که جا بیندازد، هنوز خبر نمی‌دهیم
MAX_AGE_MIN="${OPS_BACKUP_MAX_AGE:-200}"
DISK_PCT="${OPS_DISK_PCT:-85}"

mkdir -p "$STATE" 2>/dev/null

say(){ echo "$1"; }
notify(){
  node "$APP/server/index.js" --notify "$1" >/dev/null 2>&1 ||
    echo "  (خبر نرفت — تنظیماتِ ربات را ببینید)"
}

# یک خبر دوبار پشتِ سرِ هم نمی‌رود: اولین بار می‌گوید، و تا درست نشود
# ساکت می‌ماند. وگرنه یک دیسکِ پر یعنی صد پیام در روز و بعدش کسی
# پیام‌ها را نمی‌خواند.
once(){
  local key="$1" msg="$2" f="$STATE/$1"
  if [ ! -f "$f" ]; then
    : > "$f"
    notify "$msg"
  fi
}
clear_once(){ rm -f "$STATE/$1" 2>/dev/null; }

fails=0
bad(){ say "  ❌ $2"; fails=$((fails+1)); once "$1" "⚠️ سرور SLTech — $2"; }
good(){ say "  ✅ $2"; clear_once "$1"; }

check(){
  say "— چکِ سرور —"

  # ۱) تازه‌ترین پشتیبان
  local last age
  last=$(ls -t "$OUT"/sltech-*.db.gz 2>/dev/null | head -1)
  if [ -z "$last" ]; then
    bad backup-missing "هیچ پشتیبانی در $OUT نیست."
  else
    age=$(( ( $(date +%s) - $(stat -c %Y "$last") ) / 60 ))
    if [ "$age" -gt "$MAX_AGE_MIN" ]; then
      bad backup-stale "تازه‌ترین پشتیبان $age دقیقه پیش است — کرونِ پشتیبان کار نمی‌کند."
    elif [ "$(stat -c %s "$last")" -lt 1024 ]; then
      bad backup-tiny "پشتیبانِ آخر کمتر از یک کیلوبایت است — یعنی خالی است."
    else
      good backup-stale "پشتیبان: $age دقیقه پیش، $(du -h "$last" | cut -f1)"
      clear_once backup-missing; clear_once backup-tiny
    fi
  fi

  # ۲) جای دیسک
  local pct
  pct=$(df -P "$OUT" 2>/dev/null | awk 'NR==2{gsub("%","",$5); print $5}')
  if [ -n "${pct:-}" ] && [ "$pct" -ge "$DISK_PCT" ]; then
    bad disk "دیسک ${pct}٪ پر است — پشتیبان‌ها و پیوست‌ها جا کم می‌آورند."
  else
    good disk "دیسک: ${pct:-?}٪ پر"
  fi

  # ۳) خودِ سرویس. دو بار می‌پرسیم: یک نرسیدن می‌تواند یک لحظهٔ
  #    بازنشانی باشد، نه خرابی.
  local code=0
  code=$(curl -s -o /dev/null -m 5 -w '%{http_code}' "http://127.0.0.1:$PORT/healthz" 2>/dev/null)
  if [ "$code" != "200" ]; then
    sleep 5
    code=$(curl -s -o /dev/null -m 5 -w '%{http_code}' "http://127.0.0.1:$PORT/healthz" 2>/dev/null)
  fi
  if [ "$code" = "200" ]; then
    good service "سرویس بالاست"
  else
    bad service "سرویس جواب نمی‌دهد (کدِ $code) — systemctl status sltech"
  fi

  # ۴) خطاهای برنامه در شبانه‌روزِ گذشته. خودِ سرویس سرِ هر خطا پیام
  #    می‌دهد (ساعتی یک بار برای هر امضا)؛ این‌جا جمعش را می‌بینیم،
  #    تا خطایی که پیامش رفته و فراموش شده هم دیده شود.
  local errs
  errs=$(node -e "
const {DatabaseSync}=require('node:sqlite');
try{
  const db=new DatabaseSync(process.argv[1]);
  const since=Date.now()-86400000;
  const r=db.prepare('SELECT COUNT(*) k, COALESCE(SUM(n),0) n FROM app_errors WHERE last>=?').get(since);
  const top=db.prepare('SELECT method,path,msg,n FROM app_errors WHERE last>=? ORDER BY n DESC LIMIT 3').all(since);
  console.log(JSON.stringify({k:r.k, n:r.n, top}));
}catch(e){ console.log(JSON.stringify({k:0,n:0,top:[]})); }
" "$DB" 2>/dev/null)
  local kinds
  kinds=$(echo "$errs" | sed 's/.*"k":\([0-9]*\).*/\1/')
  if [ "${kinds:-0}" -gt 0 ]; then
    local total
    total=$(echo "$errs" | sed 's/.*"n":\([0-9]*\).*/\1/')
    bad apperrors "$kinds جور خطا در ۲۴ ساعت گذشته ($total بار) — ops.sh errors"
  else
    good apperrors "خطای برنامه‌ای در ۲۴ ساعت گذشته نبوده"
  fi

  # ۵) سطحِ عمومیِ سایت: چند مقاله منتشر شده و نقشهٔ سایت چند نشانی
  #    دارد. چرا این‌جا: یک بار سرچ کنسول ۲۴ نشانی نشان داد و ۲۴ دقیقاً
  #    «خانه + فهرستِ مقاله‌ها + ۲۲ صفحهٔ شغلی» است — یعنی هیچ مقاله‌ای
  #    در نقشه نبود و هیچ‌کس خبر نداشت. مقاله‌ای که پیش‌نویس مانده،
  #    نوشته نشده حساب می‌شود، و این تنها جایی است که هر روز نگاه
  #    می‌شود.
  local arts pub locs
  arts=$(node -e "
const {DatabaseSync}=require('node:sqlite');
try{
  const db=new DatabaseSync(process.argv[1]);
  const r=db.prepare('SELECT COUNT(*) t, COALESCE(SUM(published),0) p FROM sl_articles').get();
  console.log(r.t+' '+r.p);
}catch(e){ console.log('- -'); }
" "$DB" 2>/dev/null)
  pub=${arts##* }
  arts=${arts%% *}
  locs=$(curl -s -m 5 -H 'Host: sltech.ir' "http://127.0.0.1:$PORT/sitemap.xml" 2>/dev/null |
         grep -c '<loc>' || true)
  if [ "${locs:-0}" -lt 2 ]; then
    bad sitemap "نقشهٔ سایت خالی است (${locs:-0} نشانی) — گوگل چیزی برای خزیدن ندارد."
  else
    good sitemap "نقشهٔ سایت: $locs نشانی"
  fi
  if [ "$arts" = "-" ]; then
    say "  مقاله‌ها خوانده نشد."
  elif [ "${pub:-0}" -lt "${arts:-0}" ]; then
    say "  ℹ️  مقاله: $arts نوشته، $pub منتشرشده — بقیه پیش‌نویس‌اند و در سایت نیستند."
  else
    say "  ✅ مقاله: هر $arts نوشته منتشر شده‌اند"
  fi
}

# ---------- فهرستِ خطاها ----------
# برای وقتی که پیام آمده و باید دید دقیقاً چه بوده.
errors(){
  say "— خطاهای برنامه —"
  node -e "
const {DatabaseSync}=require('node:sqlite');
const db=new DatabaseSync(process.argv[1]);
const rows=db.prepare('SELECT method,path,msg,n,first,last FROM app_errors ORDER BY last DESC LIMIT 40').all();
if(!rows.length){ console.log('  چیزی ثبت نشده.'); }
for(const r of rows){
  const d=new Date(r.last).toISOString().slice(0,16).replace('T',' ');
  console.log('  ['+d+'] x'+r.n+'  '+r.method+' '+r.path);
  console.log('      '+r.msg);
}
" "$DB" 2>/dev/null || say "  خوانده نشد."
}

# ---------- آزمونِ بازیابی ----------
# پشتیبانی که باز نشود پشتیبان نیست. شبی یک بار آخرین نسخه در یک
# فایلِ موقت باز می‌شود، سلامتش چک می‌شود و جدول‌های اصلی شمرده
# می‌شوند. اگر صفر درآمد، یعنی نسخه به درد نمی‌خورد.
restore(){
  say "— آزمونِ بازیابی —"
  local last tmp
  last=$(ls -t "$OUT"/sltech-*.db.gz 2>/dev/null | head -1)
  if [ -z "$last" ]; then bad restore "پشتیبانی برای آزمودن نیست."; return; fi
  tmp=$(mktemp -d)
  if ! gunzip -c "$last" > "$tmp/t.db" 2>/dev/null; then
    bad restore "پشتیبانِ آخر باز نشد (gunzip) — $(basename "$last")"
    rm -rf "$tmp"; return
  fi
  local out
  out=$(node -e "
const {DatabaseSync}=require('node:sqlite');
try{
  const db=new DatabaseSync(process.argv[1]);
  const ok=db.prepare('PRAGMA integrity_check').get();
  const n=t=>{ try{ return db.prepare('SELECT COUNT(*) c FROM '+t).get().c; }catch(e){ return -1; } };
  console.log(JSON.stringify({ ok:Object.values(ok)[0], panels:n('panels'), kartabl:n('kartabl') }));
}catch(e){ console.log(JSON.stringify({ ok:'باز نشد: '+e.message })); }
" "$tmp/t.db" 2>/dev/null)
  rm -rf "$tmp"
  case "$out" in
    *'"ok":"ok"'*)
      local p k
      p=$(echo "$out" | sed 's/.*"panels":\([-0-9]*\).*/\1/')
      k=$(echo "$out" | sed 's/.*"kartabl":\([-0-9]*\).*/\1/')
      if [ "${p:-0}" -gt 0 ]; then
        good restore "پشتیبانِ $(basename "$last") سالم است — $p کارتابل، $k ردیفِ داده"
      else
        bad restore "پشتیبان باز شد ولی خالی است — $out"
      fi;;
    *) bad restore "پشتیبانِ آخر سالم نیست — $out";;
  esac
}

# ---------- پشتیبانِ فایلِ کلیدها ----------
# دیتابیس پشتیبان دارد، ولی /etc/sltech/env نه. اگر سرور از دست برود،
# داده هست و توکن‌ها نیستند — و بعضی‌شان دیگر ساخته نمی‌شوند.
#
# رمز لازم است و از خودِ آدم پرسیده می‌شود (یا OPS_ENV_PASS). بی‌رمز
# کپی نمی‌گیریم: یک فایلِ متنیِ پر از توکن کنارِ پشتیبان‌ها، خودش یک
# در است.
env_backup(){
  say "— پشتیبانِ فایلِ کلیدها —"
  [ -f "$ENVF" ] || { say "  ❌ $ENVF نیست."; fails=$((fails+1)); return; }
  command -v openssl >/dev/null 2>&1 || { say "  ❌ openssl نصب نیست."; fails=$((fails+1)); return; }
  local pass="${OPS_ENV_PASS:-}"
  if [ -z "$pass" ]; then
    printf '  رمز برای فایلِ رمزشده: '
    read -rs pass; echo
  fi
  [ -n "$pass" ] || { say "  ❌ رمز خالی بود."; fails=$((fails+1)); return; }
  mkdir -p "$OUT/env"
  local stamp; stamp=$(date +%Y%m%d-%H%M)
  local f="$OUT/env/env-$stamp.enc"
  if OPS_PASS="$pass" openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt \
       -in "$ENVF" -out "$f" -pass env:OPS_PASS 2>/dev/null; then
    chmod 600 "$f"
    say "  ✅ $f"
    say "  این فایل را جایی بیرونِ همین سرور نگه دارید."
    say "  برگرداندن:  openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -in $f -out env"
  else
    say "  ❌ رمزگذاری نشد."; fails=$((fails+1))
  fi

  # کلیدِ امضای برنامهٔ اندروید. یک بار گم شد و نسخهٔ تازهٔ برنامه
  # دیگر «همان برنامه» حساب نمی‌شد — یعنی هر کاربری باید اول قبلی را
  # پاک می‌کرد. این فایل در مخزن نیست و نباید باشد، پس تنها جایش همین
  # سرور است و تنها پشتیبانش همین‌جا ساخته می‌شود.
  if [ -f "$KEYSTORE" ]; then
    local kf="$OUT/env/keystore-$stamp.enc"
    if OPS_PASS="$pass" openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt \
         -in "$KEYSTORE" -out "$kf" -pass env:OPS_PASS 2>/dev/null; then
      chmod 600 "$kf"
      say "  ✅ $kf"
      say "  رمزِ خودِ کلید جدا از این است و جایی ذخیره نمی‌شود — آن را"
      say "  در مدیرِ رمزتان نگه دارید، وگرنه این فایل هم به درد نمی‌خورد."
    else
      say "  ❌ کلیدِ اندروید رمزگذاری نشد."; fails=$((fails+1))
    fi
  else
    say "  ℹ️ کلیدِ اندروید ($KEYSTORE) نیست — رد شد."
  fi
}

case "${1:-check}" in
  check)   check;;
  errors)  errors;;
  restore) restore;;
  env)     env_backup;;
  all)     check; restore;;
  *) echo "استفاده: bash server/ops.sh [check|errors|restore|env|all]"; exit 2;;
esac

[ "$fails" -eq 0 ] && say "— همه‌چیز سرِ جایش —" || say "— $fails مورد ایراد داشت —"
exit 0
