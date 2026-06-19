enum UserRole {
  admin,
  teacher,
  student,
  parent;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Guru';
      case UserRole.student:
        return 'Siswa';
      case UserRole.parent:
        return 'Orang Tua';
    }
  }

  /// Label nomor identitas yang sesuai konteks role.
  String get identityLabel {
    switch (this) {
      case UserRole.admin:
      case UserRole.teacher:
        return 'NIP';
      case UserRole.student:
        return 'NIS';
      case UserRole.parent:
        return 'NIK';
    }
  }

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.student,
    );
  }
}
