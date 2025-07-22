import 'package:flutter/material.dart';

class PayrollWithholdingsProvider extends ChangeNotifier {
  String taxFilingStatus = 'Married-Jointly';
  double taxableGrossAnnualIncome = 0;
  double traditionalIraContribution = 0;
  double itemizedDeductions = 0;
  int numberOfDependentChildren = 0;
  int numberOfNonChildDependents = 2;
  double grossIncomeConsideredUnearned = 0;
  bool isBlindOrOver65 = false;
  double totalCompanyPassThroughIncome = 0;
  double individualCompanyOwnership = 100;
  double totalCompanyCapitalAssets = 0;
  double totalCompanyW2Wages = 0;
  double federalTaxesWithheldToDate = 0;
  double taxAmountWithheldLastPayPeriod = 0;
  String paymentFrequency = 'Semi-Monthly';

  void updateTaxFilingStatus(String value) {
    taxFilingStatus = value;
    notifyListeners();
  }

  void updateTaxableGrossAnnualIncome(double value) {
    taxableGrossAnnualIncome = value;
    notifyListeners();
  }

  void updateTraditionalIraContribution(double value) {
    traditionalIraContribution = value;
    notifyListeners();
  }

  void updateItemizedDeductions(double value) {
    itemizedDeductions = value;
    notifyListeners();
  }

  void updateNumberOfDependentChildren(int value) {
    numberOfDependentChildren = value;
    notifyListeners();
  }

  void updateNumberOfNonChildDependents(int value) {
    numberOfNonChildDependents = value;
    notifyListeners();
  }

  void updateGrossIncomeConsideredUnearned(double value) {
    grossIncomeConsideredUnearned = value;
    notifyListeners();
  }

  void updateIsBlindOrOver65(bool value) {
    isBlindOrOver65 = value;
    notifyListeners();
  }

  void updateTotalCompanyPassThroughIncome(double value) {
    totalCompanyPassThroughIncome = value;
    notifyListeners();
  }

  void updateIndividualCompanyOwnership(double value) {
    individualCompanyOwnership = value;
    notifyListeners();
  }

  void updateTotalCompanyCapitalAssets(double value) {
    totalCompanyCapitalAssets = value;
    notifyListeners();
  }

  void updateTotalCompanyW2Wages(double value) {
    totalCompanyW2Wages = value;
    notifyListeners();
  }

  void updateFederalTaxesWithheldToDate(double value) {
    federalTaxesWithheldToDate = value;
    notifyListeners();
  }

  void updateTaxAmountWithheldLastPayPeriod(double value) {
    taxAmountWithheldLastPayPeriod = value;
    notifyListeners();
  }

  void updatePaymentFrequency(String value) {
    paymentFrequency = value;
    notifyListeners();
  }

  Map<String, double> calculate() {
    // This is a simplified calculation and does not represent a real financial model.
    // It is for demonstration purposes only.
    final grossIncome = taxableGrossAnnualIncome;
    final taxablePassThroughIncome = totalCompanyPassThroughIncome * (individualCompanyOwnership / 100);
    final qualifiedPlanContributions = traditionalIraContribution;
    final adjustedGrossIncome = grossIncome + taxablePassThroughIncome - qualifiedPlanContributions;
    final standardDeduction = 30000.0; // Example value
    final taxableIncome = adjustedGrossIncome - standardDeduction;
    final taxLiabilityBeforeCredits = taxableIncome * 0.1; // Example value
    final childTaxCredits = numberOfDependentChildren * 2000;
    final familyTaxCredits = numberOfNonChildDependents * 500;
    final estimatedTaxLiability = taxLiabilityBeforeCredits - childTaxCredits - familyTaxCredits;
    final refundableChildTaxCredit = 3517.0; // Example value
    final taxesWithheldToDate = federalTaxesWithheldToDate;
    final taxesYetToBeWithheld = 0.0; // Example value
    final totalTaxesWithheld = taxesWithheldToDate + taxesYetToBeWithheld;
    final taxSurplus = totalTaxesWithheld - estimatedTaxLiability;

    return {
      'grossIncome': grossIncome,
      'taxablePassThroughIncome': taxablePassThroughIncome,
      'qualifiedPlanContributions': qualifiedPlanContributions,
      'adjustedGrossIncome': adjustedGrossIncome,
      'standardDeduction': standardDeduction,
      'taxableIncome': taxableIncome,
      'taxLiabilityBeforeCredits': taxLiabilityBeforeCredits,
      'childTaxCredits': childTaxCredits.toDouble(),
      'familyTaxCredits': familyTaxCredits.toDouble(),
      'estimatedTaxLiability': estimatedTaxLiability,
      'refundableChildTaxCredit': refundableChildTaxCredit,
      'taxesWithheldToDate': taxesWithheldToDate,
      'taxesYetToBeWithheld': taxesYetToBeWithheld,
      'totalTaxesWithheld': totalTaxesWithheld,
      'taxSurplus': taxSurplus,
    };
  }
}