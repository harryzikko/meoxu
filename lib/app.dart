import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'providers/profile_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/transactions/transactions_screen.dart';
import 'features/cat_letter/cat_letter_screen.dart';
import 'features/cat_house/cat_house_screen.dart';

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
        onNavigateToCatHouse: () => setState(() => _currentIndex = 3),
      ),
      const TransactionsScreen(),
      const CatLetterScreen(),
      const CatHouseScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        indicatorColor: AppColors.primaryLight.withOpacity(0.5),
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cottage_outlined),
            selectedIcon: Icon(
              Icons.cottage_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'Hôm nay',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'Sổ chi tiêu',
          ),
          NavigationDestination(
            icon: Icon(Icons.mark_email_read_outlined),
            selectedIcon: Icon(
              Icons.mark_email_read_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'Thư của Mèo',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(
              Icons.pets_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'Góc của Mèo',
          ),
        ],
      ),
    );
  }
}
