import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/credit_card_calculator_provider.dart';

class CreditCardCalculatorScreen extends StatelessWidget {
  const CreditCardCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreditCardCalculatorProvider(),
      child: const CreditCardCalculatorForm(),
    );
  }
}

class CreditCardCalculatorForm extends StatefulWidget {
  const CreditCardCalculatorForm({super.key});

  @override
  State<CreditCardCalculatorForm> createState() => _CreditCardCalculatorFormState();
}

class _CreditCardCalculatorFormState extends State<CreditCardCalculatorForm> {
  int _tabIndex = 0;

  void setTabIndex(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreditCardCalculatorProvider>(context);
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
                  onTap: () => setState(() => _tabIndex = 0),
                ),
              ),
              Expanded(
                child: TabButton(
                  text: 'Assumptions',
                  selected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ),
            ],
          ),
          Expanded(
            child: _tabIndex == 0
                ? CreditCardInfoTab(provider: provider)
                : AssumptionsTab(provider: provider),
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
  final CreditCardCalculatorProvider provider;
  const CreditCardInfoTab({required this.provider, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Current credit card balance (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateBalance(double.tryParse(v) ?? 0),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Annual percentage rate (0% to 40%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateApr(double.tryParse(v) ?? 0),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Proposed additional monthly payment (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateAdditionalPayment(double.tryParse(v) ?? 0),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              final parentState = context.findAncestorStateOfType<_CreditCardCalculatorFormState>();
              parentState?.setTabIndex(1);
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class AssumptionsTab extends StatelessWidget {
  final CreditCardCalculatorProvider provider;
  const AssumptionsTab({required this.provider, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Minimum payment percentage (0% to 10%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateMinPaymentPercent(double.tryParse(v) ?? 0),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Minimum payment amount (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateMinPaymentAmount(double.tryParse(v) ?? 0),
          ),
          DropdownButtonFormField<bool>(
            decoration: const InputDecoration(labelText: 'Skip December payment when offered?'),
            value: provider.skipDecember,
            items: const [
              DropdownMenuItem(value: false, child: Text('No')),
              DropdownMenuItem(value: true, child: Text('Yes')),
            ],
            onChanged: (v) => provider.updateSkipDecember(v ?? false),
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Desired table display'),
            value: provider.displayType,
            items: const [
              DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
              DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
            ],
            onChanged: (v) => provider.updateDisplayType(v ?? 'Yearly'),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final parentState = context.findAncestorStateOfType<_CreditCardCalculatorFormState>();
                    parentState?.setTabIndex(0);
                  },
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final balance = provider.balance;
                    final apr = provider.apr;
                    final additionalPayment = provider.additionalPayment;
                    final minPercent = provider.minPaymentPercent;
                    final minAmount = provider.minPaymentAmount;
                    final skipDecember = provider.skipDecember;

                    // Calculate monthly interest rate
                    final monthlyRate = apr / 100 / 12;
                    double currentBalance = balance;
        int months = 0;
        double totalInterest = 0;
        while (currentBalance > 0.01 && months < 1000) {
                      months++;
                      // Skip December payment if enabled
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
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Result'),
            content: Text(
              'By only making minimum payments it will take $months more payments or ${years.toStringAsFixed(1)} years to pay off the remaining balance. Interest will amount to \$${totalInterest.toStringAsFixed(0)}.'
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
