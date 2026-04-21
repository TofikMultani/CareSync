import 'package:flutter/material.dart';
import 'package:healthcare_system/screens/doctor/doctor_prescriptions.dart';
//import 'package:healthcare_system/screens/patient/upload_report_page.dart';


class PatientProfilePage extends StatelessWidget {
  final String name;
  final String age;
  final String city;
  final String mobile;
  final bool viewModeAdmin;

  const PatientProfilePage({
    super.key,
    required this.name,
    required this.age,
    required this.city,
    required this.mobile,
    this.viewModeAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("Patient Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 Profile Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff11998e), Color(0xff38ef7d)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 36, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text("Age: $age • City: $city",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Mobile: $mobile",
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Basic Information (Dashboard Style)
            const Text(
              "Basic Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  _InfoRow(icon: Icons.cake, label: "Age", value: "29 Years"),
                  _InfoRow(icon: Icons.male, label: "Gender", value: "Male"),
                  _InfoRow(icon: Icons.bloodtype, label: "Blood Group", value: "O+"),
                  _InfoRow(icon: Icons.monitor_weight, label: "Weight", value: "68 kg"),
                  _InfoRow(icon: Icons.height, label: "Height", value: "170 cm"),
                  _InfoRow(icon: Icons.event_available, label: "Last Visit", value: "12 Jan 2026"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Health Summary
            const Text(
              "Health Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _SummaryCard(
              title: "Allergies",
              value: "No Known Allergies",
              icon: Icons.warning_amber,
              color: Colors.orange,
            ),
            _SummaryCard(
              title: "Chronic Condition",
              value: "Diabetes (Type 2)",
              icon: Icons.favorite,
              color: Colors.pink,
            ),

            const SizedBox(height: 30),

            if (!viewModeAdmin) ...[
              // 💊 Give Prescription Button
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
                        builder: (_) => const DoctorPrescriptionPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.medication),
                  label: const Text(
                    "Give Prescription",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------- Reusable Widgets ----------------

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.teal.withOpacity(0.12),
            child: Icon(icon, size: 18, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
