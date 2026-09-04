# Build a full wheel package including the latest console frontend.
# Run from repo root:
#   powershell -ExecutionPolicy Bypass -File scripts/wheel_build.ps1
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

$ConsoleDir = Join-Path $RepoRoot "console"
$ConsoleDest = Join-Path $RepoRoot "src/qwenpaw/console"
$DocsSrc = Join-Path $RepoRoot "website/public/docs"
$DocsDest = Join-Path $RepoRoot "src/qwenpaw/docs"
$DistDir = Join-Path $RepoRoot "dist"

Write-Host "[wheel_build] Building console frontend..."
Push-Location $ConsoleDir
try {
    npm ci
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    npm run build
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}

Write-Host "[wheel_build] Copying console/dist/* -> src/qwenpaw/console/..."
if (Test-Path $ConsoleDest) {
    Get-ChildItem $ConsoleDest -Force | Remove-Item -Recurse -Force
} else {
    New-Item -ItemType Directory -Path $ConsoleDest -Force | Out-Null
}
Copy-Item -Path (Join-Path $ConsoleDir "dist/*") -Destination $ConsoleDest -Recurse -Force

Write-Host "[wheel_build] Bundling website docs into package..."
if (Test-Path $DocsDest) {
    Remove-Item $DocsDest -Recurse -Force
}
New-Item -ItemType Directory -Path $DocsDest -Force | Out-Null
Copy-Item -Path (Join-Path $DocsSrc "*.md") -Destination $DocsDest -Force

Write-Host "[wheel_build] Building wheel..."
python -m pip install --quiet build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (Test-Path $DistDir) {
    Get-ChildItem $DistDir -Force | Remove-Item -Recurse -Force
} else {
    New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
}

python -m build --wheel --outdir $DistDir .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[wheel_build] Done. Wheel(s) in: $DistDir/"
