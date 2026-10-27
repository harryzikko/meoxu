import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/badge_item.dart';
import '../../providers/profile_provider.dart';
import '../../providers/cat_provider.dart';
import '../home/widgets/meo_mascot_widget.dart';

class CatHouseScreen extends ConsumerStatefulWidget {
  const CatHouseScreen({super.key});

  @override
  ConsumerState<CatHouseScreen> createState() => _CatHouseScreenState();
}

class _CatHouseScreenState extends ConsumerState<CatHouseScreen> {
  final List<Map<String, dynamic>> _accessories = [
    {'id': 'bell_collar', 'name': 'Túi tiền & Chuông', 'cost': 0, 'icon': '🔔'},
    {'id': 'bow_tie', 'name': 'Nơ đỏ thanh lịch', 'cost': 20, 'icon': '🎀'},
    {'id': 'glasses', 'name': 'Kính tròn tri thức', 'cost': 35, 'icon': '👓'},
    {'id': 'wizard_hat', 'name': 'Mũ phù thủy', 'cost': 50, 'icon': '🧙'},
    {'id': 'warm_scarf', 'name': 'Khăn len ấm áp', 'cost': 40, 'icon': '🧣'},
  ];

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final catState = ref.watch(catProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nhà của ${profile.catName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Cat Room Showcase Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Column(
                children: [
                  // Cat level & Points
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Cấp ${catState.cat.level}: ${catState.cat.levelTitle}',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Text('🐟', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '${catState.cat.fishPoints} cá khô',
                              style: AppTypography.labelLarge.copyWith(color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Big Center Mascot
                  MeoMascotWidget(
                    mood: catState.cat.currentMood,
                    breed: profile.catBreed,
                    equippedAccessories: catState.cat.equippedAccessories,
                    size: 190,
                  ),
                  const SizedBox(height: 14),

                  // Streak Status Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('🔥 ${catState.streak.currentStreak} ngày', style: AppTypography.titleMedium),
                            Text('Chuỗi hiện tại', style: AppTypography.caption),
                          ],
                        ),
                        Container(width: 1, height: 30, color: AppColors.border),
                        Column(
                          children: [
                            Text('🏆 ${catState.streak.recordStreak} ngày', style: AppTypography.titleMedium),
                            Text('Kỷ lục cao nhất', style: AppTypography.caption),
                          ],
                        ),
                        Container(width: 1, height: 30, color: AppColors.border),
                        Column(
                          children: [
                            Text('🧊 ${catState.streak.freezeCardsLeft}', style: AppTypography.titleMedium),
                            Text('Thẻ nghỉ còn', style: AppTypography.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Accessories Wardrobe Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tủ đồ phụ kiện cho mèo', style: AppTypography.titleMedium),
                Text(
                  'Dùng cá khô để đổi',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._accessories.map((acc) {
              final id = acc['id'] as String;
              final isUnlocked = catState.cat.unlockedAccessories.contains(id);
              final isEquipped = catState.cat.equippedAccessories.contains(id);
              final cost = acc['cost'] as int;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isEquipped ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.border),
                    width: isEquipped ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Text(acc['icon'] as String, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(acc['name'] as String, style: AppTypography.titleMedium.copyWith(fontSize: 15)),
                          Text(
                            isUnlocked ? (isEquipped ? 'Đang mặc' : 'Đã sở hữu') : 'Giá: $cost 🐟',
                            style: AppTypography.caption.copyWith(
                              color: isEquipped ? AppColors.primaryDark : AppColors.textTertiary,
                              fontWeight: isEquipped ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnlocked)
                      ElevatedButton(
                        onPressed: () {
                          ref.read(catProvider.notifier).toggleEquipAccessory(id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEquipped ? AppColors.surfaceVariant : AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: Text(
                          isEquipped ? 'Tháo ra' : 'Mặc vào',
                          style: const TextStyle(fontSize: 13),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: catState.cat.fishPoints >= cost
                            ? () async {
                                final ok = await ref.read(catProvider.notifier).unlockAccessory(id, cost);
                                if (ok && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã mở khóa ${acc['name']}!')),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: const Text('Mở khóa', style: TextStyle(fontSize: 13)),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Badges Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Bộ sưu tập huy hiệu', style: AppTypography.titleMedium),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: BadgeItem.defaultBadges.length,
              itemBuilder: (context, index) {
                final badge = BadgeItem.defaultBadges[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(badge.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 6),
                      Text(
                        badge.title,
                        style: AppTypography.titleMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        badge.description,
                        style: AppTypography.caption.copyWith(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
