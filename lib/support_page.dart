import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _supportCard(
              icon: Icons.call,
              title: "Call Hospital",
              subtitle: "+91 98765 43210",
              onTap: () {},
            ),
            _supportCard(
              icon: Icons.email,
              title: "Email Support",
              subtitle: "support@hospital.com",
              onTap: () {},
            ),
            _supportCard(
              icon: Icons.chat,
              title: "Live Chat",
              subtitle: "Chat with support team",
              onTap: () {},
            ),
            _supportCard(
              icon: Icons.help_outline,
              title: "FAQs",
              subtitle: "Common questions & answers",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.1),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
