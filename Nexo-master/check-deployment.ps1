# ============================================
# 🔍 Check Deployment Status
# ============================================
# View current deployment status & URLs

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   🔍 DEPLOYMENT STATUS CHECK           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master"
$domain = "nexoai-flax.vercel.app"
$originalPath = Get-Location

Set-Location $projectPath

# ============================================
# Git Status
# ============================================
Write-Host "📦 Git Status" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

$gitStatus = git status --porcelain 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Git not initialized" -ForegroundColor Red
} else {
    $currentBranch = git branch --show-current 2>&1
    $lastCommit = git log -1 --pretty=format:"%h - %s (%ar)" 2>&1
    
    Write-Host "Branch:      $currentBranch" -ForegroundColor White
    Write-Host "Last commit: $lastCommit" -ForegroundColor White
    
    if ([string]::IsNullOrWhiteSpace($gitStatus)) {
        Write-Host "Status:      ✓ Clean (no changes)" -ForegroundColor Green
    } else {
        $changedFiles = ($gitStatus | Measure-Object).Count
        Write-Host "Status:      ⚠️  $changedFiles file(s) modified" -ForegroundColor Yellow
    }
    
    # Check remote
    $remote = git remote get-url origin 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Remote:      $remote" -ForegroundColor White
    } else {
        Write-Host "Remote:      ⚠️  Not configured" -ForegroundColor Yellow
    }
}

# ============================================
# Backend Status (Railway)
# ============================================
Write-Host ""
Write-Host "🚂 Backend Status (Railway)" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

$railwayCheck = Get-Command railway -ErrorAction SilentlyContinue

if (!$railwayCheck) {
    Write-Host "❌ Railway CLI not installed" -ForegroundColor Red
    Write-Host "   Install: npm install -g @railway/cli" -ForegroundColor DarkGray
} else {
    $railwayAuth = railway whoami 2>&1
    $railwayLoggedIn = $LASTEXITCODE -eq 0
    
    if (!$railwayLoggedIn) {
        Write-Host "❌ Not logged in to Railway" -ForegroundColor Red
        Write-Host "   Run: railway login" -ForegroundColor DarkGray
    } else {
        Write-Host "User:        $railwayAuth" -ForegroundColor White
        
        Set-Location "$projectPath\app\backend"
        
        $railwayStatus = railway status 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Status:      ⚠️  Not linked to project" -ForegroundColor Yellow
            Write-Host "             Run: railway link" -ForegroundColor DarkGray
        } else {
            Write-Host "Status:      ✓ Linked" -ForegroundColor Green
            
            $backendUrl = railway domain 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "URL:         $backendUrl" -ForegroundColor Blue
                
                # Test backend health
                Write-Host ""
                Write-Host "Testing backend health..." -ForegroundColor Gray
                try {
                    $response = Invoke-WebRequest -Uri "$backendUrl/health" -Method GET -TimeoutSec 10 -ErrorAction SilentlyContinue
                    if ($response.StatusCode -eq 200) {
                        Write-Host "✓ Backend is responding" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "⚠️  Backend not responding or no /health endpoint" -ForegroundColor Yellow
                }
            }
        }
    }
}

# ============================================
# Frontend Status (Vercel)
# ============================================
Write-Host ""
Write-Host "🌐 Frontend Status (Vercel)" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

$vercelCheck = Get-Command vercel -ErrorAction SilentlyContinue

if (!$vercelCheck) {
    Write-Host "❌ Vercel CLI not installed" -ForegroundColor Red
    Write-Host "   Install: npm install -g vercel" -ForegroundColor DarkGray
} else {
    $vercelAuth = vercel whoami 2>&1
    $vercelLoggedIn = $LASTEXITCODE -eq 0
    
    if (!$vercelLoggedIn) {
        Write-Host "❌ Not logged in to Vercel" -ForegroundColor Red
        Write-Host "   Run: vercel login" -ForegroundColor DarkGray
    } else {
        Write-Host "User:        $vercelAuth" -ForegroundColor White
        
        Set-Location "$projectPath\app"
        
        $vercelProject = vercel inspect 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Status:      ⚠️  Not linked to project" -ForegroundColor Yellow
            Write-Host "             Run: vercel link" -ForegroundColor DarkGray
        } else {
            Write-Host "Status:      ✓ Linked" -ForegroundColor Green
            Write-Host "Domain:      https://$domain" -ForegroundColor Blue
            
            # Get latest deployment
            Write-Host ""
            Write-Host "Latest deployments:" -ForegroundColor Gray
            vercel ls --limit 3 2>&1 | Select-Object -First 5 | ForEach-Object {
                Write-Host "  $_" -ForegroundColor DarkGray
            }
            
            # Test frontend
            Write-Host ""
            Write-Host "Testing frontend..." -ForegroundColor Gray
            try {
                $response = Invoke-WebRequest -Uri "https://$domain" -Method GET -TimeoutSec 10 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    Write-Host "✓ Frontend is online" -ForegroundColor Green
                }
            } catch {
                Write-Host "⚠️  Frontend not accessible" -ForegroundColor Yellow
            }
        }
    }
}

# ============================================
# Environment Variables Check
# ============================================
Write-Host ""
Write-Host "🔐 Environment Files" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

$backendEnv = "$projectPath\app\backend\.env"
$frontendEnv = "$projectPath\app\.env"

if (Test-Path $backendEnv) {
    $backendEnvSize = (Get-Item $backendEnv).Length
    Write-Host "Backend .env:  ✓ Found ($backendEnvSize bytes)" -ForegroundColor Green
} else {
    Write-Host "Backend .env:  ❌ Not found" -ForegroundColor Red
}

if (Test-Path $frontendEnv) {
    $frontendEnvSize = (Get-Item $frontendEnv).Length
    Write-Host "Frontend .env: ✓ Found ($frontendEnvSize bytes)" -ForegroundColor Green
} else {
    Write-Host "Frontend .env: ❌ Not found" -ForegroundColor Red
}

# ============================================
# Summary & Recommendations
# ============================================
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   📋 SUMMARY                           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$issues = @()

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($gitStatus) -eq $false) {
    $issues += "Uncommitted changes"
}

if (!$railwayCheck -or !$railwayLoggedIn) {
    $issues += "Railway not ready"
}

if (!$vercelCheck -or !$vercelLoggedIn) {
    $issues += "Vercel not ready"
}

if ($issues.Count -eq 0) {
    Write-Host "✅ Everything looks good!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ready to deploy:" -ForegroundColor Cyan
    Write-Host "  .\deploy-complete.ps1        # Full deployment" -ForegroundColor White
    Write-Host "  .\quick-update.ps1           # Frontend only" -ForegroundColor White
} else {
    Write-Host "⚠️  Issues found:" -ForegroundColor Yellow
    foreach ($issue in $issues) {
        Write-Host "  - $issue" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Fix issues before deploying." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔧 Useful Commands:" -ForegroundColor Cyan
Write-Host "  railway logs                 # View backend logs" -ForegroundColor White
Write-Host "  vercel logs                  # View frontend logs" -ForegroundColor White
Write-Host "  git status                   # Check git status" -ForegroundColor White
Write-Host ""

Set-Location $originalPath
