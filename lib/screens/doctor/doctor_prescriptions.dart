import 'package:flutter/material.dart';
import 'package:healthcare_system/notification_service.dart';

// Dummy pages (replace with your actual pages)
class DoctorReportsPage extends StatelessWidget {
  const DoctorReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Uploaded Reports")),
      body: const Center(child: Text("Reports will be shown here")),
    );
  }
}

class PatientMedicalHistoryPage extends StatelessWidget {
  const PatientMedicalHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Medical History")),
      body: const Center(child: Text("Medical history will be shown here")),
    );
  }
}

class DoctorPrescriptionPage extends StatefulWidget {
  const DoctorPrescriptionPage({super.key});

  @override
  State<DoctorPrescriptionPage> createState() => _DoctorPrescriptionPageState();
}

class _DoctorPrescriptionPageState extends State<DoctorPrescriptionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();

  bool morning = false;
  bool afternoon = false;
  bool night = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Prescription"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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

                      TextFormField(
                        controller: _patientController,
                        decoration: const InputDecoration(
                          labelText: "Patient Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Enter patient name" : null,
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
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text("Save Prescription"),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (!morning && !afternoon && !night) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Please select at least one timing"),
                                  ),
                                );
                                return;
                              }

                              // 🔔 REAL MOBILE NOTIFICATION
                              await NotificationService
                                  .sendPrescriptionNotification(
                                _patientController.text,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Prescription saved & patient notified 🔔"),
                                ),
                              );

                              _patientController.clear();
                              _medicineController.clear();
                              _dosageController.clear();

                              setState(() {
                                morning = false;
                                afternoon = false;
                                night = false;
                              });
                            }
                          },
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
                        builder: (_) =>
                            const PatientMedicalHistoryPage()),
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
