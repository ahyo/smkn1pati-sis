class SchoolClass {
  final String id;
  final String name;
  final String gradeLevel;
  final String? homeroomTeacherId;
  final List<String> studentIds;

  const SchoolClass({
    required this.id,
    required this.name,
    required this.gradeLevel,
    this.homeroomTeacherId,
    this.studentIds = const [],
  });

  SchoolClass copyWith({
    String? name,
    String? gradeLevel,
    String? homeroomTeacherId,
    List<String>? studentIds,
  }) {
    return SchoolClass(
      id: id,
      name: name ?? this.name,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      homeroomTeacherId: homeroomTeacherId ?? this.homeroomTeacherId,
      studentIds: studentIds ?? this.studentIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'gradeLevel': gradeLevel,
        'homeroomTeacherId': homeroomTeacherId,
        'studentIds': studentIds,
      };

  factory SchoolClass.fromMap(String id, Map<String, dynamic> map) {
    return SchoolClass(
      id: id,
      name: map['name'] as String? ?? '',
      gradeLevel: map['gradeLevel'] as String? ?? '',
      homeroomTeacherId: map['homeroomTeacherId'] as String?,
      studentIds: List<String>.from(map['studentIds'] ?? const []),
    );
  }
}
