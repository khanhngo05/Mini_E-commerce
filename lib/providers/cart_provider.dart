import 'package:flutter/foundation.dart';
import 'package:mini_e_commerce/models/cart_item.dart';
import 'package:mini_e_commerce/models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get totalItemTypes => _items.length;
  int get totalQuantity =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  void setItems(List<CartItem> nextItems) {
    _items
      ..clear()
      ..addAll(nextItems);
    notifyListeners();
  }

  void addProduct(
    Product product, {
    int quantity = 1,
    String size = 'M',
    String color = 'Default',
  }) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          id: 'cart_${product.id}_${DateTime.now().microsecondsSinceEpoch}',
          product: product,
          quantity: quantity,
          size: size,
          color: color,
        ),
      );
    }

    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
