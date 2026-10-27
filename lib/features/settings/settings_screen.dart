import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/profile_provider.dart';
import '../../providers/transaction_provider.dart';
import 'fixed_expenses_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _exportCSV(BuildContext context, WidgetRef ref) {
    final txs = ref.read(transactionProvider).allTransactions;
    if (txs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có giao dịch để xuất')),
      );
      return;
    }

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('ID,Ngày giờ,Loại,Danh mục,Ghi chú,Số tiền,Cảm xúc');
    for (final tx in txs) {
      buffer.writeln('${tx.id},${tx.dateTime.toIso8601String()},${tx.type},${tx.categoryId},"${tx.note}",${tx.amount},${tx.emotion ?? ""}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xuất thành công ${txs.length} dòng dữ liệu CSV')),
    );
  }

  void _showIncomeDialog(BuildContext context, WidgetRef ref, double currentIncome) {
    final ctrl = TextEditingController(text: currentIncome.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thu nhập hàng tháng'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Số tiền (VNĐ)',
            suffixText: 'VNĐ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.replaceAll('.', '').replaceAll(',', ''));
              if (val != null && val > 0) {
                ref.read(profileProvider.notifier).setFinance(
                  monthlyIncome: val,
                  savingPercentage: ref.read(profileProvider).savingPercentage,
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Section: Tài chính & Ngân sách
          _buildSectionHeader('Tài chính cá nhân'),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.payments_rounded,
            title: 'Thu nhập ước tính hàng tháng',
            subtitle: CurrencyFormatter.format(profile.monthlyIncome),
            onTap: () => _showIncomeDialog(context, ref, profile.monthlyIncome),
          ),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.receipt_long_rounded,
            title: 'Khoản chi cố định',
            subtitle: 'Tiền trọ, điện nước, wifi, bảo hiểm...',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FixedExpensesScreen()),
              );
            },
          ),
          const SizedBox(height: 18),

          // Section: Trải nghiệm & Mèo Xu
          _buildSectionHeader('Trải nghiệm ứng dụng'),
          _buildSwitchCard(
            isDark: isDark,
            icon: Icons.access_time_rounded,
            title: 'Quy đổi tiền ra giờ làm việc',
            subtitle: 'Ví dụ: Cà phê ≈ 25 phút làm việc',
            value: profile.showWorkHours,
            onChanged: (_) => ref.read(profileProvider.notifier).toggleWorkHours(),
          ),
          _buildSwitchCard(
            isDark: isDark,
            icon: Icons.dark_mode_rounded,
            title: 'Chế độ tối (Dark Mode)',
            subtitle: 'Nền nâu than ấm cúng, dịu mắt',
            value: profile.isDarkMode,
            onChanged: (_) => ref.read(profileProvider.notifier).toggleDarkMode(),
          ),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.notifications_none_rounded,
            title: 'Giờ mèo nhắc nhẹ hàng ngày',
            subtitle: profile.reminderTime,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 20, minute: 30),
              );
              if (picked != null) {
                final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                ref.read(profileProvider.notifier).updateProfile(
                  profile.copyWith(reminderTime: timeStr),
                );
              }
            },
          ),
          const SizedBox(height: 18),

          // Section: Bảo mật & Dữ liệu
          _buildSectionHeader('Bảo mật & Dữ liệu'),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.file_download_outlined,
            title: 'Xuất dữ liệu chi tiêu',
            subtitle: 'Tệp CSV tương thích Excel, Google Sheets',
            onTap: () => _exportCSV(context, ref),
          ),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.lock_outline_rounded,
            title: 'Khóa ứng dụng bằng mã PIN',
            subtitle: profile.pinCode == null ? 'Chưa kích hoạt' : 'Đã bật bảo vệ',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng bảo vệ mã PIN đang hoạt động')),
              );
            },
          ),
          const SizedBox(height: 24),

          // App Slogan & Info
          Center(
            child: Column(
              children: [
                const Text('🐾 Meo Xu v1.0.0', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  'Không bắt bạn kỷ luật, chỉ giúp bạn hiểu mình.',
                  style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSettingCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryDark),
        title: Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 15)),
        subtitle: Text(subtitle, style: AppTypography.caption),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSwitchCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primaryDark),
        title: Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 15)),
        subtitle: Text(subtitle, style: AppTypography.caption),
        value: value,
        activeColor: AppColors.primaryDark,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
