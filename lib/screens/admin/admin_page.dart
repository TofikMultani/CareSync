import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare_system/screens/admin/manage_staff_page.dart';
import 'package:healthcare_system/screens/admin/laboratory_page.dart';
import 'package:healthcare_system/login_page.dart';
import 'package:healthcare_system/screens/admin/manage_doctors_page.dart';
import 'package:healthcare_system/screens/admin/manage_patients_page.dart';
import 'package:healthcare_system/screens/admin/admin_reports_page.dart';
import 'package:healthcare_system/screens/admin/admin_settings_page.dart';
import 'package:healthcare_system/screens/admin/approve_requests_page.dart';
import 'package:healthcare_system/screens/admin/support_chat_list_page.dart';
import 'package:healthcare_system/screens/change_password_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int doctorsCount = 0;
  int patientsCount = 0;
  int staffCount = 0;
  int labTestsCount = 0; // Mock lab tests count
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final doctersQuery = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Doctor').get();
      final patientsQuery = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Patient').get();
      final staffQuery = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Admin').get();
      final labsQuery = await FirebaseFirestore.instance.collection('lab_orders').get();
      
      if (mounted) {
        setState(() {
          doctorsCount = doctersQuery.docs.length;
          patientsCount = patientsQuery.docs.length;
          staffCount = staffQuery.docs.length;
          labTestsCount = labsQuery.docs.length;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: const [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.teal,
                            child:
                                Icon(Icons.admin_panel_settings, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Welcome,",
                                  style: TextStyle(fontSize: 14, color: Colors.grey)),
                              Text(
                                "Administrator",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Stats
                  const Text("System Overview",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      _StatCard(
                          title: "Doctors", value: "$doctorsCount", icon: Icons.local_hospital),
                      const SizedBox(width: 8),
                      _StatCard(title: "Patients", value: "$patientsCount", icon: Icons.group),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatCard(title: "Staff", value: "$staffCount", icon: Icons.people),
                      const SizedBox(width: 8),
                      _StatCard(title: "Lab Tests", value: "$labTestsCount", icon: Icons.science),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Management Section
                  const Text("Management",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _AdminActionTile(
                        icon: Icons.person_add,
                        title: "Manage Doctors",
                        page: const ManageDoctorsPage(),
                        onReturn: _fetchStats,
                      ),
                      _AdminActionTile(
                        icon: Icons.people,
                        title: "Manage Staff",
                        page: const ManageStaffPage(), // ✅ changed
                        onReturn: _fetchStats,
                      ),
                      _AdminActionTile(
                        icon: Icons.science,
                        title: "Laboratory",
                        page: const LaboratoryPage(), // ✅ changed
                        onReturn: _fetchStats,
                      ),
                      _AdminActionTile(
                        icon: Icons.group,
                        title: "Manage Patients",
                        page: const ManagePatientsPage(),
                        onReturn: _fetchStats,
                      ),
                      _AdminActionTile(
                        icon: Icons.approval,
                        title: "Approve Requests",
                        page: const ApproveRequestsPage(),
                        onReturn: _fetchStats,
                      ),
                      _AdminActionTile(
                        icon: Icons.settings,
                        title: "Settings",
                        page: const AdminSettingsPage(),
                        onReturn: _fetchStats,
                      ),
                      _AdminActionTile(
                        icon: Icons.support_agent,
                        title: "Support Chats",
                        page: const SupportChatListPage(),
                        onReturn: _fetchStats,
                      ),
                      _AdminActionTile(
                        icon: Icons.security,
                        title: "Change Password",
                        page: const ChangePasswordPage(),
                        onReturn: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: Icon(icon, color: Colors.teal),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12)),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget page;
  final VoidCallback onReturn;

  const _AdminActionTile({
    required this.icon,
    required this.title,
    required this.page,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
          onReturn();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
