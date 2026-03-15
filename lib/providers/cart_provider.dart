// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  // 1. Tính tổng tiền CHỈ cho những item được tick (isSelected == true)
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      if (cartItem.isSelected) {
        total += cartItem.price * cartItem.quantity;
      }
    });
    return total;
  }

  // 2. Kiểm tra xem có phải TẤT CẢ item đều đang được tick không?
  bool get isAllSelected {
    if (_items.isEmpty) return false;
    return _items.values.every((item) => item.isSelected);
  }

  // 3. Logic chọn từng item (Tick/Untick 1 sản phẩm)
  void toggleItemSelection(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.isSelected = !_items[productId]!.isSelected;
      notifyListeners(); // Cập nhật UI ngay lập tức
    }
  }

  // 4. Logic Chọn tất cả / Bỏ chọn tất cả
  void toggleSelectAll(bool isSelected) {
    _items.forEach((key, cartItem) {
      cartItem.isSelected = isSelected;
    });
    notifyListeners();
  }

  // 5. Logic Tăng / Giảm số lượng (+/-)
  void updateQuantity(String productId, int delta) {
    if (_items.containsKey(productId)) {
      int newQuantity = _items[productId]!.quantity + delta;
      
      // Nếu số lượng về 0, UI sẽ gọi hàm removeItem, ở đây chỉ xử lý logic > 0
      if (newQuantity > 0) {
        _items[productId]!.quantity = newQuantity;
        notifyListeners();
      }
    }
  }

  // 6. Xóa item khỏi giỏ (Dùng cho thao tác Swipe to delete)
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // (Phụ) Hàm này để Người 3 dùng khi bấm "Thêm vào giỏ" từ màn Detail
  void addItem({
    required String productId,
    required String title,
    required double price,
    required String imageUrl,
    required String variation,
    int quantity = 1,
  }) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += quantity;
    } else {
      _items[productId] = CartItem(
        id: DateTime.now().toString(),
        productId: productId,
        title: title,
        price: price,
        imageUrl: imageUrl,
        variation: variation,
        quantity: quantity,
      );
    }
    notifyListeners();
  }
}