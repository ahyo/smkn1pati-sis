import '../../models/academic_year.dart';
import '../../models/app_user.dart';
import '../../models/exam.dart';
import '../../models/exam_submission.dart';
import '../../models/audit_log.dart';
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
import 'mock_store.dart';

class MockDataService implements DataService {
  final _store = MockStore.instance;

  @override
  Stream<List<AppUser>> watchUsers() => _store.usersStream;

  @override
  Stream<List<SchoolClass>> watchClasses() => _store.classesStream;

  @override
  Stream<List<Subject>> watchSubjects() => _store.subjectsStream;

  @override
  Stream<List<LearningMaterial>> watchMaterials() => _store.materialsStream;

  @override
  Stream<List<Exam>> watchExams() => _store.examsStream;

  @override
  Stream<List<ExamSubmission>> watchSubmissions() => _store.submissionsStream;

  @override
  Future<void> upsertUser(AppUser user) async {
    _store.users[user.id] = user;
    _store.notifyUsers();
  }

  @override
  Future<void> deleteUser(String id) async {
    _store.users.remove(id);
    _store.notifyUsers();
  }

  @override
  Future<void> upsertClass(SchoolClass cls) async {
    _store.classes[cls.id] = cls;
    _store.notifyClasses();
  }

  @override
  Future<void> deleteClass(String id) async {
    _store.classes.remove(id);
    _store.notifyClasses();
  }

  @override
  Future<void> upsertSubject(Subject subject) async {
    _store.subjects[subject.id] = subject;
    _store.notifySubjects();
  }

  @override
  Future<void> deleteSubject(String id) async {
    _store.subjects.remove(id);
    _store.notifySubjects();
  }

  @override
  Future<void> upsertMaterial(LearningMaterial material) async {
    _store.materials[material.id] = material;
    _store.notifyMaterials();
  }

  @override
  Future<void> deleteMaterial(String id) async {
    _store.materials.remove(id);
    _store.notifyMaterials();
  }

  @override
  Future<void> upsertExam(Exam exam) async {
    _store.exams[exam.id] = exam;
    _store.notifyExams();
  }

  @override
  Future<void> deleteExam(String id) async {
    _store.exams.remove(id);
    _store.notifyExams();
  }

  @override
  Future<void> submitExam(ExamSubmission submission) async {
    _store.submissions[submission.id] = submission;
    _store.notifySubmissions();
  }

  @override
  Stream<List<TeachingJournal>> watchTeachingJournals() =>
      _store.teachingJournalsStream;

  @override
  Stream<List<StudyJournal>> watchStudyJournals() =>
      _store.studyJournalsStream;

  @override
  Future<void> upsertTeachingJournal(TeachingJournal journal) async {
    _store.teachingJournals[journal.id] = journal;
    _store.notifyTeachingJournals();
  }

  @override
  Future<void> deleteTeachingJournal(String id) async {
    _store.teachingJournals.remove(id);
    _store.notifyTeachingJournals();
  }

  @override
  Future<void> upsertStudyJournal(StudyJournal journal) async {
    _store.studyJournals[journal.id] = journal;
    _store.notifyStudyJournals();
  }

  @override
  Future<void> deleteStudyJournal(String id) async {
    _store.studyJournals.remove(id);
    _store.notifyStudyJournals();
  }

  @override
  Stream<List<TeacherAttendance>> watchTeacherAttendance() =>
      _store.teacherAttendanceStream;

  @override
  Future<void> upsertTeacherAttendance(TeacherAttendance attendance) async {
    _store.teacherAttendance[attendance.id] = attendance;
    _store.notifyTeacherAttendance();
  }

  @override
  Future<void> deleteTeacherAttendance(String id) async {
    _store.teacherAttendance.remove(id);
    _store.notifyTeacherAttendance();
  }

  @override
  Stream<List<StudentAttendance>> watchStudentAttendance() =>
      _store.studentAttendanceStream;

  @override
  Future<void> upsertStudentAttendance(StudentAttendance attendance) async {
    _store.studentAttendance[attendance.id] = attendance;
    _store.notifyStudentAttendance();
  }

  @override
  Future<void> deleteStudentAttendance(String id) async {
    _store.studentAttendance.remove(id);
    _store.notifyStudentAttendance();
  }

  @override
  Stream<List<AuditLog>> watchAuditLogs() => _store.auditLogsStream;

  @override
  Future<void> appendAuditLog(AuditLog log) async {
    _store.auditLogs[log.id] = log;
    _store.notifyAuditLogs();
  }

  @override
  Stream<List<StudentEnrollment>> watchEnrollments() =>
      _store.enrollmentsStream;

  @override
  Future<void> upsertEnrollment(StudentEnrollment enrollment) async {
    _store.enrollments[enrollment.id] = enrollment;
    _store.notifyEnrollments();
  }

  @override
  Future<void> deleteEnrollment(String id) async {
    _store.enrollments.remove(id);
    _store.notifyEnrollments();
  }

  @override
  Stream<List<PaymentCategory>> watchPaymentCategories() =>
      _store.paymentCategoriesStream;

  @override
  Future<void> upsertPaymentCategory(PaymentCategory category) async {
    _store.paymentCategories[category.id] = category;
    _store.notifyPaymentCategories();
  }

  @override
  Future<void> deletePaymentCategory(String id) async {
    _store.paymentCategories.remove(id);
    _store.notifyPaymentCategories();
  }

  @override
  Stream<List<PaymentBill>> watchPaymentBills() => _store.paymentBillsStream;

  @override
  Future<void> upsertPaymentBill(PaymentBill bill) async {
    _store.paymentBills[bill.id] = bill;
    _store.notifyPaymentBills();
  }

  @override
  Future<void> deletePaymentBill(String id) async {
    _store.paymentBills.remove(id);
    _store.notifyPaymentBills();
  }

  @override
  Stream<List<PaymentTransaction>> watchPaymentTransactions() =>
      _store.paymentTransactionsStream;

  @override
  Future<void> upsertPaymentTransaction(PaymentTransaction tx) async {
    _store.paymentTransactions[tx.id] = tx;
    _store.notifyPaymentTransactions();
  }

  @override
  Future<void> deletePaymentTransaction(String id) async {
    _store.paymentTransactions.remove(id);
    _store.notifyPaymentTransactions();
  }

  @override
  Stream<List<AcademicYear>> watchAcademicYears() =>
      _store.academicYearsStream;

  @override
  Future<void> upsertAcademicYear(AcademicYear year) async {
    _store.academicYears[year.id] = year;
    _store.notifyAcademicYears();
  }

  @override
  Future<void> deleteAcademicYear(String id) async {
    _store.academicYears.remove(id);
    _store.notifyAcademicYears();
  }
}
