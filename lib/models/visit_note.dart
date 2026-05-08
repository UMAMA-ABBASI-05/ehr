import 'package:intl/intl.dart';

class VisitNote {
  final int noteId;
  final int mpi;
  final int doctorId;
  final int? billId;
  final double? labBill;
  final double? totalBill;
  final DateTime visitDate;
  final String? noteTitle;
  final String? patientComplaint;
  final String? dignosis;
  final String? noteDetails;
  final double? billAmount;
  final String? billStatus;

  VisitNote({
    required this.noteId,
    required this.mpi,
    required this.doctorId,
    this.billId,
    this.labBill,
    this.totalBill,
    required this.visitDate,
    this.noteTitle,
    this.patientComplaint,
    this.dignosis,
    this.noteDetails,
    this.billAmount,
    this.billStatus,
  });

  factory VisitNote.fromJson(Map<String, dynamic> json) => VisitNote(
        noteId: json['note_id'] is int
            ? json['note_id']
            : int.tryParse(json['note_id'].toString()) ?? 0,
        mpi: json['mpi'] is int
            ? json['mpi']
            : int.tryParse(json['mpi'].toString()) ?? 0,
        doctorId: json['doctor_id'] is int
            ? json['doctor_id']
            : int.tryParse(json['doctor_id'].toString()) ?? 0,
        billId: json['bill_id'] != null
            ? (json['bill_id'] is int
                ? json['bill_id']
                : int.tryParse(json['bill_id'].toString()))
            : null,
        visitDate: json['visit_date'] != null
            ? _parseDate(json['visit_date'])
            : DateTime.now(),
        noteTitle: json['note_title'],
        patientComplaint: json['patient_complaint'],
        dignosis: json['dignosis'],
        noteDetails: json['note_details'],
        billAmount:
            (json['consultation_bill'] ?? json['bill_amount'])?.toDouble(),
        billStatus: json['bill_status'],
        labBill: json['lab_bill']?.toDouble(),
        totalBill: json['total_bill']?.toDouble(),
      );

  static DateTime _parseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      try {
        return DateFormat("yyyy-MM-dd hh:mm a").parse(value);
      } catch (_) {
        try {
          return DateFormat("yyyy-MM-dd HH:mm:ss").parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
    }
  }
}
