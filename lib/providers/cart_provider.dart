import 'package:flutter/foundation.dart';
import 'package:mini_e_commerce/models/cart_item.dart';

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

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
