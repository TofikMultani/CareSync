import 'package:flutter/material.dart';
import 'package:healthcare_system/screens/patient/appointment_page.dart';
import 'package:healthcare_system/screens/patient/report_page.dart';
import 'package:healthcare_system/screens/patient/prescription_page.dart';
import 'package:healthcare_system/screens/patient/patient_profile_page.dart';
import 'package:healthcare_system/app_drawer.dart';
import 'package:healthcare_system/screens/patient/support_page.dart';
import 'package:healthcare_system/screens/patient/upload_report_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Future<void> _onBottomNavTap(int index) async {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SupportPage()),
      );
      if (!mounted) return;
      setState(() {
        _currentIndex = 0;
      });
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PatientProfilePage()),
      );
      if (!mounted) return;
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                    child: Icon(Icons.person, size: 30, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Welcome back,",
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 4),
                      Text(
                        "Patient Name",
                        style: TextStyle(
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

                  const Text("Upcoming Appointment",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading:
                          const Icon(Icons.event_available, color: Colors.teal),
                      title: const Text("Dr. Sharma"),
                      subtitle: const Text("Tomorrow • 10:00 AM • Cardiology"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AppointmentPage()),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text("Active Prescriptions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.medication, color: Colors.teal),
                      title: const Text("Paracetamol"),
                      subtitle: const Text("1 Tablet - Morning & Night"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrescriptionPage()),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text("Recent Reports",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.description, color: Colors.teal),
                      title: const Text("Blood Test Report"),
                      subtitle: const Text("Uploaded on 12 Jan 2026"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReportPage()),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 📎 Upload Reports Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                        );
                      },
                      icon: const Icon(Icons.upload_file, color: Colors.teal),
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

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade100, Colors.teal.shade50],
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
