class StudyJournal {
  final String id;
  final String studentId;
  final String? subjectId;
  final DateTime date;
  final String topic;
  final String summary;
  final int durationMinutes;

  const StudyJournal({
    required this.id,
    required this.studentId,
    this.subjectId,
    required this.date,
    required this.topic,
    required this.summary,
    required this.durationMinutes,
  });

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'subjectId': subjectId,
        'date': date.toIso8601String(),
        'topic': topic,
        'summary': summary,
        'durationMinutes': durationMinutes,
      };

  factory StudyJournal.fromMap(String id, Map<String, dynamic> map) {
    return StudyJournal(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      subjectId: map['subjectId'] as String?,
      date:
          DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      topic: map['topic'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}
