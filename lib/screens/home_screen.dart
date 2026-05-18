import 'package:ehr/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_model.dart';
import '../services/api_service.dart';
import 'view_patient_screen.dart';
import 'add_patient_screen.dart';

class HomeScreen extends StatefulWidget {
  final int doctorId;

  const HomeScreen({super.key, required this.doctorId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(doctorId: widget.doctorId),
      AddPatientScreen(),
     // const Center(child: Text("Notifications Screen")),
      ProfileScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B6FF0),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 20,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_add_outlined),
              activeIcon: Icon(Icons.person_add),
              label: "Add Patient"),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.notifications_outlined),
          //     activeIcon: Icon(Icons.notifications),
          //     label: "Notification"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile"),
        ],
      ),
    );
  }
}

// ── Home Content (Search Logic yahan hai) ──────────────────────────────────
class HomeContent extends StatefulWidget {
  final int doctorId;
  const HomeContent({super.key, required this.doctorId});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String doctorName = "Loading...";
  List<PatientModel> allPatients = []; // Backend se ane wala sara data
  List<PatientModel> filteredPatients = []; // Search ke baad dikhne wala data
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => doctorName = prefs.getString('doctorName') ?? "Doctor");
    await _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() => isLoading = true);
    try {
      // Session se hospital_id lo
      final prefs = await SharedPreferences.getInstance();
      final hospitalId = prefs.getString('hospitalId') ?? '0';
      print("Fetching patients for hospital_id: $hospitalId");
      final data =
          await ApiService.getPatients(hospitalId); // ← hospital_id pass karo
      setState(() {
        allPatients = data;
        filteredPatients = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Fetch error: $e");
    }
  }

  // ── SEARCH LOGIC ─────────────────────────────────────────────────────────
  void _runFilter(String query) {
    List<PatientModel> results = [];
    if (query.isEmpty) {
      results = allPatients;
    } else {
      // Name ya Phone Number dono se search ho sakta hai
      results = allPatients
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              (p.phoneNo?.contains(query) ??
                  false)) // Null check add kiya gaya hai
          .toList();
    }
    setState(() => filteredPatients = results);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header (Figma Gradient) ────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFBEDAF5), Color(0xFFDDEEFB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome back,",
                      style: TextStyle(color: Color(0xFF2980B9), fontSize: 14)),
                  Text(" $doctorName",
                      style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Image.asset('assets/images/logo.png', width: 70, height: 70),
            ],
          ),
        ),

        // ── Search Bar ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: TextField(
              onChanged: _runFilter, // Har key press par filter chalega
              decoration: const InputDecoration(
                hintText: "Search Patients...",
                prefixIcon: Icon(Icons.search, color: Color(0xFF3B6FF0)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text("Recent Patients",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
        ),

        // ── List View ──────────────────────────────────────────────────────
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B6FF0)))
              : filteredPatients.isEmpty
                  ? const Center(child: Text("No patients found"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) =>
                          _buildPatientCard(filteredPatients[index]),
                    ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(PatientModel p) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFFF0F0F0))),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ViewPatientScreen(patient: p, doctorId: widget.doctorId),
            ),
          );
        },
        leading: const CircleAvatar(
            backgroundColor: Color(0xFFF0F4FF),
            child: Icon(Icons.person, color: Color(0xFF3B6FF0))),
        title:
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${p.gender} | ${p.phoneNo}"),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF3B6FF0)),
      ),
    );
  }
}
