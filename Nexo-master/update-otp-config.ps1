# ============================================================================
# Update OTP Configuration & Deploy Script
# ============================================================================
# Script ini akan:
# 1. Git commit & push perubahan code
# 2. Set SHOW_DEV_OTP=true di Railway backend
# 3. Set SHOW_DEV_OTP=true di Vercel (jika backend di Vercel)
# 4. Trigger redeploy otomatis
# ============================================================================

param(
    [string]$Action = "enable",  # enable, disable, status
    [switch]$SkipGit,
    [switch]$SkipRailway,
    [switch]$SkipVercel,
    [switch]$Help
)

# Colors
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

# Show help
if ($Help) {
    Write-Host @"
Usage: .\update-otp-config.ps1 [OPTIONS]

Options:
  -Action <enable|disable|status>  Set OTP display mode (default: enable)
  -SkipGit                         Skip git commit & push
  -SkipRailway                     Skip Railway deployment
  -SkipVercel                      Skip Vercel deployment
  -Help                            Show this help message

Examples:
  .\update-otp-config.ps1                    # Enable OTP di production
  .\update-otp-config.ps1 -Action disable    # Disable OTP di production
  .\update-otp-config.ps1 -Action status     # Check current config
  .\update-otp-config.ps1 -SkipGit           # Update tanpa git push

"@
    exit 0
}

# Header
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║     🔧 NEXO - OTP Configuration & Deployment Manager          ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Magenta

# Determine OTP value based on action
$OTP_VALUE = switch ($Action.ToLower()) {
    "enable"  { "true" }
    "disable" { "false" }
    "status"  { "" }
    default   { 
        Write-Error "Invalid action: $Action. Use 'enable', 'disable', or 'status'"
        exit 1
    }
}

# ============================================================================
# STEP 1: Git Operations
# ============================================================================

if (-not $SkipGit -and $Action -ne "status") {
    Write-Info "📦 STEP 1: Git Commit & Push"
    Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if git is installed
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "❌ Git tidak ditemukan. Install Git terlebih dahulu."
        exit 1
    }
    
    # Check for uncommitted changes
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        Write-Info "📝 Uncommitted changes detected. Committing..."
        
        # Show changes
        Write-Host "`nFiles to be committed:" -ForegroundColor Yellow
        git status --short
        
        # Stage all changes
        git add .
        
        # Create commit message
        $commitMsg = if ($Action -eq "enable") {
            "feat: enable dev OTP display in production for testing"
        } else {
            "feat: disable dev OTP display in production"
        }
        
        git commit -m $commitMsg
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✅ Changes committed successfully"
        } else {
            Write-Error "❌ Git commit failed"
            exit 1
        }
        
        # Push to remote
        Write-Info "`n🚀 Pushing to remote repository..."
        $currentBranch = git branch --show-current
        git push origin $currentBranch
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✅ Pushed to origin/$currentBranch"
        } else {
            Write-Error "❌ Git push failed"
            exit 1
        }
    } else {
        Write-Success "✅ No uncommitted changes. Repository is clean."
    }
    
    Write-Host ""
} elseif ($Action -eq "status") {
    Write-Info "📊 STEP 1: Checking Git Status"
    Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    git status --short
    Write-Host ""
}

# ============================================================================
# STEP 2: Railway Deployment
# ============================================================================

if (-not $SkipRailway) {
    Write-Info "🚂 STEP 2: Railway Deployment"
    Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if Railway CLI is installed
    if (-not (Get-Command railway -ErrorAction SilentlyContinue)) {
        Write-Warning "⚠️  Railway CLI tidak ditemukan."
        Write-Info "Install dengan: npm i -g @railway/cli"
        Write-Info "Atau skip dengan: -SkipRailway"
    } else {
        if ($Action -eq "status") {
            # Check current Railway variables
            Write-Info "🔍 Checking Railway environment variables..."
            railway variables
        } else {
            # Set Railway environment variable
            Write-Info "⚙️  Setting SHOW_DEV_OTP=$OTP_VALUE in Railway..."
            
            # Try to set the variable
            $railwayCmd = "railway variables set SHOW_DEV_OTP=$OTP_VALUE"
            Invoke-Expression $railwayCmd
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "✅ Railway variable set successfully"
                
                # Trigger redeploy
                Write-Info "`n🚀 Triggering Railway redeploy..."
                railway up --detach
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "✅ Railway deployment triggered"
                    Write-Info "📍 Check deployment status: railway status"
                    Write-Info "📍 View logs: railway logs"
                } else {
                    Write-Warning "⚠️  Railway deployment trigger failed. Deploy manually with: railway up"
                }
            } else {
                Write-Error "❌ Failed to set Railway variable"
                Write-Info "💡 Try manual: railway variables set SHOW_DEV_OTP=$OTP_VALUE"
            }
        }
    }
    
    Write-Host ""
}

