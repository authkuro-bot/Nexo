# ============================================
# Nexo Deployment Check Script
# ============================================
# Script untuk cek kesiapan deployment

Write-Host "🚀 Nexo Deployment Readiness Check" -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

$allGood = $true

# Check 1: Git Repository
Write-Host "📦 Checking Git Repository..." -ForegroundColor Yellow
if (Test-Path ".git") {
    Write-Host "   ✅ Git initialized" -ForegroundColor Green
} else {
    Write-Host "   ❌ Git not initialized. Run: git init" -ForegroundColor Red
    $allGood = $false
}

# Check 2: Frontend Files
Write-Host "`n📁 Checking Frontend Files..." -ForegroundColor Yellow
if (Test-Path "app/package.json") {
    Write-Host "   ✅ Frontend package.json found" -ForegroundColor Green
} else {
    Write-Host "   ❌ Frontend package.json missing" -ForegroundColor Red
    $allGood = $false
}

if (Test-Path "app/vercel.json") {
    Write-Host "   ✅ vercel.json configured" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  vercel.json missing (optional)" -ForegroundColor Yellow
}

# Check 3: Backend Files
Write-Host "`n🔧 Checking Backend Files..." -ForegroundColor Yellow
if (Test-Path "app/backend/package.json") {
    Write-Host "   ✅ Backend package.json found" -ForegroundColor Green
} else {
    Write-Host "   ❌ Backend package.json missing" -ForegroundColor Red
    $allGood = $false
}

if (Test-Path "app/backend/src/server.js") {
    Write-Host "   ✅ Backend server.js found" -ForegroundColor Green
} else {
    Write-Host "   ❌ Backend server.js missing" -ForegroundColor Red
    $allGood = $false
}

# Check 4: Environment Variables Examples
Write-Host "`n🔐 Checking Environment Templates..." -ForegroundColor Yellow
if (Test-Path "app/.env.example") {
    Write-Host "   ✅ Frontend .env.example exists" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Frontend .env.example missing" -ForegroundColor Yellow
}

if (Test-Path "app/backend/.env.example") {
    Write-Host "   ✅ Backend .env.example exists" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Backend .env.example missing" -ForegroundColor Yellow
}

# Check 5: .gitignore
Write-Host "`n🔒 Checking .gitignore..." -ForegroundColor Yellow
if (Test-Path ".gitignore") {
    $gitignore = Get-Content ".gitignore" -Raw
    if ($gitignore -like "*node_modules*" -and $gitignore -like "*.env*") {
        Write-Host "   ✅ .gitignore properly configured" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  .gitignore may need update" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ .gitignore missing" -ForegroundColor Red
    $allGood = $false
}

# Check 6: Dependencies Installed
Write-Host "`n📚 Checking Dependencies..." -ForegroundColor Yellow
if (Test-Path "app/node_modules") {
    Write-Host "   ✅ Frontend dependencies installed" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Frontend dependencies not installed" -ForegroundColor Yellow
    Write-Host "      Run: cd app && npm install" -ForegroundColor Gray
}

if (Test-Path "app/backend/node_modules") {
    Write-Host "   ✅ Backend dependencies installed" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Backend dependencies not installed" -ForegroundColor Yellow
    Write-Host "      Run: cd app/backend && npm install" -ForegroundColor Gray
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "✅ All critical checks passed!" -ForegroundColor Green
    Write-Host "`nYou're ready to deploy! Next steps:" -ForegroundColor Green
    Write-Host "1. Push to GitHub: git push origin main" -ForegroundColor White
    Write-Host "2. Deploy backend: railway.app" -ForegroundColor White
    Write-Host "3. Deploy frontend: vercel.com" -ForegroundColor White
    Write-Host "`n📖 Read: DEPLOY_VERCEL_RAILWAY.md for detailed guide" -ForegroundColor Cyan
} else {
    Write-Host "❌ Some critical checks failed!" -ForegroundColor Red
    Write-Host "Please fix the issues above before deploying." -ForegroundColor Yellow
}
Write-Host "========================================`n" -ForegroundColor Cyan
