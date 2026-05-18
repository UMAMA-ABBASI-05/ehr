import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  Map<String, dynamic>? _doctor;

  void savePatient(Map<String, dynamic> data) => _doctor = data;
  Map<String, dynamic>? get patient => _doctor;

  Future<void> updateProfile({
    required String phoneNo,
    required String specialization,
    required String about,
  }) async {
    // SharedPreferences mein save karo
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone_no', phoneNo);
    await prefs.setString('specialization', specialization);
    await prefs.setString('about', about);

    // _doctor map bhi update karo taake UI reflect kare
    if (_doctor != null) {
      _doctor!['phone_no'] = phoneNo;
      _doctor!['specialization'] = specialization;
      _doctor!['about'] = about;
    }
  }

  String get name => _doctor?['name'] ?? '';
  String get email => _doctor?['email'] ?? '';
  String get specialization => _doctor?['specialization'] ?? '';
  String get datejoin => _doctor?['date_join'] ?? '';
  String get about => _doctor?['about'] ?? '';
  String get phone_no => _doctor?['phone_no'] ?? ''; // ← space fix kiya

  void clear() => _doctor = null;
}
