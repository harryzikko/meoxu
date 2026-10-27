import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../core/database/app_database.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(const UserProfile(id: 'default_user')) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await AppDatabase.instance.getProfile();
      state = profile;
    } catch (_) {}
  }

  Future<void> updateProfile(UserProfile updated) async {
    state = updated;
    await AppDatabase.instance.updateProfile(updated);
  }

  Future<void> setCatInfo(String name, String breed) async {
    final updated = state.copyWith(catName: name, catBreed: breed);
    await updateProfile(updated);
  }

  Future<void> setFinance({
    required double monthlyIncome,
    required double savingPercentage,
  }) async {
    final updated = state.copyWith(
      monthlyIncome: monthlyIncome,
      savingPercentage: savingPercentage,
    );
    await updateProfile(updated);
  }

  Future<void> toggleDarkMode() async {
    final updated = state.copyWith(isDarkMode: !state.isDarkMode);
    await updateProfile(updated);
  }

  Future<void> toggleWorkHours() async {
    final updated = state.copyWith(showWorkHours: !state.showWorkHours);
    await updateProfile(updated);
  }

  Future<void> completeOnboarding() async {
    final updated = state.copyWith(isOnboarded: true);
    await updateProfile(updated);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});
