
import 'package:flutter/material.dart';
import 'credit_card_calculator_data.dart';

// Extracted calculation function
class CreditCardCalculationResult {
  final int months;
  final double years;
  final double totalInterest;
  CreditCardCalculationResult({required this.months, required this.years, required this.totalInterest});
}

CreditCardCalculationResult calculateCreditCardPayoff({
  required double balance,
  required double apr,
  required double additionalPayment,
  required double minPercent,
  required double minAmount,
  required bool skipDecember,
}) {
  final monthlyRate = apr / 100 / 12;
  double currentBalance = balance;
  int months = 0;
  double totalInterest = 0;
  while (currentBalance > 0.01 && months < 1000) {
    months++;
    if (skipDecember && months % 12 == 0) {
      continue;
    }
    double minPayment = (currentBalance * minPercent / 100).clamp(minAmount, double.infinity);
    double payment = minPayment + additionalPayment;
    if (payment > currentBalance) payment = currentBalance;
    double interest = currentBalance * monthlyRate;
    totalInterest += interest;
    currentBalance += interest;
    currentBalance -= payment;
  }
  double years = months / 12.0;
  return CreditCardCalculationResult(months: months, years: years, totalInterest: totalInterest);
}

class CreditCardCalculatorScreen extends StatefulWidget {
  const CreditCardCalculatorScreen({super.key});

  @override
  State<CreditCardCalculatorScreen> createState() => _CreditCardCalculatorScreenState();
}

class _CreditCardCalculatorScreenState extends State<CreditCardCalculatorScreen> {
  int _tabIndex = 0;
  final CreditCardCalculatorData data = CreditCardCalculatorData();

  void setTabIndex(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Calculator'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabButton(
                  text: 'Credit Card Information',
                  selected: _tabIndex == 0,
                  onTap: () => setTabIndex(0),
                ),
              ),
              Expanded(
                child: TabButton(
                  text: 'Assumptions',
                  selected: _tabIndex == 1,
                  onTap: () => setTabIndex(1),
                ),
              ),
            ],
          ),
          Expanded(
            child: _tabIndex == 0
                ? CreditCardInfoTab(
                    data: data,
                    onChanged: () => setState(() {}),
                    onNext: () => setTabIndex(1),
                  )
                : AssumptionsTab(
                    data: data,
                    onChanged: () => setState(() {}),
                    onPrevious: () => setTabIndex(0),
                  ),
          ),
        ],
      ),
    );
  }
}


class TabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const TabButton({required this.text, required this.selected, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.teal : Colors.white,
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class CreditCardInfoTab extends StatelessWidget {
  final CreditCardCalculatorData data;
  final VoidCallback onChanged;
  final VoidCallback onNext;
  const CreditCardInfoTab({required this.data, required this.onChanged, required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Current credit card balance (4)'),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              data.balance = double.tryParse(v) ?? 0;
              onChanged();
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Annual percentage rate (0% to 40%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              data.apr = double.tryParse(v) ?? 0;
              onChanged();
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Proposed additional monthly payment (4)'),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              data.additionalPayment = double.tryParse(v) ?? 0;
              onChanged();
            },
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onNext,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class AssumptionsTab extends StatelessWidget {
  final CreditCardCalculatorData data;
  final VoidCallback onChanged;
  final VoidCallback onPrevious;
  const AssumptionsTab({required this.data, required this.onChanged, required this.onPrevious, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrevious,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final result = calculateCreditCardPayoff(
                      balance: data.balance,
                      apr: data.apr,
                      additionalPayment: data.additionalPayment,
                      minPercent: data.minPaymentPercent,
                      minAmount: data.minPaymentAmount,
                      skipDecember: data.skipDecember,
                    );
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Result'),
                        content: Text(
                          'By only making minimum payments it will take ${result.months} more payments or ${result.years.toStringAsFixed(1)} years to pay off the remaining balance. Interest will amount to \$${result.totalInterest.toStringAsFixed(0)}.'
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Calculate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
