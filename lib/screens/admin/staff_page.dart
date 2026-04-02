import 'package:flutter/material.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Dashboard"),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
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
                      child: Icon(Icons.support_agent, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome,", style: TextStyle(fontSize: 14)),
                        Text(
                          "Staff Member",
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

            const Text(
              "Staff Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _StaffActionTile(icon: Icons.app_registration, title: "Register Patient"),
                _StaffActionTile(icon: Icons.calendar_month, title: "Manage Appointments"),
                _StaffActionTile(icon: Icons.receipt, title: "Billing"),
                _StaffActionTile(icon: Icons.group, title: "View Patients"),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Today's Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: const Icon(Icons.task_alt, color: Colors.teal),
                title: const Text("Register new patient"),
                subtitle: const Text("Patient: Aman Verma"),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.task_alt, color: Colors.teal),
                title: const Text("Prepare billing receipt"),
                subtitle: const Text("Patient: Neha Shah"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffActionTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _StaffActionTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title clicked")),
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
