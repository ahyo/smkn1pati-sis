import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:uuid/uuid.dart';

import '../models/academic_year.dart';
import '../models/app_user.dart';
import '../models/audit_log.dart';
import '../models/exam.dart';
import '../models/exam_submission.dart';
import '../models/learning_material.dart';
import '../models/payment_bill.dart';
import '../models/payment_category.dart';
import '../models/payment_transaction.dart';
import '../models/school_class.dart';
import '../models/student_attendance.dart';
import '../models/student_enrollment.dart';
import '../models/study_journal.dart';
import '../models/subject.dart';
import '../models/teacher_attendance.dart';
import '../models/teaching_journal.dart';
import '../services/data_service.dart';
import '../services/device/device_info.dart';

class DataProvider extends ChangeNotifier {
  DataProvider(this._service) {
    _subscribe();
  }

  final DataService _service;

  List<AppUser> users = const [];
  List<SchoolClass> classes = const [];
  List<Subject> subjects = const [];
  List<LearningMaterial> materials = const [];
  List<Exam> exams = const [];
  List<ExamSubmission> submissions = const [];
  List<TeachingJournal> teachingJournals = const [];
  List<StudyJournal> studyJournals = const [];
  List<TeacherAttendance> teacherAttendance = const [];
  List<StudentAttendance> studentAttendance = const [];
  List<AuditLog> auditLogs = const [];
  List<StudentEnrollment> enrollments = const [];
  List<PaymentCategory> paymentCategories = const [];
  List<PaymentBill> paymentBills = const [];
  List<PaymentTransaction> paymentTransactions = const [];
  List<AcademicYear> academicYears = const [];

  final List<StreamSubscription<dynamic>> _subs = [];

  void _subscribe() {
    _subs.add(_service.watchUsers().listen((d) {
      users = d;
      notifyListeners();
    }));
    _subs.add(_service.watchClasses().listen((d) {
      classes = d;
      notifyListeners();
    }));
    _subs.add(_service.watchSubjects().listen((d) {
      subjects = d;
      notifyListeners();
    }));
    _subs.add(_service.watchMaterials().listen((d) {
      materials = d;
      notifyListeners();
    }));
    _subs.add(_service.watchExams().listen((d) {
      exams = d;
      notifyListeners();
    }));
    _subs.add(_service.watchSubmissions().listen((d) {
      submissions = d;
      notifyListeners();
    }));
    _subs.add(_service.watchTeachingJournals().listen((d) {
      teachingJournals = d;
      notifyListeners();
    }));
    _subs.add(_service.watchStudyJournals().listen((d) {
      studyJournals = d;
      notifyListeners();
    }));
    _subs.add(_service.watchTeacherAttendance().listen((d) {
      teacherAttendance = d;
      notifyListeners();
    }));
    _subs.add(_service.watchStudentAttendance().listen((d) {
      studentAttendance = d;
      notifyListeners();
    }));
    _subs.add(_service.watchAuditLogs().listen((d) {
      auditLogs = d;
      notifyListeners();
    }));
    _subs.add(_service.watchEnrollments().listen((d) {
      enrollments = d;
      notifyListeners();
    }));
    _subs.add(_service.watchPaymentCategories().listen((d) {
      paymentCategories = d;
      notifyListeners();
    }));
    _subs.add(_service.watchPaymentBills().listen((d) {
      paymentBills = d;
      notifyListeners();
    }));
    _subs.add(_service.watchPaymentTransactions().listen((d) {
      paymentTransactions = d;
      notifyListeners();
    }));
    _subs.add(_service.watchAcademicYears().listen((d) {
      academicYears = d..sort((a, b) => b.name.compareTo(a.name));
      notifyListeners();
    }));
  }

  // Convenience lookups
  AppUser? userById(String id) {
    for (final u in users) {
      if (u.id == id) return u;
    }
    return null;
  }

  SchoolClass? classById(String id) {
    for (final c in classes) {
      if (c.id == id) return c;
    }
    return null;
  }

  Subject? subjectById(String id) {
    for (final s in subjects) {
      if (s.id == id) return s;
    }
    return null;
  }

