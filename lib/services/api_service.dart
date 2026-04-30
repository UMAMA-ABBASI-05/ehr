import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient_model.dart';
import '../utils/constants.dart';
import '../models/doctor.dart';
import '../models/visit_note.dart';
import '../models/lab_report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static Future<void> saveDoctorSession(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('doctor_id', doctorId);
  }

  static Future<int?> getSavedDoctorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('doctor_id');
  }

  // static Future<void> clearSession() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('doctor_id');
  // }

  static Future<Map<String, dynamic>> signup(Doctor doctor) async {
    try {
      final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.signupEndpoint}',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(doctor.toJson()),
      );
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonDecode(response.body)['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> login(Doctor doctor) async {
    try {
      final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.loginEndpoint}',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(doctor.toLoginJson()),
      );
      print("Backend Raw Response: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          ...data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<PatientModel> getPatientById(int mpi) async {
    try {
      final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.getPatientByIdEndpoint}$mpi');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return PatientModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load patient');
      }
    } catch (e) {
      debugPrint("Error in getPatientById: $e");
      rethrow;
    }
  }

  static Future<int?> getDoctorId(String email, String password) async {
    try {
      final url = Uri.parse(
        '${AppConstants.baseUrl}/get-doctor/$email/$password',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['doctor_id'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<PatientModel>> getPatients() async {
    try {
      final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.getPatientEndpoint}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => PatientModel.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<PatientModel>> searchPatients(String name) async {
    try {
      final url =
          Uri.parse('${AppConstants.baseUrl}/patients/search?name=$name');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => PatientModel.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getInsuranceCompanies() async {
    final response = await http
        .get(Uri.parse('${AppConstants.baseUrl}/insurance-companies'));
    return jsonDecode(response.body);
  }

  static Future<bool> savePatient(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/patients'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  // ── Visit Notes ──────────────────────────────────────────────────────────

  static Future<List<VisitNote>> getVisitNotes(int docId, int pid) async {
    try {
      final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.getAllVisitNotes}$docId/$pid',
      );
      print("Hitting URL: $url");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => VisitNote.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      print("Frontend Handle Error: $e");
      return [];
    }
  }

  // Single visit note lao note_id se
  static Future<VisitNote?> getSingleVisitNote(int noteId) async {
    try {
      final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.getVisitNote}$noteId',
      );
      print("Single Note URL: $url");
      final response = await http.get(url);
      print("Single Note Response: ${response.body}");
      if (response.statusCode == 200) {
        return VisitNote.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint("getSingleVisitNote error: $e");
      return null;
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('doctor_id');
    await prefs.remove('doctorName'); // ← Yeh add karo
  }

  // Lab reports by note_id
  static Future<List<LabReport>> getLabReports(int noteId) async {
    try {
      final url = Uri.parse(
        '${AppConstants.baseUrl}/lab-reports-by-$noteId',
      );
      print("Lab Reports URL: $url");
      final response = await http.get(url);
      print("Lab Reports Response: ${response.body}");
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => LabReport.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("getLabReports error: $e");
      return [];
    }
  }

  // Lab results by report_id
  static Future<Map<String, dynamic>> getLabResults(int reportId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/lab-results/$reportId');
      print("Lab Results URL: $url");
      final response = await http.get(url);
      print("Lab Results Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      debugPrint("getLabResults error: $e");
      return {};
    }
  }

  static Future<List<dynamic>> searchLabTests(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/lab_test_search?search_name=$query'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Search API Error: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> addVisitNote({
    required int mpi,
    required int doctorId,
    required String noteTitle,
    required String patientComplaint,
    required String dignosis,
    String? noteDetails,
    required double billAmount,
    String? lab_name,
    List<dynamic>? test_names,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.addVisitNote}'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "mpi": mpi,
          "doctor_id": doctorId,
          "note_title": noteTitle,
          "patient_complaint": patientComplaint,
          "dignosis": dignosis,
          "note_details": noteDetails ?? "",
          "bill_amount": billAmount,
          "lab_name": lab_name,
          "test_names": test_names ?? [],
        }),
      );
      if (response.statusCode == 201) {
        return {"success": true, "message": "Data inserted successfully"};
      }
      return {"success": false, "message": "Server Error"};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
