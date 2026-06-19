class Subject {
  final String id;
  final String name;
  final String code;
  final String? description;

  const Subject({
    required this.id,
    required this.name,
    required this.code,
    this.description,
  });

  Subject copyWith({String? name, String? code, String? description}) {
    return Subject(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'code': code,
        'description': description,
      };

  factory Subject.fromMap(String id, Map<String, dynamic> map) {
    return Subject(
      id: id,
      name: map['name'] as String? ?? '',
      code: map['code'] as String? ?? '',
      description: map['description'] as String?,
    );
  }
}
