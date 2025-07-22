import 'package:flutter/material.dart';

class PayrollWithholdingsResultScreen extends StatelessWidget {
  final Map<String, double> result;
  const PayrollWithholdingsResultScreen({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payroll Withholdings Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detailed Data Table',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Estimated Tax Analysis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ResultRow(
                label: 'Gross income',
                value: result['grossIncome'] ?? 0),
            ResultRow(
                label: 'Taxable Pass-Through Income',
                value: result['taxablePassThroughIncome'] ?? 0,
                op: '+'),
            ResultRow(
                label: 'Qualified Plan Contributions',
                value: result['qualifiedPlanContributions'] ?? 0,
                op: '-'),
            ResultRow(
                label: 'Adjusted gross income',
                value: result['adjustedGrossIncome'] ?? 0,
                op: '='),
            ResultRow(
                label: 'Standard/Itemized deductions',
                value: result['standardDeduction'] ?? 0,
                op: '-'),
            ResultRow(
                label: 'Taxable income',
                value: result['taxableIncome'] ?? 0,
                op: '='),
            ResultRow(
                label: 'Tax liability before credits',
                value: result['taxLiabilityBeforeCredits'] ?? 0),
            ResultRow(
                label: 'Child tax credits',
                value: result['childTaxCredits'] ?? 0,
                op: '-'),
            ResultRow(
                label: 'Family tax credits',
                value: result['familyTaxCredits'] ?? 0,
                op: '-'),
            ResultRow(
                label: 'Estimated tax liability',
                value: result['estimatedTaxLiability'] ?? 0,
                op: '='),
            ResultRow(
                label: 'Refundable Child Tax Credit',
                value: result['refundableChildTaxCredit'] ?? 0),
            ResultRow(
                label: 'Taxes withheld to date',
                value: result['taxesWithheldToDate'] ?? 0),
            ResultRow(
                label: 'Taxes yet to be withheld',
                value: result['taxesYetToBeWithheld'] ?? 0,
                op: '+'),
            ResultRow(
                label: 'Total taxes withheld/to be withheld',
                value: result['totalTaxesWithheld'] ?? 0,
                op: '='),
            ResultRow(
                label: 'Tax surplus',
                value: result['taxSurplus'] ?? 0),
          ],
        ),
      ),
    );
  }
}

class ResultRow extends StatelessWidget {
  final String label;
  final double value;
  final String? op;

  const ResultRow({required this.label, required this.value, this.op, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              if (op != null) Text('$op '),
              Text('\$${value.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }
}