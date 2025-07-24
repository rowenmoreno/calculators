import 'package:flutter/material.dart';
import 'dart:math' show pow, min;

class RetirementSavingsScreen extends StatefulWidget {
  const RetirementSavingsScreen({Key? key}) : super(key: key);

  @override
  State<RetirementSavingsScreen> createState() => _RetirementSavingsScreenState();
}

class _RetirementSavingsScreenState extends State<RetirementSavingsScreen> {
  // Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _annualIncomeController = TextEditingController();
  final TextEditingController _spouseIncomeController = TextEditingController();
  final TextEditingController _savingsBalanceController = TextEditingController();
  final TextEditingController _annualSavingsController = TextEditingController();
  final TextEditingController _annualSavingsIncreaseController = TextEditingController();
  final TextEditingController _pensionBenefitController = TextEditingController();
  final TextEditingController _inflationController = TextEditingController();
  final TextEditingController _retirementAgeController = TextEditingController();
  final TextEditingController _yearsOfRetirementController = TextEditingController();
  final TextEditingController _incomeReplacementController = TextEditingController();
  final TextEditingController _preRetReturnController = TextEditingController();
  final TextEditingController _postRetReturnController = TextEditingController();
  final TextEditingController _ssOverrideController = TextEditingController();

  // State variables
  int _currentStep = 0;
  String _pensionInflation = 'No';
  String _includeSS = 'No';
  String _maritalStatus = 'Single';
  String? _resultSummary;

