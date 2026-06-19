import 'user_role.dart';

class AppUser {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  // Identitas tambahan
  final String? phone;
  final String? address;
  final String? gender; // 'Laki-laki' / 'Perempuan'
  final DateTime? dateOfBirth;
  final String? identityNumber; // NIS/NIP/NIK sesuai role
  final String? bio;

  // Konteks role
  final String? classId;
  final List<String> childrenIds;
  final List<String> subjectIds;

  // Diisi saat siswa lulus (mis. "2025/2026")
  final String? graduatedYear;

  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.identityNumber,
    this.bio,
    this.classId,
    this.childrenIds = const [],
    this.subjectIds = const [],
    this.graduatedYear,
    required this.createdAt,
  });

  AppUser copyWith({
    String? name,
    UserRole? role,
    String? phone,
    String? address,
    String? gender,
    DateTime? dateOfBirth,
    String? identityNumber,
    String? bio,
    String? classId,
    bool clearClassId = false,
    List<String>? childrenIds,
    List<String>? subjectIds,
    String? graduatedYear,
  }) {
    return AppUser(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      identityNumber: identityNumber ?? this.identityNumber,
      bio: bio ?? this.bio,
      classId: clearClassId ? null : (classId ?? this.classId),
      childrenIds: childrenIds ?? this.childrenIds,
      subjectIds: subjectIds ?? this.subjectIds,
      graduatedYear: graduatedYear ?? this.graduatedYear,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'role': role.name,
        'phone': phone,
        'address': address,
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'identityNumber': identityNumber,
        'bio': bio,
        'classId': classId,
        'childrenIds': childrenIds,
        'subjectIds': subjectIds,
        'graduatedYear': graduatedYear,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      gender: map['gender'] as String?,
      dateOfBirth: map['dateOfBirth'] == null
          ? null
          : DateTime.tryParse(map['dateOfBirth'] as String),
      identityNumber: map['identityNumber'] as String?,
      bio: map['bio'] as String?,
      classId: map['classId'] as String?,
      childrenIds: List<String>.from(map['childrenIds'] ?? const []),
      subjectIds: List<String>.from(map['subjectIds'] ?? const []),
      graduatedYear: map['graduatedYear'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
