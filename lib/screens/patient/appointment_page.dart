import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare_system/screens/patient/payment_gateway_page.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String? selectedDoctorId;
  String? selectedDoctorName;
  DateTime selectedDate = DateTime.now();
  String selectedTime = "10:00 AM";

  List<Map<String, dynamic>> doctorsList = [];
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

      List<Map<String, dynamic>> doctors = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data.containsKey('fullName') ? data['fullName'] : 'Unknown Doctor',
          'specialty': data.containsKey('specialty') ? data['specialty'] : 'General',
        };
      }).toList();

      setState(() {
        doctorsList = doctors;
        if (doctors.isNotEmpty) {
          selectedDoctorId = doctors[0]['id'];
          selectedDoctorName = doctors[0]['name'];
        }
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching doctors: $e")),
        );
      }
    }
  }

  Future<void> _bookAppointment() async {
    if (selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a doctor")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to book")),
      );
      return;
    }

    try {
      DocumentSnapshot patientDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String patientName = patientDoc.exists ? (patientDoc.get('fullName') ?? 'Patient') : 'Patient';

      final existingSnap = await FirebaseFirestore.instance.collection('appointments')
          .where('patientId', isEqualTo: user.uid)
          .where('doctorId', isEqualTo: selectedDoctorId)
          .get();

      bool hasActive = existingSnap.docs.any((doc) {
        final data = doc.data() as Map<String, dynamic>;
        String status = data.containsKey('status') ? data['status'] : '';
        return status == 'Pending' || status == 'Confirmed' || status == 'Approved';
      });

      if (hasActive) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You already have an active or confirmed appointment with this doctor. Please choose another doctor.")));
        return;
      }

      bool? paymentSuccess = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentGatewayPage(
            amount: 1.00, // Dummy consulting fee for testing
            title: "Consultation: Dr. $selectedDoctorName",
          ),
        ),
      );

      if (paymentSuccess != true) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment was cancelled or failed.")));
        return;
      }

      await FirebaseFirestore.instance.collection('appointments').add({
        'patientId': user.uid,
        'patientName': patientName,
        'doctorId': selectedDoctorId,
        'doctorName': selectedDoctorName,
        'date': Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day)),
        'time': selectedTime,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text("Booking Complete")]),
            content: const Text("Your appointment request has been submitted and payment is verified."),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Done"),
              )
            ],
          ),
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error booking appointment: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment"), backgroundColor: Colors.teal),
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _card(
                    child: doctorsList.isEmpty
                        ? const Text("No doctors available.")
                        : DropdownButtonFormField<String>(
                            value: selectedDoctorId,
                            items: doctorsList.map((doc) {
                              return DropdownMenuItem<String>(
                                value: doc['id'],
                                child: Text("${doc['name']} (${doc['specialty']})"),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedDoctorId = val;
                                selectedDoctorName = doctorsList.firstWhere((doc) => doc['id'] == val)['name'];
                              });
                            },
                            decoration: const InputDecoration(labelText: "Select Doctor"),
                          ),
                  ),
                  _card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, color: Colors.teal),
                      title: const Text("Select Date"),
                      subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          initialDate: selectedDate,
                        );
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                    ),
                  ),
                  _card(
                    child: DropdownButtonFormField<String>(
                      value: selectedTime,
                      items: const [
                        DropdownMenuItem(value: "10:00 AM", child: Text("10:00 AM")),
                        DropdownMenuItem(value: "12:00 PM", child: Text("12:00 PM")),
                        DropdownMenuItem(value: "03:00 PM", child: Text("03:00 PM")),
                      ],
                      onChanged: (val) => setState(() => selectedTime = val!),
                      decoration: const InputDecoration(labelText: "Select Time Slot"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: doctorsList.isEmpty ? null : _bookAppointment,
                      child: const Text("Confirm Appointment"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}
