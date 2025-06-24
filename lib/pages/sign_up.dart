import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _showError = false;



  void _validateAndSignUp() async {
    setState(() {
      _showError = _passwordController.text != _confirmPasswordController.text;
    });

    if (_showError) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        // Add to 'profiles' table using the auto-generated UUID
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'email': email, // Optional
          // Add more fields as needed: 'full_name': 'John Doe', etc.
        });

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/intro');
        }
      } else {
        _showSnackBar("Sign up failed. Check your input or try again later.");
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
            children: [
              const SizedBox(height: 100),
              Image.asset('images/logob.png', height: 60),
              const SizedBox(height: 24),
              Text(
                'Sign Up',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0B1932),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up in 1 minute',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),

              _buildLabel('Email Address'),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _emailController,
                hint: 'Enter your email…',
                icon: Icons.email_outlined,
                obscure: false,
              ),

              const SizedBox(height: 24),
              _buildLabel('Password'),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _passwordController,
                hint: '***********************',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                toggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),

              const SizedBox(height: 24),
              _buildLabel('Password Confirmation'),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _confirmPasswordController,
                hint: '***********************',
                icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                toggleVisibility: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                },
                error: _showError,
              ),

              if (_showError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE76A6A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFE76A6A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ERROR: Passwords do not match!',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFFE76A6A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),
              _buildGradientButton(),

              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  text: 'Already have an account? ',
                  style: GoogleFonts.poppins(fontSize: 13),
                  children: [
                    TextSpan(
                      text: 'Sign In.',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/signin'); // Navigate to SignIn
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0B1932),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    bool error = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: toggleVisibility != null
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: toggleVisibility,
        )
            : null,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: error ? const Color(0xFFE76A6A) : Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: error ? const Color(0xFFE76A6A) : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: error ? const Color(0xFFE76A6A) : const Color(0xFF0B1932),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1932), Color(0xFF142850)],
        ),
      ),
      child: ElevatedButton(
        onPressed: _validateAndSignUp,
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
              'Sign Up',
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
    );
  }
}
