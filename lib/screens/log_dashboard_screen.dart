import 'package:ehr/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<dynamic> logs = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      // 1. SharedPreferences se hospitalId nikalna
      final prefs = await SharedPreferences.getInstance();
      final hospitalId = prefs.getString('hospitalId') ?? '0';

      // 2. Apni EHR ya LIS wali API ka URL (Apne backend ka exact IP/Port lagayein)
      // Agar emulator use kar rahi hain to 127.0.0.1 ki jagah 10.0.0.2 ya apna local IP use karein
      final url =
          Uri.parse('${AppConstants.baseUrl}/v1/logs?system_id=$hospitalId');

      // 3. API Request bhejna
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          logs = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Server se data nahi mila';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connection ka masla hai: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Logs'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading spinner
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) // Error message
              : logs.isEmpty
                  ? const Center(child: Text('Koi logs maujood nahi hain'))
                  : ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];

                        // Ek ek card banaya har log ke liye
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              'To: ${log['dest_system_name'] ?? 'Unknown'}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                                Text('Msg: ${log['operation_heading'] ?? ''}'),
                            trailing: Text(
                              log['status'] ?? 'No Status',
                              style: TextStyle(
                                // Success par green aur Fail par red rang
                                color: log['status'] == 'Success'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
