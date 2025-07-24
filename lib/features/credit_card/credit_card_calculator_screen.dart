
import 'package:flutter/material.dart';

class CreditCardCalculatorScreen extends StatefulWidget {
  const CreditCardCalculatorScreen({super.key});

  @override
  State<CreditCardCalculatorScreen> createState() =>  _CreditCardCalculatorScreenState();
}

class _CreditCardCalculatorScreenState extends State<CreditCardCalculatorScreen> {
  int _tabIndex = 0;
  
  // Text field controllers
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _aprController = TextEditingController();
  final TextEditingController _additionalPaymentController = TextEditingController();
  final TextEditingController _minPaymentPercentController = TextEditingController(text: '2');
  final TextEditingController _minPaymentAmountController = TextEditingController(text: '25');
  
  bool skipDecember = false;
  String? resultMessage;

  @override
  void dispose() {
    _balanceController.dispose();
    _aprController.dispose();
    _additionalPaymentController.dispose();
    _minPaymentPercentController.dispose();
    _minPaymentAmountController.dispose();
    super.dispose();
  }

  void setTabIndex(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void calculateResult() {
    final result = _calculateCreditCardPayoff(
      balance: double.tryParse(_balanceController.text) ?? 0,
      apr: double.tryParse(_aprController.text) ?? 0,
      additionalPayment: double.tryParse(_additionalPaymentController.text) ?? 0,
      minPercent: double.tryParse(_minPaymentPercentController.text) ?? 2,
      minAmount: double.tryParse(_minPaymentAmountController.text) ?? 25,
      skipDecember: skipDecember,
    );
    setState(() {
      resultMessage = _formatResult(result);
    });
  }

  String _formatResult(CreditCardCalculationResult result) {
    return 'By only making minimum payments it will take ${result.months} more payments or ${result.years.toStringAsFixed(1)} years to pay off the remaining balance. Interest will amount to \$${result.totalInterest.toStringAsFixed(0)}.';
  }

  CreditCardCalculationResult _calculateCreditCardPayoff({
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
    return CreditCardCalculationResult(
      months: months,
      years: years,
      totalInterest: totalInterest,
    );
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
                    balanceController: _balanceController,
                    aprController: _aprController,
                    additionalPaymentController: _additionalPaymentController,
                    onNext: () => setTabIndex(1),
                  )
                : AssumptionsTab(
                    minPaymentPercentController: _minPaymentPercentController,
                    minPaymentAmountController: _minPaymentAmountController,
                    skipDecember: skipDecember,
                    onSkipDecemberChanged: (value) => setState(() => skipDecember = value),
                    onPrevious: () => setTabIndex(0),
                    onCalculate: calculateResult,
                    resultMessage: resultMessage,
                  ),
          ),
        ],
      ),
    );
  }
}


class CreditCardCalculationResult {
  final int months;
  final double years;
  final double totalInterest;
  CreditCardCalculationResult({
    required this.months,
    required this.years,
    required this.totalInterest,
  });
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
  final TextEditingController balanceController;
  final TextEditingController aprController;
  final TextEditingController additionalPaymentController;
  final VoidCallback onNext;

  const CreditCardInfoTab({
    required this.balanceController,
    required this.aprController,
    required this.additionalPaymentController,
    required this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Current credit card balance (\$)'),
            keyboardType: TextInputType.number,
            controller: balanceController,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Annual percentage rate (0% to 40%)'),
            keyboardType: TextInputType.number,
            controller: aprController,
          ),
          TextField(
            controller: additionalPaymentController,
            decoration: const InputDecoration(labelText: 'Proposed additional monthly payment (\$)'),
            keyboardType: TextInputType.number,
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
  final TextEditingController minPaymentPercentController;
  final TextEditingController minPaymentAmountController;
  final bool skipDecember;
  final Function(bool) onSkipDecemberChanged;
  final VoidCallback onPrevious;
  final VoidCallback onCalculate;
  final String? resultMessage;

  const AssumptionsTab({
    required this.minPaymentPercentController,
    required this.minPaymentAmountController,
    required this.skipDecember,
    required this.onSkipDecemberChanged,
    required this.onPrevious,
    required this.onCalculate,
    required this.resultMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: minPaymentPercentController,
            decoration: const InputDecoration(
              labelText: 'Minimum payment percentage (%)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: minPaymentAmountController,
            decoration: const InputDecoration(
              labelText: 'Minimum payment amount (\$)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Skip December payment'),
            value: skipDecember,
            onChanged: (value) => onSkipDecemberChanged(value ?? false),
          ),
          if (resultMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              resultMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
          const Spacer(),
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
                  onPressed: onCalculate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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
