import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class LabPaymentPage extends StatefulWidget {
  final String orderId;
  final String testName;
  final double amount;

  const LabPaymentPage({
    super.key,
    required this.orderId,
    required this.testName,
    required this.amount,
  });

  @override
  State<LabPaymentPage> createState() => _LabPaymentPageState();
}

class _LabPaymentPageState extends State<LabPaymentPage> {
  bool _isProcessing = false;

  final Color primaryColor = const Color(0xFF059669);
  final Color backgroundColor = const Color(0xFFF8FAFC);

  void _launchUpi() async {
    setState(() => _isProcessing = true);

    // Provide a dummy merchant UPI ID for the hospital
    String upiId = "hospital.caresync@upi";
    String merchantName = "CareSync Hospital";
    String transactionNote = "Lab Test: ${widget.testName}";
    String amount = widget.amount.toStringAsFixed(2);
    
    // Construct the standard universal UPI intent link
    String upiUrl = "upi://pay?pa=$upiId&pn=${Uri.encodeComponent(merchantName)}&am=$amount&cu=INR&tn=${Uri.encodeComponent(transactionNote)}";
    
    Uri uri = Uri.parse(upiUrl);

    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("No UPI app found. Please install Google Pay, Paytm, or PhonePe.", style: GoogleFonts.plusJakartaSans()),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        // Since standard url_launcher cannot capture the transaction success from the external UPI app,
        // we will prompt the user to confirm if the payment was successful when they return.
        if (!mounted) return;
        _showConfirmationDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not open UPI apps: $e", style: GoogleFonts.plusJakartaSans())));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Payment Verification", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        content: Text("Did you complete the payment successfully in your UPI app?", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: Text("No / Failed", style: GoogleFonts.plusJakartaSans(color: Colors.red.shade500, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _markAsPaid();
            },
            child: Text("Yes, Successful", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsPaid() async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseFirestore.instance.collection('lab_orders').doc(widget.orderId).update({
        'paymentStatus': 'Paid',
        'paidAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(children: [
              const Icon(Icons.check_circle, color: Color(0xFF059669), size: 30),
              const SizedBox(width: 10),
              Text("Verified", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)))
            ]),
            content: Text("Your payment of \$${widget.amount.toStringAsFixed(2)} for ${widget.testName} has been recorded successfully.", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade700)),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return to previous screen
                },
                child: Text("Done", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving payment: $e", style: GoogleFonts.plusJakartaSans())));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("UPI Payment", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A))),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.qr_code_scanner_rounded, size: 64, color: primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              "Secure UPI Checkout", 
              style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              "Pay securely using any UPI app installed on your phone", 
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),

            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long_rounded, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Order Summary", 
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.testName, 
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                        ),
                      ),
                      Text(
                        "\$${widget.amount.toStringAsFixed(2)}", 
                        style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Pay Button
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [primaryColor, const Color(0xFF10B981)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isProcessing ? null : _launchUpi,
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_to_mobile_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            "Pay \$${widget.amount.toStringAsFixed(2)}", 
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              "Supported Payment Apps", 
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _miniAppIcon("GPay", Colors.blue.shade50),
                const SizedBox(width: 16),
                _miniAppIcon("PhonePe", Colors.purple.shade50),
                const SizedBox(width: 16),
                _miniAppIcon("Paytm", Colors.lightBlue.shade50),
                const SizedBox(width: 16),
                _miniAppIcon("BHIM", Colors.orange.shade50),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniAppIcon(String name, Color bg) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Text(
              name.substring(0, 1), 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.grey.shade800),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name, 
          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
