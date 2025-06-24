import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // ✅ Top Image Icon instead of container with icon
              Image.asset(
                'images/logowel.png',
                width: 56,
                height: 56,
              ),

              const SizedBox(height: 32),

              // ✅ Title
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Welcome to the\n",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: "MedVisor",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F294D),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // ✅ Description with grey stethoscope icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Your intelligent lab report analyst. ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const Icon(
                    Icons.medical_services_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ✅ Bot Image
              Image.asset(
                'images/bot.png',
                height: 260,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),

              // ✅ Get Started Button (smaller and higher)
              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F294D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');

                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ Sign In text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signin');

                    },
                    child: Text(
                      "Sign In.",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Color(0xFF0F294D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
