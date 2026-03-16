import 'package:flutter/material.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/screens/auth_gate_screen.dart';
import 'package:mini_e_commerce/models/cart_item.dart';
import 'package:mini_e_commerce/screens/cart_screen.dart';
import 'package:mini_e_commerce/screens/checkout_screen.dart';
import 'package:mini_e_commerce/screens/home_screen.dart';
import 'package:mini_e_commerce/screens/login_screen.dart';
import 'package:mini_e_commerce/screens/order_history_screen.dart';
import 'package:mini_e_commerce/screens/product_detail_screen.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
  static const String login = '/login';
  static const String shopHome = '/shop-home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthGateScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case shopHome:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case productDetail:
        final product = settings.arguments;
        if (product is! Product) {
          return MaterialPageRoute<void>(
            builder: (_) => const _NotFoundScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute<void>(
          builder: (_) => ProductDetailScreen(product: product),
          settings: settings,
        );
      case cart:
        return MaterialPageRoute<void>(
          builder: (_) => const CartScreen(),
          settings: settings,
        );
      case checkout:
        final selectedItems = settings.arguments;
        return MaterialPageRoute<void>(
          builder: (_) => CheckoutScreen(
            selectedItems: selectedItems is List
                ? selectedItems.cast<CartItem>()
                : null,
          ),
          settings: settings,
        );
      case orderHistory:
        return MaterialPageRoute<void>(
          builder: (_) => const OrderHistoryScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const _NotFoundScreen(),
          settings: settings,
        );
    }
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Khong tim thay man hinh')));
  }
}
