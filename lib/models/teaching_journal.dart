class TeachingJournal {
  final String id;
  final String teacherId;
  final String classId;
  final String subjectId;
  final DateTime date;
  final String topic;
  final String activities;
  final String? notes;
  final int attendanceCount;
  final int totalStudents;

  const TeachingJournal({
    required this.id,
    required this.teacherId,
    required this.classId,
    required this.subjectId,
    required this.date,
    required this.topic,
    required this.activities,
    this.notes,
    required this.attendanceCount,
    required this.totalStudents,
  });

  Map<String, dynamic> toMap() => {
        'teacherId': teacherId,
        'classId': classId,
        'subjectId': subjectId,
        'date': date.toIso8601String(),
        'topic': topic,
        'activities': activities,
        'notes': notes,
        'attendanceCount': attendanceCount,
        'totalStudents': totalStudents,
      };

  factory TeachingJournal.fromMap(String id, Map<String, dynamic> map) {
    return TeachingJournal(
      id: id,
      teacherId: map['teacherId'] as String? ?? '',
      classId: map['classId'] as String? ?? '',
      subjectId: map['subjectId'] as String? ?? '',
      date:
          DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      topic: map['topic'] as String? ?? '',
      activities: map['activities'] as String? ?? '',
      notes: map['notes'] as String?,
      attendanceCount: (map['attendanceCount'] as num?)?.toInt() ?? 0,
      totalStudents: (map['totalStudents'] as num?)?.toInt() ?? 0,
    );
  }
}
