import 'package:flutter/material.dart';

class QuantityProvider extends ChangeNotifier {
  int _currentNumber = 1;

  int get currentNumber => _currentNumber;

  void initQuantity(int initial) {
    _currentNumber = initial;
  }

  void increaseQuantity() {
    _currentNumber++;
    notifyListeners();
  }

  void decreaseQuantity() {
    if (_currentNumber > 1) {
      _currentNumber--;
      notifyListeners();
    }
  }
}