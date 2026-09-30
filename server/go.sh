#!/bin/bash
# ==================== جابه‌جاییِ sltech.ir ====================
# هر مرحله یک دستور. روی سرور، با کاربرِ root:
#
#   bash /opt/sltech/app/server/go.sh 1     سرویس و پشتیبانِ ساعتی
#   bash /opt/sltech/app/server/go.sh 2     گواهیِ sltech.ir و www
#   bash /opt/sltech/app/server/go.sh 3     nginx (هنوز چیزی عوض نمی‌شود)
#   bash /opt/sltech/app/server/go.sh 4     تازه کردنِ داده از D1
#   bash /opt/sltech/app/server/go.sh 5     بعد از عوض کردنِ DNS
#
# و آوردنِ فروشگاه روی همین سرور، جدا از کارتابل:
#
#   bash /opt/sltech/app/server/go.sh 6     سرویس و دیتابیسِ جدای فروشگاه
#   bash /opt/sltech/app/server/go.sh 7     گواهیِ sensacare.ir و www
#   bash /opt/sltech/app/server/go.sh 8     nginx (هنوز چیزی عوض نمی‌شود)
#   bash /opt/sltech/app/server/go.sh 9     دادهٔ تازه، درست پیش از تعویض
#   bash /opt/sltech/app/server/go.sh 10    بعد از عوض کردنِ DNS
#
# «set -e» عمداً نیست: یک بار جلسهٔ SSH را بست. به‌جایش هر قدم خودش
# بررسی می‌شود و اسکریپت با پیامِ روشن می‌ایستد.

APP=/opt/sltech/app
ENVF=/etc/sltech/env
DBF=/var/lib/sltech/sltech.db
CFINI=/root/.secrets/cf.ini
CERT=new.sltech.ir
DOMAINS="-d new.sltech.ir -d sltech.ir -d www.sltech.ir"

# --- فروشگاه ---
SENVF=/etc/sensa/env
SDBF=/var/lib/sensa/sensa.db
SCERT=sensacare.ir
SDOMAINS="-d sensacare.ir -d www.sensacare.ir"
SPORT=8788

say()  { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok()   { printf '   \033[32mok\033[0m   %s\n' "$*"; }
bad()  { printf '   \033[31mBAD\033[0m  %s\n' "$*"; }
note() { printf '        %s\n' "$*"; }
die()  { printf '\n\033[31m%s\033[0m\n\n' "$*"; exit 1; }

# شمردنِ سطرهای یک جدول، در ROWS.
#
# جوابش تصمیم می‌گیرد که کاری دوباره انجام شود یا نه، و «صفر» یعنی
# انجام شده. پس اگر شمردن نشود — sqlite3 نباشد، فایل قفل باشد، جدول
# نباشد — نباید صفر برگرداند: با آن صفرِ دروغین، جدا کردنِ دیتابیسِ
# کارتابل بی‌صدا رد می‌شد و دو سایت روی یک داده می‌ماندند. پس فقط
# «فایل نیست» صفرِ واقعی است؛ بقیه ایستادنِ کار است.
#
# و در ROWS، نه با echo: die داخلِ $( ) فقط زیرپوسته را می‌کشد و
# کارِ اصلی با دستِ خالی جلو می‌رود.
# curl، ولی صبور: تا کدِ خواسته‌شده بیاید یا مهلت تمام شود. کد را
# چاپ می‌کند و اگر نرسید ۱ برمی‌گرداند.
#
# «systemctl reload nginx» فوری نیست؛ چند لحظه کارگرهای قدیمی با
# تنظیماتِ قبلی جواب می‌دهند. در آن چند لحظه دامنه‌ای که بلوکش تازه
# اضافه شده بلوکِ خودش را ندارد و می‌افتد به اولین بلوکِ ۴۴۳ — که
# اتفاقاً بلوکِ www است و ۳۰۱ می‌دهد. یک بار همین، مرحلهٔ ۸ را واداشت
# که سایتِ سالم را «خراب» اعلام کند.
waitfor() {
  local want=$1 tries=$2; shift 2
  local i code=000
  for i in $(seq 1 "$tries"); do
    code=$(curl -sk --max-time 10 -o /dev/null -w '%{http_code}' "$@")
    if [ "$code" = "$want" ]; then echo "$code"; return 0; fi
    sleep 1
  done
  echo "$code"
  return 1
}

# یک توکن برای دو کار لازم است و هر بار یکی‌اش کم بود: بارِ اول
# دسترسیِ zone فروشگاه نبود و certbot افتاد، بارِ دوم توکنِ تازه
# دسترسیِ D1 نداشت و wrangler افتاد. متنِ خطای wrangler هم فقط
# می‌گوید «Authentication error». پس خودمان می‌گوییم چه کم است.
d1hint() {
  bad "توکنِ کلادفلر دسترسیِ D1 ندارد."
  note "My Profile → API Tokens → همان توکن → Edit"
  note "در Permissions یک ردیف اضافه کن:  Account → D1 → Edit"
  note "ردیفِ Zone → DNS → Edit را هم نگه دار؛ هر دو لازم است."
  note "توکن عوض نمی‌شود، پس $CFINI دست‌نخورده می‌ماند."
  die "دسترسی را اضافه کن و همین مرحله را دوباره بزن."
}

# نام‌های داخلِ گواهیِ فروشگاه — چه با توکن گرفته باشیم چه دستی.
#   certnames <نامِ گواهی> <دامنه> ...
certnames() {
  local cert=$1; shift
  local names d
  names=$(openssl x509 -in "/etc/letsencrypt/live/$cert/fullchain.pem" -noout -text \
          | grep -A1 'Subject Alternative Name' | tail -1 | tr -d ' ')
  note "$names"
  for d in "$@"; do
    case "$names" in *"DNS:$d"*) ok "$d پوشش دارد" ;; *) bad "$d در گواهی نیست" ;; esac
  done
}

