import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'providers/profile_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/transactions/transactions_screen.dart';
import 'features/what_if/what_if_screen.dart';
import 'features/cat_letter/cat_letter_screen.dart';
import 'features/cat_house/cat_house_screen.dart';
import 'features/settings/settings_screen.dart';

class MeoXuApp extends ConsumerWidget {
  const MeoXuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return MaterialApp(
      title: 'Meo Xu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: profile.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: profile.isOnboarded
          ? const MainNavigationScaffold()
          : OnboardingScreen(
              onFinish: () {
                ref.read(profileProvider.notifier).completeOnboarding();
              },
            ),
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(
        onNavigateToTransactions: () => setState(() => _currentIndex = 1),
        onNavigateToCatHouse: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CatHouseScreen()),
          );
        },
      ),
      const TransactionsScreen(),
      const WhatIfScreen(),
      const CatLetterScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        indicatorColor: AppColors.primaryLight.withOpacity(0.5),
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryDark),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primaryDark),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppColors.primaryDark),
            label: 'Nếu như',
          ),
          NavigationDestination(
            icon: Icon(Icons.mark_email_unread_outlined),
            selectedIcon: Icon(Icons.mark_email_unread_rounded, color: AppColors.primaryDark),
            label: 'Thư mèo',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primaryDark),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
