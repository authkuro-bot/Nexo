# 🚀 Deployment Automation Scripts

Dokumentasi lengkap untuk automatic deployment Nexo ke Vercel dan Railway.

## 📋 Daftar Script

### 1. **deploy-complete.ps1** - Full Deployment ⭐
Deploy lengkap dengan Git commit terlebih dahulu.

```powershell
.\deploy-complete.ps1
```

**Proses:**
1. ✅ Git commit & push ke GitHub
2. 🚂 Deploy backend ke Railway
3. 🌐 Deploy frontend ke Vercel (nexoai-flax.vercel.app)
4. 🔗 Update CORS configuration otomatis

**Kapan digunakan:** Deployment lengkap pertama kali atau update besar

---

### 2. **quick-update.ps1** - Quick Frontend Update ⚡
Update cepat hanya frontend.

```powershell
.\quick-update.ps1
```

**Proses:**
1. ✅ Git commit & push
2. 🌐 Deploy frontend ke Vercel

**Kapan digunakan:** Update UI/frontend saja tanpa perubahan backend

---

### 3. **deploy-with-env-sync.ps1** - Full Deploy + ENV Sync 🔐
Deploy lengkap dengan sinkronisasi environment variables dari file `.env`.

```powershell
.\deploy-with-env-sync.ps1
```

**Proses:**
1. ✅ Git commit & push
2. 📖 Baca .env files (backend & frontend)
3. 🚂 Sync ENV ke Railway → Deploy backend
4. 🌐 Deploy frontend ke Vercel
5. 🔗 Update CORS

**Kapan digunakan:** 
- Setup awal dengan environment variables baru
- Update konfigurasi environment variables
- Perubahan API keys atau credentials

---

## 🎯 Quick Start

### Pertama Kali Setup

1. **Install CLI Tools**
```powershell
npm install -g vercel
npm install -g @railway/cli
```

2. **Login ke Services**
```powershell
vercel login
railway login
```

3. **Link Projects**
```powershell
# Di folder app/backend
cd app\backend
railway link

# Di folder app (frontend)
cd ..\
vercel link
```

4. **Setup .env Files**
Pastikan file `.env` sudah lengkap:
- `app/backend/.env` - Backend configuration
- `app/.env` - Frontend configuration

5. **Deploy!**
```powershell
cd C:\Users\Kuro\Music\Nexo-master\Nexo-master
.\deploy-complete.ps1
```

---

## 🔄 Workflow Deployment

### Skenario 1: Update Code (Frontend & Backend)
```powershell
# Edit code...
.\deploy-complete.ps1
```

### Skenario 2: Update UI Saja
```powershell
# Edit components/pages...
.\quick-update.ps1
```

### Skenario 3: Update Environment Variables
```powershell
# Edit .env files...
.\deploy-with-env-sync.ps1
```

### Skenario 4: Re-deploy Backend Saja
```powershell
cd app\backend
railway up
```

### Skenario 5: Re-deploy Frontend Saja
```powershell
cd app
vercel --prod --yes
```

---

## 📊 Script Features Comparison

| Feature | deploy-complete | quick-update | deploy-with-env-sync |
|---------|----------------|--------------|----------------------|
| Git Commit | ✅ | ✅ | ✅ |
| Deploy Backend | ✅ | ❌ | ✅ |
| Deploy Frontend | ✅ | ✅ | ✅ |
| Sync ENV | ❌ | ❌ | ✅ |
| Update CORS | ✅ | ❌ | ✅ |
| Speed | Medium | Fast | Slow |

---

## 🔧 Configuration

### Domain Configuration
Domain default: **nexoai-flax.vercel.app**

Untuk ganti domain, edit di script:
```powershell
$domain = "nexoai-flax.vercel.app"
```

### Railway Backend URL
Backend URL otomatis didapat dari Railway. Untuk custom domain:

```powershell
cd app\backend
railway domain
```

### CORS Configuration
CORS otomatis di-update oleh script ke frontend URL. Jika perlu manual:

```powershell
cd app\backend
railway variables set CORS_ORIGIN=https://your-domain.vercel.app
```

