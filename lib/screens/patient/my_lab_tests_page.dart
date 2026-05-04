import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:healthcare_system/screens/patient/payment_gateway_page.dart';
import 'package:google_fonts/google_fonts.dart';

class MyLabTestsPage extends StatefulWidget {
  const MyLabTestsPage({super.key});

  @override
  State<MyLabTestsPage> createState() => _MyLabTestsPageState();
}

class _MyLabTestsPageState extends State<MyLabTestsPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final Color primaryColor = const Color(0xFF059669);
  final Color backgroundColor = const Color(0xFFF8FAFC);

  void _openResult(String url) async {
    if (url.toLowerCase().contains('.jpg') || url.toLowerCase().contains('.png') || url.toLowerCase().contains('.jpeg')) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
         appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
         backgroundColor: Colors.black,
         body: Center(child: InteractiveViewer(child: Image.network(url))),
       )));
       return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not launch file', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: Text("Not Logged In", style: GoogleFonts.plusJakartaSans())),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("My Lab Tests", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A))),
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lab_orders')
            .where('patientId', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.biotech_rounded, size: 80, color: primaryColor.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 24),
                  Text("No lab tests found.", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Text("Your ordered tests will appear here", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs.toList();
          
          // Sort locally inside Dart to avoid Firebase composite index block
          docs.sort((a, b) {
            final dateA = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final dateB = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            return (dateB ?? Timestamp.now()).compareTo(dateA ?? Timestamp.now());
          });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final orderId = docs[index].id;
              
              final isCompleted = data['status'] == 'Completed';
              final isPaid = data['paymentStatus'] == 'Paid';
              final createdAt = data['createdAt'] as Timestamp?;
              final dateStr = createdAt != null ? DateFormat('dd MMM yyyy').format(createdAt.toDate()) : 'Unknown Date';

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
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCompleted ? primaryColor.withOpacity(0.1) : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.science_rounded, color: isCompleted ? primaryColor : Colors.orange.shade600, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['testName'] ?? 'Lab Test',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Ordered on $dateStr", 
                                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCompleted ? primaryColor.withOpacity(0.1) : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data['status'] ?? 'Pending',
                              style: GoogleFonts.plusJakartaSans(
                                color: isCompleted ? primaryColor : Colors.orange.shade700, 
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Amount", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text("\$${data['price']?.toString() ?? '0.00'}", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                            ],
                          ),
                          if (isPaid)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: primaryColor, size: 16),
                                  const SizedBox(width: 6),
                                  Text("Paid", style: GoogleFonts.plusJakartaSans(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                bool? success = await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentGatewayPage(
                                  title: data['testName'] ?? 'Lab Test',
                                  amount: data['price'] != null ? (data['price'] is int ? (data['price'] as int).toDouble() : data['price'] as double) : 0.0,
                                )));
                                if (success == true) {
                                  await FirebaseFirestore.instance.collection('lab_orders').doc(orderId).update({
                                    'paymentStatus': 'Paid',
                                    'paidAt': FieldValue.serverTimestamp(),
                                  });
                                }
                              },
                              child: Text("Pay Now", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
                            )
                        ],
                      ),

                      if (data['resultFileUrl'] != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: () => _openResult(data['resultFileUrl']),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "View Test Results", 
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
