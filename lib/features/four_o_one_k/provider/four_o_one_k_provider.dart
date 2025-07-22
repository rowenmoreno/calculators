import 'package:flutter/material.dart';

class FourOOneKProvider extends ChangeNotifier {
  double currentAge = 35;
  double annualContribution = 0;
  double retirementAge = 65;
  double yearsToReceiveIncome = 20;
  double preTaxReturnDistribution = 8;
  double incomeTaxBracketDistribution = 25;
  double preTaxReturnAccumulation = 8;
  double incomeTaxBracketAccumulation = 25;
  String taxationOption = 'Option 1';

  void updateCurrentAge(double value) {
    currentAge = value;
    notifyListeners();
  }

  void updateAnnualContribution(double value) {
    annualContribution = value;
    notifyListeners();
  }

  void updateRetirementAge(double value) {
    retirementAge = value;
    notifyListeners();
  }

  void updateYearsToReceiveIncome(double value) {
    yearsToReceiveIncome = value;
    notifyListeners();
  }

  void updatePreTaxReturnDistribution(double value) {
    preTaxReturnDistribution = value;
    notifyListeners();
  }

  void updateIncomeTaxBracketDistribution(double value) {
    incomeTaxBracketDistribution = value;
    notifyListeners();
  }

  void updatePreTaxReturnAccumulation(double value) {
    preTaxReturnAccumulation = value;
    notifyListeners();
  }

  void updateIncomeTaxBracketAccumulation(double value) {
    incomeTaxBracketAccumulation = value;
    notifyListeners();
  }

  void updateTaxationOption(String value) {
    taxationOption = value;
    notifyListeners();
  }

  Map<String, double> calculate() {
    final contributionYears = retirementAge - currentAge;
    
    // This is a simplified calculation and does not represent a real financial model.
    // It is for demonstration purposes only.
    final futureValue = annualContribution * contributionYears * (1 + (preTaxReturnAccumulation / 100));
    final annualIncome = futureValue / yearsToReceiveIncome;
    final monthlyIncome = annualIncome / 12;

    return {
      'contributionYears': contributionYears,
      'annualContribution': annualContribution,
      'annualIncome': annualIncome,
      'monthlyIncome': monthlyIncome,
      'distributionYears': yearsToReceiveIncome,
    };
  }
}