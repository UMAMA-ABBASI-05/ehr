import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const Color primaryBlue = Color(0xFF1A3B5D);

  // Hardcoded — API baad mein
  final List<Map<String, String>> _history = const [
    {'date': '2026-05-01', 'action': 'Patient Added', 'detail': 'MPI: 23'},
    {'date': '2026-05-02', 'action': 'Visit Note', 'detail': 'MPI: 21'},
    {'date': '2026-05-03', 'action': 'Lab Report', 'detail': 'MPI: 18'},
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
        title: const Text('History',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Send to Engine button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Send to engine API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sent to engine!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Send to Engine',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (_, i) {
          final item = _history[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: primaryBlue),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['action'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: primaryBlue)),
                      const SizedBox(height: 4),
                      Text(item['detail'] ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                      Text(item['date'] ?? '',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
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
