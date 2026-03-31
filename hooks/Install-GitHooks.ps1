# Install-GitHooks.ps1
# Cai dat git hooks tu .agent/hooks/ vao .git/hooks/
# Chay: powershell -ExecutionPolicy Bypass -File "c:\Dev\.agent\hooks\Install-GitHooks.ps1"

$ProjectRoot = "c:\Dev\Petshop_Service_Management"
$HooksSource = "c:\Dev\.agent\hooks"
$HooksDest   = "$ProjectRoot\.git\hooks"

Write-Host ""
Write-Host "🔧 Installing Git Hooks for Petshop..." -ForegroundColor Cyan
Write-Host "   Source : $HooksSource"
Write-Host "   Target : $HooksDest"
Write-Host ""

if (-not (Test-Path "$ProjectRoot\.git")) {
    Write-Host "ERROR: .git not found in $ProjectRoot" -ForegroundColor Red
    exit 1
}

$hooks = @("pre-commit", "pre-push")
$installed = 0

foreach ($hook in $hooks) {
    $src  = "$HooksSource\$hook"
    $dest = "$HooksDest\$hook"

    if (-not (Test-Path $src)) {
        Write-Host "  SKIP: $hook (source not found)" -ForegroundColor Yellow
        continue
    }

    if (Test-Path $dest) {
        $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
        Copy-Item $dest "$dest.backup.$ts"
        Write-Host "  Backup: $hook.backup.$ts" -ForegroundColor Gray
    }

    Copy-Item $src $dest -Force
    Write-Host "  OK: $hook installed" -ForegroundColor Green
    $installed++
}

Write-Host ""
if ($installed -eq $hooks.Count) {
    Write-Host "Done! $installed/$($hooks.Count) hooks installed." -ForegroundColor Green
    Write-Host ""
    Write-Host "Hooks installed:" -ForegroundColor Cyan
    Write-Host "  pre-commit  -> checks secrets, TypeScript errors, .env files before commit"
    Write-Host "  pre-push    -> checks build, Prisma schema, blocks direct push to main"
    Write-Host ""
    Write-Host "Tips:" -ForegroundColor Yellow
    Write-Host "  Skip hook once: git commit --no-verify"
    Write-Host "  Update hooks  : re-run this script after editing .agent/hooks/"
} else {
    Write-Host "WARNING: Only $installed/$($hooks.Count) hooks installed." -ForegroundColor Yellow
}
Write-Host ""
