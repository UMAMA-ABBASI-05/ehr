import 'package:intl/intl.dart';

class LabReport {
  final int reportId;
  final int visitId;
  final String labName;
  final String testName;
  final String testStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LabReport({
    required this.reportId,
    required this.visitId,
    required this.labName,
    required this.testName,
    required this.testStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory LabReport.fromJson(Map<String, dynamic> json) => LabReport(
        reportId: json['report_id'],
        visitId: json['visit_id'],
        labName: json['lab_name'],
        testName: json['test_name'],
        testStatus: json['test_status'],
        createdAt: _parseDate(json['created_at']),
        updatedAt: _parseDate(json['updated_at']),
      );

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      try {
        return DateFormat("yyyy-MM-dd hh:mm a").parse(value);
      } catch (_) {
        return null;
      }
    }
  }
}
