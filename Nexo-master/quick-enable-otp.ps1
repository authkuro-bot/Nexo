# ============================================================================
# Quick Enable Dev OTP - One Command Deploy
# ============================================================================
# Usage: .\quick-enable-otp.ps1
# Akan otomatis: git push + railway deploy + vercel deploy
# ============================================================================

Write-Host "`n🚀 Quick Enable Dev OTP in Production`n" -ForegroundColor Cyan

# Step 1: Git
Write-Host "1️⃣  Git commit & push..." -ForegroundColor Yellow
git add .
git commit -m "feat: enable SHOW_DEV_OTP for production testing"
git push

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Git push failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Git pushed`n" -ForegroundColor Green

# Step 2: Railway
Write-Host "2️⃣  Setting Railway variable..." -ForegroundColor Yellow

if (Get-Command railway -ErrorAction SilentlyContinue) {
    railway variables set SHOW_DEV_OTP=true
    railway up --detach
    Write-Host "✅ Railway deployment triggered`n" -ForegroundColor Green
} else {
    Write-Host "⚠️  Railway CLI not found. Skipping...`n" -ForegroundColor Yellow
}

# Step 3: Vercel (if backend exists)
Write-Host "3️⃣  Checking Vercel backend..." -ForegroundColor Yellow

if ((Get-Command vercel -ErrorAction SilentlyContinue) -and (Test-Path "app/backend")) {
    Push-Location app/backend
    Write-Output "true" | vercel env add SHOW_DEV_OTP production -y
    vercel --prod --yes
    Pop-Location
    Write-Host "✅ Vercel deployment triggered`n" -ForegroundColor Green
} else {
    Write-Host "⚠️  Skipping Vercel (not configured)`n" -ForegroundColor Yellow
}

# Done
Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   ✨ Dev OTP Enabled in Production   ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "📍 Check status:"
Write-Host "   railway logs"
Write-Host "   vercel logs`n"
