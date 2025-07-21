import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/social_security_provider.dart';

class SocialSecurityScreen extends StatelessWidget {
  const SocialSecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SocialSecurityProvider(),
      child: const _SocialSecurityView(),
    );
  }
}

class _SocialSecurityView extends StatelessWidget {
  const _SocialSecurityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SocialSecurityProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Security Calculator'),
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
            if (provider.resultSummary != null) ...[
              const SizedBox(height: 24),
              Text(
                provider.resultSummary!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(SocialSecurityProvider provider) {
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

  Widget _buildStepContent(BuildContext context, SocialSecurityProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Average annual earned income (\$)', provider.incomeController),
            _buildTextField('Current age (0 to 120)', provider.ageController),
            _buildTextField('Social Security retirement age (62 to 70)', provider.retirementAgeController),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Average annual earned income (\$)', provider.spouseIncomeController),
            _buildTextField('Current age (0 to 120)', provider.spouseAgeController),
            _buildTextField('Social Security retirement age (62 to 70)', provider.spouseRetirementAgeController),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Social Security inflation rate (0% to 10%)', provider.inflationController),
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

  Widget _buildNavigation(BuildContext context, SocialSecurityProvider provider) {
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
            onPressed: provider.calculateResult,
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