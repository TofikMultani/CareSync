import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare_system/screens/patient/prescription_details_page.dart';
import 'package:intl/intl.dart';

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  List<Map<String, dynamic>> prescriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  Future<void> _fetchPrescriptions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('prescriptions')
            .where('patientId', isEqualTo: user.uid)
            .get();

        setState(() {
          var docs = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          docs.sort((a, b) {
            Timestamp tA = a['createdAt'] ?? Timestamp.now();
            Timestamp tB = b['createdAt'] ?? Timestamp.now();
            return tB.compareTo(tA);
          });
          prescriptions = docs;
          isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Prescriptions"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : prescriptions.isEmpty
              ? const Center(child: Text("No prescriptions found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prescriptions.length,
                  itemBuilder: (context, index) {
                    final data = prescriptions[index];
                    String doctor = data['doctorName'] ?? "Unknown Doctor";
                    String date = data['createdAt'] != null
                        ? DateFormat('dd MMM yyyy').format((data['createdAt'] as Timestamp).toDate())
                        : "Unknown Date";

                    List<Map<String, String>> medicines = [];
                    if (data['medicines'] != null) {
                       for(var item in data['medicines']) {
                         medicines.add({
                           "name": item['name'] ?? "Unknown",
                           "time": item['time'] ?? "Unknown"
                         });
                       }
                    } else {
                      medicines.add({
                        "name": data['medicationName'] ?? "Unknown",
                        "time": data['dosage'] ?? "Unknown"
                      });
                    }

                    return _prescriptionCard(
                      context,
                      doctor: doctor,
                      date: date,
                      medicines: medicines,
                    );
                  },
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
