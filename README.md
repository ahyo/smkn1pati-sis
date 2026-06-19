# SMK Negeri 1 Pati — Sistem Informasi & Pembelajaran Digital

Sistem Informasi Sekolah + LMS berbasis **Flutter** untuk **SMK Negeri 1 Pati**, dengan
empat peran pengguna — **Admin**, **Guru**, **Siswa**, dan **Orang Tua**. Bisa di-deploy
ke **Web**, **Android**, dan **iOS** dari satu codebase, didukung **backend FastAPI**.

> 🌐 **Demo (GitHub Pages):** https://ahyo.github.io/smkn1pati-sis/
> (mode demo memakai data mock in-memory sehingga berjalan mandiri tanpa backend)

## Fitur

- **Admin**: dashboard ringkasan, kelola pengguna (CRUD), kelola kelas + wali kelas + siswa per kelas, kelola mata pelajaran, halaman pengaturan.
- **Guru**: buat/edit materi pembelajaran, buat/edit ujian pilihan ganda dengan timer, lihat hasil submisi siswa, **catat jurnal mengajar** harian (tanggal, kelas, mapel, topik, kegiatan, kehadiran, refleksi).
- **Siswa**: lihat materi sesuai kelas, kerjakan ujian dengan timer otomatis (auto-submit saat habis), lihat hasil ujian, **catat jurnal belajar** mandiri (topik, ringkasan, durasi).
- **Orang Tua**: pantau anak — kelas, materi, nilai ujian, jurnal mengajar dari guru, dan jurnal belajar mandiri anak.
- **Auth**: login email/password + register (siswa/guru/orang tua). Role admin hanya bisa dibuat dari akun admin lain.
- **Routing role-based**: setiap peran hanya bisa mengakses halamannya sendiri.
- **Layout responsif**: di **web/desktop** (≥900px) tampil sebagai dashboard dengan sidebar kiri persisten + top bar. Di **mobile** tampil dengan AppBar + drawer hamburger.

## Menjalankan

```bash
flutter pub get
flutter run -d chrome     # Web
flutter run -d <device>   # Android / iOS
```

### Akun demo (mock backend)

App bawaan menggunakan **mock in-memory backend** sehingga langsung jalan tanpa setup eksternal. Semua akun memakai password `password`:

| Email                | Peran      |
| -------------------- | ---------- |
| `admin@sekolah.id`   | Admin      |
| `guru@sekolah.id`    | Guru       |
| `siswa@sekolah.id`   | Siswa      |
| `ortu@sekolah.id`    | Orang Tua  |

Halaman login menyediakan tombol "quick login" untuk tiap peran.

## Backend FastAPI

Rencana awal berbasis Firebase telah **diganti dengan backend FastAPI** (folder
[backend/](backend/)) — FastAPI + JWT + SQLite (pola *document store* yang selaras
dengan `toMap()` / `fromMap()` tiap model). Untuk menjalankan:

```bash
cd backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000     # dok: http://localhost:8000/docs
```

Lalu jalankan aplikasi Flutter dengan mode API aktif:

```bash
flutter run -d chrome \
  --dart-define=USE_API=true \
  --dart-define=API_BASE_URL=http://localhost:8000
```

Tanpa flag tersebut, aplikasi memakai **mock backend** (mode demo). Detail endpoint &
opsi produksi (SQLite vs PostgreSQL) ada di [backend/README.md](backend/README.md).

## Struktur

```
lib/
├── main.dart                   # Entry point + DI
├── models/                     # AppUser, SchoolClass, Subject, LearningMaterial, Exam, ExamSubmission
├── services/
│   ├── auth_service.dart       # Interface
│   ├── data_service.dart       # Interface
│   ├── mock/                   # In-memory implementation (mode demo, default)
│   └── api/                    # Implementasi backend FastAPI (opt-in via USE_API)
├── providers/                  # AuthProvider, DataProvider (ChangeNotifier)
├── router/app_router.dart      # go_router + role redirect
├── widgets/role_scaffold.dart  # Shared AppBar + dashboard tile
└── screens/
    ├── auth/                   # login, register
    ├── admin/                  # dashboard, users, classes, subjects, settings
    ├── teacher/                # dashboard, materials, exams (+editors), submissions
    ├── student/                # dashboard, materials, exams, exam runner, results
    └── parent/                 # dashboard, child detail
```

## Build & Deploy

```bash
flutter build web      # output: build/web (otomatis ter-deploy ke GitHub Pages via Actions)
flutter build apk      # Android
flutter build appbundle  # Google Play
flutter build ios      # iOS (perlu macOS + Xcode)
```
