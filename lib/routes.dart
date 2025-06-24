import 'package:flutter/material.dart';
import 'package:medvisor/pages/ai_screen.dart';
import 'package:medvisor/pages/result_load.dart';
import 'package:medvisor/pages/result_ready.dart';
import 'package:medvisor/pages/sign_up.dart';
import 'package:medvisor/pages/sign_in.dart';
import 'package:medvisor/pages/upload_page.dart';
import 'package:medvisor/pages/splash_screen.dart';
import 'package:medvisor/pages/welcome_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/welcome': (context) => WelcomePage(),
  '/signup': (context) => const SignUpScreen(),
  '/intro':(context)=> OnboardingScreen(),
  '/signin': (context) => const SignInScreen(),
  '/upload': (context) =>  ReportUploadScreen(),
  '/load':(context)=>const AnalyzingScreen(),
  '/resultReady':(context)=>const ResultReadyScreen(),
};
