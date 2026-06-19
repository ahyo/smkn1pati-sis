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

abstract class DataService {
  Stream<List<AppUser>> watchUsers();
  Stream<List<SchoolClass>> watchClasses();
  Stream<List<Subject>> watchSubjects();
  Stream<List<LearningMaterial>> watchMaterials();
  Stream<List<Exam>> watchExams();
  Stream<List<ExamSubmission>> watchSubmissions();
  Stream<List<TeachingJournal>> watchTeachingJournals();
  Stream<List<StudyJournal>> watchStudyJournals();

  Future<void> upsertUser(AppUser user);
  Future<void> deleteUser(String id);

  Future<void> upsertClass(SchoolClass cls);
  Future<void> deleteClass(String id);

  Future<void> upsertSubject(Subject subject);
  Future<void> deleteSubject(String id);

  Future<void> upsertMaterial(LearningMaterial material);
  Future<void> deleteMaterial(String id);

  Future<void> upsertExam(Exam exam);
  Future<void> deleteExam(String id);

  Future<void> submitExam(ExamSubmission submission);

  Future<void> upsertTeachingJournal(TeachingJournal journal);
  Future<void> deleteTeachingJournal(String id);

  Future<void> upsertStudyJournal(StudyJournal journal);
  Future<void> deleteStudyJournal(String id);

  Stream<List<TeacherAttendance>> watchTeacherAttendance();
  Future<void> upsertTeacherAttendance(TeacherAttendance attendance);
  Future<void> deleteTeacherAttendance(String id);

  Stream<List<StudentAttendance>> watchStudentAttendance();
  Future<void> upsertStudentAttendance(StudentAttendance attendance);
  Future<void> deleteStudentAttendance(String id);

  Stream<List<AuditLog>> watchAuditLogs();
  Future<void> appendAuditLog(AuditLog log);

  Stream<List<StudentEnrollment>> watchEnrollments();
  Future<void> upsertEnrollment(StudentEnrollment enrollment);
  Future<void> deleteEnrollment(String id);

  Stream<List<PaymentCategory>> watchPaymentCategories();
  Future<void> upsertPaymentCategory(PaymentCategory category);
  Future<void> deletePaymentCategory(String id);

  Stream<List<PaymentBill>> watchPaymentBills();
  Future<void> upsertPaymentBill(PaymentBill bill);
  Future<void> deletePaymentBill(String id);

  Stream<List<PaymentTransaction>> watchPaymentTransactions();
  Future<void> upsertPaymentTransaction(PaymentTransaction tx);
  Future<void> deletePaymentTransaction(String id);

  Stream<List<AcademicYear>> watchAcademicYears();
  Future<void> upsertAcademicYear(AcademicYear year);
  Future<void> deleteAcademicYear(String id);
}
