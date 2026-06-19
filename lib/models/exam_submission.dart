import 'exam.dart';

class ExamSubmission {
  final String id;
  final String examId;
  final String studentId;

  // Pilihan ganda: questionId -> indeks opsi yang dipilih
  final Map<String, int> answers;
  // Pilihan ganda kompleks: questionId -> indeks opsi yang dipilih
  final Map<String, List<int>> complexAnswers;
  // Benar/salah: questionId -> daftar jawaban untuk setiap pernyataan
  final Map<String, List<bool>> trueFalseAnswers;
  // Essay: questionId -> teks jawaban siswa
  final Map<String, String> essayAnswers;
  // Essay: questionId -> poin yang diberikan guru (default 0 sebelum dinilai)
  final Map<String, int> essayScores;
  // Essay: questionId -> catatan dari guru
  final Map<String, String> essayFeedback;

  /// Total skor (auto-MC + manual essay). Dihitung ulang saat submit & saat
  /// guru memberi nilai essay.
  final int score;
  final int totalPoints;
  final DateTime submittedAt;
  final DateTime? gradedAt;

  const ExamSubmission({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.answers,
    this.complexAnswers = const {},
    this.trueFalseAnswers = const {},
    this.essayAnswers = const {},
    this.essayScores = const {},
    this.essayFeedback = const {},
    required this.score,
    required this.totalPoints,
    required this.submittedAt,
    this.gradedAt,
  });

  double get percentage => totalPoints == 0 ? 0 : (score / totalPoints) * 100;

  /// True jika semua essay sudah ditambahkan ke essayScores (atau tidak ada
  /// essay sama sekali).
  bool isFullyGradedFor(Exam exam) {
    for (final q in exam.questions) {
      if (q.isEssay && !essayScores.containsKey(q.id)) {
        return false;
      }
    }
    return true;
  }

  /// Hitung ulang skor berdasarkan exam definitions + jawaban yg ada.
  static int computeScore({
    required Exam exam,
    required Map<String, int> mcAnswers,
    Map<String, List<int>> complexAnswers = const {},
    Map<String, List<bool>> trueFalseAnswers = const {},
    required Map<String, int> essayScores,
  }) {
    var s = 0;
    for (final q in exam.questions) {
      if (q.isMultipleChoice) {
        if (mcAnswers[q.id] == q.correctIndex) s += q.points;
      } else if (q.isMultipleChoiceComplex) {
        final picked = [...complexAnswers[q.id] ?? const <int>[]]..sort();
        final correct = [...q.correctIndexes]..sort();
        if (_sameIntList(picked, correct)) s += q.points;
      } else if (q.isTrueFalse) {
        final picked = trueFalseAnswers[q.id] ?? const <bool>[];
        if (_sameBoolList(picked, q.trueFalseAnswers)) s += q.points;
      } else {
        s += essayScores[q.id] ?? 0;
      }
    }
    return s;
  }

  static bool _sameIntList(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameBoolList(List<bool> a, List<bool> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  ExamSubmission copyWith({
    Map<String, int>? answers,
    Map<String, List<int>>? complexAnswers,
    Map<String, List<bool>>? trueFalseAnswers,
    Map<String, String>? essayAnswers,
    Map<String, int>? essayScores,
    Map<String, String>? essayFeedback,
    int? score,
    int? totalPoints,
    DateTime? gradedAt,
  }) {
    return ExamSubmission(
      id: id,
      examId: examId,
      studentId: studentId,
      answers: answers ?? this.answers,
      complexAnswers: complexAnswers ?? this.complexAnswers,
      trueFalseAnswers: trueFalseAnswers ?? this.trueFalseAnswers,
      essayAnswers: essayAnswers ?? this.essayAnswers,
      essayScores: essayScores ?? this.essayScores,
      essayFeedback: essayFeedback ?? this.essayFeedback,
      score: score ?? this.score,
      totalPoints: totalPoints ?? this.totalPoints,
      submittedAt: submittedAt,
      gradedAt: gradedAt ?? this.gradedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'examId': examId,
    'studentId': studentId,
    'answers': answers,
    'complexAnswers': complexAnswers,
    'trueFalseAnswers': trueFalseAnswers,
    'essayAnswers': essayAnswers,
    'essayScores': essayScores,
    'essayFeedback': essayFeedback,
    'score': score,
    'totalPoints': totalPoints,
    'submittedAt': submittedAt.toIso8601String(),
    'gradedAt': gradedAt?.toIso8601String(),
  };

  factory ExamSubmission.fromMap(String id, Map<String, dynamic> map) {
    return ExamSubmission(
      id: id,
      examId: map['examId'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      answers: Map<String, int>.from(
        (map['answers'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      complexAnswers: Map<String, List<int>>.from(
        (map['complexAnswers'] as Map? ?? {}).map(
          (k, v) => MapEntry(
            k.toString(),
            List<int>.from(
              (v as List? ?? const []).map((e) => (e as num).toInt()),
            ),
          ),
        ),
      ),
      trueFalseAnswers: Map<String, List<bool>>.from(
        (map['trueFalseAnswers'] as Map? ?? {}).map(
          (k, v) => MapEntry(
            k.toString(),
            List<bool>.from((v as List? ?? const []).map((e) => e == true)),
          ),
        ),
      ),
      essayAnswers: Map<String, String>.from(
        (map['essayAnswers'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ),
      ),
      essayScores: Map<String, int>.from(
        (map['essayScores'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      essayFeedback: Map<String, String>.from(
        (map['essayFeedback'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ),
      ),
      score: (map['score'] as num?)?.toInt() ?? 0,
      totalPoints: (map['totalPoints'] as num?)?.toInt() ?? 0,
      submittedAt:
          DateTime.tryParse(map['submittedAt'] as String? ?? '') ??
          DateTime.now(),
      gradedAt: map['gradedAt'] == null
          ? null
          : DateTime.tryParse(map['gradedAt'] as String),
    );
  }
}
