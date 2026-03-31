# Install Antigravity Agent Bundle
# Run from the bundle root directory (where .agent/ folder is)
# Usage: .\install.ps1 -ProjectPath "C:\path\to\your-project"

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = (Get-Location).Path
)

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Antigravity Agent Bundle Installer" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Validate project path exists
if (-not (Test-Path $ProjectPath)) {
    Write-Host "[ERROR] Project path not found: $ProjectPath" -ForegroundColor Red
    exit 1
}

$bundleDir = Join-Path $PSScriptRoot ".agent"
$targetDir = Join-Path $ProjectPath ".agent"

Write-Host "[1/4] Checking bundle source..." -ForegroundColor Yellow
if (-not (Test-Path $bundleDir)) {
    Write-Host "[ERROR] .agent/ folder not found in bundle. Run this script from the bundle root." -ForegroundColor Red
    exit 1
}
Write-Host "      OK - Bundle found at: $bundleDir" -ForegroundColor Green

Write-Host "[2/4] Copying .agent/ to project..." -ForegroundColor Yellow
if (Test-Path $targetDir) {
    $backup = "$targetDir.backup.$(Get-Date -Format 'yyyyMMdd-HHmm')"
    Write-Host "      Backing up existing .agent/ to $backup" -ForegroundColor Gray
    Copy-Item $targetDir $backup -Recurse -Force
}
Copy-Item $bundleDir $targetDir -Recurse -Force
Write-Host "      OK - Copied to: $targetDir" -ForegroundColor Green

Write-Host "[3/4] Creating project context folder..." -ForegroundColor Yellow
$contextDir = Join-Path $targetDir "context"
if (-not (Test-Path $contextDir)) {
    New-Item -ItemType Directory -Path $contextDir -Force | Out-Null
    Write-Host "      OK - Created: $contextDir" -ForegroundColor Green
} else {
    Write-Host "      SKIP - Already exists: $contextDir" -ForegroundColor Gray
}

Write-Host "[4/4] Creating ERRORS.md log file..." -ForegroundColor Yellow
$errorsFile = Join-Path $ProjectPath "ERRORS.md"
if (-not (Test-Path $errorsFile)) {
    Set-Content -Path $errorsFile -Value "# ERRORS.md — Error Log`n`n> Log errors encountered during development here.`n" -Encoding UTF8
    Write-Host "      OK - Created: $errorsFile" -ForegroundColor Green
} else {
    Write-Host "      SKIP - Already exists" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Installation Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Rename GEMINI.template.md → GEMINI.md (fill in project name)"
Write-Host "  2. Rename START_HERE.template.md → START_HERE.md (fill in tech stack)"
Write-Host "  3. Create context files in .agent/context/ (use /skill project-context-template)"
Write-Host "  4. Open your project in Antigravity IDE"
Write-Host ""
Write-Host "Happy coding! 🚀" -ForegroundColor Cyan
