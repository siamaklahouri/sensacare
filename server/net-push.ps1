<#
  Network scan + traffic counters  ->  SLTech kartabl
  ===============================================================
  Runs on a Windows box INSIDE your network. Sweeps the address range
  you give it, works out what each live address is, reads the byte
  counters of whatever speaks SNMP, and pushes the lot to the kartabl.

  Why this direction: the sltech server sits outside your network and
  cannot reach 192.168.x.x. Having it scan from outside would mean
  opening your network to the internet -- far too high a price for a
  usage table. This way nothing is opened: the connection always goes
  from the inside out, exactly like veeam-push.ps1 already does.

  What is sent: the addresses that answered, their DNS names, which
  common ports are open, what SNMP says the device is, and the byte
  counters of the ports you asked for. No passwords, no file contents,
  nothing about what anybody browsed.

  Nothing here asks for a Windows or domain login. The script reads
  from the network devices, not from the PCs.

  Deliberately ASCII only. Windows PowerShell 5.1 reads a .ps1 with the
  system ANSI codepage unless the file carries a UTF-8 BOM, and a BOM
  is lost the first time somebody saves the file in Notepad.

  Setup instructions (Persian): net-push.README.md, next to this file.
#>

[CmdletBinding()]
param(
  [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not $ConfigPath -or $ConfigPath -eq '') {
  $ConfigPath = Join-Path $PSScriptRoot 'net-push.json'
}
if (-not (Test-Path $ConfigPath)) {
  throw "Config file not found: $ConfigPath"
}
$cfg = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json

$Url   = [string]$cfg.url            # https://sltech.ir/api/kartabl/netuse/push
$Key   = [string]$cfg.key            # the key the admin panel printed once
# One range, or many. All three of these work:
#   "range":  "10.170.10.0/24"
#   "range":  "10.170.10.0/24, 10.170.20.0/24"
#   "ranges": ["10.170.10.0/24", "10.170.20.0/24"]
$Ranges = @()
foreach ($r in @($cfg.range) + @($cfg.ranges)) {
  if (-not $r) { continue }
  foreach ($one in ([string]$r).Split(',')) {
    $one = $one.Trim()
    if ($one) { $Ranges += $one }
  }
}
$Comm  = if ($cfg.community) { [string]$cfg.community } else { 'public' }
$Wide  = if ($cfg.parallel)  { [int]$cfg.parallel }     else { 32 }
$Wait  = if ($cfg.timeoutMs) { [int]$cfg.timeoutMs }    else { 500 }
# Ports to read counters from, per device:  { "192.168.1.1": [1] }
$Want  = $cfg.counters

if (-not $Url -or -not $Key -or $Ranges.Count -eq 0) {
  throw 'url, key and range are all required in the config file.'
}

# ---------------------------------------------------------------- range
function Expand-Range([string] $text) {
  $t = $text.Trim()
  $toNum = {
    param($ip)
    $p = $ip.Split('.')
    if ($p.Count -ne 4) { return -1 }
    [int64]$n = 0
    foreach ($x in $p) {
      $v = 0
      if (-not [int]::TryParse($x, [ref]$v)) { return -1 }
      if ($v -lt 0 -or $v -gt 255) { return -1 }
      $n = $n * 256 + $v
    }
    return $n
  }
  $toIp = {
    param($n)
    '{0}.{1}.{2}.{3}' -f (($n -shr 24) -band 255), (($n -shr 16) -band 255),
                         (($n -shr 8) -band 255), ($n -band 255)
  }

  $a = -1; $b = -1
  if ($t -match '^(.+)/(\d+)$') {
    $base = & $toNum $Matches[1]
    $bits = [int]$Matches[2]
    if ($base -lt 0 -or $bits -lt 8 -or $bits -gt 32) { throw "Bad range: $t" }
    $size = [math]::Pow(2, 32 - $bits)
    $net  = [int64]([math]::Floor($base / $size) * $size)
    if ($size -gt 2) { $a = $net + 1; $b = $net + $size - 2 }
    else             { $a = $net;     $b = $net + $size - 1 }
  }
  elseif ($t -match '^(.+?)-(.+)$') {
    $a = & $toNum $Matches[1]
    $tail = $Matches[2]
    if ($tail -match '^\d{1,3}$') { $b = $a - ($a % 256) + [int]$tail }
    else { $b = & $toNum $tail }
  }
  else { $a = & $toNum $t; $b = $a }

  if ($a -lt 0 -or $b -lt $a) { throw "Bad range: $t" }
  if (($b - $a + 1) -gt 1024) { throw "Range too big: $($b - $a + 1) addresses, limit is 1024." }

  $out = New-Object System.Collections.ArrayList
  for ($i = $a; $i -le $b; $i++) { [void]$out.Add((& $toIp $i)) }
  return $out
}

# ------------------------------------------------------------ tcp probe
function Test-Port([string] $ip, [int] $port, [int] $ms) {
  $c = New-Object System.Net.Sockets.TcpClient
  try {
    $r = $c.BeginConnect($ip, $port, $null, $null)
    if (-not $r.AsyncWaitHandle.WaitOne($ms, $false)) { return $false }
    $c.EndConnect($r) | Out-Null
    return $true
  } catch { return $false }
  finally { try { $c.Close() } catch { } }
}

# ----------------------------------------------------------------- snmp
# A minimal SNMP v2c GET. No module to install: the packet is a few
# nested BER records and the answer is read back the same way.
function BerLen([int] $n) {
  if ($n -lt 128) { return ,([byte]$n) }
  $b = New-Object System.Collections.ArrayList
  $x = $n
  while ($x -gt 0) { [void]$b.Insert(0, [byte]($x -band 255)); $x = [math]::Floor($x / 256) }
  $out = New-Object System.Collections.ArrayList
  [void]$out.Add([byte](128 + $b.Count))
  foreach ($y in $b) { [void]$out.Add($y) }
  return $out.ToArray()
}
function BerTlv([byte] $type, $body) {
  $out = New-Object System.Collections.ArrayList
  [void]$out.Add($type)
  foreach ($x in (BerLen $body.Count)) { [void]$out.Add($x) }
  foreach ($x in $body) { [void]$out.Add($x) }
  return $out.ToArray()
}
function BerInt([int] $n) {
  $b = New-Object System.Collections.ArrayList
  $x = $n
  if ($x -eq 0) { [void]$b.Add([byte]0) }
  while ($x -gt 0) { [void]$b.Insert(0, [byte]($x -band 255)); $x = [math]::Floor($x / 256) }
  if ($b[0] -ge 128) { [void]$b.Insert(0, [byte]0) }
  return BerTlv 2 $b.ToArray()
}
function BerOid([string] $oid) {
  $p = $oid.Split('.')
  $b = New-Object System.Collections.ArrayList
  [void]$b.Add([byte](40 * [int]$p[0] + [int]$p[1]))
  for ($i = 2; $i -lt $p.Count; $i++) {
    $v = [int]$p[$i]
    $chunk = New-Object System.Collections.ArrayList
    [void]$chunk.Add([byte]($v -band 127))
    $v = [math]::Floor($v / 128)
    while ($v -gt 0) {
      [void]$chunk.Insert(0, [byte](($v -band 127) -bor 128))
      $v = [math]::Floor($v / 128)
    }
    foreach ($c in $chunk) { [void]$b.Add($c) }
  }
  return BerTlv 6 $b.ToArray()
}

# Reads one TLV, returns @{ type; body; next }
function BerRead($buf, [int] $i) {
  $type = $buf[$i]
  $j = $i + 1
  $n = $buf[$j]; $j++
  if ($n -ge 128) {
    $k = $n - 128
    $n = 0
    for ($x = 0; $x -lt $k; $x++) { $n = $n * 256 + $buf[$j]; $j++ }
  }
  $body = New-Object byte[] $n
  if ($n -gt 0) { [Array]::Copy($buf, $j, $body, 0, $n) }
  return @{ type = $type; body = $body; next = $j + $n }
}
function BerNum($bytes) {
  [decimal]$n = 0
  foreach ($b in $bytes) { $n = $n * 256 + $b }
  return $n
}

function Snmp-Get([string] $ip, [string] $community, [string[]] $oids, [int] $ms) {
  $req = Get-Random -Minimum 1 -Maximum 2000000
  $binds = New-Object System.Collections.ArrayList
  foreach ($o in $oids) {
    $one = New-Object System.Collections.ArrayList
    foreach ($x in (BerOid $o))              { [void]$one.Add($x) }
    foreach ($x in (BerTlv 5 (New-Object byte[] 0))) { [void]$one.Add($x) }
    foreach ($x in (BerTlv 48 $one.ToArray())) { [void]$binds.Add($x) }
  }
  $pdu = New-Object System.Collections.ArrayList
  foreach ($x in (BerInt $req)) { [void]$pdu.Add($x) }
  foreach ($x in (BerInt 0))    { [void]$pdu.Add($x) }
  foreach ($x in (BerInt 0))    { [void]$pdu.Add($x) }
  foreach ($x in (BerTlv 48 $binds.ToArray())) { [void]$pdu.Add($x) }

  $msg = New-Object System.Collections.ArrayList
  foreach ($x in (BerInt 1)) { [void]$msg.Add($x) }
  $cb = [Text.Encoding]::ASCII.GetBytes($community)
  foreach ($x in (BerTlv 4 $cb)) { [void]$msg.Add($x) }
  foreach ($x in (BerTlv 160 $pdu.ToArray())) { [void]$msg.Add($x) }   # 0xA0 = GET
  $packet = BerTlv 48 $msg.ToArray()

  $udp = New-Object System.Net.Sockets.UdpClient
  try {
    $udp.Client.ReceiveTimeout = $ms
    [void]$udp.Send($packet, $packet.Length, $ip, 161)
    $ep = New-Object System.Net.IPEndPoint([Net.IPAddress]::Any, 0)
    $buf = $udp.Receive([ref]$ep)
  } catch { return $null }
  finally { try { $udp.Close() } catch { } }

  try {
    $m = BerRead $buf 0
    $i = $m.next - $m.body.Count                   # first byte inside the message
    $ver = BerRead $buf $i;      $i = $ver.next
    $com = BerRead $buf $i;      $i = $com.next
    $pduR = BerRead $buf $i
    $j = $pduR.next - $pduR.body.Count
    $id  = BerRead $buf $j; $j = $id.next
    $e1  = BerRead $buf $j; $j = $e1.next
    $e2  = BerRead $buf $j; $j = $e2.next
    $vbs = BerRead $buf $j
    $k = $vbs.next - $vbs.body.Count
    $out = New-Object System.Collections.ArrayList
    while ($k -lt $vbs.next) {
      $vb = BerRead $buf $k
      $nm = BerRead $buf ($vb.next - $vb.body.Count)
      $vl = BerRead $buf $nm.next
      if ($vl.type -eq 4) { [void]$out.Add([Text.Encoding]::UTF8.GetString($vl.body)) }
      elseif ($vl.type -eq 5 -or $vl.type -ge 128) { [void]$out.Add($null) }
      else { [void]$out.Add((BerNum $vl.body)) }
      $k = $vb.next
    }
    return $out
  } catch { return $null }
}

# ------------------------------------------------------------- the scan
$PORTS = @(
  @{ p = 80;   t = 'web' },      @{ p = 443;  t = 'web-tls' },
  @{ p = 22;   t = 'ssh' },      @{ p = 23;   t = 'telnet' },
  @{ p = 8291; t = 'winbox' },   @{ p = 8728; t = 'mikrotik-api' },
  @{ p = 4370; t = 'attendance' },
  @{ p = 445;  t = 'windows' },  @{ p = 3389; t = 'rdp' },
  @{ p = 9100; t = 'printer' }
)

# A whole /24 is 254 addresses, and asking each one ten questions in a
# row takes minutes. So: ping everything at once first, and only ask the
# rest of the questions of the addresses that answered.
function Ping-Many([string[]] $ips, [int] $ms) {
  $out = New-Object System.Collections.ArrayList
  $batch = 64
  for ($i = 0; $i -lt $ips.Count; $i += $batch) {
    $last  = [math]::Min($i + $batch - 1, $ips.Count - 1)
    $slice = $ips[$i..$last]
    $pings = @()
    $tasks = @()
    foreach ($ip in $slice) {
      $p = New-Object System.Net.NetworkInformation.Ping
      $pings += $p
      $tasks += $p.SendPingAsync($ip, $ms)
    }
    try { [void][Threading.Tasks.Task]::WaitAll($tasks, $ms + 2000) } catch { }
    for ($k = 0; $k -lt $slice.Count; $k++) {
      try {
        if ($tasks[$k].IsCompleted -and $tasks[$k].Result.Status -eq 'Success') {
          [void]$out.Add($slice[$k])
        }
      } catch { }
      try { $pings[$k].Dispose() } catch { }
    }
  }
  return $out
}

$hosts = New-Object System.Collections.ArrayList
foreach ($Range in $Ranges) {
  $list = Expand-Range $Range
  Write-Host ("Scanning {0} ({1} addresses) ..." -f $Range, $list.Count)

  $alive = Ping-Many $list $Wait
  Write-Host ("  {0} answered ping" -f $alive.Count)

  # A router that drops ICMP would be missed, and the router is the one
  # address that actually matters here. So the usual gateway spots are
  # always asked, answered or not.
  $ask = New-Object System.Collections.ArrayList
  foreach ($ip in $alive) { [void]$ask.Add($ip) }
  foreach ($g in @($list[0], $list[$list.Count - 1])) {
    if (-not $ask.Contains($g)) { [void]$ask.Add($g) }
  }

  foreach ($ip in $ask) {
    $open = New-Object System.Collections.ArrayList
    foreach ($x in $PORTS) {
      if (Test-Port $ip $x.p $Wait) { [void]$open.Add(@{ port = $x.p; t = $x.t }) }
    }

    $snmp = $null
    $d = Snmp-Get $ip $Comm @('1.3.6.1.2.1.1.1.0', '1.3.6.1.2.1.1.5.0') ([math]::Max($Wait, 700))
    if ($d -and $d.Count -ge 1 -and $d[0]) {
      $snmp = @{ community = $Comm; descr = [string]$d[0]; name = [string]$d[1] }
    }

    # Asked only because it might be a gateway, and it is not there.
    if (-not $alive.Contains($ip) -and $open.Count -eq 0 -and -not $snmp) { continue }

    $name = ''
    try { $name = [Net.Dns]::GetHostEntry($ip).HostName } catch { }

    [void]$hosts.Add(@{ ip = $ip; host = $name; ports = $open.ToArray(); snmp = $snmp })
  }
}
Write-Host ("Found {0} device(s) in {1} range(s)." -f $hosts.Count, $Ranges.Count)

# --------------------------------------------------------- the counters
# For each device/port the config asks for, read ifHCInOctets and
# ifHCOutOctets (64-bit). Falls back to the 32-bit pair when the device
# has no high-capacity counters.
$samples = New-Object System.Collections.ArrayList
if ($Want) {
  foreach ($prop in $Want.PSObject.Properties) {
    $ip = $prop.Name
    foreach ($idx in @($prop.Value)) {
      $i = [int]$idx
      $r = Snmp-Get $ip $Comm @(
            "1.3.6.1.2.1.31.1.1.1.6.$i", "1.3.6.1.2.1.31.1.1.1.10.$i",
            "1.3.6.1.2.1.2.2.1.10.$i",   "1.3.6.1.2.1.2.2.1.16.$i",
            "1.3.6.1.2.1.31.1.1.1.1.$i") 1500
      if (-not $r) { Write-Host ("  no answer from {0} port {1}" -f $ip, $i); continue }
      $in  = if ($r[0] -ne $null) { $r[0] } else { $r[2] }
      $out = if ($r[1] -ne $null) { $r[1] } else { $r[3] }
      if ($in -eq $null -or $out -eq $null) { continue }
      [void]$samples.Add(@{ ip = $ip; iface = $i; ifname = [string]$r[4];
                            'in' = [int64]$in; out = [int64]$out })
    }
  }
  Write-Host ("Read {0} counter(s)." -f $samples.Count)
}

# ------------------------------------------------------------- the push
$body = @{
  range   = ($Ranges -join ', ')
  by      = $env:COMPUTERNAME
  hosts   = $hosts.ToArray()
  samples = $samples.ToArray()
} | ConvertTo-Json -Depth 6 -Compress

$res = Invoke-RestMethod -Method Post -Uri $Url -Body $body `
         -ContentType 'application/json; charset=utf-8' `
         -Headers @{ 'x-net-key' = $Key }
Write-Host ("Sent. kartabl says: {0}" -f ($res | ConvertTo-Json -Compress))
