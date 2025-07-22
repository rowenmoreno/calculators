import 'package:calculators/features/payroll_withholdings/provider/payroll_withholdings_provider.dart';
import 'package:calculators/features/payroll_withholdings/payroll_withholdings_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayrollWithholdingsCalculatorScreen extends StatelessWidget {
  const PayrollWithholdingsCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PayrollWithholdingsProvider(),
      child: const PayrollWithholdingsCalculatorForm(),
    );
  }
}

class PayrollWithholdingsCalculatorForm extends StatefulWidget {
  const PayrollWithholdingsCalculatorForm({super.key});

  @override
  State<PayrollWithholdingsCalculatorForm> createState() =>
      _PayrollWithholdingsCalculatorFormState();
}

class _PayrollWithholdingsCalculatorFormState
    extends State<PayrollWithholdingsCalculatorForm> {
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
                    provider: Provider.of<PayrollWithholdingsProvider>(context),
                    onNext: () => setTabIndex(1)),
                BusinessIncomeTab(
                    provider: Provider.of<PayrollWithholdingsProvider>(context),
                    onNext: () => setTabIndex(2),
                    onPrevious: () => setTabIndex(0)),
                WithholdingInfoTab(
                    provider: Provider.of<PayrollWithholdingsProvider>(context),
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
  final PayrollWithholdingsProvider provider;
  final VoidCallback onNext;
  const IncomeAndTaxInfoTab(
      {required this.provider, required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Tax filing status'),
            value: provider.taxFilingStatus,
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
            onChanged: (v) => provider.updateTaxFilingStatus(v ?? 'Single'),
          ),
          TextFormField(
            initialValue: provider.taxableGrossAnnualIncome.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Taxable gross annual income subject to ordinary income rates (W-2, unearned/investment, etc) (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateTaxableGrossAnnualIncome(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.traditionalIraContribution.toString(),
            decoration:
                const InputDecoration(labelText: 'Traditional IRA Contribution (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateTraditionalIraContribution(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.itemizedDeductions.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Itemized deductions (state/local and property taxes capped at \$10,000) - \$0 for Standard (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                provider.updateItemizedDeductions(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.numberOfDependentChildren.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Number of dependent children under 17 with SS# (0 to 15)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                provider.updateNumberOfDependentChildren(int.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.numberOfNonChildDependents.toString(),
            decoration: const InputDecoration(
                labelText: 'Number of non-child dependents (0 to 15)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                provider.updateNumberOfNonChildDependents(int.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.grossIncomeConsideredUnearned.toString(),
            decoration: const InputDecoration(
                labelText:
                    'Amount of gross income considered "unearned"/investment income (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateGrossIncomeConsideredUnearned(double.tryParse(v) ?? 0),
          ),
          DropdownButtonFormField<bool>(
            decoration: const InputDecoration(
                labelText:
                    'Are you (and your spouse if filing jointly) either blind or over age 65?'),
            value: provider.isBlindOrOver65,
            items: const [
              DropdownMenuItem(value: false, child: Text('No')),
              DropdownMenuItem(value: true, child: Text('Yes')),
            ],
            onChanged: (v) => provider.updateIsBlindOrOver65(v ?? false),
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
  final PayrollWithholdingsProvider provider;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  const BusinessIncomeTab(
      {required this.provider,
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
            initialValue: provider.totalCompanyPassThroughIncome.toString(),
            decoration: const InputDecoration(
                labelText: 'Total company pass-through income (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateTotalCompanyPassThroughIncome(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.individualCompanyOwnership.toString(),
            decoration: const InputDecoration(
                labelText: 'Individual company ownership (0% to 100%)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateIndividualCompanyOwnership(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.totalCompanyCapitalAssets.toString(),
            decoration: const InputDecoration(
                labelText: 'Total company capital assets (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateTotalCompanyCapitalAssets(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.totalCompanyW2Wages.toString(),
            decoration:
                const InputDecoration(labelText: 'Total company W-2 wages (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                provider.updateTotalCompanyW2Wages(double.tryParse(v) ?? 0),
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
  final PayrollWithholdingsProvider provider;
  final VoidCallback onPrevious;
  const WithholdingInfoTab(
      {required this.provider, required this.onPrevious, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: provider.federalTaxesWithheldToDate.toString(),
            decoration: const InputDecoration(
                labelText: 'Federal taxes withheld to date (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateFederalTaxesWithheldToDate(double.tryParse(v) ?? 0),
          ),
          TextFormField(
            initialValue: provider.taxAmountWithheldLastPayPeriod.toString(),
            decoration: const InputDecoration(
                labelText: 'Tax amount withheld last pay period (\$)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => provider
                .updateTaxAmountWithheldLastPayPeriod(double.tryParse(v) ?? 0),
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Payment frequency'),
            value: provider.paymentFrequency,
            items: const [
              DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'Bi-Weekly', child: Text('Bi-Weekly')),
              DropdownMenuItem(
                  value: 'Semi-Monthly', child: Text('Semi-Monthly')),
              DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'Annually', child: Text('Annually')),
            ],
            onChanged: (v) => provider.updatePaymentFrequency(v ?? 'Weekly'),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PayrollWithholdingsResultScreen(result: result),
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