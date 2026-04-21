import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorOrderLabTestPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const DoctorOrderLabTestPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<DoctorOrderLabTestPage> createState() => _DoctorOrderLabTestPageState();
}

class _DoctorOrderLabTestPageState extends State<DoctorOrderLabTestPage> {
  void _orderTest(String testId, String testName, double price) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Order Lab Test"),
        content: Text("Are you sure you want to prescribe $testName to ${widget.patientName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Order"),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      try {
        await FirebaseFirestore.instance.collection('lab_orders').add({
          'patientId': widget.patientId,
          'patientName': widget.patientName,
          'doctorId': user.uid,
          'testId': testId,
          'testName': testName,
          'price': price,
          'paymentStatus': 'Unpaid',
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Test ordered successfully!")));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to order test: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("Order Lab Test"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Select a test to order for ${widget.patientName}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('laboratory_tests').orderBy('testName').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No tests available in catalog."));

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final testName = data['testName'] ?? 'Unknown Test';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.science, color: Colors.white),
                        ),
                        title: Text(testName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(data['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.teal)),
                          onPressed: () {
                            double price = 0.0;
                            if (data['price'] != null) {
                              price = data['price'] is int ? (data['price'] as int).toDouble() : data['price'] as double;
                            }
                            _orderTest(docs[index].id, testName, price);
                          },
                          child: const Text("Order", style: TextStyle(color: Colors.teal)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
