import 'dart:math';
import '../../models/cat_state.dart';

class CatDialogueEngine {
  static final Random _random = Random();

  /// Sinh lời thoại động dựa trên Tính cách x Xưng hô x Thời gian x Ngân sách x Cử chỉ nựng
  static String getDialogue({
    required String personality, // 'sweet', 'butler', 'playful', 'zen'
    required String callTerm, // 'Sen', 'Bạn', 'Chủ nhân', 'Đồng chí', etc.
    required String catName,
    required String userName,
    required CatMood mood,
    bool isOverspent = false,
    bool isUnder20Percent = false,
    bool hasNoTransactions = false,
    bool isPetting = false,
    DateTime? now,
  }) {
    final term = callTerm.isNotEmpty ? callTerm : 'Sen';
    final time = now ?? DateTime.now();
    final hour = time.hour;

    // 1. Phản ứng khi được vuốt ve / nựng mèo
    if (isPetting) {
      return _getPettingDialogue(personality, term, catName);
    }

    // 2. Phản ứng theo trạng thái ngân sách
    if (isOverspent) {
      return _getOverspentDialogue(personality, term, catName);
    }
    if (isUnder20Percent) {
      return _getUnder20Dialogue(personality, term, catName);
    }
    if (hasNoTransactions) {
      return _getNoTransactionDialogue(personality, term, catName, hour);
    }

    // 3. Phản ứng theo mood đặc biệt
    if (mood == CatMood.dancing) {
      return _getDancingDialogue(personality, term, catName);
    }

    // 4. Lời chào và tâm sự theo thời gian trong ngày
    return _getTimeOfDayDialogue(personality, term, catName, hour);
  }

  // --- Khi được xoa đầu / vuốt ve ---
  static String _getPettingDialogue(
    String personality,
    String term,
    String catName,
  ) {
    final Map<String, List<String>> pool = {
      'sweet': [
        'Rừ rừ rừ... $term gãi cằm làm $catName sướng muốn rụng lông nè~ ♥',
        'Meo meo~ $term là số một trần đời! Yêu $term nhiều lắm á!',
        '*Dụi đầu vào tay* Được $term nựng là bao mệt mỏi tan biến hết trơn!',
        'Rừ rừ... Gãi tiếp đi $term ơi, đừng dừng lại nha~ ✨',
      ],
      'butler': [
        '*Khẽ cúi đầu hưởng thụ* Cảm ơn $term. Được hầu cận $term là niềm vinh hạnh của tôi.',
        'Sự quan tâm của $term khiến tôi thêm tận tụy gìn giữ hầu bao cho ngài.',
        '*Chớp mắt thanh lịch* Một cử chỉ thật ấm áp, thưa $term.',
      ],
      'playful': [
        'A há! Đúng huyệt ngứa rồi $term ơi! Cho thêm 10 giây nựng nữa nào haha!',
        'Được đấy $term ơi! Nựng thế này mai $catName canh cá khô chuẩn 10 điểm!',
        '*Lăn ngửa phơi bụng* Đã tay chưa $term? Tính phí một cái xoa bụng bằng 1 que kem nhé!',
      ],
      'zen': [
        '*Khép mắt tĩnh lặng* Hơi ấm từ bàn tay $term thật dịu dàng. Bình an là đây chứ đâu.',
        'Mỗi cái chạm nhẹ nhắc ta chậm lại một nhịp giữa bộn bề, cảm ơn $term.',
        '*Thở nhẹ an nhiên* Tâm an vạn sự an. $catName luôn ở đây bên $term.',
      ],
    };

    final list = pool[personality] ?? pool['sweet']!;
    return list[_random.nextInt(list.length)];
  }

