import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for a few seconds, then go to results
    Future.delayed(const Duration(seconds: 3), () {
      // Just a placeholder result — can be replaced with arguments passed by Navigator
      Navigator.pushReplacementNamed(
        context,
        '/get_results',
        arguments: 'Sample Prediction Result',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F294D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Analyzing\nData...',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
