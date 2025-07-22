import 'package:calculators/features/four_o_one_k/provider/four_o_one_k_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FourOOneKCalculatorScreen extends StatelessWidget {
  const FourOOneKCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FourOOneKProvider(),
      child: const FourOOneKCalculatorForm(),
    );
  }
}

class FourOOneKCalculatorForm extends StatefulWidget {
  const FourOOneKCalculatorForm({super.key});

  @override
  State<FourOOneKCalculatorForm> createState() => _FourOOneKCalculatorFormState();
}

class _FourOOneKCalculatorFormState extends State<FourOOneKCalculatorForm> {
  int _tabIndex = 0;

  void setTabIndex(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FourOOneKProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('401K Calculator'),
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
                  text: 'Distribution',
                  selected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ),
              Expanded(
                child: TabButton(
                  text: 'Accumulation',
                  selected: _tabIndex == 2,
                  onTap: () => setState(() => _tabIndex = 2),
                ),
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                SavingsTab(provider: provider, onNext: () => setTabIndex(1)),
                DistributionTab(provider: provider, onNext: () => setTabIndex(2), onPrevious: () => setTabIndex(0)),
                AccumulationTab(provider: provider, onPrevious: () => setTabIndex(1)),
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

class SavingsTab extends StatelessWidget {
  final FourOOneKProvider provider;
  final VoidCallback onNext;
  const SavingsTab({required this.provider, required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: provider.currentAge.toString(),
            decoration: const InputDecoration(labelText: 'Current age (1 to 120)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateCurrentAge(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.annualContribution.toString(),
            decoration: const InputDecoration(labelText: 'Your annual contribution (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateAnnualContribution(double.tryParse(v) ?? 0),
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

class DistributionTab extends StatelessWidget {
  final FourOOneKProvider provider;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  const DistributionTab({required this.provider, required this.onNext, required this.onPrevious, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: provider.retirementAge.toString(),
            decoration: const InputDecoration(labelText: 'Age when income should start (1 to 120)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateRetirementAge(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.yearsToReceiveIncome.toString(),
            decoration: const InputDecoration(labelText: 'Number of years to receive income (1 to 70)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateYearsToReceiveIncome(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.preTaxReturnDistribution.toString(),
            decoration: const InputDecoration(labelText: 'Before tax return on savings (distribution phase) (-12% to 12%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updatePreTaxReturnDistribution(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.incomeTaxBracketDistribution.toString(),
            decoration: const InputDecoration(labelText: 'Income tax bracket (distribution phase) (0% to 75%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateIncomeTaxBracketDistribution(double.tryParse(v) ?? 0),
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
                  onPressed: onNext,
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AccumulationTab extends StatelessWidget {
  final FourOOneKProvider provider;
  final VoidCallback onPrevious;
  const AccumulationTab({required this.provider, required this.onPrevious, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: provider.preTaxReturnAccumulation.toString(),
            decoration: const InputDecoration(labelText: 'Before tax return on savings (accumulation phase) (-12% to 12%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updatePreTaxReturnAccumulation(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.incomeTaxBracketAccumulation.toString(),
            decoration: const InputDecoration(labelText: 'Income tax bracket (accumulation phase) (0% to 75%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider.updateIncomeTaxBracketAccumulation(double.tryParse(v) ?? 0),
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Taxation of contribution options'),
            value: provider.taxationOption,
            items: const [
              DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
              DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
            ],
            onChanged: (v) => provider.updateTaxationOption(v ?? 'Option 1'),
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
                    final provider = Provider.of<FourOOneKProvider>(context, listen: false);
                    final result = provider.calculate();
                    final annualContribution = result['annualContribution'] ?? 0;
                    final contributionYears = result['contributionYears'] ?? 0;
                    final annualIncome = result['annualIncome'] ?? 0;
                    final monthlyIncome = result['monthlyIncome'] ?? 0;
                    final distributionYears = result['distributionYears'] ?? 0;

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Result'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Based on the assumptions you provided, your \$${annualContribution.toStringAsFixed(0)} annual contribution for ${contributionYears.toStringAsFixed(0)} years could provide as much as \$${annualIncome.toStringAsFixed(0)} per year (\$${monthlyIncome.toStringAsFixed(0)} per month) for your anticipated ${distributionYears.toStringAsFixed(0)} year distribution period.'
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '* Actual contribution levels to non-deductible accounts have been reduced to reflect the effects of making after-tax contributions.',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
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