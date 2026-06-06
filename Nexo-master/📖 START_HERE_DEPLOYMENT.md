# 🚀 Nexo Deployment - START HERE

Selamat datang di sistem deployment otomatis Nexo! File ini adalah **entry point** untuk semua yang Anda butuhkan.

---

## ⚡ Quick Start (Paling Penting!)

### 🎯 Sudah Setup? Deploy Sekarang!

**Double-click salah satu:**
- `Deploy-Complete.cmd` - Deploy lengkap
- `Quick-Update.cmd` - Update frontend saja

**Atau jalankan:**
```powershell
.\deploy-complete.ps1
```

### 🔧 Belum Setup? Ikuti Langkah Ini:

1. **Install CLI Tools:**
   ```powershell
   npm install -g vercel @railway/cli
   ```

2. **Login:**
   ```powershell
   vercel login
   railway login
   ```

3. **Link Projects:**
   ```powershell
   cd app\backend
   railway link
   
   cd ..\
   vercel link
   ```

4. **Deploy!**
   ```powershell
   cd C:\Users\Kuro\Music\Nexo-master\Nexo-master
   .\deploy-complete.ps1
   ```

---

## 📚 Dokumentasi Lengkap

### 📖 Untuk Pemula
Baca file ini dalam urutan:

1. **`QUICK_REFERENCE.txt`** ⭐ Paling Penting!
   - Cheat sheet semua command
   - Quick troubleshooting
   - Common workflows
   
2. **`DEPLOY_README.md`**
   - Quick start guide
   - Domain info
   - Basic workflows

### 📖 Untuk Pengguna Lanjutan

3. **`DEPLOYMENT_AUTOMATION.md`**
   - Complete deployment guide
   - Script comparison
   - Advanced configuration
   - Troubleshooting lengkap

4. **`DEPLOYMENT_FLOW.txt`**
   - Visual flow charts
   - Decision trees
   - Process diagrams

### 📖 Reference Files

5. **`.deployment-scripts-summary.txt`**
   - Summary semua script yang dibuat
   - Feature list lengkap
   - Requirements

---

## 🎯 Pilih Script Yang Tepat

### Skenario 1: Update Code (Backend + Frontend)
```powershell
.\deploy-complete.ps1
```
⏱️ **Time:** 3-5 minutes

### Skenario 2: Update UI Saja
```powershell
.\quick-update.ps1
```
⏱️ **Time:** 1-2 minutes

### Skenario 3: Update Environment Variables
```powershell
.\deploy-with-env-sync.ps1
```
⏱️ **Time:** 4-6 minutes

### Skenario 4: Cek Status
```powershell
.\check-deployment.ps1
```
⏱️ **Time:** 10 seconds

---

## 📦 Daftar Semua Script

### PowerShell Scripts (Recommended)
| Script | Fungsi | Waktu |
|--------|--------|-------|
| `deploy-complete.ps1` | Full deployment | 3-5 min |
| `quick-update.ps1` | Frontend only | 1-2 min |
| `deploy-with-env-sync.ps1` | Deploy + ENV sync | 4-6 min |
| `check-deployment.ps1` | Check status | 10 sec |

### Windows Batch Files (Double-Click)
| File | Fungsi |
|------|--------|
| `Deploy-Complete.cmd` | Full deployment |
| `Quick-Update.cmd` | Frontend only |

---

## 🌐 Deployment URLs

- **Frontend:** https://nexoai-flax.vercel.app
- **Backend:** (Akan ditampilkan setelah deploy)

---

## 🔍 Quick Commands Cheat Sheet

### Deploy Commands
```powershell
.\deploy-complete.ps1          # Full deployment
.\quick-update.ps1             # Quick update
.\check-deployment.ps1         # Check status
```

### Manual Commands
```powershell
# Backend
cd app\backend
railway up

# Frontend
cd app
vercel --prod --yes
```

### View Logs
```powershell
railway logs                   # Backend logs
vercel logs                    # Frontend logs
```

### Check Status
```powershell
railway status                 # Backend status
vercel ls                      # Frontend deployments
git status                     # Git status
```

---

## 🐛 Troubleshooting Cepat

### Error: Command not found
```powershell
npm install -g vercel @railway/cli
```

### Error: Not logged in
```powershell
vercel login
railway login
```

