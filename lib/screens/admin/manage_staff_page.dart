import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare_system/screens/admin/add_staff_page.dart';
import 'package:healthcare_system/screens/admin/edit_staff_page.dart';

class ManageStaffPage extends StatefulWidget {
  const ManageStaffPage({super.key});

  @override
  State<ManageStaffPage> createState() => _ManageStaffPageState();
}

class _ManageStaffPageState extends State<ManageStaffPage> {
  List<Map<String, dynamic>> staffList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    try {
      // Query users where role is Staff
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Staff')
          .get();

      if (mounted) {
        setState(() {
          staffList = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleStaffStatus(String id, bool currentlyActive) async {
    try {
      String newStatus = currentlyActive ? 'Inactive' : 'Active';
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'status': newStatus,
      });
      _fetchStaff(); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Staff marked as $newStatus")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Staff'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStaffPage()),
          ).then((_) => _fetchStaff());
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : staffList.isEmpty
              ? const Center(child: Text("No staff members found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: staffList.length,
                  itemBuilder: (context, index) {
                    final staff = staffList[index];
                    final isActive = staff['status'] != 'Inactive';
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withOpacity(0.15),
                          child:
                              const Icon(Icons.support_agent, color: Colors.teal),
                        ),
                        title: Text(staff['fullName'] ?? 'Unknown'),
                        subtitle: Text(
                            '${staff['title'] ?? 'Staff'} • ${isActive ? 'Active' : 'Inactive'}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'Edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditStaffPage(
                                    staffId: staff['id'],
                                    staffData: staff,
                                  ),
                                ),
                              ).then((_) => _fetchStaff());
                            } else if (value == 'ToggleStatus') {
                              _toggleStaffStatus(staff['id'], isActive);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'Edit', child: Text('Edit')),
                            PopupMenuItem(
                                value: 'ToggleStatus',
                                child: Text(isActive ? 'Deactivate' : 'Activate')),
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
