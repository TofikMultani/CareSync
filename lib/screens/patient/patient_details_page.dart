import 'package:flutter/material.dart';
import 'package:healthcare_system/screens/doctor/doctor_prescriptions.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:healthcare_system/screens/patient/upload_report_page.dart';


class PatientProfilePage extends StatelessWidget {
  final String name;
  final String age;
  final String city;
  final String mobile;
  final bool viewModeAdmin;

  const PatientProfilePage({
    super.key,
    required this.name,
    required this.age,
    required this.city,
    required this.mobile,
    this.viewModeAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF059669);
    final Color backgroundColor = const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Patient Profile", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A))),
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, const Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded, size: 40, color: Color(0xFF059669)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.cake_rounded, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text("$age yrs", style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Expanded(child: Text(city, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(mobile, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 🔹 Basic Information (Dashboard Style)
            Text(
              "Basic Information",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _InfoRow(icon: Icons.cake_rounded, label: "Age", value: "$age Years"),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const _InfoRow(icon: Icons.male_rounded, label: "Gender", value: "Male"),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const _InfoRow(icon: Icons.bloodtype_rounded, label: "Blood Group", value: "O+"),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const _InfoRow(icon: Icons.monitor_weight_rounded, label: "Weight", value: "68 kg"),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const _InfoRow(icon: Icons.height_rounded, label: "Height", value: "170 cm"),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const _InfoRow(icon: Icons.event_available_rounded, label: "Last Visit", value: "12 Jan 2026"),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 🔹 Health Summary
            Text(
              "Health Summary",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),

            const _SummaryCard(
              title: "Allergies",
              value: "No Known Allergies",
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
            ),
            const _SummaryCard(
              title: "Chronic Condition",
              value: "Diabetes (Type 2)",
              icon: Icons.favorite_rounded,
              color: Colors.pink,
            ),

            const SizedBox(height: 40),

            if (!viewModeAdmin) ...[
              // 💊 Give Prescription Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), // Slate 900
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorPrescriptionPage(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.medication_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Give Prescription",
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------- Reusable Widgets ----------------

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF059669)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.grey.shade600, fontSize: 14)),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF0F172A))),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      ),
    );
  }
}
