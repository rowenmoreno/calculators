import 'package:flutter/material.dart';
import 'dart:math';

class RetirementPlannerProvider extends ChangeNotifier {
  int currentStep = 0;

  // Step 1: Income/Savings
  final TextEditingController ageController = TextEditingController(text: '35');
  final TextEditingController annualIncomeController = TextEditingController(text: '0');
  final TextEditingController spouseIncomeController = TextEditingController(text: '0');
  final TextEditingController savingsController = TextEditingController(text: '0');
  final TextEditingController retirementAgeController = TextEditingController(text: '65');
  final TextEditingController yearsOfRetirementController = TextEditingController(text: '20');

  // Step 2: Assumptions
  final TextEditingController inflationController = TextEditingController(text: '3');
  final TextEditingController incomeReplacementController = TextEditingController(text: '75');
  final TextEditingController preRetReturnController = TextEditingController(text: '8');
  final TextEditingController postRetReturnController = TextEditingController(text: '8');

  // Step 3: Social Security
  String includeSS = 'No';
  String maritalStatus = 'Single';
  final TextEditingController ssOverrideController = TextEditingController(text: '0');

  List<String> maritalStatusOptions = ['Single', 'Married', 'Divorced', 'Widowed'];

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

  void setIncludeSS(String value) {
    includeSS = value;
    notifyListeners();
  }

  void setMaritalStatus(String value) {
    maritalStatus = value;
    notifyListeners();
  }

  void calculateResult() {
    // Parse inputs
    int currentAge = int.tryParse(ageController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int retirementAge = int.tryParse(retirementAgeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 65;
    int yearsToRetirement = retirementAge - currentAge;
    double currentSavings = double.tryParse(savingsController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    double annualSavings = double.tryParse(annualIncomeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    double annualIncrease = double.tryParse(yearsOfRetirementController.text.replaceAll('%', '')) ?? 0;
    double preRetReturn = double.tryParse(preRetReturnController.text.replaceAll('%', '')) ?? 0;
    double inflation = double.tryParse(inflationController.text.replaceAll('%', '')) ?? 0;
    double incomeReplacement = double.tryParse(incomeReplacementController.text.replaceAll('%', '')) ?? 0;
    double annualIncome = double.tryParse(annualIncomeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    // Future value of a growing annuity (savings): FV = P*[(1+r)^n - (1+g)^n]/(r-g) + PV*(1+r)^n
    double r = preRetReturn / 100;
    double g = annualIncrease / 100;
    int n = yearsToRetirement;
    double fvSavings = 0;
    if (r != g) {
      fvSavings = annualSavings * (pow(1 + r, n) - pow(1 + g, n)) / (r - g);
    } else {
      fvSavings = annualSavings * n * pow(1 + r, n - 1);
    }
    fvSavings += currentSavings * pow(1 + r, n);

    // Estimate annual income needed in retirement
    double neededIncome = annualIncome * (incomeReplacement / 100) * pow(1 + inflation / 100, n);

    resultSummary =
      'At age $retirementAge, you will have approximately \$${fvSavings.toStringAsFixed(0)} in savings.\n'
      'You will need about \$${neededIncome.toStringAsFixed(0)} per year in retirement (in future dollars).';
    notifyListeners();
  }

  @override
  void dispose() {
    ageController.dispose();
    annualIncomeController.dispose();
    spouseIncomeController.dispose();
    savingsController.dispose();
    retirementAgeController.dispose();
    yearsOfRetirementController.dispose();
    inflationController.dispose();
    incomeReplacementController.dispose();
    preRetReturnController.dispose();
    postRetReturnController.dispose();
    ssOverrideController.dispose();
    super.dispose();
  }
} 