# دامنه باید به همین سرور برسد، وگرنه webroot بی‌معنی است.
resolves() {
  local ip; ip=$(getent ahostsv4 "$1" | awk '{print $1}' | head -1)
  [ "$ip" = "185.231.112.152" ] || die "$1 به $ip می‌رسد، نه به این سرور."
}

# بردنِ یک گواهی از روشِ کلادفلری به webroot:
#   towebroot <نامِ گواهی> "<آرگومان‌های -d>" <دامنه> ...
#
# تا وقتی گواهی‌ها با dns-cloudflare تازه می‌شوند، سرور به توکنِ
# کلادفلر بند است. حالا که هر دو دامنه روی همین سرورند، خودش جوابِ
# ACME را می‌دهد و توکن دیگر لازم نیست.
towebroot() {
  local cert=$1 doms=$2; shift 2
  install -d /var/www/acme
  # --force-renewal لازم است: بی آن certbot می‌بیند گواهی هنوز تازه
  # است، کاری نمی‌کند، و روشِ تازه‌شوی در پرونده همان قبلی می‌ماند.
  certbot certonly --webroot -w /var/www/acme \
    --cert-name "$cert" $doms \
    --non-interactive --agree-tos --force-renewal \
    || die "گواهیِ $cert با روشِ webroot گرفته نشد. متنِ خطا را بفرست."

  certnames "$cert" "$@"
  if grep -q 'authenticator = webroot' "/etc/letsencrypt/renewal/$cert.conf"
    then ok "$cert از این پس خودکار تازه می‌شود"
    else bad "روشِ تازه‌شویِ $cert عوض نشد"
  fi
  certbot renew --cert-name "$cert" --dry-run >/dev/null 2>&1 \
    && ok "تازه‌شویِ آزمایشیِ $cert گرفت" || bad "تازه‌شویِ آزمایشیِ $cert رد شد"
}

ROWS=0
rows() {
  ROWS=0
  [ -s "$1" ] || return 0
  local n
  n=$(sqlite3 "$1" "SELECT COUNT(*) FROM \"$2\";" 2>/dev/null)
  case "$n" in
    '' | *[!0-9]*) die "شمردنِ جدولِ «$2» در $1 نشد. sqlite3 نصب است؟ فایل قفل نیست؟" ;;
  esac
  ROWS=$n
}

[ "$(id -u)" = 0 ] || die "با کاربرِ root اجرا کن."
[ -d "$APP" ]      || die "برنامه در $APP نیست."

STEP="${1:-}"

