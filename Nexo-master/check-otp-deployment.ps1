# ============================================================================
# Check OTP Deployment Status
# ============================================================================
# Verifikasi apakah SHOW_DEV_OTP sudah aktif di production
# ============================================================================

param(
    [string]$BackendUrl = "",
    [string]$TestPhone = "081234567890"
)

Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   🔍 OTP Deployment Status Checker           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# ============================================================================
# 1. Check Railway Environment Variables
# ============================================================================

Write-Host "1️⃣  Railway Environment Variables" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

if (Get-Command railway -ErrorAction SilentlyContinue) {
    $railwayVars = railway variables 2>&1
    
    if ($railwayVars -match "SHOW_DEV_OTP") {
        Write-Host "✅ SHOW_DEV_OTP found in Railway" -ForegroundColor Green
        
        # Try to extract value
        if ($railwayVars -match "SHOW_DEV_OTP[:\s]+(\w+)") {
            $value = $matches[1]
            Write-Host "   Value: $value" -ForegroundColor Cyan
        }
    } else {
        Write-Host "❌ SHOW_DEV_OTP NOT found in Railway" -ForegroundColor Red
        Write-Host "   Run: railway variables set SHOW_DEV_OTP=true" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Railway CLI not installed" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================================
# 2. Check Vercel Environment Variables
# ============================================================================

Write-Host "2️⃣  Vercel Environment Variables" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

if (Get-Command vercel -ErrorAction SilentlyContinue) {
    if (Test-Path "app/backend") {
        Push-Location app/backend
        $vercelVars = vercel env ls production 2>&1
        
        if ($vercelVars -match "SHOW_DEV_OTP") {
            Write-Host "✅ SHOW_DEV_OTP found in Vercel" -ForegroundColor Green
        } else {
            Write-Host "❌ SHOW_DEV_OTP NOT found in Vercel" -ForegroundColor Red
            Write-Host "   Run: vercel env add SHOW_DEV_OTP production" -ForegroundColor Yellow
        }
        
        Pop-Location
    } else {
        Write-Host "⚠️  Backend folder not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Vercel CLI not installed" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================================
# 3. Test API Endpoint
# ============================================================================

Write-Host "3️⃣  API Endpoint Test" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

if ($BackendUrl -eq "") {
    Write-Host "⚠️  Backend URL not provided" -ForegroundColor Yellow
    $BackendUrl = Read-Host "Enter backend URL (or press Enter to skip)"
}

if ($BackendUrl -ne "") {
    $BackendUrl = $BackendUrl.TrimEnd('/')
    $apiUrl = "$BackendUrl/api/auth/otp/send"
    
    Write-Host "🔗 Testing: $apiUrl" -ForegroundColor Cyan
    
    try {
        $body = @{
            phone = $TestPhone
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body -ContentType "application/json" -ErrorAction Stop
        
        if ($response.otp) {
            Write-Host "✅ OTP found in response!" -ForegroundColor Green
            Write-Host "   OTP Code: $($response.otp)" -ForegroundColor Cyan
            Write-Host "   Message: $($response.message)" -ForegroundColor Cyan
        } else {
            Write-Host "❌ OTP NOT in response" -ForegroundColor Red
            Write-Host "   Message: $($response.message)" -ForegroundColor Yellow
            Write-Host "   Response: $($response | ConvertTo-Json)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ API request failed" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⏭️  API test skipped" -ForegroundColor Gray
}

Write-Host ""

# ============================================================================
# 4. Check Railway Logs
# ============================================================================

Write-Host "4️⃣  Recent Railway Logs" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

if (Get-Command railway -ErrorAction SilentlyContinue) {
    Write-Host "🔍 Searching for OTP in logs..." -ForegroundColor Cyan
    
    $logs = railway logs --limit 50 2>&1
    $otpLogs = $logs | Select-String -Pattern "\[OTP\]" | Select-Object -First 5
    
    if ($otpLogs) {
        Write-Host "✅ OTP logs found:" -ForegroundColor Green
        $otpLogs | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    } else {
        Write-Host "⚠️  No OTP logs found in recent logs" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Railway CLI not installed" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================================
# Summary & Recommendations
# ============================================================================

Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║             📋 SUMMARY & TIPS                  ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Magenta

Write-Host "💡 Troubleshooting Steps:" -ForegroundColor Cyan
Write-Host "   1. Set env var:     .\update-otp-config.ps1 -Action enable"
Write-Host "   2. Check deployment: railway status"
Write-Host "   3. View live logs:   railway logs -f"
Write-Host "   4. Test frontend:    Open browser → Register → Check OTP badge"

Write-Host "`n📚 Documentation:"
Write-Host "   • Full guide: cat DEV_OTP_GUIDE.md"
Write-Host "   • Quick start: cat README.md`n"
