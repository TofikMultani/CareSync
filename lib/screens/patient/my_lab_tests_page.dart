import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:healthcare_system/screens/patient/payment_gateway_page.dart';

class MyLabTestsPage extends StatefulWidget {
  const MyLabTestsPage({super.key});

  @override
  State<MyLabTestsPage> createState() => _MyLabTestsPageState();
}

class _MyLabTestsPageState extends State<MyLabTestsPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch file')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Scaffold(body: Center(child: Text("Not Logged In")));

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("My Lab Tests", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lab_orders')
            .where('patientId', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.biotech, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No lab tests found.", style: TextStyle(fontSize: 18, color: Colors.grey)),
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
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final orderId = docs[index].id;
              
              final isCompleted = data['status'] == 'Completed';
              final isPaid = data['paymentStatus'] == 'Paid';
              final createdAt = data['createdAt'] as Timestamp?;
              final dateStr = createdAt != null ? DateFormat('dd MMM yyyy').format(createdAt.toDate()) : 'Unknown Date';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            child: Icon(Icons.science, color: isCompleted ? Colors.green : Colors.orange),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['testName'] ?? 'Lab Test',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text("Ordered on $dateStr", style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data['status'] ?? 'Pending',
                              style: TextStyle(color: isCompleted ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Test Amount: \$${data['price']?.toString() ?? '0.00'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (isPaid)
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                SizedBox(width: 4),
                                Text("Paid", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
                              child: const Text("Pay Now", style: TextStyle(color: Colors.white, fontSize: 12)),
                            )
                        ],
                      ),

                      if (data['resultFileUrl'] != null) ...[
                        const Divider(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _openResult(data['resultFileUrl']),
                            icon: const Icon(Icons.download, color: Colors.white),
                            label: const Text("View Test Results", style: TextStyle(color: Colors.white)),
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
