import 'package:flutter/material.dart';

class FourOOneKResultScreen extends StatelessWidget {
  final double result;
  const FourOOneKResultScreen({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('401k Results')),
      body: Center(
        child: Text('Result: \$${result.toStringAsFixed(2)}'),
      ),
    );
  }
}