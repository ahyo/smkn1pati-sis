import 'dart:async';

import '../../models/academic_year.dart';
import '../../models/app_user.dart';
import '../../models/audit_log.dart';
import '../../models/exam.dart';
import '../../models/exam_submission.dart';
import '../../models/learning_material.dart';
import '../../models/payment_bill.dart';
import '../../models/payment_category.dart';
import '../../models/payment_transaction.dart';
import '../../models/school_class.dart';
import '../../models/student_attendance.dart';
import '../../models/student_enrollment.dart';
import '../../models/study_journal.dart';
import '../../models/subject.dart';
import '../../models/teacher_attendance.dart';
import '../../models/teaching_journal.dart';
import '../data_service.dart';
import 'api_client.dart';

/// Implementasi [DataService] berbasis HTTP terhadap backend FastAPI.
///
/// Karena REST tidak realtime, setiap `watch*` didukung oleh polling berkala
/// (default 8 detik). Setiap mutasi (`upsert`/`delete`) memicu penyegaran
/// langsung pada koleksi terkait sehingga UI cepat sinkron.
class ApiDataService implements DataService {
  ApiDataService(
    this._api, {
    Duration pollInterval = const Duration(seconds: 8),
  }) {
    _timer = Timer.periodic(pollInterval, (_) => _refreshAll());
  }

  final ApiClient _api;
  late final Timer _timer;

  final Map<String, StreamController<List<dynamic>>> _ctrls = {};
  final Map<String, Object Function(Map<String, dynamic>)> _parsers = {};

  // ── Infrastruktur polling generik ──────────────────────────────────────────

  Stream<List<T>> _watch<T>(
    String collection,
    T Function(String id, Map<String, dynamic> map) fromMap,
  ) {
    final ctrl = _ctrls.putIfAbsent(collection, () {
      _parsers[collection] =
          (m) => fromMap(m['id'] as String, m) as Object;
      return StreamController<List<dynamic>>.broadcast(
        onListen: () => _refresh(collection),
      );
    });
    return ctrl.stream.map((list) => list.cast<T>());
  }

