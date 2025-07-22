import 'package:calculators/features/investment_growth/provider/investment_growth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InvestmentGrowthCalculatorScreen extends StatelessWidget {
  const InvestmentGrowthCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InvestmentGrowthProvider(),
      child: const InvestmentGrowthCalculatorForm(),
    );
  }
}

class InvestmentGrowthCalculatorForm extends StatefulWidget {
  const InvestmentGrowthCalculatorForm({super.key});

  @override
  State<InvestmentGrowthCalculatorForm> createState() =>
      _InvestmentGrowthCalculatorFormState();
}

class _InvestmentGrowthCalculatorFormState
    extends State<InvestmentGrowthCalculatorForm> {
  int _tabIndex = 0;

  void setTabIndex(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvestmentGrowthProvider>(context);
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
                SavingsTab(provider: provider, onNext: () => setTabIndex(1)),
                AssumptionsTab(
                    provider: provider, onPrevious: () => setTabIndex(0)),
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
  final InvestmentGrowthProvider provider;
  final VoidCallback onNext;
  const SavingsTab({required this.provider, required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: provider.currentInvestmentBalance.toString(),
            decoration:
                const InputDecoration(labelText: 'Current investment balance (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                provider.updateCurrentInvestmentBalance(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.annualContributions.toString(),
            decoration:
                const InputDecoration(labelText: 'Annual contributions (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                provider.updateAnnualContributions(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.yearsToInvest.toString(),
            decoration:
                const InputDecoration(labelText: 'Number of years to invest (1 to 50)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                provider.updateYearsToInvest(double.tryParse(v) ?? 0),
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
  final InvestmentGrowthProvider provider;
  final VoidCallback onPrevious;
  const AssumptionsTab(
      {required this.provider, required this.onPrevious, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: provider.beforeTaxReturnFullyTaxable.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Before-tax return on fully-taxable investment (-12% to 12%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateBeforeTaxReturnFullyTaxable(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.beforeTaxReturnTaxDeferred.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Before-tax return on tax-deferred investment (-12% to 12%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateBeforeTaxReturnTaxDeferred(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.returnOnTaxFreeInvestment.toString(),
            decoration: const InputDecoration(
                labelText: 'Return on tax-free investment (-12% to 12%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateReturnOnTaxFreeInvestment(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.marginalTaxBracket.toString(),
            decoration:
                const InputDecoration(labelText: 'Marginal tax bracket (0% to 75%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                provider.updateMarginalTaxBracket(double.tryParse(v) ?? 0),
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
                    final result = provider.calculate();
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