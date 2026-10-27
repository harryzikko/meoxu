class WeeklyInsight {
  final String weekLabel;
  final double currentWeekTotal;
  final double previousWeekTotal;
  final List<String> discoveries;
  final String smallSuggestion;
  final String bestPraise;
  final bool hasEnoughData;

  const WeeklyInsight({
    required this.weekLabel,
    this.currentWeekTotal = 0.0,
    this.previousWeekTotal = 0.0,
    this.discoveries = const [],
    this.smallSuggestion =
        'Thử đợi 10 phút trước khi mua đồ online sau 22h nhé.',
    this.bestPraise =
        'Bạn đã rất chăm chỉ ghi chép và thấu hiểu chi tiêu của mình!',
    this.hasEnoughData = true,
  });
}
