import 'package:flutter/material.dart';

class CreditCardCalculatorProvider extends ChangeNotifier {
  double balance = 0;
  double apr = 18;
  double additionalPayment = 0;
  double minPaymentPercent = 3;
  double minPaymentAmount = 35;
  bool skipDecember = false;
  String displayType = 'Yearly';

  void updateBalance(double value) {
    balance = value;
    notifyListeners();
  }

  void updateApr(double value) {
    apr = value;
    notifyListeners();
  }

  void updateAdditionalPayment(double value) {
    additionalPayment = value;
    notifyListeners();
  }

  void updateMinPaymentPercent(double value) {
    minPaymentPercent = value;
    notifyListeners();
  }

  void updateMinPaymentAmount(double value) {
    minPaymentAmount = value;
    notifyListeners();
  }

  void updateSkipDecember(bool value) {
    skipDecember = value;
    notifyListeners();
  }

  void updateDisplayType(String value) {
    displayType = value;
    notifyListeners();
  }

  // Add calculation logic here as needed
}
