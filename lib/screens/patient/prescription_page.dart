import 'package:flutter/material.dart';
import 'package:healthcare_system/screens/patient/prescription_details_page.dart';

class PrescriptionPage extends StatelessWidget {
  const PrescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Prescriptions"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _prescriptionCard(
            context,
            doctor: "Dr. Sharma",
            date: "28 Jan 2026",
            medicines: [
              {"name": "Paracetamol", "time": "Morning & Night"},
              {"name": "Vitamin D", "time": "Once Daily"},
            ],
          ),
          _prescriptionCard(
            context,
            doctor: "Dr. Mehta",
            date: "20 Jan 2026",
            medicines: [
              {"name": "Amoxicillin", "time": "Morning"},
            ],
          ),
        ],
      ),
    );
  }

  Widget _prescriptionCard(
    BuildContext context, {
    required String doctor,
    required String date,
    required List<Map<String, String>> medicines,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.teal),
        title: Text("Doctor: $doctor"),
        subtitle: Text("Date: $date"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: const Text("View Details"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrescriptionDetailsPage(
                  doctor: doctor,
                  date: date,
                  medicines: medicines,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
