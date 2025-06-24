import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Blue curved background with robot and viruses
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: const BoxDecoration(
                  color: Color(0xFFD2E6FD), // exact light blue background
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              // Robot Image (larger, aligned bottom right)
              Positioned(
                bottom: 0,
                right: 20,
                child: Image.asset(
                  'images/robot.png',
                  height: 290,
                ),
              ),
              // Virus 1 (top-left near head)
              Positioned(
                top: 160,
                left: 98,
                child: Image.asset(
                  'images/virus1.png',
                  height: 55,
                ),
              ),
              // Virus 2 (larger and below virus1)
              Positioned(
                top: 220,
                left: 50,
                child: Image.asset(
                  'images/virus2.png',
                  height: 60,
                ),
              ),
              // Virus 3 (connector)
              Positioned(
                top: 280,
                left: 40,
                child: Image.asset(
                  'images/virus3.png',
                  height: 90,
                ),
              ),
              // Virus 4 (bottom left)
              Positioned(
                bottom: 30,
                left: 40,
                child: Image.asset(
                  'images/virus4.png',
                  height: 35,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'AI-Powered Disease\nAnalysis, Made Easy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF2E3A59),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Analyze your symptom with AI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Arrow Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/upload');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2C59),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 18),
                elevation: 10,
                shadowColor: Colors.black12,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
