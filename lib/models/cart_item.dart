class CartItem {
  final String id;
  final String productId;
  final String title;
  final String imageUrl;
  final double price;
  final String variation;
  int quantity;
  bool isSelected;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.variation,
    this.quantity = 1,
    this.isSelected = false,
  });

  // 👇 THÊM DÒNG NÀY VÀO ĐÂY 👇
  // Getter tính tổng tiền của riêng item này (Đơn giá x Số lượng)
  double get lineTotal => price * quantity; 
}