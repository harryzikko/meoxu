class BadgeItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  BadgeItem copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return BadgeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  static List<BadgeItem> defaultBadges = [
    const BadgeItem(
      id: 'first_record',
      title: 'Khoản chi đầu tiên',
      description: 'Làm quen với Mèo Xu bằng giao dịch đầu tiên',
      icon: '🐾',
      isUnlocked: false,
    ),
    const BadgeItem(
      id: 'streak_7',
      title: '7 ngày bền bỉ',
      description: 'Ghi chép liên tục 7 ngày cùng mèo',
      icon: '🔥',
      isUnlocked: false,
    ),
    const BadgeItem(
      id: 'no_regret_week',
      title: 'Tuần không hối hận',
      description: 'Cả tuần không có khoản chi nào gắn nhãn hối hận',
      icon: '✨',
      isUnlocked: false,
    ),
    const BadgeItem(
      id: 'early_bird',
      title: 'Dậy sớm cùng mèo',
      description: 'Ghi nhận giao dịch trước 7h sáng',
      icon: '🌅',
      isUnlocked: false,
    ),
    const BadgeItem(
      id: 'fish_collector',
      title: 'Kho cá khô đầy',
      description: 'Tích lũy được trên 200 điểm cá khô',
      icon: '🐟',
      isUnlocked: false,
    ),
  ];
}
