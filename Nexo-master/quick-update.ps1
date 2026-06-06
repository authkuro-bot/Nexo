# ============================================
# 🚀 Quick Update Frontend
# ============================================
# Commit GitHub → Deploy Frontend only
# ============================================

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   ⚡ QUICK FRONTEND UPDATE             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master"
$domain = "nexoai-flax.vercel.app"
$originalPath = Get-Location

Set-Location $projectPath

# ============================================
# Git Commit & Push
# ============================================
Write-Host "📦 Git Status..." -ForegroundColor Yellow
Write-Host ""

$gitStatus = git status --porcelain 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Git not initialized!" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($gitStatus)) {
    Write-Host "✓ No changes to commit" -ForegroundColor Green
} else {
    Write-Host "Changes:" -ForegroundColor Gray
    git status --short | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    Write-Host ""
    
    Write-Host "📝 Commit message (Enter for default):" -ForegroundColor Yellow
    $commitMsg = Read-Host "Message"
    
    if ([string]::IsNullOrWhiteSpace($commitMsg)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $commitMsg = "Quick update - $timestamp"
    }
    
    Write-Host ""
    Write-Host "💾 Committing..." -ForegroundColor Gray
    git add .
    git commit -m $commitMsg
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Commit failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✓ Committed: $commitMsg" -ForegroundColor Green
}

Write-Host ""
Write-Host "🌐 Pushing to GitHub..." -ForegroundColor Gray

$currentBranch = git branch --show-current 2>&1
git push origin $currentBranch

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Push failed (continuing...)" -ForegroundColor Yellow
} else {
    Write-Host "✓ Pushed to origin/$currentBranch" -ForegroundColor Green
}

# ============================================
# Deploy to Vercel
# ============================================
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  🌐 Deploying to Vercel                ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

$frontendPath = "$projectPath\app"

if (!(Test-Path $frontendPath)) {
    Write-Host "❌ Frontend path not found!" -ForegroundColor Red
    exit 1
}

Set-Location $frontendPath

Write-Host "🚀 Deploying..." -ForegroundColor Cyan
Write-Host ""

vercel --prod --yes

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    Set-Location $originalPath
    exit 1
}

Write-Host ""
Write-Host "✅ Deployed to: https://$domain" -ForegroundColor Green
Write-Host ""

Set-Location $originalPath

Write-Host "🎉 Update complete!" -ForegroundColor Green
Write-Host ""
