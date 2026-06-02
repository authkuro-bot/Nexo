# ============================================
# Auto Deploy from .env Files
# ============================================
# Script ini otomatis baca .env dan upload ke Railway & Vercel

$ErrorActionPreference = "Continue"

Write-Host "🚀 Auto Deploy Nexo from .env Files" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$projectPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master"
Set-Location $projectPath

# ============================================
# Function: Parse .env file
# ============================================
function Parse-EnvFile {
    param([string]$Path)
    
    $envVars = @{}
    
    if (!(Test-Path $Path)) {
        Write-Host "⚠️  File not found: $Path" -ForegroundColor Yellow
        return $envVars
    }
    
    $content = Get-Content $Path
    foreach ($line in $content) {
        $line = $line.Trim()
        
        # Skip comments and empty lines
        if ($line -match '^#' -or $line -eq '') {
            continue
        }
        
        # Parse KEY=VALUE
        if ($line -match '^([^=]+)=(.*)$') {
            $key = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            
            # Remove quotes if present
            $value = $value -replace '^["'']|["'']$', ''
            
            $envVars[$key] = $value
        }
    }
    
    return $envVars
}

# ============================================
# STEP 1: Check CLI Tools
# ============================================
Write-Host "🔧 Checking CLI tools..." -ForegroundColor Yellow

$railwayCheck = Get-Command railway -ErrorAction SilentlyContinue
$vercelCheck = Get-Command vercel -ErrorAction SilentlyContinue

if (!$railwayCheck -or !$vercelCheck) {
    Write-Host "❌ Missing CLI tools!" -ForegroundColor Red
    
    if (!$railwayCheck) {
        Write-Host "   Installing Railway CLI..." -ForegroundColor Yellow
        npm install -g @railway/cli
    }
    
    if (!$vercelCheck) {
        Write-Host "   Installing Vercel CLI..." -ForegroundColor Yellow
        npm install -g vercel
    }
}

Write-Host "✓ CLI tools ready" -ForegroundColor Green

# ============================================
# STEP 2: Check Authentication
# ============================================
Write-Host "`n🔐 Checking authentication..." -ForegroundColor Yellow

$railwayAuth = railway whoami 2>&1
$railwayLoggedIn = $LASTEXITCODE -eq 0

$vercelAuth = vercel whoami 2>&1
$vercelLoggedIn = $LASTEXITCODE -eq 0

if (!$railwayLoggedIn) {
    Write-Host "🔐 Logging in to Railway..." -ForegroundColor Yellow
    railway login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Railway login failed!" -ForegroundColor Red
        exit 1
    }
    $railwayAuth = railway whoami 2>&1
}

if (!$vercelLoggedIn) {
    Write-Host "🔐 Logging in to Vercel..." -ForegroundColor Yellow
    vercel login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Vercel login failed!" -ForegroundColor Red
        exit 1
    }
    $vercelAuth = vercel whoami 2>&1
}

Write-Host "✓ Railway: $railwayAuth" -ForegroundColor Green
Write-Host "✓ Vercel: $vercelAuth" -ForegroundColor Green

# ============================================
# STEP 3: Parse Backend .env
# ============================================
Write-Host "`n📖 Reading backend .env..." -ForegroundColor Yellow

$backendEnvPath = "$projectPath\app\backend\.env"
$backendEnv = Parse-EnvFile -Path $backendEnvPath

if ($backendEnv.Count -eq 0) {
    Write-Host "❌ No backend .env found!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Found $($backendEnv.Count) backend environment variables" -ForegroundColor Green

# ============================================
# STEP 4: Deploy Backend to Railway
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📦 DEPLOYING BACKEND TO RAILWAY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Set-Location "$projectPath\app\backend"

# Check if Railway project exists
$railwayStatus = railway status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  No Railway project linked. Initializing..." -ForegroundColor Yellow
    railway init
}

Write-Host "`n🔐 Uploading environment variables to Railway..." -ForegroundColor Yellow

