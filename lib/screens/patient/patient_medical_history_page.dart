import 'package:flutter/material.dart';

class PatientMedicalHistoryPage extends StatelessWidget {
  const PatientMedicalHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      {
        "date": "10 Jan 2026",
        "doctor": "Dr. Sharma",
        "note": "Fever & cold"
      },
      {
        "date": "28 Jan 2026",
        "doctor": "Dr. Mehta",
        "note": "Stomach pain"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final record = history[index];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading:
                  const Icon(Icons.history, color: Colors.teal),
              title: Text(record["doctor"]!),
              subtitle: Text("${record["note"]} • ${record["date"]}"),
            ),
          );
        },
      ),
    );
  }
}
