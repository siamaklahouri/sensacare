#!/usr/bin/env bash
# کدام بخش‌های هر کارتابل باز است — و اگر بسته شده، برگرداندنش.
#
# «بسته» یعنی فقط پنهان: دادهٔ همان بخش دست‌نخورده در دیتابیس می‌ماند و
# با باز کردنِ دوباره، همان‌طور که بود برمی‌گردد. این اسکریپت هم همین
# را نشان می‌دهد — هم فهرستِ بخش‌ها، هم اینکه چند ردیف داده پشتِ هر
# کدام هست — تا لازم نباشد کسی حدس بزند.
#
#   bash server/views.sh                 همهٔ کارتابل‌ها
#   bash server/views.sh siamak          یکی
#   bash server/views.sh siamak --open   و همهٔ بخش‌هایش را باز کن
set -u
DB=${DB_FILE:-/var/lib/sltech/sltech.db}
WHO=${1:-}
ACT=${2:-}
[ -f "$DB" ] || { echo "دیتابیس پیدا نشد: $DB"; exit 1; }

node -e '
const { DatabaseSync } = require("node:sqlite");
const db = new DatabaseSync(process.argv[1]);
const who = process.argv[2] || "";
const open = process.argv[3] === "--open";

/* همان فهرستی که سرور می‌شناسد. اگر روزی بخشی اضافه شد، این‌جا هم
   باید اضافه شود — ولی چون فقط برای نمایش و بازکردن است، نبودنِ یکی
   چیزی را خراب نمی‌کند. */
const VIEWS = {
  it: [["servers","سرورها و بکاپ"],["companies","شرکت‌ها"],["mvpn","سرویس MVPN"],
       ["datetools","تبدیل"],["report","گزارش‌ساز"],["veeam","VeeamBackup"]],
  fin: [["invoices","سررسید اسناد دریافتنی"],["payables","بدهی‌ها و پرداخت‌ها"],
        ["payablenotes","اسناد پرداختنی"],["receivablenotes","اسناد دریافتنی"],
        ["expenses","منابع و مصارف"],["bank","حساب‌های بانکی"],
        ["budget","بودجه‌بندی ماهانه"],["parties","طرف‌حساب‌ها"],
        ["datetools","تبدیل"],["report","گزارش‌ساز"]]
};
VIEWS.gen = VIEWS.it;

/* چند ردیف داده پشتِ هر بخش هست. فقط برای اینکه سیاه روی سفید معلوم
   باشد بستنِ یک بخش، داده‌اش را نبرده. */
const COUNT = {
  mvpn:      d => (d.lines || []).length,
  servers:   d => (d.vm || []).length,
  companies: d => Object.values(d.companies || {}).reduce((n,v)=> n + (v||[]).length, 0)
};

const rows = db.prepare("SELECT slug,name,kind,cfg FROM planners ORDER BY slug").all();
let any = false;
for (const r of rows) {
  if (who && r.slug !== who) continue;
  any = true;
  let cfg = {}; try { cfg = JSON.parse(r.cfg || "{}"); } catch (e) {}
  const kind = r.kind === "it" ? "it" : r.kind === "fin" ? "fin" : "gen";
  const all = VIEWS[kind] || [];
  const explicit = Array.isArray(cfg.views);
  const on = new Set(explicit ? cfg.views : all.map(v => v[0]));

  /* دادهٔ خودِ کارتابل در جدولِ kartabl نشسته، با کلیدِ «<slug>:db» —
     مگر کارتابلِ سیامک که از روزِ اول «db» خالی بوده و همان مانده. */
  let data = {};
  for (const key of [r.slug + ":db", "db"]) {
    try {
      const d = db.prepare("SELECT v FROM kartabl WHERE k=?").get(key);
      if (d && d.v) { data = JSON.parse(d.v) || {}; break; }
    } catch (e) { /* خوانده نشد؛ بعدی */ }
  }

  console.log("\n" + r.slug + "  (" + (r.name || "—") + ", " + kind + ")");
  console.log("  فهرستِ بخش‌ها: " + (explicit
    ? "صریح — هرچه این‌جا نباشد بسته است"
    : "تعیین نشده — یعنی همه باز است"));
  for (const [id, label] of all) {
    const n = COUNT[id] ? COUNT[id](data) : null;
    console.log("   " + (on.has(id) ? "✅" : "⛔") + " " + label.padEnd(22) +
      (n === null ? "" : "  (" + n + " ردیف داده" + (on.has(id) ? "" : " — سرِ جایش") + ")"));
  }
  const shut = all.filter(v => !on.has(v[0]));
  if (shut.length && !open)
    console.log("  برای باز کردنشان:  bash server/views.sh " + r.slug + " --open");

  if (open && who === r.slug) {
    cfg.views = all.map(v => v[0]);
    db.prepare("UPDATE planners SET cfg=? WHERE slug=?").run(JSON.stringify(cfg), r.slug);
    console.log("  ← همهٔ بخش‌ها باز شد. یک بار سرویس را ریستارت کنید یا صفحه را تازه کنید.");
  }
}
if (!any) console.log("کارتابلی با این نام نیست: " + who);
' "$DB" "$WHO" "$ACT"
