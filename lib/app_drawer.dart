import 'package:flutter/material.dart';
import 'package:healthcare_system/screens/patient/home_page.dart';
import 'package:healthcare_system/login_page.dart';
import 'package:healthcare_system/screens/patient/appointment_page.dart';
import 'package:healthcare_system/screens/patient/report_page.dart';
import 'package:healthcare_system/screens/patient/prescription_page.dart';
// import 'package:healthcare_system/screens/patient/patient_profile_page.dart'; // ❌ Removed

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.teal),
            accountName: const Text("Patient Name"),
            accountEmail: const Text("patient@email.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.teal, size: 32),
            ),
          ),

          _drawerItem(context, Icons.home, "Home", const HomePage()),
          _drawerItem(context, Icons.calendar_month, "Appointments", const AppointmentPage()),
          _drawerItem(context, Icons.receipt_long, "Reports", const ReportPage()),
          _drawerItem(context, Icons.medication, "Prescriptions", const PrescriptionPage()),

          const Spacer(),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
