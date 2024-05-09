import 'package:flutter/material.dart';

class TabControllerProvider with ChangeNotifier {
  late TabController tabController;

  void initializeTabController(TickerProvider vsync, {required int length}) {
    tabController = TabController(vsync: vsync, length: length);
  }

  void changeTab(int index) {
    tabController.animateTo(index);
    notifyListeners();
  }
}
