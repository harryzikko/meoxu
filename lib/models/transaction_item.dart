enum EmotionType { happy, necessary, regret, impulsive }

class TransactionItem {
  final String id;
  final double amount;
  final String type; // 'expense' or 'income'
  final String categoryId;
  final String note;
  final DateTime dateTime;
  final String? emotion; // 'happy', 'necessary', 'regret', 'impulsive' or null
  final bool isFixed;
  final String source; // 'manual', 'voice', 'notification', 'receipt'
  final String status; // 'confirmed', 'pending'

  const TransactionItem({
    required this.id,
    required this.amount,
    this.type = 'expense',
    required this.categoryId,
    required this.note,
    required this.dateTime,
    this.emotion,
    this.isFixed = false,
    this.source = 'manual',
    this.status = 'confirmed',
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  TransactionItem copyWith({
    String? id,
    double? amount,
    String? type,
    String? categoryId,
    String? note,
    DateTime? dateTime,
    String? emotion,
    bool? isFixed,
    String? source,
    String? status,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
      emotion: emotion ?? this.emotion,
      isFixed: isFixed ?? this.isFixed,
      source: source ?? this.source,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'note': note,
      'date_time': dateTime.toIso8601String(),
      'emotion': emotion,
      'is_fixed': isFixed ? 1 : 0,
      'source': source,
      'status': status,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type']?.toString() ?? 'expense',
      categoryId: map['category_id']?.toString() ?? 'other',
      note: map['note']?.toString() ?? '',
      dateTime: DateTime.tryParse(map['date_time']?.toString() ?? '') ?? DateTime.now(),
      emotion: map['emotion']?.toString(),
      isFixed: map['is_fixed'] == 1 || map['is_fixed'] == true,
      source: map['source']?.toString() ?? 'manual',
      status: map['status']?.toString() ?? 'confirmed',
    );
  }
}
