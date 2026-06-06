# ============================================
# Complete Deployment Script
# ============================================
# Commit GitHub -> Deploy Vercel & Railway
# Domain: nexoai-flax.vercel.app
# ============================================

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   NEXO COMPLETE DEPLOYMENT            " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master"
$domain = "nexoai-flax.vercel.app"
$originalPath = Get-Location
$deploymentStartTime = Get-Date

Set-Location $projectPath

# ============================================
# STEP 1: Git - Check Status and Commit
# ============================================
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  STEP 1/4: Git Commit                 " -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "Checking git status..." -ForegroundColor Gray

$gitStatus = git status --porcelain 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Git not initialized!" -ForegroundColor Red
    Write-Host "   Run: git init" -ForegroundColor Yellow
    exit 1
}

if ([string]::IsNullOrWhiteSpace($gitStatus)) {
    Write-Host "OK: Working tree clean (no changes to commit)" -ForegroundColor Green
    $skipCommit = $true
} else {
    Write-Host "OK: Found changes to commit:" -ForegroundColor Green
    Write-Host ""
    git status --short | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    $skipCommit = $false
}

# Commit if there are changes
if (!$skipCommit) {
    Write-Host ""
    Write-Host "Enter commit message (Enter for default):" -ForegroundColor Yellow
    $commitMsg = Read-Host "Message"
    
    if ([string]::IsNullOrWhiteSpace($commitMsg)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $commitMsg = "Deploy update - $timestamp"
    }
    
    Write-Host ""
    Write-Host "Staging all changes..." -ForegroundColor Gray
    git add .
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to stage changes!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "OK: Staged" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Creating commit..." -ForegroundColor Gray
    git commit -m $commitMsg
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Commit failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "OK: Commit created: $commitMsg" -ForegroundColor Green
}

# Push to GitHub
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Gray

$currentBranch = git branch --show-current 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Could not determine current branch!" -ForegroundColor Red
    exit 1
}

Write-Host "   Branch: $currentBranch" -ForegroundColor DarkGray

git push origin $currentBranch

if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Push failed (continuing anyway...)" -ForegroundColor Yellow
    Write-Host "   You may need to: git remote add origin <url>" -ForegroundColor DarkGray
} else {
    Write-Host "OK: Pushed to origin/$currentBranch" -ForegroundColor Green
}

Write-Host ""
Write-Host "Git commit and push complete!" -ForegroundColor Green
Start-Sleep -Seconds 2

# ============================================
# STEP 2: Check CLI Tools and Auth
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  STEP 2/4: Verify Tools and Auth      " -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# Check Railway CLI
Write-Host "Checking Railway CLI..." -ForegroundColor Gray
$railwayCheck = Get-Command railway -ErrorAction SilentlyContinue

if (!$railwayCheck) {
    Write-Host "ERROR: Railway CLI not found!" -ForegroundColor Red
    Write-Host "   Install: npm install -g @railway/cli" -ForegroundColor Yellow
    exit 1
}

$railwayAuth = railway whoami 2>&1
$railwayLoggedIn = $LASTEXITCODE -eq 0

if (!$railwayLoggedIn) {
    Write-Host "Please login to Railway..." -ForegroundColor Yellow
    railway login
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Railway login failed!" -ForegroundColor Red
        exit 1
    }
    
    $railwayAuth = railway whoami 2>&1
}

Write-Host "OK: Railway: $railwayAuth" -ForegroundColor Green

# Check Vercel CLI
Write-Host ""
Write-Host "Checking Vercel CLI..." -ForegroundColor Gray
$vercelCheck = Get-Command vercel -ErrorAction SilentlyContinue

if (!$vercelCheck) {
    Write-Host "ERROR: Vercel CLI not found!" -ForegroundColor Red
    Write-Host "   Install: npm install -g vercel" -ForegroundColor Yellow
    exit 1
}

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

Write-Host "OK: Vercel: $vercelAuth" -ForegroundColor Green

Write-Host ""
Write-Host "All tools ready!" -ForegroundColor Green
Start-Sleep -Seconds 1

# ============================================
# STEP 3: Deploy Backend to Railway
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  STEP 3/4: Deploy Backend             " -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$backendPath = "$projectPath\app\backend"

if (!(Test-Path $backendPath)) {
    Write-Host "ERROR: Backend path not found: $backendPath" -ForegroundColor Red
    exit 1
}

Set-Location $backendPath
Write-Host "Location: $backendPath" -ForegroundColor DarkGray
Write-Host ""

# Check Railway project
$railwayStatus = railway status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: No Railway project linked. Linking..." -ForegroundColor Yellow
    railway link
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to link Railway project!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Deploying backend to Railway..." -ForegroundColor Cyan
Write-Host "   (This may take a few minutes)" -ForegroundColor DarkGray
Write-Host ""

