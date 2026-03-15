import 'package:flutter/foundation.dart';

class UiProvider extends ChangeNotifier {
  int _selectedBottomTab = 0;
  int _currentBannerIndex = 0;

  int get selectedBottomTab => _selectedBottomTab;
  int get currentBannerIndex => _currentBannerIndex;

  void setBottomTab(int index) {
    if (_selectedBottomTab == index) {
      return;
    }
    _selectedBottomTab = index;
    notifyListeners();
  }

  void setBannerIndex(int index) {
    if (_currentBannerIndex == index) {
      return;
    }
    _currentBannerIndex = index;
    notifyListeners();
  }
}