# ---------------------------------------------------------------
step1() {
  say "۱ · کد و سرویس"
  git -C "$APP" pull --ff-only || die "git pull نشد. خروجی‌اش را بفرست."
  ok "کد به‌روز شد: $(git -C "$APP" log --oneline -1)"

  # کرونِ سرور تا پیش از جابه‌جاییِ دامنه باید خاموش بماند، وگرنه از
  # روی دیتابیسِ کهنه پشتیبان می‌فرستد و با نسخه‌های کلادفلر قاطی می‌شود.
  if grep -q '^CRON_UTC=-' "$ENVF" 2>/dev/null; then
    ok "کرونِ برنامه خاموش است (درست — تا مرحلهٔ ۵ همین‌طور می‌ماند)"
  else
    printf 'CRON_UTC=-\n' >> "$ENVF"
    ok "کرونِ برنامه خاموش شد تا وقتِ جابه‌جایی"
  fi

  systemctl restart sltech
  sleep 3
  if [ "$(systemctl is-active sltech)" = active ]; then ok "سرویس بالاست"
  else bad "سرویس بالا نیامد"; journalctl -u sltech -n 20 --no-pager; exit 1; fi

  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' -H 'Host: sltech.ir' http://127.0.0.1:8787/)
  [ "$code" = 200 ] && ok "خودِ برنامه جواب می‌دهد ($code)" || bad "برنامه $code داد"

  code=$(curl -s -o /dev/null -w '%{http_code}' https://new.sltech.ir/)
  [ "$code" = 200 ] && ok "از بیرون هم ($code)" || bad "new.sltech.ir -> $code"

  say "۲ · پشتیبانِ ساعتیِ دیتابیس"
  install -d -m 700 -o sltech -g sltech /var/backups/sltech /var/backups/sltech/daily
  install -m 644 "$APP/server/sltech-backup.service" /etc/systemd/system/
  install -m 644 "$APP/server/sltech-backup.timer"   /etc/systemd/system/
  chmod +x "$APP/server/backup.sh"
  systemctl daemon-reload
  systemctl enable --now sltech-backup.timer >/dev/null 2>&1
  ok "زمان‌سنج نصب و روشن شد"

  systemctl start sltech-backup.service
  sleep 6
  if ls /var/backups/sltech/*.db.gz >/dev/null 2>&1; then
    ok "یک نسخه همین حالا گرفته شد"
    ls -lh /var/backups/sltech/*.db.gz | tail -3 | while read -r l; do note "$l"; done
  else
    bad "نسخه‌ای ساخته نشد"; journalctl -u sltech-backup -n 15 --no-pager
  fi
  systemctl list-timers sltech-backup --no-pager | head -3 | while read -r l; do note "$l"; done

  say "تمام شد. حالا مرحلهٔ ۲."
  note "برای مرحلهٔ ۲ یک توکنِ کلادفلر لازم است، با دو دسترسی:"
  note "  Zone  -> DNS      -> Edit   روی sltech.ir"
  note "  Account -> D1     -> Edit"
  note "بسازش و بگذارش در $CFINI به این شکل (فقط همین یک خط):"
  note "  dns_cloudflare_api_token = ..."
  note "دستورش:  install -d -m 700 /root/.secrets && nano $CFINI"
}

# ---------------------------------------------------------------
step2() {
  say "گواهی برای sltech.ir و www"
  [ -s "$CFINI" ] || die "$CFINI نیست یا خالی است. اول توکن را آن‌جا بگذار."
  chmod 600 "$CFINI"
  grep -q 'dns_cloudflare_api_token' "$CFINI" || die "$CFINI باید خطِ dns_cloudflare_api_token داشته باشد."

  if ! command -v certbot >/dev/null; then
    apt-get update -qq && apt-get install -y -qq certbot || die "certbot نصب نشد."
  fi
  if ! python3 -c 'import certbot_dns_cloudflare' 2>/dev/null; then
    apt-get install -y -qq python3-certbot-dns-cloudflare || die "افزونهٔ کلادفلر نصب نشد."
  fi
  ok "certbot و افزونهٔ کلادفلر آماده‌اند"

  # روشِ فایلی (HTTP-01) این‌جا کار نمی‌کند: تا رکورد عوض نشده،
  # sltech.ir به ورکر می‌رود نه به این سرور. پس DNS-01.
  say "گرفتنِ گواهی (یکی دو دقیقه طول می‌کشد)"
  certbot certonly --dns-cloudflare \
    --dns-cloudflare-credentials "$CFINI" \
    --dns-cloudflare-propagation-seconds 30 \
    --cert-name "$CERT" $DOMAINS \
    --non-interactive --agree-tos --keep-until-expiring \
    --expand || die "گواهی گرفته نشد. متنِ خطا را بفرست."

  local names
  names=$(openssl x509 -in "/etc/letsencrypt/live/$CERT/fullchain.pem" -noout -text \
          | grep -A1 'Subject Alternative Name' | tail -1 | tr -d ' ')
  note "$names"
  for d in new.sltech.ir sltech.ir www.sltech.ir; do
    case "$names" in *"DNS:$d"*) ok "$d پوشش دارد" ;; *) bad "$d در گواهی نیست" ;; esac
  done
  say "تمام شد. حالا مرحلهٔ ۳."
}

# ---------------------------------------------------------------
step3() {
  say "nginx"
  [ -f "/etc/letsencrypt/live/$CERT/fullchain.pem" ] || die "گواهی نیست. اول مرحلهٔ ۲."
  install -d /var/www/acme
  local bak="/etc/nginx/sites-available/sltech.bak.$(date +%s)"
  cp -f /etc/nginx/sites-available/sltech "$bak" 2>/dev/null
  install -m 644 "$APP/server/nginx-sltech.conf" /etc/nginx/sites-available/sltech
  ln -sf /etc/nginx/sites-available/sltech /etc/nginx/sites-enabled/sltech
  rm -f /etc/nginx/sites-enabled/default

  # اگر تنظیمات ایراد داشت، فایلِ معیوب نباید بماند. nginxِ در حالِ
  # کار با تنظیماتِ قبلی زنده است و چیزی نمی‌افتد، ولی اولین restart —
  # حتی یکی که certbot موقعِ تمدید می‌زند — سایت را می‌خواباند. پس
  # همان‌جا برمی‌گردانیم.
  if ! nginx -t; then
    if [ -f "$bak" ]; then
      cp -f "$bak" /etc/nginx/sites-available/sltech
      bad "تنظیماتِ تازه برگردانده شد؛ فایلِ قبلی دوباره سرِ جایش است."
    else
      rm -f /etc/nginx/sites-enabled/sltech
      bad "تنظیماتِ تازه برداشته شد."
    fi
    die "تنظیماتِ nginx ایراد دارد. متنِ بالا را بفرست."
  fi
  systemctl reload nginx
  ok "nginx بارگذاری شد"

  local code loc
  code=$(waitfor 200 15 https://new.sltech.ir/) \
    && ok "new.sltech.ir هنوز ۲۰۰ می‌دهد" || bad "new.sltech.ir -> $code"
  code=$(waitfor 200 15 --resolve sltech.ir:443:127.0.0.1 https://sltech.ir/) \
    && ok "sltech.ir روی همین سرور جواب می‌دهد ($code)" || bad "sltech.ir -> $code"
  # مقصدِ ۳۰۱ سنجیده می‌شود نه خودش: هر بلوکِ ناشناسی هم ۳۰۱ می‌دهد.
  loc=$(curl -sk --max-time 10 --resolve www.sltech.ir:443:127.0.0.1 \
        -o /dev/null -w '%{redirect_url}' https://www.sltech.ir/)
  [ "$loc" = "https://sltech.ir/" ] \
    && ok "www به بدونِ www می‌رود ($loc)" || bad "www می‌رود به $loc"

  note "برای کاربران هنوز هیچ چیز عوض نشده — DNS هنوز به کلادفلر است."
  say "تمام شد. حالا مرحلهٔ ۴."
}

# ---------------------------------------------------------------
step4() {
  say "تازه کردنِ داده از D1"
  [ -s "$CFINI" ] || die "$CFINI نیست."
  local tok
  tok=$(sed -n 's/^dns_cloudflare_api_token *= *//p' "$CFINI" | head -1)
  [ -n "$tok" ] || die "توکن در $CFINI خوانده نشد."

  local out=/var/lib/sltech/d1-$(date +%Y%m%d-%H%M).sql
  say "خروجی گرفتن از D1 (چند دقیقه)"
  # از داخلِ خودِ پوشه اجرا می‌شود تا wrangler.toml را پیدا کند، و با
  # همان نسخه‌ای که در package.json هست — نه «latest»، که یک روز
  # می‌تواند رفتارش عوض شود.
  ( cd "$APP" && CLOUDFLARE_API_TOKEN="$tok" \
    npx --yes wrangler@4 d1 export sensa-db --remote --output "$out" ) \
    || d1hint
  [ -s "$out" ] || die "فایلِ خروجی خالی است."
  ok "گرفته شد: $out ($(du -h "$out" | cut -f1))"

  say "ریختن داخلِ دیتابیسِ سرور"
  systemctl stop sltech
  node "$APP/server/import-d1.js" "$out" || { systemctl start sltech; die "وارد کردن نشد. دیتابیسِ قبلی دست‌نخورده است."; }
  chown sltech:sltech "$DBF"
  systemctl start sltech
  sleep 3
  [ "$(systemctl is-active sltech)" = active ] && ok "سرویس دوباره بالا آمد" || bad "سرویس بالا نیامد"

  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' https://new.sltech.ir/)
  [ "$code" = 200 ] && ok "و جواب می‌دهد ($code)" || bad "new.sltech.ir -> $code"
  systemctl start sltech-backup.service
  ok "یک پشتیبان از دادهٔ تازه هم گرفته شد"

  say "حالا نوبتِ DNS — این تنها قدمی است که کاربران می‌بینند"
  note "در کلادفلر، DNS دامنهٔ sltech.ir:"
  note "  ۱) رکوردهای Worker برای «sltech.ir» و «www» را پاک کن"
  note "  ۲) به‌جایشان دو رکوردِ A بگذار به 185.231.112.152"
  note "  ۳) هر دو خاکستری (DNS only)، نه نارنجی"
  note "رکوردهای «new» و «tg» دست نخورند."
  note "بعدش:  bash $APP/server/go.sh 5"
}

# ---------------------------------------------------------------
step5() {
  say "بعد از DNS"
  local ip code
  ip=$(getent ahostsv4 sltech.ir | awk '{print $1}' | head -1)
  note "sltech.ir الان به $ip می‌رسد"
  if [ "$ip" != "185.231.112.152" ]; then
    bad "هنوز به این سرور نرسیده. چند دقیقه صبر کن و دوباره بزن."
    exit 1
  fi
  ok "روی همین سرور نشست"

  # تا پیش از جابه‌جایی، PANEL_HOST روی دامنهٔ آزمایشی بود — وگرنه
  # new.sltech.ir صفحهٔ کارتابل را نشان نمی‌داد. حالا که دامنهٔ اصلی
  # به این سرور رسیده، باید همان باشد، وگرنه برنامه sltech.ir را
  # «دامنهٔ ناشناس» می‌بیند و فروشگاه را سرو می‌کند. یک بار همین اتفاق
  # افتاد و سایت با آدرسِ درست، محتوای آن یکی سایت را نشان داد.
  if grep -q '^PANEL_HOST=sltech\.ir$' "$ENVF"; then
    ok "PANEL_HOST درست است"
  else
    if grep -q '^PANEL_HOST=' "$ENVF"; then
      sed -i 's|^PANEL_HOST=.*|PANEL_HOST=sltech.ir|' "$ENVF"
    else
      printf '\nPANEL_HOST=sltech.ir\n' >> "$ENVF"
    fi
    ok "PANEL_HOST روی sltech.ir تنظیم شد"
  fi

  say "روشن کردنِ کرون"
  sed -i '/^CRON_UTC=-$/d' "$ENVF"
  systemctl restart sltech
  sleep 3
  systemctl is-active sltech >/dev/null && ok "سرویس با کرونِ ساعتی بالا آمد" || bad "سرویس بالا نیامد"

  for u in https://sltech.ir/ https://sltech.ir/login https://www.sltech.ir/; do
    code=$(curl -s -o /dev/null -w '%{http_code}' "$u")
    case "$code" in 200|301) ok "$u -> $code" ;; *) bad "$u -> $code" ;; esac
  done

  # ۲۰۰ گرفتن کافی نیست: وقتی PANEL_HOST غلط بود، sltech.ir هم ۲۰۰
  # می‌داد — فقط محتوایش مالِ آن یکی سایت بود. پس محتوا سنجیده می‌شود.
  if curl -s -H 'Host: sltech.ir' http://127.0.0.1:8787/ | grep -q planList; then
    ok "و محتوایش واقعاً صفحهٔ SLTech است، نه فروشگاه"
  else
    bad "روی sltech.ir محتوای درست سرو نمی‌شود — PANEL_HOST را ببین"
  fi
  journalctl -u sltech -n 6 --no-pager | grep -i 'کرون' | while read -r l; do note "$l"; done

  say "تمام"
  note "یک نوبتِ پشتیبان را صبر کن (سرِ دقیقهٔ ۳۰) و ببین زیپ در تلگرام آمد."
  note "و در پنل مدیر، «وصل کردن ربات‌ها به سایت» را بزن."
}