---

## 🐛 Troubleshooting

### Error: Railway CLI not found
```powershell
npm install -g @railway/cli
railway login
```

### Error: Vercel CLI not found
```powershell
npm install -g vercel
vercel login
```

### Error: Project not linked
```powershell
# Backend
cd app\backend
railway link

# Frontend
cd app
vercel link
```

### Error: Git push failed
Cek remote repository:
```powershell
git remote -v
```

Jika belum ada:
```powershell
git remote add origin https://github.com/username/nexo.git
```

### Error: Deployment failed
Check logs:
```powershell
# Backend logs
railway logs

# Frontend logs
vercel logs
```

### Error: CORS issue
Update manual:
```powershell
cd app\backend
railway variables set CORS_ORIGIN=https://nexoai-flax.vercel.app
railway variables set FRONTEND_URL=https://nexoai-flax.vercel.app
```

---

## 📝 Environment Variables

### Backend (.env)
Minimal required:
```env
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_KEY=your_service_key

# JWT
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=7d

# Cloudflare R2
CLOUDFLARE_R2_ACCOUNT_ID=your_account_id
CLOUDFLARE_R2_ACCESS_KEY_ID=your_access_key
CLOUDFLARE_R2_SECRET_ACCESS_KEY=your_secret_key
CLOUDFLARE_R2_BUCKET=your_bucket_name
CLOUDFLARE_R2_PUBLIC_URL=your_public_url
CLOUDFLARE_R2_ENDPOINT=your_endpoint

# AI Provider
AI_PROVIDER=openai
OPENAI_API_KEY=your_openai_key
OPENAI_MODEL=gpt-4o-mini
```

### Frontend (.env)
```env
VITE_API_URL=https://your-backend.railway.app
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_anon_key
VITE_CLOUDFLARE_R2_PUBLIC_URL=your_r2_public_url
```

---

## ⚡ Tips & Best Practices

### 1. Commit Messages
Script akan membuat default commit message, tapi lebih baik tulis manual:
```
✅ Good: "Add product filter feature"
❌ Bad: "update"
```

### 2. Test Locally First
Sebelum deploy, test di local:
```powershell
# Backend
cd app\backend
npm run dev

# Frontend
cd app
npm run dev
```

### 3. Check Status Before Deploy
```powershell
git status
railway status
vercel ls
```

### 4. Monitor Logs After Deploy
```powershell
# Terminal 1: Backend logs
railway logs

# Terminal 2: Frontend logs
vercel logs
```

### 5. Backup .env Files
Backup file `.env` sebelum update:
```powershell
copy app\backend\.env app\backend\.env.backup
copy app\.env app\.env.backup
```

---

## 🔗 Useful Commands

### Git Commands
```powershell
git status                      # Check status
git log --oneline -5            # Last 5 commits
git diff                        # See changes
git reset --soft HEAD~1         # Undo last commit
```

### Railway Commands
```powershell
railway status                  # Check deployment status
railway logs                    # View logs
railway domain                  # Get backend URL
railway variables               # List environment variables
railway variables set KEY=value # Set variable
railway up                      # Deploy
railway open                    # Open Railway dashboard
```

### Vercel Commands
```powershell
vercel ls                       # List deployments
vercel logs                     # View logs
vercel inspect                  # Project info
vercel domains                  # List domains
vercel env ls                   # List environment variables
vercel --prod --yes             # Deploy to production
```

---

## 📚 Additional Resources

- [Railway Documentation](https://docs.railway.app/)
- [Vercel Documentation](https://vercel.com/docs)
- [Git Documentation](https://git-scm.com/doc)

---

## 🆘 Support

Jika ada masalah:
1. Check logs: `railway logs` dan `vercel logs`
2. Verify environment variables
3. Test locally first
4. Check GitHub issues

---

## 📜 Script Changelog

### v1.0.0 (2026-06-06)
- ✅ Initial release
- ✅ Full deployment automation
- ✅ Quick update script
- ✅ ENV sync deployment
- ✅ Auto CORS configuration
- ✅ Git integration

---

**Happy Deploying! 🚀**
