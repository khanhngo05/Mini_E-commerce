import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mini_e_commerce/services/api_service.dart';
import 'package:mini_e_commerce/services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    ApiService? apiService,
    LocalStorageService? localStorageService,
  }) : _apiService = apiService ?? ApiService(),
       _localStorageService = localStorageService ?? LocalStorageService() {
    unawaited(restoreSession());
  }

  final ApiService _apiService;
  final LocalStorageService _localStorageService;
  static const String _demoUsername = 'group10';
  static const String _demoPassword = 'group10@';

  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await _localStorageService.readAuthToken();
      _errorMessage = null;
    } catch (_) {
      _token = null;
      _errorMessage = 'Không thể khôi phục phiên đăng nhập.';
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _apiService.login(
        username: username,
        password: password,
      );
      _token = token;
      await _localStorageService.saveAuthToken(token);
      return true;
    } catch (error) {
      // Fallback cho tài khoản demo trong trường hợp API bị lỗi mạng.
      if (username.trim() == _demoUsername && password == _demoPassword) {
        _token = 'demo_local_token';
        await _localStorageService.saveAuthToken(_token!);
        _errorMessage = null;
        return true;
      }

      _token = null;
      _errorMessage = error.toString().replaceFirst('ApiException: ', '');
      if (_errorMessage == null || _errorMessage!.trim().isEmpty) {
        _errorMessage = 'Đăng nhập thất bại. Vui lòng kiểm tra tài khoản.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _localStorageService.clearAuthToken();
    } finally {
      _token = null;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }
}
