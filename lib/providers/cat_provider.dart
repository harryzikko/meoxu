import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cat_state.dart';
import '../models/streak_state.dart';
import '../core/database/app_database.dart';
import '../core/utils/date_time_utils.dart';

class CatCombinedState {
  final CatState cat;
  final StreakState streak;

  const CatCombinedState({
    this.cat = const CatState(),
    this.streak = const StreakState(),
  });

  CatCombinedState copyWith({CatState? cat, StreakState? streak}) {
    return CatCombinedState(
      cat: cat ?? this.cat,
      streak: streak ?? this.streak,
    );
  }
}

class CatNotifier extends StateNotifier<CatCombinedState> {
  CatNotifier() : super(const CatCombinedState()) {
    loadCatAndStreak();
  }

  Future<void> loadCatAndStreak() async {
    try {
      final cat = await AppDatabase.instance.getCatState();
      final streak = await AppDatabase.instance.getStreakState();
      state = state.copyWith(cat: cat, streak: streak);
    } catch (_) {}
  }

  void updateMood(CatMood newMood) {
    state = state.copyWith(cat: state.cat.copyWith(currentMood: newMood));
  }

  Future<void> onTransactionRecorded() async {
    // Add fish points
    final newFish = state.cat.fishPoints + 5;

    // Check and update streak
    final now = DateTime.now();
    int newStreak = state.streak.currentStreak;
    int recordStreak = state.streak.recordStreak;

    if (state.streak.lastRecordDate == null) {
      newStreak = 1;
    } else {
      if (DateTimeUtils.isToday(state.streak.lastRecordDate!)) {
        // Already recorded today, streak unchanged
      } else if (DateTimeUtils.isYesterday(state.streak.lastRecordDate!)) {
        newStreak += 1;
      } else {
        // Missed a day: check if freeze card available
        if (state.streak.freezeCardsLeft > 0) {
          // Freeze card used
          newStreak += 1;
        } else {
          newStreak = 1;
        }
      }
    }

    if (newStreak > recordStreak) {
      recordStreak = newStreak;
    }

    // Evaluate cat level based on streak
    int newLevel = state.cat.level;
    if (newStreak >= 30) {
      newLevel = 4;
    } else if (newStreak >= 14) {
      newLevel = 3;
    } else if (newStreak >= 3) {
      newLevel = 2;
    }

    final updatedCat = state.cat.copyWith(
      fishPoints: newFish,
      level: newLevel,
      currentMood: newStreak >= 7 ? CatMood.dancing : CatMood.excited,
    );

    final updatedStreak = state.streak.copyWith(
      currentStreak: newStreak,
      recordStreak: recordStreak,
      lastRecordDate: now,
    );

    state = state.copyWith(cat: updatedCat, streak: updatedStreak);
    await AppDatabase.instance.updateCatState(updatedCat);
    await AppDatabase.instance.updateStreakState(updatedStreak);
  }

  Future<void> onEmotionAttached() async {
    final updated = state.cat.copyWith(fishPoints: state.cat.fishPoints + 2);
    state = state.copyWith(cat: updated);
    await AppDatabase.instance.updateCatState(updated);
  }

  Future<bool> unlockAccessory(String id, int cost) async {
    if (state.cat.fishPoints < cost) return false;
    final updatedAccessories = [...state.cat.unlockedAccessories, id];
    final updated = state.cat.copyWith(
      fishPoints: state.cat.fishPoints - cost,
      unlockedAccessories: updatedAccessories,
    );
    state = state.copyWith(cat: updated);
    await AppDatabase.instance.updateCatState(updated);
    return true;
  }

  Future<void> toggleEquipAccessory(String id) async {
    final equipped = List<String>.from(state.cat.equippedAccessories);
    if (equipped.contains(id)) {
      equipped.remove(id);
    } else {
      equipped.add(id);
    }
    final updated = state.cat.copyWith(equippedAccessories: equipped);
    state = state.copyWith(cat: updated);
    await AppDatabase.instance.updateCatState(updated);
  }
}

final catProvider = StateNotifierProvider<CatNotifier, CatCombinedState>((ref) {
  return CatNotifier();
});
