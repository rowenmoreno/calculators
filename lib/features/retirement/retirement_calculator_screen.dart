import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/retirement_calculator_provider.dart';

class RetirementCalculatorScreen extends StatelessWidget {
  const RetirementCalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RetirementCalculatorProvider(),
      child: const _RetirementCalculatorView(),
    );
  }
}

class _RetirementCalculatorView extends StatelessWidget {
  const _RetirementCalculatorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RetirementCalculatorProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Retirement Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.currentStep == i ? Colors.teal : Colors.grey[300],
                        foregroundColor: provider.currentStep == i ? Colors.white : Colors.black,
                      ),
                      onPressed: () => provider.setStep(i),
                      child: Text('Part ${i + 1}'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: _buildStepContent(context, provider))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (provider.currentStep > 0)
                  ElevatedButton(
                    onPressed: provider.prevStep,
                    child: const Text('Previous'),
                  ),
                if (provider.currentStep < 2)
                  ElevatedButton(
                    onPressed: provider.nextStep,
                    child: const Text('Next'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, RetirementCalculatorProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Assumptions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Monthly or annual figures?'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: provider.figuresType,
                  items: const [DropdownMenuItem(value: 'Monthly', child: Text('Monthly')), DropdownMenuItem(value: 'Annual', child: Text('Annual'))],
                  onChanged: (val) {
                    if (val != null) provider.setFiguresType(val);
                  },
                ),
              ],
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Itemized Income', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(children: [
                  const SizedBox(),
                  const Center(child: Text('Pre-Retirement')),
                  const Center(child: Text('Post-Retirement')),
                ]),
                ...provider.incomeFields.map((field) => TableRow(children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(field)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: provider.incomeControllers[field + '_pre'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: provider.incomeControllers[field + '_post'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                ])),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Itemized Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(children: [
                  const SizedBox(),
                  const Center(child: Text('Pre-Retirement')),
                  const Center(child: Text('Post-Retirement')),
                ]),
                ...provider.expenseFields.map((field) => TableRow(children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(field)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: provider.expenseControllers[field + '_pre'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: provider.expenseControllers[field + '_post'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                ])),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: provider.calculateResult,
                child: const Text('Calculate'),
              ),
            ),
            if (provider.resultSummary != null) ...[
              const SizedBox(height: 16),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(provider.resultSummary!),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () => _emailResults(context),
                  child: const Text('Email Results'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        );
      default:
        return const SizedBox();
    }
  }

  void _emailResults(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Results'),
        content: const Text('Email functionality is not implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 