import 'dart:convert';

import 'package:mini_e_commerce/models/cart_item.dart';
import 'package:mini_e_commerce/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _cartKey = 'cart_items_v1';
  static const String _orderKey = 'orders_v1';

  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = items.map((item) => item.toJson()).toList();
    await prefs.setString(_cartKey, jsonEncode(payload));
  }

  Future<List<CartItem>> readCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);
    if (raw == null || raw.isEmpty) {
      return const <CartItem>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <CartItem>[];
    }

    return decoded
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = orders.map((order) => order.toJson()).toList();
    await prefs.setString(_orderKey, jsonEncode(payload));
  }

  Future<List<Order>> readOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_orderKey);
    if (raw == null || raw.isEmpty) {
      return const <Order>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <Order>[];
    }

    return decoded
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
