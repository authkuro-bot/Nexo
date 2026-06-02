# 🚀 Deploy Nexo via CLI (Command Line)

**Panduan Lengkap Deploy Otomatis dengan Command Line**

Email: authkuro@gmail.com
Path: C:\Users\Kuro\Music\Nexo-master\Nexo-master

---

## 📋 Prerequisites

### 1. Install Node.js & npm

Cek apakah sudah terinstall:

```bash
node --version
npm --version
```

Jika belum, download di: https://nodejs.org (pilih LTS)

### 2. Install Git

```bash
git --version
```

Jika belum: https://git-scm.com/download/win

---

## 🔧 TAHAP 1: Install CLI Tools

### Step 1.1: Install Vercel CLI

```bash
npm install -g vercel
```

Verifikasi:
```bash
vercel --version
```

### Step 1.2: Install Railway CLI

```bash
npm install -g @railway/cli
```

Verifikasi:
```bash
railway --version
```

---

## 🔐 TAHAP 2: Login & Authentication

### Step 2.1: Login Vercel

```bash
# Buka terminal di: C:\Users\Kuro\Music\Nexo-master\Nexo-master
cd C:\Users\Kuro\Music\Nexo-master\Nexo-master

# Login Vercel
vercel login
```

**Akan muncul prompt:**
```
> Log in to Vercel
? Continue with Google
```

- **Pilih:** "Continue with Google"
- Browser akan terbuka otomatis
- **Login dengan:** authkuro@gmail.com
- **Authorize** Vercel CLI
- Kembali ke terminal, akan muncul: `✓ Logged in`

### Step 2.2: Login Railway

```bash
# Login Railway
railway login
```

**Akan muncul:**
```
> Login with browser? (Y/n)
```

- **Ketik:** Y dan Enter
- Browser akan terbuka
- **Login dengan Google:** authkuro@gmail.com
- **Authorize** Railway CLI
- Kembali ke terminal: `✓ Logged in as authkuro@gmail.com`

---

## 📦 TAHAP 3: Setup Git & GitHub

### Step 3.1: Initialize Git (jika belum)

```bash
cd C:\Users\Kuro\Music\Nexo-master\Nexo-master

# Cek apakah sudah ada .git
dir .git

# Jika tidak ada, init:
git init
git branch -M main
```

### Step 3.2: Create .gitignore

Pastikan file `.gitignore` ada dan berisi:

```bash
# Cek isi .gitignore
type .gitignore
```

Jika kosong atau tidak ada, buat:

```bash
echo node_modules/ > .gitignore
echo .env >> .gitignore
echo .env.local >> .gitignore
echo dist/ >> .gitignore
echo build/ >> .gitignore
echo .DS_Store >> .gitignore
```

### Step 3.3: Push to GitHub

**Opsi A: Via GitHub CLI (Recommended)**

Install GitHub CLI:
```bash
# Download dari: https://cli.github.com/
# Atau via winget:
winget install --id GitHub.cli
```

Login & create repo:
```bash
# Login GitHub
gh auth login
# Pilih: GitHub.com → HTTPS → Login with browser → authkuro@gmail.com

# Create repo & push
gh repo create Nexo --private --source=. --push
```

**Opsi B: Manual via GitHub Website**

1. Buka https://github.com/new
2. Login dengan authkuro@gmail.com
3. Nama repository: `Nexo`
4. Private/Public: pilih sesuai kebutuhan
5. **JANGAN** centang "Initialize with README"
6. Klik "Create repository"

Lalu di terminal:
```bash
git remote add origin https://github.com/authkuro/Nexo.git
git add .
git commit -m "Initial commit for deployment"
git push -u origin main
```

---

## 🚂 TAHAP 4: Deploy Backend ke Railway (CLI)

### Step 4.1: Navigate ke Backend

```bash
cd C:\Users\Kuro\Music\Nexo-master\Nexo-master\app\backend
```

### Step 4.2: Initialize Railway Project

```bash
railway init
```

**Interactive prompts:**
```
? Select a project: Create new project
? Enter project name: nexo-backend
? Select an environment: production
✓ Created project nexo-backend
```

### Step 4.3: Link to GitHub (Optional tapi Recommended)

```bash
# Link ke GitHub untuk auto-deploy
railway link
```

Atau skip ini jika ingin manual deploy saja.

