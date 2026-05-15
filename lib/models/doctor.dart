class Doctor {
  final int? doctorId;
  final String name;
  final String email;
  final String password;
  final String? specialization;
  final String? about;
  final String? phoneNo;
  final DateTime? dateJoin;
  final String? hospitalId;
  Doctor({
    this.doctorId,
    required this.name,
    required this.email,
    required this.password,
    this.specialization,
    this.about,
    this.phoneNo,
    this.dateJoin,
    this.hospitalId,
  });

  // JSON se Doctor object banane ke liye
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorId: json['doctor_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      specialization: json['specialization'],
      about: json['about'],
      phoneNo: json['phone_no'],
      dateJoin:
          json['date_join'] != null ? DateTime.parse(json['date_join']) : null,
      hospitalId: json['hospital_id'],
    );
  }

  // Doctor object ko JSON mein convert karne ke liye
  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'name': name,
      'email': email,
      'password': password,
      'specialization': specialization,
      'about': about,
      'phone_no': phoneNo,
      'date_join': dateJoin?.toIso8601String(),
      'hospital_id': hospitalId,
    };
  }

  // Login ke liye sirf email aur password
  Map<String, dynamic> toLoginJson() {
    return {'email': email, 'password': password};
  }
}
