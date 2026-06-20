import 'dart:async';
import 'dart:math';

import '../../models/app_user.dart';
import '../../models/attendance_status.dart';
import '../../models/audit_log.dart';
import '../../models/enrollment_status.dart';
import '../../models/enrollment_type.dart';
import '../../models/exam.dart';
import '../../models/exam_submission.dart';
import '../../models/learning_material.dart';
import '../../models/academic_year.dart';
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
import '../../models/user_role.dart';

/// Singleton in-memory store. Seed data shared between mock auth and mock
/// data services so the demo experience is consistent.
class MockStore {
  MockStore._() {
    _seed();
  }

  static final MockStore instance = MockStore._();

  // email -> password
  final Map<String, String> credentials = {};

  final Map<String, AppUser> users = {};
  final Map<String, SchoolClass> classes = {};
  final Map<String, Subject> subjects = {};
  final Map<String, LearningMaterial> materials = {};
  final Map<String, Exam> exams = {};
  final Map<String, ExamSubmission> submissions = {};
  final Map<String, TeachingJournal> teachingJournals = {};
  final Map<String, StudyJournal> studyJournals = {};
  final Map<String, TeacherAttendance> teacherAttendance = {};
  final Map<String, StudentAttendance> studentAttendance = {};
  final Map<String, AuditLog> auditLogs = {};
  final Map<String, StudentEnrollment> enrollments = {};
  final Map<String, PaymentCategory> paymentCategories = {};
  final Map<String, PaymentBill> paymentBills = {};
  final Map<String, PaymentTransaction> paymentTransactions = {};
  final Map<String, AcademicYear> academicYears = {};

  final StreamController<List<AppUser>> _usersCtrl =
      StreamController.broadcast();
  final StreamController<List<SchoolClass>> _classesCtrl =
      StreamController.broadcast();
  final StreamController<List<Subject>> _subjectsCtrl =
      StreamController.broadcast();
  final StreamController<List<LearningMaterial>> _materialsCtrl =
      StreamController.broadcast();
  final StreamController<List<Exam>> _examsCtrl = StreamController.broadcast();
  final StreamController<List<ExamSubmission>> _submissionsCtrl =
      StreamController.broadcast();
  final StreamController<List<TeachingJournal>> _teachingJournalsCtrl =
      StreamController.broadcast();
  final StreamController<List<StudyJournal>> _studyJournalsCtrl =
      StreamController.broadcast();
  final StreamController<List<TeacherAttendance>> _teacherAttendanceCtrl =
      StreamController.broadcast();
  final StreamController<List<StudentAttendance>> _studentAttendanceCtrl =
      StreamController.broadcast();
  final StreamController<List<AuditLog>> _auditLogsCtrl =
      StreamController.broadcast();
  final StreamController<List<StudentEnrollment>> _enrollmentsCtrl =
      StreamController.broadcast();
  final StreamController<List<PaymentCategory>> _paymentCategoriesCtrl =
      StreamController.broadcast();
  final StreamController<List<PaymentBill>> _paymentBillsCtrl =
      StreamController.broadcast();
  final StreamController<List<PaymentTransaction>> _paymentTransactionsCtrl =
      StreamController.broadcast();
  final StreamController<List<AcademicYear>> _academicYearsCtrl =
      StreamController.broadcast();

  Stream<List<AppUser>> get usersStream =>
      _withInitial(_usersCtrl.stream, () => users.values.toList());
  Stream<List<SchoolClass>> get classesStream =>
      _withInitial(_classesCtrl.stream, () => classes.values.toList());
  Stream<List<Subject>> get subjectsStream =>
      _withInitial(_subjectsCtrl.stream, () => subjects.values.toList());
  Stream<List<LearningMaterial>> get materialsStream =>
      _withInitial(_materialsCtrl.stream, () => materials.values.toList());
  Stream<List<Exam>> get examsStream =>
      _withInitial(_examsCtrl.stream, () => exams.values.toList());
  Stream<List<ExamSubmission>> get submissionsStream =>
      _withInitial(_submissionsCtrl.stream, () => submissions.values.toList());
  Stream<List<TeachingJournal>> get teachingJournalsStream => _withInitial(
    _teachingJournalsCtrl.stream,
    () => teachingJournals.values.toList(),
  );
  Stream<List<StudyJournal>> get studyJournalsStream => _withInitial(
    _studyJournalsCtrl.stream,
    () => studyJournals.values.toList(),
  );
  Stream<List<TeacherAttendance>> get teacherAttendanceStream => _withInitial(
    _teacherAttendanceCtrl.stream,
    () => teacherAttendance.values.toList(),
  );
  Stream<List<StudentAttendance>> get studentAttendanceStream => _withInitial(
    _studentAttendanceCtrl.stream,
    () => studentAttendance.values.toList(),
  );
  Stream<List<AuditLog>> get auditLogsStream =>
      _withInitial(_auditLogsCtrl.stream, () => auditLogs.values.toList());
  Stream<List<StudentEnrollment>> get enrollmentsStream => _withInitial(
        _enrollmentsCtrl.stream,
        () => enrollments.values.toList(),
      );
  Stream<List<PaymentCategory>> get paymentCategoriesStream => _withInitial(
        _paymentCategoriesCtrl.stream,
        () => paymentCategories.values.toList(),
      );
  Stream<List<PaymentBill>> get paymentBillsStream => _withInitial(
        _paymentBillsCtrl.stream,
        () => paymentBills.values.toList(),
      );
  Stream<List<PaymentTransaction>> get paymentTransactionsStream => _withInitial(
        _paymentTransactionsCtrl.stream,
        () => paymentTransactions.values.toList(),
      );
  Stream<List<AcademicYear>> get academicYearsStream => _withInitial(
        _academicYearsCtrl.stream,
        () => academicYears.values.toList(),
      );

  Stream<T> _withInitial<T>(Stream<T> source, T Function() initial) async* {
    yield initial();
    yield* source;
  }

  void notifyUsers() => _usersCtrl.add(users.values.toList());
  void notifyClasses() => _classesCtrl.add(classes.values.toList());
  void notifySubjects() => _subjectsCtrl.add(subjects.values.toList());
  void notifyMaterials() => _materialsCtrl.add(materials.values.toList());
  void notifyExams() => _examsCtrl.add(exams.values.toList());
  void notifySubmissions() => _submissionsCtrl.add(submissions.values.toList());
  void notifyTeachingJournals() =>
      _teachingJournalsCtrl.add(teachingJournals.values.toList());
  void notifyStudyJournals() =>
      _studyJournalsCtrl.add(studyJournals.values.toList());
  void notifyTeacherAttendance() =>
      _teacherAttendanceCtrl.add(teacherAttendance.values.toList());
  void notifyStudentAttendance() =>
      _studentAttendanceCtrl.add(studentAttendance.values.toList());
  void notifyAuditLogs() => _auditLogsCtrl.add(auditLogs.values.toList());
  void notifyEnrollments() =>
      _enrollmentsCtrl.add(enrollments.values.toList());
  void notifyPaymentCategories() =>
      _paymentCategoriesCtrl.add(paymentCategories.values.toList());
  void notifyPaymentBills() =>
      _paymentBillsCtrl.add(paymentBills.values.toList());
  void notifyPaymentTransactions() =>
      _paymentTransactionsCtrl.add(paymentTransactions.values.toList());
  void notifyAcademicYears() =>
      _academicYearsCtrl.add(academicYears.values.toList());

  // Heuristik sederhana untuk demo: kategori gender berdasar nama depan
  // (akun nyata sebaiknya diisi sendiri lewat halaman edit profil).
  static const _femaleNameHints = {
    'Citra',
    'Eka',
    'Hana',
    'Jihan',
    'Lina',
    'Nabila',
    'Putri',
    'Rahma',
    'Tiara',
    'Vina',
    'Xena',
    'Zahra',
    'Bella',
    'Dina',
    'Fitri',
    'Hanin',
    'Jovita',
    'Linda',
    'Nia',
  };

  bool _isFemaleByFirstName(String fullName) {
    final first = fullName.trim().split(' ').first;
    return _femaleNameHints.contains(first);
  }

