import 'package:calculators/features/loan/loan_result_screen.dart';
import 'package:calculators/features/loan/provider/loan_calculator_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoanCalculatorScreen extends StatelessWidget {
  const LoanCalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoanCalculatorProvider(),
      child: const _LoanCalculatorView(),
    );
  }
}

class _LoanCalculatorView extends StatelessWidget {
  const _LoanCalculatorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoanCalculatorProvider>(context);
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
              controller: provider.balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Current monthly payment ( 24)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: provider.paymentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Annual percentage rate (0% to 40%)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: provider.rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Number of months you want to have the loan paid off? (1 to 360)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: provider.monthsController,
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
                  onPressed: () {
                    provider.calculate();
                    if (provider.resultSummary != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoanResultScreen(resultSummary: provider.resultSummary!),
                        ),
                      );
                    }
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