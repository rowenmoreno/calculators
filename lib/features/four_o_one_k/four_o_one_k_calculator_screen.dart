import 'package:flutter/material.dart';
import 'dart:math' show pow;



class FourOOneKCalculatorScreen extends StatefulWidget {
  const FourOOneKCalculatorScreen({super.key});

  @override
  State<FourOOneKCalculatorScreen> createState() => _FourOOneKCalculatorScreenState();
}

class _FourOOneKCalculatorScreenState extends State<FourOOneKCalculatorScreen> {
  int _tabIndex = 0;
  
  // Text field controllers
  final TextEditingController _currentAgeController = TextEditingController();
  final TextEditingController _annualContributionController = TextEditingController();
  final TextEditingController _retirementAgeController = TextEditingController();
  final TextEditingController _yearsToReceiveIncomeController = TextEditingController();
  final TextEditingController _preTaxReturnDistributionController = TextEditingController();
  final TextEditingController _incomeTaxBracketDistributionController = TextEditingController();
  final TextEditingController _preTaxReturnAccumulationController = TextEditingController();
  final TextEditingController _incomeTaxBracketAccumulationController = TextEditingController();
  
  String taxationOption = 'Option 1';
  String? resultMessage;

  @override
  void dispose() {
    _currentAgeController.dispose();
    _annualContributionController.dispose();
    _retirementAgeController.dispose();
    _yearsToReceiveIncomeController.dispose();
    _preTaxReturnDistributionController.dispose();
    _incomeTaxBracketDistributionController.dispose();
    _preTaxReturnAccumulationController.dispose();
    _incomeTaxBracketAccumulationController.dispose();
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
    final annualContribution = result['annualContribution'] ?? 0;
    final contributionYears = result['contributionYears'] ?? 0;
    final annualIncome = result['annualIncome'] ?? 0;
    final monthlyIncome = result['monthlyIncome'] ?? 0;
    final distributionYears = result['distributionYears'] ?? 0;
    final accumulatedValue = result['accumulatedValue'] ?? 0;

    return 'Based on the assumptions you provided, your \$${annualContribution.toStringAsFixed(0)} '
           'annual contribution for ${contributionYears.toStringAsFixed(0)} years could grow to '
           '\$${accumulatedValue.toStringAsFixed(0)} at retirement. '
           'This could provide as much as \$${annualIncome.toStringAsFixed(0)} per year '
           '(\$${monthlyIncome.toStringAsFixed(0)} per month) for your anticipated '
           '${distributionYears.toStringAsFixed(0)} year distribution period.';
  }

  double _calculateTraditional401k(
    double annualContribution,
    double years,
    double returnRate,
    double taxRate
  ) {
    // For Traditional 401(k):
    // 1. Contributions are pre-tax
    // 2. Growth is tax-deferred
    // 3. Withdrawals are taxed as ordinary income
    double balance = 0;
    for (int i = 0; i < years; i++) {
      balance = (balance + annualContribution) * (1 + returnRate);
    }
    // Apply tax on the final amount since it will be taxed upon withdrawal
    return balance * (1 - taxRate);
  }

  double _calculateRoth401k(
    double annualContribution,
    double years,
    double returnRate,
    double taxRate
  ) {
    // For Roth 401(k):
    // 1. Contributions are after-tax
    // 2. Growth is tax-free
    // 3. Qualified withdrawals are tax-free
    double afterTaxContribution = annualContribution * (1 - taxRate);
    double balance = 0;
    for (int i = 0; i < years; i++) {
      balance = (balance + afterTaxContribution) * (1 + returnRate);
    }
    return balance; // No tax on withdrawal for Roth
  }

  double _calculateAnnualIncome(
    double accumulatedValue,
    double distributionYears,
    double returnRate,
    double taxRate
  ) {
    // This uses a simplified distribution calculation
    // assuming equal withdrawals over the distribution period
    // while the remaining balance continues to grow
    
    // PMT formula: PMT = PV * r * (1 + r)^n / ((1 + r)^n - 1)
    // where:
    // PMT = Annual withdrawal
    // PV = Present value (accumulated value)
    // r = Annual return rate
    // n = Number of years
    
    if (returnRate == 0) {
      // Simple division if no return during distribution
      return accumulatedValue / distributionYears;
    }
    
    final numerator = accumulatedValue * returnRate * pow((1 + returnRate), distributionYears);
    final denominator = pow((1 + returnRate), distributionYears) - 1;
    
    return numerator / denominator;
  }

