import 'package:flutter/material.dart';

class AppConstants {
  // Backend API base URL
  static const String baseUrl = 'http://192.168.100.143:8001';

  // API Endpoints
  //        LOGIN / SING UP
  static const String signupEndpoint = '/signup';
  static const String loginEndpoint = '/login';
  //          PATEINTS
  static const String getPatientEndpoint = '/patients';

  static const String searchPatientEndpoint = '/patients/search';
  // PATEINTS section ke andar
  static const String getPatientByIdEndpoint = '/patients/';
  //          VISIT NOTES
  static const String getAllVisitNotes = '/all-visit-notes';
  static const String addVisitNote = '/visit-note-add';
  static const String getVisitNote = '/visit-note';

  // Colors
  static const Color primaryBlue = Color(0xFF4E7FFF);
  static const Color lightBlue = Color(0xFFE8F0FF);
  static const Color textGrey = Color(0xFF9E9E9E);
}
