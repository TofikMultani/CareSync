import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare_system/screens/patient/prescription_details_page.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  List<Map<String, dynamic>> prescriptions = [];
  bool isLoading = true;

  final Color primaryColor = const Color(0xFF059669);
  final Color backgroundColor = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  Future<void> _fetchPrescriptions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('prescriptions')
            .where('patientId', isEqualTo: user.uid)
            .get();

        setState(() {
          var docs = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          docs.sort((a, b) {
            Timestamp tA = a['createdAt'] ?? Timestamp.now();
            Timestamp tB = b['createdAt'] ?? Timestamp.now();
            return tB.compareTo(tA);
          });
          prescriptions = docs;
          isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("My Prescriptions", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A))),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : prescriptions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.receipt_long_rounded, size: 80, color: primaryColor.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 24),
                      Text("No Prescriptions Yet", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      Text("Your prescriptions will be listed here.", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: prescriptions.length,
                  itemBuilder: (context, index) {
                    final data = prescriptions[index];
                    String doctor = data['doctorName'] ?? "Unknown Doctor";
                    String date = data['createdAt'] != null
                        ? DateFormat('dd MMM yyyy').format((data['createdAt'] as Timestamp).toDate())
                        : "Unknown Date";

                    List<Map<String, String>> medicines = [];
                    if (data['medicines'] != null) {
                       for(var item in data['medicines']) {
                         medicines.add({
                           "name": item['name'] ?? "Unknown",
                           "time": item['time'] ?? "Unknown"
                         });
                       }
                    } else {
                      medicines.add({
                        "name": data['medicationName'] ?? "Unknown",
                        "time": data['dosage'] ?? "Unknown"
                      });
                    }

                    return _prescriptionCard(
                      context,
                      doctor: doctor,
                      date: date,
                      medicines: medicines,
                    );
                  },
                ),
    );
  }

  Widget _prescriptionCard(
    BuildContext context, {
    required String doctor,
    required String date,
    required List<Map<String, String>> medicines,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.medical_information_rounded, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor,
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.medication_liquid_rounded, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${medicines.length} Medicine(s) Prescribed",
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrescriptionDetailsPage(
                        doctor: doctor,
                        date: date,
                        medicines: medicines,
                      ),
                    ),
                  );
                },
                child: Text("View Details", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
