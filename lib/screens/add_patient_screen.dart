import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final nicCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final policyCtrl = TextEditingController();

  String? selectedGender;
  DateTime? dob;
  bool isSubmitting = false;

  // API se payers
  List<dynamic> _payers = [];
  bool _payersLoading = true;
  String? selectedCompany;
  String? selectedPayerId;

  // Plan type same rehta hai
  final List<String> plans = ['Silver', 'Golden', 'Bronze'];
  String? selectedPlan;

  @override
  void initState() {
    super.initState();
    _loadPayers();
  }

  Future<void> _loadPayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hospitalId = prefs.getString('hospitalId') ?? '';
      final Map<String, dynamic> data = await ApiService.getPayers(hospitalId);
      setState(() {
        _payers = data['payers'] ?? [];
        _payersLoading = false;
      });
    } catch (e) {
      setState(() => _payersLoading = false);
    }
  }

  _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => dob = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  "Add Patient",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 28),

                // Name
                _buildLabel("Name"),
                _buildInputField(nameCtrl, "Enter your name"),
                const SizedBox(height: 16),

                // Date of Birth
                _buildLabel("Date of Birth"),
                _buildDateField(),
                const SizedBox(height: 16),

                // Gender
                _buildLabel("Gender"),
                _buildDropdownField<String>(
                  value: selectedGender,
                  hint: "Select Gender",
                  items: ["Male", "Female", "Other"],
                  onChanged: (v) => setState(() => selectedGender = v),
                ),
                const SizedBox(height: 16),

                // NIC
                _buildLabel("NIC"),
                _buildInputField(nicCtrl, "Enter NIC"),
                const SizedBox(height: 16),

                // Phone No
                _buildLabel("Phone no"),
                _buildInputField(
                  phoneCtrl,
                  "Enter Phone no",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Address
                _buildLabel("Address"),
                _buildInputField(addressCtrl, "Enter Address"),
                const SizedBox(height: 16),

                // Insurance Company
                _buildLabel("Insurance Company"),
                _payersLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1A365D),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Loading insurance companies...',
                                style: TextStyle(
                                    color: Color(0xFFBBBBBB), fontSize: 14)),
                          ],
                        ),
                      )
                    : _buildDropdownField<String>(
                        value: selectedCompany,
                        hint: "Select Insurance Company",
                        items:
                            _payers.map((p) => p['name'].toString()).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedCompany = val;
                            selectedPayerId = _payers
                                .firstWhere(
                                    (p) => p['name'] == val)['system_id']
                                .toString();
                          });
                        },
                      ),
                const SizedBox(height: 16),

                // Policy Number
                _buildLabel("Policy Number"),
                _buildInputField(policyCtrl, "Enter policy Number"),
                const SizedBox(height: 16),

                // Plan Type
                _buildLabel("Plan Type"),
                _buildDropdownField<String>(
                  value: selectedPlan,
                  hint: "Select Plan Type",
                  items: plans,
                  onChanged: (v) => setState(() => selectedPlan = v),
                ),
                const SizedBox(height: 36),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    onPressed: isSubmitting ? null : _saveData,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController ctrl,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dob == null
                  ? "mm/dd/yyyy"
                  : DateFormat('MM/dd/yyyy').format(dob!),
              style: TextStyle(
                color: dob == null
                    ? const Color(0xFFBBBBBB)
                    : const Color(0xFF333333),
                fontSize: 14,
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                color: Color(0xFF888888), size: 18),
          ],
        ),
      ),
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

  _saveData() async {
    if (dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Date of Birth")),
      );
      return;
    }

    if (nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter patient name")),
      );
      return;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select gender")),
      );
      return;
    }

    if (selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select insurance company")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      Map<String, dynamic> data = {
        "name": nameCtrl.text,
        "nic": nicCtrl.text,
        "gender": selectedGender,
        "date_of_birth": DateFormat('yyyy-MM-dd').format(dob!),
        "phone_no": phoneCtrl.text,
        "address": addressCtrl.text,
        "insurance_company": selectedPayerId,
        "plan_type": selectedPlan,
        "policy_number": policyCtrl.text,
      };

      print('Data: $data');

      bool success = await ApiService.savePatient(data);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data Sync to EHR, LIS & Payer!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save patient"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    nicCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    policyCtrl.dispose();
    super.dispose();
  }
}
