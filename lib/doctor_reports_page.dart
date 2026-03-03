import 'package:flutter/material.dart';

class DoctorReportsPage extends StatelessWidget {
  const DoctorReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: Column(
        children: [
          _Header(title: "Patient Reports"),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _ReportCard(
                  patient: "Rahul Patel",
                  report: "Blood Test",
                  date: "12 Feb 2026",
                ),
                _ReportCard(
                  patient: "Neha Shah",
                  report: "X-Ray Report",
                  date: "10 Feb 2026",
                ),
                _ReportCard(
                  patient: "Amit Desai",
                  report: "MRI Scan",
                  date: "08 Feb 2026",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String patient;
  final String report;
  final String date;

  const _ReportCard({
    required this.patient,
    required this.report,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.15),
          child: const Icon(Icons.description, color: Colors.orange),
        ),
        title: Text(patient, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$report • $date"),
        trailing: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.visibility),
          label: const Text("View"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff11998e), Color(0xff38ef7d)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 16,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
