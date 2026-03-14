import 'package:mini_e_commerce/models/product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String size;
  final String color;
  final bool isSelected;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.size,
    required this.color,
    this.isSelected = true,
  });

  double get lineTotal => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['id'] ?? '') as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      size: (json['size'] ?? '') as String,
      color: (json['color'] ?? '') as String,
      isSelected: (json['isSelected'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'size': size,
      'color': color,
      'isSelected': isSelected,
    };
  }

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? size,
    String? color,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
