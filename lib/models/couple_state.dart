class CoupleProfile {
  final String userNickname;
  final String partnerName;
  final String partnerCatName;
  final String partnerCatBreed;
  final int daysTogether;
  final double partnerFishPercentage; // 0.0 - 1.0
  final String partnerStatusLabel; // 'An tâm 🌿', 'Vui vẻ ✨', 'Cảnh báo 🍲'
  final int partnerSafeDays; // out of 7
  final int userSafeDays; // out of 7
  final String connectCode;

  const CoupleProfile({
    this.userNickname = 'Linh',
    this.partnerName = 'Nam',
    this.partnerCatName = 'Bé Miu',
    this.partnerCatBreed = 'white',
    this.daysTogether = 48,
    this.partnerFishPercentage = 0.65,
    this.partnerStatusLabel = 'Vui vẻ ✨',
    this.partnerSafeDays = 5,
    this.userSafeDays = 6,
    this.connectCode = 'MEOXU-NAMLINH',
  });

  CoupleProfile copyWith({
    String? userNickname,
    String? partnerName,
    String? partnerCatName,
    String? partnerCatBreed,
    int? daysTogether,
    double? partnerFishPercentage,
    String? partnerStatusLabel,
    int? partnerSafeDays,
    int? userSafeDays,
    String? connectCode,
  }) {
    return CoupleProfile(
      userNickname: userNickname ?? this.userNickname,
      partnerName: partnerName ?? this.partnerName,
      partnerCatName: partnerCatName ?? this.partnerCatName,
      partnerCatBreed: partnerCatBreed ?? this.partnerCatBreed,
      daysTogether: daysTogether ?? this.daysTogether,
      partnerFishPercentage: partnerFishPercentage ?? this.partnerFishPercentage,
      partnerStatusLabel: partnerStatusLabel ?? this.partnerStatusLabel,
      partnerSafeDays: partnerSafeDays ?? this.partnerSafeDays,
      userSafeDays: userSafeDays ?? this.userSafeDays,
      connectCode: connectCode ?? this.connectCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_nickname': userNickname,
      'partner_name': partnerName,
      'partner_cat_name': partnerCatName,
      'partner_cat_breed': partnerCatBreed,
      'days_together': daysTogether,
      'partner_fish_percentage': partnerFishPercentage,
      'partner_status_label': partnerStatusLabel,
      'partner_safe_days': partnerSafeDays,
      'user_safe_days': userSafeDays,
      'connect_code': connectCode,
    };
  }

  factory CoupleProfile.fromMap(Map<String, dynamic> map) {
    return CoupleProfile(
      userNickname: map['user_nickname']?.toString() ?? 'Linh',
      partnerName: map['partner_name']?.toString() ?? 'Nam',
      partnerCatName: map['partner_cat_name']?.toString() ?? 'Bé Miu',
      partnerCatBreed: map['partner_cat_breed']?.toString() ?? 'white',
      daysTogether: (map['days_together'] as num?)?.toInt() ?? 48,
      partnerFishPercentage:
          (map['partner_fish_percentage'] as num?)?.toDouble() ?? 0.65,
      partnerStatusLabel:
          map['partner_status_label']?.toString() ?? 'Vui vẻ ✨',
      partnerSafeDays: (map['partner_safe_days'] as num?)?.toInt() ?? 5,
      userSafeDays: (map['user_safe_days'] as num?)?.toInt() ?? 6,
      connectCode: map['connect_code']?.toString() ?? 'MEOXU-NAMLINH',
    );
  }
}

class CoupleGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double userContribution;
  final double partnerContribution;
  final DateTime targetDate;
  final String status; // 'active', 'completed', 'disbursed'

  const CoupleGoal({
    required this.id,
    this.title = 'Chuyến trốn phố Đà Lạt 🌲🏕️',
    this.targetAmount = 10000000.0,
    this.userContribution = 3500000.0,
    this.partnerContribution = 3300000.0,
    required this.targetDate,
    this.status = 'active',
  });

  double get currentAmount => userContribution + partnerContribution;
  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, targetAmount);
  double get progressPercentage => (currentAmount / targetAmount).clamp(0.0, 1.0);
  bool get isCompleted => currentAmount >= targetAmount;

  double get userPercentage =>
      targetAmount > 0 ? (userContribution / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get partnerPercentage =>
      targetAmount > 0 ? (partnerContribution / targetAmount).clamp(0.0, 1.0) : 0.0;

  CoupleGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? userContribution,
    double? partnerContribution,
    DateTime? targetDate,
    String? status,
  }) {
    return CoupleGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      userContribution: userContribution ?? this.userContribution,
      partnerContribution: partnerContribution ?? this.partnerContribution,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'user_contribution': userContribution,
      'partner_contribution': partnerContribution,
      'target_date': targetDate.toIso8601String(),
      'status': status,
    };
  }

  factory CoupleGoal.fromMap(Map<String, dynamic> map) {
    return CoupleGoal(
      id: map['id']?.toString() ?? 'goal_1',
      title: map['title']?.toString() ?? 'Chuyến trốn phố Đà Lạt 🌲🏕️',
      targetAmount: (map['target_amount'] as num?)?.toDouble() ?? 10000000.0,
      userContribution:
          (map['user_contribution'] as num?)?.toDouble() ?? 3500000.0,
      partnerContribution:
          (map['partner_contribution'] as num?)?.toDouble() ?? 3300000.0,
      targetDate: DateTime.tryParse(map['target_date']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 45)),
      status: map['status']?.toString() ?? 'active',
    );
  }
}

class CoupleContribution {
  final String id;
  final String goalId;
  final String contributorName;
  final double amount;
  final String message;
  final DateTime dateTime;

  const CoupleContribution({
    required this.id,
    required this.goalId,
    required this.contributorName,
    required this.amount,
    required this.message,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'contributor_name': contributorName,
      'amount': amount,
      'message': message,
      'date_time': dateTime.toIso8601String(),
    };
  }

  factory CoupleContribution.fromMap(Map<String, dynamic> map) {
    return CoupleContribution(
      id: map['id']?.toString() ?? '',
      goalId: map['goal_id']?.toString() ?? '',
      contributorName: map['contributor_name']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      message: map['message']?.toString() ?? '',
      dateTime: DateTime.tryParse(map['date_time']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class CoupleChallenge {
  final String title;
  final String rule;
  final String penalty;
  final String userStatus;
  final String partnerStatus;

  const CoupleChallenge({
    this.title = 'Kèo Đãi Ăn Cuối Tuần',
    this.rule =
        'Ai lỡ để vơi đĩa cá quá hạn mức trước sẽ đãi người kia một nồi lẩu Thái chua cay full topping tối Chủ Nhật!',
    this.penalty = 'Nồi lẩu Thái chua cay',
    this.userStatus = 'Phong độ đỉnh cao ✨',
    this.partnerStatus = 'Nguy cơ đãi ăn! 🍲',
  });
}

class CoupleLoveNote {
  final String id;
  final String sender;
  final String timeText;
  final String message;
  final bool isRead;

  const CoupleLoveNote({
    required this.id,
    required this.sender,
    required this.timeText,
    required this.message,
    this.isRead = false,
  });
}
