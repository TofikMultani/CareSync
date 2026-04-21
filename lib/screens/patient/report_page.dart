import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('reports')
            .where('patientId', isEqualTo: user.uid)
            .get();

        setState(() {
          reports = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
          
          // Sort locally to avoid Firebase composite index requirement
          reports.sort((a, b) {
            final dateA = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final dateB = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            return dateB.compareTo(dateA); // Descending
          });
          
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
      appBar: AppBar(
        title: const Text("My Reports"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? const Center(child: Text("No reports found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    String title = report['title'] ?? 'Medical Report';
                    String status = report['status'] ?? 'Pending';
                    String date = report['createdAt'] != null
                        ? DateFormat('dd MMM yyyy').format((report['createdAt'] as Timestamp).toDate())
                        : 'Unknown Date';

                    return _reportTile(
                      context,
                      report['id'],
                      title,
                      date,
                      status,
                      report['fileUrl'],
                    );
                  },
                ),
    );
  }

  void _openReport(String url) async {
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

  Widget _reportTile(
      BuildContext context, String id, String title, String date, String status, String? fileUrl) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.description, color: Colors.teal),
        title: Text(title),
        subtitle: Text("Date: $date"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (fileUrl != null)
              IconButton(
                icon: const Icon(Icons.remove_red_eye, color: Colors.teal),
                onPressed: () {
                  _openReport(fileUrl);
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                onPressed: () async {
                  await _generateSingleReportPdf(title, date, status);
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () async {
                 bool? confirm = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                       title: const Text("Delete Report"),
                       content: const Text("Are you sure you want to delete this report?"),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                         TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                       ],
                    ),
                 );
                 if (confirm == true) {
                    await FirebaseFirestore.instance.collection('reports').doc(id).delete();
                    _fetchReports();
                 }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateSingleReportPdf(
      String title, String date, String status) async {
    final pdf = pw.Document();

    try {
      final Uint8List logoBytes =
          (await rootBundle.load('assets/images/hospital_logo.png'))
              .buffer
              .asUint8List();

      final Uint8List signBytes =
          (await rootBundle.load('assets/images/doctor_signature.png'))
              .buffer
              .asUint8List();

      final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);
      final pw.MemoryImage signImage = pw.MemoryImage(signBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with Logo
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Row(
                        children: [
                          pw.Image(logoImage, width: 50),
                          pw.SizedBox(width: 10),
                          pw.Text(
                            "CareSync Center",
                            style: pw.TextStyle(
                                fontSize: 18, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                      pw.Text("Medical Report",
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),

                  pw.Divider(),
                  pw.SizedBox(height: 20),

                  pw.Text("Report Name: $title",
                      style: const pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 8),
                  pw.Text("Date: $date",
                      style: const pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 8),
                  pw.Text("Status: $status",
                      style: const pw.TextStyle(fontSize: 16)),

                  pw.SizedBox(height: 20),
                  pw.Divider(),

                  pw.Text("Doctor's Remarks",
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    "Patient condition is stable. Continue prescribed medication and follow up after 7 days.",
                    style: const pw.TextStyle(fontSize: 14),
                  ),

                  pw.Spacer(),

                  pw.Divider(),

                  // Doctor Signature
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Dr. H. Mehta",
                              style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text("MD (Medicine)",
                              style: const pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 6),
                          pw.Image(signImage, width: 100),
                          pw.Text("Signature",
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Text(
                        "Generated on:\n${DateTime.now()}",
                        style: const pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      // Ignore if image load fails
    }
  }
}