  // --- Khi vượt hạn mức ngày (Tuyệt đối không trách móc, luôn đồng cảm) ---
  static String _getOverspentDialogue(
    String personality,
    String term,
    String catName,
  ) {
    final Map<String, List<String>> pool = {
      'sweet': [
        'Hôm nay $term chi tiêu hơi quá tay một xíu, nhưng không sao hết nha! Có $catName chia lại cá cho mấy ngày tới là ổn ngay à~',
        'Đừng lo nha $term ơi, ai cũng có ngày chi nhiều mà. $catName vẫn luôn yêu thương $term!',
        'Uống một ngụm nước ấm nha $term! Ngày mai mình cùng nhau thong thả lại nhé~',
      ],
      'butler': [
        'Thưa $term, ngân sách hôm nay có phần thâm hụt nhẹ. Tôi đã chủ động điều chỉnh lại hạn mức các ngày sau để đảm bảo cân đối.',
        'Một khoản chi ngoài dự liệu cũng là điều bình thường. Chúng ta sẽ cùng kiểm soát tốt hơn vào ngày mai, thưa $term.',
      ],
      'playful': [
        'Úi chà! Hôm nay $term chơi lớn thế! Không sao cả, thỉnh thoảng xả láng tí, mai anh em mình lại ăn mì gói sang chảnh gỡ lại!',
        'Tiêu hơi lố tí ti thôi mà, chuyện nhỏ như con thỏ! Mai $catName sẽ khóa tủ cá lại giúp $term nhé haha!',
      ],
      'zen': [
        'Tiền bạc chỉ là dòng chảy luân chuyển. Tiêu rồi thì trân trọng giá trị nó mang lại nhé $term, đừng bận lòng quá khứ.',
        'Thấu hiểu bản thân quan trọng hơn việc tự trách mình. Hít một hơi thật sâu và đón ngày mai nhẹ nhõm nhé $term.',
      ],
    };

    final list = pool[personality] ?? pool['sweet']!;
    return list[_random.nextInt(list.length)];
  }

  // --- Khi còn dưới 20% đĩa cá khô hôm nay ---
  static String _getUnder20Dialogue(
    String personality,
    String term,
    String catName,
  ) {
    final Map<String, List<String>> pool = {
      'sweet': [
        'Đĩa cá khô hôm nay còn một mẩu xíu xiu thôi nè $term ơi, mình thong thả chờ ngày mai nha!',
        '$catName ôm đĩa cá giữ cho $term nè. Tối nay mình uống trà ấm xem phim chill thôi nhé~',
      ],
      'butler': [
        'Hạn mức hôm nay sắp cạn, thưa $term. Tôi khuyến nghị giữ lại khoản dự phòng nhỏ này cho trường hợp khẩn cấp.',
        'Chỉ còn một lượng nhỏ ngân sách cho ngày hôm nay. Kính mong $term cân nhắc trước khi phát sinh thêm.',
      ],
      'playful': [
        'Báo động đỏ! Đĩa cá chỉ còn bộ xương thôi $term ơi! Giữ tay chèo, mai lại có cá mới tha hồ bơi!',
        'Còn có tí tiền dính túi nè $term! Cầm cự đến 0h đêm nay là sang ngày mới rủng rỉnh rồi!',
      ],
      'zen': [
        'Đủ đầy xuất phát từ sự biết đủ. Một ngày sắp trôi qua bình yên với những gì ta có, $term nhé.',
        'Còn ít cá khô cũng chẳng sao, những điều quý giá nhất vốn dĩ đều miễn phí.',
      ],
    };

    final list = pool[personality] ?? pool['sweet']!;
    return list[_random.nextInt(list.length)];
  }

  // --- Khi chưa có giao dịch nào hôm nay ---
  static String _getNoTransactionDialogue(
    String personality,
    String term,
    String catName,
    int hour,
  ) {
    if (hour < 12) {
      return '$term ơi, sáng nay chưa tiêu gì cả, đĩa cá khô vẫn còn nguyên vẹn rực rỡ nè!';
    }
    return '$term hôm nay tiết kiệm ghê, $catName nằm cuộn tròn ngủ sưởi nắng thảnh thơi quá zZz~';
  }

