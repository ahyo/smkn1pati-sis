class PaymentCategory {
  final String id;
  final String name;
  final String? description;
  final int defaultAmount; // dalam rupiah
  final bool isRecurringMonthly; // true = SPP bulanan

  const PaymentCategory({
    required this.id,
    required this.name,
    this.description,
    required this.defaultAmount,
    this.isRecurringMonthly = false,
  });

  PaymentCategory copyWith({
    String? name,
    String? description,
    int? defaultAmount,
    bool? isRecurringMonthly,
  }) {
    return PaymentCategory(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultAmount: defaultAmount ?? this.defaultAmount,
      isRecurringMonthly: isRecurringMonthly ?? this.isRecurringMonthly,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'defaultAmount': defaultAmount,
        'isRecurringMonthly': isRecurringMonthly,
      };

  factory PaymentCategory.fromMap(String id, Map<String, dynamic> map) {
    return PaymentCategory(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      defaultAmount: (map['defaultAmount'] as num?)?.toInt() ?? 0,
      isRecurringMonthly: map['isRecurringMonthly'] as bool? ?? false,
    );
  }
}
