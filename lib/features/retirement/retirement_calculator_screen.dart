import 'package:flutter/material.dart';

class RetirementCalculatorScreen extends StatefulWidget {
  const RetirementCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<RetirementCalculatorScreen> createState() => _RetirementCalculatorScreenState();
}

class _RetirementCalculatorScreenState extends State<RetirementCalculatorScreen> {
  // Constants
  static const List<String> incomeFields = [
    'Wages, salary and tips',
    'Alimony, child support (received)',
    'Dividends from stocks, etc.',
    'Interest on savings accounts, CDs, etc.',
    'Social Security benefits',
    'Pensions',
    'Other income'
  ];
  
  static const List<String> expenseFields = [
    'Mortgage payment or rent (\$)',
    'Vacation home (mortgage) (\$)',
    'Automobile loan(s) (\$)',
    'Personal loan(s) (\$)',
    'Charge accounts (\$)',
    'Federal income taxes (\$)',
    'State income taxes (\$)',
    'FICA (Social Security taxes) (\$)',
    'Real estate taxes (\$)',
    'Other taxes (\$)',
    'Utilities (\$)',
    'Household repairs and maintenance (\$)',
    'Food (\$)',
    'Clothing and laundry (\$)',
    'Educational expenses (\$)',
    'Child care (\$)',
    'Automobile expenses (gas, repairs, etc.) (\$)',
    'Other transportation expenses (\$)',
    'Life insurance premiums (\$)',
    'Homeowners (renters) insurance (\$)',
    'Automobile insurance (\$)',
    'Medical, dental and disability insurance (\$)',
    'Entertainment and dining (\$)',
    'Recreation and travel (\$)',
    'Club dues (\$)',
    'Hobbies (\$)',
    'Gifts (\$)',
    'Major home improvements and furnishings (\$)',
    'Professional services (\$)',
    'Charitable contributions (\$)',
    'Other and miscellaneous expenses (\$)'
  ];

  // Controllers
  final Map<String, TextEditingController> _incomeControllers = {};
  final Map<String, TextEditingController> _expenseControllers = {};

  // State variables
  String _figuresType = 'Monthly';
  int _currentStep = 0;
  String? _resultSummary;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var field in incomeFields) {
      _incomeControllers[field + '_pre'] = TextEditingController()..addListener(_calculateResult);
      _incomeControllers[field + '_post'] = TextEditingController()..addListener(_calculateResult);
    }
    for (var field in expenseFields) {
      _expenseControllers[field + '_pre'] = TextEditingController()..addListener(_calculateResult);
      _expenseControllers[field + '_post'] = TextEditingController()..addListener(_calculateResult);
    }
  }

  @override
  void dispose() {
    for (var controller in [..._incomeControllers.values, ..._expenseControllers.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setStep(int step) {
    if (step >= 0 && step <= 2) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _setFiguresType(String type) {
    setState(() {
      _figuresType = type;
      _calculateResult();
    });
  }

  void _calculateResult() {
    if (!mounted) return;
    
    double totalPreIncome = 0;
    double totalPostIncome = 0;
    double totalPreExpenses = 0;
    double totalPostExpenses = 0;

    for (var field in incomeFields) {
      totalPreIncome += double.tryParse(_incomeControllers[field + '_pre']?.text ?? '0') ?? 0;
      totalPostIncome += double.tryParse(_incomeControllers[field + '_post']?.text ?? '0') ?? 0;
    }

    for (var field in expenseFields) {
      totalPreExpenses += double.tryParse(_expenseControllers[field + '_pre']?.text ?? '0') ?? 0;
      totalPostExpenses += double.tryParse(_expenseControllers[field + '_post']?.text ?? '0') ?? 0;
    }

    double preRetirementNet = totalPreIncome - totalPreExpenses;
    double postRetirementNet = totalPostIncome - totalPostExpenses;
    double difference = postRetirementNet - preRetirementNet;

    setState(() {
      _resultSummary = _generateResultMessage(
        totalPreIncome: totalPreIncome,
        totalPostIncome: totalPostIncome,
        totalPreExpenses: totalPreExpenses,
        totalPostExpenses: totalPostExpenses,
        preRetirementNet: preRetirementNet,
        postRetirementNet: postRetirementNet,
        difference: difference,
      );
    });
  }

  String _generateResultMessage({
    required double totalPreIncome,
    required double totalPostIncome,
    required double totalPreExpenses,
    required double totalPostExpenses,
    required double preRetirementNet,
    required double postRetirementNet,
    required double difference,
  }) {
    return 'Based on your input, your income during retirement will remain constant at \$${totalPostIncome.toStringAsFixed(2)}, your expenses will remain constant at \$${totalPostExpenses.toStringAsFixed(2)}, and your net cash flow will remain constant at \$${postRetirementNet.toStringAsFixed(2)}.';
  }

  Widget _buildIncomeExpenseTable({
    required List<String> fields,
    required Map<String, TextEditingController> controllers,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            const TableRow(children: [
              SizedBox(),
              Center(child: Text('Pre-Retirement')),
              Center(child: Text('Post-Retirement')),
            ]),
            ...fields.map((field) => TableRow(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(field),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: controllers[field + '_pre'],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: controllers[field + '_post'],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ])),
          ],
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
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
                  value: _figuresType,
                  items: const [
                    DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'Annual', child: Text('Annual')),
                  ],
                  onChanged: (val) {
                    if (val != null) _setFiguresType(val);
                  },
                ),
              ],
            ),
          ],
        );
      case 1:
        return _buildIncomeExpenseTable(
          fields: incomeFields,
          controllers: _incomeControllers,
          title: 'Itemized Income',
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIncomeExpenseTable(
              fields: expenseFields,
              controllers: _expenseControllers,
              title: 'Itemized Expenses',
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _calculateResult,
                child: const Text('Calculate'),
              ),
            ),
            if (_resultSummary != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(_resultSummary!),
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
                        backgroundColor: _currentStep == i ? Colors.teal : Colors.grey[300],
                        foregroundColor: _currentStep == i ? Colors.white : Colors.black,
                      ),
                      onPressed: () => _setStep(i),
                      child: Text('Part ${i + 1}'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: _buildStepContent())),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: _prevStep,
                    child: const Text('Previous'),
                  ),
                if (_currentStep < 2)
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: const Text('Next'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
