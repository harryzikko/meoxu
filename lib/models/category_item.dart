import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> keywords;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.keywords = const [],
  });

  static const List<CategoryItem> defaultCategories = [
    CategoryItem(
      id: 'food',
      name: 'Ăn uống',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF9E7D),
      keywords: ['ăn', 'bún', 'phở', 'cơm', 'cà phê', 'trà sữa'],
    ),
    CategoryItem(
      id: 'transport',
      name: 'Di chuyển',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF68B0AB),
      keywords: ['grab', 'xăng', 'gửi xe', 'bus', 'taxi'],
    ),
    CategoryItem(
      id: 'bills',
      name: 'Hóa đơn',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF8EC5FC),
      keywords: ['tiền nhà', 'điện', 'nước', 'wifi', 'internet'],
    ),
    CategoryItem(
      id: 'entertainment',
      name: 'Giải trí',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFFC39BD3),
      keywords: ['phim', 'game', 'du lịch', 'netflix'],
    ),
    CategoryItem(
      id: 'shopping',
      name: 'Mua sắm',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFFFB26B),
      keywords: ['mua', 'shopee', 'lazada', 'quần áo'],
    ),
    CategoryItem(
      id: 'health',
      name: 'Sức khỏe',
      icon: Icons.favorite_rounded,
      color: Color(0xFFF28B9B),
      keywords: ['thuốc', 'khám', 'gym', 'bác sĩ'],
    ),
    CategoryItem(
      id: 'income',
      name: 'Thu nhập',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF7ED6A5),
      keywords: ['lương', 'thưởng', 'được cho', 'tiền về'],
    ),
    CategoryItem(
      id: 'other',
      name: 'Khác',
      icon: Icons.category_rounded,
      color: Color(0xFFB5A699),
      keywords: [],
    ),
  ];

  static CategoryItem getById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => defaultCategories.last,
    );
  }
}
