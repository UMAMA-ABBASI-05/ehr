import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final doctor = Doctor(
        name: '',
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      try {
        final result = await ApiService.login(doctor);
        print("Login Result: $result");

        if (result['success'] == true) {
          final dynamic rawId = result['doctor_id'];

          if (rawId != null) {
            int doctorId =
                rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

            // Session save karein
            await ApiService.saveDoctorSession(doctorId);

            // ← Doctor name bhi save karo
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('doctorName', result['name'] ?? "Doctor");

            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Welcome back!"),
                    backgroundColor: Colors.green),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(doctorId: doctorId),
                ),
              );
            }
          } else {
            _showError("Login successful but Doctor ID missing in response");
          }
        } else {
          _showError(result['message'] ?? "Invalid credentials");
        }
      } catch (e) {
        _showError("Connection Error: Check IP 192.168.100.109 and Firewall");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: _emailController,
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Valid email likhein'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 48),
                  _buildLoginButton(),
                  const SizedBox(height: 20),
                  _buildSignUpLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      String? Function(String?)? validator}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0))),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFFAAAAAA)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0))),
      child: TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Password darj karein' : null,
        decoration: InputDecoration(
          hintText: "Enter your password",
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFAAAAAA)),
          suffixIcon: IconButton(
            icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFFAAAAAA)),
            onPressed: () =>
                setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B6FF0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Sign In",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ",
            style: TextStyle(color: Color(0xFF666666))),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SignUpScreen())),
          child: const Text("Sign up",
              style: TextStyle(
                  color: Color(0xFF3B6FF0), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
