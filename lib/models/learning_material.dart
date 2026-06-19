class LearningMaterial {
  final String id;
  final String title;
  final String content;
  final String subjectId;
  final String classId;
  final String teacherId;
  final String? attachmentUrl;
  final DateTime createdAt;

  const LearningMaterial({
    required this.id,
    required this.title,
    required this.content,
    required this.subjectId,
    required this.classId,
    required this.teacherId,
    this.attachmentUrl,
    required this.createdAt,
  });

  LearningMaterial copyWith({
    String? title,
    String? content,
    String? subjectId,
    String? classId,
    String? attachmentUrl,
  }) {
    return LearningMaterial(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      subjectId: subjectId ?? this.subjectId,
      classId: classId ?? this.classId,
      teacherId: teacherId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'subjectId': subjectId,
        'classId': classId,
        'teacherId': teacherId,
        'attachmentUrl': attachmentUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LearningMaterial.fromMap(String id, Map<String, dynamic> map) {
    return LearningMaterial(
      id: id,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      subjectId: map['subjectId'] as String? ?? '',
      classId: map['classId'] as String? ?? '',
      teacherId: map['teacherId'] as String? ?? '',
      attachmentUrl: map['attachmentUrl'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
