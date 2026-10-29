param(
  [string]$ApiUrl = "https://cuid-arte-gamma.vercel.app/api/v1",
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot

try {
  if (-not $SkipBuild) {
    Write-Host "==> flutter pub get"
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get fallo" }

    Write-Host "==> flutter build web (API_URL=$ApiUrl)"
    flutter build web --release --dart-define=API_URL="$ApiUrl"
    if ($LASTEXITCODE -ne 0) { throw "flutter build web fallo" }
  }

  Write-Host "==> Publicando build/web en Vercel"
  npx --yes vercel deploy build/web --prod
  if ($LASTEXITCODE -ne 0) { throw "vercel deploy fallo" }
}
finally {
  Pop-Location
}
