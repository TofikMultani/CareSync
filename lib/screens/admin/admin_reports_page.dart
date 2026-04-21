import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  int totalAppointments = 0;
  int completedLabTests = 0;
  int activeDoctors = 0;
  int openSupportTickets = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final apptsQuery = await FirebaseFirestore.instance.collection('appointments').get();
      final labsQuery = await FirebaseFirestore.instance.collection('reports').get();
      final doctorsQuery = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Doctor').get();
      final chatsQuery = await FirebaseFirestore.instance.collection('support_chats').get();

      if (mounted) {
        setState(() {
          totalAppointments = apptsQuery.docs.length;
          completedLabTests = labsQuery.docs.length; // Simplified
          activeDoctors = doctorsQuery.docs.length;
          openSupportTickets = chatsQuery.docs.length;
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
        title: const Text('System Reports'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _metricCard(
                    'Total Appointments', '$totalAppointments', Icons.calendar_month, Colors.teal),
                _metricCard(
                    'Lab Reports', '$completedLabTests', Icons.science, Colors.green),
                _metricCard(
                    'Active Doctors', '$activeDoctors', Icons.local_hospital, Colors.blue),
                _metricCard(
                    'Open Support Tickets', '$openSupportTickets', Icons.support_agent, Colors.orange),
                const SizedBox(height: 12),
                Card(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.file_download, color: Colors.teal),
                    title: const Text('Download Monthly Summary'),
                    subtitle:
                        const Text('PDF export UI is ready for backend integration.'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Report export endpoint can be connected next.')),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