  Map<String, double> _calculate() {
    final currentAge = double.tryParse(_currentAgeController.text) ?? 0;
    final retirementAge = double.tryParse(_retirementAgeController.text) ?? 0;
    final annualContribution = double.tryParse(_annualContributionController.text) ?? 0;
    final yearsToReceiveIncome = double.tryParse(_yearsToReceiveIncomeController.text) ?? 0;
    final preTaxReturnDistribution = (double.tryParse(_preTaxReturnDistributionController.text) ?? 0) / 100;
    final incomeTaxBracketDistribution = (double.tryParse(_incomeTaxBracketDistributionController.text) ?? 0) / 100;
    final preTaxReturnAccumulation = (double.tryParse(_preTaxReturnAccumulationController.text) ?? 0) / 100;
    final incomeTaxBracketAccumulation = (double.tryParse(_incomeTaxBracketAccumulationController.text) ?? 0) / 100;

    final contributionYears = retirementAge - currentAge;
    
    // Calculate accumulated value based on taxation option
    double accumulatedValue;
    if (taxationOption == 'Option 1') {
      // Traditional 401(k) first
      accumulatedValue = _calculateTraditional401k(
        annualContribution,
        contributionYears,
        preTaxReturnAccumulation,
        incomeTaxBracketAccumulation
      );
    } else {
      // Roth 401(k) first
      accumulatedValue = _calculateRoth401k(
        annualContribution,
        contributionYears,
        preTaxReturnAccumulation,
        incomeTaxBracketAccumulation
      );
    }

    // Calculate distribution
    final annualIncome = _calculateAnnualIncome(
      accumulatedValue,
      yearsToReceiveIncome,
      preTaxReturnDistribution,
      incomeTaxBracketDistribution
    );
    
    final monthlyIncome = annualIncome / 12;

    return {
      'annualContribution': annualContribution,
      'contributionYears': contributionYears,
      'annualIncome': annualIncome,
      'monthlyIncome': monthlyIncome,
      'distributionYears': yearsToReceiveIncome,
      'accumulatedValue': accumulatedValue,
    };
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
                SavingsTab(
                  currentAgeController: _currentAgeController,
                  annualContributionController: _annualContributionController,
                  onNext: () => setTabIndex(1),
                ),
                DistributionTab(
                  retirementAgeController: _retirementAgeController,
                  yearsToReceiveIncomeController: _yearsToReceiveIncomeController,
                  preTaxReturnDistributionController: _preTaxReturnDistributionController,
                  incomeTaxBracketDistributionController: _incomeTaxBracketDistributionController,
                  onNext: () => setTabIndex(2),
                  onPrevious: () => setTabIndex(0),
                ),
                AccumulationTab(
                  preTaxReturnAccumulationController: _preTaxReturnAccumulationController,
                  incomeTaxBracketAccumulationController: _incomeTaxBracketAccumulationController,
                  taxationOption: taxationOption,
                  onTaxationOptionChanged: (value) => setState(() => taxationOption = value ?? 'Option 1'),
                  onCalculate: calculateResult,
                  resultMessage: resultMessage,
                  onPrevious: () => setTabIndex(1),
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
  final TextEditingController currentAgeController;
  final TextEditingController annualContributionController;
  final VoidCallback onNext;

  const SavingsTab({
    required this.currentAgeController,
    required this.annualContributionController,
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
            controller: currentAgeController,
            decoration: const InputDecoration(
              labelText: 'Current age (1 to 120)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: annualContributionController,
            decoration: const InputDecoration(
              labelText: 'Your annual contribution (\$)',
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

class DistributionTab extends StatelessWidget {
  final TextEditingController retirementAgeController;
  final TextEditingController yearsToReceiveIncomeController;
  final TextEditingController preTaxReturnDistributionController;
  final TextEditingController incomeTaxBracketDistributionController;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const DistributionTab({
    required this.retirementAgeController,
    required this.yearsToReceiveIncomeController,
    required this.preTaxReturnDistributionController,
    required this.incomeTaxBracketDistributionController,
    required this.onNext,
    required this.onPrevious,
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
            controller: retirementAgeController,
            decoration: const InputDecoration(
              labelText: 'Age when income should start (1 to 120)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: yearsToReceiveIncomeController,
            decoration: const InputDecoration(
              labelText: 'Number of years to receive income (1 to 70)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: preTaxReturnDistributionController,
            decoration: const InputDecoration(
              labelText: 'Before tax return on savings (distribution phase) (-12% to 12%)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: incomeTaxBracketDistributionController,
            decoration: const InputDecoration(
              labelText: 'Income tax bracket (distribution phase) (0% to 75%)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
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
  final TextEditingController preTaxReturnAccumulationController;
  final TextEditingController incomeTaxBracketAccumulationController;
  final String taxationOption;
  final Function(String?) onTaxationOptionChanged;
  final VoidCallback onCalculate;
  final VoidCallback onPrevious;
  final String? resultMessage;

  const AccumulationTab({
    required this.preTaxReturnAccumulationController,
    required this.incomeTaxBracketAccumulationController,
    required this.taxationOption,
    required this.onTaxationOptionChanged,
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
          // Label for Accumulation Phase
          const Text('Before tax return on savings (accumulation phase)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('(-12% to 12%)', 
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: preTaxReturnAccumulationController,
            decoration: const InputDecoration(
              suffixText: '%',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Label for Income Tax Bracket
          const Text('Income tax bracket (accumulation phase)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('(0% to 75%)', 
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: incomeTaxBracketAccumulationController,
            decoration: const InputDecoration(
              suffixText: '%',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Taxation Options
          const Text('Taxation of contribution options',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('1) Traditional 401(k) deductible account fully funded, contributions to Roth 401(k) non-deductible account are reduced',
              style: TextStyle(fontSize: 12)),
          const Text('2) Full contribution made to Roth 401(k) non-deductible account, Traditional 401(k) account given a \'side-account\' to reflect tax savings',
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: taxationOption,
            items: const [
              DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
              DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
            ],
            onChanged: onTaxationOptionChanged,
          ),
          if (resultMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              resultMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Text(
              '* Actual contribution levels to non-deductible accounts have been reduced to reflect the effects of making after-tax contributions.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
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