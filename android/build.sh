#!/usr/bin/env bash
# ==================== ساختنِ APK، مرحله‌به‌مرحله ====================
# دو بار این کار نیمه‌کاره ماند و هر دو بار به یک دلیل: دانلود وسطِ
# راه قطع شد و ابزارِ bubblewrap دانلودش را از سر نمی‌گیرد — از صفر
# شروع می‌کند. روی این شبکه یعنی هیچ‌وقت تمام نمی‌شود.
#
# پس این‌جا هر چیزِ سنگین با «curl -C -» می‌آید (یعنی از همان بایتی که
# قطع شده ادامه می‌دهد) و هر مرحله نشانِ «انجام شد» می‌گذارد. اگر وسطِ
# کار هرچه پیش آمد، همین اسکریپت را دوباره بزنید: مرحله‌های تمام‌شده
# رد می‌شوند و از همان‌جا ادامه می‌دهد.
#
#   bash android/build.sh --check    کجای کاریم؟
#   bash android/build.sh            ادامه بده
#
# رمزِ کلید را این اسکریپت نه می‌پرسد نه نگه می‌دارد؛ فقط خودِ
# bubblewrap سرِ امضا می‌پرسدش. پس داخلِ tmux اجرا کنید:
#
#   tmux new -s apk    (و اگر ارتباط قطع شد: tmux attach -t apk)

set -u
APP="${APP:-/opt/sltech/app}"
AND="$APP/android"
SDK="${ANDROID_HOME:-/opt/android-sdk}"
# bubblewrap با جاوا ۱۷ کار می‌کند و با نسخه‌های بالاتر نه. پس
# «JAVA_HOME»ِ سیستم کافی نیست — ممکن است ۲۱ باشد و همه‌چیز سرِ
# gradle بشکند، آن هم بعد از نیم ساعت دانلود. اول دنبالِ خودِ ۱۷
# می‌گردیم و اگر JAVA_HOME هم ۱۷ بود، همان.
pick_jdk(){
  local c
  for c in /usr/lib/jvm/java-17-openjdk-amd64 /usr/lib/jvm/java-17-openjdk \
           /usr/lib/jvm/temurin-17-jdk-amd64 "${JAVA_HOME:-}"; do
    [ -n "$c" ] && [ -x "$c/bin/java" ] || continue
    "$c/bin/java" -version 2>&1 | grep -m1 ' version ' | grep -q '"17\.' && { echo "$c"; return; }
  done
  echo ""
}
JDK="${JDK_PATH:-$(pick_jdk)}"
KEY="${KEYSTORE:-/root/android.keystore}"
ALIAS="${KEY_ALIAS:-sltech}"
STATE="$AND/.build-state"
# شمارهٔ ساختِ ابزارِ خط‌فرمان. اگر گوگل عوضش کرد، همین یک خط را
# عوض کنید؛ بقیهٔ اسکریپت دست نمی‌خورد.
CLT_VER="${CLT_VER:-11076708}"
CLT_URL="https://dl.google.com/android/repository/commandlinetools-linux-${CLT_VER}_latest.zip"
CLT_ZIP="/var/tmp/cmdline-tools-${CLT_VER}.zip"

mkdir -p "$STATE"
done_(){ [ -f "$STATE/$1" ]; }
mark(){ : > "$STATE/$1"; }
say(){ echo "$1"; }
die(){ echo "❌ $1" >&2; exit 1; }

