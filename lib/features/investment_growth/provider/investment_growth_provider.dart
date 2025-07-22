import 'package:flutter/material.dart';

class InvestmentGrowthProvider extends ChangeNotifier {
  double currentInvestmentBalance = 0;
  double annualContributions = 0;
  double yearsToInvest = 20;
  double beforeTaxReturnFullyTaxable = 8;
  double beforeTaxReturnTaxDeferred = 8;
  double returnOnTaxFreeInvestment = 5;
  double marginalTaxBracket = 25;

  void updateCurrentInvestmentBalance(double value) {
    currentInvestmentBalance = value;
    notifyListeners();
  }

  void updateAnnualContributions(double value) {
    annualContributions = value;
    notifyListeners();
  }

  void updateYearsToInvest(double value) {
    yearsToInvest = value;
    notifyListeners();
  }

  void updateBeforeTaxReturnFullyTaxable(double value) {
    beforeTaxReturnFullyTaxable = value;
    notifyListeners();
  }

  void updateBeforeTaxReturnTaxDeferred(double value) {
    beforeTaxReturnTaxDeferred = value;
    notifyListeners();
  }

  void updateReturnOnTaxFreeInvestment(double value) {
    returnOnTaxFreeInvestment = value;
    notifyListeners();
  }

  void updateMarginalTaxBracket(double value) {
    marginalTaxBracket = value;
    notifyListeners();
  }

  Map<String, double> calculate() {
    // This is a simplified calculation and does not represent a real financial model.
    // It is for demonstration purposes only.
    final fullyTaxable = currentInvestmentBalance + (annualContributions * yearsToInvest) * (1 + (beforeTaxReturnFullyTaxable / 100));
    final taxDeferred = currentInvestmentBalance + (annualContributions * yearsToInvest) * (1 + (beforeTaxReturnTaxDeferred / 100));
    final taxFree = currentInvestmentBalance + (annualContributions * yearsToInvest) * (1 + (returnOnTaxFreeInvestment / 100));

    return {
      'fullyTaxable': fullyTaxable,
      'taxDeferred': taxDeferred,
      'taxFree': taxFree,
    };
  }
}