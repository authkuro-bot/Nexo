# ============================================
# Git Commit + Update Frontend to Vercel
# ============================================

$ErrorActionPreference = "Continue"

Write-Host "Git Commit + Deploy Frontend to Vercel" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master"
Set-Location $projectPath

# ============================================
# STEP 1: Check Git Status
# ============================================
Write-Host "Checking git status..." -ForegroundColor Yellow

$gitStatus = git status --porcelain 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Git not initialized!" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($gitStatus)) {
    Write-Host "OK: No changes to commit (working tree clean)" -ForegroundColor Green
    $skipCommit = $true
} else {
    Write-Host "OK: Found changes to commit" -ForegroundColor Green
    $skipCommit = $false
    
    Write-Host ""
    Write-Host "Changed files:" -ForegroundColor Cyan
    git status --short
}

# ============================================
# STEP 2: Git Add & Commit
# ============================================
if (!$skipCommit) {
    Write-Host ""
    Write-Host "Staging changes..." -ForegroundColor Yellow
    
    git add .
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to stage changes!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "OK: All changes staged" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Enter commit message (or press Enter for default):" -ForegroundColor Yellow
    $commitMsg = Read-Host "Message"
    
    if ([string]::IsNullOrWhiteSpace($commitMsg)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $commitMsg = "Update frontend - $timestamp"
    }
    
    Write-Host ""
    Write-Host "Creating commit..." -ForegroundColor Yellow
    git commit -m $commitMsg
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to create commit!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "OK: Commit created: $commitMsg" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Skipping commit (no changes)" -ForegroundColor Gray
}

# ============================================
# STEP 3: Git Push
# ============================================
Write-Host ""
Write-Host "Pushing to remote repository..." -ForegroundColor Yellow

$currentBranch = git branch --show-current 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Could not determine current branch!" -ForegroundColor Red
    exit 1
}

Write-Host "Branch: $currentBranch" -ForegroundColor Gray

git push origin $currentBranch

if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Push failed or no remote configured" -ForegroundColor Yellow
    Write-Host "Continuing with Vercel deployment..." -ForegroundColor Gray
} else {
    Write-Host "OK: Pushed to origin/$currentBranch" -ForegroundColor Green
}

# ============================================
# STEP 4: Check Vercel CLI
# ============================================
Write-Host ""
Write-Host "Checking Vercel CLI..." -ForegroundColor Yellow

$vercelCheck = Get-Command vercel -ErrorAction SilentlyContinue

if (!$vercelCheck) {
    Write-Host "ERROR: Vercel CLI not found!" -ForegroundColor Red
    Write-Host "Install with: npm install -g vercel" -ForegroundColor Yellow
    exit 1
}

Write-Host "OK: Vercel CLI ready" -ForegroundColor Green

# ============================================
# STEP 5: Check Vercel Authentication
# ============================================
Write-Host ""
Write-Host "Checking Vercel authentication..." -ForegroundColor Yellow

$vercelAuth = vercel whoami 2>&1
$vercelLoggedIn = $LASTEXITCODE -eq 0

if (!$vercelLoggedIn) {
    Write-Host "Please login to Vercel..." -ForegroundColor Yellow
    vercel login
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Vercel login failed!" -ForegroundColor Red
        exit 1
    }
    
    $vercelAuth = vercel whoami 2>&1
}

Write-Host "OK: Logged in as: $vercelAuth" -ForegroundColor Green

# ============================================
# STEP 6: Deploy to Vercel
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DEPLOYING TO VERCEL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$frontendPath = "$projectPath\app"

if (!(Test-Path $frontendPath)) {
    Write-Host "ERROR: Frontend path not found: $frontendPath" -ForegroundColor Red
    exit 1
}

Set-Location $frontendPath
Write-Host "Location: $frontendPath" -ForegroundColor Gray

Write-Host ""
Write-Host "Starting Vercel deployment..." -ForegroundColor Yellow
Write-Host "(This may take a few minutes)" -ForegroundColor Gray
Write-Host ""

vercel --prod --yes

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Vercel deployment failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  - Check vercel logs" -ForegroundColor White
    Write-Host "  - Verify project is linked: vercel link" -ForegroundColor White
    Write-Host "  - Try manual deploy: vercel --prod" -ForegroundColor White
    
    Set-Location $projectPath
    exit 1
}

# ============================================
# STEP 7: Get Deployment URL
# ============================================
Write-Host ""
Write-Host "Deployment successful!" -ForegroundColor Green

Write-Host ""
Write-Host "Getting deployment URL..." -ForegroundColor Yellow

$deploymentUrl = vercel ls --limit 1 2>&1 | Select-String -Pattern "https://[^\s]+" | ForEach-Object { $_.Matches[0].Value } | Select-Object -First 1

if ($deploymentUrl) {
    Write-Host ""
    Write-Host "Frontend URL:" -ForegroundColor Cyan
    Write-Host "  $deploymentUrl" -ForegroundColor Blue
    Write-Host ""
    Write-Host "(Click to open or copy the URL above)" -ForegroundColor Gray
}

Set-Location $projectPath

# ============================================
# FINAL SUMMARY
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "UPDATE COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "What was done:" -ForegroundColor Cyan
if (!$skipCommit) {
    Write-Host "  + Git commit created" -ForegroundColor Green
    Write-Host "  + Pushed to remote repository" -ForegroundColor Green
} else {
    Write-Host "  - No changes to commit" -ForegroundColor Gray
}
Write-Host "  + Deployed to Vercel production" -ForegroundColor Green

Write-Host ""
Write-Host "Quick commands:" -ForegroundColor Cyan
Write-Host "  vercel logs            - View deployment logs" -ForegroundColor White
Write-Host "  vercel ls              - List recent deployments" -ForegroundColor White
Write-Host "  git log -1             - View last commit" -ForegroundColor White

Write-Host ""
Write-Host "Frontend is now live!" -ForegroundColor Green
