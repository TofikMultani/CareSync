import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare_system/screens/patient/patient_details_page.dart';
class ManagePatientsPage extends StatefulWidget {
  const ManagePatientsPage({super.key});

  @override
  State<ManagePatientsPage> createState() => _ManagePatientsPageState();
}

class _ManagePatientsPageState extends State<ManagePatientsPage> {
  List<Map<String, dynamic>> patients = [];
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
        patients = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _togglePatientStatus(String id, bool currentlyActive) async {
    try {
      String newStatus = currentlyActive ? 'Inactive' : 'Active';
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'status': newStatus,
      });
      _fetchPatients(); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Patient marked $newStatus')));
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Patients'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or city',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : patients.isEmpty
                    ? const Center(child: Text("No patients found"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          final isActive = patient['status'] != 'Inactive';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: isActive ? Colors.white : Colors.orange.withOpacity(0.08),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isActive ? Colors.teal : Colors.grey,
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(patient['fullName'] ?? 'Unknown'),
                              subtitle: Text(
                                  'Age: ${patient['age'] ?? 'N/A'} • City: ${patient['city'] ?? 'N/A'} • ${isActive ? 'Active' : 'Inactive'}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility,
                                        color: Colors.teal),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PatientProfilePage(
                                            name: patient['fullName'] ?? 'Unknown',
                                            age: patient['age']?.toString() ?? 'N/A',
                                            city: patient['city'] ?? 'N/A',
                                            mobile: patient['mobile'] ?? patient['phone'] ?? 'N/A',
                                            viewModeAdmin: true,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(isActive ? Icons.block : Icons.check_circle,
                                        color: isActive ? Colors.redAccent : Colors.green),
                                    onPressed: () {
                                      _togglePatientStatus(patient['id'], isActive);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