# ===================================================================
#                       فروشگاه — sensacare.ir
# ===================================================================

# ---------------------------------------------------------------
step6() {
  say "۶ · سرویس و دیتابیسِ جدای فروشگاه"
  [ -s "$CFINI" ] || die "$CFINI نیست. همان توکنِ کلادفلر لازم است."
  local tok; tok=$(sed -n 's/^dns_cloudflare_api_token *= *//p' "$CFINI" | head -1)
  [ -n "$tok" ] || die "توکن در $CFINI خوانده نشد."

  install -d -m 755 /etc/sensa
  install -d -m 700 -o sltech -g sltech /var/lib/sensa /var/backups/sensa /var/backups/sensa/daily

  # این مرحله باید بشود دوباره زد. بارِ اول همین‌جا تا نیمه رفت و روی
  # فایلِ تنظیمات افتاد؛ اگر کلِ کار را از نو می‌کرد، یعنی یک خروجیِ
  # دیگر از D1 و یک بار دیگر خواباندنِ کارتابل، بی‌هیچ سودی. دادهٔ تازه
  # هم مهم نیست: مرحلهٔ ۹ درست پیش از تعویضِ DNS دوباره می‌گیرد.
  rows "$SDBF" products
  local have=$ROWS
  if [ "$have" -gt 0 ]; then
    ok "دیتابیسِ فروشگاه از قبل هست ($have محصول) — دوباره نمی‌گیریم"
  else
    say "خروجی گرفتن از D1"
    local out=/var/lib/sensa/d1-$(date +%Y%m%d-%H%M).sql
    ( cd "$APP" && CLOUDFLARE_API_TOKEN="$tok" \
      npx --yes wrangler@4 d1 export sensa-db --remote --output "$out" ) \
      || d1hint
    [ -s "$out" ] || die "فایلِ خروجی خالی است."
    ok "گرفته شد ($(du -h "$out" | cut -f1))"

    say "ساختنِ دیتابیسِ فروشگاه"
    DB_FILE="$SDBF" node "$APP/server/import-d1.js" "$out" || die "وارد کردن نشد."

    say "جدا کردنِ داده — جدول‌های کارتابل از این نسخه می‌روند"
    node "$APP/server/split-db.js" "$SDBF" shop --yes || die "جدا کردن نشد."
  fi

  rows "$DBF" products
  if [ "$ROWS" -eq 0 ]; then
    ok "سمتِ کارتابل از قبل جدا شده — دست نمی‌زنیم"
  else
    say "و از سمتِ کارتابل، جدول‌های فروشگاه"
    systemctl stop sltech
    node "$APP/server/split-db.js" "$DBF" panel --yes || { systemctl start sltech; die "جدا کردن نشد."; }
    chown sltech:sltech "$DBF"
    systemctl start sltech
    sleep 3
    [ "$(systemctl is-active sltech)" = active ] && ok "کارتابل دوباره بالا آمد" || die "کارتابل بالا نیامد"
  fi

  say "تنظیماتِ سرویسِ فروشگاه"
  if [ ! -f "$SENVF" ]; then
    {
      printf 'PORT=%s\nBIND=127.0.0.1\n' "$SPORT"
      printf 'DB_FILE=%s\n' "$SDBF"
      printf 'PUBLIC_HOST=sensacare.ir\nSHOP_HOST=sensacare.ir\n'
      # کارهای کارتابل مالِ آن یکی سرویس است.
      printf 'KARTABL_JOBS=off\n'
      # تا پیش از تعویضِ دامنه، کرون خاموش: وگرنه از روی نسخه‌ای که
      # هنوز زنده نیست برای مشتری‌ها پیام می‌رود.
      printf 'CRON_UTC=-\n'
      # کلیدهایی که از تنظیماتِ کارتابل برمی‌داریم — رله و رمزها.
      grep -E '^(TG_BASE|BALE_BASE|JWT_SECRET|SMS_|ADMIN_|BOT_SECRET)' "$ENVF" 2>/dev/null
    } > "$SENVF"
    ok "$SENVF ساخته شد"
  else
    ok "$SENVF از قبل هست، دست نخورد"
  fi

  # سرویس با کاربرِ sltech بالا می‌آید، نه root. اگر این فایل ۶۰۰ و مالِ
  # root بماند، سرویس با EACCES می‌افتد — همان چیزی که یک بار خورد.
  # گروهش sltech و حالتش ۶۴۰: سرویس می‌خواند، بقیه نه.
  chown root:sltech "$SENVF"
  chmod 640 "$SENVF"
  if command -v runuser >/dev/null 2>&1; then
    runuser -u sltech -- test -r "$SENVF" \
      || die "کاربرِ sltech نمی‌تواند $SENVF را بخواند"
    ok "برای کاربرِ sltech خواندنی است"
  else
    note "runuser نبود؛ خواندنی بودنِ $SENVF چک نشد"
  fi

  chown sltech:sltech "$SDBF"

  install -m 644 "$APP/server/sensa.service" /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable --now sensa >/dev/null 2>&1
  sleep 3
  if [ "$(systemctl is-active sensa)" = active ]; then ok "سرویسِ فروشگاه بالاست"
  else bad "بالا نیامد"; journalctl -u sensa -n 20 --no-pager; exit 1; fi

  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' -H 'Host: sensacare.ir' "http://127.0.0.1:$SPORT/")
  [ "$code" = 200 ] && ok "و جواب می‌دهد ($code)" || bad "فروشگاه $code داد"
  if curl -s -H 'Host: sensacare.ir' "http://127.0.0.1:$SPORT/" | grep -q planList; then
    bad "محتوایش اس‌ال‌تک است، نه فروشگاه — PANEL_HOST را در $SENVF ببین"
  else
    ok "و محتوایش فروشگاه است"
  fi

  say "تمام شد. حالا مرحلهٔ ۷."
}

