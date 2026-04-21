import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

class DoctorReportsPage extends StatelessWidget {
  const DoctorReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: Column(
        children: [
          const _Header(title: "Patient Reports"),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No patient reports available."));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final reportTitle = data['title'] ?? 'Unknown Report';
                    final patientId = data['patientId'];
                    final createdAt = data['createdAt'] as Timestamp?;
                    
                    String dateStr = "Unknown Date";
                    if (createdAt != null) {
                      dateStr = DateFormat('dd MMM yyyy').format(createdAt.toDate());
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: patientId != null ? FirebaseFirestore.instance.collection('users').doc(patientId).get() : null,
                      builder: (context, userSnapshot) {
                        String patientName = "Unknown Patient";
                        if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
                          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          patientName = userData['fullName'] ?? 'Unknown Patient';
                        }
                        
                        return _ReportCard(
                          patient: patientName,
                          report: reportTitle,
                          date: dateStr,
                          fileUrl: data['fileUrl'],
                        );
                      },
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

class _ReportCard extends StatelessWidget {
  final String patient;
  final String report;
  final String date;
  final String? fileUrl;

  const _ReportCard({
    required this.patient,
    required this.report,
    required this.date,
    this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.15),
          child: const Icon(Icons.description, color: Colors.orange),
        ),
        title: Text(patient, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$report • $date"),
        trailing: ElevatedButton.icon(
          onPressed: () async {
            if (fileUrl != null && fileUrl!.isNotEmpty) {
               if (fileUrl!.toLowerCase().contains('.jpg') || fileUrl!.toLowerCase().contains('.png') || fileUrl!.toLowerCase().contains('.jpeg')) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                    appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
                    backgroundColor: Colors.black,
                    body: Center(child: InteractiveViewer(child: Image.network(fileUrl!))),
                  )));
                  return;
               }
               final uri = Uri.parse(fileUrl!);
               if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                 if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch file')));
               }
               return;
            }

            if (report.toLowerCase().endsWith('.jpg') || report.toLowerCase().endsWith('.png') || report.toLowerCase().endsWith('.jpeg')) {
               showDialog(context: context, builder: (_) => AlertDialog(
                  title: Text(report),
                  content: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       const Icon(Icons.image, size: 80, color: Colors.teal),
                       const SizedBox(height: 10),
                       const Text("Image preview... (Simulated)"),
                     ]
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))]
               ));
            } else {
               final pdf = pw.Document();
               pdf.addPage(pw.Page(build: (pw.Context context) {
                 return pw.Center(child: pw.Text("Medical Report: $report\nPatient: $patient\nDate: $date", style: const pw.TextStyle(fontSize: 24)));
               }));
               try {
                 await Printing.layoutPdf(onLayout: (format) async => pdf.save());
               } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error viewing PDF: $e')));
               }
            }
          },
          icon: const Icon(Icons.visibility),
          label: const Text("View"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 140,
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
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
