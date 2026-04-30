import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LabResultScreen extends StatefulWidget {
  final int reportId;
  const LabResultScreen({super.key, required this.reportId});

  @override
  State<LabResultScreen> createState() => _LabResultScreenState();
}

class _LabResultScreenState extends State<LabResultScreen> {
  late Future<Map<String, dynamic>> _resultData;
  static const Color primaryBlue = Color(0xFF1A3B5D);

  @override
  void initState() {
    super.initState();
    _resultData = ApiService.getLabResults(widget.reportId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Lab Result",
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _resultData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryBlue));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data found"));
          }

          final data = snapshot.data!;
          final String testName = data['test_name'] ?? "Lab Report";
          final String description = data['description'] ?? "";
          final List miniResults = data['mini_test_results'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(testName,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue)),
                const SizedBox(height: 16),
                if (description.isNotEmpty) ...[
                  const Text("Report Summary",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8EEF4)),
                    ),
                    child: Text(description,
                        style: const TextStyle(
                            color: Colors.black87, height: 1.6)),
                  ),
                  const SizedBox(height: 24),
                ],
                if (miniResults.isNotEmpty) ...[
                  const Text("Results",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8EEF4)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0F4FF),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text("Parameters",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: primaryBlue))),
                              Expanded(
                                  flex: 3,
                                  child: Text("Normal Range",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: primaryBlue))),
                              Expanded(
                                  flex: 2,
                                  child: Text("Units",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: primaryBlue))),
                              Expanded(
                                  flex: 2,
                                  child: Text("Results",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: primaryBlue))),
                            ],
                          ),
                        ),
                        ...miniResults.asMap().entries.map((entry) {
                          final i = entry.key;
                          final r = entry.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: i.isEven
                                  ? Colors.white
                                  : const Color(0xFFFAFBFF),
                              border: const Border(
                                top: BorderSide(color: Color(0xFFE8EEF4)),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text(r['test_name'] ?? "",
                                        style: const TextStyle(fontSize: 13))),
                                Expanded(
                                    flex: 3,
                                    child: Text(r['normal_range'] ?? "",
                                        style: const TextStyle(fontSize: 13))),
                                Expanded(
                                    flex: 2,
                                    child: Text(r['unit'] ?? "",
                                        style: const TextStyle(fontSize: 13))),
                                Expanded(
                                    flex: 2,
                                    child: Text(r['result_value'] ?? "",
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600))),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text("No results available",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
