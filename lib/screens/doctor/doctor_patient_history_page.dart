import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import 'package:healthcare_system/screens/doctor/doctor_order_lab_test_page.dart';

class DoctorPatientHistoryPage extends StatefulWidget {
  final String patientId;

  const DoctorPatientHistoryPage({super.key, required this.patientId});

  @override
  State<DoctorPatientHistoryPage> createState() => _DoctorPatientHistoryPageState();
}

class _DoctorPatientHistoryPageState extends State<DoctorPatientHistoryPage> {
  Map<String, dynamic>? patientData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.patientId).get();
      if (doc.exists) {
        if (mounted) setState(() => patientData = doc.data() as Map<String, dynamic>);
      }
      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = patientData?['fullName'] ?? 'Unknown Patient';
    final age = patientData?['age']?.toString() ?? 'N/A';
    final gender = patientData?['gender'] ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("Patient History"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 Patient Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff11998e), Color(0xff38ef7d)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(fontSize: 24, color: Colors.teal)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text("Age: $age • $gender",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Patient ID: ${widget.patientId.substring(0, 5)}",
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Action Buttons
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => DoctorOrderLabTestPage(patientId: widget.patientId, patientName: name),
                ));
              },
              icon: const Icon(Icons.science, color: Colors.teal),
              label: const Text("Order Lab Test", style: TextStyle(color: Colors.teal)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                side: const BorderSide(color: Colors.teal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Lab Orders Section
            const Text("Current Lab Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('lab_orders').where('patientId', isEqualTo: widget.patientId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                if (snapshot.data!.docs.isEmpty) return const Text("No active lab orders.");
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return _InfoTile(title: data['testName'] ?? 'Lab Test', subtitle: data['status'] ?? 'Pending', icon: Icons.science_outlined);
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // 🔹 Reports Section
            const Text(
              "Medical Reports",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reports').where('patientId', isEqualTo: widget.patientId).snapshots(),
              builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No reports uploaded by patient.");
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final reportTitle = data['title'] ?? 'Unknown Report';
                    final createdAt = data['createdAt'] as Timestamp?;
                    
                    String dateStr = "Unknown Date";
                    if (createdAt != null) {
                      dateStr = DateFormat('dd MMM yyyy').format(createdAt.toDate());
                    }

                    return _ReportCard(
                      reportName: reportTitle,
                      date: dateStr,
                      fileUrl: data['fileUrl'],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Custom Widgets ----------------

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.15),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String reportName;
  final String date;
  final String? fileUrl;

  const _ReportCard({
    required this.reportName,
    required this.date,
    this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xffe0f2f1),
          child: Icon(Icons.picture_as_pdf, color: Colors.teal),
        ),
        title: Text(reportName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date),
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

            if (reportName.toLowerCase().endsWith('.jpg') || reportName.toLowerCase().endsWith('.png') || reportName.toLowerCase().endsWith('.jpeg')) {
               showDialog(context: context, builder: (_) => AlertDialog(
                  title: Text(reportName),
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
                 return pw.Center(child: pw.Text("Medical Report: $reportName\nDate: $date", style: const pw.TextStyle(fontSize: 24)));
               }));
               try {
                 await Printing.layoutPdf(onLayout: (format) async => pdf.save());
               } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error viewing report: $e')));
               }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          icon: const Icon(Icons.visibility, size: 16),
          label: const Text("View"),
        ),
      ),
    );
  }
}
