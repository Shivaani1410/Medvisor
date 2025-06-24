import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultReadyScreen extends StatelessWidget {
  const ResultReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get result from previous screen
    final String result = ModalRoute.of(context)?.settings.arguments as String? ?? 'No result received';

    return Scaffold(
      backgroundColor: const Color(0xFF0F294D),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Top icon/image
                Image.asset(
                  'images/search.png',
                  height: 140,
                  width: 140,
                ),

                const SizedBox(height: 32),

                // ✅ Headline
                Text(
                  "Your results are ready!",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // ✅ Subtext with preview of result
                Text(
                  "Hey Laftoz! Your analysis says:\n\n\"$result\"",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // ✅ View Results Button
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/final_result',
                        arguments: result,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF223D64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Results',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
