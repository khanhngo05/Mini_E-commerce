# Mini E-Commerce (Flutter)

Ứng dụng thương mại điện tử mini được xây dựng bằng Flutter, mô phỏng các luồng cốt lõi của một app mua sắm hiện đại: đăng nhập người dùng, duyệt sản phẩm, lọc theo danh mục, quản lý giỏ hàng, checkout và theo dõi lịch sử đơn hàng.

## Mục tiêu dự án

- Xây dựng app E-Commerce theo kiến trúc rõ ràng, dễ mở rộng.
- Thực hành quản lý state với Provider.
- Kết hợp dữ liệu từ API ngoài và dữ liệu local.
- Tổ chức luồng xác thực và điều hướng theo trạng thái đăng nhập.
- Lưu trạng thái phiên đăng nhập, giỏ hàng và đơn hàng cục bộ để cải thiện trải nghiệm người dùng.

## Tính năng chính

- Hiển thị danh sách sản phẩm từ Fake Store API.
- Đăng nhập bằng Fake Store API (`/auth/login`).
- `AuthGate` tự động điều hướng:
	- Đã đăng nhập -> vào trang mua sắm.
	- Chưa đăng nhập -> vào màn hình đăng nhập.
- Khôi phục phiên đăng nhập từ local storage khi mở app.
- Hỗ trợ đăng xuất trực tiếp từ màn hình chính.
- Fallback tài khoản demo khi API đăng nhập lỗi mạng.
- Danh mục sản phẩm và banner trang chủ từ `assets/data/home_content.json`.
- Lọc sản phẩm theo danh mục.
- Xem chi tiết sản phẩm.
- Giỏ hàng:
	- Thêm sản phẩm với biến thể (size, color).
	- Tăng/giảm số lượng.
	- Chọn từng sản phẩm hoặc chọn tất cả.
	- Tính tổng tiền theo sản phẩm được chọn.
- Checkout từ các sản phẩm đã chọn.
- Lưu và hiển thị lịch sử đơn hàng.
- Điều hướng theo named routes tập trung tại `AppRouter`.

## Công nghệ sử dụng

- Flutter (SDK Dart `^3.10.7`)
- State management: `provider`
- HTTP client: `http`
- Local persistence: `shared_preferences`
- Date/formatting: `intl`
- Routing: named routes qua `AppRouter` + `AuthGateScreen`
- Testing:
	- `flutter_test`
	- `network_image_mock`

## Kiến trúc thư mục

```text
lib/
	main.dart
	app_router.dart
	constants/
	models/
	providers/
	screens/
	services/
	utils/
	widgets/

assets/
	data/
		home_content.json

test/
	home/
```

## Luồng dữ liệu tổng quan

1. `ProductProvider` gọi `ApiService` để lấy danh sách sản phẩm và category từ API.
2. `ApiService` đồng thời đọc banner/category local từ `home_content.json`.
3. `AuthProvider` gọi API login, lưu token vào local và khôi phục phiên khi app khởi động.
4. `AuthGateScreen` quyết định hiển thị `LoginScreen` hay `HomeScreen` theo trạng thái auth.
5. UI lắng nghe thay đổi thông qua `ChangeNotifier` và render lại tự động.
6. `CartProvider` và `OrderProvider` lưu dữ liệu vào local bằng `LocalStorageService`.

## Bắt đầu nhanh

### 1) Yêu cầu môi trường

- Flutter SDK (khuyến nghị bản ổn định mới nhất)
- Dart SDK tương thích với `^3.10.7`
- Android Studio hoặc VS Code + Flutter extension

### 2) Cài đặt dependency

```bash
flutter pub get
```

### 3) Chạy ứng dụng

```bash
flutter run
```

Tài khoản demo mặc định:

- Username: `group10`
- Password: `group10@`

### 4) Chạy test

```bash
flutter test
```

## Testing hiện có

Dự án hiện có các test tiêu biểu:

- `test/home/home_screen_widget_test.dart`
- `test/home/home_product_provider_test.dart`
- `test/home/cart_provider_test.dart`

Lưu ý:

- Nếu chạy `flutter test` ở root workspace nhiều dự án, kết quả có thể fail do project khác.
- Để đúng phạm vi dự án này, chạy test trong thư mục `mini_e_commerce`.

## Định hướng phát triển

- Tích hợp backend thực tế cho user profile, đơn hàng và thanh toán.
- Thêm tìm kiếm, wishlist, đánh giá sản phẩm.
- Bổ sung xử lý offline/empty/error states chi tiết hơn.
- Tăng độ phủ test cho toàn bộ các màn hình quan trọng.
- Tối ưu hiệu năng và trải nghiệm đa nền tảng.

## Đóng góp

Mọi đóng góp đều được chào đón. Bạn có thể:

1. Fork repository.
2. Tạo branch mới cho tính năng hoặc bugfix.
3. Commit và mở Pull Request.

## License

Dự án phục vụ mục đích học tập và thực hành.
