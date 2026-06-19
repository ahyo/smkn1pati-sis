enum QuestionType {
  multipleChoice,
  multipleChoiceComplex,
  trueFalse,
  essay;

  String get label {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Pilihan Ganda';
      case QuestionType.multipleChoiceComplex:
        return 'Pilihan Ganda Kompleks';
      case QuestionType.trueFalse:
        return 'Benar / Salah';
      case QuestionType.essay:
        return 'Essay';
    }
  }

  static QuestionType fromString(String? value) {
    return QuestionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => QuestionType.multipleChoice,
    );
  }
}

class ExamQuestion {
  final String id;
  final QuestionType type;
  final String prompt;

  // MC fields
  final List<String> options;
  final int correctIndex;
  final List<int> correctIndexes;
  final List<bool> trueFalseAnswers;

  // Essay fields
  final String? sampleAnswer;

  final int points;

  const ExamQuestion({
    required this.id,
    this.type = QuestionType.multipleChoice,
    required this.prompt,
    this.options = const [],
    this.correctIndex = 0,
    this.correctIndexes = const [],
    this.trueFalseAnswers = const [],
    this.sampleAnswer,
    this.points = 10,
  });

  bool get isMultipleChoice => type == QuestionType.multipleChoice;
  bool get isMultipleChoiceComplex =>
      type == QuestionType.multipleChoiceComplex;
  bool get isTrueFalse => type == QuestionType.trueFalse;
  bool get isObjective => !isEssay;
  bool get isEssay => type == QuestionType.essay;

  ExamQuestion copyWith({
    QuestionType? type,
    String? prompt,
    List<String>? options,
    int? correctIndex,
    List<int>? correctIndexes,
    List<bool>? trueFalseAnswers,
    String? sampleAnswer,
    int? points,
  }) {
    return ExamQuestion(
      id: id,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      correctIndexes: correctIndexes ?? this.correctIndexes,
      trueFalseAnswers: trueFalseAnswers ?? this.trueFalseAnswers,
      sampleAnswer: sampleAnswer ?? this.sampleAnswer,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'prompt': prompt,
    'options': options,
    'correctIndex': correctIndex,
    'correctIndexes': correctIndexes,
    'trueFalseAnswers': trueFalseAnswers,
    'sampleAnswer': sampleAnswer,
    'points': points,
  };

  factory ExamQuestion.fromMap(Map<String, dynamic> map) {
    return ExamQuestion(
      id: map['id'] as String? ?? '',
      type: QuestionType.fromString(map['type'] as String?),
      prompt: map['prompt'] as String? ?? '',
      options: List<String>.from(map['options'] ?? const []),
      correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
      correctIndexes: List<int>.from(
        (map['correctIndexes'] as List? ?? const []).map(
          (e) => (e as num).toInt(),
        ),
      ),
      trueFalseAnswers: List<bool>.from(
        (map['trueFalseAnswers'] as List? ?? const []).map((e) => e == true),
      ),
      sampleAnswer: map['sampleAnswer'] as String?,
      points: (map['points'] as num?)?.toInt() ?? 10,
    );
  }
}

class Exam {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String classId;
  final String teacherId;
  final List<ExamQuestion> questions;
  final int durationMinutes;
  final DateTime startAt;
  final DateTime endAt;

  const Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.classId,
    required this.teacherId,
    required this.questions,
    required this.durationMinutes,
    required this.startAt,
    required this.endAt,
  });

  int get totalPoints => questions.fold(0, (sum, q) => sum + q.points);

  int get essayCount =>
      questions.where((q) => q.type == QuestionType.essay).length;
  int get mcCount =>
      questions.where((q) => q.type == QuestionType.multipleChoice).length;
  int get multipleChoiceComplexCount => questions
      .where((q) => q.type == QuestionType.multipleChoiceComplex)
      .length;
  int get trueFalseCount =>
      questions.where((q) => q.type == QuestionType.trueFalse).length;
  int get objectiveCount => questions.where((q) => q.isObjective).length;
  bool get hasEssayQuestions => essayCount > 0;

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startAt) && now.isBefore(endAt);
  }

  Exam copyWith({
    String? title,
    String? description,
    String? subjectId,
    String? classId,
    List<ExamQuestion>? questions,
    int? durationMinutes,
    DateTime? startAt,
    DateTime? endAt,
  }) {
    return Exam(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      classId: classId ?? this.classId,
      teacherId: teacherId,
      questions: questions ?? this.questions,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'subjectId': subjectId,
    'classId': classId,
    'teacherId': teacherId,
    'questions': questions.map((q) => q.toMap()).toList(),
    'durationMinutes': durationMinutes,
    'startAt': startAt.toIso8601String(),
    'endAt': endAt.toIso8601String(),
  };

  factory Exam.fromMap(String id, Map<String, dynamic> map) {
    return Exam(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      subjectId: map['subjectId'] as String? ?? '',
      classId: map['classId'] as String? ?? '',
      teacherId: map['teacherId'] as String? ?? '',
      questions: (map['questions'] as List? ?? [])
          .map((e) => ExamQuestion.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 60,
      startAt:
          DateTime.tryParse(map['startAt'] as String? ?? '') ?? DateTime.now(),
      endAt:
          DateTime.tryParse(map['endAt'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 1)),
    );
  }
}
