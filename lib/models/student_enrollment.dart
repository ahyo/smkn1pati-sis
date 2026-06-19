import 'enrollment_status.dart';
import 'enrollment_type.dart';

class StudentEnrollment {
  final String id;
  final EnrollmentType type;
  final EnrollmentStatus status;

  // Data calon siswa
  final String fullName;
  final String email;
  final String? phone;
  final String? address;
  final String? gender;
  final DateTime? dateOfBirth;

  // Asal sekolah
  final String previousSchoolName;
  final String previousSchoolCity;
  final String previousSchoolType; // SD / SMP / SMA / SMK / dll

  // Kelas terakhir di sekolah asal (mis. "9", "6")
  final String? previousGradeLevel;

  // Khusus pindahan
  final String? transferReason;

  // Pilihan kelas yang diinginkan (opsional, diisi admin saat menyetujui)
  final String? requestedClassId;

  // Proses admin
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedByAdminId;
  final String? reviewNote;

  // Jika disetujui, ID user yang dibuat
  final String? approvedUserId;

  const StudentEnrollment({
    required this.id,
    required this.type,
    required this.status,
    required this.fullName,
    required this.email,
    this.phone,
    this.address,
    this.gender,
    this.dateOfBirth,
    required this.previousSchoolName,
    required this.previousSchoolCity,
    required this.previousSchoolType,
    this.previousGradeLevel,
    this.transferReason,
    this.requestedClassId,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedByAdminId,
    this.reviewNote,
    this.approvedUserId,
  });

  StudentEnrollment copyWith({
    EnrollmentType? type,
    EnrollmentStatus? status,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? gender,
    DateTime? dateOfBirth,
    String? previousSchoolName,
    String? previousSchoolCity,
    String? previousSchoolType,
    String? previousGradeLevel,
    String? transferReason,
    String? requestedClassId,
    DateTime? reviewedAt,
    String? reviewedByAdminId,
    String? reviewNote,
    String? approvedUserId,
  }) {
    return StudentEnrollment(
      id: id,
      type: type ?? this.type,
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      previousSchoolName: previousSchoolName ?? this.previousSchoolName,
      previousSchoolCity: previousSchoolCity ?? this.previousSchoolCity,
      previousSchoolType: previousSchoolType ?? this.previousSchoolType,
      previousGradeLevel: previousGradeLevel ?? this.previousGradeLevel,
      transferReason: transferReason ?? this.transferReason,
      requestedClassId: requestedClassId ?? this.requestedClassId,
      createdAt: createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedByAdminId: reviewedByAdminId ?? this.reviewedByAdminId,
      reviewNote: reviewNote ?? this.reviewNote,
      approvedUserId: approvedUserId ?? this.approvedUserId,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'status': status.name,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'previousSchoolName': previousSchoolName,
        'previousSchoolCity': previousSchoolCity,
        'previousSchoolType': previousSchoolType,
        'previousGradeLevel': previousGradeLevel,
        'transferReason': transferReason,
        'requestedClassId': requestedClassId,
        'createdAt': createdAt.toIso8601String(),
        'reviewedAt': reviewedAt?.toIso8601String(),
        'reviewedByAdminId': reviewedByAdminId,
        'reviewNote': reviewNote,
        'approvedUserId': approvedUserId,
      };

  factory StudentEnrollment.fromMap(String id, Map<String, dynamic> map) {
    return StudentEnrollment(
      id: id,
      type: EnrollmentType.fromString(map['type'] as String?),
      status: EnrollmentStatus.fromString(map['status'] as String?),
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      gender: map['gender'] as String?,
      dateOfBirth: map['dateOfBirth'] == null
          ? null
          : DateTime.tryParse(map['dateOfBirth'] as String),
      previousSchoolName: map['previousSchoolName'] as String? ?? '',
      previousSchoolCity: map['previousSchoolCity'] as String? ?? '',
      previousSchoolType: map['previousSchoolType'] as String? ?? '',
      previousGradeLevel: map['previousGradeLevel'] as String?,
      transferReason: map['transferReason'] as String?,
      requestedClassId: map['requestedClassId'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      reviewedAt: map['reviewedAt'] == null
          ? null
          : DateTime.tryParse(map['reviewedAt'] as String),
      reviewedByAdminId: map['reviewedByAdminId'] as String?,
      reviewNote: map['reviewNote'] as String?,
      approvedUserId: map['approvedUserId'] as String?,
    );
  }
}
