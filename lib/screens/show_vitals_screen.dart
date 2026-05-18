import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowVitalsScreen extends StatefulWidget {
  final int mpi;
  final String docId;

  const ShowVitalsScreen({
    super.key,
    required this.mpi,
    required this.docId,
  });

  @override
  State<ShowVitalsScreen> createState() => _ShowVitalsScreenState();
}

class _ShowVitalsScreenState extends State<ShowVitalsScreen> {
  static const Color primaryBlue = Color(0xFF1A3B5D);
  static const String baseUrl = 'http://192.168.100.143:8001';

  bool _loading = true;
  String? _error;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'BP', 'Sugar', 'Temperature'];
  List<Map<String, dynamic>> _allVitals = [];

  @override
  void initState() {
    super.initState();
    _fetchVitals();
  }

  Future<void> _fetchVitals() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ── API CALL ──────────────────────────────────────────
      // Expected endpoint: GET /vitals/{mpi}?doc_id={docId}
      // Response expected:
      // [
      //   {
      //     "vital_id": 1,
      //     "type": "BP",           // "BP" | "Sugar" | "Temperature"
      //     "systolic": "120",      // only for BP
      //     "diastolic": "80",      // only for BP
      //     "value": null,          // for Sugar & Temperature
      //     "unit": "mmHg",
      //     "meal_time": null,      // only for Sugar: "Before Meal" | "After Meal"
      //     "recorded_at": "2026-04-28T10:30:00"
      //   },
      //   {
      //     "vital_id": 2,
      //     "type": "Sugar",
      //     "systolic": null,
      //     "diastolic": null,
      //     "value": "95",
      //     "unit": "mg/dL",
      //     "meal_time": "Before Meal",
      //     "recorded_at": "2026-04-28T08:00:00"
      //   },
      //   {
      //     "vital_id": 3,
      //     "type": "Temperature",
      //     "systolic": null,
      //     "diastolic": null,
      //     "value": "98.6",
      //     "unit": "°F",
      //     "meal_time": null,
      //     "recorded_at": "2026-04-27T09:00:00"
      //   }
      // ]

      final uri = Uri.parse(
        '$baseUrl/vitals/${widget.mpi}?doc_id=${widget.docId}',
      );

      print('📍 Fetching vitals: $uri');

      final response = await http.get(uri).timeout(
            const Duration(seconds: 10),
          );

      print('   Response: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _allVitals = data.map((item) {
            return {
              'type': item['type'] ?? '',
              'systolic': item['systolic']?.toString(),
              'diastolic': item['diastolic']?.toString(),
              'value': item['value']?.toString(),
              'unit': item['unit'] ?? '',
              'meal_time': item['meal_time'],
              'datetime':
                  DateTime.tryParse(item['recorded_at']?.toString() ?? '') ??
                      DateTime.now(),
            };
          }).toList();
          _loading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _allVitals = [];
          _loading = false;
        });
      } else {
        throw Exception('Server error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Vitals error: $e');
      setState(() {
        _error = 'Failed to load vitals. Please try again.';
        _loading = false;
      });
    }
  }

  // ── Helpers ──────────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'All') return _allVitals;
    return _allVitals.where((v) => v['type'] == _selectedFilter).toList();
  }

  String _getValue(Map<String, dynamic> v) => v['type'] == 'BP'
      ? '${v['systolic'] ?? '-'}/${v['diastolic'] ?? '-'}'
      : v['value'] ?? '-';

  String _formatDate(DateTime dt) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}\n$h:$min $period';
  }

  Color _typeColor(String t) => t == 'BP'
      ? const Color(0xFF1565C0)
      : t == 'Sugar'
          ? const Color(0xFF2E7D32)
          : const Color(0xFFAD1457);

  IconData _typeIcon(String t) => t == 'BP'
      ? Icons.favorite_rounded
      : t == 'Sugar'
          ? Icons.water_drop_rounded
          : Icons.thermostat_rounded;

  // ── Build ─────────────────────────────────────────────────
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
          'Patient Vitals',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primaryBlue),
            onPressed: _fetchVitals,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Pills ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final active = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? primaryBlue : const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : primaryBlue,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // ── Body ─────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryBlue))
                : _error != null
                    ? _buildError()
                    : _filtered.isEmpty
                        ? _buildEmpty()
                        : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final v = _filtered[i];
        final color = _typeColor(v['type']);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8EEF4)),
          ),
          child: Row(
            children: [
              // ── Icon ──
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon(v['type']), color: color, size: 22),
              ),
              const SizedBox(width: 14),

              // ── Value ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v['type'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _getValue(v),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            v['unit'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (v['type'] == 'Sugar' && v['meal_time'] != null)
                      Text(
                        v['meal_time'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Date ──
              Text(
                _formatDate(v['datetime']),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF999999),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 40, color: Color(0xFFBBBBBB)),
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Color(0xFF888888))),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _fetchVitals,
            child: const Text('Retry', style: TextStyle(color: primaryBlue)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'No ${_selectedFilter == 'All' ? '' : _selectedFilter} vitals found',
        style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
      ),
    );
  }
}
