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

# ---------- بخش‌های اشتراکی ----------
# vshare-ui.test.mjs یک گروه، دو اشتراک و سه سرورِ نمونه می‌خواهد.
# این تکه در vshare.setup.md دستی نوشته شده بود و این‌جا جا مانده
# بود — نتیجه‌اش این شد که آن آزمون روی هر ماشینی جز لپ‌تاپِ کسی که
# یک بار دستی راهش انداخته بود قرمز می‌شد، و روی CI هم همین‌طور.
j(){ curl -s -b "$D/ck" -H 'Content-Type: application/json' "$@"; }
API="http://127.0.0.1:$PORT/api/admin.planer"

j -X POST "$API/orgs" -d '{"name":"گروه آزمون","members":["siamak","sina"]}' >/dev/null
ORG=$(j "$API/orgs" | node -e "
let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{
  try{ const j=JSON.parse(s); process.stdout.write(String((j.items&&j.items[0]&&j.items[0].id)||'')); }
  catch(e){ process.stdout.write(''); }});")
if [ -n "$ORG" ]; then
  j -X POST "$API/view-shares" -d "{\"owner\":\"siamak\",\"view\":\"servers\",\"org\":\"$ORG\",\"w\":true}"  >/dev/null
  j -X POST "$API/view-shares" -d "{\"owner\":\"siamak\",\"view\":\"checklist\",\"org\":\"$ORG\",\"w\":false}" >/dev/null
  echo "گروه و دو بخشِ اشتراکی ساخته شد."
else
  echo "⚠️  شناسهٔ گروه خوانده نشد — آزمونِ بخش‌های اشتراکی خواهد افتاد."
fi

# سه سرورِ نمونه در دادهٔ سیامک. آزمون انتظارِ srv-a تا srv-c دارد.
node -e '
const {DatabaseSync}=require("node:sqlite");
const db=new DatabaseSync(process.argv[1]);
const vm=[["srv-a","10.0.0.11",120,12],["srv-b","10.0.0.12",240,20],["srv-c","10.0.0.13",80,8]]
  .map(([server,location,sizeUsed,sizeVib])=>({ server, location, sizeUsed, sizeVib,
      schedule:"هر شب", lastRestore:"۱۴۰۵/۰۶/۰۱", lastFullBackup:"۱۴۰۵/۰۷/۰۱", storage:"NAS" }));
const cur=db.prepare("SELECT v FROM kartabl WHERE k=?").get("db");
const obj=cur&&cur.v?JSON.parse(cur.v):{}; obj.vm=vm;
db.prepare("INSERT INTO kartabl(k,v,rev,updated) VALUES(?,?,1,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v, rev=kartabl.rev+1, updated=excluded.updated")
  .run("db", JSON.stringify(obj), Date.now());
' "$D/t.db"


# ---------- دادهٔ پایه ----------
# چند آزمون به داده‌ای تکیه می‌کنند که هیچ‌جا در کد نبود و فقط روی
# دیتابیسِ لپ‌تاپِ کسی که یک بار دستی ساخته بودش وجود داشت:
# چک‌لیستِ ریموت (aria)، شرکت‌ها و یادداشتِ بازدید (rownote). نتیجه‌اش
# این شد که CI ماه‌ها قرمز بود و محلی سبز — و قرمزِ همیشگی یعنی کسی
# دیگر نگاهش نمی‌کند.
node -e '
const {DatabaseSync}=require("node:sqlite");
const db=new DatabaseSync(process.argv[1]);
const get=k=>{ const r=db.prepare("SELECT v FROM kartabl WHERE k=?").get(k); return r&&r.v?JSON.parse(r.v):{}; };
const put=(k,o)=> db.prepare("INSERT INTO kartabl(k,v,rev,updated) VALUES(?,?,1,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v, rev=kartabl.rev+1, updated=excluded.updated")
  .run(k, JSON.stringify(o), Date.now());

const st=get("state");
/* پانزده ستونِ تقویمِ بررسیِ ریموت. خالی‌اند، همان‌طور که در کارتابلِ
   واقعی هم تا وقتی کسی تاریخ نگذاشته خالی‌اند؛ خانه‌های جدول از
   همین تعداد ساخته می‌شوند. */
if(!Array.isArray(st.remoteCheckDates) || !st.remoteCheckDates.length)
  st.remoteCheckDates = Array.from({length:15}, ()=> "");
if(!st.remoteChecks || typeof st.remoteChecks!=="object") st.remoteChecks={};
put("state", st);

const d=get("db");
if(!Array.isArray(d.roster) || !d.roster.length)
  d.roster = [{server:"srv-ا"},{server:"srv-ب"},{server:"srv-ج"}];
/* یک شرکت با سه بازدید، که یکی‌شان یادداشت دارد: rownote هم وجودِ
   مداد را می‌سنجد و هم حالتِ «یادداشت دارد» را. */
if(!d.companies || !Object.keys(d.companies).length)
  d.companies = { "احیا": [
    {dateStr:"۱۴۰۴.۰۱.۰۱", time:"۱۰m", type:"onsite"},
    {dateStr:"۱۴۰۴.۰۲.۰۲", time:"۲۰m", type:"remote"},
    {dateStr:"۱۴۰۴.۰۳.۰۳", time:"۳۰m", type:"onsite", note:"سوییچِ طبقهٔ دوم عوض شد."}
  ] };
put("db", d);
' "$D/t.db"
echo "دادهٔ پایه نشست: چک‌لیستِ ریموت، شرکت‌ها."

echo "کارتابل‌های آزمون آماده‌اند." 
