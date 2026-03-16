import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mini_e_commerce/models/order.dart';
import 'package:mini_e_commerce/services/local_storage_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({LocalStorageService? localStorageService})
    : _localStorageService = localStorageService ?? LocalStorageService() {
    _initializationFuture = loadOrders();
  }

  final List<Order> _orders = [];
  final LocalStorageService _localStorageService;
  late final Future<void> _initializationFuture;
  bool _isInitialized = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isInitialized => _isInitialized;

  Future<void> _waitUntilInitialized() async {
    if (_isInitialized) {
      return;
    }
    await _initializationFuture;
  }

  Future<void> loadOrders() async {
    final storedOrders = await _localStorageService.readOrders();
    _orders
      ..clear()
      ..addAll(storedOrders);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addOrder(Order order) async {
    await _waitUntilInitialized();
    _orders.insert(0, order);
    await _localStorageService.saveOrders(_orders);
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

  Future<bool> cancelOrder(String orderId, String reason) async {
    await _waitUntilInitialized();

    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      return false;
    }

    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex < 0) {
      return false;
    }

    final targetOrder = _orders[orderIndex];
    if (targetOrder.status != OrderStatus.pendingConfirmation) {
      return false;
    }

    _orders[orderIndex] = targetOrder.copyWith(
      status: OrderStatus.canceled,
      cancellationReason: normalizedReason,
    );
    await _localStorageService.saveOrders(_orders);
    notifyListeners();
    return true;
  }
}