### Step 4.4: Set Environment Variables

**Cara 1: Via Command Line (Satu per satu)**

```bash
# Database Supabase
railway variables set SUPABASE_URL=https://xxxxxxxxxxxxxx.supabase.co
railway variables set SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
railway variables set SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Server
railway variables set PORT=3000
railway variables set NODE_ENV=production

# JWT Secret (generate random)
railway variables set JWT_SECRET=your-super-secret-jwt-key-min-32-chars

# OpenAI
railway variables set OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx

# CORS (temporary)
railway variables set CORS_ORIGIN=*
```

**Cara 2: Via File (Lebih Cepat)**

Buat file `railway.env`:

```bash
# Di folder app/backend, buat file railway.env
notepad railway.env
```

Isi file:
```bash
SUPABASE_URL=https://xxxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
PORT=3000
NODE_ENV=production
JWT_SECRET=your-super-secret-jwt-key-min-32-chars
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
CORS_ORIGIN=*
```

Upload:
```bash
railway variables set --from-file railway.env

# Hapus file setelah upload (keamanan)
del railway.env
```

### Step 4.5: Deploy Backend

```bash
railway up
```

Output:
```
✓ Build successful
✓ Deployment successful
✓ Service: nexo-backend
```

### Step 4.6: Get Backend URL

```bash
railway domain
```

Output:
```
✓ https://nexo-backend-production-xxxx.up.railway.app
```

**COPY URL INI** - akan digunakan untuk frontend!

### Step 4.7: Test Backend

```bash
# Test health endpoint
curl https://nexo-backend-production-xxxx.up.railway.app/api/health
```

atau buka di browser.

---

## 🎨 TAHAP 5: Deploy Frontend ke Vercel (CLI)

### Step 5.1: Navigate ke Frontend

```bash
cd C:\Users\Kuro\Music\Nexo-master\Nexo-master\app
```

### Step 5.2: Deploy dengan Interactive Mode

```bash
vercel
```

**Interactive prompts:**

```
? Set up and deploy "C:\Users\Kuro\Music\Nexo-master\Nexo-master\app"?
→ Y

? Which scope do you want to deploy to?
→ authkuro (pilih username Anda)

? Link to existing project?
→ N

? What's your project's name?
→ nexo

? In which directory is your code located?
→ ./ (tekan Enter)

? Want to override the settings? [y/N]
→ Y

? Which settings do you want to override?
→ (pilih dengan spacebar)
  [x] Build Command
  [x] Output Directory
  [x] Development Command
→ Enter

? What's your Build Command?
→ npm run build

? What's your Output Directory?
→ dist

? What's your Development Command?
→ npm run dev
```

### Step 5.3: Set Environment Variables

Vercel akan deploy tanpa env vars dulu. Setelah deploy, set env vars:

```bash
# Set environment variables
vercel env add VITE_API_URL

# Akan muncul prompt:
? What's the value of VITE_API_URL?
→ https://nexo-backend-production-xxxx.up.railway.app

? Add VITE_API_URL to which Environments?
→ Production, Preview, Development (pilih semua)

# Ulangi untuk variable lainnya:
vercel env add VITE_SUPABASE_URL
# Value: https://xxxxxxxxxxxxxx.supabase.co

vercel env add VITE_SUPABASE_ANON_KEY
# Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

vercel env add VITE_ENABLE_AI_CHAT
# Value: true
```

### Step 5.4: Redeploy dengan Environment Variables

```bash
# Deploy production dengan env vars
vercel --prod
```

Output:
```
✓ Production: https://nexo-xxxx.vercel.app
```

**COPY URL INI!**

---

## 🔗 TAHAP 6: Update CORS di Backend

Sekarang backend perlu tahu domain frontend.

```bash
# Navigate ke backend
cd C:\Users\Kuro\Music\Nexo-master\Nexo-master\app\backend

# Update CORS_ORIGIN
railway variables set CORS_ORIGIN=https://nexo-xxxx.vercel.app

# Railway otomatis redeploy (tunggu 1 menit)
```

Cek status:
```bash
railway status
```

---

## 🎯 TAHAP 7: Verifikasi Deployment

### Test Backend:

```bash
curl https://nexo-backend-production-xxxx.up.railway.app/api/health
```

