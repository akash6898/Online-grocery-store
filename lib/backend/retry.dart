import 'package:flutter/material.dart';

class Retry extends ChangeNotifier {
  void retry() {
    notifyListeners();
  }

  Future retry1() async {
    await Future.delayed(const Duration(seconds: 5), () {
      notifyListeners();
    });
  }
}
