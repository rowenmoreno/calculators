import 'package:flutter/material.dart';

class RetirementData {
  String figuresType = 'Monthly';
  int currentStep = 0;
  String? resultSummary;
  
  final Map<String, TextEditingController> incomeControllers = {};
  final Map<String, TextEditingController> expenseControllers = {};
  
  final List<String> incomeFields = [
    'Salary',
    'Investment Income',
    'Pension',
    'Social Security',
    'Other Income'
  ];
  
  final List<String> expenseFields = [
    'Housing',
    'Transportation',
    'Healthcare',
    'Food & Dining',
    'Entertainment',
    'Insurance',
    'Other Expenses'
  ];

  RetirementData() {
    for (var field in incomeFields) {
      incomeControllers[field + '_pre'] = TextEditingController();
      incomeControllers[field + '_post'] = TextEditingController();
    }
    for (var field in expenseFields) {
      expenseControllers[field + '_pre'] = TextEditingController();
      expenseControllers[field + '_post'] = TextEditingController();
    }
  }

  void dispose() {
    for (var controller in [...incomeControllers.values, ...expenseControllers.values]) {
      controller.dispose();
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 2) {
      currentStep = step;
    }
  }

  void nextStep() {
    if (currentStep < 2) {
      currentStep++;
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
    }
  }

  void setFiguresType(String type) {
    figuresType = type;
  }

  void calculateResult() {
    double totalPreIncome = 0;
    double totalPostIncome = 0;
    double totalPreExpenses = 0;
    double totalPostExpenses = 0;

    for (var field in incomeFields) {
      totalPreIncome += double.tryParse(incomeControllers[field + '_pre']?.text ?? '0') ?? 0;
      totalPostIncome += double.tryParse(incomeControllers[field + '_post']?.text ?? '0') ?? 0;
    }

    for (var field in expenseFields) {
      totalPreExpenses += double.tryParse(expenseControllers[field + '_pre']?.text ?? '0') ?? 0;
      totalPostExpenses += double.tryParse(expenseControllers[field + '_post']?.text ?? '0') ?? 0;
    }

    double preRetirementNet = totalPreIncome - totalPreExpenses;
    double postRetirementNet = totalPostIncome - totalPostExpenses;
    double difference = postRetirementNet - preRetirementNet;

    resultSummary = '''
    ${figuresType} Summary:
    Pre-Retirement:
      Total Income: \$${totalPreIncome.toStringAsFixed(2)}
      Total Expenses: \$${totalPreExpenses.toStringAsFixed(2)}
      Net: \$${preRetirementNet.toStringAsFixed(2)}
      
    Post-Retirement:
      Total Income: \$${totalPostIncome.toStringAsFixed(2)}
      Total Expenses: \$${totalPostExpenses.toStringAsFixed(2)}
      Net: \$${postRetirementNet.toStringAsFixed(2)}
      
    Difference in Net: \$${difference.toStringAsFixed(2)}
    ''';
  }
}

class RetirementCalculatorScreen extends StatefulWidget {
  const RetirementCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<RetirementCalculatorScreen> createState() => _RetirementCalculatorScreenState();
}

class _RetirementCalculatorScreenState extends State<RetirementCalculatorScreen> {
  final data = RetirementData();

  @override
  void dispose() {
    data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        backgroundColor: data.currentStep == i ? Colors.teal : Colors.grey[300],
                        foregroundColor: data.currentStep == i ? Colors.white : Colors.black,
                      ),
                      onPressed: () => setState(() => data.setStep(i)),
                      child: Text('Part ${i + 1}'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: _buildStepContent(context))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (data.currentStep > 0)
                  ElevatedButton(
                    onPressed: () => setState(() => data.prevStep()),
                    child: const Text('Previous'),
                  ),
                if (data.currentStep < 2)
                  ElevatedButton(
                    onPressed: () => setState(() => data.nextStep()),
                    child: const Text('Next'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (data.currentStep) {
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
                  value: data.figuresType,
                  items: const [DropdownMenuItem(value: 'Monthly', child: Text('Monthly')), DropdownMenuItem(value: 'Annual', child: Text('Annual'))],
                  onChanged: (val) {
                    if (val != null) setState(() => data.setFiguresType(val));
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
                ...data.incomeFields.map((field) => TableRow(children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(field)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: data.incomeControllers[field + '_pre'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      onChanged: (_) => setState(() => data.calculateResult()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: data.incomeControllers[field + '_post'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      onChanged: (_) => setState(() => data.calculateResult()),
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
                ...data.expenseFields.map((field) => TableRow(children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(field)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: data.expenseControllers[field + '_pre'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      onChanged: (_) => setState(() => data.calculateResult()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: data.expenseControllers[field + '_post'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      onChanged: (_) => setState(() => data.calculateResult()),
                    ),
                  ),
                ])),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => setState(() => data.calculateResult()),
                child: const Text('Calculate'),
              ),
            ),
            if (data.resultSummary != null) ...[
              const SizedBox(height: 16),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(data.resultSummary!),
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