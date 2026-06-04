# 🛠️ Deployment & Configuration Scripts

## Available Scripts

### 1️⃣ **update-otp-config.ps1** - Full Configuration Manager
Comprehensive script untuk manage OTP configuration dan deployment.

```powershell
# Enable OTP di production (full automation)
.\update-otp-config.ps1

# Disable OTP di production
.\update-otp-config.ps1 -Action disable

# Check current status
.\update-otp-config.ps1 -Action status

# Enable tanpa git push
.\update-otp-config.ps1 -SkipGit

# Enable hanya Railway (skip Vercel)
.\update-otp-config.ps1 -SkipVercel

# Show help
.\update-otp-config.ps1 -Help
```

**Features:**
- ✅ Git commit & push otomatis
- ✅ Set Railway environment variable
- ✅ Set Vercel environment variable
- ✅ Trigger auto-redeploy
- ✅ Status checker
- ✅ Interactive prompts

---

### 2️⃣ **quick-enable-otp.ps1** - One-Command Deploy
Script paling simple, tanpa prompts. Langsung enable OTP dan deploy.

```powershell
.\quick-enable-otp.ps1
```

**What it does:**
1. Git add, commit, push
2. Railway: set SHOW_DEV_OTP=true
3. Railway: trigger deploy
4. Vercel: set SHOW_DEV_OTP=true (if exists)
5. Vercel: trigger deploy

**Use case:** Demo cepat, testing, presentation

---

### 3️⃣ **check-otp-deployment.ps1** - Deployment Checker
Verifikasi apakah OTP config sudah aktif di production.

```powershell
# Basic check
.\check-otp-deployment.ps1

# Check with API test
.\check-otp-deployment.ps1 -BackendUrl "https://your-backend.railway.app"

# Custom test phone
.\check-otp-deployment.ps1 -BackendUrl "https://..." -TestPhone "081234567890"
```

**What it checks:**
1. ✅ Railway environment variables
2. ✅ Vercel environment variables
3. ✅ API endpoint (actual OTP response)
4. ✅ Railway logs for OTP entries

---

### 4️⃣ **deploy-all.ps1** - Full Deployment (Updated)
Deploy backend + frontend dengan OTP configuration prompt.

```powershell
.\deploy-all.ps1
```

**Updated features:**
- Deploy backend ke Railway
- Deploy frontend ke Vercel
- **NEW:** Prompt untuk enable/disable OTP
- CORS configuration reminder

---

## 🚀 Quick Start Guide

### First Time Deployment

```powershell
# 1. Install CLI tools (if not installed)
npm install -g @railway/cli vercel

# 2. Login to services
railway login
vercel login

# 3. Deploy everything
.\deploy-all.ps1

# 4. Enable OTP display
# (will be prompted during deploy-all.ps1)
# OR manually:
.\update-otp-config.ps1
```

---

### Enable OTP for Demo

```powershell
# Option A: One-command (fastest)
.\quick-enable-otp.ps1

# Option B: With control
.\update-otp-config.ps1

# Option C: Manual
railway variables set SHOW_DEV_OTP=true
railway up
```

---

### Verify OTP is Working

```powershell
# Check configuration
.\check-otp-deployment.ps1 -BackendUrl "https://your-backend.railway.app"

# Check logs manually
railway logs | Select-String "OTP"

# Test on frontend
# 1. Open production URL
# 2. Register dengan nomor test
# 3. Check badge "Kode OTP (dev mode): 123456"
```

---

### Disable OTP After Demo

```powershell
# Disable OTP
.\update-otp-config.ps1 -Action disable

# Or manual
railway variables set SHOW_DEV_OTP=false
railway up
```

---

## 📋 Workflow Examples

### Scenario 1: Weekly Demo Presentation

```powershell
# Before presentation (5 minutes before)
.\quick-enable-otp.ps1

# During presentation
# - Open app
# - Register user
# - Show OTP badge
# - Complete verification

# After presentation
.\update-otp-config.ps1 -Action disable
```

---

