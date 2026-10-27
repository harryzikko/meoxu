class StreakState {
  final int currentStreak;
  final int recordStreak;
  final int freezeCardsLeft;
  final DateTime? lastRecordDate;

  const StreakState({
    this.currentStreak = 0,
    this.recordStreak = 0,
    this.freezeCardsLeft = 2,
    this.lastRecordDate,
  });

  StreakState copyWith({
    int? currentStreak,
    int? recordStreak,
    int? freezeCardsLeft,
    DateTime? lastRecordDate,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      recordStreak: recordStreak ?? this.recordStreak,
      freezeCardsLeft: freezeCardsLeft ?? this.freezeCardsLeft,
      lastRecordDate: lastRecordDate ?? this.lastRecordDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'current_streak': currentStreak,
      'record_streak': recordStreak,
      'freeze_cards_left': freezeCardsLeft,
      'last_record_date': lastRecordDate?.toIso8601String(),
    };
  }

  factory StreakState.fromMap(Map<String, dynamic> map) {
    return StreakState(
      currentStreak: map['current_streak'] as int? ?? 0,
      recordStreak: map['record_streak'] as int? ?? 0,
      freezeCardsLeft: map['freeze_cards_left'] as int? ?? 2,
      lastRecordDate: map['last_record_date'] != null
          ? DateTime.tryParse(map['last_record_date'].toString())
          : null,
    );
  }
}
