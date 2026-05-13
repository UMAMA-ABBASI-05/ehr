import 'package:ehr/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
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

      try {
        final result = await ApiService.loginAdmin(
          _emailController.text.trim(),
          _passwordController.text,
        );

        print("Admin Login Result: $result");

        if (result['success'] == true) {
          SessionService().savePatient(result);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('doctorName', result['name'] ?? "Admin");

          final dynamic rawId = result['users_id'];
          int userId =
              rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

          await ApiService.saveDoctorSession(userId);

          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Welcome Admin!"),
                  backgroundColor: Colors.green),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              (_) => false,
            );
          }
        } else {
          _showError(result['message'] ?? "Invalid credentials");
        }
      } catch (e) {
        _showError("Connection Error: Check IP and Firewall");
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
                  const SizedBox(height: 60),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Admin Login",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter Admin credentials ",
                      style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0))),
                    child: TextFormField(
                      controller: _emailController,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter Valid email'
                          : null,
                      decoration: const InputDecoration(
                        hintText: "Enter admin email",
                        prefixIcon: Icon(Icons.email_outlined,
                            color: Color(0xFFAAAAAA)),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0))),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter Password ' : null,
                      decoration: InputDecoration(
                        hintText: "Enter admin password",
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Color(0xFFAAAAAA)),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFFAAAAAA)),
                          onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B6FF0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Login as Admin",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Back to Doctor Login
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "← Doctor Login",
                      style: TextStyle(
                        color: Color(0xFF3B6FF0),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
