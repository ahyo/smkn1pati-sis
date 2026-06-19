enum PaymentMethod {
  cash,
  bankTransfer,
  gateway,
  virtualAccount;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.bankTransfer:
        return 'Transfer Bank';
      case PaymentMethod.gateway:
        return 'Payment Gateway';
      case PaymentMethod.virtualAccount:
        return 'Virtual Account';
    }
  }

  static PaymentMethod fromString(String? v) =>
      PaymentMethod.values.firstWhere(
        (e) => e.name == v,
        orElse: () => PaymentMethod.cash,
      );
}

enum TransactionStatus {
  pending,
  confirmed,
  rejected,
  expired;

  String get label {
    switch (this) {
      case TransactionStatus.pending:
        return 'Menunggu Konfirmasi';
      case TransactionStatus.confirmed:
        return 'Dikonfirmasi';
      case TransactionStatus.rejected:
        return 'Ditolak';
      case TransactionStatus.expired:
        return 'Kadaluarsa';
    }
  }

  static TransactionStatus fromString(String? v) =>
      TransactionStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => TransactionStatus.pending,
      );
}

class PaymentTransaction {
  final String id;
  final String billId;
  final String studentId;
  final int amount;
  final PaymentMethod method;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? confirmedByAdminId;
  final String? proofNote; // catatan/deskripsi bukti bayar dari siswa
  final String? receiptNumber;
  final String? gatewayRef; // referensi dari payment gateway
  final String? virtualAccountNumber;
  final DateTime? vaExpiredAt;
  final String? rejectionReason;

  const PaymentTransaction({
    required this.id,
    required this.billId,
    required this.studentId,
    required this.amount,
    required this.method,
    this.status = TransactionStatus.pending,
    required this.createdAt,
    this.confirmedAt,
    this.confirmedByAdminId,
    this.proofNote,
    this.receiptNumber,
    this.gatewayRef,
    this.virtualAccountNumber,
    this.vaExpiredAt,
    this.rejectionReason,
  });

  bool get isPending => status == TransactionStatus.pending;
  bool get isConfirmed => status == TransactionStatus.confirmed;

  PaymentTransaction copyWith({
    TransactionStatus? status,
    DateTime? confirmedAt,
    String? confirmedByAdminId,
    String? receiptNumber,
    String? rejectionReason,
  }) {
    return PaymentTransaction(
      id: id,
      billId: billId,
      studentId: studentId,
      amount: amount,
      method: method,
      status: status ?? this.status,
      createdAt: createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      confirmedByAdminId: confirmedByAdminId ?? this.confirmedByAdminId,
      proofNote: proofNote,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      gatewayRef: gatewayRef,
      virtualAccountNumber: virtualAccountNumber,
      vaExpiredAt: vaExpiredAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toMap() => {
        'billId': billId,
        'studentId': studentId,
        'amount': amount,
        'method': method.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'confirmedAt': confirmedAt?.toIso8601String(),
        'confirmedByAdminId': confirmedByAdminId,
        'proofNote': proofNote,
        'receiptNumber': receiptNumber,
        'gatewayRef': gatewayRef,
        'virtualAccountNumber': virtualAccountNumber,
        'vaExpiredAt': vaExpiredAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
      };

  factory PaymentTransaction.fromMap(String id, Map<String, dynamic> map) {
    return PaymentTransaction(
      id: id,
      billId: map['billId'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      method: PaymentMethod.fromString(map['method'] as String?),
      status: TransactionStatus.fromString(map['status'] as String?),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      confirmedAt: map['confirmedAt'] != null
          ? DateTime.tryParse(map['confirmedAt'] as String)
          : null,
      confirmedByAdminId: map['confirmedByAdminId'] as String?,
      proofNote: map['proofNote'] as String?,
      receiptNumber: map['receiptNumber'] as String?,
      gatewayRef: map['gatewayRef'] as String?,
      virtualAccountNumber: map['virtualAccountNumber'] as String?,
      vaExpiredAt: map['vaExpiredAt'] != null
          ? DateTime.tryParse(map['vaExpiredAt'] as String)
          : null,
      rejectionReason: map['rejectionReason'] as String?,
    );
  }
}
