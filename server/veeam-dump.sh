#!/usr/bin/env bash
# چه چیزی از Veeam روی سرور ذخیره شده — بی‌واسطه، از خودِ دیتابیس.
#
# وقتی جدولِ کارتابل چیزی می‌گوید که با کنسولِ Veeam نمی‌خواند، حدس زدن
# بی‌فایده است: این‌جا هر جاب و هر اجرا همان‌طور که ذخیره شده چاپ
# می‌شود، و زیرش نشان داده می‌شود که نتیجهٔ هر جاب از کدام اجرا درآمده.
set -u
DB=${DB_FILE:-/var/lib/sltech/sltech.db}
SLUG=${SLUG:-siamak}
[ -f "$DB" ] || { echo "دیتابیس پیدا نشد: $DB"; exit 1; }

APP=$(cd "$(dirname "$0")/.." && pwd)
node --input-type=module -e '
const { DatabaseSync } = await import("node:sqlite");
/* همان قاعده‌ای که صفحه می‌بیند — وگرنه این خروجی و آن جدول دو چیزِ
   متفاوت می‌گفتند و همین، نیمِ روز را می‌برد. */
const { withSessionResults } = await import(process.argv[3] + "/src/veeam.js");
const db = new DatabaseSync(process.argv[1]);
const row = db.prepare("SELECT v FROM settings WHERE k=?").get("veeam:" + process.argv[2]);
if (!row) { console.log("هیچ گزارشی ذخیره نشده (کلیدِ veeam:" + process.argv[2] + " نیست)."); process.exit(0); }
let r; try { r = JSON.parse(row.v); } catch (e) { console.log("ذخیره شده ولی خوانده نشد:", String(e)); process.exit(0); }

if (Array.isArray(r.jobs)) r.jobs = withSessionResults(r.jobs, r.sessions || []);

const age = r.at ? Math.round((Date.now() - r.at) / 60000) : null;
const gap = (r.at && r.prev) ? Math.round((r.at - r.prev) / 60000) : null;
console.log("زمانِ گزارش : " + (r.at ? new Date(r.at).toLocaleString("fa-IR") + "  (" + age + " دقیقه پیش)" : "—"));
console.log("فاصلهٔ ارسال: " + (gap ? gap + " دقیقه" : "— (هنوز فقط یک گزارش رسیده)"));
console.log("سرورِ Veeam : " + (r.host || "—"));
console.log("فرستنده     : " + (r.agent || "—"));
console.log("خطا         : " + (r.error || "—"));

const n = a => Array.isArray(a) ? a.length : 0;
console.log("\nجاب‌ها " + n(r.jobs) + "  •  مخزن‌ها " + n(r.repos) + "  •  اجراها " + n(r.sessions));

const pad = (s, w) => { s = String(s === undefined || s === null ? "" : s); 
  return s.length >= w ? s.slice(0, w) : s + " ".repeat(w - s.length); };

if (n(r.jobs)) {
  console.log("\n— جاب‌ها —");
  console.log("  " + pad("نام", 28) + pad("نتیجه", 10) + pad("وضعیت", 10) +
              pad("آخرین اجرا", 18) + pad("ماشین", 7) + pad("دامنه", 7) + "از اجرای");
  for (const j of r.jobs) {
    console.log("  " + pad(j.name, 28) + pad(j.result || "—", 10) + pad(j.state || "—", 10) +
      pad(j.last || "—", 18) + pad(n(j.vms), 7) + pad(n(j.scope), 7) + (j.via || "—"));
  }
  for (const j of r.jobs) {
    if (n(j.vms)) console.log("    ماشین‌های «" + j.name + "»: " + j.vms.join(", "));
    if (n(j.scope)) console.log("    دامنهٔ «" + j.name + "»: " + j.scope.join(", "));
    if (j.message) console.log("    پیامِ «" + j.name + "»: " + String(j.message).replace(/\s+/g, " ").slice(0, 160));
  }
} else {
  console.log("\n⚠ فهرستِ جاب‌ها خالی است — پس صفحه هم خالی نشان می‌دهد.");
}

if (n(r.sessions)) {
  console.log("\n— اجراها (به همان ترتیبی که رسیده‌اند) —");
  console.log("  " + pad("نام", 34) + pad("نتیجه", 10) + pad("وضعیت", 10) +
              pad("شروع", 18) + "پایان");
  for (const x of r.sessions) {
    console.log("  " + pad(x.name, 34) + pad(x.result || "—", 10) + pad(x.state || "—", 10) +
      pad(x.start || "—", 18) + (x.end || "—"));
  }
  /* همین‌جا معلوم می‌شود که نتیجهٔ هر جاب از کجا آمده: اگر جابی نتیجهٔ
     اجرای جابِ دیگری را پوشیده باشد، در همین دو ستون دیده می‌شود. */
  const jn = new Set((r.jobs || []).map(j => j.name));
  const orphan = [...new Set(r.sessions.map(x => x.name).filter(x => x && !jn.has(x)))];
  if (orphan.length) {
    console.log("\n  نامِ اجراهایی که عیناً با هیچ جابی یکی نیستند:");
    for (const x of orphan) console.log("    " + x);
  }
}
' "$DB" "$SLUG" "$APP"
