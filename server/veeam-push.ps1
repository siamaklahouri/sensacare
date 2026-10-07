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
  $text = Get-Content -Path $Path -Raw -Encoding UTF8

  # A Windows account is written BACKUP-SRV\user, and that lone backslash
  # is the single most common way this file gets broken: JSON needs it
  # doubled. ConvertFrom-Json answers with "Unrecognized escape sequence",
  # which says nothing about which character or how to fix it.
  #
  # So: any backslash that is not already part of a valid JSON escape gets
  # doubled here. The alternation matters -- it swallows a valid escape
  # (\\ among them) whole, so the second backslash of an already-correct
  # pair is never seen on its own and doubled a second time.
  $fixed = [regex]::Replace($text, '\\(["\\/bfnrtu])|\\', {
    param($m)
    if ($m.Groups[1].Success) { return $m.Value }
    return '\\'
  })
  if ($fixed -ne $text) { Write-Verbose 'Config: doubled a backslash that JSON needed escaped.' }

  try { $c = $fixed | ConvertFrom-Json }
  catch { throw "Config file is not valid JSON: $Path -- $($_.Exception.Message)" }
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

# The HTTP status line alone is useless here: Veeam answers 400 for a bad
# password, for an unsupported API version and for an MFA-enabled account
# alike, and only the response BODY says which. Windows PowerShell throws
# the body away, so it has to be read off the stream by hand.
function Get-HttpError {
  param($Err)
  $status = ''
  $body = ''
  # pwsh 7 hands the body over here; Windows PowerShell 5.1 leaves it empty.
  if ($Err.ErrorDetails -and $Err.ErrorDetails.Message) { $body = [string]$Err.ErrorDetails.Message }
  $resp = $null
  try { $resp = $Err.Exception.Response } catch { }
  if ($resp) {
    try { $status = [string][int]$resp.StatusCode } catch { }
    if (-not $body) {
      try {
        $stream = $resp.GetResponseStream()
        if ($stream) {
          $sr = New-Object System.IO.StreamReader($stream)
          $body = $sr.ReadToEnd()
          $sr.Close()
        }
      } catch { }
    }
  }
  if (-not $body) { $body = [string]$Err.Exception.Message }
  $body = ($body -replace '\s+', ' ').Trim()
  if ($body.Length -gt 400) { $body = $body.Substring(0, 400) }
  return @{ Status = $status; Body = $body }
}

# Veeam's API version changes with every build, and sending the wrong one
# gets a 400. Rather than pinning a number that breaks on the next update,
# try newest to oldest and keep the first that answers.
$ApiVersions = @('1.0-rev1', '1.2-rev1', '1.2-rev0', '1.1-rev1', '1.1-rev0', '1.0-rev0')

# Answers that mean "your credentials are the problem", not "your version
# is". Veeam phrases these differently across builds, so this matches on
# what the message says rather than on an error code.
$CredWords = 'invalid_grant|invalid_client|user name or password|username or password|' +
             'incorrect|unauthor|not authenticated|logon|log on|mfa|multi-factor|' +
             'two-factor|locked|expired'