  Exam? examById(String id) {
    for (final e in exams) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<LearningMaterial> materialsForClass(String classId) =>
      materials.where((m) => m.classId == classId).toList();

  List<Exam> examsForClass(String classId) =>
      exams.where((e) => e.classId == classId).toList();

  List<LearningMaterial> materialsByTeacher(String teacherId) =>
      materials.where((m) => m.teacherId == teacherId).toList();

  List<Exam> examsByTeacher(String teacherId) =>
      exams.where((e) => e.teacherId == teacherId).toList();

  List<ExamSubmission> submissionsByStudent(String studentId) =>
      submissions.where((s) => s.studentId == studentId).toList();

  List<ExamSubmission> submissionsForExam(String examId) =>
      submissions.where((s) => s.examId == examId).toList();

  List<TeachingJournal> teachingJournalsByTeacher(String teacherId) =>
      teachingJournals.where((j) => j.teacherId == teacherId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<TeachingJournal> teachingJournalsForClass(String classId) =>
      teachingJournals.where((j) => j.classId == classId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<StudyJournal> studyJournalsByStudent(String studentId) =>
      studyJournals.where((j) => j.studentId == studentId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<TeacherAttendance> teacherAttendanceForTeacher(String teacherId) =>
      teacherAttendance.where((a) => a.teacherId == teacherId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  TeacherAttendance? teacherAttendanceOnDate(
      String teacherId, DateTime date) {
    final key = TeacherAttendance.dateKey(date);
    for (final a in teacherAttendance) {
      if (a.teacherId == teacherId && a.dateKeyStr == key) return a;
    }
    return null;
  }

  List<StudentAttendance> studentAttendanceForStudent(String studentId) =>
      studentAttendance.where((a) => a.studentId == studentId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<StudentAttendance> studentAttendanceForClassOnDate(
      String classId, DateTime date, {String? subjectId}) {
    final key = StudentAttendance.dateKey(date);
    return studentAttendance
        .where((a) =>
            a.classId == classId &&
            a.dateKeyStr == key &&
            (subjectId == null || a.subjectId == subjectId))
        .toList();
  }

  /// Mata pelajaran yang diajarkan di sebuah kelas (diturunkan dari ujian &
  /// materi yang ditautkan ke kelas tsb), urut berdasarkan nama.
  List<Subject> subjectsForClass(String classId) {
    final ids = <String>{
      ...exams.where((e) => e.classId == classId).map((e) => e.subjectId),
      ...materials.where((m) => m.classId == classId).map((m) => m.subjectId),
    };
    final list = ids
        .map(subjectById)
        .whereType<Subject>()
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// Returns dates (deduped, sorted desc) for which any attendance was
  /// recorded for [classId].
  List<DateTime> classAttendanceSessions(String classId) {
    final keys = <String, DateTime>{};
    for (final a in studentAttendance) {
      if (a.classId == classId) {
        keys.putIfAbsent(a.dateKeyStr,
            () => DateTime(a.date.year, a.date.month, a.date.day));
      }
    }
    final list = keys.values.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  // Mutations delegate to service
  Future<void> upsertUser(AppUser u) => _service.upsertUser(u);
  Future<void> deleteUser(String id) => _service.deleteUser(id);
  Future<void> upsertClass(SchoolClass c) => _service.upsertClass(c);
  Future<void> deleteClass(String id) => _service.deleteClass(id);
  Future<void> upsertSubject(Subject s) => _service.upsertSubject(s);
  Future<void> deleteSubject(String id) => _service.deleteSubject(id);
  Future<void> upsertMaterial(LearningMaterial m) =>
      _service.upsertMaterial(m);
  Future<void> deleteMaterial(String id) => _service.deleteMaterial(id);
  Future<void> upsertExam(Exam e) => _service.upsertExam(e);
  Future<void> deleteExam(String id) => _service.deleteExam(id);
  Future<void> submitExam(ExamSubmission s) => _service.submitExam(s);
  Future<void> upsertTeachingJournal(TeachingJournal j) =>
      _service.upsertTeachingJournal(j);
  Future<void> deleteTeachingJournal(String id) =>
      _service.deleteTeachingJournal(id);
  Future<void> upsertStudyJournal(StudyJournal j) =>
      _service.upsertStudyJournal(j);
  Future<void> deleteStudyJournal(String id) =>
      _service.deleteStudyJournal(id);
  Future<void> upsertTeacherAttendance(TeacherAttendance a) =>
      _service.upsertTeacherAttendance(a);
  Future<void> deleteTeacherAttendance(String id) =>
      _service.deleteTeacherAttendance(id);
  Future<void> upsertStudentAttendance(StudentAttendance a) =>
      _service.upsertStudentAttendance(a);
  Future<void> deleteStudentAttendance(String id) =>
      _service.deleteStudentAttendance(id);
  Future<void> appendAuditLog(AuditLog log) => _service.appendAuditLog(log);
  Future<void> upsertEnrollment(StudentEnrollment e) =>
      _service.upsertEnrollment(e);
  Future<void> deleteEnrollment(String id) => _service.deleteEnrollment(id);

  Future<void> upsertPaymentCategory(PaymentCategory c) =>
      _service.upsertPaymentCategory(c);
  Future<void> deletePaymentCategory(String id) =>
      _service.deletePaymentCategory(id);
  Future<void> upsertPaymentBill(PaymentBill b) =>
      _service.upsertPaymentBill(b);
  Future<void> deletePaymentBill(String id) => _service.deletePaymentBill(id);
  Future<void> upsertPaymentTransaction(PaymentTransaction tx) =>
      _service.upsertPaymentTransaction(tx);
  Future<void> deletePaymentTransaction(String id) =>
      _service.deletePaymentTransaction(id);

  Future<void> upsertAcademicYear(AcademicYear y) =>
      _service.upsertAcademicYear(y);
  Future<void> deleteAcademicYear(String id) =>
      _service.deleteAcademicYear(id);

  AcademicYear? get activeAcademicYear {
    for (final y in academicYears) {
      if (y.isActive) return y;
    }
    return null;
  }

  /// Jalankan proses kenaikan kelas & kelulusan.
  /// [mapping] = { classId_asal → classId_tujuan | null (lulus) }
  Future<void> runClassPromotion({
    required Map<String, String?> mapping,
    required String academicYearId,
    required String adminId,
  }) async {
    final year = academicYears.where((y) => y.id == academicYearId).firstOrNull;
    if (year == null) return;

    for (final entry in mapping.entries) {
      final srcClassId = entry.key;
      final dstClassId = entry.value; // null = lulus
      final srcClass = classById(srcClassId);
      if (srcClass == null) continue;

      // Snapshot list sebelum dimodifikasi
      final studentIds = List<String>.from(srcClass.studentIds);

      for (final studentId in studentIds) {
        final student = userById(studentId);
        if (student == null) continue;

        if (dstClassId == null) {
          // Lulus — hapus classId, catat tahun lulus
          await upsertUser(student.copyWith(
            clearClassId: true,
            graduatedYear: year.name,
          ));
        } else {
          // Naik kelas — pindah ke kelas tujuan
          await upsertUser(student.copyWith(classId: dstClassId));
          // Update roster kelas tujuan (baca ulang agar dapat state terkini)
          final dstClass = classById(dstClassId);
          if (dstClass != null &&
              !dstClass.studentIds.contains(studentId)) {
            await upsertClass(dstClass.copyWith(
              studentIds: [...dstClass.studentIds, studentId],
            ));
          }
        }
      }
      // Kosongkan roster kelas asal setelah semua siswa diproses
      await upsertClass(srcClass.copyWith(studentIds: []));
    }

    // Tandai promotion sudah dijalankan
    await upsertAcademicYear(year.copyWith(
      promotionRunAt: DateTime.now(),
      promotionRunByAdminId: adminId,
    ));
  }

  StudentEnrollment? enrollmentById(String id) {
    for (final e in enrollments) {
      if (e.id == id) return e;
    }
    return null;
  }

  PaymentCategory? paymentCategoryById(String id) {
    for (final c in paymentCategories) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<PaymentBill> billsForStudent(String studentId) =>
      paymentBills.where((b) => b.studentId == studentId).toList()
        ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

  List<PaymentBill> unpaidBillsForStudent(String studentId) =>
      paymentBills
          .where((b) =>
              b.studentId == studentId && b.status != BillStatus.paid)
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<PaymentTransaction> transactionsForBill(String billId) =>
      paymentTransactions.where((t) => t.billId == billId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<PaymentTransaction> transactionsForStudent(String studentId) =>
      paymentTransactions.where((t) => t.studentId == studentId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<PaymentTransaction> get pendingTransactions =>
      paymentTransactions
          .where((t) => t.status == TransactionStatus.pending)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  /// Convenience: catat aksi yang dilakukan [actor] terhadap target tertentu.
  /// Mengisi otomatis id, timestamp, dan deviceLabel.
  Future<void> recordAudit({
    required AppUser actor,
    required AuditAction action,
    String? targetType,
    String? targetId,
    String? targetLabel,
    String? note,
  }) async {
    await _service.appendAuditLog(AuditLog(
      id: 'au_${const Uuid().v4()}',
      timestamp: DateTime.now(),
      action: action,
      actorId: actor.id,
      actorName: actor.name,
      actorEmail: actor.email,
      actorRole: actor.role.label,
      targetType: targetType,
      targetId: targetId,
      targetLabel: targetLabel,
      deviceLabel: describeCurrentDevice(),
      note: note,
    ));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
