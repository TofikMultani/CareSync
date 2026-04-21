import 'package:flutter/material.dart';
import 'package:healthcare_system/screens/admin/add_doctor_page.dart';

// This widget is used to add a button to ManageDoctorsPage FAB
extension AddDoctorFAB on num {
  // Helper for floating action button
}

// Show add doctor button in manage doctors page
FloatingActionButton buildAddDoctorFAB(BuildContext context) {
  return FloatingActionButton.extended(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddDoctorPage()),
      );
    },
    backgroundColor: Colors.teal,
    icon: const Icon(Icons.person_add),
    label: const Text('Add Doctor'),
  );
}
