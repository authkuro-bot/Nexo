# 🚀 Quick Deployment Guide

## 📌 One-Click Deployment

### Windows Users (Double-Click)
- **`Deploy-Complete.cmd`** - Full deployment (Git → Backend → Frontend)
- **`Quick-Update.cmd`** - Quick frontend update only

### PowerShell Users
```powershell
.\deploy-complete.ps1        # Full deployment
.\quick-update.ps1           # Frontend only
.\deploy-with-env-sync.ps1   # With ENV sync
.\check-deployment.ps1       # Check status
```

---

## 🎯 Quick Start (First Time)

### 1. Install CLI Tools
```powershell
npm install -g vercel
npm install -g @railway/cli
```

### 2. Login
```powershell
vercel login
railway login
```

### 3. Link Projects
```powershell
# Backend
cd app\backend
railway link

# Frontend
cd ..\
vercel link
```

### 4. Deploy!
```powershell
cd C:\Users\Kuro\Music\Nexo-master\Nexo-master
.\deploy-complete.ps1
```

---

## 📝 Domain Info

- **Frontend:** https://nexoai-flax.vercel.app
- **Backend:** Auto dari Railway

---

## 🔄 Common Workflows

### Update Code
```powershell
# Edit code...
.\deploy-complete.ps1
```

### Update Frontend Only
```powershell
# Edit UI...
.\quick-update.ps1
```

### Update Environment Variables
```powershell
# Edit .env files...
.\deploy-with-env-sync.ps1
```

### Check Status
```powershell
.\check-deployment.ps1
```

---

## 🐛 Quick Fixes

### Not Logged In?
```powershell
vercel login
railway login
```

### Project Not Linked?
```powershell
cd app\backend && railway link
cd app && vercel link
```

### Git Issues?
```powershell
git remote add origin https://github.com/username/nexo.git
git push -u origin main
```

---

## 📚 Full Documentation

See **`DEPLOYMENT_AUTOMATION.md`** for complete guide.

---

**Happy Deploying! 🎉**
