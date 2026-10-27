# Meo Xu – Đặc tả sản phẩm cho Antigravity

*Tên tạm: **Meo Xu** (Mèo giữ xu). Slogan: "Không bắt bạn kỷ luật, chỉ giúp bạn hiểu mình."*

## 1. Tổng quan

**Mục tiêu:** App ghi chi tiêu hàng ngày, nhập liệu cực nhanh, không gây áp lực, đồng hành bằng một chú mèo ảo dễ thương.

**Đối tượng chính:** Sinh viên và nhân viên văn phòng trẻ (18–32 tuổi) tại Việt Nam, từng bỏ app chi tiêu vì nhập chán.

**Điểm khác biệt (USP):**

1. Nhập liệu 3 giây: gõ câu tự nhiên hoặc nói giọng nói.
2. Gắn cảm xúc cho từng khoản chi, app tìm ra mẫu hành vi.
3. Quy đổi tiền ra giờ làm việc.
4. Một con số duy nhất: "Hôm nay được tiêu thoải mái X đồng".
5. Mèo ảo phản ứng theo thói quen chi tiêu, không phán xét.

**Nền tảng:** Mobile (Android trước, iOS sau). Ngôn ngữ giao diện: tiếng Việt (chuẩn bị sẵn i18n để thêm tiếng Anh).

## 2. Gợi ý công nghệ

- **Framework:** Flutter (một codebase cho Android + iOS), state management dùng Riverpod.
- **Lưu trữ:** Local-first bằng SQLite (thư viện Drift). Dữ liệu nằm trên máy, hoạt động offline.
- **Đồng bộ (giai đoạn 2):** Supabase hoặc Firebase, đăng nhập Google/Apple.
- **Giọng nói:** Gói speech-to-text của hệ điều hành (tiếng Việt).
- **Phân tích câu nhập:** Parser bằng quy tắc (regex) cho MVP; giai đoạn 2 dùng LLM để hiểu câu phức tạp.
- **Animation mèo:** Rive hoặc Lottie.
- **Thông báo:** flutter\_local\_notifications.

## 3. Nhân vật & phong cách thiết kế

### 3.1 Linh vật: Mèo Xu

- Mèo tròn, mắt to, má hồng, đeo một chiếc túi tiền nhỏ ở cổ.
- Phong cách: minh họa phẳng (flat), nét bo tròn, ít chi tiết để animation mượt.
- Người dùng được đặt tên mèo và chọn giống (mèo cam, mèo mướp, mèo tam thể, mèo đen, mèo trắng). Mỗi giống là một bộ skin khác màu lông.

### 3.2 Trạng thái cảm xúc của mèo (mỗi trạng thái 1 animation)

| Trạng thái | Khi nào xuất hiện |
| --- | --- |
| Vui vẻ, vẫy đuôi | Chi tiêu trong mức cho phép |
| Ngủ gật | Chưa có khoản chi nào hôm nay |
| Háo hức, mắt sáng | Vừa ghi xong một khoản chi |
| Lo lắng nhẹ, tai cụp | Còn dưới 20% mức tiêu hôm nay |
| Bối rối, ngồi gãi đầu | Vượt mức tiêu hôm nay (không buồn, không trách) |
| Nhảy múa | Đạt chuỗi 7 ngày ghi chép liên tục |
| Đói bụng | Quá 24 giờ chưa ghi chép (nhắc nhẹ) |

### 3.3 Bảng màu & phông chữ

- Màu chính: cam đào `#FFB26B`; nền kem `#FFF8F0`; chữ nâu đậm `#4A3728`.
- Màu cảm xúc: vui `#7ED6A5`, cần thiết `#8EC5FC`, hối hận `#F28B9B`, bốc đồng `#FFD36B`.
- Phông chữ: Nunito hoặc Quicksand (bo tròn, hỗ trợ tiếng Việt đầy đủ dấu).
- Có Dark mode (nền nâu than, mèo vẫn rõ).
- Giọng văn: thân thiện, xưng "mình" và gọi người dùng là "bạn" hoặc tên riêng. Tuyệt đối không dùng lời lẽ chê trách.

### 3.4 Đơn vị tiền ảo: "Cá khô"

