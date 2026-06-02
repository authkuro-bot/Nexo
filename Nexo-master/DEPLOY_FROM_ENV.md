# 🚀 Deploy dari .env Files (SUPER MUDAH!)

**Untuk**: Anda yang sudah punya semua credentials di `.env` files

---

## ⚡ One Command Deploy

```powershell
.\auto-deploy-from-env.ps1
```

**That's it!** Script akan:
1. ✅ Baca `app/backend/.env` dan `app/.env`
2. ✅ Upload semua env vars ke Railway (backend)
3. ✅ Upload semua env vars ke Vercel (frontend)
4. ✅ Deploy backend ke Railway
5. ✅ Deploy frontend ke Vercel
6. ✅ Update CORS otomatis
7. ✅ Show URLs

---

## 📋 What Gets Synced?

### Backend (.env → Railway)

```bash
# Server Config
PORT, NODE_ENV, FRONTEND_URL

# Database
SUPABASE_URL, SUPABASE_SERVICE_KEY

# Authentication
JWT_SECRET, JWT_EXPIRES_IN

# Storage (Cloudflare R2)
CLOUDFLARE_R2_ACCOUNT_ID
CLOUDFLARE_R2_ACCESS_KEY_ID
CLOUDFLARE_R2_SECRET_ACCESS_KEY
CLOUDFLARE_R2_BUCKET
CLOUDFLARE_R2_PUBLIC_URL
CLOUDFLARE_R2_ENDPOINT

# AI Provider
AI_PROVIDER
OPENAI_API_KEY
OPENAI_MODEL
OPENAI_BASE_URL

# Data Providers
DATA_PROVIDER, MEDIA_PROVIDER, etc.
```

### Frontend (.env → Vercel)

```bash
# API
VITE_API_URL (otomatis dari Railway URL)

# Database
VITE_SUPABASE_URL
VITE_SUPABASE_ANON_KEY

# Storage
VITE_CLOUDFLARE_R2_PUBLIC_URL
```

---

## 🔧 Script Features

### Auto Deploy from ENV
```powershell
.\auto-deploy-from-env.ps1
```
- Reads `.env` files
- Uploads to Railway & Vercel
- Deploys everything
- Updates CORS

### Sync ENV Only (No Deploy)
```powershell
.\sync-env.ps1
```
- Only syncs env vars
- No deployment
- Useful for updating secrets

---

## 📝 Your Current .env

Saya detected credentials ini di `.env`:

### Backend
```
✅ SUPABASE_URL
✅ SUPABASE_SERVICE_KEY
✅ JWT_SECRET
✅ CLOUDFLARE_R2_* (6 variables)
✅ OPENAI_API_KEY (Groq)
✅ OPENAI_MODEL
✅ OPENAI_BASE_URL
```

### Frontend
```
✅ SUPABASE_URL
✅ SUPABASE_SERVICE_KEY
✅ CLOUDFLARE_R2_PUBLIC_URL
```

---

## 🎯 Usage Scenarios

### First Time Deploy
```powershell
# All in one!
.\auto-deploy-from-env.ps1
```

### Update Code Only
```powershell
# Deploy tanpa sync env
.\deploy-all.ps1
```

### Update .env + Deploy
```powershell
# Edit .env files first
# Then:
.\auto-deploy-from-env.ps1
```

### Update Secrets Only
```powershell
# Edit .env files
# Then sync without deploy:
.\sync-env.ps1

# Then deploy manually:
.\deploy-all.ps1
```

---

## 🔐 Security Notes

**IMPORTANT:**

1. ✅ `.env` files are in `.gitignore` (not committed)
2. ✅ Script uploads to Railway & Vercel securely
3. ✅ Production values override development values
4. ✅ Service keys stay on backend only

**Production Overrides:**
- `NODE_ENV` → `production`
- `PORT` → `3000`
- `OTP_DELIVERY` → `production`
- `VITE_API_URL` → Railway backend URL

---

## 🛠️ Script Logic

### What Script Does:

