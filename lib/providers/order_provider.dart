import 'package:flutter/foundation.dart';
import 'package:mini_e_commerce/models/order.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void setOrders(List<Order> nextOrders) {
    _orders
      ..clear()
      ..addAll(nextOrders);
    notifyListeners();
  }

  void clear() {
    _orders.clear();
    notifyListeners();
  }
}
