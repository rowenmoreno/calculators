import 'package:flutter/material.dart';

class FourOOneKCalculatorData {
  double currentAge;
  double annualContribution;
  double retirementAge;
  double yearsToReceiveIncome;
  double preTaxReturnDistribution;
  double incomeTaxBracketDistribution;
  double preTaxReturnAccumulation;
  double incomeTaxBracketAccumulation;
  String taxationOption;

  FourOOneKCalculatorData({
    this.currentAge = 0,
    this.annualContribution = 0,
    this.retirementAge = 0,
    this.yearsToReceiveIncome = 0,
    this.preTaxReturnDistribution = 0,
    this.incomeTaxBracketDistribution = 0,
    this.preTaxReturnAccumulation = 0,
    this.incomeTaxBracketAccumulation = 0,
    this.taxationOption = 'Option 1',
  });

  Map<String, double> calculate() {
    final contributionYears = retirementAge - currentAge;
    final annualIncome = annualContribution * 12; // Simplified calculation
    final monthlyIncome = annualIncome / 12;

    return {
      'annualContribution': annualContribution,
      'contributionYears': contributionYears,
      'annualIncome': annualIncome,
      'monthlyIncome': monthlyIncome,
      'distributionYears': yearsToReceiveIncome,
    };
  }
}

class FourOOneKCalculatorScreen extends StatefulWidget {
  const FourOOneKCalculatorScreen({super.key});

  @override
  State<FourOOneKCalculatorScreen> createState() => _FourOOneKCalculatorScreenState();
}

class _FourOOneKCalculatorScreenState extends State<FourOOneKCalculatorScreen> {
  final data = FourOOneKCalculatorData();
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
                SavingsTab(data: data, onNext: () => setTabIndex(1)),
                DistributionTab(data: data, onNext: () => setTabIndex(2), onPrevious: () => setTabIndex(0)),
                AccumulationTab(data: data, onPrevious: () => setTabIndex(1)),
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
  final FourOOneKCalculatorData data;
  final VoidCallback onNext;
  const SavingsTab({required this.data, required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: data.currentAge.toString(),
            decoration: const InputDecoration(labelText: 'Current age (1 to 120)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.currentAge = double.tryParse(v) ?? 0,
          ),
          TextFormField(
            initialValue: data.annualContribution.toString(),
            decoration: const InputDecoration(labelText: 'Your annual contribution (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.annualContribution = double.tryParse(v) ?? 0,
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
  final FourOOneKCalculatorData data;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  const DistributionTab({required this.data, required this.onNext, required this.onPrevious, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: data.retirementAge.toString(),
            decoration: const InputDecoration(labelText: 'Age when income should start (1 to 120)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.retirementAge = double.tryParse(v) ?? 0,
          ),
          TextFormField(
            initialValue: data.yearsToReceiveIncome.toString(),
            decoration: const InputDecoration(labelText: 'Number of years to receive income (1 to 70)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.yearsToReceiveIncome = double.tryParse(v) ?? 0,
          ),
          TextFormField(
            initialValue: data.preTaxReturnDistribution.toString(),
            decoration: const InputDecoration(labelText: 'Before tax return on savings (distribution phase) (-12% to 12%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.preTaxReturnDistribution = double.tryParse(v) ?? 0,
          ),
          TextFormField(
            initialValue: data.incomeTaxBracketDistribution.toString(),
            decoration: const InputDecoration(labelText: 'Income tax bracket (distribution phase) (0% to 75%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.incomeTaxBracketDistribution = double.tryParse(v) ?? 0,
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
  final FourOOneKCalculatorData data;
  final VoidCallback onPrevious;
  const AccumulationTab({required this.data, required this.onPrevious, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: data.preTaxReturnAccumulation.toString(),
            decoration: const InputDecoration(labelText: 'Before tax return on savings (accumulation phase) (-12% to 12%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.preTaxReturnAccumulation = double.tryParse(v) ?? 0,
          ),
          TextFormField(
            initialValue: data.incomeTaxBracketAccumulation.toString(),
            decoration: const InputDecoration(labelText: 'Income tax bracket (accumulation phase) (0% to 75%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data.incomeTaxBracketAccumulation = double.tryParse(v) ?? 0,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Taxation of contribution options'),
            value: data.taxationOption,
            items: const [
              DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
              DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
            ],
            onChanged: (v) => data.taxationOption = v ?? 'Option 1',
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