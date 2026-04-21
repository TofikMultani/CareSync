import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDoctorPage extends StatefulWidget {
  final String doctorId;
  final Map<String, dynamic> doctorData;

  const EditDoctorPage({super.key, required this.doctorId, required this.doctorData});

  @override
  State<EditDoctorPage> createState() => _EditDoctorPageState();
}

class _EditDoctorPageState extends State<EditDoctorPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController doctorNameController;
  late TextEditingController phoneController;
  late TextEditingController licenseController;
  late TextEditingController specialtyController;
  late TextEditingController experienceController;
  late TextEditingController qualificationController;
  late TextEditingController hospitalController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    doctorNameController = TextEditingController(text: widget.doctorData['fullName'] ?? '');
    phoneController = TextEditingController(text: widget.doctorData['phone'] ?? '');
    licenseController = TextEditingController(text: widget.doctorData['license'] ?? '');
    specialtyController = TextEditingController(text: widget.doctorData['specialty'] ?? 'Select');
    experienceController = TextEditingController(text: widget.doctorData['experience']?.toString() ?? '');
    qualificationController = TextEditingController(text: widget.doctorData['qualification'] ?? '');
    hospitalController = TextEditingController(text: widget.doctorData['hospital'] ?? '');
  }

  Future<void> _updateDoctor() async {
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

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.doctorId).update({
        'fullName': doctorNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'license': licenseController.text.trim(),
        'specialty': specialtyController.text,
        'experience': experienceController.text.trim(),
        'qualification': qualificationController.text.trim(),
        'hospital': hospitalController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating doctor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
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
        title: const Text('Edit Doctor'),
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
                    child: Icon(Icons.edit_document,
                        size: 60, color: Colors.teal),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email (Read Only - Just for info)
                  TextFormField(
                    initialValue: widget.doctorData['email'] ?? 'N/A',
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Registered Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(height: 12),

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

                  // Update Button
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
                        : const Icon(Icons.save),
                      label: Text(
                        isSaving ? 'Saving...' : 'Save Changes',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: isSaving ? null : _updateDoctor,
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
    phoneController.dispose();
    licenseController.dispose();
    specialtyController.dispose();
    experienceController.dispose();
    qualificationController.dispose();
    hospitalController.dispose();
    super.dispose();
  }
}
