<#
  گزارشِ Veeam → کارتابل
  ===============================================================
  این اسکریپت روی یک ویندوزِ داخلِ شبکهٔ شرکت اجرا می‌شود — همان‌جایی
  که به سرورِ Veeam Backup & Replication دسترسی دارد. از REST APIِ خودِ
  Veeam وضعیتِ جاب‌ها را می‌پرسد و خلاصه‌اش را به کارتابل می‌فرستد.

  چرا این‌طوری و نه برعکس: سرورِ sltech بیرونِ شبکهٔ شماست و به پورتِ
  ۹۴۱۹ِ سرورِ Veeam نمی‌رسد. اگر قرار بود او بپرسد، باید آن پورت را به
  اینترنت باز می‌کردید — که برای یک جدولِ وضعیت، بهای خیلی گزافی است.
  این‌طوری هیچ درگاهی باز نمی‌شود: ارتباط همیشه از داخل به بیرون است.

  چه چیزی می‌رود: نامِ جاب، نوعش، نتیجهٔ آخرین اجرا، وضعیت، زمانِ آخرین
  و بعدیِ اجرا، و حجم. نه خودِ بکاپ، نه نامِ کاربری، نه رمز.

  ---------------------------------------------------------------
  راه‌اندازی

  ۱) در پنل، روی کارتابل، دکمهٔ «کلید Veeam» → «کلید بساز». کلید و
     آدرس را بردارید.

  ۲) یک کاربرِ فقط‌خواندنی در Veeam بسازید (Users and Roles → نقشِ
     «Veeam Backup Viewer»). کاربرِ ادمین لازم نیست و نباید داد.

  ۳) فایلِ تنظیمات را کنارِ همین اسکریپت بسازید — veeam-push.config.json:

       {
         "VbrHost":  "veeam01.company.local",
         "VbrUser":  "COMPANY\\veeam-viewer",
         "VbrPass":  "...",
         "PushUrl":  "https://sltech.ir/api/kartabl/veeam/push",
         "PushKey":  "...",
         "SkipCertCheck": true
       }

     این فایل رمز دارد: دسترسی‌اش را به همان کاربری بدهید که اسکریپت
     با آن اجرا می‌شود و بس.

  ۴) یک Scheduled Task بسازید که ساعتی یک بار اجرایش کند:

       schtasks /create /tn "Veeam report to kartabl" /sc hourly ^
         /ru SYSTEM /tr "powershell -NoProfile -ExecutionPolicy Bypass -File C:\veeam-push\veeam-push.ps1"

  ---------------------------------------------------------------
  اگر اسکریپت به Veeam نرسید، باز هم چیزی می‌فرستد — با توضیحِ خطا.
  سکوت بدترین حالت است: کارتابل سبزِ هفتهٔ پیش را نشان می‌دهد و کسی
  نمی‌فهمد که خبری نیست.
#>

