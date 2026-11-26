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
# Some networks only reach the internet through a proxy. Put it here and
# the report goes that way:  "proxy": "http://10.170.10.9:8080"
$Proxy = if ($cfg.proxy) { [string]$cfg.proxy } else { '' }
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
# All ports of one address at once. One after another meant ten times the
# timeout for every silent address -- five seconds each, and a /24 with a
# handful of live hosts took minutes.
function Test-Ports([string] $ip, $ports, [int] $ms) {
  $cs = @()
  $rs = @()
  foreach ($p in $ports) {
    $c = New-Object System.Net.Sockets.TcpClient
    $cs += $c
    try { $rs += $c.BeginConnect($ip, [int]$p.p, $null, $null) } catch { $rs += $null }
  }
  Start-Sleep -Milliseconds $ms
  $open = New-Object System.Collections.ArrayList
  for ($i = 0; $i -lt $ports.Count; $i++) {
    try {
      if ($rs[$i] -and $rs[$i].IsCompleted -and $cs[$i].Connected) {
        [void]$open.Add(@{ port = [int]$ports[$i].p; t = [string]$ports[$i].t })
      }
    } catch { }
    try { $cs[$i].Close() } catch { }
  }
  return $open
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

# ------------------------------------------------------- device ports
# Which ports does this device have, and how many bytes has each moved?
# Asked index by index rather than by walking the tree: a GET carries
# four questions at once, a walk needs a round trip per answer, and a
# switch has far fewer ports than the tree has branches.
function Get-Ifaces([string] $ip, [string] $community, [int] $ms, [int] $max) {
  $out = New-Object System.Collections.ArrayList
  for ($i = 1; $i -le $max; $i++) {
    $r = Snmp-Get $ip $community @(
          "1.3.6.1.2.1.31.1.1.1.1.$i",     # ifName
          "1.3.6.1.2.1.2.2.1.8.$i",        # ifOperStatus
          "1.3.6.1.2.1.31.1.1.1.6.$i",     # ifHCInOctets
          "1.3.6.1.2.1.31.1.1.1.10.$i") $ms
    if (-not $r) { continue }
    $name = [string]$r[0]
    if (-not $name) {
      # No high-capacity name? Try the plain description before giving up.
      $d = Snmp-Get $ip $community @("1.3.6.1.2.1.2.2.1.2.$i") $ms
      if ($d) { $name = [string]$d[0] }
    }
    if (-not $name) { continue }
    $in  = $r[2]; $out2 = $r[3]
    if ($in -eq $null -or $out2 -eq $null) {
      $o = Snmp-Get $ip $community @("1.3.6.1.2.1.2.2.1.10.$i", "1.3.6.1.2.1.2.2.1.16.$i") $ms
      if ($o) { $in = $o[0]; $out2 = $o[1] }
    }
    if ($in -eq $null -or $out2 -eq $null) { continue }
    [void]$out.Add(@{ i = $i; name = $name; up = ($r[1] -eq 1);
                      'in' = [int64]$in; out = [int64]$out2 })
  }
  return $out
}

# The port that carries the internet is almost always the busiest one
# that is up. A guess, but a good one -- and the kartabl lets a human
# change it afterwards, which is what the next run reads back.
function Pick-Iface($ifaces) {
  $best = $null
  foreach ($f in $ifaces) {
    if (-not $f.up) { continue }
    if ($f.name -match '^(lo|Loopback|Null)') { continue }
    if ($best -eq $null -or ($f.'in' + $f.out) -gt ($best.'in' + $best.out)) { $best = $f }
  }
  return $best
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
    $open = Test-Ports $ip $PORTS $Wait

    $snmp = $null
    $d = Snmp-Get $ip $Comm @('1.3.6.1.2.1.1.1.0', '1.3.6.1.2.1.1.5.0') ([math]::Max($Wait, 700))
    if ($d -and $d.Count -ge 1 -and $d[0]) {
      $snmp = @{ community = $Comm; descr = [string]$d[0]; name = [string]$d[1] }
    }

    # Asked only because it might be a gateway, and it is not there.
    if (-not $alive.Contains($ip) -and $open.Count -eq 0 -and -not $snmp) { continue }

    $name = ''
    try { $name = [Net.Dns]::GetHostEntry($ip).HostName } catch { }

    $ifs = @()
    if ($snmp) { $ifs = @(Get-Ifaces $ip $Comm ([math]::Max($Wait, 700)) 24) }

    [void]$hosts.Add(@{ ip = $ip; host = $name; ports = @($open); snmp = $snmp;
                        ifaces = $ifs })
  }
}
$withSnmp = 0
foreach ($h in $hosts) { if ($h.snmp) { $withSnmp++ } }
Write-Host ("Found {0} device(s) in {1} range(s); {2} answered SNMP." -f `
            $hosts.Count, $Ranges.Count, $withSnmp)
if ($withSnmp -eq 0) {
  Write-Host "  Nothing answered SNMP, so there are no byte counters to read."
  Write-Host ("  Turn SNMP on in the router (read-only, v2c) and make sure its " +
              "community is '{0}', or change `"community`" in net-push.json." -f $Comm)
}

