import 'package:flutter/material.dart';
import 'patient_details_page.dart';

class DoctorPatientsPage extends StatelessWidget {
  const DoctorPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = [
      {
        "name": "Rahul Patel",
        "age": "22",
        "city": "Ahmedabad",
        "mobile": "+91 9876543210",
      },
      {
        "name": "Neha Shah",
        "age": "24",
        "city": "Surat",
        "mobile": "+91 9123456789",
      },
      {
        "name": "Amit Mehta",
        "age": "30",
        "city": "Vadodara",
        "mobile": "+91 9988776655",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Patients"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];

          return Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(patient["name"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "Age: ${patient["age"]} • City: ${patient["city"]}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientProfilePage(
                      name: patient["name"]!,
                      age: patient["age"]!,
                      city: patient["city"]!,
                      mobile: patient["mobile"]!,
                    ),
                  ),
                );

              },
            ),
          );
        },
      ),
    );
  }
}