Expected:
```json
{"status":"ok","runtime":{...}}
```

### Test Frontend:

Buka browser:
```
https://nexo-xxxx.vercel.app
```

Tekan F12 → Network tab → pastikan API calls ke Railway success (200 OK).

---

## 🔄 Update & Redeploy (Future Updates)

### Update Backend:

```bash
# 1. Edit code
# 2. Commit
git add .
git commit -m "Update backend"

# 3. Deploy
cd app/backend
railway up

# Atau jika sudah link GitHub:
git push origin main
# Railway auto-deploy!
```

### Update Frontend:

```bash
# 1. Edit code
# 2. Commit
git add .
git commit -m "Update frontend"

# 3. Deploy
cd app
vercel --prod

# Atau jika sudah link GitHub:
git push origin main
# Vercel auto-deploy!
```

---

## 📜 Script Otomasi

Saya buatkan script untuk deploy otomatis!

### Script 1: deploy-backend.ps1

```powershell
# C:\Users\Kuro\Music\Nexo-master\Nexo-master\deploy-backend.ps1

Write-Host "🚂 Deploying Backend to Railway..." -ForegroundColor Cyan

# Navigate to backend
Set-Location "C:\Users\Kuro\Music\Nexo-master\Nexo-master\app\backend"

# Check if railway is logged in
$railwayStatus = railway whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged in to Railway. Run: railway login" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Logged in as: $railwayStatus" -ForegroundColor Green

# Deploy
Write-Host "📦 Building and deploying..." -ForegroundColor Yellow
railway up

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Backend deployed successfully!" -ForegroundColor Green
    Write-Host "🔗 Getting deployment URL..." -ForegroundColor Yellow
    railway domain
} else {
    Write-Host "`n❌ Deployment failed!" -ForegroundColor Red
    exit 1
}
```

### Script 2: deploy-frontend.ps1

```powershell
# C:\Users\Kuro\Music\Nexo-master\Nexo-master\deploy-frontend.ps1

Write-Host "🎨 Deploying Frontend to Vercel..." -ForegroundColor Cyan

# Navigate to frontend
Set-Location "C:\Users\Kuro\Music\Nexo-master\Nexo-master\app"

# Check if vercel is logged in
$vercelStatus = vercel whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged in to Vercel. Run: vercel login" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Logged in as: $vercelStatus" -ForegroundColor Green

# Deploy production
Write-Host "📦 Building and deploying to production..." -ForegroundColor Yellow
vercel --prod --yes

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Frontend deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Deployment failed!" -ForegroundColor Red
    exit 1
}
```

### Script 3: deploy-all.ps1 (Deploy Both!)

```powershell
# C:\Users\Kuro\Music\Nexo-master\Nexo-master\deploy-all.ps1

Write-Host "🚀 Deploying Nexo (Backend + Frontend)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check logged in status
Write-Host "🔐 Checking authentication..." -ForegroundColor Yellow

$railwayAuth = railway whoami 2>&1
$vercelAuth = vercel whoami 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Please login first:" -ForegroundColor Red
    Write-Host "   railway login" -ForegroundColor Gray
    Write-Host "   vercel login" -ForegroundColor Gray
    exit 1
}

Write-Host "✓ Railway: $railwayAuth" -ForegroundColor Green
Write-Host "✓ Vercel: $vercelAuth" -ForegroundColor Green

# Deploy Backend
Write-Host "`n📦 Step 1/2: Deploying Backend..." -ForegroundColor Cyan
Set-Location "C:\Users\Kuro\Music\Nexo-master\Nexo-master\app\backend"
railway up

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Backend deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Backend deployed!" -ForegroundColor Green
$backendUrl = railway domain 2>&1
Write-Host "🔗 Backend URL: $backendUrl" -ForegroundColor Blue

# Deploy Frontend
Write-Host "`n📦 Step 2/2: Deploying Frontend..." -ForegroundColor Cyan
Set-Location "C:\Users\Kuro\Music\Nexo-master\Nexo-master\app"
vercel --prod --yes

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Frontend deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ All deployments successful!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n🎉 Nexo is now live!" -ForegroundColor Green
Write-Host "📖 Check your Vercel dashboard for the frontend URL" -ForegroundColor Cyan
```

### Cara Pakai Script:

```bash
# Deploy backend saja
.\deploy-backend.ps1

