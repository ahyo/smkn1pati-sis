enum AcademicYearStatus {
  active,
  inactive,
  archived;

  String get label {
    switch (this) {
      case AcademicYearStatus.active:
        return 'Aktif';
      case AcademicYearStatus.inactive:
        return 'Tidak Aktif';
      case AcademicYearStatus.archived:
        return 'Diarsipkan';
    }
  }

  static AcademicYearStatus fromString(String? v) =>
      AcademicYearStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => AcademicYearStatus.inactive,
      );
}

class AcademicYear {
  final String id;
  final String name; // mis. "2025/2026"
  final DateTime startDate;
  final DateTime endDate;
  final AcademicYearStatus status;
  final DateTime createdAt;
  final String? createdByAdminId;
  // Dicatat setelah proses kenaikan kelas dijalankan
  final DateTime? promotionRunAt;
  final String? promotionRunByAdminId;

  const AcademicYear({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.status = AcademicYearStatus.inactive,
    required this.createdAt,
    this.createdByAdminId,
    this.promotionRunAt,
    this.promotionRunByAdminId,
  });

  bool get isActive => status == AcademicYearStatus.active;
  bool get promotionDone => promotionRunAt != null;

  AcademicYear copyWith({
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    AcademicYearStatus? status,
    DateTime? promotionRunAt,
    String? promotionRunByAdminId,
  }) {
    return AcademicYear(
      id: id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt,
      createdByAdminId: createdByAdminId,
      promotionRunAt: promotionRunAt ?? this.promotionRunAt,
      promotionRunByAdminId:
          promotionRunByAdminId ?? this.promotionRunByAdminId,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'createdByAdminId': createdByAdminId,
        'promotionRunAt': promotionRunAt?.toIso8601String(),
        'promotionRunByAdminId': promotionRunByAdminId,
      };

  factory AcademicYear.fromMap(String id, Map<String, dynamic> map) {
    return AcademicYear(
      id: id,
      name: map['name'] as String? ?? '',
      startDate:
          DateTime.tryParse(map['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate:
          DateTime.tryParse(map['endDate'] as String? ?? '') ?? DateTime.now(),
      status: AcademicYearStatus.fromString(map['status'] as String?),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      createdByAdminId: map['createdByAdminId'] as String?,
      promotionRunAt: map['promotionRunAt'] != null
          ? DateTime.tryParse(map['promotionRunAt'] as String)
          : null,
      promotionRunByAdminId: map['promotionRunByAdminId'] as String?,
    );
  }
}