[CmdletBinding()]
param(
  [string] $ConfigPath = (Join-Path $PSScriptRoot 'veeam-push.config.json')
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Read-Config {
  param([string] $Path)
  if (-not (Test-Path $Path)) { throw "فایلِ تنظیمات پیدا نشد: $Path" }
  $c = Get-Content -Path $Path -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($k in 'VbrHost', 'VbrUser', 'VbrPass', 'PushUrl', 'PushKey') {
    if (-not $c.$k) { throw "در تنظیمات، «$k» خالی است." }
  }
  return $c
}

# گواهیِ خودامضا روی سرورهای داخلی عادی است. این فقط وقتی خاموش
# می‌شود که خودِ شما در تنظیمات گفته باشید، و فقط برای همین نشست.
function Disable-CertCheck {
  if ($PSVersionTable.PSVersion.Major -ge 6) { return }   # pwsh پارامترِ خودش را دارد
  if (-not ('VeeamNoCert' -as [type])) {
    Add-Type -TypeDefinition @'
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class VeeamNoCert {
  public static void Install() {
    ServicePointManager.ServerCertificateValidationCallback =
      delegate (object s, X509Certificate c, X509Chain ch, System.Net.Security.SslPolicyErrors e) { return true; };
  }
}
'@
  }
  [VeeamNoCert]::Install()
}

function Invoke-Vbr {
  param(
    [string] $Url, [string] $Method = 'GET',
    [hashtable] $Headers, $Body, [string] $ContentType, [bool] $SkipCert
  )
  # عمداً $args نیست: آن یکی متغیرِ خودکارِ پاورشل است و دست زدن به آن
  # داخلِ یک تابع، جایی دیگر چیزی را می‌شکند.
  $req = @{ Uri = $Url; Method = $Method; Headers = $Headers; UseBasicParsing = $true; TimeoutSec = 60 }
  if ($Body) { $req.Body = $Body }
  if ($ContentType) { $req.ContentType = $ContentType }
  # pwsh 6+ پرچمِ خودش را دارد؛ در ویندوزپاورشلِ ۵ همان بالا خاموش شده
  if ($SkipCert -and $PSVersionTable.PSVersion.Major -ge 6) { $req.SkipCertificateCheck = $true }
  return Invoke-RestMethod @req
}

# نسخهٔ APIِ Veeam با هر بیلد عوض می‌شود و اگر اشتباه بفرستید، سرور
# ۴۰۰ می‌دهد. به‌جای اینکه یک عدد را سفت کنیم و با آپدیتِ بعدی بشکند،
# از تازه به قدیم امتحان می‌شود و اولی که جواب داد می‌ماند.
$ApiVersions = @('1.2-rev1', '1.2-rev0', '1.1-rev0', '1.1-rev1', '1.0-rev2')

function Connect-Vbr {
  param([string] $Base, [string] $User, [string] $Pass, [bool] $SkipCert)
  $last = $null
  foreach ($v in $ApiVersions) {
    try {
      $form = 'grant_type=password&username=' + [uri]::EscapeDataString($User) +
              '&password=' + [uri]::EscapeDataString($Pass)
      $tok = Invoke-Vbr -Url "$Base/api/oauth2/token" -Method POST `
        -Headers @{ 'x-api-version' = $v; 'accept' = 'application/json' } `
        -ContentType 'application/x-www-form-urlencoded' `
        -Body $form -SkipCert $SkipCert
      if ($tok.access_token) { return @{ Token = $tok.access_token; Version = $v } }
    } catch { $last = $_ }
  }
  throw "ورود به Veeam نشد. آخرین خطا: $($last.Exception.Message)"
}

function Get-VbrJobs {
  param([string] $Base, [string] $Token, [string] $Version, [bool] $SkipCert)
  $h = @{ Authorization = "Bearer $Token"; 'x-api-version' = $Version; accept = 'application/json' }
  $r = Invoke-Vbr -Url "$Base/api/v1/jobs/states?limit=500" -Headers $h -SkipCert $SkipCert
  $rows = if ($r.data) { $r.data } else { $r }

  $when = {
    param($t)
    if (-not $t) { return '' }
    try { return ([datetime]$t).ToString('yyyy-MM-dd HH:mm') } catch { return [string]$t }
  }

  return @($rows | ForEach-Object {
    [pscustomobject]@{
      name   = [string]$_.name
      type   = [string]$_.type
      result = [string]$_.lastResult
      state  = [string]$_.status
      last   = & $when $_.lastRun
      next   = & $when $_.nextRun
      # «/jobs/states» حجمِ بکاپ را نمی‌دهد، تعدادِ آبجکتِ جاب را می‌دهد.
      # عددِ نزدیک را به‌جای عددِ خواسته‌شده گذاشتن، بدتر از نگذاشتن است.
      objects = [string]$_.objectsCount
      note    = [string]$_.description
    }
  })
}

# ---------------------------------------------------------------

$cfg = Read-Config -Path $ConfigPath
$skip = [bool]$cfg.SkipCertCheck
if ($skip) { Disable-CertCheck }

$base = $cfg.VbrHost
if ($base -notmatch '^https?://') { $base = "https://${base}:9419" }
$base = $base.TrimEnd('/')

$jobs = @()
$err  = ''
try {
  $conn = Connect-Vbr -Base $base -User $cfg.VbrUser -Pass $cfg.VbrPass -SkipCert $skip
  $jobs = Get-VbrJobs -Base $base -Token $conn.Token -Version $conn.Version -SkipCert $skip
} catch {
  # به Veeam نرسیدیم. باز هم می‌فرستیم — با خطا — تا کارتابل بداند
  # عددهایش کهنه‌اند. نفرستادن یعنی سکوت، و سکوت شبیهِ «همه‌چیز خوب
  # است» دیده می‌شود.
  $err = $_.Exception.Message
}

$payload = @{
  host  = $cfg.VbrHost
  agent = "veeam-push.ps1 / $($env:COMPUTERNAME)"
  error = $err
  # @() لازم است: با یک جابِ تنها، پاورشل آرایه را باز می‌کند و
  # ConvertTo-Json به‌جای فهرست، یک شیء می‌سازد — و سرور آن را
  # «هیچ جابی نیامد» می‌خواند.
  jobs  = @($jobs)
} | ConvertTo-Json -Depth 5 -Compress

try {
  $res = Invoke-RestMethod -Uri $cfg.PushUrl -Method POST -TimeoutSec 60 -UseBasicParsing `
    -ContentType 'application/json; charset=utf-8' `
    -Headers @{ 'x-veeam-key' = $cfg.PushKey } `
    -Body ([Text.Encoding]::UTF8.GetBytes($payload))
  if ($err) { Write-Output "رفت، ولی با خطای Veeam: $err" }
  else { Write-Output "رفت: $($res.jobs) جاب" }
} catch {
  # Write-Error با ErrorActionPreference=Stop خودش پرتاب می‌کند و خطِ
  # بعدی اصلاً اجرا نمی‌شود؛ آن وقت Scheduled Task کدِ خروجِ درست را
  # نمی‌بیند و خرابی بی‌صدا می‌ماند.
  Write-Warning "فرستادن به کارتابل نشد: $($_.Exception.Message)"
  exit 1
}
