import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_e_commerce/constants/app_theme.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/providers/cart_provider.dart';
import 'package:mini_e_commerce/providers/product_provider.dart';
import 'package:mini_e_commerce/screens/home_screen.dart';
import 'package:mini_e_commerce/services/product_service.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

void main() {
  group('HomeScreen widget', () {
    testWidgets('renders core ecommerce elements', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ProductProvider>(
                create: (_) =>
                    ProductProvider(productService: _FakeProductService()),
              ),
              ChangeNotifierProvider<CartProvider>(
                create: (_) => CartProvider(),
              ),
            ],
            child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();
      });

      expect(find.text('TH4 - Nhóm G10'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}

class _FakeProductService extends ProductService {
  @override
  Future<List<Product>> fetchProducts({int limit = 20}) async {
    final products = List<Product>.generate(12, (index) {
      return Product(
        id: index + 1,
        title: 'San pham ${index + 1}',
        price: 10 + index.toDouble(),
        description: 'Mo ta',
        category: 'Category',
        imageUrl: 'https://example.com/product_${index + 1}.jpg',
        rating: 4.3,
        ratingCount: 1234 + index,
      );
    });
    return products.take(limit).toList();
  }
}
