#!/usr/bin/env bash
# ساختِ همهٔ نشانه‌های برنامه از یک منبع: art/sl-glyph.png
#
# چرا اسکریپت و نه فایل‌های دستی: نشانه‌ها پنج‌تا هستند و هر کدام
# اندازه و حاشیهٔ خودش را دارد. یک بار که دستی ساخته شوند، دفعهٔ بعد
# هیچ‌کس یادش نیست کدام چند درصد بود. این‌جا نوشته است.
#
# اجرا:  bash art/make-icons.sh
set -euo pipefail
cd "$(dirname "$0")/.."

G=art/sl-glyph.png
OUT=public
M=1024                       # بوم مادر؛ همه‌چیز از این کوچک می‌شود

CENTER='#3A4A6A'             # مرکزِ پس‌زمینه
EDGE='#131B2B'               # لبهٔ پس‌زمینه

[ -f "$G" ] || { echo "منبع نیست: $G"; exit 1; }

# نسبتِ عرضِ لوگو به عرضِ بوم.
#
# «۵۰٪» برای maskable عددِ دلبخواه نیست. اندروید از یک نشانهٔ تطبیقی
# فقط مرکزِ ۷۲ از ۱۰۸ را نشان می‌دهد و منطقه‌ای که تضمین می‌کند هیچ
# ماسکی نمی‌بُرَدش دایرهٔ ۶۶ از ۱۰۸ است — یعنی ۶۱٪ بوم. قطرِ این لوگو
# ۱.۲۱ برابرِ عرضش است، پس عرضِ امنش ۶۱٪ ÷ ۱.۲۱ ≈ ۵۰٪.
#
# نشانهٔ قبلی ۶۵٪ بود و درست همین‌جا می‌شکست: روی گوشی دو سرِ لوگو
# بریده می‌شد. این‌که فایل ۵۱۲ در ۵۱۲ سالم است هیچ ربطی ندارد؛ آن‌چه
# دیده می‌شود مرکزش است.
#
# نشانهٔ گردِ معمولی ماسک نمی‌خورد، پس آن‌جا ۷۲٪ جا دارد — و در
# ۶۴ پیکسلِ favicon که ریزه‌کاری دیده نمی‌شود، ۷۴٪.

# نشانهٔ تک‌رنگ (purpose: monochrome) عمداً ساخته نمی‌شود. اندروید آن
# را تخت و یک‌رنگ می‌کند و از این لوگو یک لکه درمی‌آید: حفرهٔ S با
# آبیِ خودِ لوگو پر است، پس قالبش دیگر «SL» خوانده نمی‌شود. امتحان شد.
# نشانهٔ تک‌رنگِ درست یعنی طراحیِ یک مارکِ ساده‌شده — کارِ این اسکریپت نیست.

grad () { # $1=out  — پس‌زمینهٔ شیب‌دار به اندازهٔ بوم
  convert -size ${M}x${M} radial-gradient:"$CENTER"-"$EDGE" "$1"
}

place () { # $1=bg  $2=frac  $3=out — لوگو را وسطِ پس‌زمینه می‌نشاند
  local gw=$(awk "BEGIN{printf \"%d\", $M*$2}")
  convert "$1" \
    \( "$G" -resize ${gw}x -alpha extract -blur 0x14 -level 0%,70% \
       -background '#9EC4FF' -alpha shape -channel A -evaluate multiply 0.38 +channel \) \
    -gravity center -composite \
    \( "$G" -resize ${gw}x \) -gravity center -composite "$3"
}

round () { # $1=in $2=out — بریدن به دایره + لبهٔ نازکِ روشن
  convert "$1" \
    \( -size ${M}x${M} xc:none -fill white -draw "circle $((M/2)),$((M/2)) $((M/2)),2" \) \
    -alpha set -compose DstIn -composite \
    -fill none -stroke 'rgba(255,255,255,0.13)' -strokewidth 5 \
    -draw "circle $((M/2)),$((M/2)) $((M/2)),5" "$2"
}

say () { printf '  %-26s %s\n' "$1" "$2"; }

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

grad "$tmp/bg.png"

# ۱) نشانهٔ گرد — داخلِ صفحه‌ها، مانیفست (any)، و نشانهٔ ۱۹۲
place "$tmp/bg.png" 0.72 "$tmp/sq.png"
round "$tmp/sq.png" "$tmp/round.png"
convert "$tmp/round.png" -resize 512x512 -strip PNG32:$OUT/icon-sl.4.png
convert "$tmp/round.png" -resize 192x192 -strip PNG32:$OUT/app-icon-192.2.png

# ۲) favicon — در ۶۴ پیکسل ریزه‌کاری دیده نمی‌شود، پس لوگو بزرگ‌تر
place "$tmp/bg.png" 0.74 "$tmp/sqf.png"
round "$tmp/sqf.png" "$tmp/roundf.png"
convert "$tmp/roundf.png" -resize 64x64 -unsharp 0x0.6+0.7+0.02 -strip PNG32:$OUT/favicon-sl.4.png

# ۳) maskable — مربعِ توپر تا هر ماسکی پُر دربیاید، لوگو در منطقهٔ امن
place "$tmp/bg.png" 0.50 "$tmp/mask.png"
# این یکی عمداً PNG24 می‌ماند و پالت نمی‌شود. تنها فایلی است که از
# دستِ bubblewrap و خودِ اندروید رد می‌شود، و سرویس‌ورکر هم دیگر
# پیش‌دریافتش نمی‌کند — پس پنجاه کیلوبایتی که با پالت صرفه‌جویی
# می‌شد، روی یک بار دانلود در تمامِ عمرِ نصب است. نمی‌ارزد.
convert "$tmp/mask.png" -alpha remove -alpha off -resize 512x512 \
  -strip PNG24:$OUT/app-icon-mask.2.png

# ۴) آیفون — iOS خودش گوشه را گرد می‌کند و شفافیت را سیاه می‌کند.
#    این یکی شفافیت ندارد، پس پالت‌کردنش بی‌خطر است و نصفِ حجم می‌شود.
#    نشانه‌های گرد را نمی‌شود: پالت، کانالِ شفافیت را به دو پله
#    می‌رساند و لبهٔ دایره دندانه‌دار می‌شود — امتحان شد و دیده می‌شود.
place "$tmp/bg.png" 0.66 "$tmp/ap.png"
convert "$tmp/ap.png" -alpha remove -alpha off -resize 180x180 \
  -dither FloydSteinberg -colors 255 -strip PNG8:$OUT/app-icon-apple.2.png

for f in icon-sl.4 app-icon-192.2 favicon-sl.4 app-icon-mask.2 app-icon-apple.2; do
  say "$f.png" "$(identify -format '%wx%h  %B بایت' $OUT/$f.png)"
done
