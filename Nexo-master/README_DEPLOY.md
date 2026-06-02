# 🚀 Nexo Deployment - Quick Reference

**Email**: authkuro@gmail.com  
**Path**: `C:\Users\Kuro\Music\Nexo-master\Nexo-master`

---

## ⚡ Quick Start (First Time)

### Opsi A: Auto Deploy dari .env (RECOMMENDED) ⭐

**Jika semua credentials sudah ada di `.env`:**

```powershell
# Deploy otomatis + upload semua env vars dari .env
.\auto-deploy-from-env.ps1
```

**Done!** Script akan:
- ✅ Read .env files
- ✅ Upload env vars ke Railway & Vercel
- ✅ Deploy backend + frontend
- ✅ Update CORS otomatis

---

### Opsi B: Manual Setup

```powershell
# 1. Install CLI tools
npm install -g vercel @railway/cli

# 2. Login
railway login   # Browser opens → authkuro@gmail.com
vercel login    # Browser opens → authkuro@gmail.com

# 3. Deploy everything
.\setup-and-deploy.ps1
```

**Done!** 🎉

---

## 📦 Automated Scripts

### Auto Deploy from .env (BEST!)
```powershell
.\auto-deploy-from-env.ps1
```
Reads `.env` files → uploads to Railway & Vercel → deploys everything.

### Sync Environment Variables Only
```powershell
.\sync-env.ps1
```
Only syncs .env to Railway & Vercel (no deployment).

### Deploy Everything
```powershell
.\deploy-all.ps1
```
Deploys backend + frontend in one command.

### Deploy Backend Only
```powershell
.\deploy-backend.ps1
```

### Deploy Frontend Only
```powershell
.\deploy-frontend.ps1
```

### First-Time Setup
```powershell
.\setup-and-deploy.ps1
```
Installs tools, login, git setup, and deploy.

### Check Readiness
```powershell
.\deploy-check.ps1
```
Validates project is ready for deployment.

---

## 🔧 Manual Deploy Commands

### Backend (Railway)
```powershell
cd app\backend
railway up
railway domain  # Get URL
```

### Frontend (Vercel)
```powershell
cd app
vercel --prod
```

---

## 🔐 Environment Variables

### Railway (Backend)
```powershell
# Set one by one
railway variables set SUPABASE_URL=https://xxx.supabase.co
railway variables set OPENAI_API_KEY=sk-xxx

# Or from file
railway variables set --from-file .env
```

### Vercel (Frontend)
```powershell
# Interactive
vercel env add VITE_API_URL
# Paste value when prompted

# Or via command
echo "value" | vercel env add VITE_API_URL production
```

---

## 📊 Monitoring & Logs

### Railway
```powershell
railway status              # Check deployment status
railway logs                # View real-time logs
railway logs --tail 100     # Last 100 lines
railway variables           # List env vars
railway domain              # Get deployment URL
```

### Vercel
```powershell
vercel ls                   # List deployments
vercel logs                 # View logs
vercel inspect              # Project info
vercel env ls               # List env vars
```

---

## 🔄 Update & Redeploy

### After Code Changes
```powershell
# 1. Commit
git add .
git commit -m "Update features"

# 2. Deploy
.\deploy-all.ps1

# Or push to GitHub (auto-deploy)
git push origin main
```

### Update Backend Only
```powershell
cd app\backend
git add .
git commit -m "Update backend"
railway up
```

### Update Frontend Only
```powershell
cd app
git add .
git commit -m "Update frontend"
vercel --prod
```

---

## 🔗 Important URLs

After deployment, save these:

```
Backend:  https://nexo-backend-production-xxxx.up.railway.app
Frontend: https://nexo-xxxx.vercel.app
Database: https://xxxxxxxxxxxxxx.supabase.co
```

---

## ⚙️ CORS Setup

After frontend deploys, update backend CORS:

```powershell
railway variables set CORS_ORIGIN=https://nexo-xxxx.vercel.app
```

Multiple domains:
```powershell
railway variables set CORS_ORIGIN=https://nexo.vercel.app,https://nexo.com
```

---

## 🐛 Troubleshooting

### Backend Won't Start
```powershell
# Check logs
railway logs

# Verify env vars
railway variables

# Check project status
railway status
```

### Frontend Build Failed
```powershell
# Check Vercel logs
vercel logs

# Try debug mode
vercel --prod --debug

# Clear cache & redeploy
vercel --prod --force
```

### CORS Errors
```powershell
# Update backend CORS
railway variables set CORS_ORIGIN=<frontend-url>

# Wait 1 minute for redeploy
railway status
```

### Not Logged In
```powershell
# Railway
railway logout
railway login

# Vercel
vercel logout
vercel login
```

---

## 📚 Documentation

- **Full Guide**: [DEPLOY_CLI_GUIDE.md](./DEPLOY_CLI_GUIDE.md)
- **Web Deploy**: [DEPLOY_VERCEL_RAILWAY.md](./DEPLOY_VERCEL_RAILWAY.md)
- **Detailed**: [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)

---

## 🆘 Quick Help

```powershell
# Railway help
railway help
railway [command] --help

# Vercel help
vercel help
vercel [command] --help
```

---

## 🎯 Common Workflows

### Development → Production
```powershell
# 1. Test locally
npm run dev

# 2. Commit changes
git add .
git commit -m "Feature X"

# 3. Deploy
.\deploy-all.ps1

# 4. Verify
# Open browser → test frontend
# Check logs → railway logs
```

### Rollback Deployment
```powershell
# Vercel (via dashboard or CLI)
vercel rollback

# Railway (redeploy previous)
railway up --restore [deployment-id]
```

### Add Custom Domain
```powershell
# Vercel
vercel domains add nexo.com

# Railway
railway domain add api.nexo.com
```

---

## ✅ Post-Deployment Checklist

- [ ] Backend health endpoint works
- [ ] Frontend loads without errors
- [ ] API calls from frontend to backend succeed (no CORS)
- [ ] Database connections working
- [ ] Environment variables all set
- [ ] CORS properly configured
- [ ] URLs saved to password manager

---

**Need Help?**

- Railway: https://discord.gg/railway
- Vercel: https://discord.gg/vercel
- Docs: See markdown files in this folder

---

**Quick Command Summary:**

```powershell
# First time
.\setup-and-deploy.ps1

# Regular updates
.\deploy-all.ps1

# Backend only
.\deploy-backend.ps1

# Frontend only
.\deploy-frontend.ps1

# Check before deploy
.\deploy-check.ps1

# View logs
railway logs
vercel logs
```

Happy deploying! 🚀
