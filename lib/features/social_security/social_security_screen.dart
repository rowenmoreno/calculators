import 'package:flutter/material.dart';

class SocialSecurityData {
  int currentStep = 0;
  String? resultSummary;
  
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController retirementAgeController = TextEditingController();
  final TextEditingController spouseIncomeController = TextEditingController();
  final TextEditingController spouseAgeController = TextEditingController();
  final TextEditingController spouseRetirementAgeController = TextEditingController();
  final TextEditingController inflationController = TextEditingController();

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

  void calculateResult() {
    // TODO: Implement calculation logic
    resultSummary = '''
    Based on your inputs:
    Your monthly benefit: \$${double.tryParse(incomeController.text)?.toStringAsFixed(2) ?? '0.00'}
    Spouse's monthly benefit: \$${double.tryParse(spouseIncomeController.text)?.toStringAsFixed(2) ?? '0.00'}
    ''';
  }

  void dispose() {
    incomeController.dispose();
    ageController.dispose();
    retirementAgeController.dispose();
    spouseIncomeController.dispose();
    spouseAgeController.dispose();
    spouseRetirementAgeController.dispose();
    inflationController.dispose();
  }
}

class SocialSecurityScreen extends StatefulWidget {
  const SocialSecurityScreen({Key? key}) : super(key: key);

  @override
  State<SocialSecurityScreen> createState() => _SocialSecurityScreenState();
}

class _SocialSecurityScreenState extends State<SocialSecurityScreen> {
  final data = SocialSecurityData();

  @override
  void dispose() {
    data.dispose();
    super.dispose();
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
            if (data.resultSummary != null) ...[
              const SizedBox(height: 24),
              Text(
                data.resultSummary!,
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
            _buildTextField('Average annual earned income (\$)', data.incomeController),
            _buildTextField('Current age (0 to 120)', data.ageController),
            _buildTextField('Social Security retirement age (62 to 70)', data.retirementAgeController),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Average annual earned income (\$)', data.spouseIncomeController),
            _buildTextField('Current age (0 to 120)', data.spouseAgeController),
            _buildTextField('Social Security retirement age (62 to 70)', data.spouseRetirementAgeController),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Social Security inflation rate (0% to 10%)', data.inflationController),
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
        if (data.currentStep < 2)
          ElevatedButton(
            onPressed: () => setState(() => data.nextStep()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Next'),
          ),
        if (data.currentStep == 2)
          ElevatedButton(
            onPressed: () => setState(() => data.calculateResult()),
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