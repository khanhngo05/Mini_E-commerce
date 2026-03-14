import 'package:flutter/foundation.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductService? productService})
    : _productService = productService ?? ProductService();

  final ProductService _productService;

  final List<Product> _products = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  static const int _pageSize = 8;
  int _nextPage = 1;

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts({int limit = 8}) async {
    await fetchInitialProducts(limit: limit);
  }

  Future<void> fetchInitialProducts({int limit = 8}) async {
    _isLoading = true;
    _errorMessage = null;
    _hasMore = true;
    _nextPage = 1;
    notifyListeners();

    try {
      final firstPageLimit = limit < _pageSize ? _pageSize : limit;
      final result = await _productService.fetchProducts(limit: firstPageLimit);
      _products.clear();
      _products.addAll(result);
      _hasMore = result.length >= firstPageLimit;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts({int limit = 8}) async {
    await fetchInitialProducts(limit: limit);
  }

  Future<void> fetchMoreProducts() async {
    if (_isLoading || _isFetchingMore || !_hasMore) {
      return;
    }

    _isFetchingMore = true;
    notifyListeners();

    try {
      final nextLimit = (_nextPage + 1) * _pageSize;
      final result = await _productService.fetchProducts(limit: nextLimit);

      if (result.length <= _products.length) {
        _hasMore = false;
      } else {
        _products.addAll(result.sublist(_products.length));
        _nextPage++;
        _hasMore = result.length >= nextLimit;
      }
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isFetchingMore = false;
    notifyListeners();
  }
}
