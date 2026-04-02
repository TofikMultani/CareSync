//import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  final List<Map<String, String>> reports = const [
    {"title": "Blood Test", "date": "12 Jan 2026", "status": "Normal"},
    {"title": "X-Ray Chest", "date": "20 Jan 2026", "status": "Reviewed"},
    {"title": "MRI Scan", "date": "25 Jan 2026", "status": "Pending"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reports"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _reportTile(
            context,
            report["title"]!,
            report["date"]!,
            report["status"]!,
          );
        },
      ),
    );
  }

  Widget _reportTile(
      BuildContext context, String title, String date, String status) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.description, color: Colors.teal),
        title: Text(title),
        subtitle: Text("Date: $date"),
        trailing: IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
          onPressed: () async {
            await _generateSingleReportPdf(title, date, status);
          },
        ),
      ),
    );
  }

  Future<void> _generateSingleReportPdf(
      String title, String date, String status) async {
    final pdf = pw.Document();

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
                          "ABC HealthCare Center",
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
  }
}
