# ============================================
# Deploy Nexo (Backend + Frontend)
# ============================================

$ErrorActionPreference = "Continue"

Write-Host "🚀 Deploying Nexo (Backend + Frontend)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Store current location
$originalPath = Get-Location

# Check CLI tools installed
Write-Host "🔧 Checking CLI tools..." -ForegroundColor Yellow

$railwayCheck = Get-Command railway -ErrorAction SilentlyContinue
$vercelCheck = Get-Command vercel -ErrorAction SilentlyContinue

$missingTools = @()
if (!$railwayCheck) { $missingTools += "railway" }
if (!$vercelCheck) { $missingTools += "vercel" }

if ($missingTools.Count -gt 0) {
    Write-Host "❌ Missing CLI tools: $($missingTools -join ', ')" -ForegroundColor Red
    Write-Host "`n📦 Install with:" -ForegroundColor Yellow
    if ($missingTools -contains "railway") {
        Write-Host "   npm install -g @railway/cli" -ForegroundColor White
    }
    if ($missingTools -contains "vercel") {
        Write-Host "   npm install -g vercel" -ForegroundColor White
    }
    exit 1
}

Write-Host "✓ Railway CLI installed" -ForegroundColor Green
Write-Host "✓ Vercel CLI installed" -ForegroundColor Green

# Check authentication
Write-Host "`n🔐 Checking authentication..." -ForegroundColor Yellow

$railwayAuth = railway whoami 2>&1
$railwayLoggedIn = $LASTEXITCODE -eq 0

$vercelAuth = vercel whoami 2>&1
$vercelLoggedIn = $LASTEXITCODE -eq 0

if (!$railwayLoggedIn -or !$vercelLoggedIn) {
    Write-Host "❌ Not logged in to all services" -ForegroundColor Red
    if (!$railwayLoggedIn) {
        Write-Host "   Login to Railway: railway login" -ForegroundColor Yellow
    }
    if (!$vercelLoggedIn) {
        Write-Host "   Login to Vercel: vercel login" -ForegroundColor Yellow
    }
    exit 1
}

Write-Host "✓ Railway: $railwayAuth" -ForegroundColor Green
Write-Host "✓ Vercel: $vercelAuth" -ForegroundColor Green

# Deploy Backend
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📦 STEP 1/2: Deploying Backend..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$backendPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master\app\backend"

if (!(Test-Path $backendPath)) {
    Write-Host "❌ Backend path not found!" -ForegroundColor Red
    exit 1
}

Set-Location $backendPath
Write-Host "📂 Location: $backendPath" -ForegroundColor Gray

railway up

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Backend deployment failed!" -ForegroundColor Red
    Write-Host "   Check logs: railway logs" -ForegroundColor Yellow
    Set-Location $originalPath
    exit 1
}

Write-Host "`n✅ Backend deployed successfully!" -ForegroundColor Green

# Get backend URL
$backendUrl = railway domain 2>&1
Write-Host "🔗 Backend URL: $backendUrl" -ForegroundColor Blue

# Configure OTP display (optional)
Write-Host "`n🔧 Configure Dev OTP Display..." -ForegroundColor Yellow
$enableOtp = Read-Host "Enable OTP display in production? (y/N)"
if ($enableOtp -eq "y" -or $enableOtp -eq "Y") {
    railway variables set SHOW_DEV_OTP=true
    Write-Host "✅ Dev OTP enabled for testing" -ForegroundColor Green
} else {
    Write-Host "⏭️  Skipping OTP configuration" -ForegroundColor Gray
}

# Small delay
Start-Sleep -Seconds 2

# Deploy Frontend
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📦 STEP 2/2: Deploying Frontend..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$frontendPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master\app"

if (!(Test-Path $frontendPath)) {
    Write-Host "❌ Frontend path not found!" -ForegroundColor Red
    Set-Location $originalPath
    exit 1
}

Set-Location $frontendPath
Write-Host "📂 Location: $frontendPath" -ForegroundColor Gray

vercel --prod --yes

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Frontend deployment failed!" -ForegroundColor Red
    Write-Host "   Check logs: vercel logs" -ForegroundColor Yellow
    Set-Location $originalPath
    exit 1
}

Write-Host "`n✅ Frontend deployed successfully!" -ForegroundColor Green

# Return to original location
Set-Location $originalPath

# Final Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "🎉 ALL DEPLOYMENTS SUCCESSFUL!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n📋 Deployment Summary:" -ForegroundColor Cyan
Write-Host "   Backend:  $backendUrl" -ForegroundColor Blue
Write-Host "   Frontend: (check Vercel output above)" -ForegroundColor Blue

Write-Host "`n⚠️  Important: Update CORS" -ForegroundColor Yellow
Write-Host "   After getting frontend URL, run:" -ForegroundColor White
Write-Host "   railway variables set CORS_ORIGIN=<frontend-url>" -ForegroundColor Gray

Write-Host "`n✅ Next steps:" -ForegroundColor Cyan
Write-Host "   1. Copy frontend URL from Vercel output" -ForegroundColor White
Write-Host "   2. Update CORS_ORIGIN in Railway" -ForegroundColor White
Write-Host "   3. Test your application" -ForegroundColor White
Write-Host "   4. Monitor logs:" -ForegroundColor White
Write-Host "      - railway logs (backend)" -ForegroundColor Gray
Write-Host "      - vercel logs (frontend)" -ForegroundColor Gray

Write-Host "`n🎊 Happy deploying!" -ForegroundColor Green
