import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color primaryBlue = Color(0xFF1A3B5D);
  late Future<List<dynamic>> _historyFuture;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiService.getConfigHistory();
  }

  Future<void> _sendToEngine() async {
    setState(() => _sending = true);
    try {
      final ok = await ApiService.sendConfigToEngine();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Sent to engine!' : 'Send failed'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
      setState(() {
        _historyFuture = ApiService.getConfigHistory();
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _sending
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: primaryBlue, strokeWidth: 2),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _sendToEngine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Send to Engine',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryBlue));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No history found',
                    style: TextStyle(color: Colors.grey)));
          }

          final history = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (_, i) {
              final item = history[i];

              // Sirf woh actions lo jo 0 se zyada hain
              final List<Map<String, dynamic>> actions = [];
              if ((item['add_patient_count'] ?? 0) > 0)
                actions.add({
                  'label': 'Added Patient',
                  'count': item['add_patient_count'],
                });
              if ((item['add_visit_count'] ?? 0) > 0)
                actions.add({
                  'label': 'Added Visit',
                  'count': item['add_visit_count'],
                });
              if ((item['add_claim_count'] ?? 0) > 0)
                actions.add({
                  'label': 'Added Claim',
                  'count': item['add_claim_count'],
                });

              // Agar koi action nahi toh skip karo
              if (actions.isEmpty) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hospital Name
                    Text(
                      item['hospital_name'] ?? 'N/A',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: primaryBlue),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 10),

                    // Actions — sirf woh jo > 0
                    ...actions.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${a['label']}:',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black54),
                              ),
                              Text(
                                '${a['count']}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
