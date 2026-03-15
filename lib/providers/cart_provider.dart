import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final LocalStorageService _storage = LocalStorageService();

  List<CartItem> get items => List.unmodifiable(_items);

  // Getter dùng cho Badge ở HomeScreen
  int get totalItemTypes => _items.length;

  // Logic Người 4: Tổng tiền chỉ tính món được tick
  double get totalAmount => _items.fold(0.0, (sum, item) => item.isSelected ? sum + item.lineTotal : sum);

  bool get isAllSelected => _items.isNotEmpty && _items.every((item) => item.isSelected);

  void addProduct(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + quantity);
    } else {
      _items.add(CartItem(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: quantity,
        isSelected: false,
      ));
    }
    _saveAndNotify();
  }

  void toggleItemSelection(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isSelected: !_items[index].isSelected);
      _saveAndNotify();
    }
  }

  void toggleSelectAll(bool value) {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isSelected: value);
    }
    _saveAndNotify();
  }

  void updateQuantity(String id, int delta) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      int newQty = _items[index].quantity + delta;
      if (newQty > 0) {
        _items[index] = _items[index].copyWith(quantity: newQty);
        _saveAndNotify();
      }
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveAndNotify();
  }

  // Hàm clear() để CheckoutScreen gọi khi đặt hàng xong
  void clear() {
    _items.clear();
    _saveAndNotify();
  }

  void _saveAndNotify() {
    unawaited(_storage.saveCart(_items));
    notifyListeners();
  }
}