- Mức tiêu hôm nay được hiển thị như **một đĩa cá khô** của mèo. Chi nhiều thì đĩa vơi dần (vừa trực quan vừa dễ thương).
- Vẫn luôn hiển thị số tiền thật (VNĐ) bên cạnh, cá chỉ là lớp minh họa.

## 4. Tính năng cốt lõi (MVP)

### 4.1 Nhập chi tiêu siêu nhanh

**Ô nhập ở thanh dưới cùng của màn hình chính**, luôn hiện, một chạm là gõ được.

**Cách nhập:**

- Gõ câu tự nhiên: `trưa ăn bún 45k`, `grab 32k`, `cà phê 2 ly 70`, `lương 12tr`.
- Nút micro: nói rồi app chuyển thành văn bản và phân tích.
- Nút bàn phím số: dùng khi muốn nhập tay kiểu truyền thống.

**Quy tắc parser (MVP):**

- Nhận dạng số tiền: `45k` = 45.000; `1tr2` = 1.200.000; `1.5tr` = 1.500.000; `70` đứng một mình sau từ ngữ chi tiêu quen thuộc được hiểu là 70.000 (hỏi xác nhận nếu mơ hồ).
- Nhận dạng danh mục bằng từ khóa: ăn, bún, phở, cơm, cà phê, trà sữa → Ăn uống; grab, xăng, gửi xe, bus → Di chuyển; tiền nhà, điện, nước, wifi → Hóa đơn; phim, game, du lịch → Giải trí; mua, shopee, quần áo → Mua sắm; thuốc, khám → Sức khỏe; lương, thưởng, được cho → Thu nhập.
- Nhận dạng thời gian: "hôm qua", "sáng nay", "thứ 2", mặc định là thời điểm hiện tại.
- Sau khi phân tích, hiện một **thẻ xác nhận** (số tiền, danh mục, thời gian) có thể sửa bằng một chạm. Nếu người dùng không làm gì trong 3 giây, tự lưu.
- App học: nếu người dùng sửa danh mục cho một từ khóa, lần sau tự áp dụng.

### 4.2 Gắn cảm xúc (một chạm)

Sau khi lưu, mèo hỏi nhẹ: *"Khoản này bạn thấy thế nào?"* với 4 biểu tượng:

- 😊 **Vui** (chi cho niềm vui)
- 👌 **Cần thiết**
- 😿 **Hối hận**
- ⚡ **Bốc đồng**

Quy tắc: được bỏ qua hoàn toàn (vuốt đi hoặc không chạm). Mặc định không gắn nhãn. Có thể bật chế độ "tự gắn nhãn cần thiết" cho hóa đơn cố định.

### 4.3 Con số "Hôm nay thoải mái tiêu"

**Màn hình chính chỉ có một con số lớn**, kèm đĩa cá khô.

**Công thức:**

```
ngân_sách_tháng = thu_nhập_dự_kiến − chi_cố_định − mục_tiêu_tiết_kiệm
ngày_còn_lại   = số_ngày_còn_lại_trong_tháng (tính cả hôm nay)
chi_thoải_mái_hôm_nay = (ngân_sách_tháng − đã_chi_thoải_mái_từ_đầu_tháng) / ngày_còn_lại
```

- Chi cố định (tiền nhà, điện, nước, wifi, học phí...) được đánh dấu "cố định" và trừ trước, không tính vào con số hằng ngày.
- Hôm nay chi ít hơn thì phần dư tự chuyển sang các ngày sau (con số ngày mai tăng). Chi vượt thì ngày sau giảm đều, không dồn hết vào một ngày.
- Nếu con số xuống dưới 0 thì hiển thị "0đ" và mèo ở trạng thái bối rối, kèm gợi ý nhẹ nhàng.
- Thanh trượt nhỏ cho phép người dùng điều chỉnh "mức tiết kiệm" (nhiều hơn hoặc ít hơn) và thấy con số thay đổi ngay.

### 4.4 Quy đổi ra giờ làm việc

- Khi thiết lập, người dùng nhập thu nhập tháng (hoặc lương theo giờ) và số giờ làm mỗi tháng (mặc định 176 giờ).
- Công thức: `giờ_làm = số_tiền / (thu_nhập_tháng / số_giờ_làm_tháng)`.
- Mọi khoản chi hiển thị thêm dòng phụ nhỏ: *"≈ 25 phút làm việc"*. Dưới 1 giờ hiển thị phút; từ 1 giờ trở lên hiển thị giờ và phút; từ 8 giờ trở lên hiển thị theo ngày công ("≈ 1,5 ngày công").
- Có công tắc ẩn/hiện trong cài đặt (một số người không muốn thấy).

