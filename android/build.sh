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

# ---------- ۱) دانلودِ ابزارِ خط‌فرمان، با ازسرگیری ----------
# «-C -» یعنی از همان بایتی که قطع شده ادامه بده. همین یک پرچم، همان
# چیزی است که دو بارِ قبل نبود.
if ! done_ clt-ok; then
  say "— ۱/۵ دانلودِ ابزارِ خط‌فرمانِ اندروید —"
  for try in 1 2 3 4 5 6 7 8 9 10; do
    say "   تلاشِ $try …"
    if curl -L -C - --retry 5 --retry-delay 5 --retry-all-errors \
         --connect-timeout 20 --speed-time 60 --speed-limit 2048 \
         -o "$CLT_ZIP" "$CLT_URL"; then
      if unzip -tq "$CLT_ZIP" >/dev/null 2>&1; then
        mark clt-ok; say "   ✅ کامل و سالم"; break
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