# Production environment variables for Railway
$railwayVars = @{
    # Server
    "PORT" = "3000"
    "NODE_ENV" = "production"
    "FRONTEND_URL" = "*"  # Will update after frontend deploy
    
    # Supabase
    "SUPABASE_URL" = $backendEnv["SUPABASE_URL"]
    "SUPABASE_SERVICE_KEY" = $backendEnv["SUPABASE_SERVICE_KEY"]
    
    # JWT
    "JWT_SECRET" = $backendEnv["JWT_SECRET"]
    "JWT_EXPIRES_IN" = $backendEnv["JWT_EXPIRES_IN"]
    
    # Cloudflare R2
    "CLOUDFLARE_R2_ACCOUNT_ID" = $backendEnv["CLOUDFLARE_R2_ACCOUNT_ID"]
    "CLOUDFLARE_R2_ACCESS_KEY_ID" = $backendEnv["CLOUDFLARE_R2_ACCESS_KEY_ID"]
    "CLOUDFLARE_R2_SECRET_ACCESS_KEY" = $backendEnv["CLOUDFLARE_R2_SECRET_ACCESS_KEY"]
    "CLOUDFLARE_R2_BUCKET" = $backendEnv["CLOUDFLARE_R2_BUCKET"]
    "CLOUDFLARE_R2_PUBLIC_URL" = $backendEnv["CLOUDFLARE_R2_PUBLIC_URL"]
    "CLOUDFLARE_R2_ENDPOINT" = $backendEnv["CLOUDFLARE_R2_ENDPOINT"]
    
    # AI Provider
    "AI_PROVIDER" = $backendEnv["AI_PROVIDER"]
    "AI_PROVIDER_STRICT" = $backendEnv["AI_PROVIDER_STRICT"]
    "AI_PROVIDER_TIMEOUT_MS" = $backendEnv["AI_PROVIDER_TIMEOUT_MS"]
    "AI_MAX_OUTPUT_TOKENS" = $backendEnv["AI_MAX_OUTPUT_TOKENS"]
    
    # OpenAI
    "OPENAI_API_KEY" = $backendEnv["OPENAI_API_KEY"]
    "OPENAI_MODEL" = $backendEnv["OPENAI_MODEL"]
    "OPENAI_BASE_URL" = $backendEnv["OPENAI_BASE_URL"]
    
    # Data Provider
    "DATA_PROVIDER" = $backendEnv["DATA_PROVIDER"]
    "AUTH_DATA_MODE" = $backendEnv["AUTH_DATA_MODE"]
    "OTP_DELIVERY" = "production"  # Override for production
    "MEDIA_PROVIDER" = $backendEnv["MEDIA_PROVIDER"]
    "RESEARCH_LAKE_PROVIDER" = $backendEnv["RESEARCH_LAKE_PROVIDER"]
    "AI_TRACE_PROVIDER" = $backendEnv["AI_TRACE_PROVIDER"]
    
    # Cache & Intervals
    "DASHBOARD_REALTIME_INTERVAL_MS" = $backendEnv["DASHBOARD_REALTIME_INTERVAL_MS"]
    "DASHBOARD_METRICS_CACHE_TTL_MS" = $backendEnv["DASHBOARD_METRICS_CACHE_TTL_MS"]
    "AI_RECOMMENDATION_CACHE_TTL_MS" = $backendEnv["AI_RECOMMENDATION_CACHE_TTL_MS"]
    "SATURATION_REFRESH_INTERVAL_MS" = $backendEnv["SATURATION_REFRESH_INTERVAL_MS"]
}

# Upload variables to Railway
$uploadCount = 0
$skipCount = 0

foreach ($key in $railwayVars.Keys) {
    $value = $railwayVars[$key]
    
    if ([string]::IsNullOrWhiteSpace($value)) {
        Write-Host "   ⏭️  Skipping $key (empty value)" -ForegroundColor Gray
        $skipCount++
        continue
    }
    
    Write-Host "   📤 Setting $key..." -ForegroundColor Gray
    railway variables set "$key=$value" 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        $uploadCount++
    } else {
        Write-Host "   ⚠️  Failed to set $key" -ForegroundColor Yellow
    }
}

Write-Host "`n✓ Uploaded $uploadCount variables, skipped $skipCount" -ForegroundColor Green

# Deploy backend
Write-Host "`n📦 Deploying backend..." -ForegroundColor Yellow
railway up

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Backend deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Backend deployed successfully!" -ForegroundColor Green

# Get backend URL
$backendUrl = railway domain 2>&1
Write-Host "🔗 Backend URL: $backendUrl" -ForegroundColor Blue

# ============================================
# STEP 5: Parse Frontend .env
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📦 DEPLOYING FRONTEND TO VERCEL" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Set-Location "$projectPath\app"

Write-Host "📖 Reading frontend .env..." -ForegroundColor Yellow

$frontendEnvPath = "$projectPath\app\.env"
$frontendEnv = Parse-EnvFile -Path $frontendEnvPath

Write-Host "✓ Found $($frontendEnv.Count) frontend environment variables" -ForegroundColor Green

# ============================================
# STEP 6: Deploy Frontend to Vercel
# ============================================

