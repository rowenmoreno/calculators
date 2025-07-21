import 'package:flutter/material.dart';

class LoanResultScreen extends StatelessWidget {
  final String resultSummary;
  const LoanResultScreen({Key? key, required this.resultSummary}) : super(key: key);

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
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              resultSummary,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () => _emailResults(context),
                  child: const Text('Email Results'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 