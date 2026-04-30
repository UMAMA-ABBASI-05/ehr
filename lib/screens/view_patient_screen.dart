import 'package:ehr/screens/visit_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import '../models/visit_note.dart';
import '../services/api_service.dart';
import 'add_consultation_screen.dart'; // Naya note add karne ke liye

class ViewPatientScreen extends StatefulWidget {
  final PatientModel patient;
  final int doctorId;

  const ViewPatientScreen(
      {super.key, required this.patient, required this.doctorId});

  @override
  State<ViewPatientScreen> createState() => _ViewPatientScreenState();
}

class _ViewPatientScreenState extends State<ViewPatientScreen> {
  late Future<PatientModel> _patientDetails;
  late Future<List<VisitNote>> _visitNotes;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Data ko refresh karne ka function
  void _refreshData() {
    setState(() {
      // 1. Patient ki complete details (NIC, Address, Age) fetch karein
      _patientDetails = ApiService.getPatientById(widget.patient.mpi);

      // 2. Doctor ID aur Patient MPI use karte hue notes fetch karein
      _visitNotes =
          ApiService.getVisitNotes(widget.doctorId, widget.patient.mpi);
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "View Patient",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // --- PATIENT INFO CARD ---
              FutureBuilder<PatientModel>(
                future: _patientDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingBox(150);
                  }

                  // Agar API fail ho jaye toh pechli screen wala data hi dikhayein
                  final p = snapshot.data ?? widget.patient;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: const Color(0xFFE8EEF4)), // Border styling
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Patient: ${p.name}",
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A3B5D)),
                        ),
                        const SizedBox(height: 12),
                        _infoRow("Age", "${p.age ?? 'N/A'}"),
                        _infoRow("Gender", p.gender ?? 'N/A'),
                        _infoRow("Phone no", p.phoneNo ?? 'N/A'),
                        _infoRow("NIC", p.nic ?? 'N/A'),
                        _infoRow("Address", p.address ?? 'N/A'),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // --- VISITING NOTES SECTION HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Visiting Notes",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A3B5D)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddConsultationScreen(
                            mpi: widget.patient
                                .mpi, // Patient object se mpi nikal kar dein
                            doctorId: widget.doctorId, // Doctor ID pass karein
                          ),
                        ),
                      ).then((_) => _refreshData());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3B5D),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text("Add Notes",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // --- VISITING NOTES LIST ---
              FutureBuilder<List<VisitNote>>(
                future: _visitNotes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF1A3B5D)));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _NoteCard(note: snapshot.data![index]);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for Patient Info rows
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          children: [
            TextSpan(
                text: "$label: ",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBox(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.notes_outlined, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text("No visiting notes found.",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// --- NOTE CARD WIDGET ---
class _NoteCard extends StatelessWidget {
  final VisitNote note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // Sahi BorderSide implementation
        side: const BorderSide(color: Color(0xFFE8EEF4)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisitNoteDetailScreen(note: note),
            ),
          );
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              const Icon(Icons.assignment_outlined, color: Color(0xFF1A3B5D)),
        ),
        title: Text(
          note.noteTitle ?? "Medical Visit",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            DateFormat('yyyy-MM-dd | hh:mm a').format(note.visitDate),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }
}
