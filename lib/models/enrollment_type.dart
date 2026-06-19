enum EnrollmentType {
  newStudent,
  transfer;

  String get label {
    switch (this) {
      case EnrollmentType.newStudent:
        return 'Siswa Baru';
      case EnrollmentType.transfer:
        return 'Pindahan';
    }
  }

  static EnrollmentType fromString(String? v) {
    return EnrollmentType.values.firstWhere(
      (e) => e.name == v,
      orElse: () => EnrollmentType.newStudent,
    );
  }
}
