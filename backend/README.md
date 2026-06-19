# Backend API — SMK Negeri 1 Pati

Backend **FastAPI** untuk Sistem Informasi & Pembelajaran Digital SMK Negeri 1 Pati.
Menggantikan rencana awal berbasis **Firebase**.

- **FastAPI** + **Uvicorn**
- **JWT** untuk autentikasi (PyJWT) + hashing kata sandi **PBKDF2** (stdlib)
- Penyimpanan **SQLite** (default) atau **PostgreSQL** — dipilih lewat
  `DATABASE_URL`. Pola *document store* yang selaras dengan `toMap()` /
  `fromMap()` di model Flutter.

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

## Menjalankan dengan PostgreSQL

### Opsi A — Docker Compose (paling mudah)

Menjalankan API + PostgreSQL sekaligus:

```bash
cd backend
docker compose up --build
```

API di <http://localhost:8000>, PostgreSQL di port 5432. Seed otomatis berjalan
pada database `smkn1pati`.

### Opsi B — PostgreSQL sendiri

```bash
export DATABASE_URL=postgresql://lms:lms@localhost:5432/smkn1pati
uvicorn app.main:app --reload --port 8000
```

Cek engine yang aktif: `GET /` → `{"engine": "postgresql", ...}`.

## Konfigurasi (environment variable)

| Variabel              | Default                    | Keterangan                              |
|-----------------------|----------------------------|-----------------------------------------|
| `DATABASE_URL`        | *(kosong → SQLite)*        | `postgresql://user:pass@host:5432/db`   |
| `LMS_DB_PATH`         | `backend/data.db`          | Lokasi file SQLite (bila tanpa Postgres)|
| `LMS_SECRET_KEY`      | *(ganti di produksi!)*     | Kunci penanda-tangan JWT                |
| `LMS_TOKEN_TTL_HOURS` | `168`                      | Masa berlaku token (jam)                |
| `LMS_CORS_ORIGINS`    | `*`                        | Origin diizinkan (pisah koma)           |

## SQLite vs PostgreSQL untuk produksi

| | SQLite | PostgreSQL |
|---|---|---|
| Penulisan bersamaan | 1 penulis pada satu waktu | Banyak penulis paralel (MVCC) |
| Skala | Ribuan baris, beban ringan | Jutaan baris, ratusan koneksi |
| Cocok untuk | Dev, demo, sekolah kecil | Produksi banyak siswa (mis. ujian serentak) |

**Rekomendasi:** SQLite untuk pengembangan; **PostgreSQL untuk produksi**
dengan banyak siswa. Karena akses DB terisolasi di `app/db.py` dan memakai pola
JSON yang sama (`TEXT` di SQLite ↔ `JSONB` di Postgres), perpindahan cukup
dengan mengatur `DATABASE_URL` — tanpa mengubah router, auth, atau aplikasi Flutter.
