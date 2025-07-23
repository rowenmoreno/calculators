
import 'package:flutter/material.dart';
import 'dart:math';

class LoanCalculatorData {
  String balance = '';
  String payment = '';
  String rate = '';
  String months = '';
  String? resultSummary;

  void calculate() {
    final balanceValue = double.tryParse(balance.replaceAll(',', '')) ?? 0;
    final currentPayment = double.tryParse(payment.replaceAll(',', '')) ?? 0;
    final rateValue = double.tryParse(rate.replaceAll('%', '')) ?? 0;
    final monthsValue = int.tryParse(months) ?? 0;

    if (balanceValue <= 0 || monthsValue <= 0) {
      resultSummary = null;
      return;
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

    double interestSavings = totalInterestOld - totalInterestNew;
    double paymentDifference = newMonthlyPayment - currentPayment;
    resultSummary = 'If you pay off your loan in $monthsValue month${monthsValue > 1 ? 's' : ''} instead of the scheduled $scheduledMonths month${scheduledMonths > 1 ? 's' : ''}, you will pay \$${interestSavings.abs().toStringAsFixed(2)} ${interestSavings >= 0 ? 'less' : 'more'} in interest, and your new monthly payment will be \$${newMonthlyPayment.toStringAsFixed(2)} (\$${paymentDifference.abs().toStringAsFixed(2)} ${paymentDifference >= 0 ? 'more' : 'less'} than your current monthly payment).';
  }
}

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final data = LoanCalculatorData();

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
            const Text('Current loan balance ( 24)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => data.balance = value),
            ),
            const SizedBox(height: 24),
            const Text('Current monthly payment ( 24)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => data.payment = value),
            ),
            const SizedBox(height: 24),
            const Text('Annual percentage rate (0% to 40%)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => data.rate = value),
            ),
            const SizedBox(height: 24),
            const Text('Number of months you want to have the loan paid off? (1 to 360)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => data.months = value),
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
                  onPressed: () {
                    setState(() {
                      data.calculate();
                    });
                  },
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