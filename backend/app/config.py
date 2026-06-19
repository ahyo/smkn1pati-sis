"""Konfigurasi aplikasi backend SMK Negeri 1 Pati.

Semua nilai dapat ditimpa lewat environment variable agar mudah dideploy.
"""
import os

# Lokasi file database SQLite.
DB_PATH = os.environ.get("LMS_DB_PATH", os.path.join(os.path.dirname(__file__), "..", "data.db"))

# Kunci penanda-tangan JWT. WAJIB diganti di produksi (mis. lewat env LMS_SECRET_KEY).
SECRET_KEY = os.environ.get("LMS_SECRET_KEY", "ganti-kunci-ini-di-produksi-smkn1pati")

# Masa berlaku token (jam).
TOKEN_TTL_HOURS = int(os.environ.get("LMS_TOKEN_TTL_HOURS", "168"))  # 7 hari

# Daftar origin yang diizinkan (CORS). "*" untuk semua saat pengembangan.
CORS_ORIGINS = os.environ.get("LMS_CORS_ORIGINS", "*").split(",")

# Koleksi data yang valid — harus selaras dengan DataService di aplikasi Flutter.
COLLECTIONS = {
    "users",
    "classes",
    "subjects",
    "materials",
    "exams",
    "submissions",
    "teachingJournals",
    "studyJournals",
    "teacherAttendance",
    "studentAttendance",
    "auditLogs",
    "enrollments",
    "paymentCategories",
    "paymentBills",
    "paymentTransactions",
    "academicYears",
}
