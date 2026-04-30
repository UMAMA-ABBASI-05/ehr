import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 seconds baad login screen par jayega
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Healthcare Icon with Heart
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                size: 80,
                color: Color(0xFF4E7FFF),
              ),
            ),
            const SizedBox(height: 30),

            // Healthcare Text
            const Text(
              'Healthcare',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E7FFF),
              ),
            ),
            const SizedBox(height: 8),

            // Medical app Text
            const Text(
              'Medical app',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),

            // Stethoscope decoration (optional)
            const SizedBox(height: 50),
            Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/stethoscope.png', // Agar image hai to
                width: 200,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(); // Image nahi hai to kuch nahi dikhao
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
