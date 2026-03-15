import 'dart:async';
import 'package:flutter/material.dart';
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

  // --- PHẦN 1: TÍNH TỔNG TIỀN CHỈ CHO NHỮNG ITEM ĐƯỢC TICK (Logic của bạn) ---
  double get totalAmount {
    return _items.fold<double>(0, (sum, item) {
      if (item.isSelected) {
        return sum + item.lineTotal;
      }
      return sum;
    });
  }

  // --- PHẦN 2: KIỂM TRA CHỌN TẤT CẢ (Logic của bạn) ---
  bool get isAllSelected {
    if (_items.isEmpty) return false;
    return _items.every((item) => item.isSelected);
  }

  // --- CÁC HÀM CỦA NHÓM LÀM (LƯU LOCAL STORAGE) ---
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

  // --- PHẦN 3: LOGIC CHỌN TỪNG ITEM (Đã gộp chung với Local Storage) ---
  void toggleItemSelection(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;

    final target = _items[index];
    _items[index] = target.copyWith(isSelected: !target.isSelected);
    unawaited(_localStorageService.saveCart(_items));
    notifyListeners();
  }

  // --- PHẦN 4: LOGIC CHỌN TẤT CẢ / BỎ CHỌN TẤT CẢ (Logic của bạn) ---
  void toggleSelectAll(bool isSelected) {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isSelected: isSelected);
    }
    unawaited(_localStorageService.saveCart(_items));
    notifyListeners();
  }

  // --- PHẦN 5: LOGIC TĂNG GIẢM SỐ LƯỢNG (+/-) (Logic của bạn) ---
  void updateQuantity(String cartItemId, int delta) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;

    int nextQuantity = _items[index].quantity + delta;
    if (nextQuantity > 0) {
      _items[index] = _items[index].copyWith(quantity: nextQuantity);
      unawaited(_localStorageService.saveCart(_items));
      notifyListeners();
    }
  }

  // --- PHẦN 6: XOÁ ITEM (Nhóm) ---
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