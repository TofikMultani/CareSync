import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications"), backgroundColor: Colors.teal),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.teal),
            title: Text("Appointment Confirmed"),
            subtitle: Text("Your appointment is confirmed for tomorrow."),
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.teal),
            title: Text("Prescription Uploaded"),
            subtitle: Text("Doctor uploaded your prescription."),
          ),
        ],
      ),
    );
  }
}
