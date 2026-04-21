import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare_system/notification_service.dart';
import 'package:healthcare_system/screens/doctor/doctor_reports_page.dart';
import 'package:healthcare_system/screens/patient/patient_medical_history_page.dart';

class DoctorPrescriptionPage extends StatefulWidget {
  const DoctorPrescriptionPage({super.key});

  @override
  State<DoctorPrescriptionPage> createState() => _DoctorPrescriptionPageState();
}

class _DoctorPrescriptionPageState extends State<DoctorPrescriptionPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedPatientId;
  String? selectedPatientName;
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  bool morning = false;
  bool afternoon = false;
  bool night = false;

  List<Map<String, dynamic>> patientsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Patient')
          .get();

      setState(() {
        patientsList = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['fullName'] ?? 'Unknown Patient',
          };
        }).toList();

        if (patientsList.isNotEmpty) {
          selectedPatientId = patientsList[0]['id'];
          selectedPatientName = patientsList[0]['name'];
        }
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a patient")),
      );
      return;
    }

    if (!morning && !afternoon && !night) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one timing")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String doctorName = doctorDoc.exists ? (doctorDoc.get('fullName') ?? 'Doctor') : 'Doctor';

      String timing = [
        if (morning) "Morning",
        if (afternoon) "Afternoon",
        if (night) "Night",
      ].join(" & ");

      await FirebaseFirestore.instance.collection('prescriptions').add({
        'patientId': selectedPatientId,
        'patientName': selectedPatientName,
        'doctorId': user.uid,
        'doctorName': doctorName,
        'medicines': [
          {
            'name': _medicineController.text.trim(),
            'time': timing,
            'duration': _durationController.text.trim(),
          }
        ],
        'medicationName': _medicineController.text.trim(),
        'dosage': "${_dosageController.text.trim()} - $timing for ${_durationController.text.trim()}",
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 🔔 REAL MOBILE NOTIFICATION
      await NotificationService.sendPrescriptionNotification(selectedPatientName ?? 'Patient');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Prescription saved & patient notified 🔔")),
        );
        _medicineController.clear();
        _dosageController.clear();
        _durationController.clear();
        setState(() {
          morning = false;
          afternoon = false;
          night = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving prescription: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Prescription"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Patient Details",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            
                            patientsList.isEmpty
                                ? const Text("No patients available.")
                                : DropdownButtonFormField<String>(
                                    value: selectedPatientId,
                                    decoration: const InputDecoration(
                                      labelText: "Select Patient",
                                      prefixIcon: Icon(Icons.person),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: patientsList.map((doc) {
                                      return DropdownMenuItem<String>(
                                        value: doc['id'],
                                        child: Text(doc['name']),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedPatientId = val;
                                        selectedPatientName = patientsList.firstWhere((p) => p['id'] == val)['name'];
                                      });
                                    },
                                  ),

                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _medicineController,
                              decoration: const InputDecoration(
                                labelText: "Medicine Name",
                                prefixIcon: Icon(Icons.medication),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Enter medicine name" : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _dosageController,
                              decoration: const InputDecoration(
                                labelText: "Dosage (e.g. 1 tablet)",
                                prefixIcon: Icon(Icons.local_hospital),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Enter dosage" : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _durationController,
                              decoration: const InputDecoration(
                                labelText: "Duration (e.g. 5 days)",
                                prefixIcon: Icon(Icons.timer),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Enter duration" : null,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Timing",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            CheckboxListTile(
                              title: const Text("Morning"),
                              value: morning,
                              onChanged: (val) => setState(() => morning = val!),
                            ),
                            CheckboxListTile(
                              title: const Text("Afternoon"),
                              value: afternoon,
                              onChanged: (val) => setState(() => afternoon = val!),
                            ),
                            CheckboxListTile(
                              title: const Text("Night"),
                              value: night,
                              onChanged: (val) => setState(() => night = val!),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                icon: const Icon(Icons.save),
                                label: const Text("Save Prescription"),
                                onPressed: _savePrescription,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text("View Uploaded Reports"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DoctorReportsPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.history),
                      label: const Text("View Patient Medical History"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PatientMedicalHistoryPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
