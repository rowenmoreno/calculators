
import 'package:flutter/material.dart';

class PayrollWithholdingsData {
  String taxFilingStatus = 'Single';
  double taxableGrossAnnualIncome = 0;
  double traditionalIraContribution = 0;
  double itemizedDeductions = 0;
  int numberOfDependentChildren = 0;
  int numberOfNonChildDependents = 0;
  double grossIncomeConsideredUnearned = 0;
  bool isBlindOrOver65 = false;
  double totalCompanyPassThroughIncome = 0;
  double individualCompanyOwnership = 0;
  double totalCompanyCapitalAssets = 0;
  double totalCompanyW2Wages = 0;
  double federalTaxesWithheldToDate = 0;
  double taxAmountWithheldLastPayPeriod = 0;
  String paymentFrequency = 'Weekly';

  void updateTaxFilingStatus(String value) => taxFilingStatus = value;
  void updateTaxableGrossAnnualIncome(double value) => taxableGrossAnnualIncome = value;
  void updateTraditionalIraContribution(double value) => traditionalIraContribution = value;
  void updateItemizedDeductions(double value) => itemizedDeductions = value;
  void updateNumberOfDependentChildren(int value) => numberOfDependentChildren = value;
  void updateNumberOfNonChildDependents(int value) => numberOfNonChildDependents = value;
  void updateGrossIncomeConsideredUnearned(double value) => grossIncomeConsideredUnearned = value;
  void updateIsBlindOrOver65(bool value) => isBlindOrOver65 = value;
  void updateTotalCompanyPassThroughIncome(double value) => totalCompanyPassThroughIncome = value;
  void updateIndividualCompanyOwnership(double value) => individualCompanyOwnership = value;
  void updateTotalCompanyCapitalAssets(double value) => totalCompanyCapitalAssets = value;
  void updateTotalCompanyW2Wages(double value) => totalCompanyW2Wages = value;
  void updateFederalTaxesWithheldToDate(double value) => federalTaxesWithheldToDate = value;
  void updateTaxAmountWithheldLastPayPeriod(double value) => taxAmountWithheldLastPayPeriod = value;
  void updatePaymentFrequency(String value) => paymentFrequency = value;

  Map<String, double> calculate() {
    final double standardDeduction = _getStandardDeduction();
    final double qualifiedBusinessIncome = _calculateQualifiedBusinessIncome();
    final double effectiveTaxableIncome = _calculateEffectiveTaxableIncome(standardDeduction);
    final double totalTax = _calculateTotalTax(effectiveTaxableIncome, qualifiedBusinessIncome);
    final double childTaxCredit = _calculateChildTaxCredit(totalTax);
    final int remainingPayPeriods = _getRemainingPayPeriods();
    final double suggestedWithholding = _calculateSuggestedWithholding(totalTax, childTaxCredit, remainingPayPeriods);

    return {
      'standardDeduction': standardDeduction,
      'qualifiedBusinessIncome': qualifiedBusinessIncome,
      'effectiveTaxableIncome': effectiveTaxableIncome,
      'totalTax': totalTax,
      'childTaxCredit': childTaxCredit,
      'suggestedWithholding': suggestedWithholding,
      'remainingPayPeriods': remainingPayPeriods.toDouble(),
    };
  }

  double _getStandardDeduction() {
    switch (taxFilingStatus) {
      case 'Single':
        return isBlindOrOver65 ? 14900 : 13850;
      case 'Head of Household':
        return isBlindOrOver65 ? 21800 : 20800;
      case 'Married-Separately':
        return isBlindOrOver65 ? 14900 : 13850;
      case 'Married-Jointly':
        return isBlindOrOver65 ? 29700 : 27700;
      case 'Trust':
        return 100;
      default:
        return 0;
    }
  }