# ---------- گزارشِ وضعیت ----------
status(){
  say "— کجای کاریم —"
  if [ -n "$JDK" ] && [ -x "$JDK/bin/java" ]; then
    say "  ✅ JDK 17: $JDK  ($("$JDK/bin/java" -version 2>&1 | grep -m1 ' version ' | tr -d '"'))"
  else
    local other=""
    [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ] \
      && other=" — آنچه هست: $("$JAVA_HOME/bin/java" -version 2>&1 | grep -m1 ' version ' | tr -d '"')"
    say "  ❌ JDK 17 پیدا نشد$other"
  fi
  [ -f "$KEY" ] && say "  ✅ کلیدِ امضا: $KEY" || say "  ❌ کلیدِ امضا نیست: $KEY"
  if [ -f "$CLT_ZIP" ]; then
    say "  ◻ فایلِ ابزار: $(du -h "$CLT_ZIP" | cut -f1) دانلود شده$(done_ clt-ok && echo ' و سالم')"
  else
    say "  ❌ فایلِ ابزار هنوز دانلود نشده"
  fi
  [ -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ] \
    && say "  ✅ ابزارِ خط‌فرمان نصب شده" || say "  ❌ ابزارِ خط‌فرمان نصب نشده"
  done_ sdk-pkgs && say "  ✅ بسته‌های SDK نصب شده‌اند" || say "  ❌ بسته‌های SDK نصب نشده‌اند"
  command -v bubblewrap >/dev/null && say "  ✅ bubblewrap: $(command -v bubblewrap)" \
    || say "  ❌ bubblewrap نصب نشده"
  [ -f "$AND/app-release-signed.apk" ] \
    && say "  ✅ APK ساخته شده: $(du -h "$AND/app-release-signed.apk" | cut -f1)" \
    || say "  ◻ APK هنوز ساخته نشده"
  local free
  free=$(df -P /var/tmp | awk 'NR==2{print int($4/1024)}')
  say "  جای خالیِ دیسک: ${free} مگابایت  (دستِ‌کم ۴۰۰۰ لازم است)"
}

[ "${1:-}" = "--check" ] && { status; exit 0; }

# ---------- پیش‌نیازها ----------
[ -n "$JDK" ] && [ -x "$JDK/bin/java" ] ||
  die "JDK 17 پیدا نشد. bubblewrap فقط با ۱۷ کار می‌کند:
     apt install -y openjdk-17-jdk-headless
   اگر جای دیگری نصب است:  JDK_PATH=/path/to/jdk17 bash android/build.sh"
[ -f "$KEY" ] || die "کلیدِ امضا در $KEY نیست."
[ -f "$AND/twa-manifest.json" ] || die "twa-manifest.json پیدا نشد."
free=$(df -P /var/tmp | awk 'NR==2{print int($4/1024)}')
[ "$free" -gt 4000 ] || die "جای دیسک کم است (${free} مگابایت). دستِ‌کم ۴ گیگابایت لازم است."

# ---------- نشانه‌ها روی سایتِ زنده هستند؟ ----------
# bubblewrap نشانهٔ برنامه را از همین نشانی‌ها برمی‌دارد، نه از روی
# دیسک. پس اگر سایت هنوز مستقر نشده باشد، APK با نشانهٔ قدیمی — یا
# اصلاً بی‌نشانه — ساخته می‌شود و این نیم ساعت بعد معلوم می‌شود.
# دو ثانیه این‌جا، به‌جای نیم ساعت آن‌جا.
for u in $(grep -oE 'https://[^"]+\.png' "$AND/twa-manifest.json"); do
  code=$(curl -s -o /dev/null --max-time 12 -w '%{http_code}' "$u" || echo 000)
  case "$code" in
    200) : ;;
    000) say "   ⚠️  به $u نرسیدم. اگر اینترنتِ سرور مشکل دارد ادامه بدهید؛"
         say "       وگرنه اول استقرار بدهید." ;;
    *)   die "نشانهٔ $u روی سایت نیست (کد $code).
   یعنی سایت هنوز مستقر نشده. اول این را بزنید و بعد برگردید:
     bash /opt/sltech/app/server/update.sh" ;;
  esac
done

