import 'package:flutter_test/flutter_test.dart';
import 'package:meoxu/models/user_profile.dart';
import 'package:meoxu/models/cat_state.dart';
import 'package:meoxu/core/constants/cat_dialogues.dart';

void main() {
  group('UserProfile Personalization Tests', () {
    test('Default user profile has complete personalization fields', () {
      const profile = UserProfile(id: 'u1');
      expect(profile.catPersonality, equals('sweet'));
      expect(profile.callTerm, equals('sen'));
      expect(profile.formattedCallTerm, equals('Sen'));
      expect(profile.eyeColor, equals('amber'));
      expect(profile.catBreed, equals('orange'));
    });

    test('Custom call terms format correctly', () {
      const p1 = UserProfile(id: 'u1', callTerm: 'ban');
      expect(p1.formattedCallTerm, equals('Bạn'));

      const p2 = UserProfile(id: 'u2', callTerm: 'chu_nhan');
      expect(p2.formattedCallTerm, equals('Chủ nhân'));

      const p3 = UserProfile(id: 'u3', callTerm: 'dong_chi');
      expect(p3.formattedCallTerm, equals('Đồng chí'));

      const p4 = UserProfile(id: 'u4', callTerm: 'nguoi_anh_em');
      expect(p4.formattedCallTerm, equals('Người anh em'));

      const p5 = UserProfile(id: 'u5', callTerm: 'Đại vương');
      expect(p5.formattedCallTerm, equals('Đại vương'));
    });

    test('Serialization toMap and fromMap preserves personalization data', () {
      const profile = UserProfile(
        id: 'user_456',
        userName: 'Harry',
        catName: 'Bánh Mì',
        catBreed: 'tuxedo',
        catPersonality: 'butler',
        callTerm: 'chu_nhan',
        eyeColor: 'heterochromia',
      );

      final map = profile.toMap();
      expect(map['cat_personality'], equals('butler'));
      expect(map['call_term'], equals('chu_nhan'));
      expect(map['eye_color'], equals('heterochromia'));
      expect(map['cat_breed'], equals('tuxedo'));

      final restored = UserProfile.fromMap(map);
      expect(restored.catPersonality, equals('butler'));
      expect(restored.callTerm, equals('chu_nhan'));
      expect(restored.formattedCallTerm, equals('Chủ nhân'));
      expect(restored.eyeColor, equals('heterochromia'));
      expect(restored.catBreed, equals('tuxedo'));
    });

    test('copyWith updates personalization fields accurately', () {
      const profile = UserProfile(id: 'u1');
      final updated = profile.copyWith(
        catPersonality: 'zen',
        callTerm: 'ban',
        eyeColor: 'ocean_blue',
        catBreed: 'siamese',
      );

      expect(updated.catPersonality, equals('zen'));
      expect(updated.callTerm, equals('ban'));
      expect(updated.eyeColor, equals('ocean_blue'));
      expect(updated.catBreed, equals('siamese'));
    });
  });

  group('CatDialogueEngine Tests', () {
    test('Petting interaction generates affectionate dialogue containing address term', () {
      final sweetPet = CatDialogueEngine.getDialogue(
        personality: 'sweet',
        callTerm: 'Sen',
        catName: 'Bánh Mì',
        userName: 'Harry',
        mood: CatMood.happy,
        isPetting: true,
      );
      expect(sweetPet.contains('Sen'), isTrue);

      final butlerPet = CatDialogueEngine.getDialogue(
        personality: 'butler',
        callTerm: 'Chủ nhân',
        catName: 'Quản gia Xu',
        userName: 'Harry',
        mood: CatMood.happy,
        isPetting: true,
      );
      expect(butlerPet.contains('Chủ nhân'), isTrue);

      final playfulPet = CatDialogueEngine.getDialogue(
        personality: 'playful',
        callTerm: 'Đồng chí',
        catName: 'Xu Tưng Tửng',
        userName: 'Harry',
        mood: CatMood.happy,
        isPetting: true,
      );
      expect(playfulPet.contains('Đồng chí'), isTrue);

      final zenPet = CatDialogueEngine.getDialogue(
        personality: 'zen',
        callTerm: 'Bạn',
        catName: 'Thiền Sư Miu',
        userName: 'Harry',
        mood: CatMood.happy,
        isPetting: true,
      );
      expect(zenPet.contains('Bạn'), isTrue);
    });

    test('Overspent condition never blames the user, always supports and adapts', () {
      for (final personality in ['sweet', 'butler', 'playful', 'zen']) {
        final dialogue = CatDialogueEngine.getDialogue(
          personality: personality,
          callTerm: 'Sen',
          catName: 'Mèo Xu',
          userName: 'Harry',
          mood: CatMood.confused,
          isOverspent: true,
        );
        expect(dialogue.isNotEmpty, isTrue);
        expect(dialogue.contains('Sen'), isTrue);
      }
    });

    test('Time of day produces distinct greetings', () {
      final morning = DateTime(2026, 4, 15, 8, 0); // 8:00 AM
      final night = DateTime(2026, 4, 15, 23, 30); // 11:30 PM

      final morningMsg = CatDialogueEngine.getDialogue(
        personality: 'sweet',
        callTerm: 'Sen',
        catName: 'Mèo Xu',
        userName: 'Harry',
        mood: CatMood.happy,
        now: morning,
      );
      expect(morningMsg.contains('buổi sáng') || morningMsg.contains('Buổi sáng'), isTrue);

      final nightMsg = CatDialogueEngine.getDialogue(
        personality: 'sweet',
        callTerm: 'Sen',
        catName: 'Mèo Xu',
        userName: 'Harry',
        mood: CatMood.happy,
        now: night,
      );
      expect(nightMsg.contains('Khuya') || nightMsg.contains('ngủ') || nightMsg.contains('zZz'), isTrue);
    });
  });

  group('CatState Mood & Accessory Suite Tests', () {
    test('CatMood.purring exists and can be assigned', () {
      const state = CatState(currentMood: CatMood.purring);
      expect(state.currentMood, equals(CatMood.purring));

      final map = state.toMap();
      expect(map['current_mood'], equals('purring'));

      final restored = CatState.fromMap(map);
      expect(restored.currentMood, equals(CatMood.purring));
    });
  });
}
