import 'package:flutter/material.dart';

enum AuditAction {
  signIn,
  signInFailed,
  signOut,
  register,
  passwordChange,
  profileUpdate,
  userCreate,
  userUpdate,
  userDelete,
  classCreate,
  classUpdate,
  classDelete,
  subjectCreate,
  subjectUpdate,
  subjectDelete;

  String get label {
    switch (this) {
      case AuditAction.signIn:
        return 'Berhasil Login';
      case AuditAction.signInFailed:
        return 'Login Gagal';
      case AuditAction.signOut:
        return 'Logout';
      case AuditAction.register:
        return 'Registrasi';
      case AuditAction.passwordChange:
        return 'Ubah Sandi';
      case AuditAction.profileUpdate:
        return 'Ubah Profil';
      case AuditAction.userCreate:
        return 'Tambah Pengguna';
      case AuditAction.userUpdate:
        return 'Ubah Pengguna';
      case AuditAction.userDelete:
        return 'Hapus Pengguna';
      case AuditAction.classCreate:
        return 'Tambah Kelas';
      case AuditAction.classUpdate:
        return 'Ubah Kelas';
      case AuditAction.classDelete:
        return 'Hapus Kelas';
      case AuditAction.subjectCreate:
        return 'Tambah Mapel';
      case AuditAction.subjectUpdate:
        return 'Ubah Mapel';
      case AuditAction.subjectDelete:
        return 'Hapus Mapel';
    }
  }

  /// Group umum untuk filter UI.
  String get category {
    switch (this) {
      case AuditAction.signIn:
      case AuditAction.signInFailed:
      case AuditAction.signOut:
      case AuditAction.register:
      case AuditAction.passwordChange:
      case AuditAction.profileUpdate:
        return 'Akun';
      case AuditAction.userCreate:
      case AuditAction.userUpdate:
      case AuditAction.userDelete:
        return 'Pengguna';
      case AuditAction.classCreate:
      case AuditAction.classUpdate:
      case AuditAction.classDelete:
        return 'Kelas';
      case AuditAction.subjectCreate:
      case AuditAction.subjectUpdate:
      case AuditAction.subjectDelete:
        return 'Mapel';
    }
  }

  IconData get icon {
    switch (this) {
      case AuditAction.signIn:
        return Icons.login;
      case AuditAction.signInFailed:
        return Icons.report_problem_outlined;
      case AuditAction.signOut:
        return Icons.logout;
      case AuditAction.register:
        return Icons.person_add_outlined;
      case AuditAction.passwordChange:
        return Icons.password_outlined;
      case AuditAction.profileUpdate:
        return Icons.manage_accounts_outlined;
      case AuditAction.userCreate:
      case AuditAction.userUpdate:
      case AuditAction.userDelete:
        return Icons.people_outline;
      case AuditAction.classCreate:
      case AuditAction.classUpdate:
      case AuditAction.classDelete:
        return Icons.class_outlined;
      case AuditAction.subjectCreate:
      case AuditAction.subjectUpdate:
      case AuditAction.subjectDelete:
        return Icons.menu_book_outlined;
    }
  }

  Color color(ColorScheme scheme) {
    switch (this) {
      case AuditAction.signIn:
      case AuditAction.register:
      case AuditAction.userCreate:
      case AuditAction.classCreate:
      case AuditAction.subjectCreate:
        return Colors.green.shade700;
      case AuditAction.signInFailed:
      case AuditAction.userDelete:
      case AuditAction.classDelete:
      case AuditAction.subjectDelete:
        return scheme.error;
      case AuditAction.signOut:
        return scheme.onSurfaceVariant;
      default:
        return scheme.primary;
    }
  }

  static AuditAction fromString(String? v) =>
      AuditAction.values.firstWhere((a) => a.name == v,
          orElse: () => AuditAction.signIn);
}

class AuditLog {
  final String id;
  final DateTime timestamp;
  final AuditAction action;
  final String? actorId;       // who did it
  final String? actorName;
  final String? actorEmail;
  final String? actorRole;     // role label saat aksi terjadi
  final String? targetType;    // 'user', 'class', 'subject', etc.
  final String? targetId;
  final String? targetLabel;   // human-readable
  final String? deviceLabel;   // 'Chrome di macOS', 'iOS', dst.
  final String? note;          // detail tambahan / pesan error

  const AuditLog({
    required this.id,
    required this.timestamp,
    required this.action,
    this.actorId,
    this.actorName,
    this.actorEmail,
    this.actorRole,
    this.targetType,
    this.targetId,
    this.targetLabel,
    this.deviceLabel,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'action': action.name,
        'actorId': actorId,
        'actorName': actorName,
        'actorEmail': actorEmail,
        'actorRole': actorRole,
        'targetType': targetType,
        'targetId': targetId,
        'targetLabel': targetLabel,
        'deviceLabel': deviceLabel,
        'note': note,
      };

  factory AuditLog.fromMap(String id, Map<String, dynamic> map) {
    return AuditLog(
      id: id,
      timestamp:
          DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
      action: AuditAction.fromString(map['action'] as String?),
      actorId: map['actorId'] as String?,
      actorName: map['actorName'] as String?,
      actorEmail: map['actorEmail'] as String?,
      actorRole: map['actorRole'] as String?,
      targetType: map['targetType'] as String?,
      targetId: map['targetId'] as String?,
      targetLabel: map['targetLabel'] as String?,
      deviceLabel: map['deviceLabel'] as String?,
      note: map['note'] as String?,
    );
  }
}
