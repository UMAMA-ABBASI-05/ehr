import 'package:ehr/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'admin_login_screen.dart';

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

  List<dynamic> _hospitals = [];
  String? _selectedHospitalId;
  bool _hospitalsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      final data = await ApiService.getAllHospitals();
      setState(() {
        _hospitals = data;
        _hospitalsLoading = false;
      });
    } catch (e) {
      setState(() => _hospitalsLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedHospitalId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Select Hospitals '), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final result = await ApiService.loginDoctor(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          hospitalId: _selectedHospitalId!,
        );

        print("Doctor Login Result: $result");

        if (result['success'] == true) {
          SessionService().savePatient(result);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('doctorName', result['name'] ?? "Doctor");

          await prefs.setString(
              'hospitalId', _selectedHospitalId!.toString()); // ← save

          final dynamic rawId = result['users_id'] ?? result['doctor_id'];
          int userId =
              rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;
          await prefs.setInt('docid', result['users_id'] ?? 0);

          await ApiService.saveDoctorSession(userId);

          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Welcome back!"),
                  backgroundColor: Colors.green),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen(doctorId: userId)),
            );
          }
        } else {
          _showError(result['message'] ?? "Invalid credentials");
        }
      } catch (e) {
        _showError("Error: $e");
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
                      "Login",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Valid email likhein'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _buildPasswordField(),
                  const SizedBox(height: 16),

                  // Hospital Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _hospitalsLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xFF3B6FF0)),
                                ),
                                SizedBox(width: 12),
                                Text('Hospitals loading...',
                                    style: TextStyle(
                                        color: Color(0xFFAAAAAA),
                                        fontSize: 14)),
                              ],
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedHospitalId,
                              isExpanded: true,
                              hint: const Row(
                                children: [
                                  Icon(Icons.local_hospital_outlined,
                                      color: Color(0xFFAAAAAA), size: 22),
                                  SizedBox(width: 12),
                                  Text('Select Hospital',
                                      style: TextStyle(
                                          color: Color(0xFFAAAAAA),
                                          fontSize: 15)),
                                ],
                              ),
                              items: _hospitals
                                  .map((h) => DropdownMenuItem<String>(
                                        value: h['hospital_id'] as String,
                                        child: Text(
                                          h['name'] ?? 'N/A',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF333333)),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedHospitalId = val),
                            ),
                          ),
                  ),

                  const SizedBox(height: 48),

                  // Login Button
                  _buildLoginButton(),
                  const SizedBox(height: 20),

                  // Sign Up link
                  _buildSignUpLink(),
                  const SizedBox(height: 16),

                  // Admin Login link
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen()),
                    ),
                    child: const Text(
                      "Login as Admin",
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
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
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
          child: const Text("Sign up",
              style: TextStyle(
                  color: Color(0xFF3B6FF0), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
