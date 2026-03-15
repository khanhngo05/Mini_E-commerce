import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mini_e_commerce/models/cart_item.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/services/local_storage_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({LocalStorageService? localStorageService})
    : _localStorageService = localStorageService ?? LocalStorageService() {
    unawaited(loadCart());
  }

  final List<CartItem> _items = [];
  final LocalStorageService _localStorageService;
  bool _isInitialized = false;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isInitialized => _isInitialized;
  int get totalItemTypes => _items.length;
  int get totalQuantity =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);
  double get totalAmount =>
      _items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  Future<void> loadCart() async {
    final storedItems = await _localStorageService.readCart();
    _items
      ..clear()
      ..addAll(storedItems);
    _isInitialized = true;
    notifyListeners();
  }

  void setItems(List<CartItem> nextItems) {
    _items
      ..clear()
      ..addAll(nextItems);
    unawaited(_localStorageService.saveCart(_items));
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

    unawaited(_localStorageService.saveCart(_items));
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int nextQuantity) {
    if (nextQuantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) {
      return;
    }

    _items[index] = _items[index].copyWith(quantity: nextQuantity);
    unawaited(_localStorageService.saveCart(_items));
    notifyListeners();
  }

  void toggleSelection(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) {
      return;
    }

    final target = _items[index];
    _items[index] = target.copyWith(isSelected: !target.isSelected);
    unawaited(_localStorageService.saveCart(_items));
    notifyListeners();
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    unawaited(_localStorageService.saveCart(_items));
    notifyListeners();
  }

  void clear() {
    _items.clear();
    unawaited(_localStorageService.saveCart(_items));
    notifyListeners();
  }
}
