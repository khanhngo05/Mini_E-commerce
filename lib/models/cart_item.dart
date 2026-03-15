// lib/models/cart_item.dart
class CartItem {
  final String id; // ID của item trong giỏ
  final String productId; // ID của sản phẩm gốc
  final String title;
  final String imageUrl;
  final double price;
  final String variation; // Ví dụ: "Size L, Màu Đỏ"
  int quantity;
  bool isSelected; // Cực kỳ quan trọng cho màn hình của bạn

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.variation,
    this.quantity = 1,
    this.isSelected = false, // Mặc định khi thêm vào giỏ là chưa chọn
  });
}