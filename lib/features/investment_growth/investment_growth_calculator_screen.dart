import 'package:flutter/material.dart';

class InvestmentGrowthData {
  double currentInvestmentBalance;
  double annualContributions;
  double yearsToInvest;
  double beforeTaxReturnFullyTaxable;
  double beforeTaxReturnTaxDeferred;
  double returnOnTaxFreeInvestment;
  double marginalTaxBracket;

  InvestmentGrowthData({
    this.currentInvestmentBalance = 0,
    this.annualContributions = 0,
    this.yearsToInvest = 20,
    this.beforeTaxReturnFullyTaxable = 8,
    this.beforeTaxReturnTaxDeferred = 8,
    this.returnOnTaxFreeInvestment = 5,
    this.marginalTaxBracket = 25,
  });

  Map<String, double> calculate() {
    // This is a simplified calculation and does not represent a real financial model.
    // It is for demonstration purposes only.
    final fullyTaxable = currentInvestmentBalance + (annualContributions * yearsToInvest) * (1 + (beforeTaxReturnFullyTaxable / 100));
    final taxDeferred = currentInvestmentBalance + (annualContributions * yearsToInvest) * (1 + (beforeTaxReturnTaxDeferred / 100));
    final taxFree = currentInvestmentBalance + (annualContributions * yearsToInvest) * (1 + (returnOnTaxFreeInvestment / 100));

    return {
      'fullyTaxable': fullyTaxable,
      'taxDeferred': taxDeferred,
      'taxFree': taxFree,
    };
  }
}

class InvestmentGrowthCalculatorScreen extends StatefulWidget {
  const InvestmentGrowthCalculatorScreen({super.key});

  @override
  State<InvestmentGrowthCalculatorScreen> createState() => _InvestmentGrowthCalculatorScreenState();
}

class _InvestmentGrowthCalculatorScreenState extends State<InvestmentGrowthCalculatorScreen> {
  final data = InvestmentGrowthData();
  int _tabIndex = 0;

  void setTabIndex(int index) {
    setState(() {
      _tabIndex = index;
    });
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
                SavingsTab(data: data, onNext: () => setTabIndex(1)),
                AssumptionsTab(data: data, onPrevious: () => setTabIndex(0)),
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
  final InvestmentGrowthData data;
  final VoidCallback onNext;
  const SavingsTab({required this.data, required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: data.currentInvestmentBalance.toString(),
            decoration:
                const InputDecoration(labelText: 'Current investment balance (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                data.currentInvestmentBalance = double.tryParse(v) ?? 0,
          ),
          TextFormField(
            initialValue: data.annualContributions.toString(),
            decoration:
                const InputDecoration(labelText: 'Annual contributions (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                data.annualContributions = double.tryParse(v) ?? 0,
          ),
          TextFormField(
            initialValue: data.yearsToInvest.toString(),
            decoration:
                const InputDecoration(labelText: 'Number of years to invest (1 to 50)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                data.yearsToInvest = double.tryParse(v) ?? 0,
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
  final InvestmentGrowthData data;
  final VoidCallback onPrevious;
  const AssumptionsTab(
      {required this.data, required this.onPrevious, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: data.beforeTaxReturnFullyTaxable.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Before-tax return on fully-taxable investment (-12% to 12%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.beforeTaxReturnFullyTaxable = double.tryParse(v) ?? 0,
          ),
          TextFormField(
            initialValue: data.beforeTaxReturnTaxDeferred.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Before-tax return on tax-deferred investment (-12% to 12%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.beforeTaxReturnTaxDeferred = double.tryParse(v) ?? 0,
          ),
          TextFormField(
            initialValue: data.returnOnTaxFreeInvestment.toString(),
            decoration: const InputDecoration(
                labelText: 'Return on tax-free investment (-12% to 12%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.returnOnTaxFreeInvestment = double.tryParse(v) ?? 0,
          ),
          TextFormField(
            initialValue: data.marginalTaxBracket.toString(),
            decoration:
                const InputDecoration(labelText: 'Marginal tax bracket (0% to 75%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                data.marginalTaxBracket = double.tryParse(v) ?? 0,
          ),
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
                  onPressed: () {
                    final result = data.calculate();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Result'),
                        content: Text(
                            'Based on the assumptions you provided you could expect to accumulate \$${result['fullyTaxable']?.toStringAsFixed(0)} in a fully-taxable account, \$${result['taxDeferred']?.toStringAsFixed(0)} in a tax-deferred investment (adjusted for taxes), or \$${result['taxFree']?.toStringAsFixed(0)} in a tax-free investment vehicle.'),
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