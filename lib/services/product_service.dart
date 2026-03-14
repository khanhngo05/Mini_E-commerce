import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_e_commerce/models/product.dart';

class ProductService {
  ProductService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://fakestoreapi.com';
  final http.Client _client;

  Future<List<Product>> fetchProducts({int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl/products?limit=$limit');

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw ApiException(
          'Khong lay duoc danh sach san pham. Ma loi: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const ApiException('Du lieu san pham khong dung dinh dang.');
      }

      return decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException('Loi ket noi API: $error');
    }
  }

  Future<Product> fetchProductById(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw ApiException(
          'Khong lay duoc chi tiet san pham. Ma loi: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Du lieu chi tiet san pham khong hop le.');
      }

      return Product.fromJson(decoded);
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException('Loi ket noi API: $error');
    }
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
