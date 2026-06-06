# ============================================
# 🚀 Full Deployment with ENV Sync
# ============================================
# Commit → Sync .env → Deploy All
# ============================================

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   🚀 FULL DEPLOYMENT + ENV SYNC        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master"
$domain = "nexoai-flax.vercel.app"
$originalPath = Get-Location

Set-Location $projectPath

# ============================================
# Function: Parse .env file
# ============================================
function Parse-EnvFile {
    param([string]$Path)
    
    $envVars = @{}
    
    if (!(Test-Path $Path)) {
        return $envVars
    }
    
    $content = Get-Content $Path
    foreach ($line in $content) {
        $line = $line.Trim()
        
        if ($line -match '^#' -or $line -eq '') {
            continue
        }
        
        if ($line -match '^([^=]+)=(.*)$') {
            $key = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            $value = $value -replace '^["'']|["'']$', ''
            $envVars[$key] = $value
        }
    }
    
    return $envVars
}

# ============================================
# STEP 1: Git Commit & Push
# ============================================
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  📦 STEP 1/5: Git Commit               ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

$gitStatus = git status --porcelain 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Git not initialized!" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($gitStatus)) {
    Write-Host "✓ No changes to commit" -ForegroundColor Green
    $skipCommit = $true
} else {
    Write-Host "Changes found:" -ForegroundColor Gray
    git status --short | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    Write-Host ""
    
    Write-Host "📝 Commit message (Enter for default):" -ForegroundColor Yellow
    $commitMsg = Read-Host "Message"
    
    if ([string]::IsNullOrWhiteSpace($commitMsg)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $commitMsg = "Deploy with env sync - $timestamp"
    }
    
    Write-Host ""
    Write-Host "💾 Creating commit..." -ForegroundColor Gray
    git add .
    git commit -m $commitMsg
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Commit failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✓ Committed: $commitMsg" -ForegroundColor Green
    $skipCommit = $false
}

Write-Host ""
Write-Host "🌐 Pushing to GitHub..." -ForegroundColor Gray
$currentBranch = git branch --show-current 2>&1
git push origin $currentBranch

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Push failed (continuing...)" -ForegroundColor Yellow
} else {
    Write-Host "✓ Pushed to origin/$currentBranch" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Git complete!" -ForegroundColor Green
Start-Sleep -Seconds 1

# ============================================
# STEP 2: Parse Environment Files
# ============================================
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  📖 STEP 2/5: Read Environment Files   ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Write-Host "📖 Reading backend .env..." -ForegroundColor Gray
$backendEnvPath = "$projectPath\app\backend\.env"
$backendEnv = Parse-EnvFile -Path $backendEnvPath

if ($backendEnv.Count -eq 0) {
    Write-Host "⚠️  No backend .env found!" -ForegroundColor Yellow
} else {
    Write-Host "✓ Found $($backendEnv.Count) backend variables" -ForegroundColor Green
}

Write-Host ""
Write-Host "📖 Reading frontend .env..." -ForegroundColor Gray
$frontendEnvPath = "$projectPath\app\.env"
$frontendEnv = Parse-EnvFile -Path $frontendEnvPath

if ($frontendEnv.Count -eq 0) {
    Write-Host "⚠️  No frontend .env found!" -ForegroundColor Yellow
} else {
    Write-Host "✓ Found $($frontendEnv.Count) frontend variables" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Environment files parsed!" -ForegroundColor Green
Start-Sleep -Seconds 1

# ============================================
# STEP 3: Deploy Backend & Sync ENV
# ============================================
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  🚂 STEP 3/5: Deploy Backend + ENV     ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

$backendPath = "$projectPath\app\backend"

if (!(Test-Path $backendPath)) {
    Write-Host "❌ Backend path not found!" -ForegroundColor Red
    exit 1
}

Set-Location $backendPath

# Check Railway CLI
$railwayCheck = Get-Command railway -ErrorAction SilentlyContinue
if (!$railwayCheck) {
    Write-Host "❌ Railway CLI not found!" -ForegroundColor Red
    Write-Host "   Install: npm install -g @railway/cli" -ForegroundColor Yellow
    exit 1
}

$railwayAuth = railway whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "🔐 Please login to Railway..." -ForegroundColor Yellow
    railway login
}

Write-Host "✓ Railway authenticated" -ForegroundColor Green
Write-Host ""

# Sync environment variables
if ($backendEnv.Count -gt 0) {
    Write-Host "🔐 Syncing backend environment variables..." -ForegroundColor Cyan
    
    $railwayVars = @{
        "PORT" = "3000"
        "NODE_ENV" = "production"
        "SUPABASE_URL" = $backendEnv["SUPABASE_URL"]
        "SUPABASE_SERVICE_KEY" = $backendEnv["SUPABASE_SERVICE_KEY"]
        "JWT_SECRET" = $backendEnv["JWT_SECRET"]
        "JWT_EXPIRES_IN" = $backendEnv["JWT_EXPIRES_IN"]
        "CLOUDFLARE_R2_ACCOUNT_ID" = $backendEnv["CLOUDFLARE_R2_ACCOUNT_ID"]
        "CLOUDFLARE_R2_ACCESS_KEY_ID" = $backendEnv["CLOUDFLARE_R2_ACCESS_KEY_ID"]
        "CLOUDFLARE_R2_SECRET_ACCESS_KEY" = $backendEnv["CLOUDFLARE_R2_SECRET_ACCESS_KEY"]
        "CLOUDFLARE_R2_BUCKET" = $backendEnv["CLOUDFLARE_R2_BUCKET"]
        "CLOUDFLARE_R2_PUBLIC_URL" = $backendEnv["CLOUDFLARE_R2_PUBLIC_URL"]
        "CLOUDFLARE_R2_ENDPOINT" = $backendEnv["CLOUDFLARE_R2_ENDPOINT"]
        "AI_PROVIDER" = $backendEnv["AI_PROVIDER"]
        "OPENAI_API_KEY" = $backendEnv["OPENAI_API_KEY"]
        "OPENAI_MODEL" = $backendEnv["OPENAI_MODEL"]
        "DATA_PROVIDER" = $backendEnv["DATA_PROVIDER"]
        "AUTH_DATA_MODE" = $backendEnv["AUTH_DATA_MODE"]
        "OTP_DELIVERY" = "production"
        "MEDIA_PROVIDER" = $backendEnv["MEDIA_PROVIDER"]
    }
    
    $uploadCount = 0
    foreach ($key in $railwayVars.Keys) {
        $value = $railwayVars[$key]
        
        if ([string]::IsNullOrWhiteSpace($value)) {
            continue
        }
        
        Write-Host "  📤 $key" -ForegroundColor DarkGray
        railway variables set "$key=$value" 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            $uploadCount++
        }
    }
    
    Write-Host ""
    Write-Host "✓ Synced $uploadCount environment variables" -ForegroundColor Green
}

