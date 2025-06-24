import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  void _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/upload');
        }
      } else {
        _showSnackBar("Sign in failed. Check your credentials.");
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar("Unexpected error: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Center(
                child: Column(
                  children: [
                    Image.asset('images/logob.png', height: 60),
                    const SizedBox(height: 24),
                    Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B1932),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Let's experience the joy of telecare AI.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Email field
              Text(
                'Email Address',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0B1932),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  hintText: 'Enter your email...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Password field
              Text(
                'Password',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0B1932),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  hintText: 'Enter your password…',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sign In button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B1932), Color(0xFF142850)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _signInWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Social media login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(FontAwesomeIcons.facebookF),
                  const SizedBox(width: 16),
                  _socialButton(FontAwesomeIcons.google),
                  const SizedBox(width: 16),
                  _socialButton(FontAwesomeIcons.instagram),
                ],
              ),

              const SizedBox(height: 24),

              // Sign Up link
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.poppins(fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Sign Up.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Forgot your password?',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, size: 20),
    );
  }
}