  static const _otomotifAsatQuestions = <ExamQuestion>[
    ExamQuestion(
      id: '',
      prompt: 'Urutan langkah kerja mesin 4 tak yang benar adalah ...',
      options: [
        'Hisap - Usaha - Kompresi - Buang',
        'Hisap - Kompresi - Usaha - Buang',
        'Kompresi - Hisap - Usaha - Buang',
        'Buang - Hisap - Kompresi - Usaha',
        'Buang - Hisap - Kompresi - Usaha - Tekanan',
      ],
      correctIndex: 1,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Mesin 2 tak tidak menggunakan katup, tetapi menggunakan ...',
      options: [
        'Noken as',
        'Membran',
        'Port/lubang masuk dan buang',
        'Push rod',
        'Piston',
      ],
      correctIndex: 2,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Mesin 4 tak melumasi mesin dengan cara ...',
      options: [
        'Oli dicampur bensin',
        'Oli disemprotkan dari karburator',
        'Oli tersimpan di bak mesin',
        'Tanpa oli',
        'Oli disemprotkan dari bak oli',
      ],
      correctIndex: 2,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Keuntungan mesin 2 tak dibanding mesin 4 tak adalah ...',
      options: [
        'Lebih irit bahan bakar',
        'Lebih ramah lingkungan',
        'Tenaga lebih besar pada kapasitas sama',
        'Lebih awet',
        'Murah harganya',
      ],
      correctIndex: 2,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Tujuan utama balancing roda adalah ...',
      options: [
        'Menambah kecepatan mobil',
        'Mengurangi getaran saat berkendara',
        'Memperbesar traksi ban',
        'Menghemat oli mesin',
        'Menghemat bahan bakar',
      ],
      correctIndex: 1,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Velg bengkok akan menyebabkan ...',
      options: [
        'Hasil balancing tidak akurat',
        'Balancing lebih cepat',
        'Mesin rusak',
        'Ban tidak bisa dipompa',
        'Mobil tidak bisa jalan',
      ],
      correctIndex: 0,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Jika hasil balancing sering berubah, kemungkinan penyebabnya adalah ...',
      options: [
        'Oli habis',
        'Mesin panas',
        'Rem aus',
        'Ban atau velg rusak',
        'Bahan bakar habis',
      ],
      correctIndex: 3,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Balancing yang menyeimbangkan roda secara vertikal dan horizontal disebut ...',
      options: [
        'Static balancing',
        'Wheel alignment',
        'Manual balancing',
        'Spooring',
        'Dynamic balancing',
      ],
      correctIndex: 4,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Komponen utama engine yang berfungsi sebagai tempat gerak piston adalah ...',
      options: [
        'Cylinder block',
        'Cylinder head',
        'Crankshaft',
        'Camshaft',
        'Manifold',
      ],
      correctIndex: 0,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Fungsi utama piston adalah ...',
      options: [
        'Mengatur campuran udara dan bahan bakar',
        'Mengubah energi panas menjadi energi mekanik',
        'Menyimpan oli mesin',
        'Mengatur timing katup',
        'Menyemprotkan bahan bakar',
      ],
      correctIndex: 1,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Gasket kepala silinder berfungsi untuk ...',
      options: [
        'Menyaring oli',
        'Mengatur tekanan bahan bakar',
        'Menyimpan air radiator',
        'Menyimpan air pendingin',
        'Mencegah kebocoran antara block dan head',
      ],
      correctIndex: 4,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Salah satu faktor penting dalam ruang bakar adalah turbulensi, yang berfungsi untuk ...',
      options: [
        'Mengurangi suara mesin',
        'Mencampur udara dan bahan bakar lebih baik',
        'Menghemat oli',
        'Mendinginkan mesin',
        'Menghasilkan turbulensi',
      ],
      correctIndex: 1,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Komponen utama yang membentuk ruang bakar adalah ...',
      options: [
        'Piston, kepala silinder, dan dinding silinder',
        'Karburator dan radiator',
        'Rantai dan gir',
        'Kopling dan transmisi',
        'Gasket',
      ],
      correctIndex: 0,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Salah satu tanda adanya kerak karbon di ruang bakar adalah ...',
      options: [
        'Ban bocor',
        'Oli bertambah',
        'Mesin knocking',
        'Lampu redup',
        'Udara masuk tanpa filter',
      ],
      correctIndex: 2,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Sebuah mobil bensin menunjukkan hasil gas analyzer: CO tinggi, HC tinggi, CO2 rendah. Penyebab paling mungkin adalah ...',
      options: [
        'Campuran terlalu kurus',
        'Sensor O2 rusak (campuran terlalu miskin)',
        'Kompresi terlalu tinggi',
        'Pembakaran tidak sempurna',
        'Terlalu panas',
      ],
      correctIndex: 3,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Katalitik converter berfungsi untuk ...',
      options: [
        'Menambah tenaga',
        'Menyaring udara masuk',
        'Menambah bahan bakar',
        'Membuat mesin mati secara otomatis',
        'Mengurangi emisi gas berbahaya',
      ],
      correctIndex: 4,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Fungsi utama sensor O2 adalah ...',
      options: [
        'Mengontrol campuran udara-bahan bakar',
        'Mengukur suhu',
        'Mengukur tekanan',
        'Menghidupkan mesin',
        'Isi bahan bakar',
      ],
      correctIndex: 0,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Fungsi utama baterai pada mobil adalah ...',
      options: [
        'Menyimpan bahan bakar',
        'Menyuplai energi listrik saat mesin mati dan starter',
        'Menggerakkan roda',
        'Mendinginkan mesin',
        'Menghidupkan elektrical mobil',
      ],
      correctIndex: 1,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt: 'Jika berat jenis elektrolit rendah, maka kondisi aki ...',
      options: [
        'Penuh',
        'Normal',
        'Kosong / lemah',
        'Agak kering',
        'Terlalu panas',
      ],
      correctIndex: 2,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Sebuah aki menunjukkan tegangan 12 V saat mesin mati, tetapi turun menjadi 9 V saat starter. Analisis yang tepat adalah ...',
      options: [
        'Aki normal',
        'Alternator rusak',
        'Starter rusak',
        'Aki lemah / drop saat beban',
        'Radiator bocor',
      ],
      correctIndex: 3,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Perhatikan pernyataan berikut tentang mesin 4 tak!\n'
          '1. Memiliki langkah hisap, kompresi, usaha, dan buang.\n'
          '2. Dalam satu siklus kerja memerlukan dua putaran poros engkol.\n'
          '3. Campuran bahan bakar dan oli berada dalam satu ruang.\n'
          '4. Gas buang keluar setiap satu kali putaran poros engkol.\n'
          'Pernyataan yang benar adalah ...',
      options: ['1 dan 2', '1 dan 3', '2 dan 4', '3 dan 4', '1 dan 4'],
      correctIndex: 0,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Perhatikan ciri-ciri berikut!\n'
          '1. Tenaga lebih besar untuk kapasitas mesin yang sama.\n'
          '2. Konsumsi bahan bakar lebih irit.\n'
          '3. Menggunakan oli samping.\n'
          '4. Emisi gas buang lebih ramah lingkungan.\n'
          'Ciri khas mesin 2 tak ditunjukkan oleh nomor ...',
      options: ['1 dan 2', '1 dan 3', '2 dan 4', '3 dan 4', '1 dan 4'],
      correctIndex: 1,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Perhatikan pernyataan berikut tentang balancing roda mobil!\n'
          '1. Balancing bertujuan menyeimbangkan putaran roda.\n'
          '2. Balancing dapat mengurangi getaran saat kendaraan berjalan.\n'
          '3. Balancing dilakukan dengan mengatur tekanan oli mesin.\n'
          '4. Balancing membantu memperpanjang umur ban.\n'
          'Pernyataan yang benar adalah ...',
      options: ['1 dan 3', '2 dan 3', '1, 2, dan 4', '1 dan 4', '3 dan 4'],
      correctIndex: 2,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Balancing roda sebaiknya dilakukan ketika ...\n'
          '1. Setelah mengganti ban baru.\n'
          '2. Setelah roda menghantam lubang keras.\n'
          '3. Kendaraan mengalami getaran saat melaju.\n'
          '4. Mengganti oli mesin.\n'
          'Pernyataan yang benar adalah ...',
      options: ['1 dan 4', '2 dan 4', '3 dan 4', '1, 2, dan 3', '3 dan 1'],
      correctIndex: 3,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.multipleChoiceComplex,
      prompt: 'Tanda ruang bakar mengalami kerak karbon berlebih adalah ...',
      options: [
        'Warna hitam pekat',
        'Mesin knocking',
        'Tenaga menurun',
        'Tekanan ban berkurang',
        'Pembakaran lebih cepat',
      ],
      correctIndexes: [0, 1, 2],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.multipleChoiceComplex,
      prompt: 'Komponen yang membentuk ruang bakar meliputi ...',
      options: [
        'Kepala silinder',
        'Piston',
        'Dinding silinder',
        'Karburator',
        'Radiator',
      ],
      correctIndexes: [0, 1, 2],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Tujuan penggunaan gas analyzer pada bengkel otomotif adalah ...\n'
          '1. Memastikan emisi kendaraan sesuai standar.\n'
          '2. Membantu penyetelan mesin agar optimal.\n'
          '3. Mengurangi pencemaran udara.\n'
          '4. Mengukur ketebalan kampas rem.\n'
          'Pernyataan yang benar adalah ...',
      options: ['1 dan 4', '2 dan 3', '1, 2, dan 3', '3 dan 4', '1 dan 3'],
      correctIndex: 2,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Perhatikan langkah penggunaan gas analyzer berikut!\n'
          '1. Mesin kendaraan dipanaskan terlebih dahulu.\n'
          '2. Probe alat dimasukkan ke knalpot kendaraan.\n'
          '3. Mesin kendaraan harus dimatikan selama pengukuran.\n'
          '4. Hasil emisi dibaca pada layar alat.\n'
          'Pernyataan yang benar adalah ...',
      options: ['1 dan 4', '3 dan 4', '2 dan 3', '1 dan 3', '1, 2, dan 4'],
      correctIndex: 4,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Komponen utama dalam baterai mobil adalah ...\n'
          '1. Elektrolit.\n2. Pelat positif dan negatif.\n'
          '3. Separator.\n4. Radiator pendingin.\n'
          'Pernyataan yang benar adalah ...',
      options: ['1 dan 2', '2 dan 3', '2 dan 4', '1, 2, dan 3', '3 dan 4'],
      correctIndex: 3,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      prompt:
          'Penyebab baterai mobil cepat soak adalah ...\n'
          '1. Sistem pengisian kendaraan bermasalah.\n'
          '2. Kendaraan jarang digunakan.\n'
          '3. Beban kelistrikan berlebihan.\n'
          '4. Tekanan angin ban terlalu tinggi.\n'
          'Pernyataan yang benar adalah ...',
      options: ['1 dan 3', '1, 2, dan 3', '2 dan 4', '3 dan 4', '1 dan 4'],
      correctIndex: 1,
      points: 2,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.trueFalse,
      prompt:
          'Komponen yang mengatur buka tutup katup pada mesin 4 tak adalah ...',
      options: ['Piston', 'Noken as (camshaft)'],
      trueFalseAnswers: [false, true],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.trueFalse,
      prompt: 'Mesin 2 tak menghasilkan suara lebih bising karena ...',
      options: ['Proses pembakaran lebih sering', 'Putaran rendah'],
      trueFalseAnswers: [true, false],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.trueFalse,
      prompt: 'Alat yang digunakan untuk balancing roda mobil adalah ...',
      options: ['Dongkrak', 'Kompresor'],
      trueFalseAnswers: [false, false],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.trueFalse,
      prompt: 'Balancing roda berhubungan langsung dengan ...',
      options: ['Putaran roda', 'Putaran mesin'],
      trueFalseAnswers: [true, false],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.trueFalse,
      prompt: 'Fungsi utama ruang bakar pada motor bakar adalah ...',
      options: [
        'Tempat terjadinya pembakaran campuran udara dan bahan bakar',
        'Mengubah energi panas menjadi energi mekanik',
      ],
      trueFalseAnswers: [true, true],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.trueFalse,
      prompt: 'Identifikasi ruang bakar dapat dilakukan melalui ...',
      options: ['Nomor polisi kendaraan', 'Volume bahan bakar'],
      trueFalseAnswers: [false, false],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.trueFalse,
      prompt: 'Sistem EGR berfungsi untuk ...',
      options: ['Menurunkan NOx', 'Mengurangi HC'],
      trueFalseAnswers: [true, false],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.trueFalse,
      prompt: 'Jika lambda < 1, maka ...',
      options: ['Campuran miskin', 'Campuran kaya'],
      trueFalseAnswers: [false, true],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.trueFalse,
      prompt: 'Tegangan satu sel aki timbal-asam adalah sekitar ...',
      options: ['2 volt', '12 volt'],
      trueFalseAnswers: [true, false],
      points: 4,
    ),
    ExamQuestion(
      id: '',
      type: QuestionType.trueFalse,
      prompt: 'Komponen yang bertugas mengisi aki saat mesin hidup adalah ...',
      options: ['Starter', 'Radiator'],
      trueFalseAnswers: [false, false],
      points: 4,
    ),
  ];

