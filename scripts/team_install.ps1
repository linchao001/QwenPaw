# Install qwenpaw + bundled local reme-ai wheels for team members.
#
# From repo:  powershell -ExecutionPolicy Bypass -File scripts/team_install.ps1
# From dist/: powershell -ExecutionPolicy Bypass -File .\team_install.ps1
#
# Options (env):
#   $env:QWENPAW_SKIP_VENV = "1"      Skip virtualenv creation
#   $env:QWENPAW_VENV_DIR = ".venv"   Virtualenv directory
param(
    [string]$DistDir = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$RepoRoot = Split-Path -Parent $ScriptDir

if (-not $DistDir) {
    $wheelsHere = Get-ChildItem -Path $ScriptDir -Filter "reme_ai-*.whl" -ErrorAction SilentlyContinue
    if ($wheelsHere) {
        $DistDir = $ScriptDir
    } else {
        $DistDir = Join-Path $RepoRoot "dist"
    }
}

if ($env:QWENPAW_VENV_DIR) {
    $VenvDir = $env:QWENPAW_VENV_DIR
} elseif ($DistDir -eq $ScriptDir) {
    $VenvDir = Join-Path $DistDir ".venv"
} else {
    $VenvDir = Join-Path $RepoRoot ".venv"
}

$RemeWheel = Get-ChildItem -Path $DistDir -Filter "reme_ai-*.whl" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$QwenpawWheel = Get-ChildItem -Path $DistDir -Filter "qwenpaw-*.whl" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $RemeWheel) {
    Write-Error "[team_install] Missing reme-ai wheel in $DistDir"
}
if (-not $QwenpawWheel) {
    Write-Error "[team_install] Missing qwenpaw wheel in $DistDir"
}

if ($env:QWENPAW_SKIP_VENV -ne "1") {
    if (-not (Test-Path $VenvDir)) {
        Write-Host "[team_install] Creating virtualenv: $VenvDir"
        python -m venv $VenvDir
    }
    & (Join-Path $VenvDir "Scripts\Activate.ps1")
}

Write-Host "[team_install] Installing reme-ai + qwenpaw from $DistDir ..."
python -m pip install --upgrade pip
python -m pip install $RemeWheel.FullName $QwenpawWheel.FullName

$KbSetup = Join-Path $ScriptDir "team_setup_kb.ps1"
if (-not (Test-Path $KbSetup)) {
    Write-Error "[team_install] Missing $KbSetup"
}
. $KbSetup

Write-Host ""
Write-Host "[team_install] Installed versions:"
qwenpaw --version
python -c "import reme; print('reme-ai', reme.__version__)"

Write-Host ""
Write-Host "[team_install] Next steps:"
Write-Host "  qwenpaw init --defaults"
Write-Host "  qwenpaw app"
Write-Host "  # knowledge base: clone into $env:USERPROFILE\.reme\knowledge_bases\ (dir=zhb_kb, kb_id=zhb_kb)"
Write-Host "  # open http://127.0.0.1:8088/"
