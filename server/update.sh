#!/bin/bash
# ==================== به‌روز کردنِ سرور ====================
# کدِ تازه را می‌گیرد، سرویس را دوباره بالا می‌آورد و می‌سنجد که
# واقعاً جواب می‌دهد. روی سرور، با کاربرِ root:
#
#   bash /opt/sltech/app/server/update.sh
#
# چرا جدا از go.sh؟ چون go.sh برای دورانِ جابه‌جاییِ دامنه نوشته شده
# بود و مرحلهٔ یکش کرونِ پشتیبان را خاموش می‌کند. آن کار همان موقع
# درست بود و حالا نیست — کسی که فقط می‌خواهد کدِ تازه را بیاورد،
# نباید مجبور باشد یادش بماند که آن خط را رد کند.
#
# «set -e» عمداً نیست: یک بار جلسهٔ SSH را بست. هر قدم خودش بررسی
# می‌شود و با پیامِ روشن می‌ایستد.

# این دو را می‌شود از بیرون داد تا بشود اسکریپت را جای دیگری هم آزمود
APP=${APP:-/opt/sltech/app}
PORT=${PORT:-8787}

say()  { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok()   { printf '   \033[32mok\033[0m   %s\n' "$*"; }
bad()  { printf '   \033[31mBAD\033[0m  %s\n' "$*"; }
die()  { printf '\n\033[31m%s\033[0m\n\n' "$*"; exit 1; }

[ "$(id -u)" = 0 ] || die "با کاربرِ root اجرا کن."
[ -d "$APP/.git" ] || die "برنامه در $APP نیست."

say "۱ · کدِ تازه"
BEFORE=$(git -C "$APP" rev-parse --short HEAD 2>/dev/null)
BRANCH=$(git -C "$APP" rev-parse --abbrev-ref HEAD 2>/dev/null)
echo "   شاخه: $BRANCH"

# قدمِ ۲ همین اسکریپت «npm install» می‌زند و npm خودش package-lock.json
# را بازنویسی می‌کند. نتیجه این بود که هر به‌روزرسانی، به‌روزرسانیِ
# بعدی را می‌بست — با پیامی که مثلِ یک دست‌کاریِ مشکوک به نظر می‌رسید.
# این فایل ساختهٔ npm است، نه کارِ کسی؛ پس اگر تنها همین دست‌خورده
# باشد، برمی‌گردانیمش و رد می‌شویم. هر فایلِ دیگری همان‌طور که بود
# جلوی به‌روزرسانی را می‌گیرد.
if [ "$(git -C "$APP" status --porcelain)" = " M package-lock.json" ]; then
  git -C "$APP" checkout -- package-lock.json \
    && ok "package-lock.json که npm عوضش کرده بود، برگشت"
fi

# هر تغییرِ دست‌نخورده‌ای روی سرور، pull را می‌شکند. بهتر است همین‌جا
# با پیامِ روشن بایستد تا نصفه‌کاره جلو برود.
if [ -n "$(git -C "$APP" status --porcelain)" ]; then
  bad "روی سرور فایلِ دست‌خورده هست. اول ببین چه چیزی عوض شده:"
  git -C "$APP" status --short
  die "تا تکلیفِ این‌ها روشن نشود، به‌روزرسانی انجام نمی‌شود."
fi

git -C "$APP" pull --ff-only || die "git pull نشد. خروجی‌اش را بفرست."
AFTER=$(git -C "$APP" rev-parse --short HEAD)
if [ "$BEFORE" = "$AFTER" ]; then
  ok "از قبل به‌روز بود ($AFTER)"
else
  ok "$BEFORE → $AFTER"
  git -C "$APP" log --oneline "$BEFORE..$AFTER" | sed 's/^/        /'
fi

say "۲ · وابستگی‌ها"
if git -C "$APP" diff --name-only "$BEFORE" "$AFTER" 2>/dev/null | grep -q '^package.*\.json$'; then
  (cd "$APP" && npm install --omit=dev --no-audit --no-fund) || die "npm install نشد."
  ok "وابستگی‌ها تازه شدند"
else
  ok "دست‌نخورده‌اند، نصبِ دوباره لازم نیست"
fi

say "۳ · دیتابیس"
# migrations.sql تکرارپذیر است (همه‌جا IF NOT EXISTS)، پس هر بار
# اجرایش بی‌خطر است. تا امروز اصلاً اجرا نمی‌شد: جدولِ تازه‌ای که با
# کد می‌آمد روی سرور ساخته نمی‌شد و قابلیتش بی‌صدا کار نمی‌کرد —
# دقیقاً همین سرِ جدولِ خطاها پیش آمد. سرویس هنوز بالاست و این
# دستور چیزی را نمی‌اندازد، فقط نبوده‌ها را می‌سازد.
if (cd "$APP" && node server/migrate.js); then
  ok "مهاجرت‌ها اجرا شدند"
else
  die "مهاجرت‌ها اجرا نشدند. خروجی‌اش را بفرست."
fi

say "۴ · سرویس"
if [ -n "$SKIP_SVC" ]; then ok "راه‌اندازیِ سرویس رد شد (آزمون)"; else
systemctl restart sltech || die "سرویس راه نیفتاد."
sleep 3
if [ "$(systemctl is-active sltech)" = active ]; then
  ok "سرویس بالاست"
else
  bad "سرویس بالا نیامد:"
  journalctl -u sltech -n 25 --no-pager
  die "کدِ تازه بالا نیامد."
fi
fi

say "۵ · واقعاً جواب می‌دهد؟"
if [ -n "$SKIP_SVC" ]; then CODE=200; else
CODE=$(curl -s -o /dev/null -w '%{http_code}' -H 'Host: sltech.ir' "http://127.0.0.1:$PORT/"); fi
if [ "$CODE" = 200 ]; then ok "صفحهٔ اصلی $CODE"
else bad "صفحهٔ اصلی $CODE داد"; journalctl -u sltech -n 25 --no-pager; die "بالا نیامد."; fi

# سرویسِ فروشگاه جداست و فقط اگر روی همین سرور باشد
if [ -z "$SKIP_SVC" ] && systemctl list-unit-files 2>/dev/null | grep -q '^sensa\.service'; then
  systemctl restart sensa && sleep 2
  if [ "$(systemctl is-active sensa)" = active ]; then ok "فروشگاه هم بالاست"
  else bad "فروشگاه بالا نیامد"; journalctl -u sensa -n 20 --no-pager; fi
fi

say "تمام. نسخهٔ روی سرور: $(git -C "$APP" log --oneline -1)"
printf '\nدر مرورگر یک بار Ctrl+Shift+R بزن تا نسخهٔ کَش‌شده کنار برود.\n\n'
