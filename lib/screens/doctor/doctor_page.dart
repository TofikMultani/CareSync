import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare_system/screens/doctor/doctor_patients_page.dart';
import 'package:healthcare_system/screens/doctor/doctor_prescriptions.dart';
import 'package:healthcare_system/screens/doctor/doctor_reports_page.dart';
import 'package:healthcare_system/screens/admin/approve_requests_page.dart';
import 'package:healthcare_system/screens/doctor/doctor_appointments_page.dart';
import 'package:healthcare_system/login_page.dart';
import 'package:healthcare_system/notification_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthcare_system/screens/change_password_page.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  String doctorName = "Loading...";
  List<Map<String, dynamic>> pendingRequests = [];
  int confirmedCount = 0;
  int completedCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            doctorName = doc.get('fullName') ?? 'Doctor';
          });
        }

        QuerySnapshot apptSnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: user.uid)
            .get();

        if (mounted) {
          setState(() {
            pendingRequests = [];
            confirmedCount = 0;
            completedCount = 0;

            for (var doc in apptSnapshot.docs) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              
              if (data['status'] == 'Pending') {
                pendingRequests.add(data);
              } else if (data['status'] == 'Confirmed') {
                confirmedCount++;
              } else if (data['status'] == 'Completed') {
                completedCount++;
              }
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            doctorName = 'Doctor';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
            doctorName = 'Guest';
        });
      }
    }
  }

  Future<void> _approveAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).update({
        'status': 'Confirmed',
      });
      // Refresh list
      _fetchDoctorData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment Confirmed")),
      );
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔷 Header Section
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff11998e), Color(0xff38ef7d)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.medical_services,
                                color: Colors.teal, size: 30),
                          ),
                          const SizedBox(width: 12),

                          // 👨‍⚕️ Doctor Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Good Morning 👋",
                                    style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  doctorName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                const Text("Have a healthy day!",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),

                          // 🚪 Logout Button
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Logout"),
                                  content: const Text(
                                      "Are you sure you want to logout?"),
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
                                        FirebaseAuth.instance.signOut();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginPage()),
                                          (route) => false,
                                        );
                                      },
                                      child: const Text("Logout"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Actions Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Appointments Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Analytics Chart
                  SizedBox(
                    height: 180,
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Stack(
                                children: [
                                  const Center(child: Text("Appts", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 25,
                                      sections: [
                                        PieChartSectionData(color: Colors.orange, value: pendingRequests.length.toDouble(), title: '${pendingRequests.length}', radius: 35, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                        PieChartSectionData(color: Colors.blue, value: confirmedCount.toDouble(), title: '$confirmedCount', radius: 35, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                        PieChartSectionData(color: Colors.green, value: completedCount.toDouble(), title: '$completedCount', radius: 35, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LegendItem(color: Colors.orange, text: "Pending (${pendingRequests.length})"),
                              const SizedBox(height: 8),
                              _LegendItem(color: Colors.blue, text: "Confirmed ($confirmedCount)"),
                              const SizedBox(height: 8),
                              _LegendItem(color: Colors.green, text: "Completed ($completedCount)"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Doctor Actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _ActionCard(
                        icon: Icons.group,
                        title: "View Patients",
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DoctorPatientsPage()),
                          );
                        },
                      ),
                      /* _ActionCard(
                        icon: Icons.check_circle,
                        title: "Approve Requests",
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ApproveRequestsPage()),
                          );
                        },
                      ), */ // Approvals now shown below
                      _ActionCard(
                        icon: Icons.receipt_long,
                        title: "View Reports",
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DoctorReportsPage()),
                          );
                        },
                      ),
                      _ActionCard(
                        icon: Icons.medication,
                        title: "Give Prescription",
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DoctorPrescriptionPage()),
                          );
                        },
                      ),
                      _ActionCard(
                        icon: Icons.calendar_month,
                        title: "My Appointments",
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DoctorAppointmentsPage()),
                          ).then((_) => _fetchDoctorData());
                        },
                      ),

                      _ActionCard(
                        icon: Icons.notifications_active,
                        title: "Notifications",
                        color: Colors.redAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationPage(),
                            ),
                          );
                        },
                      ),
                      _ActionCard(
                        icon: Icons.security,
                        title: "Change Password",
                        color: Colors.blueGrey,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChangePasswordPage()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🔸 Pending Requests
                  const Text(
                    "Pending Patient Requests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (pendingRequests.isEmpty)
                    const Text("No pending appointment requests."),
                  
                  ...pendingRequests.map((req) => _RequestTile(
                    name: req['patientName'] ?? 'Unknown Patient',
                    request: "Appointment Request for ${req['time']}",
                    onApprove: () {
                      _approveAppointment(req['id']);
                    },
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Widgets ----------------

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final String name;
  final String request;
  final VoidCallback onApprove;

  const _RequestTile({
    required this.name,
    required this.request,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(request),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: onApprove,
          child: const Text("Approve"),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
