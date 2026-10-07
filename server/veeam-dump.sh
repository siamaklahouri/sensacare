#!/usr/bin/env bash
# چه چیزی از Veeam روی سرور ذخیره شده — بی‌واسطه، از خودِ دیتابیس.
#
# وقتی جدولِ کارتابل خالی است، دو حالت دارد: یا اسکریپت چیزی نفرستاده،
# یا فرستاده و صفحه نشانش نمی‌دهد. این‌جا معلوم می‌شود کدام — بی‌آنکه
# لازم باشد کسی حدس بزند.
set -u
DB=${DB_FILE:-/var/lib/sltech/sltech.db}
SLUG=${SLUG:-siamak}
[ -f "$DB" ] || { echo "دیتابیس پیدا نشد: $DB"; exit 1; }

node -e '
const { DatabaseSync } = require("node:sqlite");
const db = new DatabaseSync(process.argv[1]);
const row = db.prepare("SELECT v FROM settings WHERE k=?").get("veeam:" + process.argv[2]);
if (!row) { console.log("هیچ گزارشی ذخیره نشده (کلیدِ veeam:" + process.argv[2] + " نیست)."); process.exit(0); }
let r; try { r = JSON.parse(row.v); } catch (e) { console.log("ذخیره شده ولی خوانده نشد:", String(e)); process.exit(0); }

const age = r.at ? Math.round((Date.now() - r.at) / 60000) : null;
console.log("زمانِ گزارش : " + (r.at ? new Date(r.at).toLocaleString("fa-IR") + "  (" + age + " دقیقه پیش)" : "—"));
console.log("سرورِ Veeam : " + (r.host || "—"));
console.log("فرستنده     : " + (r.agent || "—"));
console.log("خطا         : " + (r.error || "—"));
console.log("");
const n = a => Array.isArray(a) ? a.length : 0;
console.log("جاب‌ها   : " + n(r.jobs));
console.log("مخزن‌ها  : " + n(r.repos));
console.log("اجراها   : " + n(r.sessions));
console.log("");
if (n(r.jobs)) {
  console.log("سه جابِ اول، همان‌طور که ذخیره شده‌اند:");
  for (const j of r.jobs.slice(0, 3)) console.log("  " + JSON.stringify(j));
  const blank = r.jobs.filter(j => !j.result).length;
  if (blank) console.log("\n  ⚠ " + blank + " جاب ستونِ «نتیجه» خالی دارد.");
} else {
  console.log("⚠ فهرستِ جاب‌ها خالی است — پس صفحه هم خالی نشان می‌دهد.");
  console.log("  یعنی آخرین باری که اسکریپت فرستاد، هیچ جابی داخلش نبود.");
}
if (n(r.sessions)) {
  /* نامِ اجراها لازم است: وقتی ستونِ نتیجه خالی می‌ماند، معمولاً به این
     دلیل است که Veeam نامِ اجرا را با پسوندِ نوعِ بکاپ می‌سازد و به نامِ
     جاب نمی‌خورد. این‌جا هر دو کنار هم دیده می‌شوند. */
  console.log("\nسه اجرای اول:");
  for (const x of r.sessions.slice(0, 3)) console.log("  " + JSON.stringify(x));
  const names = [...new Set(r.sessions.map(x => x.name).filter(Boolean))];
  const jnames = new Set((r.jobs || []).map(j => j.name));
  const orphan = names.filter(x => !jnames.has(x));
  if (orphan.length) {
    console.log("\n  نامِ اجراهایی که عیناً با هیچ جابی یکی نیستند:");
    for (const x of orphan.slice(0, 5)) console.log("    " + x);
  }
}
' "$DB" "$SLUG"
