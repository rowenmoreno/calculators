import 'package:flutter/material.dart';

class InvestmentGrowthResultScreen extends StatelessWidget {
  final Map<String, double> result;
  const InvestmentGrowthResultScreen({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    final totalValue = result['totalValue'] ?? 0;
    final totalContributions = result['totalContributions'] ?? 0;
    final totalGrowth = result['totalGrowth'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Investment Growth Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Future Value: \$${totalValue.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Total Contributions: \$${totalContributions.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Total Growth: \$${totalGrowth.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}