# ---------- به گوگل می‌رسیم؟ ----------
# این سرور یک بار ۴۰۴ِ خودِ گوگل گرفت برای فایلی که از جای دیگر همان
# لحظه ۲۰۰ می‌داد — یعنی مسدودسازیِ جغرافیایی، نه نبودنِ فایل.
#
# و فقط آن زیپ نیست: gradle هم افزونهٔ اندروید را از maven2ِ همین
# دامنه می‌گیرد. اگر آن بسته باشد، رساندنِ زیپ به سرور هیچ چیزی را حل
# نمی‌کند و خرابی نیم ساعت بعد سرِ gradle پیدا می‌شود. پس هر دو را
# همین‌جا می‌سنجیم.
MAVEN_PROBE="https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/8.1.0/gradle-8.1.0.pom"
probe(){ curl -s -o /dev/null --max-time 20 -w '%{http_code}' "$1" 2>/dev/null || echo 000; }
if ! done_ clt-ok; then
  c1=$(probe "$CLT_URL"); c2=$(probe "$MAVEN_PROBE")
  say "— رسیدن به گوگل —"
  say "   ابزارِ خط‌فرمان: $c1        maven اندروید: $c2"
  if [ "$c1" != "200" ] && [ "$c2" != "200" ]; then
    die "هیچ‌کدام باز نیست. این سرور به dl.google.com دسترسی ندارد.
   رساندنِ دستیِ زیپ هم کافی نیست: gradle همان‌جا دوباره گیر می‌کند.
   یا باید مسیرِ شبکهٔ سرور عوض شود، یا APK جای دیگری ساخته شود."
  fi
  [ "$c2" = "200" ] || say "   ⚠️  maven باز نیست؛ اگر زیپ را دستی رساندید، gradle هم می‌افتد."
fi

# ---------- ۱) دانلودِ ابزارِ خط‌فرمان، با ازسرگیری ----------
# «-C -» یعنی از همان بایتی که قطع شده ادامه بده. همین یک پرچم، همان
# چیزی است که دو بارِ قبل نبود.
#
# ولی ازسرگیری یک تله دارد و یک بار توی آن افتادیم: اگر چیزی که روی
# دیسک مانده اصلاً دانلودِ ناقص نباشد — مثلاً صفحهٔ خطای یک فیلتر —
# curl از همان بایت ادامه می‌دهد، سرور چیزی اضافه نمی‌دهد، تستِ زیپ
# می‌افتد و حلقه ده بار همان را تکرار می‌کند. بی‌پایان و بی‌معنی.
#
# پس قبل از هر ازسرگیری، چهار بایتِ اولِ فایل سنجیده می‌شود. هر زیپی
# با «PK» شروع می‌شود؛ اگر نشد، آن فایل دانلودِ ناقص نیست و باید پاک
# شود، نه ادامه داده شود.
zip_head_ok(){ [ -s "$1" ] && [ "$(head -c2 "$1" 2>/dev/null)" = "PK" ]; }

if ! done_ clt-ok; then
  say "— ۱/۵ دانلودِ ابزارِ خط‌فرمانِ اندروید —"
  if [ -f "$CLT_ZIP" ] && ! zip_head_ok "$CLT_ZIP"; then
    say "   چیزی که از قبل مانده زیپ نیست ($(stat -c%s "$CLT_ZIP") بایت) — پاکش می‌کنم."
    say "   محتوایش:"
    head -c 300 "$CLT_ZIP" | tr -d '\000' | sed 's/^/     /'
    echo
    rm -f "$CLT_ZIP"
  fi
  for try in 1 2 3 4 5 6 7 8 9 10; do
    say "   تلاشِ $try …"
    if curl -L -C - --retry 5 --retry-delay 5 --retry-all-errors \
         --connect-timeout 20 --speed-time 60 --speed-limit 2048 \
         -o "$CLT_ZIP" "$CLT_URL"; then
      if unzip -tq "$CLT_ZIP" >/dev/null 2>&1; then
        mark clt-ok; say "   ✅ کامل و سالم"; break
      fi
      # زیپ نیست؟ پس ادامه دادنش بی‌فایده است.
      if ! zip_head_ok "$CLT_ZIP"; then
        say "   آن‌چه آمد زیپ نیست ($(stat -c%s "$CLT_ZIP") بایت):"
        head -c 300 "$CLT_ZIP" | tr -d '\000' | sed 's/^/     /'
        echo
        rm -f "$CLT_ZIP"
        die "نشانیِ $CLT_URL به‌جای فایل، یک صفحه برمی‌گرداند.
   یعنی این دانلود از این سرور رد نمی‌شود — تکرارش فایده ندارد.

   اگر آن صفحه «Error 404» گوگل است، لزوماً یعنی فایل نیست نیست:
   همین نشانی از بیرونِ ایران ۲۰۰ و ۱۴۶ مگابایت می‌دهد. گوگل
   دانلودهای Android SDK را از بعضی نشانی‌ها همین‌طور رد می‌کند.

   راهِ دررو: فایل را از هر جای دیگری که در دسترس است بگیرید و
   دقیقاً همین‌جا بگذارید، بعد همین اسکریپت را دوباره بزنید:
     $CLT_ZIP
   اسکریپت اگر فایلِ سالم ببیند، از مرحلهٔ ۲ ادامه می‌دهد."
      fi
      say "   فایل ناقص است؛ ادامه می‌دهم."
    fi
    sleep 5
  done
  done_ clt-ok || die "دانلود تمام نشد. همین دستور را دوباره بزنید؛ از همان‌جا ادامه می‌دهد."
