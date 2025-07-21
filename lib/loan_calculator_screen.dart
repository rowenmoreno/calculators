import 'package:flutter/material.dart';
import 'dart:math';
import 'loan_result_screen.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();

  String? _resultSummary;
  String? _newMonthlyPayment;
  String? _interestSavings;
  bool _showResults = false;

  @override
  void dispose() {
    _balanceController.dispose();
    _paymentController.dispose();
    _rateController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  void _calculate() {
    final balance = double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0;
    final currentPayment = double.tryParse(_paymentController.text.replaceAll(',', '')) ?? 0;
    final rate = double.tryParse(_rateController.text.replaceAll('%', '')) ?? 0;
    final months = int.tryParse(_monthsController.text) ?? 0;

    if (balance <= 0 || months <= 0) {
      return;
    }

    // Correct monthly interest rate calculation
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
      // Calculate new monthly payment using amortization formula
      newMonthlyPayment = balance * monthlyRate / (1 - pow(1 + monthlyRate, -months));
      // Calculate scheduled months for current payment
      if (currentPayment > 0 && currentPayment > balance * monthlyRate) {
        scheduledMonths = ((log(currentPayment) - log(currentPayment - balance * monthlyRate)) / log(1 + monthlyRate)).ceil();
      } else {
        scheduledMonths = 0;
      }
      // Calculate total interest for old payment
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
      // Calculate total interest for new payment
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
    String summary =
        'If you pay off your loan in $months month${months > 1 ? 's' : ''} instead of the scheduled $scheduledMonths month${scheduledMonths > 1 ? 's' : ''}, you will pay \$${interestSavings.abs().toStringAsFixed(2)} ${interestSavings >= 0 ? 'less' : 'more'} in interest, and your new monthly payment will be \$${newMonthlyPayment.toStringAsFixed(2)} (\$${paymentDifference.abs().toStringAsFixed(2)} ${paymentDifference >= 0 ? 'more' : 'less'} than your current monthly payment).';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoanResultScreen(resultSummary: summary),
      ),
    );
  }

  void _emailResults() {
    // Placeholder for email functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Results'),
        content: const Text('Email functionality is not implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current loan balance (\$)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Current monthly payment (\$)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Annual percentage rate (0% to 40%)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Number of months you want to have the loan paid off? (1 to 360)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _monthsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 180,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 