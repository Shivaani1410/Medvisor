
import 'package:flutter/material.dart';
import 'routes.dart';// import the new routes file
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mobgulapundxzglhkmev.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vYmd1bGFwdW5keHpnbGhrbWV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAzMjk5ODAsImV4cCI6MjA2NTkwNTk4MH0.gqSe-UK_Hw2JBpsaYyX-_sWbcKYNnDXTmrY4ivrkiRg',
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medvisor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: appRoutes, // use defined routes
    );
  }
}
