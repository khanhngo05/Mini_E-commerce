import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:mini_e_commerce/models/banner_item.dart';
import 'package:mini_e_commerce/models/category.dart';
import 'package:mini_e_commerce/models/product.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://fakestoreapi.com';
  final http.Client _client;

  Future<List<Product>> fetchProducts({int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl/products?limit=$limit');
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw ApiException(
          'Cannot fetch products. Code: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const ApiException('Products response has invalid format.');
      }

      return decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException('Network error while fetching products: $error');
    }
  }

  Future<Product> fetchProductById(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw ApiException(
          'Cannot fetch product detail. Code: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Product detail response has invalid format.');
      }

      return Product.fromJson(decoded);
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException('Network error while fetching product detail: $error');
    }
  }

  Future<List<BannerItem>> fetchLocalBanners() async {
    final content = await _loadHomeContentJson();
    final rawBanners = content['banners'];
    if (rawBanners is! List) {
      return const <BannerItem>[];
    }

    return rawBanners
        .map((item) => BannerItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Category>> fetchLocalCategories() async {
    final content = await _loadHomeContentJson();
    final rawCategories = content['categories'];
    if (rawCategories is! List) {
      return const <Category>[];
    }

    return rawCategories
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> _loadHomeContentJson() async {
    final raw = await rootBundle.loadString('assets/data/home_content.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Home content JSON has invalid format.');
    }
    return decoded;
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
