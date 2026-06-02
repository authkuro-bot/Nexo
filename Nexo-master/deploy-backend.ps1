# ============================================
# Deploy Backend to Railway
# ============================================

Write-Host "🚂 Deploying Backend to Railway..." -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# Navigate to backend
$backendPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master\app\backend"

if (!(Test-Path $backendPath)) {
    Write-Host "❌ Backend path not found: $backendPath" -ForegroundColor Red
    exit 1
}

Set-Location $backendPath
Write-Host "✓ Changed directory to: $backendPath" -ForegroundColor Green

# Check if railway CLI is installed
$railwayCheck = Get-Command railway -ErrorAction SilentlyContinue
if (!$railwayCheck) {
    Write-Host "❌ Railway CLI not found!" -ForegroundColor Red
    Write-Host "   Install: npm install -g @railway/cli" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Railway CLI found" -ForegroundColor Green

# Check if logged in
Write-Host "`n🔐 Checking Railway authentication..." -ForegroundColor Yellow
$railwayStatus = railway whoami 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged in to Railway" -ForegroundColor Red
    Write-Host "   Run: railway login" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Logged in as: $railwayStatus" -ForegroundColor Green

# Check if project is linked
Write-Host "`n🔗 Checking project link..." -ForegroundColor Yellow
$projectInfo = railway status 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  No Railway project linked" -ForegroundColor Yellow
    Write-Host "   Initializing new project..." -ForegroundColor Cyan
    railway init
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to initialize project" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✓ Project linked" -ForegroundColor Green

# Deploy
Write-Host "`n📦 Building and deploying..." -ForegroundColor Yellow
Write-Host "   This may take 2-3 minutes..." -ForegroundColor Gray

railway up

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "✅ Backend deployed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    Write-Host "`n🔗 Getting deployment URL..." -ForegroundColor Yellow
    $domain = railway domain 2>&1
    
    if ($domain) {
        Write-Host "Backend URL: $domain" -ForegroundColor Blue
        Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
        Write-Host "   1. Copy the URL above" -ForegroundColor White
        Write-Host "   2. Use it as VITE_API_URL in frontend" -ForegroundColor White
        Write-Host "   3. Deploy frontend: .\deploy-frontend.ps1" -ForegroundColor White
    }
} else {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "`n💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Check Railway logs: railway logs" -ForegroundColor White
    Write-Host "   - Verify environment variables: railway variables" -ForegroundColor White
    Write-Host "   - Check Railway dashboard: https://railway.app" -ForegroundColor White
    exit 1
}
