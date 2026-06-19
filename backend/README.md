# Backend API — SMK Negeri 1 Pati

Backend **FastAPI** untuk Sistem Informasi & Pembelajaran Digital SMK Negeri 1 Pati.
Menggantikan rencana awal berbasis **Firebase**.

- **FastAPI** + **Uvicorn**
- **JWT** untuk autentikasi (PyJWT) + hashing kata sandi **PBKDF2** (stdlib)
- **SQLite** sebagai penyimpanan (pola *document store*, selaras dengan
  `toMap()` / `fromMap()` di model Flutter) — mudah dipindah ke PostgreSQL nanti

## Menjalankan

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Dokumentasi interaktif otomatis: <http://localhost:8000/docs>

Saat pertama kali dijalankan, database `data.db` dibuat dan diisi data awal
SMK Negeri 1 Pati.

### Akun demo (kata sandi: `password`)

| Role      | Email             |
|-----------|-------------------|
| Admin     | admin@sekolah.id  |
| Guru      | guru@sekolah.id   |
| Siswa     | siswa@sekolah.id  |
| Orang Tua | ortu@sekolah.id   |

## Endpoint utama

### Autentikasi (`/api/auth`)
| Method | Path                     | Keterangan                       |
|--------|--------------------------|----------------------------------|
| POST   | `/api/auth/register`     | Daftar akun baru → `{token,user}`|
| POST   | `/api/auth/login`        | Login → `{token, user}`          |
| GET    | `/api/auth/me`           | Profil pengguna aktif (Bearer)   |
| PUT    | `/api/auth/profile`      | Perbarui profil (Bearer)         |
| POST   | `/api/auth/change-password` | Ganti kata sandi (Bearer)     |

### Data (`/api/{collection}`) — butuh header `Authorization: Bearer <token>`
| Method | Path                       | Memetakan ke DataService Flutter |
|--------|----------------------------|----------------------------------|
| GET    | `/api/{collection}`        | `watch<Entity>()`                |
| PUT    | `/api/{collection}/{id}`   | `upsert<Entity>()`               |
| DELETE | `/api/{collection}/{id}`   | `delete<Entity>()`               |

Koleksi yang valid: `users`, `classes`, `subjects`, `materials`, `exams`,
`submissions`, `teachingJournals`, `studyJournals`, `teacherAttendance`,
`studentAttendance`, `auditLogs`, `enrollments`, `paymentCategories`,
`paymentBills`, `paymentTransactions`, `academicYears`.

## Menghubungkan dari aplikasi Flutter

Di `lib/main.dart` set `useApi = true`, lalu jalankan dengan base URL backend:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

## Konfigurasi (environment variable)

| Variabel              | Default                    | Keterangan                     |
|-----------------------|----------------------------|--------------------------------|
| `LMS_DB_PATH`         | `backend/data.db`          | Lokasi file SQLite             |
| `LMS_SECRET_KEY`      | *(ganti di produksi!)*     | Kunci penanda-tangan JWT       |
| `LMS_TOKEN_TTL_HOURS` | `168`                      | Masa berlaku token (jam)       |
| `LMS_CORS_ORIGINS`    | `*`                        | Origin diizinkan (pisah koma)  |

## Catatan produksi: SQLite vs PostgreSQL

SQLite cocok untuk pengembangan & sekolah skala kecil–menengah. Untuk produksi
dengan banyak siswa dan penulisan bersamaan tinggi, **PostgreSQL** lebih
dianjurkan (lihat penjelasan di catatan proyek). Lapisan `app/db.py` sengaja
dibuat terisolasi sehingga migrasi ke PostgreSQL cukup mengganti modul tersebut.
