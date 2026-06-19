enum EnrollmentStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case EnrollmentStatus.pending:
        return 'Menunggu';
      case EnrollmentStatus.approved:
        return 'Diterima';
      case EnrollmentStatus.rejected:
        return 'Ditolak';
    }
  }

  static EnrollmentStatus fromString(String? v) {
    return EnrollmentStatus.values.firstWhere(
      (e) => e.name == v,
      orElse: () => EnrollmentStatus.pending,
    );
  }
}
