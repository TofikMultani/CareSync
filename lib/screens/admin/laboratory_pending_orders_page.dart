    import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class LaboratoryPendingOrdersPage extends StatefulWidget {
  const LaboratoryPendingOrdersPage({super.key});

  @override
  State<LaboratoryPendingOrdersPage> createState() => _LaboratoryPendingOrdersPageState();
}

class _LaboratoryPendingOrdersPageState extends State<LaboratoryPendingOrdersPage> {
  
  Future<void> _uploadResult(String orderId, String patientId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      withData: true,
    );
    
    if (result != null) {
      if (result.files.single.path == null && result.files.single.bytes == null) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Cannot read file format. Try again.")));
         return;
      }

      String name = result.files.single.name;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final storageRef = FirebaseStorage.instance.ref()
            .child('lab_results/$patientId/${DateTime.now().millisecondsSinceEpoch}_$name');
        
        UploadTask uploadTask;
        if (result.files.single.bytes != null) {
           uploadTask = storageRef.putData(result.files.single.bytes!);
        } else {
           File file = File(result.files.single.path!);
           uploadTask = storageRef.putFile(file);
        }
        
        final snapshot = await uploadTask;
        if (snapshot.state != TaskState.success) {
           throw Exception("Upload failed with state: ${snapshot.state}");
        }
        
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('lab_orders').doc(orderId).update({
          'status': 'Completed',
          'resultFileUrl': downloadUrl,
          'completedAt': FieldValue.serverTimestamp(),
        });
        
        if (mounted) Navigator.pop(context); // close dialog
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Result uploaded and order marked Completed!")));
      } catch (e) {
        if (mounted) Navigator.pop(context); // close dialog
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload error: $e")));
      }
    }
  }

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
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("Incoming Lab Orders"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('lab_orders').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No incoming laboratory orders."));

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              final isCompleted = data['status'] == 'Completed';
              final createdAt = data['createdAt'] as Timestamp?;
              final dateStr = createdAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(createdAt.toDate()) : 'Unknown Time';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['testName'] ?? 'Lab Test',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text("Patient: ${data['patientName'] ?? 'Unknown'}"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text("Ordered: $dateStr"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.payment, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text("Payment: ${data['paymentStatus'] ?? 'Unpaid'}", 
                            style: TextStyle(color: data['paymentStatus'] == 'Paid' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!isCompleted)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                            onPressed: () => _uploadResult(doc.id, data['patientId'] ?? ''),
                            icon: const Icon(Icons.upload_file),
                            label: const Text("Upload Test Results"),
                          ),
                        )
                      else if (data['resultFileUrl'] != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.teal)),
                            onPressed: () => _openResult(data['resultFileUrl']),
                            icon: const Icon(Icons.remove_red_eye, color: Colors.teal),
                            label: const Text("View Rendered Result", style: TextStyle(color: Colors.teal)),
                          ),
                        ),
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