function Get-VbrToken {
  param([string] $Base, [string] $User, [string] $Pass, [bool] $SkipCert, [string] $Version)
  $form = 'grant_type=password&username=' + [uri]::EscapeDataString($User) +
          '&password=' + [uri]::EscapeDataString($Pass)
  return Invoke-Vbr -Url "$Base/api/oauth2/token" -Method POST `
    -Headers @{ 'x-api-version' = $Version; 'accept' = 'application/json' } `
    -ContentType 'application/x-www-form-urlencoded' `
    -Body $form -SkipCert $SkipCert
}

function Connect-Vbr {
  param([string] $Base, [string] $User, [string] $Pass, [bool] $SkipCert)
  $last = 'no response'
  $learned = @()
  foreach ($v in $ApiVersions) {
    try {
      $tok = Get-VbrToken -Base $Base -User $User -Pass $Pass -SkipCert $SkipCert -Version $v
      if ($tok.access_token) {
        Write-Verbose "api-version $v accepted."
        return @{ Token = $tok.access_token; Version = $v }
      }
    } catch {
      $e = Get-HttpError $_
      $last = ("api-version $v -> HTTP $($e.Status) $($e.Body)").Trim()
      Write-Verbose $last
      # Stop at the first answer that blames the credentials. Walking the
      # rest of the list would be four more failed logins every run, every
      # hour -- which is how a domain account gets locked out.
      if ($e.Body -match $CredWords) {
        throw "Veeam rejected the sign-in (not an API-version problem): $last"
      }
      # When the version is wrong, VBR answers with the versions it DOES
      # accept: "Unsupported RESTAPI version. The following versions are
      # supported: v1.0-rev1." Take it at its word. A hard-coded list ages
      # with every Veeam release; that sentence does not.
      # This costs nothing extra: a rejected version never reached the
      # sign-in, so it is not a failed login attempt.
      if ($e.Body -match 'supported[^0-9]*v?([0-9]+\.[0-9]+-rev[0-9]+)') {
        $told = $Matches[1]
        if ($ApiVersions -notcontains $told -and $learned -notcontains $told) {
          $learned += $told
          Write-Verbose "server says it supports $told -- will try that"
        }
      }
    }
  }
  foreach ($v in $learned) {
    try {
      $tok = Get-VbrToken -Base $Base -User $User -Pass $Pass -SkipCert $SkipCert -Version $v
      if ($tok.access_token) {
        Write-Verbose "api-version $v accepted (the server named it)."
        return @{ Token = $tok.access_token; Version = $v }
      }
    } catch {
      $e = Get-HttpError $_
      $last = ("api-version $v -> HTTP $($e.Status) $($e.Body)").Trim()
      Write-Verbose $last
      if ($e.Body -match $CredWords) {
        throw "Veeam rejected the sign-in (not an API-version problem): $last"
      }
    }
  }
  throw "Veeam login failed for every API version tried. Last answer: $last"
}

function Get-VbrJobs {
  param([string] $Base, [string] $Token, [string] $Version, [bool] $SkipCert)
  $h = @{ Authorization = "Bearer $Token"; 'x-api-version' = $Version; accept = 'application/json' }
  # /jobs/states carries each job's last result; /jobs carries only its
  # configuration. Older API versions do not have the first. Falling back
  # is worth it -- but the report says which one answered, because a table
  # of job names with every result blank, and no word why, is worse than
  # no table.
  $r = $null
  $script:JobsVia = 'jobs/states'
  try {
    $r = Invoke-Vbr -Url "$Base/api/v1/jobs/states?limit=500" -Headers $h -SkipCert $SkipCert
  } catch {
    $je = Get-HttpError $_
    Write-Verbose "jobs/states -> HTTP $($je.Status) $($je.Body)"
    $script:JobsVia = 'jobs'
    $r = Invoke-Vbr -Url "$Base/api/v1/jobs?limit=500" -Headers $h -SkipCert $SkipCert
  }

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
      # /jobs/states calls them lastResult/status; /jobs has neither, and
      # leaves them empty rather than inventing a result.
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

# Repositories and recent sessions. Both are extras: a build that does
# not have them still sends its jobs. So each is wrapped on its own --
# one missing endpoint must not cost us the whole report.
function Get-VbrRepos {
  param([string] $Base, [string] $Token, [string] $Version, [bool] $SkipCert)
  $h = @{ Authorization = "Bearer $Token"; 'x-api-version' = $Version; accept = 'application/json' }
  $r = $null
  try {
    $r = Invoke-Vbr -Url "$Base/api/v1/backupInfrastructure/repositories/states" -Headers $h -SkipCert $SkipCert
  } catch {
    Write-Verbose "repositories/states -> $((Get-HttpError $_).Body)"
    return @()
  }
  $rows = @()
  if ($r -and $r.data) { $rows = @($r.data) } elseif ($r -is [array]) { $rows = $r }
  if ($rows.Count -eq 0) { return @() }

  return @($rows | ForEach-Object {
    # Builds disagree on units: some answer in GB, some in bytes. Take
    # whichever is there and normalise to GB, rather than printing a
    # number whose unit nobody can be sure of.
    $cap = 0.0; $free = 0.0
    if ($null -ne $_.capacityGB) { $cap = [double]$_.capacityGB }
    elseif ($null -ne $_.capacity) { $cap = [double]$_.capacity / 1GB }
    if ($null -ne $_.freeGB) { $free = [double]$_.freeGB }
    elseif ($null -ne $_.freeSpace) { $free = [double]$_.freeSpace / 1GB }
    $used = $cap - $free
    if ($used -lt 0) { $used = 0 }
    [pscustomobject]@{
      name  = [string]$_.name
      type  = [string]$_.type
      capacity = [string][math]::Round($cap, 1)
      free     = [string][math]::Round($free, 1)
      used     = [string][math]::Round($used, 1)
      pct      = [string]$(if ($cap -gt 0) { [math]::Round(($used / $cap) * 100) } else { '' })
    }
  })
}

function Get-VbrSessions {
  param([string] $Base, [string] $Token, [string] $Version, [bool] $SkipCert)
  $h = @{ Authorization = "Bearer $Token"; 'x-api-version' = $Version; accept = 'application/json' }
  $r = $null
  try {
    $r = Invoke-Vbr -Url "$Base/api/v1/sessions?limit=40" -Headers $h -SkipCert $SkipCert
  } catch {
    Write-Verbose "sessions -> $((Get-HttpError $_).Body)"
    return @()
  }
  $rows = @()
  if ($r -and $r.data) { $rows = @($r.data) } elseif ($r -is [array]) { $rows = $r }
  if ($rows.Count -eq 0) { return @() }

  $when = {
    param($t)
    if (-not $t) { return '' }
    try { return ([datetime]$t).ToString('yyyy-MM-dd HH:mm') } catch { return [string]$t }
  }

  return @($rows | ForEach-Object {
    # Some builds answer with a plain string here, others with an object
    # carrying the message alongside. Read both rather than guessing.
    $rr = ''
    if ($null -ne $_.result) {
      if ($_.result -is [string]) { $rr = $_.result }
      elseif ($_.result.result) { $rr = [string]$_.result.result }
    }
    $mins = ''
    try {
      if ($_.creationTime -and $_.endTime) {
        $mins = [string][math]::Round((([datetime]$_.endTime) - ([datetime]$_.creationTime)).TotalMinutes)
      }
    } catch { }
    [pscustomobject]@{
      name   = [string]$_.name
      type   = [string]$_.sessionType
      result = $rr
      state  = [string]$_.state
      start  = & $when $_.creationTime
      end    = & $when $_.endTime
      mins   = $mins
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

$jobs  = @()
$repos = @()
$sess  = @()
$err   = ''
$script:JobsVia = ''
try {
  $conn = Connect-Vbr -Base $base -User $cfg.VbrUser -Pass $cfg.VbrPass -SkipCert $skip
  $jobs  = Get-VbrJobs     -Base $base -Token $conn.Token -Version $conn.Version -SkipCert $skip
  $repos = Get-VbrRepos    -Base $base -Token $conn.Token -Version $conn.Version -SkipCert $skip
  $sess  = Get-VbrSessions -Base $base -Token $conn.Token -Version $conn.Version -SkipCert $skip
} catch {
  # Veeam was unreachable. Send anyway, with the error, so the kartabl
  # knows its numbers are stale. Sending nothing is silence, and silence
  # looks exactly like "everything is fine".
  $err = $_.Exception.Message
}

# When /jobs/states is unavailable, each job comes back without its last
# result -- a table of names and blank verdicts, which is worse than no
# table. But the sessions endpoint answered, and a session carries the
# verdict. So: for each job, find its newest session by name and take the
# result, state and run time from there.
#
# This is why it matters: on this customer's build /jobs/states returns
# HTTP 500 ("The value of enum EJobStatus is not supported ... Actual
# value was Stopped") -- a bug inside Veeam's own serializer, nothing we
# can fix from outside. The sessions route is unaffected.
function Add-SessionResults {
  param($Jobs, $Sessions)
  if (-not $Jobs -or -not $Sessions) { return $Jobs }

  # newest session per job name
  $newest = @{}
  foreach ($x in $Sessions) {
    $n = [string]$x.name
    if (-not $n) { continue }
    $cur = $newest[$n]
    if (-not $cur -or ([string]$x.start) -gt ([string]$cur.start)) { $newest[$n] = $x }
  }

  foreach ($j in $Jobs) {
    $x = $newest[[string]$j.name]
    if (-not $x) { continue }
    if (-not $j.result) { $j.result = $x.result }
    if (-not $j.state)  { $j.state  = $x.state }
    if (-not $j.last)   { $j.last   = $x.start }
  }
  return $Jobs
}

if ($script:JobsVia -eq 'jobs') {
  $jobs = Add-SessionResults -Jobs $jobs -Sessions $sess
  if (@($sess).Count -gt 0) { $script:JobsVia = 'jobs+sessions' }
}

$payload = @{
  host  = [string]$cfg.VbrHost
  # The server keeps this short, so the note is short: the README says
  # what "via /jobs" means (that API version has no job states, so the
  # result column stays blank).
  agent = "veeam-push.ps1 / $($env:COMPUTERNAME)" +
          $(switch ($script:JobsVia) {
              'jobs'          { ' (via /jobs)' }
              'jobs+sessions' { ' (via /jobs + sessions)' }
              default         { '' }
            })
  error = $err
  # @() matters: with a single job PowerShell unrolls the array and
  # ConvertTo-Json writes an object instead of a list -- which the server
  # reads as "no jobs came".
  jobs  = @($jobs)
  repos = @($repos)
  sessions = @($sess)
} | ConvertTo-Json -Depth 5 -Compress

try {
  $res = Invoke-RestMethod -Uri $cfg.PushUrl -Method POST -TimeoutSec 60 -UseBasicParsing `
    -ContentType 'application/json; charset=utf-8' `
    -Headers @{ 'x-veeam-key' = $cfg.PushKey } `
    -Body ([Text.Encoding]::UTF8.GetBytes($payload))
  if ($err) { Write-Output "Sent, but Veeam errored: $err" }
  else {
    $via = if ($script:JobsVia -and $script:JobsVia -ne 'jobs/states') { " [$($script:JobsVia)]" } else { '' }
    Write-Output "Sent: $($res.jobs) job(s), $(@($repos).Count) repo(s), $(@($sess).Count) session(s)$via"
  }
} catch {
  # Write-Error throws under ErrorActionPreference=Stop, so the next line
  # never runs and the Scheduled Task never sees the exit code -- the
  # failure would stay silent.
  Write-Warning "Push to kartabl failed: $($_.Exception.Message)"
  exit 1
}