# ---------------------------------------------------------------
step7() {
  say "۷ · گواهی برای sensacare.ir"
  [ -s "$CFINI" ] || die "$CFINI نیست."
  # توکنی که برای sltech.ir ساخته شده بود فقط همان zone را می‌دید، و
  # certbot با «Unable to determine zone_id» می‌افتاد — پیامی که معلوم
  # نمی‌کند اشکال از توکن است. پس اول خودمان می‌پرسیم.
  local tok zones
  tok=$(sed -n 's/^dns_cloudflare_api_token *= *//p' "$CFINI" | head -1)
  [ -n "$tok" ] || die "توکنی در $CFINI نیست."
  zones=$(curl -s -H "Authorization: Bearer $tok" \
    'https://api.cloudflare.com/client/v4/zones?name=sensacare.ir' \
    | grep -o '"id":"[0-9a-f]\{32\}"' | head -1)
  if [ -z "$zones" ]; then
    bad "توکنِ کلادفلر دامنهٔ sensacare.ir را نمی‌بیند."
    note "در کلادفلر → My Profile → API Tokens توکن را Edit کن و"
    note "در Zone Resources، هم sltech.ir و هم sensacare.ir را بده"
    note "(یا All zones). دسترسی: Zone → DNS → Edit."
    note "بعد توکنِ تازه را در $CFINI بگذار و همین مرحله را دوباره بزن."
    exit 1
  fi
  ok "توکن، zone فروشگاه را می‌بیند"

  # روشِ فایلی کار نمی‌کند: تا رکورد عوض نشده، sensacare.ir به ورکر
  # می‌رود نه به این سرور. پس DNS-01، مثل دفعهٔ قبل.
  certbot certonly --dns-cloudflare \
    --dns-cloudflare-credentials "$CFINI" \
    --dns-cloudflare-propagation-seconds 30 \
    --cert-name "$SCERT" $SDOMAINS \
    --non-interactive --agree-tos --keep-until-expiring --expand \
    || die "گواهی گرفته نشد. متنِ خطا را بفرست."

  certnames "$SCERT" sensacare.ir www.sensacare.ir
  say "تمام شد. حالا مرحلهٔ ۸."
}

