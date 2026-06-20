import 'package:flutter/material.dart';

import '../models/user_role.dart';

class NavItem {
  const NavItem({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}

List<NavItem> navItemsFor(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return const [
        NavItem(
            path: '/admin', label: 'Dashboard', icon: Icons.dashboard_outlined),
        NavItem(
            path: '/admin/users',
            label: 'Pengguna',
            icon: Icons.people_outline),
        NavItem(
            path: '/admin/classes', label: 'Kelas', icon: Icons.class_outlined),
        NavItem(
            path: '/admin/subjects',
            label: 'Mata Pelajaran',
            icon: Icons.menu_book_outlined),
        NavItem(
            path: '/admin/exams',
            label: 'Pantau Ujian',
            icon: Icons.quiz_outlined),
        NavItem(
            path: '/admin/grades',
            label: 'Nilai Siswa',
            icon: Icons.assessment_outlined),
        NavItem(
            path: '/admin/enrollments',
            label: 'Pendaftaran',
            icon: Icons.assignment_ind_outlined),
        NavItem(
            path: '/admin/payments',
            label: 'Pembayaran',
            icon: Icons.payments_outlined),
        NavItem(
            path: '/admin/academic-years',
            label: 'Tahun Ajaran',
            icon: Icons.calendar_today_outlined),
        NavItem(
            path: '/admin/audit',
            label: 'Audit Trail',
            icon: Icons.history),
        NavItem(
            path: '/admin/settings',
            label: 'Pengaturan',
            icon: Icons.settings_outlined),
      ];
    case UserRole.teacher:
      return const [
        NavItem(
            path: '/teacher',
            label: 'Dashboard',
            icon: Icons.dashboard_outlined),
        NavItem(
            path: '/teacher/materials',
            label: 'Materi',
            icon: Icons.menu_book_outlined),
        NavItem(
            path: '/teacher/exams', label: 'Ujian', icon: Icons.quiz_outlined),
        NavItem(
            path: '/teacher/journals',
            label: 'Jurnal Mengajar',
            icon: Icons.event_note_outlined),
        NavItem(
            path: '/teacher/attendance',
            label: 'Presensi Saya',
            icon: Icons.event_available_outlined),
        NavItem(
            path: '/teacher/class-attendance',
            label: 'Presensi Siswa',
            icon: Icons.fact_check_outlined),
      ];
    case UserRole.student:
      return const [
        NavItem(
            path: '/student',
            label: 'Dashboard',
            icon: Icons.dashboard_outlined),
        NavItem(
            path: '/student/materials',
            label: 'Materi',
            icon: Icons.menu_book_outlined),
        NavItem(
            path: '/student/exams', label: 'Ujian', icon: Icons.quiz_outlined),
        NavItem(
            path: '/student/results',
            label: 'Hasil',
            icon: Icons.assessment_outlined),
        NavItem(
            path: '/student/journals',
            label: 'Jurnal Belajar',
            icon: Icons.book_outlined),
        NavItem(
            path: '/student/attendance',
            label: 'Presensi',
            icon: Icons.event_available_outlined),
        NavItem(
            path: '/student/payments',
            label: 'Pembayaran',
            icon: Icons.payments_outlined),
      ];
    case UserRole.parent:
      return const [
        NavItem(
            path: '/parent',
            label: 'Dashboard',
            icon: Icons.dashboard_outlined),
        NavItem(
            path: '/parent/attendance',
            label: 'Presensi Anak',
            icon: Icons.event_available_outlined),
        NavItem(
            path: '/parent/payments',
            label: 'Pembayaran',
            icon: Icons.payments_outlined),
      ];
  }
}

/// Returns the index of the nav item that "owns" [currentLocation]
/// (longest prefix match). -1 when none match.
int activeNavIndex(List<NavItem> items, String currentLocation) {
  int bestIdx = -1;
  int bestLen = -1;
  for (var i = 0; i < items.length; i++) {
    final p = items[i].path;
    if (currentLocation == p ||
        currentLocation.startsWith('$p/') ||
        currentLocation == p) {
      if (p.length > bestLen) {
        bestLen = p.length;
        bestIdx = i;
      }
    }
  }
  return bestIdx;
}
