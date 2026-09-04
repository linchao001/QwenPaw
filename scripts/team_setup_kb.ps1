# Clone / update shared ReMe knowledge base (zhb_kb) for team installs.
# Called from team_install.ps1 (same directory).
$ErrorActionPreference = "Stop"

if ($env:QWENPAW_SKIP_KB -eq "1") {
    Write-Host "[team_install] Skipping knowledge base setup (QWENPAW_SKIP_KB=1)."
    return
}

$KbGitUrl = "git@gitlab.internal.qifeng.ai:qifeng_test/zhb_kb.git"
# Business KB lives under ReMe's knowledge_bases root; directory name == kb_id.
$KbId = "zhb_kb"
$KbRoot = Join-Path $env:USERPROFILE ".reme\knowledge_bases"
$KbPath = Join-Path $KbRoot $KbId
$Branch = "feature/dev-$(Get-Date -Format 'yyyyMMdd')"

function Write-KbCloneError {
    Write-Error @"
[team_install] Failed to set up knowledge base at $KbPath

Please check:
  1. Git is installed and available in PATH
  2. SSH key is loaded and registered on GitLab (gitlab.internal.qifeng.ai)
  3. You have read access to: qifeng_test/zhb_kb

Test SSH:
  ssh -T git@gitlab.internal.qifeng.ai

Clone manually:
  cd $KbRoot
  git clone $KbGitUrl
"@
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "[team_install] Git is required to clone the shared knowledge base ($KbGitUrl)."
}

Write-Host "[team_install] Setting up ReMe knowledge base '$KbId' under $KbRoot"
New-Item -ItemType Directory -Force -Path $KbRoot | Out-Null

# Previous installs used directory name ``zhb``; rename when present.
$LegacyKbPath = Join-Path $KbRoot "zhb"
if (-not (Test-Path $KbPath) -and (Test-Path (Join-Path $LegacyKbPath ".git"))) {
    Write-Host "[team_install] Renaming legacy knowledge base '$LegacyKbPath' -> '$KbPath'"
    Move-Item -Path $LegacyKbPath -Destination $KbPath
}

if (Test-Path (Join-Path $KbPath ".git")) {
    Write-Host "[team_install] Knowledge base repo exists, fetching latest..."
    Push-Location $KbPath
    try {
        git fetch --all --prune
        if ($LASTEXITCODE -ne 0) { Write-KbCloneError }
    } finally {
        Pop-Location
    }
} elseif (Test-Path $KbPath) {
    Write-Error "[team_install] Path exists but is not a git repo: $KbPath"
} else {
    Write-Host "[team_install] Cloning $KbGitUrl into $KbRoot (dir=$KbId) ..."
    # Clone into knowledge_bases so the repo folder name becomes zhb_kb.
    Push-Location $KbRoot
    try {
        git clone $KbGitUrl
        if ($LASTEXITCODE -ne 0) { Write-KbCloneError }
    } finally {
        Pop-Location
    }
    if (-not (Test-Path (Join-Path $KbPath ".git"))) {
        Write-KbCloneError
    }
}

Push-Location $KbPath
try {
    git checkout -b $Branch 2>$null
    if ($LASTEXITCODE -ne 0) {
        git checkout $Branch
        if ($LASTEXITCODE -ne 0) { Write-Error "[team_install] Failed to checkout branch $Branch" }
        Write-Host "[team_install] Checked out existing branch: $Branch"
    } else {
        Write-Host "[team_install] Created local branch: $Branch"
    }
} finally {
    Pop-Location
}

Write-Host "[team_install] Knowledge base ready (kb_id=$KbId, path=$KbPath, branch=$Branch)."
