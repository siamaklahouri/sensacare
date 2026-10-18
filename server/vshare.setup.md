# راه‌اندازیِ آزمونِ بخش‌های اشتراکی

`vshare.test.mjs` خودش کار می‌کند (`node server/vshare.test.mjs`) و به
هیچ سروری کار ندارد.

`vshare-ui.test.mjs` به یک سرورِ واقعیِ محلی نیاز دارد، چون همان چیزی
را می‌آزماید که کاربر می‌بیند: صفحه، نوارِ کنار، و اینکه نوشتن واقعاً
در دادهٔ کارتابلِ صاحبِ بخش می‌نشیند.

```sh
D=/tmp/vs; rm -rf $D; mkdir -p $D
cat > $D/env <<EOT
PORT=8911
BIND=127.0.0.1
DB_FILE=$D/t.db
ADMIN_USER=admin
ADMIN_PASS=adminadminadmin
JWT_SECRET=testsecrettestsecrettestsecret12
PANEL_HOST=sltech.ir
# «بله»ی قلابیِ آزمونِ ارسالِ مشخصات. بی این خط، sendcreds سراغِ
# بلهٔ واقعی می‌رود و — به‌درستی — می‌افتد.
BALE_BASE=http://127.0.0.1:8913
EOT

# جدول‌ها
node -e "
const {DatabaseSync}=require('node:sqlite'), fs=require('fs');
const db=new DatabaseSync('$D/t.db');
for(const f of ['schema.sql','migrations.sql']) db.exec(fs.readFileSync(f,'utf8'));
"

# رمزِ ادمین مستقیم در settings (راه‌اندازیِ معمولی کدِ تلگرامی می‌خواهد)
node --input-type=module -e "
import { hashPassword } from './src/pass.js';
import { DatabaseSync } from 'node:sqlite';
const db = new DatabaseSync('$D/t.db');
const put = (k,v)=> db.prepare('INSERT INTO settings(k,v) VALUES(?,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v').run(k, JSON.stringify(v));
put('adminPlanerUser','admin');
put('adminPlanerPassHash', await hashPassword('adminadminadmin'));
put('adminPlanerPassGen', 1);
"

(set -a; . $D/env; set +a; node server/index.js > $D/log 2>&1 &)
```

بعد، با `curl` و کوکیِ ادمین: یک گروه بسازید که `sina` عضوش باشد،
«سرورها و بکاپ»ِ `siamak` را با دسترسیِ نوشتن و «چک‌لیست ماهانه»‌اش را
فقط‌خواندنی به آن گروه بدهید، رمزِ `sina` را بگذارید، و در جدولِ
`kartabl` برای کلیدِ `db` چند سرورِ نمونه بنویسید. آزمون انتظار دارد
`sina` همین دو بخش را ببیند.

ترتیبِ بخش‌ها در نوار مهم است و آزمون می‌سنجدش: اول بخش‌های خودِ
کاربر، بعد سرفصلِ گروه، بعد بخش‌های اشتراکی.

---

## اجرای همهٔ آزمون‌ها

```sh
DB_FILE=$D/t.db bash server/run-tests.sh
```

سقفِ تعدادِ ورودِ سمتِ سرور یک اجرای پشتِ سر هم را با ۴۲۹ می‌خواباند.
آن سقف برای کاربرِ واقعی درست است و دست نمی‌خورد؛ این اسکریپت فقط پیش
از شروع پاکش می‌کند. برای همین `DB_FILE` می‌خواهد.

هر آزمون رمزِ کارتابلی را که لازم دارد خودش می‌گذارد، پس ترتیبشان مهم
نیست و هرکدام تنها هم اجرا می‌شود.

---

## همان راه‌اندازی، این بار کوتاه

اگر محفظه از نو ساخته شده و همه‌چیز از صفر لازم است، بعد از ساختنِ
جدول‌ها و رمزِ ادمین (بالا) این‌ها فیکسچرِ موردِ نیازِ همهٔ آزمون‌ها را
می‌سازند. `theme.test.mjs` یک کارتابلِ «عمومی» می‌خواهد و
`vshare-ui.test.mjs` یک گروه، دو اشتراک و سه سرور:

```sh
B=http://127.0.0.1:8911; A=$B/api/admin.planer
C=$(curl -s -i -X POST $A/signin -H 'Content-Type: application/json' \
      -d '{"user":"admin","password":"adminadminadmin"}' \
    | grep -i '^set-cookie' | sed 's/^[Ss]et-[Cc]ookie: //' | cut -d';' -f1 | paste -sd'; ')
j(){ curl -s -H 'Content-Type: application/json' -H "cookie: $C" "$@"; }

# کارتابلِ عمومی
j -X POST $A/planners -d '{"name":"علی","slug":"ali","kind":"gen","password":"alialialiali"}'

# گروه، و دو بخشِ سیامک که با آن گروه به اشتراک می‌رود
j -X POST $A/orgs -d '{"name":"گروه آزمون","members":["siamak","sina"]}'
ORG=$(j $A/orgs | python3 -c 'import sys,json; print(json.load(sys.stdin)["items"][0]["id"])')
j -X POST $A/view-shares -d "{\"owner\":\"siamak\",\"view\":\"servers\",\"org\":\"$ORG\",\"w\":true}"
j -X POST $A/view-shares -d "{\"owner\":\"siamak\",\"view\":\"checklist\",\"org\":\"$ORG\",\"w\":false}"
```

و سه سرورِ نمونه در دادهٔ سیامک (آزمون انتظار دارد `srv-a` تا `srv-c`
باشند):

```sh
node -e '
const {DatabaseSync}=require("node:sqlite");
const db=new DatabaseSync(process.env.DB_FILE);
const vm=[["srv-a","10.0.0.11",120,12],["srv-b","10.0.0.12",240,20],["srv-c","10.0.0.13",80,8]]
  .map(([server,location,sizeUsed,sizeVib])=>({ server, location, sizeUsed, sizeVib,
      schedule:"هر شب", lastRestore:"۱۴۰۵/۰۶/۰۱", lastFullBackup:"۱۴۰۵/۰۷/۰۱", storage:"NAS" }));
const cur=db.prepare("SELECT v FROM kartabl WHERE k=?").get("db");
const obj=cur&&cur.v?JSON.parse(cur.v):{}; obj.vm=vm;
db.prepare("INSERT INTO kartabl(k,v,rev,updated) VALUES(?,?,1,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v, rev=kartabl.rev+1, updated=excluded.updated")
  .run("db", JSON.stringify(obj), Date.now());
'
```

نکتهٔ خاموش‌کردنِ سرورِ محلی: `pkill -f "node server/index.js"` خطِ فرمانِ
خودِ پوسته را هم می‌گیرد و وسطِ کار می‌کُشدش. الگو را لنگر بزنید:
`pgrep -f '^node server/index\.js$'`.
