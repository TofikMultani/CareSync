import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare_system/screens/doctor/doctor_patient_history_page.dart';  // Added import

class DoctorPatientsPage extends StatefulWidget {
  const DoctorPatientsPage({super.key});

  @override
  State<DoctorPatientsPage> createState() => _DoctorPatientsPageState();
}

class _DoctorPatientsPageState extends State<DoctorPatientsPage> {
  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignedPatients();
  }

  Future<void> _fetchAssignedPatients() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      // 1. Fetch appointments where doctorId == current user
      QuerySnapshot apptSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: user.uid)
          .get();

      // 2. Extract unique patient IDs
      Set<String> patientIds = {};
      for (var doc in apptSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('patientId') && data['patientId'] != null) {
          patientIds.add(data['patientId']);
        }
      }

      if (patientIds.isEmpty) {
        setState(() {
          patients = [];
          isLoading = false;
        });
        return;
      }

      // 3. Fetch patient details
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Patient')
          .get();

      List<Map<String, dynamic>> matchingPatients = [];
      for (var doc in usersSnapshot.docs) {
        if (patientIds.contains(doc.id)) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Added id
          matchingPatients.add(data);
        }
      }

      setState(() {
        patients = matchingPatients;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Patients"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty 
              ? const Center(child: Text("You have no assigned patients yet."))
              : ListView.builder(
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
                        title: Text(patient["fullName"] ?? "Unknown Patient",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "Age: ${patient["age"] ?? "N/A"} • City: ${patient["city"] ?? "N/A"}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          if (patient["id"] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorPatientHistoryPage(
                                  patientId: patient["id"],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
