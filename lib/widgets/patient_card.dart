import 'package:flutter/material.dart';
import '../models/patient_model.dart';

class PatientCard extends StatelessWidget {
  final PatientModel patient;

  const PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(Icons.person, color: Colors.blue),
        ),
        title: Text(
          patient.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patient.phoneNo ?? 'N/A',
                style: TextStyle(color: Colors.grey)),
            Text(patient.phoneNo ?? 'N/A',
                style: TextStyle(color: Colors.blue, fontSize: 12)),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Patient details par janay ke liye
        },
      ),
    );
  }
}
