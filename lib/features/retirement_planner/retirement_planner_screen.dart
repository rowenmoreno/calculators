import 'package:flutter/material.dart';
import 'dart:math' show pow, min;

class RetirementPlannerScreen extends StatefulWidget {
  const RetirementPlannerScreen({Key? key}) : super(key: key);

  @override
  State<RetirementPlannerScreen> createState() => _RetirementPlannerScreenState();
}

class _RetirementPlannerScreenState extends State<RetirementPlannerScreen> {
  // Constants
  static const List<String> maritalStatusOptions = ['Single', 'Married'];

  // Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _annualIncomeController = TextEditingController();
  final TextEditingController _spouseIncomeController = TextEditingController();
  final TextEditingController _savingsController = TextEditingController();
  final TextEditingController _retirementAgeController = TextEditingController();
  final TextEditingController _yearsOfRetirementController = TextEditingController();
  final TextEditingController _inflationController = TextEditingController();
  final TextEditingController _incomeReplacementController = TextEditingController();
  final TextEditingController _preRetReturnController = TextEditingController();
  final TextEditingController _postRetReturnController = TextEditingController();
  final TextEditingController _ssOverrideController = TextEditingController();

  // State variables
  int _currentStep = 0;
  String _includeSS = 'No';
  String _maritalStatus = 'Single';
  String? _resultSummary;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupControllerListeners();
  }

  void _initializeControllers() {
    _ageController.text = '0';
    _annualIncomeController.text = '0';
    _spouseIncomeController.text = '0';
    _savingsController.text = '0';
    _retirementAgeController.text = '0';
    _yearsOfRetirementController.text = '0';
    _inflationController.text = '0';
    _incomeReplacementController.text = '0';
    _preRetReturnController.text = '0';
    _postRetReturnController.text = '0';
    _ssOverrideController.text = '0';
  }

  void _setupControllerListeners() {
    // Add listeners to update calculations when text changes
    _ageController.addListener(_calculateResult);
    _annualIncomeController.addListener(_calculateResult);
    _spouseIncomeController.addListener(_calculateResult);
    _savingsController.addListener(_calculateResult);
    _retirementAgeController.addListener(_calculateResult);
    _yearsOfRetirementController.addListener(_calculateResult);
    _inflationController.addListener(_calculateResult);
    _incomeReplacementController.addListener(_calculateResult);
    _preRetReturnController.addListener(_calculateResult);
    _postRetReturnController.addListener(_calculateResult);
    _ssOverrideController.addListener(_calculateResult);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _annualIncomeController.dispose();
    _spouseIncomeController.dispose();
    _savingsController.dispose();
    _retirementAgeController.dispose();
    _yearsOfRetirementController.dispose();
    _inflationController.dispose();
    _incomeReplacementController.dispose();
    _preRetReturnController.dispose();
    _postRetReturnController.dispose();
    _ssOverrideController.dispose();
    super.dispose();
  }

  void _setIncludeSS(String val) {
    setState(() {
      _includeSS = val;
      _resultSummary = null;
      _calculateResult();
    });
  }

  void _setMaritalStatus(String val) {
    setState(() {
      _maritalStatus = val;
      _resultSummary = null;
      _calculateResult();
    });
  }

  void _calculateResult() {
    if (_currentStep != 2) return;

    try {
      final age = int.parse(_ageController.text);
      final income = double.parse(_annualIncomeController.text);
      final spouseIncome = double.parse(_spouseIncomeController.text);
      final savings = double.parse(_savingsController.text);
      final retirementAge = int.parse(_retirementAgeController.text);
      final yearsOfRetirement = int.parse(_yearsOfRetirementController.text);
      final inflation = double.parse(_inflationController.text) / 100;
      final incomeReplacement = double.parse(_incomeReplacementController.text) / 100;
      final preRetReturn = double.parse(_preRetReturnController.text) / 100;
      final postRetReturn = double.parse(_postRetReturnController.text) / 100;
      final ssOverride = double.parse(_ssOverrideController.text);

      if (!_isInputValid(age, income, spouseIncome, savings, retirementAge, yearsOfRetirement,
          inflation, incomeReplacement, preRetReturn, postRetReturn)) {
        setState(() {
          _resultSummary = 'Please check your input values.\n'
              'Age: 1-120\n'
              'Retirement Age: 1-120\n'
              'Years of Retirement: 1-40\n'
              'Inflation: 0-10%\n'
              'Income Replacement: 0-300%\n'
              'Investment Returns: -12% to 12%';
        });
        return;
      }

      final yearsToRetirement = retirementAge - age;
      final totalIncome = income + spouseIncome;
      final targetIncome = totalIncome * incomeReplacement;
      
      // Calculate future value of current savings
      final futureValueSavings = savings * pow(1 + preRetReturn, yearsToRetirement);
      
      // Calculate total needed at retirement
      final retirementNeed = targetIncome * (1 - pow(1 + postRetReturn - inflation, -yearsOfRetirement)) /
          (postRetReturn - inflation);
      
      // Calculate monthly social security benefit if included
      double monthlySSBenefit = 0;
      if (_includeSS == 'Yes') {
        monthlySSBenefit = ssOverride > 0 ? ssOverride : _estimateSSBenefit(totalIncome);
      }
      
      final annualSSBenefit = monthlySSBenefit * 12;
      final inflatedSSBenefit = annualSSBenefit * pow(1 + inflation, yearsToRetirement);
      
      // Adjust retirement need for social security
      final adjustedRetirementNeed = retirementNeed - (inflatedSSBenefit / (postRetReturn - inflation)) *
          (1 - pow(1 + postRetReturn - inflation, -yearsOfRetirement));
      
      // Calculate required monthly savings
      final requiredSavings = (adjustedRetirementNeed - futureValueSavings) *
          (preRetReturn) /
          (pow(1 + preRetReturn, yearsToRetirement) - 1) /
          12;

      setState(() {
        _resultSummary = _formatResults(
          targetIncome,
          retirementNeed,
          adjustedRetirementNeed,
          futureValueSavings,
          monthlySSBenefit,
          requiredSavings,
        );
      });
    } catch (e) {
      setState(() {
        _resultSummary = 'Error in calculations. Please check your input values.';
      });
    }
  }

  bool _isInputValid(
    int age,
    double income,
    double spouseIncome,
    double savings,
    int retirementAge,
    int yearsOfRetirement,
    double inflation,
    double incomeReplacement,
    double preRetReturn,
    double postRetReturn,
  ) {
    return age >= 1 && age <= 120 &&
        income >= 0 &&
        spouseIncome >= 0 &&
        savings >= 0 &&
        retirementAge >= 1 && retirementAge <= 120 &&
        yearsOfRetirement >= 1 && yearsOfRetirement <= 40 &&
        inflation >= 0 && inflation <= 0.10 &&
        incomeReplacement >= 0 && incomeReplacement <= 3.0 &&
        preRetReturn >= -0.12 && preRetReturn <= 0.12 &&
        postRetReturn >= -0.12 && postRetReturn <= 0.12;
  }

  double _estimateSSBenefit(double income) {
    // Simplified Social Security benefit estimation
    // This is a very rough approximation
    final pia = min(income * 0.4, 3000.0);
    return _maritalStatus == 'Married' ? pia * 1.5 : pia;
  }

  String _formatResults(
    double targetIncome,
    double retirementNeed,
    double adjustedRetirementNeed,
    double futureValueSavings,
    double monthlySSBenefit,
    double requiredSavings,
  ) {
    return '''Retirement Planning Results:

Target Annual Income: \${_formatCurrency(targetIncome)}
Total Retirement Need: \${_formatCurrency(retirementNeed)}
Adjusted Need (with SS): \${_formatCurrency(adjustedRetirementNeed)}
Future Value of Current Savings: \${_formatCurrency(futureValueSavings)}
Estimated Monthly SS Benefit: \${_formatCurrency(monthlySSBenefit)}
Required Monthly Savings: \${_formatCurrency(requiredSavings)}

Note: These calculations are estimates based on your inputs.
Please consult a financial advisor for personalized advice.''';
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '\${m[1]},',
        );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirement Planner'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavigation(context),
            const SizedBox(height: 16),
            _buildStepContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final steps = ['Income/Savings', 'Assumptions', 'Social Security'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStep == i ? Colors.teal : Colors.grey[300],
                  foregroundColor: _currentStep == i ? Colors.white : Colors.black,
                  elevation: 0,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => setState(() {
                  _currentStep = i;
                  _resultSummary = null;
                }),
                child: Text(steps[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Your current age (1 to 120)', _ageController),
            _buildTextField('Current annual income (\$)', _annualIncomeController),
            _buildTextField("Spouse's annual income (if applicable) (\$)", _spouseIncomeController),
            _buildTextField('Current retirement savings balance (\$)', _savingsController),
            _buildTextField('Desired retirement age (1 to 120)', _retirementAgeController),
            _buildTextField('Number of years of retirement income (1 to 40)', _yearsOfRetirementController),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Expected inflation (0% to 10%)', _inflationController),
            _buildTextField('Income replacement at retirement (0% to 300%)', _incomeReplacementController),
            _buildTextField('Pre-retirement investment return (-12% to 12%)', _preRetReturnController),
            _buildTextField('Post-retirement investment return (-12% to 12%)', _postRetReturnController),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown('Include Social Security (SS) benefits?', _includeSS, ['No', 'Yes'], _setIncludeSS),
            _buildDropdown('Marital status (For SS purposes only)', _maritalStatus, maritalStatusOptions, _setMaritalStatus, enabled: _includeSS == 'Yes'),
            _buildTextField('Social Security override amount (monthly amount in today\'s dollars) (\$)', _ssOverrideController, enabled: _includeSS == 'Yes'),
            if (_resultSummary != null) ...[
              const SizedBox(height: 16),
              Text(
                _resultSummary!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, void Function(String) onChanged, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
            onChanged: enabled ? (val) { if (val != null) onChanged(val); } : null,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          ElevatedButton(
            onPressed: () => setState(() {
              _currentStep--;
              _resultSummary = null;
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Previous'),
          ),
        if (_currentStep < 2)
          ElevatedButton(
            onPressed: () => setState(() {
              _currentStep++;
              _resultSummary = null;
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Next'),
          ),
        if (_currentStep == 2)
          ElevatedButton(
            onPressed: () {
              // TODO: Implement calculation and result display
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Calculate'),
          ),
      ],
    );
  }
} 