class UserProfile {
  final String id;
  final String userName;
  final String catName;
  final String catBreed; // 'orange', 'tabby', 'calico', 'black', 'white', 'siamese', 'tuxedo'
  final String catPersonality; // 'sweet', 'butler', 'playful', 'zen'
  final String callTerm; // 'sen', 'ban', 'chu_nhan', 'dong_chi', 'nguoi_anh_em' or custom
  final String eyeColor; // 'amber', 'ocean_blue', 'emerald', 'heterochromia'
  final double monthlyIncome;
  final double monthlyWorkHours;
  final double savingPercentage; // 0.0 - 100.0
  final String currency;
  final String reminderTime; // e.g. "20:00"
  final bool showWorkHours;
  final bool isDarkMode;
  final String? pinCode;
  final bool isOnboarded;

  const UserProfile({
    required this.id,
    this.userName = 'Bạn',
    this.catName = 'Mèo Xu',
    this.catBreed = 'orange',
    this.catPersonality = 'sweet',
    this.callTerm = 'sen',
    this.eyeColor = 'amber',
    this.monthlyIncome = 10000000.0,
    this.monthlyWorkHours = 176.0,
    this.savingPercentage = 20.0,
    this.currency = 'VNĐ',
    this.reminderTime = '20:30',
    this.showWorkHours = true,
    this.isDarkMode = false,
    this.pinCode,
    this.isOnboarded = false,
  });

  String get formattedCallTerm {
    switch (callTerm) {
      case 'sen':
        return 'Sen';
      case 'ban':
        return 'Bạn';
      case 'chu_nhan':
        return 'Chủ nhân';
      case 'dong_chi':
        return 'Đồng chí';
      case 'nguoi_anh_em':
        return 'Người anh em';
      default:
        return callTerm.isNotEmpty ? callTerm : 'Sen';
    }
  }

  UserProfile copyWith({
    String? id,
    String? userName,
    String? catName,
    String? catBreed,
    String? catPersonality,
    String? callTerm,
    String? eyeColor,
    double? monthlyIncome,
    double? monthlyWorkHours,
    double? savingPercentage,
    String? currency,
    String? reminderTime,
    bool? showWorkHours,
    bool? isDarkMode,
    String? pinCode,
    bool? isOnboarded,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      catName: catName ?? this.catName,
      catBreed: catBreed ?? this.catBreed,
      catPersonality: catPersonality ?? this.catPersonality,
      callTerm: callTerm ?? this.callTerm,
      eyeColor: eyeColor ?? this.eyeColor,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyWorkHours: monthlyWorkHours ?? this.monthlyWorkHours,
      savingPercentage: savingPercentage ?? this.savingPercentage,
      currency: currency ?? this.currency,
      reminderTime: reminderTime ?? this.reminderTime,
      showWorkHours: showWorkHours ?? this.showWorkHours,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      pinCode: pinCode ?? this.pinCode,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_name': userName,
      'cat_name': catName,
      'cat_breed': catBreed,
      'cat_personality': catPersonality,
      'call_term': callTerm,
      'eye_color': eyeColor,
      'monthly_income': monthlyIncome,
      'monthly_work_hours': monthlyWorkHours,
      'saving_percentage': savingPercentage,
      'currency': currency,
      'reminder_time': reminderTime,
      'show_work_hours': showWorkHours ? 1 : 0,
      'is_dark_mode': isDarkMode ? 1 : 0,
      'pin_code': pinCode,
      'is_onboarded': isOnboarded ? 1 : 0,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? 'default_user',
      userName: map['user_name']?.toString() ?? 'Bạn',
      catName: map['cat_name']?.toString() ?? 'Mèo Xu',
      catBreed: map['cat_breed']?.toString() ?? 'orange',
      catPersonality: map['cat_personality']?.toString() ?? 'sweet',
      callTerm: map['call_term']?.toString() ?? 'sen',
      eyeColor: map['eye_color']?.toString() ?? 'amber',
      monthlyIncome: (map['monthly_income'] as num?)?.toDouble() ?? 10000000.0,
      monthlyWorkHours:
          (map['monthly_work_hours'] as num?)?.toDouble() ?? 176.0,
      savingPercentage: (map['saving_percentage'] as num?)?.toDouble() ?? 20.0,
      currency: map['currency']?.toString() ?? 'VNĐ',
      reminderTime: map['reminder_time']?.toString() ?? '20:30',
      showWorkHours:
          (map['show_work_hours'] == 1 || map['show_work_hours'] == true),
      isDarkMode: (map['is_dark_mode'] == 1 || map['is_dark_mode'] == true),
      pinCode: map['pin_code']?.toString(),
      isOnboarded: (map['is_onboarded'] == 1 || map['is_onboarded'] == true),
    );
  }
}
