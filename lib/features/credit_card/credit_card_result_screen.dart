import 'package:flutter/material.dart';

class CreditCardResultScreen extends StatelessWidget {
  final double result;
  const CreditCardResultScreen({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Credit Card Results')),
      body: Center(
        child: Text('Result: \$${result.toStringAsFixed(2)}'),
      ),
    );
  }
}
