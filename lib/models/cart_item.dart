import 'product.dart';

class CartItem {
  final String id;
  final Product product; // Phải dùng đối tượng Product hoàn chỉnh
  final int quantity;
  final String size;
  final String color;
  final bool isSelected;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.size = 'M',
    this.color = 'Default',
    this.isSelected = false,
  });

  // 👇 ĐÂY LÀ DÒNG NGƯỜI 5 (ORDER) ĐANG CẦN ĐỂ HẾT LỖI 👇
  double get lineTotal => product.price * quantity;

  // Hàm hỗ trợ cập nhật dữ liệu (Immutable)
  CartItem copyWith({
    int? quantity,
    bool? isSelected,
  }) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
      size: size,
      color: color,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Phục vụ Người 1 lưu Local Storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'product': product.toJson(),
        'quantity': quantity,
        'size': size,
        'color': color,
        'isSelected': isSelected,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        product: Product.fromJson(json['product']),
        quantity: json['quantity'],
        size: json['size'],
        color: json['color'],
        isSelected: json['isSelected'] ?? false,
      );
}