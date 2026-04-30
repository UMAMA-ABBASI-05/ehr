class PatientModel {
  final int mpi;
  final String name;
  final String? phoneNo; // String? rakhein kyunke backend se null aa sakta hai
  final String? gender; // Isay bhi nullable rakhein
  final String? nic;
  final int? age; // Age field
  final String? address;

  PatientModel({
    required this.mpi,
    required this.name,
    this.phoneNo,
    this.gender,
    this.nic,
    this.age,
    this.address,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      // int.tryParse ya simple cast karein
      mpi: json['mpi'] is int ? json['mpi'] : int.parse(json['mpi'].toString()),
      name: json['name'] ?? 'Unknown', // Null safety ke liye default value
      phoneNo: json['phone_no']?.toString(), // JSON key 'phone_no' hai
      gender: json['gender']?.toString(),
      nic: json['nic']?.toString(),
      age: json['age'] != null
          ? int.tryParse(json['age'].toString())
          : null, // String/Int dono handle honge
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mpi': mpi,
      'name': name,
      'phone_no': phoneNo,
      'gender': gender,
      'nic': nic,
      'age': age,
      'address': address,
    };
  }
}