  double _calculateQualifiedBusinessIncome() {
    final double qbiDeduction = totalCompanyPassThroughIncome * (individualCompanyOwnership / 100) * 0.2;
    final double w2Limit = totalCompanyW2Wages * (individualCompanyOwnership / 100) * 0.5;
    final double capitalLimit = (totalCompanyCapitalAssets * (individualCompanyOwnership / 100) * 0.25) +
        (totalCompanyW2Wages * (individualCompanyOwnership / 100) * 0.25);
    
    return [qbiDeduction, w2Limit, capitalLimit].reduce((a, b) => a < b ? a : b);
  }

  double _calculateEffectiveTaxableIncome(double standardDeduction) {
    final double deduction = itemizedDeductions > standardDeduction ? itemizedDeductions : standardDeduction;
    return taxableGrossAnnualIncome - deduction - traditionalIraContribution;
  }

  double _calculateTotalTax(double effectiveTaxableIncome, double qualifiedBusinessIncome) {
    double remainingIncome = effectiveTaxableIncome - qualifiedBusinessIncome;
    double totalTax = 0;

    if (taxFilingStatus == 'Single') {
      if (remainingIncome > 578125) {
        totalTax += (remainingIncome - 578125) * 0.37;
        remainingIncome = 578125;
      }
      if (remainingIncome > 231250) {
        totalTax += (remainingIncome - 231250) * 0.35;
        remainingIncome = 231250;
      }
      if (remainingIncome > 182100) {
        totalTax += (remainingIncome - 182100) * 0.32;
        remainingIncome = 182100;
      }
      if (remainingIncome > 95375) {
        totalTax += (remainingIncome - 95375) * 0.24;
        remainingIncome = 95375;
      }
      if (remainingIncome > 44725) {
        totalTax += (remainingIncome - 44725) * 0.22;
        remainingIncome = 44725;
      }
      if (remainingIncome > 11000) {
        totalTax += (remainingIncome - 11000) * 0.12;
        remainingIncome = 11000;
      }
      totalTax += remainingIncome * 0.10;
    }
    return totalTax;
  }

  double _calculateChildTaxCredit(double totalTax) {
    return (numberOfDependentChildren * 2000 + numberOfNonChildDependents * 500).toDouble();
  }

  int _getRemainingPayPeriods() {
    final int totalPeriods = {
      'Weekly': 52,
      'Bi-Weekly': 26,
      'Semi-Monthly': 24,
      'Monthly': 12,
      'Annually': 1,
    }[paymentFrequency] ?? 52;

    return (totalPeriods / 2).round();
  }

  double _calculateSuggestedWithholding(double totalTax, double childTaxCredit, int remainingPayPeriods) {
    final double remaining = totalTax - childTaxCredit - federalTaxesWithheldToDate;
    return remaining / remainingPayPeriods;
  }
}

class PayrollWithholdingsCalculatorScreen extends StatefulWidget {
  const PayrollWithholdingsCalculatorScreen({super.key});

  @override
  State<PayrollWithholdingsCalculatorScreen> createState() => _PayrollWithholdingsCalculatorScreenState();
}

