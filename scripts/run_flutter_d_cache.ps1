param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$FlutterArgs
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$cacheRoot = Join-Path $projectRoot ".cache"
$tempRoot = Join-Path $cacheRoot "temp"
$gradleRoot = Join-Path $cacheRoot "gradle"
$pubRoot = Join-Path $cacheRoot "pub"

$paths = @($cacheRoot, $tempRoot, $gradleRoot, $pubRoot)
foreach ($path in $paths) {
  if (-not (Test-Path $path)) {
    New-Item -ItemType Directory -Path $path | Out-Null
  }
}

$env:TEMP = $tempRoot
$env:TMP = $tempRoot
$env:GRADLE_USER_HOME = $gradleRoot
$env:PUB_CACHE = $pubRoot

if (-not $FlutterArgs -or $FlutterArgs.Count -eq 0) {
  $FlutterArgs = @("run")
}

Write-Host "Using D-drive project cache paths:" -ForegroundColor Cyan
Write-Host "TEMP=$env:TEMP"
Write-Host "GRADLE_USER_HOME=$env:GRADLE_USER_HOME"
Write-Host "PUB_CACHE=$env:PUB_CACHE"
Write-Host ""

& flutter @FlutterArgs
exit $LASTEXITCODE