# Check if Vercel project exists
$vercelProject = vercel inspect 2>&1
$isLinked = $LASTEXITCODE -eq 0

if (!$isLinked) {
    Write-Host "⚠️  No Vercel project linked. Will create during deploy..." -ForegroundColor Yellow
}

Write-Host "`n🔐 Setting environment variables in Vercel..." -ForegroundColor Yellow

# Production environment variables for Vercel
$vercelVars = @{
    "VITE_API_URL" = $backendUrl
    "VITE_SUPABASE_URL" = $frontendEnv["SUPABASE_URL"]
    "VITE_SUPABASE_ANON_KEY" = $frontendEnv["SUPABASE_SERVICE_KEY"]  # Use service key or anon key
    "VITE_CLOUDFLARE_R2_PUBLIC_URL" = $frontendEnv["CLOUDFLARE_R2_PUBLIC_URL"]
}

foreach ($key in $vercelVars.Keys) {
    $value = $vercelVars[$key]
    
    if ([string]::IsNullOrWhiteSpace($value)) {
        Write-Host "   ⏭️  Skipping $key (empty value)" -ForegroundColor Gray
        continue
    }
    
    Write-Host "   📤 Setting $key..." -ForegroundColor Gray
    
    # Check if variable exists
    $existingVar = vercel env ls 2>&1 | Select-String -Pattern $key -Quiet
    
    if ($existingVar) {
        Write-Host "      (already exists, skipping)" -ForegroundColor Gray
    } else {
        # Add new variable
        echo $value | vercel env add $key production 2>&1 | Out-Null
    }
}

Write-Host "✓ Environment variables configured" -ForegroundColor Green

# Deploy frontend
Write-Host "`n📦 Deploying frontend..." -ForegroundColor Yellow
vercel --prod --yes

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Frontend deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Frontend deployed successfully!" -ForegroundColor Green

# Get frontend URL from deployment
$frontendUrl = vercel ls --limit 1 2>&1 | Select-String -Pattern "https://.*\.vercel\.app" | ForEach-Object { $_.Matches[0].Value }

Write-Host "🔗 Frontend URL: $frontendUrl" -ForegroundColor Blue

# ============================================
# STEP 7: Update CORS in Backend
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "🔗 UPDATING CORS CONFIGURATION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Set-Location "$projectPath\app\backend"

if ($frontendUrl) {
    Write-Host "📤 Setting CORS_ORIGIN to: $frontendUrl" -ForegroundColor Yellow
    railway variables set "CORS_ORIGIN=$frontendUrl" 2>&1 | Out-Null
    railway variables set "FRONTEND_URL=$frontendUrl" 2>&1 | Out-Null
    
    Write-Host "✓ CORS updated (backend will auto-redeploy)" -ForegroundColor Green
    Write-Host "   Waiting for redeploy..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
} else {
    Write-Host "⚠️  Could not get frontend URL. Update CORS manually:" -ForegroundColor Yellow
    Write-Host "   railway variables set CORS_ORIGIN=<frontend-url>" -ForegroundColor Gray
}

# ============================================
# FINAL SUMMARY
# ============================================
Set-Location $projectPath

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "🎉 DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "📋 Deployment URLs:" -ForegroundColor Cyan
Write-Host "   Backend:  $backendUrl" -ForegroundColor Blue
if ($frontendUrl) {
    Write-Host "   Frontend: $frontendUrl" -ForegroundColor Blue
} else {
    Write-Host "   Frontend: Check Vercel dashboard" -ForegroundColor Yellow
}

Write-Host "`n✅ Next steps:" -ForegroundColor Cyan
Write-Host "   1. Open frontend URL in browser" -ForegroundColor White
Write-Host "   2. Test application functionality" -ForegroundColor White
Write-Host "   3. Check logs:" -ForegroundColor White
Write-Host "      - railway logs" -ForegroundColor Gray
Write-Host "      - vercel logs" -ForegroundColor Gray

Write-Host "`n📚 Environment variables:" -ForegroundColor Cyan
Write-Host "   ✓ $uploadCount variables uploaded to Railway" -ForegroundColor Green
Write-Host "   ✓ $($vercelVars.Count) variables set in Vercel" -ForegroundColor Green

Write-Host "`n🔄 Future updates:" -ForegroundColor Cyan
Write-Host "   - Update .env files" -ForegroundColor White
Write-Host "   - Run: .\auto-deploy-from-env.ps1" -ForegroundColor White
Write-Host "   - Or run: .\deploy-all.ps1 (without env sync)" -ForegroundColor White

Write-Host "`n🎊 Happy deploying!" -ForegroundColor Green
