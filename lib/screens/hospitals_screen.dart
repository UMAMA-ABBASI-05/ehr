import 'package:flutter/material.dart';

class HospitalsScreen extends StatelessWidget {
  const HospitalsScreen({super.key});

  static const Color primaryBlue = Color(0xFF1A3B5D);

  // Hardcoded — API baad mein
  final List<String> _hospitals = const [
    'Shifa Hospital',
    'PIMS Hospital',
    'Poly Clinic',
    'Ali Medical Centre',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hospitals',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hospitals.length,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_hospital_outlined, color: primaryBlue),
              const SizedBox(width: 14),
              Text(_hospitals[i],
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: primaryBlue)),
            ],
          ),
        ),
      ),
    );
  }
}
