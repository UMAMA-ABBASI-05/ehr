import 'package:ehr/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowVitalsScreen extends StatefulWidget {
  // Peechli screen se sirf mpi aa raha hai
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
      // widget.mpi se peechli screen wali ID use ki
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
          errorMessage = 'server error ';
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
                        final String vitalType =
                            (vital['type'] ?? '').toString().toLowerCase();

                        // 1. Agar Type SUGAR hai
                        if (vitalType == 'sugar') {
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: const Icon(Icons.biotech,
                                  color: Colors.orange),
                              title: Text('Type: ${vital['type']}'),
                              subtitle: Text(
                                  'Value: ${vital['value']} ${vital['unit']}'),
                              trailing: Text(vital['meal_time'] ?? 'N/A'),
                            ),
                          );
                        }

                        // 2. Agar Type BP (Blood Pressure) hai
                        if (vitalType == 'bp' ||
                            vitalType == 'blood pressure') {
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading:
                                  const Icon(Icons.favorite, color: Colors.red),
                              title: Text('Type: ${vital['type']}'),
                              subtitle: Text(
                                  'BP: ${vital['systolic']}/${vital['diastolic']} ${vital['unit']}'),
                            ),
                          );
                        }

                        // 3. Agar Type TEMPERATURE hai
                        if (vitalType == 'temperature' || vitalType == 'temp') {
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: const Icon(Icons.thermostat,
                                  color: Colors.blue),
                              title: Text('Type: ${vital['type']}'),
                              subtitle: Text(
                                  'Value: ${vital['value']} ${vital['unit']}'),
                            ),
                          );
                        }

                        // Fallback: Agar koi aur type ho to sirf type aur value dikhaye
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: const Icon(Icons.health_and_safety,
                                color: Colors.teal),
                            title: Text('Type: ${vital['type'] ?? 'Unknown'}'),
                            subtitle: Text(
                                'Value: ${vital['value'] ?? ''} ${vital['unit'] ?? ''}'),
                          ),
                        );
                      }),
    );
  }
}
