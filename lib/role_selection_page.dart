import 'package:flutter/material.dart';
import 'package:healthcare_system/screens/patient/home_page.dart';
import 'package:healthcare_system/screens/doctor/doctor_page.dart';
import 'package:healthcare_system/screens/admin/admin_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Select Role"), backgroundColor: Colors.teal),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _roleCard(context, "Patient", Icons.person, const HomePage()),
          _roleCard(context, "Doctor", Icons.medical_services,
              const DoctorPage()),
          _roleCard(context, "Admin", Icons.admin_panel_settings,
              const AdminPage()),
        ],
      ),
    );
  }

  Widget _roleCard(
      BuildContext context, String title, IconData icon, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => page));
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.teal),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