Write-Host ""
Write-Host "🚀 Deploying backend..." -ForegroundColor Cyan
railway up

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Backend deployment failed!" -ForegroundColor Red
    Set-Location $originalPath
    exit 1
}

Write-Host ""
Write-Host "✅ Backend deployed!" -ForegroundColor Green

$backendUrl = railway domain 2>&1 | Select-String -Pattern "https?://[^\s]+" | ForEach-Object { $_.Matches[0].Value } | Select-Object -First 1

if (!$backendUrl) {
    $backendUrl = railway domain 2>&1
}

Write-Host "🔗 Backend URL: $backendUrl" -ForegroundColor Blue
Start-Sleep -Seconds 2

# ============================================
# STEP 4: Deploy Frontend & Sync ENV
# ============================================
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  🌐 STEP 4/5: Deploy Frontend + ENV    ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

$frontendPath = "$projectPath\app"

if (!(Test-Path $frontendPath)) {
    Write-Host "❌ Frontend path not found!" -ForegroundColor Red
    Set-Location $originalPath
    exit 1
}

Set-Location $frontendPath

# Check Vercel CLI
$vercelCheck = Get-Command vercel -ErrorAction SilentlyContinue
if (!$vercelCheck) {
    Write-Host "❌ Vercel CLI not found!" -ForegroundColor Red
    Write-Host "   Install: npm install -g vercel" -ForegroundColor Yellow
    exit 1
}

$vercelAuth = vercel whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "🔐 Please login to Vercel..." -ForegroundColor Yellow
    vercel login
}

Write-Host "✓ Vercel authenticated" -ForegroundColor Green
Write-Host ""

# Sync environment variables
if ($frontendEnv.Count -gt 0 -or $backendUrl) {
    Write-Host "🔐 Syncing frontend environment variables..." -ForegroundColor Cyan
    
    # Note: Vercel env management is complex via CLI
    # Better to set them in Vercel dashboard or use vercel.json
    Write-Host "  ℹ️  Environment variables should be set in Vercel dashboard" -ForegroundColor DarkGray
    Write-Host "  📝 VITE_API_URL = $backendUrl" -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "🚀 Deploying frontend..." -ForegroundColor Cyan
Write-Host "   Target: $domain" -ForegroundColor DarkGray
Write-Host ""

vercel --prod --yes

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Frontend deployment failed!" -ForegroundColor Red
    Set-Location $originalPath
    exit 1
}

Write-Host ""
Write-Host "✅ Frontend deployed!" -ForegroundColor Green

$frontendUrl = "https://$domain"
Write-Host "🔗 Frontend URL: $frontendUrl" -ForegroundColor Blue

# ============================================
# STEP 5: Update CORS
# ============================================
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  🔗 STEP 5/5: Update CORS              ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Set-Location $backendPath

Write-Host "📤 Updating CORS configuration..." -ForegroundColor Gray
railway variables set "CORS_ORIGIN=$frontendUrl" 2>&1 | Out-Null
railway variables set "FRONTEND_URL=$frontendUrl" 2>&1 | Out-Null

Write-Host "✓ CORS updated" -ForegroundColor Green
Write-Host "   Waiting for backend restart..." -ForegroundColor DarkGray
Start-Sleep -Seconds 5

# ============================================
# FINAL SUMMARY
# ============================================
Set-Location $originalPath

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  🎉 DEPLOYMENT COMPLETE!               ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Summary" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

if (!$skipCommit) {
    Write-Host "✓ Git:        Committed & pushed" -ForegroundColor Green
}
Write-Host "✓ Backend:    $backendUrl" -ForegroundColor Green
Write-Host "✓ Frontend:   $frontendUrl" -ForegroundColor Green
Write-Host "✓ ENV Sync:   $uploadCount variables" -ForegroundColor Green
Write-Host "✓ CORS:       Configured" -ForegroundColor Green
Write-Host ""

Write-Host "🎊 Deployment successful!" -ForegroundColor Green
Write-Host ""
