import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mini_e_commerce/models/order.dart';
import 'package:mini_e_commerce/services/local_storage_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({LocalStorageService? localStorageService})
    : _localStorageService = localStorageService ?? LocalStorageService() {
    unawaited(loadOrders());
  }

  final List<Order> _orders = [];
  final LocalStorageService _localStorageService;
  bool _isInitialized = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isInitialized => _isInitialized;

  Future<void> loadOrders() async {
    final storedOrders = await _localStorageService.readOrders();
    _orders
      ..clear()
      ..addAll(storedOrders);
    _isInitialized = true;
    notifyListeners();
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    unawaited(_localStorageService.saveOrders(_orders));
    notifyListeners();
  }

  void setOrders(List<Order> nextOrders) {
    _orders
      ..clear()
      ..addAll(nextOrders);
    unawaited(_localStorageService.saveOrders(_orders));
    notifyListeners();
  }

  void clear() {
    _orders.clear();
    unawaited(_localStorageService.saveOrders(_orders));
    notifyListeners();
  }
}
