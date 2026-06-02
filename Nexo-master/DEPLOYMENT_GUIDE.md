# 🚀 Tutorial Deploy Nexo - Lengkap & Praktis

## 📋 Daftar Isi
1. [Arsitektur Deployment](#arsitektur-deployment)
2. [Persiapan Awal](#persiapan-awal)
3. [Deploy Database (Supabase)](#1-deploy-database-supabase)
4. [Deploy Backend (Railway)](#2-deploy-backend-railway)
5. [Deploy Frontend (Vercel)](#3-deploy-frontend-vercel)
6. [Konfigurasi Domain & CORS](#4-konfigurasi-domain--cors)
7. [Testing & Monitoring](#5-testing--monitoring)
8. [Alternatif Platform](#6-alternatif-platform-deployment)
9. [Troubleshooting](#7-troubleshooting)

---

## Arsitektur Deployment

```
┌─────────────────────────────────────────────────────────────┐
│                     PRODUCTION SETUP                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Frontend (Vercel)                                          │
│  ├─ React + Vite                                            │
│  ├─ Domain: nexo.vercel.app                                 │
│  └─ Environment: VITE_API_URL                               │
│           │                                                 │
│           ↓                                                 │
│  Backend (Railway)                                          │
│  ├─ Node.js + Express                                       │
│  ├─ Domain: nexo-backend.railway.app                        │
│  └─ Environment: SUPABASE_URL, OPENAI_KEY, etc.            │
│           │                                                 │
│           ↓                                                 │
│  Database (Supabase)                                        │
│  ├─ PostgreSQL                                              │
│  ├─ Auth & Storage                                          │
│  └─ REST API & Realtime                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Persiapan Awal

### ✅ Checklist Requirements

- [ ] Akun GitHub (untuk koneksi Git)
- [ ] Akun Vercel (frontend)
- [ ] Akun Railway (backend)
- [ ] Akun Supabase (database)
- [ ] Akun OpenAI/Azure OpenAI (AI services)
- [ ] Akun Cloudflare R2 atau AWS S3 (optional, untuk storage)

### 📁 Struktur Project

```
Nexo-master/
├── app/                    # Frontend (React + Vite)
│   ├── src/
│   ├── package.json
│   ├── vercel.json
│   └── .env.production
└── app/backend/            # Backend (Node.js + Express)
    ├── src/
    ├── package.json
    └── .env
```

---

## 1️⃣ Deploy Database (Supabase)

### Step 1.1: Buat Project Supabase

1. Kunjungi [supabase.com](https://supabase.com)
2. Klik **"New Project"**
3. Isi detail:
   - **Project Name**: `nexo-production`
   - **Database Password**: (simpan ini, akan digunakan nanti)
   - **Region**: `Southeast Asia (Singapore)` (pilih yang terdekat)
   - **Pricing Plan**: Free / Pro (sesuai kebutuhan)

4. Tunggu 2-3 menit hingga project siap

### Step 1.2: Setup Database Schema

1. Buka **SQL Editor** di Supabase Dashboard
2. Jalankan script database Anda (jika ada file `schema.sql` atau migrations)

```sql
-- Contoh: Buat table trends
CREATE TABLE IF NOT EXISTS trends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT,
  growth NUMERIC,
  saturation NUMERIC,
  phase TEXT,
  platform TEXT,
  detected_at TIMESTAMPTZ DEFAULT NOW(),
  thumbnail TEXT,
  competitor_count INTEGER,
  avg_price NUMERIC,
  review_velocity INTEGER,
  description TEXT,
  recommendation TEXT,
  source_url TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Buat index untuk performa
CREATE INDEX idx_trends_category ON trends(category);
CREATE INDEX idx_trends_phase ON trends(phase);
CREATE INDEX idx_trends_platform ON trends(platform);
```

3. Jalankan script grants untuk permissions:

```sql
-- File: app/backend/src/scripts/grants.sql
-- Sesuaikan dengan kebutuhan Anda
```

### Step 1.3: Ambil Credentials

Di Supabase Dashboard, pergi ke **Settings > API**:

```
✅ Project URL: https://xxxxxxxxxxxxx.supabase.co
✅ anon/public key: eyJhbGc...
✅ service_role key: eyJhbGc... (RAHASIA!)
```

**⚠️ PENTING**: 
- `anon key` = untuk frontend (public, aman)
- `service_role key` = untuk backend (private, JANGAN diekspos!)

### Step 1.4: Setup Storage (Optional)

Jika menggunakan Supabase Storage untuk gambar:

1. Buka **Storage** di dashboard
2. Klik **"New Bucket"**
3. Nama: `trend-thumbnails`
4. Public/Private: Pilih **Public**
5. Setup policies:

```sql
-- Allow public read
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'trend-thumbnails');

-- Allow authenticated upload
CREATE POLICY "Authenticated upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'trend-thumbnails');
```

---

## 2️⃣ Deploy Backend (Railway)

### Step 2.1: Persiapan Backend

1. **Pastikan backend bisa jalan lokal dulu**:

```bash
cd app/backend
npm install
npm start
```

2. **Test endpoint**:
```bash
curl http://localhost:3000/api/health
# Expected: {"status":"ok"}
```

### Step 2.2: Deploy ke Railway

#### Opsi A: Deploy via GitHub (Recommended)

1. Push code ke GitHub:

```bash
# Di root project (bukan di dalam app/)
git init
git add .
git commit -m "Initial commit for deployment"
git remote add origin https://github.com/username/nexo.git
git push -u origin main
```

2. Kunjungi [railway.app](https://railway.app)
3. Klik **"New Project"** → **"Deploy from GitHub repo"**
4. Pilih repository `nexo`
5. Railway akan otomatis detect Node.js

#### Opsi B: Deploy via Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Init project
cd app/backend
railway init

# Deploy
railway up
```

### Step 2.3: Konfigurasi Railway

#### A. Set Root Directory

Railway perlu tahu backend ada di subfolder:

1. Di Railway dashboard, buka project Anda
2. Klik **Settings** tab
3. Scroll ke **Build** section
4. Set:
   - **Root Directory**: `app/backend`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`

#### B. Set Environment Variables

Klik **Variables** tab, tambahkan:

```bash
# Database
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...
SUPABASE_ANON_KEY=eyJhbGc...

# Server
PORT=3000
NODE_ENV=production

# JWT Secret (generate random string)
JWT_SECRET=your-super-secret-jwt-key-change-this

# AI Services
OPENAI_API_KEY=sk-...
# atau jika pakai Azure OpenAI:
AZURE_OPENAI_API_KEY=your-azure-key
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4

# Cloudflare R2 (optional)
R2_ACCOUNT_ID=your-account-id
R2_ACCESS_KEY_ID=your-access-key
R2_SECRET_ACCESS_KEY=your-secret-key
R2_BUCKET_NAME=nexo-assets
R2_PUBLIC_URL=https://nexo-assets.your-domain.com

# CORS (akan diset setelah deploy frontend)
CORS_ORIGIN=https://nexo.vercel.app
```

#### C. Generate Domain

1. Di tab **Settings**, scroll ke **Networking**
2. Klik **Generate Domain**
3. Domain Anda: `nexo-backend-production.up.railway.app`
4. **SIMPAN URL INI** untuk konfigurasi frontend

### Step 2.4: Verify Deployment

```bash
# Test public endpoint
curl https://nexo-backend-production.up.railway.app/api/health

# Expected response:
{
  "status": "ok",
  "runtime": {...}
}
```

---

## 3️⃣ Deploy Frontend (Vercel)

### Step 3.1: Persiapan Frontend

1. **Update environment production**:

Edit `app/.env.production`:

```bash
# Backend API
VITE_API_URL=https://nexo-backend-production.up.railway.app

# Supabase (untuk client-side auth)
VITE_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc...

# Feature flags (optional)
VITE_ENABLE_AI_CHAT=true
VITE_ENABLE_ANALYTICS=true
```

2. **Test build lokal**:

```bash
cd app
npm install
npm run build
npm run preview
# Buka http://localhost:4173
```

### Step 3.2: Deploy ke Vercel

#### Opsi A: Deploy via Vercel Dashboard (Termudah)

1. Kunjungi [vercel.com](https://vercel.com)
2. Klik **"Add New Project"**
3. Import dari GitHub repository
4. Vercel akan detect Vite automatically

**⚠️ PENTING - Konfigurasi Vercel:**

```
Framework Preset: Vite
Root Directory: app/
Build Command: npm run build
Output Directory: dist
Install Command: npm install
```

5. Klik **"Deploy"**
6. Tunggu 2-3 menit

#### Opsi B: Deploy via Vercel CLI

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
cd app
vercel --prod
```

### Step 3.3: Set Environment Variables di Vercel

1. Di Vercel Dashboard, buka project Anda
2. Klik **Settings** → **Environment Variables**
3. Tambahkan satu per satu:

```
VITE_API_URL = https://nexo-backend-production.up.railway.app
VITE_SUPABASE_URL = https://xxxxxxxxxxxxx.supabase.co
VITE_SUPABASE_ANON_KEY = eyJhbGc...
VITE_ENABLE_AI_CHAT = true
```

4. Pilih environment: **Production**, **Preview**, **Development**
5. Klik **Save**

### Step 3.4: Redeploy

Setelah tambah environment variables:

1. Klik **Deployments** tab
2. Klik titik tiga (...) di deployment terakhir
3. Klik **Redeploy**

### Step 3.5: Verify Frontend

1. Buka `https://nexo.vercel.app` (atau domain Anda)
2. Cek Network tab di browser DevTools
3. Pastikan API calls ke Railway backend berhasil

---

## 4️⃣ Konfigurasi Domain & CORS

### Step 4.1: Update CORS di Backend

Setelah frontend deploy, update Railway environment variables:

```bash
CORS_ORIGIN=https://nexo.vercel.app,https://nexo-preview.vercel.app
```

Atau jika punya custom domain:

```bash
CORS_ORIGIN=https://nexo.com,https://www.nexo.com,https://nexo.vercel.app
```

### Step 4.2: Custom Domain (Optional)

#### Frontend (Vercel):

1. Beli domain di Namecheap/GoDaddy/Cloudflare
2. Di Vercel: **Settings** → **Domains**
3. Add domain: `nexo.com`
4. Ikuti instruksi DNS:

```
A Record:
Name: @
Value: 76.76.21.21

CNAME Record:
Name: www
Value: cname.vercel-dns.com
```

5. Tunggu propagasi DNS (5-60 menit)

#### Backend (Railway):

1. Di Railway: **Settings** → **Networking**
2. Klik **Custom Domain**
3. Add: `api.nexo.com`
4. Setup DNS:

```
CNAME Record:
Name: api
Value: nexo-backend-production.up.railway.app
```

---

## 5️⃣ Testing & Monitoring

### Step 5.1: Smoke Testing

```bash
# Test backend health
curl https://nexo-backend-production.up.railway.app/api/health

# Test backend endpoints
curl https://nexo-backend-production.up.railway.app/api/trends

# Test frontend
curl -I https://nexo.vercel.app
```

### Step 5.2: Monitoring

#### Railway Monitoring:

1. **Metrics tab**: CPU, Memory, Network usage
2. **Logs tab**: Real-time application logs
3. **Alerts**: Setup alerts untuk downtime

#### Vercel Analytics:

1. Enable **Vercel Analytics** (gratis)
2. Dashboard otomatis track:
   - Page views
   - User location
   - Performance metrics
   - Web Vitals

#### Supabase Monitoring:

1. **Database tab** → **Usage**
2. Monitor:
   - Database size
   - Active connections
   - Query performance

### Step 5.3: Error Tracking (Optional)

Integrate Sentry untuk error tracking:

```bash
npm install @sentry/react @sentry/node
```

**Frontend** (`app/src/main.tsx`):
```typescript
import * as Sentry from '@sentry/react';

Sentry.init({
  dsn: 'https://...@sentry.io/...',
  environment: import.meta.env.MODE,
  tracesSampleRate: 1.0,
});
```

**Backend** (`app/backend/src/server.js`):
```javascript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: 'https://...@sentry.io/...',
  environment: process.env.NODE_ENV,
});
```

---

## 6️⃣ Alternatif Platform Deployment

### Opsi 1: Full Stack di Vercel

**Deployment monorepo dengan Vercel Functions:**

1. **Struktur**:
```
project/
├── api/           # Backend → Vercel Serverless Functions
│   └── *.js
└── src/           # Frontend
```

2. **vercel.json**:
```json
{
  "rewrites": [
    { "source": "/api/(.*)", "destination": "/api/$1" },
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

**Pro**: Simple, satu platform
**Con**: Serverless functions punya cold start, tidak ideal untuk long-running tasks

---

### Opsi 2: Backend di Render.com

**Alternatif Railway yang lebih murah:**

1. Kunjungi [render.com](https://render.com)
2. **New** → **Web Service**
3. Connect GitHub repo
4. Settings:
   - **Root Directory**: `app/backend`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`

**Pricing**: Free tier tersedia (dengan limitasi)

---

### Opsi 3: Full VPS (DigitalOcean/AWS/GCP)

**Untuk full control:**

```bash
# 1. Setup VPS Ubuntu 22.04
ssh root@your-server-ip

# 2. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# 3. Install PM2
npm install -g pm2

# 4. Deploy backend
cd /var/www
git clone https://github.com/username/nexo.git
cd nexo/app/backend
npm install
pm2 start src/server.js --name nexo-backend

# 5. Setup Nginx reverse proxy
apt-get install nginx
nano /etc/nginx/sites-available/nexo

# Nginx config:
server {
    listen 80;
    server_name api.nexo.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# 6. Enable site
ln -s /etc/nginx/sites-available/nexo /etc/nginx/sites-enabled/
systemctl restart nginx

# 7. SSL dengan Let's Encrypt
apt-get install certbot python3-certbot-nginx
certbot --nginx -d api.nexo.com
```

**Pro**: Full control, no cold start
**Con**: Perlu maintenance sendiri

---

### Opsi 4: Deploy Database Alternatif

#### A. PlanetScale (MySQL)
- Free tier: 5GB storage
- Serverless, auto-scaling
- No connection limits

#### B. Railway PostgreSQL
- Built-in dengan Railway backend
- Mudah setup
- Tapi lebih mahal dari Supabase free tier

#### C. Neon (Serverless PostgreSQL)
- Free tier: 3GB storage
- Serverless, auto-pause saat idle
- Compatible dengan Supabase client

---

## 7️⃣ Troubleshooting

### Issue 1: CORS Error

**Symptom**: 
```
Access to fetch at 'https://backend.railway.app' from origin 'https://frontend.vercel.app' 
has been blocked by CORS policy
```

**Solution**:
1. Cek Railway environment variable `CORS_ORIGIN`
2. Pastikan include domain frontend
3. Redeploy backend

---

### Issue 2: Environment Variables Tidak Terbaca

**Symptom**: 
```
Error: SUPABASE_URL is not defined
```

**Solution**:

**Frontend (Vite)**:
- Variable harus prefix `VITE_`
- Harus redeploy setelah tambah env var

**Backend (Node.js)**:
- Pastikan `dotenv` ter-load: `import 'dotenv/config'`
- Cek typo di Railway dashboard

---

### Issue 3: Build Failed di Vercel

**Symptom**:
```
Error: Cannot find module 'vite'
```

**Solution**:
1. Pastikan `package.json` ada di root directory yang benar
2. Cek Root Directory setting di Vercel = `app/`
3. Clear cache dan redeploy:
   ```bash
   vercel --force
   ```

---

### Issue 4: Database Connection Timeout

**Symptom**:
```
Error: Connection timeout to Supabase
```

**Solution**:
1. Cek Supabase project status (mungkin paused di free tier)
2. Verifikasi `SUPABASE_URL` dan keys benar
3. Test koneksi manual:

```javascript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const { data, error } = await supabase.from('trends').select('*').limit(1);
console.log({ data, error });
```

---

### Issue 5: Railway Out of Memory

**Symptom**:
```
Error: JavaScript heap out of memory
```

**Solution**:
1. Upgrade Railway plan (free tier = 512MB)
2. Atau optimize backend:

```javascript
// Limit payload size
app.use(express.json({ limit: '1mb' }));

// Add pagination
const limit = Math.min(req.query.limit || 10, 100);
```

---

## 8️⃣ Best Practices

### Security Checklist

- [ ] Jangan commit `.env` ke Git
- [ ] Gunakan `service_role` key hanya di backend
- [ ] Enable Railway private networking jika possible
- [ ] Setup rate limiting:

```javascript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 menit
  max: 100, // 100 requests per IP
});

app.use('/api/', limiter);
```

- [ ] Enable HTTPS only (Railway & Vercel default)
- [ ] Setup Supabase RLS (Row Level Security)

---

### Performance Optimization

**Frontend:**
- Enable Vercel Edge Caching
- Lazy load routes:
  ```typescript
  const Dashboard = lazy(() => import('./pages/Dashboard'));
  ```
- Optimize images dengan `sharp` atau Vercel Image Optimization

**Backend:**
- Implement Redis caching (Railway add-on)
- Database connection pooling
- Add indexes di Supabase

---

### Cost Optimization

| Service | Free Tier | Paid Tier |
|---------|-----------|-----------|
| **Vercel** | 100GB bandwidth/month | $20/month (Pro) |
| **Railway** | $5 credit/month | Pay-as-you-go ($0.000231/GB-s) |
| **Supabase** | 500MB database, 2GB bandwidth | $25/month (Pro) |

**Tips**:
- Mulai dengan free tier semua
- Monitor usage via dashboard
- Scale gradually based on traffic

---

## 9️⃣ Deployment Checklist

### Pre-Deployment
- [ ] Test lengkap di local (frontend + backend)
- [ ] Update `.env.production` dengan production URLs
- [ ] Commit semua changes
- [ ] Push ke GitHub

### Database
- [ ] Supabase project created
- [ ] Database schema migrated
- [ ] Credentials copied
- [ ] Storage buckets configured (if needed)

### Backend
- [ ] Railway project created
- [ ] Root directory set: `app/backend`
- [ ] Environment variables configured
- [ ] Custom domain generated
- [ ] Health endpoint accessible

### Frontend
- [ ] Vercel project created
- [ ] Root directory set: `app/`
- [ ] Environment variables set
- [ ] Build successful
- [ ] Frontend can call backend API

### Post-Deployment
- [ ] CORS configured
- [ ] Custom domains configured (optional)
- [ ] Monitoring setup
- [ ] Error tracking enabled (optional)
- [ ] SSL certificates active
- [ ] Smoke tests passed

---

## 🎉 Selesai!

Aplikasi Nexo Anda sekarang sudah live di:
- **Frontend**: https://nexo.vercel.app
- **Backend**: https://nexo-backend.up.railway.app
- **Database**: Supabase (managed)

### Next Steps:
1. Share link dengan users untuk testing
2. Monitor logs & metrics
3. Setup CI/CD untuk auto-deploy on push
4. Add custom domain untuk branding

---

## 📚 Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Railway Documentation](https://docs.railway.app)
- [Supabase Documentation](https://supabase.com/docs)
- [Vite Deployment Guide](https://vitejs.dev/guide/static-deploy.html)

---

**Butuh bantuan?** Tanya di:
- Railway Discord: https://discord.gg/railway
- Vercel Discord: https://discord.gg/vercel
- Supabase Discord: https://discord.gg/supabase

Happy Deploying! 🚀