### 4.5 Danh sách giao dịch

- Nhóm theo ngày, mỗi dòng gồm: biểu tượng danh mục, ghi chú, số tiền, chấm màu cảm xúc, giờ làm quy đổi.
- Vuốt trái để xóa, vuốt phải để sửa. Có "Hoàn tác" trong 5 giây sau khi xóa.
- Bộ lọc: theo danh mục, theo cảm xúc, theo khoảng ngày.
- Tìm kiếm theo từ khóa trong ghi chú.

### 4.6 Báo cáo hành vi hàng tuần: "Thư của Mèo"

Mỗi Chủ nhật tối, mèo gửi một "lá thư" (màn hình dạng thẻ cuộn) gồm:

1. Tổng chi tuần so với tuần trước (một câu ngắn).
2. **Phát hiện hành vi** (tạo tự động từ dữ liệu), ví dụ:
   - *"70% khoản bạn thấy hối hận xảy ra sau 22h."*
   - *"Thứ Sáu là ngày bạn chi nhiều nhất, trung bình gấp 2 lần các ngày khác."*
   - *"Trà sữa chiếm 18% chi tiêu ăn uống, nhưng chỉ 1/5 lần bạn cảm thấy vui."*
3. Một **việc nhỏ** mèo gợi ý thử tuần tới (chỉ một việc, ví dụ: "Thử đợi 10 phút trước khi mua đồ online sau 22h nhé").
4. Lời khen cho điều tốt nhất tuần (luôn có ít nhất một điều).

**Quy tắc phát hiện mẫu:** cần tối thiểu 10 giao dịch trong tuần, nếu không thì mèo viết "Tuần này mình chưa đủ dữ liệu, cứ thong thả nhé".

### 4.7 Tính năng "Nếu như..."

- Ở màn hình chi tiết của một danh mục hoặc ghi chú lặp lại (ví dụ "cà phê"), có nút "Nếu như...".
- Hiển thị quy đổi: *"Cà phê mỗi ngày ≈ 18 triệu/năm ≈ 1 chuyến đi Nhật"* và *"Nếu bớt một nửa, một năm tiết kiệm 9 triệu"*.
- Thanh trượt cho phép người dùng thử "bớt X lần mỗi tuần" và xem kết quả theo tháng, năm.
- Không bao giờ dùng lời trách móc, chỉ trình bày lựa chọn.

### 4.8 Hệ thống mèo (gắn kết lâu dài)

- **Chuỗi ngày (streak):** ghi chép ít nhất 1 lần mỗi ngày (kể cả ghi "hôm nay không chi gì") sẽ tăng chuỗi. Có 2 "thẻ nghỉ" mỗi tháng để lỡ ngày không mất chuỗi.
- **Điểm cá:** mỗi lần ghi chép, gắn cảm xúc hoặc hoàn thành thử thách nhỏ sẽ nhận cá. Dùng cá để mở khóa phụ kiện cho mèo (mũ, nơ, kính, khăn quàng) và nội thất cho góc nhà của mèo.
- **Cấp độ mèo:** mèo con → mèo trẻ → mèo trưởng thành → mèo thông thái, lên cấp dựa trên số ngày ghi chép (không dựa trên số tiền tiết kiệm, để không tạo áp lực).
- **Huy hiệu:** "7 ngày liên tiếp", "Tuần không bốc đồng", "Người đầu tiên ghi chép lúc 6h sáng"...

### 4.9 Nhắc nhở thông minh

- Tối đa 2 thông báo mỗi ngày, mặc định 1.
- Giờ nhắc do người dùng chọn; nếu hôm nay đã ghi chép thì không nhắc.
- Nội dung thông báo là lời mèo, đáng yêu và đa dạng (ít nhất 30 mẫu câu để không lặp).
- Cho phép tắt hoàn toàn.

## 5. Tính năng giai đoạn 2

