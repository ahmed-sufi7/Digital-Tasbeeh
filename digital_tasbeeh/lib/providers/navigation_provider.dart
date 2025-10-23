import 'package:flutter/foundation.dart';

enum NavigationTab {
  home,
  manage,
  stats,
}

class NavigationProvider extends ChangeNotifier {
  NavigationTab _currentTab = NavigationTab.home;
  
  NavigationTab get currentTab => _currentTab;
  
  void setTab(NavigationTab tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      notifyListeners();
    }
  }
  
  bool isTabActive(NavigationTab tab) {
    return _currentTab == tab;
  }
}