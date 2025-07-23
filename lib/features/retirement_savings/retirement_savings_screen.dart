import 'package:flutter/material.dart';

class RetirementSavingsData {
  int currentStep = 0;
  final TextEditingController ageController = TextEditingController();
  final TextEditingController annualIncomeController = TextEditingController();
  final TextEditingController spouseIncomeController = TextEditingController();
  final TextEditingController savingsBalanceController = TextEditingController();
  final TextEditingController annualSavingsController = TextEditingController();
  final TextEditingController annualSavingsIncreaseController = TextEditingController();
  final TextEditingController pensionBenefitController = TextEditingController();
  final TextEditingController inflationController = TextEditingController();
  final TextEditingController retirementAgeController = TextEditingController();
  final TextEditingController yearsOfRetirementController = TextEditingController();
  final TextEditingController incomeReplacementController = TextEditingController();
  final TextEditingController preRetReturnController = TextEditingController();
  final TextEditingController postRetReturnController = TextEditingController();
  final TextEditingController ssOverrideController = TextEditingController();
  
  String pensionInflation = 'No';
  String includeSS = 'No';
  String maritalStatus = 'Single';
  final List<String> yesNoOptions = ['Yes', 'No'];
  final List<String> maritalStatusOptions = ['Single', 'Married'];

  void setStep(int step) {
    if (step >= 0 && step <= 3) {
      currentStep = step;
    }
  }

  void nextStep() {
    if (currentStep < 3) {
      currentStep++;
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
    }
  }

  void setPensionInflation(String value) {
    pensionInflation = value;
  }

  void setIncludeSS(String value) {
    includeSS = value;
  }

  void setMaritalStatus(String value) {
    maritalStatus = value;
  }

  void dispose() {
    ageController.dispose();
    annualIncomeController.dispose();
    spouseIncomeController.dispose();
    savingsBalanceController.dispose();
    annualSavingsController.dispose();
    annualSavingsIncreaseController.dispose();
    pensionBenefitController.dispose();
    inflationController.dispose();
    retirementAgeController.dispose();
    yearsOfRetirementController.dispose();
    incomeReplacementController.dispose();
    preRetReturnController.dispose();
    postRetReturnController.dispose();
    ssOverrideController.dispose();
  }
}

class RetirementSavingsScreen extends StatefulWidget {
  const RetirementSavingsScreen({Key? key}) : super(key: key);

  @override
  State<RetirementSavingsScreen> createState() => _RetirementSavingsScreenState();
}

class _RetirementSavingsScreenState extends State<RetirementSavingsScreen> {
  final data = RetirementSavingsData();

  @override
  void dispose() {
    data.dispose();
    super.dispose();
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
                  backgroundColor: data.currentStep == i ? Colors.teal : Colors.grey[300],
                  foregroundColor: data.currentStep == i ? Colors.white : Colors.black,
                  elevation: 0,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => setState(() => data.setStep(i)),
                child: Text(steps[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (data.currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Your current age (1 to 120)', data.ageController),
            _buildTextField('Current annual income (\$)', data.annualIncomeController),
            _buildTextField("Spouse's annual income (if applicable) (\$)", data.spouseIncomeController),
            _buildTextField('Current retirement savings balance (\$)', data.savingsBalanceController),
            _buildTextField('Current annual savings amount (\$ or percent of income)', data.annualSavingsController),
            _buildTextField('Current annual savings increases (0% to 10%)', data.annualSavingsIncreaseController),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Annual pension benefit at retirement (\$)', data.pensionBenefitController),
            _buildDropdown('Pension increases with inflation?', data.pensionInflation, data.yesNoOptions, (val) => setState(() => data.setPensionInflation(val))),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Expected inflation (0% to 10%)', data.inflationController),
            _buildTextField('Desired retirement age (1 to 120)', data.retirementAgeController),
            _buildTextField('Number of years of retirement income (1 to 40)', data.yearsOfRetirementController),
            _buildTextField('Income replacement at retirement (0% to 300%)', data.incomeReplacementController),
            _buildTextField('Pre-retirement investment return (-12% to 12%)', data.preRetReturnController),
            _buildTextField('Post-retirement investment return (-12% to 12%)', data.postRetReturnController),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown('Include Social Security benefits?', data.includeSS, data.yesNoOptions, (val) => setState(() => data.setIncludeSS(val))),
            _buildDropdown('Marital status', data.maritalStatus, data.maritalStatusOptions, (val) => setState(() => data.setMaritalStatus(val)), enabled: data.includeSS == 'Yes'),
            _buildTextField('Social Security override amount (monthly amount in today\'s dollars) (\$)', data.ssOverrideController, enabled: data.includeSS == 'Yes'),
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
        if (data.currentStep > 0)
          ElevatedButton(
            onPressed: () => setState(() => data.prevStep()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Previous'),
          ),
        if (data.currentStep < 3)
          ElevatedButton(
            onPressed: () => setState(() => data.nextStep()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Next'),
          ),
        if (data.currentStep == 3)
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