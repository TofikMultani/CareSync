import 'package:flutter/material.dart';
import 'package:healthcare_system/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare_system/screens/admin/admin_page.dart';
import 'package:healthcare_system/screens/doctor/doctor_page.dart';
import 'package:healthcare_system/screens/patient/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    await Future.delayed(const Duration(seconds: 2));

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          String role = userDoc.get('role') ?? 'Patient';
          if (!mounted) return;
          if (role == "Admin") {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const AdminPage()));
            return;
          } else if (role == "Doctor") {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const DoctorPage()));
            return;
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomePage()));
            return;
          }
        }
      } catch (e) {
        // Fail silently, go to login
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.local_hospital, size: 80, color: Colors.teal),
            SizedBox(height: 10),
            Text("CareSync",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.teal),
          ],
        ),
      ),
    );
  }
}
