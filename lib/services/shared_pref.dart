class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  Map<String, dynamic>? _doctor;

  void savePatient(Map<String, dynamic> data) => _doctor = data;
  Map<String, dynamic>? get patient => _doctor;

  String get name => _doctor?['name'] ?? '';
  String get email => _doctor?['email'] ?? '';
  String get specialization => _doctor?['specialization'] ?? '';
  String get datejoin => _doctor?['date_join'] ?? '';
  String get about => _doctor?['about'] ?? '';
  String get phone_no => _doctor?['phone_no '] ?? '';

  void clear() => _doctor = null;
}
