import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/shared_pref.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final s = SessionService();

  void _showEditDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final docId = prefs.getInt('docid') ?? 0;

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _EditProfileDialog(
        docId: docId,
        initialPhone: s.phone_no,
        initialSpec: s.specialization,
        initialAbout: s.about,
        onSuccess: (phone, spec, abt) async {
          await s.updateProfile(
            phoneNo: phone,
            specialization: spec,
            about: abt,
          );
          if (mounted) setState(() {});
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated!'),
                backgroundColor: Colors.green,
              ),
            );
        },
        onFail: () {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Update failed'),
                backgroundColor: Colors.red,
              ),
            );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Color(0xFF152F5B)),
                    onPressed: _showEditDialog,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _ProfileField(label: 'Name', value: s.name),
                    _ProfileField(
                      label: 'Email',
                      value: s.email.isNotEmpty ? s.email : 'N/A',
                    ),
                    _ProfileField(
                      label: 'Specialization',
                      value: s.specialization.isNotEmpty
                          ? s.specialization
                          : 'N/A',
                    ),
                    _ProfileField(
                      label: 'Phone no',
                      value: s.phone_no.isNotEmpty ? s.phone_no : 'N/A',
                    ),
                    _ProfileField(
                      label: 'About',
                      value: s.about.isNotEmpty ? s.about : 'N/A',
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          SessionService().clear();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (r) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE24B4A),
                          side: const BorderSide(color: Color(0xFFE24B4A)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: const Row(children: []),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Separate Dialog Widget ──────────────────────────────────────────
class _EditProfileDialog extends StatefulWidget {
  final int docId;
  final String initialPhone;
  final String initialSpec;
  final String initialAbout;
  final Function(String phone, String spec, String abt) onSuccess;
  final VoidCallback onFail;

  const _EditProfileDialog({
    required this.docId,
    required this.initialPhone,
    required this.initialSpec,
    required this.initialAbout,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _specCtrl;
  late final TextEditingController _aboutCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
    _specCtrl = TextEditingController(text: widget.initialSpec);
    _aboutCtrl = TextEditingController(text: widget.initialAbout);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _specCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Keyboard band karo
    FocusScope.of(context).unfocus();

    final phone = _phoneCtrl.text.trim();
    final spec = _specCtrl.text.trim();
    final abt = _aboutCtrl.text.trim();

    setState(() => _saving = true);

    try {
      final ok = await ApiService.updateDoctorInfo(
        docId: widget.docId,
        phoneNo: phone,
        specialization: spec,
        about: abt,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (ok) {
        widget.onSuccess(phone, spec, abt);
      } else {
        widget.onFail();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      widget.onFail();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit Profile',
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1a1a2e)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_phoneCtrl, 'Phone No', Icons.phone_outlined),
            const SizedBox(height: 12),
            _field(
                _specCtrl, 'Specialization', Icons.medical_services_outlined),
            const SizedBox(height: 12),
            _field(_aboutCtrl, 'About', Icons.info_outline, maxLines: 3),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);
                },
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF152F5B),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        ),
      ),
    );
  }
}

// ── Profile Field Widget ────────────────────────────────────────────
class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1a1a2e)),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
