import 'package:flutter/material.dart';

class DoctorPatientHistoryPage extends StatelessWidget {
  const DoctorPatientHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("Patient History"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 Patient Profile Card
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
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 32, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Rahul Patel",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text("Age: 29 • Male",
                          style: TextStyle(color: Colors.white70)),
                      Text("Patient ID: P1023",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 History Section
            const Text(
              "Medical History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _HistoryCard(
              title: "Fever & Cold",
              date: "12 Jan 2026",
              status: "Recovered",
              statusColor: Colors.green,
              icon: Icons.thermostat,
            ),
            _HistoryCard(
              title: "Blood Pressure Check",
              date: "03 Dec 2025",
              status: "Under Observation",
              statusColor: Colors.orange,
              icon: Icons.favorite,
            ),
            _HistoryCard(
              title: "Diabetes Consultation",
              date: "18 Oct 2025",
              status: "Ongoing",
              statusColor: Colors.redAccent,
              icon: Icons.bloodtype,
            ),

            const SizedBox(height: 24),

            // 🔹 Past Prescriptions
            const Text(
              "Past Prescriptions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _InfoTile(
              title: "Paracetamol + Vitamin C",
              subtitle: "12 Jan 2026",
              icon: Icons.medication,
            ),
            _InfoTile(
              title: "BP Control Tablets",
              subtitle: "03 Dec 2025",
              icon: Icons.receipt_long,
            ),

            const SizedBox(height: 24),

            // 🔹 Reports Section
            const Text(
              "Medical Reports",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _ReportCard(
              reportName: "Blood Test Report",
              date: "04 Dec 2025",
            ),
            _ReportCard(
              reportName: "Sugar Level Report",
              date: "18 Oct 2025",
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Custom Widgets ----------------

class _HistoryCard extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final IconData icon;

  const _HistoryCard({
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(icon, color: statusColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.15),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String reportName;
  final String date;

  const _ReportCard({
    required this.reportName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xffe0f2f1),
          child: Icon(Icons.picture_as_pdf, color: Colors.teal),
        ),
        title: Text(reportName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date),
        trailing: ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          icon: const Icon(Icons.visibility, size: 16),
          label: const Text("View"),
        ),
      ),
    );
  }
}
