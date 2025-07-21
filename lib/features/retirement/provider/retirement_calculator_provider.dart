import 'package:flutter/material.dart';

class RetirementCalculatorProvider extends ChangeNotifier {
  int currentStep = 0;
  String figuresType = 'Monthly';
  final Map<String, TextEditingController> incomeControllers = {};
  final Map<String, TextEditingController> expenseControllers = {};
  String? resultSummary;

  final List<String> incomeFields = [
    'Wages, salary and tips ( 24)',
    'Alimony, child support (received) ( 24)',
    'Dividends from stocks, etc. ( 24)',
    'Interest on savings accounts, CDs, etc. ( 24)',
    'Social Security benefits ( 24)',
    'Pensions ( 24)',
    'Other income ( 24)',
  ];
  final List<String> expenseFields = [
    'Mortgage payment or rent ( 24)',
    'Vacation home (mortgage) ( 24)',
    'Automobile loan(s) ( 24)',
    'Personal loan(s) ( 24)',
    'Charge accounts ( 24)',
    'Federal income taxes ( 24)',
    'State income taxes ( 24)',
    'FICA (Social Security taxes) ( 24)',
    'Real estate taxes ( 24)',
    'Other taxes ( 24)',
    'Utilities ( 24)',
    'Household repairs and maintenance ( 24)',
    'Food ( 24)',
    'Clothing and laundry ( 24)',
    'Educational expenses ( 24)',
    'Child care ( 24)',
    'Automobile expenses (gas, repairs, etc.) ( 24)',
    'Other transportation expenses ( 24)',
    'Life insurance premiums ( 24)',
    'Homeowners (renters) insurance ( 24)',
    'Automobile insurance ( 24)',
    'Medical, dental and disability insurance ( 24)',
    'Entertainment and dining ( 24)',
    'Recreation and travel ( 24)',
    'Club dues ( 24)',
    'Hobbies ( 24)',
    'Gifts ( 24)',
    'Major home improvements and furnishings ( 24)',
    'Professional services ( 24)',
    'Charitable contributions ( 24)',
    'Other and miscellaneous expenses ( 24)',
  ];

  RetirementCalculatorProvider() {
    for (var field in incomeFields) {
      incomeControllers[field + '_pre'] = TextEditingController();
      incomeControllers[field + '_post'] = TextEditingController();
    }
    for (var field in expenseFields) {
      expenseControllers[field + '_pre'] = TextEditingController();
      expenseControllers[field + '_post'] = TextEditingController();
    }
  }

  void setStep(int step) {
    currentStep = step;
    notifyListeners();
  }

  void setFiguresType(String type) {
    figuresType = type;
    notifyListeners();
  }

  void nextStep() {
    if (currentStep < 2) {
      currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  void calculateResult() {
    double preIncome = 0;
    double postIncome = 0;
    double preExpenses = 0;
    double postExpenses = 0;
    for (var field in incomeFields) {
      preIncome += double.tryParse(incomeControllers[field + '_pre']?.text ?? '0') ?? 0;
      postIncome += double.tryParse(incomeControllers[field + '_post']?.text ?? '0') ?? 0;
    }
    for (var field in expenseFields) {
      preExpenses += double.tryParse(expenseControllers[field + '_pre']?.text ?? '0') ?? 0;
      postExpenses += double.tryParse(expenseControllers[field + '_post']?.text ?? '0') ?? 0;
    }
    double preNet = preIncome - preExpenses;
    double postNet = postIncome - postExpenses;

    String incomeStr = _describeChange('income during retirement', preIncome, postIncome);
    String expenseStr = _describeChange('expenses', preExpenses, postExpenses);
    String netStr = _describeChange('net cash flow', preNet, postNet);

    resultSummary =
        'Based on your input, your $incomeStr, your $expenseStr, and your $netStr.';
    notifyListeners();
  }

  String _describeChange(String label, double pre, double post) {
    String preStr = _formatCurrency(pre);
    String postStr = _formatCurrency(post);
    if ((pre - post).abs() < 0.01) {
      return '$label will remain constant at $preStr';
    } else if (post > pre) {
      return '$label will increase from $preStr to $postStr';
    } else {
      return '$label will decrease from $preStr to $postStr';
    }
  }

  String _formatCurrency(double value) {
    if (value % 1 == 0) {
      return ' 4${value.toStringAsFixed(0)}';
    } else {
      return ' 4${value.toStringAsFixed(2)}';
    }
  }

  @override
  void dispose() {
    for (var c in incomeControllers.values) {
      c.dispose();
    }
    for (var c in expenseControllers.values) {
      c.dispose();
    }
    super.dispose();
  }
} 