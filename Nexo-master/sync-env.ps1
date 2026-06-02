# ============================================
# Sync .env to Railway & Vercel
# ============================================
# Script ini hanya sync environment variables
# Tidak melakukan deployment

$ErrorActionPreference = "Continue"

Write-Host "🔐 Sync Environment Variables" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$projectPath = "C:\Users\Kuro\Music\Nexo-master\Nexo-master"

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
            $value = $value -replace '^["'']|["'']$', ''
            $envVars[$key] = $value
        }
    }
    
    return $envVars
}

# ============================================
# Sync Backend to Railway
# ============================================
Write-Host "📤 Syncing backend .env to Railway..." -ForegroundColor Yellow

Set-Location "$projectPath\app\backend"

$backendEnv = Parse-EnvFile -Path "$projectPath\app\backend\.env"

# Map production variables
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
    "OPENAI_BASE_URL" = $backendEnv["OPENAI_BASE_URL"]
    "DATA_PROVIDER" = $backendEnv["DATA_PROVIDER"]
    "MEDIA_PROVIDER" = $backendEnv["MEDIA_PROVIDER"]
}

$uploadCount = 0
foreach ($key in $railwayVars.Keys) {
    $value = $railwayVars[$key]
    if (![string]::IsNullOrWhiteSpace($value)) {
        railway variables set "$key=$value" 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✓ $key" -ForegroundColor Green
            $uploadCount++
        }
    }
}

Write-Host "✅ Synced $uploadCount variables to Railway" -ForegroundColor Green

# ============================================
# Sync Frontend to Vercel
# ============================================
Write-Host "`n📤 Syncing frontend .env to Vercel..." -ForegroundColor Yellow

Set-Location "$projectPath\app"

$frontendEnv = Parse-EnvFile -Path "$projectPath\app\.env"

# Get backend URL from Railway
$backendUrl = railway domain 2>&1

$vercelVars = @{
    "VITE_API_URL" = $backendUrl
    "VITE_SUPABASE_URL" = $frontendEnv["SUPABASE_URL"]
    "VITE_SUPABASE_ANON_KEY" = $frontendEnv["SUPABASE_SERVICE_KEY"]
    "VITE_CLOUDFLARE_R2_PUBLIC_URL" = $frontendEnv["CLOUDFLARE_R2_PUBLIC_URL"]
}

foreach ($key in $vercelVars.Keys) {
    $value = $vercelVars[$key]
    if (![string]::IsNullOrWhiteSpace($value)) {
        Write-Host "   ✓ $key" -ForegroundColor Green
        echo $value | vercel env add $key production 2>&1 | Out-Null
    }
}

Write-Host "✅ Synced $($vercelVars.Count) variables to Vercel" -ForegroundColor Green

Write-Host "`n🎉 Environment variables synced!" -ForegroundColor Cyan
Write-Host "   Run .\deploy-all.ps1 to deploy with new variables" -ForegroundColor White

Set-Location $projectPath
