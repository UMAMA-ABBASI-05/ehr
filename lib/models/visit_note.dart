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
  final double? billAmount; // ← Add karo
  final String? billStatus; // ← Add karo

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
    this.billAmount, // ← Add karo
    this.billStatus, // ← Add karo
  });

  factory VisitNote.fromJson(Map<String, dynamic> json) => VisitNote(
        noteId: json['note_id'],
        mpi: json['mpi'],
        doctorId: json['doctor_id'],
        billId: json['bill_id'],
        // visit_date null ho sakta hai single note API mein
        visitDate: json['visit_date'] != null
            ? DateFormat("yyyy-MM-dd hh:mm a").parse(json['visit_date'])
            : DateTime.now(),
        noteTitle: json['note_title'],
        patientComplaint: json['patient_complaint'],
        dignosis: json['dignosis'],
        noteDetails: json['note_details'],
        // single note API mein 'consultation_bill' hai, list API mein 'bill_amount'
        billAmount:
            (json['consultation_bill'] ?? json['bill_amount'])?.toDouble(),
        billStatus: json['bill_status'],
        labBill: json['lab_bill']?.toDouble(),
        totalBill: json['total_bill']?.toDouble(),
      );
}