class _PayrollWithholdingsCalculatorScreenState extends State<PayrollWithholdingsCalculatorScreen> {
  final data = PayrollWithholdingsData();
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
        title: const Text('Payroll Withholdings Calculator'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabButton(
                  text: 'Income and Tax Information',
                  selected: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
              ),
              Expanded(
                child: TabButton(
                  text: 'Business/Self-Employed Income',
                  selected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ),
              Expanded(
                child: TabButton(
                  text: 'Withholding Information',
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
                IncomeAndTaxInfoTab(
                    data: data,
                    onNext: () => setTabIndex(1)),
                BusinessIncomeTab(
                    data: data,
                    onNext: () => setTabIndex(2),
                    onPrevious: () => setTabIndex(0)),
                WithholdingInfoTab(
                    data: data,
                    onPrevious: () => setTabIndex(1)),
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

class IncomeAndTaxInfoTab extends StatelessWidget {
  final PayrollWithholdingsData data;
  final VoidCallback onNext;
  const IncomeAndTaxInfoTab(
      {required this.data, required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Tax filing status'),
            value: data.taxFilingStatus,
            items: const [
              DropdownMenuItem(value: 'Single', child: Text('Single')),
              DropdownMenuItem(
                  value: 'Head of Household', child: Text('Head of Household')),
              DropdownMenuItem(
                  value: 'Married-Separately',
                  child: Text('Married-Separately')),
              DropdownMenuItem(
                  value: 'Married-Jointly', child: Text('Married-Jointly')),
              DropdownMenuItem(value: 'Trust', child: Text('Trust')),
            ],
            onChanged: (v) => data.updateTaxFilingStatus(v ?? 'Single'),
          ),
          TextFormField(
            initialValue: data.taxableGrossAnnualIncome.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Taxable gross annual income subject to ordinary income rates (W-2, unearned/investment, etc) (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data
                .updateTaxableGrossAnnualIncome(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: data.traditionalIraContribution.toString(),
            decoration:
                const InputDecoration(labelText: 'Traditional IRA Contribution (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data
                .updateTraditionalIraContribution(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: data.itemizedDeductions.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Itemized deductions (state/local and property taxes capped at \$10,000) - \$0 for Standard (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                data.updateItemizedDeductions(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: data.numberOfDependentChildren.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Number of dependent children under 17 with SS# (0 to 15)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                data.updateNumberOfDependentChildren(int.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: data.numberOfNonChildDependents.toString(),
            decoration: const InputDecoration(
                labelText: 'Number of non-child dependents (0 to 15)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                data.updateNumberOfNonChildDependents(int.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: data.grossIncomeConsideredUnearned.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Amount of gross income considered "unearned"/investment income (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data
                .updateGrossIncomeConsideredUnearned(double.tryParse(v) ?? 0),
          ),
          DropdownButtonFormField<bool>(
            decoration: const InputDecoration(
                labelText:
                    'Are you (and your spouse if filing jointly) either blind or over age 65?'),
            value: data.isBlindOrOver65,
            items: const [
              DropdownMenuItem(value: false, child: Text('No')),
              DropdownMenuItem(value: true, child: Text('Yes')),
            ],
            onChanged: (v) => data.updateIsBlindOrOver65(v ?? false),
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

class BusinessIncomeTab extends StatelessWidget {
  final PayrollWithholdingsData data;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  const BusinessIncomeTab(
      {required this.data,
      required this.onNext,
      required this.onPrevious,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: data.totalCompanyPassThroughIncome.toString(),
            decoration: const InputDecoration(
                labelText: 'Total company pass-through income (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data
                .updateTotalCompanyPassThroughIncome(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: data.individualCompanyOwnership.toString(),
            decoration: const InputDecoration(
                labelText: 'Individual company ownership (0% to 100%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data
                .updateIndividualCompanyOwnership(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: data.totalCompanyCapitalAssets.toString(),
            decoration: const InputDecoration(
                labelText: 'Total company capital assets (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data
                .updateTotalCompanyCapitalAssets(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: data.totalCompanyW2Wages.toString(),
            decoration:
                const InputDecoration(labelText: 'Total company W-2 wages (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                data.updateTotalCompanyW2Wages(double.tryParse(v) ?? 0),
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

class WithholdingInfoTab extends StatelessWidget {
  final PayrollWithholdingsData data;
  final VoidCallback onPrevious;
  const WithholdingInfoTab(
      {required this.data, required this.onPrevious, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: data.federalTaxesWithheldToDate.toString(),
            decoration: const InputDecoration(
                labelText: 'Federal taxes withheld to date (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data
                .updateFederalTaxesWithheldToDate(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: data.taxAmountWithheldLastPayPeriod.toString(),
            decoration: const InputDecoration(
                labelText: 'Tax amount withheld last pay period (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => data
                .updateTaxAmountWithheldLastPayPeriod(double.tryParse(v) ?? 0),
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Payment frequency'),
            value: data.paymentFrequency,
            items: const [
              DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'Bi-Weekly', child: Text('Bi-Weekly')),
              DropdownMenuItem(
                  value: 'Semi-Monthly', child: Text('Semi-Monthly')),
              DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'Annually', child: Text('Annually')),
            ],
            onChanged: (v) => data.updatePaymentFrequency(v ?? 'Weekly'),
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
