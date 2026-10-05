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
