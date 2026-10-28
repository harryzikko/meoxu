import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/cat_dialogues.dart';
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
  int _selectedTabIndex = 0; // 0: Tủ đồ, 1: Cá nhân hóa, 2: Kỷ niệm
  String? _catSpeech;

  final List<Map<String, dynamic>> _accessories = [
    {'id': 'bell_collar', 'name': 'Túi tiền & Chuông', 'cost': 0, 'icon': '🔔'},
    {'id': 'bow_tie', 'name': 'Nơ đỏ thanh lịch', 'cost': 20, 'icon': '🎀'},
    {'id': 'glasses', 'name': 'Kính tròn tri thức', 'cost': 35, 'icon': '👓'},
    {'id': 'chef_hat', 'name': 'Mũ đầu bếp bánh cá', 'cost': 40, 'icon': '👨‍🍳'},
    {'id': 'flower_crown', 'name': 'Vòng hoa cúc nhí', 'cost': 45, 'icon': '🌸'},
    {'id': 'sunglasses', 'name': 'Kính râm cực ngầu', 'cost': 50, 'icon': '🕶️'},
    {'id': 'wizard_hat', 'name': 'Mũ phù thủy huyền bí', 'cost': 60, 'icon': '🧙'},
    {'id': 'fish_mouth', 'name': 'Ngậm cá tươi rủng rỉnh', 'cost': 30, 'icon': '🐟'},
    {'id': 'warm_scarf', 'name': 'Khăn len ấm áp', 'cost': 40, 'icon': '🧣'},
  ];

  final List<Map<String, dynamic>> _breeds = [
    {'id': 'orange', 'name': 'Mèo Cam', 'color': Color(0xFFFFB26B), 'desc': 'Ham ăn, mũm mĩm, ấm áp'},
    {'id': 'tabby', 'name': 'Mèo Mướp', 'color': Color(0xFFC7A788), 'desc': 'Lanh lợi, thân thiện, dễ nuôi'},
    {'id': 'calico', 'name': 'Tam Thể', 'color': Color(0xFFFFF9EE), 'desc': 'May mắn, độc đáo, đáng yêu'},
    {'id': 'black', 'name': 'Mèo Mun', 'color': Color(0xFF38353B), 'desc': 'Huyền bí, lém lỉnh, cá tính'},
    {'id': 'white', 'name': 'Mèo Trắng', 'color': Color(0xFFFAF7F2), 'desc': 'Bông tuyết, dịu dàng, tiểu thư'},
    {'id': 'siamese', 'name': 'Mèo Xiêm', 'color': Color(0xFFF2E6D8), 'desc': 'Mặt nạ socola, quý phái'},
    {'id': 'tuxedo', 'name': 'Tuxedo', 'color': Color(0xFF2C2F33), 'desc': 'Mặc vest lịch lãm, điềm đạm'},
  ];

  final List<Map<String, dynamic>> _eyeColors = [
    {'id': 'amber', 'name': 'Hổ phách', 'color': Color(0xFFF39C12), 'desc': 'Vàng mật ong ấm cúng'},
    {'id': 'ocean_blue', 'name': 'Xanh biển biếc', 'color': Color(0xFF00B4D8), 'desc': 'Biển xanh lấp lánh'},
    {'id': 'emerald', 'name': 'Ngọc lục bảo', 'color': Color(0xFF2ECC71), 'desc': 'Xanh ngọc bích kiêu sa'},
    {'id': 'heterochromia', 'name': 'Hai màu mắt', 'color': Color(0xFF8E44AD), 'desc': 'Odd eyes: 1 xanh biển, 1 vàng'},
  ];

  final List<Map<String, dynamic>> _personalities = [
    {
      'id': 'sweet',
      'name': 'Bé ngọt ngào',
      'icon': '🥰',
      'badge': 'Nuông chiều • Ngọt ngào',
      'quote': 'Sen ơi, xoa bụng meo một cái lấy hên nha! Meo yêu Sen nhất trần đời! ♥',
    },
    {
      'id': 'butler',
      'name': 'Quản gia mèo',
      'icon': '🎩',
      'badge': 'Lịch thiệp • Chu đáo',
      'quote': 'Thưa chủ nhân, hầu bao hôm nay được kiểm kê chu toàn. Kính chúc ngài bình an.',
    },
    {
      'id': 'playful',
      'name': 'Đồng chí mèo',
      'icon': '😎',
      'badge': 'Tưng tửng • Hài hước',
      'quote': 'Người anh em ơi! Tiêu lố tí thôi mà lo gì, mai ta lại gỡ sạch sành sanh!',
    },
    {
      'id': 'zen',
      'name': 'Mèo thiền tri kỷ',
      'icon': '🧘',
      'badge': 'An yên • Chữa lành',
      'quote': 'Hít một hơi thật sâu. Tiền là phương tiện, an lạc trong tâm mới là đích đến.',
    },
  ];

  final List<Map<String, String>> _callTerms = [
    {'id': 'sen', 'name': 'Sen', 'desc': 'Hoàng thượng gọi Sen'},
    {'id': 'ban', 'name': 'Bạn', 'desc': 'Bạn bè thân tình, bình đẳng'},
    {'id': 'chu_nhan', 'name': 'Chủ nhân', 'desc': 'Quý phái, tôn kính'},
    {'id': 'dong_chi', 'name': 'Đồng chí', 'desc': 'Đồng cam cộng khổ'},
    {'id': 'nguoi_anh_em', 'name': 'Người anh em', 'desc': 'Huynh đệ chí cốt'},
  ];

  void _onPetCat() {
    final profile = ref.read(profileProvider);
    final catState = ref.read(catProvider);

    final msg = CatDialogueEngine.getDialogue(
      personality: profile.catPersonality,
      callTerm: profile.formattedCallTerm,
      catName: profile.catName,
      userName: profile.userName,
      mood: catState.cat.currentMood,
      isPetting: true,
    );

    setState(() {
      _catSpeech = msg;
    });
  }

  void _showChangeCatNameDialog(BuildContext context, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    final quickNames = ['Bánh Mì', 'Đậu Phộng', 'Mochi', 'Bơ', 'Hạt Dẻ', 'Miu', 'Gạo'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            title: const Text('Đặt tên cho mèo cưng'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Tên mèo',
                    hintText: 'Nhập tên mèo yêu thích',
                    prefixIcon: Icon(Icons.pets),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Gợi ý tên đáng yêu:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: quickNames.map((name) {
                    return ActionChip(
                      label: Text(name, style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        ctrl.text = name;
                        setDlgState(() {});
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = ctrl.text.trim();
                  if (text.isNotEmpty) {
                    ref.read(profileProvider.notifier).updateCatCustomization(catName: text);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final catState = ref.watch(catProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final speechToShow = _catSpeech ??
        CatDialogueEngine.getDialogue(
          personality: profile.catPersonality,
          callTerm: profile.formattedCallTerm,
          catName: profile.catName,
          userName: profile.userName,
          mood: catState.cat.currentMood,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('Nhà của ${profile.catName}'),
        actions: [
          IconButton(
            tooltip: 'Đổi tên mèo',
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: () => _showChangeCatNameDialog(context, profile.catName),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            // Cat Room Showcase Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.primaryLight, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Cat level & Points
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('🐟', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '${catState.cat.fishPoints} cá khô',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Big Center Mascot with Interactive Petting
                  MeoMascotWidget(
                    mood: catState.cat.currentMood,
                    breed: profile.catBreed,
                    eyeColor: profile.eyeColor,
                    equippedAccessories: catState.cat.equippedAccessories,
                    size: 190,
                    onPet: _onPetCat,
                  ),
                  const SizedBox(height: 12),

                  // Cat Interactive Speech Bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface.withOpacity(0.9)
                          : Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primaryLight.withOpacity(0.7),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            speechToShow,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Pet Action Button
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _onPetCat();
                    },
                    icon: const Icon(Icons.favorite_rounded, color: AppColors.primaryDark, size: 18),
                    label: const Text('Xoa đầu nựng mèo 🐾', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: const BorderSide(color: AppColors.primaryDark, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Streak Status Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface.withOpacity(0.6)
                          : Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '🔥 ${catState.streak.currentStreak} ngày',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('Chuỗi hiện tại', style: AppTypography.caption),
                          ],
                        ),
                        Container(width: 1, height: 28, color: AppColors.border),
                        Column(
                          children: [
                            Text(
                              '🏆 ${catState.streak.recordStreak} ngày',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('Kỷ lục', style: AppTypography.caption),
                          ],
                        ),
                        Container(width: 1, height: 28, color: AppColors.border),
                        Column(
                          children: [
                            Text(
                              '🧊 ${catState.streak.freezeCardsLeft}',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('Thẻ nghỉ', style: AppTypography.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Segmented Bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildTabButton(0, '👗 Tủ đồ', isDark),
                  _buildTabButton(1, '✨ Cá nhân hóa', isDark),
                  _buildTabButton(2, '🏅 Kỷ niệm', isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Content
            if (_selectedTabIndex == 0)
              _buildWardrobeTab(context, profile, catState, isDark)
            else if (_selectedTabIndex == 1)
              _buildPersonalizationTab(context, profile, isDark)
            else
              _buildBadgesTab(isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title, bool isDark) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSurfaceVariant : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB 0: TỦ ĐỒ PHỤ KIỆN ---
  Widget _buildWardrobeTab(
    BuildContext context,
    dynamic profile,
    dynamic catState,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tủ đồ phụ kiện cho mèo', style: AppTypography.titleMedium),
            Text(
              'Đổi bằng cá khô 🐟',
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
                color: isEquipped
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.border),
                width: isEquipped ? 1.6 : 1.0,
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
                      Text(
                        acc['name'] as String,
                        style: AppTypography.titleMedium.copyWith(fontSize: 14.5),
                      ),
                      Text(
                        isUnlocked
                            ? (isEquipped ? 'Đang mặc' : 'Đã sở hữu')
                            : 'Giá: $cost 🐟 cá khô',
                        style: AppTypography.caption.copyWith(
                          color: isEquipped
                              ? AppColors.primaryDark
                              : AppColors.textTertiary,
                          fontWeight:
                              isEquipped ? FontWeight.w700 : FontWeight.w500,
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
                      backgroundColor: isEquipped
                          ? AppColors.surfaceVariant
                          : AppColors.primary,
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
                            final ok = await ref
                                .read(catProvider.notifier)
                                .unlockAccessory(id, cost);
                            if (ok && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã mở khóa ${acc['name']}! 🎉'),
                                ),
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
      ],
    );
  }

  // --- TAB 1: CÁ NHÂN HÓA MÈO CƯNG ---
  Widget _buildPersonalizationTab(
    BuildContext context,
    dynamic profile,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tên mèo & Xưng hô
        _buildSectionHeader('Tên & Cách xưng hô'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tên mèo cưng', style: AppTypography.caption),
                      Text(
                        profile.catName,
                        style: AppTypography.titleMedium.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showChangeCatNameDialog(context, profile.catName),
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Đổi tên'),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text('Mèo sẽ gọi bạn là gì?', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _callTerms.map((term) {
                  final isSelected = profile.callTerm == term['id'];
                  return ChoiceChip(
                    label: Text(term['name']!),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        ref.read(profileProvider.notifier).updateCatCustomization(callTerm: term['id']);
                      }
                    },
                    selectedColor: AppColors.primary,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Tính cách Mèo cưng
        _buildSectionHeader('Tính cách Mèo cưng'),
        ..._personalities.map((item) {
          final isSelected = profile.catPersonality == item['id'];
          return GestureDetector(
            onTap: () {
              ref.read(profileProvider.notifier).updateCatCustomization(catPersonality: item['id']);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['icon'] as String, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item['name'] as String,
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['badge'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['quote'] as String,
                          style: AppTypography.caption.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primaryDark, size: 20),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 14),

        // 3. Màu lông & Giống mèo
        _buildSectionHeader('Màu lông & Giống mèo'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            children: _breeds.map((breed) {
              final isSelected = profile.catBreed == breed['id'];
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: breed['color'] as Color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12, width: 2),
                  ),
                ),
                title: Text(
                  breed['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(breed['desc'] as String, style: const TextStyle(fontSize: 11)),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primaryDark)
                    : null,
                onTap: () {
                  ref.read(profileProvider.notifier).updateCatCustomization(catBreed: breed['id']);
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // 4. Màu mắt
        _buildSectionHeader('Màu mắt cưng'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            children: _eyeColors.map((eye) {
              final isSelected = profile.eyeColor == eye['id'];
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: eye['color'] as Color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: (eye['color'] as Color).withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                title: Text(
                  eye['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(eye['desc'] as String, style: const TextStyle(fontSize: 11)),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primaryDark)
                    : null,
                onTap: () {
                  ref.read(profileProvider.notifier).updateCatCustomization(eyeColor: eye['id']);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: HUY HIỆU ---
  Widget _buildBadgesTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bộ sưu tập huy hiệu', style: AppTypography.titleMedium),
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
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(badge.icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    badge.title,
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
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
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
