import 'package:flutter/material.dart';

class SocialSecurityProvider extends ChangeNotifier {
  int currentStep = 0;

  // Step 1: Your Information
  final TextEditingController incomeController = TextEditingController(text: '');
  final TextEditingController ageController = TextEditingController(text: '');
  final TextEditingController retirementAgeController = TextEditingController(text: '67');

  // Step 2: Spouse Information
  final TextEditingController spouseIncomeController = TextEditingController(text: '');
  final TextEditingController spouseAgeController = TextEditingController(text: '');
  final TextEditingController spouseRetirementAgeController = TextEditingController(text: '67');

  // Step 3: Common Assumptions
  final TextEditingController inflationController = TextEditingController(text: '2.50%');

  String? resultSummary;

  void setStep(int step) {
    currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (currentStep < 2) {
      currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  void calculateResult() {
    double income = double.tryParse(incomeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    double spouseIncome = double.tryParse(spouseIncomeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    double combinedIncome = income + spouseIncome;

    // Estimate Social Security benefit: 40% of each individual's income if income > 0
    double ssBenefit = 0;
    if (income > 0) ssBenefit += income * 0.4;
    if (spouseIncome > 0) ssBenefit += spouseIncome * 0.4;

    double replacementPercent = combinedIncome > 0 ? (ssBenefit / combinedIncome) * 100 : 0;

    resultSummary =
        'It appears that Social Security will replace approximately ${replacementPercent.toStringAsFixed(0)}% of your current combined income of \\$${combinedIncome.toStringAsFixed(0)}.';
    notifyListeners();
  }

  @override
  void dispose() {
    incomeController.dispose();
    ageController.dispose();
    retirementAgeController.dispose();
    spouseIncomeController.dispose();
    spouseAgeController.dispose();
    spouseRetirementAgeController.dispose();
    inflationController.dispose();
    super.dispose();
  }
} 