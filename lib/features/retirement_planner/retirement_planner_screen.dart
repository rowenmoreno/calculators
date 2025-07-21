import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/retirement_planner_provider.dart';

class RetirementPlannerScreen extends StatelessWidget {
  const RetirementPlannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RetirementPlannerProvider(),
      child: const _RetirementPlannerView(),
    );
  }
}

class _RetirementPlannerView extends StatelessWidget {
  const _RetirementPlannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RetirementPlannerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirement Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepper(provider),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: _buildStepContent(context, provider),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigation(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(RetirementPlannerProvider provider) {
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
                  backgroundColor: provider.currentStep == i ? Colors.teal : Colors.grey[300],
                  foregroundColor: provider.currentStep == i ? Colors.white : Colors.black,
                  elevation: 0,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => provider.setStep(i),
                child: Text(steps[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, RetirementPlannerProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Your current age (1 to 120)', provider.ageController),
            _buildTextField('Current annual income (\$)', provider.annualIncomeController),
            _buildTextField("Spouse's annual income (if applicable) (\$)", provider.spouseIncomeController),
            _buildTextField('Current retirement savings balance (\$)', provider.savingsController),
            _buildTextField('Desired retirement age (1 to 120)', provider.retirementAgeController),
            _buildTextField('Number of years of retirement income (1 to 40)', provider.yearsOfRetirementController),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Expected inflation (0% to 10%)', provider.inflationController),
            _buildTextField('Income replacement at retirement (0% to 300%)', provider.incomeReplacementController),
            _buildTextField('Pre-retirement investment return (-12% to 12%)', provider.preRetReturnController),
            _buildTextField('Post-retirement investment return (-12% to 12%)', provider.postRetReturnController),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown('Include Social Security (SS) benefits?', provider.includeSS, ['No', 'Yes'], provider.setIncludeSS),
            _buildDropdown('Marital status (For SS purposes only)', provider.maritalStatus, provider.maritalStatusOptions, provider.setMaritalStatus, enabled: provider.includeSS == 'Yes'),
            _buildTextField('Social Security override amount (monthly amount in today\'s dollars) (\$)', provider.ssOverrideController, enabled: provider.includeSS == 'Yes'),
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

  Widget _buildNavigation(BuildContext context, RetirementPlannerProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (provider.currentStep > 0)
          ElevatedButton(
            onPressed: provider.prevStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Previous'),
          ),
        if (provider.currentStep < 2)
          ElevatedButton(
            onPressed: provider.nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Next'),
          ),
        if (provider.currentStep == 2)
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