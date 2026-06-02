# 🚀 Quick Start Deploy - 15 Menit

Panduan singkat untuk deploy Nexo dalam 15 menit.

## ⚡ Speed Run Checklist

### 1. Database (5 menit)
```bash
# 1. Buka https://supabase.com → New Project
# 2. Nama: nexo-production
# 3. Password: [generate & simpan]
# 4. Region: Singapore
# 5. Tunggu 2 menit

# 6. Copy credentials:
# Settings > API
# - Project URL
# - anon key
# - service_role key
```

### 2. Backend (5 menit)
```bash
# 1. Buka https://railway.app → New Project → Deploy from GitHub
# 2. Connect repo nexo
# 3. Settings:
#    Root Directory: app/backend
#    Start Command: npm start

# 4. Variables tab, paste:
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
SUPABASE_ANON_KEY=eyJ...
PORT=3000
NODE_ENV=production
JWT_SECRET=generate-random-32-chars
OPENAI_API_KEY=sk-...
CORS_ORIGIN=*

# 5. Networking > Generate Domain
# Copy: https://nexo-backend-xxx.up.railway.app
```

### 3. Frontend (5 menit)
```bash
# 1. Buka https://vercel.com → New Project → Import from GitHub
# 2. Select repo: nexo
# 3. Settings:
#    Root Directory: app/
#    Framework: Vite

# 4. Environment Variables:
VITE_API_URL=https://nexo-backend-xxx.up.railway.app
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...

# 5. Deploy → Tunggu 2 menit
# 6. Open: https://nexo-xxx.vercel.app
```

### 4. Fix CORS
```bash
# Di Railway, update variable:
CORS_ORIGIN=https://nexo-xxx.vercel.app

# Redeploy (otomatis)
```

## ✅ Done!

Test:
1. Buka `https://nexo-xxx.vercel.app`
2. Check Network tab di DevTools
3. API calls harus 200 OK

---

## 🔧 Jika Ada Error

### Frontend tidak bisa akses backend
```bash
# Cek 1: CORS_ORIGIN di Railway sudah benar?
# Cek 2: VITE_API_URL di Vercel sudah include https://?
# Cek 3: Backend health endpoint bisa diakses?
curl https://nexo-backend-xxx.up.railway.app/api/health
```

### Build failed
```bash
# Vercel: Clear cache & redeploy
# Railway: Check logs tab
```

---

Butuh detail lengkap? Baca [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
