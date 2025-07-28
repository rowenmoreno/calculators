import 'package:flutter/material.dart';
import 'dart:math' show pow;


class InvestmentGrowthCalculatorScreen extends StatefulWidget {
  const InvestmentGrowthCalculatorScreen({super.key});

  @override
  State<InvestmentGrowthCalculatorScreen> createState() => _InvestmentGrowthCalculatorScreenState();
}

class _InvestmentGrowthCalculatorScreenState extends State<InvestmentGrowthCalculatorScreen> {
  int _tabIndex = 0;

  // Text field controllers
  final TextEditingController _currentInvestmentController = TextEditingController();
  final TextEditingController _annualContributionsController = TextEditingController();
  final TextEditingController _yearsToInvestController = TextEditingController(text: '20');
  final TextEditingController _beforeTaxReturnFullyTaxableController = TextEditingController(text: '8');
  final TextEditingController _beforeTaxReturnTaxDeferredController = TextEditingController(text: '8');
  final TextEditingController _returnOnTaxFreeInvestmentController = TextEditingController(text: '5');
  final TextEditingController _marginalTaxBracketController = TextEditingController(text: '25');

  String? resultMessage;

  @override
  void dispose() {
    _currentInvestmentController.dispose();
    _annualContributionsController.dispose();
    _yearsToInvestController.dispose();
    _beforeTaxReturnFullyTaxableController.dispose();
    _beforeTaxReturnTaxDeferredController.dispose();
    _returnOnTaxFreeInvestmentController.dispose();
    _marginalTaxBracketController.dispose();
    super.dispose();
  }

  void setTabIndex(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void calculateResult() {
    final result = _calculate();
    setState(() {
      resultMessage = _formatResult(result);
    });
  }

  String _formatResult(Map<String, double> result) {
    return 'Based on the assumptions you provided you could expect to accumulate '
           '\$${result['fullyTaxable']?.toStringAsFixed(0)} in a fully-taxable account, '
           '\$${result['taxDeferred']?.toStringAsFixed(0)} in a tax-deferred investment (adjusted for taxes), '
           'or \$${result['taxFree']?.toStringAsFixed(0)} in a tax-free investment vehicle.';
  }

  Map<String, double> _calculate() {
    // Get values from controllers
    final currentInvestmentBalance = double.tryParse(_currentInvestmentController.text) ?? 0;
    final yearsToInvest = double.tryParse(_yearsToInvestController.text) ?? 20;
    final beforeTaxReturnFullyTaxable = (double.tryParse(_beforeTaxReturnFullyTaxableController.text) ?? 8) / 100;
    final beforeTaxReturnTaxDeferred = (double.tryParse(_beforeTaxReturnTaxDeferredController.text) ?? 8) / 100;
    final returnOnTaxFreeInvestment = (double.tryParse(_returnOnTaxFreeInvestmentController.text) ?? 5) / 100;
    final marginalTaxBracket = (double.tryParse(_marginalTaxBracketController.text) ?? 25) / 100;

    // For fully-taxable account:
    // The after-tax return is 6.0% (8% before-tax return × (1 - 25% tax rate))
    final afterTaxReturnFullyTaxable = beforeTaxReturnFullyTaxable * (1 - marginalTaxBracket);
    final fullyTaxable = currentInvestmentBalance * pow(1 + afterTaxReturnFullyTaxable, yearsToInvest);
    
    // For tax-deferred account:
    // Money grows tax-free at 8%, then entire amount is taxed at withdrawal
    final taxDeferredBeforeTax = currentInvestmentBalance * pow(1 + beforeTaxReturnTaxDeferred, yearsToInvest);
    final taxDeferred = taxDeferredBeforeTax * (1 - marginalTaxBracket);
    
    // For tax-free account:
    // Money grows at 5% with no taxes due
    final taxFree = currentInvestmentBalance * pow(1 + returnOnTaxFreeInvestment, yearsToInvest);

    return {
      'fullyTaxable': fullyTaxable,
      'taxDeferred': taxDeferred,
      'taxFree': taxFree,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Growth Calculator'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabButton(
                  text: 'Savings',
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
            child: IndexedStack(
              index: _tabIndex,
              children: [
                SavingsTab(
                  currentInvestmentController: _currentInvestmentController,
                  annualContributionsController: _annualContributionsController,
                  yearsToInvestController: _yearsToInvestController,
                  onNext: () => setTabIndex(1),
                ),
                AssumptionsTab(
                  beforeTaxReturnFullyTaxableController: _beforeTaxReturnFullyTaxableController,
                  beforeTaxReturnTaxDeferredController: _beforeTaxReturnTaxDeferredController,
                  returnOnTaxFreeInvestmentController: _returnOnTaxFreeInvestmentController,
                  marginalTaxBracketController: _marginalTaxBracketController,
                  onCalculate: calculateResult,
                  resultMessage: resultMessage,
                  onPrevious: () => setTabIndex(0),
                ),
              ],
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
  const TabButton(
      {required this.text,
      required this.selected,
      required this.onTap,
      super.key});

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

class SavingsTab extends StatelessWidget {
  final TextEditingController currentInvestmentController;
  final TextEditingController annualContributionsController;
  final TextEditingController yearsToInvestController;
  final VoidCallback onNext;

  const SavingsTab({
    required this.currentInvestmentController,
    required this.annualContributionsController,
    required this.yearsToInvestController,
    required this.onNext,
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
            controller: currentInvestmentController,
            decoration: const InputDecoration(
              labelText: 'Current investment balance (\$)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: annualContributionsController,
            decoration: const InputDecoration(
              labelText: 'Annual contributions (\$)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: yearsToInvestController,
            decoration: const InputDecoration(
              labelText: 'Number of years to invest (1 to 50)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class AssumptionsTab extends StatelessWidget {
  final TextEditingController beforeTaxReturnFullyTaxableController;
  final TextEditingController beforeTaxReturnTaxDeferredController;
  final TextEditingController returnOnTaxFreeInvestmentController;
  final TextEditingController marginalTaxBracketController;
  final VoidCallback onCalculate;
  final VoidCallback onPrevious;
  final String? resultMessage;

  const AssumptionsTab({
    required this.beforeTaxReturnFullyTaxableController,
    required this.beforeTaxReturnTaxDeferredController,
    required this.returnOnTaxFreeInvestmentController,
    required this.marginalTaxBracketController,
    required this.onCalculate,
    required this.onPrevious,
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
            controller: beforeTaxReturnFullyTaxableController,
            decoration: const InputDecoration(
              labelText: 'Before-tax return on fully-taxable investment (-12% to 12%)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: beforeTaxReturnTaxDeferredController,
            decoration: const InputDecoration(
              labelText: 'Before-tax return on tax-deferred investment (-12% to 12%)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: returnOnTaxFreeInvestmentController,
            decoration: const InputDecoration(
              labelText: 'Return on tax-free investment (-12% to 12%)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: marginalTaxBracketController,
            decoration: const InputDecoration(
              labelText: 'Marginal tax bracket (0% to 75%)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
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