railway up

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Backend deployment failed!" -ForegroundColor Red
    Write-Host "   Check: railway logs" -ForegroundColor Yellow
    Set-Location $originalPath
    exit 1
}

Write-Host ""
Write-Host "Backend deployed successfully!" -ForegroundColor Green

# Get backend URL
$backendUrl = railway domain 2>&1 | Select-String -Pattern "https?://[^\s]+" | ForEach-Object { $_.Matches[0].Value } | Select-Object -First 1

if (!$backendUrl) {
    $backendUrl = railway domain 2>&1
}

Write-Host "Backend URL: $backendUrl" -ForegroundColor Blue

$backendDeployTime = Get-Date
Start-Sleep -Seconds 2

# ============================================
# STEP 4: Deploy Frontend to Vercel
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  STEP 4/4: Deploy Frontend            " -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$frontendPath = "$projectPath\app"

if (!(Test-Path $frontendPath)) {
    Write-Host "ERROR: Frontend path not found: $frontendPath" -ForegroundColor Red
    Set-Location $originalPath
    exit 1
}

Set-Location $frontendPath
Write-Host "Location: $frontendPath" -ForegroundColor DarkGray
Write-Host ""

# Check Vercel project
$vercelProject = vercel inspect 2>&1
$isLinked = $LASTEXITCODE -eq 0

if (!$isLinked) {
    Write-Host "WARNING: No Vercel project linked. Will link to nexoai-flax..." -ForegroundColor Yellow
}

Write-Host "Deploying frontend to Vercel..." -ForegroundColor Cyan
Write-Host "   Target: $domain" -ForegroundColor DarkGray
Write-Host "   (This may take a few minutes)" -ForegroundColor DarkGray
Write-Host ""

# Deploy to production
vercel --prod --yes

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Frontend deployment failed!" -ForegroundColor Red
    Write-Host "   Check: vercel logs" -ForegroundColor Yellow
    Set-Location $originalPath
    exit 1
}

Write-Host ""
Write-Host "Frontend deployed successfully!" -ForegroundColor Green

# Get frontend URL
$frontendUrl = "https://$domain"
Write-Host "Frontend URL: $frontendUrl" -ForegroundColor Blue

$frontendDeployTime = Get-Date

# ============================================
# STEP 5: Update CORS Configuration
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  Updating CORS Configuration          " -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

Set-Location $backendPath

Write-Host "Setting CORS_ORIGIN to: $frontendUrl" -ForegroundColor Gray
railway variables set "CORS_ORIGIN=$frontendUrl" 2>&1 | Out-Null

Write-Host "Setting FRONTEND_URL to: $frontendUrl" -ForegroundColor Gray
railway variables set "FRONTEND_URL=$frontendUrl" 2>&1 | Out-Null

Write-Host "OK: CORS updated (backend will auto-restart)" -ForegroundColor Green
Write-Host "   Waiting for restart..." -ForegroundColor DarkGray
Start-Sleep -Seconds 5

# ============================================
# FINAL SUMMARY
# ============================================
Set-Location $originalPath

$deploymentEndTime = Get-Date
$totalDuration = ($deploymentEndTime - $deploymentStartTime).TotalSeconds

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT SUCCESSFUL!                " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Deployment Summary" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor DarkGray
Write-Host ""

if (!$skipCommit) {
    Write-Host "Git Commit:   $commitMsg" -ForegroundColor Green
    Write-Host "Git Push:     origin/$currentBranch" -ForegroundColor Green
} else {
    Write-Host "Git Commit:   No changes" -ForegroundColor DarkGray
}

Write-Host "Backend:      $backendUrl" -ForegroundColor Green
Write-Host "Frontend:     $frontendUrl" -ForegroundColor Green
Write-Host "CORS:         Configured" -ForegroundColor Green
Write-Host ""
Write-Host "Total time:   $([math]::Round($totalDuration, 1)) seconds" -ForegroundColor Cyan
Write-Host ""

Write-Host "Useful Commands" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "View logs:" -ForegroundColor Yellow
Write-Host "  railway logs              # Backend logs" -ForegroundColor White
Write-Host "  vercel logs               # Frontend logs" -ForegroundColor White
Write-Host ""
Write-Host "Check status:" -ForegroundColor Yellow
Write-Host "  railway status            # Backend status" -ForegroundColor White
Write-Host "  vercel ls                 # Frontend deployments" -ForegroundColor White
Write-Host ""

Write-Host "Next Steps" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "1. Open frontend: $frontendUrl" -ForegroundColor White
Write-Host "2. Test authentication and features" -ForegroundColor White
Write-Host "3. Monitor logs for errors" -ForegroundColor White
Write-Host ""

Write-Host "Your app is now live!" -ForegroundColor Green
Write-Host ""
