param(
    [Parameter(Mandatory = $true)]
    [string]$DistDir,
    [Parameter(Mandatory = $true)]
    [string]$ScriptsDir
)

$ErrorActionPreference = "Stop"

Copy-Item (Join-Path $ScriptsDir "team_install.ps1") -Destination $DistDir -Force
Copy-Item (Join-Path $ScriptsDir "team_install.sh") -Destination $DistDir -Force
Copy-Item (Join-Path $ScriptsDir "team_setup_kb.ps1") -Destination $DistDir -Force
Copy-Item (Join-Path $ScriptsDir "team_setup_kb.sh") -Destination $DistDir -Force

$installTxt = @"
QwenPaw team install package
============================

Requires Python 3.11 ~ 3.13, Git, and GitLab SSH access (gitlab.internal.qifeng.ai)

Windows (PowerShell, run inside this folder):
  powershell -ExecutionPolicy Bypass -File .\team_install.ps1

Linux / macOS / Git Bash:
  bash ./team_install.sh

The installer will:
  - install qwenpaw + reme-ai wheels
  - clone zhb_kb into %USERPROFILE%\.reme\knowledge_bases\
    (git@gitlab.internal.qifeng.ai:qifeng_test/zhb_kb.git -> ...\knowledge_bases\zhb_kb)
  - create local branch feature/dev-YYYYMMDD

Skip KB setup: set QWENPAW_SKIP_KB=1 before running the installer.

After install:
  .\.venv\Scripts\Activate.ps1   (Windows)
  source .venv/bin/activate      (Linux/macOS)
  qwenpaw init --defaults
  qwenpaw app
  open http://127.0.0.1:8088/
"@

Set-Content -Path (Join-Path $DistDir "INSTALL.txt") -Value $installTxt -Encoding UTF8

Write-Host "[team_wheel_build] Packaged install scripts -> $DistDir/"
