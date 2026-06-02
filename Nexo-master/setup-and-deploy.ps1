# ============================================
# Nexo First-Time Setup & Deploy
# ============================================

$ErrorActionPreference = "Continue"

Write-Host "🚀 Nexo First-Time Setup & Deploy" -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Cyan

# Change to project directory
$projectPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master"
Set-Location $projectPath

Write-Host "📂 Project Path: $projectPath" -ForegroundColor Gray
Write-Host ""

# Step 1: Install CLI tools
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 1/5: Installing CLI Tools" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$railwayCheck = Get-Command railway -ErrorAction SilentlyContinue
$vercelCheck = Get-Command vercel -ErrorAction SilentlyContinue

if (!$railwayCheck) {
    Write-Host "📦 Installing Railway CLI..." -ForegroundColor Yellow
    npm install -g @railway/cli
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Railway CLI installed" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to install Railway CLI" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ Railway CLI already installed" -ForegroundColor Green
}

if (!$vercelCheck) {
    Write-Host "📦 Installing Vercel CLI..." -ForegroundColor Yellow
    npm install -g vercel
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Vercel CLI installed" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to install Vercel CLI" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ Vercel CLI already installed" -ForegroundColor Green
}

# Step 2: Login to services
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "STEP 2/5: Authentication" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "🔐 Login to Railway..." -ForegroundColor Yellow
Write-Host "   Browser will open - use: authkuro@gmail.com" -ForegroundColor Gray
railway login

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Railway login failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Railway login successful" -ForegroundColor Green

Write-Host "`n🔐 Login to Vercel..." -ForegroundColor Yellow
Write-Host "   Browser will open - use: authkuro@gmail.com" -ForegroundColor Gray
vercel login

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Vercel login failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Vercel login successful" -ForegroundColor Green

# Step 3: Git setup
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "STEP 3/5: Git Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if (!(Test-Path ".git")) {
    Write-Host "📦 Initializing Git repository..." -ForegroundColor Yellow
    git init
    git branch -M main
    Write-Host "✓ Git initialized" -ForegroundColor Green
} else {
    Write-Host "✓ Git already initialized" -ForegroundColor Green
}

# Check if there are changes to commit
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "`n📝 Committing changes..." -ForegroundColor Yellow
    git add .
    git commit -m "Initial commit for deployment"
    Write-Host "✓ Changes committed" -ForegroundColor Green
} else {
    Write-Host "✓ No changes to commit" -ForegroundColor Green
}

# Step 4: GitHub setup
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "STEP 4/5: GitHub Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$ghCheck = Get-Command gh -ErrorAction SilentlyContinue
if ($ghCheck) {
    Write-Host "📤 Creating GitHub repository..." -ForegroundColor Yellow
    Write-Host "   Using account: authkuro@gmail.com" -ForegroundColor Gray
    
    gh repo create Nexo --private --source=. --push 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ GitHub repository created and pushed" -ForegroundColor Green
    } else {
        Write-Host "⚠️  GitHub repo creation skipped (may already exist)" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  GitHub CLI not installed - skipping GitHub setup" -ForegroundColor Yellow
    Write-Host "   Install from: https://cli.github.com/" -ForegroundColor Gray
    Write-Host "   Or create repo manually at: https://github.com/new" -ForegroundColor Gray
}

# Step 5: Deploy
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "STEP 5/5: Deployment" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "⚠️  Before deploying, ensure you have:" -ForegroundColor Yellow
Write-Host "   1. Supabase project created" -ForegroundColor White
Write-Host "   2. Supabase credentials ready" -ForegroundColor White
Write-Host "   3. OpenAI API key" -ForegroundColor White
Write-Host ""

$response = Read-Host "Ready to deploy? (Y/n)"

if ($response -eq "n" -or $response -eq "N") {
    Write-Host "`n⏸️  Deployment paused" -ForegroundColor Yellow
    Write-Host "   Run .\deploy-all.ps1 when ready" -ForegroundColor Cyan
    exit 0
}

Write-Host "`n🚀 Starting deployment..." -ForegroundColor Cyan

# Run the deploy-all script
& "$projectPath\deploy-all.ps1"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "✅ SETUP & DEPLOYMENT COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    Write-Host "`n🎉 Nexo is now live!" -ForegroundColor Green
    Write-Host "`n📚 Useful commands:" -ForegroundColor Cyan
    Write-Host "   Deploy backend:  .\deploy-backend.ps1" -ForegroundColor White
    Write-Host "   Deploy frontend: .\deploy-frontend.ps1" -ForegroundColor White
    Write-Host "   Deploy both:     .\deploy-all.ps1" -ForegroundColor White
    Write-Host "   Check status:    railway status && vercel ls" -ForegroundColor White
} else {
    Write-Host "`n❌ Deployment failed" -ForegroundColor Red
    Write-Host "   Check errors above and try again" -ForegroundColor Yellow
    exit 1
}