# Deploy frontend saja
.\deploy-frontend.ps1

# Deploy semuanya sekaligus
.\deploy-all.ps1
```

---

## 🛠️ Advanced: CI/CD Auto-Deploy

Setup auto-deploy saat git push:

### Railway Auto-Deploy:

```bash
# Link Railway ke GitHub
cd app/backend
railway link

# Pilih project nexo-backend
# Railway akan auto-deploy setiap kali push ke GitHub!
```

### Vercel Auto-Deploy:

Vercel otomatis setup Git integration saat first deploy. Setiap push ke `main` branch, Vercel auto-deploy.

**Disable auto-deploy:**
```bash
# Via CLI
vercel git disconnect

# Via Dashboard
# Project Settings → Git → Configure
```

---

## 📊 Monitoring via CLI

### Railway:

```bash
# Cek status deployment
railway status

# Lihat logs real-time
railway logs

# Cek environment variables
railway variables

# Lihat info project
railway environment
```

### Vercel:

```bash
# Lihat list deployments
vercel ls

# Lihat logs deployment terakhir
vercel logs

# Lihat environment variables
vercel env ls

# Lihat info project
vercel inspect
```

---

## 🔧 Troubleshooting CLI

### Railway CLI Issues:

```bash
# Railway command not found
npm install -g @railway/cli

# Login expired
railway logout
railway login

# Project not found
railway link
```

### Vercel CLI Issues:

```bash
# Vercel command not found
npm install -g vercel

# Login expired
vercel logout
vercel login

# Project link broken
vercel link
```

---

## 🚀 One-Command Setup (First Time)

Buat script setup lengkap:

```powershell
# setup-and-deploy.ps1

Write-Host "🚀 Nexo First-Time Setup & Deploy" -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Cyan

# Install CLI tools
Write-Host "📦 Installing CLI tools..." -ForegroundColor Yellow
npm install -g vercel @railway/cli

# Login
Write-Host "`n🔐 Login to services..." -ForegroundColor Yellow
Write-Host "Opening Railway login..." -ForegroundColor Cyan
railway login

Write-Host "Opening Vercel login..." -ForegroundColor Cyan
vercel login

# Git setup
Write-Host "`n📦 Setting up Git..." -ForegroundColor Yellow
Set-Location "C:\Users\Kuro\Music\Nexo-master\Nexo-master"

if (!(Test-Path ".git")) {
    git init
    git branch -M main
}

git add .
git commit -m "Initial commit for deployment"

# Create GitHub repo (requires gh CLI)
Write-Host "`n📤 Creating GitHub repository..." -ForegroundColor Yellow
gh repo create Nexo --private --source=. --push

# Deploy
Write-Host "`n🚀 Starting deployment..." -ForegroundColor Yellow
.\deploy-all.ps1

Write-Host "`n✅ Setup complete!" -ForegroundColor Green
```

---

## 📝 Summary Commands

**Quick Reference:**

```bash
# LOGIN (one time)
railway login
vercel login

# DEPLOY BACKEND
cd app/backend
railway up

# DEPLOY FRONTEND
cd app
vercel --prod

# CHECK STATUS
railway status
vercel ls

# VIEW LOGS
railway logs
vercel logs

# UPDATE ENV VARS
railway variables set KEY=value
vercel env add KEY
```

---

## 🎓 Next Steps

Setelah deploy via CLI berhasil:

1. **Setup GitHub Webhook** untuk auto-deploy
2. **Enable monitoring** di Railway & Vercel dashboard
3. **Add custom domain** via CLI:
   ```bash
   vercel domains add nexo.com
   railway domain
   ```

4. **Setup secrets management**:
   ```bash
   # Railway secrets (encrypted)
   railway secrets set SECRET_KEY=value
   ```

---

## 📞 Support

Jika ada error saat deploy via CLI:

- **Railway Discord**: https://discord.gg/railway
- **Vercel Discord**: https://discord.gg/vercel
- **Railway Docs**: https://docs.railway.app/develop/cli
- **Vercel CLI Docs**: https://vercel.com/docs/cli

---

✅ **Sekarang Anda bisa deploy Nexo hanya dengan 2 command:**

```bash
railway up       # Deploy backend
vercel --prod    # Deploy frontend
```

Happy deploying! 🚀
