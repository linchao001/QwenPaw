# Build team distribution wheels: qwenpaw + local ReMe (reme-ai).
# Run from repo root:
#   powershell -ExecutionPolicy Bypass -File scripts/team_wheel_build.ps1
#
# ReMe checkout path: $env:QWENPAW_REME_SRC (default: ../ReMe)
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$RemeSrc = if ($env:QWENPAW_REME_SRC) { $env:QWENPAW_REME_SRC } else { Join-Path (Split-Path $RepoRoot -Parent) "ReMe" }
$DistDir = Join-Path $RepoRoot "dist"

if (-not (Test-Path (Join-Path $RemeSrc "pyproject.toml"))) {
    Write-Error "[team_wheel_build] ReMe checkout not found: $RemeSrc. Set QWENPAW_REME_SRC."
}

Write-Host "[team_wheel_build] Step 1/2: qwenpaw wheel (includes console frontend)..."
& (Join-Path $RepoRoot "scripts/wheel_build.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[team_wheel_build] Step 2/2: reme-ai wheel from $RemeSrc ..."
python -m pip install --quiet build
Push-Location $RemeSrc
try {
    python -m build --wheel --outdir $DistDir
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}

& (Join-Path $RepoRoot "scripts/team_pack_dist.ps1") -DistDir $DistDir -ScriptsDir (Join-Path $RepoRoot "scripts")

$installCmd = "powershell -ExecutionPolicy Bypass -File `"$DistDir\team_install.ps1`""

Write-Host ""
Write-Host "[team_wheel_build] Done. Package directory: $DistDir"
Get-ChildItem $DistDir -Filter "*.whl" | ForEach-Object { Write-Host "  $($_.Name)" }
Write-Host "  team_install.ps1"
Write-Host "  team_install.sh"
Write-Host "  INSTALL.txt"
Write-Host ""
Write-Host "Team install (one command, after cd to dist):"
Write-Host "  cd $DistDir"
Write-Host "  powershell -ExecutionPolicy Bypass -File .\team_install.ps1"
Write-Host ""
Write-Host "Or copy-paste:"
Write-Host "  $installCmd"