  // --- Khi đạt chuỗi 7 ngày trở lên (Dancing) ---
  static String _getDancingDialogue(
    String personality,
    String term,
    String catName,
  ) {
    return 'Meo meo! Chuỗi giữ xu xuất sắc quá $term ơi! $catName múa quạt ăn mừng cùng $term nè! 💃✨';
  }

  // --- Lời thoại theo buổi trong ngày ---
  static String _getTimeOfDayDialogue(
    String personality,
    String term,
    String catName,
    int hour,
  ) {
    // Sáng sớm (05h - 10h)
    if (hour >= 5 && hour < 11) {
      final Map<String, List<String>> morning = {
        'sweet': [
          'Chào buổi sáng $term iu dấu! $term nhớ ăn sáng đầy đủ nạp năng lượng kiếm cá nha!',
          'Buổi sáng rạng rỡ nha $term! Nhìn $term dậy sớm là $catName thấy ngập tràn động lực rùi!',
        ],
        'butler': [
          'Chào buổi sáng, thưa $term. Chúc ngài một ngày làm việc hanh thông và hiệu quả.',
          'Hôm nay bầu trời rất đẹp. Tôi đã chuẩn bị tinh thần theo dõi ngân sách cùng ngài, thưa $term.',
        ],
        'playful': [
          'Dậy đi $term ơi! Mặt trời rọi tới mông rồi, làm cốc cà phê rồi chiến đấu thôi nào!',
          'Chào ngày mới $term! Hôm nay mục tiêu gom thêm cá khô bỏ hũ nhé!',
        ],
        'zen': [
          'Một buổi sáng an lành nhé $term. Hít thở thật sâu và đón nhận ngày mới dịu dàng.',
          'Mỗi ngày mới là một cơ hội để sống trọn vẹn và thảnh thơi. Chúc $term bình an.',
        ],
      };
      final list = morning[personality] ?? morning['sweet']!;
      return list[_random.nextInt(list.length)];
    }

    // Buổi trưa (11h - 13h)
    if (hour >= 11 && hour < 14) {
      return '$term ăn cơm trưa ngon miệng nhé! Nhớ ghi lại bữa trưa để $catName canh cá giúp nè~ 🍜';
    }

    // Buổi chiều (14h - 17h)
    if (hour >= 14 && hour < 18) {
      return 'Buổi chiều hơi buồn ngủ xíu đúng hông $term? Uống ngụm nước rồi xoa đầu $catName cái lấy hên nha!';
    }

    // Buổi tối (18h - 21h)
    if (hour >= 18 && hour < 22) {
      return 'Hoan hô $term đã hoàn thành một ngày làm việc chăm chỉ! Về nhà nghỉ ngơi cùng $catName thôi nào!';
    }

    // Đêm muộn (22h - 04h)
    final Map<String, List<String>> night = {
      'sweet': [
        'Khuya rồi nha $term ơi, đừng lướt điện thoại nữa nha. Lại đây đắp chăn $catName sưởi ấm cho ngủ nè~ zZz',
        '$catName bắt đầu ngáp ngủ rùi nè... $term cũng ngủ sớm giữ sức khỏe nhé, thương $term!',
      ],
      'butler': [
        'Đã khuya rồi, thưa $term. Tôi kính chúc ngài một giấc ngủ thật sâu và an giấc.',
        'Mọi việc của ngày hôm nay đã chu toàn. $term hãy nghỉ ngơi để tái tạo năng lượng.',
      ],
      'playful': [
        'Cú đêm hả $term? Tắt màn hình đi ngủ thôi, mai còn thức sớm cày cuốc chớ!',
        'Coi chừng quầng thâm mắt to hơn mắt $catName đấy nha $term haha! Ngủ thôi nào!',
      ],
      'zen': [
        'Gác lại những bộn bề của ngày hôm nay nhé $term. Giấc ngủ ngon là liều thuốc chữa lành quý giá nhất.',
        'Đêm đã tĩnh lặng. Chúc $term tìm thấy sự an lạc và thư thái trong giấc mơ.',
      ],
    };
    final list = night[personality] ?? night['sweet']!;
    return list[_random.nextInt(list.length)];
  }
}