### Error: Project not linked
```powershell
cd app\backend && railway link
cd app && vercel link
```

### Error: Deployment failed
```powershell
# Check logs
railway logs
vercel logs

# Check status
.\check-deployment.ps1
```

---

## 💡 Tips & Best Practices

✅ **DO:**
- Selalu cek status dulu: `.\check-deployment.ps1`
- Test locally sebelum deploy: `npm run dev`
- Gunakan commit message yang jelas
- Monitor logs setelah deploy
- Backup file `.env` sebelum edit

❌ **DON'T:**
- Deploy tanpa test local dulu
- Edit environment variables langsung di Railway/Vercel (gunakan script)
- Skip commit ke GitHub
- Deploy dengan uncommitted changes

---

## 📋 File Structure

```
Nexo-master/
├── 📖 START_HERE_DEPLOYMENT.md    ← You are here!
│
├── 🚀 Deployment Scripts
│   ├── deploy-complete.ps1
│   ├── quick-update.ps1
│   ├── deploy-with-env-sync.ps1
│   ├── check-deployment.ps1
│   ├── Deploy-Complete.cmd
│   └── Quick-Update.cmd
│
├── 📚 Documentation
│   ├── QUICK_REFERENCE.txt        ← Paling berguna!
│   ├── DEPLOY_README.md
│   ├── DEPLOYMENT_AUTOMATION.md
│   ├── DEPLOYMENT_FLOW.txt
│   └── .deployment-scripts-summary.txt
│
└── app/
    ├── backend/
    │   └── .env                   ← Configure this
    └── .env                       ← Configure this
```

---

## 🎯 Workflow Recommended

### 1️⃣ First Time Setup
```powershell
# Install & login
npm install -g vercel @railway/cli
vercel login
railway login

# Link projects
cd app\backend && railway link
cd app && vercel link

# Configure .env files
# Edit app/backend/.env
# Edit app/.env

# Deploy with ENV sync
cd C:\Users\Kuro\Music\Nexo-master\Nexo-master
.\deploy-with-env-sync.ps1
```

### 2️⃣ Regular Development
```powershell
# Edit code...

# Test locally
cd app && npm run dev

# Deploy
.\deploy-complete.ps1
```

### 3️⃣ Quick UI Fix
```powershell
# Edit components...

# Deploy frontend only
.\quick-update.ps1
```

### 4️⃣ Update Configuration
```powershell
# Edit .env files...

# Deploy with ENV sync
.\deploy-with-env-sync.ps1
```

---

## 🆘 Butuh Bantuan?

### Quick Help
1. Baca: `QUICK_REFERENCE.txt` (most useful!)
2. Check: `.\check-deployment.ps1`
3. View logs: `railway logs` atau `vercel logs`

### Detailed Help
1. Complete guide: `DEPLOYMENT_AUTOMATION.md`
2. Flow charts: `DEPLOYMENT_FLOW.txt`
3. Script summary: `.deployment-scripts-summary.txt`

---

## ✨ Features

✅ **Automatic:**
- Git commit & push
- Backend deployment (Railway)
- Frontend deployment (Vercel)
- CORS configuration
- Environment variable sync

✅ **Smart:**
- Error handling
- Status validation
- Health checks
- Progress indicators

✅ **User-friendly:**
- Colored output
- Clear messages
- Time tracking
- Interactive prompts

---

## 🎊 Ready to Deploy?

Jalankan salah satu:

**Paling Simple (Double-click):**
- `Deploy-Complete.cmd`

**PowerShell (Recommended):**
```powershell
.\deploy-complete.ps1
```

**Check Status First:**
```powershell
.\check-deployment.ps1
```

---

## 📞 Quick Support

Jika ada masalah:
1. Run: `.\check-deployment.ps1`
2. Check logs: `railway logs` dan `vercel logs`
3. Read: `DEPLOYMENT_AUTOMATION.md` bagian Troubleshooting
4. Review: `.env` files

---

## 🎯 What's Next?

1. ✅ Setup CLI tools (vercel, railway)
2. ✅ Configure .env files
3. ✅ Run first deployment
4. ✅ Bookmark this file
5. ✅ Keep `QUICK_REFERENCE.txt` handy

---

**Happy Deploying! 🚀**

---

*Created: 2026-06-06*  
*Version: 1.0.0*  
*Domain: nexoai-flax.vercel.app*