  // Constants
  static const List<String> yesNoOptions = ['Yes', 'No'];
  static const List<String> maritalStatusOptions = ['Single', 'Married'];

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
    _savingsBalanceController.text = '0';
    _annualSavingsController.text = '0';
    _annualSavingsIncreaseController.text = '0';
    _pensionBenefitController.text = '0';
    _inflationController.text = '0';
    _retirementAgeController.text = '0';
    _yearsOfRetirementController.text = '0';
    _incomeReplacementController.text = '0';
    _preRetReturnController.text = '0';
    _postRetReturnController.text = '0';
    _ssOverrideController.text = '0';
  }

  void _setupControllerListeners() {
    _ageController.addListener(_calculateResult);
    _annualIncomeController.addListener(_calculateResult);
    _spouseIncomeController.addListener(_calculateResult);
    _savingsBalanceController.addListener(_calculateResult);
    _annualSavingsController.addListener(_calculateResult);
    _annualSavingsIncreaseController.addListener(_calculateResult);
    _pensionBenefitController.addListener(_calculateResult);
    _inflationController.addListener(_calculateResult);
    _retirementAgeController.addListener(_calculateResult);
    _yearsOfRetirementController.addListener(_calculateResult);
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
    _savingsBalanceController.dispose();
    _annualSavingsController.dispose();
    _annualSavingsIncreaseController.dispose();
    _pensionBenefitController.dispose();
    _inflationController.dispose();
    _retirementAgeController.dispose();
    _yearsOfRetirementController.dispose();
    _incomeReplacementController.dispose();
    _preRetReturnController.dispose();
    _postRetReturnController.dispose();
    _ssOverrideController.dispose();
    super.dispose();
  }

  void _setPensionInflation(String value) {
    setState(() {
      _pensionInflation = value;
      _calculateResult();
    });
  }

  void _setIncludeSS(String value) {
    setState(() {
      _includeSS = value;
      _calculateResult();
    });
  }

  void _setMaritalStatus(String value) {
    setState(() {
      _maritalStatus = value;
      _calculateResult();
    });
  }

  void _calculateResult() {
    if (_currentStep != 3) return;

    try {
      final age = int.parse(_ageController.text);
      final annualIncome = double.parse(_annualIncomeController.text);
      final spouseIncome = double.parse(_spouseIncomeController.text);
      final savingsBalance = double.parse(_savingsBalanceController.text);
      final annualSavings = double.parse(_annualSavingsController.text);
      final annualSavingsIncrease = double.parse(_annualSavingsIncreaseController.text) / 100;
      final pensionBenefit = double.parse(_pensionBenefitController.text);
      final inflation = double.parse(_inflationController.text) / 100;
      final retirementAge = int.parse(_retirementAgeController.text);
      final yearsOfRetirement = int.parse(_yearsOfRetirementController.text);
      final incomeReplacement = double.parse(_incomeReplacementController.text) / 100;
      final preRetReturn = double.parse(_preRetReturnController.text) / 100;
      final postRetReturn = double.parse(_postRetReturnController.text) / 100;
      final ssOverride = double.parse(_ssOverrideController.text);

      if (!_isInputValid(age, annualIncome, spouseIncome, savingsBalance, annualSavings, annualSavingsIncrease,
          pensionBenefit, inflation, retirementAge, yearsOfRetirement, incomeReplacement, preRetReturn, postRetReturn)) {
        setState(() {
          _resultSummary = 'Please check your input values.\n'
              'Age: 1-120\n'
              'Retirement Age: 1-120\n'
              'Years of Retirement: 1-40\n'
              'Annual Savings Increase: 0-10%\n'
              'Inflation: 0-10%\n'
              'Income Replacement: 0-300%\n'
              'Investment Returns: -12% to 12%';
        });
        return;
      }

      // Calculate retirement savings
      final yearsToRetirement = retirementAge - age;
      final totalIncome = annualIncome + spouseIncome;
      final targetIncome = totalIncome * incomeReplacement;
      
      // Calculate future value of current savings and future contributions
      double futureValueSavings = savingsBalance * pow(1 + preRetReturn, yearsToRetirement);
      double futureValueContributions = 0;
      
      // Calculate future value of annual savings with increases
      for (int i = 0; i < yearsToRetirement; i++) {
        final savingsForYear = annualSavings * pow(1 + annualSavingsIncrease, i);
        futureValueContributions += savingsForYear * pow(1 + preRetReturn, yearsToRetirement - i);
      }
      
      // Calculate pension value
      double pensionValue = pensionBenefit * 12;
      if (_pensionInflation == 'Yes') {
        pensionValue = pensionValue * pow(1 + inflation, yearsToRetirement);
      }
      
      // Calculate social security benefit
      double monthlySSBenefit = 0;
      if (_includeSS == 'Yes') {
        monthlySSBenefit = ssOverride > 0 ? ssOverride : _estimateSSBenefit(totalIncome);
      }
      
      final annualSSBenefit = monthlySSBenefit * 12;
      final inflatedSSBenefit = annualSSBenefit * pow(1 + inflation, yearsToRetirement);
      
      // Calculate total retirement need
      final totalFutureValue = futureValueSavings + futureValueContributions;
      final annualNeed = targetIncome - pensionValue - inflatedSSBenefit;
      final retirementNeed = annualNeed * (1 - pow(1 + postRetReturn - inflation, -yearsOfRetirement)) /
          (postRetReturn - inflation);
      
      setState(() {
        _resultSummary = _formatResults(
          targetIncome: targetIncome,
          totalFutureValue: totalFutureValue,
          annualNeed: annualNeed,
          retirementNeed: retirementNeed,
          monthlySSBenefit: monthlySSBenefit,
          pensionValue: pensionValue,
          futureValueSavings: futureValueSavings,
          futureValueContributions: futureValueContributions,
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
    double annualIncome,
    double spouseIncome,
    double savingsBalance,
    double annualSavings,
    double annualSavingsIncrease,
    double pensionBenefit,
    double inflation,
    int retirementAge,
    int yearsOfRetirement,
    double incomeReplacement,
    double preRetReturn,
    double postRetReturn,
  ) {
    return age >= 1 && age <= 120 &&
        annualIncome >= 0 &&
        spouseIncome >= 0 &&
        savingsBalance >= 0 &&
        annualSavings >= 0 &&
        annualSavingsIncrease >= 0 && annualSavingsIncrease <= 0.10 &&
        pensionBenefit >= 0 &&
        inflation >= 0 && inflation <= 0.10 &&
        retirementAge >= 1 && retirementAge <= 120 &&
        yearsOfRetirement >= 1 && yearsOfRetirement <= 40 &&
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

  String _formatResults({
    required double targetIncome,
    required double totalFutureValue,
    required double annualNeed,
    required double retirementNeed,
    required double monthlySSBenefit,
    required double pensionValue,
    required double futureValueSavings,
    required double futureValueContributions,
  }) {
    return '''Retirement Planning Results:

Target Annual Income: \${_formatCurrency(targetIncome)}
Total Future Value of Savings: \${_formatCurrency(totalFutureValue)}
  - From Current Savings: \${_formatCurrency(futureValueSavings)}
  - From Future Contributions: \${_formatCurrency(futureValueContributions)}
Annual Need in Retirement: \${_formatCurrency(annualNeed)}
Total Retirement Need: \${_formatCurrency(retirementNeed)}
Annual Pension Benefit: \${_formatCurrency(pensionValue)}
Monthly Social Security Benefit: \${_formatCurrency(monthlySSBenefit)}

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
        title: const Text('Retirement Savings Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepper(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: _buildStepContent(context),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final steps = ['Income/Savings', 'Pension', 'Assumptions', 'Social Security'];
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
                  if (i == 3) _calculateResult();
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
            _buildTextField('Current retirement savings balance (\$)', _savingsBalanceController),
            _buildTextField('Current annual savings amount (\$ or percent of income)', _annualSavingsController),
            _buildTextField('Current annual savings increases (0% to 10%)', _annualSavingsIncreaseController),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Annual pension benefit at retirement (\$)', _pensionBenefitController),
            _buildDropdown('Pension increases with inflation?', _pensionInflation, yesNoOptions, _setPensionInflation),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Expected inflation (0% to 10%)', _inflationController),
            _buildTextField('Desired retirement age (1 to 120)', _retirementAgeController),
            _buildTextField('Number of years of retirement income (1 to 40)', _yearsOfRetirementController),
            _buildTextField('Income replacement at retirement (0% to 300%)', _incomeReplacementController),
            _buildTextField('Pre-retirement investment return (-12% to 12%)', _preRetReturnController),
            _buildTextField('Post-retirement investment return (-12% to 12%)', _postRetReturnController),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown('Include Social Security benefits?', _includeSS, yesNoOptions, _setIncludeSS),
            _buildDropdown('Marital status', _maritalStatus, maritalStatusOptions, _setMaritalStatus, enabled: _includeSS == 'Yes'),
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
        keyboardType: TextInputType.text,
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
              if (_currentStep == 3) _calculateResult();
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Previous'),
          ),
        if (_currentStep < 3)
          ElevatedButton(
            onPressed: () => setState(() {
              _currentStep++;
              if (_currentStep == 3) _calculateResult();
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Next'),
          ),
        if (_currentStep == 3)
          ElevatedButton(
            onPressed: _calculateResult,
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