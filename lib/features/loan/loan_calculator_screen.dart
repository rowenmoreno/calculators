
import 'package:flutter/material.dart';
import 'dart:math';



class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  // Text field controllers
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();

  String? resultMessage;

  @override
  void dispose() {
    _balanceController.dispose();
    _paymentController.dispose();
    _rateController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  void calculateResult() {
    final result = _calculate();
    setState(() {
      resultMessage = _formatResult(result);
    });
  }

  Map<String, double> _calculate() {
    final balanceValue = double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0;
    final currentPayment = double.tryParse(_paymentController.text.replaceAll(',', '')) ?? 0;
    final rateValue = double.tryParse(_rateController.text.replaceAll('%', '')) ?? 0;
    final monthsValue = int.tryParse(_monthsController.text) ?? 0;

    if (balanceValue <= 0 || monthsValue <= 0) {
      return {};
    }

    double monthlyRate = (rateValue / 100) / 12;
    double newMonthlyPayment = 0;
    double totalInterestOld = 0;
    double totalInterestNew = 0;
    int scheduledMonths = 0;

    if (monthlyRate == 0) {
      newMonthlyPayment = balanceValue / monthsValue;
      scheduledMonths = currentPayment > 0 ? (balanceValue / currentPayment).ceil() : 0;
      totalInterestOld = 0;
      totalInterestNew = 0;
    } else {
      newMonthlyPayment = balanceValue * monthlyRate / (1 - (1 / (pow(1 + monthlyRate, monthsValue))));
      if (currentPayment > 0 && currentPayment > balanceValue * monthlyRate) {
        scheduledMonths = ((log(currentPayment) - log(currentPayment - balanceValue * monthlyRate)) / log(1 + monthlyRate)).ceil();
      } else {
        scheduledMonths = 0;
      }

      double remaining = balanceValue;
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

      remaining = balanceValue;
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

    return {
      'newMonthlyPayment': newMonthlyPayment,
      'scheduledMonths': scheduledMonths.toDouble(),
      'monthsValue': monthsValue.toDouble(),
      'interestSavings': totalInterestOld - totalInterestNew,
      'paymentDifference': newMonthlyPayment - currentPayment,
    };
  }

  String _formatResult(Map<String, double> result) {
    if (result.isEmpty) return '';
    
    final monthsValue = result['monthsValue']?.toInt() ?? 0;
    final scheduledMonths = result['scheduledMonths']?.toInt() ?? 0;
    final interestSavings = result['interestSavings'] ?? 0;
    final newMonthlyPayment = result['newMonthlyPayment'] ?? 0;
    final paymentDifference = result['paymentDifference'] ?? 0;

    return 'If you pay off your loan in $monthsValue month${monthsValue > 1 ? 's' : ''} '
           'instead of the scheduled $scheduledMonths month${scheduledMonths > 1 ? 's' : ''}, '
           'you will pay \$${interestSavings.abs().toStringAsFixed(2)} ${interestSavings >= 0 ? 'less' : 'more'} in interest, '
           'and your new monthly payment will be \$${newMonthlyPayment.toStringAsFixed(2)} '
           '(\$${paymentDifference.abs().toStringAsFixed(2)} ${paymentDifference >= 0 ? 'more' : 'less'} '
           'than your current monthly payment).';
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current loan balance (\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current monthly payment (\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Annual percentage rate (0% to 40%)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _monthsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of months to pay off loan (1 to 360)',
                border: OutlineInputBorder(),
              ),
            ),
            if (resultMessage?.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              Text(
                resultMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: calculateResult,
              child: const Text(
                'Calculate',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 