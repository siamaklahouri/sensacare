#!/usr/bin/env bash
# آخرین ورودِ هر کارتابل — همان عددی که پنلِ ادمین نشان می‌دهد، ولی
# این‌بار از خودِ دیتابیس و با تاریخِ خوانا.
#
#   bash server/logins.sh
#   DB_FILE=/path/to/other.db bash server/logins.sh
#
# فقط می‌خواند؛ چیزی نمی‌نویسد.
set -u
DB="${DB_FILE:-/var/lib/sltech/sltech.db}"
[ -f "$DB" ] || { echo "دیتابیس پیدا نشد: $DB"; exit 1; }

node --no-warnings --input-type=module -e '
import { DatabaseSync } from "node:sqlite";
const db = new DatabaseSync(process.argv[1]);
const TZ = "Asia/Tehran";
const fa = ms => {
  const d = new Date(Number(ms));
  const day = new Intl.DateTimeFormat("fa-IR-u-ca-persian",
    { year:"numeric", month:"long", day:"numeric", timeZone:TZ }).format(d);
  const hm = new Intl.DateTimeFormat("fa-IR",
    { hour:"2-digit", minute:"2-digit", hourCycle:"h23", timeZone:TZ }).format(d);
  return day + " — " + hm;
};
const fd = n => String(n).replace(/[0-9]/g, d => "\u06F0\u06F1\u06F2\u06F3\u06F4\u06F5\u06F6\u06F7\u06F8\u06F9"[+d]);
const ago = ms => {
  const s = Math.round((Date.now() - Number(ms)) / 1000);
  if (s < 0) return "در آینده!";
  if (s < 3600) return fd(Math.round(s/60)) + " دقیقه پیش";
  if (s < 86400) return fd(Math.round(s/3600)) + " ساعت پیش";
  return fd(Math.round(s/86400)) + " روز پیش";
};
const get = k => { try {
  const r = db.prepare("SELECT v FROM settings WHERE k=?").get(k);
  if (!r) return null;
  try { return JSON.parse(r.v); } catch (e) { return r.v; }
} catch (e) { return null; } };

/* کارتابل‌های داخلِ جدول، به‌علاوهٔ هر کلیدِ login: که در تنظیمات هست —
   تا کارتابل‌های داخلِ کد (siamak و…) هم بیفتند. */
const rows = db.prepare("SELECT slug, name, created FROM planners ORDER BY created, slug").all();
const keys = db.prepare("SELECT k FROM settings WHERE k LIKE ?").all("login:%").map(r=>r.k);
const slugs = [...new Set(rows.map(r=>r.slug).concat(keys.map(k=>k.slice(6))))];
const nameOf = {}; for (const r of rows) nameOf[r.slug] = r.name;

console.log("");
console.log("کارتابل".padEnd(14), "آخرین ورود با رمز".padEnd(30),
            "آخرین استفاده".padEnd(26), "نام");
console.log("-".repeat(96));
let bad = 0;
for (const s of slugs) {
  const v = get("login:" + s), sv = get("seen:" + s);
  const nm = (nameOf[s] || (s === "admin.planer" ? "پنلِ ادمین" : "—"));
  const cell = x => {
    if (x === null || x === 0 || x === "") return "—";
    const n = Number(x);
    if (!(Number.isFinite(n) && n > 1600000000000 && n < Date.now() + 60000)) {
      bad++; return "مشکوک: " + JSON.stringify(x);
    }
    return fa(n) + "  (" + ago(n) + ")";
  };
  console.log(s.padEnd(14), cell(v).padEnd(30), cell(sv).padEnd(26), nm);
}
console.log("");
console.log("نکته: «ورود با رمز» لحظهٔ زدنِ رمز است؛ کسی که وارد مانده تا وقتی");
console.log("      دوباره رمز نزند آن تاریخ برایش عوض نمی‌شود. «آخرین استفاده»");
console.log("      هر بار که کارتابل واقعاً کاری می‌کند تازه می‌شود (حداکثر هر");
console.log("      پنج دقیقه یک‌بار نوشته می‌شود، و خبرگیرهای پس‌زمینه حساب نیستند).");
if (bad) { console.log(""); console.log("‼ " + bad + " مقدارِ غیرعادی پیدا شد."); }
console.log("");
/* ساعتِ خودِ سرور هم کنارش، چون اگر ساعتِ سرور عقب باشد همهٔ این
   تاریخ‌ها عقب‌اند و ایراد از این‌جا نیست. */
console.log("ساعتِ همین سرور:", fa(Date.now()), " (UTC: " + new Date().toISOString() + ")");
' "$DB"