# --------------------------------------------------------- the counters
# Nothing to configure by hand: every device that speaks SNMP reports
# its busiest live port. If the kartabl says otherwise for an address --
# because somebody picked a port there -- that one wins. And "counters"
# in the config file still overrides both.
$chosen = @{}
try {
  $planUrl = $Url -replace '/push$', '/plan'
  $pa = @{ Method = 'Get'; Uri = $planUrl; Headers = @{ 'x-net-key' = $Key } }
  if ($Proxy) { $pa['Proxy'] = $Proxy; $pa['ProxyUseDefaultCredentials'] = $true }
  $plan = Invoke-RestMethod @pa
  if ($plan -and $plan.plan) {
    foreach ($prop in $plan.plan.PSObject.Properties) { $chosen[$prop.Name] = [int]$prop.Value }
  }
} catch { }
if ($Want) {
  foreach ($prop in $Want.PSObject.Properties) {
    foreach ($idx in @($prop.Value)) { $chosen[$prop.Name] = [int]$idx; break }
  }
}

$samples = New-Object System.Collections.ArrayList
foreach ($h in $hosts) {
  if (-not $h.snmp) { continue }
  $ifs = @($h.ifaces)
  if ($ifs.Count -eq 0) { continue }
  $pick = $null
  if ($chosen.ContainsKey($h.ip)) {
    foreach ($f in $ifs) { if ($f.i -eq $chosen[$h.ip]) { $pick = $f } }
  }
  if (-not $pick) { $pick = Pick-Iface $ifs }
  if (-not $pick) { continue }
  [void]$samples.Add(@{ ip = $h.ip; iface = $pick.i; ifname = $pick.name;
                        name = $h.host; 'in' = $pick.'in'; out = $pick.out })
}
Write-Host ("Read {0} counter(s)." -f $samples.Count)

# ------------------------------------------------------------- the push
$body = @{
  range   = ($Ranges -join ', ')
  by      = $env:COMPUTERNAME
  hosts   = $hosts.ToArray()
  samples = $samples.ToArray()
} | ConvertTo-Json -Depth 6 -Compress

$args2 = @{ Method = 'Post'; Uri = $Url; Body = $body
            ContentType = 'application/json; charset=utf-8'
            Headers = @{ 'x-net-key' = $Key } }
if ($Proxy) {
  $args2['Proxy'] = $Proxy
  $args2['ProxyUseDefaultCredentials'] = $true
} else {
  # No proxy in the config: use whatever Windows itself is set to.
  # Invoke-RestMethod does not always pick that up on its own, and on a
  # network where everything goes out through a proxy, "unable to
  # connect" is all you ever see.
  try {
    $sys = [System.Net.WebRequest]::GetSystemWebProxy()
    $via = $sys.GetProxy([Uri]$Url)
    if ($via -and $via.AbsoluteUri -ne ([Uri]$Url).AbsoluteUri) {
      $args2['Proxy'] = $via
      $args2['ProxyUseDefaultCredentials'] = $true
      Write-Host ("Going out through the system proxy: {0}" -f $via)
    }
  } catch { }
}

# One failed send should not cost a sample: the counters only mean
# something next to the previous reading, and the next run is five
# minutes away.
$sent = $false
for ($try = 1; $try -le 3; $try++) {
  try {
    $res = Invoke-RestMethod @args2
    Write-Host ("Sent. kartabl says: {0}" -f ($res | ConvertTo-Json -Compress))
    $sent = $true
    break
  } catch {
    $why = $_.Exception.Message
    if ($try -lt 3) {
      Write-Host ("  attempt {0} failed ({1}); trying again..." -f $try, $why)
      Start-Sleep -Seconds (3 * $try)
    } else {
      Write-Host ("Could not reach the kartabl: {0}" -f $why)
      Write-Host ("  URL: {0}" -f $Url)
      Write-Host ("  From this very machine, try:  Test-NetConnection {0} -Port 443" -f ([Uri]$Url).Host)
      Write-Host "  And:  netsh winhttp show proxy"
      Write-Host "  If this network only goes out through a proxy, add it to net-push.json:"
      Write-Host '    "proxy": "http://PROXY-HOST:PORT"'
    }
  }
}
if (-not $sent) { exit 1 }
