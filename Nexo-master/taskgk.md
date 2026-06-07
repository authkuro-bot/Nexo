# Loading dan Retry Chatbot RAG Nexo

## Ringkasan
Ganti indikator tiga titik dengan bubble AI yang menampilkan:

- Logo Nexo dengan breathing halus.
- Teks `Nexo AI sedang menganalisis` dengan animated ellipsis.
- Nexo Data Runner compact di bawah teks.
- Tombol `Coba lagi` jika request AI gagal.
- Loading berhenti ketika chunk jawaban pertama diterima.
- Pertanyaan tidak diduplikasi ketika retry.

Animasi juga diterapkan pada pembuka chat dengan teks `Nexo AI sedang menyiapkan percakapan`.

## Perubahan Implementasi

### Komponen Animasi Bersama
Ekstrak Nexo Data Runner menjadi komponen reusable:

```ts
type NexoDataRunnerProps = {
  size?: 'compact' | 'default';
  label: string;
};
```

Tambahkan komponen status chatbot:

```ts
type ChatAiStatusProps = {
  message: string;
  mode: 'welcome' | 'answer';
};
```

Perilaku animasi:

- Teks utama tetap diam agar mudah dibaca.
- Tiga titik memiliki area lebar tetap dan melakukan staggered fade serta gerakan vertikal `1px`.
- Siklus titik sekitar `1.2s`.
- Runner bergerak setiap `1.85s`.
- Bubble baru ditampilkan setelah request berlangsung `180ms` untuk mencegah flicker.
- Tidak ada skeleton abu-abu atau persentase palsu.
- Reduced motion menampilkan logo dan runner dalam keadaan statis.

### State dan Kontrak Chat
Perluas model pesan dan request:

```ts
type ChatMessageStatus = 'streaming' | 'complete' | 'failed';

interface ChatMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: string;
  status?: ChatMessageStatus;
}

type ChatRequestPhase =
  | 'idle'
  | 'analyzing'
  | 'streaming'
  | 'failed';

interface ChatRequestState {
  phase: ChatRequestPhase;
  trendId: string;
  userMessageId?: string;
  assistantMessageId?: string;
  originalMessage?: string;
  error?: string;
  errorCode?: string;
  retryable: boolean;
}
```

Store menyediakan:

```ts
streamChat(trendId: string, message: string): Promise<void>;
retryFailedChat(trendId: string): Promise<void>;
retryWelcome(trendId: string): Promise<void>;
```

Parameter `trendName` yang tidak digunakan dihapus.

### Siklus Jawaban
1. Tambahkan pesan pengguna satu kali.
2. Set phase menjadi `analyzing`.
3. Tampilkan status setelah `180ms`.
4. Saat chunk pertama diterima:
   - Buat atau perbarui pesan assistant.
   - Ubah phase menjadi `streaming`.
   - Sembunyikan bubble analisis.
5. Setelah `[DONE]`:
   - Tandai pesan assistant `complete`.
   - Ubah phase menjadi `idle`.
   - Tambahkan hitungan chat harian hanya jika respons berhasil.
6. Jika SSE mengandung `error`, perlakukan sebagai kegagalan, bukan respons sukses.

State request disimpan berdasarkan `trendId`, sehingga berpindah produk tidak menampilkan loading atau error milik chat lain.

### Error dan Retry
Error ditampilkan sebagai bubble assistant inline:

```text
Analisis Nexo belum berhasil.
[pesan aman untuk pengguna]

[Coba lagi]
```

Aturan retry:

- Network error, HTTP `5xx`, dan SSE error: tampilkan `Coba lagi`.
- HTTP `429`: tampilkan batas harian tanpa tombol retry.
- Error autentikasi atau validasi: tidak retryable.
- Retry menggunakan pertanyaan pengguna yang sama.
- Pesan pengguna tidak ditambahkan ulang.
- Jawaban parsial yang gagal dihapus atau direset sebelum retry.
- Hasil retry menggantikan posisi jawaban gagal.
- Error generik assistant lama tidak lagi ditambahkan sebagai pesan terpisah.
- Input dinonaktifkan selama phase `analyzing` dan `streaming`, lalu aktif kembali saat gagal.

### Pembuka Chat
- Ganti `WelcomeSkeleton` dengan status `Nexo AI sedang menyiapkan percakapan`.
- Gunakan Nexo Data Runner compact.
- Jika gagal, tampilkan error inline dan tombol `Coba lagi`.
- Pengguna tetap boleh langsung mengetik meskipun pembuka gagal.
- Retry pembuka tidak menghapus percakapan yang sudah ada.

## Aksesibilitas
- Bubble status memakai `role="status"` dan `aria-live="polite"`.
- Screen reader hanya membaca kalimat tetap satu kali.
- Animated ellipsis, runner, dan partikel memakai `aria-hidden="true"`.
- Error memakai `role="alert"`.
- Tombol retry memiliki label yang menjelaskan aksi.
- Fokus tidak dipindahkan otomatis ketika loading berubah menjadi hasil.

## Pengujian
- Loading jawaban muncul setelah delay dan memuat teks serta runner.
- Loading tidak berkedip untuk respons di bawah `180ms`.
- Chunk pertama menyembunyikan loading dan menampilkan streaming answer.
- Success menyelesaikan pesan dan menaikkan hitungan harian sekali.
- Network dan `5xx` menampilkan tombol retry.
- SSE error tidak ditandai sebagai sukses.
- Retry tidak menduplikasi pertanyaan pengguna.
- Jawaban parsial gagal digantikan oleh hasil retry.
- `429` tidak menampilkan tombol retry.
- Welcome loading, success, error, dan retry bekerja.
- State loading tidak bocor ketika berpindah trend.
- Reduced-motion dan atribut ARIA diuji.
- Jalankan `npm test`, lint terarah, dan production build tanpa browser checking.

## Asumsi
- Endpoint backend `/api/chat` dan format SSE tidak perlu diubah.
- Nexo Data Runner yang sudah ada digunakan kembali, bukan dibuat duplikat.
- Teks jawaban tetap dirender dengan mekanisme chatbot yang sekarang.
- Tidak menambahkan library baru karena Motion dan Radix Progress sudah tersedia.