```
1. Parse .env files (backend & frontend)
2. Check Railway & Vercel CLI authentication
3. Map development vars → production vars
4. Upload to Railway:
   - Set PORT=3000
   - Set NODE_ENV=production
   - Upload all backend secrets
5. Deploy backend to Railway
6. Get backend URL
7. Upload to Vercel:
   - Set VITE_API_URL=<railway-url>
   - Upload all frontend env vars
8. Deploy frontend to Vercel
9. Update CORS in Railway with frontend URL
10. Display URLs
```

---

## ⚡ Quick Commands

```powershell
# Deploy everything from .env
.\auto-deploy-from-env.ps1

# Sync env only
.\sync-env.ps1

# Deploy without env sync
.\deploy-all.ps1

# Backend only
.\deploy-backend.ps1

# Frontend only
.\deploy-frontend.ps1
```

---

## 🔄 Update Workflow

**Scenario 1: Code changes only**
```powershell
# Edit code
git commit -m "Update features"
.\deploy-all.ps1
```

**Scenario 2: .env changes + code**
```powershell
# Edit .env + code
git commit -m "Update"
.\auto-deploy-from-env.ps1
```

**Scenario 3: .env changes only**
```powershell
# Edit .env
.\sync-env.ps1
# No need to redeploy (Railway auto-restarts)
```

---

## 📊 Comparison

| Script | Sync ENV | Deploy Backend | Deploy Frontend | Update CORS |
|--------|----------|----------------|-----------------|-------------|
| `auto-deploy-from-env.ps1` | ✅ | ✅ | ✅ | ✅ |
| `sync-env.ps1` | ✅ | ❌ | ❌ | ❌ |
| `deploy-all.ps1` | ❌ | ✅ | ✅ | ❌ |
| `deploy-backend.ps1` | ❌ | ✅ | ❌ | ❌ |
| `deploy-frontend.ps1` | ❌ | ❌ | ✅ | ❌ |

---

## 🎓 Best Practices

1. **First time**: Use `auto-deploy-from-env.ps1`
2. **Regular updates**: Use `deploy-all.ps1` (faster)
3. **Secret rotation**: Use `sync-env.ps1` then manual deploy
4. **Quick fixes**: Use specific scripts (`deploy-backend.ps1`)

---

## 🆘 Troubleshooting

### Script can't find .env
```
❌ No backend .env found!
```
**Fix**: Pastikan file ada di:
- `C:\Users\Kuro\Music\Nexo-master\Nexo-master\app\backend\.env`
- `C:\Users\Kuro\Music\Nexo-master\Nexo-master\app\.env`

### Not logged in
```
❌ Not logged in to Railway
```
**Fix**: Script akan auto-prompt login. Follow browser.

### Variable not uploaded
```
⏭️ Skipping KEY (empty value)
```
**Fix**: Check .env file, pastikan value ada setelah `=`

### CORS still not working
```
Frontend can't reach backend
```
**Fix**: Wait 1 minute for Railway redeploy, atau run:
```powershell
railway variables set CORS_ORIGIN=<frontend-url>
```

---

## 🎉 Success Output

```
🚀 Auto Deploy Nexo from .env Files
========================================

✓ CLI tools ready
✓ Railway: authkuro
✓ Vercel: authkuro
✓ Found 25 backend environment variables

📦 DEPLOYING BACKEND TO RAILWAY
   ✓ Uploaded 20 variables
   ✅ Backend deployed successfully!
   🔗 Backend URL: https://nexo-xxx.railway.app

📦 DEPLOYING FRONTEND TO VERCEL
   ✓ Environment variables configured
   ✅ Frontend deployed successfully!
   🔗 Frontend URL: https://nexo-xxx.vercel.app

🔗 UPDATING CORS CONFIGURATION
   ✓ CORS updated

🎉 DEPLOYMENT COMPLETE!
```

---

## 📌 Summary

**Best for you:**
```powershell
.\auto-deploy-from-env.ps1
```

**Time**: 5-10 minutes  
**Difficulty**: Super easy  
**Requirements**: .env files must exist

---

**Next:** Open `https://nexo-xxx.vercel.app` and test! 🎊
