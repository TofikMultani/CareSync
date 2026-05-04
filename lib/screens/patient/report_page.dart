import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  final Color primaryColor = const Color(0xFF059669);
  final Color backgroundColor = const Color(0xFFF8FAFC);

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("My Reports", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A))),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : reports.isEmpty
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
                        child: Icon(Icons.description_rounded, size: 80, color: primaryColor.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 24),
                      Text("No Reports Found", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      Text("Your medical reports will appear here.", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch file', style: GoogleFonts.plusJakartaSans())));
    }
  }

  Widget _reportTile(
      BuildContext context, String id, String title, String date, String status, String? fileUrl) {
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
                  child: Icon(Icons.assignment_rounded, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: status.toLowerCase() == 'completed' || status.toLowerCase() == 'available' 
                                  ? primaryColor.withOpacity(0.1) 
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: status.toLowerCase() == 'completed' || status.toLowerCase() == 'available'
                                    ? primaryColor
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Color(0xFFF1F5F9), height: 1),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: fileUrl != null ? primaryColor : Colors.red.shade400,
                      side: BorderSide(color: fileUrl != null ? primaryColor : Colors.red.shade400, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (fileUrl != null) {
                        _openReport(fileUrl);
                      } else {
                        await _generateSingleReportPdf(title, date, status);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(fileUrl != null ? Icons.visibility_rounded : Icons.picture_as_pdf_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(fileUrl != null ? "View Report" : "Generate PDF", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                    onPressed: () async {
                       bool? confirm = await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                             title: Text("Delete Report", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                             content: Text("Are you sure you want to delete this report?", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade700)),
                             actions: [
                               TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontWeight: FontWeight.bold))),
                               TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Delete", style: GoogleFonts.plusJakartaSans(color: Colors.red.shade400, fontWeight: FontWeight.bold))),
                             ],
                          ),
                       );
                       if (confirm == true) {
                          await FirebaseFirestore.instance.collection('reports').doc(id).delete();
                          _fetchReports();
                       }
                    },
                  ),
                ),
              ],
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
                                fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor(0.02, 0.588, 0.412)),
                          ),
                        ],
                      ),
                      pw.Text("Medical Report",
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                    ],
                  ),

                  pw.SizedBox(height: 16),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 24),

                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor(0.97, 0.97, 0.97),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      border: pw.Border.all(color: PdfColors.grey300)
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text("Report Name: ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                            pw.Text(title, style: const pw.TextStyle(fontSize: 14)),
                          ]
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          children: [
                            pw.Text("Date: ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                            pw.Text(date, style: const pw.TextStyle(fontSize: 14)),
                          ]
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          children: [
                            pw.Text("Status: ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                            pw.Text(status, style: const pw.TextStyle(fontSize: 14)),
                          ]
                        ),
                      ]
                    )
                  ),

                  pw.SizedBox(height: 32),

                  pw.Text("Doctor's Remarks",
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor(0.02, 0.588, 0.412))),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    "Patient condition is stable. Continue prescribed medication and follow up after 7 days.",
                    style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey800, lineSpacing: 1.5),
                  ),

                  pw.Spacer(),

                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 16),

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
                              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                          pw.SizedBox(height: 8),
                          pw.Image(signImage, width: 100),
                          pw.SizedBox(height: 4),
                          pw.Text("Signature",
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                        ],
                      ),
                      pw.Text(
                        "Generated on:\n${DateTime.now()}",
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
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
