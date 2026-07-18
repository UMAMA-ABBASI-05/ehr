import 'package:ehr/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowVitalsScreen extends StatefulWidget {
  final int mpi;

  const ShowVitalsScreen({super.key, required this.mpi});

  @override
  State<ShowVitalsScreen> createState() => _ShowVitalsScreenState();
}

class _ShowVitalsScreenState extends State<ShowVitalsScreen> {
  List<dynamic> vitalsList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPatientVitals();
  }

  Future<void> fetchPatientVitals() async {
    try {
      final url =
          Uri.parse('${AppConstants.baseUrl}/patient/vitals?mpi=${widget.mpi}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          vitalsList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Server error';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  // Reading logic (Basic text generation)
  String _buildVitalReading(dynamic vital, String type) {
    if (type == 'bp' || type == 'blood pressure') {
      return 'Reading: ${vital['systolic'] ?? '-'}/${vital['diastolic'] ?? '-'} ${vital['unit'] ?? ''}';
    } else if (type == 'sugar') {
      return 'Reading: ${vital['value'] ?? '-'} ${vital['unit'] ?? ''} (${vital['meal_time'] ?? 'N/A'})';
    } else {
      return 'Reading: ${vital['value'] ?? '-'} ${vital['unit'] ?? ''}';
    }
  }

  // Time format logic (String parsing for API datetime string)
  String _formatDateTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Date: N/A';
    try {
      DateTime dt = DateTime.parse(rawDate);
      return 'Date: ${dt.day}/${dt.month}/${dt.year} - ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Date: $rawDate'; // Agar parse na ho sake to raw text dikhaye
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Vitals'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : vitalsList.isEmpty
                  ? const Center(child: Text('Koi vitals maujood nahi hain'))
                  : ListView.builder(
                      itemCount: vitalsList.length,
                      itemBuilder: (context, index) {
                        final vital = vitalsList[index];
                        final String vitalType = (vital['type'] ?? '')
                            .toString()
                            .toLowerCase()
                            .trim();

                        return ListTile(
                          title: Text('Type: ${vital['type'] ?? 'Unknown'}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_buildVitalReading(vital, vitalType)),
                              Text(_formatDateTime(
                                  vital['recorded_at'])), // Time line
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
