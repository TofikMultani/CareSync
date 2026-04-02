import 'package:flutter/material.dart';
import 'package:healthcare_system/screens/patient/home_page.dart';
import 'package:healthcare_system/screens/admin/admin_page.dart';
import 'package:healthcare_system/screens/doctor/doctor_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedRole = "Patient";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_hospital, size: 60, color: Colors.teal),
                  const SizedBox(height: 10),
                  const Text("HealthCare Login",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 20),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: "Login As",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Admin", child: Text("Admin")),
                      DropdownMenuItem(value: "Doctor", child: Text("Doctor")),
                      DropdownMenuItem(value: "Patient", child: Text("Patient")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () {
                        if (selectedRole == "Admin") {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => const AdminPage()));
                        } else if (selectedRole == "Doctor") {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => const DoctorPage()));
                        } else {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => const HomePage()));
                        }
                      },
                      child: const Text("Login", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
