enum CatMood {
  happy, // Chi tiêu trong mức cho phép
  sleeping, // Chưa có khoản chi nào hôm nay
  excited, // Vừa ghi xong một khoản chi
  worried, // Còn dưới 20% mức tiêu hôm nay
  confused, // Vượt mức tiêu hôm nay (không trách móc)
  dancing, // Đạt chuỗi 7 ngày liên tục
  hungry, // Quá 24h chưa ghi chép
}

class CatState {
  final int level; // 1: Mèo con, 2: Mèo trẻ, 3: Mèo trưởng thành, 4: Mèo thông thái
  final int fishPoints;
  final List<String> unlockedAccessories;
  final List<String> equippedAccessories;
  final List<String> unlockedFurniture;
  final List<String> equippedFurniture;
  final CatMood currentMood;

  const CatState({
    this.level = 1,
    this.fishPoints = 50, // Starting bonus fish
    this.unlockedAccessories = const ['bell_collar'],
    this.equippedAccessories = const ['bell_collar'],
    this.unlockedFurniture = const ['cushion_mat'],
    this.equippedFurniture = const ['cushion_mat'],
    this.currentMood = CatMood.sleeping,
  });

  String get levelTitle {
    switch (level) {
      case 1:
        return 'Mèo con thơ ngây';
      case 2:
        return 'Mèo trẻ năng động';
      case 3:
        return 'Mèo trưởng thành';
      case 4:
        return 'Mèo thông thái giữ xu';
      default:
        return 'Mèo con';
    }
  }

  CatState copyWith({
    int? level,
    int? fishPoints,
    List<String>? unlockedAccessories,
    List<String>? equippedAccessories,
    List<String>? unlockedFurniture,
    List<String>? equippedFurniture,
    CatMood? currentMood,
  }) {
    return CatState(
      level: level ?? this.level,
      fishPoints: fishPoints ?? this.fishPoints,
      unlockedAccessories: unlockedAccessories ?? this.unlockedAccessories,
      equippedAccessories: equippedAccessories ?? this.equippedAccessories,
      unlockedFurniture: unlockedFurniture ?? this.unlockedFurniture,
      equippedFurniture: equippedFurniture ?? this.equippedFurniture,
      currentMood: currentMood ?? this.currentMood,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'fish_points': fishPoints,
      'unlocked_accessories': unlockedAccessories.join(','),
      'equipped_accessories': equippedAccessories.join(','),
      'unlocked_furniture': unlockedFurniture.join(','),
      'equipped_furniture': equippedFurniture.join(','),
      'current_mood': currentMood.name,
    };
  }

  factory CatState.fromMap(Map<String, dynamic> map) {
    return CatState(
      level: map['level'] as int? ?? 1,
      fishPoints: map['fish_points'] as int? ?? 50,
      unlockedAccessories: (map['unlocked_accessories'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? ['bell_collar'],
      equippedAccessories: (map['equipped_accessories'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? ['bell_collar'],
      unlockedFurniture: (map['unlocked_furniture'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? ['cushion_mat'],
      equippedFurniture: (map['equipped_furniture'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? ['cushion_mat'],
      currentMood: CatMood.values.firstWhere(
        (m) => m.name == map['current_mood'],
        orElse: () => CatMood.sleeping,
      ),
    );
  }
}
