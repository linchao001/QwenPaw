# Scripts

Run from **repo root**.

## Build wheel (with latest console)

**Linux / macOS / Git Bash:**

```bash
bash scripts/wheel_build.sh
```

**Windows PowerShell:**

```powershell
powershell -ExecutionPolicy Bypass -File scripts/wheel_build.ps1
```

- Builds the console frontend (`console/`), copies `console/dist` to `src/qwenpaw/console/dist`, then builds the wheel. Output: `dist/*.whl`.

## Team install (custom ReMe + qwenpaw)

When PyPI `reme-ai` is too old, build **two wheels** and install with one command (no `pyproject.toml` changes).

**Maintainer — build wheels:**

```bash
bash scripts/team_wheel_build.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts/team_wheel_build.ps1
```

ReMe path: `QWENPAW_REME_SRC=/path/to/ReMe` (bash) or `$env:QWENPAW_REME_SRC = "D:\path\to\ReMe"` (PowerShell).

Output: `dist/qwenpaw-*.whl`, `dist/reme_ai-*.whl`, plus `team_install.ps1`, `team_install.sh`, `INSTALL.txt`. Zip `dist/` and share.

**Team member — install (one command, inside extracted `dist/` folder):**

Requires Git + SSH access to `gitlab.internal.qifeng.ai` (clones into `~/.reme/knowledge_bases/`, directory `zhb_kb`).

```powershell
powershell -ExecutionPolicy Bypass -File .\team_install.ps1
```

```bash
bash ./team_install.sh
```

Skip knowledge-base clone: `QWENPAW_SKIP_KB=1` (bash) or `$env:QWENPAW_SKIP_KB=1` (PowerShell).

Requires Python 3.11–3.13. The install script creates `.venv` by default (`QWENPAW_SKIP_VENV=1` to skip).

## Build website

```bash
bash scripts/website_build.sh
```

- Installs dependencies (pnpm or npm) and runs the Vite build. Output: `website/dist/`.

## Build Docker image

```bash
bash scripts/docker_build.sh [IMAGE_TAG] [EXTRA_ARGS...]
```

- Default tag: `qwenpaw:latest`. Uses `deploy/Dockerfile` (multi-stage: builds console then Python app).
- Example: `bash scripts/docker_build.sh myreg/qwenpaw:v1 --no-cache`.

## Run Test

```bash
# Run all tests
python scripts/run_tests.py

# Run all unit tests
python scripts/run_tests.py -u

# Run unit tests for a specific module
python scripts/run_tests.py -u providers

# Run integration tests
python scripts/run_tests.py -i

# Run all tests and generate a coverage report
python scripts/run_tests.py -a -c

# Run tests in parallel (requires pytest-xdist)
python scripts/run_tests.py -p

# Show help
python scripts/run_tests.py -h
```