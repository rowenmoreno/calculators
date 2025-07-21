import 'package:flutter/material.dart';
import 'dart:math';

class LoanCalculatorProvider extends ChangeNotifier {
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController monthsController = TextEditingController();

  String? resultSummary;

  void calculate() {
    final balance = double.tryParse(balanceController.text.replaceAll(',', '')) ?? 0;
    final currentPayment = double.tryParse(paymentController.text.replaceAll(',', '')) ?? 0;
    final rate = double.tryParse(rateController.text.replaceAll('%', '')) ?? 0;
    final months = int.tryParse(monthsController.text) ?? 0;

    if (balance <= 0 || months <= 0) {
      resultSummary = null;
      notifyListeners();
      return;
    }

    double monthlyRate = (rate / 100) / 12;
    double newMonthlyPayment = 0;
    double totalInterestOld = 0;
    double totalInterestNew = 0;
    int scheduledMonths = 0;

    if (monthlyRate == 0) {
      newMonthlyPayment = balance / months;
      scheduledMonths = currentPayment > 0 ? (balance / currentPayment).ceil() : 0;
      totalInterestOld = 0;
      totalInterestNew = 0;
    } else {
      newMonthlyPayment = balance * monthlyRate / (1 - (1 / (pow(1 + monthlyRate, months))));
      if (currentPayment > 0 && currentPayment > balance * monthlyRate) {
        scheduledMonths = ((log(currentPayment) - log(currentPayment - balance * monthlyRate)) / log(1 + monthlyRate)).ceil();
      } else {
        scheduledMonths = 0;
      }
      double remaining = balance;
      totalInterestOld = 0;
      int tempMonths = 0;
      while (remaining > 0 && tempMonths < 1000 && currentPayment > 0 && currentPayment > remaining * monthlyRate) {
        double interest = remaining * monthlyRate;
        double principal = currentPayment - interest;
        if (principal <= 0) break;
        remaining -= principal;
        totalInterestOld += interest;
        tempMonths++;
      }
      remaining = balance;
      totalInterestNew = 0;
      tempMonths = 0;
      while (remaining > 0 && tempMonths < 1000 && newMonthlyPayment > remaining * monthlyRate) {
        double interest = remaining * monthlyRate;
        double principal = newMonthlyPayment - interest;
        if (principal <= 0) break;
        remaining -= principal;
        totalInterestNew += interest;
        tempMonths++;
      }
    }

    double interestSavings = totalInterestOld - totalInterestNew;
    double paymentDifference = newMonthlyPayment - currentPayment;
    resultSummary =
        'If you pay off your loan in $months month${months > 1 ? 's' : ''} instead of the scheduled $scheduledMonths month${scheduledMonths > 1 ? 's' : ''}, you will pay \$${interestSavings.abs().toStringAsFixed(2)} ${interestSavings >= 0 ? 'less' : 'more'} in interest, and your new monthly payment will be \$${newMonthlyPayment.toStringAsFixed(2)} (\$${paymentDifference.abs().toStringAsFixed(2)} ${paymentDifference >= 0 ? 'more' : 'less'} than your current monthly payment).';
    notifyListeners();
  }

  @override
  void dispose() {
    balanceController.dispose();
    paymentController.dispose();
    rateController.dispose();
    monthsController.dispose();
    super.dispose();
  }
} 