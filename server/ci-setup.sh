#!/usr/bin/env bash
# سرورِ آزمون را از صفر بالا می‌آورد — همان کاری که در
# server/vshare.setup.md دستی نوشته شده بود، یک‌جا و بی‌دست.
# گیت‌هاب‌اکشن از همین استفاده می‌کند، و روی هر ماشینِ دیگری هم کار
# می‌کند:
#
#   bash server/ci-setup.sh /tmp/vs 8911
#
# چیزی که می‌سازد: یک دیتابیسِ خالی با جدول‌ها، رمزِ ادمین، دو
# کارتابلِ آزمون، و سرویسی که روی همان پورت جواب می‌دهد.
set -u
D="${1:-/tmp/vs}"
PORT="${2:-8911}"
APP="$(cd "$(dirname "$0")/.." && pwd)"

rm -rf "$D"; mkdir -p "$D"
cat > "$D/env" <<EOT
PORT=$PORT
BIND=127.0.0.1
DB_FILE=$D/t.db
ADMIN_USER=admin
ADMIN_PASS=adminadminadmin
JWT_SECRET=testsecrettestsecrettestsecret12
PANEL_HOST=sltech.ir
SHOP_HOST=sensacare.ir
PUSH_OFF=1
BALE_BASE=http://127.0.0.1:8913
EOT

cd "$APP"
node -e "
const {DatabaseSync}=require('node:sqlite'), fs=require('fs');
const db=new DatabaseSync(process.argv[1]);
for(const f of ['schema.sql','migrations.sql']) db.exec(fs.readFileSync(f,'utf8'));
" "$D/t.db"

node --input-type=module -e "
import { hashPassword } from './src/pass.js';
import { DatabaseSync } from 'node:sqlite';
const db = new DatabaseSync(process.argv[1]);
const put = (k,v)=> db.prepare('INSERT INTO settings(k,v) VALUES(?,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v').run(k, JSON.stringify(v));
put('adminPlanerUser','admin');
put('adminPlanerPassHash', await hashPassword('adminadminadmin'));
put('adminPlanerPassGen', 1);
" "$D/t.db"

(set -a; . "$D/env"; set +a; nohup node server/index.js > "$D/log" 2>&1 &)

for i in $(seq 1 60); do
  code=$(curl -s -o /dev/null --max-time 2 -w '%{http_code}' "http://127.0.0.1:$PORT/login" 2>/dev/null)
  [ "$code" = "200" ] && { echo "سرورِ آزمون بالا آمد روی $PORT"; break; }
  sleep 0.5
done
[ "${code:-}" = "200" ] || { echo "بالا نیامد:"; tail -20 "$D/log"; exit 1; }

# کارتابل‌های آزمون. اسکریپت بار دوم هم باید کار کند، پس «از قبل هست»
# خطا نیست.
mk(){
  curl -s -c "$D/ck" -X POST "http://127.0.0.1:$PORT/api/admin.planer/signin" \
    -H 'Content-Type: application/json' \
    -d '{"user":"admin","password":"adminadminadmin"}' >/dev/null
  curl -s -b "$D/ck" -X POST "http://127.0.0.1:$PORT/api/admin.planer/planners" \
    -H 'Content-Type: application/json' -d "$1" >/dev/null
}
mk '{"slug":"siamak","name":"سیامک","kind":"it","user":"siamak"}'
mk '{"slug":"sina","name":"سینا","kind":"fin","user":"sina"}'
curl -s -b "$D/ck" -X POST "http://127.0.0.1:$PORT/api/admin.planer/planners/siamak/password" \
  -H 'Content-Type: application/json' -d '{"password":"siamaksiamak"}' >/dev/null
curl -s -b "$D/ck" -X POST "http://127.0.0.1:$PORT/api/admin.planer/planners/sina/password" \
  -H 'Content-Type: application/json' -d '{"password":"sinasinasina"}' >/dev/null
echo "کارتابل‌های آزمون آماده‌اند."
