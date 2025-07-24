import 'package:flutter/material.dart';
import 'dart:math' show pow;

class SocialSecurityScreen extends StatefulWidget {
  const SocialSecurityScreen({Key? key}) : super(key: key);

  @override
  State<SocialSecurityScreen> createState() => _SocialSecurityScreenState();
}

class _SocialSecurityScreenState extends State<SocialSecurityScreen> {
  // Controllers
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _retirementAgeController = TextEditingController();
  final TextEditingController _spouseIncomeController = TextEditingController();
  final TextEditingController _spouseAgeController = TextEditingController();
  final TextEditingController _spouseRetirementAgeController = TextEditingController();
  final TextEditingController _inflationController = TextEditingController();

  // State variables
  int _currentStep = 0;
  String? _resultSummary;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupControllerListeners();
  }

  void _initializeControllers() {
    _incomeController.text = '0';
    _ageController.text = '0';
    _retirementAgeController.text = '62';
    _spouseIncomeController.text = '0';
    _spouseAgeController.text = '0';
    _spouseRetirementAgeController.text = '62';
    _inflationController.text = '0';
  }

  void _setupControllerListeners() {
    _incomeController.addListener(_calculateResult);
    _ageController.addListener(_calculateResult);
    _retirementAgeController.addListener(_calculateResult);
    _spouseIncomeController.addListener(_calculateResult);
    _spouseAgeController.addListener(_calculateResult);
    _spouseRetirementAgeController.addListener(_calculateResult);
    _inflationController.addListener(_calculateResult);
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _ageController.dispose();
    _retirementAgeController.dispose();
    _spouseIncomeController.dispose();
    _spouseAgeController.dispose();
    _spouseRetirementAgeController.dispose();
    _inflationController.dispose();
    super.dispose();
  }

  void _calculateResult() {
    if (_currentStep != 2) return;

    try {
      final income = double.parse(_incomeController.text);
      final age = int.parse(_ageController.text);
      final retirementAge = int.parse(_retirementAgeController.text);
      final spouseIncome = double.parse(_spouseIncomeController.text);
      final spouseAge = int.parse(_spouseAgeController.text);
      final spouseRetirementAge = int.parse(_spouseRetirementAgeController.text);
      final inflation = double.parse(_inflationController.text) / 100;

      if (!_isInputValid(income, age, retirementAge, spouseIncome, spouseAge, spouseRetirementAge, inflation)) {
        setState(() {
          _resultSummary = 'Please check your input values.\n'
              'Age: 0-120\n'
              'Retirement Age: 62-70\n'
              'Inflation: 0-10%';
        });
        return;
      }

      // Calculate primary insurance amount (PIA)
      final pia = _calculatePIA(income);
      double monthlyBenefit = pia;
      
      // Adjust for early or late retirement
      monthlyBenefit *= _calculateRetirementFactor(retirementAge);

      // Calculate spouse's benefit
      double spousePIA = 0;
      double spouseMonthlyBenefit = 0;
      if (spouseIncome > 0) {
        spousePIA = _calculatePIA(spouseIncome);
        spouseMonthlyBenefit = spousePIA * _calculateRetirementFactor(spouseRetirementAge);
        
        // Spousal benefit is the greater of their own benefit or 50% of their spouse's PIA
        final spousalBenefit = pia * 0.5 * _calculateRetirementFactor(spouseRetirementAge);
        spouseMonthlyBenefit = spouseMonthlyBenefit > spousalBenefit ? spouseMonthlyBenefit : spousalBenefit;
      }

      setState(() {
        _resultSummary = _formatResults(
          monthlyBenefit: monthlyBenefit,
          spouseMonthlyBenefit: spouseMonthlyBenefit,
          retirementAge: retirementAge,
          spouseRetirementAge: spouseRetirementAge,
          inflation: inflation
        );
      });
    } catch (e) {
      setState(() {
        _resultSummary = 'Error in calculations. Please check your input values.';
      });
    }
  }

  bool _isInputValid(
    double income,
    int age,
    int retirementAge,
    double spouseIncome,
    int spouseAge,
    int spouseRetirementAge,
    double inflation,
  ) {
    return age >= 0 && age <= 120 &&
        retirementAge >= 62 && retirementAge <= 70 &&
        (spouseAge == 0 || (spouseAge >= 0 && spouseAge <= 120)) &&
        (spouseRetirementAge == 62 || (spouseRetirementAge >= 62 && spouseRetirementAge <= 70)) &&
        inflation >= 0 && inflation <= 0.10;
  }

  double _calculatePIA(double income) {
    // This is a simplified calculation of Primary Insurance Amount (PIA)
    // Real calculation involves indexing earnings and using bend points
    final aime = income / 12;  // Average Indexed Monthly Earnings
    double pia = 0;

    if (aime <= 1115) {
      pia = aime * 0.90;
    } else if (aime <= 6721) {
      pia = (1115 * 0.90) + ((aime - 1115) * 0.32);
    } else {
      pia = (1115 * 0.90) + ((6721 - 1115) * 0.32) + ((aime - 6721) * 0.15);
    }

    return pia;
  }

  double _calculateRetirementFactor(int retirementAge) {
    // Factors for retirement age adjustment
    const normalRetirementAge = 67;
    
    if (retirementAge == normalRetirementAge) {
      return 1.0;
    } else if (retirementAge < normalRetirementAge) {
      // Reduction for early retirement (approximately 6.67% per year)
      return 1.0 - ((normalRetirementAge - retirementAge) * 0.0667);
    } else {
      // Increase for delayed retirement (8% per year)
      return 1.0 + ((retirementAge - normalRetirementAge) * 0.08);
    }
  }

  String _formatResults({
    required double monthlyBenefit,
    required double spouseMonthlyBenefit,
    required int retirementAge,
    required int spouseRetirementAge,
    required double inflation,
  }) {
    final yearlyInflationFactor = 1 + inflation;
    
    return '''Social Security Benefit Estimate:

Your monthly benefit at age $retirementAge: \${_formatCurrency(monthlyBenefit)}
${spouseMonthlyBenefit > 0 ? "Spouse's monthly benefit at age $spouseRetirementAge: \${_formatCurrency(spouseMonthlyBenefit)}\n" : ""}
Combined monthly benefit: \${_formatCurrency(monthlyBenefit + spouseMonthlyBenefit)}

Estimated future values (with $inflation% annual inflation):
After 5 years: \${_formatCurrency((monthlyBenefit + spouseMonthlyBenefit) * pow(yearlyInflationFactor, 5))}
After 10 years: \${_formatCurrency((monthlyBenefit + spouseMonthlyBenefit) * pow(yearlyInflationFactor, 10))}
After 20 years: \${_formatCurrency((monthlyBenefit + spouseMonthlyBenefit) * pow(yearlyInflationFactor, 20))}

Note: These are estimates based on current rules and simplified calculations.
Please consult the Social Security Administration for official benefit calculations.''';
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
        title: const Text('Social Security Calculator'),
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
            if (_resultSummary != null) ...[
              const SizedBox(height: 24),
              Text(
                _resultSummary!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final steps = ['Your Information', 'Spouse Information (if applicable)', 'Common Assumptions'];
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
                  _calculateResult();
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
            _buildTextField('Average annual earned income (\$)', _incomeController),
            _buildTextField('Current age (0 to 120)', _ageController),
            _buildTextField('Social Security retirement age (62 to 70)', _retirementAgeController),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Average annual earned income (\$)', _spouseIncomeController),
            _buildTextField('Current age (0 to 120)', _spouseAgeController),
            _buildTextField('Social Security retirement age (62 to 70)', _spouseRetirementAgeController),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Social Security inflation rate (0% to 10%)', _inflationController),
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
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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
              _calculateResult();
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
              _calculateResult();
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
            onPressed: () => setState(() => _calculateResult()),
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