  void _seed() {
    final now = DateTime.now();
    final rand = Random(42); // deterministic seed for reproducibility

    DateTime dayOnly(DateTime d, int offsetDays) {
      final t = d.subtract(Duration(days: offsetDays));
      return DateTime(t.year, t.month, t.day);
    }

    // ============================== Admin ==============================
    final admin = AppUser(
      id: 'u_admin',
      email: 'admin@sekolah.id',
      name: 'Hari Wibowo',
      role: UserRole.admin,
      phone: '0812-3456-7890',
      address: 'Jl. Pendidikan No. 12, Yogyakarta',
      gender: 'Laki-laki',
      dateOfBirth: DateTime(1985, 4, 12),
      identityNumber: '198504122010011001',
      bio: 'Kepala administrasi sistem LMS Sekolah.',
      createdAt: now,
    );
    users[admin.id] = admin;
    credentials[admin.email] = 'password';

    // ============================== Subjects ==============================
    const subjectsList = <Subject>[
      Subject(
        id: 's_math',
        name: 'Matematika',
        code: 'MTK',
        description: 'Mata pelajaran matematika',
      ),
      Subject(
        id: 's_indo',
        name: 'Bahasa Indonesia',
        code: 'BIN',
        description: 'Mata pelajaran Bahasa Indonesia',
      ),
      Subject(
        id: 's_ipa',
        name: 'IPA',
        code: 'IPA',
        description: 'Ilmu Pengetahuan Alam',
      ),
      Subject(
        id: 's_ips',
        name: 'IPS',
        code: 'IPS',
        description: 'Ilmu Pengetahuan Sosial',
      ),
      Subject(
        id: 's_eng',
        name: 'Bahasa Inggris',
        code: 'BIG',
        description: 'Mata pelajaran Bahasa Inggris',
      ),
      Subject(
        id: 's_pjok',
        name: 'PJOK',
        code: 'PJK',
        description: 'Pendidikan Jasmani, Olahraga & Kesehatan',
      ),
      Subject(
        id: 's_otomotif',
        name: 'Dasar-Dasar Teknik Otomotif',
        code: 'DTO',
        description: 'Mata pelajaran dasar-dasar teknik otomotif',
      ),
    ];
    for (final s in subjectsList) {
      subjects[s.id] = s;
    }

    // ============================== Teachers ==============================
    // (id, email, name, subjectId)
    final teachersData = <(String, String, String, String)>[
      ('u_teacher', 'guru@sekolah.id', 'Bu Sari Indriani', 's_math'),
      ('t_andi', 'andi@sekolah.id', 'Pak Andi Wibowo', 's_indo'),
      ('t_rina', 'rina@sekolah.id', 'Bu Rina Hartono', 's_ipa'),
      ('t_hadi', 'hadi@sekolah.id', 'Pak Hadi Pranoto', 's_ips'),
      ('t_maya', 'maya@sekolah.id', 'Bu Maya Lestari', 's_eng'),
      ('t_joko', 'joko@sekolah.id', 'Pak Joko Susilo', 's_pjok'),
    ];
    for (final t in teachersData) {
      final u = AppUser(
        id: t.$1,
        email: t.$2,
        name: t.$3,
        role: UserRole.teacher,
        subjectIds: [t.$4],
        phone: '0813-${1000 + rand.nextInt(9000)}-${1000 + rand.nextInt(9000)}',
        gender: t.$3.startsWith('Bu') ? 'Perempuan' : 'Laki-laki',
        identityNumber:
            '19${70 + rand.nextInt(15)}${(rand.nextInt(11) + 1).toString().padLeft(2, '0')}${(rand.nextInt(28) + 1).toString().padLeft(2, '0')}2010012${rand.nextInt(900) + 100}',
        createdAt: now,
      );
      users[u.id] = u;
      credentials[u.email] = 'password';
    }
    final teacherBySubject = {for (final t in teachersData) t.$4: t.$1};

    // Override demo teacher (Bu Sari) with full profile data.
    users['u_teacher'] = AppUser(
      id: 'u_teacher',
      email: 'guru@sekolah.id',
      name: 'Bu Sari Indriani',
      role: UserRole.teacher,
      subjectIds: ['s_math'],
      phone: '0812-3456-7891',
      address: 'Jl. Melati No. 8, Yogyakarta',
      gender: 'Perempuan',
      dateOfBirth: DateTime(1980, 8, 17),
      identityNumber: '198008172005012001',
      bio:
          'Wali kelas 10A sekaligus guru Matematika SMA. '
          'Menyukai pendekatan interaktif berbasis masalah.',
      createdAt: now,
    );

    // ============================== Classes (SMA) ==============================
    // (id, name, grade, homeroomTeacherId)
    final classesData = <(String, String, String, String)>[
      ('c_10a', '10A', '10', 'u_teacher'),
      ('c_10b', '10B', '10', 't_andi'),
      ('c_11a', '11A', '11', 't_rina'),
      ('c_12a', '12A', '12', 't_hadi'),
    ];
    final classOrder = classesData.map((c) => c.$1).toList();
    final gradeByClass = {
      for (final c in classesData) c.$1: int.tryParse(c.$3) ?? 10,
    };

    // ============================== Students ==============================
    const studentNames = <String>[
      // 10A — student 0 is the demo Andi
      'Andi Saputra', 'Budi Hartono', 'Citra Dewi Lestari', 'Dimas Pratama',
      'Eka Putri Anggraini', 'Farhan Nugroho', 'Galih Santoso', 'Hana Permata',
      'Indra Maulana', 'Jihan Aulia',
      // 10B
      'Kemal Aditya', 'Lina Marlina', 'Maulana Rizky', 'Nabila Salsabila',
      'Oka Pranata', 'Putri Ramadhani', 'Qori Hidayat', 'Rahma Dewi',
      'Surya Pradana', 'Tiara Anggreini',
      // 11A
      'Umar Faruq', 'Vina Aprilia', 'Wahyu Hidayat', 'Xena Maharani',
      'Yusuf Mansyur', 'Zahra Fadhila', 'Arief Rahman', 'Bella Sintia',
      'Candra Wijaya', 'Dina Sartika',
      // 12A
      'Erlangga Putra', 'Fitri Handayani', 'Gilang Ramadhan', 'Hanin Nabila',
      'Ilham Akbar', 'Jovita Aulia', 'Kresna Adi', 'Linda Marpaung',
      'Mahesa Yudha', 'Nia Ramadhanti',
    ];

    final studentIdsByClass = <String, List<String>>{
      for (final c in classOrder) c: <String>[],
    };
    for (var i = 0; i < studentNames.length; i++) {
      final classId = classOrder[i ~/ 10];
      final isDemo = i == 0;
      final id = isDemo ? 'u_student' : 's_$i';
      final email = isDemo ? 'siswa@sekolah.id' : 'siswa$i@sekolah.id';
      final isFemaleByName = _isFemaleByFirstName(studentNames[i]);
      // SMA: kelas 10 ~16 tahun (lahir 2010), 11 ~17 (2009), 12 ~18 (2008)
      final birthYear = 2020 - (gradeByClass[classId] ?? 10);
      final u = AppUser(
        id: id,
        email: email,
        name: studentNames[i],
        role: UserRole.student,
        classId: classId,
        phone: '0856-${1000 + rand.nextInt(9000)}-${1000 + rand.nextInt(9000)}',
        gender: isFemaleByName ? 'Perempuan' : 'Laki-laki',
        dateOfBirth: DateTime(
          birthYear,
          rand.nextInt(12) + 1,
          rand.nextInt(28) + 1,
        ),
        identityNumber:
            '${(2000 + rand.nextInt(900)).toString().padLeft(4, '0')}${i.toString().padLeft(4, '0')}',
        createdAt: now,
      );
      users[u.id] = u;
      credentials[u.email] = 'password';
      studentIdsByClass[classId]!.add(u.id);
    }

    // Override demo student (Andi) with full profile data.
    users['u_student'] = AppUser(
      id: 'u_student',
      email: 'siswa@sekolah.id',
      name: 'Andi Saputra',
      role: UserRole.student,
      classId: 'c_10a',
      phone: '0856-1111-2222',
      address: 'Jl. Anggrek No. 5, Yogyakarta',
      gender: 'Laki-laki',
      dateOfBirth: DateTime(2010, 6, 15),
      identityNumber: '20100001',
      bio: 'Siswa kelas 10A, suka matematika dan bercita-cita jadi insinyur.',
      createdAt: now,
    );

    // Insert classes (with full student rosters now known)
    for (final c in classesData) {
      classes[c.$1] = SchoolClass(
        id: c.$1,
        name: c.$2,
        gradeLevel: c.$3,
        homeroomTeacherId: c.$4,
        studentIds: studentIdsByClass[c.$1]!,
      );
    }

    // ============================== Parents ==============================
    // (id, email, name, [child student ids])
    final parentsData = <(String, String, String, List<String>)>[
      ('u_parent', 'ortu@sekolah.id', 'Pak Budi Saputra', ['u_student']),
      ('p_1', 'ortu1@sekolah.id', 'Bu Yanti Hartono', ['s_1']),
      ('p_2', 'ortu2@sekolah.id', 'Pak Joko Lestari', ['s_2']),
      ('p_3', 'ortu3@sekolah.id', 'Bu Lina Pratama', ['s_3']),
      // Bu Wati punya dua anak (Eka di 7A, Xena di 8A)
      ('p_4', 'ortu4@sekolah.id', 'Bu Wati Anggraini', ['s_4', 's_23']),
      ('p_5', 'ortu5@sekolah.id', 'Bu Sri Maulana', ['s_8']),
      ('p_6', 'ortu6@sekolah.id', 'Pak Hartono Aditya', ['s_10']),
      // Bu Maria punya dua anak (Qori di 7B, Ilham di 8B)
      ('p_7', 'ortu7@sekolah.id', 'Bu Maria Hidayat', ['s_16', 's_34']),
      ('p_8', 'ortu8@sekolah.id', 'Pak Bambang Faruq', ['s_20']),
      ('p_9', 'ortu9@sekolah.id', 'Bu Ratna Putra', ['s_30']),
    ];
    for (final p in parentsData) {
      final u = AppUser(
        id: p.$1,
        email: p.$2,
        name: p.$3,
        role: UserRole.parent,
        childrenIds: p.$4,
        phone: '0815-${1000 + rand.nextInt(9000)}-${1000 + rand.nextInt(9000)}',
        gender: p.$3.startsWith('Bu') ? 'Perempuan' : 'Laki-laki',
        identityNumber:
            '34${(rand.nextInt(90) + 10)}${(rand.nextInt(90) + 10)}${(rand.nextInt(900000) + 100000)}',
        createdAt: now,
      );
      users[u.id] = u;
      credentials[u.email] = 'password';
    }

    // Override demo parent (Pak Budi) with full profile data.
    users['u_parent'] = AppUser(
      id: 'u_parent',
      email: 'ortu@sekolah.id',
      name: 'Pak Budi Saputra',
      role: UserRole.parent,
      childrenIds: ['u_student'],
      phone: '0815-9999-8888',
      address: 'Jl. Anggrek No. 5, Yogyakarta',
      gender: 'Laki-laki',
      dateOfBirth: DateTime(1980, 3, 20),
      identityNumber: '3471190303800001',
      bio: 'Ayah dari Andi Saputra. Bekerja sebagai wiraswasta.',
      createdAt: now,
    );

    // ============================== Materials ==============================
    // (subjectId, title, content)
    final materialsData = <(String, String, String)>[
      (
        's_math',
        'Persamaan Linear Satu Variabel',
        'Persamaan linear satu variabel berbentuk ax + b = 0, dengan a ≠ 0. '
            'Penyelesaiannya dilakukan dengan operasi aljabar untuk mengisolasi '
            'variabel x. Contoh: 2x + 5 = 13 ⇒ 2x = 8 ⇒ x = 4.',
      ),
      (
        's_math',
        'Persamaan Kuadrat',
        'Persamaan kuadrat berbentuk ax² + bx + c = 0 (a ≠ 0). Tiga metode utama '
            'penyelesaian: pemfaktoran, melengkapkan kuadrat sempurna, dan rumus abc. '
            'Diskriminan D = b² − 4ac menentukan jumlah & jenis akar.',
      ),
      (
        's_indo',
        'Teks Eksposisi',
        'Teks eksposisi adalah teks yang berisi gagasan, pendapat, atau pendirian '
            'penulis disertai argumen dan fakta. Strukturnya: tesis — argumentasi — '
            'penegasan ulang.',
      ),
      (
        's_indo',
        'Hikayat',
        'Hikayat adalah salah satu bentuk prosa lama Melayu yang umumnya '
            'mengisahkan kehidupan keluarga istana, kepahlawanan, atau cerita yang '
            'mengandung unsur kemustahilan dan kesaktian.',
      ),
      (
        's_ipa',
        'Klasifikasi Makhluk Hidup',
        'Klasifikasi makhluk hidup adalah pengelompokan makhluk hidup '
            'berdasarkan persamaan dan perbedaan ciri-cirinya.',
      ),
      (
        's_ipa',
        'Tata Surya',
        'Tata surya terdiri dari Matahari sebagai pusat dan delapan planet '
            'yang mengelilinginya: Merkurius, Venus, Bumi, Mars, Yupiter, Saturnus, Uranus, Neptunus.',
      ),
      (
        's_ips',
        'Letak Geografis Indonesia',
        'Indonesia terletak di antara dua benua (Asia & Australia) dan dua '
            'samudra (Hindia & Pasifik), serta di garis khatulistiwa.',
      ),
      (
        's_eng',
        'Descriptive Text',
        'A descriptive text describes a particular person, place, or thing in '
            'detail. Its structure consists of identification (general statement) '
            'and description (specific details). Common features: present tense, '
            'adjectives, sensory language.',
      ),
      (
        's_pjok',
        'Permainan Bola Voli',
        'Bola voli adalah permainan beregu yang dimainkan oleh dua tim dengan '
            'masing-masing 6 pemain. Tujuannya adalah menjatuhkan bola di area lawan.',
      ),
    ];
    for (var i = 0; i < materialsData.length; i++) {
      final m = materialsData[i];
      final classId = classOrder[i % classOrder.length];
      materials['m_$i'] = LearningMaterial(
        id: 'm_$i',
        title: m.$2,
        content: m.$3,
        subjectId: m.$1,
        classId: classId,
        teacherId: teacherBySubject[m.$1]!,
        createdAt: dayOnly(now, 10 + i),
      );
    }

    // ============================== Exams ==============================
    // Per-subject question templates (id will be regenerated per exam)
    final questionTemplates = <String, List<ExamQuestion>>{
      's_math': const [
        ExamQuestion(
          id: '',
          prompt: 'Nilai x dari persamaan 2x + 5 = 13 adalah ...',
          options: ['3', '4', '5', '6'],
          correctIndex: 1,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Diskriminan dari persamaan x² − 4x + 3 = 0 adalah ...',
          options: ['1', '2', '4', '16'],
          correctIndex: 2,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Nilai sin 30° adalah ...',
          options: ['0', '1/2', '√2 / 2', '√3 / 2'],
          correctIndex: 1,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Hasil dari log₁₀ 100 adalah ...',
          options: ['1', '2', '10', '100'],
          correctIndex: 1,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Median dari data 3, 5, 7, 9, 11 adalah ...',
          options: ['5', '6', '7', '9'],
          correctIndex: 2,
        ),
        ExamQuestion(
          id: '',
          type: QuestionType.essay,
          prompt:
              'Tentukan akar-akar persamaan kuadrat x² − 5x + 6 = 0 menggunakan metode pemfaktoran. Tuliskan langkah-langkahnya.',
          sampleAnswer:
              'x² − 5x + 6 = 0\n'
              '⇒ Cari dua bilangan yang hasil kalinya = 6 dan jumlahnya = −5, '
              'yaitu −2 dan −3.\n'
              '⇒ (x − 2)(x − 3) = 0\n'
              '⇒ x − 2 = 0 atau x − 3 = 0\n'
              '⇒ x₁ = 2 atau x₂ = 3.\n'
              'Jadi akar-akarnya adalah x = 2 dan x = 3.',
          points: 20,
        ),
      ],
      's_indo': const [
        ExamQuestion(
          id: '',
          prompt: 'Hikayat termasuk dalam jenis prosa ...',
          options: ['modern', 'lama', 'fabel', 'naratif baru'],
          correctIndex: 1,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Ciri utama teks anekdot adalah ...',
          options: [
            'bersifat humoris dan menyindir',
            'panjang dan rinci',
            'berbentuk syair',
            'berdasarkan data ilmiah',
          ],
          correctIndex: 0,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Tujuan utama teks negosiasi adalah ...',
          options: [
            'memenangkan satu pihak',
            'mencapai kesepakatan bersama',
            'menghibur pendengar',
            'menyampaikan informasi sepihak',
          ],
          correctIndex: 1,
        ),
        ExamQuestion(
          id: '',
          prompt:
              'Paragraf yang berisi pendapat penulis disertai bukti dan alasan disebut ...',
          options: ['narasi', 'deskripsi', 'eksposisi', 'argumentasi'],
          correctIndex: 3,
        ),
        ExamQuestion(
          id: '',
          type: QuestionType.essay,
          prompt:
              'Tulislah satu paragraf teks eksposisi singkat (3-5 kalimat) dengan tema "Pentingnya Pendidikan Karakter di Sekolah".',
          sampleAnswer:
              'Contoh paragraf eksposisi:\n'
              'Pendidikan karakter merupakan bagian penting dalam pendidikan formal '
              'di sekolah. Tidak hanya mengasah kemampuan akademik, sekolah juga '
              'bertanggung jawab membentuk pribadi siswa yang jujur, disiplin, dan '
              'bertanggung jawab. Karakter yang baik akan menjadi pondasi kuat bagi '
              'siswa dalam menghadapi tantangan di masa depan.\n\n'
              'Penilaian: gagasan jelas (tesis di awal), didukung argumen, ditutup '
              'simpulan/penegasan ulang.',
          points: 20,
        ),
      ],
      's_ipa': const [
        ExamQuestion(
          id: '',
          prompt: 'Tumbuhan menghasilkan oksigen melalui proses ...',
          options: ['fotosintesis', 'respirasi', 'pencernaan', 'transpirasi'],
          correctIndex: 0,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Planet terdekat dari Matahari adalah ...',
          options: ['Venus', 'Mars', 'Merkurius', 'Bumi'],
          correctIndex: 2,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Air membeku pada suhu ...',
          options: ['0°C', '100°C', '25°C', '-10°C'],
          correctIndex: 0,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Sumber utama energi makhluk hidup adalah ...',
          options: ['air', 'tanah', 'matahari', 'bulan'],
          correctIndex: 2,
        ),
        ExamQuestion(
          id: '',
          type: QuestionType.essay,
          prompt: 'Sebutkan dan jelaskan tiga tahap utama dalam siklus air!',
          sampleAnswer:
              'Tiga tahap utama siklus air:\n'
              '1. Evaporasi — penguapan air dari permukaan laut, sungai, dan danau menjadi uap karena panas matahari.\n'
              '2. Kondensasi — uap air berubah menjadi titik-titik air membentuk awan saat naik ke atmosfer dan mendingin.\n'
              '3. Presipitasi — jatuhnya air dari awan ke permukaan bumi dalam bentuk hujan, salju, atau es.',
          points: 20,
        ),
      ],
      's_ips': const [
        ExamQuestion(
          id: '',
          prompt: 'Indonesia terletak di antara dua benua, yaitu ...',
          options: [
            'Asia & Eropa',
            'Asia & Australia',
            'Eropa & Afrika',
            'Asia & Amerika',
          ],
          correctIndex: 1,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Ibu kota Indonesia adalah ...',
          options: ['Bandung', 'Jakarta', 'Surabaya', 'Yogyakarta'],
          correctIndex: 1,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Pulau terbesar di Indonesia adalah ...',
          options: ['Jawa', 'Sumatra', 'Kalimantan', 'Sulawesi'],
          correctIndex: 2,
        ),
        ExamQuestion(
          id: '',
          prompt: 'Mata uang Indonesia adalah ...',
          options: ['Ringgit', 'Rupee', 'Rupiah', 'Peso'],
          correctIndex: 2,
        ),
        ExamQuestion(
          id: '',
          type: QuestionType.essay,
          prompt:
              'Jelaskan dampak positif dan negatif letak geografis Indonesia bagi kehidupan masyarakatnya!',
          sampleAnswer:
              'Dampak positif:\n'
              '- Tanah subur karena banyak gunung berapi.\n'
              '- Kekayaan hayati laut karena diapit dua samudra.\n'
              '- Posisi strategis sebagai jalur perdagangan dunia.\n\n'
              'Dampak negatif:\n'
              '- Rawan bencana (gempa, tsunami, gunung meletus).\n'
              '- Curah hujan tinggi yang dapat menyebabkan banjir & longsor.\n'
              '- Kerentanan terhadap perubahan iklim.',
          points: 20,
        ),
      ],
    };

    // Build 1 exam per (subject, class) for the 4 main subjects = 16 exams.
    final examSubjects = ['s_math', 's_indo', 's_ipa', 's_ips'];
    var examIdx = 0;
    for (final subjectId in examSubjects) {
      final teacherId = teacherBySubject[subjectId]!;
      final templates = questionTemplates[subjectId]!;
      for (final classId in classOrder) {
        final cls = classes[classId]!;
        final subject = subjects[subjectId]!;
        final examId = 'e_$examIdx';
        final questions = [
          for (var i = 0; i < templates.length; i++)
            ExamQuestion(
              id: '${examId}_q$i',
              type: templates[i].type,
              prompt: templates[i].prompt,
              options: templates[i].options,
              correctIndex: templates[i].correctIndex,
              correctIndexes: templates[i].correctIndexes,
              trueFalseAnswers: templates[i].trueFalseAnswers,
              sampleAnswer: templates[i].sampleAnswer,
              points: templates[i].points,
            ),
        ];
        // Stagger schedule: started a few days ago, ends in the future.
        final startAt = dayOnly(now, 7 - (examIdx % 7));
        final endAt = now.add(Duration(days: 7 + (examIdx % 7)));
        exams[examId] = Exam(
          id: examId,
          title: 'Ulangan ${subject.name} ${cls.name}',
          description:
              'Ulangan harian materi ${subject.name} kelas ${cls.name}',
          subjectId: subjectId,
          classId: classId,
          teacherId: teacherId,
          durationMinutes: 30,
          startAt: startAt,
          endAt: endAt,
          questions: questions,
        );
        examIdx++;
      }
    }

    // ============================== Submissions ==============================
    // For every exam, ~75% of class students submit with realistic score
    // distribution: 40% high (70-100%), 35% mid (50-69%), 25% low (20-49%).
    for (final exam in exams.values.toList()) {
      final cls = classes[exam.classId];
      if (cls == null) continue;
      for (final studentId in cls.studentIds) {
        if (rand.nextDouble() > 0.75) continue; // some students didn't submit

        final dist = rand.nextDouble();
        final double targetPercent;
        if (dist < 0.40) {
          targetPercent = 70 + rand.nextInt(31).toDouble(); // 70-100
        } else if (dist < 0.75) {
          targetPercent = 50 + rand.nextInt(20).toDouble(); // 50-69
        } else {
          targetPercent = 20 + rand.nextInt(30).toDouble(); // 20-49
        }
        final mcQs = exam.questions
            .where((q) => q.isMultipleChoice)
            .toList(growable: false);
        final essayQs = exam.questions
            .where((q) => q.isEssay)
            .toList(growable: false);

        // MC answers — `targetPercent` of them correct.
        final mcAnswers = <String, int>{};
        final mcCorrectCount = (targetPercent / 100 * mcQs.length)
            .round()
            .clamp(0, mcQs.length);
        final mcIdx = List.generate(mcQs.length, (i) => i)..shuffle(rand);
        final mcCorrectSet = mcIdx.take(mcCorrectCount).toSet();
        for (var i = 0; i < mcQs.length; i++) {
          final q = mcQs[i];
          if (mcCorrectSet.contains(i)) {
            mcAnswers[q.id] = q.correctIndex;
          } else {
            var wrong = rand.nextInt(q.options.length);
            if (wrong == q.correctIndex) {
              wrong = (wrong + 1) % q.options.length;
            }
            mcAnswers[q.id] = wrong;
          }
        }

        // Essay: tulis jawaban + (kadang) sudah dinilai oleh guru (60% chance).
        final essayAnswers = <String, String>{};
        final essayScores = <String, int>{};
        final essayFeedback = <String, String>{};
        const essayResponses = [
          'Menurut saya, materi ini berhubungan dengan kehidupan sehari-hari. '
              'Saya sudah memahami konsepnya dan dapat memberikan beberapa contoh.',
          'Saya menjelaskan jawaban berdasarkan apa yang dipelajari di kelas. '
              'Beberapa poin penting sudah saya cantumkan dalam jawaban ini.',
          'Berdasarkan materi yang saya pelajari, jawabannya seperti yang saya '
              'tulis di atas. Mohon koreksi jika ada yang kurang tepat.',
        ];
        for (final q in essayQs) {
          essayAnswers[q.id] =
              essayResponses[rand.nextInt(essayResponses.length)];
          if (rand.nextDouble() < 0.6) {
            // sudah dinilai
            final ratio = (targetPercent / 100).clamp(0.0, 1.0);
            // sedikit jitter agar nilai bervariasi
            final jitter = (rand.nextDouble() - 0.5) * 0.2;
            final pct = (ratio + jitter).clamp(0.0, 1.0);
            essayScores[q.id] = (pct * q.points).round();
            if (rand.nextBool()) {
              essayFeedback[q.id] = pct > 0.7
                  ? 'Bagus, sudah lengkap.'
                  : 'Jawaban perlu lebih detail.';
            }
          }
        }

        final score = ExamSubmission.computeScore(
          exam: exam,
          mcAnswers: mcAnswers,
          essayScores: essayScores,
        );
        final totalPoints = exam.totalPoints;
        final submittedAt = exam.startAt.add(
          Duration(hours: rand.nextInt(72), minutes: rand.nextInt(60)),
        );

        final id = 'sub_${exam.id}_$studentId';
        submissions[id] = ExamSubmission(
          id: id,
          examId: exam.id,
          studentId: studentId,
          answers: mcAnswers,
          essayAnswers: essayAnswers,
          essayScores: essayScores,
          essayFeedback: essayFeedback,
          score: score,
          totalPoints: totalPoints,
          submittedAt: submittedAt,
          gradedAt: essayQs.isEmpty || essayScores.length == essayQs.length
              ? submittedAt.add(Duration(hours: 24 + rand.nextInt(48)))
              : null,
        );
      }
    }

    final otomotifExamId = 'e_otomotif_asat_10a';
    exams[otomotifExamId] = Exam(
      id: otomotifExamId,
      title: 'ASAT Dasar-Dasar Teknik Otomotif 10A',
      description:
          'Asesmen Sumatif Akhir Tahun SMK Negeri 1 Pati Tahun Pelajaran 2025/2026.',
      subjectId: 's_otomotif',
      classId: 'c_10a',
      teacherId: 'u_teacher',
      durationMinutes: 90,
      startAt: dayOnly(now, 1),
      endAt: now.add(const Duration(days: 30)),
      questions: [
        for (var i = 0; i < _otomotifAsatQuestions.length; i++)
          ExamQuestion(
            id: '${otomotifExamId}_q$i',
            type: _otomotifAsatQuestions[i].type,
            prompt: _otomotifAsatQuestions[i].prompt,
            options: _otomotifAsatQuestions[i].options,
            correctIndex: _otomotifAsatQuestions[i].correctIndex,
            correctIndexes: _otomotifAsatQuestions[i].correctIndexes,
            trueFalseAnswers: _otomotifAsatQuestions[i].trueFalseAnswers,
            sampleAnswer: _otomotifAsatQuestions[i].sampleAnswer,
            points: _otomotifAsatQuestions[i].points,
          ),
      ],
    );

    // ============================== Teaching journals ==============================
    const topicByCode = <String, List<String>>{
      's_math': [
        'Persamaan Linear Satu Variabel',
        'Persamaan Kuadrat',
        'Trigonometri Dasar',
        'Logaritma',
        'Statistika & Peluang',
      ],
      's_indo': [
        'Teks Eksposisi',
        'Teks Anekdot',
        'Hikayat',
        'Teks Negosiasi',
        'Drama',
      ],
      's_ipa': [
        'Klasifikasi Makhluk Hidup',
        'Sistem Pencernaan',
        'Hukum Newton',
        'Energi & Perubahannya',
        'Ekosistem & Lingkungan',
      ],
      's_ips': [
        'Letak Geografis Indonesia',
        'Sejarah Kemerdekaan Indonesia',
        'Pancasila & UUD 1945',
        'Sistem Ekonomi Indonesia',
        'Interaksi Sosial',
      ],
      's_eng': [
        'Descriptive Text',
        'Recount Text',
        'Procedure Text',
        'Narrative Text',
        'Argumentative Text',
      ],
      's_pjok': [
        'Bola Voli',
        'Sepak Bola',
        'Atletik',
        'Senam Lantai',
        'Renang Gaya Bebas',
      ],
    };
    var tjIdx = 0;
    for (final t in teachersData) {
      final teacherId = t.$1;
      final subjectId = t.$4;
      final topics = topicByCode[subjectId] ?? const ['Materi Umum'];
      final journalCount = 3 + rand.nextInt(3); // 3-5
      for (var i = 0; i < journalCount; i++) {
        final classId = classOrder[rand.nextInt(classOrder.length)];
        final cls = classes[classId]!;
        final attendance =
            cls.studentIds.length - rand.nextInt(3); // some absences
        teachingJournals['tj_$tjIdx'] = TeachingJournal(
          id: 'tj_$tjIdx',
          teacherId: teacherId,
          classId: classId,
          subjectId: subjectId,
          date: dayOnly(now, i + 1),
          topic: topics[i % topics.length],
          activities:
              'Diskusi materi "${topics[i % topics.length]}" diikuti latihan soal '
              'dan tanya jawab kelas.',
          notes: rand.nextBool()
              ? 'Siswa antusias mengikuti pelajaran. Beberapa siswa perlu pendampingan tambahan.'
              : null,
          attendanceCount: attendance.clamp(0, cls.studentIds.length),
          totalStudents: cls.studentIds.length,
        );
        tjIdx++;
      }
    }

    // ============================== Study journals ==============================
    var sjIdx = 0;
    for (final u
        in users.values.where((u) => u.role == UserRole.student).toList()) {
      final count = rand.nextInt(4); // 0-3 catatan per siswa
      for (var i = 0; i < count; i++) {
        final subjectId = examSubjects[rand.nextInt(examSubjects.length)];
        final subjectName = subjects[subjectId]?.name ?? 'Pelajaran';
        studyJournals['sj_$sjIdx'] = StudyJournal(
          id: 'sj_$sjIdx',
          studentId: u.id,
          subjectId: subjectId,
          date: dayOnly(now, i + 1),
          topic: 'Latihan $subjectName',
          summary:
              'Mengulang materi yang dipelajari di sekolah dan mengerjakan '
              'beberapa soal latihan dari buku paket.',
          durationMinutes: 30 + rand.nextInt(60),
        );
        sjIdx++;
      }
    }

    // ============================== Teacher attendance ==============================
    // Last 14 weekdays per teacher
    for (final t in teachersData) {
      final teacherId = t.$1;
      var dayOffset = 0;
      var recordCount = 0;
      while (recordCount < 14 && dayOffset < 30) {
        final d = dayOnly(now, dayOffset);
        dayOffset++;
        if (d.weekday > 5) continue; // skip weekend

        final r = rand.nextDouble();
        final AttendanceStatus status;
        if (r < 0.85) {
          status = AttendanceStatus.hadir;
        } else if (r < 0.92) {
          status = AttendanceStatus.terlambat;
        } else if (r < 0.96) {
          status = AttendanceStatus.izin;
        } else {
          status = AttendanceStatus.sakit;
        }

        final DateTime? checkIn;
        if (status == AttendanceStatus.hadir) {
          checkIn = DateTime(d.year, d.month, d.day, 7, 25 + rand.nextInt(15));
        } else if (status == AttendanceStatus.terlambat) {
          checkIn = DateTime(d.year, d.month, d.day, 7, 45 + rand.nextInt(20));
        } else {
          checkIn = null;
        }

        final id = 'ta_${teacherId}_$recordCount';
        teacherAttendance[id] = TeacherAttendance(
          id: id,
          teacherId: teacherId,
          date: d,
          status: status,
          checkInTime: checkIn,
        );
        recordCount++;
      }
    }

    // ============================== Student attendance ==============================
    // Presensi per mata pelajaran: untuk tiap kelas, ambil mapel yang diajarkan
    // (diturunkan dari ujian kelas tsb), lalu catat 8 pertemuan terakhir per
    // mapel untuk semua siswa.
    for (final classId in classOrder) {
      final cls = classes[classId]!;
      final classSubjects = exams.values
          .where((e) => e.classId == classId)
          .map((e) => e.subjectId)
          .toSet()
          .toList();
      if (classSubjects.isEmpty) continue;

      var dayOffset = 0;
      var sessionCount = 0;
      while (sessionCount < 8 && dayOffset < 45) {
        final d = dayOnly(now, dayOffset);
        dayOffset++;
        if (d.weekday > 5) continue;

        for (final subjectId in classSubjects) {
          for (final studentId in cls.studentIds) {
            final r = rand.nextDouble();
            final AttendanceStatus status;
            if (r < 0.85) {
              status = AttendanceStatus.hadir;
            } else if (r < 0.91) {
              status = AttendanceStatus.terlambat;
            } else if (r < 0.95) {
              status = AttendanceStatus.izin;
            } else if (r < 0.98) {
              status = AttendanceStatus.sakit;
            } else {
              status = AttendanceStatus.alpa;
            }
            final id = 'sa_${classId}_${subjectId}_${sessionCount}_$studentId';
            studentAttendance[id] = StudentAttendance(
              id: id,
              classId: classId,
              studentId: studentId,
              subjectId: subjectId,
              date: d,
              status: status,
              recordedByTeacherId: cls.homeroomTeacherId,
            );
          }
        }
        sessionCount++;
      }
    }

    // ============================== Enrollments (seed) ==============================
    final enrollmentSeed = <StudentEnrollment>[
      StudentEnrollment(
        id: 'enr_1',
        type: EnrollmentType.newStudent,
        status: EnrollmentStatus.pending,
        fullName: 'Rizky Aditya Pratama',
        email: 'rizky.aditya@gmail.com',
        phone: '0858-1234-5678',
        address: 'Jl. Mawar No. 3, Pati',
        gender: 'Laki-laki',
        dateOfBirth: DateTime(2010, 5, 22),
        previousSchoolName: 'SMP Negeri 1 Pati',
        previousSchoolCity: 'Pati',
        previousSchoolType: 'SMP',
        previousGradeLevel: '9',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      StudentEnrollment(
        id: 'enr_2',
        type: EnrollmentType.transfer,
        status: EnrollmentStatus.pending,
        fullName: 'Siti Nurhaliza',
        email: 'siti.nurhaliza@gmail.com',
        phone: '0821-9876-5432',
        address: 'Jl. Kenanga No. 7, Jepara',
        gender: 'Perempuan',
        dateOfBirth: DateTime(2009, 11, 8),
        previousSchoolName: 'SMK Negeri 2 Jepara',
        previousSchoolCity: 'Jepara',
        previousSchoolType: 'SMK',
        previousGradeLevel: '10',
        transferReason: 'Mengikuti kepindahan orang tua ke Pati.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      StudentEnrollment(
        id: 'enr_3',
        type: EnrollmentType.newStudent,
        status: EnrollmentStatus.approved,
        fullName: 'Bagus Firmansyah',
        email: 'bagus.firmansyah@gmail.com',
        phone: '0812-3344-5566',
        gender: 'Laki-laki',
        dateOfBirth: DateTime(2010, 3, 14),
        previousSchoolName: 'SMP Muhammadiyah 1 Pati',
        previousSchoolCity: 'Pati',
        previousSchoolType: 'SMP',
        previousGradeLevel: '9',
        requestedClassId: 'c_10a',
        createdAt: now.subtract(const Duration(days: 10)),
        reviewedAt: now.subtract(const Duration(days: 8)),
        reviewedByAdminId: 'u_admin',
        reviewNote: 'Berkas lengkap. Ditempatkan di kelas 10A.',
        approvedUserId: null,
      ),
      StudentEnrollment(
        id: 'enr_4',
        type: EnrollmentType.transfer,
        status: EnrollmentStatus.rejected,
        fullName: 'Dewi Rahmawati',
        email: 'dewi.rahma@gmail.com',
        gender: 'Perempuan',
        dateOfBirth: DateTime(2008, 7, 20),
        previousSchoolName: 'SMA Negeri 1 Pati',
        previousSchoolCity: 'Pati',
        previousSchoolType: 'SMA',
        previousGradeLevel: '11',
        transferReason: 'Jarak sekolah terlalu jauh dari rumah baru.',
        createdAt: now.subtract(const Duration(days: 15)),
        reviewedAt: now.subtract(const Duration(days: 12)),
        reviewedByAdminId: 'u_admin',
        reviewNote: 'Kuota kelas 11 sudah penuh untuk tahun ajaran ini.',
      ),
    ];
    for (final e in enrollmentSeed) {
      enrollments[e.id] = e;
    }

    // ============================== Payment Categories (seed) ==============================
    const categorySeed = <PaymentCategory>[
      PaymentCategory(
        id: 'pc_spp',
        name: 'SPP',
        description: 'Sumbangan Pembinaan Pendidikan bulanan',
        defaultAmount: 150000,
        isRecurringMonthly: true,
      ),
      PaymentCategory(
        id: 'pc_buku',
        name: 'Buku & LKS',
        description: 'Pembelian buku paket dan lembar kerja siswa',
        defaultAmount: 350000,
        isRecurringMonthly: false,
      ),
      PaymentCategory(
        id: 'pc_ekskul',
        name: 'Ekstrakurikuler',
        description: 'Biaya kegiatan ekstrakurikuler',
        defaultAmount: 75000,
        isRecurringMonthly: false,
      ),
      PaymentCategory(
        id: 'pc_ujian',
        name: 'Ujian & Penilaian',
        description: 'Biaya ujian tengah semester dan akhir semester',
        defaultAmount: 100000,
        isRecurringMonthly: false,
      ),
    ];
    for (final c in categorySeed) {
      paymentCategories[c.id] = c;
    }

    // ============================== Payment Bills (seed) ==============================
    // SPP Jan-Apr 2026 untuk demo student (u_student)
    final months = [1, 2, 3, 4];
    final monthNames = ['Januari', 'Februari', 'Maret', 'April'];
    for (var i = 0; i < months.length; i++) {
      final m = months[i];
      final isPaid = m < 4;
      final isPartial = m == 3;
      final id = 'bill_spp_${m}_2026';
      final paidAmt = isPaid ? (isPartial ? 75000 : 150000) : 0;
      paymentBills[id] = PaymentBill(
        id: id,
        studentId: 'u_student',
        classId: 'c_10a',
        categoryId: 'pc_spp',
        title: 'SPP ${monthNames[i]} 2026',
        amount: 150000,
        paidAmount: paidAmt,
        dueDate: DateTime(2026, m, 10),
        status: isPaid
            ? (isPartial ? BillStatus.partiallyPaid : BillStatus.paid)
            : BillStatus.unpaid,
        month: m,
        year: 2026,
        createdAt: DateTime(2026, m, 1),
        createdByAdminId: 'u_admin',
      );
    }
    // Tagihan buku (lunas)
    paymentBills['bill_buku_2026'] = PaymentBill(
      id: 'bill_buku_2026',
      studentId: 'u_student',
      classId: 'c_10a',
      categoryId: 'pc_buku',
      title: 'Buku & LKS Semester Genap 2025/2026',
      amount: 350000,
      paidAmount: 350000,
      dueDate: DateTime(2026, 1, 15),
      status: BillStatus.paid,
      createdAt: DateTime(2026, 1, 5),
      createdByAdminId: 'u_admin',
    );
    // SPP menunggak bulan Desember untuk siswa lain (s_1)
    paymentBills['bill_spp_12_2025'] = PaymentBill(
      id: 'bill_spp_12_2025',
      studentId: 's_1',
      classId: 'c_10a',
      categoryId: 'pc_spp',
      title: 'SPP Desember 2025',
      amount: 150000,
      paidAmount: 0,
      dueDate: DateTime(2025, 12, 10),
      status: BillStatus.overdue,
      month: 12,
      year: 2025,
      createdAt: DateTime(2025, 12, 1),
      createdByAdminId: 'u_admin',
    );

    // ============================== Payment Transactions (seed) ==============================
    // Konfirmasi pembayaran SPP Januari & Februari (lunas), SPP Maret (sebagian)
    paymentTransactions['tx_1'] = PaymentTransaction(
      id: 'tx_1',
      billId: 'bill_spp_1_2026',
      studentId: 'u_student',
      amount: 150000,
      method: PaymentMethod.bankTransfer,
      status: TransactionStatus.confirmed,
      createdAt: DateTime(2026, 1, 8),
      confirmedAt: DateTime(2026, 1, 9),
      confirmedByAdminId: 'u_admin',
      receiptNumber: 'RCP-2026-0001',
    );
    paymentTransactions['tx_2'] = PaymentTransaction(
      id: 'tx_2',
      billId: 'bill_spp_2_2026',
      studentId: 'u_student',
      amount: 150000,
      method: PaymentMethod.cash,
      status: TransactionStatus.confirmed,
      createdAt: DateTime(2026, 2, 7),
      confirmedAt: DateTime(2026, 2, 7),
      confirmedByAdminId: 'u_admin',
      receiptNumber: 'RCP-2026-0024',
    );
    paymentTransactions['tx_3'] = PaymentTransaction(
      id: 'tx_3',
      billId: 'bill_spp_3_2026',
      studentId: 'u_student',
      amount: 75000,
      method: PaymentMethod.bankTransfer,
      status: TransactionStatus.confirmed,
      createdAt: DateTime(2026, 3, 5),
      confirmedAt: DateTime(2026, 3, 6),
      confirmedByAdminId: 'u_admin',
      receiptNumber: 'RCP-2026-0047',
      proofNote: 'Transfer sebagian dulu, sisanya menyusul.',
    );
    // Transaksi buku (lunas)
    paymentTransactions['tx_4'] = PaymentTransaction(
      id: 'tx_4',
      billId: 'bill_buku_2026',
      studentId: 'u_student',
      amount: 350000,
      method: PaymentMethod.cash,
      status: TransactionStatus.confirmed,
      createdAt: DateTime(2026, 1, 12),
      confirmedAt: DateTime(2026, 1, 12),
      confirmedByAdminId: 'u_admin',
      receiptNumber: 'RCP-2026-0008',
    );
    // Transaksi pending (belum dikonfirmasi)
    paymentTransactions['tx_5'] = PaymentTransaction(
      id: 'tx_5',
      billId: 'bill_spp_4_2026',
      studentId: 'u_student',
      amount: 150000,
      method: PaymentMethod.bankTransfer,
      status: TransactionStatus.pending,
      createdAt: now.subtract(const Duration(hours: 3)),
      proofNote: 'Sudah transfer ke rek BRI sekolah.',
    );

    // ============================== Academic Years (seed) ==============================
    final academicYearSeed = <AcademicYear>[
      AcademicYear(
        id: 'ay_2024',
        name: '2024/2025',
        startDate: DateTime(2024, 7, 15),
        endDate: DateTime(2025, 6, 30),
        status: AcademicYearStatus.archived,
        createdAt: DateTime(2024, 7, 1),
        createdByAdminId: 'u_admin',
        promotionRunAt: DateTime(2025, 6, 28),
        promotionRunByAdminId: 'u_admin',
      ),
      AcademicYear(
        id: 'ay_2025',
        name: '2025/2026',
        startDate: DateTime(2025, 7, 14),
        endDate: DateTime(2026, 6, 30),
        status: AcademicYearStatus.active,
        createdAt: DateTime(2025, 7, 1),
        createdByAdminId: 'u_admin',
      ),
    ];
    for (final y in academicYearSeed) {
      academicYears[y.id] = y;
    }

    // ============================== Audit Logs (seed) ==============================
    // Riwayat acak agar halaman audit punya data demo. Login berhasil + 1
    // login gagal + perubahan profil + tindakan admin.
    const sampleDevices = [
      'Chrome di macOS',
      'Chrome di Windows',
      'Safari di iPhone',
      'Chrome di Android',
      'Firefox di Linux',
    ];
    final actorPool = [
      users['u_admin']!,
      users['u_teacher']!,
      users['u_student']!,
      users['u_parent']!,
      users['t_andi']!,
      users['t_rina']!,
    ];
    var auditIdx = 0;
    for (var hour = 0; hour < 28; hour++) {
      final actor = actorPool[rand.nextInt(actorPool.length)];
      final device = sampleDevices[rand.nextInt(sampleDevices.length)];
      final ts = now.subtract(Duration(hours: hour * 3 + rand.nextInt(3)));
      auditLogs['au_$auditIdx'] = AuditLog(
        id: 'au_$auditIdx',
        timestamp: ts,
        action: hour.isEven ? AuditAction.signIn : AuditAction.signOut,
        actorId: actor.id,
        actorName: actor.name,
        actorEmail: actor.email,
        actorRole: actor.role.label,
        deviceLabel: device,
      );
      auditIdx++;
    }
    // Satu login gagal
    auditLogs['au_$auditIdx'] = AuditLog(
      id: 'au_$auditIdx',
      timestamp: now.subtract(const Duration(hours: 2)),
      action: AuditAction.signInFailed,
      actorEmail: 'guru@sekolah.id',
      deviceLabel: 'Chrome di Windows',
      note: 'Email atau kata sandi salah',
    );
    auditIdx++;
    // Beberapa tindakan admin
    auditLogs['au_$auditIdx'] = AuditLog(
      id: 'au_$auditIdx',
      timestamp: now.subtract(const Duration(days: 1, hours: 3)),
      action: AuditAction.userCreate,
      actorId: 'u_admin',
      actorName: 'Hari Wibowo',
      actorEmail: 'admin@sekolah.id',
      actorRole: 'Admin',
      targetType: 'user',
      targetId: 't_maya',
      targetLabel: 'Bu Maya Lestari',
      deviceLabel: 'Chrome di macOS',
      note: 'Menambahkan guru Bahasa Inggris',
    );
    auditIdx++;
    auditLogs['au_$auditIdx'] = AuditLog(
      id: 'au_$auditIdx',
      timestamp: now.subtract(const Duration(days: 2, hours: 6)),
      action: AuditAction.classCreate,
      actorId: 'u_admin',
      actorName: 'Hari Wibowo',
      actorEmail: 'admin@sekolah.id',
      actorRole: 'Admin',
      targetType: 'class',
      targetId: 'c_12a',
      targetLabel: '12A',
      deviceLabel: 'Chrome di macOS',
    );
    auditIdx++;
    auditLogs['au_$auditIdx'] = AuditLog(
      id: 'au_$auditIdx',
      timestamp: now.subtract(const Duration(hours: 5)),
      action: AuditAction.passwordChange,
      actorId: 'u_teacher',
      actorName: 'Bu Sari Indriani',
      actorEmail: 'guru@sekolah.id',
      actorRole: 'Guru',
      deviceLabel: 'Safari di iPhone',
    );
    auditIdx++;
  }
}
