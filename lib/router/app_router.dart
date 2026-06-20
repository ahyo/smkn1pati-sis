import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../screens/admin/admin_academic_year_screen.dart';
import '../screens/admin/admin_audit_screen.dart';
import '../screens/admin/admin_class_promotion_screen.dart';
import '../screens/admin/admin_class_editor_screen.dart';
import '../screens/admin/admin_classes_screen.dart';
import '../screens/admin/admin_enrollment_detail_screen.dart';
import '../screens/admin/admin_enrollments_screen.dart';
import '../screens/admin/admin_exam_detail_screen.dart';
import '../screens/admin/admin_exams_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_grades_screen.dart';
import '../screens/admin/admin_payments_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/admin/admin_subject_editor_screen.dart';
import '../screens/admin/admin_subjects_screen.dart';
import '../screens/admin/admin_user_editor_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/enrollment/enrollment_form_screen.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/landing/news_detail_screen.dart';
import '../screens/parent/parent_attendance_screen.dart';
import '../screens/parent/parent_child_detail_screen.dart';
import '../screens/parent/parent_dashboard_screen.dart';
import '../screens/parent/parent_payments_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_attendance_screen.dart';
import '../screens/student/student_exam_runner_screen.dart';
import '../screens/student/student_exams_screen.dart';
import '../screens/student/student_journal_editor_screen.dart';
import '../screens/student/student_journals_screen.dart';
import '../screens/student/student_material_detail_screen.dart';
import '../screens/student/student_materials_screen.dart';
import '../screens/student/student_payments_screen.dart';
import '../screens/student/student_results_screen.dart';
import '../screens/teacher/teacher_attendance_screen.dart';
import '../screens/teacher/teacher_class_attendance_editor_screen.dart';
import '../screens/teacher/teacher_class_attendance_screen.dart';
import '../screens/teacher/teacher_dashboard_screen.dart';
import '../screens/teacher/teacher_exam_editor_screen.dart';
import '../screens/teacher/teacher_grade_submission_screen.dart';
import '../screens/teacher/teacher_exams_screen.dart';
import '../screens/teacher/teacher_journal_editor_screen.dart';
import '../screens/teacher/teacher_journals_screen.dart';
import '../screens/teacher/teacher_material_editor_screen.dart';
import '../screens/teacher/teacher_materials_screen.dart';
import '../screens/teacher/teacher_submissions_screen.dart';

GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    refreshListenable: auth,
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final loc = state.matchedLocation;
      final isPublic = loc == '/' ||
          loc == '/login' ||
          loc == '/register' ||
          loc == '/enroll' ||
          loc.startsWith('/berita');

      if (!loggedIn) {
        // Unauthenticated users may visit any public page.
        return isPublic ? null : '/';
      }
      // Logged-in users are redirected away from public pages to their home.
      if (isPublic) {
        return _homeFor(auth.user!.role);
      }
      // Role guard: prevent users from entering other role areas.
      final role = auth.user!.role;
      if (loc.startsWith('/admin') && role != UserRole.admin) {
        return _homeFor(role);
      }
      if (loc.startsWith('/teacher') && role != UserRole.teacher) {
        return _homeFor(role);
      }
      if (loc.startsWith('/student') && role != UserRole.student) {
        return _homeFor(role);
      }
      if (loc.startsWith('/parent') && role != UserRole.parent) {
        return _homeFor(role);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/enroll',
        builder: (_, __) => const EnrollmentFormScreen(),
      ),
      GoRoute(
        path: '/berita/:id',
        builder: (_, st) =>
            NewsDetailScreen(id: st.pathParameters['id'] ?? ''),
      ),

      // Admin
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'users',
            builder: (_, __) => const AdminUsersScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const AdminUserEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, st) => AdminUserEditorScreen(
                  userId: st.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'classes',
            builder: (_, __) => const AdminClassesScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const AdminClassEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, st) => AdminClassEditorScreen(
                  classId: st.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'subjects',
            builder: (_, __) => const AdminSubjectsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const AdminSubjectEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, st) => AdminSubjectEditorScreen(
                  subjectId: st.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'exams',
            builder: (_, __) => const AdminExamsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, st) => AdminExamDetailScreen(
                  examId: st.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'grades',
            builder: (_, __) => const AdminGradesScreen(),
          ),
          GoRoute(
            path: 'enrollments',
            builder: (_, __) => const AdminEnrollmentsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, st) => AdminEnrollmentDetailScreen(
                  enrollmentId: st.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'payments',
            builder: (_, __) => const AdminPaymentsScreen(),
          ),
          GoRoute(
            path: 'academic-years',
            builder: (_, __) => const AdminAcademicYearScreen(),
            routes: [
              GoRoute(
                path: ':id/promote',
                builder: (_, st) => AdminClassPromotionScreen(
                  academicYearId: st.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'audit',
            builder: (_, __) => const AdminAuditScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (_, __) => const AdminSettingsScreen(),
          ),
        ],
      ),

      // Teacher
      GoRoute(
        path: '/teacher',
        builder: (_, __) => const TeacherDashboardScreen(),
        routes: [
          GoRoute(
            path: 'materials',
            builder: (_, __) => const TeacherMaterialsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const TeacherMaterialEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, st) => TeacherMaterialEditorScreen(
                  materialId: st.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'exams',
            builder: (_, __) => const TeacherExamsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const TeacherExamEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, st) => TeacherExamEditorScreen(
                  examId: st.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: ':id/submissions',
                builder: (_, st) => TeacherSubmissionsScreen(
                  examId: st.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: ':subId',
                    builder: (_, st) => TeacherGradeSubmissionScreen(
                      examId: st.pathParameters['id']!,
                      submissionId: st.pathParameters['subId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'journals',
            builder: (_, __) => const TeacherJournalsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const TeacherJournalEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, st) => TeacherJournalEditorScreen(
                  journalId: st.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'attendance',
            builder: (_, __) => const TeacherAttendanceScreen(),
          ),
          GoRoute(
            path: 'class-attendance',
            builder: (_, __) => const TeacherClassAttendanceScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, st) {
                  final classId = st.uri.queryParameters['classId'];
                  final dateStr = st.uri.queryParameters['date'];
                  final date = dateStr == null ? null : DateTime.tryParse(dateStr);
                  return TeacherClassAttendanceEditorScreen(
                    classId: classId,
                    date: date,
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Student
      GoRoute(
        path: '/student',
        builder: (_, __) => const StudentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'materials',
            builder: (_, __) => const StudentMaterialsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, st) => StudentMaterialDetailScreen(
                  materialId: st.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'exams',
            builder: (_, __) => const StudentExamsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, st) => StudentExamRunnerScreen(
                  examId: st.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'results',
            builder: (_, __) => const StudentResultsScreen(),
          ),
          GoRoute(
            path: 'journals',
            builder: (_, __) => const StudentJournalsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const StudentJournalEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, st) => StudentJournalEditorScreen(
                  journalId: st.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'attendance',
            builder: (_, __) => const StudentAttendanceScreen(),
          ),
          GoRoute(
            path: 'payments',
            builder: (_, __) => const StudentPaymentsScreen(),
          ),
        ],
      ),

      // Parent
      GoRoute(
        path: '/parent',
        builder: (_, __) => const ParentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'children/:id',
            builder: (_, st) => ParentChildDetailScreen(
              childId: st.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'attendance',
            builder: (_, st) => ParentAttendanceScreen(
              initialChildId: st.uri.queryParameters['child'],
            ),
          ),
          GoRoute(
            path: 'payments',
            builder: (_, __) => const ParentPaymentsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => _ErrorScreen(message: state.error?.toString()),
    debugLogDiagnostics: kDebugMode,
  );
}

String _homeFor(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.teacher:
      return '/teacher';
    case UserRole.student:
      return '/student';
    case UserRole.parent:
      return '/parent';
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Halaman tidak ditemukan: ${message ?? ''}'));
  }
}
