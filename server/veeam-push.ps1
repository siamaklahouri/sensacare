<#
  Veeam Backup & Replication  ->  SLTech kartabl
  ===============================================================
  Runs on a Windows box INSIDE the company network -- the one that can
  reach the VBR server. Asks Veeam's own REST API for job states and
  pushes a summary to the kartabl.

  Why this direction: the sltech server sits outside your network and
  cannot reach port 9419 on the VBR server. Having it poll would mean
  exposing that port to the internet -- far too high a price for a
  status table. This way nothing is opened: the connection always goes
  from the inside out.

  What is sent: job name, type, last result, state, last and next run,
  object count. Not the backups, not usernames, not passwords.

  Deliberately ASCII only. Windows PowerShell 5.1 reads a .ps1 with the
  system ANSI codepage unless the file carries a UTF-8 BOM, and a BOM
  is lost the first time somebody saves the file in Notepad. A script
  that lives on a customer's server must not depend on that.

  Setup instructions (Persian): veeam-push.README.md, next to this file.
#>

[CmdletBinding()]
param(
  [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Where the config file lives, when the caller did not say.
#
# This is NOT done as a param() default. In Windows PowerShell 5.1,
# $PSScriptRoot is still empty while parameter defaults are being bound,
# so the default blew up with "Cannot bind argument to parameter 'Path'"
# before the script had run a single line. Here it is already set, and
# the two fallbacks cover being dot-sourced or pasted into a console.
if (-not $ConfigPath) {
  $root = $PSScriptRoot
  if (-not $root -and $MyInvocation.MyCommand.Path) {
    $root = Split-Path -Parent $MyInvocation.MyCommand.Path
  }
  if (-not $root) { $root = (Get-Location).Path }
  $ConfigPath = Join-Path $root 'veeam-push.config.json'
}

function Read-Config {
  param([string] $Path)
  if (-not (Test-Path $Path)) {
    throw "Config file not found: $Path`nPut veeam-push.config.json next to veeam-push.ps1, or pass -ConfigPath."
  }
  $c = Get-Content -Path $Path -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($k in 'VbrHost', 'VbrUser', 'VbrPass', 'PushUrl', 'PushKey') {
    if (-not $c.$k) { throw "Config value '$k' is empty." }
  }
  return $c
}

# Self-signed certificates are normal on internal servers. This is only
# switched off when the config says so, and only for this session.
function Disable-CertCheck {
  if ($PSVersionTable.PSVersion.Major -ge 6) { return }   # pwsh has its own switch
  [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
}

function Invoke-Vbr {
  param(
    [string] $Url, [string] $Method = 'GET',
    [hashtable] $Headers, $Body, [string] $ContentType, [bool] $SkipCert
  )
  # Deliberately not $args -- that is an automatic variable, and writing
  # to it inside a function breaks something else somewhere else.
  $req = @{ Uri = $Url; Method = $Method; Headers = $Headers; UseBasicParsing = $true; TimeoutSec = 60 }
  if ($Body) { $req.Body = $Body }
  if ($ContentType) { $req.ContentType = $ContentType }
  if ($SkipCert -and $PSVersionTable.PSVersion.Major -ge 6) { $req.SkipCertificateCheck = $true }
  return Invoke-RestMethod @req
}

# Veeam's API version changes with every build, and sending the wrong one
# gets a 400. Rather than pinning a number that breaks on the next update,
# try newest to oldest and keep the first that answers.
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
      if ($tok.access_token) {
        Write-Verbose "Veeam API version $v accepted."
        return @{ Token = $tok.access_token; Version = $v }
      }
    } catch { $last = $_ }
  }
  $msg = if ($last) { $last.Exception.Message } else { 'no response' }
  throw "Veeam login failed. Last error: $msg"
}

function Get-VbrJobs {
  param([string] $Base, [string] $Token, [string] $Version, [bool] $SkipCert)
  $h = @{ Authorization = "Bearer $Token"; 'x-api-version' = $Version; accept = 'application/json' }
  $r = Invoke-Vbr -Url "$Base/api/v1/jobs/states?limit=500" -Headers $h -SkipCert $SkipCert

  # Windows PowerShell 5.1 runs a ForEach-Object block once for $null,
  # unlike pwsh 7. Without this, a VBR server with no jobs at all would
  # have produced one all-empty row that looks like a real job.
  $rows = @()
  if ($r -and $r.data) { $rows = @($r.data) }
  elseif ($r -is [array]) { $rows = $r }
  if ($rows.Count -eq 0) { return @() }

  $when = {
    param($t)
    if (-not $t) { return '' }
    try { return ([datetime]$t).ToString('yyyy-MM-dd HH:mm') } catch { return [string]$t }
  }

  return @($rows | ForEach-Object {
    [pscustomobject]@{
      name    = [string]$_.name
      type    = [string]$_.type
      result  = [string]$_.lastResult
      state   = [string]$_.status
      last    = & $when $_.lastRun
      next    = & $when $_.nextRun
      # /jobs/states gives the job's object count, not the backup size.
      # Putting a near-enough number where the asked-for one belongs is
      # worse than putting none.
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
  # Veeam was unreachable. Send anyway, with the error, so the kartabl
  # knows its numbers are stale. Sending nothing is silence, and silence
  # looks exactly like "everything is fine".
  $err = $_.Exception.Message
}

$payload = @{
  host  = [string]$cfg.VbrHost
  agent = "veeam-push.ps1 / $($env:COMPUTERNAME)"
  error = $err
  # @() matters: with a single job PowerShell unrolls the array and
  # ConvertTo-Json writes an object instead of a list -- which the server
  # reads as "no jobs came".
  jobs  = @($jobs)
} | ConvertTo-Json -Depth 5 -Compress

try {
  $res = Invoke-RestMethod -Uri $cfg.PushUrl -Method POST -TimeoutSec 60 -UseBasicParsing `
    -ContentType 'application/json; charset=utf-8' `
    -Headers @{ 'x-veeam-key' = $cfg.PushKey } `
    -Body ([Text.Encoding]::UTF8.GetBytes($payload))
  if ($err) { Write-Output "Sent, but Veeam errored: $err" }
  else { Write-Output "Sent: $($res.jobs) job(s)" }
} catch {
  # Write-Error throws under ErrorActionPreference=Stop, so the next line
  # never runs and the Scheduled Task never sees the exit code -- the
  # failure would stay silent.
  Write-Warning "Push to kartabl failed: $($_.Exception.Message)"
  exit 1
}
