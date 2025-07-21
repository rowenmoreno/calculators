import 'package:flutter/material.dart';
import 'dart:math';

class RetirementSavingsProvider extends ChangeNotifier {
  int currentStep = 0;

  // Step 1: Income/Savings
  final TextEditingController ageController = TextEditingController(text: '35');
  final TextEditingController annualIncomeController = TextEditingController(text: '0');
  final TextEditingController spouseIncomeController = TextEditingController(text: '0');
  final TextEditingController savingsBalanceController = TextEditingController(text: '0');
  final TextEditingController annualSavingsController = TextEditingController(text: '0');
  final TextEditingController annualSavingsIncreaseController = TextEditingController(text: '0%');

  // Step 2: Pension
  final TextEditingController pensionBenefitController = TextEditingController(text: '0');
  String pensionInflation = 'No';
  List<String> yesNoOptions = ['No', 'Yes'];

  // Step 3: Assumptions
  final TextEditingController inflationController = TextEditingController(text: '3%');
  final TextEditingController retirementAgeController = TextEditingController(text: '65');
  final TextEditingController yearsOfRetirementController = TextEditingController(text: '20');
  final TextEditingController incomeReplacementController = TextEditingController(text: '75%');
  final TextEditingController preRetReturnController = TextEditingController(text: '8%');
  final TextEditingController postRetReturnController = TextEditingController(text: '8%');

  // Step 4: Social Security
  String includeSS = 'No';
  String maritalStatus = 'Single';
  List<String> maritalStatusOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
  final TextEditingController ssOverrideController = TextEditingController(text: '0');

  String? resultSummary;

  void setStep(int step) {
    currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (currentStep < 3) {
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

  void setPensionInflation(String value) {
    pensionInflation = value;
    notifyListeners();
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
    int yearsOfRetirement = int.tryParse(yearsOfRetirementController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 20;
    double currentSavings = double.tryParse(savingsBalanceController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    double annualSavings = double.tryParse(annualSavingsController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    double annualIncrease = double.tryParse(annualSavingsIncreaseController.text.replaceAll('%', '')) ?? 0;
    double preRetReturn = double.tryParse(preRetReturnController.text.replaceAll('%', '')) ?? 0;
    double postRetReturn = double.tryParse(postRetReturnController.text.replaceAll('%', '')) ?? 0;
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

    // Estimate annual income needed in retirement (future dollars)
    double neededIncome = annualIncome * (incomeReplacement / 100) * pow(1 + inflation / 100, n);
    double balance = fvSavings;
    double withdrawal = neededIncome;
    double postR = postRetReturn / 100;
    double infl = inflation / 100;

    // Simulate withdrawals over retirement years
    for (int i = 0; i < yearsOfRetirement; i++) {
      balance = balance * (1 + postR);
      balance -= withdrawal;
      withdrawal *= (1 + infl); // Increase withdrawal for inflation
    }

    if (balance >= 0) {
      resultSummary =
          'Congratulations!!! It appears that you have saved enough to meet your goal. In fact, it appears that at age ${retirementAge + yearsOfRetirement} you will still have \$${balance.toStringAsFixed(0)} in your retirement accounts.';
    } else {
      resultSummary =
          'It appears that you may run out of savings before the end of your retirement. At age ${retirementAge + yearsOfRetirement}, your retirement accounts may be depleted.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    ageController.dispose();
    annualIncomeController.dispose();
    spouseIncomeController.dispose();
    savingsBalanceController.dispose();
    annualSavingsController.dispose();
    annualSavingsIncreaseController.dispose();
    pensionBenefitController.dispose();
    inflationController.dispose();
    retirementAgeController.dispose();
    yearsOfRetirementController.dispose();
    incomeReplacementController.dispose();
    preRetReturnController.dispose();
    postRetReturnController.dispose();
    ssOverrideController.dispose();
    super.dispose();
  }
} 