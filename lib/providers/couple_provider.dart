import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/couple_state.dart';
import '../core/database/app_database.dart';

class CoupleStateHolder {
  final CoupleProfile profile;
  final CoupleGoal? activeGoal;
  final List<CoupleContribution> contributions;
  final CoupleChallenge challenge;
  final List<CoupleLoveNote> loveNotes;
  final String pokeDialogue;
  final int heartCount;

  const CoupleStateHolder({
    this.profile = const CoupleProfile(),
    this.activeGoal,
    this.contributions = const [],
    this.challenge = const CoupleChallenge(),
    this.loveNotes = const [],
    this.pokeDialogue =
        '"Hôm nay tụi mình đều giữ đĩa cá ngoan ngoãn nha meo~ Đừng để hao hụt kẻo cuối tuần bị phạt đó!"',
    this.heartCount = 0,
  });

  CoupleStateHolder copyWith({
    CoupleProfile? profile,
    CoupleGoal? activeGoal,
    List<CoupleContribution>? contributions,
    CoupleChallenge? challenge,
    List<CoupleLoveNote>? loveNotes,
    String? pokeDialogue,
    int? heartCount,
  }) {
    return CoupleStateHolder(
      profile: profile ?? this.profile,
      activeGoal: activeGoal ?? this.activeGoal,
      contributions: contributions ?? this.contributions,
      challenge: challenge ?? this.challenge,
      loveNotes: loveNotes ?? this.loveNotes,
      pokeDialogue: pokeDialogue ?? this.pokeDialogue,
      heartCount: heartCount ?? this.heartCount,
    );
  }
}

class CoupleNotifier extends StateNotifier<CoupleStateHolder> {
  CoupleNotifier() : super(const CoupleStateHolder()) {
    loadCoupleData();
  }

  static const List<String> _pokeReplies = [
    '"Bé Miu quay lại ngoe nguẩy đuôi: Meo! Em vừa uống trà sữa xong nhưng vẫn trong đĩa cá nhé!"',
    '"Bé Xu híp mắt sung sướng: Rì rào rì rào... Tối nay nhớ nấu cơm ăn chung nha!"',
    '"Bé Miu giơ chân trước xin tha: Đừng chọc em nữa, em đang cố nhịn mua túi xách nè meo~"',
    '"Hai chú mèo cụng đầu vào nhau kêu rừ rừ thật ấm áp 🐾"',
    '"Bé Xu vểnh tai: Hôm nay Nam giữ đĩa cá rất chuẩn, khen bạn trai 10 điểm!"',
  ];
  int _pokeIndex = 0;

  Future<void> loadCoupleData() async {
    try {
      final profile = await AppDatabase.instance.getCoupleProfile();
      final goals = await AppDatabase.instance.getCoupleGoals();
      final active = goals.isNotEmpty ? goals.first : null;

      List<CoupleContribution> contribs = [];
      if (active != null) {
        contribs = await AppDatabase.instance.getCoupleContributions(active.id);
      }

      final defaultNotes = [
        const CoupleLoveNote(
          id: 'note_1',
          sender: 'Nam',
          timeText: '12:40 trưa nay',
          message:
              'Tối nay tan làm cùng ghé ăn bún bò không em iu? Anh bao nha meo~ Đĩa cá của anh vẫn đủ cá để mời bạn gái nè!',
          isRead: false,
        ),
      ];

      state = state.copyWith(
        profile: profile,
        activeGoal: active,
        contributions: contribs,
        loveNotes: defaultNotes,
      );
    } catch (_) {}
  }

  void pokePartner() {
    _pokeIndex = (_pokeIndex + 1) % _pokeReplies.length;
    state = state.copyWith(pokeDialogue: _pokeReplies[_pokeIndex]);
  }

  void sendHeart() {
    state = state.copyWith(heartCount: state.heartCount + 1);
  }

  Future<void> addContribution({
    required double amount,
    required String message,
    required String contributorName,
  }) async {
    final currentGoal = state.activeGoal;
    if (currentGoal == null) return;

    final isUser = contributorName == state.profile.userNickname;
    final updatedGoal = currentGoal.copyWith(
      userContribution: isUser
          ? currentGoal.userContribution + amount
          : currentGoal.userContribution,
      partnerContribution: isUser
          ? currentGoal.partnerContribution
          : currentGoal.partnerContribution + amount,
    );

    final newContribution = CoupleContribution(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      goalId: currentGoal.id,
      contributorName: contributorName,
      amount: amount,
      message: message.trim().isEmpty ? 'Góp cá khô vào hũ chung 🐟' : message,
      dateTime: DateTime.now(),
    );

    final updatedContribs = [newContribution, ...state.contributions];

    state = state.copyWith(
      activeGoal: updatedGoal,
      contributions: updatedContribs,
    );

    await AppDatabase.instance.saveCoupleGoal(updatedGoal);
    await AppDatabase.instance.insertCoupleContribution(newContribution);
  }

  Future<void> createNewGoal({
    required String title,
    required double targetAmount,
    required DateTime targetDate,
    required double initialContribution,
  }) async {
    final id = 'goal_${DateTime.now().millisecondsSinceEpoch}';
    final newGoal = CoupleGoal(
      id: id,
      title: title,
      targetAmount: targetAmount,
      userContribution: initialContribution,
      partnerContribution: 0.0,
      targetDate: targetDate,
      status: 'active',
    );

    final newContribution = CoupleContribution(
      id: 'init_${DateTime.now().millisecondsSinceEpoch}',
      goalId: id,
      contributorName: state.profile.userNickname,
      amount: initialContribution,
      message: 'Khởi động mục tiêu: $title 🎉',
      dateTime: DateTime.now(),
    );

    state = state.copyWith(
      activeGoal: newGoal,
      contributions: [newContribution],
    );

    await AppDatabase.instance.saveCoupleGoal(newGoal);
    await AppDatabase.instance.insertCoupleContribution(newContribution);
  }

  Future<void> disburseGoal(String method) async {
    final currentGoal = state.activeGoal;
    if (currentGoal == null) return;

    final updated = currentGoal.copyWith(status: 'disbursed');
    state = state.copyWith(activeGoal: updated);
    await AppDatabase.instance.saveCoupleGoal(updated);
  }

  void sendLoveNote(String message) {
    if (message.trim().isEmpty) return;
    final newNote = CoupleLoveNote(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      sender: state.profile.userNickname,
      timeText: 'Vừa xong',
      message: message,
      isRead: true,
    );
    state = state.copyWith(loveNotes: [newNote, ...state.loveNotes]);
  }
}

final coupleProvider =
    StateNotifierProvider<CoupleNotifier, CoupleStateHolder>((ref) {
  return CoupleNotifier();
});
