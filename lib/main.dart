
import 'package:calculators/features/calculators/loan/loan_calculator_screen.dart';
import 'package:calculators/features/calculators/retirement/retirement_calculator_screen.dart';
import 'package:calculators/features/calculators/retirement_planning_calculator/retirement_planning_screen.dart';
import 'package:flutter/material.dart';
import 'features/calculators/retirement_savings_calculator/retirement_savings_screen.dart';
import 'package:calculators/features/calculators/social_security/social_security_screen.dart';
import 'package:calculators/features/calculators/credit_card/credit_card_calculator_screen.dart';
import 'package:calculators/features/calculators/four_o_one_k/four_o_one_k_calculator_screen.dart';
import 'package:calculators/features/calculators/investment_growth/investment_growth_calculator_screen.dart';
import 'package:calculators/features/calculators/payroll_withholdings/payroll_withholdings_calculator_screen.dart';
import 'package:calculators/features/video_player/firebase_video_player_screen.dart';
import 'package:calculators/features/video_player/video_carousel_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget { 
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculators',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 
  void _navigateToLoanCalculator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoanCalculatorScreen(),
      ),
    );
  }

  void _navigateToRetirementCalculator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RetirementCalculatorScreen(),
      ),
    );
  }

  void _navigateToRetirementPlanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RetirementSavingsScreen(),
      ),
    );
  }

  void _navigateToRetirementSavingsPlanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RetirementPlanningScreen(),
      ),
    );
  }

  void _navigateToSocialSecurityCalculator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SocialSecurityScreen(),
      ),
    );
  }

  void _navigateToVideoCarousel() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VideoCarouselScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Calculators'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: _navigateToLoanCalculator,
            //   child: const Text('Loan Calculator'),
            // ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: _navigateToRetirementCalculator,
            //   child: const Text('Retirement Calculator'),
            // ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: _navigateToRetirementPlanner,
            //   child: const Text('Retirement Savings Calculator'),
            // ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: _navigateToRetirementSavingsPlanner,
            //   child: const Text('Retirement Planning Calculator'),
            // ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: _navigateToSocialSecurityCalculator,
            //   child: const Text('Social Security Calculator'),
            // ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => const CreditCardCalculatorScreen(),
            //       ),
            //     );
            //   },
            //   child: const Text('Credit Card Calculator'),
            // ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => const FourOOneKCalculatorScreen(),
            //       ),
            //     );
            //   },
            //   child: const Text('401k Calculator'),
            // ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => const InvestmentGrowthCalculatorScreen(),
            //       ),
            //     );
            //   },
            //   child: const Text('Investment Growth Calculator'),
            // ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => const PayrollWithholdingsCalculatorScreen(),
            //       ),
            //     );
            //   },
            //   child: const Text('Payroll Withholdings Calculator'),
            // ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FirebaseVideoPlayerScreen(
                      videoName: 'SampleVideo_1280x720_10mb.mp4',
                    ),
                  ),
                );
              },
              child: const Text('Watch Video'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToVideoCarousel,
              child: const Text('Video Carousel'),
            ),
          ],
        ),
      ),
    );
  }
}
