import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:healthcare_system/screens/patient/live_chat_page.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF059669);
    final Color backgroundColor = const Color(0xFFF8FAFC);

    final body = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How can we help you?",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Choose a method below to get in touch with our support team or find answers to common questions.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          
          _supportCard(
            icon: Icons.call_rounded,
            title: "Call Hospital",
            subtitle: "+91 98765 43210",
            primaryColor: primaryColor,
            onTap: () async {
              final Uri url = Uri.parse('tel:+919876543210');
              if (!await launchUrl(url)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch phone dialer.', style: GoogleFonts.plusJakartaSans())));
                }
              }
            },
          ),
          _supportCard(
            icon: Icons.email_rounded,
            title: "Email Support",
            subtitle: "careSync@healthcare.com",
            primaryColor: primaryColor,
            onTap: () async {
              final Uri url = Uri.parse('mailto:careSync@healthcare.com');
              if (!await launchUrl(url)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch email app.', style: GoogleFonts.plusJakartaSans())));
                }
              }
            },
          ),
          _supportCard(
            icon: Icons.chat_rounded,
            title: "Live Chat",
            subtitle: "Chat with support team",
            primaryColor: primaryColor,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveChatPage()));
            },
          ),
          _supportCard(
            icon: Icons.help_outline_rounded,
            title: "FAQs",
            subtitle: "Common questions & answers",
            primaryColor: primaryColor,
            onTap: () {
              _showFaqBottomSheet(context, primaryColor);
            },
          ),
        ],
      ),
    );

    if (!showScaffold) {
      return SafeArea(child: body);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Support", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A))),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: body,
    );
  }

  Widget _supportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFaqBottomSheet(BuildContext context, Color primaryColor) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Frequently Asked Questions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _faqItem(
                        primaryColor: primaryColor,
                        question: 'How can I book an appointment?',
                        answer: 'Navigate to the Appointments tab and choose your preferred doctor, date, and time slot. You will receive a confirmation once booked.',
                      ),
                      _faqItem(
                        primaryColor: primaryColor,
                        question: 'How do I upload reports?',
                        answer: 'Go to your Profile or the Home dashboard and select "Upload Medical Reports". You can choose files from your device to upload securely.',
                      ),
                      _faqItem(
                        primaryColor: primaryColor,
                        question: 'How do I contact emergency support?',
                        answer: 'Use the "Call Hospital" option on this support page for immediate assistance from our 24/7 emergency response team.',
                      ),
                      _faqItem(
                        primaryColor: primaryColor,
                        question: 'Can I reschedule an appointment?',
                        answer: 'Yes, go to your upcoming appointments, select the appointment you want to change, and choose "Reschedule".',
                      ),
                      _faqItem(
                        primaryColor: primaryColor,
                        question: 'How are my medical records secured?',
                        answer: 'We use industry-standard encryption to protect your data. Your records are only accessible to you and your authorized healthcare providers.',
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _faqItem({required Color primaryColor, required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: primaryColor,
          collapsedIconColor: Colors.grey.shade500,
          title: Text(
            question,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: const Color(0xFF0F172A),
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Text(
              answer,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
