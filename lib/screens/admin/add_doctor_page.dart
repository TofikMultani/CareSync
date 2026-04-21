import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AddDoctorPage extends StatefulWidget {
  const AddDoctorPage({super.key});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController(); // Added Password Field
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController specialtyController =
      TextEditingController(text: 'Select');
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();

  bool isSaving = false;

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;
    if (specialtyController.text == 'Select') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a specialty')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    FirebaseApp? secondaryApp;

    try {
      // 1. Create a secondary Firebase App instance to prevent Admin from being logged out
      secondaryApp = await Firebase.initializeApp(
        name: 'DoctorCreationApp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      // 2. Create the Doctor's FirebaseAuth User under the secondary app
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String newDoctorUid = userCredential.user!.uid;

      // 3. Save Doctor Profile into the primary Firebase Firestore database
      await FirebaseFirestore.instance.collection('users').doc(newDoctorUid).set({
        'fullName': doctorNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'license': licenseController.text.trim(),
        'specialty': specialtyController.text,
        'experience': experienceController.text.trim(),
        'qualification': qualificationController.text.trim(),
        'hospital': hospitalController.text.trim(),
        'role': 'Doctor',
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Doctor ${doctorNameController.text} account successfully securely provisioned!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auth Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding doctor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 4. Always clean up the secondary app memory
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
      
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Doctor'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(Icons.medical_services,
                        size: 60, color: Colors.teal),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Doctor Provisioning',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Doctor Name
                  TextFormField(
                    controller: doctorNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name (Dr.) *',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter doctor name' : null,
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Login *',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter email';
                      if (!value.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Initial Password *',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter an initial password';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Enter phone' : null,
                  ),
                  const SizedBox(height: 12),

                  // License Number
                  TextFormField(
                    controller: licenseController,
                    decoration: InputDecoration(
                      labelText: 'Medical License Number *',
                      prefixIcon: const Icon(Icons.shield),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter license' : null,
                  ),
                  const SizedBox(height: 12),

                  // Specialty
                  DropdownButtonFormField<String>(
                    value: specialtyController.text,
                    decoration: InputDecoration(
                      labelText: 'Specialty *',
                      prefixIcon: const Icon(Icons.local_hospital),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Select', child: Text('Select Specialty')),
                      DropdownMenuItem(
                          value: 'Physician', child: Text('Physician')),
                      DropdownMenuItem(
                          value: 'Cardiologist', child: Text('Cardiologist')),
                      DropdownMenuItem(
                          value: 'Orthopedic', child: Text('Orthopedic')),
                      DropdownMenuItem(
                          value: 'Pediatrician', child: Text('Pediatrician')),
                      DropdownMenuItem(
                          value: 'Dermatologist', child: Text('Dermatologist')),
                      DropdownMenuItem(
                          value: 'Surgeon', child: Text('Surgeon')),
                      DropdownMenuItem(value: 'ENT', child: Text('ENT')),
                    ],
                    onChanged: (value) => setState(
                        () => specialtyController.text = value ?? 'Select'),
                  ),
                  const SizedBox(height: 12),

                  // Years of Experience
                  TextFormField(
                    controller: experienceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Years of Experience *',
                      prefixIcon: const Icon(Icons.history),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter experience' : null,
                  ),
                  const SizedBox(height: 12),

                  // Qualification
                  TextFormField(
                    controller: qualificationController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Qualifications (MBBS, MD, etc.) *',
                      prefixIcon: const Icon(Icons.school),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter qualifications' : null,
                  ),
                  const SizedBox(height: 12),

                  // Hospital/Clinic Name
                  TextFormField(
                    controller: hospitalController,
                    decoration: InputDecoration(
                      labelText: 'Hospital/Clinic Name',
                      prefixIcon: const Icon(Icons.business),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: isSaving 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Icon(Icons.check_circle),
                      label: Text(
                        isSaving ? 'Provisioning...' : 'Provision Doctor Account',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: isSaving ? null : _saveDoctor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.teal, fontSize: 18)),
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

  @override
  void dispose() {
    doctorNameController.dispose();
    emailController.dispose();
    passwordController.dispose(); // Dispose new controller
    phoneController.dispose();
    licenseController.dispose();
    specialtyController.dispose();
    experienceController.dispose();
    qualificationController.dispose();
    hospitalController.dispose();
    super.dispose();
  }
}
