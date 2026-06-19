enum BillStatus {
  unpaid,
  partiallyPaid,
  paid,
  overdue;

  String get label {
    switch (this) {
      case BillStatus.unpaid:
        return 'Belum Bayar';
      case BillStatus.partiallyPaid:
        return 'Bayar Sebagian';
      case BillStatus.paid:
        return 'Lunas';
      case BillStatus.overdue:
        return 'Menunggak';
    }
  }

  static BillStatus fromString(String? v) => BillStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => BillStatus.unpaid,
      );
}

class PaymentBill {
  final String id;
  final String studentId;
  final String? classId;
  final String categoryId;
  final String title; // mis. "SPP Januari 2026"
  final int amount; // rupiah
  final int paidAmount; // sudah dibayar
  final DateTime dueDate;
  final BillStatus status;
  final int? month; // 1-12, hanya untuk SPP bulanan
  final int? year;
  final String? notes;
  final DateTime createdAt;
  final String? createdByAdminId;

  const PaymentBill({
    required this.id,
    required this.studentId,
    this.classId,
    required this.categoryId,
    required this.title,
    required this.amount,
    this.paidAmount = 0,
    required this.dueDate,
    this.status = BillStatus.unpaid,
    this.month,
    this.year,
    this.notes,
    required this.createdAt,
    this.createdByAdminId,
  });

  int get remainingAmount => amount - paidAmount;
  bool get isFullyPaid => status == BillStatus.paid;

  PaymentBill copyWith({
    String? categoryId,
    String? title,
    int? amount,
    int? paidAmount,
    DateTime? dueDate,
    BillStatus? status,
    String? notes,
  }) {
    return PaymentBill(
      id: id,
      studentId: studentId,
      classId: classId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      month: month,
      year: year,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      createdByAdminId: createdByAdminId,
    );
  }

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'classId': classId,
        'categoryId': categoryId,
        'title': title,
        'amount': amount,
        'paidAmount': paidAmount,
        'dueDate': dueDate.toIso8601String(),
        'status': status.name,
        'month': month,
        'year': year,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'createdByAdminId': createdByAdminId,
      };

  factory PaymentBill.fromMap(String id, Map<String, dynamic> map) {
    return PaymentBill(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      classId: map['classId'] as String?,
      categoryId: map['categoryId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      paidAmount: (map['paidAmount'] as num?)?.toInt() ?? 0,
      dueDate: DateTime.tryParse(map['dueDate'] as String? ?? '') ??
          DateTime.now(),
      status: BillStatus.fromString(map['status'] as String?),
      month: (map['month'] as num?)?.toInt(),
      year: (map['year'] as num?)?.toInt(),
      notes: map['notes'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      createdByAdminId: map['createdByAdminId'] as String?,
    );
  }
}
