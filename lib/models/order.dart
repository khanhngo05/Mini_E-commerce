import 'package:mini_e_commerce/models/cart_item.dart';

enum OrderStatus { pendingConfirmation, shipping, delivered, canceled }

class Order {
  final String id;
  final List<CartItem> items;
  final String shippingAddress;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  double get totalAmount {
    return items.fold<double>(0, (sum, item) => sum + item.lineTotal);
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? const []);
    return Order(
      id: (json['id'] ?? '') as String,
      items: rawItems
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      shippingAddress: (json['shippingAddress'] ?? '') as String,
      paymentMethod: (json['paymentMethod'] ?? '') as String,
      status: _orderStatusFromString(
        (json['status'] ?? 'pendingConfirmation') as String,
      ),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '') as String) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Order copyWith({
    String? id,
    List<CartItem>? items,
    String? shippingAddress,
    String? paymentMethod,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static OrderStatus _orderStatusFromString(String value) {
    switch (value) {
      case 'pendingConfirmation':
        return OrderStatus.pendingConfirmation;
      case 'shipping':
        return OrderStatus.shipping;
      case 'delivered':
        return OrderStatus.delivered;
      case 'canceled':
        return OrderStatus.canceled;
      default:
        return OrderStatus.pendingConfirmation;
    }
  }
}