# ---------------------------------------------------------------
# ۷م · همان گواهی، بدونِ هیچ توکنی
#
# توکنِ کلادفلر فقط zone اس‌ال‌تک را می‌دید و درست کردنش گیر کرد. این
# راه از توکن رد می‌شود: certbot مقدارِ TXT را می‌دهد، تو در پنلِ
# کلادفلر می‌گذاری. برای گرفتنِ گواهی پیش از تعویضِ DNS همین بس است.
#
# اما این گواهی خودش تازه نمی‌شود، و گواهی‌ای که تازه نشود سه ماهِ بعد
# سایت را می‌خواباند. پس بعد از تعویضِ DNS، مرحلهٔ ۷ه آن را به روشِ
# webroot برمی‌گرداند: از آن لحظه دامنه روی همین سرور است، پس خودِ
# سرور جواب می‌دهد و دیگر نه توکن لازم است نه دستِ تو.
step7m() {
  say "۷م · گواهی برای sensacare.ir، با رکوردِ دستی"
  note "certbot یک یا دو مقدارِ TXT می‌دهد. هر کدام را در کلادفلر،"
  note "دامنهٔ sensacare.ir، با همان نامی که خودش می‌گوید"
  note "(_acme-challenge یا _acme-challenge.www) ثبت کن، Save کن،"
  note "چند ثانیه صبر کن، بعد Enter. تا تمام نشده پنجره را نبند."
  note ""
  certbot certonly --manual --preferred-challenges dns \
    --cert-name "$SCERT" $SDOMAINS \
    --agree-tos --expand \
    || die "گواهی گرفته نشد. متنِ خطا را بفرست."

  certnames "$SCERT" sensacare.ir www.sensacare.ir
  note "این گواهی خودکار تازه نمی‌شود."
  note "بعد از تعویضِ DNS حتماً:  bash $APP/server/go.sh 7h"
  say "تمام شد. حالا مرحلهٔ ۸."
}

# ---------------------------------------------------------------
step7h() {
  say "۷ه · گواهیِ فروشگاه، به تازه‌شویِ خودکار"
  resolves sensacare.ir
  [ -f "/etc/letsencrypt/live/$SCERT/fullchain.pem" ] || die "گواهی نیست. اول مرحلهٔ ۷ یا ۷م."
  towebroot "$SCERT" "$SDOMAINS" sensacare.ir www.sensacare.ir
  systemctl reload nginx
  ok "nginx با گواهیِ تازه بارگذاری شد"
  say "تمام شد."
}

