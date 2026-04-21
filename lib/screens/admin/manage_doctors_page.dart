import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare_system/screens/admin/add_doctor_page.dart';
import 'package:healthcare_system/screens/admin/edit_doctor_page.dart';
import 'package:healthcare_system/screens/admin/admin_view_doctor_schedule.dart';

class ManageDoctorsPage extends StatefulWidget {
  const ManageDoctorsPage({super.key});

  @override
  State<ManageDoctorsPage> createState() => _ManageDoctorsPageState();
}

class _ManageDoctorsPageState extends State<ManageDoctorsPage> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Doctor')
          .get();

      setState(() {
        doctors = snapshot.docs.map((doc) {
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

  Future<void> _toggleDoctorStatus(String id, bool currentlyActive) async {
    try {
      String newStatus = currentlyActive ? 'Inactive' : 'Active';
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'status': newStatus,
      });
      _fetchDoctors(); // Refresh
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Doctor marked as $newStatus")));
      }
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Doctors'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDoctorPage()),
          ).then((_) => _fetchDoctors()); // Refresh on return
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Doctor'),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : doctors.isEmpty
              ? const Center(child: Text("No doctors found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    final isActive = doctor['status'] != 'Inactive'; // Default to active if status is missing
                    return Card(
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withOpacity(0.15),
                          child: const Icon(Icons.medical_services, color: Colors.teal),
                        ),
                        title: Text(doctor['fullName'] ?? 'Unknown'),
                        subtitle: Text('${doctor['specialty'] ?? 'General'} • ${isActive ? 'Active' : 'Inactive'}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'Edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditDoctorPage(
                                    doctorId: doctor['id'],
                                    doctorData: doctor,
                                  ),
                                ),
                              ).then((_) => _fetchDoctors());
                            } else if (value == 'ToggleStatus') {
                              _toggleDoctorStatus(doctor['id'], isActive);
                            } else if (value == 'View Schedule') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminViewDoctorSchedule(
                                    doctorId: doctor['id'],
                                    doctorName: doctor['fullName'] ?? 'Dr.',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${doctor['fullName']} • $value')),
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'View Schedule', child: Text('View Schedule')),
                            PopupMenuItem(
                                value: 'ToggleStatus', 
                                child: Text(isActive ? 'Deactivate' : 'Activate')
                            ),
                          ],
                        ),
                        tileColor: isActive
                            ? Colors.white
                            : Colors.orange.withOpacity(0.08),
                      ),
                    );
                  },
                ),
    );
  }
}