### Scenario 2: Testing New Features

```powershell
# 1. Make code changes
# 2. Enable OTP for testing
.\update-otp-config.ps1

# 3. Verify deployment
.\check-otp-deployment.ps1 -BackendUrl "https://..."

# 4. Test on production
# ...

# 5. If working, keep it. If not, rollback:
git revert HEAD
git push
```

---

### Scenario 3: Scheduled Check

```powershell
# Check if OTP is currently enabled
.\update-otp-config.ps1 -Action status

# Check deployment health
.\check-otp-deployment.ps1 -BackendUrl "https://..."

# Review logs
railway logs --limit 100 | Select-String "OTP"
```

---

## 🔧 Configuration Files

### Environment Variables

| Variable | Value | Effect |
|----------|-------|--------|
| `SHOW_DEV_OTP=true` | Force enable | Always show OTP in response |
| `SHOW_DEV_OTP=false` | Force disable | Never show OTP |
| `SHOW_DEV_OTP` not set | Auto | Show only in development |

### Where to Set

**Railway:**
```powershell
railway variables set SHOW_DEV_OTP=true
```

**Vercel:**
```powershell
vercel env add SHOW_DEV_OTP production
# Input: true
```

**Local (.env):**
```env
SHOW_DEV_OTP=true
```

---

## 🐛 Troubleshooting

### Script Fails: "railway: command not found"

```powershell
# Install Railway CLI
npm install -g @railway/cli

# Or with npm
npm i -g @railway/cli@latest

# Verify
railway --version
```

---

### Script Fails: "vercel: command not found"

```powershell
# Install Vercel CLI
npm install -g vercel

# Verify
vercel --version
```

---

### OTP Not Showing After Deploy

```powershell
# 1. Check env var is set
railway variables | Select-String "SHOW_DEV_OTP"

# 2. Check deployment logs
railway logs | Select-String "OTP"

# 3. Force redeploy
railway up --detach

# 4. Test API directly
Invoke-RestMethod -Uri "https://your-backend.railway.app/api/auth/otp/send" `
  -Method POST `
  -Body '{"phone":"081234567890"}' `
  -ContentType "application/json"
```

---

### Git Push Fails

```powershell
# Check git status
git status

# Pull latest changes first
git pull origin main

# Then run script
.\update-otp-config.ps1
```

---

### Railway/Vercel Not Logged In

```powershell
# Railway
railway login

# Vercel
vercel login

# Verify
railway whoami
vercel whoami
```

---

## 📚 Additional Resources

- **Full OTP Guide:** `DEV_OTP_GUIDE.md`
- **Deployment Guide:** `DEPLOYMENT_GUIDE.md`
- **Quick Start:** `QUICK_START_DEPLOY.md`
- **CLI Reference:** `DEPLOY_CLI_GUIDE.md`

---

## 🎯 Best Practices

1. **Always test locally first** before enabling in production
2. **Use `-Action status`** to check current config before changes
3. **Monitor logs** after deployment: `railway logs -f`
4. **Disable OTP** after demo/testing for security
5. **Document changes** in git commit messages
6. **Keep CLI tools updated**: `npm update -g @railway/cli vercel`

---

## ⚠️ Security Notes

- `SHOW_DEV_OTP=true` should only be used for:
  - ✅ Demo/presentation
  - ✅ Testing environment
  - ✅ Staging server
  - ❌ **NOT for real production with real users**

- Always disable after use:
  ```powershell
  .\update-otp-config.ps1 -Action disable
  ```

---

## 📞 Support

If scripts fail:

1. Check prerequisites:
   - Node.js installed
   - Railway CLI installed
   - Vercel CLI installed
   - Logged in to both services

2. Run status check:
   ```powershell
   .\check-otp-deployment.ps1
   ```

3. Check logs:
   ```powershell
   railway logs
   vercel logs
   ```

4. Manual fallback:
   - Set env vars via web dashboard
   - Deploy via web interface

---

**Last Updated:** Juni 2026  
**Version:** 1.0.0
