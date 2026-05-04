import 'package:flutter/material.dart';
import 'package:healthcare_system/screens/patient/home_page.dart';
import 'package:healthcare_system/login_page.dart';
import 'package:healthcare_system/screens/patient/appointment_page.dart';
import 'package:healthcare_system/screens/patient/report_page.dart';
import 'package:healthcare_system/screens/patient/prescription_page.dart';
import 'package:healthcare_system/screens/patient/bmi_calculator_page.dart';
import 'package:healthcare_system/screens/change_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _userName = "Patient";
  String _userEmail = "";
  
  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) setState(() => _userEmail = user.email ?? "");
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _userName = doc.get('fullName') ?? 'Patient';
          });
        }
      } catch (e) {
        // Fallback
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC), // Soft Slate
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Icon(Icons.person, color: Color(0xFF059669), size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userName,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_userEmail.isNotEmpty)
                  Text(
                    _userEmail,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(context, Icons.dashboard_rounded, "Dashboard", const HomePage()),
                _drawerItem(context, Icons.calendar_month_rounded, "Appointments", const AppointmentPage()),
                _drawerItem(context, Icons.receipt_long_rounded, "Reports", const ReportPage()),
                _drawerItem(context, Icons.medication_liquid_rounded, "Prescriptions", const PrescriptionPage()),
                _drawerItem(context, Icons.monitor_weight_rounded, "BMI Calculator", const BmiCalculatorPage()),
                _drawerItem(context, Icons.security_rounded, "Change Password", const ChangePasswordPage()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: () => _showLogoutDialog(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2), // Light red bg
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
                    const SizedBox(width: 16),
                    Text(
                      "Logout",
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF059669), size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        onTap: () {
          Navigator.pop(context);
          // Only push if it's not HomePage, otherwise pushReplacement to avoid huge stack
          if (page is HomePage) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
          } else {
             Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Logout", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to log out of CareSync?", style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                 Navigator.pop(ctx);
                 Navigator.pushAndRemoveUntil(
                   context,
                   MaterialPageRoute(builder: (_) => const LoginPage()),
                   (route) => false,
                 );
              }
            },
            child: Text("Logout", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