1. **Đọc thông báo ngân hàng/ví điện tử (Android):** dùng NotificationListenerService, đọc thông báo từ các app ngân hàng (Vietcombank, MB, Techcombank, VPBank, TPBank, BIDV, MoMo, ZaloPay...) và tự tạo giao dịch ở trạng thái "chờ xác nhận". Phải xin quyền rõ ràng, giải thích minh bạch, xử lý hoàn toàn trên máy, không gửi nội dung thông báo lên server. Với iOS: thay bằng Shortcuts (Phím tắt) để người dùng tự dán/gửi tin nhắn.
2. **Chụp hóa đơn:** OCR bằng ML Kit hoặc dịch vụ LLM, tự tách tổng tiền, tên quán, ngày.
3. **Chế độ cặp đôi "Hai chú mèo":** hai người liên kết, mỗi người có một mèo; chia sẻ tiến độ mục tiêu chung (chỉ hiện phần trăm đạt mục tiêu, không hiện chi tiết khoản chi). Thử thách vui: người vượt ngân sách đãi người kia một bữa.
4. **Mục tiêu tiết kiệm:** ví dụ "Đi Đà Lạt 5 triệu", mèo ngồi cạnh một chiếc vali, vali đầy dần theo tiến độ.
5. **Widget màn hình chính:** hiển thị mèo và con số "Hôm nay thoải mái tiêu", kèm nút thêm nhanh.
6. **Xuất dữ liệu:** CSV và PDF.
7. **Nhập liệu bằng LLM:** hiểu câu phức tạp như "hôm qua đi ăn lẩu với 4 đứa, tao trả hết 640k, chia lại mỗi đứa 160k".

## 6. Các màn hình

1. **Onboarding (4 bước, dưới 60 giây):** chào mèo → chọn giống và đặt tên mèo → nhập thu nhập tháng và các khoản cố định chính → chọn giờ nhắc. Có nút "Bỏ qua, thiết lập sau".
2. **Trang chủ:** mèo ở giữa (animation), đĩa cá khô với con số "Hôm nay thoải mái tiêu", 3 giao dịch gần nhất, thanh nhập liệu cố định ở dưới.
3. **Giao dịch:** danh sách, lọc, tìm kiếm.
4. **Thống kê:** biểu đồ cột theo tuần/tháng (đơn giản), tỷ lệ theo cảm xúc, top 5 khoản chi nhiều nhất. **Không dùng biểu đồ tròn nhiều màu rối mắt.**
5. **Thư của Mèo:** báo cáo tuần dạng thẻ cuộn.
6. **Nhà của Mèo:** tùy chỉnh phụ kiện, nội thất, xem huy hiệu và chuỗi ngày.
7. **Cài đặt:** thu nhập, chi cố định, danh mục tùy chỉnh, giờ nhắc, bật/tắt quy đổi giờ làm, dark mode, xuất dữ liệu, khóa app bằng vân tay hoặc mã PIN.

## 7. Mô hình dữ liệu (gợi ý)

```
User/Profile: id, tên, tên_mèo, giống_mèo, thu_nhập_tháng, giờ_làm_tháng, mức_tiết_kiệm_%, tiền_tệ
Transaction: id, số_tiền, loại (chi/thu), danh_mục_id, ghi_chú, thời_gian, cảm_xúc (vui|cần|hối_hận|bốc_đồng|null), là_cố_định (bool), nguồn (nhập_tay|giọng_nói|thông_báo|hóa_đơn), trạng_thái (đã_xác_nhận|chờ)
Category: id, tên, biểu_tượng, màu, từ_khóa[]
KeywordRule: từ_khóa, danh_mục_id (do người dùng sửa mà học được)
FixedExpense: id, tên, số_tiền, ngày_trong_tháng
Streak: ngày_hiện_tại, kỷ_lục, thẻ_nghỉ_còn_lại
CatState: cấp_độ, điểm_cá, phụ_kiện_đã_mở[], phụ_kiện_đang_đeo[]
Badge: id, đã_đạt_ngày
WeeklyInsight: tuần, danh_sách_phát_hiện[], gợi_ý, lời_khen
```

## 8. Quy tắc trải nghiệm quan trọng

