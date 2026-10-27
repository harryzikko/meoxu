enum TransactionType { expense, income }

class ParserResult {
  final double amount;
  final String note;
  final String categoryId;
  final String categoryName;
  final DateTime dateTime;
  final TransactionType type;
  final double confidence; // 0.0 - 1.0

  const ParserResult({
    required this.amount,
    required this.note,
    required this.categoryId,
    required this.categoryName,
    required this.dateTime,
    this.type = TransactionType.expense,
    this.confidence = 1.0,
  });

  ParserResult copyWith({
    double? amount,
    String? note,
    String? categoryId,
    String? categoryName,
    DateTime? dateTime,
    TransactionType? type,
    double? confidence,
  }) {
    return ParserResult(
      amount: amount ?? this.amount,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
    );
  }
}