# ---------------------------------------------------------------
# ۱۱ · بریدنِ آخرین بندِ سرور به کلادفلر
#
# هر دو گواهی با dns-cloudflare گرفته شده‌اند، یعنی تا ابد برای
# تازه شدن به آن توکن نیاز دارند. و آن توکن در گفت‌وگو فاش شد، پس
# باید حذف شود — ولی تا وقتی گواهی‌ها به آن بندند، حذفش یعنی سه ماهِ
# بعد هر دو سایت با گواهیِ منقضی بخوابند.
#
# حالا هر دو دامنه روی همین سرورند، پس خودِ سرور می‌تواند جوابِ ACME
# را بدهد. این مرحله هر دو را به webroot می‌برد و با یک تازه‌شویِ
# آزمایشی ثابت می‌کند که واقعاً کار می‌کند — بعد توکن دور ریختنی است.
step11() {
  say "۱۱ · هر دو گواهی، بی‌نیاز از کلادفلر"
  local d code
  for d in sltech.ir www.sltech.ir new.sltech.ir sensacare.ir www.sensacare.ir; do
    resolves "$d"
  done
  ok "هر پنج نام به همین سرور می‌رسند"

  say "گواهیِ اس‌ال‌تک"
  towebroot "$CERT" "$DOMAINS" new.sltech.ir sltech.ir www.sltech.ir

  say "گواهیِ فروشگاه"
  towebroot "$SCERT" "$SDOMAINS" sensacare.ir www.sensacare.ir

  systemctl reload nginx
  ok "nginx بارگذاری شد"

  code=$(waitfor 200 15 https://sltech.ir/)    && ok "sltech.ir -> $code"    || bad "sltech.ir -> $code"
  code=$(waitfor 200 15 https://sensacare.ir/) && ok "sensacare.ir -> $code" || bad "sensacare.ir -> $code"

  if grep -rq 'dns_cloudflare' /etc/letsencrypt/renewal/ 2>/dev/null; then
    bad "هنوز گواهی‌ای به کلادفلر بند است:"
    grep -rl 'dns_cloudflare' /etc/letsencrypt/renewal/ | while read -r f; do note "$f"; done
  else
    ok "هیچ گواهی‌ای دیگر به کلادفلر بند نیست"
    say "حالا توکن دور ریختنی است"
    note "در کلادفلر → My Profile → API Tokens → آن توکن → Delete"
    note "و بعد روی سرور:   shred -u $CFINI"
    note "تا وقتی حذف نکرده‌ای، آن توکن هر کاری با DNS هر دو دامنه می‌تواند بکند."
  fi
  say "تمام شد."
}

# ---------------------------------------------------------------
step8() {
  say "۸ · nginx برای فروشگاه"
  [ -f "/etc/letsencrypt/live/$SCERT/fullchain.pem" ] || die "گواهی نیست. اول مرحلهٔ ۷."
  local bak="/etc/nginx/sites-available/sensa.bak.$(date +%s)"
  cp -f /etc/nginx/sites-available/sensa "$bak" 2>/dev/null
  install -m 644 "$APP/server/nginx-sensa.conf" /etc/nginx/sites-available/sensa
  ln -sf /etc/nginx/sites-available/sensa /etc/nginx/sites-enabled/sensa

  if ! nginx -t; then
    if [ -f "$bak" ]; then cp -f "$bak" /etc/nginx/sites-available/sensa
    else rm -f /etc/nginx/sites-enabled/sensa; fi
    die "تنظیماتِ nginx ایراد دارد. متنِ بالا را بفرست."
  fi
  systemctl reload nginx
  ok "nginx بارگذاری شد"

  local code loc
  code=$(waitfor 200 15 --resolve sensacare.ir:443:127.0.0.1 https://sensacare.ir/) \
    && ok "sensacare.ir روی همین سرور جواب می‌دهد ($code)" \
    || bad "sensacare.ir -> $code"

  # این‌جا «۳۰۱ گرفتیم» کافی نیست: اولین بلوکِ ۴۴۳ هم ۳۰۱ می‌دهد، پس
  # اگر بلوکِ www هنوز زنده نشده باشد همین چک به دلیلِ غلط سبز می‌شود.
  # مقصدِ ۳۰۱ را می‌سنجیم، نه خودش را.
  loc=$(curl -sk --max-time 10 --resolve www.sensacare.ir:443:127.0.0.1 \
        -o /dev/null -w '%{redirect_url}' https://www.sensacare.ir/)
  [ "$loc" = "https://sensacare.ir/" ] \
    && ok "www به بدونِ www می‌رود ($loc)" || bad "www می‌رود به $loc"

  code=$(waitfor 200 10 https://sltech.ir/) \
    && ok "و اس‌ال‌تک دست‌نخورده است ($code)" || bad "sltech.ir -> $code"

  note "برای کاربران هنوز هیچ چیز عوض نشده — DNS هنوز به کلادفلر است."
  say "تمام شد. حالا مرحلهٔ ۹."
}

# ---------------------------------------------------------------
step9() {
  say "۹ · دادهٔ تازه، درست پیش از تعویض"
  note "هر سفارشی که بینِ این لحظه و عوض کردنِ رکورد ثبت شود از دست می‌رود."
  note "پس صفحهٔ DNS کلادفلر را همین حالا در تبِ دیگر باز کن."
  [ -s "$CFINI" ] || die "$CFINI نیست."
  local tok; tok=$(sed -n 's/^dns_cloudflare_api_token *= *//p' "$CFINI" | head -1)

  local out=/var/lib/sensa/d1-$(date +%Y%m%d-%H%M).sql
  ( cd "$APP" && CLOUDFLARE_API_TOKEN="$tok" \
    npx --yes wrangler@4 d1 export sensa-db --remote --output "$out" ) || d1hint
  [ -s "$out" ] || die "فایلِ خروجی خالی است."
  ok "گرفته شد ($(du -h "$out" | cut -f1))"

  systemctl stop sensa
  DB_FILE="$SDBF" node "$APP/server/import-d1.js" "$out" || { systemctl start sensa; die "وارد کردن نشد."; }
  node "$APP/server/split-db.js" "$SDBF" shop --yes || { systemctl start sensa; die "جدا کردن نشد."; }
  chown sltech:sltech "$SDBF"
  systemctl start sensa
  sleep 3
  # اینجا دیگر bad بس نیست. قدمِ بعدی تعویضِ DNS است؛ اگر سرویس بالا
  # نیامده باشد و ما دستورِ DNS را چاپ کنیم، فروشگاه را با دستِ خودمان
  # از دسترسِ مشتری در می‌آوریم. پس تا سالم نشود، از اینجا جلوتر نمی‌رود.
  if [ "$(systemctl is-active sensa)" != active ]; then
    journalctl -u sensa -n 20 --no-pager
    die "سرویسِ فروشگاه بالا نیامد — DNS را عوض نکن."
  fi
  ok "سرویس دوباره بالا آمد"

  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' -H 'Host: sensacare.ir' "http://127.0.0.1:$SPORT/")
  [ "$code" = 200 ] || die "فروشگاه $code داد نه ۲۰۰ — DNS را عوض نکن."
  if curl -s -H 'Host: sensacare.ir' "http://127.0.0.1:$SPORT/" | grep -q planList; then
    die "محتوا اس‌ال‌تک است نه فروشگاه — DNS را عوض نکن."
  fi
  ok "و با دادهٔ تازه، فروشگاه را می‌دهد ($code)"

  say "حالا DNS — این تنها قدمی است که مشتری‌ها می‌بینند"
  note "در کلادفلر، دامنهٔ sensacare.ir:"
  note "  اگر رکوردها از نوعِ Worker بودند، اول در ورکرِ sensa"
  note "  بخشِ Domains & Routes آن دو دامنه را Remove کن."
  note "  بعد دو رکوردِ A به 185.231.112.152، هر دو خاکستری."
  note "بعدش:  bash $APP/server/go.sh 10"
}

# ---------------------------------------------------------------
step10() {
  say "۱۰ · بعد از DNS"
  local ip code
  ip=$(getent ahostsv4 sensacare.ir | awk '{print $1}' | head -1)
  note "sensacare.ir الان به $ip می‌رسد"
  [ "$ip" = "185.231.112.152" ] || { bad "هنوز نرسیده. چند دقیقه صبر کن."; exit 1; }
  ok "روی همین سرور نشست"

  # «۲۰۰ یا ۳۰۱، هر کدام» چکِ نرمی بود که هیچ‌وقت چیزی نمی‌گرفت: اولین
  # بلوکِ ۴۴۳ به هر نامِ ناشناسی ۳۰۱ می‌دهد و آن ۳۰۱ این چک را سبز
  # می‌کرد. این‌جا، یک قدم بعد از تعویضِ DNS، دقیقاً همان جایی است که
  # نباید چیزی را اشتباه سبز ببینیم. پس هر کدام جوابِ خودش را بدهد.
  local loc
  code=$(waitfor 200 20 https://sensacare.ir/) \
    && ok "sensacare.ir -> $code" || bad "sensacare.ir -> $code"
  if curl -s --max-time 15 https://sensacare.ir/ | grep -q planList
    then bad "sensacare.ir محتوای اس‌ال‌تک را می‌دهد"
    else ok "و محتوایش فروشگاه است"
  fi

  loc=$(curl -s --max-time 15 -o /dev/null -w '%{redirect_url}' https://www.sensacare.ir/)
  [ "$loc" = "https://sensacare.ir/" ] \
    && ok "www.sensacare.ir -> $loc" || bad "www.sensacare.ir می‌رود به $loc"

  code=$(waitfor 200 10 https://sltech.ir/) \
    && ok "sltech.ir -> $code" || bad "sltech.ir -> $code"
  if curl -s --max-time 15 https://sltech.ir/ | grep -q planList
    then ok "و اس‌ال‌تک هم صفحهٔ خودش را می‌دهد"
    else bad "sltech.ir صفحهٔ خودش را نمی‌دهد"
  fi

  say "روشن کردنِ کرونِ فروشگاه"
  sed -i '/^CRON_UTC=-$/d' "$SENVF"
  systemctl restart sensa
  sleep 3
  systemctl is-active sensa >/dev/null && ok "سرویسِ فروشگاه با کرون بالا آمد" || bad "بالا نیامد"

  say "پشتیبانِ ساعتیِ فروشگاه"
  sed -e 's|/var/lib/sltech/sltech.db|/var/lib/sensa/sensa.db|' \
      -e 's|/var/backups/sltech|/var/backups/sensa|' \
      -e 's|SLTech database backup|SensaCare database backup|' \
      "$APP/server/sltech-backup.service" > /etc/systemd/system/sensa-backup.service
  sed 's|SLTech database backup|SensaCare database backup|' \
      "$APP/server/sltech-backup.timer" > /etc/systemd/system/sensa-backup.timer
  systemctl daemon-reload
  systemctl enable --now sensa-backup.timer >/dev/null 2>&1
  systemctl start sensa-backup.service
  sleep 6
  if ls /var/backups/sensa/*.db.gz >/dev/null 2>&1; then
    ok "اولین پشتیبانِ فروشگاه گرفته شد"
    ls -lh /var/backups/sensa/*.db.gz | tail -2 | while read -r l; do note "$l"; done
  else
    bad "نسخه‌ای ساخته نشد"; journalctl -u sensa-backup -n 12 --no-pager
  fi

  say "تمام — دو سایت، یک سرور، دو دیتابیس"
  note "در پنلِ فروشگاه «وصل کردن ربات‌ها» را بزن تا وب‌هوکِ تلگرام از رله برود."
  note "و در ورکرِ رله، متغیرِ SHOP_ORIGIN را روی https://sensacare.ir بگذار."
}

case "$STEP" in
  1) step1 ;;
  2) step2 ;;
  3) step3 ;;
  4) step4 ;;
  5) step5 ;;
  6) step6 ;;
  7) step7 ;;
  7m) step7m ;;
  7h) step7h ;;
  8) step8 ;;
  9) step9 ;;
  10) step10 ;;
  11) step11 ;;
  *) die "کدام مرحله؟  bash $0 1   (۱ تا ۵ کارتابل، ۶ تا ۱۰ فروشگاه، 7m گواهیِ دستی، 7h برگرداندنش به خودکار)" ;;
esac
