import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare_system/screens/patient/payment_gateway_page.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final List<String> timeSlots = [
    "09:00 AM", "10:00 AM", "11:00 AM",
    "12:00 PM", "02:00 PM", "03:00 PM",
    "04:00 PM", "05:00 PM"
  ];

  List<Map<String, dynamic>> doctorsList = [];
  bool isLoading = true;

  final Color primaryColor = const Color(0xFF059669);
  final Color backgroundColor = const Color(0xFFF8FAFC);

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
            title: "Consultation: . $selectedDoctorName",
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(children: [const Icon(Icons.check_circle, color: Color(0xFF059669)), const SizedBox(width: 8), Text("Booking Complete", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18))]),
            content: Text("Your appointment request has been submitted and payment is verified.", style: GoogleFonts.plusJakartaSans()),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text("Done", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Book Appointment", style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Specialist",
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    child: doctorsList.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("No doctors available.", style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedDoctorId,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontSize: 16),
                              items: doctorsList.map((doc) {
                                return DropdownMenuItem<String>(
                                  value: doc['id'],
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: primaryColor.withOpacity(0.1),
                                        child: Icon(Icons.person, color: primaryColor, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("${doc['name']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                          Text("${doc['specialty']}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedDoctorId = val;
                                  selectedDoctorName = doctorsList.firstWhere((doc) => doc['id'] == val)['name'];
                                });
                              },
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),
                  
                  Text(
                    "Select Date",
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        initialDate: selectedDate,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: primaryColor,
                                onPrimary: Colors.white,
                                onSurface: const Color(0xFF0F172A),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: _card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.calendar_month_rounded, color: primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(
                                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Select Time",
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: timeSlots.map((time) {
                      bool isSelected = selectedTime == time;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTime = time;
                          });
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 60) / 3, // 3 columns
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade200,
                              width: 1.5,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ] : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            time,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF0F172A),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      onPressed: doctorsList.isEmpty ? null : _bookAppointment,
                      child: Text(
                        "Confirm Appointment",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}
