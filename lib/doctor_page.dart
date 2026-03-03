import 'package:flutter/material.dart';
import 'doctor_patients_page.dart';
import 'doctor_prescriptions.dart';
import 'approve_requests_page.dart';
import 'doctor_appointments_page.dart';
//import 'doctor_patient_history_page.dart';


class DoctorPage extends StatelessWidget {
  const DoctorPage({super.key});

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
                              children: const [
                                Text("Good Morning 👋",
                                    style: TextStyle(color: Colors.grey)),
                                SizedBox(height: 4),
                                Text(
                                  "Dr. Sharma",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Text("Have a healthy day!",
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
                                        Navigator.pop(context); // go back to login
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
                      _ActionCard(
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
                      ),
                      _ActionCard(
                        icon: Icons.receipt_long,
                        title: "View Reports",
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DoctorReportsPage()),
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
                            MaterialPageRoute(builder: (_) => const DoctorAppointmentsPage()),
                          );
                        },
                      ),
                      // _ActionCard(
                      //   icon: Icons.history_edu,
                      //   title: "Patient History",
                      //   color: Colors.brown,
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (_) => const DoctorPatientHistoryPage(),
                      //       ),
                      //     );
                      //   },
                      // ),

                      _ActionCard(
                        icon: Icons.notifications_active,
                        title: "Notifications",
                        color: Colors.redAccent,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Notifications Page Coming Soon")),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🔸 Pending Requests
                  const Text(
                    "Pending Patient Requests",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _RequestTile(
                    name: "Rahul Patel",
                    request: "Appointment Approval",
                    onApprove: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ApproveRequestsPage()),
                      );
                    },
                  ),
                  _RequestTile(
                    name: "Neha Shah",
                    request: "Report Review",
                    onApprove: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ApproveRequestsPage()),
                      );
                    },
                  ),
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
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
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
          child: const Text("Review"),
        ),
      ),
    );
  }
}
