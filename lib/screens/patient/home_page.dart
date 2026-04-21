import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare_system/screens/patient/appointment_page.dart';
import 'package:healthcare_system/screens/patient/report_page.dart';
import 'package:healthcare_system/screens/patient/prescription_page.dart';
import 'package:healthcare_system/screens/patient/patient_editable_profile_page.dart';
import 'package:healthcare_system/app_drawer.dart';
import 'package:healthcare_system/screens/patient/support_page.dart';
import 'package:healthcare_system/screens/patient/upload_report_page.dart';
import 'package:healthcare_system/screens/patient/my_lab_tests_page.dart';
import 'package:intl/intl.dart';
import 'package:healthcare_system/notification_service.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String patientName = "Loading...";

  List<Map<String, dynamic>> upcomingAppointments = [];
  Map<String, dynamic>? activePrescription;
  Map<String, dynamic>? recentReport;
  bool isLoading = true;
  StreamSubscription<QuerySnapshot>? _prescriptionSubscription;
  bool _listenersSetup = false;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            patientName = doc.get('fullName') ?? 'Patient';
          });
        }
        
        if (!_listenersSetup) {
          _setupListeners(user.uid);
          _listenersSetup = true;
        }

        DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        
        // Fetch appointment
        try {
          final apptSnapshot = await FirebaseFirestore.instance.collection('appointments')
              .where('patientId', isEqualTo: user.uid)
              // .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today)) // Removed to avoid composite index error
              .get();
          if (apptSnapshot.docs.isNotEmpty) {
            var docs = apptSnapshot.docs.toList();
            docs = docs.where((d) {
              final data = d.data();
              if (data['status'] == 'Completed') return false;
              final date = ((data['date'] as Timestamp?) ?? Timestamp.now()).toDate();
              return date.isAfter(today.subtract(const Duration(days: 1)));
            }).toList();
            if (docs.isNotEmpty) {
              docs.sort((a, b) => ((a.data()['date'] as Timestamp?) ?? Timestamp.now()).compareTo((b.data()['date'] as Timestamp?) ?? Timestamp.now()));
              upcomingAppointments = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
            } else {
              upcomingAppointments = [];
            }
          }
        } catch(e) {}

        // Fetch prescription
        try {
          final presSnapshot = await FirebaseFirestore.instance.collection('prescriptions')
              .where('patientId', isEqualTo: user.uid)
              .get();
          if (presSnapshot.docs.isNotEmpty) {
            var docs = presSnapshot.docs.toList();
            docs.sort((a, b) => ((b.data()['createdAt'] as Timestamp?) ?? Timestamp.now()).compareTo((a.data()['createdAt'] as Timestamp?) ?? Timestamp.now()));
            activePrescription = docs.first.data();
          }
        } catch(e) {}

        // Fetch report
        try {
          final repSnapshot = await FirebaseFirestore.instance.collection('reports')
              .where('patientId', isEqualTo: user.uid)
              .get();
          if (repSnapshot.docs.isNotEmpty) {
            var docs = repSnapshot.docs.toList();
            docs.sort((a, b) => ((b.data()['createdAt'] as Timestamp?) ?? Timestamp.now()).compareTo((a.data()['createdAt'] as Timestamp?) ?? Timestamp.now()));
            recentReport = docs.first.data();
          }
        } catch(e) {}

        if (mounted) {
          setState(() => isLoading = false);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
            patientName = 'Guest';
            isLoading = false;
        });
      }
    }
  }

  void _setupListeners(String userId) {
    _prescriptionSubscription?.cancel();
    _prescriptionSubscription = FirebaseFirestore.instance
        .collection('prescriptions')
        .where('patientId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>?;
          if (data != null && data['createdAt'] != null) {
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            if (DateTime.now().difference(createdAt).inSeconds < 30) {
               NotificationService.sendPrescriptionNotification(patientName);
               _fetchPatientData(); // Refresh UI
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _prescriptionSubscription?.cancel();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String _appBarTitle() {
    if (_currentIndex == 1) return "Support";
    if (_currentIndex == 2) return "My Profile";
    return patientName != "Loading..." && patientName != "Guest" ? "Hi, $patientName" : "Patient Dashboard";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_appBarTitle()),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: _currentIndex == 1
          ? const SupportPage(showScaffold: false)
          : _currentIndex == 2
              ? const PatientEditableProfilePage(showScaffold: false)
              : isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.teal, Colors.tealAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person,
                                      size: 30, color: Colors.teal),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Welcome back,",
                                        style: TextStyle(color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text(
                                      patientName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Today's Health Overview",
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    _healthCard(
                                        icon: Icons.favorite,
                                        label: "Heart Rate",
                                        value: "72 bpm",
                                        color: Colors.red),
                                    const SizedBox(width: 12),
                                    _healthCard(
                                        icon: Icons.bloodtype,
                                        label: "Blood Pressure",
                                        value: "120 / 80",
                                        color: Colors.redAccent),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    _healthCard(
                                        icon: Icons.monitor_weight,
                                        label: "Weight",
                                        value: "58 kg",
                                        color: Colors.blue),
                                    const SizedBox(width: 12),
                                    _healthCard(
                                        icon: Icons.thermostat,
                                        label: "Temperature",
                                        value: "98.4 °F",
                                        color: Colors.orange),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Dedicated Booking Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const AppointmentPage(),
                                        ),
                                      ).then((_) => _fetchPatientData());
                                    },
                                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                                    label: const Text(
                                      "Book New Appointment",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                const Text("Upcoming Appointments",
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),

                                upcomingAppointments.isEmpty
                                  ? const Card(
                                      child: ListTile(
                                          title: Text("No upcoming appointments.")
                                      )
                                    )
                                  : Column(
                                      children: upcomingAppointments.map((appt) {
                                        return Card(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            leading: const Icon(Icons.event_available, color: Colors.teal),
                                            title: Text("Dr. ${appt['doctorName'] ?? 'Unknown'}"),
                                            subtitle: Text(
                                              "${DateFormat('dd MMM yyyy').format((appt['date'] as Timestamp).toDate())} • ${appt['time']}"
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                const SizedBox(height: 24),

                                const Text("Active Prescriptions",
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),

                                Card(
                                  child: activePrescription != null ? ListTile(
                                    leading: const Icon(Icons.medication,
                                        color: Colors.teal),
                                    title: Text(activePrescription!['medicationName'] ?? 'Medication'),
                                    subtitle:
                                        Text(activePrescription!['dosage'] ?? 'Details'),
                                    trailing: const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const PrescriptionPage()),
                                      );
                                    },
                                  ) : const ListTile(
                                    title: Text("No active prescriptions"),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                const Text("Recent Reports",
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),

                                Card(
                                  child: recentReport != null ? ListTile(
                                    leading: const Icon(Icons.description,
                                        color: Colors.teal),
                                    title: Text(recentReport!['title'] ?? 'Report'),
                                    subtitle: Text("Uploaded on ${DateFormat('dd MMM yyyy').format((recentReport!['createdAt'] as Timestamp).toDate())}"),
                                    trailing: const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const ReportPage()),
                                      ).then((_) => _fetchPatientData());
                                    },
                                  ) : const ListTile(title: Text("No recent reports based on history.")),
                                ),

                                const SizedBox(height: 12),

                                // 📎 Upload Reports Button
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.teal, width: 1.5),
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const UploadReportPage(),
                                        ),
                                      ).then((_) => _fetchPatientData());
                                    },
                                    icon: const Icon(Icons.upload_file,
                                        color: Colors.teal),
                                    label: const Text(
                                      "Upload Medical Reports",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.blue, width: 1.5),
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const MyLabTestsPage(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.science,
                                        color: Colors.blue),
                                    label: const Text(
                                      "My Lab Tests",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.teal.shade100,
                                        Colors.teal.shade50
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.lightbulb, color: Colors.teal),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Health Tip: Drink at least 2 liters of water daily and walk 30 minutes for a healthy heart.",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Support"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _healthCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
