import 'package:flutter/material.dart';
import 'package:mini_e_commerce/app_router.dart';
import 'package:mini_e_commerce/constants/app_theme.dart';
import 'package:mini_e_commerce/providers/auth_provider.dart';
import 'package:mini_e_commerce/providers/cart_provider.dart';
import 'package:mini_e_commerce/providers/order_provider.dart';
import 'package:mini_e_commerce/providers/product_provider.dart';
import 'package:mini_e_commerce/providers/ui_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MiniECommerceApp());
}

class MiniECommerceApp extends StatelessWidget {
  const MiniECommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider()),
        ChangeNotifierProvider<UiProvider>(create: (_) => UiProvider()),
      ],
      child: MaterialApp(
        title: 'TH4 - G10',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRouter.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