  Future<void> _refresh(String collection) async {
    final ctrl = _ctrls[collection];
    final parser = _parsers[collection];
    if (ctrl == null || parser == null || ctrl.isClosed) return;
    try {
      final data = await _api.get('/api/$collection') as List<dynamic>;
      final items = data
          .map((e) => parser(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (!ctrl.isClosed) ctrl.add(items);
    } catch (_) {
      // Pertahankan data terakhir saat gangguan jaringan sesaat.
    }
  }

  void _refreshAll() {
    for (final c in _ctrls.keys.toList()) {
      _refresh(c);
    }
  }

  Future<void> _upsert(String collection, String id, Map<String, dynamic> map) async {
    await _api.put('/api/$collection/$id', map);
    await _refresh(collection);
  }

  Future<void> _delete(String collection, String id) async {
    await _api.delete('/api/$collection/$id');
    await _refresh(collection);
  }

  void dispose() {
    _timer.cancel();
    for (final c in _ctrls.values) {
      c.close();
    }
  }

  // ── Users ───────────────────────────────────────────────────────────────
  @override
  Stream<List<AppUser>> watchUsers() => _watch('users', AppUser.fromMap);
  @override
  Future<void> upsertUser(AppUser user) => _upsert('users', user.id, user.toMap());
  @override
  Future<void> deleteUser(String id) => _delete('users', id);

  // ── Classes ───────────────────────────────────────────────────────────────
  @override
  Stream<List<SchoolClass>> watchClasses() => _watch('classes', SchoolClass.fromMap);
  @override
  Future<void> upsertClass(SchoolClass cls) => _upsert('classes', cls.id, cls.toMap());
  @override
  Future<void> deleteClass(String id) => _delete('classes', id);

  // ── Subjects ───────────────────────────────────────────────────────────────
  @override
  Stream<List<Subject>> watchSubjects() => _watch('subjects', Subject.fromMap);
  @override
  Future<void> upsertSubject(Subject subject) => _upsert('subjects', subject.id, subject.toMap());
  @override
  Future<void> deleteSubject(String id) => _delete('subjects', id);

  // ── Materials ───────────────────────────────────────────────────────────────
  @override
  Stream<List<LearningMaterial>> watchMaterials() => _watch('materials', LearningMaterial.fromMap);
  @override
  Future<void> upsertMaterial(LearningMaterial material) => _upsert('materials', material.id, material.toMap());
  @override
  Future<void> deleteMaterial(String id) => _delete('materials', id);

  // ── Exams ───────────────────────────────────────────────────────────────
  @override
  Stream<List<Exam>> watchExams() => _watch('exams', Exam.fromMap);
  @override
  Future<void> upsertExam(Exam exam) => _upsert('exams', exam.id, exam.toMap());
  @override
  Future<void> deleteExam(String id) => _delete('exams', id);

  // ── Submissions ───────────────────────────────────────────────────────────────
  @override
  Stream<List<ExamSubmission>> watchSubmissions() => _watch('submissions', ExamSubmission.fromMap);
  @override
  Future<void> submitExam(ExamSubmission submission) => _upsert('submissions', submission.id, submission.toMap());

  // ── Teaching journals ──────────────────────────────────────────────────────
  @override
  Stream<List<TeachingJournal>> watchTeachingJournals() => _watch('teachingJournals', TeachingJournal.fromMap);
  @override
  Future<void> upsertTeachingJournal(TeachingJournal journal) => _upsert('teachingJournals', journal.id, journal.toMap());
  @override
  Future<void> deleteTeachingJournal(String id) => _delete('teachingJournals', id);

  // ── Study journals ──────────────────────────────────────────────────────
  @override
  Stream<List<StudyJournal>> watchStudyJournals() => _watch('studyJournals', StudyJournal.fromMap);
  @override
  Future<void> upsertStudyJournal(StudyJournal journal) => _upsert('studyJournals', journal.id, journal.toMap());
  @override
  Future<void> deleteStudyJournal(String id) => _delete('studyJournals', id);

  // ── Teacher attendance ──────────────────────────────────────────────────────
  @override
  Stream<List<TeacherAttendance>> watchTeacherAttendance() => _watch('teacherAttendance', TeacherAttendance.fromMap);
  @override
  Future<void> upsertTeacherAttendance(TeacherAttendance attendance) => _upsert('teacherAttendance', attendance.id, attendance.toMap());
  @override
  Future<void> deleteTeacherAttendance(String id) => _delete('teacherAttendance', id);

  // ── Student attendance ──────────────────────────────────────────────────────
  @override
  Stream<List<StudentAttendance>> watchStudentAttendance() => _watch('studentAttendance', StudentAttendance.fromMap);
  @override
  Future<void> upsertStudentAttendance(StudentAttendance attendance) => _upsert('studentAttendance', attendance.id, attendance.toMap());
  @override
  Future<void> deleteStudentAttendance(String id) => _delete('studentAttendance', id);

  // ── Audit logs ──────────────────────────────────────────────────────
  @override
  Stream<List<AuditLog>> watchAuditLogs() => _watch('auditLogs', AuditLog.fromMap);
  @override
  Future<void> appendAuditLog(AuditLog log) => _upsert('auditLogs', log.id, log.toMap());

  // ── Enrollments ──────────────────────────────────────────────────────
  @override
  Stream<List<StudentEnrollment>> watchEnrollments() => _watch('enrollments', StudentEnrollment.fromMap);
  @override
  Future<void> upsertEnrollment(StudentEnrollment enrollment) => _upsert('enrollments', enrollment.id, enrollment.toMap());
  @override
  Future<void> deleteEnrollment(String id) => _delete('enrollments', id);

  // ── Payment categories ──────────────────────────────────────────────────────
  @override
  Stream<List<PaymentCategory>> watchPaymentCategories() => _watch('paymentCategories', PaymentCategory.fromMap);
  @override
  Future<void> upsertPaymentCategory(PaymentCategory category) => _upsert('paymentCategories', category.id, category.toMap());
  @override
  Future<void> deletePaymentCategory(String id) => _delete('paymentCategories', id);

  // ── Payment bills ──────────────────────────────────────────────────────
  @override
  Stream<List<PaymentBill>> watchPaymentBills() => _watch('paymentBills', PaymentBill.fromMap);
  @override
  Future<void> upsertPaymentBill(PaymentBill bill) => _upsert('paymentBills', bill.id, bill.toMap());
  @override
  Future<void> deletePaymentBill(String id) => _delete('paymentBills', id);

  // ── Payment transactions ──────────────────────────────────────────────────────
  @override
  Stream<List<PaymentTransaction>> watchPaymentTransactions() => _watch('paymentTransactions', PaymentTransaction.fromMap);
  @override
  Future<void> upsertPaymentTransaction(PaymentTransaction tx) => _upsert('paymentTransactions', tx.id, tx.toMap());
  @override
  Future<void> deletePaymentTransaction(String id) => _delete('paymentTransactions', id);

  // ── Academic years ──────────────────────────────────────────────────────
  @override
  Stream<List<AcademicYear>> watchAcademicYears() => _watch('academicYears', AcademicYear.fromMap);
  @override
  Future<void> upsertAcademicYear(AcademicYear year) => _upsert('academicYears', year.id, year.toMap());
  @override
  Future<void> deleteAcademicYear(String id) => _delete('academicYears', id);
}
