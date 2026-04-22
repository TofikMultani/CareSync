import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:healthcare_system/screens/patient/live_chat_page.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _supportCard(
            icon: Icons.call,
            title: "Call Hospital",
            subtitle: "+91 98765 43210",
            onTap: () async {
              final Uri url = Uri.parse('tel:+919876543210');
              if (!await launchUrl(url)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch phone dialer.')));
                }
              }
            },
          ),
          _supportCard(
            icon: Icons.email,
            title: "Email Support",
            subtitle: "careSync@healthcare.com",
            onTap: () async {
              final Uri url = Uri.parse('mailto:careSync@healthcare.com');
              if (!await launchUrl(url)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch email app.')));
                }
              }
            },
          ),
          _supportCard(
            icon: Icons.chat,
            title: "Live Chat",
            subtitle: "Chat with support team",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveChatPage()));
            },
          ),
          _supportCard(
            icon: Icons.help_outline,
            title: "FAQs",
            subtitle: "Common questions & answers",
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (sheetContext) {
                  return ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      ListTile(
                        leading:
                            Icon(Icons.question_answer, color: Colors.teal),
                        title: Text('How can I book an appointment?'),
                        subtitle: Text(
                            'Open Appointments and choose doctor, date, and time.'),
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.question_answer, color: Colors.teal),
                        title: Text('How do I upload reports?'),
                        subtitle: Text(
                            'Use Upload Medical Reports from your dashboard.'),
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.question_answer, color: Colors.teal),
                        title: Text('How do I contact emergency support?'),
                        subtitle: Text(
                            'Use Call Hospital option for immediate help.'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );

    if (!showScaffold) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: body,
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
