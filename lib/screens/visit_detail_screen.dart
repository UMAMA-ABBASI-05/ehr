import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit_note.dart';
import '../models/lab_report.dart';
import '../services/api_service.dart';
import 'lab_report_detail_screen.dart';

class VisitNoteDetailScreen extends StatefulWidget {
  final VisitNote note;
  const VisitNoteDetailScreen({super.key, required this.note});

  @override
  State<VisitNoteDetailScreen> createState() => _VisitNoteDetailScreenState();
}

class _VisitNoteDetailScreenState extends State<VisitNoteDetailScreen> {
  late Future<Map<String, dynamic>> _combinedData;
  static const Color primaryBlue = Color(0xFF1A3B5D);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _combinedData = Future.wait([
      ApiService.getSingleVisitNote(widget.note.noteId),
      ApiService.getLabReports(widget.note.noteId),
    ]).then((results) => {
          'note': results[0],
          'labs': results[1],
        });
  }

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
        title: Text(
          widget.note.noteTitle ?? "Visit Detail",
          style:
              const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _combinedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryBlue));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: primaryBlue));
          }

          final VisitNote? note = snapshot.data!['note'] as VisitNote?;
          final List<LabReport> labs =
              snapshot.data!['labs'] as List<LabReport>;
          final displayNote = note ?? widget.note;

          // Bill calculations
          final double consultBill = displayNote.billAmount ?? 0;
          final double labBill = displayNote.labBill ?? 0;
          final double totalBill =
              displayNote.totalBill ?? (consultBill + labBill);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TOP DETAIL CARD ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8EEF4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inlineRow("Patient Complaint",
                          displayNote.patientComplaint ?? "Not mentioned"),
                      const Divider(color: Color(0xFFE8EEF4), height: 20),
                      _inlineRow(
                          "Diagnosis", displayNote.dignosis ?? "Not mentioned"),
                      const Divider(color: Color(0xFFE8EEF4), height: 20),
                      _inlineRow("Consultation Notes",
                          displayNote.noteDetails ?? "No details added"),
                      const Divider(color: Color(0xFFE8EEF4), height: 20),
                      _inlineRow(
                        "Lab Tests",
                        labs.isEmpty
                            ? "No lab tests"
                            : labs.map((l) => l.testName).join(", "),
                      ),
                      const Divider(color: Color(0xFFE8EEF4), height: 20),
                      _inlineRow(
                        "Consultation Bill",
                        consultBill > 0 ? "$consultBill" : "N/A",
                      ),
                      const Divider(color: Color(0xFFE8EEF4), height: 20),
                      _billStatusRow(displayNote.billStatus ?? "N/A"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- LAB REPORTS SECTION ---
                if (labs.isNotEmpty) ...[
                  const Text(
                    "Lab Reports",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: labs.length,
                    itemBuilder: (context, index) =>
                        _LabReportCard(report: labs[index]),
                  ),
                  const SizedBox(height: 16),

                  // --- TOTAL LAB CHARGES ---
                  _billRow("Total Lab Charges", labBill),
                  const SizedBox(height: 10),

                  // --- TOTAL BILL ---
                  _billRow("Total Bill", totalBill, isTotal: true),
                  const SizedBox(height: 24),

                  // --- SUBMIT CLAIM BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Submit claim API
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Submit Claim",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _inlineRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ",
            style: const TextStyle(
                color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _billStatusRow(String status) {
    final bool isPaid = status.toLowerCase() == "paid";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Bill Status",
            style: TextStyle(
                color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isPaid
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
                color: isPaid ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _billRow(String label, double amount, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isTotal ? primaryBlue.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EEF4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: isTotal ? primaryBlue : Colors.black87)),
          Text(
            "$amount PKR",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isTotal ? primaryBlue : Colors.black87),
          ),
        ],
      ),
    );
  }
}

// --- LAB REPORT CARD ---
class _LabReportCard extends StatelessWidget {
  final LabReport report;
  const _LabReportCard({required this.report});

  static const Color primaryBlue = Color(0xFF1A3B5D);

  void _showChangeLabSheet(BuildContext context) {
    final List<String> labs = ["IDC", "MIR", "Chughtai", "Excel"];
    String? selectedLab = report.labName;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Lab",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue)),
              const SizedBox(height: 16),
              ...labs.map((lab) => RadioListTile<String>(
                    value: lab,
                    groupValue: selectedLab,
                    activeColor: primaryBlue,
                    title: Text(lab),
                    onChanged: (val) => setSheetState(() => selectedLab = val),
                  )),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Send",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String status = report.testStatus.toLowerCase();
    final bool isCompleted = status == "completed";
    final bool isRejected = status == "rejected";

    return GestureDetector(
      onTap: isCompleted
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LabResultScreen(reportId: report.reportId),
                ),
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE8EEF4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.science_outlined,
                  color: primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.testName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    report.createdAt != null
                        ? DateFormat('dd MMM yyyy | hh:mm a')
                            .format(report.createdAt!)
                        : "Date N/A",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : isRejected
                              ? Colors.red.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.testStatus,
                      style: TextStyle(
                          color: isCompleted
                              ? Colors.green
                              : isRejected
                                  ? Colors.red
                                  : Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            if (isRejected)
              ElevatedButton(
                onPressed: () => _showChangeLabSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text("Change Lab",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              )
            else if (isCompleted)
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
