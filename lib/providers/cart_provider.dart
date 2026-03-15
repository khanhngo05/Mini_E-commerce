import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final LocalStorageService _storage = LocalStorageService();

  List<CartItem> get items => List.unmodifiable(_items);

  List<CartItem> get selectedItems =>
      _items.where((item) => item.isSelected).toList(growable: false);
  bool get hasSelectedItems => selectedItems.isNotEmpty;
  bool get allSelected => isAllSelected;

  int get totalItemTypes => _items.length;
  int get totalQuantity =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  // Logic Người 4: Tổng tiền chỉ tính món được tick
  double get totalAmount => selectedItems.fold<double>(
    0,
    (sum, item) => sum + item.lineTotal,
  );

  double get selectedAmount => totalAmount;

  bool get isAllSelected => _items.isNotEmpty && _items.every((item) => item.isSelected);

  void setItems(List<CartItem> nextItems) {
    _items
      ..clear()
      ..addAll(nextItems);
    _saveAndNotify();
  }

  void addProduct(
    Product product, {
    int quantity = 1,
    String size = 'M',
    String color = 'Default',
    bool isSelected = false,
  }) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.size == size &&
          item.color == color,
    );
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
        isSelected: isSelected ? true : _items[index].isSelected,
      );
    } else {
      _items.add(CartItem(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: quantity,
        size: size,
        color: color,
        isSelected: isSelected,
      ));
    }
    _saveAndNotify();
  }

  void setItemSelection(String id, bool isSelected) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isSelected: isSelected);
      _saveAndNotify();
    }
  }

  void toggleItemSelection(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      setItemSelection(id, !_items[index].isSelected);
    }
  }

  void toggleSelectAll(bool value) {
    if (_items.isEmpty) {
      return;
    }
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isSelected: value);
    }
    _saveAndNotify();
  }

  void removeSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
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