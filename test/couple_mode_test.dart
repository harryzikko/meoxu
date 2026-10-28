import 'package:flutter_test/flutter_test.dart';
import 'package:meoxu/models/couple_state.dart';

void main() {
  group('Couple Mode Test Suite', () {
    test('CoupleProfile defaults and serialization', () {
      const profile = CoupleProfile();
      expect(profile.userNickname, equals('Linh'));
      expect(profile.partnerName, equals('Nam'));
      expect(profile.daysTogether, equals(48));
      expect(profile.partnerFishPercentage, equals(0.65));
      expect(profile.connectCode, equals('MEOXU-NAMLINH'));

      final map = profile.toMap();
      final restored = CoupleProfile.fromMap(map);
      expect(restored.userNickname, equals(profile.userNickname));
      expect(restored.partnerName, equals(profile.partnerName));
      expect(restored.daysTogether, equals(profile.daysTogether));
      expect(restored.partnerFishPercentage, equals(profile.partnerFishPercentage));
      expect(restored.connectCode, equals(profile.connectCode));

      final updated = profile.copyWith(daysTogether: 49, partnerStatusLabel: 'An tâm 🌿');
      expect(updated.daysTogether, equals(49));
      expect(updated.partnerStatusLabel, equals('An tâm 🌿'));
    });

    test('CoupleGoal progress and metrics calculations', () {
      final goal = CoupleGoal(
        id: 'goal_1',
        title: 'Chuyến trốn phố Đà Lạt 🌲🏕️',
        targetAmount: 10000000.0,
        userContribution: 3500000.0,
        partnerContribution: 3300000.0,
        targetDate: DateTime.now().add(const Duration(days: 45)),
      );

      expect(goal.currentAmount, equals(6800000.0));
      expect(goal.remainingAmount, equals(3200000.0));
      expect(goal.progressPercentage, closeTo(0.68, 0.001));
      expect(goal.userPercentage, closeTo(0.35, 0.001));
      expect(goal.partnerPercentage, closeTo(0.33, 0.001));
      expect(goal.isCompleted, isFalse);

      final completedGoal = goal.copyWith(
        userContribution: 5500000.0,
        partnerContribution: 5000000.0,
      );
      expect(completedGoal.isCompleted, isTrue);
      expect(completedGoal.remainingAmount, equals(0.0));
      expect(completedGoal.progressPercentage, equals(1.0));

      final map = goal.toMap();
      final restored = CoupleGoal.fromMap(map);
      expect(restored.id, equals(goal.id));
      expect(restored.title, equals(goal.title));
      expect(restored.targetAmount, equals(goal.targetAmount));
      expect(restored.userContribution, equals(goal.userContribution));
      expect(restored.partnerContribution, equals(goal.partnerContribution));
    });

    test('CoupleContribution serialization', () {
      final now = DateTime.now();
      final contrib = CoupleContribution(
        id: 'contrib_1',
        goalId: 'goal_1',
        contributorName: 'Linh',
        amount: 500000.0,
        message: 'Thả thêm cá khô vào hũ 🐟',
        dateTime: now,
      );

      expect(contrib.amount, equals(500000.0));
      expect(contrib.contributorName, equals('Linh'));

      final map = contrib.toMap();
      final restored = CoupleContribution.fromMap(map);
      expect(restored.id, equals(contrib.id));
      expect(restored.goalId, equals(contrib.goalId));
      expect(restored.contributorName, equals(contrib.contributorName));
      expect(restored.amount, equals(contrib.amount));
      expect(restored.message, equals(contrib.message));
    });

    test('CoupleChallenge defaults', () {
      const challenge = CoupleChallenge();
      expect(challenge.title, equals('Kèo Đãi Ăn Cuối Tuần'));
      expect(challenge.penalty, equals('Nồi lẩu Thái chua cay'));
      expect(challenge.userStatus, contains('Phong độ'));
      expect(challenge.partnerStatus, contains('Nguy cơ'));
    });
  });
}
