"""Data awal (seed) untuk SMK Negeri 1 Pati.

Dijalankan otomatis saat startup bila database masih kosong. Menyediakan akun
login untuk tiap role serta data inti agar aplikasi langsung dapat dicoba.

Akun demo (semua kata sandi: `password`):
  admin@sekolah.id  · guru@sekolah.id  · siswa@sekolah.id  · ortu@sekolah.id
"""
from datetime import datetime, timezone

from . import db, security

_NOW = datetime.now(timezone.utc).isoformat()


def _iso(y: int, m: int, d: int) -> str:
    return datetime(y, m, d, tzinfo=timezone.utc).isoformat()


def seed_if_empty() -> None:
    if db.count_documents("users") > 0:
        return

    # ── Tahun ajaran ─────────────────────────────────────────────────────────
    db.upsert_document("academicYears", "ay_2025", {
        "name": "2025/2026",
        "startDate": _iso(2025, 7, 14),
        "endDate": _iso(2026, 6, 20),
        "status": "active",
        "createdAt": _NOW,
        "createdByAdminId": "u_admin",
    })

    # ── Mata pelajaran ───────────────────────────────────────────────────────
    subjects = [
        ("subj_mtk", "Matematika", "MTK", "Matematika wajib kelompok A"),
        ("subj_bind", "Bahasa Indonesia", "BIND", "Bahasa Indonesia kelompok A"),
        ("subj_prog", "Pemrograman Dasar", "PROG", "Dasar pemrograman produktif RPL"),
        ("subj_jaringan", "Komputer dan Jaringan Dasar", "KJD", "Produktif TKJ"),
    ]
    for sid, name, code, desc in subjects:
        db.upsert_document("subjects", sid, {"name": name, "code": code, "description": desc})

    # ── Kelas ────────────────────────────────────────────────────────────────
    db.upsert_document("classes", "cls_x_rpl1", {
        "name": "X RPL 1",
        "gradeLevel": "X",
        "homeroomTeacherId": "u_guru",
        "studentIds": ["u_siswa"],
    })
    db.upsert_document("classes", "cls_xi_tkj1", {
        "name": "XI TKJ 1",
        "gradeLevel": "XI",
        "homeroomTeacherId": None,
        "studentIds": [],
    })

    # ── Pengguna + kredensial ────────────────────────────────────────────────
    users = [
        {
            "id": "u_admin", "email": "admin@sekolah.id", "name": "Administrator Sekolah",
            "role": "admin", "phone": "0295-123456", "gender": "Laki-laki",
            "identityNumber": "198001012005011001",
            "address": "Jl. AMD Patiunus No. 1, Pati Lor, Kabupaten Pati",
            "bio": "Administrator Sistem Informasi SMK Negeri 1 Pati.",
        },
        {
            "id": "u_guru", "email": "guru@sekolah.id", "name": "Budi Santoso, S.Pd.",
            "role": "teacher", "phone": "0812-3456-7890", "gender": "Laki-laki",
            "identityNumber": "198505152010011002",
            "address": "Perum Pati Permai Blok C No. 12, Pati",
            "subjectIds": ["subj_prog", "subj_jaringan"],
            "bio": "Guru produktif Rekayasa Perangkat Lunak.",
        },
        {
            "id": "u_siswa", "email": "siswa@sekolah.id", "name": "Andi Pratama",
            "role": "student", "phone": "0813-9876-5432", "gender": "Laki-laki",
            "identityNumber": "0051234567", "classId": "cls_x_rpl1",
            "dateOfBirth": _iso(2009, 3, 17),
            "address": "Desa Margorejo RT 02 RW 03, Pati",
            "bio": "Siswa kelas X RPL 1.",
        },
        {
            "id": "u_ortu", "email": "ortu@sekolah.id", "name": "Sri Wahyuni",
            "role": "parent", "phone": "0856-1122-3344", "gender": "Perempuan",
            "identityNumber": "3318014405800002", "childrenIds": ["u_siswa"],
            "address": "Desa Margorejo RT 02 RW 03, Pati",
            "bio": "Orang tua dari Andi Pratama.",
        },
    ]
    for u in users:
        uid = u.pop("id")
        u.setdefault("createdAt", _NOW)
        db.upsert_document("users", uid, u)
        db.set_credential(u["email"], security.hash_password("password"), uid)

    # ── Kategori pembayaran ──────────────────────────────────────────────────
    db.upsert_document("paymentCategories", "pc_spp", {
        "name": "SPP Bulanan", "description": "Sumbangan Pembinaan Pendidikan",
        "defaultAmount": 150000, "createdAt": _NOW,
    })
    db.upsert_document("paymentCategories", "pc_gedung", {
        "name": "Uang Gedung", "description": "Pengembangan sarana sekolah",
        "defaultAmount": 1500000, "createdAt": _NOW,
    })

    print("[seed] Data awal SMK Negeri 1 Pati berhasil dibuat.")