- **Không bao giờ phán xét:** từ ngữ luôn trung lập hoặc động viên. Cấm các từ như "lãng phí", "tệ", "quá tay".
- **Mọi thao tác chính dưới 3 chạm.** Ghi một khoản chi không quá 3 giây.
- **Dùng được hoàn toàn offline.**
- **Quyền riêng tư:** dữ liệu mặc định chỉ nằm trên máy. Có màn hình giải thích rõ ràng khi xin quyền nào.
- **Định dạng tiền:** `1.250.000đ` (dấu chấm ngăn cách hàng nghìn), hỗ trợ viết tắt k, tr.
- **Khả năng tiếp cận:** cỡ chữ điều chỉnh được, độ tương phản đạt chuẩn WCAG AA, mô tả cho trình đọc màn hình.
- **Hiệu năng:** khởi động dưới 2 giây trên máy tầm trung, animation mèo 60fps.

## 9. Lộ trình triển khai (cho Antigravity làm từng giai đoạn)

**Giai đoạn A – Nền tảng (làm trước):**

1. Khởi tạo dự án Flutter, cấu trúc thư mục theo tính năng (feature-first).
2. Cài đặt design system: màu, phông chữ, các thành phần dùng chung (nút, thẻ, ô nhập).
3. Dựng cơ sở dữ liệu SQLite với các bảng ở mục 7.
4. Onboarding và lưu hồ sơ.

**Giai đoạn B – Lõi:** 5. Parser câu nhập và thẻ xác nhận (kèm bộ test đơn vị với ít nhất 40 câu mẫu tiếng Việt). 6. Trang chủ với con số "Hôm nay thoải mái tiêu" và đĩa cá. 7. Danh sách giao dịch, sửa, xóa, hoàn tác. 8. Gắn cảm xúc. 9. Quy đổi giờ làm việc.

**Giai đoạn C – Mèo & gắn kết:** 10. Animation mèo theo các trạng thái ở mục 3.2. 11. Streak, điểm cá, phụ kiện, huy hiệu. 12. Thông báo nhắc nhở.

**Giai đoạn D – Thông minh:** 13. Thư của Mèo hàng tuần (bộ quy tắc phát hiện mẫu). 14. Tính năng "Nếu như...". 15. Thống kê.

**Giai đoạn E – Hoàn thiện MVP:** 16. Nhập giọng nói. 17. Dark mode, khóa app, xuất CSV. 18. Kiểm thử, tối ưu hiệu năng, chuẩn bị đưa lên cửa hàng ứng dụng.

## 10. Tiêu chí nghiệm thu MVP

- Cài mới đến lúc ghi được khoản chi đầu tiên: dưới 90 giây.
- Parser nhận đúng số tiền ở ít nhất 95% câu mẫu và đúng danh mục ở ít nhất 85%.
- Con số "Hôm nay thoải mái tiêu" tính đúng theo công thức ở mục 4.3 (có test cho các trường hợp: tiêu ít, tiêu vượt, đầu tháng, cuối tháng, có thu nhập phát sinh).
- Mèo chuyển đúng trạng thái theo mục 3.2.
- Hoạt động đầy đủ khi tắt mạng.
- Không có lỗi hiển thị dấu tiếng Việt.

## 11. Đoạn lời nhắc (prompt) để dán vào Antigravity

> Hãy xây dựng ứng dụng di động Flutter tên "Meo Xu" theo tài liệu đặc tả này. Bắt đầu với **Giai đoạn A**: khởi tạo dự án theo cấu trúc feature-first, dùng Riverpod cho quản lý trạng thái và Drift cho SQLite. Dựng design system (bảng màu, phông Nunito, các thành phần dùng chung) đúng mục 3.3. Tạo các bảng dữ liệu theo mục 7 và màn hình Onboarding 4 bước ở mục 6. Dùng placeholder (hình mèo đơn giản bằng SVG hoặc Lottie mẫu) cho nhân vật, tôi sẽ thay bằng hình minh họa chính thức sau. Mọi chuỗi giao diện đặt trong tệp i18n, mặc định tiếng Việt. Viết test đơn vị cho các hàm tính toán. Khi xong mỗi giai đoạn, hãy tóm tắt những gì đã làm và chờ tôi xác nhận trước khi sang giai đoạn kế tiếp.

*Mẹo:* giao Antigravity từng giai đoạn một (A → B → C...) thay vì cả đặc tả cùng lúc, để dễ kiểm tra và sửa lỗi.
