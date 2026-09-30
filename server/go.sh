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

  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' https://new.sltech.ir/)
  [ "$code" = 200 ] && ok "new.sltech.ir هنوز ۲۰۰ می‌دهد" || bad "new.sltech.ir -> $code"
  code=$(curl -sk --resolve sltech.ir:443:127.0.0.1 -o /dev/null -w '%{http_code}' https://sltech.ir/)
  [ "$code" = 200 ] && ok "sltech.ir روی همین سرور جواب می‌دهد ($code)" || bad "sltech.ir -> $code"
  code=$(curl -sk --resolve www.sltech.ir:443:127.0.0.1 -o /dev/null -w '%{http_code}' https://www.sltech.ir/)
  [ "$code" = 301 ] && ok "www به بدونِ www می‌رود ($code)" || bad "www -> $code"

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
    || die "خروجیِ D1 گرفته نشد. توکن باید دسترسیِ D1 داشته باشد."
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
  ip=$(getent hosts sltech.ir | awk '{print $1}' | head -1)
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

  say "خروجی گرفتن از D1"
  local out=/var/lib/sensa/d1-$(date +%Y%m%d-%H%M).sql
  ( cd "$APP" && CLOUDFLARE_API_TOKEN="$tok" \
    npx --yes wrangler@4 d1 export sensa-db --remote --output "$out" ) \
    || die "خروجیِ D1 گرفته نشد."
  [ -s "$out" ] || die "فایلِ خروجی خالی است."
  ok "گرفته شد ($(du -h "$out" | cut -f1))"

  say "ساختنِ دیتابیسِ فروشگاه"
  DB_FILE="$SDBF" node "$APP/server/import-d1.js" "$out" || die "وارد کردن نشد."

  say "جدا کردنِ داده — جدول‌های کارتابل از این نسخه می‌روند"
  node "$APP/server/split-db.js" "$SDBF" shop --yes || die "جدا کردن نشد."

  say "و از سمتِ کارتابل، جدول‌های فروشگاه"
  systemctl stop sltech
  node "$APP/server/split-db.js" "$DBF" panel --yes || { systemctl start sltech; die "جدا کردن نشد."; }
  chown sltech:sltech "$DBF"
  systemctl start sltech
  sleep 3
  [ "$(systemctl is-active sltech)" = active ] && ok "کارتابل دوباره بالا آمد" || bad "کارتابل بالا نیامد"

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
    chmod 600 "$SENVF"
    ok "$SENVF ساخته شد"
  else
    ok "$SENVF از قبل هست، دست نخورد"
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
  # روشِ فایلی کار نمی‌کند: تا رکورد عوض نشده، sensacare.ir به ورکر
  # می‌رود نه به این سرور. پس DNS-01، مثل دفعهٔ قبل.
  certbot certonly --dns-cloudflare \
    --dns-cloudflare-credentials "$CFINI" \
    --dns-cloudflare-propagation-seconds 30 \
    --cert-name "$SCERT" $SDOMAINS \
    --non-interactive --agree-tos --keep-until-expiring --expand \
    || die "گواهی گرفته نشد. متنِ خطا را بفرست."

  local names
  names=$(openssl x509 -in "/etc/letsencrypt/live/$SCERT/fullchain.pem" -noout -text \
          | grep -A1 'Subject Alternative Name' | tail -1 | tr -d ' ')
  note "$names"
  for d in sensacare.ir www.sensacare.ir; do
    case "$names" in *"DNS:$d"*) ok "$d پوشش دارد" ;; *) bad "$d در گواهی نیست" ;; esac
  done
  say "تمام شد. حالا مرحلهٔ ۸."
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

  local code
  code=$(curl -sk --resolve sensacare.ir:443:127.0.0.1 -o /dev/null -w '%{http_code}' https://sensacare.ir/)
  [ "$code" = 200 ] && ok "sensacare.ir روی همین سرور جواب می‌دهد ($code)" || bad "-> $code"
  code=$(curl -sk --resolve www.sensacare.ir:443:127.0.0.1 -o /dev/null -w '%{http_code}' https://www.sensacare.ir/)
  [ "$code" = 301 ] && ok "www به بدونِ www می‌رود ($code)" || bad "www -> $code"
  code=$(curl -s -o /dev/null -w '%{http_code}' https://sltech.ir/)
  [ "$code" = 200 ] && ok "و اس‌ال‌تک دست‌نخورده است ($code)" || bad "sltech.ir -> $code"

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
    npx --yes wrangler@4 d1 export sensa-db --remote --output "$out" ) || die "خروجیِ D1 نشد."
  [ -s "$out" ] || die "فایلِ خروجی خالی است."
  ok "گرفته شد ($(du -h "$out" | cut -f1))"

  systemctl stop sensa
  DB_FILE="$SDBF" node "$APP/server/import-d1.js" "$out" || { systemctl start sensa; die "وارد کردن نشد."; }
  node "$APP/server/split-db.js" "$SDBF" shop --yes || { systemctl start sensa; die "جدا کردن نشد."; }
  chown sltech:sltech "$SDBF"
  systemctl start sensa
  sleep 3
  [ "$(systemctl is-active sensa)" = active ] && ok "سرویس دوباره بالا آمد" || bad "بالا نیامد"

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
  ip=$(getent hosts sensacare.ir | awk '{print $1}' | head -1)
  note "sensacare.ir الان به $ip می‌رسد"
  [ "$ip" = "185.231.112.152" ] || { bad "هنوز نرسیده. چند دقیقه صبر کن."; exit 1; }
  ok "روی همین سرور نشست"

  for u in https://sensacare.ir/ https://www.sensacare.ir/ https://sltech.ir/; do
    code=$(curl -s -o /dev/null -w '%{http_code}' "$u")
    case "$code" in 200|301) ok "$u -> $code" ;; *) bad "$u -> $code" ;; esac
  done

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
  8) step8 ;;
  9) step9 ;;
  10) step10 ;;
  *) die "کدام مرحله؟  bash $0 1   (۱ تا ۵ کارتابل، ۶ تا ۱۰ فروشگاه)" ;;
esac
