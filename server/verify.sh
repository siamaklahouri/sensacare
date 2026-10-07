#!/usr/bin/env bash
# چک کردنِ اینکه آن‌چه مستقر شده همان است که باید باشد.
#
# از بیرون نمی‌شود این را سنجید؛ از خودِ سرور می‌شود. هر خط یک «آره یا
# نه»ِ ساده است، نه یک حدس: صفحه‌ها را از همان سرویسی می‌گیرد که به
# کاربر جواب می‌دهد و داخلشان را می‌گردد.
set -u
APP=${APP:-/opt/sltech/app}
PORT=${PORT:-8787}
HOST=${HOST:-sltech.ir}
ok=0; bad=0; dunno=0
say(){ if [ "$1" = 1 ]; then echo "  ✅ $2"; ok=$((ok+1)); else echo "  ❌ $2"; bad=$((bad+1)); fi; }
# چیزی که نتوانستیم بپرسیم، «خراب» نیست. گفتنش بهتر از یک تیکِ قلابی
# یا یک ضربدرِ بی‌جاست.
hm(){ echo "  ❔ $1"; dunno=$((dunno+1)); }

echo "— کدی که روی سرور نشسته —"
cd "$APP" || { echo "پوشهٔ $APP نیست."; exit 1; }
git log --oneline -1
BR=$(git rev-parse --abbrev-ref HEAD)
echo "  شاخه: $BR"
if git fetch -q origin "$BR" 2>/dev/null; then
  BEHIND=$(git rev-list --count "HEAD..origin/$BR" 2>/dev/null || echo "?")
  case "$BEHIND" in
    0) say 1 "آخرین نسخه است" ;;
    ?*[0-9]*|[0-9]*) say 0 "$BEHIND کامیت عقب است — update.sh را دوباره بزنید" ;;
    *) hm "نتوانستم با گیت‌هاب مقایسه کنم" ;;
  esac
else
  hm "به گیت‌هاب نرسیدم، پس عقب‌افتادگی را نمی‌دانم"
fi

echo
echo "— سرویس —"
if command -v systemctl >/dev/null 2>&1 && systemctl list-units >/dev/null 2>&1; then
  systemctl is-active --quiet sltech && say 1 "سرویس sltech بالاست" || say 0 "سرویس sltech بالا نیست"
else
  hm "systemd این‌جا نیست، پس وضعیتِ سرویس را نپرسیدم"
fi

get(){ curl -s --max-time 20 -H "Host: $HOST" "http://127.0.0.1:$PORT$1"; }
has(){ echo "$2" | grep -qF "$1"; }

echo
echo "— پوستهٔ مشترک، در هر کارتابل —"
for slug in siamak sina reza; do
  P=$(get "/$slug/")
  n=$(printf '%s' "$P" | wc -c)
  if [ "$n" -lt 20000 ]; then say 0 "$slug: صفحه نیامد ($n بایت)"; continue; fi
  m=0
  has 'radius:14px' "$P" && m=$((m+1))
  has ':root:not([data-theme="dark"])' "$P" && m=$((m+1))
  has 'radial-gradient(1200px 500px at 100% -5%' "$P" && m=$((m+1))
  has 'border-radius:11px' "$P" && m=$((m+1))
  say "$([ $m = 4 ] && echo 1 || echo 0)" "$slug: پوستهٔ مشترک آمده ($m از ۴ نشانه)"
  has 'PART:' "$P" && say 0 "$slug: یک {{PART}} باز نشده مانده" || true
done

echo
echo "— بخش‌های تازه —"
S=$(get /siamak/)
has 'حجم vbk (GB)' "$S" && say 1 "ستونِ «حجم vbk» در سرورها" || say 0 "ستونِ «حجم vbk» نیامده"
has 'حجم vib (GB)' "$S" && say 1 "ستونِ «حجم vib» در سرورها"  || say 0 "ستونِ «حجم vib» نیامده"
has 'data-view="veeam"' "$S" && say 1 "بخشِ VeeamBackup در نوار" || say 0 "بخشِ VeeamBackup نیامده (تیکش را در «ویرایش» زده‌اید؟)"
has 'id="remoteBody"' "$S" && say 1 "چک‌لیست ریموت آمادهٔ کشیدنِ ردیف" || say 0 "چک‌لیست ریموت هنوز شناسه ندارد"
has 'data-rd="companyVisits"' "$S" && say 1 "شرکت‌ها آمادهٔ کشیدنِ ردیف" || say 0 "شرکت‌ها هنوز علامت ندارد"

for f in /viewshare.js /shared.js; do
  J=$(get "$f")
  echo "$J" | grep -q 'navAnchor' && say 1 "$f: جای تازهٔ بخش‌ها در نوار" || say 0 "$f: هنوز نسخهٔ قدیمی است"
done

echo
echo "— پنل —"
A=$(get /login)
has 'اشتراکِ بخشِ یک کارتابل با یک گروه' "$A" && say 1 "فرمِ اشتراکِ بخش در پنل" || say 0 "فرمِ اشتراکِ بخش نیامده"
has 'کلید Veeam' "$A" && say 1 "دکمهٔ کلید Veeam در پنل" || say 0 "دکمهٔ کلید Veeam نیامده"

echo
X=""
[ $dunno -gt 0 ] && X="  ($dunno مورد را نشد پرسید)"
if [ $bad = 0 ]; then echo "همه درست — $ok تا.$X"; else echo "$bad مورد درست نیست (از $((ok+bad))).$X"; fi
exit $([ $bad = 0 ] && echo 0 || echo 1)
