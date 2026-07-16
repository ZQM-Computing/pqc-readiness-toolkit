<#
.SYNOPSIS
Build OpenQuantumSafe/liboqs on Windows using MSVC/CMake.
#>

param(
  [string]$LiboqsDir,
  [switch]$WithOpenSSLProvider
)

$ErrorActionPreference = 'Stop'
if (-not $LiboqsDir) {
  $LiboqsDir = Join-Path $PSScriptRoot '..\vendor\liboqs'
}
Write-Host '[liboqs] target=' $LiboqsDir

# 1. prerequisites
$cmakeExe = 'C:\Program Files\CMake\bin\cmake.exe'
if (-not (Test-Path $cmakeExe)) {
  throw "cmake not found at $cmakeExe"
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  throw 'git not found on PATH'
}
Write-Host '[liboqs] prerequisites OK'

# 2. clone
if (-not (Test-Path $LiboqsDir)) {
  $parent = Split-Path $LiboqsDir -Parent
  if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  git clone --depth 1 https://github.com/open-quantum-safe/liboqs.git $LiboqsDir | Out-Null
}
else {
  Set-Location $LiboqsDir
  git pull --ff-only | Out-Null
}
Set-Location $LiboqsDir
Write-Host '[liboqs] source ready'

# 3. configure
$buildDir = Join-Path $LiboqsDir 'build-windows'
if (-not (Test-Path $buildDir)) { New-Item $buildDir -ItemType Directory | Out-Null }
Set-Location $buildDir

$cmakeArgs = @('-G','Visual Studio 17 2022','-A','x64','-DBUILD_SHARED_LIBS=OFF','-DCMAKE_BUILD_TYPE=Release')
if ($WithOpenSSLProvider) {
  $cmakeArgs += '-DOQS_PROVIDER_BUILD=ON'
}
& $cmakeExe @cmakeArgs .. | Out-Null
Write-Host '[liboqs] configure done'

# 4. build
& $cmakeExe --build . --config Release -j $([Environment]::ProcessorCount) | Out-Null
Write-Host '[liboqs] build done'

# 5. copy artifacts locally
$outDir = Join-Path $PSScriptRoot '..\dist\liboqs'
if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }
New-Item $outDir -ItemType Directory | Out-Null

$srcPatterns = @(
  Join-Path $buildDir 'Release\*.lib'
  Join-Path $buildDir 'Release\*.dll'
)
foreach ($p in $srcPatterns) {
  if (Get-Item $p -ErrorAction SilentlyContinue) {
    Copy-Item $p $outDir -Force
  }
}
Write-Host '[liboqs] artifacts copied to' $outDir
