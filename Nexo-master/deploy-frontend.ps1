# ============================================
# Deploy Frontend to Vercel
# ============================================

Write-Host "🎨 Deploying Frontend to Vercel..." -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# Navigate to frontend
$frontendPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master\app"

if (!(Test-Path $frontendPath)) {
    Write-Host "❌ Frontend path not found: $frontendPath" -ForegroundColor Red
    exit 1
}

Set-Location $frontendPath
Write-Host "✓ Changed directory to: $frontendPath" -ForegroundColor Green

# Check if vercel CLI is installed
$vercelCheck = Get-Command vercel -ErrorAction SilentlyContinue
if (!$vercelCheck) {
    Write-Host "❌ Vercel CLI not found!" -ForegroundColor Red
    Write-Host "   Install: npm install -g vercel" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Vercel CLI found" -ForegroundColor Green

# Check if logged in
Write-Host "`n🔐 Checking Vercel authentication..." -ForegroundColor Yellow
$vercelStatus = vercel whoami 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged in to Vercel" -ForegroundColor Red
    Write-Host "   Run: vercel login" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Logged in as: $vercelStatus" -ForegroundColor Green

# Check environment variables
Write-Host "`n🔍 Checking environment variables..." -ForegroundColor Yellow
$envCheck = vercel env ls 2>&1

if ($envCheck -notlike "*VITE_API_URL*") {
    Write-Host "⚠️  VITE_API_URL not set!" -ForegroundColor Yellow
    Write-Host "   Frontend won't be able to connect to backend." -ForegroundColor Gray
    Write-Host "   Add it later with: vercel env add VITE_API_URL" -ForegroundColor Gray
} else {
    Write-Host "✓ Environment variables configured" -ForegroundColor Green
}

# Deploy to production
Write-Host "`n📦 Building and deploying to production..." -ForegroundColor Yellow
Write-Host "   This may take 2-3 minutes..." -ForegroundColor Gray

vercel --prod --yes

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "✅ Frontend deployed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Open the Vercel URL shown above" -ForegroundColor White
    Write-Host "   2. Copy the frontend URL" -ForegroundColor White
    Write-Host "   3. Update CORS in Railway backend:" -ForegroundColor White
    Write-Host "      railway variables set CORS_ORIGIN=<your-vercel-url>" -ForegroundColor Gray
    
    Write-Host "`n💡 Useful commands:" -ForegroundColor Cyan
    Write-Host "   - View deployments: vercel ls" -ForegroundColor White
    Write-Host "   - View logs: vercel logs" -ForegroundColor White
    Write-Host "   - Open dashboard: vercel" -ForegroundColor White
} else {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "`n💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Check build logs above" -ForegroundColor White
    Write-Host "   - Verify package.json exists" -ForegroundColor White
    Write-Host "   - Try: vercel --debug" -ForegroundColor White
    Write-Host "   - Check Vercel dashboard: https://vercel.com" -ForegroundColor White
    exit 1
}
