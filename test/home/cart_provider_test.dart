import 'package:flutter_test/flutter_test.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/providers/cart_provider.dart';
// 👇 1. THÊM IMPORT NÀY 👇
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // 👇 2. THÊM DÒNG NÀY ĐỂ KHỞI TẠO MÔI TRƯỜNG TEST 👇
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CartProvider Logic Tests (Người 4)', () {
    late CartProvider cartProvider;
    late Product mockProduct;

    setUp(() {
      // 👇 3. "LỪA" FLUTTER RẰNG ĐÃ CÓ BỘ NHỚ GIẢ LẬP 👇
      SharedPreferences.setMockInitialValues({}); 
      
      cartProvider = CartProvider();
      mockProduct = Product(
        id: 2251061749, // Mã số sinh viên của bạn (kiểu int)
        title: 'Sản phẩm Test',
        price: 150000.0,
        imageUrl: '',
        description: 'Test logic Người 4',
        category: 'Fashion',
        rating: 4.5,
        ratingCount: 10,
      );
    });

    test('Logic: Tính tổng tiền khi tick chọn', () {
      cartProvider.addProduct(mockProduct, quantity: 2);
      final id = cartProvider.items.first.id;
      
      // Ban đầu chưa tick -> 0đ
      expect(cartProvider.totalAmount, 0.0);

      cartProvider.toggleItemSelection(id);
      // 150.000 * 2 = 300.000
      expect(cartProvider.totalAmount, 300000.0);

      cartProvider.setItemSelection(id, false);
      // Bỏ tick thì tổng phải tự động trừ về 0
      expect(cartProvider.totalAmount, 0.0);
    });

    test('Logic: Chọn tất cả 2 chiều', () {
      cartProvider.addProduct(mockProduct, quantity: 1);
      cartProvider.toggleSelectAll(true);
      expect(cartProvider.isAllSelected, true);
    });
  });
}