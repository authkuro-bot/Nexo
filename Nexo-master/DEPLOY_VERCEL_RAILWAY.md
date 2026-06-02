# 🚀 Deploy Nexo: Vercel + Railway (Step-by-Step)

## 📋 Yang Anda Butuhkan

- ✅ Akun GitHub (gratis)
- ✅ Akun Vercel (gratis) - [Sign up](https://vercel.com/signup)
- ✅ Akun Railway (gratis) - [Sign up](https://railway.app)
- ✅ Akun Supabase (gratis) - [Sign up](https://supabase.com)
- ✅ OpenAI API Key (berbayar) - [Get Key](https://platform.openai.com/api-keys)

---

## 🗂️ TAHAP 1: Persiapan - Push ke GitHub

### Step 1.1: Inisialisasi Git (jika belum)

```bash
# Buka terminal di root project
cd c:\Users\Kuro\Music\Nexo-master\Nexo-master

# Cek apakah sudah ada .git
dir .git

# Jika belum ada, init git:
git init
```

### Step 1.2: Commit Code

```bash
# Add semua file
git add .

# Commit
git commit -m "Initial commit - ready for deployment"
```

### Step 1.3: Push ke GitHub

```bash
# Cara 1: Via GitHub Desktop (lebih mudah)
# 1. Download GitHub Desktop: https://desktop.github.com
# 2. File > Add Local Repository
# 3. Pilih folder: c:\Users\Kuro\Music\Nexo-master\Nexo-master
# 4. Publish Repository > Nexo
# 5. ✅ Done!

# Cara 2: Via Command Line
# Buat repo baru di https://github.com/new
# Nama: Nexo
# Private/Public: pilih sesuai keinginan

# Connect & push:
git remote add origin https://github.com/USERNAME/Nexo.git
git branch -M main
git push -u origin main
```

---

## 🗄️ TAHAP 2: Setup Database di Supabase

### Step 2.1: Buat Project Supabase

1. **Buka** [https://supabase.com](https://supabase.com)
2. **Login** atau Sign Up dengan GitHub
3. **Klik** tombol "New Project" (hijau)
4. **Isi form:**
   - Name: `nexo-production`
   - Database Password: `[klik Generate]` → **SIMPAN PASSWORD INI!**
   - Region: `Southeast Asia (Singapore)`
   - Pricing Plan: `Free` (untuk mulai)

5. **Klik** "Create new project"
6. **Tunggu 2-3 menit** (ada loading bar)

### Step 2.2: Copy Database Credentials

Setelah project ready:

1. **Klik** icon ⚙️ Settings (sidebar kiri bawah)
2. **Pilih** "API" di menu settings
3. **Copy & Simpan** 3 informasi ini:

```
📋 COPY INI KE NOTEPAD:

Project URL:
https://xxxxxxxxxxxxxx.supabase.co

anon public key:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6...

service_role secret key:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6...
```

### Step 2.3: Setup Database Tables (Optional)

Jika Anda punya SQL schema:

1. **Klik** 🔧 SQL Editor (sidebar kiri)
2. **Klik** "New query"
3. **Paste** SQL schema Anda (contoh):

```sql
-- Contoh table trends
CREATE TABLE IF NOT EXISTS trends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT,
  growth NUMERIC DEFAULT 0,
  saturation NUMERIC DEFAULT 0,
  phase TEXT,
  platform TEXT,
  detected_at TIMESTAMPTZ DEFAULT NOW(),
  thumbnail TEXT,
  competitor_count INTEGER DEFAULT 0,
  avg_price NUMERIC DEFAULT 0,
  review_velocity INTEGER DEFAULT 0,
  description TEXT,
  recommendation TEXT,
  source_url TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index untuk performa
CREATE INDEX idx_trends_category ON trends(category);
CREATE INDEX idx_trends_platform ON trends(platform);
CREATE INDEX idx_trends_phase ON trends(phase);
```

4. **Klik** "Run" atau tekan `Ctrl + Enter`
5. ✅ Success!

---

## 🚂 TAHAP 3: Deploy Backend di Railway

### Step 3.1: Login ke Railway

1. **Buka** [https://railway.app](https://railway.app)
2. **Klik** "Login" → pilih **"Login with GitHub"**
3. Authorize Railway untuk akses GitHub

### Step 3.2: Create New Project

1. **Klik** "New Project" (dashboard utama)
2. **Pilih** "Deploy from GitHub repo"
3. **Pilih** repository `Nexo` yang tadi dibuat
4. **Klik** repository tersebut

Railway akan mulai deploy, tapi **akan GAGAL** karena belum ada konfigurasi. Itu normal!

### Step 3.3: Konfigurasi Build Settings

1. **Klik** service yang baru dibuat (ada nama random seperti "production")
2. **Klik** tab "Settings"
3. **Scroll ke bawah** ke bagian "Build"
4. **Isi:**

```
Root Directory:
app/backend

Build Command:
npm install

Start Command:
npm start
```

5. **Klik** "Deploy" (di atas) untuk save & redeploy

### Step 3.4: Set Environment Variables

Ini bagian penting! Backend butuh credentials.

1. Masih di service yang sama, **klik** tab "Variables"
2. **Klik** "New Variable" untuk setiap variable berikut:

```bash
# ========== COPY & PASTE SATU PER SATU ==========

# Database Supabase (dari Step 2.2)
SUPABASE_URL
https://xxxxxxxxxxxxxx.supabase.co

SUPABASE_ANON_KEY
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

SUPABASE_SERVICE_ROLE_KEY
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Server Config
PORT
3000

NODE_ENV
production

# JWT Secret (generate random string 32+ karakter)
# Bisa pakai: https://randomkeygen.com/
JWT_SECRET
ganti-dengan-random-string-minimal-32-karakter

# AI Service - OpenAI
OPENAI_API_KEY
sk-proj-xxxxxxxxxxxxxxxxxxxxxx

# CORS (temporary, akan diupdate setelah deploy frontend)
CORS_ORIGIN
*
```

**Cara input:**
- Ketik nama variable di kotak "Variable Name"
- Ketik value di kotak "Value"
- Klik "Add" atau tekan Enter
- Ulangi untuk semua variable

3. **Otomatis redeploy** setelah save variables
4. **Tunggu 1-2 menit** sampai status "Active" (hijau)

### Step 3.5: Generate Public URL

1. Masih di service, **klik** tab "Settings"
2. **Scroll** ke "Networking"
3. **Klik** "Generate Domain"
4. Railway akan generate URL seperti:

```
https://nexo-backend-production-xxxx.up.railway.app
```

5. **COPY URL INI** → akan dipakai untuk frontend

### Step 3.6: Test Backend

Buka browser atau terminal:

```bash
# Test health endpoint
curl https://nexo-backend-production-xxxx.up.railway.app/api/health

# Atau buka di browser:
https://nexo-backend-production-xxxx.up.railway.app/api/health

# Expected response:
{
  "status": "ok",
  "runtime": {...}
}
```

✅ **Backend ready!**

---

## 🎨 TAHAP 4: Deploy Frontend di Vercel

### Step 4.1: Login ke Vercel

1. **Buka** [https://vercel.com](https://vercel.com)
2. **Klik** "Sign Up" → pilih **"Continue with GitHub"**
3. Authorize Vercel untuk akses GitHub

### Step 4.2: Import Project

1. **Klik** "Add New..." → "Project"
2. **Cari** repository `Nexo`
3. **Klik** "Import" di samping repository tersebut

### Step 4.3: Konfigurasi Project Settings

**PENTING! Jangan langsung deploy dulu.**

Di halaman Configure Project:

```
Framework Preset:
Vite

Root Directory:
app/
(klik "Edit" lalu pilih folder "app")

Build Command:
npm run build

Output Directory:
dist

Install Command:
npm install
```

**⚠️ JANGAN KLIK DEPLOY DULU!** 

Scroll ke bawah dulu untuk set environment variables.

### Step 4.4: Set Environment Variables

Masih di halaman yang sama, scroll ke **"Environment Variables"**:

```bash
# ========== PASTE SATU PER SATU ==========

# Backend API URL (dari Step 3.5)
Name: VITE_API_URL
Value: https://nexo-backend-production-xxxx.up.railway.app

# Supabase (dari Step 2.2)
Name: VITE_SUPABASE_URL
Value: https://xxxxxxxxxxxxxx.supabase.co

Name: VITE_SUPABASE_ANON_KEY
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Feature flags (optional)
Name: VITE_ENABLE_AI_CHAT
Value: true
```

**Cara input:**
- Ketik nama di kotak pertama
- Ketik value di kotak kedua
- Klik "Add"
- Ulangi untuk semua variable

### Step 4.5: Deploy!

1. **Klik** tombol "Deploy" (besar, biru)
2. **Tunggu 2-3 menit** (ada progress bar)
3. ✅ Success! Akan ada confetti 🎉

### Step 4.6: Copy Frontend URL

Setelah deploy success:

```
https://nexo-xxxx.vercel.app
```

**COPY URL INI** → akan dipakai untuk update CORS

### Step 4.7: Test Frontend

1. **Klik** "Visit" untuk buka website
2. **Tekan F12** untuk buka DevTools
3. **Pilih** tab "Network"
4. **Refresh** halaman
5. **Cek** API calls (yang ke Railway backend)

Jika ada error CORS, lanjut ke Step 5.

---

## 🔗 TAHAP 5: Fix CORS (Connect Frontend ↔ Backend)

### Step 5.1: Update CORS di Railway

Backend perlu tahu domain frontend yang diizinkan.

1. **Buka** Railway dashboard: [https://railway.app](https://railway.app)
2. **Klik** project Nexo
3. **Klik** service backend
4. **Klik** tab "Variables"
5. **Cari** variable `CORS_ORIGIN`
6. **Klik** icon edit (pensil)
7. **Update value** dengan URL frontend dari Step 4.6:

```
https://nexo-xxxx.vercel.app
```

Atau jika punya custom domain:

```
https://nexo.com,https://www.nexo.com,https://nexo-xxxx.vercel.app
```

8. **Save** → backend otomatis redeploy (tunggu 1 menit)

### Step 5.2: Test Connection

1. **Buka** frontend: `https://nexo-xxxx.vercel.app`
2. **F12** → tab "Network"
3. **Refresh** halaman
4. **Cek** request ke backend → harus **200 OK** (hijau)

✅ **Semua connected!**

---

## 🎯 TAHAP 6: Verifikasi Final

### Checklist Testing:

- [ ] Frontend terbuka tanpa error
- [ ] Network tab tidak ada error CORS
- [ ] Data dari backend muncul di frontend
- [ ] API calls ke Railway backend success (200)
- [ ] Database query ke Supabase berhasil

### Test Endpoints:

```bash
# 1. Backend Health
https://nexo-backend-production-xxxx.up.railway.app/api/health

# 2. Frontend
https://nexo-xxxx.vercel.app

# 3. API Trends (contoh)
https://nexo-backend-production-xxxx.up.railway.app/api/trends
```

---

## 🔧 Troubleshooting

### ❌ Problem 1: Railway Build Failed

**Error:**
```
npm ERR! Cannot find module 'express'
```

**Solution:**
- Cek Root Directory di Settings = `app/backend`
- Pastikan `package.json` ada di `app/backend/`
- Redeploy

---

### ❌ Problem 2: Vercel Build Failed

**Error:**
```
Error: Cannot find module 'vite'
```

**Solution:**
- Cek Root Directory = `app/`
- Pastikan `package.json` ada di `app/`
- Clear cache:
  1. Deployment tab
  2. Klik titik tiga (...) di deployment terakhir
  3. Klik "Redeploy"

---

### ❌ Problem 3: CORS Error di Browser

**Error:**
```
Access to fetch at 'https://backend.railway.app' blocked by CORS
```

**Solution:**
1. Verifikasi `CORS_ORIGIN` di Railway = URL frontend yang benar
2. Pastikan tidak ada typo (https vs http)
3. Tunggu 1 menit setelah update variable (redeploy otomatis)
4. Hard refresh browser: `Ctrl + Shift + R`

---

### ❌ Problem 4: Environment Variables Tidak Terbaca

**Frontend (Vite):**
- Variable harus prefix `VITE_`
- Contoh: `VITE_API_URL` bukan `API_URL`
- Harus redeploy setelah tambah env var

**Backend (Node.js):**
- Cek typo di nama variable
- Pastikan tidak ada spasi di awal/akhir value
- Railway otomatis load env vars, tidak perlu dotenv di production

---

### ❌ Problem 5: Frontend Blank / White Screen

**Debug:**

1. **Buka DevTools Console** (`F12` → Console tab)
2. **Cek error message**

**Common fixes:**
- VITE_API_URL tidak diset → set di Vercel
- API endpoint salah → verifikasi URL Railway
- CORS error → fix di Railway (Step 5)

---

## 📊 Monitoring & Logs

### Railway Logs:

1. Buka project di Railway
2. Klik service backend
3. Tab "Deployments"
4. Klik "View Logs"

Real-time logs untuk debugging.

### Vercel Logs:

1. Buka project di Vercel
2. Tab "Deployments"
3. Klik deployment terakhir
4. Klik "View Function Logs" (jika ada functions)
5. Atau check "Runtime Logs"

---

## 🚀 Update Code Setelah Deploy

### Workflow Update:

```bash
# 1. Edit code di local
# 2. Test di local dulu
npm run dev

# 3. Commit changes
git add .
git commit -m "Update fitur X"

# 4. Push ke GitHub
git push

# 5. Deploy otomatis!
# - Railway: auto-deploy setelah push ke main branch
# - Vercel: auto-deploy setelah push ke main branch
```

**Tidak perlu manual deploy lagi!** Tinggal push ke GitHub, Railway dan Vercel otomatis rebuild.

### Disable Auto-Deploy (Optional):

**Railway:**
- Service Settings → Source → Pause/Resume deployment

**Vercel:**
- Project Settings → Git → Auto-deploy branches

---

## 💰 Monitoring Usage (Free Tier Limits)

### Railway Free Tier:
- **$5 credit/month** (reset tiap bulan)
- ~500 jam/bulan untuk 1 service
- Monitor: Dashboard → Usage tab

### Vercel Free Tier:
- **100GB bandwidth/month**
- Unlimited deployments
- Monitor: Project → Analytics

### Supabase Free Tier:
- **500MB database**
- **1GB file storage**
- **2GB bandwidth**
- Monitor: Dashboard → Usage

---

## 🎓 Next Steps

Setelah deployment berhasil:

1. **Custom Domain** (optional):
   - Vercel: Settings → Domains → Add
   - Railway: Settings → Networking → Custom Domain

2. **Enable Analytics**:
   - Vercel Analytics (gratis)
   - Google Analytics

3. **Setup Monitoring**:
   - [Sentry](https://sentry.io) untuk error tracking
   - [LogRocket](https://logrocket.com) untuk session replay

4. **Performance Optimization**:
   - Enable Vercel Edge Network
   - Add Redis cache di Railway

---

## 📞 Butuh Bantuan?

- **Railway Discord**: https://discord.gg/railway
- **Vercel Discord**: https://discord.gg/vercel
- **Supabase Discord**: https://discord.gg/supabase

---

## 📌 Summary

**URLs Penting:**

```
Frontend: https://nexo-xxxx.vercel.app
Backend:  https://nexo-backend-production-xxxx.up.railway.app
Database: https://xxxxxxxxxxxxxx.supabase.co
```

**Credentials:**
- Simpan semua credentials di password manager (1Password, Bitwarden, dll)
- Jangan commit `.env` ke Git
- Backup database password Supabase

---

🎉 **Selamat! Nexo sudah live di production!**

Share link ke user dan mulai collect feedback! 🚀
