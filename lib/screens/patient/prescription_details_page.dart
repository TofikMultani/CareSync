import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrescriptionDetailsPage extends StatelessWidget {
  final String doctor;
  final String date;
  final List<Map<String, String>> medicines;

  const PrescriptionDetailsPage({
    super.key,
    required this.doctor,
    required this.date,
    required this.medicines,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription Details"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              _generatePdf();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _infoTile("Doctor", doctor),
            _infoTile("Date", date),

            const SizedBox(height: 16),
            const Text("Medicines",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            ...medicines.map((med) => Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.medication, color: Colors.teal),
                    title: Text(med["name"]!),
                    subtitle: Text("Timing: ${med["time"]}"),
                  ),
                )),

            const SizedBox(height: 20),
            const Text("Doctor Notes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Take medicines after food. Drink plenty of water. Avoid oily food.",
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _infoTile(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.info, color: Colors.teal),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  void _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Hospital Name",
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.Text("Prescription"),

              pw.SizedBox(height: 16),
              pw.Text("Doctor: $doctor"),
              pw.Text("Date: $date"),

              pw.SizedBox(height: 12),
              pw.Text("Medicines:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

              pw.Table.fromTextArray(
                headers: ["Medicine", "Timing"],
                data: medicines
                    .map((m) => [m["name"]!, m["time"]!])
                    .toList(),
              ),

              pw.SizedBox(height: 40),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Doctor Signature"),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
