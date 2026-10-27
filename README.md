# 🐾 Meo Xu — Mèo Giữ Xu

> **Slogan:** *"Không bắt bạn kỷ luật, chỉ giúp bạn hiểu mình."*  
> Ứng dụng ghi chi tiêu hàng ngày thông minh, nhập liệu siêu tốc 3 giây, đồng hành cùng một chú mèo ảo đáng yêu, không phán xét và không gây áp lực.

---

## 🌟 Điểm khác biệt (USP)

1. **Nhập liệu 3 giây**: Gõ câu tự nhiên (`trưa ăn bún bò 45k`, `grab 32k`, `cà phê 2 ly 70`, `lương 12tr`) hoặc nói giọng nói tiếng Việt.
2. **Con số duy nhất "Hôm nay thoải mái tiêu"**: Kèm hình ảnh trực quan **Đĩa cá khô** của mèo. Tiêu nhiều thì đĩa cá vơi dần. Vượt hạn mức mèo tự cân đối cho các ngày sau, không bao giờ dùng lời trách móc.
3. **Gắn cảm xúc một chạm**: Sau khi lưu, mèo hỏi nhẹ *"Khoản này bạn thấy thế nào?"* (😊 Vui, 👌 Cần thiết, 😿 Hối hận, ⚡ Bốc đồng).
4. **Quy đổi ra giờ làm việc**: Mọi khoản chi tự động quy đổi (`≈ 25 phút làm việc`, `≈ 1,5 ngày công`) giúp bạn cân nhắc giá trị thực sự.
5. **Thư của Mèo hàng tuần**: Báo cáo hành vi cá nhân hóa dạng thư tay cuộn (phát hiện thói quen mua sắm đêm khuya, ngày chi nhiều nhất, gợi ý nhỏ tuần tới, lời khen ấm áp).
6. **Nhà của Mèo & Gắn kết**: Chuỗi ngày (Streak), tích lũy cá khô, đổi phụ kiện (nơ đỏ, kính mắt, mũ phù thủy) và mở khóa huy hiệu thành tựu.

---

## 🚀 Tự Động Biên Dịch APK & IPA (GitHub Actions)

Dự án được cấu hình sẵn quy trình CI/CD hoàn chỉnh tại `.github/workflows/build-mobile.yml`:

| Nền tảng | Định dạng | Phương thức cài đặt | Workflow Runner |
|---|---|---|---|
| **Android** | `MeoXu-release.apk` | Cài trực tiếp trên mọi thiết bị Android | `ubuntu-latest` |
| **iOS** | `MeoXu-unsigned.ipa` | Cài qua Sideloadly / TrollStore / AltStore | `macos-14` |

### Cách đẩy code lên GitHub để nhận file cài đặt:
1. Nhấp đúp vào file `push-to-github.bat` trong thư mục dự án.
2. Dán link GitHub Repository của bạn khi được hỏi (ví dụ `git@github-harryzikko:harryzikko/meoxu.git` hoặc `https://github.com/harryzikko/meoxu.git`).
3. GitHub Actions sẽ tự động chạy kiểm thử và đóng gói **MeoXu-Android-APK** và **MeoXu-iOS-IPA-Unsigned** trong phần **Actions -> Artifacts**.

---

## 🏗️ Cấu Trúc Dự Án (Feature-First Architecture)