# ============================================================================
# STEP 3: Vercel Deployment
# ============================================================================

if (-not $SkipVercel) {
    Write-Info "▲ STEP 3: Vercel Deployment"
    Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if Vercel CLI is installed
    if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
        Write-Warning "⚠️  Vercel CLI tidak ditemukan."
        Write-Info "Install dengan: npm i -g vercel"
        Write-Info "Atau skip dengan: -SkipVercel"
    } else {
        if ($Action -eq "status") {
            # Check current Vercel env vars
            Write-Info "🔍 Checking Vercel environment variables..."
            Write-Host "`nFrontend:" -ForegroundColor Yellow
            Push-Location app
            vercel env ls production
            Pop-Location
            
            Write-Host "`nBackend (if exists):" -ForegroundColor Yellow
            if (Test-Path "app/backend") {
                Push-Location app/backend
                vercel env ls production 2>$null
                Pop-Location
            } else {
                Write-Info "No separate backend folder for Vercel"
            }
        } else {
            # Ask user where to set the variable
            Write-Info "📋 Where is your backend deployed on Vercel?"
            Write-Host "  1. Backend di folder 'app/backend' (monorepo)" -ForegroundColor Cyan
            Write-Host "  2. Backend project terpisah" -ForegroundColor Cyan
            Write-Host "  3. Backend tidak di Vercel (skip)" -ForegroundColor Cyan
            
            $choice = Read-Host "`nPilihan (1/2/3)"
            
            switch ($choice) {
                "1" {
                    # Backend in app/backend
                    if (Test-Path "app/backend") {
                        Write-Info "`n⚙️  Setting SHOW_DEV_OTP=$OTP_VALUE for backend..."
                        Push-Location app/backend
                        
                        # Remove existing env var if exists
                        vercel env rm SHOW_DEV_OTP production -y 2>$null
                        
                        # Add new env var
                        Write-Output $OTP_VALUE | vercel env add SHOW_DEV_OTP production
                        
                        if ($LASTEXITCODE -eq 0) {
                            Write-Success "✅ Vercel backend variable set"
                            
                            # Trigger redeploy
                            Write-Info "`n🚀 Triggering Vercel redeploy..."
                            vercel --prod --yes
                            
                            if ($LASTEXITCODE -eq 0) {
                                Write-Success "✅ Vercel deployment complete"
                            }
                        }
                        
                        Pop-Location
                    } else {
                        Write-Error "❌ Folder app/backend tidak ditemukan"
                    }
                }
                "2" {
                    # Separate backend project
                    $backendPath = Read-Host "Masukkan path ke backend project"
                    
                    if (Test-Path $backendPath) {
                        Push-Location $backendPath
                        
                        vercel env rm SHOW_DEV_OTP production -y 2>$null
                        Write-Output $OTP_VALUE | vercel env add SHOW_DEV_OTP production
                        
                        if ($LASTEXITCODE -eq 0) {
                            Write-Success "✅ Vercel variable set"
                            vercel --prod --yes
                        }
                        
                        Pop-Location
                    } else {
                        Write-Error "❌ Path tidak valid: $backendPath"
                    }
                }
                "3" {
                    Write-Info "⏭️  Skipping Vercel backend deployment"
                }
                default {
                    Write-Warning "⚠️  Invalid choice. Skipping Vercel."
                }
            }
        }
    }
    
    Write-Host ""
}

# ============================================================================
# Summary
# ============================================================================

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    ✨ DEPLOYMENT COMPLETE ✨                   ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

if ($Action -eq "enable") {
    Write-Success "🎉 Dev OTP telah DIAKTIFKAN di production!"
    Write-Info "`n📝 Next steps:"
    Write-Info "  1. Tunggu deployment selesai (~2-5 menit)"
    Write-Info "  2. Test di production URL"
    Write-Info "  3. OTP badge harusnya muncul di UI"
    Write-Info "`n🔍 Verify:"
    Write-Info "  • Railway: railway logs"
    Write-Info "  • Vercel: vercel logs"
} elseif ($Action -eq "disable") {
    Write-Success "🔒 Dev OTP telah DINONAKTIFKAN di production"
    Write-Info "`n📝 Next steps:"
    Write-Info "  1. Tunggu deployment selesai"
    Write-Info "  2. OTP tidak akan muncul di UI"
} else {
    Write-Info "📊 Status check complete"
}

Write-Host "`n💡 Tips:"
Write-Info "  • Check deployment: .\check-deployment.ps1"
Write-Info "  • View full guide: cat DEV_OTP_GUIDE.md"
Write-Info "  • Toggle OTP anytime with this script"

Write-Host ""