fi

# ---------- ۲) باز کردنش ----------
if [ ! -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
  say "— ۲/۵ نصبِ ابزارِ خط‌فرمان —"
  rm -rf "$SDK/cmdline-tools/latest.tmp"
  mkdir -p "$SDK/cmdline-tools/latest.tmp"
  unzip -q "$CLT_ZIP" -d "$SDK/cmdline-tools/latest.tmp" || die "باز کردنِ فایل نشد."
  rm -rf "$SDK/cmdline-tools/latest"
  mv "$SDK/cmdline-tools/latest.tmp/cmdline-tools" "$SDK/cmdline-tools/latest"
  rmdir "$SDK/cmdline-tools/latest.tmp" 2>/dev/null || true
  say "   ✅ نصب شد"
fi

export ANDROID_HOME="$SDK" ANDROID_SDK_ROOT="$SDK" JAVA_HOME="$JDK"
export PATH="$SDK/cmdline-tools/latest/bin:$SDK/platform-tools:$JDK/bin:$PATH"

# ---------- ۳) بسته‌های SDK ----------
if ! done_ sdk-pkgs; then
  say "— ۳/۵ بسته‌های SDK —"
  yes | sdkmanager --licenses >/dev/null 2>&1 || true
  for try in 1 2 3 4 5; do
    if sdkmanager --install "platform-tools" "build-tools;34.0.0" "platforms;android-34"; then
      mark sdk-pkgs; say "   ✅ نصب شدند"; break
    fi
    say "   تلاشِ $try نشد؛ دوباره…"; sleep 8
  done
  done_ sdk-pkgs || die "نصبِ بسته‌ها تمام نشد. دوباره بزنید."
fi

# ---------- ۴) bubblewrap ----------
if ! command -v bubblewrap >/dev/null; then
  say "— ۴/۵ نصبِ bubblewrap —"
  npm i -g @bubblewrap/cli --no-audit --no-fund || die "نصبِ bubblewrap نشد. دوباره بزنید."
fi
# پیکربندی را خودمان می‌نویسیم تا bubblewrap نه بپرسد و نه چیزی دانلود کند
mkdir -p "$HOME/.bubblewrap"
printf '{\n  "jdkPath": "%s",\n  "androidSdkPath": "%s"\n}\n' "$JDK" "$SDK" \
  > "$HOME/.bubblewrap/config.json"

# ---------- ۵) ساخت ----------
say "— ۵/۵ ساختِ APK —"
cd "$AND"
[ -f ./android.keystore ] || cp "$KEY" ./android.keystore
chmod 600 ./android.keystore
# حافظهٔ این سرور ۱٫۹ گیگابایت است؛ بی این سقف، gradle خودش را می‌کشد.
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx900m -Dorg.gradle.daemon=false"
# «--skipVersionUpgrade» در همهٔ نسخه‌های bubblewrap نیست. اگر نبود،
# کلِ کار آخرِ راه می‌افتاد — بعد از نیم ساعت دانلود. پس اول با پرچم،
# و اگر نشناختش بی‌پرچم. شمارهٔ نسخه از قبل در twa-manifest.json
# درست است (۲)، پس هر دو راه یک نتیجه می‌دهند.
bubblewrap update --skipVersionUpgrade 2>/dev/null ||
  bubblewrap update ||
  die "update نشد."
say "   رمزِ کلید را bubblewrap خودش می‌پرسد — این اسکریپت نمی‌پرسد و نگهش نمی‌دارد."
bubblewrap build --skipPwaValidation || die "build نشد."

[ -f app-release-signed.apk ] || die "APK ساخته نشد."
cp app-release-signed.apk "$APP/public/sltech.apk"
say ""
say "✅ تمام. APK در $APP/public/sltech.apk"
say ""
# ---------- آخرین سنجه: اثرِ انگشت با assetlinks می‌خواند؟ ----------
# اگر نخواند، اندروید برنامه را «تأییدنشده» می‌بیند و نوارِ آدرس را
# بالای صفحه می‌گذارد — یعنی همهٔ این کار بی‌نتیجه. پس این‌جا فقط چاپ
# نمی‌کنیم، می‌سنجیم.
FP=$(keytool -list -v -keystore ./android.keystore -alias "$ALIAS" 2>/dev/null |
     grep -i 'SHA256:' | head -1 | sed 's/.*SHA256: *//' | tr -d ' \r' | tr 'a-f' 'A-F')
say "— اثرِ انگشتِ کلیدی که با آن امضا شد —"
say "   $FP"
if [ -z "$FP" ]; then
  say "   ⚠️ خوانده نشد (رمز؟). خودتان بسنجید."
elif grep -qi -- "$FP" "$APP/public/.well-known/assetlinks.json"; then
  say "   ✅ در assetlinks.json هست — بعد از استقرار، برنامه تأییدشده باز می‌شود."
else
  say "   ❌ در assetlinks.json نیست. تا اضافه نشود، اندروید نوارِ آدرس را"
  say "      بالای صفحه می‌گذارد. اضافه‌اش کنید — کنارِ قبلی‌ها، نه به‌جایشان:"
  say "      public/.well-known/assetlinks.json → sha256_cert_fingerprints"
fi
say ""
# ---------- نصب روی گوشی ----------
# این مهم‌ترین جمله‌ای است که آخرِ کار لازم می‌شود و تا امروز نوشته
# نشده بود: APKِ تازه با کلیدِ دیگری امضا شده، و اندروید اجازه نمی‌دهد
# برنامه‌ای با امضای متفاوت روی نسخهٔ نصب‌شده بنشیند — هرچه
# appVersionCode بالاتر باشد. پیامش «App not installed» است و آدم
# فکر می‌کند فایل خراب است.
say "— نصب روی گوشی —"
say "   ۱) برنامهٔ فعلیِ SLTech را از گوشی پاک کنید."
say "      کلیدِ امضا عوض شده و اندروید نصبِ روی نسخهٔ قبلی را رد می‌کند؛"
say "      پیامش «App not installed» است و ربطی به سالم بودنِ فایل ندارد."
say "   ۲) https://sltech.ir/sltech.apk را دانلود و نصب کنید."
say ""
say "   دادهٔ کارتابل با پاک کردنِ برنامه از بین نمی‌رود: برنامه فقط یک"
say "   پوسته است و همه‌چیز یا روی سرور است یا در حافظهٔ خودِ کروم برای"
say "   همین دامنه — که مالِ کروم است، نه این برنامه."
say ""
say "کلید را از این‌جا پاک کنید وقتی کارتان تمام شد:  rm -f $AND/android.keystore"
