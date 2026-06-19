import 'package:flutter/material.dart';

enum AttendanceStatus {
  hadir,
  terlambat,
  izin,
  sakit,
  alpa;

  String get label {
    switch (this) {
      case AttendanceStatus.hadir:
        return 'Hadir';
      case AttendanceStatus.terlambat:
        return 'Terlambat';
      case AttendanceStatus.izin:
        return 'Izin';
      case AttendanceStatus.sakit:
        return 'Sakit';
      case AttendanceStatus.alpa:
        return 'Alpa';
    }
  }

  String get short {
    switch (this) {
      case AttendanceStatus.hadir:
        return 'H';
      case AttendanceStatus.terlambat:
        return 'T';
      case AttendanceStatus.izin:
        return 'I';
      case AttendanceStatus.sakit:
        return 'S';
      case AttendanceStatus.alpa:
        return 'A';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.hadir:
        return const Color(0xFF15803D); // green-700
      case AttendanceStatus.terlambat:
        return const Color(0xFFB45309); // amber-700
      case AttendanceStatus.izin:
        return const Color(0xFF1D4ED8); // blue-700
      case AttendanceStatus.sakit:
        return const Color(0xFF7E22CE); // purple-700
      case AttendanceStatus.alpa:
        return const Color(0xFFB91C1C); // red-700
    }
  }

  static AttendanceStatus fromString(String? value) {
    return AttendanceStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => AttendanceStatus.hadir,
    );
  }
}
