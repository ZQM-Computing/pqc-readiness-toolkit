<#
.SYNOPSIS
PQC readiness discovery for Windows endpoints.
#>

$ErrorActionPreference = 'SilentlyContinue'
$evidenceDir = Join-Path $PSScriptRoot '..\evidence'
$null = New-Item -Path $evidenceDir -ItemType Directory -Force

function Write-Evidence {
    param([string]$Path, [string]$Content)
    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
    Write-Host "  wrote $(Split-Path $Path)"
}

# CNG certificate inventory
$cng = Get-Certificate -CertStoreLocation Cert:\LocalMachine\My | Where-Object { $_.PublicKey.Key.KeySize -gt 0 }
$cngRows = foreach ($c in $cng) {
    [pscustomobject]@{
        Store = 'LocalMachine\My'
        Thumbprint = $c.Thumbprint
        Subject = $c.Subject
        Algorithm = $c.PublicKey.Key.Algorithm
        KeySize = $c.PublicKey.Key.KeySize
        FriendlyName = $c.FriendlyName
    }
}
Write-Evidence (Join-Path $evidenceDir 'pqc_cng_keys.json') ($cngRows | ConvertTo-Json -Depth 5)

# Schannel TLS registry enablement
$tlsRows = [ordered]@{ TLS_12_Server = 'Unknown'; TLS_13_Server = 'Unknown'; CipherSuites = @() }
if (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -ErrorAction SilentlyContinue) { $tlsRows.TLS_12_Server = 'Enabled' }
if (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -ErrorAction SilentlyContinue) { $tlsRows.TLS_13_Server = 'Enabled' }
$cipherPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
if (Test-Path $cipherPath) { $tlsRows.CipherSuites = Get-ChildItem $cipherPath | Select-Object -ExpandProperty Name }
Write-Evidence (Join-Path $evidenceDir 'pqc_tls_schannel.json') ([pscustomobject]$tlsRows | ConvertTo-Json -Depth 5)

# BitLocker status
$bitlocker = Get-BitLockerVolume -ErrorAction SilentlyContinue
$blRows = foreach ($v in $bitlocker) {
    $kp = $v.KeyProtector | Select-Object KeyProtectorType,RecoveryPassword,Password,Name
    [pscustomobject]@{ Drive = $v.MountPoint; EncryptionMethod = $v.EncryptionMethod; KeyProtectors = $kp }
}
Write-Evidence (Join-Path $evidenceDir 'pqc_bitlocker.json') ($blRows | ConvertTo-Json -Depth 6)

# Code-signing certificates
$signEku = '1.3.6.1.5.5.7.3.3'
$codeSign = $cng | Where-Object { $_.Extensions | Where-Object { $_.Oid.Value -eq $signEku } }
$csRows = foreach ($c in $codeSign) {
    [pscustomobject]@{ Thumbprint = $c.Thumbprint; NotAfter = $c.NotAfter; HasPrivateKey = $c.HasPrivateKey }
}
Write-Evidence (Join-Path $evidenceDir 'pqc_codesign_certs.json') ($csRows | ConvertTo-Json -Depth 5)

# CA roots/intermediate counts
$rootCAs = Get-Certificate -CertStoreLocation Cert:\LocalMachine\Root
$intCAs = Get-Certificate -CertStoreLocation Cert:\LocalMachine\CA
Write-Evidence (Join-Path $evidenceDir 'pqc_ca_roots.json') ([pscustomobject]@{ RootCount = $rootCAs.Count; IntermediateCount = $intCAs.Count } | ConvertTo-Json)

# Algorithm inventory
$algos = $cng | Group-Object { $_.PublicKey.Key.Algorithm } | Sort-Object Count -Descending
$algoRows = foreach ($a in $algos) { [pscustomobject]@{ Algorithm = $a.Name; Count = $a.Count } }
Write-Evidence (Join-Path $evidenceDir 'pqc_algorithm_counts.json') ($algoRows | ConvertTo-Json -Depth 5)

$legacy = certutil -store My
Write-Evidence (Join-Path $evidenceDir 'pqc_legacy_certutil.txt') $legacy

# Read-only staged pilot inventory for Kyber/Dilithium candidates.
# Does not write or replace certs; evaluates hybrid/PQC readiness gaps.
$kems = @('kyber','dilithium','ml-kem','ml-dsa')
$matches = @()
foreach ($c in $cng) {
    $subject = ($c.Subject ?? '').ToLower()
    $friendly = ($c.FriendlyName ?? '').ToLower()
    $text = "$subject $friendly"
    foreach ($k in $kems) {
        if ($text.Contains($k)) {
            $matches += [pscustomobject]@{
                Type    = 'POST_QUANTUM_CANDIDATE'
                Store   = 'LocalMachine\My'
                Thumb   = $c.Thumbprint
                Subject = $c.Subject
                Algo    = $c.PublicKey.Key.Algorithm
                Reason  = "keyword_match:$k"
            }
        }
    }
}
$knownHybridAlgos = @(
    'OQS_ML_KEM_768',
    'OQS_ML_KEM_1024',
    'OQS_ML_DSA_44',
    'OQS_ML_DSA_65',
    'OQS_ML_DSA_87'
)
foreach ($a in $knownHybridAlgos) {
    $hits = $cng | Where-Object { $_.PublicKey.Key.Algorithm -eq $a }
    foreach ($c in $hits) {
        $matches += [pscustomobject]@{
            Type    = 'HYBRID_OQS_ALGORITHM'
            Store   = 'LocalMachine\My'
            Thumb   = $c.Thumbprint
            Subject = $c.Subject
            Algo    = $a
            Reason  = 'algorithm_enumeration'
        }
    }
}
Write-Evidence (Join-Path $evidenceDir 'pqc_pilot_kyber_dilithium_candidates.json') ($matches | ConvertTo-Json -Depth 5)

Write-Host "`nDiscovery complete. Evidence files written to"
Write-Output $evidenceDir
