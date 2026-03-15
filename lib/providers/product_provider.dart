import 'package:flutter/foundation.dart' hide Category;
import 'package:mini_e_commerce/models/banner_item.dart';
import 'package:mini_e_commerce/models/category.dart';
import 'package:mini_e_commerce/models/product.dart';
import 'package:mini_e_commerce/services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static const String allCategoryId = 'all';

  final ApiService _apiService;

  final List<Product> _allProducts = <Product>[];
  final List<BannerItem> _banners = <BannerItem>[];
  final List<Category> _categories = <Category>[];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  String? _selectedCategoryId;
  static const int _pageSize = 8;
  int _loadedCount = _pageSize;

  List<Product> get products {
    final source = (_selectedCategoryId == null || _selectedCategoryId == allCategoryId)
        ? _allProducts
        : _allProducts.where((product) {
            return _normalizeCategoryId(product.category) == _selectedCategoryId;
          }).toList();
    return List.unmodifiable(source);
  }

  List<BannerItem> get banners => List.unmodifiable(_banners);
  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  String? get selectedCategoryId => _selectedCategoryId;

  Future<void> fetchProducts({int limit = 8}) async {
    await fetchInitialProducts(limit: limit);
  }

  Future<void> fetchInitialProducts({int limit = 8}) async {
    _isLoading = true;
    _errorMessage = null;
    _hasMore = true;
    _loadedCount = limit < _pageSize ? _pageSize : limit;
    notifyListeners();

    try {
      final allProducts = await _apiService.fetchProducts(limit: _loadedCount);
      final apiCategoryIds = await _apiService.fetchProductCategoryIds();
      final localBanners = await _apiService.fetchLocalBanners();
      final localCategories = await _apiService.fetchLocalCategories();

      _allProducts
        ..clear()
        ..addAll(allProducts);
      _banners
        ..clear()
        ..addAll(localBanners);
      _categories
        ..clear()
        ..addAll(_buildResolvedCategories(localCategories, apiCategoryIds));
      _hasMore = allProducts.length >= _loadedCount;
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
      _loadedCount += _pageSize;
      final nextProducts = await _apiService.fetchProducts(limit: _loadedCount);
      _allProducts
        ..clear()
        ..addAll(nextProducts);
      _hasMore = nextProducts.length >= _loadedCount;
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isFetchingMore = false;
    notifyListeners();
  }

  void setCategory(String? categoryId) {
    final normalized = _normalizeCategoryId(categoryId);
    _selectedCategoryId = (normalized == null || normalized == allCategoryId)
        ? null
        : normalized;
    _hasMore = _allProducts.length >= _loadedCount;
    notifyListeners();
  }

  String? _normalizeCategoryId(String? raw) {
    if (raw == null) {
      return null;
    }
    final normalized = raw.trim().toLowerCase();
    return normalized.isEmpty ? null : normalized;
  }

  List<Category> _buildResolvedCategories(
    List<Category> localCategories,
    List<String> apiCategoryIds,
  ) {
    final availableCategoryIds = apiCategoryIds
        .map(_normalizeCategoryId)
        .whereType<String>()
        .toSet();

    final resolved = <Category>[
      const Category(id: allCategoryId, name: 'Tất cả', icon: 'shopping_basket'),
    ];

    final seen = <String>{};
    for (final category in localCategories) {
      final id = _normalizeCategoryId(category.id);
      if (id == null || !availableCategoryIds.contains(id) || seen.contains(id)) {
        continue;
      }
      resolved.add(Category(id: id, name: category.name, icon: category.icon));
      seen.add(id);
    }

    for (final id in availableCategoryIds) {
      if (seen.contains(id)) {
        continue;
      }
      resolved.add(Category(id: id, name: id, icon: 'category'));
      seen.add(id);
    }

    return resolved;
  }
}
