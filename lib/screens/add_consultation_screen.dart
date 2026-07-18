import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loinc_master.dart';
import '../services/api_service.dart';
import '../widgets/test_search_widget.dart'; // Import check karein

class AddConsultationScreen extends StatefulWidget {
  final int mpi;
  final int doctorId;

  const AddConsultationScreen({
    super.key,
    required this.mpi,
    required this.doctorId,
  });

  @override
  State<AddConsultationScreen> createState() => _AddConsultationScreenState();
}

class _AddConsultationScreenState extends State<AddConsultationScreen> {
  // Controllers
  final _titleController = TextEditingController(text: "Visiting Note");
  final _complaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final _billController = TextEditingController();
  List<dynamic> _labs = [];
  bool _labLoading = true;
  String? selectedlab;
  String? selectedlabId;

  // State variables
  List<LoincMaster> _selectedTests = [];
  String _selectedLab = "IDC";
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadlabs();
  }

  // Save Function
  void _saveConsultation() async {
    // 1. Basic Validation
    if (_complaintController.text.isEmpty || _billController.text.isEmpty) {
      _showSnack("Please fill required fields (*)", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Real API Call
      // Note: ApiService method must handle the 'dignosis' spelling mismatch
      final result = await ApiService.addVisitNote(
        mpi: widget.mpi,
        doctorId: widget.doctorId,
        noteTitle: _titleController.text.isEmpty
            ? "Visiting Note"
            : _titleController.text,
        patientComplaint: _complaintController.text,
        dignosis: _diagnosisController.text,
        noteDetails: _notesController.text,
        billAmount: double.tryParse(_billController.text) ?? 0.0,
        // Rule: lab_name is required only if tests are ordered
        lab_name: _selectedTests.isNotEmpty ? selectedlab : null,
        test_names: _selectedTests.isNotEmpty
            ? _selectedTests.map((t) => t.toJson()).toList()
            : null,
      );

      setState(() => _isLoading = false);

      // 3. Response Handling
      if (result['success'] == true) {
        _showSnack("Consultation Saved Successfully!", Colors.green);
        Navigator.pop(context, true); // Return true to refresh previous screen
      } else {
        // Backend error message (like 400 Bad Request details)
        _showSnack(result['message']?.toString() ?? "Save failed", Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack("Connection Error: $e", Colors.red);
    }
  }

  Future<void> _loadlabs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hospitalId = prefs.getString('hospitalId') ?? '';
      final Map<String, dynamic> data = await ApiService.getPayers(hospitalId);
      setState(() {
        _labs = data['labs'] ?? [];
        _labLoading = false;
      });
    } catch (e) {
      setState(() => _labLoading = false);
    }
  }

  void _openTestSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: TestSearchWidget(onSelect: (test) {
          setState(() {
            // Duplicate check
            if (!_selectedTests.any((t) => t.loincCode == test.loincCode)) {
              _selectedTests.add(test);
            }
          });
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add Visit Note",
            style: TextStyle(
                color: Color(0xFF152F5B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Note Title"),
                _buildInput(_titleController, "e.g., Routine Checkup"),

                _buildLabel("Patient Complaint *"),
                _buildInput(_complaintController, "Describe symptoms..."),

                _buildLabel("Diagnosis *"),
                _buildInput(_diagnosisController, "Enter diagnosis..."),

                _buildLabel("Consultation Notes"),
                _buildInput(_notesController, "Additional details...",
                    maxLines: 3),

                _buildLabel("choose lab"),
                _buildDropdownField<String>(
                  value: selectedlab,
                  hint: "Select lab",
                  items: _labs.map((p) => p['name'].toString()).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedlab = val;
                      selectedlabId = _labs
                          .firstWhere((p) => p['name'] == val)['system_id']
                          .toString();
                    });
                  },
                ),

                const SizedBox(height: 20),
                const Text("Order Lab Tests",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                Row(
                  children: [
                    // _labChip("IDC"),
                    const SizedBox(width: 10),
                    // _labChip("MIR"),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _openTestSearch,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Search Tests"),
                    ),
                  ],
                ),

                // Selected Tests Display
                if (_selectedTests.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Wrap(
                      spacing: 8,
                      children: _selectedTests
                          .map((t) => Chip(
                                label: Text(t.mobileName ?? t.longCommonName,
                                    style: const TextStyle(fontSize: 12)),
                                onDeleted: () =>
                                    setState(() => _selectedTests.remove(t)),
                                deleteIconColor: Colors.redAccent,
                              ))
                          .toList(),
                    ),
                  ),

                _buildLabel("Bill Amount (PKR) *"),
                _buildInput(_billController, "0.00", isNumber: true),

                const SizedBox(height: 100), // Bottom padding for button
              ],
            ),
          ),

          // Fixed Save Button at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF152F5B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _saveConsultation,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Consultation",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 5),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87)),
      );

  Widget _buildInput(TextEditingController ctrl, String hint,
      {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _labChip(String label) {
    bool isSelected = _selectedLab == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (v) => setState(() => _selectedLab = label),
      selectedColor: const Color(0xFF152F5B),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String hint,
    required List<String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint,
              style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14)),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF888888), size: 20),
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e as T,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
