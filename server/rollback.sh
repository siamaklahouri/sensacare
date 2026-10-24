#!/bin/bash
# ==================== برگشت به نسخهٔ قبل ====================
# استقرار یک دستور است (update.sh) و برگشت هیچ دستوری نداشت — یعنی
# شبی که استقراری خراب از آب دربیاید، باید همان شب دستوراتش را از نو
# سرِهم می‌کردیم. بدترین وقتِ یاد گرفتن.
#
#   bash /opt/sltech/app/server/rollback.sh          یک قدم عقب
#   bash /opt/sltech/app/server/rollback.sh <sha>    به همان نسخه
#   bash /opt/sltech/app/server/rollback.sh --list   نسخه‌های اخیر
#
# کاری که می‌کند: کدِ همان نسخه را می‌گذارد، سرویس را بالا می‌آورد و
# می‌سنجد که جواب می‌دهد. دیتابیس دست نمی‌خورد — برگشتِ داده کارِ
# پشتیبان است، نه این.

APP=${APP:-/opt/sltech/app}
PORT=${PORT:-8787}

say()  { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok()   { printf '   \033[32mok\033[0m   %s\n' "$*"; }
bad()  { printf '   \033[31mBAD\033[0m  %s\n' "$*"; }
die()  { printf '\n\033[31m%s\033[0m\n\n' "$*"; exit 1; }

[ "$(id -u)" = 0 ] || die "با کاربرِ root اجرا کن."
[ -d "$APP/.git" ] || die "برنامه در $APP نیست."

if [ "${1:-}" = "--list" ]; then
  git -C "$APP" log --oneline -15
  exit 0
fi

NOW=$(git -C "$APP" rev-parse --short HEAD)
TARGET="${1:-}"
[ -n "$TARGET" ] || TARGET=$(git -C "$APP" rev-parse --short HEAD~1 2>/dev/null)
[ -n "$TARGET" ] || die "نسخهٔ قبلی پیدا نشد."

git -C "$APP" cat-file -e "$TARGET^{commit}" 2>/dev/null || die "«$TARGET» نسخهٔ معتبری نیست."

say "برگشت از $NOW به $TARGET"
git -C "$APP" log --oneline -1 "$TARGET" | sed 's/^/   /'

if [ -n "$(git -C "$APP" status --porcelain)" ]; then
  bad "روی سرور فایلِ دست‌خورده هست:"
  git -C "$APP" status --short
  die "اول تکلیفشان روشن شود."
fi

# شاخه رها می‌شود (detached) — عمدی است: تا وقتی روی نسخهٔ قدیمی
# هستیم، update.sh خودش می‌گوید که روی شاخه نیستیم و اشتباهی pull
# نمی‌کند.
git -C "$APP" checkout --quiet "$TARGET" || die "checkout نشد."
ok "کد برگشت"

# اگر وابستگی‌ها بینِ این دو نسخه عوض شده‌اند، باید دوباره نصب شوند
if git -C "$APP" diff --name-only "$TARGET" "$NOW" 2>/dev/null | grep -q '^package.*\.json$'; then
  (cd "$APP" && npm install --omit=dev --no-audit --no-fund) || bad "npm install نشد — ولی ادامه می‌دهیم."
fi

say "سرویس"
systemctl restart sltech || die "سرویس راه نیفتاد."
sleep 3
[ "$(systemctl is-active sltech)" = active ] || {
  journalctl -u sltech -n 25 --no-pager
  die "نسخهٔ قبلی هم بالا نیامد — یعنی ایراد از کد نیست."
}
ok "سرویس بالاست"

CODE=$(curl -s -o /dev/null -w '%{http_code}' -H 'Host: sltech.ir' "http://127.0.0.1:$PORT/")
[ "$CODE" = 200 ] && ok "صفحهٔ اصلی $CODE" || { bad "صفحهٔ اصلی $CODE داد"; journalctl -u sltech -n 20 --no-pager; }

node "$APP/server/index.js" --notify "↩️ SLTech به نسخهٔ $TARGET برگشت (از $NOW)" >/dev/null 2>&1

cat <<EOT

تمام. روی نسخهٔ $TARGET هستیم و شاخه رها شده است.

برای برگشت به آخرین نسخه، وقتی ایراد درست شد:
  git -C $APP checkout claude/dazzling-dirac-a5e75m && bash $APP/server/update.sh

EOT
