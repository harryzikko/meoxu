class FixedExpense {
  final String id;
  final String name;
  final double amount;
  final int dayOfMonth; // 1 - 31

  const FixedExpense({
    required this.id,
    required this.name,
    required this.amount,
    this.dayOfMonth = 1,
  });

  FixedExpense copyWith({
    String? id,
    String? name,
    double? amount,
    int? dayOfMonth,
  }) {
    return FixedExpense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'day_of_month': dayOfMonth,
    };
  }

  factory FixedExpense.fromMap(Map<String, dynamic> map) {
    return FixedExpense(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dayOfMonth: (map['day_of_month'] as int?) ?? 1,
    );
  }
}