```
meoxu/
├── .github/
│   └── workflows/
│       └── build-mobile.yml            # CI/CD tự động build APK & IPA unsigned
├── android/                            # Scaffold Android Native & Manifest
├── ios/                                # Scaffold iOS Native & Info.plist
├── lib/
│   ├── main.dart                       # Entry point ứng dụng
│   ├── app.dart                        # Main Scaffold & Tab Navigation
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart         # Bảng màu chuẩn: Cam đào, nền kem, chữ nâu đậm
│   │   │   ├── app_typography.dart     # Phông Nunito bo tròn chuẩn tiếng Việt
│   │   │   └── app_strings.dart        # Hệ thống chuỗi giao diện tiếng Việt thân thiện
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Hỗ trợ Light mode & Dark mode
│   │   ├── database/
│   │   │   └── app_database.dart       # SQLite Database (Profile, Tx, Fixed, Rules, Cat, Streak)
│   │   ├── parser/
│   │   │   ├── expense_parser.dart     # Bộ phân tích câu tiếng Việt & Học từ khóa
│   │   │   └── parser_result.dart
│   │   └── utils/
│   │       ├── budget_calculator.dart  # Công thức "Hôm nay thoải mái tiêu" & Đĩa cá khô
│   │       ├── currency_formatter.dart # Định dạng tiền VNĐ & viết tắt k, tr
│   │       ├── work_hours_converter.dart # Quy đổi tiền ra giờ làm việc / ngày công
│   │       └── date_time_utils.dart
│   ├── models/                         # Dữ liệu đối tượng chuẩn đặc tả mục 7
│   │   ├── user_profile.dart
│   │   ├── transaction_item.dart
│   │   ├── category_item.dart
│   │   ├── fixed_expense.dart
│   │   ├── cat_state.dart
│   │   ├── streak_state.dart
│   │   ├── badge_item.dart
│   │   └── weekly_insight.dart
│   ├── providers/                      # Riverpod State Management
│   │   ├── profile_provider.dart
│   │   ├── transaction_provider.dart
│   │   ├── fixed_expenses_provider.dart
│   │   ├── cat_provider.dart
│   │   └── budget_calculator_provider.dart
│   └── features/                       # Màn hình chức năng
│       ├── onboarding/                 # 4 bước Onboarding (< 60s)
│       ├── home/                       # Mèo ở giữa, Đĩa cá khô, Quick input, Cảm xúc
│       │   └── widgets/
│       │       ├── meo_mascot_widget.dart # Vector Canvas 60fps, 7 trạng thái, 5 giống mèo
│       │       ├── fish_plate_card.dart
│       │       ├── quick_input_bar.dart
│       │       ├── confirm_card_bottom_sheet.dart # Đếm ngược 3s tự lưu
│       │       └── emotion_selector_dialog.dart
│       ├── transactions/               # Lịch sử nhóm theo ngày, vuốt xóa, hoàn tác
│       ├── stats/                      # Biểu đồ cột đơn giản, tỷ lệ cảm xúc, top 5
│       ├── cat_letter/                 # Báo cáo tuần "Thư của Mèo", phát hiện thói quen
│       ├── what_if/                    # Tính năng "Nếu như..." & slider bớt X lần/tuần
│       ├── cat_house/                  # Nhà của Mèo, tủ đồ phụ kiện, chuỗi ngày, huy hiệu
│       └── settings/                   # Cài đặt thu nhập, chi cố định, Dark mode, xuất CSV
├── test/
│   ├── expense_parser_test.dart        # Bộ 45 câu mẫu tiếng Việt (Độ chính xác > 95%)
│   ├── budget_calculator_test.dart     # Test các trường hợp ngân sách, tiêu vượt, đầu/cuối tháng
│   └── work_hours_test.dart            # Test quy đổi giờ làm việc theo phút/giờ/ngày công
├── pubspec.yaml
└── SPEC.md                             # Tài liệu đặc tả gốc
```

---

## 🧪 Kiểm Thử Đơn Vị (Unit Tests)

Bộ kiểm thử bao quát toàn diện các logic cốt lõi:
- **`expense_parser_test.dart`**: 45 câu thoại mẫu chi tiêu tiếng Việt đa dạng danh mục (Ăn uống, Di chuyển, Hóa đơn, Giải trí, Mua sắm, Sức khỏe, Thu nhập, Thời gian). Đạt chuẩn nghiệm thu: số tiền $\ge 95\%$, danh mục $\ge 85\%$.
- **`budget_calculator_test.dart`**: Kiểm thử công thức số tiền thoải mái tiêu hàng ngày, trừ khoản chi cố định trước, tự động cân đối khi tiêu ít hoặc tiêu vượt hạn mức.
- **`work_hours_test.dart`**: Kiểm thử định dạng theo phút ($< 1$h), giờ và phút ($1-8$h), ngày công ($\ge 8$h).
