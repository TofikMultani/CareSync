import 'package:healthcare_system/screens/admin/staff_page.dart';
import 'package:healthcare_system/screens/admin/laboratory_page.dart';
import 'package:healthcare_system/login_page.dart'; // add this import at top
import 'package:healthcare_system/screens/doctor/doctor_page.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          )
        ],

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.admin_panel_settings,
                          color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome,",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(
                          "Administrator",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Stats
            const Text("System Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Row(
              children: const [
                _StatCard(title: "Doctors", value: "12", icon: Icons.local_hospital),
                SizedBox(width: 8),
                _StatCard(title: "Patients", value: "120", icon: Icons.group),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                _StatCard(title: "Staff", value: "20", icon: Icons.people),
                SizedBox(width: 8),
                _StatCard(title: "Lab Tests", value: "35", icon: Icons.science),
              ],
            ),

            const SizedBox(height: 16),

            // Management Section
            const Text("Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _AdminActionTile(
                icon: Icons.person_add,
                title: "Manage Doctors",
                page: DoctorPage(),
              ),
              _AdminActionTile(
                icon: Icons.people,
                title: "Manage Staff",
                page: StaffPage(),       // ✅ changed
              ),
              _AdminActionTile(
                icon: Icons.science,
                title: "Laboratory",
                page: LaboratoryPage(), // ✅ changed
              ),
              _AdminActionTile(
                icon: Icons.group,
                title: "Manage Patients",
                page: DoctorPage(),     // (we’ll replace later with PatientPage)
              ),
              _AdminActionTile(
                icon: Icons.bar_chart,
                title: "Reports",
                page: DoctorPage(),     // (you can create ReportsPage later)
              ),
              _AdminActionTile(
                icon: Icons.settings,
                title: "Settings",
                page: DoctorPage(),     // (optional future page)
              ),
            ],
          ),


          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: Icon(icon, color: Colors.teal),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12)),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget page;

  const _AdminActionTile({
    required this.icon,
    required this.title,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
