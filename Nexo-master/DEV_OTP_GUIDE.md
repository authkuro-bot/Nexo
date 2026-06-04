# 🔐 Dev OTP Configuration Guide

## Overview

Aplikasi ini memiliki fitur "Dev OTP Mode" yang menampilkan kode OTP langsung di layar untuk memudahkan testing tanpa perlu akses ke WhatsApp/SMS.

## Cara Kerja

Di **localhost** (NODE_ENV=development):
- OTP otomatis ditampilkan di response API
- Frontend menampilkan badge "Kode OTP (dev mode): 123456"

Di **production** (NODE_ENV=production):
- Secara default, OTP **TIDAK** ditampilkan
- Untuk demo/testing, bisa diaktifkan dengan environment variable

---

## 🚀 Mengaktifkan Dev OTP di Production

### Opsi 1: Via Railway Dashboard

1. Buka Railway dashboard → pilih service backend Anda
2. Masuk ke tab **Variables**
3. Tambahkan environment variable baru:
   ```
   SHOW_DEV_OTP=true
   ```
4. Klik **Deploy** atau tunggu auto-redeploy
5. ✅ Dev OTP sekarang akan muncul di production!

### Opsi 2: Via Railway CLI

```bash
railway variables set SHOW_DEV_OTP=true
railway up
```

### Opsi 3: Via Vercel Dashboard (jika backend di Vercel)

1. Buka Vercel dashboard → pilih project backend
2. Settings → Environment Variables
3. Tambahkan:
   - **Name:** `SHOW_DEV_OTP`
   - **Value:** `true`
   - **Environment:** Production (centang)
4. Redeploy project

### Opsi 4: Via Vercel CLI

```bash
vercel env add SHOW_DEV_OTP
# Input: true
# Environment: Production

vercel --prod
```

---

## 📋 Environment Variable Reference

| Variable | Value | Behavior |
|----------|-------|----------|
| `SHOW_DEV_OTP=true` | Force show | OTP selalu tampil (bahkan di production) |
| `SHOW_DEV_OTP=false` | Force hide | OTP tidak tampil (bahkan di development) |
| `SHOW_DEV_OTP=1` | Force show | Sama dengan `true` |
| `SHOW_DEV_OTP=0` | Force hide | Sama dengan `false` |
| *tidak diset* | Auto | Show hanya jika `NODE_ENV !== 'production'` |

---

## 🔍 Verifikasi

### 1. Cek Backend Logs
Setelah deploy, cek logs backend:

```bash
# Railway
railway logs

# Vercel
vercel logs
```

Cari output seperti:
```
[OTP][register] Phone: 081234567890, Code: 982632
```

### 2. Test API Langsung

```bash
curl -X POST https://your-backend-url.railway.app/api/auth/otp/send \
  -H "Content-Type: application/json" \
  -d '{"phone":"081234567890"}'
```

Response harusnya berisi field `otp`:
```json
{
  "message": "OTP terkirim",
  "otp": "982632"
}
```

### 3. Test di Frontend
1. Buka aplikasi di production
2. Lakukan registrasi dengan nomor testing
3. Setelah klik "Daftar", badge biru harusnya muncul:
   ```
   Kode OTP (dev mode): 982632
   ```

---

## ⚠️ Security Warning

**PENTING:** `SHOW_DEV_OTP=true` sebaiknya **HANYA digunakan untuk:**
- Demo/presentation
- Testing environment
- Staging server

**JANGAN gunakan di production yang sesungguhnya** karena:
- User bisa melihat OTP tanpa akses WhatsApp
- Mengurangi keamanan sistem autentikasi

Untuk production real, gunakan:
```env
SHOW_DEV_OTP=false
OTP_DELIVERY=whatsapp  # atau sms
```

---

## 📝 Technical Details

### Backend Implementation

File: `app/backend/src/lib/runtime.js`
```javascript
export function shouldShowDevOtp() {
  const showDevOtp = (process.env.SHOW_DEV_OTP || '').toLowerCase();
  if (showDevOtp === 'true' || showDevOtp === '1') return true;
  if (showDevOtp === 'false' || showDevOtp === '0') return false;
  return process.env.NODE_ENV !== 'production';
}
```

### API Endpoints yang Terpengaruh

1. `POST /api/auth/otp/send` (Register OTP)
2. `POST /api/auth/forgot-password` (Forgot Password OTP)

Response format:
```json
{
  "message": "OTP terkirim",
  "otp": "123456"  // ← Field ini hanya muncul jika shouldShowDevOtp() = true
}
```

### Frontend Implementation

File: `app/src/pages/LoginPage.tsx`
- Baris 177, 221, 243: Toast notification dengan OTP
- Baris 620, 804: Badge biru yang menampilkan dev OTP

---

## 🎯 Quick Checklist untuk Demo

- [ ] Set `SHOW_DEV_OTP=true` di environment variables backend
- [ ] Redeploy backend
- [ ] Buka frontend production
- [ ] Test registrasi → OTP badge muncul ✅
- [ ] Test forgot password → OTP badge muncul ✅
- [ ] Screenshot untuk dokumentasi

---

## 🐛 Troubleshooting

### OTP masih tidak muncul setelah set env var

1. **Cek apakah env var tersimpan:**
   ```bash
   railway variables list
   # atau
   vercel env ls
   ```

2. **Cek apakah backend sudah redeploy:**
   - Railway: lihat deployment logs
   - Vercel: lihat deployment history

3. **Cek response API langsung:**
   - Buka DevTools → Network tab
   - Trigger OTP send
   - Cek response body ada field `otp` atau tidak

4. **Cek backend logs:**
   - Harusnya ada log: `[OTP][register] Phone: xxx, Code: xxx`

### OTP muncul tapi frontend tidak menampilkan

1. **Cek console browser:**
   - Mungkin ada error JavaScript
   - Cek apakah `toast.info()` berfungsi

2. **Cek file LoginPage.tsx:**
   - Pastikan baris 177, 221, 243 tidak dikomentari
   - Pastikan conditional `if (result.otp)` masih ada

---

## 📞 Support

Jika masih ada masalah, cek:
1. Backend logs: `railway logs -f` atau `vercel logs --follow`
2. Browser console: F12 → Console tab
3. Network tab: F12 → Network → filter `/api/auth/`

---

**Last Updated:** Juni 2026  
**Version:** 1.0.0
