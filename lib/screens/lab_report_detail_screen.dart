import 'package:flutter/material.dart';
import '../models/lab_result.dart';
import '../services/api_service.dart';

class LabResultScreen extends StatefulWidget {
  final int reportId;
  const LabResultScreen({super.key, required this.reportId});

  @override
  State<LabResultScreen> createState() => _LabResultScreenState();
}

class _LabResultScreenState extends State<LabResultScreen> {
  static const Color primaryBlue = Color(0xFF1A3B5D);
  late Future<LabResult> _resultFuture;

  @override
  void initState() {
    super.initState();
    _resultFuture = ApiService.getLabResult(widget.reportId);
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
        title: const Text(
          'Lab Result',
          style: TextStyle(
              color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<LabResult>(
        future: _resultFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryBlue));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString().replaceAll('Exception: ', ''),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final result = snapshot.data!;
          return _buildBody(result);
        },
      ),
    );
  }

  Widget _buildBody(LabResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Test Title ──────────────────────────────────────
          Text(
            result.testName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 20),

          // ── Report Summary Card ──────────────────────────────
          if (result.description != null && result.description!.isNotEmpty) ...[
            const Text(
              'Report Summary',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EEF4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                result.description!,
                style: const TextStyle(
                    fontSize: 14, color: Colors.black87, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Results Table ────────────────────────────────────
          const Text(
            'Results',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8EEF4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Row
                _tableHeader(),
                const Divider(height: 1, color: Color(0xFFE8EEF4)),
                // Data Rows
                ...result.miniTestResults.asMap().entries.map((entry) {
                  final isLast = entry.key == result.miniTestResults.length - 1;
                  return Column(
                    children: [
                      _tableRow(entry.value),
                      if (!isLast)
                        const Divider(height: 1, color: Color(0xFFE8EEF4)),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    const style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: primaryBlue,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Parameters', style: style)),
          Expanded(flex: 2, child: Text('Normal Range', style: style)),
          Expanded(flex: 1, child: Text('Units', style: style)),
          Expanded(
            flex: 1,
            child: Text('Results', style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(LabMiniTestResult row) {
    // Abnormal check — result se bahar ho to red
    final bool isAbnormal = _isAbnormal(row.resultValue, row.normalRange);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              row.testName,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.normalRange,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              row.unit,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              row.resultValue,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isAbnormal ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Simple range check — "13.5 – 17.5" format parse karke check karta hai
  bool _isAbnormal(String resultValue, String normalRange) {
    try {
      final value = double.tryParse(resultValue);
      if (value == null) return false;

      // en-dash ya hyphen dono support karta hai
      final parts =
          normalRange.replaceAll('–', '-').replaceAll(',', '').split('-');
      if (parts.length == 2) {
        final low = double.tryParse(parts[0].trim());
        final high = double.tryParse(parts[1].trim());
        if (low != null && high != null) {
          return value < low || value > high;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
