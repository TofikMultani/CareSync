import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminViewDoctorSchedule extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const AdminViewDoctorSchedule({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AdminViewDoctorSchedule> createState() => _AdminViewDoctorScheduleState();
}

class _AdminViewDoctorScheduleState extends State<AdminViewDoctorSchedule> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: widget.doctorId)
          .get();

      if (mounted) {
        setState(() {
          var docs = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          docs.sort((a, b) {
            Timestamp tA = a['date'] ?? Timestamp.now();
            Timestamp tB = b['date'] ?? Timestamp.now();
            return tA.compareTo(tB);
          });
          appointments = docs;
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
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: Text("Dr. ${widget.doctorName}'s Schedule"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? const Center(child: Text("No appointments found for this doctor."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    String time = appt['time'] ?? 'Unknown Time';
                    DateTime dateVar = (appt['date'] as Timestamp).toDate();
                    String dateStr = "${dateVar.day}/${dateVar.month}/${dateVar.year}";

                    return _AdminAppointmentCard(
                      name: appt['patientName'] ?? 'Unknown Patient',
                      time: "$dateStr at $time",
                      status: appt['status'] ?? 'Pending',
                    );
                  },
                ),
    );
  }
}

class _AdminAppointmentCard extends StatelessWidget {
  final String name;
  final String time;
  final String status;

  const _AdminAppointmentCard({
    required this.name,
    required this.time,
    required this.status,
  });

  Color getStatusColor() {
    switch (status) {
      case "Confirmed":
        return Colors.green;
      case "Pending":
      case "Pending Review":
        return Colors.orange;
      case "Completed":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: getStatusColor().withOpacity(0.15),
              child: Icon(Icons.calendar_today, color: getStatusColor()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Patient: $name",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Time: $time",
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                    color: getStatusColor(), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
