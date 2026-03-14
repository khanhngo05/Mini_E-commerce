import 'package:flutter_test/flutter_test.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/providers/product_provider.dart';
import 'package:mini_e_commerce/services/product_service.dart';

void main() {
  group('Home ProductProvider', () {
    test('fetchInitialProducts loads first page and enables hasMore', () async {
      final provider = ProductProvider(productService: _FakeProductService());

      await provider.fetchInitialProducts();

      expect(provider.products.length, 8);
      expect(provider.hasMore, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('fetchMoreProducts appends next page and stops at end', () async {
      final provider = ProductProvider(productService: _FakeProductService());

      await provider.fetchInitialProducts();
      await provider.fetchMoreProducts();
      expect(provider.products.length, 16);
      expect(provider.hasMore, isTrue);

      await provider.fetchMoreProducts();
      expect(provider.products.length, 18);
      expect(provider.hasMore, isFalse);
      expect(provider.isFetchingMore, isFalse);
    });

    test('refreshProducts resets list to first page', () async {
      final provider = ProductProvider(productService: _FakeProductService());

      await provider.fetchInitialProducts();
      await provider.fetchMoreProducts();
      expect(provider.products.length, 16);

      await provider.refreshProducts();
      expect(provider.products.length, 8);
      expect(provider.hasMore, isTrue);
      expect(provider.errorMessage, isNull);
    });
  });
}

class _FakeProductService extends ProductService {
  @override
  Future<List<Product>> fetchProducts({int limit = 20}) async {
    final products = List<Product>.generate(18, (index) {
      return Product(
        id: index + 1,
        title: 'San pham ${index + 1}',
        price: 12.5 + index,
        description: 'Mo ta san pham',
        category: 'Category',
        imageUrl: 'https://example.com/product_${index + 1}.jpg',
        rating: 4.5,
        ratingCount: 1200 + index,
      );
    });

    return products.take(limit).toList();
  }
}
